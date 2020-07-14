/**
 * Given an account hierarchy parent-children, this batch activates all Contracts
 * related to both parent and children.
 *
 * Contracts related to parent account are activated when:
 * 		- related opportunity is Closed Won
 * 		- there's at least one successful onboarding case at child level
 *
 * Contracts related to child account are activated when:
 * 		- there's at least one Closed Won opportunity at parent level
 * 		- related opportunity is Closed Won
 *
 * Could be used for others country that shares the same parent-child hierarchy
 */
global class BatchDelayedContractActivation implements Database.Batchable<sObject> {

	Map<String, Map<String, Business_Config__c>> mapBusinessData = LibBusinessConfig.motherOfAllBusinessMaps.get('DelayedActivationOfContractsAndAddCharges');

	Set<String> accountRecordTypeToFilter;
	Set<String> accountTypesToFilter;
	Set<String> contractStatusesToFilter;

	global BatchDelayedContractActivation() {
		accountRecordTypeToFilter = new Set<String>();
		accountTypesToFilter = new Set<String>();
		contractStatusesToFilter = new Set<String>();

		for (String rt : mapBusinessData.keySet()) {
			accountRecordTypeToFilter.add(rt);
			accountTypesToFilter.add(mapBusinessData.get(rt).get('childAccountType').Business_Rule_Value__c);
			accountTypesToFilter.add(mapBusinessData.get(rt).get('parentAccountType').Business_Rule_Value__c);
			contractStatusesToFilter.addAll(mapBusinessData.get(rt).get('validContractStatuses').Business_Rule_Value__c.split(','));
		}
	}

	/**
	 * Gets all Contract records whose:
	 * 	- status belongs to a defined set
	 * 	- related account's type belongs to a defined set
	 * 	- related account's record type belongs to a defined set
	 * 	- related opportunity is closed won
	 * 	- is not expired
	 * @param  BC [description]
	 * @return    [description]
	 */
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
		                                    SELECT
		                                    Status,
		                                    AccountId,
		                                    Account.ParentId,
		                                    Account.Parent.Type,
		                                    Account.Type,
		                                    Account.RecordType.DeveloperName,
		                                    Id_Opportunity__c
		                                    FROM Contract
		                                    WHERE Account.RecordType.DeveloperName IN :accountRecordTypeToFilter
		                                    AND Account.Type IN :accountTypesToFilter
		                                    AND Id_Opportunity__r.StageName = 'Closed Won'
		                                            AND Status IN :contractStatusesToFilter
		                                            AND (End_Date__c = null OR End_Date__c > TODAY)
		                                ]);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {

		Map<Id, List<Contract>> parentAccountToContracts = new Map<Id, List<Contract>>();
		Map<Id, List<Contract>> parentAccountToChildrenContracts = new Map<Id, List<Contract>>();

		List<Contract> toUpdate = new List<Contract>();

		/* ***** STEP 1:

			Create maps

		***** */

		for (Contract cnt : (List<Contract>) scope) {

			// check if is a valid contract record
			if (!isValidContract(cnt)) {
				continue;
			}

			Map<String, Business_Config__c> rules = mapBusinessData.get(cnt.Account.RecordType.DeveloperName);

			Id key;
			Map<Id, List<Contract>> toModify;

			if (String.isNotBlank(cnt.Account.ParentId)
			        && cnt.Account.Parent.Type == rules.get('parentAccountType').Business_Rule_Value__c) {
				key = cnt.Account.ParentId;
				toModify = parentAccountToChildrenContracts;
			} else {
				key = cnt.AccountId;
				toModify = parentAccountToContracts;
			}

			if (!toModify.containsKey(key)) {
				toModify.put(key, new List<Contract>());
			}

			toModify.get(key).add(cnt);
		}

		// free heap mem
		scope.clear();

		if (parentAccountToChildrenContracts.isEmpty() && parentAccountToContracts.isEmpty()) {
			return; // nothing to do
		}

		/* ***** STEP 2:

			Checks if can activate children contracts querying the opportunity at
			parent level

		***** */

		for (Opportunity opp : [
		            SELECT
		            AccountId
		            FROM Opportunity
		            WHERE StageName = 'Closed Won'
		                              AND AccountId IN :parentAccountToChildrenContracts.keySet()
		        ]) {

			List<Contract> contracts = parentAccountToChildrenContracts.get(opp.AccountId);

			if (contracts != null) {
				toUpdate.addAll(contracts);
			}

			parentAccountToChildrenContracts.remove(opp.AccountId);
		}

		/* ***** STEP 3:

			Checks if can activate parent contracts querying the successful
			onboarding case at child level

		***** */


		for (Case cs : [
		            SELECT
		            Closed_Reason__c,
		            RecordType.DeveloperName,
		            Account.ParentId
		            FROM Case
		            WHERE Type = 'Onboarding'
		                         AND Account.ParentId IN :parentAccountToContracts.keySet()
		                         AND isClosed = true
		        ]) {


			if (!isSuccessfulOnboardingCase(cs)) {
				continue;
			}

			List<Contract> contracts = parentAccountToContracts.get(cs.Account.ParentId);

			if (contracts != null) {
				toUpdate.addAll(contracts);

			}

			// remove key from map to avoid duplicates and to free heap
			parentAccountToContracts.remove(cs.Account.ParentId);
		}

		/* ***** STEP 4:

			Updates contracts

		***** */

		for (Contract cnt : toUpdate) {

			Map<String, Business_Config__c> rules = mapBusinessData.get(cnt.Account.RecordType.DeveloperName);

			String activationStatus = rules.get('contractActivationStatus').Business_Rule_Value__c;

			cnt.Status = activationStatus;
		}

		if (!toUpdate.isEmpty()) {
			update toUpdate;
		}
	}

	/**
	 * Checks if a given contract record is eligible to be activated. To be eligible
	 * both contract' status and related account's type must match a BC defined
	 * value
	 * @param  cnt Contract record to check
	 * @return     true if record is eligible, false otherwise
	 */
	private Boolean isValidContract(Contract cnt) {
		Map<String, Business_Config__c> rules = mapBusinessData.get(cnt.Account.RecordType.DeveloperName);

		Set<String> accountTypes = new Set<String>();
		accountTypes.add(rules.get('parentAccountType').Business_Rule_Value__c);
		accountTypes.add(rules.get('childAccountType').Business_Rule_Value__c);

		Set<String> contractStatuses = new Set<String>(rules.get('validContractStatuses').Business_Rule_Value__c.split(','));

		return (
		           accountTypes.contains(cnt.Account.Type)
		           && contractStatuses.contains(cnt.Status)
		       );
	}

	/**
	 * Checks if a given onboarding case is closed successfully
	 * @param  cs Case record
	 * @return    true if case is closed successfully, false otherwise
	 */
	private Boolean isSuccessfulOnboardingCase(Case cs) {
		Map<String, Business_Config__c> rules = LibBusinessConfig.motherOfAllBusinessMaps.get('RestaurantCareClosingAction').get(cs.RecordType.DeveloperName);

		if (rules == null) {
			return false;
		}

		Map<String, String> closeReason = (Map<String, String>) JSON.deserialize(rules.get('closingReason').Business_Rule_Value__c, Map<String, String>.class);

		Set<String> positiveReason = new Set<String>(closeReason.get('Positive').split(','));

		return positiveReason.contains(cs.Closed_Reason__c);
	}

	global void finish(Database.BatchableContext BC) {

	}
}