/**
* @Description: This batch closes the CC cases which were resolved 7 days before 
*/
global class BatchCCCaseClosure implements Database.Batchable<sObject>,Schedulable{
    public List<String> recordTypes = new List<String>();
    private Map<String, Map<String, Map<String, Business_Config__c>> > moam = 
    																		LibBusinessConfig.motherOfAllBusinessMaps;
    private static Map<String, Business_Config__c> mapBusinessRules;
	// Initialize the number of days
	private Integer numberofDaysforSocialCases = 3;
	private Integer numberOfDays	=  7;
    
    public BatchCCCaseClosure(){
    	Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('CCCaseClosureProcess');
    	if(mapBusinessLogic != null){
    		mapBusinessRules 	= mapBusinessLogic.get('Global_Config');
	    	if(mapBusinessRules != null){
	    		recordTypes = mapBusinessRules.get('recordTypes').Business_rule_Value__c.split(',');
				numberOfDays = Integer.valueOf(mapBusinessRules.get('numberOfDays').Business_Rule_Value__c);
				numberOfDaysforSocialCases = Integer.valueOf(mapBusinessRules.get('numberOfDaysforSocialCases').Business_rule_Value__c);
			} 
    	}
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
		List<Id> recordTypeIds 	= new List<Id>();
		Date resolvedDate		= Date.today().addDays(-numberOfDays);
		Date resolvedDateforSocialCases = Date.today().addDays(-numberOfDaysforSocialCases);

		// Initialize the record type ids
		for(String rec : recordTypes){
	      	recordTypeIds.add(LibRecordTypeHelper.getRecordTypeValue(rec));
	    } 
		return Database.getQueryLocator([SELECT Id,Status,origin,resolvedDate__c
											FROM CASE
											WHERE RecordTypeId in: recordTypeIds
											 	AND (resolvedDate__c <: resolvedDate 
												     OR (resolvedDate__c <=: resolvedDateforSocialCases AND (Origin='Facebook' OR Origin='Twitter' OR Origin='Instagram'))
													)
											 	AND Status = 'Resolved']);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    	List<Case> casesTobeClosed = (List<Case>)scope;
    	for(Case cs : casesToBeClosed){
			cs.status = 'Closed';						
    	}   
    	
    	// In case of failure perform partial update
    	List<Database.saveResult> results = Database.update(casesTobeClosed,false);
    	LoggingUtility.createLog('BatchCCCaseClosure','BATCH','CASE CLOSURE',null);
    	Boolean isError = false;	
    	for(Database.saveResult result : results){
    		if(!result.isSuccess()){
    			LoggingUtility.logError('BatchCCCaseClosure','BatchCCCaseClosure: Update failed for case ' + result.getId() + 
    							' Errors '  + result.getErrors() + '\n');
    			System.debug(Logginglevel.ERROR,'BatchCCCaseClosure: Update failed for case ' + result.getId() + 
    							' Errors '  + result.getErrors());
    			isError = true;
    		}
    	}
    	
    	// Do Logging in case of error.
    	if(isError){
    		LoggingUtility.commitLogs();
    	}
    	    	
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    // Scheduler for the batch
    global void execute(SchedulableContext sc) {
        BatchCCCaseClosure batch = new BatchCCCaseClosure();
        Database.executebatch(batch);
    }
}