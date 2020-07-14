trigger Contract_Trigger on Contract (before insert, before update, before delete, after insert, after update, after delete) {
    if (Trigger_Manager__c.getInstance().Deactivate_Contract_Trigger__c) return;

    TriggerFactory.createAndExecuteHandler(ContractHandler.class);

}