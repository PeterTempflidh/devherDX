/**
 * @author Konrad Czykin
 * @date 29.06.2020
 * @description Test class for StockItem_Selector
 */
@isTest
private class StockItem_SelectorTest {

    //CREATE DATA FOR TESTS METHODS
    @testSetup
    static void setup(){
            UnitTestDataFactory.getRecordtypeValues();
            Country__c country = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'HKD');
            insert country;
            Company__c company = UnitTestDataFactory.createCompany('FoodPanda', 'FoodPanda', country);
            insert company;
            List<Account> lstAccounts = UnitTestDataFactory.createAccounts(2, country, 'FP_Account');
            insert lstAccounts;
            List<Stock_Item__c> stockItem1 = UnitTestDataFactory.createStockItems(1, Constants.FP_STOCKITEM_DEVELOPERNAME, lstAccounts[0], null, 'A - New', Date.today().addMonths(-1), Date.today(), Date.today().addMonths(-2),
                'TestSimNumber', 'TestSimMobile', 'testSimProvider', 'testStatus', 'testType');
            stockItem1[0].Account_Country__c = 'Hong Kong';
            List<Stock_Item__c> stockItem2 = UnitTestDataFactory.createStockItems(1, Constants.FP_STOCKITEM_DEVELOPERNAME, lstAccounts[1], null, 'A - New', Date.today().addMonths(-1), Date.today(), Date.today().addMonths(-2),
                'TestSimNumber', 'TestSimMobile', 'testSimProvider', 'testStatus', 'testType');
                stockItem2[0].Account_Country__c = 'Hong Kong';
            insert new List<Stock_Item__c>{stockItem1[0], stockItem2[0]};
    }

    /**
    * @date         : 29/06/2020
    * @method name  : testGetStockItems
    * @description  : Test method of the getStockItems
    */
    @isTest
    static void testGetStockItems(){
        Map<Id, Stock_Item__c> mapSI = new Map<Id, Stock_Item__c>([SELECT Id FROM Stock_Item__c]);

        Test.startTest();
            List<Stock_Item__c> lstSI = StockItem_Selector.getStockItems(mapSI.keySet());
        Test.stopTest();
        System.assertEquals(2, lstSi.size());
        System.assertEquals('testStatus', lstSI[0].Status__c);
        System.assertEquals('testStatus', lstSI[1].Status__c);
    }

    /**
    * @date         : 29/06/2020
    * @method name  : testGetStockItemsNoIds
    * @description  : Test method of the getStockItems, empty set of Ids
    */
    @isTest
    static void testGetStockItemsNoIds(){
        Set<Id> emptySet = new Set<Id>();

        Test.startTest();
            List<Stock_Item__c> lstSI = StockItem_Selector.getStockItems(emptySet);
        Test.stopTest();
        System.assertEquals(0, lstSi.size());
    }
}