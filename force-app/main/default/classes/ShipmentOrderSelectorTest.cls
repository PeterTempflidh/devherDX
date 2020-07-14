/**
 * @author Konrad Czykin
 * @date 30.06.2020
 * @description  Test class for ShipmentOrderSelector
 */
@isTest
private class ShipmentOrderSelectorTest {

    private static List<Account> lstAccounts;
    private static country__c country;
    private static Opportunity opp;
    private static Company__c company;
    private static List<Opportunity_Quote_Line_Item__c> oqp;
    private static List_Product_Price__c lpp;
    private static Opportunity_Quote__c newQuote;

    //CREATE DATA FOR TESTS METHODS
    @testSetup
    static void setup(){
        UnitTestDataFactory.getRecordtypeValues();
        country = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'HKD');
        insert country;
        company = UnitTestDataFactory.createCompany('FoodPanda', 'FoodPanda', country);
        insert company;
        lstAccounts = UnitTestDataFactory.createAccounts(2, country, 'FP_Account');
        insert lstAccounts;

        opp = UnitTestDataFactory.createOpportunity('TestOpp123', lstAccounts[0], 'FP_Opportunity', Date.today());
        opp.type = 'Contract & Product';
        opp.StageName = 'New';
        opp.Probability = 60;
        insert  new List<sObject> {opp};

        newQuote = new Opportunity_Quote__c(Id_Opportunity__c = opp.id, status__c = 'Draft',Id_Account__c =  lstAccounts[0].Id);
        newQuote.recordtypeid = LibRecordTypeHelper.getRecordTypeValue('FP_Opportunity_Quote');
        insert newQuote;

        Tarif__c t = UnitTestDataFactory.createTarif(company, country, 'Menu Printing', 'FP_Tarif', false);
        insert t;

        List_Add_on__c lao = new List_Add_on__c(Is_Active__c=true,Type__c='Deal / Promotion',Company__c=company.id,id_country__c=country.id,name='Test add on');
        lao.recordtypeid=LibRecordTypeHelper.getRecordTypeValue('FP_List_Add_On');

        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(company, country, 'Apple', 'FP_List_Product_Group');
        insert new List<SObject> {lao,lpg};

        lpp = UnitTestDataFactory.createProduct(company, country , 'Menu Printing with website', lpg.id, 'FP_List_Product_Price', 1, true, 100, 1, false, 20);

        lpp.product_type__c = 'Menu Printing';
        lpp.Requires_Branding__c = true;
        lpp.Requires_Asset__c = true;

        insert new List<sobject> { lpp};

