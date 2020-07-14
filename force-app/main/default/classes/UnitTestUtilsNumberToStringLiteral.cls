@isTest
private class UnitTestUtilsNumberToStringLiteral {

	@testSetup static void setup() {
		NumberToStringLiteral__c[] configs = new List<NumberToStringLiteral__c>();

		configs.add(new NumberToStringLiteral__c(
		                Name = 'it_IT_1',
		                String_Literal__c = 'uno'));

		configs.add(new NumberToStringLiteral__c(
		                Name = UserInfo.getLocale() + '_1',
		                String_Literal__c = 'whatever'));

		insert configs;
	}

	@isTest static void getStringLiteralByUserLocaleReturnsCorrectly() {
		String res = UtilsNumberToStringLiteral.getStringLiteralByUserLocale(1);
		System.assertEquals('whatever', res);
	}

	@isTest static void getStringLiteralByLocaleReturnsCorrectly() {
		String res = UtilsNumberToStringLiteral.getStringLiteralByLocale(1, 'it_IT');
		System.assertEquals('uno', res);
	}

	@isTest static void getStringLiteralByLocaleReturnsEmptyStringIfInputParametersAreInvalid() {
		String res1 = UtilsNumberToStringLiteral.getStringLiteralByLocale(null, 'it_IT');
		String res2 = UtilsNumberToStringLiteral.getStringLiteralByLocale(1, '');
		System.assert(String.isBlank(res1));
		System.assert(String.isBlank(res2));
	}

	@isTest static void getStringLiteralByLocaleReturnsEmptyStringIfRecordNotExist() {
		String res = UtilsNumberToStringLiteral.getStringLiteralByLocale(2, 'it_IT');
		System.assert(String.isBlank(res));
	}

}