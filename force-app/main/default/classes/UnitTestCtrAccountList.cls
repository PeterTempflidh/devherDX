@isTest
private class UnitTestCtrAccountList {

    private static User runningUser = UnitTestDataFactory.createUser('System Administrator', 'testUser@deliveryhero.com', 'UK', 'UK');

    static Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Case'});
    private static Account acc_uk;
    private static Country__c c_uk;
    private static USerRole ur;
    private static Company__c com_uk;


    @testSetup static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
        List<MidasIntegration__c> midasIntg = new List<MidasIntegration__c>();
        midasIntg.add(new MidasIntegration__c(name = 'PP', EndPoint__c = 'http://midas.medusa-hero.com/backend/', AuthenticationToken__c = 'WyI0IiwiYzUwNjRkMmQ2MWUwNTE3YjVhNjRmMTk4Yjc2NmFiODgiXQ.CgtJbA.kFY4BLsKd3XXiXg7QtVxmLqZ7i0', countrybrand__c='{"United Kingdom":"UKHH", "Kuwait":"KWTB"}'));
        insert midasIntg;
        
        List<CountryCompanyBrand__c> countryBrandSettings = new List<CountryCompanyBrand__c>();

        CountryCompanyBrand__c config2 = new CountryCompanyBrand__c();
        config2.name = 'United Kingdom';
        config2.code__c = 'UKHH';
        countryBrandSettings.add(config2);
        
        CountryCompanyBrand__c config3 = new CountryCompanyBrand__c();
        config3.name = 'Kuwait';
        config3.code__c = 'KWTB';
        countryBrandSettings.add(config3);
        
