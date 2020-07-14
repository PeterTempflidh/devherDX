@isTest
private class UnitTestClsBrandingContent {

	static String activeRule = '{"isActive": true, "validBrandingTypes": ["Blade sign"], "activeStatusToAccountStatus": {"Installed successfully": "Branded"}, "waitingStatusToAccountStatus": {"New - Awaiting Installation": "In Progress"}, "inactiveStatusToAccountStatus": {"Uninstalled": "", "Canceled": ""}, "accountStatusOnDelete": ""}';
	static String inactiveRule = '{"isActive": false }';
	static Id RT_ID = LibRecordTypeHelper.getRecordType('UK_Branding_Content', 'Branding_Content__c').Id;
	static Opportunity opp_uk;

	@testSetup
	static void setup() {

		UnitTestDataFactory.getRecordTypeValues();
		Country__c c = UnitTestDataFactory.createCountry('UK', 'United Kingdom', 'GBP');
		insert c;

		List<Business_Config__c> configs = new List<Business_Config__c>();


		configs.add(
		    UnitTestDataFactory.createBusinessConfig(
		        'BrandingActivation',
		        'Process',
		        'checkForAccountUpdate',
		        activeRule,
		        c.id,
		        'UK_Branding_Content',
		        true,
		        true)
		);
		
		configs.add(
		    UnitTestDataFactory.createBusinessConfig(
		        'BrandingActivation',
		        'Process',
		        'checkForBrandingActivation',
		        'true',
		        c.id,
		        'UK_Branding_Content',
		        true,
		        false)
		);
        	configs.add(
		    UnitTestDataFactory.createBusinessConfig(
		        'BrandingActivation',
		        'Process',
		        'brandingActivationStatus',
		        'Installed successfully',
		        c.id,
		        'UK_Branding_Content',
		        true,
		        false)
		);
      

		insert configs;

		List<Account> accs = UnitTestDataFactory.createAccounts(1, c, 'UK_Account');
		insert accs;
		
		opp_uk = UnitTestDataFactory.createOpportunity('TestOpp123', accs[0], 'UK_Opportunity', Date.today());
		insert opp_uk;

		Case acase = UnitTestDataFactory.createCase(accs[0], 'Closed', 'Onboarding', '', '', c, 'CD_Entry_Case', '');
		acase.Closed_Reason__c = 'Successful';
		Case acase1 = UnitTestDataFactory.createCase(accs[0], 'Closed', 'Menu Processing', '', '', c, 'CD_Entry_Case', '');
		acase1.Closed_Reason__c = 'Take Online';
		Case acase2 = UnitTestDataFactory.createCase(accs[0], 'Closed', 'Quality Check', '', '', c, 'CD_Entry_Case', '');
		acase2.Closed_Reason__c = 'Successful';

		insert new List<Case>{acase,acase1,acase2};
	}

	@isTest static void updateAccountBrandingStatusDoesNothingIfBusinessConfigIsEmpty() {
		// delete business configs
		delete [select id from Business_Config__c];

		Account acc = [Select Id from Account limit 1];

		Test.startTest();

		insert getActiveBrandingContent(acc);

		Test.stopTest();

		Account res = [Select Branding_Status__c From Account where Id = : acc.Id];

		System.assertNotEquals('Branded', res.Branding_Status__c);
	}

	@isTest static void updateAccountBrandingStatusDoesNothingIfBusinessConfigIsEmptyPerRecordType() {
		Account acc = [Select Id from Account limit 1];

		Test.startTest();

		Branding_Content__c bc = getActiveBrandingContent(acc);
		bc.RecordTypeId = LibRecordTypeHelper.getRecordType('AT_Branding_Content', 'Branding_Content__c').Id;
		insert bc;

		Test.stopTest();

		Account res = [Select Branding_Status__c From Account where Id = : acc.Id];

		System.assertNotEquals('Branded', res.Branding_Status__c);
	}

	@isTest static void updateAccountBrandingStatusDoesNothingIfConfigNotActive() {
		Account acc = [Select Branding_Status__c from Account limit 1];

		Business_Config__c config = [Select Business_Rule_Value__c From Business_Config__c Where Business_Rule_Name__c = 'checkForAccountUpdate'];
		config.Business_Rule_Value__c = inactiveRule;
		update config;

		Test.startTest();

		Branding_Content__c bc = getActiveBrandingContent(acc);
		insert bc;

		Test.stopTest();

		Account res = [Select Branding_Status__c From Account where Id = : acc.Id];

		System.assertEquals(acc.Branding_Status__c, res.Branding_Status__c);
	}

