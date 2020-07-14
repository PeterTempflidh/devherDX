@isTest
private class UnitTestScheduleBatchDelayedContractActi {

	@testSetup static void setup() {
		UnitTestDataFactory.getRecordtypeValues();
		Country__c ec = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
		insert ec;

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

		insert rules;
	}

	@isTest static void scheduleBatchContractRenewalWorksCorrectly() {
		Id jobId;

		Test.startTest();
		jobId = System.schedule('test job', '0 0 0 * * ?', new ScheduleBatchDelayedContractActivation());
		Test.stopTest();

		CronTrigger[] jobs = [Select Id from CronTrigger Where Id = : jobId];

		System.assert(!jobs.isEmpty());

	}

}