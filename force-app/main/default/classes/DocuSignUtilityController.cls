/**
* @author       : Delivery Hero SE (sundra.anand@deliveryhero.com)
* @date         : 09.01.2020
* @description  : Processor/Controller class for DocuSign Status Object
* @Test Class   : DocuSignUtilityController_Test
* @log          :
* -------------------------------------------------------------------------------------------------------------------------------
* Developer            Date         Description                                                                  version
* -------------------------------------------------------------------------------------------------------------------------------
* Sundra Anand         09.01.2020   Newly created                                                                 V1.0
* Sundra Anand         22.03.2020   Code refactoring                                                              V1.1

**/

public class DocuSignUtilityController {

    public static String oppQuoteId;
    public static Opportunity_Quote__c oppQuoteRecord;
    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;

    //DocuSign Connection Settings
    private static final String USER_NAME;
    private static final String PASS_WORD;
    private static final String INTEGRATOR_KEY;
    private static final String ACCOUNT_ID;
    private static final String BASE_URL;
    private static final String AUTH_TEMPLATE;
    private static DocuSign_Org_Settings__c orgSetting;
    private static final String STATUS_VOID = 'voided';
    private static String VOID_REASON;

    // Static block
    static {
        orgSetting = DocuSign_Org_Settings__c.getInstance();
        USER_NAME = orgSetting.DocuSign_User_Name__c;
        PASS_WORD = orgSetting.DocuSign_PassWord__c;
        INTEGRATOR_KEY = orgSetting.DocuSign_Integrator_Key__c;
        ACCOUNT_ID = orgSetting.DocuSign_Account_Id__c;
        BASE_URL = orgSetting.DocuSign_Base_URL__c;
        AUTH_TEMPLATE  = '<DocuSignCredentials><Username>' + USER_NAME
                + '</Username><Password>' + PASS_WORD
                + '</Password><IntegratorKey>' + INTEGRATOR_KEY
                + '</IntegratorKey></DocuSignCredentials>';
    }

    //Constructor for VF page - DocuSignURLGenerator
    public DocuSignUtilityController(ApexPages.StandardController controller) {
        oppQuoteId = controller.getId();
    }

    // **
    // * @date          : 09.01.20
    // * @description   : Used in VF page DocuSignURLGenerator to redirect to DocuSign Page.
    // * @params        :
    // * @return        : PageReference
    // **
    public PageReference createEnvelope() {

        String finalURL = buildDocuSignURL(oppQuoteId);
        PageReference createEnvelopURL = new PageReference(finalURL);
        createEnvelopURL.setRedirect(true);
        return createEnvelopURL;

    }

    // **
    // * @date          : 09.01.20
    // * @description   : Create DocuSign Envelope URL.
    // * @params        : Opportunity_Quote__c
    // * @return        : String
    // **
    @AuraEnabled(cacheable=true)
    public static String buildDocuSignURL(String quoteId) {

        //Get Quote Record
        oppQuoteRecord = OpportunityQuoteSelector.findQuotesbyIds(new Set<Id> {Id.valueOf(quoteId)})[0];

        //DocuSign url parameters
        String returnURL, RC = '', RSL ='', RSRO ='', RROS='1', CCRM='', CCTM='', CCNM='', CRCL='', CRL='', SourceID='', OCO ='', DST='', LA='1', LF='', CEM='', CES='', STB='', SSB='', SES='', SEM='', SRS='', SCS ='', RES='';

        DocusignEmailTemplate dsEmail = getEmailTemplate(oppQuoteRecord);

        CRL = loadRecipients(oppQuoteRecord, dsEmail);
        CES = dsEmail.emailSubject; //Email Subject
        DST = dsEmail.dsTemplate; //DocuSign Template
        CEM = dsEmail.emailBody; //Email Message

        //returnURL = '/apex/dsfs__DocuSign_CreateEnvelope?DSEID=0&SourceID=' +oppQuote.Id +'&RC='+RC +'&RSL='+RSL+'&RSRO='+RSRO+'&RROS='+RROS+'&CCRM='+CCRM+'&CCTM='+CCTM+'&CRCL='+CRCL+'&CRL='+CRL+'&OCO='+OCO+'&DST='+DST+'&CCNM='+CCNM+'&LA='+LA+'&LF='+LF+'+&CES='+CES+'&CEM='+CEM+'&SRS='+SRS+'&STB='+STB+'&SSB='+SSB+'&SES='+SES+'&SEM='+SEM+' &SRS='+SRS+'&SCS='+SCS+'&RES='+RES;
        returnURL = '/apex/dsfs__DocuSign_CreateEnvelope?DSEID=0&SourceID='+quoteId+'&CRL='+CRL+'&DST='+DST+'&CES='+CES+'&CEM='+CEM;  //Final URL

        return returnURL;

    }

