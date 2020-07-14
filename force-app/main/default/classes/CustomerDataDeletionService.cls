/**
* @Description: This method exposes a web service to delete customer data in salesforce
  @URLMAPPING`: /cutomerDataDeletionService
*/

@RestResource(urlMapping = '/customerDataDeletionService/*')
global class CustomerDataDeletionService {
    
    public static String FULLFILLED				= 'fulfilled';
    public static String ALREADY_FULLFILLED		= 'fulfilled_already';
    public static String ERROR					= 'error';
    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    
    /**
    * @Description: This method deletes customer data in the salesforce based on the user email provided in the request
    				and returns a success or failure response
    				1. Method returns Fulfilled when the data is deleted
    				2. Method returns fulfilled_already when the data is already deleted or no data is there for deletion
    				3. Method returns error when there is an error in deletion
    */
    @HttpPost
    global static DeletionResponse deleteCustomerData(Integer requestId,String userEmail){
    	DeletionResponse res;
    	try{
    		LoggingUtility.createLog('CDD','CUSTOMER_DATA','DELETION',null);
    		Integer numberOfDeletedRecords = deleteCall(new List<String>{userEmail});
    		if(numberOfDeletedRecords == 0){
    			res = new DeletionResponse(requestId,ALREADY_FULLFILLED,'');
    		}else{
    			res = new DeletionResponse(requestId,FULLFILLED,'');
    		}	
    	}catch(Exception e){
    		LoggingUtility.logError('CDD',e.getMessage());
			LoggingUtility.commitLogs();
    		res = new DeletionResponse(requestId,ERROR,e.getMessage());
    	}
    	return res;
    }
    
    
    /**
	* @Description: This method queries and performs the deletion call on the following objects
					1. Cases
					2. LiveChatTrasncripts
	  @Param: List<String> List of comma seperated emails
	  @Return: Number of records deleted
	*/
    public static Integer deleteCall(List<String> emails) {
		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('customerDataDeletionProcess');
    	if(mapBusinessLogic == null){
    		throw new customerDataDeletionException('Business Configs missing in the system');
    	}
    	Map<String, Business_Config__c> mapBusinessRules 				= mapBusinessLogic.get('Global_Config');
		if(mapBusinessRules == null){
			throw new customerDataDeletionException('Business Configs rules missing in the system');
		}    
		
		// populate the record type Ids
		List<String> recordTypeNames = mapBusinessRules.get('recordTypes').Business_rule_value__c.split(',');	
		List<String> recordTypeIds 		= new List<String>();
		For(String rec : recordTypeNames){
			recordTypeIds.add(LibRecordTypeHelper.getRecordTypeValue(rec));
		} 
    		
		// Querying all the cases for the emails and the specified record types. Query Cost = 0.6666 
		List<Case> casesToBeDeleted	= [SELECT id, ContactEmail, SuppliedEmail,Customer_Email__c,Contact_Email__c
										FROM case
										WHERE (SuppliedEmail in:emails 
												OR Customer_Email__c in:emails
												OR ContactEmail in: emails
												OR Contact_Email__c in: emails) 
											AND (RecordTypeId in : recordTypeIds)];
		
		// Check if there are too many cases are going to be deleted against an email and thrown an error										
		if(Boolean.valueOf(mapBusinessRules.get('isSuspiciousCheckEnabled').Business_rule_value__c)){
			performSuspiciousEmailCheck(casesToBeDeleted,mapBusinessRules);
		}
											 
		// Querying all the chat transcripts. Email__c is an indexed field. query cost < 0.5
		List<LiveChatTranscript> chatsToBeDeleted = [SELECT id, Email__c,CaseId
														FROM LiveChatTranscript
														WHERE Email__c in:emails]; 
	 	
		// fetch all the cases from Live Chat transcripts
		Set<Id> caseIds = new Set<Id>();
		for(LiveChatTranscript ct : chatsToBeDeleted){
			if(ct.caseid != null){
				caseIds.add(ct.caseId);
			}
		}
		for(Case cs : casesToBeDeleted){
			caseIds.add(cs.id);
		}

		Integer recordsToDelete = caseIds.size() + chatsToBeDeleted.size();
		if (recordsToDelete == 0)
			return 0;
        
        Integer numberOfRecordsDeleted 	= 0;
        String errorMessage				= '';
        if(caseIds.size() > 0){
        	try{
				numberOfRecordsDeleted += deleteRecords(null,new List<Id>(caseIds),'Case');
        	}catch(Exception e){
        		errorMessage = e.getMessage();
        	}
        }
		if(chatsToBeDeleted.size() > 0){
			try{
				numberOfRecordsDeleted += deleteRecords(chatsToBeDeleted,null,'LiveChatTranscript');
			}Catch(Exception e){
				errorMessage = e.getMessage();
			}
		}
		
		if(errorMessage != '')
			throw new customerDataDeletionException('Customer records deletion failed for \n'+errorMessage);
    	 
    	return numberOfRecordsDeleted;
    }
    
    /**
    * @Description: This method checks whether there are too many cases for deletion for an email id
    */
    public static void performSuspiciousEmailCheck(List<Case> casesToBeDeleted,Map<String, Business_Config__c> mapBusinessRules){
    	Map<String,Integer> countMap = new Map<String,Integer>();
		for(Case cs : casesToBeDeleted){
			if(cs.Customer_Email__c != null){
				populateMap(countMap,cs.Customer_email__c);
			}else if(cs.SuppliedEmail != null){
				populateMap(countMap,cs.SuppliedEmail);
			}else if(cs.ContactEmail != null){
				populateMap(countMap,cs.ContactEmail);
			}else if(cs.Contact_Email__c != null){
				populateMap(countMap,cs.Contact_Email__c);
			}
		}
		
		Integer suspiciousCheckTreshhold = Integer.valueOf(mapBusinessRules.get('suspiciousCheckTreshhold').Business_rule_value__c);
		for(String email : countMap.keySet()){
			if(countMap.get(email) > suspiciousCheckTreshhold){
				throw new customerDataDeletionException('Too many cases to delete for the email :' + email);
			}
		}
    }
    
    private static void populateMap(Map<String,Integer> countMap,String email){
    	if(!countMap.containsKey(email)){
			countMap.put(email,0);
		}
		countMap.put(email,countMap.get(email)+1);
    }
    
    /**
    * @Description: This method performs a delete with partial failure either for the list of Ids or for the list of records
    */
    public static Integer deleteRecords(List<SObject> records,List<Id> recordIds,String objectType){
		String errorMessage = '\nFailed ' + objectType + ': ';
		List<Database.DeleteResult> results;
    	Integer numberOfDeletedRecords = 0;
    	
    	if(recordIds != null && !recordIds.isEmpty()){
    		numberOfDeletedRecords = recordIds.size();
			results = Database.delete(recordIds, false);	 
    	}else if(records!= null && !records.isEmpty()){
			results = Database.delete(records, false);
			numberOfDeletedRecords = records.size();
		}
		
		Boolean isError = false;
		for(Database.DeleteResult dr : results){
			if (!dr.isSuccess()) {
				ID recordId = dr.getId();
				errorMessage += recordId + ',';
				isError = true;
			}
		}
		
		if(isError){
			throw new customerDataDeletionException(errorMessage);
		}
		
		return numberOfDeletedRecords;
    }
    
    global class DeletionResponse{
    	public Integer requestId;
    	public String status;
    	public String comment;
    	
    	public DeletionResponse(Integer requestId,String status,String comment){
    		this.requestId 	= requestId;
    		this.status		= status;
    		this.comment	= comment;
    	}
    }
    
    global class customerDataDeletionException extends Exception{}
}