/**
 * Created by danish.farooq on 7/1/20.
 * @description test class ClsRestAssetUpdAfterShip
 */

@IsTest
private class ClsRestAssetUpdAfterShip_Test {

    private static Account accountObj;
    private static Country__c countryObj;
    private static Map<String,RecordType> mapRecordTypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Account','Contact','Asset__C'});
    public static string msg = '';

    @testSetup
    public static void testSetup(){

        countryObj = UnitTestDataFactory.createCountry('FP', Constants.COUNTRY_NAME_MALAYSIA, 'MYR');

        Company__c com = UnitTestDataFactory.createCompany('FP', 'FP', countryObj);
        insert new List<sObject> {countryObj,com};

        UnitTestDataFactory.getRecordtypeValues();

        accountObj = UnitTestDataFactory.createAccount('TestAccount', countryObj, Constants.FP_ACCOUNT_DEVELOPERNAME);
        accountObj.Record_Country__c = Constants.COUNTRY_NAME_MALAYSIA;
        accountObj.phone = '+6012345678';
        insert accountObj;

        Contact conObj = new Contact(lastname='test',
                contact_role__c='Owner',
                accountid=accountObj.id,
                email='test@test.com',
                mobilephone='+6012345678',
                recordtypeid= mapRecordTypes.get(constants.FP_CONTACT_DEVELOPERNAME).id);

        insert conObj;

        List<Opportunity> fpOpportunity = UnitTestDataFactory.createOpportunities(new List<Account> { accountObj }, 1, Constants.FP_OPPORTUNITY_DEVELOPERNAME, Date.today().addMonths(2));
        insert fpOpportunity;

        List<Stock_Item__c> stockItems = UnitTestDataFactory.createStockItems(2, 'FP_Stock_Item', accountObj, null, 'A1 - New used', Date.today(), Date.today().addDays(10), Date.today().addDays(-30), '1234567890', '1234567890', 'Korea Telekom', 'In Stock', 'Other');
        insert stockItems;

        List<Asset__c> lstAssets = UnitTestDataFactory.createAssets(10, accountObj, fpOpportunity[0], Date.today().addDays(-10), true, stockItems[0], stockItems[1], 'FP_Asset', '12345674',
                '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', Constants.ASSET_STATUS_ACTIVATED_SUCCESSFULLY ,
                Date.today().addDays(20), 'Yazi Logistics', '1234', 'none');
        lstAssets[0].tracking_active__c = true;
        lstAssets[0].tracking_number__c = '73658';
        lstAssets[0].aftership_id__c = '1234';
        insert lstAssets;

    }

    @IsTest
    static void testPostCallout_Exception() {

        ClsRestShippingOrderUpdAftership.Tracker trackerObj = new ClsRestShippingOrderUpdAftership.Tracker();
        ClsRestShippingOrderUpdAftership.CheckPoint checkPointObj = new  ClsRestShippingOrderUpdAftership.CheckPoint();
        checkPointObj.message = Constants.ASSET_TAG_EXCEPTION;
        checkPointObj.tag = Constants.ASSET_TAG_EXCEPTION;

        trackerObj.Id = '1234';
        trackerObj.tracking_ship_date = Date.today();
        trackerObj.updated_at = Datetime.Now();
        trackerObj.expected_delivery = string.valueOf(Datetime.Now());
        trackerObj.tracking_number = '73658';
        trackerObj.tag = Constants.ASSET_TAG_EXCEPTION;
        trackerObj.checkpoints = new List<ClsRestShippingOrderUpdAftership.CheckPoint> { checkPointObj };

        msg = JSON.serialize(trackerObj);
        msg = '{"msg":' + msg + '}';

        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri ='services/apexrest/UpdateAssetStatus';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(msg);
        RestContext.request = request;
        ClsRestAssetUpdAfterShip.updateAssetStatus();
        test.stopTest();

        List<Asset__c> lstAsset = [Select ID FROM Asset__c WHERE
                                   Tracking_Exception__c =: Constants.ASSET_TAG_EXCEPTION ];

        System.assertEquals(1,lstAsset.size());

    }

    @IsTest
    static void testPostCallout_Delivered() {

        ClsRestShippingOrderUpdAftership.Tracker trackerObj = new ClsRestShippingOrderUpdAftership.Tracker();
        ClsRestShippingOrderUpdAftership.CheckPoint checkPointObj = new  ClsRestShippingOrderUpdAftership.CheckPoint();
        checkPointObj.message = Constants.ASSET_TAG_DELIVERED;
        checkPointObj.tag = Constants.ASSET_TAG_DELIVERED;

        Datetime currentDatetime = Datetime.Now();
        trackerObj.Id = '1234';
        trackerObj.tracking_ship_date = Date.today();
        trackerObj.updated_at =currentDatetime;
        trackerObj.expected_delivery = string.valueOf(Datetime.Now());
        trackerObj.tracking_number = '73658';
        trackerObj.tag = Constants.ASSET_TAG_DELIVERED;
        trackerObj.checkpoints = new List<ClsRestShippingOrderUpdAftership.CheckPoint> { checkPointObj };

        msg = JSON.serialize(trackerObj);
        msg = '{"msg":' + msg + '}';

        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri ='services/apexrest/UpdateAssetStatus';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(msg);
        RestContext.request = request;
        ClsRestAssetUpdAfterShip.updateAssetStatus();
        test.stopTest();

        List<Asset__c> lstAsset = [Select ID FROM Asset__c WHERE
                Last_Tracking_Update__c =: currentDatetime ];

        System.assertEquals(1,lstAsset.size());
    }
}