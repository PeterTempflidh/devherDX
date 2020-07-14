@isTest
private class UnitTestBatchDelayedContractActivation {

	@testSetup static void setup() {
		UnitTestDataFactory.getRecordtypeValues();

		Country__c ec = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
		Country__c bh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');

		insert new List<Country__c> {ec, bh};

		company__c com = UnitTestDataFactory.createCompany('Talabat', 'Talabat', bh);
        insert com;

		List<Business_Config__c> rules = new List<Business_Config__c>();

		// ec rules
		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'CD_Account',
		        Id_Country__c = ec.Id,
		        Is_Active__c = true,
		        Parent__c = true,
		        Type__c = 'Process',
		        Process_Name__c = 'DelayedActivationOfContractsAndAddCharges',
		        Business_Rule_Name__c = 'parentAccountType',
		        Business_Rule_Value__c = 'Franchise'
		    )
		);

		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'CD_Account',
		        Id_Country__c = ec.Id,
		        Is_Active__c = true,
		        Parent__c = false,
		        Type__c = 'Process',
		        Process_Name__c = 'DelayedActivationOfContractsAndAddCharges',
		        Business_Rule_Name__c = 'childAccountType',
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
		        Process_Name__c = 'DelayedActivationOfContractsAndAddCharges',
		        Business_Rule_Name__c = 'validContractStatuses',
		        Business_Rule_Value__c = 'Draft'
		    )
		);

		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'CD_Account',
		        Id_Country__c = ec.Id,
		        Is_Active__c = true,
		        Parent__c = false,
		        Type__c = 'Process',
		        Process_Name__c = 'DelayedActivationOfContractsAndAddCharges',
		        Business_Rule_Name__c = 'contractActivationStatus',
		        Business_Rule_Value__c = 'Activated'
		    )
		);

		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'CD_Restaurant_Operations',
		        Id_Country__c = ec.Id,
		        Is_Active__c = true,
		        Parent__c = true,
		        Type__c = 'Process',
		        Process_Name__c = 'RestaurantCareClosingAction',
		        Business_Rule_Name__c = 'closingReason',
		        Business_Rule_Value__c = '{"Positive":"Successful,Take Online","Negative":"Invalid,Not Successful"}'
		    )
		);

		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'CD_Restaurant_Operations',
		        Id_Country__c = ec.Id,
		        Is_Active__c = true,
		        Parent__c = false,
		        Type__c = 'Process',
		        Process_Name__c = 'RestaurantCareClosingAction',
		        Business_Rule_Name__c = 'Type',
		        Business_Rule_Value__c = 'Onboarding'
		    )
		);

		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'Talabat_Account',
		        Id_Country__c = bh.Id,
		        Is_Active__c = true,
		        Parent__c = true,
		        Type__c = 'Process',
		        Process_Name__c = 'DelayedActivationOfContractsAndAddCharges',
		        Business_Rule_Name__c = 'parentAccountType',
		        Business_Rule_Value__c = 'Brand'
		    )
		);

		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'Talabat_Account',
		        Id_Country__c = bh.Id,
		        Is_Active__c = true,
		        Parent__c = true,
		        Type__c = 'Process',
		        Process_Name__c = 'DelayedActivationOfContractsAndAddCharges',
		        Business_Rule_Name__c = 'childAccountType',
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
		        Process_Name__c = 'DelayedActivationOfContractsAndAddCharges',
		        Business_Rule_Name__c = 'validContractStatuses',
		        Business_Rule_Value__c = 'Draft'
		    )
		);

		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'Talabat_Account',
		        Id_Country__c = bh.Id,
		        Is_Active__c = true,
		        Parent__c = false,
		        Type__c = 'Process',
		        Process_Name__c = 'DelayedActivationOfContractsAndAddCharges',
		        Business_Rule_Name__c = 'contractActivationStatus',
		        Business_Rule_Value__c = 'Activated'
		    )
		);

		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'Talabat_Restaurant_Ops',
		        Id_Country__c = bh.Id,
		        Is_Active__c = true,
		        Parent__c = true,
		        Type__c = 'Process',
		        Process_Name__c = 'RestaurantCareClosingAction',
		        Business_Rule_Name__c = 'closingReason',
		        Business_Rule_Value__c = '{"Positive":"Successful,Take Online","Negative":"Invalid,Not Successful"}'
		    )
		);

		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'Talabat_Restaurant_Ops',
		        Id_Country__c = bh.Id,
		        Is_Active__c = true,
		        Parent__c = false,
		        Type__c = 'Process',
		        Process_Name__c = 'RestaurantCareClosingAction',
		        Business_Rule_Name__c = 'Type',
		        Business_Rule_Value__c = 'Onboarding'
		    )
		);

		insert rules;

		Account ecClientAccount = UnitTestDataFactory.createAccount('client ec', ec, 'CD_Account');
		ecClientAccount.Type = 'Client';
		insert ecClientAccount;

		Account ecParentAcc = UnitTestDataFactory.createAccount('Franchise Account', ec, 'CD_Account');
		ecParentAcc.Type = 'Franchise';
		ecParentAcc.ParentId = ecClientAccount.Id;
		insert ecParentAcc;

		Account[] ecChildrenAcc = UnitTestDataFactory.createAccounts(1, ec, 'CD_Account');
		for (Account a : ecChildrenAcc) {
			a.Type = 'Branch';
			a.ParentId = ecParentAcc.Id;
		}

		insert ecChildrenAcc;

		

		Opportunity ecParentOpp = UnitTestDataFactory.createOpportunity('Parent Opps', ecParentAcc, 'CD_Opportunity', Date.today());
		ecParentOpp.Business_Type__c = 'New Business';
		insert ecParentOpp;

		

        

		Opportunity ecChildOpp = UnitTestDataFactory.createOpportunity('child opps', ecChildrenAcc[0], 'CD_Opportunity', Date.today());
		ecChildOpp.Business_Type__c = 'New Business';
		insert ecChildOpp;

		Contract parentCnt = UnitTestDataFactory.createContract(ecParentAcc, Date.today(), null, 'Draft', 'CD_Contract');
		parentCnt.Id_Opportunity__c = ecParentOpp.Id;

		Contract childCnt = UnitTestDataFactory.createContract(ecChildrenAcc[0], Date.today(), null, 'Draft', 'CD_Contract');
		childCnt.Id_Opportunity__c = ecChildOpp.Id;
		insert new List<Contract> {parentCnt, childCnt};

		Case csec = UnitTestDataFactory.createCase(ecChildrenAcc[0], 'New', 'Onboarding', 'Successful', 'Automatic', ec, 'CD_Restaurant_Operations', 'test');
		insert csec;

		Account bhParentAcc = UnitTestDataFactory.createAccount('Brand Account', bh, 'Talabat_Account');
		bhParentAcc.Type = 'Brand';
		insert bhParentAcc;

		Account[] bhChildrenAcc = UnitTestDataFactory.createAccounts(1, bh, 'Talabat_Account');
		for (Account a : bhChildrenAcc) {
			a.Type = 'Branch';
			a.ParentId = bhParentAcc.Id;
		}

		insert bhChildrenAcc;

		Opportunity bhParentOpp = UnitTestDataFactory.createOpportunity('Parent Opps', bhParentAcc, 'Talabat_Opportunity', Date.today());
		bhParentOpp.Business_Type__c = 'New Business';
		insert bhParentOpp;

		Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=bhParentOpp.id,status__c='Approved',ID_Account__c=bhParentAcc.id);
        insert newQuote;

		List_Service_Price__c lsp = UnitTestDataFactory.createService(com,bh,'testService1','Talabat_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType');
        insert lsp;

        Opportunity_Line_Item__c oppService = UnitTestDataFactory.createOpportunityLineItemService('testService3',ecParentOpp,lsp.id,true,'Talabat_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        insert oppService;

        List<Opportunity_Quote_Line_Item__c> oppQuoteLine =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'Talabat_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Commission Fee','Service');
        oppQuoteLine[0].id_opportunity__c=bhParentOpp.id;
        oppQuoteLine[0].id_list_service_price__c=lsp.id;
        insert oppQuoteLine ;
        newQuote.status__c='Accepted';
        update newQuote;


		Case cs = UnitTestDataFactory.createCase(bhChildrenAcc[0], 'New', 'Onboarding', 'Successful', 'Automatic', bh, 'Talabat_Restaurant_Ops', 'test');
		insert cs;

		Contract parentbhCnt = UnitTestDataFactory.createContract(bhParentAcc, Date.today(), null, 'Draft', 'Talabat_Contract');
		parentbhCnt.Id_Opportunity__c = bhParentOpp.Id;
		parentbhCnt.id_opportunity_quote_line_item__c=oppQuoteLine[0].id;
		insert parentbhCnt;
	}

	@isTest static void batchDelayedContractActivationWorksCorrectly() {

		setParentOppsAsWon();
		setChildOppsAsWon();
		closeOnboardingSuccessful();

		Test.startTest();

		Database.executeBatch(new BatchDelayedContractActivation());

		Test.stopTest();

		for (Contract c : getParentContracts()) {
			System.assertEquals('Activated', c.Status);
		}

		for (Contract c : getChildContracts()) {
			System.assertEquals('Activated', c.Status);
		}
	}

	@isTest static void batchDelayedContractActivationSkipsContractsIfChildOppStillOpen() {

		setParentOppsAsWon();

		Test.startTest();

		Database.executeBatch(new BatchDelayedContractActivation());

		Test.stopTest();

		for (Contract c : getParentContracts()) {
			System.assertNotEquals('Activated', c.Status);
		}

		for (Contract c : getChildContracts()) {
			System.assertNotEquals('Activated', c.Status);
		}
	}

	@isTest static void batchDelayedContractActivationSkipsContractsIfParentOppStillOpen() {

		setChildOppsAsWon();
		closeOnboardingSuccessful();

		Test.startTest();

		Database.executeBatch(new BatchDelayedContractActivation());

		Test.stopTest();

		for (Contract c : getParentContracts()) {
			System.assertNotEquals('Activated', c.Status);
		}

		for (Contract c : getChildContracts()) {
			System.assertNotEquals('Activated', c.Status);
		}
	}

	@isTest static void batchDelayedContractActivationSkipsParentContractsIfOnbordingFailed() {

		setParentOppsAsWon();
		setChildOppsAsWon();
		closeOnboardingSuccessful(new Set<String> {'CD_Restaurant_Operations'});
		closeOnboardingAsFailed(new Set<String> {'Talabat_Restaurant_Ops'});

		Test.startTest();

		Database.executeBatch(new BatchDelayedContractActivation());

		Test.stopTest();

		Contract[] ecContracts = getParentContracts(new Set<String>{'CD_Contract'});
		ecContracts.addAll(getChildContracts(new Set<String>{'CD_Contract'}));

		for (Contract c : ecContracts) {
			System.assertEquals('Activated', c.Status);
		}

		for (Contract c : getParentContracts(new Set<String>{'Talabat_Contract'})) {
			System.assertNotEquals('Activated', c.Status);
		}
	}

	static void closeOnboardingSuccessful() {
		closeOnboardingSuccessful(new Set<String> {'CD_Restaurant_Operations', 'Talabat_Restaurant_Ops'});
	}
	static void closeOnboardingSuccessful(Set<String> recTypes) {
		Case[] cases = [Select Status, Closed_Reason__c From Case Where Type = 'Onboarding' and RecordType.DeveloperName in :recTypes];
		for ( Case c : cases) {
			c.Closed_Reason__c = 'Successful';
			c.Status = 'Closed';
		}
		update cases;
	}
	static void closeOnboardingAsFailed() {
		closeOnboardingAsFailed(new Set<String> {'CD_Restaurant_Operations', 'Talabat_Restaurant_Ops'});
	}
	static void closeOnboardingAsFailed(Set<String> recTypes) {
		Case[] cases = [Select Closed_Reason__c, Root_Cause__c From Case Where Type = 'Onboarding' and RecordType.DeveloperName in :recTypes];
		for (Case c : cases) {
			c.Closed_Reason__c = 'Not Successful';
			c.Status = 'Closed';
			c.Root_Cause__c = 'Duplicated';
		}
		update cases;
	}
	static void setParentOppsAsWon() {
		setParentOppsAsWon(new Set<String> {'CD_Opportunity', 'Talabat_Opportunity'});
	}
	static void setParentOppsAsWon(Set<String> recTypes) {
		Opportunity[] opps = [Select StageName  From Opportunity WHere Account.Type In ('Brand', 'Franchise') and RecordType.DeveloperName in :recTypes];
		for (Opportunity opp : opps) {
			opp.StageName = 'Closed Won';
		}
		update opps;
	}
	static void setChildOppsAsWon() {
		setChildOppsAsWon(new Set<String> {'CD_Opportunity', 'Talabat_Opportunity'});
	}
	static void setChildOppsAsWon(Set<String> recTypes) {
		Opportunity[] opps = [Select StageName  From Opportunity WHere Account.Type in ('Branch') and RecordType.DeveloperName in: recTypes];
		for (Opportunity opp : opps) {
			opp.StageName = 'Closed Won';
		}
		update opps;
	}
	static Contract[] getChildContracts() {
		return getChildContracts(new Set<String> {'CD_Contract', 'Talabat_Contract'});
	}
	static Contract[] getChildContracts(Set<String> recTypes) {
		return [Select Status From Contract Where RecordType.DeveloperName in :recTypes and Account.Type in ('Branch')];
	}
	static Contract[] getParentContracts() {
		return getParentContracts(new Set<String> {'CD_Contract', 'Talabat_Contract'});
	}
	static Contract[] getParentContracts(Set<String> recTypes) {
		return [Select Status From Contract Where RecordType.DeveloperName in :recTypes and Account.Type In ('Brand', 'Franchise')];
	}
}