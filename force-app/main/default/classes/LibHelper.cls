/**
 * Created by sourabha.rao on 19.10.2017.
 * Helper class for methods that can be called from many other classes
 */

public without sharing class LibHelper {
    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;


    public static Set<id> checkForNonActiveAddon(Set<Id> oppids){
        Set<ID> oppsWithNotActiveAddon = new Set<ID>();

        if (oppids == null || oppids.isEmpty()) {
            return oppsWithNotActiveAddon;
        }
            
        if(oppids.contains(null)) {
            oppids.remove(null);
        }
        
        List<Add_on_Service__c> addon = [SELECT id,Opportunity__c,status__c
                                         FROM add_on_service__c
                                         WHERE Opportunity__c in :oppids];
        
        for(Add_on_Service__c ao:addon){
            if(ao.status__c!='Active'){
                oppsWithNotActiveAddon.add(ao.Opportunity__c);
            }
        }
        
        return oppsWithNotActiveAddon;
    }
    
    /**
    * @Description: This method checks for the open photo listing cases
    */
    public static Set<Id> checkForOpenPhotoListingCases(Set<Id> opptoCheckForOpenPhotoListing){
    	Set<Id> oppWithOpenPhotoListingCases	= new Set<Id>();
    	List<Case> photoListingCases = [SELECT Id,Opportunity__c
    										FROM Case
    										WHERE Opportunity__c in: opptoCheckForOpenPhotoListing
                                                AND  type = 'Photo Listing'
    											AND isClosed = false];
		
		for(Case cs : photoListingCases){
			oppWithOpenPhotoListingCases.add(cs.Opportunity__c);
		}
		
		return oppWithOpenPhotoListingCases;
    }

    public static Set<id> checkForInactiveAsset(Set<Id> oppids,set<string> stStatus){
        Set<ID> oppWithInactiveAsset = new Set<ID>();
        List<Asset__c> assetLst =[SELECT Opportunity__c,
                Retour_date__c,
                Status__c
        FROM Asset__c
        WHERE Opportunity__c IN :oppids];


        for(Asset__c currentAsset:assetLst){
            if (!stStatus.contains(currentAsset.Status__c) && currentAsset.Retour_date__c == null) {
                oppWithInactiveAsset.add(currentAsset.Opportunity__c);
            }
        }

        return oppWithInactiveAsset;

    }
    public static Set<id> checkForOpencase(Set<Id> oppids){
        Set<ID> oppWithOpenCases = new Set<ID>();
        List<Case> casetLst = [select id, status, type, opportunity__c,case_reason__c, closed_reason__c
                                from Case
                                where opportunity__c in :oppIds
                                    And Status != 'Closed'];

        for(Case currentCase:casetLst){
                oppWithOpenCases.add(currentCase.Opportunity__c);
        }

        return oppWithOpenCases;

    }

    public static Set<id> checkForUndeliveredShipments(Set<Id> oppids){
        Set<ID> oppWithUndeliveredShipments = new Set<ID>();
        List<Shipment_Order__c> ShipmentOrderLst =[SELECT Opportunity__c,Status__c
        FROM Shipment_Order__c
        WHERE Opportunity__c IN :oppids
            AND Status__c != 'Delivered'];

        for(Shipment_Order__c shipOrd:ShipmentOrderLst){
            oppWithUndeliveredShipments.add(shipOrd.Opportunity__c);
        }

        return oppWithUndeliveredShipments;

    }


    public static Set<id> checkForUninstalledBranding(Set<Id> oppids,set<string> stStatus){
        Set<ID> oppWithUninstalledBranding = new Set<ID>();
        List<Branding_content__c> brandingContentLst = [SELECT Opportunity__c,
                Status__c
        FROM Branding_content__c
        WHERE Opportunity__c in :oppids
        AND Type__c Like 'White Label%'];

        for(Branding_content__c branding:brandingContentLst){
            if (!stStatus.contains(branding.status__c)) {
                oppWithUninstalledBranding.add(branding.Opportunity__c);
            }
        }

        return oppWithUninstalledBranding;

    }




    public Static void createRelatedRecords(Map<Id,Set<string>>oppids){
        List<Opportunity_Quote_Line_Item__c> oppQuoteLinesForAddon = new List<Opportunity_Quote_Line_Item__c>();
        List<Opportunity_Quote_Line_Item__c> oppQuoteLinesForAsset = new List<Opportunity_Quote_Line_Item__c>();
        List<Opportunity_Quote_Line_Item__c> oppQuoteLinesForBranding = new List<Opportunity_Quote_Line_Item__c>();

        List<Opportunity_Quote_Line_Item__c> oppquoteLines = new List<Opportunity_Quote_Line_Item__c>([

                select id,
                        name,
                        CurrencyIsoCode,
                (select id from Add_on_Services__r),
                (select id from Assets__r),
                (select id from Branding_Content__r),
                        Id_List_Product_Price__r.Requires_Branding__c,
                        Id_List_Product_Price__r.Requires_Asset__c,
                        Id_Opportunity_Quote__r.Id_Account__c,
                        Id_Opportunity__c,
                        Id_Opportunity__r.OwnerId,
                        Id_Opportunity__r.RecordType.DeveloperName,
                        Quantity__c,
                        Id_List_Product_Price__c,
                        Id_list_Add_On__c,
                        Sub_type__c,
                        Id_list_Add_On__r.name,
                        Id_List_Product_Price__r.Product_Type__c,
                        Number_of_Copies__c,
                        weight__c,
                        Line_Item_Type__c,
                        Contract_Addition__c,
                        size__c,
                        start_date__c,
                        end_date__c,
                        Id_List_Product_Price__r.Product_Name__c,
                        Deposit_Method__c,
                        Specifications__c,
                        Delivery__c,
                        Source_GRID__c,
                        RecordType.DeveloperName,
                        Id_Opportunity__r.AccountId,
                        Id_Opportunity__r.Account.GRID__c
                from Opportunity_Quote_Line_Item__c
                where Id_Opportunity__c in: OppIds.keyset()
                and Line_Item_Type__c In ('AddOn','Product')
                and Id_Opportunity_Quote__r.status__c = 'Accepted']);



        for(opportunity_quote_line_item__c oq:oppquoteLines){
            system.debug('oq->'+oq);
            if(oq.line_item_type__c=='AddOn'
                    && oppids.get(oq.Id_Opportunity__c).contains('AddOn')
                    && (oq.Add_on_Services__r == null || oq.Add_on_Services__r.isEmpty())) {
                oppQuoteLinesForAddon.add(oq);

            }else if(oq.line_item_type__c=='Product'
                    && oq.Id_List_Product_Price__r.Requires_Asset__c
                    && oppids.get(oq.Id_Opportunity__c).contains('Asset')
                    && (oq.Assets__r == null || oq.Assets__r.isEmpty())
                    && (oq.Delivery__c != 'Shipment')) { // included to don't created the Asset until the Shipmet is delivered  SP-2414
                system.debug('oq.Delivery__c-->'+oq.Delivery__c);
                oppQuoteLinesForAsset.add(oq);


            }else if(oq.line_item_type__c=='Product'
                    && oq.Id_List_Product_Price__r.Requires_Branding__c
                    && oppids.get(oq.Id_Opportunity__c).contains('Branding')
                    && (oq.Assets__r == null || oq.Assets__r.isEmpty())
                    && (oq.Delivery__c != 'Shipment')) {
                oppQuoteLinesForBranding.add(oq);


            }
        }

        oppids.clear();
        oppquoteLines.clear();

        if(!oppQuoteLinesForAddon.isEmpty()){
            createAddOn(oppQuoteLinesForAddon);

        }
        if(!oppQuoteLinesForAsset.isEmpty()){
            createAssets(oppQuoteLinesForAsset,null);
        }
        if(!oppQuoteLinesForBranding.isEmpty()){
            createBranding(oppQuoteLinesForBranding,null);
        }

    }

    public static void createAddOn(List<Opportunity_Quote_Line_Item__c> oppQuoteLineIds){
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('AddonCreation');
        List<Add_on_Service__c> lstAddon = new List<add_on_service__c>();
        if(mapBusinessLogic!=null && !mapBusinessLogic.isEmpty()){

            if(oppQuoteLineIds!=null && !oppQuoteLineIds.isempty()) {
                for (opportunity_quote_line_item__c oppQlineItem : oppQuoteLineIds) {
                    Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(oppQlineItem.RecordType.DeveloperName);
                    if(mapBusinessRules!=null && !mapBusinessRules.isEmpty()){
                        Add_on_Service__c addon = new Add_on_Service__c();
                        //addon.name = oppQlineItem.Id_list_Add_On__r.name;
                        addon.start_date__c=oppQlineItem.start_date__c;
                        addon.end_date__c=oppQlineItem.end_date__c;
                        addon.Account_Name__c = oppQlineItem.Id_Opportunity_Quote__r.Id_Account__c;
                        addon.CurrencyIsoCode = oppQlineItem.CurrencyIsoCode;
                        addon.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('AddonRecType').Business_Rule_Value__c);
                        addon.Opportunity__c = oppQlineItem.Id_Opportunity__c;
                        addon.Id_Opportunity_Quote_Line_item__c = oppQlineItem.id;
                        addon.type__c = oppQlineItem.sub_Type__c;
                        addon.Id_list_Add_On__c=oppQlineItem.Id_list_Add_On__c;
                        addon.Contract_Addition__c=oppQlineItem.Contract_Addition__c;
                        addon.Specifications__c = oppQlineItem.Specifications__c;
                        addon.status__c=mapBusinessRules.get(oppQlineItem.sub_Type__c).Business_Rule_Value__c;
                        lstAddon.add(addon);
                    }
                }

                if(!lstAddon.isEmpty()){
                    insert lstAddon;
                }
            }
        }
    }


    public static void createAssets(List<Opportunity_Quote_Line_Item__c> oppQuoteLineIds, map<ID,Shipment_Order_Line_Item__c> mpShipOrdbyLineItem) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('AssetCreation');
        List<Asset__c> listAssets = new List<Asset__c>();
        if (mapBusinessLogic == null || mapBusinessLogic.isEmpty())
            return;

        if (oppQuoteLineIds != null && !oppQuoteLineIds.isempty()) {
            for (opportunity_quote_line_item__c oppQlineItem : oppQuoteLineIds) {
                Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(oppQlineItem.RecordType.DeveloperName);
                if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                    for (integer i = 1; i <= oppQlineItem.Quantity__c; i++) {
                        Asset__c newAsset = new Asset__c();
                        newAsset.name = oppQlineItem.name;

                        system.debug('newAsset.name-->'+newAsset.name);
                        newAsset.OwnerId = oppQlineItem.Id_Opportunity__r.OwnerId;
                        newAsset.Account__c = oppQlineItem.Id_Opportunity_Quote__r.Id_Account__c;
                        newAsset.GRID__c = oppQlineItem.Id_Opportunity__r.Account.GRID__c;
                        newAsset.CurrencyIsoCode = oppQlineItem.CurrencyIsoCode;
                        newAsset.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('AssetRecordType').Business_Rule_Value__c);
                        newAsset.Id_Opportunity_Quote_Line_Item__c = oppQlineItem.Id;
                        newAsset.Opportunity__c = oppQlineItem.Id_Opportunity__c;

                        if (oppQlineItem.Id_List_Product_Price__r != null &&
                                mapBusinessRules.ContainsKey('AssetStatus-' + oppQlineItem.Id_List_Product_Price__r.Product_Type__c)) {
                            newAsset.Status__c = mapBusinessRules.get('AssetStatus-' + oppQlineItem.Id_List_Product_Price__r.Product_Type__c).Business_Rule_Value__c;
                        } else {
                            newAsset.Status__c = mapBusinessRules.get('AssetStatus').Business_Rule_Value__c;
                        }

                        newAsset.comment__c = String.isBlank(oppQlineItem.source_grid__C) ? '' : 'Source GRID :' + oppQlineItem.source_grid__C;
                        if (oppQlineItem.delivery__c == null || oppQlineItem.Delivery__c == 'Shipment') {
                            if (mapBusinessRules.get('AssetStatusShipment') != null) {
                                newAsset.Status__c = mapBusinessRules.get('AssetStatusShipment').Business_Rule_Value__c;
                            }
                            newAsset.type__c = 'Original';
                        } else {
                            newAsset.type__c = oppQlineItem.delivery__c;
                        }
                        if (mpShipOrdbyLineItem != null && mpShipOrdbyLineItem.get(oppQlineItem.id) != null) {
                            newAsset.Shipment_Order_Line_Item__c = mpShipOrdbyLineItem.get(oppQlineItem.id).Id;
                            newAsset.Stock_Item_Serial_No__c = mpShipOrdbyLineItem.get(oppQlineItem.id).Serial_Number__c;
                            newAsset.Stock_Item__c = mpShipOrdbyLineItem.get(oppQlineItem.id).Stock_Item__c;
                        }
                        listAssets.add(newAsset);
                    }
                }
            }
            if (!listAssets.isEmpty()) {
                insert listAssets;
            }
        }
    }

    public static void createBranding(List<Opportunity_Quote_Line_Item__c> oppQuoteLineIds, map<ID,Shipment_Order_Line_Item__c> mpShipOrdbyLineItem){
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('BrandingCreation');
        List<Branding_Content__c> listBranding = new List<Branding_Content__c>();

        if(mapBusinessLogic == null || mapBusinessLogic.isEmpty())
            return;

        for (Opportunity_Quote_Line_Item__c oppQlineItem : oppQuoteLineIds) {
            Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(oppQlineItem.RecordType.DeveloperName);
			if (mapBusinessRules == null || mapBusinessRules.isEmpty())
				continue;
			createBrandingRecord(oppQlineItem,listBranding,mapBusinessRules, mpShipOrdbyLineItem);
        }
        if(!listBranding.isEmpty())
            insert listBranding;
    }
    
    public static void createBrandingRecord(Opportunity_Quote_line_item__c oppQlineItem,
    													List<Branding_Content__c> listBranding,
														Map<String,Business_Config__c> mapBusinessRules, map<ID,Shipment_Order_Line_Item__c> mpShipOrdbyLineItem){
		
		Id ownerId 					= oppQlineItem.Id_Opportunity__r.OwnerId;
	    Id oppId 					= oppQlineItem.Id_Opportunity__c;
	    Id accId 					= oppQlineItem.Id_Opportunity__r.AccountId;
	    
	    integer qty = 0;
        if (oppQlineItem.branding_content__r == null || oppQlineItem.branding_content__r.isEmpty()) {
            Set<string> prodtTypeSet = new Set<String>();
            if (mapBusinessRules.get('DefaultBrandingQtyProdType') != null) {
                prodtTypeSet = new Set<String>(mapBusinessRules.get('DefaultBrandingQtyProdType').Business_Rule_Value__c.split(','));
            }
            if (mapBusinessRules.get('DefaultBrandingQtyProdType') != null && 
            	prodtTypeSet.contains(oppQlineItem.Id_List_Product_Price__r.Product_Type__c)) {
                	qty = 1;
            } else
                qty = Integer.valueof(oppQlineItem.Quantity__c);
                                    
            for (integer i = 1; i <= qty; i++  ) {
                Branding_Content__c newBranding 				= new Branding_Content__c();
                newBranding.OwnerId 							= ownerId;
                newBranding.Restaurant_Name__c 					= accId;
                newBranding.CurrencyIsoCode 					= oppQlineItem.CurrencyIsoCode;
                newBranding.Opportunity__c 						= oppId;
                newBranding.type__c 							= oppQlineItem.Id_List_Product_Price__r.Product_Type__c;
                newBranding.Id_Opportunity_Quote_Line_Item__c 	= oppQlineItem.id;
                newBranding.Number_of_Copies__c 				= oppQlineItem.Number_of_Copies__c;
                newBranding.Size__c 							= oppQlineItem.size__c;
                newBranding.weight__c 							= oppQlineItem.weight__c;
                newBranding.product__c 							= oppQlineItem.Id_List_Product_Price__c;
                newBranding.Deposit_Method__c 					= oppQlineItem.Deposit_Method__c;
                newBranding.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('BrandingContentRecordType').Business_Rule_Value__c);
                if (mapBusinessRules.get('BrandingContentRecordType').Business_Rule_Value__c == 'UK_Branding_Content')
                    newBranding.Quantity__c = 1;
                if (qty == 1){
                    newBranding.Quantity__c = oppQlineItem.Quantity__c;
                }else{
                    newBranding.Quantity__c = 1;// this case is when exist multiple record fo branding then always the quantity will be 1
                }
                if (mapBusinessRules.get('TemplateType') != null && 
                	Boolean.valueof(mapBusinessRules.get('TemplateType').Business_Rule_Value__c)) {
                    if (oppQlineItem.Id_List_Product_Price__r.Product_Name__c != null && 
                    	oppQlineItem.Id_List_Product_Price__r.Product_Name__c.containsIgnorecase('With Website')) {
                        	newBranding.Template_type__c = 'With Website';
                    } else if (oppQlineItem.Id_List_Product_Price__r.Product_Name__c != null && 
                    	oppQlineItem.Id_List_Product_Price__r.Product_Name__c.containsIgnorecase('Without Website'))
                        	newBranding.Template_type__c = 'Without Website';
                }

                if(oppQlineItem.Delivery__c == 'Shipment'){
                    if(mapBusinessRules.containskey('BrandingStatusShipment')){
                        newBranding.Status__c = mapBusinessRules.get('BrandingStatusShipment').Business_Rule_Value__c;
                    }
                }else{
                    if(mapBusinessRules.get('BrandingStatus')!= null){
                        newBranding.Status__c = mapBusinessRules.get('BrandingStatus').Business_Rule_Value__c;
                    }
               }
                if(mpShipOrdbyLineItem!= null && mpShipOrdbyLineItem.get(oppQlineItem.id) != null ){
                    newBranding.Shipment_Order_Line_Item__c=  mpShipOrdbyLineItem.get(oppQlineItem.id).Id;
                    newBranding.Quantity__c = mpShipOrdbyLineItem.get(oppQlineItem.id).Quantity__c == null ? newBranding.Quantity__c :
                                                mpShipOrdbyLineItem.get(oppQlineItem.id).Quantity__c != oppQlineItem.Quantity__c ?
                                                mpShipOrdbyLineItem.get(oppQlineItem.id).Quantity__c : newBranding.Quantity__c;
                    newBranding.Stock_Item__c = mpShipOrdbyLineItem.get(oppQlineItem.id).Stock_Item__c;
                }

                listBranding.add(newBranding);
            }
        }
	
	}

    /**
     * used in ClsEmailProcessor
     *
     * @param mapCases
     */
    public static void linkCasesToAccountBasedOnFieldValue(Map<Id, Case> mapCases) {
        System.debug('LINKAGE METHOD CALLED!');
        Set<String> setFieldValues = new Set<String>();
        Map<String, Business_Config__c> mapBusinessRule = new Map<String, Business_Config__c>();
        Map<String, Id> mapAccounts = new Map<String, Id>();
        Map<String, Id> mapContacts = new Map<String, Id>();

        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('EmailConfiguration');
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('EmailConfiguration');

        //Map<String,List<Case>> mapSortedCasesByRecordTypeName = sortCasesByRecordType(mapCases);

        //for(String theRecordTypeName : mapSortedCasesByRecordTypeName.keySet()){

        String theRecordTypeName = LibRecordTypeHelper.getRecordTypeValue(mapCases.values()[0].RecordTypeId);

        System.debug('theRecordTypeName: ' + theRecordTypeName);
        mapBusinessRule = mapBusinessLogic.get(theRecordTypeName);

        if (mapBusinessRule != null) {
            /*String lookUpField = mapBusinessRule.get('lookUpField').Business_Rule_Value__c;
            String connectionField = mapBusinessRule.get('connectionField').Business_Rule_Value__c;
            String lookUpObject = mapBusinessRule.get('lookUpObject').Business_Rule_Value__c;*/
            String caseField = mapBusinessRule.get('caseField').Business_Rule_Value__c;
            String accountField = mapBusinessRule.get('accountField').Business_Rule_Value__c;
            String contactField = mapBusinessRule.get('contactField').Business_Rule_Value__c;
            String accountRecordTypeId = mapBusinessRule.get('accountRecordTypeId').Business_Rule_Value__c;
            String contactRecordTypeId = mapBusinessRule.get('contactRecordTypeId').Business_Rule_Value__c;

            List<Case> listCases = mapCases.values();

            for (Case c : listCases) {
                String fieldValue = (String)c.get(caseField);
                if (fieldValue != null) {
                    fieldValue = fieldValue.trim();
                    if (!setFieldValues.contains(fieldvalue)) {
                        setFieldValues.add(fieldvalue);
                    }
                }
            }

            if (!setFieldValues.isEmpty()) {


                String queryAccounts = 'SELECT Id, ' + accountField + ' FROM Account WHERE ' + accountField + ' IN: setFieldValues AND RecordTypeId = \'' + accountRecordTypeId + '\'';
                String queryContacts = 'SELECT Name,Id,AccountId, ' + contactField + ' FROM Contact WHERE ' + contactField + ' IN: setFieldValues AND RecordTypeId = \'' + contactRecordTypeId + '\'';

                System.debug('contacts query: ' + queryContacts);

                List<Account> listAccounts = Database.query(queryAccounts);
                List<Contact> listContacts = Database.query(queryContacts);

                System.debug('list accounts size: ' + listAccounts.size());
                System.debug('list contacts size: ' + listContacts.size());

                if (!listAccounts.isEmpty()) {
                    for (Account a : listAccounts) {
                        mapAccounts.put((String)a.get(accountField), a.Id);
                    }
                }

                if (!listContacts.isEmpty()) {
                    for (Contact c : listContacts) {
                        System.debug('found contact: ' + c);
                        mapContacts.put((String)c.get(contactField), c.AccountId);
                    }
                }


                System.debug('mapAccounts ' + mapAccounts);
                System.debug('mapContacts ' + mapContacts);


                for (Case c : listCases) {
                    Id theAccountId = null;
                    System.debug('getting something out of mapAccounts ' + mapAccounts.get((String)c.get(caseField)));
                    System.debug('getting something out of mapContacts ' + mapContacts.get((String)c.get(caseField)));

                    if (mapAccounts.get((String)c.get(caseField)) != null) {
                        System.debug('found something in account map');
                        theAccountId = mapAccounts.get((String)c.get(caseField));
                    }

                    if (mapContacts.get((String)c.get(caseField)) != null && theAccountId == null) {
                        System.debug('found something in contact map');
                        System.debug('mapContacts: ' + mapContacts);
                        System.debug('found value in contact map : ' + c);
                        theAccountId = mapContacts.get((String)c.get(caseField));
                    }

                    c.AccountId = theAccountId;

                }
            }




        }
        //}
        update mapCases.values();
    }

    /**
    * @Description: Used for returning case reason level 1 - 3 for testing
    */
    public static Case getCaseLevelTest(){
        return [SELECT Id, RecordTypeId,Type,Case_Reason_Level_1__c,Case_Reason_Level_2__c,Case_Reason_Level_3__c FROM Case LIMIT 1];
    }

}