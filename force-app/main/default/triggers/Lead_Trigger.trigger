trigger Lead_Trigger on Lead (before insert, before update, after insert) {

	if (Trigger_Manager__c.getInstance().Deactivate_Lead_Trigger__c) return;

	if (Trigger.isBefore) {

		if (Trigger.isInsert) {
			ClsLeadProcessor.PhoneToMobileForAUContactPage(Trigger.new);
			ClsLeadProcessor.validateLeadDeliveryService(Trigger.new, Trigger.oldMap);
		}

		if (Trigger.isUpdate) {
			ClsLeadProcessor.verifyGRID(Trigger.new, Trigger.oldMap);
			ClsLeadProcessor.validateLeadDeliveryService(Trigger.new, Trigger.oldMap);
		}

		ClsLeadProcessor.assignRecordCountryToBillingCountry(Trigger.new, Trigger.oldMap);
		LibBusinessConfig.setCountryLookUp(Trigger.new);
		LibBusinessConfig.setSObjectCurrencyAndCompanyCode(Trigger.new);
		ClsLeadProcessor.verifyCategory(Trigger.new, Trigger.oldMap);
	}

	if (Trigger.isAfter && Trigger.isInsert) {
		ClsLeadProcessor.setGRID(Trigger.new);
	}
}
