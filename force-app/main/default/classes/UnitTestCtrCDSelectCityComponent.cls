@isTest
private class UnitTestCtrCDSelectCityComponent {

	@isTest static void CtrCDSelectCityComponentBuildCorrectly() {
		Test.startTest();
		CtrCDSelectCityComponent ctr = new CtrCDSelectCityComponent();
		Test.stopTest();
	}

	@isTest static void CtrCDSelectCityComponentGetCitiesReturnsCorrectly() {
		Set<String> res;
		Test.startTest();
		res = CtrCDSelectCityComponent.getCities('IT');
		Test.stopTest();
		System.assertNotEquals(null, res);
	}

}