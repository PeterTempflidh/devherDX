@isTest
private class UnitTestCtrLDSNotesRelatedlist {

	@testSetup static void setup() {
		UnitTestDataFactory.getRecordtypeValues();
		Country__c c = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
		insert c;

		Account a = UnitTestDataFactory.createAccount('test', c, 'CD_Account');
		insert a;

		Note n = new Note(Title = 'test note', Body = 'test body', ParentId = a.Id);
		insert n;
	}

	@isTest static void CtrLDSNotesRelatedListBiuldCorrectly() {
		Test.startTest();

		CtrLDSNotesRelatedList ctr = new CtrLDSNotesRelatedList();

		Test.stopTest();
	}

	@isTest static void retrieveReturnsEmptyListIfParentIdIsNull() {
		List<Note> res;

		Test.startTest();

		res = CtrLDSNotesRelatedList.retrieve('');

		Test.stopTest();

		System.assertNotEquals(null, res);
		System.assert(res.isEmpty());
	}

	@isTest static void retrieveReturnsEmptyListIfParentIdIsNotAValidId() {
		List<Note> res;

		Test.startTest();

		res = CtrLDSNotesRelatedList.retrieve('invalid-Id');

		Test.stopTest();

		System.assertNotEquals(null, res);
		System.assert(res.isEmpty());
	}

	@isTest static void retrieveReturnsCorrectly() {
		List<Note> res;

		Test.startTest();

		res = CtrLDSNotesRelatedList.retrieve([select id from account limit 1].id);

		Test.stopTest();

		System.assertNotEquals(null, res);
		System.assertEquals(1, res.size());
	}

	@isTest static void upsertNoteReturnsnullIfParentIdIsNull() {
		Note res;

		Test.startTest();

		res = CtrLDSNotesRelatedList.upsertNote('', 'test title', 'test body', '');

		Test.stopTest();

		System.assertEquals(null, res);
	}

	@isTest static void upsertNoteCreateNewNoteCorrectly() {
		Note res;
		Account a = [select id from account limit 1];
		Test.startTest();

		res = CtrLDSNotesRelatedList.upsertNote('', 'test title', 'test body', a.id);

		Test.stopTest();

		System.assertNotEquals(null, res);
		System.assert(String.isNotBlank(res.id));

		System.assertEquals('test title', res.Title);
		System.assertEquals('test body', res.Body);
		System.assertEquals(a.id, res.ParentId);

		List<Note> notes = [select id from Note where parentid =: a.id];

		System.assertEquals(2, notes.size());
	}

	@isTest static void upsertNoteUpdateCorrectlyNote() {
		Account a = [select id from account limit 1];
		
		Note existing = [select id from note where parentid =:a.Id limit 1];
		Note res;

		Test.startTest();

		res = CtrLDSNotesRelatedList.upsertNote(existing.Id, 'test title', 'test body', a.id);

		Test.stopTest();

		System.assertNotEquals(null, res);
		System.assertEquals(existing.Id, res.Id);
		System.assertEquals('test title', res.Title);
		System.assertEquals('test body', res.Body);
		System.assertEquals(a.id, res.ParentId);

		List<Note> notes = [select id from Note where parentid =: a.id];

		System.assertEquals(1, notes.size());
	}

	@isTest static void deleteNoteWorksCorrectly() {
		Account a = [select id from account limit 1];
		
		Note existing = [select id from note where parentid =:a.Id limit 1];

		Test.startTest();

		CtrLDSNotesRelatedList.deleteNote(existing.Id);

		Test.stopTest();

		List<Note> notes = [select id from Note where parentid =: a.id];

		System.assert(notes.isEmpty());
	}

}