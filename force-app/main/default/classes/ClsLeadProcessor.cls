global with sharing class ClsLeadProcessor {
    public static Map<String, Business_Config__c>  mapBusinessData;
    public static Lead leadTobeConverted;
    public static Account tempAccount = new Account();
    public static List<String> listFieldsToDisplay;
    public static List<String> listFieldsToQuery;
    public static List<String> listFieldsLeadInformation;
    public static List<String> listFieldsAccountInformation;
    public static List<String> listFieldsContactInformation;
    public static List<String> mandatoryFields;
    public static String skipConversionPage;
    public static Boolean skipConversion;
    public static List<String> listFieldsNonContracted;
    public static Boolean nonContracted;
    public static String territoryOppOwner;
    public static String territoryAccOwner;
    public static String companyCode;
    public static String leadId;
    public static String accountId;
    private static List<String> defaultStageProbability;
    private static List<String> leadToQuoteStage;
    private static String oppBusinessType;
    public static Id updateQuoteId;

    public static List<String> results = new List<String>();
    private static Boolean enabledTerritory;
    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    
    /**
     * Called before insert and before update, validates the Delivery Service on Lead 
     * @param Leads
     */
    public static void validateLeadDeliveryService(List<Lead> leads, Map<Id, Lead> oldLeads){

        ClsSObjectUtils.validateLeadDeliveryService(leads);
    }

    webService static List<String> processLeadConversion(String idOfLead, String companyCodeLead, Boolean future) {

        skipConversion = true;
        leadId = idOfLead;
        companyCode = companyCodeLead;
        //mapBusinessData = LibBusinessConfig.getGenericProcessData('Lead Conversion').get(companyCode + '_Lead');
        mapBusinessData = moam.get('Lead Conversion').get(companyCode + '_Lead');
        enabledTerritory = false;


        Boolean isBusinessConfigDataCorrect = checkIfBusinessConfigsAreAvailable();
        if (!isBusinessConfigDataCorrect) {
            results.add('error');
            results.add(Label.Lead_Conversion_Check_Business_Config_Rules);
        } else {

            system.debug('@@@@ calling processLeadConversion : ' + listFieldsToQuery);
            leadTobeConverted = queryLead(listFieldsToQuery);
            tempAccount.Name = leadTobeConverted.Company;
        }

        if (results.size() == 0 || (results.size() > 0 && !results[0].equals('error'))) {
            if (!skipConversion || skipConversionPage.equals('false')) {
                results.add('success');
                results.add('showConversionPage');
            } else {
                convertLead(future);
            }
        }

        return results;
    }

    webService static Boolean checkIfBusinessConfigsAreAvailable() {
        if (mapBusinessData != null && !mapBusinessData.isEmpty()) {

            List<String> listOfFields = new List<String>();
            listOfFields = mapBusinessData.get('FieldsToQuery') != null ? mapBusinessData.get('FieldsToQuery').Business_Rule_Value__c.split(',') : new List<String>();
            listFieldsLeadInformation = mapBusinessData.get('LeadInformationFieldsToDisplay') != null ? mapBusinessData.get('LeadInformationFieldsToDisplay').Business_Rule_Value__c.split(',') : new List<String>();
            listFieldsAccountInformation = mapBusinessData.get('AccountInformationFieldsToDisplay') != null ? mapBusinessData.get('AccountInformationFieldsToDisplay').Business_Rule_Value__c.split(',') : new List<String>();
            listFieldsContactInformation = mapBusinessData.get('ContactInformationFieldsToDisplay') != null ? mapBusinessData.get('ContactInformationFieldsToDisplay').Business_Rule_Value__c.split(',') : new List<String>();
            mandatoryFields = mapBusinessData.get('MandatoryFields') != null ? mapBusinessData.get('MandatoryFields').Business_Rule_Value__c.split(',') : new List<String>();
            skipConversionPage = mapBusinessData.get('SkipConversionPage') != null ? mapBusinessData.get('SkipConversionPage').Business_Rule_Value__c : '';
            nonContracted = mapBusinessData.get('nonContractedFlag') != null ? Boolean.valueOf(mapBusinessData.get('nonContractedFlag').Business_Rule_Value__c) : null;
            listFieldsNonContracted = mapBusinessData.get('MandatoryFieldsNonContracted') != null ? mapBusinessData.get('MandatoryFieldsNonContracted').Business_Rule_Value__c.split(',') : new List<String>();
            defaultStageProbability = mapBusinessData.get('DefaultStageProbability') != null ? mapBusinessData.get('DefaultStageProbability').Business_Rule_Value__c.split(',') : new List<String>();
            enabledTerritory = mapBusinessData.get('EnableTerritory') != null ? Boolean.valueOf(mapBusinessData.get('EnableTerritory').Business_Rule_Value__c) : false;
            oppBusinessType = mapBusinessData.get('OppBusinessType') != null ? mapBusinessData.get('OppBusinessType').Business_Rule_Value__c : null;
            leadToQuoteStage = mapBusinessData.get('LeadToQuoteOppStage') != null ? mapBusinessData.get('LeadToQuoteOppStage').Business_Rule_Value__c.split(',') : new List<String>();
            Set<String> allFieldsToQuerySet = new Set<String>();
            allFieldsToQuerySet.addAll(convertToLowerCase(listOfFields));
            allFieldsToQuerySet.addAll(convertToLowerCase(listFieldsLeadInformation));
            allFieldsToQuerySet.addAll(convertToLowerCase(listFieldsAccountInformation));
            allFieldsToQuerySet.addAll(convertToLowerCase(listFieldsContactInformation));
            allFieldsToQuerySet.addAll(convertToLowerCase(mandatoryFields));
            allFieldsToQuerySet.addAll(convertToLowerCase(listFieldsNonContracted));
            allFieldsToQuerySet.add('record_country__c');

            listFieldsToQuery = new List<String>();
            listFieldsToQuery.addAll(allFieldsToQuerySet);
            for (String str : listFieldsToQuery) {
                system.debug('@@@@ calling checkIfBusinessConfigsAreAvailable - str : ' + str);
            }


            if (listFieldsToQuery == null || listFieldsToQuery.isEmpty() || listFieldsLeadInformation == null || listFieldsLeadInformation.isEmpty() ||  listFieldsAccountInformation == null || listFieldsAccountInformation.isEmpty()
                    || listFieldsContactInformation == null || listFieldsContactInformation.isEmpty() || mandatoryFields == null || mandatoryFields.isEmpty() || skipConversionPage == null || skipConversionPage.length() == 0) {
                return false;
            } else {
                return true;
            }
        }
        return false;
    }

    webService static List<String> convertToLowerCase(List<String> fields) {
        List<String> lowerCaseFields = new List<String>();
        for (String str : fields) {
            lowerCaseFields.add(str.toLowerCase());
        }
        return lowerCaseFields;
    }

    webService static Lead queryLead(List<String> listOfFields) {
        String query = 'SELECT Non_Contracted__c,Commission__c,Order_date__c,Tariff_Name__c,' + String.join(listOfFields, ',') + ' FROM Lead WHERE Id =:leadId';
        Sobject obj = Database.query(query);

        areAllRequiredFieldsFilled(obj);
        if (obj.get('Non_Contracted__c') != null && ((Boolean)obj.get('Non_Contracted__c'))) {
            checkForNonContractedMandatoryFields(obj);
        }
        return (Lead)obj;

    }


    webService static void areAllRequiredFieldsFilled(Sobject obj) {
        for (String str : mandatoryFields) {
            if (obj.get(str) == null || (String.valueOf(obj.get(str))).length() == 0) {
                skipConversion = false;
                break;
            }
        }
    }

    static void checkForNonContractedMandatoryFields(Sobject obj) {
        if (nonContracted != null && nonContracted) {
            for (String str : listFieldsNonContracted) {
                if (obj.get(str) == null || (String.valueOf(obj.get(str))).length() == 0) {
                    skipConversion = false;
                    break;
                }
            }
        }
    }

    webService static String convertLead(Boolean future) {
        Lead existingLead = [SELECT Status FROM Lead Where Id = :leadId];
        if (existingLead.Status == 'Converted') {
            results.add('error');
            results.add('Lead already converted');
            return 'error';
        }

        if (string.IsBlank(tempAccount.Name)) {
            results.add('error');
            results.add(Label.Lead_Conversion_Company_Name_Mandatory);
            return 'error';
        }

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadId);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr;
        try {
            lcr = Database.convertLead(lc);
        } catch (Exception e) {
            results.add('error');
            results.add(Label.Lead_Conversion_Error);
            return 'error';
        }

        Id newContactId = lcr.getContactId();
        Id newAccountId = lcr.getAccountId();
        Id newOpportunityId = lcr.getOpportunityId();

        String success;
        String success_updateContact;
        String success_updateAccount = updateNewAccount(newAccountId);
        if (newContactId != null) {
            success_updateContact = updateContacts(newContactId, newAccountId);
        }


        success = success_updateAccount;

        if (newOpportunityId != null) {
            //Opportunity updateOpp = [SELECT Id, CurrencyIsoCode, Recordtypeid,ownerId, Country__c,StageName,Probability,Record_Country__c FROM Opportunity WHERE Id=:newOpportunityId];
            Opportunity updateOpp = new Opportunity(Id = newOpportunityId);
            //updateOpp.Recordtypeid = LibRecordTypeHelper.getRecordType(companyCode + '_Opportunity', 'Opportunity').Id;
            updateOpp.Recordtypeid = LibRecordTypeHelper.getRecordTypeValue(companyCode + '_Opportunity');
            Map<String, String> oppStageAndProbability = new Map<String, String>();
            //Added the default stage and probability for lead convertion on 24.04.15 by magesh
            if (!defaultStageProbability.isEmpty()) {
                for (String str : defaultStageProbability) {
                    List<String> fields = str.split('=');
                    oppStageAndProbability.put(fields[0], fields[1]);
                }
                if (oppStageAndProbability.get('StageName') != null) {
                    updateOpp.StageName = oppStageAndProbability.get('StageName');
                    if (oppStageAndProbability.get('Probability') != null) {
                        updateOpp.Probability = Decimal.valueOf(oppStageAndProbability.get('Probability'));
                    }
                }
            }
            try {
                if (territoryOppOwner != null) {
                    updateOpp.ownerId = territoryOppOwner;
                } else {
                    updateOpp.ownerId = UserInfo.getUserId();
                }
                if (oppBusinessType != null) {
                    updateOpp.Business_Type__c = oppBusinessType;
                    updateOpp.Name = oppBusinessType;
                }

                oppStageAndProbability.clear();

                if (leadTobeConverted.Commission__c != null && leadTobeConverted.Order_date__c != null && leadTobeConverted.Tariff_Name__c != null) {
                    if (!leadToQuoteStage.isEmpty()) {
                        for (String str : leadToQuoteStage) {
                            List<String> fields = str.split('=');
                            oppStageAndProbability.put(fields[0], fields[1]);
                        }
                        if (oppStageAndProbability.get('StageName') != null) {
                            updateOpp.StageName = oppStageAndProbability.get('StageName');
                            if (oppStageAndProbability.get('Probability') != null) {
                                updateOpp.Probability = Decimal.valueOf(oppStageAndProbability.get('Probability'));
                            }
                        }
                    }
                }
                if (future == false) {
                    updateOpp.Opp_Origin__c = 'Fieldsales';
                    Tarif__c tarif = [select id from Tarif__c where name = :leadTobeConverted.Tariff_Name__c];
                    updateOpp.id_tarif__c = tarif.id;
                }
                update updateOpp;
                if (leadTobeConverted.Commission__c != null && leadTobeConverted.Order_date__c != null && leadTobeConverted.Tariff_Name__c != null) {
                    if (future == true)
                        futureLeadToQuoteProcess(updateOpp.Id);
                    updateQuoteId = updateOpp.Id;
                }
            } catch (Exception e) {
                results.add('error');
                results.add(Label.Lead_Conversion_Error);
                return 'error';
            }
        }



        if (success.equals('success')) {
            accountId = newAccountId;
            results.add('success');
            results.add(accountId);
            if (success_updateContact.equals('success')) {
                return 'success';
            }
            return 'error';
        }


        return 'error';

    }

    webService static String createOppQuote() {
        if (updateQuoteId != null)
            return leadToQuoteProcess(updateQuoteId);
        return null;
    }

    /*webservice static String updateContacts(String acctId){
        if(enabledTerritory){
            List<Contact> listContacts = new List<Contact>();
            String recordtypeName = companyCode + '_Account';
            String typeOfterritory = mapBusinessData.get('TerritoryType') != null ? mapBusinessData.get('TerritoryType').Business_Rule_Value__c : null;
            List<Territory__c> listTerretories = [select id,Account_owner__c,Account_Record_Type__c,Company__c,Country__c,Field_to_compare__c,Opportunity_owner__c,Type__c,Values__c,Territory__c from Territory__c where Account_Record_Type__c=:recordtypeName and Type__c =: typeOfterritory];

            if(!listTerretories.isEmpty()){
                listContacts = [SELECT Id, OwnerId FROM Contact WHERE AccountId =: accountId];

                for(Contact theContact : listContacts){
                    theContact.OwnerId = listTerretories[0].Account_owner__c;
                }
            }
            try{
                update listContacts;
            }catch(Exception e){

                results.add('error');
                results.add(Label.Lead_Conversion_Error);
                return 'error';

            }

        }

        return 'success';
    }*/

    webservice static String updateContacts(String contId, String acctId) {
        //Id contactRecordTypeId = LibRecordTypeHelper.getRecordType(companyCode + '_Contact', 'Contact').Id;
        Id contactRecordTypeId = LibRecordTypeHelper.getRecordTypeValue(companyCode + '_Contact');
        String LeadToContactMap = mapBusinessData.get('LeadToContactMap') != null ? mapBusinessData.get('LeadToContactMap').Business_Rule_Value__c : '';
        system.debug(LeadToContactMap);
        Contact newContact = new Contact(id = contId, Contact_Role__c = 'Owner', RecordTypeId = contactRecordTypeId);
        Lead convertedLead = queryLead(listFieldsToQuery);

        if (LeadToContactMap != null && LeadToContactMap != '') {

            List<String> keyPair = LeadToContactMap.split('=');
            newContact.put(keyPair[0], convertedLead.get(keyPair[1]));

        }
        if (territoryAccOwner != null) {
            newContact.OwnerId = territoryAccOwner;
        }
        try {
            update newContact;
            return 'success';
        } catch (Exception e) {
            results.add('error');
            results.add(Label.Lead_Conversion_Error_When_Updating_New_Contact);
            return 'error';
        }
    }

    webService static String updateNewAccount(String acctId) {
        //String leadFieldsToQueryAfterConversion = mapBusinessData.get('LeadFieldsToQueryAfterConversion') != null ? mapBusinessData.get('LeadFieldsToQueryAfterConversion').Business_Rule_Value__c : '';
        List<String> leadToAccountMap = mapBusinessData.get('LeadToAccountMap') != null ? mapBusinessData.get('LeadToAccountMap').Business_Rule_Value__c.split(',') : new List<String>();
        List<String> leadToAccountNonContractedMap = mapBusinessData.get('LeadToAccountNonContractedMap') != null ? mapBusinessData.get('LeadToAccountNonContractedMap').Business_Rule_Value__c.split(',') : new List<String>();
        //Account newlyCreatedAccount = [SELECT Id,Non_Contracted__c, RecordTypeId, RecordType.DeveloperName FROM Account WHERE Id =: acctId LIMIT 1];
        String queryAcc = 'SELECT Id,Non_Contracted__c, RecordTypeId, RecordType.DeveloperName,Record_Country__c';
        if (mapBusinessData.get('TerritoryFieldToCompare') != null && mapBusinessData.get('TerritoryFieldToCompare').Business_Rule_Value__c != null) {
            queryAcc = queryAcc + ',' + mapBusinessData.get('TerritoryFieldToCompare').Business_Rule_Value__c;
        }
        queryAcc = queryAcc + ' FROM Account WHERE Id =: acctId LIMIT 1';
        Account newlyCreatedAccount = (Account) Database.query(queryAcc);

        Lead convertedLead = queryLead(listFieldsToQuery);

        if (newlyCreatedAccount != null) {
            newlyCreatedAccount.Name = tempAccount.Name;
            //newlyCreatedAccount.Recordtypeid = LibRecordTypeHelper.getRecordType(companyCode + '_Account', 'Account').Id;
            newlyCreatedAccount.Recordtypeid = LibRecordTypeHelper.getRecordTypeValue(companyCode + '_Account');
            for (String str : leadToAccountMap) {
                List<String> keyPair = str.split('=');
                newlyCreatedAccount.put(keyPair[0], convertedLead.get(keyPair[1]));
            }
            if (newlyCreatedAccount.Non_Contracted__c && nonContracted != null && nonContracted && leadToAccountNonContractedMap != null && !leadToAccountNonContractedMap.isEmpty()) {
                for (String str : leadToAccountNonContractedMap) {
                    List<String> keyPair = str.split('=');
                    System.debug('keyPair[0]: ' + keyPair[0]);
                    newlyCreatedAccount.put(keyPair[0], convertedLead.get(keyPair[1]));
                }
            }

            String recordtypeName = companyCode + '_Account';
            if (enabledTerritory) {
                String typeOfterritory = mapBusinessData.get('TerritoryType') != null ? mapBusinessData.get('TerritoryType').Business_Rule_Value__c : null;
                String fieldToCompare = mapBusinessData.get('TerritoryFieldToCompare').Business_Rule_Value__c;

                if (newlyCreatedAccount.get(fieldToCompare) != null) {
                    for (Territory__c tr : [select id, Account_owner__c, Account_Record_Type__c, Company__c, Country__c, Field_to_compare__c, Opportunity_owner__c, Type__c, Values__c, Territory__c from Territory__c where Account_Record_Type__c = :recordtypeName and Type__c = : typeOfterritory]) {
                        if (tr.type__c == 'Range') {
                            // System.debug('@@Inside If Condition for Range');
                            Integer filedValue = Integer.valueOf(newlyCreatedAccount.get(fieldToCompare));
                            // System.debug('@@Integer.valueOf(newlyCreatedAccount.get(fieldToCompare)): '+Integer.valueOf(newlyCreatedAccount.get(fieldToCompare)));
                            List<String> postCodes = tr.Values__c.split('-');
                            // System.debug('@@Integer.valueOf(postCodes[0]): '+Integer.valueOf(postCodes[0]));
                            // System.debug('@@Integer.valueOf(postCodes[1]): '+Integer.valueOf(postCodes[1]));
                            if (filedValue >= Integer.valueOf(postCodes[0]) && filedValue <= Integer.valueOf(postCodes[1])) {
                                newlyCreatedAccount.put('ownerId', tr.Account_owner__c);
                                //  System.debug('@@Account Owner: '+tr.Account_owner__c);
                                newlyCreatedAccount.put('Territory__c', tr.Territory__c);
                                //  System.debug('@@Territory: '+tr.Territory__c);
                                territoryOppOwner = tr.Opportunity_owner__c;
                                territoryAccOwner = tr.Account_owner__c;
                                break;
                            }
                        } else if (tr.type__c == 'Comma separated') {
                            Set<String> PostCodeValues = new Set<String>(tr.Values__c.split(','));
                            if (PostCodeValues.contains(String.valueOf(newlyCreatedAccount.get(fieldToCompare)))) {
                                newlyCreatedAccount.put('ownerId', tr.Account_owner__c);
                                newlyCreatedAccount.put('Territory__c', tr.Territory__c);
                                territoryOppOwner = tr.Opportunity_owner__c;
                                territoryAccOwner = tr.Account_owner__c;
                                break;
                            }
                        }
                    }
                }
            }

            try {
                update newlyCreatedAccount;
            } catch (Exception e) {
                results.add('error');
                results.add(Label.Lead_Conversion_Error);
                return 'error';
            }
        }
        return 'success';
    }

    public static void assignRecordCountryToBillingCountry(List<Lead> newList, Map<Id, Lead> oldMap) {
        for (Lead ld : newList) {
            if (ld.Record_Country__c != null && (oldMap == null || (oldMap.get(ld.id) != null && ld.Record_Country__c != oldMap.get(ld.id).Record_Country__c))) {
                if (ld.Record_Country__c != 'Korea') {
                    ld.country = ld.Record_Country__c;
                }
                System.debug('ld.country: ' + ld.country);
            }
        }
    }

    public static void PhoneToMobileForAUContactPage(List<Lead> newList) {
        //Id leadAURecordtypeId = LibRecordTypeHelper.getRecordType('DH_AU_Lead','Lead').Id;
        Id leadAURecordtypeId = LibRecordTypeHelper.getRecordTypeValue('DH_AU_Lead');
        if (GlobalAPIProfile__c.getValues('ProfileId') != null && GlobalAPIProfile__c.getValues('ProfileId').value__c != null) {
            Id userProfileId = ID.valueOf(GlobalAPIProfile__c.getValues('ProfileId').Value__c);
            if (Id.valueOf(UserInfo.getProfileId()) == userProfileId) {
                for (Lead ld : newList) {
                    if (!String.isBlank(ld.Phone) && ld.Phone.indexOf('614') == 0 && leadAURecordtypeId == ld.RecordTypeId) {
                        ld.MobilePhone =  ld.Phone;
                        ld.Phone = null;
                    }
                }
            }
        }
    }

    @future
    public static void futureLeadToQuoteProcess(Id oppId) {
        leadToQuoteProcess(oppId);
    }


    //@future
    public static String leadToQuoteProcess(Id oppId) {
        Opportunity opp = [select id, RecordType.DeveloperName, Opp_Origin__c, CurrencyIsoCode, Company_Code__c, AccountId, StageName, Probability, Non_Standard_Contract_Components__c from Opportunity where id = :oppId];
        Lead convertedLead = [SELECT id, Order_date__c, Commission__c, Setup_Fee__c, Non_Standard_Contract_Components__c, installments__c, Non_Standard_Contract_Terms__c, Tariff_Name__c FROM Lead where ConvertedOpportunityId = :opp.Id];

        Boolean createOppQuote = false;

        if (convertedLead != null && convertedLead.Commission__c != null && convertedLead.Order_date__c != null && convertedLead.Tariff_Name__c != null) {
            System.debug('opp.Company_Code__c: ' + opp.Company_Code__c);
            String oppLineItemRecordtypeId = LibRecordTypeHelper.getRecordTypeValue(opp.Company_Code__c + '_Opportunity_Line_Item');
            String oppQuoteLineItemRecordtypeId = LibRecordTypeHelper.getRecordTypeValue(opp.Company_Code__c + '_Opportunity_Quote_Line_Item');
            List<Opportunity_Line_Item__c> oppLines = new List<Opportunity_Line_Item__c>();
            List<Opportunity_Quote_Line_Item__c> oppQLines = new List<Opportunity_Quote_Line_Item__c>();

            Opportunity_Quote__c oppQuote = new Opportunity_Quote__c(Id_Opportunity__c = opp.id, CurrencyIsoCode = opp.CurrencyIsoCode, status__c = 'Approved', Id_Account__c = opp.AccountId, recordtypeId = LibRecordTypeHelper.getRecordTypeValue(opp.Company_Code__c + '_Opportunity_Quote'));
            if (convertedLead.Non_Standard_Contract_Components__c != null) {
                opp.Non_Standard_Contract_Components__c = convertedLead.Non_Standard_Contract_Components__c;
                oppQuote.Non_Standard_Contract_Components__c = convertedLead.Non_Standard_Contract_Components__c;
                oppQuote.Non_Standard_Contract_terms__c = convertedLead.Non_Standard_Contract_Terms__c;
            }
            //LeadToQuoteProcess__c leadToQuoteSetting = LeadToQuoteProcess__c.getValues(opp.RecordType.DeveloperName);
            String tarifName = convertedLead.Tariff_Name__c;
            String tarifID;
            if (tarifName != null) {
                List<String> serviceIds = new List<String>();
                List<String> productIds = new List<String>();
                for (Tarif_Member__c tm : [select Id_Tarif_Item__c, Tarif_Name__c, Type__c from Tarif_Member__c where Tarif_Name__r.name = :tarifName]) {
                    tarifID = tm.Tarif_Name__c;
                    if (tm.Type__c == 'Service') {
                        serviceIds.add(tm.Id_Tarif_Item__c);
                    } else {
                        productIds.add(tm.Id_Tarif_Item__c);
                    }
                    opp.ID_tarif__c = tarifID;
                }
                Set<String> productNamesRegional = new set<String>();
                if (tarifName.contains('Regional')) {
                    if (convertedLead.Non_Standard_Contract_Components__c != null && convertedLead.Non_Standard_Contract_Components__c != '' && convertedLead.Non_Standard_Contract_Components__c.contains('Exclusive Special Offer')) {
                        productNamesRegional.add('Exclusive Special Offer');

                    } else
                        productNamesRegional.add('Taste Test');

                    if (convertedLead.Non_Standard_Contract_Components__c != null && convertedLead.Non_Standard_Contract_Components__c != '' && convertedLead.Non_Standard_Contract_Components__c.contains('BladeT&C')) {
                        productNamesRegional.add('Blade Sign');

                    }


                }
                List<List_Service_Price__c> listService = [Select Id, Name, Commission_In_Percentage__c, Commission_Per_Order__c, Commission_Type__c, Type__c, Service_Type__c, Maximum_Commission_In_Percentage__c, Minimum_Commission_in_Percentage__c, Recurring_Fee__c from List_Service_Price__c where id in :serviceIds];
                List<List_Product_Price__c> listProduct = [Select id, Product_Name__c, Id_List_Product_Group__r.Name, Product_Type__c, Installments__c, List_Price__c, Id_List_Product_Group__c, Requires_Additional_Charge__c, Requires_Add_On__c, Requires_Asset__c, Requires_Branding__c from List_Product_Price__c where id in :productIds or ( Product_Name__c in :productNamesRegional )];
                for (List_Service_Price__c listS : listService) {
                    Decimal commission = listS.Commission_In_Percentage__c;

                    if (listS.Service_Type__c == 'Commission Fee') {
                        if (listS.Commission_In_Percentage__c == convertedLead.Commission__c) {
                            createOppQuote = true;
                        } else if (listS.Minimum_Commission_in_Percentage__c != null && listS.Minimum_Commission_in_Percentage__c <= convertedLead.Commission__c) {
                            createOppQuote = true;
                        } else if (listS.Minimum_Commission_in_Percentage__c == null) {
                            createOppQuote = true;
                        }
                        commission = convertedLead.Commission__c;
                    }
                    oppLines.add(new Opportunity_Line_Item__c(Id_List_Service_Price__c = listS.id, name = listS.name, Commission_In_Percentage__c = commission,
                                 Commission_Per_Order__c = listS.Commission_Per_Order__c, Id_Opportunity__c = opp.id, start_date__c = convertedLead.Order_date__c,
                                 Has_Related_Tarif__c = true, Line_Item_Type__c = 'Service', recordtypeid = oppLineItemRecordtypeId, CurrencyIsoCode = opp.CurrencyIsoCode,
                                 Recurring_Fee__c = listS.Recurring_Fee__c, Sub_Type__c = listS.Service_Type__c));
                    oppQLines.add(new Opportunity_Quote_Line_Item__c(Id_List_Service_Price__c = listS.id, name = listS.name, Commission_In_Percentage__c = commission,
                                  Commission_Per_Order__c = listS.Commission_Per_Order__c, Has_Related_Tarif__c = true, Start_Date__c = convertedLead.Order_date__c, Line_Item_Type__c = 'Service',
                                  recordtypeId = oppQuoteLineItemRecordtypeId, Id_Opportunity__c = opp.id, CurrencyIsoCode = opp.CurrencyIsoCode, Recurring_Fee__c = listS.Recurring_Fee__c, Sub_Type__c = listS.Service_Type__c));
                }

                for (List_Product_Price__c listP : listProduct) {
                    String discount = '0';
                    integer installments;
                    Decimal totalAmt = listP.List_Price__c;
                    if (listP.Product_Type__c == 'Setup Fee') {
                        if (convertedLead.Setup_Fee__c != null && listP.List_Price__c > convertedLead.Setup_Fee__c) {
                            discount = '' + (listP.List_Price__c - convertedLead.Setup_Fee__c);

                        }
                        installments = Integer.valueof(convertedLead.installments__c);
                        totalAmt = convertedLead.Setup_Fee__c;
                    } else
                        installments = Integer.valueof(listP.Installments__c);

                    oppLines.add(new Opportunity_Line_Item__c(Id_List_Price_Product__c = listP.id, name = listP.Product_Name__c, Listed_Price__c = listP.List_Price__c, Quantity__c = 1,
                                 Total_Amount__c = totalAmt, Discount__c = discount, Product_Group__c = listP.Id_List_Product_Group__r.Name, Line_Item_Type__c = 'Product',
                                 Installments__c = installments, Id_Opportunity__c = opp.id, Has_Related_Tarif__c = true, sub_type__c = listP.Product_Type__c,
                                 recordtypeid = oppLineItemRecordtypeId, CurrencyIsoCode = opp.CurrencyIsoCode));

                    oppQLines.add(new Opportunity_Quote_Line_Item__c(name = listP.Product_Name__c, Id_List_Product_Price__c = listP.id, Listed_Price__c = listP.List_Price__c, Quantity__c = 1,
                                  Total_Amount__c = totalAmt, Discount__c = discount, Id_Opportunity__c = opp.id, Product_Group__c = listP.Id_List_Product_Group__r.Name,
                                  Installments__c = installments, Has_Related_Tarif__c = true, recordtypeId = oppQuoteLineItemRecordtypeId,
                                  CurrencyIsoCode = opp.CurrencyIsoCode, Line_Item_Type__c = 'Product', sub_type__c = listP.Product_Type__c));


                }
                //if(leadToQuoteSetting.StageName__c!=null && leadToQuoteSetting.Probability__c!=null){
                //    opp.StageName = leadToQuoteSetting.StageName__c;
                //    opp.Probability = leadToQuoteSetting.Probability__c;
                //}
                //opp.Opp_Origin__c = 'Fieldsales'; moved to convertlead
                insert oppLines;
                //update opp;
                if (createOppQuote) {
                    insert oppQuote;

                    for (Opportunity_Quote_Line_Item__c opql : oppQLines) {
                        opql.Id_Opportunity_Quote__c = oppQuote.Id;
                    }
                    insert oppQLines;
                    return oppQuote.Id;
                }
            }
        }
        return null;
    }

    /**
     * Called after insert, set GRID on newly created lead records
     * @param leads new leads
     */
    public static void setGRID(List<Lead> leads) {
        System.debug('GRIDLeadCreationAction.setGRID: start, leads are: ' + leads.size());

        List<Lead> toUpdate = new List<Lead>();

        for (Lead ld : leads) {

            System.debug('GRIDLeadCreationAction.setGRID: Lead is: ' + ld.Id + ', sequence is: ' + ld.GRIDSequence__c);

            String grid = UtilsGlobalIdentifier.getGlobalIdentifierFromSequenceNumber(
                              Integer.valueOf(ld.GRIDSequence__c));

            toUpdate.add(
                new Lead(Id = ld.Id,
                         GRID__c = grid)
            );

            System.debug('GRIDLeadCreationAction.setGRID: grid is: ' + grid);
        }

        if (!Test.isRunningTest()) {
            update toUpdate;

            /* At this point you might ask yourself why the f*** he did this...
            Well, when I wrote this method Salesforce had this bug: https://success.salesforce.com/issues_view?id=a1p300000008XFyAAM
            Basically during test class auto number field are not unique...
            This caused lot of test class to fail because of the unique constraint we
            have on the GRID field, that depends on the Grid Sequence...
            As always AMAZING SALESFORCE EXPERIENCE :S */
        }

        System.debug('GRIDLeadCreationAction.setGRID: done');
    }

    /**
     * Called before update, checks that GRID is in sync with the sequence number.
     * Checks is performed only if GRID has changed
     * @param leads updated lead
     * @param oldLeads previous leads
     */
    public static void verifyGRID(List<Lead> leads, Map<Id, Lead> oldLeads) {
        System.debug('ClsLeadProcessor.verifyGRID: start, leads are: ' + leads.size());

        for (Lead ld : leads) {
            System.debug('ClsLeadProcessor.verifyGRID: Lead is: ' + ld.Id + ', grid is: ' + ld.GRID__c + ', seq is: ' + ld.GRIDSequence__c);

            if (ld.GRID__c == oldLeads.get(ld.Id).GRID__c) {
                continue; // nothing to check
            }

            Integer seq = UtilsGlobalIdentifier.getSequenceNumberFromGlobalIdentifier(ld.GRID__c);

            System.debug('ClsLeadProcessor.verifyGRID: seq is: ' + seq);

            if (seq != Integer.valueOf(ld.GRIDSequence__c)) {
                System.debug('ClsLeadProcessor.verifyGRID: grid out of sync! Rejecting record: ' + ld.Id);
                ld.addError(Label.GRID_Out_of_sync);
            }
        }

        System.debug('ClsLeadProcessor.verifyGRID: done');
    }
        /**
     * Called before insert and before update, checks the number of categories chosen for FP_Lead reacord type 
     * @param leads inserted, leads updated
     */
    public static void verifyCategory(List<Lead> leads, Map<Id, Lead> oldLeads){
   
        List<Lead> lstLeads = new List<Lead>();

        if(oldLeads == null || oldLeads.isEmpty()){
            ClsLeadProcessor.verifyCategory(leads);
        }else{
            for(Lead ld : leads){
                if(ld.Category__c != oldLeads.get(ld.Id).Category__c) lstLeads.add(ld);
            }
            if(!lstLeads.isEmpty()) ClsLeadProcessor.verifyCategory(lstLeads);
        }
    }

    /**
     * Called from verifyFPCategory method. Add error for leads where number of categories chosen is greater then 1
     * @param list of leads
     */
    public static void verifyCategory(List<lead> leads){
        /*All the recordtype set of Lead Object */
		Map<Id, RecordType> ldRTMap = LibRecordTypeHelper.getRecordTypeForIds(new Set<String>{'Lead'});
		/*Getting data from process name */
		Map<String, Map<String, Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('oneCategoryRecordtypes');
		/*Getting all the business rules from process  */
		Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get('ALL');
		if(mapBusinessRules == null || mapBusinessRules.get('LeadRecordTypes') == null) {return;}
		/*Getting business rules related to Lead recordtype  */
		Set<String> oneCatldRTSet = new Set<String>(mapBusinessRules.get('LeadRecordTypes').Business_Rule_Value__c.split(','));

        List<String> lstCat = new List<String>();
        for(Lead ld : leads){
            if((ldRTMap.get(ld.RecordTypeId) != null && !oneCatldRTSet.contains(ldRTMap.get(ld.RecordTypeId).developerName)) 
			|| String.isEmpty(ld.Category__c)) {continue;}
            lstCat = ld.Category__c.split(';');
            if(lstCat.size() > 1) ld.addError(Label.Error_message_for_Account_and_Lead_Category_Validation);
            lstCat.clear();
        }
    }
}
