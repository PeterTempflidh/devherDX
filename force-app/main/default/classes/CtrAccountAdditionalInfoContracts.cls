public with sharing class CtrAccountAdditionalInfoContracts {

	private final Account acct;
	public Account extraInfo {
		Get{
			return this.extraInfo = [Select Id,Menu_Typing_Progress_Status__c,Name,
				        Menu_Typing_By_User__c,
				        Menu_Typing_Date_Start__c,
				        Restaurant_Status__c
				        from Account 
				        where id =: this.acct.Id];
		}
	Set;}

	public Map<Id,Contract> mapContracts {Get;Set;}
	public String contractId {Get;Set;}
	
    public CtrAccountAdditionalInfoContracts(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();

        this.mapContracts = new Map<Id,Contract>([SELECT Id,Name__c,Commission__c,
        										End_Date__c,StartDate,ActivatedDate,Status
        										 FROM CONTRACT 
        										 WHERE AccountId =: this.acct.Id]);
    }
}