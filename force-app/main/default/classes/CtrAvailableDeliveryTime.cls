public with sharing class CtrAvailableDeliveryTime {
	public Account acct { get; set; }
	public Boolean showEdit { get; set; }
	public CtrAvailableDeliveryTime(ApexPages.StandardController stdController) {
		this.showEdit = false;
		this.acct = (Account) stdController.getRecord();
	}

	public void save () {
		try {
			update this.acct;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Account_Available_Delivery_Time_Saved_Successfully));
			this.showEdit = false;
		} catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Account_Available_Delivery_Time_Save_Error));
			System.debug('@@@@ calling save in CtrAvailableDeliveryTime. Following error occurred while saving delivery time info: ' + e.getMessage());
		}
	}

	public void edit(){
		this.showEdit = true;
	}

	public void cancel(){
		this.showEdit = false;
	}
}