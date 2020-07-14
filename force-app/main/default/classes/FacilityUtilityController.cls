/**
* @author Shivani
* @date 15/05/2020
*
* @description (SSC-2796 and 2794) class to get Facility validations config to use in
1. AccountClone.page
2. Lead conversion2.page
3. CreateNewAddress.page
4. PY_LeadConvertFields.component
5. PY_AccountConvertFields.component
*/
public with sharing class FacilityUtilityController {

    /*
    * @description  cache load from org
    */
    private static Map<String, Map<String, Map<String, Business_Config__c>>> moam = LibBusinessConfig.motherOfAllBusinessMaps;
     /*
    * @description  variable to hold recordtypeName
    * @returns String record type name
    */
    private String recordTypeName;

    /* *******************************************************************************************************
    * @description Facility business config wrapper class instance to hold different message from Business config
    * @returns FacilityBusinessConfigWrapper if exist in Config.
    */
    public FacilityBusinessConfigWrapper wrpForFacilityValidation{get;set;}


    /*******************************************************************************************************
    * @description (SSC-2796 and 2794) Controller extensions runs for Lead Conversion,Acc Clone and Create new address
    * @param ctr ApexPages.StandardController
    */
    public FacilityUtilityController(ApexPages.StandardController ctr){
        try{
            wrpForFacilityValidation = new FacilityBusinessConfigWrapper();
            /*
            * @description : fetch recordtypename based on different type of records
            */
            SObject record = ctr.getRecord();

            if(record instanceof Lead) {
                Lead leadRec = (Lead) record;
                recordTypeName = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosById().get(leadRec.RecordTypeId).getDeveloperName();
            }
            else if(record instanceof Account){
                Account accountRec = (Account) record;
                recordTypeName = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosById().get(accountRec.RecordTypeId).getDeveloperName();
            }
            else if(record instanceof AddressDetail__c){
                AddressDetail__c addRecord = (AddressDetail__c) record;
                recordTypeName = ClsAccountSelector.findAccountById(addRecord.Account__c).RecordType.DeveloperName;
            }
            wrpForFacilityValidation = facilityBusinessConfigRecord();

        }catch(Exception ex){
             ClsLogErrorMessage.logMessages('FacilityUtilityConstructor',
             ex.getMessage() + ex.getStackTraceString());
        }


    }


    /*******************************************************************************************************
    * @description (SSC-2796 and 2794) fetch facility business config from Moam and get records from config
    * @return FacilityBusinessConfigWrapper
    */
    private FacilityBusinessConfigWrapper facilityBusinessConfigRecord(){
    	// SSC-2796 and SSC -2796 fetch facility validation from business config
    	FacilityBusinessConfigWrapper facilityWrapperBusinessConfig = new FacilityBusinessConfigWrapper();
        Map<String, Map<String, Business_Config__c>> mapBusinessLogicFacility = moam.get('LeadConversionAndAccountCloneFacilityCheck');
        if (mapBusinessLogicFacility != null && recordTypeName != null) {
        	 facilityWrapperBusinessConfig  = fetchFacilityBusinessConfig(mapBusinessLogicFacility,facilityWrapperBusinessConfig);
        }
        return facilityWrapperBusinessConfig;
    }

    /*******************************************************************************************************
    * @description (SSC-2796 and 2794) get validation and condition value from Business config for facility
    * @param mapBusinessLogicFacility Business config record type and business Rule Map
    * @param facilityWrapper - to get wrapper value from JSON
    * @return FacilityBusinessConfigWrapper
    */
    private  FacilityBusinessConfigWrapper fetchFacilityBusinessConfig(Map<String, Map<String, Business_Config__c>> mapBusinessLogicFacility,
                                                              FacilityBusinessConfigWrapper facilityWrapper){
    	Map<String, Business_Config__c> mapBusinessDataFacility = new  Map<String, Business_Config__c>();
        mapBusinessDataFacility = mapBusinessLogicFacility.containsKey(recordTypeName) ? mapBusinessLogicFacility.get(recordTypeName) : new Map<String, Business_Config__c>();
           // SSC-2796 get all facility validation related message
        if(mapBusinessDataFacility != null && !mapBusinessDataFacility.isEmpty()){
            String checkParameters = mapBusinessDataFacility.containsKey('checkParameters') ? mapBusinessDataFacility.get('checkParameters').Business_Rule_Value__c : '';
            facilityWrapper = facilityBusinessConfigJsonToWrapper(checkParameters,facilityWrapper);
            return facilityWrapper;
        }
        return facilityWrapper;

    }

    /*******************************************************************************************************
    * @description (SSC-2796 and 2794) convert Facility JSON to Wrapper class FacilityBusinessConfigWrapper
    * @param checkParameters  config rule to get from Business config
    * @param facilityWrapper to get wrapper value from JSON
    * @return FacilityBusinessConfigWrapper
    */
    private static FacilityBusinessConfigWrapper facilityBusinessConfigJsonToWrapper(String checkParameters,FacilityBusinessConfigWrapper facilityWrapper) {
    	if(String.isNotBlank(checkParameters)) {
      		facilityWrapper = (FacilityBusinessConfigWrapper) System.JSON.deserialize(checkParameters, FacilityBusinessConfigWrapper.class);
        }
		return facilityWrapper;
	}


}
