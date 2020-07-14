global class BatchDelayedOnboardingCreation implements Database.Batchable<sObject> {

	private static Map<String, Map<String, Business_Config__c>> mapBusinessData = LibBusinessConfig.motherOfAllBusinessMaps.get('DelayedOnboardingCreation');

	Set<String> accountRecordTypeToFilter;
	Set<String> accountTypeToFilter;
	Set<String> oppsStageNameToFilter;

	global BatchDelayedOnboardingCreation() {
		accountRecordTypeToFilter =  new Set<String>();
		accountTypeToFilter =  new Set<String>();
		oppsStageNameToFilter =  new Set<String>();

		for (String rt : mapBusinessData.keySet()) {
			accountRecordTypeToFilter.add(rt);

			Map<String, Business_Config__c> rules = mapBusinessData.get(rt);

			if (rules.containsKey('validChildAccountTypes')) {
				accountTypeToFilter.addAll(rules.get('validChildAccountTypes').Business_Rule_Value__c.split(','));
			}

			if (rules.containsKey('validOppStageNames')) {
				oppsStageNameToFilter.addAll(rules.get('validOppStageNames').Business_Rule_Value__c.split(','));
			}
		}
	}

	/**
	 * Gets assets related only to certain type of account or to open
	 * opportunities
	 * @param  BC [description]
	 * @return    [description]
	 */
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
		                                    SELECT
		                                    Status__c,
		                                    Account__c,
		                                    Opportunity__c,
		                                    RecordType.DeveloperName,
		                                    Account__r.Type,
		                                    Account__r.ParentId,
		                                    Account__r.RecordType.DeveloperName,
		                                    Opportunity__r.StageName

		                                    FROM Asset__c

		                                    WHERE Account__r.RecordType.DeveloperName IN :accountRecordTypeToFilter
		                                    AND Account__r.Type IN :accountTypeToFilter
		                                    AND Account__r.ParentId != ''
		                                    AND Status__c = 'Activated Successfully'
		                                            AND(
		                                                    Opportunity__c = ''
		                                                            OR Opportunity__r.StageName IN :oppsStageNameToFilter
		                                            )
		                                ]
		                               );
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		Map<Id, Id> accIdToParentId = new Map<Id, Id>();
		Map<Id, Account> accIdToAccount = new Map<Id, Account>();
		Map<Id, Opportunity> oppIdToOpp = new Map<Id, Opportunity>();
		Map<Id, List<Asset__c>> oppIdToAssets = new Map<Id, List<Asset__c>>();
		Map<Id, List<Asset__c>> accIdToAssets = new Map<Id, List<Asset__c>>();

		Set<Id> validAccountIds = new Set<Id>();
		Set<Id> validOppIds = new Set<Id>();
		Set<Id> validAssetIds = new Set<Id>();
		Set<Id> invalidIds = new Set<Id>();
		Set<Id> temp = new Set<Id>();

		List<Case> toInsert = new List<Case>();
		List<Opportunity> toUpdate = new List<Opportunity>();

		/* *****

			STEP 1: Filter records and store all account ids

		***** */

		for (Asset__c ast : (List<Asset__c>) scope) {

			// skips invalid assets
			if (!isValidAsset(ast)) {
				continue;
			}

			validAccountIds.add(ast.Account__c);
			validOppIds.add(ast.Opportunity__c);
			validAssetIds.add(ast.Id);
		}

		// free heap
		scope.clear();

		if (validAccountIds.isEmpty()) {
			return;
		}

		/* *****

			STEP 2: Gets all opportunities and assets related to valid accounts

		***** */

		for (Account acc : [
		            SELECT
		            ParentId,
					Delivery_Service__c,
		            RecordType.DeveloperName,
		            CurrencyIsoCode,

		            (
		                SELECT
		                StageName,
		                AccountId,
		                CurrencyIsoCode,
		                Account.Delivery_Service__c,
		                Account.RecordType.DeveloperName
		                FROM Opportunities
		                WHERE Id IN :validOppIds
		            ),

		            (
		                SELECT
		                Status__c,
		                Opportunity__c
		                FROM Assets__r
		                WHERE Id IN :validAssetIds
		            )

		            FROM Account

		            WHERE Id IN: validAccountIds
		        ]
		    ) {

			// create child-parent map
			accIdToParentId.put(acc.Id, acc.ParentId); // do not remove this map, it's not redundant

			// create assets map
			for (Asset__c ast : acc.Assets__r) {
				Id key;
				Map<Id, List<Asset__c>> mapToMod;

				if (String.isBlank(ast.Opportunity__c)) {
					key = acc.Id;
					mapToMod = accIdToAssets;
					accIdToAccount.put(acc.Id, acc);
				} else {
					key = ast.Opportunity__c;
					mapToMod = oppIdToAssets;
				}

				if (!mapToMod.containsKey(key)) {
					mapToMod.put(key, new List<Asset__c>());
				}

				mapToMod.get(key).add(ast);
			}

			// create opp map
			for (Opportunity opp : acc.Opportunities) {
				oppIdToOpp.put(opp.Id, opp);
			}

			// remove redundant relationship fields to save heap mem
			acc.Assets__r.clear();
			acc.Opportunities.clear();
		}

		// free heap mem
		validAccountIds.clear();
		validOppIds.clear();
		validAssetIds.clear();

		/* *****

			STEP 3: Filter account and opportunities records

		***** */

		// filter opps
		for (Id oppId : oppIdToAssets.keySet()) {
			Opportunity opp = oppIdToOpp.get(oppId);
			List<Asset__c> assets = oppIdToAssets.get(oppId);

			if (!isValidOppWithAssets(opp, assets)) {
				oppIdToOpp.remove(oppId);
			}
		}

		// filter accounts
		for (Id accId : accIdToAssets.keySet()) {
			Account acc = accIdToAccount.get(accId);

			if (!isValidAccountWithAssets(acc, accIdToAssets.get(accId))) {
				accIdToAccount.remove(accId);
			}
		}

		// at this point we do not need assets records anymore
		accIdToAssets.clear();
		oppIdToAssets.clear();

		if (accIdToAccount.isEmpty() && oppIdToOpp.isEmpty()) {
			return;
		}

		/* *****

			STEP 4: For remaining accounts and opportunities checks the opportunity
			at parent level

		***** */

		for (Opportunity opp : oppIdToOpp.values()) {
			temp.add(accIdToParentId.get(opp.AccountId));
		}

		for (Account acc : accIdToAccount.values()) {
			temp.add(acc.ParentId);
		}

		// gets the opportunities related to parent accounts
		for (Opportunity opp : [
		            SELECT
		            Name,
		            StageName,
		            Type,
		            Business_Type__c,
		            AccountId,
		            Account.RecordType.DeveloperName
		            FROM Opportunity
		            WHERE AccountId IN :temp
		            AND StageName = 'Closed Won'
		        ]) {
			if (isValidParentOpportunity(opp)) {
				validAccountIds.add(opp.AccountId);
			}
		}

		// filter opportunities
		for (Opportunity opp : oppIdToOpp.values()) {
			if (!validAccountIds.contains(accIdToParentId.get(opp.AccountId))) {
				invalidIds.add(opp.Id);
			}
		}

		// filter account
		for (Account acc : accIdToAccount.values()) {
			if (!validAccountIds.contains(acc.ParentId)) {
				invalidIds.add(acc.Id);
			}
		}

		for (Id toDel : invalidIds) {
			accIdToAccount.remove(toDel);
			oppIdToOpp.remove(toDel);
		}
		invalidIds.clear();
		validAccountIds.clear();

		if (accIdToAccount.isEmpty() && oppIdToOpp.isEmpty()) {
			return;
		}

		/* *****

			STEP 5: For remaining opportunities and account checks if there's
			already an open onboarding or one closed successfully

		***** */

		temp.clear();

		for (Id accId : accIdToAccount.keySet()) {
			temp.add(accId);
		}

		for (Opportunity opp : oppIdToOpp.values()) {
			temp.add(opp.AccountId);
		}

		for (Case cs : [
		            SELECT
		            AccountId,
		            IsClosed,
		            Closed_Reason__c,
		            Opportunity__c,
		            Account.RecordType.DeveloperName
		            FROM Case
		            WHERE AccountId IN :temp
		            AND Type = 'Onboarding'
		        ]) {
			if (isValidOnboardingCase(cs)) {
				accIdToAccount.remove(cs.AccountId);
				oppIdToOpp.remove(cs.Opportunity__c);
			}
		}

		if (accIdToAccount.isEmpty() && oppIdToOpp.isEmpty()) {
			return;
		}

		/* *****

			STEP 6: Create the onboarding for remaining opportunities and
			accounts

		***** */

		for (Opportunity opp : oppIdToOpp.values()) {
			toInsert.add(getOnboardingCase(opp));

			if (opp.StageName != 'Onboarding') {
				opp.StageName = 'Onboarding';
				toUpdate.add(opp);
			}
		}

		for (Account acc : accIdToAccount.values()) {
			toInsert.add(getOnboardingCase(acc));
		}

		insert toInsert;
		update toUpdate;
	}

	global void finish(Database.BatchableContext BC) {

	}

	/**
	 * Return an onboarding case related to specified account
	 * @param  acc [description]
	 * @return     [description]
	 */
	private Case getOnboardingCase(Account acc) {
		return getOnboardingCase(
		           acc.Id,
		           null,
		           acc.CurrencyIsoCode,
		           acc.Delivery_Service__c,
		           mapBusinessData.get(acc.RecordType.DeveloperName)
		       );
	}

	/**
	 * Returns an onboarding case related to specified opportunity
	 * @param  opp [description]
	 * @return     [description]
	 */
	private Case getOnboardingCase(Opportunity opp) {
		return getOnboardingCase(
		           opp.AccountId,
		           opp.Id,
		           opp.CurrencyIsoCode,
		           opp.Account.Delivery_Service__c,
		           mapBusinessData.get(opp.Account.RecordType.DeveloperName)
		       );
	}

	/**
	 * Returns an onboarding case related to account and opportunity
	 * @param  accId           Account id
	 * @param  oppId           Opportunity id (optional)
	 * @param  currencyIsoCode Currency iso code
	 * @param  deliveryService Account's delivery service
	 * @param  rules           BC rules
	 * @return                 An onboarding case
	 */
	private Case getOnboardingCase(Id accId, Id oppId, String currencyIsoCode, String deliveryService, Map<String, Business_Config__c> rules) {
		Case onBrd = new Case(
		    Opportunity__c = oppId,
		    AccountId = accId,
		    CurrencyIsoCode = currencyIsoCode
		);

		if (deliveryService == 'Mixed'
		        || deliveryService == 'All Inclusive') {
			onBrd.Case_reason__c = deliveryService;
		}

		Map<String, String> fieldToValue = (Map<String, String>) JSON.deserialize(rules.get('onboardingCaseFields').Business_Rule_Value__c, Map<String, String>.class);
		for (String field : fieldToValue.keySet()) {
			String val = fieldToValue.get(field);
			onBrd.put(field, val);
		}

		return onBrd;
	}

	/**
	 * Checks if given Case record is a valid Onboaring case. To be valid must be
	 * open or closed successfully
	 * @param  cs      Case record
	 * @return         true if case record is a valid onboarding, false otherwise
	 */
	private Boolean isValidOnboardingCase(Case cs) {
		Map<String, Business_Config__c> rules = mapBusinessData.get(cs.Account.RecordType.DeveloperName);

		Set<String> unSuccessfulClosedReason = new Set<String>(rules.get('unSuccessfulClosedReason').Business_Rule_Value__c.split(','));

		// still open or closed successfully
		return (!cs.isClosed || !unSuccessfulClosedReason.contains(cs.Closed_Reason__c));
	}

	/**
	 * Checks if given Opportunity record fulfills all requirements to allow the
	 * creation of an onboarding case at child level
	 * @param  opp          Parent account's opportunity
	 * @return              true if onboarding could be created at child level, false otherwise
	 */
	private Boolean isValidParentOpportunity(Opportunity opp) {
		Boolean res = true;

		Map<String, Business_Config__c> rules = mapBusinessData.get(opp.Account.RecordType.DeveloperName);

		Map<String, String> fieldToValue = (Map<String, String>) JSON.deserialize(rules.get('parentOpportunityFields').Business_Rule_Value__c, Map<String, String>.class);

		for (String field : fieldToValue.keySet()) {
			String valueToFulfill = fieldToValue.get(field);
			res &= (opp.get(field) == valueToFulfill);
		}

		return res;
	}

	/**
	 * Given an Opportunity record, related to a child account, and his related
	 * assets checks if fulfills all requirements to create the onboarding case.
	 * To fulfill requirements Opportunity record must be related to an Account of
	 * a specified Type defined in a Business config, must have at least one Asset,
	 * stage name must match with a value defined in a Business Config and
	 * all his assets records status must match a value defined in Business Config
	 * @param opp Opportunity record to check
	 * @param assets Related assets
	 * @return     true if opportunity record fulfills all requirements, false otherwise
	 */
	private Boolean isValidOppWithAssets(Opportunity opp, List<Asset__c> assets) {
		Boolean res;

		Map<String, Business_Config__c> rules = mapBusinessData.get(opp.Account.RecordType.DeveloperName);

		Set<String> validAssetStatuses = rules.containsKey('assetValidStatuses') ? new Set<String>(rules.get('assetValidStatuses').Business_Rule_Value__c.split(',')) : new Set<String>();
		Set<String> validOppStages = rules.containsKey('validOppStageNames') ? new Set<String>(rules.get('validOppStageNames').Business_Rule_Value__c.split(',')) : new Set<String>();

		res = (validOppStages.contains(opp.StageName) && !assets.isEmpty());

		if (res) {
			// checks assets status
			for (Asset__c ast : assets) {
				res &= validAssetStatuses.contains(ast.Status__c);
			}
		}

		return res;
	}

	/**
	 * Given an account record and his assets, not related to any opportunity,
	 * checks if fulfills all requirements to create the onboarding case. Requirement
	 * is that all asset record are in a status defined into a BC
	 * @param  acc    Account record
	 * @param  assets Related assets
	 * @return        true if account record fulfills all requirements, false otherwise
	 */
	private Boolean isValidAccountWithAssets(Account acc, List<Asset__c> assets) {
		Boolean res;

		Map<String, Business_Config__c> rules = mapBusinessData.get(acc.RecordType.DeveloperName);

		Set<String> validAssetStatuses = rules.containsKey('assetValidStatuses') ? new Set<String>(rules.get('assetValidStatuses').Business_Rule_Value__c.split(',')) : new Set<String>();

		res = (!assets.isEmpty());

		if (res) {
			// checks assets status
			for (Asset__c ast : assets) {
				res &= validAssetStatuses.contains(ast.Status__c);
			}
		}

		return res;
	}

	/**
	 * Checks if given asset record could trigger the onboarding creation at
	 * account or opportunity level
	 * @param  ast Asset record
	 * @return     [description]
	 */
	private Boolean isValidAsset(Asset__c ast) {
		Map<String, Business_Config__c> rules = mapBusinessData.get(ast.Account__r.RecordType.DeveloperName);

		Set<String> validAccountTypes = rules.containsKey('validChildAccountTypes') ? new Set<String>(rules.get('validChildAccountTypes').Business_Rule_Value__c.split(',')) : new Set<String>();
		Set<String> validOppStages = rules.containsKey('validOppStageNames') ? new Set<String>(rules.get('validOppStageNames').Business_Rule_Value__c.split(',')) : new Set<String>();

		return (
		           validAccountTypes.contains(ast.Account__r.Type)
		           && (
		               String.isBlank(ast.Opportunity__c)
		               || validOppStages.contains(ast.Opportunity__r.StageName)
		           )
		       );
	}
}