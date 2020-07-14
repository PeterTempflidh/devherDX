public class ClsAccountHelper {
	
	/**
	* @Description: This method updates the owners of the restaunrats in MIDAS whenever the owner is change
	* @Params:  List<String> List of account Ids whose owners are changed
	*/
	@future(callout = true)
	public static void changeOwnershipOfTheAccount(List<String> accountIds){
		Map<Id,Account> accountmap = new Map<Id,Account>([Select Name,OwnerId,Owner.email,record_country__c,backend_id__c,recordType.developerName,
															 (Select Name,Backend_Id__c,Platform__c from Platforms_Performance__r)
														FROM Account
														where Id in: accountIds ]);
									
		makeCalloutToMidasForOwnershipChange(accountmap);
	}
	
	/**
	* @Description: This method makes callout to MIDAS for updating the ownerships
	* @Params: Map<Id,Account> Map of all the accounts
	*/
	public static void makeCalloutToMidasForOwnershipChange(Map<Id,Account> accountMap){
	    List<Account> accounts				= accountMap.values();
	    List<Account> failedAccounts		= new List<Account>();
	    List<Account> successfullAccounts 	= new List<Account>();
	    Set<Id> failedAccountIds			= new Set<Id>();
	    Set<Id> successfullAccountIds		= new Set<Id>();
	    String api							= '/ownerships';
	    String errorMessage 				= 'Error: There was a failure in updating owners of the account in MIDAS for some accounts\n';
        
        // Populate all the maps required
        Map<String,List<Account>> codeVsAccountsMap 		= populateCodeVsAccountsMap(accounts);
        
        DataWrapper wrapper		= new DataWrapper();
        wrapper.populateMetaData();
        for(String code : codeVsAccountsMap.keySet()){
        	List<Account> accountsToBeProcessed = codeVsAccountsMap.get(code);
        	HttpResponse res = new HttpResponse();      
        	Http http = new Http();
        	String uri = '/v2/sites/'+code+api;
        	
        	wrapper.populateData(accountsToBeProcessed);
        	String body 			= JSON.serialize(wrapper,true);
        	System.debug('Body => ' + body);
        	HttpRequest req 		= LibWebserviceHelper.constructMidasHttpRequest('PP',uri,'POST',body);
        	// Log
        	String logName = code+'OwnershipChange';
        	LoggingUtility.createLog(logName,'MIDAS','OWNERSHIP CHANGE',null);
        	LoggingUtility.log(logName,'code : ' + code + '\nBody => ' + body);
        	if(req!=null){
        		try{
	                LoggingUtility.captureTimeStamp(logName,'Begin');
                    res = http.send(req);
                    LoggingUtility.captureTimeStamp(logName,'End');
                    LoggingUtility.log(logName,'\nResponse Body : ' + res.getBody() + 'Response status code : ' + res.getStatusCode());
	                if(res.getStatusCode()==200) {
	                    ResultWrapper resWrapper = (ResultWrapper)JSON.Deserialize(res.getBody(),ResultWrapper.class);
	                    for(Result result : resWrapper.data.results){                	
	                    	if(result.status != 'OK'){
	                    		errorMessage += 'SF Restaurant Id: ' + result.ownership.sf_restaurant_id + 
	                    						' Error: ' + result.status_code+ ': ' +result.description + '\n';
        						LoggingUtility.logError(logName,errorMessage);
	                    		accountMap.get(result.ownership.sf_restaurant_id).MIDASApiException__c = 'Error: ' + result.description;
	                    		if(!failedAccountIds.contains(accountMap.get(result.ownership.sf_restaurant_id).Id)){
	                    			failedAccounts.add(accountMap.get(result.ownership.sf_restaurant_id));
	                    			failedAccountIds.add(accountMap.get(result.ownership.sf_restaurant_id).Id);
	                    		}
	                    	}else{
	                    		// Clear the MIDASApiException__c
	                    		Account acc = accountMap.get(result.ownership.sf_restaurant_id);
	                    		acc.MIDASApiException__c = null;
	                    		if(!successfullAccountIds.contains(acc.Id)){
	                    			successfullAccounts.add(acc);
	                    			successfullAccountIds.add(acc.Id);
	                    		}
	                    	}
	                    } 
	                }else{
	            		errorMessage = 'Error: The MIDAS Ownership change callout failed for some accounts';
	            		LoggingUtility.logError(logName,errorMessage);
	                    for(Account acc : accountsToBeProcessed){
	                    	acc.MIDASApiException__c = 'Error: ' + res.getBody();
	                    	if(!failedAccountIds.contains(acc.Id)){
	                    		failedAccounts.add(acc);
	                    		failedAccountIds.add(acc.Id);
	                    	}
	                    }
	                }
        		}catch(CalloutException e){
        			LoggingUtility.captureTimeStamp(logName,'End');
                	LoggingUtility.logError(logName,e.getMessage());
        		}
            }else{
               	throw new AccountHelperException('Error: MidasIntegration__c is not configured');
            } 
        }    
        
        if(successfullAccounts.size() > 0){
        	update successfullAccounts;
        }
        if(failedAccounts.size() > 0 ){
        	update failedAccounts;
        }   	
        
        LoggingUtility.commitLogs();
	}
	
	/**
	* @Description: This method populates a map of (Code => Accounts)
	*/
	@TestVisible
	private static Map<String,List<Account>> populateCodeVsAccountsMap(List<Account> accounts){
		Map<String,List<Account>> codeVsAccountsMap =  new Map<String,List<Account>>();
		for(Account acc : accounts){
			if(acc.Platforms_performance__r.size() > 0){
				for(Platform_Performance__c plat : acc.Platforms_performance__r){
					String platformName;
					if(acc.recordType.developerName == 'Talabat_Account'){
	 					platformName 	= plat.Name;
	 				}else{
	 					platformName	= plat.Platform__c;
	 				}
					if(CountryCompanyBrand__c.getInstance(platformName) == null){
						// Not throwing the error as configuration cannot be present for few platforms
						//throw new AccountHelperException('Error: CountryCompanyBrand__c configuration not present for ' + plat.platform__c);
						continue;
					}
					String code = CountryCompanyBrand__c.getInstance(platformName).code__c;
					if(!codeVsAccountsMap.containsKey(code)){
		        		codeVsAccountsMap.put(code,new List<Account>());
		        	}
		        	codeVsAccountsMap.get(code).add(acc);
				}
			}else{
				if(CountryCompanyBrand__c.getInstance(acc.record_country__c) == null){
					// Nor throwing the error as few platforms cannot have platforms and owner is changed
					//throw new AccountHelperException('Error: CountryCompanyBrand__c configuration not present for '+ acc.record_Country__c);
					continue;
				}
				String code = CountryCompanyBrand__c.getInstance(acc.record_country__c).code__c;
				if(!codeVsAccountsMap.containsKey(code)){
	        		codeVsAccountsMap.put(code,new List<Account>());
	        	}
	        	codeVsAccountsMap.get(code).add(acc);
			}
		}
		return codeVsAccountsMap;          
	}
	
	/**
    * Called from verifyFPCategory method. Add error for accounts where number of categories chosen is greater then 1
    * @param list of accounts
    */
    public static void verifyCategory(List<Account> accs){
		/*All the recordtype set of Account Object */
		Map<Id, RecordType> accRTMap = LibRecordTypeHelper.getRecordTypeForIds(new Set<String>{'Account'});
		/*Getting data from process name */
		Map<String, Map<String, Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('oneCategoryRecordtypes');
		/*Getting all the business rules from process  */
		Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get('ALL');
		if(mapBusinessRules == null || mapBusinessRules.get('AccountRecordTypes') == null) {return;}
		/*Getting business rules related to Account recordtype  */
		Set<String> oneCatAccRTSet = new Set<String>(mapBusinessRules.get('AccountRecordTypes').Business_Rule_Value__c.split(','));

        List<String> lstCat = new List<String>();
        for(Account acc : accs){  
			if((accRTMap.get(acc.RecordTypeId) != null && !oneCatAccRTSet.contains(accRTMap.get(acc.RecordTypeId).developerName)) 
			|| String.isEmpty(acc.Category__c)) {continue;}
            lstCat = acc.Category__c.split(';');
            if(lstCat.size() > 1) acc.addError(Label.Error_message_for_Account_and_Lead_Category_Validation);
            lstCat.clear();
        }
    }
	
	/**
	* @Description: This class is a wrapper of the request generated
	*/
	public class DataWrapper{
		public Meta meta;
		public List<Data> data;
		
		public void populateMetaData(){
			String userEmail 	= UserInfo.getUserEmail();
			String userRole 	= [Select Name from UserRole where Id =: UserInfo.getUserRoleId()].Name;
			meta = new Meta(userEmail,userRole);
		}
		
		public void populateData(List<Account> accounts){
			data	= new List<Data>();
			for(Account acc : accounts){
				data.add(new Data(acc.owner.email,acc.Id));
			}
		}
	}
	
	/**
	* @Description: This class is a wrapper of the result
	*/
	public class ResultWrapper{
		public Data data;
	}
	
	public class Meta{
		public String username;
		public String sf_role;
		
		public Meta(String username,String sf_role){
			this.username 	= username;
			this.sf_role	= sf_role;
		}
	}
	
	public class Data{
		public String username;
		public Integer restaurant_id;
		public String sf_restaurant_id;
		public List<Result> results;
		
		public Data(String username,String sf_restaurant_id){
			this.username 			= username;
			this.sf_restaurant_id	= sf_restaurant_id;
		}
	}
	
	public class result{
		public String status;
		public String status_code;
		public String description;
		public Ownership ownership;
	}
	
	public class Ownership{
		public String username;
		public Integer restaurant_id;
		public String sf_restaurant_id;
	}
	
	public class AccountHelperException extends Exception{}
}
