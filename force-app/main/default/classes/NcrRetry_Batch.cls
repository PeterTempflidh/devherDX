/**
* @author Mantas Jurkunas
* @date 15.11.2019
*
* @description Batch that controls the NCR retry process
*
*/

global with sharing class NcrRetry_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful, Schedulable {

	public static void schedule(String cronExpression) {
		System.schedule('NCR Retry', cronExpression, new NcrRetry_Batch());
	}

	global void execute(SchedulableContext SC) {
		Database.executeBatch(new NcrRetry_Batch());
	}

	global Database.QueryLocator start(Database.BatchableContext bc) {
		//Querying all Opportunities that have failed
        return Database.getQueryLocator([
				SELECT
					Id, Booking_Api_Id__c, Id_Opportunity__c, Id_Opportunity__r.Source_System__c,
					Id_Opportunity__r.Country__r.Name, Id_Opportunity__r.StageName, Id_Opportunity__r.Record_Country__c
				FROM Opportunity_Line_Item__c WHERE Midas_Exception__c = TRUE]);
    }

	global void execute(Database.BatchableContext bc, List<Opportunity_Line_Item__c> failedOpportunityLineItems) {
		List<Opportunity_Line_Item__c> lineItems = new NcrRetry_Utils().initialiseLineItemData(failedOpportunityLineItems).retryBookings().updateSuccessfulBookings();
		if (lineItems.isEmpty()) {
			LoggingUtility.commitLogs();
			return;
		}
		toggleTriggers(false);
		List<Database.SaveResult> saveResults = Database.update(lineItems, false);
		toggleTriggers(true);
		Map<Id, List<String>> errorMap = new Map<Id, List<String>>();
		for (Integer index = 0; index < lineItems.size(); index++) {
			if (saveResults[index].getId() != null) {
				continue;
			}
			List<String> errorMessages = new List<String>();
			for (Database.Error error: saveResults[index].getErrors()) {
				errorMessages.add(error.getMessage());
			}
			errorMap.put(lineItems[index].Id, errorMessages);
		}
		LoggingUtility.createLog('MIDAS_RETRY_DML', 'MIDAS_SELFBOOKING', 'NCR_RETRY_DML', null);
		LoggingUtility.logError('MIDAS_RETRY_DML', JSON.serialize(errorMap));
		LoggingUtility.captureTimeStamp('MIDAS_RETRY_DML','End');
		LoggingUtility.commitLogs();
    }

	global void finish(Database.BatchableContext BC) {


	}

	private static void toggleTriggers(Boolean isEnabled) {
		Trigger_Manager__c triggerManager = Trigger_Manager__c.getInstance();
		triggerManager.Deactivate_Opp_Line_Item_Trigger__c = isEnabled;
		upsert triggerManager;
	}



}
