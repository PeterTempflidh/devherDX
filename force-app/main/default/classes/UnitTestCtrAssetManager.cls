@isTest
private class UnitTestCtrAssetManager {
    private static User testUser;
    private static Country__c country;
    private static List<Account> accounts;
    private static List<Opportunity> opportunities;
    private static List<Asset__c> assets;
    private static List<Stock_Item__c> stockItems;
    private static List<Consignment__c> consignments;

    static {
        UnitTestDataFactory.getRecordtypeValues();
        List<Platform_Country__c> platformCountry =new List<Platform_Country__c>(); 
        platformCountry.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name='FOCPlatform', country__c='Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
        testUser = UnitTestDataFactory.createUser('Yogiyo Customer Care Management', 'yogiyounittestuser@deliveryhero.com', 'Yogiyo', 'KR');
        insert testUser;
        System.runAs(testUser){
            country = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            insert country;

            consignments = UnitTestDataFactory.createConsignments(1, false, 'Ordered', 'Other', 'trackingUrl');
            accounts = UnitTestDataFactory.createAccounts(1, country, 'Yogiyo_Account');

            List<sObject> objectsToInsert1 = new List<sObject>();
            objectsToInsert1.addAll((List<sObject>)consignments);
            objectsToInsert1.addAll((List<sObject>)accounts);
            insert objectsToInsert1;

            stockItems = UnitTestDataFactory.createStockItems(2,'Yogiyo_Stock_Item', accounts[0], consignments[0], 'A1 - New used', Date.today(), Date.today().addDays(10), Date.today().addDays(-30), '1234567890', '1234567890', 'Korea Telekom', 'Ordered', 'Other');
            opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'Yogiyo_Opportunity', Date.today().addMonths(2));
            
            List<sObject> objectsToInsert2 = new List<sObject>();
            objectsToInsert2.addAll((List<sObject>)stockItems);
            objectsToInsert2.addAll((List<sObject>)opportunities);
            insert objectsToInsert2;

            assets = UnitTestDataFactory.createAssets(10, accounts[0], opportunities[0], Date.today().addDays(-10), true, stockItems[0], stockItems[1], 'Yogiyo_Asset',
                    '12345674', '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'Exchange Requested',
                    Date.today().addDays(20), 'Yazi Logistics', '1234', 'Delivered to Warehouse');
            
            insert assets;
        }
    }

    @isTest static void test_Variables() {
        Test.startTest();

        CtrAssetManager cam;
        System.runAs(testUser){
            cam = new CtrAssetManager();
        }

        Test.stopTest();

        Asset__c testAsset = new Asset__c();
        System.assertEquals(new Asset__c(), cam.myAsset);
        System.assertEquals(10, cam.mapExistingAssets.size());
        System.assertEquals(null, cam.selectedAssetToEdit);
    }
    
    @isTest static void test_SaveAndReset() {
        Test.startTest();

        CtrAssetManager cam;
        List<Asset__c> myAsset;

        System.runAs(testUser){
            myAsset = UnitTestDataFactory.createAssets(1, accounts[0], opportunities[0], Date.today().addDays(-10), true, stockItems[0], stockItems[1], 'Yogiyo_Asset',
                    '12345674', '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'Exchange Requested',
                    Date.today().addDays(20), 'Yazi Logistics', '1234', 'Delivered to Warehouse');
            
            cam = new CtrAssetManager();
            cam.myAsset = myAsset[0];
            cam.save();
        }

        Test.stopTest();

        List<Asset__c> allAssets = [SELECT Id, Name FROM Asset__c];

        System.assertEquals(11, allAssets.size());
    }

    @isTest static void test_EditAsset() {
        Test.startTest();

        CtrAssetManager cam;

        System.runAs(testUser){
            cam = new CtrAssetManager();
            cam.selectedAssetToEdit = assets[0].Id;
            cam.editAsset();
            cam.myAsset.Name = 'Test Edit';
            cam.save();
        }
        
        Test.stopTest();

        Asset__c testAsset = [SELECT Id, Name FROM Asset__c WHERE Id =: assets[0].Id];
        System.assertEquals('Test Edit', testAsset.Name);
    }   
}