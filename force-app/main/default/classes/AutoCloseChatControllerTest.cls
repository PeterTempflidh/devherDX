@isTest
public with sharing class AutoCloseChatControllerTest {
    @isTest
    public static void AutoCloseChatControllerTest() {
		Business_Config__c bc1 = new Business_Config__c(
			Business_Rule_Name__c = 'AutoCloseChatTime',
			Process_Name__c = 'AutoCloseChatTime',
			Record_Type_Id__c = 'AutoCloseChatTime',
			Type__c = 'Process'
		);
		insert bc1;
		
		Business_Config__c bc2 = new Business_Config__c(
			Business_Rule_Name__c = 'Foodpanda',
			Business_Rule_Value__c = '{ "Hong Kong": { "warning": 2, "warningClose": 5, "inactiveClose": 10 }, "Berlin": { "warning": 2, "warningClose": 5, "inactiveClose": 10 } }',
			Is_Active__c = true,
			Record_Type_Id__c = 'AutoCloseChatTime',
			Type__c = 'Process'
		);
		insert bc2;
		
        LiveChatVisitor visitor=new LiveChatVisitor();
        insert visitor;
		
		LiveChatTranscript ltr = new LiveChatTranscript(Country__c = 'Hong Kong',
														Platform__c = 'Foodpanda',
														LiveChatVisitorId = visitor.Id);
		insert ltr;

		Integer[] times =+ AutoCloseChatController.getTimes(ltr.Id);
		system.assertEquals(5000, times[0]); 
		system.assertEquals(10000, times[1]); 
		system.assertEquals(90000, times[2]); 
	}
}
