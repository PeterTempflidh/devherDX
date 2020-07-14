@isTest
public class UnitTestBatchTerminateAddOns {
    
    @testSetup static void setup() {
		Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Add_On_Service__c'});
		UnitTestDataFactory.getRecordtypeValues();

		Country__c uk = UnitTestDataFactory.createCountry('UK', 'United Kingdom', 'GBP');
		insert new List<Country__c> {uk};

		Business_Config__c b1 = UnitTestDataFactory.createBusinessConfig('BatchAddOnTermination', 'Process', 'terminateAddOns', 'true', uk.id, 'UK_Add_On', true, true);
		Business_Config__c b2 = UnitTestDataFactory.createBusinessConfig('BatchAddOnTermination', 'Process', 'expiredStatus', 'Expired', uk.id, 'UK_Add_On', true, false);
		Business_Config__c b3 = UnitTestDataFactory.createBusinessConfig('BatchAddOnTermination', 'Process', 'terminationStatus', 'Terminated', uk.id, 'UK_Add_On', true, false);
		insert new List<sObject> {b1, b2, b3};

		Account acc1 = UnitTestDataFactory.createAccount('BatchTestClassAccount1', uk, 'UK_Account');
		insert new List<Account> {acc1};

		insert new Add_On_Service__c(
		    Account_Name__c = acc1.Id,
		    RecordTypeId 	= mapRecordtypes.get('UK_Add_On').Id,
		    End_Date__c 	= Date.today(),
		    status__c		= 'Active'
		);

	}
	
	@isTest
	public static void testExpiredStatus(){
		Test.startTest();
			Database.executeBatch(new BatchTerminateAddOns());
		Test.stopTest();
		
		Add_On_Service__c addOn = [Select Status__c from Add_On_Service__c];
		
		System.assertEquals('Expired',addOn.status__c);
	}
	
	@isTest
	public static void testTerminatedStatus(){
		Add_On_Service__c addOn 	= [Select Termination_Reason__c from Add_On_Service__c];
		addOn.Termination_Reason__c = 'test';
		update addon;
		
		Test.startTest();
			Database.executeBatch(new BatchTerminateAddOns());
		Test.stopTest();
		
		addOn = [Select Status__c from Add_On_Service__c];
		
		System.assertEquals('Terminated',addOn.status__c);
	}
	
	@isTest static void testScheduleBatchTerminateAddOns() {
		Id jobId;

		Test.startTest();
			jobId = System.schedule('test job', '0 0 0 * * ?', new ScheduleBatchTerminateAddOns());
		Test.stopTest();

		CronTrigger[] jobs = [Select Id from CronTrigger Where Id = : jobId];

		System.assert(!jobs.isEmpty());

	}
	
	@isTest static void testNoBusinessConfig(){
		Delete [Select Id from Business_Config__c];
		Test.startTest();
			Database.executeBatch(new BatchTerminateAddOns());
		Test.stopTest();
		
		Add_On_Service__c addOn = [Select Status__c from Add_On_Service__c];
		
		System.assertNotEquals('Expired',addOn.status__c);
		System.assertNotEquals('Terminated',addOn.status__c); 
	}
	
	@isTest static void testDisabledBusinessConfig(){
		Business_Config__c b = [Select Business_Rule_Value__c From Business_Config__c Where Business_Rule_Name__c = 'terminateAddOns'];
		b.Business_Rule_Value__c = 'false';
		update b;
		
		Test.startTest();
			Database.executeBatch(new BatchTerminateAddOns());
		Test.stopTest();
		
		Add_On_Service__c addOn = [Select Status__c from Add_On_Service__c];
		
		System.assertNotEquals('Expired',addOn.status__c);
		System.assertNotEquals('Terminated',addOn.status__c); 
	}
	
}