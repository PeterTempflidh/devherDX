@isTest
private class UnitTestClsUtilsApexPages {

	@isTest static void addConfirmMessageWorksCorrectly() {
		PageReference pref = new PageReference('http://test.test');

		Test.startTest();
		Test.setCurrentPage(pref);

		ClsUtilsApexPages.addConfirmMessage('message');

		Test.stopTest();

		System.assert(ApexPages.hasMessages(ApexPages.Severity.CONFIRM));
	}

	@isTest static void addErrorMessageWorksCorrectly() {
		PageReference pref = new PageReference('http://test.test');

		Test.startTest();
		Test.setCurrentPage(pref);

		ClsUtilsApexPages.addErrorMessage('message');

		Test.stopTest();

		System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
	}

	@isTest static void addInfoMessageWorksCorrectly() {
		PageReference pref = new PageReference('http://test.test');

		Test.startTest();
		Test.setCurrentPage(pref);

		ClsUtilsApexPages.addInfoMessage('message');

		Test.stopTest();

		System.assert(ApexPages.hasMessages(ApexPages.Severity.INFO));
	}

	@isTest static void addWarningMessageWorksCorrectly() {
		PageReference pref = new PageReference('http://test.test');

		Test.startTest();
		Test.setCurrentPage(pref);

		ClsUtilsApexPages.addWarningMessage('message');

		Test.stopTest();

		System.assert(ApexPages.hasMessages(ApexPages.Severity.WARNING));
	}

}