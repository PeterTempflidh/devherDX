@isTest
private class UnitTestCtrServiceManager {

    private static User testUser;
    private static Country__c country;
    private static Company__c company;
    private static List<List_Service_Price__c> services;
    private static List<Opportunity_Service_Item__c> opi;
    
    static {
        testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'yogiyounittestuser@deliveryhero.com', 'Yogiyo', 'KR');
        insert testUser;
        List<Platform_Country__c> platformCountry =new List<Platform_Country__c>(); 
        platformCountry.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name='FOCPlatform', country__c='Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
        UnitTestDataFactory.getRecordtypeValues();
        System.runAs(testUser){
            country = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            insert country;

            company = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', country);
            insert company;


            Business_Config__c smcBusinesConfigService = UnitTestDataFactory.createBusinessConfig('SalesManagementProcessService', 'Process', 'useServiceTypes', 'false', country.Id, 'Yogiyo_List_Service_Price', true, true);
            Business_Config__c smcBusinesConfigService2 = UnitTestDataFactory.createBusinessConfig('SalesManagementProcessService', 'Process', 'showCommissionPerOrder', 'true', country.Id, 'Yogiyo_List_Service_Price', true, true);
            Business_Config__c smcBusinesConfigService3 = UnitTestDataFactory.createBusinessConfig('SalesManagementProcessService', 'Process', 'showRequiresApprovalSwitch', 'true', country.Id, 'Yogiyo_List_Service_Price', true, true);
            Business_Config__c smcBusinesConfigProduct = UnitTestDataFactory.createBusinessConfig('SalesManagementProcessProducts', 'Process', 'useProductTypes', 'false', country.Id, 'Yogiyo_List_Service_Price', true, true);
            insert new List<sObject>{smcBusinesConfigService,smcBusinesConfigService2,smcBusinesConfigService3,smcBusinesConfigProduct};
            services = UnitTestDataFactory.createServices(company, country, 10, 'Yogiyo_List_Service_Price', 13, 13, 15, 10, 1, '% per Order', true, 299, 'Monthly', 'Commission', 'ServiceType');
            List<Account> accts = UnitTestDataFactory.createAccounts(1, country, 'Yogiyo_Account');

            List<sObject> objectsToInsert2 = new List<sObject>();
            objectsToInsert2.addAll((List<sObject>)services);
            objectsToInsert2.addAll((List<sObject>)accts);
            insert objectsToInsert2;

            List<Opportunity> opps = UnitTestDataFactory.createOpportunities(accts, 1, 'Yogiyo_Opportunity', Date.today().addMonths(2));
            insert opps;
            
            opi = UnitTestDataFactory.createOpportunityServiceItems(opps[0], services[0].Id, 1, false, 'Yogiyo_Opportunity_Service_Item', 13, 1, Date.today(), 'Commission', 299);
            insert opi;
        }
    }
    //SP-682
    @isTest static void test_showApprovalRequiredButton(){
        Test.startTest();

        CtrserviceManager sm;

        System.runAs(testUser){
            sm = new CtrserviceManager();
        }

        Test.stopTest();
    }

    @isTest static void test_Variables() {

        Test.startTest();

        CtrserviceManager sm;

        System.runAs(testUser){
            sm = new CtrserviceManager();
        }

        Test.stopTest();

        System.assertEquals(sm.listServices.size(), 10);
        System.assertEquals(sm.mapMyServices.size(), 10);
        System.assertEquals(sm.myService.Commission_Type__c,'Percentage');
    }

    @isTest static void test_AddService() {

        Test.startTest();

        CtrserviceManager sm;

        System.runAs(testUser){

            sm = new CtrserviceManager();
            // Adding a service without a name will failed
            sm.addService();
        
            System.assertEquals(sm.listServices.size(), 10);
            System.assertEquals(sm.mapMyServices.size(), 10);


            // Adding with the name
            sm.myService.Name = 'Test Service';
            sm.addService();

        }
        Test.stopTest();

        System.assertEquals(sm.listServices.size(), 11);
        System.assertEquals(sm.mapMyServices.size(), 11);
    }
    
    @isTest static void test_EditService() {
        Test.startTest();

        CtrserviceManager sm;

        System.runAs(testUser){

            sm = new CtrserviceManager();
            sm.serviceId = services[0].Id;
            sm.editItem();
            sm.myService.Name = 'TEST';
            sm.addService();
        }
        Test.stopTest();

        List<List_Service_Price__c> services_1 = [SELECT Id ,Is_Active__c, Name,Commission_In_Percentage__c,Commission_Per_Order__c,Default_Commission_In_Percentage__c ,Maximum_Commission_In_Percentage__c,Minimum_Commission_in_Percentage__c,Type__c, Recurring_Fee__c,Recurring_Interval__c, Id_Country__c, Company__c, CurrencyIsoCode
                        FROM List_Service_Price__c];
        System.assertEquals(services_1.size(), 10);
        System.assertEquals(services_1[0].Name, 'TEST');
    }
    
    @isTest static void test_DeleteService() {
        Test.startTest();

        CtrserviceManager sm;

        System.runAs(testUser){

            sm = new CtrserviceManager();
            sm.serviceId = services[0].Id;
            sm.chooseServiceToDelete();
            sm.deleteItem();

            // Deleting an active service should fail
            System.assertEquals(sm.listServices.size(), 10);
            System.assertEquals(sm.mapMyServices.size(), 10);

            delete opi;
            sm.deleteItem();

            // Can now be deleted since the opportunity service item has been deleted.
            System.assertEquals(sm.listServices.size(), 9);
            System.assertEquals(sm.mapMyServices.size(), 9);

            sm.cancel();
            System.assertEquals(sm.myService.Commission_Type__c,'Percentage');
        }
        Test.stopTest();
    }
}