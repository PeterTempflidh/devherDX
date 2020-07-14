@isTest
private class UnitTestCtrDE_MenuChange {

	@testSetup static void setup() {
		UnitTestDataFactory.getRecordtypeValues();
	}

	@isTest static void CtrDE_MenuChangeInitCorrectly() {
		Boolean showForm;
		Integer listSize;

		Test.startTest();

		Test.setCurrentPage(Page.DE_MenuChange_LH);

		CtrDE_MenuChange ctr = new CtrDE_MenuChange();
		showForm = ctr.showForm;
		listSize =  ctr.newAttachments.size();

		Test.stopTest();

		System.assert(showForm);
		System.assertEquals(CtrDE_MenuChange.ATTACHMENTS_NUMBER, listSize);
	}

	/* LH PORTAL */

	@isTest static void saveReturnsCorrectlyForLH() {
		String email = 'amazingRestaurant@whatever.com';

		Test.startTest();
		Test.setCurrentPage(Page.DE_MenuChange_LH);

		CtrDE_MenuChange ctr = new CtrDE_MenuChange();
		ctr.allergens = true;
		ctr.EmailAdd = email;
		ctr.lieferheldId = '123';
		ctr.postalCode = '12334';
		ctr.menuChangeDetails = 'bla bla bla';

		Attachment att = ctr.newAttachments[0];
		att.Body = Blob.valueOf('whatever');
		att.Name = 'whatever';

		ctr.save();

		Test.stopTest();

		Case[] cases = [SELECT
		                Platform__c
		                FROM Case
		                WHERE SuppliedEmail = :email
		                                      AND Type = 'Menu Change'
		                                              AND Origin = 'Web'
		                                                      AND RecordType.DeveloperName = 'DE_Entry_Case'];

		System.assertEquals(1, cases.size());
		System.assertEquals('LieferheldDE', cases[0].Platform__c);

		Id caseId = cases[0].Id;

		Attachment[] atts = [SELECT Id
		                     FROM Attachment
		                     WHERE ParentId = : caseId];

		System.assertEquals(1, atts.size());
	}

	@isTest static void saveReturnsCorrectlyIfPortalIsLhAndMenuChangeForPizzaDeIsTrue() {
		String email = 'amazingRestaurant@whatever.com';

		Test.startTest();
		Test.setCurrentPage(Page.DE_MenuChange_LH);

		CtrDE_MenuChange ctr = new CtrDE_MenuChange();
		ctr.allergens = true;
		ctr.EmailAdd = email;
		ctr.lieferheldId = '123';
		ctr.changeOnPizzade = 'Yes';
		ctr.pizzadeId = '123';

		Attachment att = ctr.newAttachments[0];
		att.Body = Blob.valueOf('whatever');
		att.Name = 'whatever';

		ctr.save();

		Test.stopTest();

		Case[] cases = [SELECT
		                Platform__c
		                FROM Case
		                WHERE SuppliedEmail = :email
		                                      AND Type = 'Menu Change'
		                                              AND Origin = 'Web'
		                                                      AND RecordType.DeveloperName = 'DE_Entry_Case'];

		System.assertEquals(1, cases.size());
		System.assert(cases[0].Platform__c.contains('LieferheldDE'));
		System.assert(cases[0].Platform__c.contains('PizzaDE'));

		Id caseId = cases[0].Id;

		Attachment[] atts = [SELECT Id
		                     FROM Attachment
		                     WHERE ParentId = : caseId];

		System.assertEquals(1, atts.size());

	}

	@isTest static void saveReturnsErrorIPortalIsLhAndfMenuChangeForPizzaDeIsTrueAndPizzaDeIdIsMissing() {
		Test.startTest();
		Test.setCurrentPage(Page.DE_MenuChange_LH);

		CtrDE_MenuChange ctr = new CtrDE_MenuChange();
		ctr.lieferheldId = '123';
		ctr.changeOnPizzade = 'Yes';

		ctr.save();

		Test.stopTest();

		Case[] cases = [SELECT
		                Id
		                FROM Case
		                WHERE RecordType.DeveloperName = 'DE_Entry_Case'];

		System.assert(cases.isEmpty());
	}

	/* PDE PORTAL */

	@isTest static void saveReturnsCorrectlyForPDE() {
		String email = 'amazingRestaurant@whatever.com';

		Test.startTest();
		Test.setCurrentPage(Page.DE_MenuChange_PDE);

		CtrDE_MenuChange ctr = new CtrDE_MenuChange();
		ctr.allergens = true;
		ctr.EmailAdd = email;
		ctr.pizzadeId = '123';
		ctr.postalCode = '12334';
		ctr.menuChangeDetails = 'bla bla bla';

		Attachment att = ctr.newAttachments[0];
		att.Body = Blob.valueOf('whatever');
		att.Name = 'whatever';

		ctr.save();

		Test.stopTest();

		Case[] cases = [SELECT
		                Platform__c
		                FROM Case
		                WHERE SuppliedEmail = :email
		                                      AND Type = 'Menu Change'
		                                              AND Origin = 'Web'
		                                                      AND RecordType.DeveloperName = 'DE_Entry_Case'];

		System.assertEquals(1, cases.size());
		System.assertEquals('PizzaDE', cases[0].Platform__c);

		Id caseId = cases[0].Id;

		Attachment[] atts = [SELECT Id
		                     FROM Attachment
		                     WHERE ParentId = : caseId];

		System.assertEquals(1, atts.size());
	}

	@isTest static void saveReturnsCorrectlyIfPortalIsPDEAndMenuChangeForLhIsTrue() {
		String email = 'amazingRestaurant@whatever.com';

		Test.startTest();
		Test.setCurrentPage(Page.DE_MenuChange_PDE);

		CtrDE_MenuChange ctr = new CtrDE_MenuChange();
		ctr.allergens = true;
		ctr.EmailAdd = email;
		ctr.pizzadeId = '123';
		ctr.lieferheldId = '123';
		ctr.changeOnLh = 'Yes';

		Attachment att = ctr.newAttachments[0];
		att.Body = Blob.valueOf('whatever');
		att.Name = 'whatever';

		ctr.save();

		Test.stopTest();

		Case[] cases = [SELECT
		                Platform__c
		                FROM Case
		                WHERE SuppliedEmail = :email
		                                      AND Type = 'Menu Change'
		                                              AND Origin = 'Web'
		                                                      AND RecordType.DeveloperName = 'DE_Entry_Case'];

		System.assertEquals(1, cases.size());
		System.assert(cases[0].Platform__c.contains('LieferheldDE'));
		System.assert(cases[0].Platform__c.contains('PizzaDE'));

		Id caseId = cases[0].Id;

		Attachment[] atts = [SELECT Id
		                     FROM Attachment
		                     WHERE ParentId = : caseId];

		System.assertEquals(1, atts.size());

	}

	@isTest static void saveReturnsErrorIPortalIsPDEAndfMenuChangeForLhIsTrueAndLhIdIsMissing() {
		Test.startTest();
		Test.setCurrentPage(Page.DE_MenuChange_PDE);

		CtrDE_MenuChange ctr = new CtrDE_MenuChange();
		ctr.pizzadeId = '123';
		ctr.changeOnLh = 'Yes';

		ctr.save();

		Test.stopTest();

		Case[] cases = [SELECT
		                Id
		                FROM Case
		                WHERE RecordType.DeveloperName = 'DE_Entry_Case'];

		System.assert(cases.isEmpty());
	}

}