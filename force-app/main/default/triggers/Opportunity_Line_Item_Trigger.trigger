trigger Opportunity_Line_Item_Trigger on Opportunity_Line_Item__c (after insert, after update, before insert, before update) {
    if (Trigger_Manager__c.getInstance().Deactivate_Opp_Line_Item_Trigger__c) return;
	
    TriggerFactory.createAndExecuteHandler(OppLineItemHandler.class);
}