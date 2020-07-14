/**
 * Created by marco.zeuli on 14/2/2018.
 */
@isTest
private class UnitTestClsDeleteCustomerDetails {

    static final String EMAIL_TO_SEARCH_FOR = 'aaaaaa@aaaaaaa.it';

    @TestSetup
    static void setup() {
        UnitTestDataFactory.getRecordtypeValues();

        Country__c de = UnitTestDataFactory.createCountry('DE', 'Germany', 'EUR');
        insert de;

        Account acc = UnitTestDataFactory.createAccount('test', de, 'DE_Account');
        insert acc;

        Case inbound = new Case(
            RecordTypeId = LibRecordTypeHelper.getRecordTypeValue('DE_Inbound_Case'),
                Customer_Email__c = EMAIL_TO_SEARCH_FOR,
                Subject = 'test',
                Description = 'test',
                Platform__c = 'PizzaDE',
                Order_Number__c = '0'
        );

        Case internal = new Case(
                RecordTypeId = LibRecordTypeHelper.getRecordTypeValue('DE_Internal_Case'),
                Customer_Email__c = EMAIL_TO_SEARCH_FOR,
                Subject = 'test',
                Description = 'test',
                Platform__c = 'PizzaDE'
        );

        Case finance = new Case(
                RecordTypeId = LibRecordTypeHelper.getRecordTypeValue('DE_Finance_Case'),
                Customer_Email__c = EMAIL_TO_SEARCH_FOR,
                Subject = 'test',
                Description = 'test',
                Platform__c = 'PizzaDE'
        );

        Case entry = new Case(
                RecordTypeId = LibRecordTypeHelper.getRecordTypeValue('DE_Entry_Case'),
                Customer_Email__c = EMAIL_TO_SEARCH_FOR,
                Subject = 'test',
                Description = 'test',
                Platform__c = 'PizzaDE'
        );

        insert new List<Case> {inbound, internal, finance, entry};

        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;

        LiveChatTranscript chat1 = new LiveChatTranscript(
                Email__c = EMAIL_TO_SEARCH_FOR,
                LiveChatVisitorId = visitor.Id,
                Migration_ID__c = 'avoid flow to run'
        );

        insert chat1;
        
        // Create business configs
		Business_Config__c bc1 = UnitTestDataFactory.createBusinessConfig('customerDataDeletionProcess', 'Process','recordTypes','DE_Internal_Case,DE_Inbound_Case,DE_Finance_Case,DE_Entry_Case,DE_Restaurant_Operations', null, 'Global_Config', true, true);
    	Business_Config__c bc2 = UnitTestDataFactory.createBusinessConfig('customerDataDeletionProcess', 'Process','isSuspiciousCheckEnabled','True', null, 'Global_Config', true, false);
    	Business_Config__c bc3 = UnitTestDataFactory.createBusinessConfig('customerDataDeletionProcess', 'Process','suspiciousCheckTreshhold','15', null, 'Global_Config', true, false);
    	insert new List<sObject>{bc1,bc2,bc3};
    }

    @IsTest
    static void deleteDataDeleteAllRecords() {

        Test.startTest();

        ClsDeleteCustomerDetails.deleteData(EMAIL_TO_SEARCH_FOR);

        Test.stopTest();

        List<Case> cc = [SELECT Id FROM Case];
        List<LiveChatTranscript> chats = [SELECT Id FROM LiveChatTranscript];

        System.assert(cc.isEmpty());
        System.assert(chats.isEmpty());
    }
    
    @isTest
    static void testCustomerDataDeletionWebService(){
    	
    	Test.startTest();
        	CustomerDataDeletionService.DeletionResponse res  = CustomerDataDeletionService.deleteCustomerData(123,EMAIL_TO_SEARCH_FOR);
			CustomerDataDeletionService.DeletionResponse res2 = CustomerDataDeletionService.deleteCustomerData(124,'test@test.com');
        Test.stopTest();
        
        List<Case> cc = [SELECT Id FROM Case];
        List<LiveChatTranscript> chats = [SELECT Id FROM LiveChatTranscript];

        System.assert(cc.isEmpty());
        System.assert(chats.isEmpty());
        
        System.assertEquals(res.status,CustomerDataDeletionService.FULLFILLED);
        System.assertEquals(res2.status,CustomerDataDeletionService.ALREADY_FULLFILLED);
    }
    
    @isTest
    static void testSuspiciousDeletion(){
    	// create bulk cases
    	List<Case> cases = new List<Case>();
    	for(Integer i=0;i<=15;i++){
    		Case inbound = new Case(
	            RecordTypeId = LibRecordTypeHelper.getRecordTypeValue('DE_Inbound_Case'),
	                Customer_Email__c = EMAIL_TO_SEARCH_FOR,
	                Subject = 'test',
	                Description = 'test',
	                Platform__c = 'PizzaDE',
	                Order_Number__c = '0'
	        );
	        cases.add(inbound);
    	}
    	insert cases;
    	
    	Test.startTest();
        	ClsDeleteCustomerDetails.Result result = ClsDeleteCustomerDetails.deleteData(EMAIL_TO_SEARCH_FOR);
        Test.stopTest();
        
        // check no cases are deleted
        cases = [Select Id from Case];
        System.assertEquals(cases.size(),20);
        System.assertEquals(result.isError,True);
    }

}