        oqp = UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote, lpp.id, lpg.id, 4, true, 'DE_Opportunity_Quote_Line_Item', 1, '20', 200.0, 2, 300.0, 'Fee');
        oqp[0].Id_Opportunity__c = opp.id;
        oqp[0].Recordtypeid=LibRecordTypeHelper.getRecordTypeValue('FP_Opportunity_Quote_Line_Item');
        oqp[0].Delivery__c = 'Shipment';
        insert oqp;
        newQuote.status__c = 'Accepted';
        update newQuote;

        oqp = [select id,Id_Opportunity__r.AccountId,Id_Opportunity__c, Id_Opportunity_Quote__c from Opportunity_Quote_Line_Item__c];

        Shipment_Order__c ship = new Shipment_Order__c();

        ship = new Shipment_Order__c(Account__c = oqp[0].Id_Opportunity__r.AccountId,
                Opportunity__c = oqp[0].Id_Opportunity__c,
                Opportunity_Quote__c = oqp[0].Id_Opportunity_Quote__c,
                Status__c = 'Shipped',
                Shipping_Company__c = 'sf-express',
                Tracking_Number__c = '12345',
                Tracking_active__c = false
        );

        insert ship;
        
        Stock_Item__c stockItem = new Stock_Item__c(RecordTypeId= UnitTestDataFactory.getRecordType('FP_Stock_Item').Id,Name = '123456_KR');
        stockItem.Id_Account__c = lstAccounts[0].Id;
        stockItem.Status__c = 'New - In Stock';
        insert stockItem;
        
        Shipment_Order_Line_Item__c shipOrdLin = new Shipment_Order_Line_Item__c(Name = 'Test Line',
                Shipment_Order__c = ship.id,
                List_Product_Price__c = lpp.id,
                Opportunity_Quote_Line_Item__c = oqp[0].id,
                Quantity__c = 12,
                Stock_Item__c = stockItem.Id);

        insert shipOrdLin;
    }

    /**
    * @date         : 30/06/2020
    * @method name  : testGetShipmentOrderbyTrackingCorrectTrackingNumber
    * @description  : Test method of the getShipmentOrderbyTracking, correct tracking number
    */
    @isTest
    static void testGetShipmentOrderbyTrackingCorrectTrackingNumber(){

        Test.startTest();
            List<Shipment_Order__c> lstSO = ShipmentOrderSelector.getShipmentOrderbyTracking(new Set<String>{'12345'});
        Test.stopTest();
        System.assertEquals(1, lstSO.size());
        System.assertEquals('12345', lstSO[0].Tracking_Number__c);
    }

    /**
    * @date         : 30/06/2020
    * @method name  : testGetShipmentOrderbyTrackingWrongNumber
    * @description  : Test method of the getShipmentOrderbyTracking, wrong tracking number
    */
    @isTest
    static void testGetShipmentOrderbyTrackingWrongNumber(){

        Test.startTest();
            List<Shipment_Order__c> lstSO = ShipmentOrderSelector.getShipmentOrderbyTracking(new Set<String>{'54321'});
        Test.stopTest();
        System.assertEquals(0, lstSO.size());
    }

    /**
    * @date         : 30/06/2020
    * @method name  : testGetShipmentOrderbyTrackingEmptySet
    * @description  : Test method of the getShipmentOrderbyTracking, empty set of tracking numbers
    */
    @isTest
    static void testGetShipmentOrderbyTrackingEmptySet(){
        Set<String> emptySet = new Set<String>();
        Test.startTest();
            List<Shipment_Order__c> lstSO = ShipmentOrderSelector.getShipmentOrderbyTracking(emptySet);
        Test.stopTest();
        System.assertEquals(0, lstSO.size());
    }
    
    /**
    * @date         : 30/06/2020
    * @method name  : getShipmentOrderActivebyTrackingCorrectArguments
    * @description  : Test method of the getShipmentOrderActivebyTracking, correct arguments
    */
    @isTest
    static void testGetShipmentOrderActivebyTrackingCorrectArguments(){
        List<Shipment_Order__c> lstSOexist = [SELECT Id FROM Shipment_Order__c];
        lstSOexist[0].tracking_active__c = true;
        lstSOexist[0].aftership_id__c = '123456789';
        update lstSOexist;

        Test.startTest();
            List<Shipment_Order__c> lstSO = ShipmentOrderSelector.getShipmentOrderActivebyTracking('12345', '123456789');
        Test.stopTest();
        System.assertEquals(1, lstSO.size());
        System.assertEquals('12345', lstSO[0].Tracking_Number__c);
        System.assert(lstSO[0].tracking_active__c);
    }

    /**
    * @date         : 30/06/2020
    * @method name  : testGetShipmentOrderActivebyTrackingEmptyArguments
    * @description  : Test method of the getShipmentOrderActivebyTracking, empty tracking number and aftership_id
    */
    @isTest
    static void testGetShipmentOrderActivebyTrackingEmptyArguments(){
        List<Shipment_Order__c> lstSOexist = [SELECT Id FROM Shipment_Order__c];
        lstSOexist[0].tracking_active__c = true;
        lstSOexist[0].aftership_id__c = '123456789';
        update lstSOexist;

        Test.startTest();
            List<Shipment_Order__c> lstSO = ShipmentOrderSelector.getShipmentOrderActivebyTracking('', '');
        Test.stopTest();
        System.assertEquals(0, lstSO.size());
    }

    /**
    * @date         : 30/06/2020
    * @method name  : testGetShipmentOrderbyIdWithLineItemsCorrectId
    * @description  : Test method of the getShipmentOrderbyIdWithLineItems, correct argument
    */
    @isTest
    static void testGetShipmentOrderbyIdWithLineItemsCorrectId(){
        List<Shipment_Order__c> lstSOexist = [SELECT Id FROM Shipment_Order__c];

        Test.startTest();
            Shipment_Order__c shipmentOrder = ShipmentOrderSelector.getShipmentOrderbyIdWithLineItems(lstSOexist[0].Id);
        Test.stopTest();
        System.assertEquals(lstSOexist[0].Id, shipmentOrder.Id);
        System.assertEquals(1, shipmentOrder.Shipment_Order_Line_Items__r.size());

    }

    /**
    * @date         : 30/06/2020
    * @method name  : testGetOpenShipmentOrdersForAccountNotOpen
    * @description  : Test method of the getOpenShipmentOrdersForAccount, correct argument, status not equal Open
    */
    @isTest
    static void testGetOpenShipmentOrdersForAccountNotOpen(){
        List<Account> lstAcc = [SELECT Id FROM Account];

        Test.startTest();
            List<Shipment_Order__c> lstSO = ShipmentOrderSelector.getOpenShipmentOrdersForAccount(lstAcc[0].Id);
        Test.stopTest();
        System.assertEquals(0, lstSO.size());
    }

    /**
    * @date         : 30/06/2020
    * @method name  : testGetOpenShipmentOrdersForAccount
    * @description  : Test method of the getOpenShipmentOrdersForAccount, correct argument, status not equal Open
    */
    @isTest
    static void testGetOpenShipmentOrdersForAccountOpen(){
        List<Account> lstAcc = [SELECT Id FROM Account];
        List<Shipment_Order__c> lstSOexist = [SELECT Id FROM Shipment_Order__c];
        lstSOexist[0].Status__c = 'Open';
        update lstSOexist;

        Test.startTest();
            List<Shipment_Order__c> lstSO = ShipmentOrderSelector.getOpenShipmentOrdersForAccount(lstAcc[0].Id);
        Test.stopTest();
        System.assertEquals(1, lstSO.size());
    }

    /**
    * @date         : 30/06/2020
    * @method name  : testGetShipmentOrdersForAccount
    * @description  : Test method of the getShipmentOrdersForAccount, correct argument
    */
    @isTest
    static void testGetShipmentOrdersForAccountCorrectId(){
        List<Account> lstAcc = [SELECT Id FROM Account];

        Test.startTest();
            Map<Id,List<Shipment_Order__c>> mapSO = ShipmentOrderSelector.getShipmentOrdersForAccount(new Set<Id>{lstAcc[0].Id});
        Test.stopTest();
        System.assertEquals(1, mapSO.size());
        System.assertEquals(lstAcc[0].Id, mapSO.get(lstAcc[0].Id)[0].Account__c);
    }

    /**
    * @date         : 30/06/2020
    * @method name  : testGetShipmentOrdersForAccountTwoShipmentOrders
    * @description  : Test method of the getShipmentOrdersForAccount, correct argument
    */
    @isTest
    static void testGetShipmentOrdersForAccountTwoShipmentOrders(){
        List<Account> lstAcc = [SELECT Id FROM Account];
        List<Opportunity> lstOpp = [SELECT Id FROM Opportunity];
        List<Opportunity_Quote__c> lstOppQ = [SELECT Id FROM Opportunity_Quote__c];

        Shipment_Order__c ship = new Shipment_Order__c();

        ship = new Shipment_Order__c(Account__c = lstAcc[0].Id,
                Opportunity__c = lstOpp[0].Id,
                Opportunity_Quote__c = lstOppQ[0].Id,
                Status__c = 'Shipped',
                Shipping_Company__c = 'sf-express',
                Tracking_Number__c = '12345',
                Tracking_active__c = false
        );
        insert ship;
        
        Test.startTest();
            Map<Id,List<Shipment_Order__c>> mapSO = ShipmentOrderSelector.getShipmentOrdersForAccount(new Set<Id>{lstAcc[0].Id});
        Test.stopTest();
        System.assertEquals(1, mapSO.size());
        System.assertEquals(lstAcc[0].Id, mapSO.get(lstAcc[0].Id)[0].Account__c);
        System.assertEquals(2,  mapSO.get(lstAcc[0].Id).size());
    }
}