@isTest
public class UnitTestBatchLogDeletion {
   	
   	@isTest
   	public static void testBatch(){
   		// create custom settings
    	Logging__c logConfig =new Logging__c(SetupOwnerId=Userinfo.getUserId());
    	logConfig.DISABLE_MIDAS__C = false;
    	logConfig.NUMBER_OF_DAYS__c = 30;
    	insert logConfig;
    	
   		LoggingUtility.createLog('test','MIDAS','test',null);
   		LoggingUtility.commitLogs();
   		
   		List<Log_error_message__c> logs = [Select Id from Log_Error_message__c];
   		System.assertEquals(logs.size(),1);
   		
   		Test.startTest();
   			BatchLogDeletion bt = new BatchLogDeletion();
   			bt.numberOfDays = -1;
   			Database.executeBatch(bt);
   		Test.stopTest();
   		
   		logs = [Select Id from Log_Error_message__c];
   		System.assertEquals(logs.size(	),0);
   	}
   	
   	@isTest
   	public static void testScheduler(){
   		// create custom settings
    	Logging__c logConfig =new Logging__c(SetupOwnerId=Userinfo.getUserId());
    	logConfig.DISABLE_MIDAS__C = false;
    	logConfig.NUMBER_OF_DAYS__c = 30;
    	insert logConfig;
    	
   		String CRON_EXP = '0 0 0 15 3 ? 2022'; 
   		LoggingUtility.createLog('test','MIDAS','test',null);
   		LoggingUtility.commitLogs();
   		Test.startTest();
        	String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new BatchLogDeletion());
        Test.stopTest();
        
        // Default number of days are 20. so no logs should be deleted
        List<Log_error_message__c> logs = [Select Id from Log_Error_message__c];
   		System.assertEquals(logs.size(),1);
   	}
   	 
}