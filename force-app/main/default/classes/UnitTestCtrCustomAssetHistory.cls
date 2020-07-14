@istest
private class UnitTestCtrCustomAssetHistory {
    private static User testUser;
  private static Country__c country;
  private static List<Account> accounts;
  private static List<Opportunity> opportunities;
  private static List<Asset__c> assets;
    private static List<Stock_Item__c> stockItems;
    private static List<Consignment__c> consignments;
    
    
    static {
    UnitTestDataFactory.getRecordtypeValues();
    testUser = UnitTestDataFactory.createUser('Yogiyo Customer Care Management', 'yogiyounittestuser@deliveryhero.com', 'Yogiyo', 'KR');
    insert testUser;
    System.runAs(testUser){
      country = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
      insert country;

      consignments = UnitTestDataFactory.createConsignments(1, false, 'Ordered', 'Other', 'trackingUrl');
      accounts = UnitTestDataFactory.createAccounts(1, country, 'Yogiyo_Account');

      List<sObject> objectsToInsert1 = new List<sObject>();
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
    
    static testmethod void UnitTest1(){
        List<CtrCustomAssetHistory.SomeObjectHistory> listResult;
        Test.startTest();
        
        System.runas(testuser){
            
            CtrCustomAssetHistory ctrl = new CtrCustomAssetHistory();
            ctrl.SomeObjectId = assets[0].Id;
            listResult = ctrl.SomeObjectHistories;
            String actionFormat = ctrl.SomeObjectHistories[0].ActionFormat;
        }
        Test.stopTest();
        System.assert(!listResult.isEmpty());
        
        
    }
    
}