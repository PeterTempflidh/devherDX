/**
 * Test class for CtrLDSAttachmentsRelatedList
 */
@isTest
private class UnitTestCtrLDSAttachmentsRelatedList {

	@testSetup static void setup() {
		UnitTestDataFactory.getRecordtypeValues();

		Country__c c = UnitTestDataFactory.createCountry('UK', 'United Kingdom', 'GBP');
		insert c;

		Account a = UnitTestDataFactory.createAccount('test', c, 'UK_Account');
		insert a;

		Attachment att = new Attachment(
		    Name = 'Amazing takeaway Experience',
		    ContentType = 'application/pdf',
		    Body = Blob.valueOf('An amazing takeaway experience! :D'),
		    ParentId = a.Id
		);

		insert att;
	}

	@isTest static void CtrLDSAttachmentsRelatedListInstantiteCorrectly() {
		Account acc = [Select Id from Account limit 1];

		CtrLDSAttachmentsRelatedList ctr;

		Test.startTest();

		ctr = new CtrLDSAttachmentsRelatedList();
		ctr.parentId = acc.Id;

		Test.stopTest();

		System.assertEquals(acc.Id, ctr.parentId);
		System.assert(!ctr.attachments.isEmpty());
		System.assertNotEquals(null, ctr.newAttachment);
		System.assert(String.isBlank(ctr.newAttachment.Id));
		System.assert(String.isBlank(ctr.newAttachment.name));
		System.assertEquals(null, ctr.newAttachment.Body);
	}

	@isTest static void uploadAttachmentCreateNewAttachmentCorrectly() {
		Account acc = [select id from account limit 1];
		CtrLDSAttachmentsRelatedList ctr;
		PageReference res;

		String fileName = 'AnAmazingPdf.pdf';
		String ContentType = 'application/pdf';
		Blob body = Blob.valueOf('bla bla bla bla');

		Test.startTest();

		ctr = new CtrLDSAttachmentsRelatedList();
		ctr.parentId = acc.Id;

		ctr.newAttachment.Name = fileName;
		ctr.newAttachment.ContentType = contentType;
		ctr.newAttachment.Body = body;

		res = ctr.uploadAttachment();

		Test.stopTest();

		System.assertEquals(null, res);

		System.assertNotEquals(null, ctr.newAttachment);
		System.assert(String.isBlank(ctr.newAttachment.Id));
		System.assert(String.isBlank(ctr.newAttachment.Name));
		System.assertEquals(null, ctr.newAttachment.Body);

		Attachment[] insertedAtt = [
			Select
			Body
			From Attachment
			Where ParentId =:acc.Id
			And Name =:fileName
			And ContentType =:contentType
			Limit 1
		];

		System.assert(!insertedAtt.isEmpty());
		System.assertEquals(body.toString(), insertedAtt[0].Body.toString());
	}

	@isTest static void deleteAttachmentDeleteAttachmentCorrectly() {
		Account acc = [select id from account limit 1];
		CtrLDSAttachmentsRelatedList ctr;
		PageReference res;

		Attachment attToDelete = [Select Id from Attachment Where ParentId =: acc.Id Limit 1];

		Test.startTest();

		ctr = new CtrLDSAttachmentsRelatedList();
		ctr.toDelete = attToDelete.Id;
		res = ctr.deleteAttachment();

		Test.stopTest();

		System.assertEquals(null, res);

		Attachment[] shouldBeEmpty = [select id from attachment where id=: attToDelete.Id];

		System.assert(shouldBeEmpty.isEmpty());
	}

}