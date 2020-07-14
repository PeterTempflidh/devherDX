trigger Attachment_Trigger on Attachment (before insert, after insert) {

	if (Trigger_Manager__c.getInstance().Deactivate_Attachment_Trigger__c) return;
	
	if (trigger.isInsert && trigger.isAfter) {
		ClsAttachmentProcessor.updateLastBranding(trigger.new);
	}

	if (trigger.isInsert && trigger.isBefore) {
		ClsAttachmentProcessor.updateParentToCaseOnEmailAttch(trigger.new);
	}
}