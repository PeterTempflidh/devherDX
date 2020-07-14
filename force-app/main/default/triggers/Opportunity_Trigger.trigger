trigger Opportunity_Trigger on Opportunity (after update, before insert, before update, after insert) {

    if (Trigger_Manager__c.getInstance().Deactivate_Opportunity_Trigger__c) return;
    
    TriggerFactory.createAndExecuteHandler(ClsOpportunityHandler.class);
}