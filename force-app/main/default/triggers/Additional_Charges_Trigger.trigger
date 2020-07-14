trigger Additional_Charges_Trigger on Additional_Charges__c (before update, after insert, after update) {
	
	if (Trigger_Manager__c.getInstance().Deactivate_Add_Charges_Trigger__c) return;

	if (Trigger.isUpdate && Trigger.isBefore) {

		ClsAdditionalChargeProcessor.populateFieldsAfterProductUpdate(Trigger.new, Trigger.oldMap);
		ClsAdditionalChargeProcessor.preventSelfApproval(Trigger.newMap);
	}
	if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter) {
		ClsAdditionalChargeProcessor.createAdditionalChargeShadow(Trigger.new);
		if (Trigger.isUpdate) {
			ClsAdditionalChargeProcessor.createEntryCaseForFlatCommissionCancelation(Trigger.new, Trigger.oldMap);
		}
	}
}