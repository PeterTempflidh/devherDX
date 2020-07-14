@isTest
private class UnitTestCtrDE_SpecialDeals {

	@testSetup static void setup() {
		UnitTestDataFactory.getRecordtypeValues();
	}

	@isTest static void CtrDE_SpecialDealsInitCorrectly() {
		Boolean showForm;
		Integer listSize;

		Test.startTest();

		Test.setCurrentPage(Page.DE_SpecialDeals_LH);

		CtrDE_SpecialDeals ctr = new CtrDE_SpecialDeals();
		showForm = ctr.showForm;
		listSize =  ctr.newAttachments.size();

		Test.stopTest();

		System.assert(showForm);
		System.assertEquals(CtrDE_SpecialDeals.ATTACHMENTS_NUMBER, listSize);
	}

	/* LH PORTAL */

	@isTest static void saveReturnsCorrectlyForLH() {
		String email = 'amazingRestaurant@whatever.com';

		Test.startTest();
		Test.setCurrentPage(Page.DE_SpecialDeals_LH);

		CtrDE_SpecialDeals ctr = new CtrDE_SpecialDeals();
		ctr.EmailAdd = email;
		ctr.customerId = '123';

		Attachment att = ctr.newAttachments[0];
		att.Body = Blob.valueOf('whatever');
		att.Name = 'whatever';

		ctr.save();

		Test.stopTest();

		Case[] cases = [SELECT
		                Platform__c
		                FROM Case
		                WHERE SuppliedEmail = :email
		                                      AND Type = 'Sales Task'
		                                              AND Origin = 'Web'
		                                                      AND Case_Reason__c = 'Meal Deals'
		                                                              AND RecordType.DeveloperName = 'DE_Internal_Case'];

		System.assertEquals(1, cases.size());
		System.assertEquals('LieferheldDE', cases[0].Platform__c);

		Id caseId = cases[0].Id;

		Attachment[] atts = [SELECT Id
		                     FROM Attachment
		                     WHERE ParentId = : caseId];

		System.assertEquals(1, atts.size());
	}

	/* PDE PORTAL */

	@isTest static void saveReturnsCorrectlyForPDE() {
		String email = 'amazingRestaurant@whatever.com';

		Test.startTest();
		Test.setCurrentPage(Page.DE_SpecialDeals_PDE);

		CtrDE_SpecialDeals ctr = new CtrDE_SpecialDeals();
		ctr.EmailAdd = email;
		ctr.customerId = '123';

		Attachment att = ctr.newAttachments[0];
		att.Body = Blob.valueOf('whatever');
		att.Name = 'whatever';

		ctr.save();

		Test.stopTest();

		Case[] cases = [SELECT
		                Platform__c
		                FROM Case
		                WHERE SuppliedEmail = :email
		                                      AND Type = 'Sales Task'
		                                              AND Origin = 'Web'
		                                                      AND Case_Reason__c = 'Meal Deals'
		                                                              AND RecordType.DeveloperName = 'DE_Internal_Case'];

		System.assertEquals(1, cases.size());
		System.assertEquals('PizzaDE', cases[0].Platform__c);

		Id caseId = cases[0].Id;

		Attachment[] atts = [SELECT Id
		                     FROM Attachment
		                     WHERE ParentId = : caseId];

		System.assertEquals(1, atts.size());
	}

}