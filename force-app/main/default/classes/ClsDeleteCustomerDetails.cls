public with sharing class ClsDeleteCustomerDetails {
    public static String EMAILS_DELETED_SUCCESSFULLY 	= 'Deleted successfully';
    public static String NO_EMAILS_TO_DELETE 			= 'Inserted emails are not present into the Database';
	
	/**
	* @Description: This method deletes the below data associated with the email
					1. Cases
					2. Chat Transcripts
					3. Tasks
	* @Param: emailData = Comma seperated emails
	*/
	@RemoteAction
	public static Result deleteData(String emailData) {
        LoggingUtility.createLog('CDD','CUSTOMER_DATA','DELETION',null);
        List<String> emails = new List<String>();

        if (String.isBlank(emailData)) {
            return new Result('Enter email addresses',true);
        }

        // Remove Spaces and New lines
        emailData 	= emailData.remove(' ');
        emailData	= emailData.remove('\n');
        emails 		= emailData.split(',');
		
		try{
        	Integer numberOfRecordsDeleted = CustomerDataDeletionService.deleteCall(emails);
        	if(numberOfRecordsDeleted == 0)
        		return new Result(NO_EMAILS_TO_DELETE,false);
        	
        	return new Result(EMAILS_DELETED_SUCCESSFULLY,false);
		}catch(Exception e){
			LoggingUtility.logError('CDD',e.getMessage());
			LoggingUtility.commitLogs();
			return new Result(e.getMessage(),True);
		}
 
    }
    
    public class Result{
    	public String message;
    	public Boolean isError;
    	public String type;
    	
    	public Result(String message,Boolean isError){
    		this.message	= message;
    		this.isError	= isError;
    		if(this.isError){
    			type = 'Error';
    		}else{
    			type = 'Success';
    		}
    	}
    }
}