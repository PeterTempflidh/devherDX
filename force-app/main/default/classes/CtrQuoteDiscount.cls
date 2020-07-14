public with sharing class CtrQuoteDiscount {

	public Id targetObjectId { get; set; }
	public String hostname { get; set; }
	public String salutation { get; set; }
	public String opportunityName { get; set; }
	public String accountName { get; set; }
	public String quoteName { get; set; }

	public CtrQuoteDiscount() {
		hostname = ApexPages.currentPage().getHeaders().get('Host');
		List<User> runningUser = [SELECT Id, Manager.Name FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
		this.salutation = runningUser[0].Manager.Name;
	}
 
	public Id getWorkItemId(){
		Id workItemId = null;
		for(ProcessInstanceWorkitem workItem  : [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: targetObjectId])
        {
            workItemId  =  workItem.Id;
        }
        return workItemId;
	} 



	public String getDiscountUrl(){
		Id workItemId = getWorkItemId();
		String pageUrl = '/ui/support/servicedesk/ServiceDeskPage#/p/process/ProcessInstanceWorkitemWizardStageManager?id='+ workItemId;
		String absolutePath = 'https://' + this.hostname + pageUrl;
		system.debug(absolutePath);
		return absolutePath;
	}
}