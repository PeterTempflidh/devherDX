@isTest
private class UnitTestBatchDelayedOnboardingCreation {

	@testSetup static void setup() {

		UnitTestDataFactory.getRecordtypeValues();

		Country__c bh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
		Country__c ec = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
		insert new List<Country__c> {ec, bh};

		List<Business_Config__c> rules = new List<Business_Config__c>();
        String rtIdRestaurantOperationTL = LibRecordTypeHelper.getRecordTypeValue('Talabat_Restaurant_Ops');
        String rtIdRestaurantOperationCD = LibRecordTypeHelper.getRecordTypeValue('CD_Restaurant_Operations');
		// ec rules
		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'CD_Account',
		        Id_Country__c = ec.Id,
		        Is_Active__c = true,
		        Parent__c = true,
		        Type__c = 'Process',
		        Process_Name__c = 'DelayedOnboardingCreation',
		        Business_Rule_Name__c = 'validChildAccountTypes',
		        Business_Rule_Value__c = 'Branch'
		    )
		);

		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'CD_Account',
		        Id_Country__c = ec.Id,
		        Is_Active__c = true,
		        Parent__c = false,
		        Type__c = 'Process',
		        Process_Name__c = 'DelayedOnboardingCreation',
		        Business_Rule_Name__c = 'onboardingCaseFields',
		        Business_Rule_Value__c = '{ "RecordTypeId": "'+rtIdRestaurantOperationCD +'","type": "Onboarding", "subject": "Onboard Restaurant", "status": "New", "Origin": "Automatic"}'
		    )
		);

        
		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'CD_Account',
		        Id_Country__c = ec.Id,
		        Is_Active__c = true,
		        Parent__c = false,
		        Type__c = 'Process',
		        Process_Name__c = 'DelayedOnboardingCreation',
		        Business_Rule_Name__c = 'unSuccessfulClosedReason',
		        Business_Rule_Value__c = 'Not Successful'
		    )
		);

		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'CD_Account',
		        Id_Country__c = ec.Id,
		        Is_Active__c = true,
		        Parent__c = false,
		        Type__c = 'Process',
		        Process_Name__c = 'DelayedOnboardingCreation',
		        Business_Rule_Name__c = 'parentOpportunityFields',
		        Business_Rule_Value__c = '{"Business_Type__c": "New Business"}'
		    )
		);

		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'CD_Account',
		        Id_Country__c = ec.Id,
		        Is_Active__c = true,
		        Parent__c = false,
		        Type__c = 'Process',
		        Process_Name__c = 'DelayedOnboardingCreation',
		        Business_Rule_Name__c = 'assetValidStatuses',
		        Business_Rule_Value__c = 'Activated Successfully'
		    )
		);

		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'CD_Account',
		        Id_Country__c = ec.Id,
		        Is_Active__c = true,
		        Parent__c = false,
		        Type__c = 'Process',
		        Process_Name__c = 'DelayedOnboardingCreation',
		        Business_Rule_Name__c = 'validOppStageNames',
		        Business_Rule_Value__c = 'Onboarding,Quality Check Request'
		    )
		);

		// bh rules
		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'Talabat_Account',
		        Id_Country__c = bh.Id,
		        Is_Active__c = true,
		        Parent__c = true,
		        Type__c = 'Process',
		        Process_Name__c = 'DelayedOnboardingCreation',
		        Business_Rule_Name__c = 'validChildAccountTypes',
		        Business_Rule_Value__c = 'Branch'
		    )
		);

		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'Talabat_Account',
		        Id_Country__c = bh.Id,
		        Is_Active__c = true,
		        Parent__c = false,
		        Type__c = 'Process',
		        Process_Name__c = 'DelayedOnboardingCreation',
		        Business_Rule_Name__c = 'onboardingCaseFields',
		        Business_Rule_Value__c = '{ "RecordTypeId": "'+rtIdRestaurantOperationTL +'","type": "Onboarding", "subject": "Onboard Restaurant", "status": "New", "Origin": "Automatic"}'
		    )
		);

		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'Talabat_Account',
		        Id_Country__c = bh.Id,
		        Is_Active__c = true,
		        Parent__c = false,
		        Type__c = 'Process',
		        Process_Name__c = 'DelayedOnboardingCreation',
		        Business_Rule_Name__c = 'unSuccessfulClosedReason',
		        Business_Rule_Value__c = 'Not Successful'
		    )
		);

		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'Talabat_Account',
		        Id_Country__c = bh.Id,
		        Is_Active__c = true,
		        Parent__c = false,
		        Type__c = 'Process',
		        Process_Name__c = 'DelayedOnboardingCreation',
		        Business_Rule_Name__c = 'parentOpportunityFields',
		        Business_Rule_Value__c = '{"Business_Type__c": "New Business"}'
		    )
		);

		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'Talabat_Account',
		        Id_Country__c = bh.Id,
		        Is_Active__c = true,
		        Parent__c = false,
		        Type__c = 'Process',
		        Process_Name__c = 'DelayedOnboardingCreation',
		        Business_Rule_Name__c = 'assetValidStatuses',
		        Business_Rule_Value__c = 'Activated Successfully'
		    )
		);

		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'Talabat_Account',
		        Id_Country__c = ec.Id,
		        Is_Active__c = true,
		        Parent__c = false,
		        Type__c = 'Process',
		        Process_Name__c = 'DelayedOnboardingCreation',
		        Business_Rule_Name__c = 'validOppStageNames',
		        Business_Rule_Value__c = 'Onboarding,Quality Check Request'
		    )
		);

		insert rules;

		List<Account> accs = new List<Account>();

		Account ecParentAcc = UnitTestDataFactory.createAccount('Franchise Account', ec, 'CD_Account');
		ecParentAcc.Type = 'Franchise';
		insert ecParentAcc;

		Account bhParentAcc = UnitTestDataFactory.createAccount('Brand Account', bh, 'Talabat_Account');
		bhParentAcc.Type = 'Brand';
		insert bhParentAcc;

		Account[] ecChildrenAcc = UnitTestDataFactory.createAccounts(2, ec, 'CD_Account');
		for (Account a : ecChildrenAcc) {
			a.Type = 'Branch';
			a.ParentId = ecParentAcc.Id;
			a.Delivery_Service__c = 'Hybrid';
		}

		Account[] bhChildrenAcc = UnitTestDataFactory.createAccounts(2, bh, 'Talabat_Account');
		for (Account a : bhChildrenAcc) {
			a.Type = 'Branch';
			a.ParentId = bhParentAcc.Id;
			a.Delivery_Service__c = 'DH Delivery';
		}

		accs.addAll(ecChildrenAcc);
		accs.addAll(bhChildrenAcc);

		insert accs;

		List<Opportunity> opps = new List<Opportunity>();

		Opportunity ecOpp = UnitTestDataFactory.createOpportunity('Parent Opps', ecParentAcc, 'CD_Opportunity', Date.today());
		ecOpp.Business_Type__c = 'New Business';

		Opportunity bhOpp = UnitTestDataFactory.createOpportunity('Parent Bh Opp', bhParentAcc, 'Talabat_Opportunity', Date.today());
		bhOpp.Business_Type__c = 'New Business';

		insert new List<Opportunity> {ecOpp, bhOpp};

		for (Account a : ecChildrenAcc) {
			opps.add(UnitTestDataFactory.createOpportunity('child opp', a, 'CD_Opportunity', Date.today()));
		}

		for (Account a : bhChildrenAcc) {
			opps.add(UnitTestDataFactory.createOpportunity('child bh opp', a, 'Talabat_Opportunity', Date.today()));
		}

		insert opps;

		for (Opportunity opp : opps) {
			opp.StageName = 'Quality Check Request';
			opp.Business_Type__c = 'New Business';
		}
		update opps;

		List<Asset__c> assets = new List<Asset__c>();

		Id bhrtid = [Select id From RecordType Where DeveloperName = 'Talabat_Asset'].Id;
		Id ecrtid = [Select id From RecordType Where DeveloperName = 'CD_Asset'].Id;

		for (Opportunity opp : opps) {
			assets.add(new Asset__c(
			               Account__c = opp.AccountId,
			               Opportunity__c = opp.Id,
			               Status__c = 'New',
			               Name = 'asset',
			               RecordTypeId = opp.Name.contains('bh') ? bhrtid : ecrtid
			           ));
		}

		insert assets;

		// account without opps but just assets
		Account ecNoOpp = UnitTestDataFactory.createAccount('ec with no opp', ec, 'CD_Account');
		ecNoOpp.Type = 'Branch';
		ecNoOpp.ParentId = ecParentAcc.Id;

		Account bhNoOpp = UnitTestDataFactory.createAccount('bh with no opp', bh, 'Talabat_Account');
		bhNoOpp.Type = 'Branch';
		bhNoOpp.ParentId = bhParentAcc.Id;

		insert new List<Account> {ecNoOpp, bhNoOpp};

		Asset__c ecAst = new Asset__c(
		    Account__c = ecNoOpp.Id,
		    Status__c = 'New',
		    Name = 'asset',
		    RecordTypeId = ecrtid
		);

		Asset__c bhAst = new Asset__c(
		    Account__c = bhNoOpp.Id,
		    Status__c = 'New',
		    Name = 'asset',
		    RecordTypeId = bhrtid
		);

		insert new List<Asset__c>{bhAst, ecAst};
	}

	@isTest static void batchDelayedOnboardingCreationWorksCorrectly() {
		Opportunity[] opps = getParentOpps(new Set<String> {'CD_Opportunity', 'Talabat_Opportunity'});

		for (Opportunity o : opps) {
			o.StageName = 'Closed Won';
		}

		update opps;

		Asset__c[] assets = getAssetWithOpp(new Set<String> {'Talabat_Asset', 'CD_Asset'});
		assets.addAll(getAssetWithoutOpp(new Set<String> {'Talabat_Asset', 'CD_Asset'}));
		for (Asset__c a : assets) {
			a.Status__c = 'Activated Successfully';
		}
		update assets;

		Test.startTest();

		Database.executeBatch(new BatchDelayedOnboardingCreation());

		Test.stopTest();

		Map<Id, Boolean> oppIdToCase = new Map<Id, Boolean>();
		Map<Id, Boolean> accIdToCase = new Map<Id, Boolean>();
		Case[] onboardings = [SELECT Opportunity__c, AccountId FROM Case WHERE Type = 'Onboarding'];
		Opportunity[] childOpps = getChildOpps(new Set<String> {'CD_Opportunity', 'Talabat_Opportunity'});
		Account[] accNoOpp = getAccountWithoutOpp(new Set<String> {'CD_Account', 'Talabat_Account'});

		for (Case c : onboardings) {
			oppIdToCase.put(c.Opportunity__c, true);
			accIdToCase.put(c.AccountId, true);
		}

		System.assertEquals(childOpps.size() + accNoOpp.size(), onboardings.size());

		for (Opportunity opp : childOpps) {
			System.assert(oppIdToCase.containsKey(opp.Id));
			System.assertEquals('Onboarding', opp.StageName);
		}

		for (Account acc : accNoOpp) {
			System.assert(accIdToCase.containsKey(acc.Id));
		}
	}

	@isTest static void batchDelayedOnboardingCreationSkipsAssetNonActivated() {
		Opportunity[] opps = getParentOpps(new Set<String> {'CD_Opportunity'});
		for (Opportunity o : opps) {
			o.StageName = 'Closed Won';
		}
		update opps;

		Id oppWithActiveAsset;

		Asset__c[] assets = getAssetWithOpp(new Set<String> {'CD_Asset'});
		assets[0].Status__c = 'Activated Successfully';
		oppWithActiveAsset = assets[0].Opportunity__c;

		update assets;
		System.debug('Accounts test'+ [select id,Record_Country__c, RecordType.DeveloperName  from account ]);
		Test.startTest();

		Database.executeBatch(new BatchDelayedOnboardingCreation());

		Test.stopTest();

		Case[] onboardings = [SELECT Opportunity__c, AccountId FROM Case WHERE Type = 'Onboarding'];

		System.assertEquals(1, onboardings.size());
		System.assertEquals(oppWithActiveAsset, onboardings[0].Opportunity__c);
	}

	@isTest static void batchDelayedOnboardingCreationSkipsParentAccountWithoutValidOpportunity() {
		Opportunity[] opps = getParentOpps(new Set<String> {'CD_Opportunity'});
		for (Opportunity o : opps) {
			o.Business_Type__c = 'Upgrade/Upsell';
			o.StageName = 'Closed Won';
		}
		update opps;

		// talabat is not closed won and cd has wrong business type

		Asset__c[] assets = getAssetWithOpp(new Set<String> {'Talabat_Asset', 'CD_Asset'});
		for (Asset__c a : assets) {
			a.Status__c = 'Activated Successfully';
		}
		update assets;

		Test.startTest();

		Database.executeBatch(new BatchDelayedOnboardingCreation());

		Test.stopTest();

		Case[] onboardings = [SELECT Opportunity__c, AccountId FROM Case WHERE Type = 'Onboarding'];

		System.assert(onboardings.isEmpty());
	}

	@isTest static void batchDelayedOnboardingCreationSkipsOpportunityWithValidOnboardingCase() {
		Opportunity[] opps = getParentOpps(new Set<String> {'CD_Opportunity', 'Talabat_Opportunity'});
		for (Opportunity o : opps) {
			o.StageName = 'Closed Won';
		}
		update opps;

		Asset__c[] assets = getAssetWithOpp(new Set<String> {'Talabat_Asset', 'CD_Asset'});
		for (Asset__c a : assets) {
			a.Status__c = 'Activated Successfully';
		}
		update assets;

		Opportunity[] ecChildOpps = getChildOpps(new Set<String> {'CD_Opportunity'});
		Opportunity[] bhChildOpps = getChildOpps(new Set<String> {'Talabat_Opportunity'});

		// closed successfully
		Case onb1 = new Case(
		    Status = 'Closed',
		    Type = 'Onboarding',
		    Closed_Reason__c = 'Successful',
		    AccountId = ecChildOpps[0].AccountId,
				Country__c = 'Ecuador',
		    Opportunity__c = ecChildOpps[0].Id,
            RecordTypeId = LibRecordTypeHelper.getRecordTypeValue('CD_Restaurant_Operations'),
            Root_Cause__c = 'root',
            Comments_del__c = 'Comments'
		);

		// closed not successfully
		Case onb2 = new Case(
		    Status = 'Closed',
		    Type = 'Onboarding',
		    Closed_Reason__c = 'Not Successful',
				Country__c = 'Ecuador',
		    AccountId = ecChildOpps[1].AccountId,
		    Opportunity__c = ecChildOpps[1].Id,
                RecordTypeId = LibRecordTypeHelper.getRecordTypeValue('CD_Restaurant_Operations'),
                Root_Cause__c = 'root',
                Comments_del__c = 'Comments'
		);

		// still open
		Case onb3 = new Case(
		    Status = 'New',
		    Type = 'Onboarding',
		    AccountId = bhChildOpps[0].AccountId,
			Country__c = 'Bahrain',
		    Opportunity__c = bhChildOpps[0].Id,
				RecordTypeId = LibRecordTypeHelper.getRecordTypeValue('Talabat_Restaurant_Ops')
		);

		insert new List<Case> {onb1, onb2, onb3};

		Set<Id> alreadyCreatedOnboarding = new Set<Id> {onb1.Id, onb2.Id, onb3.Id};

		Test.startTest();

		Database.executeBatch(new BatchDelayedOnboardingCreation());

		Test.stopTest();

		Case[] onboardings = [SELECT Opportunity__c, AccountId FROM Case WHERE Type = 'Onboarding' AND Id not in: alreadyCreatedOnboarding];

		System.assertEquals(2, onboardings.size());
	}

	@isTest static void batchDelayedOnboardingCreationSkipsOpportunityWithoutAssets() {
		Opportunity[] opps = getParentOpps(new Set<String> {'CD_Opportunity', 'Talabat_Opportunity'});
		for (Opportunity o : opps) {
			o.StageName = 'Closed Won';
		}
		update opps;

		Asset__c[] assets = getAssetWithOpp(new Set<String> {'Talabat_Asset'});
		for (Asset__c a : assets) {
			a.Status__c = 'Activated Successfully';
		}
		update assets;

		delete getAssetWithOpp(new Set<String> {'CD_Asset'});

		Test.startTest();

		Database.executeBatch(new BatchDelayedOnboardingCreation());

		Test.stopTest();

		Map<Id, Boolean> oppIdToCase = new Map<Id, Boolean>();

		Case[] onboardings = [SELECT Opportunity__c, AccountId FROM Case WHERE Type = 'Onboarding'];

		Opportunity[] cdOpps = getChildOpps(new Set<String> {'CD_Opportunity'});
		Opportunity[] bhOpps = getChildOpps(new Set<String> {'Talabat_Opportunity'});

		for (Case c : onboardings) {
			oppIdToCase.put(c.Opportunity__c, true);
		}

		for (Opportunity opp : cdOpps) {
			System.assert(!oppIdToCase.containsKey(opp.Id));
			System.assertNotEquals('Onboarding', opp.StageName);
		}

		for (Opportunity opp : bhOpps) {
			System.assert(oppIdToCase.containsKey(opp.Id));
		}
	}

	@isTest static void batchDelayedOnboardingCreationSkipsAssetRelatedToWrongAccounts() {
		Opportunity[] opps = getParentOpps(new Set<String> {'CD_Opportunity', 'Talabat_Opportunity'});
		for (Opportunity o : opps) {
			o.StageName = 'Closed Won';
		}
		update opps;

		Account[] accs = getAccountWithoutOpp(new Set<String> {'CD_Account'});
		for (Account acc : accs) {
			acc.Type = 'Brand';
		}
		update accs;

		Asset__c[] assets = getAssetWithoutOpp(new Set<String> {'Talabat_Asset', 'CD_Asset'});
		for (Asset__c ast : assets) {
			ast.Status__c = 'Activated Successfully';
		}
		update assets;

		Test.startTest();

		Database.executeBatch(new BatchDelayedOnboardingCreation());

		Test.stopTest();

		Case[] cases = [Select AccountId From Case Where Type = 'Onboarding'];
		Account acc = getAccountWithoutOpp(new Set<String>{'Talabat_Account'})[0];

		System.assertEquals(1, cases.size());
		System.assertEquals(acc.Id, cases[0].AccountId);
	}



	static Asset__c[] getAssetWithOpp(Set<String> recordTypes) {
		return [Select Status__c, Opportunity__c From Asset__c Where RecordType.DeveloperName in : recordTypes And Opportunity__c != ''];
	}

	static Asset__c[] getAssetWithoutOpp(Set<String> recordTypes) {
		return [Select Status__c, Opportunity__c From Asset__c Where RecordType.DeveloperName in : recordTypes And Opportunity__c = ''];
	}

	static Opportunity[] getParentOpps(Set<String> recordTypes) {
		return [SELECT StageName, Business_Type__c FROM Opportunity WHERE RecordType.DeveloperName in : recordTypes AND Account.ParentId = ''];
	}

	static Opportunity[] getChildOpps(Set<String> recordTypes) {
		return [Select StageName, AccountId From Opportunity Where RecordType.DeveloperName in : recordTypes AND Account.ParentId != ''];
	}

	static Account[] getAccountWithoutOpp(Set<String> recordTypes) {
		return [Select Type From Account Where Name like '%with no opp' And RecordType.DeveloperName in: recordTypes];
	}
}