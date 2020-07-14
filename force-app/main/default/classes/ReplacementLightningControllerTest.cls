@isTest
public class ReplacementLightningControllerTest {
	
    @isTest
    private static void test_getCurrentData() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c c = UnitTestDataFactory.createCountry('HK','Hong Kong', 'HKD');
        Company__c com = UnitTestDataFactory.createCompany('testcompany', 'HK', c);

        insert new List<sObject> { c,com };

        List<Account> accList = UnitTestDataFactory.createAccounts(1,c,'FP_Account');
        accList[0].Phone = '+85212345678';
        insert accList;
        
        List<Opportunity> opportunities = UnitTestDataFactory.createOpportunities(accList, 1, 'FP_Opportunity', Date.today());
        Database.insert(opportunities);
        
        List<Stock_Item__c> stockItems = UnitTestDataFactory.createStockItems(2,'FP_Stock_Item', accList[0], null, 'A1 - New used', Date.today(), Date.today().addDays(10), Date.today().addDays(-30), '1234567890', '1234567890', 'HK Telekom', 'Ordered', 'Other');
        insert stockItems;
        
        List<Asset__c> assets = UnitTestDataFactory.createAssets(2, accList[0], opportunities[0], Date.today().addDays(-10), true, stockItems[0],null, 'FP_Asset','12345674', '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'New - Awaiting Shipping', Date.today().addDays(5), 'retourShippingCompany', '552211385', 'Owner sends Terminal');   
        insert assets;
        
        Test.startTest();
        	String json = ReplacementLightningController.getCurrentData(assets[0].Id);
        Test.stopTest();
        
        System.assertEquals(true, !String.isEmpty(json), 'Json string expected');
    }
    
    @isTest
    private static void test_startReplacement() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c c = UnitTestDataFactory.createCountry('HK','Hong Kong', 'HKD');
        Company__c com = UnitTestDataFactory.createCompany('testcompany', 'HK', c);

        insert new List<sObject> { c,com };

        List<Account> accList = UnitTestDataFactory.createAccounts(1,c,'FP_Account');
        accList[0].Phone = '+85212345678';
        insert accList;
        
        List<Opportunity> opportunities = UnitTestDataFactory.createOpportunities(accList, 1, 'FP_Opportunity', Date.today());
        Database.insert(opportunities);
        
        List<Stock_Item__c> stockItems = UnitTestDataFactory.createStockItems(2,'FP_Stock_Item', accList[0], null, 'A1 - New used', Date.today(), Date.today().addDays(10), Date.today().addDays(-30), '1234567890', '1234567890', 'HK Telekom', 'Ordered', 'Other');
        insert stockItems;
        
        List<Asset__c> assets = UnitTestDataFactory.createAssets(2, accList[0], opportunities[0], Date.today().addDays(-10), true, stockItems[0],null, 'FP_Asset','12345674', '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'New - Awaiting Shipping', Date.today().addDays(5), 'retourShippingCompany', '552211385', 'Owner sends Terminal');   
        insert assets;
        
        Test.startTest();
        	String json = ReplacementLightningController.startReplacement(assets[0].Id);
        Test.stopTest();
        
        System.assertEquals(true, !String.isEmpty(json), 'Json string expected');
    }
   
}