@isTest
private class UnitTestClsWebserviceCalloutAdSalesKR {

	private static User testUser_kr = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'yogiyotestuser@deliveryhero.com', 'Yogiyo','KR');
	private static Country__c testCountry_kr;
	private static Company__c testCompany_kr;


	//KR testdata
    static {
    	insert testUser_kr;
    	System.runAs(testUser_kr){
    		testCountry_kr = UnitTestDataFactory.createCountry('KR','Korea','KRW');
			insert testCountry_kr;

			testCompany_kr = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', testCountry_kr);
			insert testCompany_kr;

			testUser_kr.CountryCode__c = 'KR';
			testUser_kr.Company_Name__c = 'Yogiyo';
			update testUser_kr;
			Integration_Config__c iconfig = new Integration_Config__c(Name = 'KR_YogiyoBackend',
					Endpoint__c='https://www.yogiyo.co.kr/salesforce/restaurant/',
					ClientId__c='salesforce', ClientSecret__c='salesforceSecret');
			Integration_Config__c iconfig1 = new Integration_Config__c(Name = 'KR_YogiyoBackend_STG',
					Endpoint__c='https://www.yogiyo.co.kr/salesforce/restaurant/',
					ClientId__c='salesforce', ClientSecret__c='salesforceSecret');

			insert new List<SObject>{iconfig,iconfig1};

    	}
    }
    @isTest static void getFixAmountCommissionDistricts_Pass(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebserviceAdSalesKR());
        
        FixedCommissionWrapper wrapper = ClsWebserviceCalloutAdSalesKR.getFixAmountCommissionDistricts('4712');
        
        Test.stopTest();
        
        System.assertNotEquals(null, wrapper.mapCategories);
        System.assertNotEquals(null, wrapper.mapDistricts);
        System.assertNotEquals(null, wrapper.mapDistrictPrices);
    }
	
	@isTest static void getAvailableDistrictsAndCategories_Pass() {

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new UnitTestMockWebserviceAdSalesKR());

		DistrictPriceCategoryWrapper wrapper = ClsWebserviceCalloutAdSalesKR.getAvailableDistrictsAndCategories('0815');

		Test.stopTest();

		System.assertEquals(false,wrapper.errorFlag);
		System.debug('wrapper.mapCategories: '+wrapper.mapCategories);
		System.assertNotEquals(null, wrapper.mapCategories);
		System.assertNotEquals(null, wrapper.mapDistricts);
		System.assertNotEquals(null, wrapper.mapDistrictPrices);
		System.assertNotEquals(null, wrapper.mapTypeDistricts);


	}

	@isTest static void getAvailableDistrictsAndCategories_Pass_Decimal_Amounts() {

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new UnitTestMockWebserviceAdSalesKR());

		DistrictPriceCategoryWrapper wrapper = ClsWebserviceCalloutAdSalesKR.getAvailableDistrictsAndCategories('0816');

		Test.stopTest();

		System.assertEquals(false,wrapper.errorFlag);
		System.debug('wrapper.mapCategories: '+wrapper.mapCategories);
		System.assertNotEquals(null, wrapper.mapCategories);
		System.assertNotEquals(null, wrapper.mapDistricts);
		System.assertNotEquals(null, wrapper.mapDistrictPrices);
		System.assertNotEquals(null, wrapper.mapTypeDistricts);

		System.assertEquals(50000.00, wrapper.mapDistrictPrices.get('Super-4006'));


	}
	
	@isTest static void getAvailableDistrictsAndCategories_Fail() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new UnitTestMockWebserviceAdSalesKR());

		DistrictPriceCategoryWrapper wrapper = ClsWebserviceCalloutAdSalesKR.getAvailableDistrictsAndCategories('4711');

		Test.stopTest();

		System.assertEquals(true,wrapper.errorFlag);
		System.assertEquals(Label.AdSalesKR404,wrapper.errorMessage);
		
	}

	@isTest static void getAvailableDistrictsAndCategories_Incomplete() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new UnitTestMockWebserviceAdSalesKR());

		DistrictPriceCategoryWrapper wrapper = ClsWebserviceCalloutAdSalesKR.getAvailableDistrictsAndCategories('0021');

		Test.stopTest();

		System.assertEquals(true,wrapper.errorFlag);
		System.assertEquals(Label.AdSalesKRIncomplete,wrapper.errorMessage);
		
	}

	@isTest static void getAvailableDistrictsAndCategories_Incomplete_null() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new UnitTestMockWebserviceAdSalesKR());

		DistrictPriceCategoryWrapper wrapper = ClsWebserviceCalloutAdSalesKR.getAvailableDistrictsAndCategories('0022');

		Test.stopTest();

		System.assertEquals(true,wrapper.errorFlag);
		System.assertEquals(Label.AdSalesKRException,wrapper.errorMessage);
		
	}

	@isTest static void getAvailableDistrictsAndCategories_no_basic_category() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new UnitTestMockWebserviceAdSalesKR());

		DistrictPriceCategoryWrapper wrapper = ClsWebserviceCalloutAdSalesKR.getAvailableDistrictsAndCategories('0023');

		Test.stopTest();

		System.assertEquals(false,wrapper.errorFlag);
		System.assertNotEquals(null, wrapper.mapCategories);
		System.assertNotEquals(null, wrapper.mapDistricts);
		System.assertNotEquals(null, wrapper.mapDistrictPrices);
		System.assertNotEquals(null, wrapper.mapTypeDistricts);

		System.assertEquals(null, wrapper.mapDistrictPrices.get('Basic-4006'));
		System.assertEquals(50000,wrapper.mapDistrictPrices.get('Super-4006'));
		
	}

	@isTest static void getAvailableDistrictsAndCategories_no_super_category() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new UnitTestMockWebserviceAdSalesKR());

		DistrictPriceCategoryWrapper wrapper = ClsWebserviceCalloutAdSalesKR.getAvailableDistrictsAndCategories('0024');

		Test.stopTest();

		System.assertEquals(false,wrapper.errorFlag);
		System.assertNotEquals(null, wrapper.mapCategories);
		System.assertNotEquals(null, wrapper.mapDistricts);
		System.assertNotEquals(null, wrapper.mapDistrictPrices);
		System.assertNotEquals(null, wrapper.mapTypeDistricts);

		System.assertEquals(30000, wrapper.mapDistrictPrices.get('Basic-4006'));
		System.assertEquals(null,wrapper.mapDistrictPrices.get('Super-4006'));
		
	}
	
}