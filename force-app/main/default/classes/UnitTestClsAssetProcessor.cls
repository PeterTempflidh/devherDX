@isTest
private class UnitTestClsAssetProcessor {

    private static Map<String, RecordType> mapRecordTypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Case'});

    static Country__c testCountry;
    static Company__c company;
    static List<Asset__c> assetList;
    static List<Asset__c> assets;
    static List<Asset__c>sourceAssetList;
    static List<Asset__c> takeoverAssets;
    static List<Asset__c> sharingAssets;
    static List<Stock_Item__c> stockList;
    static List<Additional_Charges__c> additionalCharges;
    static List<Opportunity_Quote__c> quotes;
    static List<List_Product_Group__c> productGroups;
    static List<List_Product_Group__c> productGroupsUK;
    static List<List_Product_Price__c> products;
    static List<List_Product_Price__c> productsUK;
    static List<Opportunity_Quote__c> quotesUK;
    static List<Additional_Charges__c> additionalChargesUK;
    static Country__c testCountryUK;
    static Company__c companyUK;
    static List<Asset__c> assetListUK;
    static List<Asset__c> assetsUK;
    static List<Stock_Item__c> stockListUK;
    static Business_Config__c businessConfig;

    @testSetup static void setup() {
        List<Platform_Country__c> platformCountry = new List<Platform_Country__c>();
        platformCountry.add(new Platform_Country__c(name = 'TalabatPlatform', country__c = 'Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name = 'FOCPlatform', country__c = 'Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
    }

    static void setupUserData(User u) {

        System.runAs(u) {
            UnitTestDataFactory.getRecordtypeValues();
            testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            testCountryUK = UnitTestDataFactory.createCountry('UK', 'United Kingdom', 'GBP');
            insert new List<sObject> { testCountry, testCountryUK};

            company = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', testCountry);
            companyUK = UnitTestDataFactory.createCompany('HH', 'hungryhouse', testCountryUK);
            insert new List<sObject> {company, companyUK};

            Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c = 'AssetStatus', Business_Rule_Value__c = 'Canceled', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c = 'updateStockStatusIfAssetReturn', Business_Rule_Value__c = 'Delivered to Warehouse', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c = 'updateStockStatusTo', Business_Rule_Value__c = 'In Stock', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c = 'AllowUpdateStockStatusUpdate', Business_Rule_Value__c = 'true', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c = 'AllowStockToReturnStock', Business_Rule_Value__c = 'true', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c = 'ReturningStatus', Business_Rule_Value__c = 'Sales Rep Terminated', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c b7 = new Business_Config__c(Business_Rule_Name__c = 'AllowUpdateAssetStatusFromAssetPage', Business_Rule_Value__c = 'true', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c b8 = new Business_Config__c(Business_Rule_Name__c = 'updateAssetStatusTo', Business_Rule_Value__c = 'Cancel Additional Charge', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c b9 = new Business_Config__c(Business_Rule_Name__c = 'updateAssetStatusIfReturnedStatus', Business_Rule_Value__c = 'Delivered to Warehouse', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c b10 = new Business_Config__c(Business_Rule_Name__c = 'AllowStockInShipmentRule', Business_Rule_Value__c = 'true', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c b11 = new Business_Config__c(Business_Rule_Name__c = 'updateStockInShipmentIfAssetRStatus', Business_Rule_Value__c = 'Owner sends Terminal,Arrange Pick up', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c b12 = new Business_Config__c(Business_Rule_Name__c = 'updateStockInShipmentStatusTo', Business_Rule_Value__c = 'In Shipment', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');

            Business_Config__c q1 = new Business_Config__c(Business_Rule_Name__c = 'Status', Business_Rule_Value__c = 'Activated Successfully', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'AssetStatusUpdateProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c q2 = new Business_Config__c(Business_Rule_Name__c = 'OppType', Business_Rule_Value__c = 'Product Only', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStatusUpdateProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c q3 = new Business_Config__c(Business_Rule_Name__c = 'SetOppStageName', Business_Rule_Value__c = 'Closed Won', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStatusUpdateProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c q4 = new Business_Config__c(Business_Rule_Name__c = 'SetOppProbability', Business_Rule_Value__c = '100', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStatusUpdateProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c q5 = new Business_Config__c(Business_Rule_Name__c = 'AllowUpdateStockStatusUpdate', Business_Rule_Value__c = 'true', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'AssetCancellationProcess', Record_Type_Id__c = 'Yogiyo_Asset_Cancellation', Type__c = 'Process');
            Business_Config__c q6 = new Business_Config__c(Business_Rule_Name__c = 'AssetCancellationRecordType', Business_Rule_Value__c = 'Yogiyo_Asset_Cancellation', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');

            Business_Config__c q7 = new Business_Config__c(Business_Rule_Name__c = 'StampTerminationDateOnField', Business_Rule_Value__c = 'Return_Request_Date__c', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c q8 = new Business_Config__c(Business_Rule_Name__c = 'AllowUpdateAssetActivationDate', Business_Rule_Value__c = 'true', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c q9 = new Business_Config__c(Business_Rule_Name__c = 'UpdateAssetActivationIfStatus', Business_Rule_Value__c = 'Activated Successfully', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c q10 = new Business_Config__c(Business_Rule_Name__c = 'AllowResetingStockFileds', Business_Rule_Value__c = 'true', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c q11 = new Business_Config__c(Business_Rule_Name__c = 'FieldsToReset', Business_Rule_Value__c = 'Is_Active__c,Status__c,Activation_Date__c,Shipping_Company__c,Tracking_Number__c,Date_Shipped__c,Activation_Due_date__c,Initiate_Return__c', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c q12 = new Business_Config__c(Business_Rule_Name__c = 'skipResetForStatus', Business_Rule_Value__c = 'New - Awaiting Shipping', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c q13 = new Business_Config__c(Business_Rule_Name__c = 'DefaultStatusIfAssetExistwithStock', Business_Rule_Value__c = 'No Return Needed', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c q14 = new Business_Config__c(Business_Rule_Name__c = 'DoNotOverWriteAssetStatus', Business_Rule_Value__c = 'Takeover', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetStockProcess', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');

            Business_Config__c c1 = new Business_Config__c(Business_Rule_Name__c = 'DefaultStatusIfAssetExistwithStock', Business_Rule_Value__c = 'No Return Needed', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetCancellationProcess', Record_Type_Id__c = 'Yogiyo_Asset_Cancellation', Type__c = 'Process');
            Business_Config__c c2 = new Business_Config__c(Business_Rule_Name__c = 'updateStockStatusTo', Business_Rule_Value__c = 'In Stock', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetCancellationProcess', Record_Type_Id__c = 'Yogiyo_Asset_Cancellation', Type__c = 'Process');
            Business_Config__c c3 = new Business_Config__c(Business_Rule_Name__c = 'updateStockInShipmentIfAssetRStatus', Business_Rule_Value__c = 'Owner sends Terminal,Arrange', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetCancellationProcess', Record_Type_Id__c = 'Yogiyo_Asset_Cancellation', Type__c = 'Process');
            Business_Config__c c4 = new Business_Config__c(Business_Rule_Name__c = 'updateStockInShipmentStatusTo', Business_Rule_Value__c = 'In Shipment', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetCancellationProcess', Record_Type_Id__c = 'Yogiyo_Asset_Cancellation', Type__c = 'Process');
            Business_Config__c c5 = new Business_Config__c(Business_Rule_Name__c = 'updateStockStatusIfAssetReturn', Business_Rule_Value__c = 'Delivered to Warehouse', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetCancellationProcess', Record_Type_Id__c = 'Yogiyo_Asset_Cancellation', Type__c = 'Process');
            Business_Config__c c6 = new Business_Config__c(Business_Rule_Name__c = 'AllowStockInShipmentRule', Business_Rule_Value__c = 'true', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetCancellationProcess', Record_Type_Id__c = 'Yogiyo_Asset_Cancellation', Type__c = 'Process');
            Business_Config__c c7 = new Business_Config__c(Business_Rule_Name__c = 'updateStockStatusIfAssetReturn', Business_Rule_Value__c = 'Delivered to Warehouse', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetCancellationProcess', Record_Type_Id__c = 'Yogiyo_Asset_Cancellation', Type__c = 'Process');
            Business_Config__c c8 = new Business_Config__c(Business_Rule_Name__c = 'AllowUpdateWarehouseDate', Business_Rule_Value__c = 'true', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetCancellationProcess', Record_Type_Id__c = 'Yogiyo_Asset_Cancellation', Type__c = 'Process');
            Business_Config__c c9 = new Business_Config__c(Business_Rule_Name__c = 'UpdateWarehouseDateIfAssetRStatus', Business_Rule_Value__c = 'Delivered to Warehouse', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'AssetCancellationProcess', Record_Type_Id__c = 'Yogiyo_Asset_Cancellation', Type__c = 'Process');

            Business_Config__c c10 = new Business_Config__c(Business_Rule_Name__c = 'AllowUpdateStockCondition', Business_Rule_Value__c = 'true', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'StockUpdateProcess', Record_Type_Id__c = 'Yogiyo_Stock_Item', Type__c = 'Process');
            Business_Config__c c11 = new Business_Config__c(Business_Rule_Name__c = 'status', Business_Rule_Value__c = 'In Stock', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'StockUpdateProcess', Record_Type_Id__c = 'Yogiyo_Stock_Item', Type__c = 'Process');
            Business_Config__c c12 = new Business_Config__c(Business_Rule_Name__c = 'UpdateStockConditionTo', Business_Rule_Value__c = 'U - Undefined', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'StockUpdateProcess', Record_Type_Id__c = 'Yogiyo_Stock_Item', Type__c = 'Process');

            Business_Config__c c13 = new Business_Config__c(Business_Rule_Name__c = 'PositiveStageName', Business_Rule_Value__c = 'Closed Won', Id_Country__c = testCountryUK.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'RestaurantCareClosingAction', Record_Type_Id__c = 'UK_Restaurant_Operations', Type__c = 'Process');
            Business_Config__c c14 = new Business_Config__c(Business_Rule_Name__c = 'NegativeStageProbability', Business_Rule_Value__c = 'Onboarding Failed;0', Id_Country__c = testCountryUK.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'RestaurantCareClosingAction', Record_Type_Id__c = 'UK_Restaurant_Operations', Type__c = 'Process');
            Business_Config__c c15 = new Business_Config__c(Business_Rule_Name__c = 'Type', Business_Rule_Value__c = 'Onboarding', Id_Country__c = testCountryUK.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'RestaurantCareClosingAction', Record_Type_Id__c = 'UK_Restaurant_Operations', Type__c = 'Process');
            Business_Config__c c16 = new Business_Config__c(Business_Rule_Name__c = 'closingReasonPositive', Business_Rule_Value__c = 'Successful,Take Online', Id_Country__c = testCountryUK.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'RestaurantCareClosingAction', Record_Type_Id__c = 'UK_Restaurant_Operations', Type__c = 'Process');
            Business_Config__c c19 = new Business_Config__c(Business_Rule_Name__c = 'closingReason', Business_Rule_Value__c = '{"Positive":"Successful,Take Online","Negative":"Invalid,Not Successful"}', Id_Country__c = testCountryUK.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'RestaurantCareClosingAction', Record_Type_Id__c = 'UK_Restaurant_Operations', Type__c = 'Process');
            Business_Config__c c17 = new Business_Config__c(Business_Rule_Name__c = 'chkAssetStatus', Business_Rule_Value__c = 'true', Id_Country__c = testCountryUK.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'RestaurantCareClosingAction', Record_Type_Id__c = 'UK_Restaurant_Operations', Type__c = 'Process');
            Business_Config__c c18 = new Business_Config__c(Business_Rule_Name__c = 'AssetStatus', Business_Rule_Value__c = 'Activated Successfully', Id_Country__c = testCountryUK.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'RestaurantCareClosingAction', Record_Type_Id__c = 'UK_Restaurant_Operations', Type__c = 'Process');
            Business_Config__c c20 = new Business_Config__c(Business_Rule_Name__c = 'CaseReason', Business_Rule_Value__c = 'Onboarding', Id_Country__c = testCountryUK.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'RestaurantCareClosingAction', Record_Type_Id__c = 'UK_Restaurant_Operations', Type__c = 'Process');

            Business_Config__c c21 = new Business_Config__c(Business_Rule_Name__c = 'AssetFieldstoSynch', Business_Rule_Value__c = 'Status__c,SIM_Activated__c,SIM_Card_Provider__c,SIM_Id__c,Termination_Date__c,Activation_Date__c,Stock_Item_Serial_No__c', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'SharedAssetDataSynch', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');

            Business_Config__c c22 = new Business_Config__c(Business_Rule_Name__c = 'AssetStatusMenuProcesing', Business_Rule_Value__c = '["Delivered"]', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'StatusObjectsByStage', Record_Type_Id__c = 'General_Config', Type__c = 'Process');
            Business_Config__c c23 = new Business_Config__c(Business_Rule_Name__c = 'BrandingStatusMenuProcesing', Business_Rule_Value__c = '["Delivered"]', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'StatusObjectsByStage', Record_Type_Id__c = 'General_Config', Type__c = 'Process');

            Business_Config__c c24 = new Business_Config__c(Business_Rule_Name__c = 'AssetStatusOnBoarding', Business_Rule_Value__c = '["Activated Successfully","Replaced"]', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'StatusObjectsByStage', Record_Type_Id__c = 'General_Config', Type__c = 'Process');
            Business_Config__c c25 = new Business_Config__c(Business_Rule_Name__c = 'BrandingStatusOnBoarding', Business_Rule_Value__c = '["Installed successfully"]', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'StatusObjectsByStage', Record_Type_Id__c = 'General_Config', Type__c = 'Process');



            insert new List<sObject> {c19, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, q14, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18,c20, c21, c22, c23, c24, c25};
            businessConfig = UnitTestDataFactory.createBusinessConfig('Custom Report Settings', 'Process', 'createAdditionalChargeShadow', 'true', testCountry.Id, 'Yogiyo_Additional_Charges', true, true);

            insert businessConfig;
            productGroups = UnitTestDataFactory.createProductGroups(company, testCountry, 10, 'Yogiyo_List_Product_Group');
            productGroupsUK = UnitTestDataFactory.createProductGroups(companyUK, testCountryUK, 10, 'UK_List_Product_Group');

            List<Account> accList = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
            List<Account> accListUK = UnitTestDataFactory.createAccounts(1, testCountryUK, 'UK_Account');




            List<sObject> objectsToInsert = new List<sObject>();
            objectsToInsert.addAll((List<sObject>)productGroups);
            objectsToInsert.addAll((List<sObject>)accList);
            objectsToInsert.addAll((List<sObject>)productGroupsUK);
            objectsToInsert.addAll((List<sObject>)accListUK);
            // objectsToInsert.add((sObject)businessConfig);
            insert objectsToInsert;
            accListUK[0].name = 'test uk acc';
            update accListUK;

            products = UnitTestDataFactory.createProducts(company, testCountry, productGroups[0].Id, 10, 'Yogiyo_List_Product_Price', 1, true, 299, 1, true, 10);
            products = UnitTestDataFactory.createProducts(company, testCountry, productGroups[0].Id, 10, 'Yogiyo_List_Product_Price', 1, true, 299, 1, true, 10);

            List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList, 2, 'Yogiyo_Opportunity', Date.today());
            List<Opportunity> oppListUK = UnitTestDataFactory.createOpportunities(accListUK, 1, 'UK_Opportunity', Date.today());
            List<sObject> objectsToInsert1 = new List<sObject>();
            objectsToInsert1.addAll((List<sObject>)products);
            objectsToInsert1.addAll((List<sObject>)oppList);
            objectsToInsert1.addAll((List<sObject>)oppListUK);
            insert objectsToInsert1;

            quotes = UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1, 'Yogiyo_Opportunity_Quote', 'draft', 'TEST', 100, 100, 'Test', 'Test', 10);
            quotesUK = UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1, 'UK_Opportunity_Quote', 'draft', 'TEST', 100, 100, 'Test', 'Test', 10);
            objectsToInsert = new List<sObject>();
            objectsToInsert.addAll((List<sObject>)quotes);
            objectsToInsert.addAll((List<sObject>)quotesUK);
            insert objectsToInsert;

            assetList = UnitTestDataFactory.createAssets(3, accList[0], oppList[0], Date.today().addDays(-10), true, null, null, 'Yogiyo_Asset',
                        '12345674', '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'Exchange Requested',
                        Date.today().addDays(20), 'Yazi Logistics', '1234', 'none');
            assetListUK = UnitTestDataFactory.createAssets(3, accListUK[0], oppListUK[0], Date.today().addDays(-10), true, null, null, 'UK_Asset',
                          '12345674', '1', '1', Date.today(), Date.today(), 'En Route', true, 'New', 'Shared Information', 'Take over Information', 'Awaiting Shipping',
                          null, 'Yazi Logistics', '1234', 'none');
            objectsToInsert = new List<sObject>();
            objectsToInsert.addAll((List<sObject>)assetList);
            objectsToInsert.addAll((List<sObject>)assetListUK);
            insert objectsToInsert;

            sourceAssetList = UnitTestDataFactory.createAssets(2, accList[0], oppList[0], Date.today().addDays(-10), true, null, null, 'Yogiyo_Asset',
                    '12345674', '1', '1', null, null, '', true, '', 'Shared Information', 'Take over Information', 'Delivered',
                    Date.today().addDays(20), '', '', 'none');
            objectsToInsert = new List<sObject>();
            objectsToInsert.addAll((List<sObject>)sourceAssetList);
            insert objectsToInsert;

            takeoverAssets = UnitTestDataFactory.createAssets(1,accList[0], oppList[0], Date.today().addDays(-10), true, null, null, 'Yogiyo_Asset',
                    '12345674', '1', '1', null, null, '', true, '', 'Shared Information', 'Take over Information', 'Delivered', 'Takeover',
                    Date.today().addDays(20), '', '', 'none');
            objectsToInsert = new List<sObject>();
            objectsToInsert.addAll((List<sObject>)takeoverAssets);
            insert objectsToInsert;

            sharingAssets = UnitTestDataFactory.createAssets(1, accList[0], oppList[1], Date.today().addDays(-10), true, null, null, 'Yogiyo_Asset',
                    '12345674', '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'Exchange Requested', 'Sharing' ,
                    Date.today().addDays(20), 'Yazi Logistics', '1234', 'none');
            objectsToInsert = new List<sObject>();
            objectsToInsert.addAll((List<sObject>)sharingAssets);
            insert objectsToInsert;


            stockList = UnitTestDataFactory.createStockItems(4, 'Yogiyo_Stock_Item', accList[0], null, 'A1 - New used', Date.today(), Date.today().addDays(10), Date.today().addDays(-30), '1234567890', '1234567890', 'Korea Telekom', 'In Stock', 'Other');
            stockListUK = UnitTestDataFactory.createStockItems(4, 'UK_Stock_Item', accList[0], null, 'A1 - New used', Date.today(), Date.today().addDays(10), Date.today().addDays(-30), '1234567890', '1234567890', 'UK Telekom', 'In Stock', 'Other');
            objectsToInsert = new List<sObject>();
            objectsToInsert.addAll((List<sObject>)stockList);
            objectsToInsert.addAll((List<sObject>)stockListUK);
            insert objectsToInsert;


            assets = UnitTestDataFactory.createAssets(10, accList[0], oppList[0], Date.today().addDays(-10), true, stockList[0], stockList[1], 'Yogiyo_Asset', '12345674',
                     '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'Exchange Requested',
                     Date.today().addDays(20), 'Yazi Logistics', '1234', 'none');
            assetsUK = UnitTestDataFactory.createAssets(10, accListUK[0], oppListUK[0], Date.today().addDays(-10), true, stockList[0], stockList[1], 'UK_Asset', '12345674',
                       '1', '1', Date.today(), Date.today(), 'En Route', true, 'New', 'Shared Information', 'Take over Information', 'Awaiting Shipping',
                       Date.today().addDays(20), 'Yazi Logistics', '1234', 'none');
            objectsToInsert = new List<sObject>();
            objectsToInsert.addAll((List<sObject>)assets);
            objectsToInsert.addAll((List<sObject>)assetsUK);
            insert objectsToInsert;


            additionalCharges = UnitTestDataFactory.createAdditionalCharges(accList[0], assets[0], oppList[0], quotes[0], products[0], productGroups[0], '100', 1, 100, 1, 100, 10, 'Yogiyo_Additional_Charges__c', null);
            insert additionalCharges;
        }
    }

    @isTest static void checkIfAssetIsUsedTest_check() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'unittestclassuser@deliveryhero.com', 'Yogiyo', 'KR');
        Test.startTest();
        setupUserData(testUser);

        System.runAs(testUser) {
            Account testAccount = [SELECT Id, Relay_Method__c FROM Account WHERE Name = 'Test Account_0'];

            testAccount.Relay_Method__c = 'Terminal';
            update testAccount;



            List<Asset__c> listAsset = [SELECT Id, Is_Active__c FROM Asset__c WHERE Account__c = : testAccount.Id];

            System.assertEquals(true, listAsset[0].Is_Active__c);
        }
        Test.stopTest();
    }

    @isTest static void checkIfAssetIsUsedTest_uncheck() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'unittestclassuser@deliveryhero.com', 'Yogiyo', 'KR');
        setupUserData(testUser);

        Test.startTest();

        System.runAs(testUser) {
            Account testAccount = [SELECT Id, Relay_Method__c FROM Account WHERE Name = 'Test Account_0'];

            testAccount.Relay_Method__c = 'Terminal';
            update testAccount;

            testAccount.Relay_Method__c = 'Email';
            update testAccount;



            List<Asset__c> listAsset = [SELECT Id, Is_Active__c FROM Asset__c WHERE Account__c = : testAccount.Id];

            //System.assertEquals(false, listAsset[0].Is_Active__c);
        }
        Test.stopTest();


    }

    @isTest static void test_method_one() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'unittestclassuser@deliveryhero.com', 'Yogiyo', 'KR');
        Test.startTest();
        setupUserData(testUser);
        System.runAs(testUser) {
            assetList[0].Stock_Item__c = stockList[0].id;
            update assetList[0];
        }
        Test.stopTest();

        Stock_Item__c result = [select id, status__c from Stock_Item__c where id = :stockList[0].id];
        System.assertEquals(result.status__c, 'Assigned');
    }

    @isTest static void test_method_two() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'unittestclassuser@deliveryhero.com', 'Yogiyo', 'KR');
        Test.startTest();
        setupUserData(testUser);
        System.runAs(testUser) {
            assetList[1].Stock_Item__c = stockList[1].id;
            update assetList[1];
            assetList[1].Stock_Item__c = null;
            update assetList[1];
        }
        Test.stopTest();

        Stock_Item__c result = [select id, status__c from Stock_Item__c where id = :stockList[1].id];

        // commented below lines for SP-413
        //System.assertEquals(result.status__c,'In Stock');

        System.assertEquals(result.status__c, 'Assigned');
    }

    @isTest static void test_method_three() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'unittestclassuser@deliveryhero.com', 'Yogiyo', 'KR');
        Test.startTest();
        setupUserData(testUser);
        System.runAs(testUser) {
            assetList[2].Stock_Item__c = stockList[2].id;
            update assetList[2];
            assetList[2].Stock_Item__c = stockList[3].id;
            update assetList[2];
        }
        Test.stopTest();

        Stock_Item__c result = [select id, status__c from Stock_Item__c where id = :stockList[3].id];
        System.assertEquals(result.status__c, 'Assigned');
    }

    @isTest static void test_additionalShadow_update_noChange() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'unittestclassuser@deliveryhero.com', 'Yogiyo', 'KR');
        Test.startTest();
        setupUserData(testUser);
        System.runAs(testUser) {
            update assets;
        }
        Test.stopTest();

        List<Additional_Charge_Shadow__c> acs = [SELECT Id, Additional_Charge__c, Ac_Name__c, AC_Total_Amount__c, AC_Termination_Date__c, AC_Termination_Reason__c, Account_Id__c, Account_Name__c, Account_Company_Number__c, Opportunity_Amount__c, Asset_Id__c, Asset_Name__c, StockItem_Id__c, StockItem_Name__c, StockItem_Simcard_Number__c FROM Additional_Charge_Shadow__c];

        System.assertEquals(10, acs.size());
        System.assertEquals(acs[0].Additional_Charge__c, additionalCharges[0].Id);
        System.assertEquals(acs[0].Asset_Id__c, assets[0].Id);
        System.assertEquals(acs[0].Asset_Name__c, assets[0].Name);
        System.assertEquals(acs[0].StockItem_Id__c, stockList[0].Id);
        System.assertEquals(acs[0].StockItem_Name__c, stockList[0].Name);
    }

    @isTest static void test_method_update_positive_Change() { // Means stockItem is changed but not removed fromm asset
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'unittestclassuser@deliveryhero.com', 'Yogiyo', 'KR');
        Test.startTest();
        setupUserData(testUser);
        /* Since you have 10 shadow objects created with thesame asset, modifying one asset will moify only one of these shadow objects. An asset can only be linked to a single
         * additional charge and hence only to one additional charge shadow object. So it is enough to determine that the stock item on one of the shadow objects change when
         * the stock item on the asset changes.
        */
        Boolean stockItemHasChanged = false;
        System.runAs(testUser) {
            Asset__c asst = [SELECT Id, Name, Stock_Item__c FROM Asset__c WHERE Id = : assets[0].Id];
            asst.Stock_Item__c = stockList[1].Id;
            update asst;
        }
        Test.stopTest();

        List<Additional_Charge_Shadow__c> acs = [SELECT Id, Additional_Charge__c, Ac_Name__c, AC_Total_Amount__c, AC_Termination_Date__c, AC_Termination_Reason__c, Account_Id__c, Account_Name__c, Account_Company_Number__c, Opportunity_Amount__c, Asset_Id__c, Asset_Name__c, StockItem_Id__c, StockItem_Name__c, StockItem_Simcard_Number__c FROM Additional_Charge_Shadow__c];

        System.assertEquals(10, acs.size());
        System.assertEquals(acs[0].Additional_Charge__c, additionalCharges[0].Id);
        System.assertEquals(acs[0].Asset_Id__c, assets[0].Id);
        System.assertEquals(acs[0].Asset_Name__c, assets[0].Name);
        System.debug('@@@@ stockList[1].Id) : ' + stockList[1].Id);
        for (Additional_Charge_Shadow__c addcs : acs) {
            System.debug('@@@@ stockList[1].Id) addcs : ' + addcs.StockItem_Id__c);
            if (addcs.StockItem_Id__c.equals(stockList[1].Id)) {
                stockItemHasChanged = true;
                break;
            }
        }
        System.assertEquals(true, stockItemHasChanged);
    }

    @isTest static void test_method_update_negative_Change() { // Means stockItem is removed from the asset completely
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'unittestclassuser@deliveryhero.com', 'Yogiyo', 'KR');
        Test.startTest();
        setupUserData(testUser);
        /* Since you have 10 shadow objects created with thesame asset, modifying one asset will moify only one of these shadow objects. An asset can only be linked to a single
         * additional charge and hence only to one additional charge shadow object. So it is enough to determine that the stock item on one of the shadow objects change when
         * the stock item on the asset changes.
        */
        Boolean stockItemHasChanged = false;
        System.runAs(testUser) {
            Asset__c asst = [SELECT Id, Name, Stock_Item__c FROM Asset__c WHERE Id = : assets[0].Id];
            asst.Stock_Item__c = null;
            update asst;
        }
        Test.stopTest();

        List<Additional_Charge_Shadow__c> acs = [SELECT Id, Additional_Charge__c, Ac_Name__c, AC_Total_Amount__c, AC_Termination_Date__c, AC_Termination_Reason__c, Account_Id__c, Account_Name__c, Account_Company_Number__c, Opportunity_Amount__c, Asset_Id__c, Asset_Name__c, StockItem_Id__c, StockItem_Name__c, StockItem_Simcard_Number__c FROM Additional_Charge_Shadow__c];


        System.assertEquals(10, acs.size());
        System.assertEquals(acs[0].Additional_Charge__c, additionalCharges[0].Id);
        System.assertEquals(acs[0].Asset_Id__c, assets[0].Id);
        System.assertEquals(acs[0].Asset_Name__c, assets[0].Name);

        for (Additional_Charge_Shadow__c addcs : acs) {
            if (addcs.StockItem_Id__c == null) {
                stockItemHasChanged = true;
                break;
            }
        }
        System.assertEquals(true, stockItemHasChanged);
    }

    @isTest static void test_stockItemFollowUp_Positive() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'unittestclassuser@deliveryhero.com', 'Yogiyo', 'KR');

        Test.startTest();

        System.runAs(testUser) {

            setupUserData(testUser);
            Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c = 'Status', Business_Rule_Value__c = 'Returned Shipment', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'StockItemFollowUp', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c = 'StockFollowUpCase', Business_Rule_Value__c = 'RecordTypeId=' + mapRecordTypes.get('Yogiyo_Internal_Case').id + ',type=Stock Item Follow Up,subject=Terminal termination,status=New', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'StockItemFollowUp', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            insert new List<sObject> {b1, b2};
            Asset__c asst = [SELECT Id, Name, status__c, Opportunity__c, Stock_Item__c FROM Asset__c WHERE Id = : assets[0].Id];

            asst.status__c = 'Returned Shipment';
            update asst;
            List<Case> csList = [select id from Case where Opportunity__c = :asst.Opportunity__c];
            //System.assertEquals(csList.size(), 1);

        }
        Test.stopTest();

    }

    @isTest static void test_stockItemFollowUp_Negative() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'unittestclassuser@deliveryhero.com', 'Yogiyo', 'KR');

        Test.startTest();

        System.runAs(testUser) {
            setupUserData(testUser);
            Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c = 'Status', Business_Rule_Value__c = 'Returned Shipment', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'StockItemFollowUp', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c = 'StockFollowUpCase', Business_Rule_Value__c = 'RecordTypeId=' + mapRecordTypes.get('Yogiyo_Internal_Case').id + ',type=Stock Item Follow Up,subject=Terminal termination,status=New', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'StockItemFollowUp', Record_Type_Id__c = 'Yogiyo_Asset', Type__c = 'Process');
            insert new List<sObject> {b1, b2};
            Asset__c asst = [SELECT Id, Name, status__c, Opportunity__c, Stock_Item__c FROM Asset__c WHERE Id = : assets[0].Id];

            asst.status__c = 'Exchange Requested';
            update asst;
            List<Case> csList = [select id from Case where Opportunity__c = :asst.Opportunity__c];
            System.assertEquals(csList.size(), 0);
        }
        Test.stopTest();

    }

    @isTest static void test_assetStockProcess_positive() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'unittestclassuser@deliveryhero.com', 'Yogiyo', 'KR');
        setupUserData(testUser);
        Asset__c asst = [SELECT Id, Name, status__c, Opportunity__c, Stock_Item__c FROM Asset__c WHERE Id = : assets[0].Id];

        Test.startTest();

        System.runAs(testUser) {
            asst.status__c = 'Canceled';
            update asst;
        }

        Test.stopTest();
        Asset__c asstResult = [SELECT Replaced_Stock_Item__c, Return_Status__c, Stock_Item__c FROM Asset__c WHERE Id = : assets[0].Id];
        // System.assertEquals(asstResult.Return_Status__c,'Arrange Pick up');
        System.assertNotEquals(asstResult.Replaced_Stock_Item__c, null);
        System.assertEquals(asstResult.Stock_Item__c, null);
    }

    @isTest static void test_resetAllReturnFields_positive() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'unittestclassuser@deliveryhero.com', 'Yogiyo', 'KR');

        Test.startTest();

        System.runAs(testUser) {
            setupUserData(testUser);
            Asset__c asst = [SELECT Id, Name, status__c, Replaced_Stock_Item__c, Opportunity__c, Stock_Item__c FROM Asset__c WHERE Id = : assets[0].Id];
            asst.status__c = 'Canceled';
            update asst;
            asst = [SELECT Id, Name, status__c, Replaced_Stock_Item__c, Opportunity__c, Stock_Item__c FROM Asset__c WHERE Id = : assets[0].Id];

            asst.Replaced_Stock_Item__c = null;
            update asst;
        }

        Test.stopTest();
        Asset__c asstResult = [SELECT Replaced_Stock_Item__c, Return_Status__c, Stock_Item__c FROM Asset__c WHERE Id = : assets[0].Id];
        System.debug('asstResult: ' + asstResult);
        //System.assertEquals(asstResult.Return_Status__c,null);
        System.assertEquals(asstResult.Replaced_Stock_Item__c, null);
        System.assertEquals(asstResult.Stock_Item__c, null);
        //  System.assertEquals(asstResult.Retour_Shipping_Company__c,null);

    }

