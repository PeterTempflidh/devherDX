@isTest
private class UnitTestLibWebserviceHelper {
	
	@isTest static void test_method_one() {
		// Implement test code
		Test.startTest();
		LibWebserviceHelper.createBillingAuthenticationHeader('Post','http://testitforfree.com','{"body":"test"}');
		LibWebserviceHelper.extractIdFromURI('param','parama2');
		Test.stopTest();
	}
		
}