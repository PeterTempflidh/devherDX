@isTest
private class UnitTestCtrDEChatbot {
	@testSetup static void setup() {
		UnitTestDataFactory.getRecordtypeValues();

		List<Integration_Config__c> configs = new List<Integration_Config__c> {
			new Integration_Config__c(Password__c = 'whatever', Name = 'ChatbotCrmApi'),
			new Integration_Config__c(Password__c = 'whatever', Name = 'ChatbotApiAiApi'),
			new Integration_Config__c(Password__c = 'whatever', Name = 'ChatbotNinecookiesApi')
		};
		insert configs;

		insert new Case(
		    status = 'New',
		    type = 'Chat',
		    origin = 'Web',
		    recordtypeid = LibRecordTypeHelper.getRecordTypeValue('DE_Inbound_Case'),
		    subject = 'whatever'
		);
	}

	@isTest static void CtrDEChatbotInitCorrectly() {
		String chatbotCrmApi;
		String chatbotApiAiApi;
		String chatbotNinecookiesApi;

		Test.startTest();

		Test.setCurrentPage(Page.DEChatbot);
		ApexPages.StandardController std = new ApexPages.StandardController([SELECT Id FROM Case LIMIT 1]);
		CtrDEChatbot ctr = new CtrDEChatbot(std);

		chatbotCrmApi = ctr.crmApiToken;
		chatbotApiAiApi = ctr.apiAiApiToken;
		chatbotNinecookiesApi = ctr.ninecookiesApiToken;

		Test.stopTest();

		System.assert(String.isNotBlank(chatbotCrmApi));
		System.assert(String.isNotBlank(chatbotApiAiApi));
		System.assert(String.isNotBlank(chatbotNinecookiesApi));
	}
}