trigger Account_Trigger on Account (before insert, before update, after update, after insert) {
	if (Trigger_Manager__c.getInstance().Deactivate_Account_Trigger__c) return;
	TriggerFactory.createAndExecuteHandler(Account_TriggerHandler.class);

	if (Trigger.isBefore) {
		ClsAccountProcessor.validateAccountDeliveryService(Trigger.new, null);
		ClsAccountProcessor.verifyCategory(Trigger.new, Trigger.oldMap);
	}
}
