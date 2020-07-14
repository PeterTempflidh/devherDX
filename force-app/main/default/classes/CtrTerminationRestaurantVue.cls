/**
 * Created by w.novoa on 12.03.2018.
 */

global without sharing class CtrTerminationRestaurantVue {

    private static final String TERMINATION_SUCCESS= '{0} terminated successfully!';
    public static final string ERROR_UPDATE_ACCOUNT_FAILED = 'Update Failed On Account Object';
    public static final string METHOD_UPDATE_ACCOUNT_ADDRESS = 'updateAccountRevenueModel Method : ';
    public static final string ERROR_UPDATE_CONTRACTS_FAILED = 'Update Failed To Get Contracts';
    public static final string METHOD_FETCH_CONTRACT_WITH_SERVICE = 'fetchAllContractsWithServiceType Method : ';

    public CtrTerminationRestaurantVue() {

    }
    public CtrTerminationRestaurantVue(ApexPages.StandardController sdtController) {

    }

    @remoteAction
    public static map<string,id> getRecordTypesRelatedList(String recordTypeAccount){
        Map<String, Map<String,Map<String,Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
        Map<String,Map<String,Business_Config__c>> mapProcessData= moam.get('TerminateRestaurant');
        map<string,Object> mpRecordTypes = new map<string,Object>();
        map<string, Id> mpRecordTypesId = new map<string, Id>();
        String strDevNamRecord;

        strDevNamRecord = LibRecordTypeHelper.getRecordTypeValue(recordTypeAccount);
        if(mapProcessData != null
                && mapProcessData.containsKey(strDevNamRecord)
                && mapProcessData.get(strDevNamRecord).get('RecodTypesRelatedList')!= null
                && mapProcessData.get(strDevNamRecord).get('RecodTypesRelatedList').Business_Rule_Value__c != null){
            mpRecordTypes= (Map<String,Object>) JSON.deserializeUntyped(mapProcessData.get(strDevNamRecord).get('RecodTypesRelatedList').Business_Rule_Value__c);
            for(String keyObj: mpRecordTypes.keyset()){
                mpRecordTypesId.put(keyObj,LibRecordTypeHelper.getRecordTypeValue((string)mpRecordTypes.get(keyObj)));
            }
        }
        return mpRecordTypesId;
    }

    @RemoteAction
    public static  List<ContractWrapper>  getActiveContracts(String idAccount) {
        List<ContractWrapper> lstContractsActive = new  List<ContractWrapper>();
        Contract conTemp = new Contract();
        map<id,List<Tier__c>> mpTier = new map<id,List<Tier__c>>();

        map<id,Contract> mpContract = new map<id,Contract>([SELECT
        id,
        ContractNumber,
        Name__c,
        StartDate,
        recordtypeid,
        recordtype.developername,
        End_Date__c,
        Status,
        Commission__c,
        Recurring_Fee__c,
        online_payment_fee__c,
        commission_per_order__C,
        Termination_Reason__c,
        Min__c,
        Max__c,
        index__c,
        IsTiered__c,
        Id_Opportunity__c,
        Service_Type__c,
        AccountId,
        CurrencyIsoCode,
        Id_Opportunity__r.Name,
        Company__c
        FROM Contract
        WHERE AccountId = : idAccount
        AND status NOT IN ('Terminated','Expired')
        ORDER BY StartDate DESC]);

        for(Tier__c tier:[select id, OwnerId, IsDeleted, Name,  Commission_in_percentage__c, Commission_per_order__c, Id_Contract__c, Id_Opportunity_Line_Item__c, Id_Opportunity_Quote_Line_Item__c, Max__c, Min__c
                            from Tier__c where id_Contract__c in : mpContract.keyset()]){
            if(mpTier.containsKey(tier.id_Contract__c)){
                mpTier.get(tier.id_Contract__c ).add(tier);
           }else{
                mpTier.put(tier.id_Contract__c , new List<Tier__c>{tier});
            }
        }



        for (Contract c : mpContract.values()) {

            lstContractsActive.add( new ContractWrapper(c,mpTier.get(c.id)));

        }
        System.debug('getActiveContracts-->'+lstContractsActive);
        return lstContractsActive;
    }

    @RemoteAction
    public static  List<AddOnWrapper>  getActiveAddOns (String idAccount) {
        List<AddOnWrapper> lstAddOn = new  List<AddOnWrapper>();


        for (Add_on_Service__c ao : [Select
                id,
                Name,
                Type__c,
                Status__c,
                End_Date__c,
                Opportunity__c,
                Opportunity__r.Name,
                Id_List_Add_On__c,
                Id_List_Add_On__r.Name,
                Opportunity__r.StageName,
                recordtypeid,
                Company__c,
		Start_Date__c,
                Termination_Reason__c

        From Add_on_Service__c
        Where Account_Name__c = : idAccount
        AND status__c NOT IN ('Terminated','Expired','Canceled')

        ORDER By End_Date__c DESC]) {
            lstAddOn.add( new AddOnWrapper(ao));
        }

        return lstAddOn;
    }
    @RemoteAction
    public static  List<AdditionalWrapper>  getActiveAddionalCharges(String idAccount) {
        List<AdditionalWrapper> lstAddCharges = new  List<AdditionalWrapper>();

        for (Additional_Charges__c add : [SELECT
                id,
                Name,
                Start_Date__c,
                City_ZipCode__c,
                Position_fm__c,
                Booking_Api_Id__c,
                type__c,
                Id_Asset__r.status__c,
                Id_Asset__r.Returned_Reason__c,
                Id_Asset__r.Retour_Date__c,
                Id_Asset__c,
                Id_Asset__r.Name,
                Id_List_Product_Price__r.Product_Name__c,
                Product__c,
                Id_opportunity__c,
                Id_Opportunity__r.Name,
                Total_Amount__c,
                Termination_Date__c,
                Id_Asset__r.termination_date__c,
                Termination_Reason__c,
                status__c,
                CurrencyIsoCode,
                Company__c,
                recordtypeid,
                recordType.developerName
        FROM Additional_Charges__c
        WHERE Id_Account__c = : idAccount AND Booking_Api_Id__c = NULL
        AND( (Status__c NOT IN('Terminated','Expired','Charged') OR (Status__c IN('Expired','Charged') AND Termination_Date__c = LAST_90_DAYS )))
        ]) {

            lstAddCharges.add(new AdditionalWrapper(add));
        }

        return lstAddCharges;
    }

    @RemoteAction
    public static  List<AdditionalWrapper>  getActiveAddionalChargesPP (String idAccount) {
        List<AdditionalWrapper> lstAddCharges = new  List<AdditionalWrapper>();

        for (Additional_Charges__c add : [SELECT
                id,
                Name,
                Start_Date__c,
                City_ZipCode__c,
                Position__c,
                Position_fm__c,
                Booking_Api_Id__c,
                type__c,
                Id_Asset__r.status__c,
                Id_Asset__r.Returned_Reason__c,
                Id_Asset__r.Retour_Date__c,
                Id_Asset__c,
                Id_Asset__r.Name,
                Id_List_Product_Price__r.Product_Name__c,
                Product__c,
                Id_opportunity__c,
                Id_Opportunity__r.Name,
                Total_Amount__c,
                Termination_Date__c,
                Id_Asset__r.termination_date__c,
                Termination_Reason__c,
                status__c,
                Company__c,
                recordtypeid,
                recordType.developerName,
                Sub_Product_Name__c,
                Quantity__c
        FROM Additional_Charges__c
        WHERE Id_Account__c = : idAccount AND  Booking_Api_Id__c != NULL
        AND( (Status__c NOT IN('Terminated','Expired','Charged') OR (Status__c IN('Expired','Charged') AND Termination_Date__c = LAST_90_DAYS )))
        ]) {
            lstAddCharges.add( new AdditionalWrapper(add));
        }

        return lstAddCharges;
    }

    @RemoteAction
    public static  List<BrandingWrapper>  getBranding (String idAccount) {
        List<BrandingWrapper> lstBrandingCont = new List<BrandingWrapper>();


        for (Branding_Content__c bc : [
                Select
                        id,
                        Name,
                        Type__c,
                        Quantity__c,
                        Status__c,
                        End_Date__c,
                        Opportunity__c,
                        Opportunity__r.Name,
                        Opportunity__r.StageName,
                        Termination_Reason__c,
                        Product__c,
                        Product__r.Name,
                        recordtypeid,
                        Installation_Date__c
                From Branding_Content__c
                Where Restaurant_Name__c = :idAccount
                AND status__c NOT IN ('Terminated','Expired','Canceled')
                ORDER By End_Date__c DESC
        ]) {
            lstBrandingCont.add( new BrandingWrapper(bc));
        }
        system.debug('getBranding-->'+lstBrandingCont);
        return lstBrandingCont;
    }

    @RemoteAction
    public static string terminateContracts(String strSelect, String RecordTypeId,
                                                List<ContractWrapper> mapContracts,
                                                List<AdditionalWrapper> mapAddCharges,
                                                List<AdditionalWrapper> mapPPCharge,
                                                List<BrandingWrapper> mapBrandingCont,
                                                List<AddOnWrapper> mapAddOn) {
        string strError;
        Boolean onlySelected;

        if(strSelect=='selected'){
            onlySelected = true;
        }else{
            onlySelected = false;

        }

        ClsTerminationRestaurantHelper terRest = new ClsTerminationRestaurantHelper(RecordTypeId);

        try {
            List<String> bookingIds = new List<String>();
            List<Additional_Charges__c> updateAdditional = new List<Additional_Charges__c>();
            List<Asset__c> updateAssets = new List<Asset__c>();
            List<Contract> updateContract = new List<Contract>();
            List<Branding_Content__c> brandingToUpdate = new List<Branding_Content__c>();
            List<Add_on_Service__c> addOnToUpdate = new List<Add_on_Service__c>();
            Map<Id, Boolean> oppIdProcessed = new Map<Id, Boolean>();
            Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
            Map<String,List<Contract>> mapOfAccountIdContract = new Map<String,List<Contract>>(); //SSC-1982
            Map<String, Map<String, Business_Config__c>> mapBusinessLogicTLife = moam.get('TlifeRevenueModel'); //SSC-1982
            Map<String, Business_Config__c> mapOfContractBusinessConfig =  new Map<String, Business_Config__c>(); //SSC-1982

            for (ContractWrapper cont : mapContracts) {
                if ( (onlySelected && !cont.isSelected)) {
                    continue;
                }

                if (terRest.contractTerminationReasonMandatory
                        && String.isBlank(cont.con.Termination_Reason__c)) {

                    strError =  Label.Terminate_Restaurant_Select_Reason;
                    return strError;
                }
                if (terRest.contractTerminationDateMandatory
                        && cont.con.End_Date__c == null) {

                    strError =  Label.Terminate_Restaurant_Select_Date;
                    return strError;
                }

                if(cont.con.End_Date__c <= date.today()){
                    cont.con.status = 'Terminated';

                    //The below logic is added for SSC-1982 : Tlife Commission
                    String contractRecordType = String.isNotBlank(cont.con.RecordType.DeveloperName) ? cont.con.RecordType.DeveloperName : '';
                    if(mapBusinessLogicTLife != null && null != mapBusinessLogicTLife.get(contractRecordType)){
                        List<Contract> listOfContract = !mapOfAccountIdContract.isEmpty() && mapOfAccountIdContract.get(cont.con.AccountId) != null ?
                                mapOfAccountIdContract.get(cont.con.AccountId) : new List<Contract>();
                        listOfContract.add(cont.con);
                        mapOfContractBusinessConfig = mapBusinessLogicTLife.get(contractRecordType);
                        mapOfAccountIdContract.put(cont.con.AccountId,listOfContract);
                    }
                    //SSC-1982 : Tlife Commission ends here
                }
                updateContract.add(cont.con);
            }

            for (AdditionalWrapper addt : mapAddCharges) {
                Asset__c updateAsset;
                if (onlySelected && !addt.isSelected) {
                    continue;
                }

                system.debug('mapAddCharges');
                if (terRest.addChargesTerminationReasonMandatory
                        && String.isBlank(addt.add.Termination_Reason__c)) {
                    strError =  Label.Terminate_Restaurant_Select_Reason + '\r\n';
                    return strError;
                }
                if (terRest.addChargesTerminationDateMandatory
                        && addt.add.Termination_Date__c == null) {
                    strError =  Label.Terminate_Restaurant_Select_Date + '\r\n';
                    return strError;
                }

                if(addt.add.termination_date__c <= date.today()){
                    addt.add.status__c = 'Terminated';
                }


                updateAdditional.add(addt.add);

                if (addt.add.Id_Asset__c != null && addt.add.Id_Asset__r.termination_date__c == null) {
                    if (terRest.doNotOverwriteStatusSet != null && terRest.doNotOverwriteStatusSet.contains(addt.add.Id_Asset__r.status__c)) {
                        updateAsset = new Asset__c(id = addt.add.Id_Asset__c, termination_date__c = addt.add.termination_date__c);
                    } else {
                        updateAsset = new Asset__c(id = addt.add.Id_Asset__c, status__c = terRest.assetStatus, termination_date__c = addt.add.termination_date__c);
                    }
                    if (updateAsset != null) {
                        if (addt.add.Id_Asset__r.Retour_Date__c == null) {
                            updateAsset.Retour_Date__c = addt.add.termination_date__c;
                        }
                        if (addt.add.Id_Asset__r.Returned_Reason__c == null) {
                            updateAsset.Returned_Reason__c = addt.add.Termination_Reason__c;
                        }
                        updateAssets.add(updateAsset);
                    }
                }
            }

            for (AdditionalWrapper addt : mapPPCharge) {

                if (onlySelected && !addt.isSelected) {
                    continue;
                }

                if (terRest.addChargesTerminationReasonMandatory
                        && String.isBlank(addt.add.Termination_Reason__c)) {

                    strError =  Label.Terminate_Restaurant_Select_Reason ;
                    return strError;
                }
                if (terRest.addChargesTerminationDateMandatory
                        && addt.add.Termination_Date__c == null) {

                    strError =  Label.Terminate_Restaurant_Select_Date ;
                    return strError;
                }


                addt.add.status__c = 'Terminated';

                // Restrict Termination of PP charges for UK if the status of the additional charge is not "To be Sent", for others terminate all
                Map<String, Map<String, Business_Config__c>> mapProcesses = moam.get('RestrictPPTerminationByStatus');
                if(addt.add.Booking_Api_Id__c != null){
                    if(mapProcesses != null && mapProcesses.get(addt.add.recordType.developerName) != null && !mapProcesses.get(addt.add.recordType.developerName).isEmpty()){
                        Map<String, Business_Config__c> mapBusinessRules = mapProcesses.get(addt.add.recordType.developerName);
                        if(mapBusinessRules.get('status') != null && mapBusinessRules.get('status').Business_rule_value__c == addt.add.status__c){
                            bookingIds.add(addt.add.Booking_Api_Id__c);
                        }
                    }else{
                        bookingIds.add(addt.add.Booking_Api_Id__c);
                    }
                }

                updateAdditional.add(addt.add);
            }
            for (BrandingWrapper bc : mapBrandingCont) {

                if (onlySelected && !bc.isSelected) {
                    continue;
                }

                String status;

                if (terRest.brandingTerminationReasonMandatory
                        && String.isBlank(bc.branding.Termination_Reason__c)) {

                    strError =  Label.Terminate_Restaurant_Select_Reason ;
                    return strError;
                }

                if (terRest.brandingTerminationDateMandatory
                        && bc.branding.End_date__c == null) {

                    strError =  Label.Terminate_Restaurant_Select_Date ;
                    return strError;
                }
                if (terRest.mapBusinessData.containsKey('checkForBrandingInstallationdate')
                        && Boolean.valueOf(terRest.mapBusinessData.get('checkForBrandingInstallationdate').Business_Rule_Value__c)) {
                    status = bc.branding.Installation_Date__c == null ?terRest.mapBusinessData.get('BrandingTerminateStatus').Business_Rule_Value__c : '';
                }
                // set status to default if blank
                if(bc.branding.End_Date__c <= date.today()) {
                    status = String.isNotBlank(status) ? status : terRest.mapBusinessData.get('BrandingUninstalledStatus').Business_Rule_Value__c;
                    bc.branding.Status__c = status;
                }
                System.debug('branding-->'+bc.branding);
                bc.branding.End_Date__c = bc.branding.End_Date__c == null ? Date.today() : bc.branding.End_Date__c;
                System.debug('branding-->'+bc.branding);
                brandingToUpdate.add(bc.branding);
            }

            for (AddOnWrapper ao : mapAddOn) {
                if (onlySelected && !ao.isSelected) {
                    continue;
                }

                if (terRest.addOnTerminationReasonMandatory
                        && String.isBlank(ao.addon.Termination_Reason__c)) {

                    strError =  Label.Terminate_Restaurant_Select_Reason ;
                    return strError;
                }
                if (terRest.addOnTerminationDateMandatory
                        && ao.addon.End_Date__c == null) {

                    strError =  Label.Terminate_Restaurant_Select_Date ;
                    return strError;
                }

                if(ao.addon.End_Date__c <= date.today()) {
                    ao.addon.Status__c = 'Terminated';
                }
                ao.addon.End_Date__c = ao.addon.End_Date__c == null ? Date.today() : ao.addon.End_Date__c;
                addOnToUpdate.add(ao.addon);
            }




            if (!bookingIds.isEmpty()) {
                String result = terRest.terminateMidasPP(bookingIds);
                if (result != 'success') {
                    return result;
                }
            }

            if(!updateContract.isEmpty()) {
                update updateContract;
            }
            if(!updateAdditional.isEmpty()) {
                update updateAdditional;
            }
            if(!updateAssets.isEmpty()){
                update updateAssets;
            }
            if(!brandingToUpdate.isEmpty()) {
                update brandingToUpdate;
            }
            if(!addOnToUpdate.isEmpty()) {
                update addOnToUpdate;
            }

            //The below logic is added for SSC-1982 : Tlife Commission
            if(!mapOfAccountIdContract.isEmpty() && !mapOfContractBusinessConfig.isEmpty()) {
                fetchAllContractsWithServiceType(mapOfAccountIdContract,mapOfContractBusinessConfig);
            }
            //logic ends here for SSC-1982 : Tlife Commission

            String returnMessage = 'Success';

            if(!updateContract.isEmpty() && updateAdditional.isEmpty() && updateAssets.isEmpty() && brandingToUpdate.isEmpty() && addOnToUpdate.isEmpty()) {
                returnMessage = String.format(TERMINATION_SUCCESS, new List<String>{ 'Contract(s)' });
            } else if(updateContract.isEmpty() && !updateAdditional.isEmpty() && !updateAssets.isEmpty() && brandingToUpdate.isEmpty() && addOnToUpdate.isEmpty()) {
                returnMessage = String.format(TERMINATION_SUCCESS, new List<String>{ 'Additional Charges & Assets' });
            } else if(updateContract.isEmpty() && updateAdditional.isEmpty() && updateAssets.isEmpty() && !brandingToUpdate.isEmpty() && addOnToUpdate.isEmpty()) {
                returnMessage = String.format(TERMINATION_SUCCESS, new List<String>{ 'Branding(s)' });
            } else if(updateContract.isEmpty() && updateAdditional.isEmpty() && updateAssets.isEmpty() && brandingToUpdate.isEmpty() && !addOnToUpdate.isEmpty()) {
                returnMessage = String.format(TERMINATION_SUCCESS, new List<String>{ 'Add-on Service(s)' });
            }

            return returnMessage;

        } catch (Exception e) {
            return e.getMessage();
        }

        return 'Success';
    }

    /**
   * @date     : [02/06/2020]
   * @method name  : fetchAllContractsWithServiceType
   * @description  : Logic to get all the contracts on the basis of Account Id implemented for SSC-1982 : Tlife Commission
   * @param  mapOfAccountIdContract Map<String,List<Contract>>
   * @param  mapOfContractBusinessConfig Map<String, Business_Config__c>
   *
   */
    public static void fetchAllContractsWithServiceType(Map<String,List<Contract>> mapOfAccountIdContract,
            Map<String, Business_Config__c> mapOfContractBusinessConfig){
        try{
            List<String> contractServiceTypes = mapOfContractBusinessConfig.get('ContractServiceType').Business_Rule_Value__c.split(',');
            List<Contract> listOfAllActiveContracts = ContractSelector.getContractsByServiceType(mapOfAccountIdContract.keySet(), contractServiceTypes,Constants.CONTRACT_STATUS_ACTIVATED);
            Map<String, List<Contract>> mapOfExistingActiveContracts = new Map<String, List<Contract>>();

            for (Contract contractInstance : listOfAllActiveContracts) {
                List<Contract> updatedListContract = !mapOfExistingActiveContracts.isEmpty() && null != mapOfExistingActiveContracts.get(contractInstance.AccountId + contractInstance.Service_Type__c) ?
                        mapOfExistingActiveContracts.get(contractInstance.AccountId + contractInstance.Service_Type__c) : new List<Contract>();
                updatedListContract.add(contractInstance);
                mapOfExistingActiveContracts.put(contractInstance.AccountId+mapOfContractBusinessConfig.get(contractInstance.Service_Type__c).Business_Rule_Value__c, updatedListContract);
            }
            updateAccountRevenueModel(mapOfAccountIdContract, mapOfContractBusinessConfig, contractServiceTypes, mapOfExistingActiveContracts);  //SSC-1982
        }catch (Exception ex) { ClsLogErrorMessage.logMessages(ERROR_UPDATE_CONTRACTS_FAILED,METHOD_FETCH_CONTRACT_WITH_SERVICE + ex.getMessage() + ex.getStackTraceString());
        }
    }

    /**
   * @date     : [18/05/2020]
   * @method name  : updateAccountRevenueModel
   * @description  : Logic to update account Revenue Model Field : SSC-1982 : Tlife Commission
   * @param   mapOfAccountIdContract Map<String,List<Contract>>
   * @param   mapOfContractBusinessConfig  Map<String, Business_Config__c>
   * @param   contractServiceTypes List<String>
   * @param   mapOfExistingActiveContracts Map<String,List<Contract>>
   */
    public static void updateAccountRevenueModel(Map<String,List<Contract>> mapOfAccountIdContract,
            Map<String, Business_Config__c> mapOfContractBusinessConfig, List<String> contractServiceTypes,
            Map<String,List<Contract>> mapOfExistingActiveContracts){

        List<Account> accountListUpdate = new List<Account>();
        try {
            for (Account accountInstance : ClsAccountSelector.getAccountByOppty((Set<Id>)JSON.deserialize(JSON.serialize(mapOfAccountIdContract.keySet()), Set<Id>.class))){
                Boolean checkServiceType = false;
                String allTypeValues = accountInstance.Revenue_Model__c;
                List<String> typeValuesList = String.isNotBlank(allTypeValues) ? allTypeValues.split(';') : new List<String>();
                for (Contract contractInstance : mapOfAccountIdContract.get(accountInstance.Id)) {
                    if (checkRevenueModelFieldValue(contractInstance,contractServiceTypes,typeValuesList,mapOfContractBusinessConfig,mapOfExistingActiveContracts)) {
                        checkServiceType = true;
                        typeValuesList.remove(typeValuesList.indexOf(mapOfContractBusinessConfig.get(contractInstance.Service_Type__c).Business_Rule_Value__c));
                        accountInstance.Revenue_Model__c = String.join(typeValuesList, ';');
                    }
                }
                if (checkServiceType) {
                    accountListUpdate.add(accountInstance);
                }
            }
            if (!accountListUpdate.isEmpty()) {
                Database.update(accountListUpdate,false);
            }
        }catch (Exception ex) { ClsLogErrorMessage.logMessages(ERROR_UPDATE_ACCOUNT_FAILED,METHOD_UPDATE_ACCOUNT_ADDRESS + ex.getMessage() + ex.getStackTraceString());
        }
    }

    /**
    * @date     : [06/05/2020]
    * @method name  : checkOldMapTaskValues
    * @description  : Logic to check the map old values
    * @param contractInstance Contract
    * @param contractServiceTypes List<String>
    * @param typeValuesList List<String>
    * @param mapOfContractBusinessConfig Map<String, Business_Config__c>
    * @param mapOfExistingActiveContracts Map<String,List<Contract>>
    * @return : Boolean
    */
    private static Boolean checkRevenueModelFieldValue(Contract contractInstance,List<String> contractServiceTypes,List<String> typeValuesList,
            Map<String, Business_Config__c> mapOfContractBusinessConfig, Map<String,List<Contract>> mapOfExistingActiveContracts) {

        String commissionServiceType = contractInstance.Service_Type__c;
        String commissionBusinessRuleValue = mapOfContractBusinessConfig.get(commissionServiceType).Business_Rule_Value__c;
        if (contractServiceTypes.contains(commissionServiceType) && typeValuesList.contains(commissionBusinessRuleValue)
                && !mapOfExistingActiveContracts.containsKey((contractInstance.AccountId+commissionBusinessRuleValue))){
            return true;
        }
        else {
            return false;
        }
    }

    global class ContractWrapper {
        public Boolean isSelected {get; set;}
        public Contract con {get; set;}
        public Opportunity opp {get; set;}
        public list<Tier__c> lsttier {get; set;}
        ContractWrapper(Contract cont, list<Tier__c> lsttiers) {
            isSelected = false;
            con = cont;
            lsttier = lsttiers;
            opp = new Opportunity();
            if (cont != null) {
                opp.Lost_Date__c = cont.End_Date__c;
                opp.Lost_Reason__c = cont.termination_Reason__c;
            }
        }
    }

    public class AdditionalWrapper {
        public Boolean isSelected {get; set;}
        public Additional_Charges__c add {get; set;}
        public Opportunity opp {get; set;}
        AdditionalWrapper(Additional_Charges__c addt) {
            isSelected = false;
            add = addt;
            opp = new Opportunity();
            if (addt != null) {
                opp.Lost_Date__c = addt.termination_date__c;
                opp.Lost_Reason__c = addt.termination_Reason__c;
            }

        }
    }

    public class BrandingWrapper {
        public Boolean isSelected {get; set;}
        public Branding_Content__c branding {get; set;}
        public Opportunity opp {get; set;}
        public BrandingWrapper(Branding_Content__c rec) {
            this.branding = rec;
            System.debug('EndDate-->'+rec.End_date__c);
            this.isSelected = false;
            opp = new Opportunity();
        }
    }

    public class AddOnWrapper {
        public Boolean isSelected {get; set;}
        public Add_on_Service__c addon {get; set;}
        public Opportunity opp {get; set;}
        public AddOnWrapper(Add_on_Service__c rec) {
            this.addon = rec;
            this.isSelected = false;
            opp = new Opportunity();
        }
    }

    /**
      @Description:  A class to hold the options for the select list
   */
    global class Option{
        public String label;
        public String value;
        public boolean selected;
        public boolean isDisabled;

        public Option(String label,string value){
            this.label      = label;
            this.value      = value;
            this.selected   = false;
            this.isDisabled = false;
        }

        public Option(String label,String value,boolean selected){
            this.label      = label;
            this.value      = value;
            this.selected   = selected;
            this.isDisabled = false;
        }

        public Option(String label,String value,boolean selected,boolean disabled){
            this.label      = label;
            this.value      = value;
            this.selected   = selected;
            this.isDisabled = disabled;
        }
    }

}
