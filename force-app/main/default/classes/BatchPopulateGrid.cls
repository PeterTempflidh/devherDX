global class BatchPopulateGrid implements Database.Batchable<sObject> {

	String query;

	global BatchPopulateGrid(String obj) {
		if (obj == 'Lead') {
			query = 'SELECT GRID__c, GRIDSequence__c FROM ' + obj + ' WHERE GRIDSequence__c != \'\' AND GRID__c = \'\' AND IsConverted = false';
		} else {
			query = 'SELECT GRID__c, GRIDSequence__c FROM ' + obj + ' WHERE GRIDSequence__c != \'\' AND GRID__c = \'\'';
		}
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		for (sObject obj : scope) {
			Integer seq = Integer.valueOf(String.valueOf(obj.get('GRIDSequence__c')));
			obj.put('GRID__c', UtilsGlobalIdentifier.getGlobalIdentifierFromSequenceNumber(seq));
		}
		update scope;
	}

	global void finish(Database.BatchableContext BC) {

	}

}