/**
* @description Controller for pdfViewer Lightning Component
*/

public class pdfViewerCtrl {

    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    private static final List<String> validQuoteStatusesForDocuSign = new List<String>{'Approved','Sent','Viewed'};
    private static final List<String> validQuoteStatusesForSendEmail = new List<String>{'Approved','Accepted'};
    private static final List<String> validQuoteStatusesForAccept = new List<String>{'Signed','Accepted'};
    private static Boolean isVipAccount = false;

    /*******************************************************************************************************
    * @description Check the access level of the logged in user
    * @param oppQuoteId Quote Id
    * @return Boolean
    */
    @AuraEnabled
    public static Boolean getAccessLevelCtrl(Id oppQuoteId){
        return [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =: Userinfo.getUserId() AND RecordId =: oppQuoteId].HasEditAccess;
    }

    /*******************************************************************************************************
    * @description Get initial values on load of Lightning component
    * @param oq Quote record
    * @return Wrapper initWrapper
    */
    @AuraEnabled
    public static initWrapper getInitData(Opportunity_Quote__c oq){

        initWrapper wrap = new initWrapper();
        List<ContentDocumentLink> cdLinkList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: oq.Id]; //Get Document Id

        if(!cdLinkList.isEmpty()){
            wrap.returnUrl = EncodingUtil.base64Encode([SELECT VersionData FROM ContentVersion WHERE ContentDocumentId =: cdLinkList[0].ContentDocumentId AND IsLatest = true].VersionData); //Generate Nintex URL
        }
        else{
            wrap.returnUrl = null;
        }

        QuoteActionsWrapper dsWrap = buttonLogicProcessor(oq);
        wrap.disableAcceptButton    = dsWrap.dsAcceptButton;
        wrap.disableSendEmailButton = dsWrap.dsSendEmailButton;
        wrap.disableDocuSignButton  = dsWrap.dsDocuSignButton;

