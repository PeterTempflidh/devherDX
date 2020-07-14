@isTest
public class UnitTestUniversalSendEmailController {
	
    @TestSetup
    static void setup() {
        
        //Country__c testCountry = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'HKD');
        //insert testCountry;	
        Country__c testCountry = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'HKD');
        insert testCountry;
        RecordType testAccountRecordType = UnitTestDataFactory.getRecordType('FP_Account');
        RecordType testOpptyQuoteRecordType = UnitTestDataFactory.getRecordType('FP_Opportunity_Quote');
        List<RecordType__c> customSettings = new List<RecordType__c>();
        customSettings.add(new RecordType__c(Name = testAccountRecordType.Id,
                                                     Value__c = 'FP_Account'));
        customSettings.add(new RecordType__c(Name = testOpptyQuoteRecordType.Id,
                                                     Value__c = 'FP_Opportunity_Quote'));
		insert customSettings;
        RecordType__c additionalSetting = new RecordType__c(Name = 'FP_Account',
                                                     Value__c = customSettings[0].Id); 
        insert additionalSetting;
        Account testAccount = UnitTestDataFactory.createAccount('testacc', testCountry, 'FP_Account');
        testAccount.Phone = '+85265541700';
        insert testAccount;
        Opportunity testOpp = UnitTestDataFactory.createOpportunity('test',testAccount,'FP_Opportunity', Date.today());
        insert testOpp;
        Business_Config__c testConfig = UnitTestDataFactory.createBusinessConfig('UniversalSendSmsButtonProperties', 'Process', 'Opportunity_Quote__c::FP_Opportunity_Quote', 'google.com', String.valueOf(testCountry.Id), 'Global_Config', true, false);                        
       	insert testConfig;
        List<Opportunity_Quote__c> testQuote = UnitTestDataFactory.createOpportunityQuotes(testOpp, 1, 'FP_Opportunity_Quote', 'Draft', 'test description', 100.00, 110.00, '','',10.00);
        insert testQuote;
        
    }
    
    @isTest
    static void positiveScenarioTest(){
        
        Test.startTest();
        Opportunity_Quote__c quote = [SELECT Id FROM Opportunity_Quote__c LIMIT 1];
        String testResult = UniversalSendEmailButton_AuraController.getDestination(quote.Id);
        system.assertEquals('google.com', testResult);
        Test.stopTest();
    }
}