        insert countryBrandSettings;
    }

    static void setupUserData() {
        c_uk = UnitTestDataFactory.createCountry('UK', 'United Kingdom', 'GBP');
        com_uk = UnitTestDataFactory.createCompany('hungryhouse', 'UK', c_uk);
        insert new List<sObject> {c_uk, com_uk};
        acc_uk = UnitTestDataFactory.createAccount('TestAccount', c_uk, 'UK_Account');
        acc_uk.Backend_ID__c = '2266';
        acc_uk.record_country__c='United Kingdom';
        insert new List<sObject> {acc_uk};
        
        CountryCompanyBrand__c config = new CountryCompanyBrand__c();
        config.name = 'hungryhouse';
        config.code__c = 'UKHH';
        insert config;
    }

    @isTest static void test_AccountList() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        System.runAs(runningUser) {
            setupUserData();

            CtrAccountList.DataWrapper result = CtrAccountList.loadAccountList(true, 'UK Sales Management','United Kingdom',null,null);

            System.debug('result: ' + result);
            //System.assertEquals(result.contains('restaurant_id'));
        }
        Test.stopTest();
    }
	
	 @isTest static void test_AccountListContinuation() {
        Test.startTest();
        System.runAs(runningUser) {
            setupUserData();
            CtrAccountList controller = new CtrAccountList();
	        Continuation conti = (Continuation)CtrAccountList.loadAccountListContinuation(true, 'UK Sales Management','United Kingdom');

	        // Perform mock callout
	        // (i.e. skip the callout and call the callback method)
	        HttpResponse response = new HttpResponse();
	        response.setBody('{"data":{"restaurants":[{"status":"Open","sf_restaurant_id":"001w000001TvGJyAAN","name":"Delhi On The Go","ownership_reason":"manual_assignment","rating":0,"postcode":"SW184NJ","owner":"taha.holawala@deliveryhero.com","id":29401},{"status":"Not eligible","sf_restaurant_id":"001w000001gjhn9AAA","name":"Papa Johns","ownership_reason":"manual_assignment","rating":0,"postcode":"CF146PD","owner":"taha.holawala@deliveryhero.com","id":38780}]}}');
	        // Set the fake response for the continuation
        	Test.setContinuationResponse('test', response);
	        // Invoke callback method
	        //Object result = Test.invokeContinuationMethod(controller, conti);
	        List<String> state = new List<String>{'test'};
			CtrAccountList.processContinuationResponse(state);
        }
        Test.stopTest();
    }
	
    @isTest static void test_createOpp() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        System.runAs(runningUser) {
            setupUserData();
            Tarif__c t = UnitTestDataFactory.createTarif(com_uk, c_uk, 'Premium Placement', 'UK_Tarif', false);
            insert t;


            String result = CtrAccountList.createOpportunity(acc_uk.Id);

            Opportunity Opp = [select id, Record_Country__c from Opportunity where id = :result];
            //System.assertNotEquals(Opp,null);
        }
        Test.stopTest();
    }


    @isTest static void test_getOppLines() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        System.runAs(runningUser) {
            setupUserData();
            Tarif__c t = UnitTestDataFactory.createTarif(com_uk, c_uk, 'Premium Placement', 'UK_Tarif', false);
            List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com_uk, c_uk, 'Premium Placement', 'UK_List_Product_Group');
            insert new List<sObject> {lpg, t};
            List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com_uk, c_uk, 'Premium Placement', lpg.id, 'UK_List_Product_Price', 1, true, 100, 1, false, 20);
            insert lpp;
            Opportunity opp = UnitTestDataFactory.createOpportunity('TestOppUK', acc_uk, 'UK_Opportunity', Date.today());
            //opp.Record_Country__c='United Kingdom';
            insert opp;
            Opportunity_Line_Item__c oppProduct = UnitTestDataFactory.createOpportunityLineItemProduct('Premium Placement', opp, lpg.id, lpp.id, true, 'UK_Opportunity_Line_Item', 1, '', 50, 1, 50, 'Premium Placement');
            oppProduct.Booking_Api_Id__c = '58983';
            insert oppProduct;


            String result1 = CtrAccountList.getOppLineItems(null, '58983','United Kingdom');
            //List<Opportunity_Line_Item__c> opplines1 = (List<Opportunity_Line_Item__c>) JSON.deserialize(result1, List<Opportunity_Line_Item__c>.class);
            String result2 = CtrAccountList.getOppLineItems('2266', null,'United Kingdom');
            //List<Opportunity_Line_Item__c> opplines2 = (List<Opportunity_Line_Item__c>) JSON.deserialize(result2, List<Opportunity_Line_Item__c>.class);
            String result3 = CtrAccountList.getOppLineItems('2266,2266', null,'United Kingdom');
            //List<Opportunity_Line_Item__c> opplines3 = (List<Opportunity_Line_Item__c>) JSON.deserialize(result2, List<Opportunity_Line_Item__c>.class);
            String result4 = CtrAccountList.getOppLineItems(null, '58983,58984','United Kingdom');
            //List<Opportunity_Line_Item__c> opplines4 = (List<Opportunity_Line_Item__c>) JSON.deserialize(result2, List<Opportunity_Line_Item__c>.class);

            //System.assertEquals(opplines1.size(),1);
            //System.assertEquals(opplines2.size(),1);
        }
        Test.stopTest();
    }


    @isTest static void test_cancelBookings() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        System.runAs(runningUser) {
            setupUserData();
            Tarif__c t = UnitTestDataFactory.createTarif(com_uk, c_uk, 'Premium Placement', 'UK_Tarif', false);
            List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com_uk, c_uk, 'Premium Placement', 'UK_List_Product_Group');
            insert new List<sObject> {lpg, t};
            List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com_uk, c_uk, 'Premium Placement', lpg.id, 'UK_List_Product_Price', 1, true, 100, 1, false, 20);
            insert lpp;
            Opportunity opp = UnitTestDataFactory.createOpportunity('TestOppUK', acc_uk, 'UK_Opportunity', Date.today());
            insert opp;
            Opportunity_Line_Item__c oppProduct = UnitTestDataFactory.createOpportunityLineItemProduct('Premium Placement', opp, lpg.id, lpp.id, true, 'UK_Opportunity_Line_Item', 1, '', 50, 1, 50, 'Premium Placement');
            oppProduct.Booking_Api_Id__c = '58983';
            insert oppProduct;


            String result = CtrAccountList.cancelBookings(new List<CtrAccountList.Bookings> {new CtrAccountList.Bookings('58983', oppProduct.id,'hungryhouse')}, 'UK Sales Management', 'test@deliveryhero.com','United Kingdom',false);

            //System.assertEquals(result,'success');
        }
        Test.stopTest();
    }


    @isTest static void test_loadPPSlots() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        System.runAs(runningUser) {
            setupUserData();


            String result = CtrAccountList.loadPPSlots('CM18', 'UK Sales Management', '2016', '8','United Kingdom');
            String result2 = CtrAccountList.loadPPSlots(null, 'UK Sales Management', '2016', '8','United Kingdom');

            System.debug('result: ' + result);
            //System.assert(result.contains('status'));
        }
        Test.stopTest();
    }

    @isTest static void test_loadPPAccounts() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        System.runAs(runningUser) {
            setupUserData();


            String result = CtrAccountList.loadPPAccounts('N1', 'UK Sales Management', false, '2016-08-08','United Kingdom');
            String result2 = CtrAccountList.loadPPAccounts('N1', 'UK Sales Management', true, '2016-08-10','United Kingdom');
            String result3 = CtrAccountList.loadPPAccounts(null, 'UK Sales Management', true, '2016-08-09','United Kingdom');


            System.debug('result: ' + result);
            //System.assert(result.contains('sf_restaurant_id'));
        }
        Test.stopTest();
    }
    
    @isTest static void test_loadPPAccountsContinuation() {
        Test.startTest();
        System.runAs(runningUser) {
            setupUserData();

            CtrAccountList controller = new CtrAccountList();
	        Continuation conti = (Continuation)CtrAccountList.loadPPAccountsConitnuation('N1', 'UK Sales Management', false, '2016-08-08','United Kingdom');

	        // Perform mock callout
	        // (i.e. skip the callout and call the callback method)
	        HttpResponse response = new HttpResponse();
	        response.setBody('{"data":{"restaurants":[{"status":"Open","sf_restaurant_id":"001w000001TvGJyAAN","name":"Delhi On The Go","ownership_reason":"manual_assignment","rating":0,"postcode":"SW184NJ","owner":"taha.holawala@deliveryhero.com","id":29401},{"status":"Not eligible","sf_restaurant_id":"001w000001gjhn9AAA","name":"Papa Johns","ownership_reason":"manual_assignment","rating":0,"postcode":"CF146PD","owner":"taha.holawala@deliveryhero.com","id":38780}]}}');
	        // Set the fake response for the continuation
        	Test.setContinuationResponse('test', response);
	        // Invoke callback method
	        //Object result = Test.invokeContinuationMethod(controller, conti);
	        List<String> state = new List<String>{'test'};
			CtrAccountList.processContinuationResponse(state);
        }
        Test.stopTest();
    }
    
    @isTest static void testGetCountryPerCurrentUser(){
        List<String> countries;
        Test.startTest();
            System.runAs(runningUser){
                setupUserData();
                countries = CtrAccountList.getCountryPerCurrentUser();
            }
        Test.stoptest();
        
        System.assertEquals(countries.size(), 1);
    }

    /*******************************************************************************************************
   * @description Tests restaurant data population on Data object when passing GRID__c in restaurant data as sf_id. Grid__c
   * value should be replaced by actual sObject id.
   */
    @isTest
    static void testDataRestaurantPopulation() {
        List<CtrAccountList.Restaurant> restaurants = new List<CtrAccountList.restaurant>();
        CtrAccountList.Data data = new CtrAccountList.Data();
        Country__c country = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        insert country;
        List<Account> accounts = UnitTestDataFactory.createAccounts(5, country, 'Yogiyo_Account');
        insert accounts;
        Map<Id, Account> accountIdMap = new Map<Id, Account>(accounts);
        for(Account account: accounts) {
            CtrAccountList.Restaurant restaurant = new CtrAccountList.Restaurant();
            restaurant.sf_restaurant_id = account.GRID__c;
            restaurants.add(restaurant);
        }
        data.populateRestaurants(restaurants);
        for(CtrAccountList.Restaurant restaurant: data.restaurants) {
            System.assert(accountIdMap.containsKey(restaurant.sf_restaurant_id), 'Error converting restaurant Ids');
        }

    }

}
