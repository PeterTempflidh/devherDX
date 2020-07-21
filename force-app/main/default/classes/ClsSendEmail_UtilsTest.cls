/***
* @description test class for ClsSendEmail_Utils class
* @date 09.07.2020
* @author Danish Farooq
   */
@IsTest
private class ClsSendEmail_UtilsTest {

    @testSetup
    static void setup(){

        UnitTestDataFactory.getRecordtypeValues();
        Country__c country = UnitTestDataFactory.createCountry('MY', 'Malaysia', 'MYR');
        insert country;

        Company__c company = UnitTestDataFactory.createCompany('FP', 'FP', country);
        insert company;

        List<Account> lstAccounts = UnitTestDataFactory.createAccounts(1, country, 'FP_Account');

        for(Account iAccount : lstAccounts){
            iAccount.phone = '+6023456789';
            iAccount.CurrencyIsoCode = 'MYR';
            iAccount.Account_status__c = 'Active';
            iAccount.Vertical__c = 'Restaurant';
            iAccount.Vertical_Segment__c = 'Regular Restaurant';
            iAccount.Category__c = 'Asian';
            iAccount.Name = 'testAccount_Test';
        }
        insert lstAccounts;

        List<Contact> lstContact = UnitTestDataFactory.createContacts(lstAccounts,'FirstName','Last Name','MR','owner',1,'test',Constants.FP_CONTACT_DEVELOPERNAME);
        insert lstContact;

        List<Opportunity> lstOppty = UnitTestDataFactory.createOpportunities(lstAccounts,1,Constants.FP_OPPORTUNITY_DEVELOPERNAME,Date.today().addDays(10));
        insert lstOppty;
    }

    @IsTest
    static void testGetEmailDetails() {

        Test.startTest();
        string opptyId = '';
        for(Opportunity iOppty : Opportunity_Selector.getAll()){
            opptyId = iOppty.ID;
        }
        SelfSignUpSendEmail_AuraController sendEmailObj = SelfSignUpSendEmail_AuraController.generateSendEmailDetails(opptyId);
        Test.stopTest();
        system.assertNotEquals(null, sendEmailObj.toEmailAddress);
        system.assertNotEquals(null, sendEmailObj.ccEmailAddress);
        system.assertNotEquals(null, sendEmailObj.emailBody);
    }

    @IsTest
    static void testSendEmailDetails() {

        Opportunity opptyObj;
        for(Opportunity iOppty : Opportunity_Selector.getAll()){
            opptyObj = iOppty;
        }
        Account accObj = AccountSelector.getAccountByName('testAccount_Test');
        Contact conObj = ContactSelector.fetchContactsWithOwnerRole(new Set<Id> { accObj.Id })[0];
        opptyObj = Opportunity_Selector.getOpportunityById(opptyObj.ID);
        string emailTempDevName = ClsSendEmail_Utils.generateEmailTemplateDevName(opptyObj);
        EmailTemplate emailTemplateObj = EmailTemplateSelector.getTemplateByDeveloperName(emailTempDevName);
        Test.startTest();
        SelfSignUpSendEmail_AuraController.EmailPropertiesWrapper emailWrapper = new SelfSignUpSendEmail_AuraController.EmailPropertiesWrapper(conObj,emailTemplateObj,opptyObj,null);
        List<Contact> lstContacts = ContactSelector.fetchContactsWithOwnerRole( new Set<Id> { accObj.ID});
        emailWrapper.lstBccContacts = lstContacts;
        SelfSignUpSendEmail_AuraController.sendEmailToContact(json.serialize(emailWrapper));
        system.assertEquals(1, Limits.getEmailInvocations(), 'An email should be sent');
        Test.stopTest();
    }
}