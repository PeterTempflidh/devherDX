trigger Case_Trigger on Case (after update, before update, before insert, after insert) {

    if (Trigger_Manager__c.getInstance().Deactivate_Case_Trigger__c) return;

    TriggerFactory.createAndExecuteHandler(ClsCaseHandler.class);


}