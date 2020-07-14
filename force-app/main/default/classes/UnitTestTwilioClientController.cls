@isTest
private class UnitTestTwilioClientController {

	final static String authToken = '12345678901234567890123456789012';
	static{
        UnitTestDataFactory.getRecordtypeValues();
		TwilioConfig__c twilioCfg = new TwilioConfig__c();
		twilioCfg.Name = 'SalesforceClick2Dial';
		twilioCfg.AccountSid__c = 'AC03c2fcd60e144e7cbeed179fcbf812a3'; 
		twilioCfg.AuthToken__c = '12345678901234567890123456789012';
    	twilioCfg.ApplicationSid__c = 'AC03c2fcd60e144e7cbeed179fcbf812a3';	    
		twilioCfg.CallerId__c = '448008085291';
		insert twilioCfg;

		// create the response body to be returned when the Call URI is requested
		String json='{"sid":"CA5ea9c5d78e1f35fc01c204682d056e22","date_created":"Mon, 02 Jan 2012 06:41:14 +0000","date_updated":"Mon, 02 Jan 2012 06:41:42 '
        	+'+0000","parent_call_sid":"CA39f78143e0374332b21c9b256e6d4e9a","account_sid":"AC03c2fcd60e144e7cbeed179fcbf812a3","to":"+918722266660",'
        	+'"to_formatted":"+918722266660","from":"+919902400323","from_formatted":"+919902400323","phone_number_sid":'
	        +'"PN17c8630939e44e7e92a45c51bcdb7122","status":"completed","start_time":"Mon, 02 Jan 2012 06:41:33 +0000",'
	        +'"end_time":"Mon, 02 Jan 2012 06:41:42 +0000","duration":"9","price":"-0.09000",'
	        +'"direction":"outbound-dial","answered_by":null,"api_version":"2010-04-01","annotation":null,'
	        +'"forwarded_from":"","group_sid":null,"caller_name":null,"uri":"/2010-04-01/Accounts/AC03c2fcd60e144e7cbeed179fcbf812a3/Calls/CA5ea9c5d78e1f35fc01c204682d056e22.json",'
	        +'"subresource_uris":{"notifications":"/2010-04-01/Accounts/AC03c2fcd60e144e7cbeed179fcbf812a3/Calls/CA5ea9c5d78e1f35fc01c204682d056e22/Notifications.json",'
	        +'"recordings":"/2010-04-01/Accounts/AC03c2fcd60e144e7cbeed179fcbf812a3/Calls/CA5ea9c5d78e1f35fc01c204682d056e22/Recordings.json"}}';
       
		// register the mock Response with the Twilio_TestHTTPMock singleton service
		// for the HTTP GET method and at the Twilio Call instance URI.
		Twilio_TestHTTPMock.getInstance().putResponse(
			'GET',
			'https://api.twilio.com/2010-04-01/Accounts/AC03c2fcd60e144e7cbeed179fcbf812a3/Calls/CA5ea9c5d78e1f35fc01c204682d056e22.json',
			new Twilio_TestHTTPMock.Response(json,200)
			);

	}
	
	@isTest static void test_method_one() {
        Country__c countryUK = UnitTestDataFactory.createCountry('UK', 'United Kingdom', 'GBP');
		insert countryUK;
		List<Account> accs = UnitTestDataFactory.createAccounts(1, countryUK, 'UK_Account');
		insert accs;
		System.currentPageReference().getParameters().put('PhoneNumber','00448008085291');
		Test.startTest();
		TwilioClientController ctrl = new TwilioClientController();
		try{
			String token = ctrl.getToken();
		}catch(Exception e){
			System.debug(e.getMessage());
		}
		String dial = ctrl.getDial();
		String duration = TwilioClientController.getCallDuration('CA5ea9c5d78e1f35fc01c204682d056e22');
		Task t = new Task(Activity_Subject__c='Call - Employee reached',CallDurationInSeconds=1,CallType='Outbound',Description='test',RecordTypeId=LibRecordTypeHelper.getRecordTypeValue('UK_Task'),Status='completed',Subject='Call',whatId=accs[0].Id);
		String task = TwilioClientController.saveTask(t);
		String task2 = TwilioClientController.saveTask(t);
		Test.stopTest();
	}



	@isTest static void test_method_two() {
        Country__c countryUK = UnitTestDataFactory.createCountry('UK', 'United Kingdom', 'GBP');
		insert countryUK;
		List<Account> accs = UnitTestDataFactory.createAccounts(1, countryUK, 'UK_Account');
		insert accs;
		Test.startTest();
		TwilioClientController ctrl = new TwilioClientController();
		String name = ctrl.uname;
		String dial = ctrl.getDial();
		//String duration = TwilioClientController.getCallDuration('CA5ea9c5d78e1f35fc01c204682d056e22');
		Task t = new Task(Activity_Subject__c='Call - Employee reached',CallDurationInSeconds=1,CallType='Outbound',Description='test',RecordTypeId=LibRecordTypeHelper.getRecordTypeValue('UK_Task'),Status='completed',Subject='Call',whatId=accs[0].Id,whoId=accs[0].Id);
		String task = TwilioClientController.saveTask(null);
		String task2 = TwilioClientController.saveTask(t);
		Test.stopTest();
	}
	
	
}