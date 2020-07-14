trigger LiveChatTranscriptTrigger on LiveChatTranscript (before update,after update) {

    if (Trigger_Manager__c.getInstance().Deactivate_LiveChatTranscript_Trigger__c) return;
    
    TriggerFactory.createAndExecuteHandler(LiveChatTranscriptTriggerHandler.class);
    
}