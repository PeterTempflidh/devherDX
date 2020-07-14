trigger Contact_Trigger on Contact (before insert, before update,after insert, after update) {

	if (Trigger_Manager__c.getInstance().Deactivate_Contact_Trigger__c) return;

	if ( Trigger.isBefore) {
		ClsContactProcessor.enforceOneOwnerRoleForAccountContacts(Trigger.new);
		LibBusinessConfig.setSObjectCurrencyAndCompanyCode(Trigger.new);
	}
	
	if (Trigger.isAfter) {
		if(Trigger.isUpdate){
			EventBusHelper.ValidateRecords('Contact',trigger.newMap, trigger.oldMap,Trigger.isInsert);
		}else if(Trigger.isInsert){
			EventBusHelper.ValidateRecords('Contact',trigger.newMap, trigger.newMap,Trigger.isInsert);
		}
	}



}