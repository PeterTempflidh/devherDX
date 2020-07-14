@isTest
public class UnitTestCtrGlobalChatBot {
    public static string TYPE = '';
    public static Boolean ERROR = false;
    
    @TestSetup
    public static void setupData(){
    	// create RecordType__c custom setting
		UnitTestDataFactory.getRecordtypeValues();	
    	
    	Country__c testCountry = UnitTestDataFactory.createCountry('PY','Uruguay', 'UYU');
        insert testCountry;
        
        List<Account> accList= UnitTestDataFactory.createAccounts(2,testCountry,'PY_Account');
        accList[0].backend_id__c = '12345';
		accList[1].backend_id__c = '54321';
        insert accList;

		Platform_Performance__c platPerform = new Platform_performance__c();
		platPerform.Account__c = accList[0].Id;
		platPerform.Platform__c = 'PedidosYa';
		platPerform.Backend_id__c = '12345';
		insert platPerform;

        // create Integration config
        Integration_Config__c config = new Integration_Config__c();
        config.AuthenticationToken__c 	= '123455';
        config.AuthTokenExtension__c	= '1234677';
        config.Endpoint__c				= 'https://dummy.api.stg.testdatafridge.com/v1/global-entity-ids/@ENTITY_ID/order-status-aggregates';
        config.Timeout__c				= 10000;
        config.name						= 'DataFridgeOrderDetails';
        
        Integration_Config__c config2 = new Integration_Config__c();
        config2.password__c 	= 'dummy password';
        config2.Endpoint__c		= 'https://dummy.execute-api.eu-central-1.amazonaws.com/prod/@PLATFORM/coupons/';
        config2.Timeout__c		= 10000;
        config2.name			= 'ChatbotCrmApi';
        
        insert new List<Integration_Config__c>{config,config2};
        
        // create business configs
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='startDateMonths',Business_Rule_Value__c='12',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='ChatBotConfigs',Record_Type_Id__c='Global_Config',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='voucherToolLink ',Business_Rule_Value__c='https://wwww.test.com',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='ChatBotConfigs',Record_Type_Id__c='Global_Config',Type__c='Process');
		Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='platformEntityMapping ',Business_Rule_Value__c='{"PedidosYa_Uruguay":"PY_UY","PizzaDE":"PD_DE"}',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='ChatBotConfigs',Record_Type_Id__c='Global_Config',Type__c='Process');
		Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='hurrierDetails',Business_Rule_Value__c='[{"Platform":"PedidosYa","Uruguay":"https://uy.usehurrier.com//dispatcher/order_details/"}]',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='ChatBotConfigs',Record_Type_Id__c='Global_Config',Type__c='Process');
		Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='orderDetailsLink',Business_Rule_Value__c='[{"Uruguay":"https://uy.usehurrier.com//dispatcher/order_details/"}]',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='ChatBotConfigs',Record_Type_Id__c='Global_Config',Type__c='Process');
		Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c='customerDetailsLink',Business_Rule_Value__c='[{"Uruguay":"https://uy.usehurrier.com//dispatcher/order_details/"}]',Id_Country__c=testcountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='ChatBotConfigs',Record_Type_Id__c='Global_Config',Type__c='Process');
		insert new List<Business_Config__c>{b1,b2,b3,b4,b5,b6};

		List<Case> cases = new List<Case>();
		Case caseRec = UnitTestDataFactory.createCase(accList[0], 'New', '', '', 'Chat', testCountry, 'PY_Inbound_Case', 'Testing');
		cases.add(caseRec);

		insert cases;

		LiveChatVisitor visitor=new LiveChatVisitor();
		insert visitor;

		LiveChatTranscript chat = new LiveChatTranscript(
				Platform__c = 'PedidosYa',
				Order_Number__c = '1234567890001',
				Email__c = 'test@test.com',
				User_Name__c = 'test name',
				My_Problem__c = 'Kunde - Anderes Problem',
				Body='Hello',
				LiveChatVisitorId=visitor.id,
				caseId=cases[0].Id,
				case=cases[0]
		);
		insert chat;
    }
    
    @isTest
    public static void testFetchOrder(){
    	TYPE = 'FETCH_ORDER';
    	Test.startTest();
			CtrGlobalChatBot controller = new CtrGlobalChatBot();
    		Continuation con=(Continuation)CtrGlobalChatBot.fetchOrder('ABC123','PedidosYa','Uruguay');
			Map<String,System.HttpRequest> continuationLabels=con.getRequests();
			List<String> labelsStrings = new List<String>();
			labelsStrings.addAll(continuationLabels.keySet());
			respond('FETCH_ORDER',false,labelsStrings[0]);
			Object result = Test.invokeContinuationMethod(controller, con);
    	Test.stopTest();
		System.assertEquals(CtrGlobalChatBot.responseWrap.isError,false,CtrGlobalChatBot.responseWrap.errorMessage);
    }
    
    @isTest
    public static void testFetchOrderError(){

    	TYPE 	= 'FETCH_ORDER';
    	ERROR	= true;
    	CtrGlobalChatBot.ResponseWrapper wrapper;
    	Test.startTest();
			CtrGlobalChatBot controller = new CtrGlobalChatBot();
			Continuation con=(Continuation)CtrGlobalChatBot.fetchOrder('ABC123','PedidosYa','Uruguay');
			Map<String,System.HttpRequest> continuationLabels=con.getRequests();
			List<String> labelsStrings = new List<String>();
			labelsStrings.addAll(continuationLabels.keySet());
			respond('FETCH_ORDER',true,labelsStrings[0]);
			Object result = Test.invokeContinuationMethod(controller, con);
    	Test.stopTest();
		CtrGlobalChatBot.fetchOrder('ABC123','PedidosYa','Uruguay');
		System.assertEquals(CtrGlobalChatBot.responseWrap.isError,true,true);
    }
    
    @isTest
    public static void testFetchOrderHistory(){

    	TYPE = 'FETCH_ORDER_HISTORY';
    	CtrGlobalChatBot.ResponseWrapper wrapper;
    	Test.startTest();
    		CtrGlobalChatBot.fetchOrderHistory('ABC123','PedidosYa','Uruguay');
    	Test.stopTest();
    	System.assertEquals(CtrGlobalChatBot.responseWrap.isError,false,CtrGlobalChatBot.responseWrap.errorMessage);
    }
    
    @isTest
    public static void testFetchRestaurant_PP(){
    	CtrGlobalChatBot.ResponseWrapper wrapper;
    	Test.startTest();
			wrapper = (CtrGlobalChatBot.ResponseWrapper)CtrGlobalChatBot.fetchRestaurantDetails('12345','PedidosYa');
    	Test.stopTest();

    	System.assertEquals(wrapper.isError,false,wrapper.errorMessage);
    	Account acc = [Select Id from Account where backend_id__c = '12345'];
    	System.assertEquals(wrapper.account.id,acc.id);
    }

	@isTest
	public static void testFetchRestaurant_Account(){
		CtrGlobalChatBot.ResponseWrapper wrapper;
		Test.startTest();
		wrapper = (CtrGlobalChatBot.ResponseWrapper)CtrGlobalChatBot.fetchRestaurantDetails('54321','PedidosYa');
		Test.stopTest();

		System.assertEquals(wrapper.isError,false,wrapper.errorMessage);
		Account acc = [Select Id from Account where backend_id__c = '54321'];
		System.assertEquals(wrapper.account.id,acc.id);
	}

	@isTest
	public static void testGetCaseFromChat(){
		LiveChatTranscript chat=[SELECT Id FROM LiveChatTranscript WHERE CaseId!=null LIMIT 1];
		String caseString=CtrGlobalChatBot.getCaseFromChat(chat.Id);
		Case expectedCase = [SELECT Id FROM Case WHERE RecordType.DeveloperName='PY_Inbound_Case' AND Origin='Chat' LIMIT 1];
		system.assertEquals(caseString.contains(expectedCase.Id),true);
	}

	@isTest
	public static void testGetLinks(){
		List<Business_Config__c> configList=[SELECT Id,Business_Rule_Name__c,Business_Rule_Value__c FROM Business_Config__c WHERE Process_Name__c='ChatBotConfigs' AND Business_Rule_Name__c IN ('hurrierDetails','customerDetailsLink','orderDetailsLink')];
		Map<String,Business_Config__c> configMap = new Map<String,Business_Config__c>();
		for(Business_Config__c config:configList){
			configMap.put(config.Business_Rule_Name__c,config);
		}
		Test.startTest();
		Map<String,String> links=CtrGlobalChatBot.getLinks('PedidosYa','Uruguay','platform delivery');
		Test.stopTest();
		system.assertEquals(((List<Map<String,String>>)JSON.deserialize(configMap.get('hurrierDetails').Business_Rule_Value__c, List<Map<String, String>>.class))[0].get('Uruguay'),links.get('HurrierDetails'));
		system.assertEquals(((List<Map<String,String>>)JSON.deserialize(configMap.get('customerDetailsLink').Business_Rule_Value__c, List<Map<String, String>>.class))[0].get('Uruguay'),links.get('CustomerDetails'));
		system.assertEquals(((List<Map<String,String>>)JSON.deserialize(configMap.get('orderDetailsLink').Business_Rule_Value__c, List<Map<String, String>>.class))[0].get('Uruguay'),links.get('OrderDetails'));
	}

	@isTest
	static void testupdatePaymentMethod() {
		Case newCase = [SELECT Id, RecordTypeId,Type,Case_Reason_Level_1__c,Case_Reason_Level_2__c,Case_Reason_Level_3__c FROM Case WHERE RecordType.DeveloperName='PY_Inbound_Case' LIMIT 1];
		test.startTest();
		String payMethod = CtrGlobalChatBot.updatePaymentMethod(newCase.Id,'Visa CC Card');
		test.stopTest();
		system.assertEquals('Visa CC Card',payMethod);
	}

	public  static void respond(String type, Boolean isError, String requestLabel) {
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		if(type == 'FETCH_ORDER_HISTORY'){
			response.setBody('{"data":{"order":{"global_entity_id":"PY_UY","order_id":"ABC123","brand_name":"Burger King","country_code":"US","locale":"en-US","timestamp":"2018-02-01T14:32:13.456Z","promised_customer_timestamp":"2018-02-01T14:32:13Z","currency":"EUR","business_type":"marketplace","vendor":{"name":"Mr. Wongs","charges":{"service_fee":1,"payment_fee":1,"joker_fee":1,"discount_fee":1},"id":"X126"},"customer":{"channel":{"type":"android","version":".."},"payment":{"minimum_order_value_fee":1,"loyalty_point_balance":4.13,"coupon":1,"transaction_number":"tx-1234","paid":true,"service_fee":1,"discount":1,"wallet_balance":1.23,"total_order_value":14.77,"total_tax":0.23,"payment_method":"credit card"},"customer_id":"ad2465X","profile":{"phone":"+49123456789","name":"summt user","last_name":"Hardenberg","guest":true,"id":"2344","locale":"en-US","first_name":"Christian","email":"dummuser@gmail.com"}},"commission":{"commissionable_value":13.3,"rate":10,"amount":1.47},"order":{"deposit":1,"tax":{"tax_rate_percent":7,"amount":0.98,"net_amount":14.02},"items":[{"name":"Kung Pao","options":[{"name":"Extra Chicken","id":"CH-1A250","quantity":2,"unit_price":123.45,"type":"choice","customer_notes":"no swiss cheese please"},{"name":"Extra Large","type":"variation","id":"CH-1A251"}],"id":"CH-1A243","quantity":2,"customer_notes":"longer than shorter limit 120, without chicken please qm;wledghouijp4bkrw eov;cdhinbjefw kdf philbfwk djophidgvbefuqkhvwbru","unit_price":123.45},{"name":"3 in 1 Lunch Deal","options":[{"name":"Hamburger","options":[{"name":"Extra Cheese","id":"CH-1A249","quantity":1,"type":"topping"}],"id":"BH-1A249","quantity":1,"type":"choice","customer_notes":"no swiss cheese please"},{"name":"Cheese Burger","id":"BH-1A250","quantity":1,"type":"choice"},{"name":"Nuggets","id":"BH-1A251","quantity":1,"type":"choice"}],"id":"BK-1B243","quantity":1,"unit_price":123.45}],"minimum_order_value":15.77,"order_value":20},"delivery":{"delivery_fee":1,"tip":2.5,"tax":{"tax_rate_percent":7,"amount":0.98,"net_amount":14.02},"location":{"city":"Berlin","street":"Oranienburger Str.","district":"Mitte","latitude":52.524667,"address_text":"Oranienburger Str. 70, 10117 Berlin","street_number":"70","description":null,"id":"abc-def","label":"work","postal_code":"10117","building":"Delivery Hero Office","longitude":13.392972},"provider":"vendor_delivery"},"corporate":true,"test_order":false,"preorder":true},"order_statuses":[]}}');
		}
		else if(type == 'FETCH_ORDER'){
			response.setBody('{"data":{"order_status_aggregates":[{"order":{"global_entity_id":"PY_UY","order_id":"ABC123","brand_name":"Burger King","country_code":"US","locale":"en-US","timestamp":"2018-02-01T14:32:13.456Z","promised_customer_timestamp":"2018-02-01T14:32:13Z","currency":"EUR","business_type":"marketplace","vendor":{"name":"Mr. Wongs","charges":{"service_fee":1,"payment_fee":1,"joker_fee":1,"discount_fee":1},"id":"X126"},"customer":{"channel":{"type":"android","version":".."},"payment":{"minimum_order_value_fee":1,"loyalty_point_balance":4.13,"coupon":1,"transaction_number":"tx-1234","paid":true,"service_fee":1,"discount":1,"wallet_balance":1.23,"total_order_value":14.77,"total_tax":0.23,"payment_method":"credit card"},"customer_id":"ad2465X","profile":{"phone":"+491234567888","name":"Dummy user","last_name":"Hardenberg","guest":true,"id":"2344","locale":"en-US","first_name":"Christian","email":"dummyuser@gmail.com"}},"commission":{"commissionable_value":13.3,"rate":10,"amount":1.47},"order":{"deposit":1,"tax":{"tax_rate_percent":7,"amount":0.98,"net_amount":14.02},"items":[{"name":"Kung Pao","options":[{"name":"Extra Chicken","id":"CH-1A250","quantity":2,"unit_price":123.45,"type":"choice","customer_notes":"no swiss cheese please"},{"name":"Extra Large","type":"variation","id":"CH-1A251"}],"id":"CH-1A243","quantity":2,"customer_notes":"longer than shorter limit 120, without chicken please qm;wledghouijp4bkrw eov;cdhinbjefw kdf philbfwk djophidgvbefuqkhvwbru","unit_price":123.45},{"name":"3 in 1 Lunch Deal","options":[{"name":"Hamburger","options":[{"name":"Extra Cheese","id":"CH-1A249","quantity":1,"type":"topping"}],"id":"BH-1A249","quantity":1,"type":"choice","customer_notes":"no swiss cheese please"},{"name":"Cheese Burger","id":"BH-1A250","quantity":1,"type":"choice"},{"name":"Nuggets","id":"BH-1A251","quantity":1,"type":"choice"}],"id":"BK-1B243","quantity":1,"unit_price":123.45}],"minimum_order_value":15.77,"order_value":20},"delivery":{"delivery_fee":1,"tip":2.5,"tax":{"tax_rate_percent":7,"amount":0.98,"net_amount":14.02},"location":{"city":"Berlin","street":"Oranienburger Str.","district":"Mitte","latitude":52.524667,"address_text":"Oranienburger Str. 70, 10117 Berlin","street_number":"70","description":null,"id":"abc-def","label":"work","postal_code":"10117","building":"Delivery Hero Office","longitude":13.392972},"provider":"vendor_delivery"},"corporate":true,"test_order":false,"preorder":true},"order_statuses":[{"global_entity_id":"LH_DE","country_code":"DE","vendor":{"id":"foo-vendor-id"},"accepted":{"estimated_delivery_time":"2018-02-01T14:32:13Z"},"order_id":"AB123fc","timestamp":"2016-06-10T21:42:24.769Z","status":"ACCEPTED"},{"global_entity_id":"LH_DE","country_code":"DE","vendor":{"id":"foo-vendor-id"},"accepted":{"estimated_delivery_time":"2018-02-01T14:32:13Z"},"order_id":"AB123fc","timestamp":"2016-06-10T21:42:24.769Z","status":"ACCEPTED"}]},{"order":{"global_entity_id":"LH_DE","order_id":"AB125fc","brand_name":"Burger King","country_code":"US","locale":"en-US","timestamp":"2018-02-01T14:32:13.456Z","promised_customer_timestamp":"2018-02-01T14:32:13Z","currency":"EUR","business_type":"marketplace","vendor":{"name":"Mr. Wongs","charges":{"service_fee":1,"payment_fee":1,"joker_fee":1,"discount_fee":1},"id":"X126"},"customer":{"channel":{"type":"android","version":".."},"payment":{"minimum_order_value_fee":1,"loyalty_point_balance":4.13,"coupon":1,"transaction_number":"tx-1234","paid":true,"service_fee":1,"discount":1,"wallet_balance":1.23,"total_order_value":14.77,"total_tax":0.23,"payment_method":"credit card"},"customer_id":"ad2465X","profile":{"phone":"+491234778900","name":"Christian Hardenberg","last_name":"Hardenberg","guest":true,"id":"2344","locale":"en-US","first_name":"Christian","email":"dummy@gmail.com"}},"commission":{"commissionable_value":13.3,"rate":10,"amount":1.47},"order":{"deposit":1,"tax":{"tax_rate_percent":7,"amount":0.98,"net_amount":14.02},"items":[{"name":"Kung Pao","options":[{"name":"Extra Chicken","id":"CH-1A250","quantity":2,"unit_price":123.45,"type":"choice","customer_notes":"no swiss cheese please"},{"name":"Extra Large","type":"variation","id":"CH-1A251"}],"id":"CH-1A243","quantity":2,"customer_notes":"longer than shorter limit 120, without chicken please qm;wledghouijp4bkrw eov;cdhinbjefw kdf philbfwk djophidgvbefuqkhvwbru","unit_price":123.45},{"name":"3 in 1 Lunch Deal","options":[{"name":"Hamburger","options":[{"name":"Extra Cheese","id":"CH-1A249","quantity":1,"type":"topping"}],"id":"BH-1A249","quantity":1,"type":"choice","customer_notes":"no swiss cheese please"},{"name":"Cheese Burger","id":"BH-1A250","quantity":1,"type":"choice"},{"name":"Nuggets","id":"BH-1A251","quantity":1,"type":"choice"}],"id":"BK-1B243","quantity":1,"unit_price":123.45}],"minimum_order_value":15.77,"order_value":20},"delivery":{"delivery_fee":1,"tip":2.5,"tax":{"tax_rate_percent":7,"amount":0.98,"net_amount":14.02},"location":{"city":"Berlin","street":"Oranienburger Str.","district":"Mitte","latitude":52.524667,"address_text":"Oranienburger Str. 70, 10117 Berlin","street_number":"70","description":null,"id":"abc-def","label":"work","postal_code":"10117","building":"Delivery Hero Office","longitude":13.392972},"provider":"vendor_delivery"},"corporate":true,"test_order":false,"preorder":true},"order_statuses":[]}]}}');
		}

		if(isError){
			response.setStatusCode(204);
			response.setBody('{"message":"data not found"}');
		}else{
			response.setStatusCode(200);
		}
		Test.setContinuationResponse(requestLabel, response);
	}
}