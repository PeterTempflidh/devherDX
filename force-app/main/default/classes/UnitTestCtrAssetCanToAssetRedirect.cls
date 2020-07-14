@isTest
private class UnitTestCtrAssetCanToAssetRedirect {
    static Country__c testCountry;
    static Company__c company;
    static List<Asset__c> assetList;
    static List<Asset__c> assets;
    static List<Stock_Item__c> stockList;
    static List<Additional_Charges__c> additionalCharges;
    static List<Opportunity_Quote__c> quotes;
    static List<List_Product_Group__c> productGroups;
    static List<List_Product_Price__c> products;
    static{
            UnitTestDataFactory.getRecordtypeValues();
            testCountry = UnitTestDataFactory.createCountry('KR','Korea','KRW');
            insert testCountry;

            company = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', testCountry);
            insert company;
            productGroups = UnitTestDataFactory.createProductGroups(company, testCountry, 10, 'Yogiyo_List_Product_Group');
            List<Account> accList = UnitTestDataFactory.createAccounts(1,testCountry,'Yogiyo_Account');
            List<sObject> objectsToInsert = new List<sObject>();
            objectsToInsert.addAll((List<sObject>)productGroups);
            objectsToInsert.addAll((List<sObject>)accList);
           // objectsToInsert.add((sObject)businessConfig);
            insert objectsToInsert;
            products = UnitTestDataFactory.createProducts(company, testCountry, productGroups[0].Id, 10, 'Yogiyo_List_Product_Price', 1, true, 299, 1, true, 10);
            List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'Yogiyo_Opportunity',Date.today());
            List<sObject> objectsToInsert1 = new List<sObject>();
            objectsToInsert1.addAll((List<sObject>)products);
            objectsToInsert1.addAll((List<sObject>)oppList);
            insert objectsToInsert1;
            quotes = UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1, 'Yogiyo_Opportunity_Quote', 'draft', 'TEST', 100, 100, 'Test', 'Test', 10);
            insert quotes;

            assetList = UnitTestDataFactory.createAssets(3,accList[0],oppList[0],Date.today().addDays(-10),true,null,null,'Yogiyo_Asset',
                    '12345674', '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'Exchange Requested',
                    Date.today().addDays(20), 'Yazi Logistics', '1234', 'none');
            insert assetList;

            stockList = UnitTestDataFactory.createStockItems(4,'Yogiyo_Stock_Item',accList[0],null,'A1 - New used', Date.today(), Date.today().addDays(10), Date.today().addDays(-30), '1234567890', '1234567890', 'Korea Telekom', 'In Stock', 'Other');
            insert stockList;

            assets = UnitTestDataFactory.createAssets(10, accList[0], oppList[0], Date.today().addDays(-10), true, stockList[0], stockList[1], 'Yogiyo_Asset', '12345674', 
                '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'Exchange Requested',
                Date.today().addDays(20), 'Yazi Logistics', '1234', 'none');
            insert assets;


    }
    @isTest static void test_method_one() {
        // Implement test code
        Asset_Cancellation__c astCan = new Asset_Cancellation__c(Asset__c=assets[0].id,Returning_Stock_Item__c=stockList[0].id);
            insert astCan;
        Test.startTest();

        ApexPages.StandardController stdController = new ApexPages.StandardController(astCan);
        CtrAssetCanToAssetRedirect obj = new CtrAssetCanToAssetRedirect(stdController);
        obj.redirectToAssetPage();
        Test.stopTest();
    }
}