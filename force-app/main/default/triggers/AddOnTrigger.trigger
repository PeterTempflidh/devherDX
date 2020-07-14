/**
 * Created by t.holawala on 05.10.2017.
 */

trigger AddOnTrigger on List_Add_On__c (before update) {
    if(Trigger.isBefore && Trigger.isUpdate){
        AddOnTriggerHandler.processBeforeUpdate(Trigger.newmap,Trigger.OldMap);
    }
}