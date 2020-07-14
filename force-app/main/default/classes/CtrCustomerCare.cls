public with sharing class CtrCustomerCare {

	public Account myAccount {Get;Set;}
	public String status {Get;Set;}

	public CtrCustomerCare() {
		String para = ApexPages.currentPage().getParameters().get('accId');

		this.myAccount = [SELECT Id,Name,Menu_Typing_Date_Start__c,Menu_Typing_By_User__c,Menu_Typing_Menu_Link__c,
							Restaurant_Name__c,Menu_Typing_Progress_Status__c From Account WHERE Id =: para];
	}

	public void startProgress(){

		if( String.isEmpty(String.valueof(this.myAccount.Menu_Typing_Date_Start__c)) || String.isEmpty(this.myAccount.Menu_Typing_By_User__c) ){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select user or date'));
			this.status= 'nok';
		}else{
			this.status= 'ok';
			this.myAccount.Menu_Typing_Progress_Status__c = 'In Progress';
			update this.myAccount;
		}
		
	}
}