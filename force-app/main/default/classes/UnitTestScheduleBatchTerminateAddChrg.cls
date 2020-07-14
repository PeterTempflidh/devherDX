@isTest
private class UnitTestScheduleBatchTerminateAddChrg {

	@testSetup static void setup() {
		Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Additional_Charges__c'});
		UnitTestDataFactory.getRecordtypeValues();

		Country__c bh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
		insert new List<Country__c> {bh};

		Business_Config__c b1 = UnitTestDataFactory.createBusinessConfig('BatchTerminateAdditionalCharges', 'Process', 'terminateExpiredAdditionalCharges', 'true', bh.id, 'Talabat_Additional_Charges', true, true);
		Business_Config__c b2 = UnitTestDataFactory.createBusinessConfig('BatchTerminateAdditionalCharges', 'Process', 'terminationStatus', 'Terminated', bh.id, 'Talabat_Additional_Charges', true, false);
		Business_Config__c b3 = UnitTestDataFactory.createBusinessConfig('BatchTerminateAdditionalCharges', 'Process', 'chargedStatus', 'Charged', bh.id, 'Talabat_Additional_Charges', true, false);
		Business_Config__c b4 = UnitTestDataFactory.createBusinessConfig('BatchTerminateAdditionalCharges', 'Process', 'terminationReason', 'Other', bh.id, 'Talabat_Additional_Charges', true, false);
		insert new List<sObject> {b1, b2, b3, b4};

		Account acc1 = UnitTestDataFactory.createAccount('BatchTestClassAccount1', bh, 'Talabat_Account');
		insert new List<Account> {acc1};

		insert new Additional_Charges__c(
		    Id_Account__c = acc1.Id,
		    RecordTypeId = mapRecordtypes.get('Talabat_Additional_Charges').Id,
		    Termination_Date__c = Date.today()
		);
	}

	@isTest static void scheduleBatchTerminateAdditionalChargesWorkCorreclty() {
		Id jobId;

		Test.startTest();
		jobId = System.schedule('test job', '0 0 0 * * ?', new ScheduleBatchTerminateAdditionalCharges());
		Test.stopTest();

		CronTrigger[] jobs = [Select Id from CronTrigger Where Id = : jobId];

		System.assert(!jobs.isEmpty());

	}

}