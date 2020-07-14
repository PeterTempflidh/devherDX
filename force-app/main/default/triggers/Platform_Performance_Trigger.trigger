trigger Platform_Performance_Trigger on Platform_Performance__c (after insert, after update ) {
    if (Trigger_Manager__c.getInstance().Deactivate_Platform_Trigger__c) return;

      //ClsPlatformPerformanceProcessor.sendToBackendPlatformToEventBus(Trigger.new);

    if(trigger.isInsert){
        //ID jobID = System.enqueueJob(new ClsAsyncEventBusExecution(trigger.newMap));
        EventBusHelper.ValidateRecordsPlatform('Platform', trigger.newMap);
    }else if(trigger.isUpdate){
        EventBusHelper.ValidateRecords('Platform_Performance__c', Trigger.newMap, Trigger.oldMap, false);
    }

    ClsPlatformPerformanceHandler.UpdateParentOnlineStatus(trigger.newMap, Trigger.oldMap);
}