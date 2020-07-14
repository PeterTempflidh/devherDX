/*
@author : Magesh Mani Yadav
@reviewer : 
@creation : 22.09.2014
*/
public without sharing class CtrUpdateQuoteStatus {
	@TestVisible private Opportunity_Quote__c oppQuote {get;set;}
	public Boolean showPanel {get;set;}
	private String urlKey;

	public CtrUpdateQuoteStatus() {
		this.urlKey = System.currentPageReference().getParameters().get('key').replace(' ','+');
		this.showPanel = true;
		if(this.urlKey!=null && this.urlKey.length()>0){
			checkQuoteStatus();
		}else{
			this.showPanel = false;
			showMessages('Invalid Key.');
		}
	}

	public Boolean checkQuoteStatus(){
		try{
			this.oppQuote = [select id,status__c,key__c from Opportunity_Quote__c where Url_Key__c =:this.urlKey limit 1];
		}catch(Exception e){
			showMessages('Invalid Key.');
			this.showPanel = false;
			return false;
		}
			if(this.oppQuote!=null && (this.oppQuote.status__c=='Accepted' || this.oppQuote.status__c=='Declined')){
				showMessages('Status was updated previously.');
				this.showPanel = false;
				return true;
			}
			return false;

	}

	public void showMessages(String messageLabel){
		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info,messageLabel));
	}

	public void acceptQuote(){
		if(!checkQuoteStatus()){
			oppQuote.status__c ='Accepted';
			update this.oppQuote;
			this.showPanel = false;
			showMessages('Status updated.');
		}
		
	}

	public void declineQuote(){
		if(!checkQuoteStatus()){
			oppQuote.status__c ='Declined';
			update this.oppQuote;
			this.showPanel = false;
			showMessages('Status updated.');
		}
	}
}