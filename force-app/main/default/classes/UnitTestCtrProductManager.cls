@isTest
private class UnitTestCtrProductManager {

    private static User testUser;
    private static Country__c country;
    private static Company__c company;
    private static List<List_Product_Group__c> lpg;
    private static List<List_Product_Price__c> products;
    private static List<Opportunity_Line_Item__c> opi;

    static {
        UnitTestDataFactory.getRecordtypeValues();
        testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'yogiyouser@deliveryhero.com', 'Yogiyo', 'KR');
        insert testUser;
        List<Platform_Country__c> platformCountry =new List<Platform_Country__c>(); 
        platformCountry.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name='FOCPlatform', country__c='Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;        
        System.runAs(testUser){
            country = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            
            List<sObject> objectsToInsert1 = new List<sObject>();
            insert country;

            company = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', country);
            insert company;
             Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='useProductTypes',Business_Rule_Value__c='false',Id_Country__c=country.id,Is_Active__c=true,Parent__c=true,Process_Name__c='SalesManagementProcessProducts',Record_Type_Id__c='Yogiyo_List_Product_Price',Type__c='Process');
            Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='DisplaySliders',Business_Rule_Value__c='false',Id_Country__c=country.id,Is_Active__c=true,Parent__c=false,Process_Name__c='SalesManagementProcessProducts',Record_Type_Id__c='Yogiyo_List_Product_Price',Type__c='Process');
            insert new List<sObject>{b1,b2};

            lpg = UnitTestDataFactory.createProductGroups(company, country, 1, 'Yogiyo_List_Product_Group');
            List<Account> accts = UnitTestDataFactory.createAccounts(1, country, 'Yogiyo_Account');

            List<sObject> objectsToInsert2 = new List<sObject>();
            objectsToInsert2.addAll((List<sObject>)lpg);
            objectsToInsert2.addAll((List<sObject>)accts);
            insert objectsToInsert2;

            products = UnitTestDataFactory.createProducts(company, country, lpg[0].Id, 10, 'Yogiyo_List_Product_Price', 1, true, 299, 1, true, 10); 
            List<Opportunity> opps = UnitTestDataFactory.createOpportunities(accts, 1, 'Yogiyo_Opportunity', Date.today().addMonths(2));
            List<sObject> objectsToInsert3 = new List<sObject>();
            objectsToInsert3.addAll((List<sObject>)products);
            objectsToInsert3.addAll((List<sObject>)opps);
            insert objectsToInsert3;

            
            opi = UnitTestDataFactory.createOpportunityLineItems(opps[0], lpg[0].Id, products[0].Id, 1, false, 'Yogiyo_Opportunity_Line_Item',1, '10', 299.0, 1, 1, 'Product');
            //opi = UnitTestDataFactory.createOpportunityProductItems(opps[0], products[0].Id, 1, false, 'Yogiyo_Opportunity_Line_Item', 1, '10', 299, 1, 1);
            system.debug('@@opi'+opi);
            insert opi;
        }
    } 
    
    @isTest static void test_Variables() {

        Test.startTest();
        CtrProductManager pm;
        System.runAs(testUser){
            pm = new CtrProductManager();
        }

        Test.stopTest();

        System.assertEquals(2, pm.listProductGroupSelection.size());
        System.assertEquals(10, pm.listProducts.size());
        System.assertEquals(1, pm.productGroups.size());
        System.assertEquals(10, pm.listProducts.size());
        System.assertEquals(1, pm.myNewProduct.Default_Quantity__c);
        System.assertEquals(null, pm.selectedProductGroup);
        System.assertEquals(null, pm.productId);
        System.assertEquals(null, pm.productToUpdate);
    }
    
    @isTest static void test_AddProduct() {
        
        Test.startTest();

        CtrProductManager pm;
        System.runAs(testUser){
            pm = new CtrProductManager();

            pm.selectedProductGroup = lpg[0].Id;
            pm.productGroups.add(lpg[0]);
            pm.addProduct();
        }

        // Will not insert if one of the required fields is null or empty
        System.assertEquals('', pm.myNewProduct.Product_Name__c);
        System.assertEquals(null, pm.myNewProduct.List_Price__c);
        System.assertEquals(10, pm.listProducts.size());
        System.assertEquals(10, pm.mapProductListPrice.size());

        System.runAs(testUser){
            pm.myNewProduct.List_Price__c = 100;
            pm.myNewProduct.Product_Name__c = 'Test Product';
            pm.addProduct();
        }

    
        Test.stopTest();
    }

    @isTest static void test_EditProduct() {
        
        Test.startTest();

        CtrProductManager pm;
        System.runAs(testUser){
            pm = new CtrProductManager();

            // Assert that list price is 100. This is set when creating products in UnitTestDataFactory
            System.assertEquals(299, products[0].List_Price__c);

            pm.productId = products[0].Id;
            
            pm.editItem();
            pm.myNewProduct.List_Price__c = 200;
            pm.addProduct();
        }

        Test.stopTest();

        List_Product_Price__c product = [SELECT Id, List_Price__c FROM List_Product_Price__c WHERE Id =: products[0].Id];

        System.assertEquals(200, product.List_Price__c);

        
    }

    @isTest static void test_DeleteProduct() {

        Test.startTest();

        CtrProductManager pm;

        System.runAs(testUser){
        
            pm = new CtrProductManager();
            system.debug('@@del'+pm.listProducts.size());
            pm.productId = products[0].Id;
            pm.chooseProductToDelete();
            pm.deleteItem();

            // Attempt to delete product attached to an opportunity product item will throw an exception
            System.assertEquals(10, pm.listProducts.size());
            System.assertEquals(10, pm.mapProductListPrice.size());

            delete opi;
            pm.deleteItem();


            pm.cancel();
            pm.initiateProductAdd();
            System.assertEquals(1, pm.myNewProduct.Default_Quantity__c);
        }
        Test.stopTest();
    }

    @isTest static void test_ValidateDiscout() {
        Test.startTest();

        CtrProductManager pm;

            System.runAs(testUser){

            pm = new CtrProductManager();

            pm.selectedProductGroup = lpg[0].Id;

            // Add will fail since maximum percentage discount cannot be more than 100 %
            pm.myNewProduct.maximum_discount__c = 110;
            pm.addProduct();
        }

        Test.stopTest();

        System.assertEquals(10, pm.listProducts.size());
        System.assertEquals(10, pm.mapProductListPrice.size());
    }

    @isTest static void test_DetermineProductGroup() {
        Test.startTest();

        CtrProductManager pm;

        System.runAs(testUser){

            pm = new CtrProductManager();

            System.assertEquals(null, pm.productToUpdate);

            pm.productGroups.add(lpg[0]);
            pm.selectedProductGroup = lpg[0].Id;
        }

        Test.stopTest();

        System.assertEquals('KRW', pm.determineProductGroup());
        System.assertEquals(lpg[0], pm.productToUpdate);
    }
    
}