/**
 * Created by w.novoa on 20.08.2018.
 */

@IsTest
private class UnitTestClsShipmentOrderProcessor {

    private static Account acc_de;
    private static country__c c_de;
    private static Opportunity opp;
    private static Company__c com_de;
    private static case cs_de;
    private static List<Opportunity_Quote_Line_Item__c> oqp;
    private static List_Product_Price__c lpp;
    static Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Case'});
    static final String adminAreaLabel = 'admin area 1 test';
    static final String adminArea = 'aat1';
    static final String localityLabel = 'locality';
    static final String locality = 'lco';
    static final String streetLabel = 'street name';
    static final String street = 'str';
    static final String numLabel = '10';
    static final String num = '10';
    static final String zipCOdeLabel = '1010';
    static final String zipCOde = '1010';

    static {

    }

    @testSetup static void setup() {

        UnitTestDataFactory.getRecordtypeValues();

        Integration_Config__c intConfig = new Integration_Config__c();
        Integration_Config__c cs1 = new Integration_Config__c( Name = 'GoogleMapsSignature', Password__c = 'Abvcd-asdfdgfhjklhnO0=');
        insert cs1;

        intConfig.Name = 'Rhim';
        intConfig.UserName__c = 'username';
        intConfig.Password__c = 'Password';
        intConfig.ClientId__c = '1111';

        intConfig.Endpoint__c = 'https://logisticapi-staging.rhiem.com:5443/3_0_0/SalesOrders.svc';

        insert intConfig;

        List<sObject> ls = Test.loadData(Business_Config__c.sObjectType, 'BusinessConfigData');

        Business_Config__c BussConfig = new Business_Config__c(
                Business_Rule_Name__c = 'IntegrationEnable',
                Business_Rule_Value__c = 'TRUE',
                Is_Active__c = true,
                Parent__c = true,
                Process_Name__c = 'ShipmentOrders',
                Record_Type_Id__c = 'FP_Account',
                Type__c = 'Process'
        );

        insert new List<sObject> {BussConfig};


        c_de = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'HKD');
        insert c_de;
        com_de = UnitTestDataFactory.createCompany('Food Panda', 'FP', c_de);
        insert com_de;
        acc_de = UnitTestDataFactory.createAccount('TestAccount', c_de, 'FP_Account');
        acc_de.Phone = '+85227367722';
        insert acc_de;

        AddressDetail__c Add = new AddressDetail__c();


        AddressDetail__c addr = new AddressDetail__c(
                Type__c = 'Shipping Address',
                LatLng__Longitude__s = 10.0,
                LatLng__Latitude__s = 5.0,
                Account__c = acc_de.Id,

                GPA_Country_long_name__c = 'Ecuador',
                GPA_Country_short_name__c = 'EC',

                GPA_Admin_area_level_1_long_name__c = adminAreaLabel,
                GPA_Admin_area_level_1_short_name__c = adminArea,

                GPA_Locality_long_name__c = localityLabel,
                GPA_Locality_short_name__c = locality,

                GPA_Route_long_name__c = streetLabel,
                GPA_Route_short_name__c = street,

                GPA_Street_number_long_name__c = numLabel,
                GPA_Street_number_short_name__c = num,

                GPA_Postal_code_long_name__c = zipCOdeLabel,
                GPA_Postal_code_short_name__c = zipCOde,

                GPA_Place_id__c = '12344',
                GPA_formatted_address__c = 'whatever bla bla',
                GPA_Was_modified_manually__c = false
        );

        insert addr;



