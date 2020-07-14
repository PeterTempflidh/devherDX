@isTest
private class UnitTestCtrLDSHistoryRelatedList {

	@testSetup static void setup() {
		UnitTestDataFactory.getRecordtypeValues();
		Country__c c = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
		insert c;

		Account a = UnitTestDataFactory.createAccount('test', c, 'CD_Account');
		insert a;
	}

	@isTest static void CtrLDSHistoryRelatedListBuildCorrectly() {
		CtrLDSHistoryRelatedList ctr;
		Test.startTest();
		ctr = new CtrLDSHistoryRelatedList();
		Test.stopTest();
		System.assert(ctr.historyRecords.isEmpty());
	}

	@isTest static void loadRecordsReturnsCorrectly() {
		Account acc = [Select Id from Account limit 1];

		CtrLDSHistoryRelatedList ctr = new CtrLDSHistoryRelatedList();
		PageReference res;

		Test.startTest();

		ctr.historyObject = 'AccountHistory';
		ctr.parentField = 'AccountId';
		ctr.parentObject = 'Account';
		ctr.parentReocrd = acc.Id;

		ctr.mockHistoryFields = new List<CtrLDSHistoryRelatedList.HistoryWrapper>();

		CtrLDSHistoryRelatedList.HistoryWrapper h1 = new CtrLDSHistoryRelatedList.HistoryWrapper();
		h1.oldVal = 'ciao';
		h1.newVal = 'come';
		h1.Field = 'Name';
		CtrLDSHistoryRelatedList.HistoryWrapper h2 = new CtrLDSHistoryRelatedList.HistoryWrapper();
		h2.oldVal = UserInfo.getUserId();
		h2.newVal = UserInfo.getUserId();
		h2.Field = 'Owner';
		CtrLDSHistoryRelatedList.HistoryWrapper h3 = new CtrLDSHistoryRelatedList.HistoryWrapper();
		h3.oldVal = UserInfo.getUserName();
		h3.newVal = UserInfo.getUserName();
		h3.Field = 'Owner';
		CtrLDSHistoryRelatedList.HistoryWrapper h4 = new CtrLDSHistoryRelatedList.HistoryWrapper();
		h4.oldVal = '';
		h4.newVal = acc.Id;
		h4.Field = 'Parent';
		CtrLDSHistoryRelatedList.HistoryWrapper h5 = new CtrLDSHistoryRelatedList.HistoryWrapper();
		h5.oldVal = '';
		h5.newVal = 'account name';
		h5.Field = 'Parent';
		CtrLDSHistoryRelatedList.HistoryWrapper h6 = new CtrLDSHistoryRelatedList.HistoryWrapper();
		h6.oldVal = 'Ecuador';
		h6.newVal = 'Colombia';
		h6.Field = 'Record_Country__c';
		CtrLDSHistoryRelatedList.HistoryWrapper h7 = new CtrLDSHistoryRelatedList.HistoryWrapper();
		h7.oldVal = 'Offline';
		h7.newVal = 'Online';
		h7.Field = 'Online_Status_Backend__c';
		CtrLDSHistoryRelatedList.HistoryWrapper h8 = new CtrLDSHistoryRelatedList.HistoryWrapper();
		h8.oldVal = '2017-02-01 18:00:00';
		h8.newVal = '2017-02-01 18:00:00';
		h8.Field = 'CreatedDate';
		CtrLDSHistoryRelatedList.HistoryWrapper h9 = new CtrLDSHistoryRelatedList.HistoryWrapper();
		h9.oldVal = '2017-02-21';
		h9.newVal = '2017-02-21';
		h9.Field = 'First_Payment_Date__c';

		ctr.mockHistoryFields.add(h1);
		ctr.mockHistoryFields.add(h2);
		ctr.mockHistoryFields.add(h3);
		ctr.mockHistoryFields.add(h4);
		ctr.mockHistoryFields.add(h5);
		ctr.mockHistoryFields.add(h6);
		ctr.mockHistoryFields.add(h7);
		ctr.mockHistoryFields.add(h8);
		ctr.mockHistoryFields.add(h9);

		res = ctr.loadAllRecords();

		Test.stopTest();

		System.assertEquals(null, res);
		System.assert(!ctr.historyRecords.isEmpty());
	}

	@isTest static void loadRecordsFilterHisotryCorrectly() {
		Account acc = [Select Id from Account limit 1];

		CtrLDSHistoryRelatedList ctr = new CtrLDSHistoryRelatedList();
		PageReference res1;

		Test.startTest();

		ctr.historyObject = 'AccountHistory';
		ctr.parentField = 'AccountId';
		ctr.parentObject = 'Account';
		ctr.parentReocrd = acc.Id;

		ctr.mockHistoryFields = new List<CtrLDSHistoryRelatedList.HistoryWrapper>();

		// ok
		CtrLDSHistoryRelatedList.HistoryWrapper h1 = new CtrLDSHistoryRelatedList.HistoryWrapper();
		h1.oldVal = 'ciao';
		h1.newVal = 'come';
		h1.Field = 'Name';

		// not ok
		CtrLDSHistoryRelatedList.HistoryWrapper h2 = new CtrLDSHistoryRelatedList.HistoryWrapper();
		h2.oldVal = '';
		h2.newVal = '';
		h2.Field = 'Owner';
		
		// not ok
		CtrLDSHistoryRelatedList.HistoryWrapper h3 = new CtrLDSHistoryRelatedList.HistoryWrapper();
		h3.oldVal = UserInfo.getUserId();
		h3.newVal = UserInfo.getUserId();
		h3.Field = 'Owner';
		
		// not ok
		CtrLDSHistoryRelatedList.HistoryWrapper h4 = new CtrLDSHistoryRelatedList.HistoryWrapper();
		h4.oldVal = '';
		h4.newVal = acc.Id;
		h4.Field = 'Parent';
		
		// not ok
		CtrLDSHistoryRelatedList.HistoryWrapper h5 = new CtrLDSHistoryRelatedList.HistoryWrapper();
		h5.oldVal = '';
		h5.newVal = 'account name';
		h5.Field = 'ParentNotExist';

		ctr.mockHistoryFields.add(h1);
		ctr.mockHistoryFields.add(h2);
		ctr.mockHistoryFields.add(h3);
		ctr.mockHistoryFields.add(h4);
		ctr.mockHistoryFields.add(h5);

		res1 = ctr.loadRecords();

		Test.stopTest();

		System.assertEquals(null, res1);
		System.assert(!ctr.historyRecords.isEmpty());
		System.assertEquals(1, ctr.historyRecords.size());
	}

}