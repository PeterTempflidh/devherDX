/***
 * @description Util class user for sending email by email template
 * @date 27.05.2020
 * @author Danish Farooq
 * #ticket : SSC-3101
 */
public inherited sharing class ClsSendEmail_Utils {

    /**
   * @description Return account Map from the List of Opportunity
   * @param opptyLst List of Opportunity
   * @return Map of Opportunity
   */
    public static Map<ID,List<Opportunity>> getAccountMap(List<Opportunity> opptyLst){

        Map<ID,List<Opportunity>>  accountMap = new Map<ID,List<Opportunity>>();
        accountMap = ClsSObjectUtils.convertToIdMap(opptyLst,'AccountId');
        return accountMap;
    }
    /**
    * @description Return contact Map from Account Ids
    * @param accountIdSet Set of Account IDs
    * @return Map of Contact
    */
    public static Map<ID,Contact> getContactsMap(Set<Id> accountIdSet){

        Map<Id,Contact> mapOfContact = new Map<Id,Contact>();
        for(Contact iCon : ContactSelector.fetchContactsWithOwnerRole(accountIdSet)){
            mapOfContact.put(iCon.AccountId,iCon);
        }
        return mapOfContact;
    }
    /**
   * @description Return EmailTemplateIds from the combination of country/company Code
   * @param opportunitiesLst List of Opportunity
   * @return Map of Email Template Dev name
   */
    public static  Map<string, EmailTemplate> getEmailTemplateId(List<Opportunity> opportunitiesLst){

        string emailTemplateDevName = '';
        List<string> emailTemplateList = new List<string>();
        Map<string, EmailTemplate> mapOfEmailTemp = new Map<string,EmailTemplate>();
        for(Opportunity iOppty : opportunitiesLst){

            emailTemplateDevName = generateEmailTemplateDevName(iOppty);
            emailTemplateList.add(emailTemplateDevName);
        }
        for(EmailTemplate iEmailTemplate : EmailTemplateSelector.getTemplatesByDeveloperName(emailTemplateList)){
            mapOfEmailTemp.put(iEmailTemplate.DeveloperName,iEmailTemplate);
        }
        return mapOfEmailTemp;
    }
    /**
    * @description Return email list to be send with selected template and contact
     * @param opportunitiesLst List of Opportunity
     * @param mapOfContactIds (Owner)contact Id against account Id
     * @param mapOfEmailTemplate template Ids against Template developer Name (MY_FP_Self_Sign_Up_Restaurant)
     * @return Map of Email Template Dev name
    */
    public static List<Messaging.SingleEmailMessage> generateEmailFromTemplate(List<Opportunity> opportunitiesLst,
            Map<ID,Contact> mapOfContactIds,
            Map<string,EmailTemplate> mapOfEmailTemplate){

        boolean hasContactAndEmailTemplate = false;
        List<Messaging.SingleEmailMessage> singleEmailMessageLst =
                new List<Messaging.SingleEmailMessage>();
        messaging.SingleEmailMessage msgEmailObj;

        string emailTemplateDevName = '';
        for(Opportunity iOppty : opportunitiesLst){

            emailTemplateDevName = generateEmailTemplateDevName(iOppty);
            hasContactAndEmailTemplate = mapOfContactIds.containsKey(iOppty.AccountID)
                    && mapOfEmailTemplate.containsKey(emailTemplateDevName);

            if(!hasContactAndEmailTemplate){
                continue;
            }
            msgEmailObj = new messaging.SingleEmailMessage();
            msgEmailObj.setTargetObjectId(mapOfContactIds.get(iOppty.AccountID).ID);
            msgEmailObj.setTemplateID(mapOfEmailTemplate.get(emailTemplateDevName).ID);
            singleEmailMessageLst.add(msgEmailObj);
        }
        return singleEmailMessageLst;
    }
    /**
    * @description Replaces merge fields in text bodies of email templates with values from Salesforce records,
    * @param emailContent email body/email template content used for rendering purpose
    * @param whoId Lead ID or a Contact ID
    * @param whatId Any sObject ID for example (Account Id or Opportunity Id)
    * @return rendered email template
    */
    public static string processEmailContent(string emailContent, string whoId, string whatId){

        Messaging.RenderEmailTemplateBodyResult emailTemplateResult = Messaging.renderEmailTemplate(whatId, whoId, new List<string> {emailContent})[0];
        string renderEmailBody = emailTemplateResult.getMergedBody();
        return renderEmailBody;
    }
    /**
    * @description generate email template dev name from Company code/Country Code/ Account Vertical
    * @param opptyObj opportunity object
    * @return email template developer Name
    */
    @TestVisible
    private static string generateEmailTemplateDevName(Opportunity opptyObj){

        string emailTemplateDevName = '';
        emailTemplateDevName = opptyObj.Account.Company_Code__c+'_';
        emailTemplateDevName += opptyObj.Account.Account_Country_Code__c+'_';
        emailTemplateDevName += 'Self_Sign_Up';
        emailTemplateDevName += (string.isBlank(opptyObj.Account.Vertical__c) ? '' : '_'+opptyObj.Account.Vertical__c);
        return emailTemplateDevName;
    }
}