        opp = UnitTestDataFactory.createOpportunity('TestOpp123', acc_de, 'FP_Opportunity', Date.today());
        opp.type = 'Contract & Product';
        opp.StageName = 'New';
        opp.Probability = 60;
        insert  new List<sObject> {opp};

        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c = opp.id, status__c = 'Draft',Id_Account__c =  acc_de.id);
        newQuote.recordtypeid = LibRecordTypeHelper.getRecordTypeValue('FP_Opportunity_Quote');

        insert newQuote;
        Tarif__c t = UnitTestDataFactory.createTarif(com_de, c_de , 'Menu Printing', 'FP_Tarif', false);
        insert t;

        List_Add_on__c lao = new List_Add_on__c(Is_Active__c=true,Type__c='Deal / Promotion',Company__c=com_de.id,id_country__c=c_de.id,name='Test add on');
        lao.recordtypeid=LibRecordTypeHelper.getRecordTypeValue('FP_List_Add_On');

        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com_de, c_de , 'Apple', 'FP_List_Product_Group');
        insert new List<SObject> {lao,lpg};

        lpp = UnitTestDataFactory.createProduct(com_de, c_de , 'Menu Printing with website', lpg.id, 'FP_List_Product_Price', 1, true, 100, 1, false, 20);

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

        cs_de = new Case(Opportunity__c = opp.id, type = 'Quality Check', AccountId = acc_de.id, RecordTypeId = mapRecordtypes.get('FP_Internal_Case').id);
        insert cs_de;


        cs_de = [select id,RecordType.DeveloperName from Case where RecordType.DeveloperName = 'FP_Internal_Case' limit 1];
        oqp = [select id,Id_Opportunity__r.AccountId,Id_Opportunity__c, Id_Opportunity_Quote__c from Opportunity_Quote_Line_Item__c];

        Shipment_Order__c ship = new Shipment_Order__c();

        System.debug('oqp-->' + oqp);
        ship = new Shipment_Order__c(Account__c = oqp[0].Id_Opportunity__r.AccountId,
                Opportunity__c = oqp[0].Id_Opportunity__c,
                Opportunity_Quote__c = oqp[0].Id_Opportunity_Quote__c,
                Status__c = 'Ready to be shipped',
                Shipping_Company__c = 'sf-express'
        );

        insert ship;
        
		Stock_Item__c stockItem = new Stock_Item__c(RecordTypeId= UnitTestDataFactory.getRecordType('FP_Stock_Item').Id,Name = '123456_KR');
        stockItem.Id_Account__c = acc_de.Id;
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

    @IsTest
    static void testBehavior() {
        cs_de = [select id,RecordType.DeveloperName from Case where RecordType.DeveloperName = 'FP_Internal_Case' limit 1];

        system.debug('case-->'+cs_de.RecordType.DeveloperName);
        system.debug('Oql-->'+[Select id from Opportunity_Quote_Line_Item__c]);

        cs_de.Status = 'Closed';
        cs_de.Closed_Reason__c = 'Successful';

        List<Shipment_Order__c> lstShip = [Select id from Shipment_Order__c];
        List<Asset__c> lstAsset = new List<Asset__c>();

        Test.startTest();
        update cs_de;
        lstShip = [Select id,Tracking_Number__c,Status__c from Shipment_Order__c];
        System.assert(lstShip.size()>0);
        lstAsset = [Select id from Asset__c];
        System.assertEquals(lstAsset.size(),0);
        lstShip[0].Status__c = 'Shipped';
        lstShip[0].Tracking_Number__c = '1111';
        update lstShip;
        lstShip[0].Status__c = 'Delivered';
        update lstShip;
        Test.stopTest();
    }
    //SSC-1665
    @IsTest
    static void UpdateAccountCountryTest() {


        Account acc = [Select id,Phone, Record_Country__c from Account limit 1];
        acc.Phone = '+6012345678';
        acc.Record_Country__c = 'Malaysia';

        country__c countryObj = [Select id,name from country__c limit 1];

        Account acc_hk = UnitTestDataFactory.createAccount('TestAccount', countryObj, 'FP_Account');
        acc_hk.Phone = '+85227367722';
        acc_hk.Record_Country__c = 'Hong Kong';
        insert acc_hk;

        Test.startTest();
        update acc;
        Shipment_Order__c shpobj = [Select id,Tracking_Number__c,Status__c,Account__c,
                                    Account_Country__c from Shipment_Order__c limit 1];
        shpobj.Account__c = acc_hk.Id;
        update shpobj;

        shpobj = [Select id,Tracking_Number__c,Status__c,Account__c,
                Account_Country__c from Shipment_Order__c WHERE Id =: shpobj.Id];

        system.assertEquals('Hong Kong', shpobj.Account_Country__c);
        Test.stopTest();
    }
}
