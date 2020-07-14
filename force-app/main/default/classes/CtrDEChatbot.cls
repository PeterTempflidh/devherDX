public with sharing class CtrDEChatbot {
	public String crmApiToken {
		get {
			return Integration_Config__c.getValues('ChatbotCrmApi').Password__c;
		}
	}
	public String apiAiApiToken {
		get {
			return Integration_Config__c.getValues('ChatbotApiAiApi').Password__c;
		}
	}
	public String ninecookiesApiToken {
		get {
			return Integration_Config__c.getValues('ChatbotNinecookiesApi').Password__c;
		}
	}
	public CtrDEChatbot(ApexPages.StandardController stdCtr) {}
}