    private static String loadRecipients(Opportunity_Quote__c oppQuoteRecord, DocusignEmailTemplate dsEmail) {
        Business_Config__c recipientConfig  = LibBusinessConfig.getBusinessConfigFromRuleMap('docuSignFilters', oppQuoteRecord.RecordTypeId, 'sendToOpportunityOwner');
        Boolean sendToOpportunityOwner = recipientConfig != null && Boolean.valueOf(recipientConfig.Business_Rule_Value__c);
        Integer ownerRoutingOrder = sendToOpportunityOwner ? 2 : 1;
        //Load Recipients ~ CRL
        String CRL = '';
        if (sendToOpportunityOwner) {
            CRL += 'Email~' + oppQuoteRecord.Id_Opportunity__r.Owner.Email + ';FirstName~' + oppQuoteRecord.Id_Opportunity__r.Owner.FirstName + ';LastName~' + oppQuoteRecord.Id_Opportunity__r.Owner.LastName + ';Role~Signer 1;SignInPersonName~;RoutingOrder~1,';
        }
        CRL += 'Email~' + dsEmail.ownerContact.Email + ';FirstName~' + dsEmail.ownerContact.FirstName + ';LastName~' + dsEmail.ownerContact.LastName + ';Role~Signer ' + ownerRoutingOrder + ';SignInPersonName~;RoutingOrder~' + ownerRoutingOrder + ';AccessCode~;RecipientNote~;SignNow~,LoadDefaultContacts~1';
        return CRL;
    }