    @isTest static void test_assetStockProcessInShipment_positive() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'unittestclassuser@deliveryhero.com', 'Yogiyo', 'KR');
        setupUserData(testUser);

        Asset__c asst = [SELECT Id, Name, status__c, Opportunity__c, Stock_Item__c FROM Asset__c WHERE Id = : assets[0].Id];
        Id stockId =  assets[0].Stock_Item__c;
        Test.startTest();

        System.runAs(testUser) {
            asst.status__c = 'Canceled';
            update asst;
        }

        Test.stopTest();
        Stock_Item__c stResult = [SELECT id, status__c FROM Stock_Item__c WHERE Id = : stockId];
        //System.assertEquals(stResult.status__c,'In Shipment');
    }


    @isTest static void test_assetStatusUpdateProcess() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'unittestclassuser@deliveryhero.com', 'Yogiyo', 'KR');

        Test.startTest();
        System.runAs(testUser) {

            setupUserData(testUser);


            Asset__c asst = [SELECT Id, Name, status__c, Opportunity__c, Stock_Item__c FROM Asset__c WHERE Id = : assets[0].Id];
            List<Asset__c> listAss = new List<Asset__c>();

            for (Asset__c ast : [select id, status__c from Asset__c where Opportunity__c = :asst.Opportunity__c and id != :asst.id]) {
                ast.status__c = 'Activated Successfully';
                ast.Source_Asset__c = asst.id;
                listAss.add(ast);
            }
            update listAss;
            Opportunity opp = new Opportunity(id = asst.Opportunity__c, type = 'Product Only');
            update opp;

            asst.status__c = 'Activated Successfully';
            update asst;
            List<Opportunity> result = [select id, stageName from Opportunity where id = : opp.id];
        }
        Test.stopTest();

        // System.assertEquals(result[0].stageName,'Closed Won');
    }

    @isTest static void test_assetStatusUpdateProcess2() {
        User testUser = UnitTestDataFactory.createUser('System Administrator', 'test@deliveryhero.com','Hungryhouse', 'UK');


        Test.startTest();

        System.runAs(testUser) {


            setupUserData(testUser);


            Asset__c asst = [SELECT Id, Name, status__c, Opportunity__c, account__c, Stock_Item__c FROM Asset__c WHERE Id = : assetsUK[0].Id];
            List<Asset__c> assets = [Select Retour_Date__c from Asset__c];
            for(Asset__c asset : assets){
            	asset.retour_Date__c = null;
            }
            update assets;
            
            Case OnboardingCase = new Case(
                    accountId = asst.account__c,
                Type = 'Onboarding',
                RecordTypeId = mapRecordtypes.get('UK_Restaurant_Operations').id,
                Status = 'New'
            );
            insert OnboardingCase;

            //terminationCase.Status = 'In retention';
            OnboardingCase.Status = 'Closed';
            onboardingCase.Accountid = asst.account__c;
            OnboardingCase.opportunity__c = asst.Opportunity__c;
            OnboardingCase.Closed_Reason__c = 'Successful';
            OnboardingCase.Case_Reason__c='Onboarding';
            update OnboardingCase;

            asst.status__c = 'Activated Successfully';
            update asst;
            system.debug('assetsUK[0].Opportunity__c-->'+asst.Opportunity__c);
            List<Opportunity> result = [select id, stageName from Opportunity where id = : asst.Opportunity__c];
            System.assertNotEquals(result[0].stageName, 'Closed Won');
        }
        Test.stopTest();

    }
    @isTest static void test_takeoverSharingAssetUpdate() {
        User testUser = UnitTestDataFactory.createUser('System Administrator', 'test@deliveryhero.com','Hungryhouse', 'UK');

        Test.startTest();

        System.runAs(testUser) {

            setupUserData(testUser);

            Asset__c takeoverAsset = [SELECT Id, Name, status__c, Type__c, Source_Asset__c FROM Asset__c WHERE Id = : takeoverAssets[0].Id];
            takeoverAsset.Source_Asset__c = sourceAssetList[0].Id;
            update takeoverAsset;

            Asset__c updatedSourceAsset = [SELECT Id, Name, status__c FROM Asset__c WHERE Id = : sourceAssetList[0].Id];
            Asset__c updatedtakeoverAsset = [SELECT Id, Name, status__c, Type__c, Source_Asset__c FROM Asset__c WHERE Id = : takeoverAssets[0].Id];

            System.assertEquals(updatedtakeoverAsset.Status__c, sourceAssetList[0].Status__c);
            System.assertEquals(updatedtakeoverAsset.Type__c, 'Original');
            System.assertEquals(updatedSourceAsset.Status__c, 'Taken Over');

            Asset__c sharingAsset = [SELECT Id, Name, status__c, Opportunity__c, account__c, Stock_Item__c, Source_Asset__c, SIM_Id__c FROM Asset__c WHERE Id = : sharingAssets[0].Id];
            sharingAsset.Source_Asset__c = sourceAssetList[1].Id;
            update sharingAsset;

            Asset__c sourceAsset = [SELECT Id, Name, status__c, Opportunity__c, account__c, Stock_Item__c, Source_Asset__c, SIM_Id__c FROM Asset__c WHERE Id = : sourceAssetList[1].Id];
            sourceAsset.SIM_Id__c = '1231231211';
            update sourceAsset;

            Asset__c sharingAssetQuery = [SELECT Id, Name, status__c, Opportunity__c, account__c, Stock_Item__c, Source_Asset__c, SIM_Id__c FROM Asset__c WHERE Id = : sharingAsset.Id];

            System.assertEquals(sharingAsset.SIM_Id__c, sharingAssetQuery.SIM_Id__c);
        }

        Test.stopTest();

    }
}