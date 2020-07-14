trigger Branding_Trigger on Branding_Content__c(before insert, after insert, after update, before delete) {
    if (Trigger_Manager__c.getInstance().Deactivate_Branding_Trigger__c) { return; }
    TriggerFactory.createAndExecuteHandler(BrandingContent_TriggerHandler.class);
}