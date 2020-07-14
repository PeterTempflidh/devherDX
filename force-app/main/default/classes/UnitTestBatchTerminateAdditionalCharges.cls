@isTest
private class UnitTestBatchTerminateAdditionalCharges {

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

	@isTest static void batchTerminateAdditionalChargesDoesNothingIfNoBusinessConfigs() {
		delete [select id from Business_Config__c];

		Additional_Charges__c ad = [Select Id From Additional_Charges__c limit 1];

		Test.startTest();

		Database.executeBatch(new BatchTerminateAdditionalCharges());

		Test.stopTest();

		ad = [Select Status__c From Additional_Charges__c Where Id = : ad.Id];

		System.assertNotEquals('Terminated', ad.Status__c);
	}

	@isTest static void batchTerminateAdditionalChargesDoesNothingIfNoBusinessLogic() {
		List<Business_Config__c> rules = [Select Record_Type_Id__c From Business_Config__c];
		for (Business_Config__c b : rules) {
			b.Record_Type_Id__c = 'Whatever';
		}
		update rules;

		Additional_Charges__c ad = [Select Id from Additional_Charges__c limit 1];

		Test.startTest();

		Database.executeBatch(new BatchTerminateAdditionalCharges());

		Test.stopTest();

		ad = [Select Status__c From Additional_Charges__c Where Id = : ad.id];

		System.assertNotEquals('Terminated', ad.Status__c);
	}

	@isTest static void batchTerminateAdditionalChargesDoesNothingIfConfigFlagIsFalse() {
		Business_Config__c b = [Select Business_Rule_Value__c From Business_Config__c Where Business_Rule_Name__c = 'terminateExpiredAdditionalCharges'];
		b.Business_Rule_Value__c = 'false';
		update b;

		Additional_Charges__c ad = [Select Id From Additional_Charges__c limit 1];

		Test.startTest();

		Database.executeBatch(new BatchTerminateAdditionalCharges());

		Test.stopTest();

		ad = [Select Status__c From Additional_Charges__c where id = : ad.Id];

		System.assertNotEquals('Terminated', ad.Status__c);
	}

	@isTest static void batchTerminateAdditionalChargesUpdatesExpiredAdditionalChargesCorrectly() {
		Additional_Charges__c ad = [Select Id From Additional_Charges__c limit 1];

		Test.startTest();

		Database.executeBatch(new BatchTerminateAdditionalCharges());

		Test.stopTest();

		ad = [Select Status__c, Termination_Reason__c From Additional_Charges__c where id = :ad.Id];

		System.assertEquals('Charged', ad.Status__c);
		System.assertEquals('Other', ad.Termination_Reason__c);
	}
	
	@isTest static void batchTerminateAdditionalChargesUpdatesExpiredAdditionalChargesCorrectly2() {
		Additional_Charges__c ad = [Select Id,Termination_Reason__c From Additional_Charges__c limit 1];
		ad.Termination_Reason__c = 'test';
		update ad;
		
		Test.startTest();

		Database.executeBatch(new BatchTerminateAdditionalCharges());

		Test.stopTest();

		ad = [Select Status__c, Termination_Reason__c From Additional_Charges__c where id = :ad.Id];

		System.assertEquals('Terminated', ad.Status__c);
	}
}