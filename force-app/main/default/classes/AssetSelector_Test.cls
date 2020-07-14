/**
 * Created by danish.farooq on 6/25/20.
 * @description Test class for AssetSelector
 */

@IsTest
private class AssetSelector_Test {
    @testSetup
    static void setup() {

        UnitTestDataFactory.getRecordtypeValues();
        Country__c testCountryMY = UnitTestDataFactory.createCountry('MY', Constants.COUNTRY_NAME_MALAYSIA, 'MYR');
        insert testCountryMY;

        Company__c testCompanyMY = UnitTestDataFactory.createCompany('FoodPanda', 'FoodPanda', testCountryMY);
        insert testCompanyMY;

        List<Account> fpAccount = UnitTestDataFactory.createAccounts(2, testCountryMY, Constants.FP_ACCOUNT_DEVELOPERNAME);
        fpAccount[0].phone = '+6012345678';
        fpAccount[1].phone = '+6012345678';
        insert fpAccount;
        List<List_Service_Price__c> fpServices = UnitTestDataFactory.createServices(testCompanyMY, testCountryMY, 10, Constants.FP_LIST_SERVICE_PRICE_DEVELOPERNAME, 13, 13, 15, 10, 1, '% per Order', true, 299, 'Monthly', 'Commission', 'ServiceType');
        List<Contact> fpContact = UnitTestDataFactory.createContacts(fpAccount, 'testContact', 'firstname', null, 'owner', 1, 'testCt', Constants.FP_CONTACT_DEVELOPERNAME);
        List<Opportunity> fpOpportunity = UnitTestDataFactory.createOpportunities(fpAccount, 1, Constants.FP_OPPORTUNITY_DEVELOPERNAME, Date.today().addMonths(2));
        insert fpOpportunity;
        Opportunity_Line_Item__c fpoppServiceItem = UnitTestDataFactory.createOpportunityLineItemService('commission Fee',fpOpportunity[0], fpServices[0].Id, false, Constants.FP_OPPORTUNITY_LINE_ITEM_DEVELOPERNAME, 13, null, Date.today(), 'Commission Fee', null);
        insert fpoppServiceItem;
        List<Opportunity_Quote__c> fpOpportunityQuote = UnitTestDataFactory.createOpportunityQuotes(fpOpportunity[0], 1, Constants.FP_OPPORTUNITY_QUOTE_DEVELOPERNAME, 'Accepted','testdata',10, 10, null,null,0);
        insert fpOpportunityQuote;
        insert UnitTestDataFactory.createOpportunityQuoteLineItem(fpOpportunityQuote[0],fpoppServiceItem,Constants.FP_OPPORTUNITY_QUOTE_LINE_ITEM_DEVELOPERNAME);
        List<List_Add_On__c> fpAddOns   = UnitTestDataFactory.createAddOns(testCountryMY.id,testCompanyMY.id,'Test Add On','Deals','test',
                Constants.FP_LIST_ADD_ON_DEVELOPERNAME,10);

        List<Stock_Item__c> stockItems = UnitTestDataFactory.createStockItems(2, 'FP_Stock_Item', fpAccount[0], null, 'A1 - New used', Date.today(), Date.today().addDays(10), Date.today().addDays(-30), '1234567890', '1234567890', 'Korea Telekom', 'In Stock', 'Other');
        insert stockItems;



        Shipment_Order__c ship = new Shipment_Order__c();
        ship = new Shipment_Order__c(Account__c = fpOpportunity[0].AccountId,
                Opportunity__c = fpOpportunity[0].ID,
                Status__c = CONSTANTS.SHIPMENTORDER_STATUS_READY_TO_BE_SHIPPERD);

        insert ship;

        Shipment_Order_Line_Item__c shipOrdLin = new Shipment_Order_Line_Item__c(Name = 'Test Line',
                Shipment_Order__c = ship.id,
                Quantity__c = 12,
                Stock_Item__c = stockItems[0].Id);

        insert shipOrdLin;

        List<Asset__c> lstAssets = UnitTestDataFactory.createAssets(10, fpAccount[0], fpOpportunity[0], Date.today().addDays(-10), true, stockItems[0], stockItems[1], 'FP_Asset', '12345674',
                '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', Constants.ASSET_STATUS_ACTIVATED_SUCCESSFULLY ,
                Date.today().addDays(20), 'Yazi Logistics', '1234', 'none');
        lstAssets[0].Shipment_Order_Line_Item__c = shipOrdLin.ID;
        lstAssets[1].Shipment_Order__c = ship.ID;
        insert lstAssets;
    }

    @IsTest
    static void testAssetSelector() {

        test.startTest();
        Opportunity opptyObj = Opportunity_Selector.getAll()[0];
        List<Asset__c> lstAsset = AssetSelector.getAssetByStatus(new Set<Id>{ opptyObj.ID} , new Set<string> { Constants.ASSET_STATUS_ACTIVATED_SUCCESSFULLY });
        system.assertEquals(lstAsset.size(),10);
        lstAsset = AssetSelector.getActiveAssetsForAccount(opptyObj.AccountId);
        system.assertEquals(lstAsset.size(),10);
        Map<ID,Asset__c> mapOfAssetsByIds = AssetSelector.getAssetsbyId(new Set<ID> {lstAsset[0].ID});
        Asset__c assetObj = AssetSelector.getAssetDetailsById(lstAsset[0].id);
        lstAsset = AssetSelector.findActiveByAccountIds(new Set<Id> { opptyObj.AccountId });
        lstAsset = AssetSelector.getAssetsNotActivated(lstAsset, new Set<Id> {opptyObj.ID});
        system.assertEquals(lstAsset.size(),0);
        test.stopTest();
    }

    @IsTest
    static void testAssetByShipmentOrder() {

        test.startTest();
        Shipment_Order_Line_Item__c shipmentOrderLineItemObj = [Select ID,Shipment_Order__c from Shipment_Order_Line_Item__c LIMIT 1];
        Map<Id, Asset__c> mapOfAssetsByIds  = AssetSelector.getAssetsMapForShipmentOrderLineItems(new Set<Id> {shipmentOrderLineItemObj.ID});
        Map<Id, List<Asset__c>> mapOfAssetsByShipmentOrder = AssetSelector.getAssetsMapForShipmentOrders(new Set<Id> {shipmentOrderLineItemObj.Shipment_Order__c});
        system.assertEquals(mapOfAssetsByIds.size(),1);
        system.assertEquals(mapOfAssetsByShipmentOrder.size(),1);
        test.stopTest();
    }


}