/**
 * Created by t.holawala on 26.09.2017.
 */

/**
    @Description: Controller for the OpportunityLineItems.page
 */
global without sharing class CtrOpportunityLineItems {

    public Opportunity opp          { get; set;}
    public String oppId             { get; private set; }
    public String flatCommissionName { get; private set; }
    public boolean blnTimeBaseEnable { get; private set; }
    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    public boolean isATPremimumPlacement { get; private set; } // SSC-1932 - PP for AT
    
    public CtrOpportunityLineItems(ApexPages.StandardController controller){
        if(!Test.isRunningTest()){
        	controller.addFields(new List<String> {'Id_Tarif__c', 'Account.Backend_ID__c'});
        }
        this.opp        = (Opportunity)controller.getRecord();
        oppId           = this.opp.Id;
		Business_Config__c flatCommissionTarifRule = LibBusinessConfig.getBusinessConfigFromRuleMap('addOpportunityLineItems', opp.RecordTypeId, 'FlatCommissionTarif');
		flatCommissionName = flatCommissionTarifRule == null ? '' : flatCommissionTarifRule.Business_Rule_Value__c;

        String oppRecordtypeName = LibBusinessConfig.getRecordTypeDevName(opp, 'Opportunity');
        if(oppRecordtypeName != 'Chain_Opportunity'){
            Business_Config__c timeBaseRule = LibBusinessConfig.getBusinessConfigFromRuleMap('addOpportunityLineItems', opp.RecordTypeId, 'TimeBaseEnable');
            blnTimeBaseEnable = timeBaseRule == null ? false : Boolean.valueof(timeBaseRule.Business_Rule_Value__c);
        }
        else{
            Business_Config__c chainTimeBaseRule = LibBusinessConfig.getBusinessConfigFromRuleMap('TimeBaseEnableForChain', opp.RecordTypeId, LibRecordTypeHelper.getRecordTypeValue(opp.Account.recordtypeId));
            blnTimeBaseEnable = chainTimeBaseRule == null ? false : Boolean.valueof(chainTimeBaseRule.Business_Rule_Value__c);
        }
        // SSC-1932 - PP for AT
        Business_Config__c atPremiumPlacementRule = LibBusinessConfig.getBusinessConfigFromRuleMap(Constants.BUSINESSCONFIG_PROCESSNAME_ADDOPPORTUNITYLINEITEMS, opp.RecordTypeId, Constants.BUSINESSCONIFG_RULENAME_ENABLESFPREMIUMPLACEMENTUI);
        isATPremimumPlacement = atPremiumPlacementRule == null ? false : Boolean.valueof(atPremiumPlacementRule.Business_Rule_Value__c);
    
	}

       /**
        @Description: Remote action to populate the Tarif Wrapper from the opportunity line items if there are
                        any opprotunity line items associated with the opportunity
     */
    @RemoteAction
    global static TarifWrapper populateData(String oppId){
        TarifWrapper wrapper  = new TarifWrapper(oppId);
	    return wrapper;
    }

    /**
        @Description: Fetches the Tarifs and the related tariff members and populates the Tarif Wrapper
                        on the change of tariff
     */
    @RemoteAction
    global static CtrOpportunityLineItems.TarifWrapper popuateTarifDetails(String serializedWrapper){
        CtrOpportunityLineItems.TarifWrapper tarifWrapper
                        = (CtrOpportunityLineItems.TarifWrapper)JSON.deserialize(serializedWrapper,CtrOpportunityLineItems.TarifWrapper.class);
		
        Tarif tar = new Tarif(tarifWrapper.tarifId, tarifWrapper.opp.RecordTypeId);
		Business_Config__c flatCommissionTarifRule = LibBusinessConfig.getBusinessConfigFromRuleMap('addOpportunityLineItems', tarifWrapper.opp.RecordTypeId, 'FlatCommissionTarif');
        // SSC-1932 - AT PP Changes Starts Here
        Business_Config__c atPPTarifRule = LibBusinessConfig.getBusinessConfigFromRuleMap(Constants.BUSINESSCONFIG_PROCESSNAME_ADDOPPORTUNITYLINEITEMS, tarifWrapper.opp.RecordTypeId, Constants.BUSINESSCONIFG_RULENAME_ENABLESFPREMIUMPLACEMENTUI);

        if(String.isNotBlank(tar.name) && tar.name.equals(Constants.TARIF_NAME_PREMIUM_PLACEMENT) && (atPPTarifRule==null || !Boolean.valueof(atPPTarifRule.Business_Rule_Value__c))) {
            Date today = Date.Today();
			tar.fetchAvailableBookings(tarifWrapper.opp, tarifWrapper.opportunityCountry, today.month() + '-' + today.year());
			tarifWrapper.tarif = tar;
		} else if (flatCommissionTarifRule != null && tar.name == flatCommissionTarifRule.Business_Rule_Value__c) {
			tarifWrapper.tarif = tar;
			tarifWrapper.populateCategoryOptions();
			tarifWrapper.populateProductOptions();
		} else {
			// Fetch Commissions associated with the tarif
	        tar.fetchCommissionsFromTarif();
	        tar.fetchProductsFromTarif();
	        tar.fetchAddOnsFromTarif();	
	        tarifWrapper.tarif = tar;
	        tarifWrapper.populateCategoryOptions();
	        tarifWrapper.populateProductOptions();
		}   
	    
	    	//locking add ons based on Buisness Configs
        	Business_Config__c lockAddons = LibBusinessConfig.getBusinessConfigFromRuleMap('addOpportunityLineItems', tarifWrapper.opp.RecordTypeId, 'lockAddons');
		TarifWrapper.lockingAddon = lockAddons == null ? TarifWrapper.tarif.locked : TarifWrapper.tarif.locked || String.valueOf(lockAddons.Business_Rule_Value__c).contains(tarifWrapper.tarif.name);
		
		LoggingUtility.commitLogs();  

        return tarifWrapper;
    }

    @RemoteAction
    global static TarifWrapper fetchBookings(String serializedWrapper){
    	try{
	    	CtrOpportunityLineItems.TarifWrapper tarifWrapper
	                        = (CtrOpportunityLineItems.TarifWrapper)JSON.deserialize(serializedWrapper,CtrOpportunityLineItems.TarifWrapper.class);
	                        
	    	tarifWrapper.tarif.fetchAvailableBookings(tarifWrapper.opp,tarifWrapper.opportunityCountry,tarifWrapper.tarif.monthYear);
	    	LoggingUtility.commitLogs();
	    	return tarifWrapper;
    	}catch(Exception e){
    		LoggingUtility.commitLogs();
    		throw e;
    	}
    }
 
    @RemoteAction
    global static TarifWrapper save(String serializedWrapper){
        CtrOpportunityLineItems.TarifWrapper tarifWrapper
                        = (CtrOpportunityLineItems.TarifWrapper)JSON.deserialize(serializedWrapper,CtrOpportunityLineItems.TarifWrapper.class);

        // SSC-1932 - AT PP Changes Starts Here
        Business_Config__c atPPTarifRule = LibBusinessConfig.getBusinessConfigFromRuleMap(Constants.BUSINESSCONFIG_PROCESSNAME_ADDOPPORTUNITYLINEITEMS, tarifWrapper.opp.RecordTypeId, Constants.BUSINESSCONIFG_RULENAME_ENABLESFPREMIUMPLACEMENTUI);
        if(String.isNotBlank(TarifWrapper.tarif.name) && TarifWrapper.tarif.name.equals(Constants.TARIF_NAME_PREMIUM_PLACEMENT) && (atPPTarifRule==null || !Boolean.valueof(atPPTarifRule.Business_Rule_Value__c))){
            tarifWrapper.tarif.savePPLineItems(tarifWrapper.opp,tarifWrapper.opportunityCountry);
        }else{    	
	        TarifWrapper.tarif.save(tarifWrapper.opp);
        }
        
        LoggingUtility.commitLogs();
        return tarifWrapper;
    }
    
    /**
    * @Description: A remoting method to create the quote
    */
    @RemoteAction
    global static String createQuote(String serializedWrapper){
    	CtrOpportunityLineItems.TarifWrapper tarifWrapper
                        = (CtrOpportunityLineItems.TarifWrapper)JSON.deserialize(serializedWrapper,CtrOpportunityLineItems.TarifWrapper.class);
        return TarifWrapper.tarif.createQuote(tarifWrapper.opp,tarifWrapper.opportunityCountry);
    }
	
    /**
    * @Description: A remoting method get nintexPackage details
    */
    @RemoteAction
    global static String getPackageDetails(String oppQuoteId, String oppRecordTypeId, String recCountry){
        return getPackageDetails(oppQuoteId, oppRecordTypeId, false, recCountry);
    }
    
    /**
    * @Description: A remoting method get nintexPackage details
    */
    @RemoteAction
    global static String getPackageDetails(String oppQuoteId, String oppRecordTypeId, Boolean isInClassicConsole, String recCountry){

        /* Adding variables to store recordtypename, countryname and recordtype name */
        String oppRecordTypeName = LibRecordTypeHelper.getRecordTypeValue(oppRecordTypeId);
	//Nintex for chain opps
        if(oppRecordTypeName == 'Chain_Opportunity'){
	            
                /* getting account recordtype and checking if nintex for chain opportunity is enabled */
                String accRecordTypeName = LibRecordTypeHelper.getRecordTypeValue(AccountSelector.getAccountRecordTypeByCountry(recCountry));                
                Business_Config__c chainOppBC = LibBusinessConfig.getBusinessConfigFromRuleMap(Constants.BUSINESSCONFIG_PROCESSNAME_NINTEXFORCHAINOPP,oppRecordTypeId,accRecordTypeName);
                
                if(chainOppBC == null || chainOppBC.business_rule_value__c == null){
                    return '/'+oppQuoteId;
                }
                else{
                    oppRecordTypeName = chainOppBC.business_rule_value__c;
                }
            }    
        List<String> recordTypeNamesList = new List<String>{oppRecordTypeName};
        List<String> countryNamesList = new List<String>{recCountry};
        //SSC-3422 Making country specific queries to generate Nintex
        Map<String,Map<String,Map<String, Business_Config__c>>> fullBCMap =  LibBusinessConfig.getBCDataWithProAndCountryAndRecType(Constants.BUSINESSCONFIG_PROCESSNAME_NINTEXDOCGENERATION, countryNamesList, recordTypeNamesList);


        if(fullBCMap == null ||fullBCMap.isempty()){
            return '/'+oppQuoteId;
        }

        /* Adding temporary variables */
        Map<String,Map<String, Business_Config__c>> countryMap = fullBCMap.get(oppRecordTypeName);
        Map<String, Business_Config__c> mapBusinessRules = countryMap == null || countryMap.isempty() ? null : countryMap.get(recCountry) == null ? countryMap.get('ALL') : countryMap.get(recCountry);

        if(mapBusinessRules == null){
            return '/'+oppQuoteId;
        }
        
        String retURL;
        String docGenPackageId, deliveryOptionId, returnUrl, docGenPackageName, deliveryOptionName;       
        
        if(mapBusinessRules != null && mapBusinessRules.get('docGenPackageName') != null && mapBusinessRules.get('deliveryOptionName') != null){
            docGenPackageName = mapBusinessRules.get('docGenPackageName').Business_rule_value__c;
            deliveryOptionName = mapBusinessRules.get('deliveryOptionName').Business_rule_value__c;
    		
    	}

        List<Loop__DDP_Integration_Option__c> doList = [SELECT Id, Loop__DDP__r.Id FROM Loop__DDP_Integration_Option__c WHERE Name = :deliveryOptionName AND Loop__DDP__r.Name = :docGenPackageName];
         if(doList.isEmpty()){
            returnUrl = '/'+oppQuoteId;
        }
        else{
            docGenPackageId = doList[0].Loop__DDP__r.Id;
            deliveryOptionId = doList[0].Id;
            if(isInClassicConsole){
                retURL = '/console';
            } else {
                retURL = oppQuoteId;
            }
            //returnUrl = '/apex/loop__looplus?&eid=' + oppQuoteId + '&header=false&sidebar=false&hidecontact=true&hideddp=true&autorun=true&ddpIds='+docGenPackageId+'&deploy='+deliveryOptionId+'&retURL=' + oppQuoteId;
            returnUrl = '/apex/loop__looplus?&eid=' + oppQuoteId + '&header=false&sidebar=false&hidecontact=true&hideddp=true&autorun=true&ddpIds='+docGenPackageId+'&deploy='+deliveryOptionId+'&retURL=' + retURL;     
        }
        
        return returnUrl;
    }

    
    /**
    * @Description: A remoting method to validate opportunity and all related records
    */
    @RemoteAction
    global static String validate(Opportunity opp){

        // validation is now changed based on the recordcoutry field of Opportunity
        if(String.isBlank(opp.Record_Country__c)){
            return 'No Error';
        }
        /* Adding variables for Bank Detail */
        String errorMessage = Label.RequiredFieldMissingMessage+ ' \n', accSoqlString, conSoqlString, addSoqlString, oppSoqlString, bankSoqlString;

        Boolean isError = false, isConError = false, isAddError = false, isOppError = false, requiredContactRoleExists = false, isBankError = false ;
        String oppRecordTypeName = LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId);
        //For Chain Opportunities, checking the account recordtype to apply validation rules
        if(oppRecordTypeName == 'Chain_Opportunity'){
	    
	    if(ValidateChainOpportunity(opp,opp.RecordTypeId)){
                 return 'No Error';
            }
            /* getting account recordtype and checking if validation rules are applicable */
            String accRecordTypeName = LibRecordTypeHelper.getRecordTypeValue(opp.Account.RecordTypeId);
            
            Business_Config__c chainOppBC = LibBusinessConfig.getBusinessConfigFromRuleMap('nintexForChainOpp',opp.RecordTypeId,accRecordTypeName);
            
            if(chainOppBC == null || chainOppBC.business_rule_value__c == null){
                return 'No Error';
            }
            else{
                oppRecordTypeName = chainOppBC.business_rule_value__c;
            }
        }

        //@Ticket #           : SSC-1214
        return ValidateOpportunity(oppRecordTypeName,opp);


    }

    /**
      * @Description: This method shortlists the opportunites on the basis of business type to check validation
            @Process Name       : VALIDATE CHILD CHAIN OPPTY ON QUOTE CREATION
            @Business Config    : nintexForChainOpp
            @Input Params       : Opportunity record and record type id
            @Return             : boolean true/false
            @TriggerContext     : Before Update.
      */
    public static boolean ValidateChainOpportunity(Opportunity opp,string recordtypeId){

        Map<String, Map<String, Business_Config__c>> mapBusinessLogic   = moam.get('nintexForChainOpp');
        Map<String, Business_Config__c> rules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(recordtypeId));

        if (rules == null || !rules.containsKey('Business_Type__c')) {
            return true;
        }



        if(!rules.get('Business_Type__c').Business_Rule_Value__c.split(',').contains(opp.Business_Type__c))
        {
            return true;
        }
        return false;
    }

    /**
      * @Description: This method return the error message by checking the business config
            @Process Name       : VALIDATE CHILD CHAIN OPPTY ON QUOTE CREATION AND Case Closure
            @Business Config    : nintexForChainOpp
            @Input Params       : record type name and opportunity
            @Return             : string
            @TriggerContext     : Before Update.
      */
    public static string ValidateOpportunity(string oppRecordTypeName,Opportunity opp ){

        /* Adding variables to store countryname and recordtype name */
        List<String> recordTypeNamesList = new List<String>{oppRecordTypeName};
        List<String> countryNamesList = new List<String>{opp.Record_Country__c};

        /* Adding variables for Bank Detail */
        String errorMessage = Label.RequiredFieldMissingMessage+ ' \n', accSoqlString, conSoqlString, addSoqlString, oppSoqlString, bankSoqlString;

        Boolean isError = false, isConError = false, isAddError = false, isOppError = false, requiredContactRoleExists = false, isBankError = false ;

        Map<String,Map<String,Map<String, Business_Config__c>>> fullBCMap =  LibBusinessConfig.getBCDataWithProAndCountryAndRecType('validationRules', countryNamesList, recordTypeNamesList);


        if(fullBCMap == null ||fullBCMap.isempty()){
            return 'No Error';
        }

        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        String type = 'Account';
        try{
            /* Adding temporary variables */
            Map<String,Map<String, Business_Config__c>> countryMap = fullBCMap.get(oppRecordTypeName);
            Map<String, Business_Config__c> mapBusinessRules = countryMap == null || countryMap.isempty() ? null : countryMap.get(opp.Record_Country__c) == null ? countryMap.get('ALL') : countryMap.get(opp.Record_Country__c);

            if(mapBusinessRules == null){
                return 'No Error';
            }

            //Checking Account fields
            if(mapBusinessRules.containsKey('accountFields')){
                type = 'Account';
                Schema.SObjectType leadSchema = schemaMap.get(type);
                Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

                String fieldsString = mapBusinessRules.get('accountFields').Business_Rule_Value__c;
                List<String> fieldList = fieldsString.split(',');
                accSoqlString = 'SELECT Id,' + fieldsString + ' FROM Account WHERE Id =' + '\'' +opp.AccountId + '\'';
                List<Account> accList = Database.query(accSoqlString);
                if(accList.isEmpty()){
                    return 'Account Not found';
                }
                else{
                    for(String fld : fieldList){
                        //SSC-614 Additional checks for Tax Number
                        if(fld != 'Food_License_Number__c' && fld != 'Tax_Number__c')
                        {
                            if(accList[0].get(fld) == null){
                                isError = true;
                                errorMessage += 'Account.'+ fieldMap.get(fld).getDescribe().getLabel() + ', ';
                            }
                        }

                        else{
                            if(fld == 'Food_License_Number__c' && mapBusinessRules.containsKey('accountFieldsAdditionalCheck') &&
                                    mapBusinessRules.get('accountFieldsAdditionalCheck').Business_Rule_Value__c.contains('Vertical__c')){
                                string accVV = String.valueOf(accList[0].get('Vertical__c'));
                                string vv = mapBusinessRules.get('accountFieldsAdditionalCheck').Business_Rule_Value__c.substringBetween('<Vertical__c>','<Vertical__c>');

                                if(String.isNotEmpty(accVV) && vv.contains(accVV) && accList[0].get(fld) == null ){
                                    isError = true;
                                    errorMessage += 'Account.'+ fieldMap.get(fld).getDescribe().getLabel()  + ', ';
                                }
                            }
                            //SSC-614 Additional checks for Tax Number
                            else if(fld == 'Tax_Number__c' && mapBusinessRules.containsKey('accountFieldsAdditionalCheck') &&
                                    mapBusinessRules.get('accountFieldsAdditionalCheck').Business_Rule_Value__c.contains('Menu_Tax_Information__c')){
                                string accTN = String.valueOf(accList[0].get('Menu_Tax_Information__c'));
                                string tn = mapBusinessRules.get('accountFieldsAdditionalCheck').Business_Rule_Value__c.substringBetween('<Menu_Tax_Information__c>','<Menu_Tax_Information__c>');

                                if(String.isNotEmpty(accTN) && tn.contains(accTN) && accList[0].get(fld) == null ){
                                    isError = true;
                                    errorMessage += 'Account.'+ fieldMap.get(fld).getDescribe().getLabel()  + ', ';
                                }
                            }
			    //Additional check for tax number based on COuntries
                            else if(fld == 'Tax_Number__c' && mapBusinessRules.containsKey('accountFieldsAdditionalCheck') &&
                                    mapBusinessRules.get('accountFieldsAdditionalCheck').Business_Rule_Value__c.contains('Tax_Number__c')){
                                string countriesForTaxNumValidation = mapBusinessRules.get('accountFieldsAdditionalCheck').Business_Rule_Value__c.substringBetween('<Tax_Number__c>','<Tax_Number__c>');

                                if(String.isNotEmpty(countriesForTaxNumValidation) && countriesForTaxNumValidation.contains(opp.Record_Country__c) && accList[0].get(fld) == null ){
                                    isError = true;
                                    errorMessage += 'Account.'+ fieldMap.get(fld).getDescribe().getLabel()  + ', ';
                                }
                            }	
                        }

                    }
                    errorMessage = isError ? errorMessage.removeEnd(', ') + ';' +' \n ' : errorMessage;

                    //Delivery_Service__c should not contain value 'Unknown'
                    if(mapBusinessRules.containsKey('accountFieldsAdditionalCheck') &&
                            mapBusinessRules.get('accountFieldsAdditionalCheck').Business_Rule_Value__c.contains('Delivery_Service__c')){
                        string accDS = String.valueOf(accList[0].get('Delivery_Service__c'));
                        string ds = mapBusinessRules.get('accountFieldsAdditionalCheck').Business_Rule_Value__c.substringBetween('<Delivery_Service__c>','<Delivery_Service__c>');

                        if(String.isNotEmpty(accDS) && ds.contains(accDS) && accList[0].get('Delivery_Service__c') != null ){
                            isError = true;
                            errorMessage += Label.InvalidDeliveryService + ' \''+ds + '\';' + ' \n';
                        }
                    }


                }

            }
            //Checking Contact fields
            if(mapBusinessRules.containsKey('contactFields')){
                type = 'Contact';
                Schema.SObjectType leadSchema = schemaMap.get(type);
                Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

                String fieldsString = mapBusinessRules.get('contactFields').Business_Rule_Value__c;
                List<String> fieldList = fieldsString.split(',');
                conSoqlString = 'SELECT Id,' + fieldsString + ' FROM Contact WHERE AccountId =' + '\'' +opp.AccountId + '\'' + 'AND (Contact_Role__c = \'Owner\' OR Contact_Role__c = \'Billing Manager\')';
                List<Contact> conList = Database.query(conSoqlString);
                if(conList.isEmpty()){
                    isConError = true;
                    errorMessage += 'Contact owner doesnt exist;  \n ';
                }
                else{

                    String requiredCOntactRole = 'Owner';
                    String contactOptinRole = '';
                    //Getting Mandatory contact role from business config;
                    if(mapBusinessRules.containsKey('contactFieldsAdditionalCheck')){
                        if(mapBusinessRules.get('contactFieldsAdditionalCheck').Business_Rule_Value__c.contains('Contact_Role__c')){
                            requiredCOntactRole = mapBusinessRules.get('contactFieldsAdditionalCheck').Business_Rule_Value__c.substringBetween('<Contact_Role__c>','<Contact_Role__c>');
                        }
                        
                        if(mapBusinessRules.get('contactFieldsAdditionalCheck').Business_Rule_Value__c.contains('Contact_Role__c')){
                            contactOptinRole = mapBusinessRules.get('contactFieldsAdditionalCheck').Business_Rule_Value__c.substringBetween('<Contact_Opt_in__c>','<Contact_Opt_in__c>');
                        }
                        
                    }
                    for(Contact con : conList){
                        for(String fld : fieldList){
                            if(fld == 'Contact_Opt_in__c'){
                                 //Contact_Opt_in__c field check is applicable only to the contactOptinRole mentioned in the Business config
                                if(con.get(fld) == null && contactOptinRole != '' && String.valueof(con.get('Contact_Role__c')).contains(contactOptinRole) ){
                                    errorMessage += con.Contact_Role__c + ' Contact.'+ fieldMap.get(fld).getDescribe().getLabel()  + ', ';
                                }
                            }else{
                                if(con.get(fld) == null){
                                    isConError = true;
                                    errorMessage += con.Contact_Role__c + ' Contact.'+ fieldMap.get(fld).getDescribe().getLabel()  + ', ';
                                } 
                            }
                                                        
                        }

                        if(con.get('Contact_Role__c') == requiredCOntactRole ){
                            requiredContactRoleExists = true;
                        }

                    }

                    errorMessage = isConError ? errorMessage.removeEnd(', ') + ';' + ' \n': errorMessage;

                    if(!requiredContactRoleExists){
                        isConError = true;
                        errorMessage += 'Contact owner not available;  \n';
                    }

                }

            }

            //Checking Address fields
            if(mapBusinessRules.containsKey('addressFields')){
                type = 'AddressDetail__c';
                Schema.SObjectType leadSchema = schemaMap.get(type);
                Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
                String requiredAddressType = 'Restaurant Address';
                //Getting Mandatory address type from business config;
                if(mapBusinessRules.containsKey('addressFieldsAdditionalCheck') &&
                        mapBusinessRules.get('addressFieldsAdditionalCheck').Business_Rule_Value__c.contains('Type__c')){
                    requiredAddressType = mapBusinessRules.get('addressFieldsAdditionalCheck').Business_Rule_Value__c.substringBetween('<Type__c>','<Type__c>');
                }

                String fieldsString = mapBusinessRules.get('addressFields').Business_Rule_Value__c;
                List<String> fieldList = fieldsString.split(',');
                addSoqlString = 'SELECT Id,' + fieldsString + ' FROM AddressDetail__c WHERE Account__c =' + '\'' +opp.AccountId + '\' AND Type__c includes ('  + '\'' +requiredAddressType + '\') LIMIT 1';
                List<AddressDetail__c> addList = Database.query(addSoqlString);
                if(addList.isEmpty()){
                    isAddError = true;
                    errorMessage += requiredAddressType + ' doesnt exist; \n ';
                }
                else{
                    for(String fld : fieldList){
                        if(addList[0].get(fld) == null){
                            isAddError = true;
                            errorMessage += ' AddressDetail.'+ fieldMap.get(fld).getDescribe().getLabel()  + ', ';
                        }

                    }
                    errorMessage = isAddError ? errorMessage.removeEnd(', ') + ';'+ ' \n' : errorMessage;
                }

            }

            //Checking Bank fields
            if(mapBusinessRules.containsKey('bankFields')){
                type = 'Bank_Detail__c';
                Schema.SObjectType bankSchema = schemaMap.get(type);
                Map<String, Schema.SObjectField> fieldMap = bankSchema.getDescribe().fields.getMap();
                /* Adding variables for Bank Detail */
                String fieldsString = '';
                for(Schema.SObjectField field : fieldMap.values()){
                     fieldsString += field.getDescribe().getName()+',';
                }
                fieldsString = fieldsString.removeEnd(',');
                bankSoqlString = 'SELECT ' + fieldsString + ' FROM Bank_Detail__c WHERE Account__c =' + '\'' +opp.AccountId + '\' AND Status__c = \'Active\' ORDER BY LastModifiedDate DESC LIMIT 1';
                List<Bank_Detail__c> bankList = Database.query(bankSoqlString);
                if(bankList.isEmpty()){
                    isBankError = true;
                    errorMessage += 'Bankdetail doesnt exist; \n ';
                }
                else{
                    List<String> fieldList = new List<string>();
                    string fieldListJson =  mapBusinessRules.get('bankFields').Business_Rule_Value__c;
                    //convert the validation from XML in to JSON - SSC-2259
                    Map<string,Map<string,List<string>>> mapOfBankObj = (Map<string,Map<string,List<string>>>) JSON.deserialize(fieldListJson,Map<string,Map<string,List<string>>>.class);
                    for(String fld : fieldsString.split(',')){
                        boolean isTrue = mapOfBankObj.containsKey(fld) && (bankList[0].get(fld) != null && mapOfBankObj.get(fld).containsKey(string.valueOf(bankList[0].get(fld))));
                        if(isTrue){
                            fieldList = mapOfBankObj.get(fld).get(string.valueOf(bankList[0].get(fld)));
                            break;
                        }
                    }
                    for(String fld : fieldList){
                        if(bankList[0].get(fld) == null){
                            isBankError = true;
                            errorMessage += ' BankDetail.'+ fieldMap.get(fld).getDescribe().getLabel()  + ', ';
                        }
                    }
                    errorMessage = isBankError ? errorMessage.removeEnd(', ') + ';'+ ' \n' : errorMessage;
                }
            }

            //Checking Opportunity fields
            if(mapBusinessRules.containsKey('opportunityFields')){
                type = 'Opportunity';
                Schema.SObjectType leadSchema = schemaMap.get(type);
                Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
                String fieldsString = mapBusinessRules.get('opportunityFields').Business_Rule_Value__c;
                List<String> fieldList = fieldsString.split(',');
                oppSoqlString = 'SELECT Id,Business_Type__c,' + fieldsString + ' FROM Opportunity WHERE Id =' + '\'' + opp.Id + '\' LIMIT 1';
                List<Opportunity> oppList = Database.query(oppSoqlString);
                if(oppList.isEmpty()){
                    isOppError = true;
                    errorMessage += 'Opportunity record doesnt exist; \n ';
                }
                else{
                    for(String fld : fieldList){
                        Boolean isExempted = false;

                        if(oppList[0].Business_Type__c == 'Switch' && mapBusinessRules.containsKey('opportunityFieldsSwitchException') 
                            && mapBusinessRules.get('opportunityFieldsSwitchException').Business_Rule_Value__c.contains(fld)){
                            continue;
                        }

                        //SSC-614 Additional checks for Onboarding Menu Comments
                        if((fld == 'List_Photo_Comments__c' || fld == 'Onboarding_Menu_Comments__c') && mapBusinessRules.containsKey('opportunityFieldsAdditionalCheck') &&
                                mapBusinessRules.get('opportunityFieldsAdditionalCheck').Business_Rule_Value__c.contains('Business_Type__c')){
                            string oppBT = String.valueOf(oppList[0].get('Business_Type__c'));
                            string exceptedBT = mapBusinessRules.get('opportunityFieldsAdditionalCheck').Business_Rule_Value__c.substringBetween('<Business_Type__c>','<Business_Type__c>');
                            if(String.isNotEmpty(oppBT) && exceptedBT.contains(oppBT)){
                                isExempted = true;
                            }
                        }

                        if(oppList[0].get(fld) == null && !isExempted){
                            isOppError = true;
                            errorMessage += ' Opportunity.'+ fieldMap.get(fld).getDescribe().getLabel()  + ', ';
                        }
                    }
                    errorMessage = isOppError ? errorMessage.removeEnd(', ') + ';' : errorMessage;
                }

            }

            if(isError || isConError || isAddError || isOppError || isBankError){
                return errorMessage;
            }
            else{
                return 'No Error';
            }
        }
        catch(Exception e){
            return e.getMessage();
        }
    }

	/**
    * @Description: Unlock the Opportunity. 
    */
    @RemoteAction
    global static TarifWrapper OpenTariff(String serializedWrapper ) {
    	 CtrOpportunityLineItems.TarifWrapper tarifWrapper
                        = (CtrOpportunityLineItems.TarifWrapper)JSON.deserialize(serializedWrapper,CtrOpportunityLineItems.TarifWrapper.class);
    	String idOpp;
    	
    	idOpp = tarifWrapper.opp.id;
    	
		List<Opportunity_Quote__c> lstOptQuo = new List<Opportunity_Quote__c>();
		List<case> lstCaseQuality = new List<case>();
		String messageStr;
		
		lstOptQuo = [SELECT Id,Id_Opportunity__c,Status__c 
				FROM Opportunity_Quote__c 
				WHERE Id_Opportunity__c = :idOpp 
				AND Status__c = 'Accepted'
				AND Id_Opportunity__r.StageName  ='Please Check'];
			
		lstCaseQuality = [SELECT Closed_Reason__c,Id,IsClosed,Opportunity__c,Reason,Type 
							FROM Case 
							WHERE Opportunity__c = :idOpp 
							AND Closed_Reason__c = 'Successful' 
							AND Type = 'Quality Check'];
		
		for(Opportunity_Quote__c oppQuo :lstOptQuo){
			oppQuo.Status__c = 'Declined';
		}
		if(lstOptQuo.size()>0 && lstCaseQuality.size() == 0 ){
			try{
				tarifWrapper.isOpportunityLocked = false;
				tarifWrapper.blnShowUnlock = false;
				
				update lstOptQuo;
				messageStr = Label.Success_unlock_Opportunity;
			}
			catch(exception e){
				messageStr = e.getMessage();
			}
		}else
		{
			messageStr = label.Error_unlock_Opportunity;
		}
	    
	    return tarifWrapper;
	}    


    /**
        @Description: A wrapper class to hold Tarif and all the related data
     */
    global class TarifWrapper{

		private  Map<String, Map<String,Map<String,Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
        public Tarif tarif;
        public string tarifId;
        public List<Option> tarifOptions;
        public List<Option> commissionOptions;
        public List<Option> categoryOptions;
        public List<option> addOnOptions;
        public List<Option> additionalChargesOptions;
        public List<Option> productOptions;
        public List<Option> sizeOptions;
        public List<option> weightOptions;
        public List<option> numberOfCopiesOptions;
        public List<Option> depositMethodOptions;
        public List<Option> billableAccountOptions;
        public List<Option> monthYearOptions;
		public List<Option> timeBaseTierOptions;
		public List<Option> deliveryOptions;
        public Tarif.Commission emptyCommission;
        public Tarif.Product emptyProduct;
		public Tarif.Product emptyAssetBranding;
        public Tarif.AddOn emptyAddOn;
        public Opportunity opp;
        public Country__c opportunityCountry;
        public boolean isOpportunityLocked;
        public boolean isPremiumPlacementOpportunity;
        public boolean showUnlock;
	    public boolean blnShowUnlock ;
		public boolean isMandatoryTimebase ;
        public boolean blnShowDeliveryField;
	 /**
        * Variable stores value if add ons are to be locked on OpportunityLineItems vf page
         */
        public boolean lockingAddon;
	    
        public TarifWrapper(String oppId){
            emptyCommission             	= new Tarif.commission();
            emptyProduct                	= new Tarif.Product();
            emptyAddOn						= new tarif.AddOn();
			emptyAssetBranding				= new tarif.Product();
            emptyCommission.hasRelatedTarif = false;
            emptyProduct.hasRelatedTarif 	= false;
			emptyAssetBranding.hasRelatedTarif 	= false;
            emptyAddOn.hasRelatedTarif		= false;
            emptyProduct.totalAmount		= 0;
			emptyAssetBranding.totalAmount	= 0;
            sizeOptions 					= populateOptionsFromPickList('Size__c');
	        weightOptions					= populateOptionsFromPickList('Weight__c');
	        numberOfCopiesOptions			= populateOptionsFromPickList('Number_Of_Copies__c');
	        depositMethodOptions			= populateOptionsFromPickList('Deposit_Method__c');
			timeBaseTierOptions				= populateOptionsFromPickListByObject('Opportunity','Time_Based_Tier_Type__c');
			deliveryOptions					= populateOptionsFromPickList('Delivery__c');
	        blnShowUnlock = checkUnlock(oppId);
            populateOpportunity(oppId);
            checkIfOpportunityIsPremiumPlacement(opp);
            checkIfOpportunityIsLocked(opp);
            populateOpportunityCountry();
            populateTarifWrapperFromItems();
            populateTarifOptions();
            populateCommissionOptions();
            populateCategoryOptions();
            populateAddOnoptions();
            populateProductOptions();	   
            populateBillableAccountOptions();   
            populateMonthYearOptions();
			isMandatoryTimebase = false;
            populateShowDeliveryField();
            
        }
        
        private boolean checkUnlock (String oppId){
		 		List<Opportunity_Quote__c> lstOptQuo = new List<Opportunity_Quote__c>();
				List<case> lstCaseQuality = new List<case>();
				
				lstOptQuo = [SELECT Id,Id_Opportunity__c,Status__c,Id_Opportunity__r.Parent_Opportunity__c,
                            Id_Opportunity__r.Parent_Opportunity__r.RecordType.DeveloperName, Id_Opportunity__r.Id_Tarif__r.Name
						FROM Opportunity_Quote__c 
						WHERE Id_Opportunity__c = :oppId 
						AND Status__c = 'Accepted'
						AND Id_Opportunity__r.StageName  ='Please Check'];
					
				lstCaseQuality = [SELECT Closed_Reason__c,Id,IsClosed,Opportunity__c,Reason,Type 
									FROM Case 
									WHERE Opportunity__c = :oppId  
									AND Closed_Reason__c = 'Successful' 
									AND Type = 'Quality Check'];
            
            if(lstOptQuo.size() > 0 && lstOptQuo[0].Id_Opportunity__r.Id_Tarif__r.Name == 'Premium Placement'){
                return false;
            }

				// If the parent opportunity is a chain opportunity do not allow unlocking of the opportunity
				if(lstOptQuo.size()>0 && 
					lstOptQuo[0].Id_Opportunity__r.Parent_Opportunity__c != null &&
					lstOptQuo[0].Id_Opportunity__r.Parent_Opportunity__r.recordType.developerName == 'Chain_Opportunity'){
						return false;	
				}	 
		
				if(lstOptQuo.size()>0 && lstCaseQuality.size() == 0){  
					return true; 		
				}
				else{
					return false;
				}
        }

        /**
            @Description: Populates the opportunity from the opportunity Id
         */
        private void populateOpportunity(String oppId){
            opp = [SELECT id, account.Backend_ID__c, CurrencyIsoCode, Company_Code__c, Record_Country__c,Id_Tarif__c,
            				Id_Tarif__r.name,stageName,account.recordType.developerName,Payment_Method__c,
                            Country__c,accountId,recordTypeId,recordType.developerName, Account.Vertical__c, Business_Type__c, Time_Based_Tier_Type__c,Source_System__c,
                            Account.Commission_Base__c
                  FROM Opportunity
                  WHERE id = :OppId ];
        }
        
        /**
        * Check if the opportunity is a premium placement opportunity in order to prevent changing of tarif
        */
        public void checkIfOpportunityIsPremiumPlacement(Opportunity Opp){
        	if(opp.Id_tarif__c != null && opp.Id_Tarif__r.name == 'Premium Placement'){
        		isPremiumPlacementOpportunity = true;
			}
        	isPremiumPlacementOpportunity = false;
        }
        
        /**
	    * @Description: Lock the opportunity line items 
	    				1.If an opportunity is Closed/Lost
	    				2. if an existing quote has the status either 'Accepted' or 'Waiting for answer'.
	    */
	    private void checkIfOpportunityIsLocked(Opportunity opp) {

            Business_Config__c tarifRule = LibBusinessConfig.getBusinessConfigFromRuleMap('addOpportunityLineItems', opp.RecordTypeId, 'LockedTarifs');
            Set<String> tarifNames = tarifRule == null ? new Set<String>() : new Set<String>(tarifRule.Business_Rule_Value__c.replaceAll(' ,|, ', ',').split(','));

            if(opp.stageName == 'Closed Lost' || (opp.Id_Tarif__r.name == 'Premium Placement' && opp.Source_System__c == 'MIDAS') || tarifNames.contains(opp.Id_Tarif__r.Name)){

	        	this.isOpportunityLocked = true;
	        	return;
	        }
	        List<Opportunity_Quote__c> listOppQuote =  [SELECT Id 
	        												FROM Opportunity_Quote__c 
	        												WHERE Id_Opportunity__c = :opp.Id 
	        													AND Status__c IN ('Waiting for answer', 'Accepted', 'Approval Pending')];
	        if (!listOppQuote.isEmpty()) {
	            this.isOpportunityLocked = true;
	        } else {
	            this.isOpportunityLocked = false;
	        }
	    }
        
        /**
        * @Description: This method populates the opportunity associated with the country
        */
        public void populateOpportunityCountry(){
        	opportunityCountry = [SELECT Id, Name, Iso__c 
    								FROM Country__c 
    								WHERE Name = : opp.Record_Country__c LIMIT 1];
        								
        }

        /**
            @Description: Populates the list of Tarif available for the country and the company
         */
        private void populateTarifOptions(){
        	tarifOptions	 = new List<Option>();
			List<Tarif__c> tarifs = [SELECT Id,Name
							            FROM Tarif__c
							            WHERE RecordTypeId = : LibRecordTypeHelper.getRecordTypeValue(opp.Company_Code__c + '_Tarif')
							            	AND Id_Country__c = : opportunityCountry.Id
							            	AND Is_Active__c = true 
							            	//AND Name != 'Premium Placement'  // Excluding premium placement as premium placement opps are created differently
						            	order by Name ASC];

            for(Tarif__c tarif : tarifs){
				if (tarif.id == opp.Id_Tarif__c) {
					tarifOptions.add(new Option(tarif.name, tarif.id, true));
				} else {
					tarifOptions.add(new Option(tarif.name, tarif.id, false));
				}
            }
        }

        /**
            @Description:  Populates the list of Commissions available based on the country and the company
         */
        private void populateCommissionOptions(){
        	commissionOptions	= new List<Option>();
            List<List_Service_price__c> commissions = [SELECT Id, Name
											            FROM List_Service_Price__c
											            WHERE RecordTypeId = : LibRecordTypeHelper.getRecordTypeValue(opp.Company_Code__c + '_List_Service_Price')
											            AND Id_Country__c = : opportunityCountry.Id 
											            AND Is_Active__c = true];

            for(List_Service_price__c comm : commissions){
                commissionOptions.add(new Option(comm.name,comm.id));
            }
        }

        /**
            @Description:  Populates the list of Categories available based on the country and the company
         */
        public void populateCategoryOptions(){
        	categoryOptions 	 = new List<option>();
        	List<List_Product_Group__c> productGroups;
        	if(tarif.availableCategories.size() > 0){
        		productGroups = [SELECT Id, Name
                                    FROM List_Product_Group__c
                                    WHERE RecordTypeId = : LibRecordTypeHelper.getRecordTypeValue(opp.Company_Code__c + '_List_Product_Group')
                                    	AND Id_Country__c = : opportunityCountry.Id
                                    	AND Name in: tarif.availableCategories];
			}else{
        		productGroups = [SELECT Id, Name
                                    FROM List_Product_Group__c
                                    WHERE RecordTypeId = : LibRecordTypeHelper.getRecordTypeValue(opp.Company_Code__c + '_List_Product_Group')
                                    AND Id_Country__c = : opportunityCountry.Id];	
        	}
            

            for(List_Product_Group__c pg : productGroups){
                categoryOptions.add(new Option(pg.name,pg.id));
            }
        }

        /**
            @Description:  Populates the list of Add Ons available based on the country and the company
         */
        private void populateAddOnoptions(){
        	addOnOptions	= new List<option>();
            List<List_Add_on__c> addOnList = [SELECT Id,Name 
        										FROM List_Add_On__c
        										WHERE RecordTypeId = : LibRecordTypeHelper.getRecordTypeValue(opp.Company_Code__c + '_List_Add_On')
                                                    AND Id_Country__c = : opportunityCountry.Id
                                                    AND Is_Active__c = true];
                                                    
            for(List_Add_On__c addOn: addOnList){
            	addOnOptions.add(New Option(addOn.name,addOn.Id));
            }
        }
        
        /**
        	@Description: This method populates all the Products (Additonal charges and assets)
        */
		public void populateProductOptions(){
			productOptions	 = new List<Option>();
			if(tarif.availableCategories.size() > 0){
				List<List_Product_price__c> products = 
										[SELECT Id,Name,Displayed_Name__c,Product_name__c
											FROM List_Product_Price__c 
											WHERE RecordTypeId = : LibRecordTypeHelper.getRecordTypeValue(opp.Company_Code__c + '_List_Product_Price') 
												AND Id_Country__c = :opportunityCountry.id
												AND Id_List_Product_group__r.name in: tarif.availableCategories
												AND Is_Active__c = true];
				
				for(List_product_price__c prod : products){
					productOptions.add(new Option(prod.Product_name__c,prod.Id));
				}
			}
		}
		
		/**
		* @Description: This method populates the list of all the billable accounts in the hierarchy, Also concatenates the account name with the account type 
						in order to avoid confusion between accounts having same name
		*/
		public void populateBillableAccountOptions(){
			billableAccountOptions = new List<Option>();
            billableAccountOptions.add(new Option(opp.RecordType.DeveloperName.equals(ClsOpportunityProcessor.RT_CHAIN) ? Label.OptionChain
                                                                                                                : Label.OptionNone, ''));
			List<Account> accountsHierarchy = getAccountHierarchy(opp.AccountId);
			for(Account acc: accountsHierarchy){
				String type = acc.Type == null ? '' : ' (' + acc.Type + ')';
				billableAccountOptions.add(new Option(acc.Name + type,acc.Id));
			}
		}
		
		/**
		* @Description: This method populates the list of month-year for premium placement
		*/
		public void populateMonthYearOptions(){
			monthYearOptions = new List<Option>();
			Date today = Date.today();
            monthYearOptions.add(new Option(today.month() + '-' + today.year(), today.month() + '-' + today.year(),true));

            for (integer i = 0; i < 10; i++) {
                Date nextDate = today.addMonths(i + 1);
                monthYearOptions.add(new Option(nextDate.month() + '-' + nextDate.year(), nextDate.month() + '-' + nextDate.year()));
            }
		}

		/**
		* @Description: This method populates from the bussiness config if is the delivery field show into Opportunity line Item. SP-3222
		*/
		public void populateShowDeliveryField(){
			Map<String,Business_Config__c> mapBusinessData;
			Map<String,Map<String,Business_Config__c>> mapProcessData= moam.get('ShipmentOrders');
			blnShowDeliveryField = false;
			if(mapProcessData != null && !mapProcessData.isEmpty()){
				mapBusinessData = mapProcessData.get(this.opp.Account.RecordType.DeveloperName);
				if(mapBusinessData!= null && mapBusinessData.containsKey('DeliverableEnable')){
					blnShowDeliveryField = boolean.valueof(mapBusinessData.get('DeliverableEnable').Business_Rule_Value__c);
				}
			}
		}
		
		/**
		* @Descripton: This method popualtes all the accounts in the hierarchy(Upwards and downwards)
		*/
		public List<Account> getAccountHierarchy(String accountId){
			List<Account> accountHierarchy = new List<Account>();
			
			accountHierarchy.addAll(getAccountHierarchyUpwards(accountId));
			accountHierarchy.addAll(getAccountHierarchyDownwards(accountId));
			
			return accountHierarchy;
		}
		
		/**
		* @Description: This method gets the account hierarchy updwards
		*/
        public List<Account> getAccountHierarchyUpwards(String accountId){
            Account account                 = new Account();
            List<Account> accountHierarchy  = new List<Account>();
            
            account =   [Select Id,Name,type,
                            parentId,parent.name,parent.type,
                            parent.parentId,parent.parent.name,parent.parent.type,
                            parent.parent.parentId,parent.parent.parent.name,parent.parent.parent.type,
                            parent.parent.parent.parentId,parent.parent.parent.parent.name,parent.parent.parent.parent.type,
                            parent.parent.parent.parent.parentId,parent.parent.parent.parent.parent.name,parent.parent.parent.parent.parent.type,
                            Franchise_connection__c,Franchise_connection__r.name,Franchise_connection__r.type,
                            Franchise_connection__r.parentId,Franchise_connection__r.parent.name,Franchise_connection__r.parent.type,
                            Franchise_connection__r.parent.parentId,Franchise_connection__r.parent.parent.name,Franchise_connection__r.parent.parent.type,
                            Franchise_connection__r.parent.parent.parentId,Franchise_connection__r.parent.parent.parent.name,Franchise_connection__r.parent.parent.parent.type,
                            Franchise_connection__r.parent.parent.parent.parentId,Franchise_connection__r.parent.parent.parent.parent.name,Franchise_connection__r.parent.parent.parent.parent.type
                        FROM Account
                        WHERE id =: accountId];
            
            accountHierarchy.addAll(parentFlow(account, true, false));
            accountHierarchy.addAll(franchiseFlow(account));
            
            return accountHierarchy;
        }
		
        /**
        * @Description: This method gets the account hierarchy updwards during next runs 
        */
        public List<Account> getAccountHierarchyUpwardsNextRuns(String accountId, Boolean isFranchiseFlow){
            Account account                 = new Account();
            List<Account> accountHierarchy  = new List<Account>();
            
            account =   [Select Id,Name,type,
                            parentId,parent.name,parent.type,
                            parent.parentId,parent.parent.name,parent.parent.type,
                            parent.parent.parentId,parent.parent.parent.name,parent.parent.parent.type,
                            parent.parent.parent.parentId,parent.parent.parent.parent.name,parent.parent.parent.parent.type,
                            parent.parent.parent.parent.parentId,parent.parent.parent.parent.parent.name,parent.parent.parent.parent.parent.type
                        FROM Account
                        WHERE id =: accountId];

                accountHierarchy.addAll(parentFlow(account, false, isFranchiseFlow));
          

            return accountHierarchy;
        }

		/**
		* @Description: This method fetches all account hierarchy in downward direction eg. from Holding to group or brand.
						does not include branches
		*/
		public List<Account> getAccountHierarchyDownwards(Id accountId){
			Integer maxIterationCount 		= 5;
	    	List<Account> accountHierarchy	= new List<Account>();
	    	/**
	    	* NOTE: Making query in the loop in order to fetch the child account records, and fetching the child branch records
	    			in a single query degrades the performance of the query and will require entire table scan.
	    	*/
	    	List<String> parentIds = new List<String>{accountId};
	    	for(Integer i=0;i<maxIterationCount;i++){
	    		List<Account> childAccounts = [SELECT Id,Name,Type,parentId,parent.Name
		    									FROM Account
		    									WHERE parentId in :parentIds
		    										AND (NOT Type like 'Branch%')];
		    	parentIds.clear();
		    	for(Account acc : childAccounts){
		    		accountHierarchy.add(acc);
		    		parentIds.add(acc.Id);
		    	} 				
		    	
		    	if(parentIds.size() == 0)
		    		break;			
	    	}
	    	
	    	return accountHierarchy;
		}
		
		/**
			@Description: This method populates the options from the picklist values 
		*/
		private List<Option> populateOptionsFromPickList(String fieldName){
			List<Option> options = new List<option>();
		 	Schema.DescribeFieldResult fieldResult = Schema.SObjectType.Opportunity_line_Item__c.fields.getMap().get(fieldName).getDescribe();
		  	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

		   	for( Schema.PicklistEntry f : ple){
		      options.add(new Option(f.getLabel(), f.getValue()));
		   	}
		   	
		   	return populateOptionsFromPickListByObject('Opportunity_line_Item__c',fieldName );
		}

		/**
			@Description: This method populates the options from the picklist for a specific picklist value in an Object
			@Parammeters: ObjectName is an string with the name of the object where is the picklist field
						: FieldName: field name of the picklist.
		*/
		private  List<Option> populateOptionsFromPickListByObject(String ObjectName, String fieldName){
			List<Option> options = new List<option>();


			Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new list<string> {ObjectName} );


			if(results.size()>0){
				Schema.DescribeFieldResult fieldResult = results[0].fields.getMap().get(fieldName).getDescribe();
				List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

				for( Schema.PicklistEntry f : ple){
					options.add(new Option(f.getLabel(), f.getValue()));
				}
			}
			return options;
		}

        /**
            @Description:  Populates the tariff wrapper and the associated members from the opprotunity
                            line items
         */
        private void populateTarifWrapperFromItems(){
            List<Opportunity_Line_Item__c> lineItems = new List<Opportunity_Line_Item__c>();
            lineItems = [SELECT Ad_Sales_Type__c,Booking_Api_Id__c,Category_Id__c,Category__c,City_ZipCode__c,Commission_In_Percentage__c,Commission_Per_Order__c,
                                Commission_Type__c,Deposit_Method__c,Deposit__c,Design_Note__c,Discount__c,District_Id__c,District__c,End_Date__c,Has_Related_Tarif__c,
                                Id,Id_List_Price_Product__c,Id_List_Service_Price__c,Id_Opportunity__c,Id_Replacement_Order__c,index__c,Installments__c,IsTiered__c,
                                Line_Item_Type__c,Listed_Price__c,Max__c,Min__c,Name,Number_of_Copies__c,OldOppQuoteLineId__c,Online_Payment_Fee__c,Position_fm__c,
                                Position__c,Product_Group__c,Quantity__c,RecordTypeId,Recurring_Fee__c,Size__c,Start_Date__c,Subsidy__c,Sub_type__c,Total_Amount__c,
                                Weight__c,Id_List_Add_on__c,ContractAddition__c,delivery__c,Source_GRID__c,Billable_Account__c,Specifications__c,Scaled__c,Id_list_price_product__r.company__r.name,
					Id_List_Price_Product__r.requires_asset__c,Id_List_Price_Product__r.requires_branding__c,
								(SELECT Min__c,Max__c,Commission_In_percentage__c,Commission_Per_Order__c, Sequence__c
                                    FROM Tiers__r
                                    ORDER BY min__c) 
                        FROM Opportunity_Line_Item__c
                        WHERE Id_Opportunity__c =: opp.Id
                        ORDER By Id_list_price_product__r.company__r.name];
   
            Tarif tar = new Tarif(opp.Id_tarif__c, opp.RecordTypeId);
			
			// For premium placement make a callout and fetch the available bookings
            //SSC-1932: Changes
            Business_Config__c atPPTarifRule = LibBusinessConfig.getBusinessConfigFromRuleMap(Constants.BUSINESSCONFIG_PROCESSNAME_ADDOPPORTUNITYLINEITEMS, opp.RecordTypeId, Constants.BUSINESSCONIFG_RULENAME_ENABLESFPREMIUMPLACEMENTUI);

            if(String.isNotBlank(tar.name) && tar.name.equals(Constants.TARIF_NAME_PREMIUM_PLACEMENT) && (atPPTarifRule==null || !Boolean.valueof(atPPTarifRule.Business_Rule_Value__c))){
                Date today = Date.today();
				tar.fetchBookingsFromLineItems(lineItems);
				// fetch the available bookings from MIDAS only if the opportunity is not locked
				if(!isOpportunityLocked){
					tar.fetchAvailableBookings(opp,opportunityCountry,today.month() + '-' + today.year());
				}
			}else{
				tar.fetchCommissionsFromLineItems(lineItems);
	            tar.fetchProductsFromLineItems(lineItems);
				tar.fetchAddOnsFromLineItems(lineItems);
			}		
			 
            tarif = tar;
            LoggingUtility.commitLogs();
        }

        /**
            @Description:  Method to gets account hierarchy upwards. Parent Accounts 
         */
        public List<Account> parentFlow(Account account, Boolean isFirstRun, Boolean isFranchiseFlow){
            List<Account> accountHierarchy  = new List<Account>();
            String franchisePreIndex = '';
            if(!isFranchiseFlow){
                franchisePreIndex = '';
            }else{
                 franchisePreIndex = Label.FranchisePreIndex + ' ';
            }

            if(isFirstRun){
                // if the opportunity is chain opportunity add the current account into the hierarchy
                if(account.Type != null && !account.Type.contains('Branch') && this.opp.recordType.developerName == 'Chain_Opportunity'){
                    accountHierarchy.add(new Account(id=account.Id,type=account.type,name=account.name));
                }
            }
            
            if(account.parentId == null)
                return accountHierarchy;
            accountHierarchy.add(new Account(id=account.parentId,type=account.parent.type,name= franchisePreIndex + account.parent.name));
            
            if(account.parent.parentId == null)
                return accountHierarchy;
            accountHierarchy.add(new Account(id=account.parent.parentId,type=account.parent.parent.type,
                                            name= franchisePreIndex + account.parent.parent.name));
            
            if(account.parent.parent.parentId == null)
                return accountHierarchy;
            accountHierarchy.add(new Account(id=account.parent.parent.parentId,type=account.parent.parent.parent.type,
                                            name=franchisePreIndex + account.parent.parent.parent.name));
            
            if(account.parent.parent.parent.parentId == null)
                return accountHierarchy;
            accountHierarchy.add(new Account(id=account.parent.parent.parent.parentId,
                                            type=account.parent.parent.parent.parent.type,
                                            name= franchisePreIndex + account.parent.parent.parent.parent.name));
            
            if(account.parent.parent.parent.parent.parentId == null)
                return accountHierarchy;
            accountHierarchy.add(new Account(id=account.parent.parent.parent.parent.parentId,
                                            type=account.parent.parent.parent.parent.parent.type,
                                            name= franchisePreIndex + account.parent.parent.parent.parent.parent.name));
            
            
            accountHierarchy.addAll(getAccountHierarchyUpwardsNextRuns(account.parent.parent.parent.parent.parentId, isFranchiseFlow));
            
            return accountHierarchy; 
        }

        /**
            @Description:  Method to gets account hierarchy upwards. Connection through Frnachise 
         */
        public List<Account> franchiseFlow(Account account){
            List<Account> accountHierarchy  = new List<Account>();
            String franchisePreIndex = Label.FranchisePreIndex + ' ';
            
            if(this.opp.recordType.developerName == 'Chain_Opportunity'){
                return accountHierarchy;
            }

            if(account.Franchise_connection__c == null)
                return accountHierarchy;
            accountHierarchy.add(new Account(id=account.Franchise_connection__c,
                                type=account.Franchise_connection__r.Type,
                                name= franchisePreIndex + account.Franchise_connection__r.Name));
            
            if(account.Franchise_connection__r.parentId == null)
                return accountHierarchy;
            accountHierarchy.add(new Account(id=account.Franchise_connection__r.ParentId,
                                            type=account.Franchise_connection__r.parent.Type,
                                            name= franchisePreIndex + account.Franchise_connection__r.parent.Name));
            
            if(account.Franchise_connection__r.parent.parentId == null)
                return accountHierarchy;
            accountHierarchy.add(new Account(id=account.Franchise_connection__r.parent.ParentId,
                                            type=account.Franchise_connection__r.parent.parent.Type,
                                            name= franchisePreIndex + account.Franchise_connection__r.parent.parent.Name));
            
            if(account.Franchise_connection__r.parent.parent.parentId == null)
                return accountHierarchy;
            accountHierarchy.add(new Account(id=account.Franchise_connection__r.parent.parent.ParentId,
                                            type=account.Franchise_connection__r.parent.parent.parent.Type,
                                            name= franchisePreIndex + account.Franchise_connection__r.parent.parent.parent.Name));
            
            if(account.Franchise_connection__r.parent.parent.parent.parentId == null)
                return accountHierarchy;
            accountHierarchy.add(new Account(id=account.Franchise_connection__r.parent.parent.parent.ParentId,
                                            type=account.Franchise_connection__r.parent.parent.parent.parent.Type,
                                            name= franchisePreIndex + account.Franchise_connection__r.parent.parent.parent.parent.Name));
            
            
            accountHierarchy.addAll(getAccountHierarchyUpwardsNextRuns(account.Franchise_connection__r.parent.parent.parent.ParentId, true));
            
            return accountHierarchy; 
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
