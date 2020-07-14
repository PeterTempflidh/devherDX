trigger AddressDetail_Trigger on AddressDetail__c (before insert, before update, after insert, after update) {
	// checks if trigger is disabled
	if (Trigger_Manager__c.getInstance().Deactivate_AddressDetail_Trigger__c) return;
	TriggerFactory.createAndExecuteHandler(Address_TriggerHandler.class);

	if(trigger.isBefore){
		TrgAddressDetailProcessor.checksDuplicateAddressTypesPerAccount(Trigger.New);
		TrgAddressDetailProcessor.generateSignedUrlForMapImage(Trigger.New);
		       	
	}
 
	if(trigger.isAfter){

			EventBusHelper.ValidateRecords('AddressDetail__c',trigger.newMap, trigger.newMap,Trigger.isInsert);

	}

}