public inherited sharing class ClsContractProcessor {

    private static Map<String,Business_Config__c> mapBusinessData { get; set; }
    private static List<Contract> contractsToUpdate;
    private static Map<String, Map<String,Map<String,Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    private static Contract con {get;set;}
    public static List<String> validServiceTypesForSwitch;
    public static Map<Id, Map<String, List<Contract>>> contractsByAccountId;
    private static final String BUSINESS_TYPE_SWITCH = 'Switch';
    private static final String STATUS_TERMINATED = 'Terminated';
    private static final String STATUS_EXPIRED = 'Expired';
    /**
     * @description contract active status
     */
    public static final String STATUS_ACTIVE = 'Activated';
    private static final String REASON_INVALID = 'Invalid';

    static Map<String,Map<String,Business_Config__c>> mapProcessData;

    static {
        validServiceTypesForSwitch = new List<String>{'Logistics Fee', 'Commission Fee'};
        mapProcessData = moam.get('ContractCreation');
    }

    public static void preventDuplicateContracts(List<Contract> newContracts) {
        //Map<String,Map<String,Business_Config__c>> mapProcessData= LibBusinessConfig.getGenericProcessData('ContractCreation');

        contractsToUpdate = new List<Contract>();
        // Map of Company Name VS (Map of Service Type VS Contract)
        Map<String,Map<String, List<Contract>>> contractByCompany = new Map<String,Map<String, List<Contract>>>();

        Set<Id> relatedAccountIds = new Set<Id>();

        for (Contract aContract :newContracts) {
            if (aContract.AccountId != null) {
                relatedAccountIds.add(aContract.AccountId);
            }
        }

        List<Contract> allContracts = [SELECT Id, AccountId, StartDate, End_Date__c, Status, Service_Type__c,IsTiered__c,
         									Company_Name__c,RecordType.DeveloperName,Id_Opportunity__c,Id_Opportunity__r.Business_Type__c,
         									Id_Opportunity_Quote_Line_Item__r.Id_List_Service_Price__r.Company__r.Name
                                        FROM Contract 
                                        WHERE Status != 'Terminated' 
                                        AND AccountId IN :relatedAccountIds /*and IsTiered__c = false*/];
        if(!allContracts.isEmpty()) {  
            mapBusinessData = mapProcessData.get(allContracts[0].RecordType.DeveloperName);
            //Updated the condition for null pointer exception by Magesh on 22.04.15
            //if(mapBusinessData!=null && !mapBusinessData.isEmpty() && mapBusinessData.get('GroupBeforeSorting') != null && mapBusinessData.get('GroupBeforeSorting').Business_Rule_Value__c != null && (mapBusinessData.get('GroupBeforeSorting').Business_Rule_Value__c != '' || mapBusinessData.get('GroupBeforeSorting').Business_Rule_Value__c != 'false')){
            //instead of the original code
            //if(mapBusinessData.get('GroupBeforeSorting') != null && (mapBusinessData.get('GroupBeforeSorting').Business_Rule_Value__c != null || mapBusinessData.get('GroupBeforeSorting').Business_Rule_Value__c != '' || mapBusinessData.get('GroupBeforeSorting').Business_Rule_Value__c != 'false')){ 
            if(mapBusinessData!=null && !mapBusinessData.isEmpty() && mapBusinessData.get('GroupBeforeSorting') != null && mapBusinessData.get('GroupBeforeSorting').Business_Rule_Value__c != null && (mapBusinessData.get('GroupBeforeSorting').Business_Rule_Value__c != '' || mapBusinessData.get('GroupBeforeSorting').Business_Rule_Value__c != 'false')){
                            
                if(!allContracts.isEmpty()){
                    for(Contract ct : allContracts){
                        // If there is quote line item connected take the company name from the Company_Name__c field
                        String companyName 	= !String.isBlank(ct.Id_Opportunity_Quote_Line_Item__r.Id_List_Service_Price__r.Company__r.Name) ?
                                            ct.Id_Opportunity_Quote_Line_Item__r.Id_List_Service_Price__r.Company__r.Name:
                                            ct.Company_Name__c;
                        companyName			= !String.isBlank(companyName) ? companyName : 'Company';
                        
                        if(contractByCompany.get(companyName) != null){
                            Map<String, List<Contract>> contractsByServiceType = contractByCompany.get(companyName);
                            if(contractsByServiceType.get(ct.Service_Type__c) != null){
                            contractsByServiceType.get(ct.Service_Type__c).add(ct);
                            } else {
                            contractsByServiceType.put(ct.Service_Type__c, new List<Contract>{ct});
                            }
                        }else{
                            Map<String, List<Contract>> contractsByServiceType = new Map<String, List<Contract>>();
                            contractsByServiceType.put(ct.Service_Type__c, new List<Contract>{ct});
                            contractByCompany.put(companyName,contractsByServiceType);
                        } 
                            
                    }
                    for(String company : contractByCompany.keySet()){
                        Map<String, List<Contract>> contractsByServiceType = contractByCompany.get(company);
                        for(String str : contractsByServiceType.keySet()){
                            performSort(contractsByServiceType.get(str));
                        }
                    }
                } else {
                    performSort(allContracts);
                }
            }
            
            try {
                Set<Contract> contractSetToUpdate = new Set<Contract>();
                contractSetToUpdate.addAll(contractsToUpdate);
                contractsToUpdate.clear();
                contractsToUpdate.addAll(contractSetToUpdate);

                update contractsToUpdate;
            } catch(Exception e) {
                newContracts[0].addError(Label.Account_Contract_Overlapping_Reorder_Error);
                System.debug('The following error occurred while reordering overlapping contracts on account : ' + e.getMessage());
            }
        }
    }

    /***************************************************************
        Purpose: Sorts the contracts which qualify as 'Switch' and populates the EndDate on the contracts in order of StartDate
        Parameters: List of contracts with related object fields - Opportunity Business Type and Company Name.
        Returns: void
        Exception Handling: None
    ***************************************************************/
    public static void processSwitchOpportunityContracts(List<Contract> newContracts) {
        List<Contract> contractsToUpdate = new List<Contract>();
        Set<Id> accountIds = ClsSObjectUtils.extractSetIds(newContracts, Contract.AccountId.getDescribe().getLocalName());
        List<Contract> contracts = ContractSelector.getContractsFromSwitchAccountsByIds(accountIds, getSwitchBusinessTypes(newContracts));
        newContracts = filterSwitchContracts(newContracts, new Map<Id, Contract>(contracts));
        if (newContracts.isEmpty()) {
            return;
        }
        Map<Id, Contract> newContractMap = new Map<Id, Contract>(newContracts);
        // prepare map of contracts by related account id
        contractsByAccountId = prepareMapOfContractsByServicetypeAndAccountId(contracts);


        for (Id accId :contractsByAccountId.keySet()) {    // iterate over each account
            Boolean foundSwitch = false;
            List<Contract> contractsToUpdateTemp = new List<Contract>();
            if (!contractsByAccountId.get(accId).containsKey(BUSINESS_TYPE_SWITCH)) { // if servicetype qualifies for switch, update the enddate accordingly
                continue;
            }
            // sort 'Switch' type contracts by startdate
            List<Contract> switchContracts = new List<Contract>();
            switchContracts = contractsByAccountId.get(accId).get(BUSINESS_TYPE_SWITCH);
            LibOpportunityLineItemsHelper.sortList(switchContracts, Contract.StartDate.getDescribe().getLocalName(), 'ASC');
            for (Integer i = 0; i < switchContracts.size(); i++) {
                if (newContractMap.containsKey(switchContracts.get(i).Id)) {
                    foundSwitch = true;
                } else if (!newContractMap.containsKey(switchContracts.get(i).Id) && !foundSwitch && i != switchContracts.size()-1) {
                    switchContracts.get(i).End_Date__c = switchContracts.get(i+1).StartDate.addDays(-1);
                    if (switchContracts.get(i).End_Date__c < switchContracts.get(i).StartDate) {
                        terminateSwitchContract(switchContracts.get(i));
                    }
                } else if (!newContractMap.containsKey(switchContracts.get(i).Id) && foundSwitch) {
                    terminateSwitchContract(switchContracts.get(i));
                }
                contractsToUpdateTemp.add(switchContracts.get(i));
            }
            if (foundSwitch) {
                contractsToUpdate.addAll(contractsToUpdateTemp);
            }
        }
        update contractsToUpdate;
    }

    private static void terminateSwitchContract(Contract contract) {
        contract.Status = STATUS_TERMINATED;
        contract.Termination_Reason__c = REASON_INVALID;
        contract.End_Date__c = contract.StartDate;
    }

    private static List<Contract> filterSwitchContracts(List<Contract> contracts, Map<Id, Contract> contractsToCompare) {
        List<Contract> filteredContracts = new List<Contract>();
        for (Contract cont : contracts) {
            Set<String> businessTypes = getSwitchBusinessTypes(new List<Contract> {cont});
            for (String businessType: businessTypes) {
                if (contractsToCompare.containsKey(cont.Id) && contractsToCompare.get(cont.Id).Id_Opportunity__r.Business_Type__c == businessType) {
                    filteredContracts.add(cont);
                }
            }
        }
        return filteredContracts;
    }

    private static Set<String> getSwitchBusinessTypes(List<Contract> contracts) {

        Set<String> businessTypes = new Set<String> {BUSINESS_TYPE_SWITCH};
        Set<Id> recordTypeIds = ClsSObjectUtils.extractSetIds(contracts, Contract.RecordTypeId.getDescribe().getLocalName());
        for (Id recordTypeId: recordTypeIds) {
            Business_Config__c additionalTypes = LibBusinessConfig.getBusinessConfigFromRuleMap('ContractCreation', recordTypeId, 'additionalSwitchBusinessTypes');
            if (additionalTypes != null && String.isNotBlank(additionalTypes.Business_Rule_Value__c)) {
                businessTypes.addAll(additionalTypes.Business_Rule_Value__c.replaceAll(' ,|, ', ',').split(','));
            }
        }
        return businessTypes;
    }


    /***************************************************************
        Purpose: Prepare a map of contracts by Service Type and Account Id. 'Switch' is a collective servicetype
        Parameters: List of contracts with related object fields - Opportunity Business Type and Company Name.
        Returns: Nested Map of contracts by servicetype by related AccountId
        Exception Handling: None
    ***************************************************************/
    public static Map<Id, Map<String, List<Contract>>> prepareMapOfContractsByServicetypeAndAccountId (List<Contract> contracts) {
        
        Map<Id, Map<String, List<Contract>>> contractsByAccountId = new Map<Id, Map<String, List<Contract>>>(); // map <accountid, <Service Type, Contract[]>>

        for (Contract aContract :contracts) {
            if (contractsByAccountId.containsKey(aContract.AccountId)) {    // accountId present in map
                if (mapProcessData.containsKey(LibRecordTypeHelper.getRecordTypeValue(aContract.RecordTypeId))
                        && mapProcessData.get(LibRecordTypeHelper.getRecordTypeValue(aContract.RecordTypeId)).containsKey('validServiceTypesForSwitch')
                        && String.isNotBlank(mapProcessData.get(LibRecordTypeHelper.getRecordTypeValue(aContract.RecordTypeId)).get('validServiceTypesForSwitch').Business_Rule_Value__c)) {
                    validServiceTypesForSwitch = mapProcessData.get(LibRecordTypeHelper.getRecordTypeValue(aContract.RecordTypeId)).get('validServiceTypesForSwitch').Business_Rule_Value__c.split(',');
                }
                if (validServiceTypesForSwitch.contains(aContract.Service_Type__c) && aContract.Id_Opportunity__r.Business_Type__c != null ) {
                    // create special servicetype 'Switch'
                    if (contractsByAccountId.get(aContract.AccountId).containsKey(BUSINESS_TYPE_SWITCH)) {
                        contractsByAccountId.get(aContract.AccountId).get(BUSINESS_TYPE_SWITCH).add(aContract);
                    } else {
                        Map<String, List<Contract>> contractsToBusinesstypeMap = contractsByAccountId.get(aContract.AccountId);
                        contractsToBusinesstypeMap.put(BUSINESS_TYPE_SWITCH, new List<Contract>());
                        contractsToBusinesstypeMap.get(BUSINESS_TYPE_SWITCH).add(aContract);
                    }
                }
                // add servicetype to map anyway
                if (contractsByAccountId.get(aContract.AccountId).containsKey(aContract.Service_Type__c)) {
                    contractsByAccountId.get(aContract.AccountId).get(aContract.Service_Type__c).add(aContract);
                } else {
                    Map<String, List<Contract>> contractsToBusinesstypeMap = contractsByAccountId.get(aContract.AccountId);
                    contractsToBusinesstypeMap.put(aContract.Service_Type__c, new List<Contract>());
                    contractsToBusinesstypeMap.get(aContract.Service_Type__c).add(aContract);
                }
                
            } else {    // Account Id not in map. Create new entry for it
                Map <String, List<Contract>> contractsToBusinesstypeMap = new Map <String, List<Contract>>();
                // create new entry for contractsToBusinesstypeMap and add to contractsByAccountId
                if (validServiceTypesForSwitch.contains(aContract.Service_Type__c) && aContract.Id_Opportunity__r.Business_Type__c != null ) {
                    // create special servicetype 'Switch'
                    contractsToBusinesstypeMap.put(BUSINESS_TYPE_SWITCH, new List<Contract>());
                    contractsToBusinesstypeMap.get(BUSINESS_TYPE_SWITCH).add(aContract);
                }
                // add servicetype to map anyway
                contractsToBusinesstypeMap.put(aContract.Service_Type__c, new List<Contract>());
                contractsToBusinesstypeMap.get(aContract.Service_Type__c).add(aContract);
                
                contractsByAccountId.put(aContract.AccountId, contractsToBusinesstypeMap);
            }
        }

        return contractsByAccountId;
    }

    public static void performSort(List<Contract> contracts){
        if(contracts.size() > 1){
            LibOpportunityLineItemsHelper.sortList(contracts, 'StartDate', 'ASC');
            for(Integer i = 0; i < contracts.size() - 1; i++){
                if(!contracts[i].IsTiered__c && contracts[i].Id_Opportunity__c!=contracts[i+1].Id_Opportunity__c){
                    contracts[i].End_Date__c = contracts[i+1].StartDate.addDays(-1);
                    contractsToUpdate.add(contracts[i]);
                }else if(contracts[i].IsTiered__c && contracts[i].Id_Opportunity__c!=contracts[contracts.size()-1].Id_Opportunity__c){
                    contracts[i].End_Date__c =contracts[contracts.size()-1].StartDate.addDays(-1);
                    contractsToUpdate.add(contracts[i]);
                }
            }
        }
    }
    
    public static void publishCommissionOnEventBus(List<Contract> conLst, Map<Id,Contract> oldConMap){
        Map<String,Business_Config__c> mapBusinessData =new Map<String,Business_Config__c>();
        Map<String,Map<String,Business_Config__c>> mapProcessData= moam.get('EventBusCommission');
        List<Id> conLstToEventBus = new List<Id>();
        List<Backend_Integration__e> lstBackendInt =new List<Backend_Integration__e>();
        if(mapProcessData!=null && !mapProcessData.isEmpty()){
            for(Contract c:conLst){
                mapBusinessData = mapProcessData.get(LibRecordTypeHelper.getRecordTypeValue(c.RecordTypeId));
                if(mapBusinessData!=null && !mapBusinessData.isEmpty() && Boolean.valueOf(mapBusinessData.get('SendToEventBus').Business_Rule_Value__c )
                    &&(oldConMap!=null && c.Status=='Activated' && c.Status!=oldConMap.get(c.Id).Status)
                        || (c.Status=='Activated' && oldConMap==null) ){
                        conLstToEventBus.add(c.Id);

                }

            }

            if(!conLstToEventBus.isEmpty()){


                for(Contract con: [SELECT id,
                                          Name,
                                        Name__c,
                                            Commission_per_order__c,
                                          Commission__c,
                                          Service_Type__c,
                                          AccountId,
                                          StartDate,
                                          End_Date__c,
                                          Status,
                                          recordtype.developername,
                                          Account.Backend_ID__c,
                                          Account.Record_country__c,
                                        Account.Account_Country_Code__c,
                                          Account.type,
                                          Account.Grid__c,
                                          Billable_Account__r.grid__c,
                                        Based_On__c,
                                        Scaled__c,
                                        Commission_Type__c,
                                          Id_Opportunity__r.Id_tarif__r.Name,
                                          (SELECT id,
                                                  Max__c,
                                                  Min__c,
                                                  Commission_per_order__c,
                                                  Commission_in_percentage__c 
                                            FROM Tiers__r)
                                    FROM Contract
                                    WHERE Id IN:conLstToEventBus])

                {   

                    Backend_Integration__e b = new Backend_Integration__e(Salesforce_Id__c = con.Id,
                    Account_BackendID__c = con.Account.Backend_ID__c,
                    Account_Country__c = con.Account.Record_country__c,
                    Record_type__c = con.Recordtype.developername,
                    Account_Type__c = con.Account.type,
                    Commission_Name__c = con.Name__c,
                    Commission_Type__c = con.Service_Type__c,
                    Start_Date__c = con.StartDate,
                    End_Date__c = con.End_Date__c,
                    Status__c = con.Status,
                    Account_GRID__c  = con.Account.GRID__c,
                    Account_Country_Code__c  = con.Account.Account_Country_Code__c,
                    Tariff_Name__c=con.Id_Opportunity__r.Id_Tarif__r.Name,
                    Event_Type__c = 'Commission',
                    Billable_Account_grid__c=con.Billable_Account__r.grid__c,
                    Commission_Based_On__c = con.Based_On__c,
                    Commission_Value_Type__c = con.Commission_Type__c);


                    if(con.Scaled__c){
                        JSONGenerator jsonGen =  JSON.createGenerator(false);
                        
                        jsonGen.writeStartArray();
                        
                        for(Tier__c t:con.Tiers__r){

                            jsonGen.writeStartObject();
                            jsonGen.writeNumberField('Min',t.Min__c);
                            if(t.Max__c!=null)
                                jsonGen.writeNumberField('Max',t.Max__c);                            
                            if(con.Commission_Type__c=='Percentage'){
                                jsonGen.writeNumberField('Commission_Value__c',t.Commission_In_percentage__c);
                            } else {
                                jsonGen.writeNumberField('Commission_Value__c', t.Commission_per_order__c);
                            }
                             jsonGen.writeEndObject();

                        }
                        jsonGen.writeEndArray();
            
                        
                        b.Commission_Tiers__c= jsonGen.getAsString();

                    }else{

                        if(con.Commission_Type__c=='Percentage'){
                            b.Commission__c= con.Commission__c;

                        }else {
                            b.Commission__c = con.Commission_Per_Order__c;
                        }
                    }
                    lstBackendInt.add(b);
                }
                if(!lstBackendInt.isEmpty()){
                    EventBusHelper.publishEvents(lstBackendInt);
                }

            }
        }
    }


    /*******************************************************************************************************
    * @description sets Platform Performance online/offline status based on active contracts
    * @param newContractsById Map<Id, Contract> new or updated contracts. (Trigger.newMap)
    * @return null
    */
    public static List<Platform_Performance__c> setPlatformStatus(Map<Id, Contract> newContractsById) {
        List<String> validServiceTypesForPlatformStatusChange;
        Set<Id> accountIdsToQuery = new Set<Id>();
        List<Platform_Performance__c> platformPerformanceToUpdate = new List<Platform_Performance__c>();
        Map<Id, List<Contract>> contractsByAccountId = new Map<Id, List<Contract>>();

        for (Contract aContract :newContractsById.values()) {
            Business_Config__c relatedBusinessConfig = LibBusinessConfig.getBusinessConfigFromRuleMap('ContractCreation',aContract.RecordTypeId,'validServiceTypesForPlatformStatusChange');
            if (relatedBusinessConfig != null) {
                validServiceTypesForPlatformStatusChange = getServiceTypesForStatusChange(relatedBusinessConfig, ',');
                if (validServiceTypesForPlatformStatusChange != null && validServiceTypesForPlatformStatusChange.contains(aContract.Service_Type__c)) {
                    accountIdsToQuery.add(aContract.AccountId);
                    if (contractsByAccountId.containsKey(aContract.AccountId)) {
                        contractsByAccountId.get(aContract.AccountId).add(aContract);
                    } else {
                        contractsByAccountId.put(aContract.AccountId, new List<Contract>{
                                aContract
                        });
                    }
                }
            }
        }
        // check if are there any active contracts for the account by platform and set status field for the platform performance
        List<Contract> relatedContracts = ContractSelector.getActiveContractsForAccounts(accountIdsToQuery);
        List<Platform_Performance__c> platformPerformance = PlatformPerformanceSelector.getPlatformPerformancesForAccounts(accountIdsToQuery);

        for (Contract aContract :relatedContracts) {
            Business_Config__c relatedBusinessConfig = LibBusinessConfig.getBusinessConfigFromRuleMap('ContractCreation',aContract.RecordTypeId,'validServiceTypesForPlatformStatusChange');
            if (relatedBusinessConfig != null) {
                validServiceTypesForPlatformStatusChange = getServiceTypesForStatusChange(relatedBusinessConfig, ',');
                if (!newContractsById.containsKey(aContract.Id) && validServiceTypesForPlatformStatusChange != null && validServiceTypesForPlatformStatusChange.contains(aContract.Service_Type__c)) {
                    contractsByAccountId.get(aContract.AccountId).add(aContract);
                }
            }
        }

        for (Platform_Performance__c pp :platformPerformance) {
            if (contractsByAccountId.containsKey(pp.Account__c) ) {
                if (pp.Vendor_Status__c != ContractSelector.ONLINE_STATUS_ACTIVE && checkForActiveContract(pp, contractsByAccountId.get(pp.Account__c)) == ContractSelector.ONLINE_STATUS_ACTIVE) {
                    pp.Vendor_Status__c = ContractSelector.ONLINE_STATUS_ACTIVE;
                    platformPerformanceToUpdate.add(pp);
                } else if (pp.Vendor_Status__c != ContractSelector.ONLINE_STATUS_PENDINGACTIVATION && checkForActiveContract(pp, contractsByAccountId.get(pp.Account__c)) == ContractSelector.ONLINE_STATUS_PENDINGACTIVATION) {
                    pp.Vendor_Status__c = ContractSelector.ONLINE_STATUS_PENDINGACTIVATION;
                    platformPerformanceToUpdate.add(pp);
                } else if (pp.Vendor_Status__c != ContractSelector.ONLINE_STATUS_TERMINATED && checkForActiveContract(pp, contractsByAccountId.get(pp.Account__c)) == ContractSelector.ONLINE_STATUS_TERMINATED) {
                    pp.Vendor_Status__c = ContractSelector.ONLINE_STATUS_TERMINATED;
                    platformPerformanceToUpdate.add(pp);
                }
            }
        }

        return platformPerformanceToUpdate;

    }

    /*******************************************************************************************************
    * @description sets Platform Performance online/offline status based on active contracts
    * @param platformPerformance - Platform_Performance__c
    * @param relatedContracts - List<Contract> - Contracts related to the same account as platform performance
    * @return Boolean - true for an active contract, false for none
    */
    private static String checkForActiveContract(Platform_Performance__c platformPerformance, List<Contract> relatedContracts) {
        Boolean hasUpcomingContract = false;

        for (Contract c : relatedContracts) {
            String companyName = !String.isBlank(c.Company__c) ? c.Company__c : c.Company_Name__c;

            if (String.isBlank(companyName) || !companyName.trim().startsWith(platformPerformance.Platform__c.trim()) || c.Status == ContractSelector.ONLINE_STATUS_TERMINATED) {
                continue;
            }
            Boolean isContractActive = c.StartDate <= Date.today() && ( c.End_Date__c == null || (c.End_Date__c >= Date.today() && c.StartDate < c.End_Date__c));
            if (isContractActive) {
                return ContractSelector.ONLINE_STATUS_ACTIVE;
            } else if (c.StartDate > Date.today() && (c.End_Date__c > Date.today() || c.End_Date__c == null)) {
                hasUpcomingContract = true;
            }
        }
        if (hasUpcomingContract) {
            return ContractSelector.ONLINE_STATUS_PENDINGACTIVATION;
        }

        return ContractSelector.ONLINE_STATUS_TERMINATED;
    }

    /*******************************************************************************************************
    * @description returns a list of values from a business config rule
    * @param businessConfig - Business_Config__c
    * @param separatorString - String - string seperator regex
    * @return List<String> - list of values from the rule
    */
    private static List<String> getServiceTypesForStatusChange(Business_Config__c businessConfig, String separatorString) {
        List<String> serviceTypes = new List<String>();
        String[] ruleValues = businessConfig.Business_Rule_Value__c.split(separatorString);

        for (Integer i = 0; i < ruleValues.size(); i++) {
            serviceTypes.add(ruleValues[i].trim());
        }
        return serviceTypes;
    }

    /**
     * @description Update Account delivery service based on active/expired contracts
     *
     * @param contracts contracts that have been updated
     */
    public static void updateAccountDeliveryService(List<Contract> contracts) {
        Set<Object> serviceTypes = new Set<Object>();
        Set<Object> recordTypeIds = new Set<Object>();
        for (Contract commission: contracts) {
            if (recordTypeIds.contains(commission.RecordTypeId)) {
                continue;
            }
            Business_Config__c config = LibBusinessConfig.getBusinessConfigFromRuleMap('ContractCreation', commission.RecordTypeId, 'deliveryServiceTypes');
            Business_Config__c config2 = LibBusinessConfig.getBusinessConfigFromRuleMap('ContractCreation', commission.RecordTypeId, 'deliveryServiceTypesMap');
            if (config != null && config.Business_Rule_Value__c != null && config2 != null && config2.Business_Rule_Value__c != null) {
                recordTypeIds.add(commission.RecordTypeId);
                serviceTypes.addAll((List<Object>) config.Business_Rule_Value__c.replaceAll(' ,|, ', ',').split(','));
            }
        }

        if (recordTypeIds.isEmpty()) {
            return;
        }

        Map<String, Set<Object>> filter = new Map<String, Set<Object>> {
                Contract.Status.getDescribe().getLocalName() => new Set<Object> { STATUS_ACTIVE, STATUS_EXPIRED, STATUS_TERMINATED },
                Contract.Service_Type__c.getDescribe().getLocalName() => serviceTypes,
                Contract.RecordTypeId.getDescribe().getLocalName() => recordTypeIds
        };
        List<Contract> filteredContracts = ClsSObjectUtils.filterFieldValues(contracts, filter, true);
        Set<Id> accountIds = ClsSObjectUtils.extractSetIds(filteredContracts, Contract.AccountId.getDescribe().getLocalName());
        List<Account> accounts = ClsAccountProcessor.updateDeliveryService(accountIds, (Set<String>)JSON.deserialize(JSON.serialize(serviceTypes), Set<String>.class));
        if (accounts == null) {
            return;
        }
        update accounts;
    }
}