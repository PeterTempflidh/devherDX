@isTest
private class UnitTestCtrLDSDownloadAllAttachments {

	@testSetup static void setup() {
		UnitTestDataFactory.getRecordtypeValues();

		Country__c c = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
		insert c;

		Account a = UnitTestDataFactory.createAccount('test', c, 'CD_Account');
		insert a;

		List<Attachment> atts = new List<Attachment>();
		atts.add(new Attachment(
		             Name = 'file1.txt',
		             ContentType = 'text/text',
		             Body = Blob.valueOf('Secondigliano Regnaaaaaa!'),
		             ParentId = a.Id
		         ));
		atts.add(new Attachment(
		             Name = 'file2.txt',
		             ContentType = 'text/text',
		             Body = Blob.valueOf('Cocoooooooooos'),
		             ParentId = a.Id
		         ));
		insert atts;
	}

	@isTest static void getAttachmentsReturnsCorrectly() {
		Account a = [Select id from Account limit 1];

		List<Attachment> res;

		Test.startTest();

		res = CtrLDSDownloadAllAttachments.getAttachments(a.Id);

		Test.stopTest();

		System.assertNotEquals(null, res);
		System.assertEquals(2, res.size());
	}

	@isTest static void getAttachmentsReturnsEmptyListIfRecordIdIsNull() {
		List<Attachment> res;

		Test.startTest();

		res = CtrLDSDownloadAllAttachments.getAttachments('');

		Test.stopTest();

		System.assertNotEquals(null, res);
		System.assert(res.isEmpty());
	}

	@isTest static void getAttachmentBodyReturnsCorrectly() {
		Attachment a = [Select id from Attachment limit 1];

		CtrLDSDownloadAllAttachments.BodyWrapper res;

		Test.startTest();

		res = CtrLDSDownloadAllAttachments.getAttachmentBody(a.Id);

		Test.stopTest();

		System.assertNotEquals(null, res);
		System.assertEquals(a.Id, res.Id);
		System.assertNotEquals(null, res.Body);
	}

	@isTest static void getAttachmentBodyReturnsNullIfAttachmentIdIsBlank() {
		CtrLDSDownloadAllAttachments.BodyWrapper res;

		Test.startTest();

		res = CtrLDSDownloadAllAttachments.getAttachmentBody('');

		Test.stopTest();

		System.assertEquals(null, res);
	}

	/**
	 * @description test if file is split into parts and then combined correctly
	 */
	@isTest
	public static void test_BuildPartialAttachment() {
		Attachment a = [Select id, Body from Attachment limit 1];
		CtrLDSDownloadAllAttachments.BodyWrapper beforeWrapper = new CtrLDSDownloadAllAttachments.BodyWrapper(a);
		CtrLDSDownloadAllAttachments.BodyWrapper afterWrapper = new CtrLDSDownloadAllAttachments.BodyWrapper(a);
		afterWrapper.Body = '';

		Test.startTest();
		for(Integer part = 1; part <= 5; part++) {
			afterWrapper.Body += CtrLDSDownloadAllAttachments.getPartialAttachmentBody(a.Id, 5, part).Body;
		}
		Test.stopTest();

		System.assert(beforeWrapper.equals(afterWrapper));
	}

}