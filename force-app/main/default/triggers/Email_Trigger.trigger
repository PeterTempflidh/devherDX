trigger Email_Trigger on EmailMessage (after insert) {

	if (Trigger_Manager__c.getInstance().Deactivate_Email_Trigger__c) return;
	
	if (Trigger.isAfter && Trigger.isInsert) {
		//ClsEmailProcessor.linkCaseToAccountBasedOnEmailaddress(Trigger.newMap);
		ClsEmailProcessor.sortIncomingEmailsByToAddress(Trigger.newMap);
	}
}