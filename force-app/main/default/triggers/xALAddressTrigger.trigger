trigger xALAddressTrigger on xAL_Address__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (Trigger_Manager__c.getInstance().Deactivate_xALAddress_Trigger__c) { return; }
    TriggerFactory.createAndExecuteHandler(xALAddress_TriggerHandler.class);
}