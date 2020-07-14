@isTest
public class UnitTestClsEventTriggerProcessor {
    
    @testSetup static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
        
        // create business configs
        List<Business_Config__c> configs = new List<Business_Config__c>();
        configs.add(UnitTestDataFactory.createBusinessConfig('opportunityUpdateFromTaskProcess','process','requiredProbabilityForCEStage','20', null,'Generic_Activity',True,True));
        configs.add(UnitTestDataFactory.createBusinessConfig('opportunityUpdateFromTaskProcess','process','oppContactEstablishedStageName','Contact Established', null,'Generic_Activity',True,false));
        configs.add(UnitTestDataFactory.createBusinessConfig('opportunityUpdateFromTaskProcess','process','requiredProbabilityForOpenStage','5', null,'Generic_Activity',True,false));
        configs.add(UnitTestDataFactory.createBusinessConfig('opportunityUpdateFromTaskProcess','process','oppOpenStageName','Open', null,'Generic_Activity',True,false));
        configs.add(UnitTestDataFactory.createBusinessConfig('opportunityUpdateFromTaskProcess','process','CEAcitvitySubject','Call - Decision maker reached', null,'Generic_Activity',True,false));
        configs.add(UnitTestDataFactory.createBusinessConfig('opportunityUpdateFromTaskProcess','process','openAcitvitySubject','Call - Employee reached,Call - Nobody reached', null,'Generic_Activity',True,false));
        configs.add(UnitTestDataFactory.createBusinessConfig('opportunityUpdateFromTaskProcess','process','taskTypes','Call', null,'Generic_Activity',True,false));
        configs.add(UnitTestDataFactory.createBusinessConfig('opportunityUpdateFromTaskProcess','process','taskStatus','Completed', null,'Generic_Activity',True,false));
        configs.add(UnitTestDataFactory.createBusinessConfig('opportunityUpdateFromTaskProcess','process','eventTypes','Meeting', null,'Generic_Activity',True,false));
        insert configs;
        
    	Country__c testCountry = UnitTestDataFactory.createCountry('DE', 'Germany', 'EUR');
        insert testCountry;
        Company__c testCompany = UnitTestDataFactory.createCompany('Lieferheld', 'Lieferheld', testCountry);
        insert testCompany;
        List<Account> accounts 	= UnitTestDataFactory.createAccounts(1, testCountry, 'DE_Account');
        insert accounts;
        List<Opportunity> opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'DE_Opportunity', Date.today().addMonths(2));
        opportunities[0].stageName = 'New';
        insert opportunities;
    }
    
    @isTest
    public static void testOpportunityStageUpdate(){   
        List<Opportunity> opportunities = [Select Id from Opportunity];
        Test.startTest();
        	Event evt  = new Event(Subject = 'Email', Type = 'Meeting', whatId = opportunities[0].id, 
        				description = 'test it', StartDateTime = DateTime.now(), EndDateTime = Datetime.now(),
        				recordtypeId = LibRecordTypeHelper.getRecordTypeValue('DE_Event'));
        	insert evt;
        Test.stopTest();
        
        List<Opportunity> opps = [Select Id from Opportunity where stageName = 'Contact Established'];
        system.assertEquals(1,opps.size());	
    }
}