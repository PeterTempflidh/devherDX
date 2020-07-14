trigger Tarif_Trigger on Tarif__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

	if (Trigger_Manager__c.getInstance().Deactivate_Tarif_Trigger__c) return;
	
	if (Trigger.isBefore && Trigger.isInsert) {
		Set<Id> setOfIdsToProcess = new Set<Id>();
		List<Tarif__c> listOfTarifsToProcess = new List<Tarif__c>();

		for (Tarif__c tarif : Trigger.new) {
			if (tarif.Is_Active__c == true) {
				listOfTarifsToProcess.add(tarif);
			}
		}

		if (!listOfTarifsToProcess.isEmpty()) {
			system.debug('@@@@ calling before insert tariff - listOfTarifsToProcess ' + listOfTarifsToProcess);
			try {
				Set<Id> setOfFailedIds = Tarif_Processor.validateTarifActivation(listOfTarifsToProcess);
				if (!setOfFailedIds.isEmpty()) {
					for (Id failedId : setOfFailedIds) {
						Trigger.newMap.get(failedId).addError(Label.Tarif_activation_failure);
					}
				}
			} catch (Exception e) {
				if (e.getMessage().contains('invalid ID field: null')) {
					Trigger.new[0].addError(Label.Save_Edit_Tariff_Failure);
				}
			}





		}
	}


	if (Trigger.isBefore && Trigger.isUpdate) {
		Set<Id> setOfIdsToProcess = new Set<Id>();
		List<Tarif__c> listOfTarifsToProcess = new List<Tarif__c>();

		for (Tarif__c tarif : Trigger.new) {
			if (tarif.Is_Active__c == true && Trigger.oldMap.get(tarif.Id).Is_Active__c == false ) {
				listOfTarifsToProcess.add(tarif);
			}
		}

		if (!listOfTarifsToProcess.isEmpty()) {
			Set<Id> setOfFailedIds = Tarif_Processor.validateTarifActivation(listOfTarifsToProcess);

			if (!setOfFailedIds.isEmpty()) {
				for (Id failedId : setOfFailedIds) {
					System.debug('failed ids found');
					Trigger.newMap.get(failedId).addError(Label.Tarif_activation_failure);
				}
			}


		}
	}

}