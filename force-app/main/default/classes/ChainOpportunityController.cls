public with sharing class ChainOpportunityController implements Queueable{
    
    public Opportunity opp          { get; set;}
    private String oppId;
    private List<Id> accountIds;
    
    public ChainOpportunityController(){
    	
    }
    
    public ChainOpportunityController(ApexPages.StandardController controller){
    	if(!Test.isRunningTest()){
        	controller.addFields(new List<String> {'StageName'});
        	controller.addFields(new List<String> {'RecordType.developerName'});
        }
    	this.opp        = (Opportunity)controller.getRecord();
        oppId           = this.opp.Id;
    }
    
    public ChainOpportunityController(String oppId,List<Id> accountIds){
    	this.oppId			= oppId;
    	this.accountIds		= accountIds;
    }
    
    /**
    * @Description: This method fetches all the child accounts (Branch Level) of the account associated with the opportunity
    				along with the child opportunities which are the child of the chain opportunitiy to check
    				whether the deal is already applied to the account or not.
    				
    	@InputParam	: Chain Opportunity Id
    	@Return		: List of Account Wrapper (Child Branches)
    */
    @RemoteAction 
    public static ResultWrapper fetchBranches(String oppId){
    	ResultWrapper result;
    	Opportunity opp 				= [SELECT AccountId,Account.type,AsynchJobId__c,
    											  recordType.developerName,stageName 
    										FROM Opportunity where id = :oppId];
    	Integer maxIterationCount 		= 5;
    	List<AccountWrapper> accounts  = new List<AccountWrapper>();
    	
    	if(opp.recordType.developerName != 'Chain_Opportunity'){
    		result = new ResultWrapper(new List<AccountWrapper>(),false,System.Label.Chain_Opportunity_RecordType,true);
    		return result;
    	}
    	
    	/**
    	* NOTE: Making query in the loop in order to fetch the child account records, and fetching the child branch records
    			in a single query degrades the performance of the query and will require entire table scan.
    	*/
    	List<String> parentIds = new List<String>{opp.accountId};
    	for(Integer i=0;i<maxIterationCount;i++){
    		List<Account> childAccounts = [SELECT Id,Name,Restaurant_name__c,Formatted_Restaurant_Address__c,
	    										Type,GRID__c,Account_status__c,parentId,parent.name,
	    										(SELECT Id from Opportunities where parent_Opportunity__c =: oppId)
	    									FROM Account
	    									WHERE parentId in :parentIds];
	    	parentIds.clear();
	    	for(Account acc : childAccounts){
	    		if(acc.type.contains('Branch')){
	    			accounts.add(new AccountWrapper(acc));
	    		}else{
	    			parentIds.add(acc.Id);
	    		}
	    	} 				
	    	
	    	if(parentIds.size() == 0)
	    		break;			
	    
    	}
    	
    	// Check if the job creation is under process 
    	if(opp.AsynchJobId__c != null){
    		AsyncApexJob  job  	= [Select Status From AsyncApexJob  where id =: opp.AsynchJobId__c];
    		if(job.status == 'Completed' || job.status == 'Failed' || job.status == 'Aborted'){
    			result				= new ResultWrapper(accounts,false,null,false);
    		}else{
    			result				= new ResultWrapper(accounts,true,System.Label.Chain_Opportunity_Under_Process,false);
    		}
    	}else{
    		result				= new ResultWrapper(accounts,false,null,false);
    	}
    	
    	return result;
    }
    
    
    /**
    * @Description: This method applies the chain opportunity deals to the accounts which are selected on the page
    			NOTE: This method creates the opportunities in chunk to avoid exceeding CPU time limit
    */
    @RemoteAction
    public static ResultWrapper applyDeals(String serializedAccountWrapper,Id oppId){
    	List<AccountWrapper> accounts 		= (List<AccountWrapper>)JSON.deserialize(serializedAccountWrapper,List<AccountWrapper>.class);
    	Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    	Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('HeadquarterDealProcess');
		Map<String, Business_Config__c> mapBusinessRules 				= mapBusinessLogic.get('Global_Config');    			
    	Set<Id> accountIdsToBeProcessed 								= new Set<Id>();
    	Integer Threshold					= Integer.valueOf(mapBusinessRules.get('SynchronousThreshold').Business_Rule_Value__c);
    	
    	Opportunity opp = [SELECT StageName from Opportunity where id =: oppId];
    	if(opp.stageName != 'Closed Won'){
    		throw new ChainOpportunityException(System.Label.Chain_Opportunity_stage);
    	}
    	
    	// Shortlist the accounts to be processed and mark the accounts for deal creation
    	for(AccountWrapper acc : accounts){
    		if(acc.isSelected && !acc.dealAlreadyApplied){
    			accountIdsToBeProcessed.add(acc.Id);
    			acc.dealAlreadyApplied = true;
    		}
    	}
    	
    	if(accountIdsToBeProcessed.size() == 0){
    		throw new ChainOpportunityException(System.Label.Chain_Opportunity_No_Accounts);
    	}
    	
    	// Checking again if the Opportunity is created for the shortlisted accounts or not
    	List<Account> accountRecords = [SELECT Id,
    										(SELECT Id from Opportunities where parent_Opportunity__c =: oppId)
	    								FROM Account
	    								where id in: accountIdsToBeProcessed];
    								
    	for(Account acc : accountRecords){
    		if(acc.Opportunities.size() > 0){
    			accountIdsToBeProcessed.remove(acc.Id);
    		}
    	}
    	
    	if(accountIdsToBeProcessed.size() == 0){
    		throw new ChainOpportunityException(System.Label.Chain_Opportunity_account_already);
    	}

    	try{
    		ResultWrapper wrapper ;
    		// if the number of accounts are above the threshold use the asynchronous approach otherwise process synchonously
    		if(accountIdsToBeProcessed.size() > Threshold){
    			enqueueJob(oppId,new List<Id>(accountIdsToBeProcessed));
    			wrapper = new ResultWrapper(accounts,true,System.Label.Chain_Opportunity_Under_Process,false);
    		}else{
    			ClsOpportunityProcessor.createChildOpportunities(oppId,new List<Id>(accountIdsToBeProcessed));
    			wrapper = new ResultWrapper(accounts,false,System.Label.Chain_Opportunity_Success,false); 
    		}
    		
    		return wrapper;
    	}catch(Exception e){
    		throw new ChainOpportunityException('Error while creating sub deals ' + e.getMessage());
    	}    
    } 
    
    
    /**
    * @Description: This method apply the deals asynchronously
    */
    public void execute(QueueableContext context){
    	Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    	Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('HeadquarterDealProcess');
		Map<String, Business_Config__c> mapBusinessRules 				= mapBusinessLogic.get('Global_Config');
    	Integer Threshold	= Integer.valueOf(mapBusinessRules.get('AsynchronousThreshold').Business_Rule_Value__c);
    	
    	ClsOpportunityProcessor.createChildOpportunities(oppId,cloneList(accountIds,threshold));
    	
    	if(accountIds.size() > 0){
    		ChainOpportunityController.enqueueJob(oppId,accountIds);
    	}else{
    		// Clear the job id from the opportunity
    		ChainOpportunityController.updateOppWithJobId(oppId,null);
    		// Send an email to the opportunity owner about the completion of the task
    		ChainOpportunityController.sendEmailNotification(oppId);
    	}
    }
    
    
    public static void enqueueJob(String oppId,List<Id> accountIds){
    	ChainOpportunityController controller =  new ChainOpportunityController(oppId,accountIds);
    	ID jobID = System.enqueueJob(controller);
        //System.enqueueJob() returns null in Apex tests
        if(test.isRunningTest() && string.isBlank(jobID)){
            jobID = '707w000004KeCKAAA3'; //test ID
        }
    	updateOppWithJobId(oppId,jobId);
    }
    
    public static List<Id> cloneList(List<Id> accountIds,Integer threshold){
    	List<Id> accountIdsToBeProcessed 		= new List<Id>();
    	List<Id> accountsToBeProcessedLater		= new List<Id>();
    	System.debug('accounts size ' + accountIds.size());
    	Integer count = 0;
    	for(Id accId : accountIds){
    		if(count < threshold){
	    		accountIdsToBeProcessed.add(accId);
	    		count++;
    		}else{
    			accountsToBeProcessedLater.add(accId);
    		}
    	}
    	
		accountIds.clear();
		accountIds.addAll(accountsToBeProcessedLater);
    	
    	return accountIdsToBeProcessed;
    }
    
    public static void updateOppWithJobId(String oppId,String jobId){
    	Opportunity opp = new Opportunity(id = oppId,asynchJobId__c = jobId);
    	update opp;
    }
    
    /**
      @Description: This method sends email notifications to the opportunity owners that the deal creation process 
    				has been completed
    */
    public static void sendEmailNotification(Id oppId){
    	Opportunity opp = [SELECT Id,Owner.FirstName,Owner.Email
    							FROM Opportunity 
    							WHERE Id =: oppId];
    	
    	ClsEmailReply.sendEmailNotification(opp,'Headquarter_deal_Completion');
    }
    /**
    * @Description: Wrapper for the account detail which are to be displayed on the page.
    */
    public class AccountWrapper{
    	public String Id;
    	public String Name;
    	public String RestaurantName;
    	public String FormattedAddress;
    	public String Type;
    	public String GRID;
    	public String AccountStatus;
    	public Boolean isSelected;
    	public Boolean dealAlreadyApplied;
    	public String ParentId;
    	public String ParentName;
    	
    	
    	public AccountWrapper(Account acc){
    		this.Id					= acc.Id;
    		this.Name 				= acc.Name;
    		this.RestaurantName 	= acc.Restaurant_Name__c;
    		if(acc.Formatted_Restaurant_Address__c != null){
    			this.FormattedAddress	= acc.Formatted_Restaurant_Address__c.replaceAll('_BR_ENCODED_',', ');
    		}else{
    			this.FormattedAddress	=  '';
    		}
    		this.Type 				= acc.Type;
    		this.GRID				= acc.GRID__c;
    		this.AccountStatus		= acc.Account_Status__c;
    		this.isSelected			= false;
    		this.dealAlreadyApplied	= false;
    		this.ParentId			= acc.parentId;
    		this.ParentName			= acc.parent.name;
    		
    		if(acc.opportunities.size() > 0){
    			this.dealAlreadyApplied = true;
    			this.isSelected			= true;
    		}
    	}
    }
    
    public Class ResultWrapper{
    	public List<AccountWrapper> accounts;
    	public Boolean isJobEnqueued;
    	public String message;
    	public Boolean isError;
    	
    	public ResultWrapper(List<AccountWrapper> accounts,Boolean isJobEnqueued,String message,Boolean isError){
    		this.accounts 		= accounts;
    		this.isJobEnqueued	= isJobEnqueued;
    		this.message		= message;
    		this.isError		= isError;
    	}    	
    }
    
    public class ChainOpportunityException extends Exception{}
}
