/**
 * @description [Selector class for ActionItem__c]
 * Created by keerthan.tantry on 05/05/2020.
 */

public with sharing class ActionItemSelector {
    /**
    * @description [Get all action items]
    * @param idSet [Set of action item ids]
    * @return      [List of action items]
    */
    public static List<ActionItem__c> getActionItemsById(Set<String> idSet){
        List<ActionItem__c> actionItems = new List<ActionItem__c>();
        for(ActionItem__c obj : [SELECT  Id,Name,Priority__c,Score_Weighting__c,Type__c,End_Date__c,CreatedDate,
                                         (SELECT Id,Code__c,Status,Subject FROM Tasks)
                                 FROM ActionItem__c
                                 WHERE Id IN:idSet
                                 ORDER BY CreatedDate DESC]){
            actionItems.add(obj);
        }
        return actionItems;
    }
    /**
    * @description [Get action items linked to account ids]
    * @param idSet [Account Id set]
    * @return      [List of action items]
    */
    public static List<ActionItem__c> getActionItemsByAccountId(Set<String> idSet){
        List<ActionItem__c> actionItems = new List<ActionItem__c>();
        for(ActionItem__c obj : [SELECT  Name,Priority__c,Score_Weighting__c,Type__c,End_Date__c,Account__c,CreatedDate,
                                        (SELECT Id,Code__c,Status,Subject FROM Tasks)
                                 FROM ActionItem__c
                                 WHERE Account__c IN:idSet
                                 ORDER BY CreatedDate DESC ]){

            actionItems.add(obj);
        }
        return actionItems;
    }

}