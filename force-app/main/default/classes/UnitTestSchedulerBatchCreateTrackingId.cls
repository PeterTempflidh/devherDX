@isTest
private class UnitTestSchedulerBatchCreateTrackingId {

public static String CRON_EXP = '0 0 0 15 3 ? 2022';
     private static Account accounts;
     private static Country__c country;
     private static Map<String,RecordType> mapRecordTypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Account','Contact','Asset__C'});
    
	
	@testSetup 
	public static void testSetup(){
	country = UnitTestDataFactory.createCountry('FP', 'Malaysia', 'MYR');
        Company__c com = UnitTestDataFactory.createCompany('FP', 'FP', country);
        insert new List<sObject> {country,com};
        UnitTestDataFactory.getRecordtypeValues();
        accounts = UnitTestDataFactory.createAccount('TestAccount', country, 'FP_Account');
        accounts.Record_Country__c = 'Malaysia';
        accounts.phone = '+6012345678';
        insert accounts;
        Contact cn = new Contact(lastname='test',
                               contact_role__c='Owner',
                               accountid=accounts.id, 
                               email='test@test.com', 
                                mobilephone='+6012345678',
                                recordtypeid=mapRecordTypes.get('FP_Contact').id);

        Shipment_Order__c ast1= new Shipment_Order__c(tracking_number__c='73658',
                                   status__c='Shipped',
                                   Account__c=accounts.id,
                                   tracking_active__c=false,
                                        Shipping_Company__c = 'ninjavan-my');

        Shipment_Order__c ast2= new Shipment_Order__c(tracking_number__c='73658',
                                   status__c='Shipped',
                                   Account__c=accounts.id,
                                   tracking_active__c=false,
                                       Shipping_Company__c = 'ninjavan-my');

        Shipment_Order__c ast3= new Shipment_Order__c(tracking_number__c='73658',
                                   status__c='Shipped',
                                   AfterShip_ID__c='123',
                                   tracking_active__c=true,
                                   Account__c=accounts.id,
                                      Shipping_Company__c = 'ninjavan-my');

        Shipment_Order__c ast4= new Shipment_Order__c(tracking_number__c='73658',
                                   status__c='Shipped',
                                   AfterShip_ID__c='123',
                                   tracking_active__c=true,
                                   Account__c=accounts.id,
                                       Shipping_Company__c = 'ninjavan-my');
        insert new List<sObject> {cn,ast1,ast2,ast3,ast4};
	}
	
    static testMethod void testBatch(){
    	Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());

        List<Integration_Config__c> intconfig=new List<Integration_Config__c>();
        intconfig.add(new Integration_Config__c(name='AfterShip',EndPoint__c='https://aftership.com/',AuthenticationToken__c='testtest',Countries__c = 'Malaysia'));

        insert intconfig;
        Test.startTest();

         	Database.executeBatch(new BatchCreateTrackingIdOnAfterShip());

        Test.stopTest();
    	
    	// verify that 4 assets have after ship id now
        List<Shipment_Order__c> shipmentOrders = [Select Id from Shipment_Order__c where AfterShip_ID__c != null];
        System.assertEquals(4,shipmentOrders.size());
        
        // verify that 2 assets have same after ship id now
        shipmentOrders = [Select Id from Shipment_Order__c where AfterShip_Id__c != '123'];
        System.assertEquals(2,shipmentOrders.size());
    }

    static testmethod void test() {
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());

        List<Integration_Config__c> intconfig=new List<Integration_Config__c>();
        intconfig.add(new Integration_Config__c(name='AfterShip',EndPoint__c='https://aftership.com/',AuthenticationToken__c='testtest'));

        insert intconfig;
        Test.startTest();

          // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest',
                            CRON_EXP,
                            new SchedulerBatchCreateTrackingId());

          // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
             NextFireTime
             FROM CronTrigger WHERE id = :jobId];

          // Verify the expressions are the same
        System.assertEquals(CRON_EXP,
        ct.CronExpression);

        Test.stopTest();
   }

    static testmethod void testClsRestAssetUpdAfetrship(){
        RestRequest req = new RestRequest();
        req.requestBody=Blob.valueof('{"meta":{"code":201},"msg":{"id":"123","tracking_ship_date":"2014-06-25","updated_at":"2014-06-25T09:23:08+00:00","expected_delivery":"2014-06-25T09:23:08+00:00","tracking_number":"73658","tag":"Exception","checkpoints":[{"tag":"Exception","message":"83dhu"}]}}');
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/UpdateShippingStatus';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        ClsRestShippingOrderUpdAftership.updateShippingStatus();
        test.stoptest();
		Date dt = Date.newInstance(2014,06,25);
		List<Shipment_Order__c> shipmentOrders = [Select Id from shipment_order__c where date_shipped__c = :dt];
		System.assertEquals(2,shipmentOrders.size());
    }
}