	@isTest static void updateAccountBrandingStatusDoesNothingAfterUpdateIfStatusIsNotChanged() {
		Account acc = [Select Id from Account limit 1];
		Branding_Content__c bc = getActiveBrandingContent(acc);
		insert bc;

		Test.startTest();

		bc.Quantity__c = 2;
		update bc;

		Test.stopTest();

		Account res = [Select Branding_Status__c From Account where Id = : acc.Id];

		System.assertEquals('Branded', res.Branding_Status__c);
	}

	@isTest static void updateAccountBrandingStatusDoesNothingIfBrandingTypeIsNotConfigured() {
		Account acc = [Select Branding_Status__c from Account limit 1];

		Test.startTest();

		Branding_Content__c bc = getBrandingContent(acc, 'Installed successfully', 'Type that not exist');
		insert bc;

		Test.stopTest();

		Account res = [Select Branding_Status__c From Account where Id = : acc.Id];

		System.assertEquals(acc.Branding_Status__c, res.Branding_Status__c);
	}

	@isTest static void updateAccountBrandingStatusDoesNothingIfStatusIsNotConfigured() {
		Account acc = [Select Branding_Status__c from Account limit 1];

		Test.startTest();

		Branding_Content__c bc = getBrandingContent(acc, 'Transferred', 'Blade sign');
		insert bc;

		Test.stopTest();

		Account res = [Select Branding_Status__c From Account where Id = : acc.Id];

		System.assertEquals(acc.Branding_Status__c, res.Branding_Status__c);
	}

	@isTest static void updateAccountBrandingStatusUpdatesAccountRecordWhenActiveBrandingContentIsInserted() {
		Account acc = [Select Id from Account limit 1];

		Test.startTest();

		Branding_Content__c bc = getActiveBrandingContent(acc);
		insert bc;

		Test.stopTest();

		Account res = [Select Branding_Status__c From Account where Id = : acc.Id];
		System.assertEquals('Branded', res.Branding_Status__c);
	}

	@isTest static void updateAccountBrandingStatusUpdatesAccountRecordWhenInactiveBrandingContentIsInserted() {
		Account acc = [Select Id from Account limit 1];

		Test.startTest();

		Branding_Content__c bc = getInactiveBrandingContent(acc);
		insert bc;

		Test.stopTest();

		Account res = [Select Branding_Status__c From Account where Id = : acc.Id];
		System.assert(String.isBlank(res.Branding_Status__c));
	}

	@isTest static void updateAccountBrandingStatusChangeBrandingStatusFromActiveToInactive() {
		Account acc = [Select Id from Account limit 1];

		Branding_Content__c active = getActiveBrandingContent(acc);
		insert active;

		Test.startTest();

		// turns active into inactive branding content
		Branding_Content__c inactive = getInactiveBrandingContent(acc);
		inactive.Id = active.Id;
		update inactive;
		
		inactive.Status__c = 'Installed successfully';
		inactive.Type__c = 'White Label App';
		update inactive;
		Test.stopTest();

		Account res = [Select Branding_Status__c From Account where Id = : acc.Id];
		System.assert(String.isBlank(res.Branding_Status__c));
	}

	@isTest static void updateAccountBrandingStatusWorksCorrectlyOnBatchInsert() {
		Integer BATCH_SIZE = 200;
		Country__c c = [select name from country__c limit 1];

		List<Account> accsWithActiveBrand = UnitTestDataFactory.createAccounts(BATCH_SIZE / 2, c, 'UK_Account');
		List<Account> accsWithInactiveBrand = UnitTestDataFactory.createAccounts(BATCH_SIZE / 2, c, 'UK_Account');

		List<Account> all = new List<Account>(accsWithActiveBrand);
		all.addAll(accsWithInactiveBrand);
		insert all;

		Test.startTest();

		List<Branding_Content__c> brandings = new List<Branding_Content__c>();

		for (Integer i = 0; i < BATCH_SIZE / 2; i++) {
			brandings.add(getActiveBrandingContent(accsWithActiveBrand.get(i)));
			brandings.add(getInactiveBrandingContent(accsWithInactiveBrand.get(i)));
		}

		insert brandings;

		Test.stopTest();

		Set<Id> accIds = new Set<Id>();
		for (Account acc : accsWithActiveBrand) {
			accIds.add(acc.Id);
		}

		for (Account acc : [select Branding_Status__c from account where id in :accIds]) {
			System.assertEquals('Branded', acc.Branding_Status__c);
		}

		accIds.clear();
		for (Account acc : accsWithInactiveBrand) {
			accIds.add(acc.Id);
		}

		for (Account acc : [select Branding_Status__c from account where id in :accIds]) {
			System.assert(String.isBlank(acc.Branding_Status__c));
		}
	}

