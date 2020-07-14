public with sharing class CtrLeadCreate {

	public Lead leadObj {get;set;}

    public CtrLeadCreate(ApexPages.StandardController stdController) {
        this.leadObj = (Lead)stdController.getRecord();
        this.leadObj.Ownerid = UserInfo.getUserId();
        this.leadObj.Generated_Menu_Number__c = ''+Math.random();

    }

    public PageReference save(){
        insert leadObj;
        return new PageReference('/'+this.leadObj.id);
    }

    public PageReference saveAndNew(){
        insert leadObj;
        return new PageReference('/apex/LeadCreate').setRedirect(true);
    }

    public PageReference cancel(){
        return new PageReference('/00Q/o');
    }

    
}