trigger Asset_Cancellation_Trigger on Asset_Cancellation__c (before insert, after insert, before update, after update) {

    if (Trigger_Manager__c.getInstance().Deactivate_AssetCancellation_Trigger__c) return;
    
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        ClsAssetCancellationProcessor.assetCancellationProcess(Trigger.new, Trigger.oldMap);
        ClsAssetCancellationProcessor.refreshStockItemUsedDays();

    }

    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            ClsAssetCancellationProcessor.assetCancellationBeforeHandler(Trigger.new, Trigger.oldMap, Trigger.isInsert);
            ClsStockItemProcessor.copySerialNumberForGlobalSearchAssetCancellation(Trigger.new, Trigger.oldMap);
            ClsAssetCancellationProcessor.setStockUsedDays(Trigger.new, Trigger.oldMap);

        }
    }
}