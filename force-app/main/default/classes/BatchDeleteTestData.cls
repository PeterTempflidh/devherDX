/** SP - 532
    * Batch for removal of testdata
    *
    * @param userid of testdata owner
    *      
    * @return void
    */

global class BatchDeleteTestData implements Database.Batchable<sObject>{
    
	String userId;
    
    
    global BatchDeleteTestData(String userId){
        this.userId = userId;
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select id from account limit 1';	
		return Database.getQueryLocator(query);
	}
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        List<Stock_Item__c> listStockItems = new List<Stock_Item__c>();
        List<Asset_Cancellation__c> listAssetCancel = new List<Asset_Cancellation__c>();
        List<Additional_Charges__c> listAddCharge = new List<Additional_Charges__c>();
        List<Asset__c> listAssets = new List<Asset__c>();
        List<Opportunity> listOpps = new List<Opportunity>();
        List<Account> listAccounts = new List<Account>();
        List<Lead> listLeads = new List<Lead>();
        List<Case> listCases = new List<Case>();
        List<Contact> listContacts = new List<Contact>();
        List<Branding_Content__c> listBranding = new List<Branding_Content__c>();
        List<Contract> listStandAloneContracts = new List<Contract>();
        List<EmailMessage> listEmails = new List<EmailMessage>();

        
        listStockItems = [SELECT Id FROM Stock_Item__c WHERE OwnerId =: userId];
        listAssetCancel = [SELECT Id FROM Asset_Cancellation__c WHERE OwnerId =: userId];
        listAddCharge = [SELECT Id FROM Additional_Charges__c WHERE CreatedById =: userId];
        listAssets = [SELECT Id FROM Asset__c WHERE OwnerId =: userId]; 
        listOpps = [SELECT Id FROM Opportunity WHERE OwnerId =: userId];
        listAccounts = [SELECT Id FROM Account WHERE OwnerId =: userId];
        listLeads = [SELECT Id FROM Lead WHERE OwnerId =: userId];
        listCases = [SELECT Id FROM Case WHERE OwnerId =: userId];
        listContacts = [SELECT Id FROM Contact WHERE OwnerId =:userId];
        listBranding = [SELECT Id FROM Branding_Content__c WHERE OwnerId =: userId];
        listStandAloneContracts = [SELECT Id FROM Contract WHERE OwnerId =: userId];
        listEmails = [SELECT Id FROM EmailMessage WHERE CreatedById =: userId];


        if(!listEmails.isEmpty()){
            delete listEmails;
        }
 
        if(!listBranding.isEmpty()){
            delete listBranding;
        }

        if(!listStockItems.isEmpty()){
            delete listStockItems;
        }
        
        if(!listAssetCancel.isEmpty()){
            delete listAssetCancel;
        }
        
        if(!listAddCharge.isEmpty()){
            delete listAddCharge;
        }
        
        if(!listAssets.isEmpty()){
            //check if cancellations linked to the asset exists which were not already deleted cause they are owned by another user
            List<Asset_Cancellation__c> cancellationByOtherUser = new List<Asset_Cancellation__c>();
            Set<Id> setAssets = new Set<Id>();
            for(Asset__c a : listAssets){
                if(!setAssets.contains(a.Id)){
                    setAssets.add(a.Id);
                }
            }
            cancellationByOtherUser = [SELECT Id FROM Asset_Cancellation__c WHERE Asset__c IN: setAssets];
            
            delete cancellationByOtherUser;
            
            delete listAssets;
        }

        if(!listCases.isEmpty()){
            delete listCases;
        }

        if(!listContacts.isEmpty()){
            delete listContacts;
        }
        
        if(!listOpps.isEmpty()){
            delete listOpps;
        }

        if(!listStandAloneContracts.isEmpty()){
            delete listStandAloneContracts;
        }
        
        if(!listAccounts.isEmpty()){
            Set<Id> setAccountIds = new Set<Id>();
            
            for(Account a : listAccounts){
                if(!setAccountIds.contains(a.id)){
                    setAccountIds.add(a.id);
                }
            }
            
            List<Case> listCasesLinkedToAccount = [SELECT Id FROM Case WHERE AccountId IN: setAccountIds];
            delete listCasesLinkedToAccount;
            
            List<Contract> listContract = [SELECT Id FROM Contract WHERE AccountId IN: setAccountIds];
            delete listContract;
            
            
            delete listAccounts;
        }
        
        if(!listLeads.isEmpty()){
            delete listLeads;
        }
    }
    
    global void finish(Database.BatchableContext BC) {

	}
}