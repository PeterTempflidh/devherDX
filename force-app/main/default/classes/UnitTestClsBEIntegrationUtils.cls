@isTest
private class UnitTestClsBEIntegrationUtils {

	@testSetup
	static void setup() {
		List<BEIntegration_CountriesToCities__c> confs = new List<BEIntegration_CountriesToCities__c>();

		confs.add(new BEIntegration_CountriesToCities__c(Name = 'Napoli',
		          City_Backend_Id__c = '1',
		          Country_Code__c = 'IT',
		          Country_Backend_Id__c = '1' ));

		confs.add(new BEIntegration_CountriesToCities__c(Name = 'Berlin',
		          City_Backend_Id__c = '1',
		          Country_Code__c = 'DE',
		          Country_Backend_Id__c = '2' ));

		insert confs;
	}

	@isTest static void isValidCityReturnsTrueIfCityIsValid() {
		Boolean res;

		Test.startTest();

		res = ClsBEIntegrationUtils.isValidCity('Napoli', 'IT');

		Test.stopTest();

		System.assert(res);
	}

	@isTest static void isValidCityReturnsFalseIfCityIsNotValid() {
		Boolean res;

		Test.startTest();

		res = ClsBEIntegrationUtils.isValidCity('Roma', 'IT');

		Test.stopTest();

		System.assert(!res);
	}

	@isTest static void isValidCityReturnsFalseIfCountryNotValid() {
		Boolean res;

		Test.startTest();

		res = ClsBEIntegrationUtils.isValidCity('Napoli', 'DE');

		Test.stopTest();

		System.assert(!res);
	}

	@isTest static void getCitiesByCountryCodeReturnAnEMptyListWhenCountryCodeNotFound() {
		Set<String> res;

		Test.startTest();

		res = ClsBEIntegrationUtils.getCitiesByCountryCode('WTF');

		Test.stopTest();

		System.assertNotEquals(null, res);
		System.assert(res.isEmpty());
	}

	@isTest static void getCitiesByCountryCodeReturnAnEMptyListWhenCountryCodeIsNull() {
		Set<String> res;

		Test.startTest();

		res = ClsBEIntegrationUtils.getCitiesByCountryCode(null);

		Test.stopTest();

		System.assertNotEquals(null, res);
		System.assert(res.isEmpty());
	}

	@isTest static void getCitiesByCountryCodeReturnsCorrectly() {

		Set<String> res;

		Test.startTest();

		res = ClsBEIntegrationUtils.getCitiesByCountryCode('IT');

		Test.stopTest();

		System.assert(!res.isEmpty());
		System.assertEquals(1, res.size());
	}
}