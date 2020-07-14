@isTest
private class UnitTestScheduleBatchDelayedOnbCreation {

	@testSetup static void setup() {
		UnitTestDataFactory.getRecordtypeValues();

		Country__c ec = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
		insert new List<Country__c> {ec};

		List<Business_Config__c> rules = new List<Business_Config__c>();

		// ec rules
		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'CD_Opportunity',
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
		        Record_Type_Id__c = 'CD_Opportunity',
		        Id_Country__c = ec.Id,
		        Is_Active__c = true,
		        Parent__c = false,
		        Type__c = 'Process',
		        Process_Name__c = 'DelayedOnboardingCreation',
		        Business_Rule_Name__c = 'onboardingCaseFields',
		        Business_Rule_Value__c = '{"type": "Onboarding", "subject": "Onboard Restaurant", "status": "New", "Origin": "Automatic"}'
		    )
		);

		rules.add(
		    new Business_Config__c(
		        Record_Type_Id__c = 'CD_Opportunity',
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
		        Record_Type_Id__c = 'CD_Opportunity',
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
		        Record_Type_Id__c = 'CD_Opportunity',
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
		        Record_Type_Id__c = 'CD_Opportunity',
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
	}

	@isTest static void scheduleBatchContractRenewalWorksCorrectly() {
		Id jobId;

		Test.startTest();
		jobId = System.schedule('test job', '0 0 0 * * ?', new ScheduleBatchDelayedOnboardingCreation());
		Test.stopTest();

		CronTrigger[] jobs = [Select Id from CronTrigger Where Id = : jobId];

		System.assert(!jobs.isEmpty());
	}
}