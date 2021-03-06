public without sharing class ClsAccountProcessor {

    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    public static final string ERROR_MAPPING_ADDRESS_FAILED = 'Mapping Of Address Failed On Address';
    public static final string METHOD_COPY_FACILITY_ADDRESS = 'copyFacilityAddressToAssociatedKitchen Method : ';
    public static final string ERROR_INSERT_UPDATE_ADDRESS_FAILED = 'InsertOrUpdateFailed On Address Object';
    public static final string METHOD_UPDATE_DELETE_ADDRESS = 'updateAndDeleteAddressDetail Method : ';

    /**
     * @description Update account country on related records
     *
     * @param accounts
     * @param oldMap
     */
    public static void updateRelatedRecordCountries(List<Account> accounts, Map<Id, Account> oldMap) {
        List<Account>  filteredAccounts = ClsSObjectUtils.filterFieldValues(accounts, oldMap, new Map<String, Set<Object>>{
                Account.Record_Country__c.getDescribe().getLocalName() => new Set<Object>()
        });
        if (filteredAccounts.isEmpty()) { return; }
        Map<Id, Account> accountMap = new Map<Id, Account>(filteredAccounts);
        List<Asset__c> assets = AssetSelector.findActiveByAccountIds(accountMap.keySet());
        List<Branding_Content__c> brandings = BrandingContent_Selector.findByAccountIds(accountMap.keySet());
        if (brandings.isEmpty() && assets.isEmpty()) {return;}
        Integer loopSize = assets.size() > brandings.size() ? assets.size() : brandings.size();
        for (Integer index = 0; index < loopSize; index++) {
            if (index < assets.size()) {
                Asset__c asset =  assets.get(index);
                asset.Account_Country__c = accountMap.get(asset.Account__c).Record_Country__c;
             }
            if (index < brandings.size()) {
                Branding_Content__c brandingContent = brandings.get(index);
                brandingContent.Account_Country__c = accountMap.get(brandingContent.Restaurant_Name__c).Record_Country__c;
            }
        }
        List<SObject> allItems = new List<SObject>((List<SObject>)assets);
        allItems.addAll((List<SObject>) brandings);
        update allItems;
    }

    /**
     * Called before insert and before update, validates the Delivery Service on Account 
     * @param accounts
     */
    public static void validateAccountDeliveryService(List<Account> accs, Map<Id, Account> oldAccounts){
        
        ClsSObjectUtils.validateLeadDeliveryService(accs);
    }
	
    public static void assignRecordCountryToBillingCountry(List<Account> newList, Map<Id, Account> oldMap) {
        for (Account acc : newList) {
            if (acc.Record_Country__c != null && (oldMap == null || (oldMap != null && oldMap.get(acc.id) != null && acc.Record_Country__c != oldMap.get(acc.id).Record_Country__c))) {
                acc.BillingCountry = acc.Record_Country__c;
            }
        }
    }

    /**
     * According to RestrictBillingAndMailingCityValues business config checks that
     * BillingCity field's value is contained in a set of specific values.
     * Possible values are retrieved using the utility class ClsBEIntegrationUtils
     * @param newAccounts new accounts or updated one
     * @param oldAccounts old account map or an empty map
     */
    public static void checksBillingAndMailingCityValues(List<Account> newAccounts, Map<Id, Account> oldAccounts) {

        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('RestrictBillingAndMailingCityValues');

        if (mapBusinessLogic == null) {
            return; // nothing to do
        }

        Map<Id, String> accountIdToCountryName = new Map<Id, String>();
        Map<Id, RecordType> recType;
        Map<String, String> countryNameToIsoCode;
        Set<Id> recTypeIds = new Set<Id>();
        Set<String> countryNames = new Set<String>();

        List<Account> accountsToCheck = new List<Account>();

        // gets rec type ids
        for (Account acc : newAccounts) {

            // checks that BillingCity has changed
            if (oldAccounts != null && oldAccounts.containsKey(acc.Id)) {
                if (acc.BillingCity == oldAccounts.get(acc.Id).BillingCity) {
                    continue;
                }
            }

            // checks for blank values
            if (String.isBlank(acc.BillingCity) || String.isBlank(acc.Record_Country__c)) {
                continue;
            }

            accountsToCheck.add(acc);
            countryNames.add(acc.Record_Country__c);
            recTypeIds.add(acc.RecordTypeId);
        }

        if (accountsToCheck.isEmpty()) {
            return; // nothing to do
        }

        // gets developer name
        recType = new Map<Id, RecordType>([Select DeveloperName From RecordType Where Id in: recTypeIds]);
        recTypeIds.clear();

        // gets country codes
        countryNameToIsoCode = new Map<String, String>();
        for (Country__c c : [Select Name, Iso__c from Country__c Where Name in: countryNames]) {
            countryNameToIsoCode.put(c.name, c.Iso__c);
        }
        countryNames.clear();

        for (Account acc : accountsToCheck) {

            if (!mapBusinessLogic.containsKey(recType.get(acc.RecordTypeId).DeveloperName)) {
                continue; // nothing to do for this one
            }

            Map<String, Business_Config__c> mapProcessData = mapBusinessLogic.get(
                        recType.get(acc.RecordTypeId).DeveloperName);

            if (!mapProcessData.containsKey('checkBillingAndMailingCity')
                    || !Boolean.valueOf(mapProcessData.get('checkBillingAndMailingCity').Business_Rule_Value__c)) {
                continue; // check disabled
            }

            // checks city value
            if (!ClsBEIntegrationUtils.isValidCity(acc.BillingCity, countryNameToIsoCode.get(acc.Record_Country__c))) {
                // build error message
                String errMsg = String.format(System.Label.AccountBillingCityNotValid, new List<String> {
                    acc.BillingCity,
                    String.valueOf(ClsBEIntegrationUtils.getCitiesByCountryCode(countryNameToIsoCode.get(acc.Record_Country__c)))
                });

                acc.BillingCity.addError(errMsg);
            }
        }

    }

    /**
     * Called after insert, set GRID value on new account. Skips account with a
     * GRID not blank, since could be the one coming from Lead conversion
     * @param accounts new account records
     */
    public static void setGRID(List<Account> accounts) {

        List<Account> toUpdate = new List<Account>();

        for (Account acc : accounts) {

            // skips account with already a grid id
            if (String.isNotBlank(acc.GRID__c)) {
                continue;
            }

            String grid = UtilsGlobalIdentifier.getGlobalIdentifierFromSequenceNumber(
                              Integer.valueOf(acc.GRIDSequence__c));

            toUpdate.add(
                new Account(Id = acc.Id,
                            GRID__c = grid)
            );

        }

        if (!toUpdate.isEmpty() && !Test.isRunningTest()) {
            update toUpdate;

            /* At this point you might ask yourself why the f*** he did this...
            Well, when I wrote this method Salesforce had this bug: https://success.salesforce.com/issues_view?id=a1p300000008XFyAAM
            Basically during test class auto number field are not unique...
            This caused lot of test class to fail because of the unique constraint we
            have on the GRID field, that depends on the Grid Sequence...
            As always AMAZING SALESFORCE EXPERIENCE :S */
        }

    }

    /**
     * Called before update, verify that grid is in sync with the sequence number.
     * Checks is performed only if grid has changed
     * @param accounts updated account
     * @param oldAccounts previous account records
     */
    public static void verifyGRID(List<Account> accounts, Map<Id, Account> oldAccounts) {

        for (Account acc : accounts) {

            if (acc.GRID__c == oldAccounts.get(acc.Id).GRID__c) {
                continue; // nothing to check here
            }

            Integer seq = UtilsGlobalIdentifier.getSequenceNumberFromGlobalIdentifier(acc.GRID__c);

            if (seq != Integer.valueOf(acc.GRIDSequence__c)) {
                acc.addError(Label.GRID_Out_of_sync);
            }
        }
    }
    
    /**
     * @Description: This method checks whether the ownership has been changed and sets the details to MIDAS
     * @Trigger Context: After Update
     * @param accounts = List of updated and inserted accounts
     * @param oldAccounts = previous account records
     */
    public static void updateOwnershipInMidas(List<Account> accounts, Map<Id, Account> oldAccounts){
    	List<String> accountIds = new List<String>();
    	
    	Map<Id,String> accountWithRecordType = new Map<Id,String>();
    	for(Account acc: accounts){
    		accountWithRecordType.put(acc.Id,LibRecordTypeHelper.getRecordTypeValue(acc.RecordTypeId));
    	}
    																	
    	Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('MIDASOwnershipUpdateProcess');
        if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) {
        	return;
        }
        
    	for(Account acc : accounts){
	        Map<String, Business_Config__c> ruleMap = mapBusinessLogic.get(accountWithRecordType.get(acc.id));
	        if(ruleMap == null || ruleMap.isEmpty()){
	        	continue;
	        }
			if(oldAccounts.get(acc.Id).ownerId != acc.ownerId && ruleMap.get('isEnabled').Business_rule_Value__c == 'True'){
				accountIds.add(acc.Id);
			}
    	}
    	
    	if(accountIds.size() > 0){
    		// Call a future method to update ownership in MIDAS
    		ClsAccountHelper.changeOwnershipOfTheAccount(accountIds);
    	}
    }

    /**
    * Called before insert and before update, checks the number of categories chosen for record types defined in BC set 
    * @param accounts inserted, accounts updated
    */
    public static void verifyCategory(List<Account> accs, Map<Id, Account> oldAccounts){

        List<Account> lstAccs = new List<Account>();

        if(oldAccounts == null || oldAccounts.isEmpty()){
            ClsAccountHelper.verifyCategory(accs);
        }else{
            for(Account acc : accs){
                if(acc.Category__c != oldAccounts.get(acc.Id).Category__c) lstAccs.add(acc);
            }
            if(!lstAccs.isEmpty()) ClsAccountHelper.verifyCategory(lstAccs);
        }  
    }

    /**
     * @description Updates account Delivery Service field based on active/expired contracts
     *
     * @param accountIds accounts that should have Delivery Service value updated
     * @param contractTypes contract service types that should be considered for Delivery Service
     *
     * @return list of accounts that had their Delivery Service value updated
     */
    public static List<Account> updateDeliveryService(final Set<Id> accountIds, final Set<String> contractTypes) {
        List<Account> accounts = ClsAccountSelector.findByIdsAndContractServiceType(accountIds, contractTypes);
        if (accounts == null || accounts.isEmpty()) {
            return null;
        }
        for (Account dsAccount: accounts) {
            if (dsAccount.Contracts.isEmpty()) {
                continue;
            }
            Business_Config__c typesConfig = LibBusinessConfig.getBusinessConfigFromRuleMap('ContractCreation', dsAccount.Contracts[0].RecordTypeId, 'deliveryServiceTypes');
            Business_Config__c typesMapConfig = LibBusinessConfig.getBusinessConfigFromRuleMap('ContractCreation', dsAccount.Contracts[0].RecordTypeId, 'deliveryServiceTypesMap');
            Boolean isBusinessConfigEmpty = typesConfig == null || String.isBlank(typesConfig.Business_Rule_Value__c) || typesMapConfig == null || String.isBlank(typesMapConfig.Business_Rule_Value__c);
            if (isBusinessConfigEmpty) {
                continue;
            }
            Map<String, String> serviceTypeMap = organiseGroupKeys((Map<String, String>) JSON.deserialize(typesMapConfig.Business_Rule_Value__c, Map<String, String>.class));
            String serviceKey = getServiceKey(dsAccount.Contracts, typesConfig);

            dsAccount.Delivery_Service__c = serviceTypeMap.containsKey(serviceKey) ? serviceTypeMap.get(serviceKey) : null;
        }
        return accounts;
    }

    /**
     * @description generates a key to decide what value to put in Delivery Service field from business config, based on active contracts.
     *              if no active contract is present the Delivery Service is set to empty.
     *
     * @param contracts contracts to be processed
     * @param typesConfig service types that should count towards delivery service population
     *
     * @return map key
     */
    private static String getServiceKey(final List<Contract> contracts, final Business_Config__c typesConfig) {
        String key = '';
        Set<String> serviceTypes = new Set<String>(typesConfig.Business_Rule_Value__c.replaceAll(' ,|, ', ',').split(','));
        for (Contract cs: contracts) {
            if (!serviceTypes.contains(cs.Service_Type__c) || !cs.Status.equals(ClsContractProcessor.STATUS_ACTIVE) || key.contains(cs.Service_Type__c)) {
                continue;
            }
            key += cs.Service_Type__c;
        }
        return key;
    }

    /**
     * @description sorts the map keys that contain more than one service type.
     *
     * @param serviceTypeMap Map where Commission service type is key and Delivery Service is the value
     *
     * @return map with sorted keys
     */
    private static Map<String, String> organiseGroupKeys(Map<String, String> serviceTypeMap) {
        Map<String, String> sortedMap = new Map<String, String>();
        for (String mapKey: serviceTypeMap.keySet()) {
            if (!mapKey.contains(',')) {
                sortedMap.put(mapKey, serviceTypeMap.get(mapKey));
                continue;
            }
            List<String> groupKey = mapKey.replaceAll(' ,|, ', ',').split(',');
            groupKey.sort();
            sortedMap.put(String.join(groupKey, ''), serviceTypeMap.get(mapKey));
        }
        return sortedMap;
    }

     /**
   * @Description: This method updates opportunity country from account country
     @Input Params       : List Account records , Map of Old Account record
     @Return             : Void
     @TriggerContext     : Before Update
     @Ticket #           : SSC-1533
    */

    public static void UpdateAccountCountryOnOpportunity(List<Account> newList, Map<Id, Account> oldMap){

        Map<Id,Account> mapOfAccount = new Map<Id,Account>();
        for(Account iAcc : newList){
            if(iAcc.Record_Country__c != oldMap.get(iAcc.Id).Record_Country__c){
                mapOfAccount.put(iAcc.Id,iAcc);
            }
        }
        if(mapOfAccount.isEmpty()) {
            return;
        }
        List<Opportunity> lstOppty = Opportunity_Selector.getOpportunityAgainstAccounts(mapOfAccount.keySet());
        if(lstOppty.isEmpty()) {
            return;
        }
        for(Opportunity iOppty : lstOppty){
            iOppty.Opportunity_Country__c = mapOfAccount.get(iOppty.AccountId).Record_Country__c;
        }
        try{
            update lstOppty;
        }
        catch(Exception ex){
            system.debug('Error : ' + ex.getMessage() + '  ' + ex.getLineNumber());
        }

    }
    /**
 * @Description: This method updates Account Country on Shipping Orders whenever account
 *               country change on Account object
   @Params       : List Account records , Map of Old Account record
   @Return             : Void
   @TriggerContext     : Before Update
   @Ticket #           : SSC-1665
  */

    public static void UpdateAccountCountryOnShippingOrders(List<Account> newList, Map<Id, Account> oldMap){

        Map<Id,Account> mapOfAccount = new Map<Id,Account>();
        List<Shipment_Order__c> updateShipmentOrders = new List<Shipment_Order__c>();

        for(Account iAccount : newList){
            if(iAccount.Record_Country__c != oldMap.get(iAccount.Id).Record_Country__c){
                mapOfAccount.put(iAccount.Id,iAccount);
            }
        }
        if(mapOfAccount.isEmpty()) {
            return;
        }
        Map<Id,List<Shipment_Order__c>> mapOfShipmentOrders = ShipmentOrderSelector.getShipmentOrdersForAccount(mapOfAccount.keySet());

        if(mapOfShipmentOrders.isEmpty()) {
            return;
        }
        for(Account iAccount : mapOfAccount.values()){

            if(!mapOfShipmentOrders.containsKey(iAccount.Id)){
                continue;
            }
            for(Shipment_Order__c iShipmentOrder : mapOfShipmentOrders.get(iAccount.Id)){

                iShipmentOrder.Account_Country__c = iAccount.Record_Country__c;
            }

            updateShipmentOrders.addAll(mapOfShipmentOrders.get(iAccount.Id));
        }
        try{
            update updateShipmentOrders;
        }
        catch(Exception ex){
            system.debug('Error : ' + ex.getMessage() + '  ' + ex.getLineNumber());
        }
    }

    /**
   * @description - Update parent account(Facility) whenever there is change in status/change in facility lookup
   *                on Branch - Kitchen Restaurant
   *
   * @param accountList  - List of Accounts
   * @param oldMap - Old map
   */
    public static void updateFacilityDetails(List<Account> accountList, map<id, Account> oldMap) {
        set<Id> objFacilityIds = new set<Id>();
        for (Account accountObj : accountList) {
            if (oldMap != null && ((String.isNotBlank(accountObj.Type) &&
                    accountObj.Type.equals(Constants.ACCOUNT_TYPE_BRANCH_KITCHEN_RESTAURANT) &&
                    oldMap.get(accountObj.Id).Account_Status__c != accountObj.Account_Status__c) ||
                    (oldMap.get(accountObj.Id).Facility__c != accountObj.Facility__c && accountObj.Facility__c != null))) {

                objFacilityIds.add(accountObj.Facility__c);
                objFacilityIds.add(String.isNotBlank(oldMap.get(accountObj.Id).Facility__c) ?
                        oldMap.get(accountObj.Id).Facility__c : null);

            } else if (oldMap == null) {
                objFacilityIds.add(accountObj.Facility__c);
            }
        }
        if (!objFacilityIds.isEmpty()) {
            updateFacilityRecords(objFacilityIds);
        }
    }

    /**
    * @date      [05/04/2020]
    * @method name   updateFacilityRecords
    * @description   Logic to update facility record
    * @param         Set<Id> objFacilityIds
    */

    private static void updateFacilityRecords(Set<Id> objFacilityIds) {

        List<Account> objFacilities = new List <Account>();
        for (Account obj : ClsAccountSelector.getStallsByFacilityIds(objFacilityIds)) {
            Integer stallsOccupied = 0;
            for (Account kitchen : obj.Stalls__r) {
                if (kitchen.Account_Status__c != null && kitchen.Account_Status__c.equals(Constants.ACCOUNT_STATUS_ACTIVE)) {
                    stallsOccupied += 1;
                }
            }
            obj.Stalls_Occupied__c = stallsOccupied;
            objFacilities.add(obj);
        }
        if (!objFacilities.isEmpty()) {
            update objFacilities;
        }
    }

    /**
    * @description - Copy Address details of parent account(Facility) whenever facility is associated
    *                to Branch - Kitchen Restaurant
    * @param listOfAcc  - List of Accounts
    * @param oldMap - Old map of Accounts
    */
    public static void copyFacilityAddressToAssociatedKitchen(List<Account> listOfAcc, Map<id, Account> oldMap) {
        Map<Id,Id> mapOfFacilityIdWithAccountId = new Map<Id,Id>();
        Set<Id> setOfAccountIds = new Set<Id>();
        List<AddressDetail__c> listOfAddressToInsert = new List<AddressDetail__c>();
        List<AddressDetail__c> listOfAddressToDelete = new List<AddressDetail__c>();
        try {
            for (Account accObj : listOfAcc) {
                if (String.isNotBlank(accObj.Facility__c) && (oldMap == null || (oldMap != null &&
                        oldMap.get(accObj.Id).Facility__c != accObj.Facility__c))) {
                    mapOfFacilityIdWithAccountId.put(accObj.Facility__c, accObj.id);
                    setOfAccountIds.add(accObj.Id);
                }
            }

            if (!mapOfFacilityIdWithAccountId.keyset().isEmpty()) {
                updateAndDeleteAddressDetail(mapOfFacilityIdWithAccountId, setOfAccountIds);
            }

        } catch (Exception ex) { ClsLogErrorMessage.logMessages(ERROR_MAPPING_ADDRESS_FAILED,
                METHOD_COPY_FACILITY_ADDRESS + ex.getMessage() + ex.getStackTraceString());
        }
    }

    /**
    * @date     : [28/03/2020]
    * @method name  : updateAndDeleteAddressDetail
    * @description  : Logic to insert, update & delete facility address to kitchen address
    * @param        : Map<Id,Id> mapOfFacilityIdWithAccountId, Set<Id> setOfAccountIds
    */

    private static void updateAndDeleteAddressDetail(Map<Id,Id> mapOfFacilityIdWithAccountId,Set<Id> setOfAccountIds) {
        List<AddressDetail__c> listOfAddressToInsert = new List<AddressDetail__c>();
        List<AddressDetail__c> listOfAddressToDelete = new List<AddressDetail__c>();
        List<AddressDetail__c> listOfAddressToUpdate = new List<AddressDetail__c>();

        try {
            //This condition is used to create a new address records on the Account Object
            for (AddressDetail__c addressObj :
                    AddressDetail_Selector.getAddressByAccountIds(mapOfFacilityIdWithAccountId.keySet())) {
                if (addressObj != null && addressObj.Type__c != null &&
                        addressObj.Type__c.contains(Constants.ADDRESS_TYPE_RESTAURANT_ADDRESS)) {
                        AddressDetail__c clonedAdd = addressObj.clone(false, false, false, false);
                        clonedAdd.Account__c = mapOfFacilityIdWithAccountId.get(addressObj.Account__c);
                        clonedAdd.Type__c = Constants.ADDRESS_TYPE_RESTAURANT_ADDRESS;
                        listOfAddressToInsert.add(clonedAdd);
                }

            }

            //This condition is used to update the existing address records on the Account Object
            for (AddressDetail__c addressObj : AddressDetail_Selector.getAddressByAccountIds(setOfAccountIds)) {
                addressListUpdateDelete(addressObj);
            }

            if (!listOfAddressToInsert.isEmpty()) {
                Database.insert(listOfAddressToInsert, false);
            }

        }catch (Exception ex) { ClsLogErrorMessage.logMessages(ERROR_INSERT_UPDATE_ADDRESS_FAILED,
                METHOD_UPDATE_DELETE_ADDRESS + ex.getMessage() + ex.getStackTraceString());
        }
    }


    /**
    * @date     : [13/04/2020]
    * @method name  : addressListUpdateDelete
    * @description  : Logic to update and delete the address list
    * @param        : AddressDetail__c addressObj
    */

    private static void addressListUpdateDelete(AddressDetail__c addressObj) {
        List<AddressDetail__c> listOfAddressToDelete = new List<AddressDetail__c>();
        List<AddressDetail__c> listOfAddressToUpdate = new List<AddressDetail__c>();

        String allTypeValues = '';
        List<String> typeValuesList = new List<String>();
        allTypeValues = addressObj.Type__c;
        typeValuesList = allTypeValues.split(';');
        if (!typeValuesList.isEmpty() && typeValuesList.size() > 1 &&
                typeValuesList.contains(Constants.ADDRESS_TYPE_RESTAURANT_ADDRESS)) {
            typeValuesList.remove(typeValuesList.indexOf(Constants.ADDRESS_TYPE_RESTAURANT_ADDRESS));
            addressObj.Type__c = String.join(typeValuesList, ';');
            listOfAddressToUpdate.add(addressObj);
        } else if (!typeValuesList.isEmpty() && typeValuesList.size() > 0 &&
                typeValuesList.contains(Constants.ADDRESS_TYPE_RESTAURANT_ADDRESS)) {
            listOfAddressToDelete.add(addressObj);
        }

        if (!listOfAddressToUpdate.isEmpty()) {
            Database.update(listOfAddressToUpdate, false);
        }

        if (!listOfAddressToDelete.isEmpty()) {
            Database.delete(listOfAddressToDelete, false);
        }

    }

    /**
   * @date     : [20/05/2020]
   * @method name  : updateChildAccounts
   * @description  : Any update on parent accounts Key/VIP attribute  same will flow down to child account(SSC-1990)
   * @param   newAccounts  [List<Account>]
   * @param   oldMap  [Map<Id, Account>]
   */
    public static void updateChildAccounts(List<Account> newAccounts, Map<Id, Account> oldMap) {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RT_TALABAT_ACCOUNT).getRecordTypeId();
        Map<Id,Boolean> accountKeyAccountMap = new Map<Id,Boolean>();
        for (Account obj : newAccounts) {
            if (obj.RecordTypeId.equals(recordTypeId) &&
                    (obj.Key_VIP_Account__c != oldMap.get(obj.Id).Key_VIP_Account__c)) {
                accountKeyAccountMap.put(obj.Id,obj.Key_VIP_Account__c);
            }
        }
        if (!accountKeyAccountMap.isEmpty()) {
            if (Limits.getQueueableJobs() == 1){
                //parse to cron expression
                String nextFireTime = String.valueOf(Datetime.now().second() + 10) + ' ' + String.valueOf(Datetime.now().minute()) + ' ' + String.valueOf(Datetime.now().hour()) + ' * * ?';
                System.schedule('ScheduledJob ' + String.valueOf(Math.random()), nextFireTime, new ClsKeyAccountUpdateSchedulable(accountKeyAccountMap));
            }else{
                System.enqueueJob(new ClsKeyAccountUpdateQueueable(accountKeyAccountMap));
            }
        }
    }
}
