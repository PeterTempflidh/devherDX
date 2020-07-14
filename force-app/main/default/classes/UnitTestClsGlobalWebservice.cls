@isTest
private class UnitTestClsGlobalWebservice {


	private static List<Account> accs;
	private static List<Contact> cts;

	@testSetup static void setup() {
		UnitTestDataFactory.getRecordtypeValues();
	}

	static void setupUserData(User u) {
		Country__c countryUK = UnitTestDataFactory.createCountry('UK', 'United Kingdom', 'GBP');
		insert new List<sObject> {countryUK};

		System.runAs(u) {
			accs = UnitTestDataFactory.createAccounts(1, countryUK, 'UK_Account');
			insert accs;
			List<Opportunity> opportunitiesUK = UnitTestDataFactory.createOpportunities(accs, 1, 'UK_Opportunity', Date.today().addMonths(2));
			insert opportunitiesUK;
			Case csss = UnitTestDataFactory.createCase(accs[0], 'New', 'Quality Check', 'Email', 'Email', countryUK, 'UK_Internal_Case', 'test');
			insert csss;
			cts = UnitTestDataFactory.createContacts(accs, 'test name', 'teste name', 'Mr', 'Owner', 1, null, 'UK_Contact');
			insert cts;
		}
	}

	@isTest static void test_method_one() {
		User testUserUK = UnitTestDataFactory.createUser('System Administrator', 'ukuser@deliveryhero.com', 'Hungryhouse', 'UK');
		Test.startTest();
		System.runAs(testUserUK) {
			setupUserData(testUserUK);
			ClsGlobalWebservice zz = new ClsGlobalWebservice();
			ClsGlobalWebservice.getTaskRecordType(accs[0].Id);
			ClsGlobalWebservice.getTaskRecordType(cts[0].Id);
			ClsGlobalWebservice.getTaskRecordType('oijkdbn2312323');
		}

		Test.stopTest();
	}



}