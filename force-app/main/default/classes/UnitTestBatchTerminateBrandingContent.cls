@isTest
public class UnitTestBatchTerminateBrandingContent {
    
    @testSetup static void setup() {
		Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Branding_Content__c'});
		UnitTestDataFactory.getRecordtypeValues();

		Country__c uk = UnitTestDataFactory.createCountry('UK', 'United Kingdom', 'GBP');
		insert new List<Country__c> {uk};

		Business_Config__c b1 = UnitTestDataFactory.createBusinessConfig('BatchBrandingContentTermination', 'Process', 'terminateBradningContent', 'true', uk.id, 'UK_Branding_Content', true, true);
		Business_Config__c b2 = UnitTestDataFactory.createBusinessConfig('BatchBrandingContentTermination', 'Process', 'expiredStatus', 'Expired', uk.id, 'UK_Branding_Content', true, false);
		Business_Config__c b3 = UnitTestDataFactory.createBusinessConfig('BatchBrandingContentTermination', 'Process', 'terminationStatus', 'Terminated', uk.id, 'UK_Branding_Content', true, false);
		insert new List<sObject> {b1, b2, b3};

		Account acc1 = UnitTestDataFactory.createAccount('BatchTestClassAccount1', uk, 'UK_Account');
		insert new List<Account> {acc1};

		insert new Branding_Content__c(
		    Restaurant_Name__c 	= acc1.Id,
		    RecordTypeId 		= mapRecordtypes.get('UK_Branding_Content').Id,
		    End_Date__c 		= Date.today(),
		    status__c			= 'Installed successfully'
		);

	}
	
	@isTest
	public static void testExpiredStatus(){
		Test.startTest();
			Database.executeBatch(new BatchTerminateBrandingContent());
		Test.stopTest();
		
		Branding_Content__c bc = [Select Status__c from Branding_Content__c];
		
		System.assertEquals('Expired',bc.status__c);
	}
	
	@isTest
	public static void testTerminatedStatus(){
		Branding_Content__c bc 	= [Select Termination_Reason__c from Branding_Content__c];
		bc.Termination_Reason__c = 'test';
		update bc;
		
		Test.startTest();
			Database.executeBatch(new BatchTerminateBrandingContent());
		Test.stopTest();
		
		bc = [Select Status__c from Branding_Content__c];
		
		System.assertEquals('Terminated',bc.status__c);
	}
	
	@isTest static void testScheduleBatchTerminateBrandingContent() {
		Id jobId;

		Test.startTest();
			jobId = System.schedule('test job', '0 0 0 * * ?', new ScheduleBatchTerminateBrandingContent());
		Test.stopTest();

		CronTrigger[] jobs = [Select Id from CronTrigger Where Id = : jobId];

		System.assert(!jobs.isEmpty());

	}
	
	@isTest static void testNoBusinessConfigs(){
		Delete [Select Id from Business_Config__c];
		
		Test.startTest();
			Database.executeBatch(new BatchTerminateBrandingContent());
		Test.stopTest();
		
		Branding_Content__c bc = [Select Status__c from Branding_Content__c];
		
		System.assertNotEquals('Expired',bc.status__c);
		System.assertNotEquals('Terminated',bc.status__c);		
	}
	
	@isTest static void testDisbaledBusinessConfig(){
		Business_Config__c b = [Select Business_Rule_Value__c From Business_Config__c Where Business_Rule_Name__c = 'terminateBradningContent'];
		b.Business_Rule_Value__c = 'false';
		update b;
		
		Test.startTest();
			Database.executeBatch(new BatchTerminateBrandingContent());
		Test.stopTest();
		
		Branding_Content__c bc = [Select Status__c from Branding_Content__c];
		
		System.assertNotEquals('Expired',bc.status__c);
		System.assertNotEquals('Terminated',bc.status__c);	
	}
	
	
}