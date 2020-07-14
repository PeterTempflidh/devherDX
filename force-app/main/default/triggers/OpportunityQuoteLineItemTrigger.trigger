trigger OpportunityQuoteLineItemTrigger on Opportunity_Quote_Line_Item__c (before insert, after insert, before update, after update) {
    
    if (Trigger_Manager__c.getInstance().Deactivate_QuoteLineItemTrigger__c) return;
    
    TriggerFactory.createAndExecuteHandler(OpportunityQuoteLineItemTriggerHandler.class);
    
}