    // **
    // * @date          : 03.03.20
    // * @description   : Method to return the email template details from the business config
    // * @params        : Opportunity_Quote__c
    // * @return        : DocusignEmailTemplate
    // **
    public static DocusignEmailTemplate getEmailTemplate(Opportunity_Quote__c oppQuote) {
        String dsEmailBody = '', templateName = '';
        DocusignEmailTemplate det = new DocusignEmailTemplate();
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('docuSignEmailTemplate');
        Map<String, Business_Config__c> mapBusinessRules = new Map<String, Business_Config__c>();
        mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(oppQuote.RecordTypeId));
        if(mapBusinessRules != null && mapBusinessRules.get(oppQuote.Id_Account__r.Record_Country__c) != null) {
            templateName = mapBusinessRules.get(oppQuote.Id_Account__r.Record_Country__c).Business_Rule_Value__c;
        }
        List<String> tempSplit = templateName.split(',');
        List<EmailTemplate> etemp = EmailTemplateSelector.getListTemplateByDeveloperName(tempSplit[0]);
        Contact ownerCon = ContactSelector.getAccountOwnerInformation(oppQuote.Id_Account__c);
        det.ownerContact = ownerCon;
        det.emailSubject = etemp[0].Subject;
        dsEmailBody = etemp[0].Body.replace('[Contact Name]', ownerCon.FirstName+' '+ownerCon.LastName);
        dsEmailBody = dsEmailBody.replace('[Contact Salutation]', (ownerCon.Salutation == null ? '' : (ownerCon.Salutation + ' ')));
        dsEmailBody = dsEmailBody.replace('[Contact FirstName]', ownerCon.FirstName);
        dsEmailBody = dsEmailBody.replace('[Opportunity Owner Name]', oppQuote.Id_Opportunity__r.Owner.FirstName+' '+oppQuote.Id_Opportunity__r.Owner.LastName);
        dsEmailBody = dsEmailBody.replace('[Opportunity Owner email]', oppQuote.Id_Opportunity__r.Owner.Email);
        det.emailBody = dsEmailBody;
        det.dsTemplate = tempSplit[1];
        return det;
    }


    // **
    // * @date          : 24.01.20
    // * @description   : Method to get List of DocuSign Status object
    // * @params        : Set<Id> of Opportunity Quotes,Set<Id> Opportunity Quotes,String of Void reason
    // * @return        : void
    // **
    @Future(Callout=true)
    public static void voidEnvelopeBuilder(Set<Id> quoteIds, Set<Id> excludeIds, String voidReason) {

        VOID_REASON = voidReason;

        List<dsfs__DocuSign_Status__c> dsStatusList = new List<dsfs__DocuSign_Status__c>();

        String queryStr =  'Select Id, dsfs__DocuSign_Envelope_ID__c, dsfs__Envelope_Status__c From dsfs__DocuSign_Status__c Where Opportunity_Quote__c IN : quoteIds and dsfs__Envelope_Status__c !=\'Completed\'';

        if(excludeIds != null && !excludeIds.isEmpty()) {
            String tempFilter = ' and Id not in (';
            for(Id i : excludeIds){
                tempFilter+= '\'' + (String)i + '\',';
            }
            String extraFilter = tempFilter.substring(0,tempFilter.length()-1);
            extraFilter+= ')';

            queryStr+= extraFilter;
        }

        dsStatusList = Database.query(queryStr);

        if(!dsStatusList.isEmpty()) {
            for(dsfs__DocuSign_Status__c dst : dsStatusList) {
                voidEnvelopeCallout(dst.dsfs__DocuSign_Envelope_ID__c);
            }
        }

    }

    // **
    // * @date          : 24.01.20
    // * @description   : Method to void envelope
    // * @params        : String of DS_Envelope_ID
    // * @return        : void
    // **
    public static void voidEnvelopeCallout(String envelopeId) {

        try {
            String endpoint = String.format('{0}/accounts/{1}/envelopes/{2}', new String[]{BASE_URL, ACCOUNT_ID, envelopeId});

            DocusignStatusRequest statusUpdate = new DocusignStatusRequest();
            if(String.isNotBlank(VOID_REASON)) {
                statusUpdate.status = STATUS_VOID;
                statusUpdate.voidedReason = VOID_REASON;
            }

            // initialize the api
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('PUT');
            request.setHeader('X-DocuSign-Authentication', String.format(AUTH_TEMPLATE, new String[]{USER_NAME,PASS_WORD,INTEGRATOR_KEY}));
            request.setBody(JSON.serialize(statusUpdate));
            System.debug('request:::::'+request);
            h.send(request);
        }
        catch(Exception exp) {
            System.debug('Error: '+exp.getMessage());
            LoggingUtility.commitLogs();
        }

    }

    // wrapper class for the status and the void reason
    public class DocusignStatusRequest {
        public String status {get; set;}
        public String voidedReason {get; set;}
    }

    // wrapper class for the EmailTemplate
    public class DocusignEmailTemplate {
        public String emailSubject {get; set;}
        public String emailBody {get; set;}
        public String dsTemplate { get; set;}
        public Contact ownerContact { get; set;}
    }

    // **
    // * @date          : 30.03.20
    // * @description   : validation to restrict users from creating more that 2 DocuSign envelopes for a quote
    // * @params        : Opportunity quote Id
    // * @return        : Boolean
    // **
    @AuraEnabled
    public static Boolean checkDocuSignEnvelopeCount(Id quoteId) {

        List<dsfs__DocuSign_Status__c> envelopesConsumed = DocuSignStatus_Selector.getDocuSignStatusbyQuoteIds(new Set<Id> {quoteId});
        if(!envelopesConsumed.isEmpty()){
            Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('docuSignFilters');
            Map<String, Business_Config__c> mapBusinessRules = new Map<String, Business_Config__c>();
            mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(envelopesConsumed[0].Opportunity_Quote__r.RecordTypeId));
            if(mapBusinessRules != null &&  mapBusinessRules.containsKey('maxEnvelopeCount') && envelopesConsumed.size() >= Integer.valueOf(mapBusinessRules.get('maxEnvelopeCount').Business_Rule_Value__c)) {
                return true;
            }
        }
        return false;

    }

    // **
    // * @date          : 30.03.20
    // * @description   : Find the current Salesforce theme of the logged in user
    // * @params        :
    // * @return        : String
    // **
    @AuraEnabled
    public static String getUIThemeDescription() {
        String theme = UserInfo.getUiThemeDisplayed();
        return theme;
    }

}
