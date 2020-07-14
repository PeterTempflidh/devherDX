/**
 * Created by t.holawala on 05.10.2017.
 */
/**
    @Description:  Trigger Handler for the Trigger: AddOnTrigger
 */
public class AddOnTriggerHandler {

    /**
        @Context: Before Update
        @Description: 1. Shortlists all the add ons which are made inactive from active
     */
    public static void processBeforeUpdate(Map<Id,List_Add_On__c> newMap,Map<Id,List_Add_On__c> oldMap){
        Set<Id> setOfIdsToProcess = new Set<Id>();
        for(List_Add_On__c li : newMap.values()) {
            if (li.Is_Active__c == false && oldMap.get(li.Id).Is_Active__c == true) {
                setOfIdsToProcess.add(li.Id);
            }
        }

        preventAddOnDeactivation(setOfIdsToProcess,newMap);
    }

    /**
        @Description: This method prevents deactivation of an Add-On if it is already associated with
                      an Active tariff
     */
    private static void preventAddOnDeactivation(Set<Id> setOfIdsToProcess,Map<Id,List_Add_On__c> newMap){
        if (!setOfIdsToProcess.isEmpty()) {
            Set<Id> setOfFailedIds = ProductAndServiceProcessor.validateServiceOrProductDeactivation(setOfIdsToProcess);
            if (!setOfFailedIds.isEmpty()) {
                for (Id failedId : setOfFailedIds) {
                   newMap.get(failedId).addError(Label.AddOn_cannot_be_de_activated_It_is_used_in_an_active_tarif);
                }
            }
        }
    }
}