@isTest
private class UnitTestBatchPopulateGrid {
	

	@testSetup static void setup() {

		UnitTestDataFactory.getRecordtypeValues();

		Country__c cnt = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
		insert cnt;

		List<Lead> lds = UnitTestDataFactory.createLeads(2, cnt, 'test', 'test', 'USD', 'test', 'CD_Lead');
		insert lds;
	}

	@isTest static void batchPopulateGridCorrectly() {
		Test.startTest();
		Database.executeBatch(new BatchPopulateGrid('Lead'));
		Test.stopTest();

		for (Lead ld: [SELECT GRID__c FROM Lead]) {
			System.assert(String.isNotBlank(ld.GRID__c));
		}
	}
}