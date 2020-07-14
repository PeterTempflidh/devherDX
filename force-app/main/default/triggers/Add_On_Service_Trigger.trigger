trigger Add_On_Service_Trigger on Add_on_Service__c ( after insert, after update, before insert, before update) {
    Add_On_Service_Helper addHel = new Add_On_Service_Helper();
    
    if (Trigger_Manager__c.getInstance().Deactivate_AddOnService_Trigger__c) return; 
	
	if (Trigger.isBefore) {
		addHel.ControlCreationAddOn(trigger.new);
	}else if(Trigger.isAfter && Trigger.isUpdate){
            addHel.OpportunityUpdateAddonByStatusChange(trigger.new , trigger.oldmap);
            addHel.updateOppOnAddOnActivation(trigger.new , trigger.oldmap);
    }
}