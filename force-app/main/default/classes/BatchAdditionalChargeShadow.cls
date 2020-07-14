global class BatchAdditionalChargeShadow implements Database.Batchable<sObject> {
	
	global BatchAdditionalChargeShadow() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([select id,RecordTypeId,Id_Asset__c from Additional_Charges__c]);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		List<Additional_Charges__c> addChargeList = (List<Additional_Charges__c>) scope;
		ClsAdditionalChargeProcessor.createAdditionalChargeShadow(addChargeList);
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}