	@isTest static void updateAccountBrandingStatusUpdatesAccountRecordWhenBrandingIsDeleted() {
		Account acc = [Select Id from Account limit 1];
		Branding_Content__c active = getActiveBrandingContent(acc);
		insert active;

		Test.startTest();

		delete active;

		Test.stopTest();

		Account res = [Select Branding_Status__c From Account where Id = : acc.Id];

		System.assert(String.isBlank(res.Branding_Status__c));
	}

	@isTest static void updateAccountBrandingStatusDoesNothingIfBrandingRecordOfAnotherTypeIsDeleted() {
		Account acc = [Select Id from Account limit 1];
		Branding_Content__c active = getActiveBrandingContent(acc);
		insert active;

		Branding_Content__c other = getBrandingContent(acc, 'Canceled', 'Test Type');
		insert other;

		Test.startTest();

		delete other;

		Test.stopTest();

		Account res = [Select Branding_Status__c From Account where Id = : acc.Id];
		System.assertEquals('Branded', res.Branding_Status__c);
	}

	@isTest static void updateAccountBrandingStatusHandleHierarchyCorrectly() {
		Country__c c = [select name from country__c limit 1];

		List<Account> accs = new List<Account>();
			
		Account withActiveBrand = UnitTestDataFactory.createAccount('test1',c, 'UK_Account');
		accs.add(withActiveBrand);

		Account withInactiveBrand = UnitTestDataFactory.createAccount('test2',c, 'UK_Account');
		accs.add(withInactiveBrand);

		Account withWaitingBrand = UnitTestDataFactory.createAccount('test3',c, 'UK_Account');
		accs.add(withWaitingBrand);

		Account withActiveBrandToDelete = UnitTestDataFactory.createAccount('test4',c, 'UK_Account');
		accs.add(withActiveBrandToDelete);

		insert accs;

		List<Branding_Content__c> toinsert = new List<Branding_Content__c>();
		toinsert.add(getActiveBrandingContent(withActiveBrand));
		toinsert.add(getInactiveBrandingContent(withInactiveBrand));
		toinsert.add(getWaitingBrandingContent(withWaitingBrand));
		toinsert.add(getActiveBrandingContent(withActiveBrandToDelete));
		insert toinsert;

		Test.startTest();

		toinsert.clear();

		// add an inactive and waiting brand to the active one
		toinsert.add(getInactiveBrandingContent(withActiveBrand));
		toinsert.add(getWaitingBrandingContent(withActiveBrand));

		// add waiting brand to inactive
		toinsert.add(getWaitingBrandingContent(withInactiveBrand));

		// add inactive to waiting
		toinsert.add(getWaitingBrandingContent(withInactiveBrand));

		insert toinsert;

		delete [select id from branding_content__c where Restaurant_Name__c =: withActiveBrandToDelete.Id];

		Test.stopTest();

		// active should remain the same
		Map<Id, Account> accounts = new Map<Id, Account>([Select Branding_Status__c from Account]);
		System.assertEquals('Branded', accounts.get(withActiveBrand.Id).Branding_Status__c);

		// inactive should be waiting now
		System.assertEquals('In Progress', accounts.get(withInactiveBrand.Id).Branding_Status__c);

		// waiting should be the same
		System.assertEquals('In Progress', accounts.get(withWaitingBrand.Id).Branding_Status__c);

		// deleted should be blank
		System.assert(String.isBlank(accounts.get(withActiveBrandToDelete.Id).Branding_Status__c));

	}

	static Branding_Content__c getActiveBrandingContent(Account acc) {
		return getBrandingContent(acc, 'Installed successfully', 'Blade sign');
	}

	static Branding_Content__c getInactiveBrandingContent(Account acc) {
		return getBrandingContent(acc, 'Canceled', 'Blade sign');
	}

	static Branding_Content__c getWaitingBrandingContent(Account acc) {
		return getBrandingContent(acc, 'New - Awaiting Installation', 'Blade sign');
	}

	static Branding_Content__c getBrandingContent(Account acc, String status, String type) {
		return new Branding_Content__c(
		           RecordTypeId = RT_ID,
		           Type__c = type,
		           Quantity__c = 1,
		           Restaurant_Name__c = acc.id,
		           Status__c = status
		       );
	}
}