        return wrap;

    }

    /*******************************************************************************************************
    * @description Wrapper class for parameters in Lightning component
    */
    public class initWrapper{
        @AuraEnabled public String returnUrl;
        @AuraEnabled public Boolean disableAcceptButton;
        @AuraEnabled public Boolean disableSendEmailButton;
        @AuraEnabled public Boolean disableDocuSignButton;
    }

    /*******************************************************************************************************
    * @description Wrapper class for enabling button based on LineItems
    */
    public class QuoteActionsWrapper {
        public Boolean dsAcceptButton;
        public Boolean dsSendEmailButton;
        public Boolean dsDocuSignButton;
        public Integer totalLineItemsCount;
        public Integer dsRequiredLineItemsCount;
        public Integer dsBlockedLineItemsCount;
    }

    /*******************************************************************************************************
    * @description Enable/Disable Accept button in component
    * @param  oq Quote record
    * @return Boolean
    */
    public static Boolean findAcceptButton(Opportunity_Quote__c oq){

        //Checking for invalid Opp quote status
        if(oq.Status__c != 'Approved' && oq.Status__c != 'Signed'){
            return true;
        }

        //Checking if other Quotes are already accepted
        List<Opportunity_Quote__c> oqList = OpportunityQuoteSelector.getQuotesFromStatus('Accepted', oq.Id_opportunity__c);
        if(!oqList.isEmpty()){
            return true;
        }

        //Finding vip accept and accept probability from business config
        Boolean enableAcceptButtonForVipAccount = false;
        Integer allowAcceptProbability = 0;
        Boolean isVipCountry = false;
        Map<String, Map<String, Business_Config__c>> mapProcessData = moam.get('QuoteScreenProcess');
        Map<String, Business_Config__c> mapBusinessData = new Map<String, Business_Config__c>();
        mapBusinessData = mapProcessData.get(LibRecordTypeHelper.getRecordTypeValue(oq.RecordTypeId));
        if (mapBusinessData != null) {
            if (mapBusinessData.containsKey('AllowVIPAcceptQuote')){
                enableAcceptButtonForVipAccount = Boolean.valueOf(mapBusinessData.get('AllowVIPAcceptQuote').Business_Rule_Value__c);
            }
            if (mapBusinessData.containsKey('AllowAcceptQuoteButton')){
                allowAcceptProbability = Integer.valueOf(mapBusinessData.get('AllowAcceptQuoteButton').Business_Rule_Value__c);
            }
            if (mapBusinessData.containsKey('AllowVipAcceptCountries')) {
                isVipCountry = mapBusinessData.get('AllowVipAcceptCountries').Business_Rule_Value__c.containsIgnoreCase(oq.Id_Account__r.Record_Country__c);
            }
        }
        enableAcceptButtonForVipAccount = oq.Id_Account__r.Key_VIP_Account__c && enableAcceptButtonForVipAccount || isVipCountry;
        //Returning true if account is a vip accound and accept on VIP accounts is allowed
        if (enableAcceptButtonForVipAccount) {
            isVipAccount = true;
            return false;
        }

        //Returning false if Opportunity's probability is less than accept probability
        if(oq.Id_Opportunity__r.Probability < allowAcceptProbability ){
            return true;
        }

        return false;

    }

    /*******************************************************************************************************
    * @description Enable/Disable Send Email button in component
    * @param  oq Quote record
    * @return Boolean
    */
    public static Boolean findSendEmailButton(Opportunity_Quote__c oq) {
        if(!(validQuoteStatusesForSendEmail.contains(oq.Status__c))
                || oq.Id_Opportunity__r.Email_Path__c == Opportunity_Selector.OPPORTUNITY_EMAILPATH_DOCUSIGN)
        {
            return true;
        }
        return false;
    }

    /*******************************************************************************************************
    * @description Enable/Disable Send DocuSign Email button in component
    * @param  oq Quote record
    * @return Boolean
    */
    public static Boolean findDocuSignButton(Opportunity_Quote__c oq) {

        Business_Config__c dsConfig = LibBusinessConfig.getBusinessConfigFromRuleMap('docuSignFilters', oq.RecordTypeId, 'enableButton');
        if(dsConfig != null) {
            if(oq.Id_Opportunity__r.Email_Path__c == Opportunity_Selector.OPPORTUNITY_EMAILPATH_CLASSIC
                    || !validQuoteStatusesForDocuSign.contains(oq.Status__c))
            {
                return true;
            }
            else {
                return false;
            }
        }
        return true;
    }

    /*******************************************************************************************************
    * @description SSC-2501 Buttons Logic based of LineItems requiring DocuSign
    * @param  oq Quote record
    * @return Boolean
    */
    public static QuoteActionsWrapper buttonLogicProcessor(Opportunity_Quote__c oq) {

        QuoteActionsWrapper dsWrap = new QuoteActionsWrapper();
        dsWrap.dsAcceptButton    = findAcceptButton(oq);
        dsWrap.dsSendEmailButton = findSendEmailButton(oq);
        dsWrap.dsDocuSignButton  = findDocuSignButton(oq);

        Boolean isDSRuleApplicable = false;
        Integer maxDsCount;
        Integer acceptProbability = 0;
        Map<String, String> buttonLogicMap;

        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('docuSignFilters');
        if(mapBusinessLogic == null) {
            return dsWrap;
        }

        Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(oq.RecordTypeId));
        if(mapBusinessRules == null){
            return dsWrap;
        }

        Business_Config__c acceptLogicConfig = mapBusinessRules.containsKey('acceptButtonLogic') ? mapBusinessRules.get('acceptButtonLogic') : null;
        Business_Config__c acceptProbConfig = mapBusinessRules.containsKey('acceptProbability') ? mapBusinessRules.get('acceptProbability') : null;

        if(acceptLogicConfig != null) {
            Map<String,Map<String, String>> allCountryLogicMap = parseAcceptButtonConfig(acceptLogicConfig.Business_Rule_Value__c);
            buttonLogicMap = allCountryLogicMap.containsKey(oq.Id_Account__r.Record_Country__c) ? allCountryLogicMap.get(oq.Id_Account__r.Record_Country__c) : null;
        }

        if(acceptProbConfig != null) {
            acceptProbability = Integer.valueOf(acceptProbConfig.Business_Rule_Value__c);
        }

        if(buttonLogicMap == null) {
            return dsWrap;
        } else {
            isDSRuleApplicable = Boolean.valueOf(buttonLogicMap.get('ApplyLogic'));
            maxDsCount = Integer.valueOf(buttonLogicMap.get('EnableOnDSCount'));
        }

        if(!isDSRuleApplicable) {
            return dsWrap;
        }

        Boolean checkEnvelopeCount = false;
        List<dsfs__DocuSign_Status__c> envelopesConsumed;
        QuoteActionsWrapper countWrap = getLineItemsCountWithEsignature(oq);

        //When ESignature is mandatory for at least one line item
        if (countWrap.dsRequiredLineItemsCount > 0 && !isVipAccount) {
            dsWrap.dsSendEmailButton = true;
            envelopesConsumed = DocuSignStatus_Selector.getDocuSignStatusbyQuoteIds(new Set<Id>{oq.Id});
            checkEnvelopeCount = true;
        }
        //Check if already some envelopes are sent then enable send email button
        if (checkEnvelopeCount && !envelopesConsumed.isEmpty() && maxDsCount != null && envelopesConsumed.size() >= maxDsCount) {
            if(!validQuoteStatusesForAccept.contains(oq.Status__c)) {
                dsWrap.dsAcceptButton = (oq.Id_Opportunity__r.Probability <= acceptProbability && oq.Id_Opportunity__r.Email_Path__c == Opportunity_Selector.OPPORTUNITY_EMAILPATH_DOCUSIGN) ? true : false;
            }
            dsWrap.dsSendEmailButton = false;
            dsWrap.dsDocuSignButton = true;
        }
        //When ESignature is blocked for all line items
        if (countWrap.dsBlockedLineItemsCount > 0 && countWrap.totalLineItemsCount == countWrap.dsBlockedLineItemsCount) {
            dsWrap.dsDocuSignButton = true;
        }

        return dsWrap;

    }

    /*******************************************************************************************************
    * @description parses business config Json for Accept on behalf of customer button
    * @param  configJson
    * @return Map<String,Map<String, String>>
    */
    private static Map<String,Map<String, String>> parseAcceptButtonConfig(String configJson) {
        Map<String,Map<String, String>> configMap = new Map<String,Map<String, String>>();
        try {
            configMap = (Map<String,Map<String, String>>) JSON.deserialize(configJson, Map<String,Map<String, String>>.class);
        } catch (Exception ex) {
            throw new PdfViewerException( Label.Json_parsing_failure_error );
        }

        return configMap;
    }

    /*******************************************************************************************************
    * @description SSC-2501 Buttons Logic based of LineItems requiring DocuSign
    * @param  oq Quote record
    * @return Boolean
    */
    public static QuoteActionsWrapper getLineItemsCountWithEsignature(Opportunity_Quote__c oq) {

        Integer totalLineItems = 0;
        Integer dsRequiredLineItems = 0;
        Integer dsBlockedLineItems = 0;

        for (Opportunity_Quote_Line_Item__c lineItems : OpportunityQuoteLineItemSelector.getQuoteLineItemByDocuSign(oq.Id)) {
            totalLineItems++;
            Boolean dsMandatoryForLPP = (lineItems.Id_List_Product_Price__c != null && lineItems.Id_List_Product_Price__r.Requires_Esignature__c == 'Mandatory') ? true : false;
            Boolean dsMandatoryForLSP = (lineItems.Id_List_Service_Price__c != null && lineItems.Id_List_Service_Price__r.Requires_Esignature__c == 'Mandatory') ? true : false;
            Boolean dsMandatoryForLAO = (lineItems.Id_List_Add_On__c != null && lineItems.Id_List_Add_On__r.Requires_Esignature__c == 'Mandatory') ? true : false;
            Boolean dsBlockedForLPP   = (lineItems.Id_List_Product_Price__c != null && lineItems.Id_List_Product_Price__r.Requires_Esignature__c == 'Block') ? true : false;
            Boolean dsBlockedForLSP   = (lineItems.Id_List_Service_Price__c != null && lineItems.Id_List_Service_Price__r.Requires_Esignature__c == 'Block') ? true : false;
            Boolean dsBlockedForLAO   = (lineItems.Id_List_Add_On__c != null && lineItems.Id_List_Add_On__r.Requires_Esignature__c == 'Block') ? true : false;

            if (dsMandatoryForLPP || dsMandatoryForLSP || dsMandatoryForLAO) {
                dsRequiredLineItems++;
            }
            else if (dsBlockedForLPP || dsBlockedForLSP || dsBlockedForLAO) {
                dsBlockedLineItems++;
            }
        }

        QuoteActionsWrapper countWrap = new QuoteActionsWrapper();
        countWrap.totalLineItemsCount = totalLineItems;
        countWrap.dsRequiredLineItemsCount = dsRequiredLineItems;
        countWrap.dsBlockedLineItemsCount = dsBlockedLineItems;

        return countWrap;

    }


    /*******************************************************************************************************
    * @description Returns url for document generation in Nintex
    * @param  oppQuote,isInClassic Quote record, Salesforce Theme
    * @return String
    */
    @AuraEnabled
    public static string generateQuoteUrl(Opportunity_Quote__c oppQuote, Boolean isInClassic){
        try{
            //This file name should always match with the nintex delivery option filename
            String fileName = ContentVersion_Selector.QUOTE_FILENAME_PREFIX + oppQuote.Name + ContentVersion_Selector.FILE_TYPE_PDF;
            List<ContentDocumentLink> cdLinkList = ContentVersion_Selector.getContentDocumnetLink(oppQuote.Id,fileName );
            //3048 - Deleting all the existing files with the same name on regenerate quote button
            if(!cdLinkList.isEmpty()){
                 List<ContentDocument> cdList = new List<ContentDocument>();
                for(ContentDocumentLink cdl :cdLinkList){
                    ContentDocument cd = new ContentDocument();
                    cd.Id = cdl.ContentDocumentId;
                    cdList.add(cd);
                }                
                delete cdList;
            }
            return CtrOpportunityLineItems.getPackageDetails(oppQuote.Id, oppQuote.Id_Opportunity__r.RecordTypeId, isInClassic, oppQuote.Id_Account__r.Record_Country__c);
        }
        catch(Exception e){
            return 'Exception occurred: ' + e.getMessage() + ' at ' + e.getLineNumber() + '. Please contact your System Administrator.';
        }


    }
    
    /*****************************************************************************
    * @description Updating opportunity type after quote is accepted. Bug fix as per SSC-2121
    * @param oq Opportunity quote
    * @return wrapper of result of validation
    *******************************************************************************/
    @AuraEnabled
    public static string updateOpportunityType(Opportunity_Quote__c oq){
        return ClsRemoteController.updateOpportunityType(oq.Id_Opportunity__c);
    }


    /*******************************************************************************************************
    * @description Class to handle exceptions
    */
    public class PdfViewerException extends Exception {}

}
