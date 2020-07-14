trigger Task_Trigger on Task (before insert, before update, after update, after insert) {

    if (Trigger_Manager__c.getInstance().Deactivate_Task_Trigger__c) return;

    /*if(trigger.isInsert && trigger.isAfter){
        ClsTaskProcessor.convertTaskToCases(Trigger.new);
    }*/
    if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter) {
        ClsTaskProcessor.updateLeadStatus(Trigger.new, Trigger.oldMap);
        ClsTaskProcessor.updateOpportunityStage(Trigger.New);

        if(Trigger.isUpdate){
            ClsTaskProcessor.syncTaskObject(Trigger.new, Trigger.oldMap);
        }
    }

    //Added for SP-1393. Will fire only on Insert
    if (Trigger.isInsert && Trigger.isAfter) {
        ClsTaskProcessor.updateCaseLastCallDate(Trigger.new);
        ClsTaskProcessor.updateLeadLastCallDate(Trigger.new);
        ClsTaskProcessor.setTaskCode(Trigger.new);
    }

}