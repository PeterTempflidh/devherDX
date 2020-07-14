trigger ContentVersionTrigger on ContentVersion (after update, before insert, before update, after insert) {

    if(Trigger_Manager__c.getInstance().Deactivate_ContentVersion_Trigger__c) return;

    TriggerFactory.createAndExecuteHandler(ContentVersion_TriggerHandler.class);
}