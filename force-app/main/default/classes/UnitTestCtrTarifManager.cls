@isTest
private class UnitTestCtrTarifManager {
    
    private static User testUser;
    private static Country__c country;
    private static Company__c company;
    private static List<List_Product_Group__c> productGroups;
    private static List<List_Product_Price__c> products;
    private static List<List_Service_Price__c> services;
    private static List<List_Add_On__c> addOns;
    private static List<Tarif__c> tarifs;

    static {
        testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'yogiyounittestuser@deliveryhero.com', 'Yogiyo', 'KR');
        insert testUser;
        UnitTestDataFactory.getRecordtypeValues();
        System.runAs(testUser){

            country = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            insert country;

            company = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', country);
            insert company;

            services = UnitTestDataFactory.createServices(company, country, 10, 'Yogiyo_List_Service_Price', 13, 13, 15, 10, 1, '% per Order', true, 299, 'Monthly', 'Commission', 'ServiceType');
            productGroups = UnitTestDataFactory.createProductGroups(company, country, 1, 'Yogiyo_List_Product_Group');

            List<sObject> objectsToInsert2 = new List<sObject>();
            objectsToInsert2.addAll((List<sObject>)services);
            objectsToInsert2.addAll((List<sObject>)productGroups);
            insert objectsToInsert2;

            products = UnitTestDataFactory.createProducts(company, country, productGroups[0].Id, 10, 'Yogiyo_List_Product_Price', 1, true, 299, 1, true, 10);
            addOns   = UnitTestDataFactory.createAddOns(country.id,company.id,'Test Add On','Deal / Promotion','test',
                                                            'Yogiyo_List_Add_On',10);
            insert addOns;
            tarifs = UnitTestDataFactory.createTarifs(company, country, 10, 'Yogiyo_Tarif', false);
            List<sObject> objectsToInsert3 = new List<sObject>();
            objectsToInsert3.addAll((List<sObject>)products);
            objectsToInsert3.addAll((List<sObject>)tarifs);
            insert objectsToInsert3; 
            
            CountryCompanyMapping__c mapping = new CountryCompanyMapping__c();
            mapping.name 				= 'Korea';
            mapping.Company_Code__c 	= 'Yogiyo';
            insert mapping;

        }
    }
    
    @isTest static void test_Varibales() {
        Test.startTest();

        CtrTarifManager tm;

        System.runAs(testUser){
            tm = new CtrTarifManager();
        }
        Test.stopTest();

        System.assertEquals(0, tm.mapSelectedServices.size());
        System.assertEquals(0, tm.mapSelectedProducts.size());
        System.assertEquals(0, tm.mapSelectedAddOns.size());
        System.assertEquals(10, tm.tariffs.size());
        System.assertEquals(11, tm.products.size());
        System.assertEquals(11, tm.services.size());
        System.assertEquals(11, tm.addOns.size());
        System.assertEquals(10, tm.servicesMap.size());
        System.assertEquals(10, tm.productsMap.size());
        System.assertEquals(10, tm.addOnMap.size());
        System.assertEquals(10, tm.tariffsMap.size());
        System.assertEquals(0, tm.selectedProductsSize);
        System.assertEquals(0, tm.selectedServicesSize);
        system.assertEquals(0, tm.selectedAddOnsSize);
        System.assertEquals(new Tarif__c(), tm.myTarif);
        System.assertEquals(null, tm.selectedService);
        System.assertEquals(null, tm.selectedProduct);
        System.assertEquals(null, tm.selectedAddOn);
        System.assertEquals(null, tm.selectedServiceToDelete);
        System.assertEquals(null, tm.selectedProductToDelete);
        System.assertEquals(null, tm.selectedAddOnToDelete);
        System.assertEquals(null, tm.selectedTarif);
    }
    
    @isTest static void test_AddService() {
        Test.startTest();

        CtrTarifManager tm;
        
        System.runAs(testUser){

            tm = new CtrTarifManager();

            System.assertEquals(11, tm.services.size());

            tm.addService();

            // Nothing happens since a service has not been selected jetzt
            System.assertEquals(null, tm.selectedService);
            System.assertEquals(null, tm.mapSelectedServices.get(services[0].Id));  

            tm.selectedService = services[0].Id;
            tm.addService();
            System.assertEquals(services[0].Id, tm.mapSelectedServices.get(services[0].Id).Id); 
        }
        Test.stopTest();
        
    }

    @isTest static void test_AddProduct() {
        Test.startTest();

        CtrTarifManager tm;
        
        System.runAs(testUser){

            tm = new CtrTarifManager();
            System.assertEquals(11, tm.products.size());
            tm.addProduct();

            // Nothing happens since a product has not been selected jetzt
            System.assertEquals(null, tm.selectedProduct);
            System.assertEquals(null, tm.mapSelectedProducts.get(products[0].Id));

            tm.selectedProduct = products[0].Id;
            tm.addProduct();
            System.assertEquals(products[0].Id, tm.mapSelectedProducts.get(products[0].Id).Id);
        }
        Test.stopTest();
    }

    @isTest static void test_AddAddOn() {
        Test.startTest();

        CtrTarifManager tm;

        System.runAs(testUser){

            tm = new CtrTarifManager();
            System.assertEquals(11, tm.addOns.size());
            tm.addAddOn();

            // Nothing happens since a product has not been selected jetzt
            System.assertEquals(null, tm.selectedAddOn);
            System.assertEquals(null, tm.mapSelectedAddOns.get(addOns[0].Id));

            tm.selectedAddOn = addOns[0].Id;
            tm.addAddOn();
            System.assertEquals(addOns[0].Id, tm.mapSelectedAddOns.get(addOns[0].Id).Id);
        }
        Test.stopTest();
    }

    @isTest static void test_DeleteServiceItem() {
        Test.startTest();

        CtrTarifManager tm;
        
        System.runAs(testUser){

            tm = new CtrTarifManager();

            System.assertEquals(11, tm.services.size());
            System.assertEquals(null, tm.mapSelectedProducts.get(services[0].Id));

            // Add Services in the map so that we can remove it
            tm.selectedService= services[0].Id;
            tm.addService();
            System.assertEquals(services[0].Id, tm.mapSelectedServices.get(services[0].Id).Id);

            // Remove Services
            tm.selectedServiceToDelete = services[0].Id;
            tm.deleteServiceItem();
        }

        Test.stopTest();

        System.assertEquals(null, tm.mapSelectedServices.get(services[0].Id));
        System.assertEquals(0, tm.mapSelectedServices.size());
    }

    @isTest static void test_DeleteProductItem() {
        Test.startTest();

        CtrTarifManager tm;
        
        System.runAs(testUser){

            tm = new CtrTarifManager();
            System.assertEquals(11, tm.products.size());
            System.assertEquals(null, tm.mapSelectedProducts.get(products[0].Id));

            // Add Services in the map so that we can remove it
            tm.selectedProduct = products[0].Id;
            tm.addProduct();
            System.assertEquals(products[0].Id, tm.mapSelectedProducts.get(products[0].Id).Id);

            // Remove Services
            tm.selectedProductToDelete = products[0].Id;
            tm.deleteProductItem();
        }

        Test.stopTest();

        System.assertEquals(null, tm.mapSelectedProducts.get(products[0].Id));
        System.assertEquals(0, tm.mapSelectedProducts.size());
    }

    @isTest static void test_DeleteAddOnItem() {
        Test.startTest();

        CtrTarifManager tm;

        System.runAs(testUser){

            tm = new CtrTarifManager();
            System.assertEquals(11, tm.addOns.size());
            System.assertEquals(null, tm.mapSelectedAddOns.get(addOns[0].Id));

            // Add Services in the map so that we can remove it
            tm.selectedAddOn = addOns[0].Id;
            tm.addAddOn();
            System.assertEquals(addOns[0].Id, tm.mapSelectedAddOns.get(addOns[0].Id).Id);

            // Remove Services
            tm.selectedAddOnToDelete = addOns[0].Id;
            tm.deleteAddOnItem();
        }

        Test.stopTest();

        System.assertEquals(null, tm.mapSelectedAddOns.get(addOns[0].Id));
        System.assertEquals(0, tm.mapSelectedAddOns.size());
    }

    @isTest static void test_AddTarif() {
        Test.startTest();

        CtrTarifManager tm;
        
        System.runAs(testUser){

            tm = new CtrTarifManager();
            System.assertEquals(11, tm.products.size());
            System.assertEquals(11, tm.services.size());
            System.assertEquals(11, tm.addOns.size());
            System.assertEquals(new Tarif__c(), tm.myTarif);

            tm.save();
            // Shouldn't save new tariff because the name is missing
            System.assertEquals(10, tm.tariffs.size());

            tm.myTarif.Is_Active__c = true;
            tm.myTarif.Is_Locked__c = true;
            tm.save();
            // Shouldn't save new tariff because Tarif is activated on create
            System.assertEquals(10, tm.tariffs.size());

            tm.myTarif.Name = 'Test Tarif';
            tm.myTarif.Is_Active__c = false;
            tm.save();

        }
        Test.stopTest();
    }

    @isTest static void test_EditTarif() {
        Test.startTest();

        CtrTarifManager tm;
        
        System.runAs(testUser){

            tm = new CtrTarifManager();

            System.assertEquals(11, tm.products.size());
            System.assertEquals(11, tm.services.size());
            System.assertEquals(11, tm.addOns.size());
            System.assertEquals(10, tm.tariffs.size());

            tm.myTarif = tarifs[0];
            tm.myTarif.Is_Locked__c = true;
            
            // Need to add product and services to test properly
            tm.selectedProduct = products[0].Id;
            tm.addProduct();

            tm.selectedService = services[0].Id;
            tm.addService();

            tm.selectedAddOn = addOns[0].Id;
            tm.addAddOn();

            System.assertEquals(services[0].Id, tm.mapSelectedServices.get(services[0].Id).Id);
            System.assertEquals(products[0].Id, tm.mapSelectedProducts.get(products[0].Id).Id);
            System.assertEquals(addOns[0].Id, tm.mapSelectedAddOns.get(addOns[0].Id).Id);

            tm.save();

            Tarif__c tarifTest = [SELECT Id, Is_Active__c, Name, Id_Country__c, Company__c, (SELECT Id, Id_Tarif_Item__c, Tarif_Name__c, Type__c FROM Tarif_Members__r ) FROM Tarif__c  WHERE Id =: tarifs[0].Id];

            List<Tarif_Member__c> tarifMembers = [SELECT Id, Id_Tarif_Item__c, Tarif_Name__c, Type__c FROM Tarif_Member__c WHERE Tarif_Name__c = :tarifTest.Id];

            System.assertEquals(3, tarifMembers.size());

            // Editing the tarif sets the tarifs to be edited and retrieves tarif members
            tm.selectedTarif = tarifTest.Id;

            tm.editTarif();
            tm.myTarif.Name = 'TEST';
            tm.save();

            Tarif__c tarifTest1 = [SELECT Id, Name FROM Tarif__c WHERE Id =: tarifTest.Id];

            System.assertEquals('TEST', tarifTest1.Name);

        }

        Test.stopTest();
    }

    @isTest static void test_DeleteTarif() {
        Test.startTest();

        CtrTarifManager tm;
        System.runAs(testUser){

            tm = new CtrTarifManager();
            
            System.assertEquals(10, tm.tariffs.size());

            tm.selectedTarif = tarifs[0].Id;
            tm.chooseTarifToDelete();
            System.assertEquals('Test_Tarif_0', tm.myTarif.Name);

            tm.deleteTarif();
            

            tm.cancel();
            tm.initiateTariffAdd();
        }
        Test.stopTest();
    }

    @isTest static void test_Miscellaneous() {
        Test.startTest();

        CtrTarifManager tm;
        System.runAs(testUser){

            tm = new CtrTarifManager();
            tm.cancel();
            tm.initiateTariffAdd();
        }

        Test.stopTest();
    }
}