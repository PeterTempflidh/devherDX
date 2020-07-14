@isTest
private class UnitTestCtrStockItemManager {

    private static User testUser;
    private static String jsonString;

    static {
        testUser = UnitTestDataFactory.createUser('Yogiyo Customer Care Management', 'yogiyounittestuser@deliveryhero.com', 'Yogiyo', 'KR');
        insert testUser;
        UnitTestDataFactory.getRecordtypeValues();
        jsonString = '[{"terminalType": "home","productionDate":"05.12.2014","orderDate": "05.12.2014","arrivalDate":"05.12.2014","valueX":"212 555-1234","simcardProvider": "Korea TeleKom","type":"test"}]';
    }
    
    @isTest static void test_Varaibles() {

        Test.startTest();

        CtrStockItemManager sim;
        System.runAs(testUser){
            sim = new CtrStockItemManager();
        }

        Test.stopTest();

        system.assertEquals(new Stock_Item__c(), sim.generalStockItem);
        system.assertEquals(1, sim.listAssetSelection.size());
    }
    
    @isTest static void test_Save() {

        Test.startTest();

        String result;
        System.runAs(testUser){
            result = CtrStockItemManager.save(jsonString);
        }

        Test.stopTest();

        system.assertEquals('ok', result);
    }

    @isTest static void test_StockItemJSON() {

        Test.startTest();

        CtrStockItemManager.StockItemJSON sim;

        System.runAs(testUser){
            sim  = new CtrStockItemManager.StockItemJSON('terminalType', '05.12.2014', '05.12.2014', '05.12.2014', 'test1', '123456789', '123456789', '123456789');
        }

        Test.stopTest();
    }
    
}