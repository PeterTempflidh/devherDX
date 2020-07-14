@isTest
private class UnitTestProductAndServiceProcessor {

    private static User testUser;
    private static Country__c country;
    private static Company__c company;
    private static List<List_Product_Group__c> productGroups;
    private static List<List_Product_Price__c> products;
    private static List<List_Service_Price__c> services;
    private static List<Tarif__c> tarifsInactive;
    private static List<Tarif__c> tarifsActive;
    private static List<Tarif_Member__c> tarifMembersForServices;
    private static List<Tarif_Member__c> tarifMembersForProducts;
    private static List<Tarif_Member__c> tarifMembersForServicesInactive;

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

            productGroups = UnitTestDataFactory.createProductGroups(company, country, 1, 'Yogiyo_List_Product_Group');
            tarifsInactive = UnitTestDataFactory.createTarifs(company, country, 1, 'Yogiyo_Tarif', false);
            tarifsActive = UnitTestDataFactory.createTarifs(company, country, 1, 'Yogiyo_Tarif', false);
            services = UnitTestDataFactory.createServices(company, country, 1, 'Yogiyo_List_Service_Price', 13, 13, 15, 10, 1, '% per Order', true, 299, 'Monthly', 'Commission', 'ServiceType');
            List<Account> accts = UnitTestDataFactory.createAccounts(1, country, 'Yogiyo_Account');

            List<sObject> objectsToInsert2 = new List<sObject>();
            objectsToInsert2.addAll((List<sObject>)productGroups);
            objectsToInsert2.addAll((List<sObject>)tarifsInactive);
            objectsToInsert2.addAll((List<sObject>)tarifsActive);
            objectsToInsert2.addAll((List<sObject>)services);
            objectsToInsert2.addAll((List<sObject>)accts);
            insert objectsToInsert2;

            /*Set<Id> tarifId = new Set<Id>();
            for(Tarif__c tarif : tarifsActive){
                tarifId.add(tarif.Id);
            }
            tarifsActive.clear();
            tarifsActive = [SELECT Id, Name, Is_Active__c FROM Tarif__c WHERE Id IN: tarifId];*/

            products = UnitTestDataFactory.createProducts(company, country, productGroups[0].Id, 10, 'Yogiyo_List_Product_Price', 1, true, 299, 1, true, 10);   
            tarifMembersForServices = UnitTestDataFactory.createTarifMembers(services[0].Id, 201, 'Yogiyo_Tarif_Member', tarifsInactive[0].Id, 'Service');
            tarifMembersForProducts = UnitTestDataFactory.createTarifMembers(products[0].Id, 201, 'Yogiyo_Tarif_Member', tarifsInactive[0].Id, 'Product');

            List<sObject> objectsToInsert3 = new List<sObject>();
            objectsToInsert3.addAll((List<sObject>)products);
            objectsToInsert3.addAll((List<sObject>)tarifMembersForServices);
            objectsToInsert3.addAll((List<sObject>)tarifMembersForProducts);
            insert objectsToInsert3;
        }
    }
    
    @isTest static void test_validateServiceOrProductDeactivationInactiveTariff() {
        Test.startTest();

        Set<Id> tarifMemberIds = new Set<Id>();
        Set<Id> tarifMemberIdsThatCanBeDeleted = new Set<Id>();

        for(Tarif_Member__c tm : tarifMembersForServices){
            tarifMemberIds.add(tm.Id);
        }
        for(Tarif_Member__c tm : tarifMembersForProducts){
            tarifMemberIds.add(tm.Id);
        }

        System.runAs(testUser){
            tarifMemberIdsThatCanBeDeleted = ProductAndServiceProcessor.validateServiceOrProductDeactivation(tarifMemberIds);
        }

        System.assertEquals(0, tarifMemberIdsThatCanBeDeleted.size());

        Test.stopTest();
    }
    
    @isTest static void test_validateServiceOrProductDeactivationActiveTariff() {
        Test.startTest();

        tarifsInactive[0].Is_Active__c = true;
        update tarifsInactive;

        Set<Id> tarifMemberIds = new Set<Id>();
        Set<Id> tarifMemberIdsThatCanBeDeleted = new Set<Id>();

        for(Tarif_Member__c tm : tarifMembersForServices){
            tarifMemberIds.add(tm.Id);
        }
        for(Tarif_Member__c tm : tarifMembersForProducts){
            tarifMemberIds.add(tm.Id);
        }

        Map<Id, Tarif_Member__c> tarifMembers = new Map<Id, Tarif_Member__c>([SELECT Id, Id_Tarif_Item__c, Name, Tarif_Name__c, Tarif_Name__r.Is_Active__c FROM Tarif_Member__c WHERE Id IN: tarifMemberIds]);
        System.runAs(testUser){
            tarifMemberIdsThatCanBeDeleted = ProductAndServiceProcessor.validateServiceOrProductDeactivation(tarifMembers.keySet());
        }
        System.assertEquals(0, tarifMemberIdsThatCanBeDeleted.size());

        Test.stopTest();
    }

    @isTest static void test_ListProductPriceTriggerTest() {
        
        Test.startTest();

        tarifsInactive[0].Is_Active__c = true;
        update tarifsInactive;

        List<List_Product_Price__c> productsToUpdate = new List<List_Product_Price__c>();
        for(List_Product_Price__c lpp: products){
            lpp.Is_Active__c = false;
            productsToUpdate.add(lpp);
        }
        System.runAs(testUser){
            upsert productsToUpdate;
        }

        Test.stopTest();
    }

    @isTest static void test_ListServiceTriggerTest() {
        Test.startTest();

        List<List_Service_Price__c> servicesToUpdate = new List<List_Service_Price__c>();
        Set<Id> serviceIds = new Set<Id>();
        Set<Id> tarifMemberIdsThatCanBeDeleted = new Set<Id>();

        for(List_Service_Price__c service: services){
            service.Is_Active__c = false;
            serviceIds.add(service.Id);
            servicesToUpdate.add(service);
        }
        System.runAs(testUser){
            upsert servicesToUpdate;
        }

        Test.stopTest();
    }
}