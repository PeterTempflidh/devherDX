@isTest
private class UnitTestCtrAssetHistory {
    private static User testUser;
    private static Country__c country;
    private static List<Account> accounts;
    private static List<Opportunity> opportunities;
    private static List<Asset__c> assets;
    private static List<Stock_Item__c> stockItems;
    private static List<Consignment__c> consignments;
    private static List<Asset__c> AssetID =new List<Asset__c>();
    private static List<Stock_Item__c> newStockItems;
    
    static {
        UnitTestDataFactory.getRecordtypeValues();
        testUser = UnitTestDataFactory.createUser('Yogiyo Customer Care Management', 'yogiyounittestuser@deliveryhero.com', 'Yogiyo', 'KR');
        insert testUser;
        List<Platform_Country__c> platformCountry =new List<Platform_Country__c>(); 
        platformCountry.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name='FOCPlatform', country__c='Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
        System.runAs(testUser){
            country = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            insert country;

            consignments = UnitTestDataFactory.createConsignments(1, false, 'Ordered', 'Other', 'trackingUrl');
            accounts = UnitTestDataFactory.createAccounts(1, country, 'Yogiyo_Account');
            accounts[0].Restaurant_Name__c='test';

            List<sObject> objectsToInsert1 = new List<sObject>();
            objectsToInsert1.addAll((List<sObject>)accounts);
            insert objectsToInsert1;

            stockItems = UnitTestDataFactory.createStockItems(2,'Yogiyo_Stock_Item', accounts[0], consignments[0], 'A1 - New used', Date.today(), Date.today().addDays(10), Date.today().addDays(-30), '1234567890', '1234567890', 'Korea Telekom', 'Ordered', 'Other');
            newStockItems = UnitTestDataFactory.createStockItems(2,'Yogiyo_Stock_Item', accounts[0], consignments[0], 'A1 - New used', Date.today(), Date.today().addDays(10), Date.today().addDays(-30), '1234567890', '1234567890', 'Korea Telekom', 'Ordered', 'Other');
            opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'Yogiyo_Opportunity', Date.today().addMonths(2));
            
            List<sObject> objectsToInsert2 = new List<sObject>();
            objectsToInsert2.addAll((List<sObject>)stockItems);
            objectsToInsert2.addAll((List<sObject>)newStockItems );
            objectsToInsert2.addAll((List<sObject>)opportunities);
            insert objectsToInsert2;

            assets = UnitTestDataFactory.createAssets(10, accounts[0], opportunities[0], Date.today().addDays(-10), true, stockItems[0], stockItems[1], 'Yogiyo_Asset',
                    '12345674', '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'Exchange Requested',
                    Date.today().addDays(20), 'retourShippingCompany', '1234', 'Arrange Pick up');   
                   
                             
            insert assets;
            assets[0].Initiate_Return__c='Sales Rep Terminated';
            
            update assets;
            
            


            
        }
    }
    static testmethod void UnitTest1(){
        Test.startTest();
        System.runAs(testUser){
            
            CtrCustomAssetHistory ctrl = new CtrCustomAssetHistory();
            ctrl.SomeObjectId=assets[0].id;
           // ctrl.SomeObjectIdsList=AssetID;
            ctrl.showMore();
           // ctrl.AllowGotoList=true;
           // Map<Id, Asset_Cancellation__c> mapAssetCancellation=ctrl.mapAssetCancellation;
            CtrCustomAssetHistory.SomeObjectHistory sh=new CtrCustomAssetHistory.SomeObjectHistory();
            string actFormat=sh.ActionFormat;
            List<CtrCustomAssetHistory.SomeObjectHistory> test=ctrl.SomeObjectHistories;
            
        }
        Test.stopTest();
    }
}