@isTest
private class UnitTestCtrProductGroupManager {
    
    private static User testUser;
    private static Country__c country;
    private static Company__c company;
    private static List<List_Product_Group__c> lpg;
    //private static List<List_Product_Price__c> products;
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
            insert country;

            company = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', country);
            insert company;

            lpg = UnitTestDataFactory.createProductGroups(company, country, 10, 'Yogiyo_List_Product_Group');
            List<Account> accts = UnitTestDataFactory.createAccounts(1, country, 'Yogiyo_Account');

            List<sObject> objectsToInsert2 = new List<sObject>();
            objectsToInsert2.addAll((List<sObject>)lpg);
            objectsToInsert2.addAll((List<sObject>)accts);
            insert objectsToInsert2;

            //List<List_Product_Price__c> products = UnitTestDataFactory.createProducts(company, country, lpg[0].Id, 10, 'Yogiyo_List_Product_Price', 1, true, 299, 1, true, 10);   
            List<List_Product_Price__c> lpp = UnitTestDataFactory.createProducts(company, country, lpg[0].Id, 10, 'Yogiyo_List_Product_Price', 1, true, 299, 1, true, 10);  
            List<Opportunity> opps = UnitTestDataFactory.createOpportunities(accts, 1, 'Yogiyo_Opportunity', Date.today().addMonths(2));
            List<sObject> objectsToInsert3 = new List<sObject>();
            objectsToInsert3.addAll((List<sObject>)lpp);
            objectsToInsert3.addAll((List<sObject>)opps);
            insert objectsToInsert3;

            //opi = UnitTestDataFactory.createOpportunityProductItems(opps[0], lpp[0].Id, 1, false, 'Yogiyo_Opportunity_Line_Item', 1, '10', 299, 1, 299);
            opi = UnitTestDataFactory.createOpportunityLineItems(opps[0], lpg[0].Id, lpp[0].Id, 1, false, 'Yogiyo_Opportunity_Line_Item',1, '10', 299.0, 1, 1, 'Product');
            insert opi;
        }
    }

    @isTest static void test_ClsManagementConsoleBase() {
        
        Test.startTest();

        CtrProductGroupManager pgm;

        System.runAs(testUser){
            pgm = new CtrProductGroupManager();
        }

        System.assertEquals(pgm.countries.size(), 2);
        System.assertEquals(pgm.companies.size(), 2);
        System.assertEquals(pgm.userCountryIds.size(), 1);
        System.assertEquals(pgm.userCompanyIds.size(), 1);
        System.assertEquals(pgm.companyList.size(), 1);
        System.assertEquals(pgm.countries[0].getValue(), 'null');
        System.assertEquals(pgm.companies[0].getValue(), 'null');
        System.assertEquals(pgm.countries[1].getValue(), pgm.selectedCountry);
        System.assertEquals(pgm.companies[1].getValue(), pgm.selectedCompany);
        System.assertEquals(pgm.countries[1].getLabel(), 'Korea');
        System.assertEquals(pgm.companies[1].getLabel(), 'Yogiyo');
        System.assertEquals(pgm.defaultCountry, 'Korea');
        System.assertEquals(pgm.defaultCompany, 'Yogiyo');
        System.assertEquals(pgm.hideCompanyDropdown, true);
        System.assertEquals(pgm.hideCountryDropdown, true);
        System.assertEquals(pgm.showCompanyDropdown, false);
        System.assertEquals(pgm.showCountryDropdown, false);

        System.assertEquals(pgm.determineCompanyCode(), 'Yogiyo');

        System.runAs(testUser){
            pgm.reInitCountryAndCompanyDropdowns();
        }
        
        System.assertEquals(pgm.userCountryIds.size(), 1);
        System.assertEquals(pgm.userCompanyIds.size(), 1);
        System.assertEquals(pgm.updateItem(), true);

        Test.stopTest();
    }
    
    @isTest static void test_Variables() {
        Test.startTest();

        CtrProductGroupManager pgm;
        
        System.runAs(testUser){
            pgm = new CtrProductGroupManager();
        }

        Test.stopTest();

        System.assertEquals(pgm.listProductGroups.size(), 10);
        System.assertEquals(pgm.mapProductGroups.size(), 10);
        System.assertEquals(pgm.newProductGroupItem, new List_Product_Group__c());

        
    }

    @isTest static void test_AddProduct() {
        Test.startTest();

        CtrProductGroupManager pgm;
        
        System.runAs(testUser){
            pgm = new CtrProductGroupManager();

            // Adding a new product without the name will cause an exception
            pgm.addProductGroup();
            System.assertEquals(pgm.listProductGroups.size(), 10);
            System.assertEquals(pgm.mapProductGroups.size(), 10);

            pgm.newProductGroupItem.Name = 'Test Product Added';
            pgm.addProductGroup();

            System.assertEquals(pgm.listProductGroups.size(), 11);
            System.assertEquals(pgm.mapProductGroups.size(), 11);
        }

        Test.stopTest();
    }

    @isTest static void test_EditProduct() {
        Test.startTest();

        CtrProductGroupManager pgm;
        
        System.runAs(testUser){
            pgm = new CtrProductGroupManager();

            pgm.productGroupId = lpg[0].Id;
            pgm.editItem();
            pgm.newProductGroupItem.Name = 'TEST';
            pgm.addProductGroup();
        }

        Test.stopTest();

        System.assertEquals(pgm.listProductGroups.size(), 10);
        System.assertEquals(pgm.mapProductGroups.size(), 10);

        List<List_Product_Group__c> lpg_1 = [SELECT Name, Id_Country__c, Company__c FROM List_Product_Group__c];
        System.assertEquals(lpg_1[0].Name, 'TEST');
        
    }

    @isTest static void test_DeleteProduct() {
        Test.startTest();

        CtrProductGroupManager pgm;
        
        System.runAs(testUser){

            pgm = new CtrProductGroupManager();

            // Delete a product;
            pgm.productGroupId = lpg[0].Id;
            pgm.chooseProductGroupToDelete();
            pgm.deleteItem();
        
            // Delete fails becuase product group is attached to an Opportunity Product Item throught the Product
            System.assertEquals(pgm.listProductGroups.size(), 10);
            System.assertEquals(pgm.mapProductGroups.size(), 10);

            // Deleting the Opportunity Product Item will lead to a successful deletion of the Product Group
            delete opi;
            pgm.productGroupId = lpg[0].Id;
            pgm.chooseProductGroupToDelete();
            pgm.deleteItem();
            
            System.assertEquals(pgm.listProductGroups.size(), 9);
            System.assertEquals(pgm.mapProductGroups.size(), 9);

            pgm.cancel();
            System.assertEquals(pgm.newProductGroupItem, new List_Product_Group__c());
        }
        Test.stopTest();
    }   
}