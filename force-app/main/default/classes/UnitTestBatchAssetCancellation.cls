@isTest
private class UnitTestBatchAssetCancellation {
    private static User testUser;
    private static Country__c country;
    private static Company__c company;
    private static List<Account> accounts;
    private static List<Opportunity> opportunities;
    private static List<Opportunity_Quote__c> quotes;
    private static List<List_Product_Group__c> productGroups;
    private static List<List_Product_Price__c> products;
    private static List<Asset__c> assets;
    private static List<Stock_Item__c>  stockItems;
    private static List<Additional_Charges__c> additionalCharges;
    private static List<Consignment__c> consignments;

    static {
        UnitTestDataFactory.getRecordtypeValues();
        testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'yogiyouser@deliveryhero.com', 'Yogiyo', 'KR');
        insert testUser;
        System.runAs(testUser){
            Platform_Country__c pt1 = new Platform_Country__c(name='FOCPlatform',Country__c='Lebanon,Qatar,United Arab Emirates');
        Platform_Country__c pt2 = new Platform_Country__c(name='TalabatPlatform',Country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates');
        insert new List<sObject>{pt1,pt2};
            country = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            insert country;

            company = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', country);
            insert company;

            productGroups = UnitTestDataFactory.createProductGroups(company, country, 10, 'Yogiyo_List_Product_Group');
            accounts = UnitTestDataFactory.createAccounts(1, country, 'Yogiyo_Account');
            
            Business_Config__c b = new Business_Config__c(Business_Rule_Name__c='createAdditionalChargeShadow',Business_Rule_Value__c='true',Id_Country__c=country.id,Is_Active__c=true,Parent__c=true,Process_Name__c='Custom Report Settings',Record_Type_Id__c='Yogiyo_Additional_Charges',Type__c='Process');
            insert b;

            List<sObject> objectsToInsert = new List<sObject>();
            objectsToInsert.addAll((List<sObject>)productGroups);
            objectsToInsert.addAll((List<sObject>)accounts);
            insert objectsToInsert;

            products = UnitTestDataFactory.createProducts(company, country, productGroups[0].Id, 10, 'Yogiyo_List_Product_Price', 1, true, 299, 1, true, 10);   
            opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'Yogiyo_Opportunity', Date.today().addMonths(2));
            List<sObject> objectsToInsert1 = new List<sObject>();
            objectsToInsert1.addAll((List<sObject>)products);
            objectsToInsert1.addAll((List<sObject>)opportunities);
            insert objectsToInsert1;

            quotes = UnitTestDataFactory.createOpportunityQuotes(opportunities[0], 1, 'Yogiyo_Opportunity_Quote', 'draft', 'TEST', 100, 100, 'Test', 'Test', 10);
            insert quotes;

            consignments = UnitTestDataFactory.createConsignments(1, false, 'Ordered', 'Other', 'trackingUrl');
            insert consignments;

            stockItems = UnitTestDataFactory.createStockItems(2,'Yogiyo_Stock_Item', accounts[0], consignments[0], 'A1 - New used', Date.today(), Date.today().addDays(10), Date.today().addDays(-30), '1234567890', '1234567890', 'Korea Telekom', 'Ordered', 'Other');
            insert stockItems;

            //assets = UnitTestDataFactory.createAssets(3,accList[0],oppList[0],Date.today().addDays(-10),true,null,null,'Yogiyo_Asset',18,'12345674', '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'Exchange Requested');
            //assets = UnitTestDataFactory.createAssets(10, accounts[0], opportunities[0], Date.today().addDays(-10), true, stockItems[0], stockItems[1], 'Yogiyo_Asset', '12345674', '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'New - Awaiting Shipping');
            //assets = UnitTestDataFactory.createAssets(10, accounts[0], opportunities[0], Date.today().addDays(-10), true, stock, replaceStock, recordTypeDeveloperName, trackingNumber, numberOfReturns, numberOfRetours, retourDate, returnDate, retourStatus, retourInProgress, returnReason, sharedInfomation, takeOverInformation, status, returnDueDate, retourShippingCompany, retourTrackingNumber, returnStatus)
                
            assets = UnitTestDataFactory.createAssets(10, accounts[0], opportunities[0], Date.today().addDays(-10), true, stockItems[0],null, 'Yogiyo_Asset','12345674', '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'New - Awaiting Shipping', Date.today().addDays(5), 'retourShippingCompany', '552211385', 'Owner sends Terminal');              

            insert assets;

            Asset_Cancellation__c astcan = new Asset_Cancellation__c(Returning_Stock_Item__c=stockItems[0].id,Asset__c=assets[0].id);
            insert astcan;

            additionalCharges = UnitTestDataFactory.createAdditionalCharges(accounts[0], assets[0], opportunities[0], quotes[0], products[0], productGroups[0], '100', 1, 100, 1, 100, 10, 'Yogiyo_Additional_Charges__c', null); 
            //additionalCharges[0].Id_Asset__c = assets[0].id;
            insert additionalCharges;

        }
    }

    @isTest static void test_positive() {
        Test.startTest();
        System.runAs(testUser){
            BatchAssetCancellation batch = new BatchAssetCancellation();
            Database.executeBatch(batch,500);
        }
        Test.stopTest();
        System.assertNotEquals(([select id from Asset_Cancellation__c where Activated_Date__c!=null]).size(),0);
    }
    
}