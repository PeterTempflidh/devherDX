/**
 * Created by danish.farooq on 6/3/20.
 */

public with sharing class SelfSignUpSendEmail_AuraController {

    @AuraEnabled public String toEmailAddress {get;set;}
    @AuraEnabled public String ccEmailAddress {get;set;}
    @AuraEnabled public String emailBody {get;set;}
    @AuraEnabled public List<PickListWrapper> validFromEmails {get;set;}
    @AuraEnabled public EmailPropertiesWrapper emailWrapperObj {get;set;}

    /**
   * @description this used to generate send email details on the basis Account vertical and contact owner email
   * @param opportunityId opportunity Id for the current record
   * @return SelfSignUpSendEmail_AuraController object reference
   * Jira Ticket SSC-3101
   */
    @AuraEnabled
    public static SelfSignUpSendEmail_AuraController generateSendEmailDetails(string opportunityId){

        try{
            Map<ID,Contact> mapOfContact;
            Map<string,EmailTemplate> mapOfEmailTemplate;
            List<Opportunity> opportunitiesList;
            opportunitiesList = new List<Opportunity>();

            SelfSignUpSendEmail_AuraController sendEmailObj = new SelfSignUpSendEmail_AuraController();
            sendEmailObj.validFromEmails = getFromEmailList();
            Opportunity opptyObj = Opportunity_Selector.getOpportunityById(opportunityId);
            opportunitiesList.add(opptyObj);

            Map<ID,List<Opportunity>> mapOfOppty = ClsSendEmail_Utils.getAccountMap(opportunitiesList);
            mapOfContact = ClsSendEmail_Utils.getContactsMap(mapOfOppty.keySet());
            mapOfEmailTemplate = ClsSendEmail_Utils.getEmailTemplateId(opportunitiesList);

            Contact contactObj = (mapOfContact.isEmpty() ? null : mapOfContact.values()[0]);
            EmailTemplate emailTemplateObj = (mapOfEmailTemplate.isEmpty() ? null : mapOfEmailTemplate.values()[0]);
            boolean isValidTemplate = (emailTemplateObj != null && contactObj != null);
            if(isValidTemplate){
                sendEmailObj.emailBody = clsSendEmail_Utils.processEmailContent(emailTemplateObj.HtmlValue,contactObj.Id,opptyObj.Id);
                sendEmailObj.emailBody = (string.isBlank(sendEmailObj.emailBody) ? '': sendEmailObj.emailBody.replace(']]>',''));
                sendEmailObj.emailWrapperObj = new EmailPropertiesWrapper(new Contact(AccountId = contactObj.AccountId,Id = contactObj.Id),new EmailTemplate(Id = emailTemplateObj.ID,DeveloperName = emailTemplateObj.DeveloperName)
                        ,opptyObj, '');
                sendEmailObj.toEmailAddress = contactObj.email;
            }
            sendEmailObj.ccEmailAddress = UserInfo.getUserEmail();
            return sendEmailObj;
        }
        catch(Exception ex){
            throw new AuraHandledException('Something went wrong: ' + ex.getMessage());
        }
    }

    /**
   * @description send email to selected contact and email template
   * @param emailWrapperJson contains email TO,CC and template detail
   */
    @AuraEnabled
    public static void sendEmailToContact(string emailWrapperJson){

        try{
            EmailPropertiesWrapper emailWrapperObj = (EmailPropertiesWrapper)System.JSON.deserializeStrict(emailWrapperJson,EmailPropertiesWrapper.class);
            //get email message from selected opportunity and contact
            Messaging.SingleEmailMessage singleEmailMessage =
                    ClsSendEmail_Utils.generateEmailFromTemplate(new List<Opportunity> { emailWrapperObj.opportunityObj},
                            new Map<Id,Contact> { emailWrapperObj.contactObj.AccountId => emailWrapperObj.contactObj},
                            new Map<string,EmailTemplate>{emailWrapperObj.emailTemplateObj.developerName => emailWrapperObj.emailTemplateObj}
                    )[0];

            //send from org wide address if user has selected OWD address
            if(!string.isBlank(emailWrapperObj.fromAddress)){
                singleEmailMessage.setOrgWideEmailAddressId(emailWrapperObj.fromAddress);
            }
            if(emailWrapperObj.lstBccContacts != null && !emailWrapperObj.lstBccContacts.isEmpty()){
                List<string> lstBccEmailAddresses = new List<string>();
                for(Contact iCon : emailWrapperObj.lstBccContacts){
                    lstBccEmailAddresses.add(iCon.email);
                }
                singleEmailMessage.setBccAddresses(lstBccEmailAddresses);
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { singleEmailMessage });
        }
        catch(Exception ex){
            throw new AuraHandledException('Something went wrong: ' + ex.getMessage());
        }
    }

    /**
   * @description get org wide default enable email addresses
   * @return return picklist wrapper for Org addresses
   * Jira Ticket SSC-3101
   */
    private static List<PickListWrapper>  getFromEmailList(){

        List<PickListWrapper> validFromEmails = new List<PickListWrapper>();
        validFromEmails.add(new PickListWrapper('"' + UserInfo.getName() + '" <' +  UserInfo.getUserEmail() + '>',UserInfo.getUserId()));
        for (OrgWideEmailAddress owa : OrgWideEmailAddressSelector.getOrgWideEmailAddresses()) {
            validFromEmails.add(new PickListWrapper('"' + UserInfo.getOrganizationName() + '" <' + owa.Address + '>',owa.Id));
        }
        return validFromEmails;
    }

    /**
     * @description wrapper class used to store pick list values information
     */
    public class PickListWrapper{

        /**
        * @description to show org wide address in picklist
         */
        @AuraEnabled
        public string pickListLabel {get;set;}
        /**
       * @description to show org wide id in picklist
        */
        @AuraEnabled
        public string pickListValue {get;set;}

        public PickListWrapper(string pickListLabel,string pickListValue){
            this.pickListLabel = pickListLabel;
            this.pickListValue = pickListValue;
        }
    }

    /**
     * @description wrapper class to store sending email information
     */
    public class EmailPropertiesWrapper{
        /**
       * @description contains opportunity object
        */
        @AuraEnabled
        public Opportunity opportunityObj {get;set;}
        /**
        * @description contains contact object
       */
        @AuraEnabled
        public Contact contactObj {get;set;}
        /**
        * @description contains email templated object
       */
        @AuraEnabled
        public EmailTemplate emailTemplateObj {get;set;}
        /**
       * @description contains from address for sending email
       */
        @AuraEnabled
        public string fromAddress {get;set;}
        /**
        * @description contains list of BCC contacts to which email send
        */
        @AuraEnabled
        public List<Contact> lstBccContacts {get;set;}
         /**
       * @description EmailPropertiesWrapper constructor to assign values
       */
        public EmailPropertiesWrapper(Contact contactObj,
                                     EmailTemplate emailTemplateObj,
                                     Opportunity opportunityObj,
                                     string fromAddress){

            this.contactObj = contactObj;
            this.emailTemplateObj = emailTemplateObj;
            this.opportunityObj = opportunityObj;
            this.fromAddress = fromAddress;
        }
    }
}
