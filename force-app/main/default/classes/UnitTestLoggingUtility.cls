@isTest
public class UnitTestLoggingUtility {
    
    @isTest
    public static void testCreation(){
    	LoggingUtility.createLog('test','test','test',null);
    	LoggingUtility.createLog('test2','test2','test2',null);
    	
    	System.assertEquals(LoggingUtility.logMap.keySet().size(),2);
    	
    	// create duplicate log
    	LoggingUtility.createLog('test','test','test',null);
    	System.assertEquals(LoggingUtility.logMap.keySet().size(),2);
    }
    
    @isTest
    public static void testLog(){
    	LoggingUtility.createLog('test','test','test',null);
    	LoggingUtility.log('test','test');
    	
    	System.assertEquals(LoggingUtility.logMap.get('test').dump__c,'test');
    }
    
    @isTest
    public static void testTimeStampAndCommit(){
    	LoggingUtility.createLog('test','MIDAS','test',null);
    	LoggingUtility.captureTimeStamp('test','Begin');
    	LoggingUtility.captureTimeStamp('test','End');
    	
    	// create custom settings
    	Logging__c logConfig =new Logging__c(SetupOwnerId=Userinfo.getUserId());
    	logConfig.DISABLE_MIDAS__C = false;
    	insert logConfig;
    	
    	LoggingUtility.commitLogs();
    	
    	List<Log_Error_Message__c> logs = [Select Callout_Begin_Timestamp__c,Callout_End_Timestamp__c,callout_time__c
    										FROM Log_Error_Message__c];
		
		System.assertEquals(logs.size(),1);
		
		Decimal calloutTime = ((logs[0].Callout_End_Timestamp__c - logs[0].Callout_Begin_Timestamp__c)/1000).setScale(2);
		System.assertEquals(calloutTime,logs[0].callout_time__c);
    }
    
    @isTest
    public static void testDisabling(){
    	LoggingUtility.createLog('test','MIDAS','test',null);
    	LoggingUtility.captureTimeStamp('test','Begin');
    	LoggingUtility.captureTimeStamp('test','End');
    	
    	// create custom settings
    	Logging__c logConfig =new Logging__c(SetupOwnerId=Userinfo.getUserId());
    	logConfig.DISABLE_MIDAS__C = true;
    	insert logConfig;
    	
    	LoggingUtility.commitLogs();
    	
    	List<Log_Error_Message__c> logs = [Select id FROM Log_Error_Message__c];
		System.assertEquals(logs.size(),0);
		
		// check for error
		LoggingUtility.logError('test','test error');
		logConfig.ONLY_ERROR_LOGGING__c = true;
		update logConfig;
		
		LoggingUtility.commitLogs();
		logs = [Select id FROM Log_Error_Message__c];
		System.assertEquals(logs.size(),1);
    }
    
    @isTest
    public static void testErrorLog(){
    	LoggingUtility.createLog('test','test','test',null);
    	LoggingUtility.logError('test','test');
    	
    	System.assertEquals(LoggingUtility.logMap.get('test').is_Error__c,true);
    	System.assertEquals(LoggingUtility.logMap.get('test').Error_Message__c,'test');
    }
    
}