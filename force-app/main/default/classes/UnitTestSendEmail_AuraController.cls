/*
@author : Aleksejs Jedamenko
@reviewer : 
@creation : 11.10.2019
*/
/**
 * This class contains unit tests for SendEmail_AuraConroller class
 *
 * SendEmail_AuraConroller contains 2 aura enabled methods which are tested here separately. 
 * For getConfigParams we test negative and positive scenarios
 * For processEmail only standard flow
 */
@isTest
public class UnitTestSendEmail_AuraController {
    @TestSetup
    static void setup() {
    
    	Country__c testCountry = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'HKD');
        insert testCountry;
        RecordType testAccountRecordType = UnitTestDataFactory.getRecordType('FP_Account');
        RecordType testOpptyQuoteRecordType = UnitTestDataFactory.getRecordType('FP_Opportunity_Quote');
        RecordType testContactRecordType = UnitTestDataFactory.getRecordType('FP_Contact');
        RecordType testOpptyRecordType = UnitTestDataFactory.getRecordType('FP_Opportunity');
        List<RecordType__c> customSettings = new List<RecordType__c>();
        customSettings.add(new RecordType__c(Name = testAccountRecordType.Id,
                                                     Value__c = 'FP_Account'));
        customSettings.add(new RecordType__c(Name = testOpptyQuoteRecordType.Id,
                                                     Value__c = 'FP_Opportunity_Quote'));
        customSettings.add(new RecordType__c(Name = testContactRecordType.Id,
                                                     Value__c = 'FP_Contact'));
        customSettings.add(new RecordType__c(Name = testOpptyRecordType.Id,
                                                     Value__c = 'FP_Opportunity'));
		insert customSettings;
        RecordType__c additionalSetting = new RecordType__c(Name = 'FP_Account',
                                                     Value__c = customSettings[0].Id); 
        insert additionalSetting;
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(UnitTestDataFactory.createAccount('testacc', testCountry, 'FP_Account'));
        testAccounts[0].Phone = '+85265541700';
	testAccounts[0].Record_Country__c = 'Hong Kong';
        insert testAccounts;
        Opportunity testOpp = UnitTestDataFactory.createOpportunity('test',testAccounts[0],'FP_Opportunity', Date.today()); 
        testOpp.Business_Type__c = 'New Business';
        insert testOpp;
        List<Contact> testContacts1 = UnitTestDataFactory.createContacts(testAccounts, 'TestSoname1','TestName1', 'Mr.','Owner', 1, 'testcontact1', 'FP_Contact'); 
        List<Contact> testContacts2 = UnitTestDataFactory.createContacts(testAccounts, 'TestSoname2','TestName2', 'Mr.','Manager', 1, 'testcontact2', 'FP_Contact');
        testContacts1.addAll(testContacts2);
        insert testContacts1;
        List<Business_Config__c> dcList = new List<Business_Config__c>();   
        dcList.add(UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'LogoImage', '<div>testimage</div>', String.valueOf(testCountry.Id), 'FP_Opportunity_Quote', true, true));
        dcList.add(UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'SocialNetworkLogos', '<div>testicons</div>', String.valueOf(testCountry.Id), 'FP_Opportunity_Quote', true, false));
        dcList.add(UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'Contract Amendment', 'Contract_Amendment', String.valueOf(testCountry.Id), 'FP_Opportunity_Quote', true, false));
        dcList.add(UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'Contract_Amendment', 'Updated Contract Agreement from', String.valueOf(testCountry.Id), 'FP_Opportunity_Quote', true, false));  
       	dcList.add(UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'defaultAttachmentPerOppBusinessType-Hong Kong', 'Upgrade/Upsell=bad_file,New Business=account_register_form,Owner Change=account_register_form,Win Back=account_register_form', String.valueOf(testCountry.Id), 'FP_Opportunity_Quote', true, false));
       	dcList.add(UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'EmailTemplateURL', '{"Hong Kong":"https://www.foodpanda.com.hk","Laos":"https://www.foodpanda.com.la","Myanmar":"https://www.foodpanda.com.mm","Cambodia":"https://www.foodpanda.com.kh"}', String.valueOf(testCountry.Id), 'FP_Opportunity_Quote', true, false));
        insert dcList;
        List<Opportunity_Quote__c> testQuote = UnitTestDataFactory.createOpportunityQuotes(testOpp, 1, 'FP_Opportunity_Quote', 'Draft', 'test description', 100.00, 110.00, '','',10.00);
        testQuote[0].Quote_Type__c = 'Contract Amendment'; 
        testQuote[0].RecordType = testOpptyQuoteRecordType; 
        insert testQuote;
        Document testDoc = UnitTestDataFactory.getDocument('test', 'application/pdf', 'account_register_form', true, 'account_register_form', String.valueOf([SELECT Id FROM Folder WHERE Name = 'FP Documents' LIMIT 1].id));
        insert testDoc;
    }
    
    @isTest
    static void getDataTestPositive(){
     	
    	Test.startTest();
        Opportunity_Quote__c oppQuote = [SELECT Id, Name FROM Opportunity_Quote__c LIMIT 1];
        String result = SendEmail_AuraController.getConfigParams(oppQuote.Id);
        SendEmail_AuraController.ConfigWrapper wrapper = (SendEmail_AuraController.ConfigWrapper)JSON.deserialize(result,SendEmail_AuraController.ConfigWrapper.class);
        Test.stopTest();
 		system.assertNotEquals(null, wrapper.emailTemplate);
        system.assertEquals(1, wrapper.listOfEmails.size());
        system.assertEquals('testcontact2_contact_0_@deliveryhero.com', wrapper.listOfEmails[0]);
        system.assert(wrapper.validFromEmails.size()>0);
        system.assertEquals('Opportunity_Quote__c', wrapper.objectAPIName);
        system.assertEquals(oppQuote.Name,wrapper.recordName);
        system.assertEquals(1, wrapper.mandatoryAttachments.size());
    }
    
    @isTest 
     static void getDataTestNegative(){
         
        Test.startTest();
        Opportunity oppty = [SELECT Id, Business_Type__c FROM Opportunity LIMIT 1];
        oppty.Business_Type__c = 'Upgrade/Upsell';
        update oppty;
        Opportunity_Quote__c oppQuote = [SELECT Id, Name FROM Opportunity_Quote__c LIMIT 1];
        String result = SendEmail_AuraController.getConfigParams(oppQuote.Id);
        SendEmail_AuraController.ConfigWrapper wrapper = (SendEmail_AuraController.ConfigWrapper)JSON.deserialize(result,SendEmail_AuraController.ConfigWrapper.class);
        Test.stopTest();
 		system.assertNotEquals(null, wrapper.emailTemplate);
        system.assertEquals(1, wrapper.listOfEmails.size());
        system.assertEquals('testcontact2_contact_0_@deliveryhero.com', wrapper.listOfEmails[0]);
        system.assert(wrapper.validFromEmails.size()>0);
        system.assertEquals('Opportunity_Quote__c', wrapper.objectAPIName);
        system.assertEquals(oppQuote.Name,wrapper.recordName);
        system.assertEquals(0, wrapper.mandatoryAttachments.size());       
 
     }	
    
     @isTest 
     static void sendEmailTest(){
     	
     	SendEmail_AuraController.EmailDatapackWrapper emailWrapper = new SendEmail_AuraController.EmailDatapackWrapper();
        emailWrapper.email = new List<String> {'testFrom@test.com'}; 
        emailWrapper.emailsTo = new List<String> {'testTo@test.com'};
        emailWrapper.emailsAdd = new List<String> {'testAdd@test.com'};
        emailWrapper.emailsCC = new List<String> {'testCC@test.com'};
        emailWrapper.emailsBCC = new List<String> {'testBCC@test.com'};
        Document doc = [SELECT Id FROM Document LIMIT 1];
        emailWrapper.attachmentIds = new List<String> {doc.Id}; 
        emailWrapper.subject = 'test subject';
        emailWrapper.message = 'test message';
        Opportunity_Quote__c oppQuote = [SELECT Id FROM Opportunity_Quote__c LIMIT 1];
        emailWrapper.recordId = oppQuote.Id;
        Test.startTest();
        SendEmail_AuraController.processEmail(JSON.serialize(emailWrapper));
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();   
        system.assertEquals(1, emailInvocations);
     }
}
