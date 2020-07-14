public with sharing class CtrAccountAdditionalInformation {

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

    public CtrAccountAdditionalInformation(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
    }

}