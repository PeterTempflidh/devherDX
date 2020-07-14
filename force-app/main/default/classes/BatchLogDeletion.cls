/**
	@Description: This method deletes the log which are older than particular number of days. 
				  Also contains the scheduler to schedule itself
*/
global class BatchLogDeletion implements Database.Batchable<sObject>,Schedulable{
    
    public Integer numberOfDays; // Number of days before which logs should be deleted
    
    global BatchLogDeletion(){
    	Logging__c logConfig = Logging__c.getInstance();
    	numberOfDays = Integer.valueOf(logConfig.NUMBER_OF_DAYS__c);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
		Date filterDate = Date.today().addDays(-numberOfDays);
		return Database.getQueryLocator([SELECT Id
											FROM Log_Error_Message__c 
											where createdDate <= :filterDate]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        if(scope.size() == 0)
        	return;
        	
    	// Delete the logs
    	delete (List<Log_Error_Message__c>)scope;
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    global void execute(SchedulableContext sc) {
        BatchLogDeletion batch = new BatchLogDeletion();
        Database.executebatch(batch);
    }
    
}