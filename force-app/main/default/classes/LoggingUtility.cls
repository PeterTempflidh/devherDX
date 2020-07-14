/**
* @Descrition: This class is used for Logging the activities in the system
*/
public class LoggingUtility {
	
	@TestVisible
	private static Map<String,Log_Error_Message__c> logMap;
	
	static{
		logMap			= new Map<String,Log_Error_Message__c>();
	}
	
	/**
	  @Description: This method initilizes the log and adds it to the map
			@InputParams	: Name of the log, Type of the log, Sub type of the log
			@OutputParams	: void
	*/
	public static void createLog(String Name,String type,String subType,String parentId){
		if(logMap.containsKey(Name)){ 
			System.debug(Logginglevel.ERROR,'Log Name already exists : ' + Name);
			return;
		}	
		
		Log_Error_Message__c log = new Log_Error_Message__c(Type__c = type,sub_Type__c = subType,parentId__c = parentId,
																dump__c = '',Error_message__c = ''); 
		logMap.put(Name,log);
	}
	
	/**
		@Description: This method logs the data against the log name
			@InputParams	: Name of the log, Data which needs to be logged
			@outputParams	: VOID
	*/
	public static void log(String Name,String data){
		if(!logMap.containsKey(Name)){
			System.debug(Logginglevel.ERROR,'Cannot Log Data, Log doesnt exists : ' + Name);
			return;
		}
		
		logMap.get(Name).dump__c += data;
	}   
	
	
	/**
		@Description: This method captures the time stamp in milliseconds
			@inputparams: Name of the log, Type (Begin or END)
			@outputparams: VOID
	*/
	public static void captureTimeStamp(String name,String type){
		if(!logMap.containsKey(Name)){
			System.debug(Logginglevel.ERROR,'Cannot capture timestamp, Log doesnt exists : ' + Name);
			return;
		}
		
		if(type == 'Begin'){
			logMap.get(Name).Callout_Begin_Timestamp__c = Datetime.now().getTime();
		}else if(type == 'End'){
			logMap.get(Name).Callout_End_Timestamp__c 	= Datetime.now().getTime();
		}
	}
	 
	
	/**
		@Description: This method logs the error
			@inputparams: Name of the log, error message
			@outputparams: VOID
	*/
	public static void logError(String name, string errorMessage){
		if(!logMap.containsKey(Name)){
			System.debug(Logginglevel.ERROR,'Cannot log error, Log doesnt exists : ' + Name);
			return;
		}
		
		logMap.get(Name).Is_Error__c 		= true;
		logMap.get(Name).Error_message__c 	+= errorMessage;
	}

	/**
	 * @description Commits logs into the database
	*/
	public static void commitLogs(){
		commitLogs(false);
	}
	/**
	 *  @description This method commits all the logs into the database
	 *  		1. Logging can be disabled completely
	 *  		2. Logging can be disbaled for a particular type
	 *  		3. Logging can only be enabled for errors
	 *  		NOTE: If the logging is disbaled for enabled for errors and not disbaled for a particular type it will
	 *  		still log for both errors and that particular type. If you want to enable logging just for errors
	 *  		then disbale all the other types and enable loggings.
 	 *  @param logErrorsOnly defines if only errors should be logged ignoring the Logging__c config.
	 */
	public static void commitLogs(Boolean logErrorsOnly){
		List<Log_Error_message__c> logsToBeUpserted = new List<Log_Error_Message__c>();
		if(logMap.isEmpty()){
			System.debug(Logginglevel.INFO,'Nothing to Log!');
			return;
		}
		
		Logging__c logConfig = Logging__c.getInstance();
		
		// If Logging is disabled return
		if(logConfig.DISABLE_LOGGING__c){
			System.debug(Logginglevel.INFO,'Cannot commit logs. Logging is disabled');
			return;
		}
		
		try{
			for(Log_Error_message__c log : logMap.values()){
				if(!Boolean.valueOf(logConfig.get('DISABLE_'+log.type__c+'__c')) && !logErrorsOnly){
					logsToBeUpserted.add(log);
				}else if(log.is_error__c && (logConfig.ONLY_ERROR_LOGGING__c || logErrorsOnly)){
					logsToBeUpserted.add(log);
				}
			}
			
			// Log the number of queries and DML operations
			for(Log_Error_message__c log : logsToBeUpserted){
				log.NUMBER_OF_QUERIES__C 			= Limits.getQueries();
				log.NUMBER_OF_DML_OPERATIONS__c 	= Limits.getDMLStatements() + 1; // adding 1 for upcoming operation
			}
			
			if(logsToBeUpserted.size() > 0)
				upsert logsToBeUpserted;
		}catch(SObjectException e){
			System.debug(Logginglevel.Error,'Error: Logs cannot be committed. No field for the logged type ' + logMap.values());
		}catch(Exception e){
			System.debug(Logginglevel.Error,'Error: Logs cannot be committed. Umexpected error ' + e.getMessage());
		}
		
	} 
	
}