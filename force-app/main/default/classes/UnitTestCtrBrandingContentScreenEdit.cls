@isTest
private class UnitTestCtrBrandingContentScreenEdit {

	@testSetup static void setup() {
		UnitTestDataFactory.getRecordtypeValues();

		Country__c c = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
		insert c;
		
		Company__c com = UnitTestDataFactory.createCompany('CD', 'CD', c);
		insert com;
		
		Account a = UnitTestDataFactory.createAccount('test', c, 'CD_Account');
		insert a;
		
		// create product Gruop
		List_Product_Group__c grp = UnitTestDataFactory.createProductGroup(com,c,'test', 'CD_List_Product_Group');
		insert grp;
		
		List<List_product_price__c> product = UnitTestDataFactory.createProducts(com, c,grp.Id,1, 'CD_List_Product_Price',0, true, 100.00, 1, false, 10);
		product[0].Requires_Branding__c = true;
		insert product;

		Branding_Content__c bc = new Branding_Content__c(Restaurant_Name__c = a.id,
		        OwnerId = UserInfo.getUserId(),
		        RecordTypeId = [Select id from recordType where DeveloperName = 'CD_Branding_Content'].Id);
		bc.product__c = product[0].Id;
		insert bc;
	}

	@isTest static void CtrBrandingContentScreenOnEditSetCorrectlyrecordTypeDevName() {
		Branding_Content__c bc = [Select id, RecordTypeId, OwnerId from Branding_Content__c limit 1];

		PageReference pref = Page.BrandingContentScreenEdit;
		pref.getParameters().put('id', bc.Id);

		Test.startTest();
		Test.setCurrentPage(pref);

		ApexPages.StandardController std = new ApexPages.StandardController(bc);
		CtrBrandingContentScreenEdit ctr = new CtrBrandingContentScreenEdit(std);

		Test.stopTest();

		System.assertEquals('CD_Branding_Content', ctr.recordTypeDevName);
	}

	@isTest static void CtrBrandingContentScreenEditOnNewSetCorrectlyRecordTypeDevName() {
		Branding_Content__c bc = new Branding_Content__c();

		PageReference pref = Page.BrandingContentScreenEdit;

		Test.startTest();
		Test.setCurrentPage(pref);

		ApexPages.StandardController std = new ApexPages.StandardController(bc);
		CtrBrandingContentScreenEdit ctr = new CtrBrandingContentScreenEdit(std);

		Test.stopTest();

		System.assert(String.isNotBlank(ctr.recordTypeDevName));
	}

}