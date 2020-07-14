/**
 * Terminates or renews Additional Charges records based on Business config
 */
global class BatchTerminateAdditionalCharges implements Database.Batchable<sObject>, Database.Stateful {

	Map<String, Map<String, Business_Config__c>> mapBusinessLogic = LibBusinessConfig.motherOfAllBusinessMaps.get('BatchTerminateAdditionalCharges');

	global Database.QueryLocator start(Database.BatchableContext BC) {
		Set<String> statusSet = new set<String>{'Active','To be Sent'};
		return Database.getQueryLocator([
		                                    SELECT
			                                    Status__c,
			                                    Type__c,
			                                    Termination_Date__c,
			                                    Termination_Reason__c,
			                                    Id_Account__c,
			                                    Id_Account__r.Record_Country__c,
			                                    RecordType.DeveloperName
		                                    FROM Additional_Charges__c
		                                    WHERE Termination_Date__c <= TODAY
		                                    AND status__c in :statusSet
		                                ]);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		System.debug('BatchTerminateAdditionalCharges.execute: start');

		if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) {
			System.debug('BatchTerminateAdditionalCharges.execute: empty business rules');
			return; // nothing to do
		}

		List<Additional_Charges__c> toUpdate = new List<Additional_Charges__c>();

		System.debug('BatchTerminateAdditionalCharges.execute: scope list is: ' + scope.size());

		for (Additional_Charges__c ad : (List<Additional_Charges__c>) scope) {

			System.debug('BatchTerminateAdditionalCharges.execute: processing : ' + ad.Id);

			Map<String, Business_Config__c> businessData = mapBusinessLogic.get(ad.RecordType.developername);

			if (businessData == null || businessData.isEmpty()) {
				System.debug('BatchTerminateAdditionalCharges.execute: empty business data');
				continue; // nothing to do
			}

			// checks if has to terminate expired Additional charges
			if (businessData.containsKey('terminateExpiredAdditionalCharges')
			        && Boolean.valueOf(businessData.get('terminateExpiredAdditionalCharges').Business_Rule_Value__c)
			        && ad.Termination_Date__c != null) {

				System.debug('BatchTerminateAdditionalCharges.execute: terminating: ' + ad.id);
				
				if(String.isBlank(ad.Termination_Reason__c)){
					ad.Status__c = businessData.get('chargedStatus').Business_Rule_Value__c;
					// if defined in business config set also the termination reason
					ad.Termination_Reason__c = businessData.get('terminationReason') != null ? businessData.get('terminationReason').Business_Rule_Value__c : ad.Termination_Reason__c;
				}else{
					ad.Status__c = businessData.get('terminationStatus').Business_Rule_Value__c;
				}

				toUpdate.add(ad);
			}
		}

		System.debug('BatchTerminateAdditionalCharges.execute: toUpdate size is: ' + toUpdate.size());

		if (!toUpdate.isEmpty()) {
			update toUpdate;
		}

		System.debug('BatchTerminateAdditionalCharges.execute: done');
	}

	global void finish(Database.BatchableContext BC) {}
}