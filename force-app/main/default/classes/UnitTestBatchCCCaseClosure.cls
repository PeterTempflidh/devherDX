@isTest
public class UnitTestBatchCCCaseClosure {
    @testSetup
    public static void setupData(){
    	UnitTestDataFactory.getRecordtypeValues();
    	
    	Country__c c = UnitTestDataFactory.createCountry('DE','Germany', 'EUR');
        insert c;
        Account acc = UnitTestDataFactory.createAccount('BatchCCClosure',c,'DE_Account');
        insert acc;
    	
    	List<Case> cases = new List<Case>();
    	Case cs1 = UnitTestDataFactory.createCase(acc,'Resolved','Customer',null,'Chat',c,'DE_Inbound_Case','test');
    	cs1.resolvedDate__c = Date.today().addDays(-20);
    	cs1.order_number__c = '90123456789012'; 
    	cs1.Case_Reason_Level_1__c = 'Across Journey';
    	cs1.Case_Reason_Level_2__c = 'Technical issue';
    	cs1.Case_Reason_Level_3__c = 'Website issue';
    	cs1.customer_email__c = 'test@test.com'; 
    	cs1.Platform__c = 'PizzaDE';
    	cs1.Description = 'test';
    	cases.add(cs1);
    	Case cs2 = UnitTestDataFactory.createCase(acc,'Resolved','Customer',null,'Chat',c,'DE_Inbound_Case','test');
    	cs2.resolvedDate__c = Date.today().addDays(-2);
    	cs2.order_number__c = '90123456789012';
    	cs2.Case_Reason_Level_1__c = 'Across Journey';
    	cs2.Case_Reason_Level_2__c = 'Technical issue';
    	cs2.Case_Reason_Level_3__c = 'Website issue';
    	cs2.customer_email__c = 'test@test.com';
    	cs2.Platform__c = 'PizzaDE';
    	cs2.Description = 'test';
    	cases.add(cs2);
    	insert cases;
    	
    	// update the case with resolved date again as resolved date resets on creation
    	cs1.resolvedDate__c = Date.today().addDays(-20);
    	cs2.resolvedDate__c = Date.today().addDays(-2);
    	update new List<Case>{cs1,cs2};
    	
    	// create configs
    	Business_Config__c bc1 = UnitTestDataFactory.createBusinessConfig('CCCaseClosureProcess', 'Process','recordTypes','DE_Inbound_Case,CD_Inbound_Case', null, 'Global_Config', true, true);
    	Business_Config__c bc2 = UnitTestDataFactory.createBusinessConfig('CCCaseClosureProcess', 'Process','numberOfDays','7', null, 'Global_Config', true, false);
    	Business_Config__c bc3 = UnitTestDataFactory.createBusinessConfig('CCCaseClosureProcess', 'Process','numberOfDaysforSocialCases','3', null, 'Global_Config', true, false);

        insert new List<sObject>{bc1,bc2,bc3};
    }
    
    @isTest
    public static void testBatchCCClosure(){
    	String CRON_EXP = '0 0 0 15 3 ? 2022';
    	Test.startTest();
    		BatchCCCaseClosure batch = new BatchCCCaseClosure();
        	Database.executebatch(batch);
    	Test.stopTest();
    	
    	List<Case> cases = [Select Id from Case where status = 'Closed'];
    	system.assertEquals(1,cases.size());
    }
    
}