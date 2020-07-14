trigger Asset_Trigger on Asset__c (before update, before insert, after update, after insert) {

    if (Trigger_Manager__c.getInstance().Deactivate_Asset_Trigger__c) return;

    // update
    if (Trigger.isUpdate) {

        if (Trigger.isBefore) {
            // before update
            ClsAssetProcessor.resetAllReturnFields(Trigger.new, Trigger.oldMap);
            ClsStockItemProcessor.copySerialNumberForGlobalSearch(Trigger.new, Trigger.oldMap);
            ClsAssetProcessor.updateTakeoverSharingAssetValues(Trigger.new, Trigger.oldMap); //Takeover
        } else if (Trigger.isAfter) {

            // after update 
            ClsAssetProcessor.createAssetCancellation(Trigger.new, Trigger.oldMap);
            ClsAssetProcessor.setAssignedStockStatus(Trigger.new, Trigger.oldMap);
            ClsStockItemProcessor.trackAccountHistory(Trigger.newMap, Trigger.oldMap);
            ClsAssetProcessor.updateAdditionalChargeShadowRecord(Trigger.newMap, Trigger.oldMap);
            ClsAssetProcessor.stockItemFollowUp(Trigger.new, Trigger.oldMap);
            ClsAssetProcessor.assetStatusUpdateProcess(Trigger.new, Trigger.oldMap);
            ClsAssetProcessor.opportunityUpdateonAssetStatusChange(Trigger.new, Trigger.oldMap);
            clsAssetProcessor.OpportunityUpdateAssetByStatusChange(Trigger.new, Trigger.oldMap);
            ClsAssetProcessor.updateTakenoverAssetValues(); //Taken over
            ClsAssetProcessor.synchSharedAssetValues(Trigger.new, Trigger.oldMap); //Synch data from source asset to shared assets
        }
    }

    // insert
    if (Trigger.isInsert) {

        if (Trigger.isBefore) {

            // before insert
            ClsAssetProcessor.updateRecordCountry(Trigger.new);
            ClsStockItemProcessor.copySerialNumberForGlobalSearch(Trigger.new, null);
            ClsAssetProcessor.changeAssetStatusByProductType(Trigger.new);

        } else if (Trigger.isAfter) {

            // after insert
            clsAssetProcessor.OpportunityUpdateAssetByStatusChange(Trigger.new, null);
            ClsStockItemProcessor.trackAccountHistory(Trigger.newMap, Trigger.oldMap);
            ClsAssetProcessor.linkAssetToOnBoardingCase(Trigger.new);
        }
    }
}