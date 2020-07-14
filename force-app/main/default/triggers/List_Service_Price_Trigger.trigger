trigger List_Service_Price_Trigger on List_Service_Price__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

	if (Trigger_Manager__c.getInstance().Deactivate_List_Serv_Price_Trigger__c) return;

	if (Trigger.isBefore && Trigger.isUpdate) {
		Set<Id> setOfIdsToProcess = new Set<Id>();

		for (List_Service_Price__c so : Trigger.new) {
			if (so.Is_Active__c == false && Trigger.oldMap.get(so.Id).Is_Active__c == true) { //if the service is about to get disabled
				if (!setOfIdsToProcess.contains(so.Id)) {
					setOfIdsToProcess.add(so.Id);
				}
			}
		}

		if (!setOfIdsToProcess.isEmpty()) {
			Set<Id> setOfFailedIds = ProductAndServiceProcessor.validateServiceOrProductDeactivation(setOfIdsToProcess);
			if (!setOfFailedIds.isEmpty()) {
				for (Id failedId : setOfFailedIds) {
					Trigger.newMap.get(failedId).addError(Label.Service_cannot_be_de_activated_It_is_used_in_an_active_tarif);
				}
			}
		}

	}
}