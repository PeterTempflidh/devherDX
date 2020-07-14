/**
 * Created by keerthan.tantry on 03/05/2020.
 * @description  [Class used as controller for linkActionItems LWC ]
 *               [Link Action Items from Task]
 *               [De-Link Action Items Task]
 *
 */

public with sharing class CtrLinkActionItems {
    public static final String ACCOUNT_LOOKUP = 'Account__c';
    /**
    * @description  [Get all action items linked to the account associated with the task]
    * @param taskId [task Id]
    * @return  [List of action items]
    */
    @AuraEnabled
    public static List < ActionItemsWrapper > getActionItems(String taskId) {
        List < ActionItemsWrapper > retList = new List < ActionItemsWrapper > ();
        List < ActionItem__c > actionItems = new List < ActionItem__c > ();
        try {
            Task objTask = ActivitySelector.getTaskDetailsById(taskId);
            if (objTask.What.get(ACCOUNT_LOOKUP) != null) {
                for (ActionItem__c obj : ActionItemSelector.getActionItemsByAccountId(new Set < String >{
                        String.valueOf(objTask.What.get(ACCOUNT_LOOKUP))
                })) {
                    if (objTask.WhatId != obj.Id) {
                        actionItems.add(obj);
                    }
                }
            }
                retList = getActionItemsWrapperList(objTask.Code__c, actionItems);
                System.debug('getActionItemsWrapperList ==>' + retList);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return retList;
    }
    /**
    * @description         [Clones Task with id taskId under action items in  actionItemIds]
    *                      [Copies Code__c across all cloned Tasks - Logical grouping of tasks for syncing]
    * @param taskId        [Id of Task to clone]
    * @param actionItemIds [Action Item Ids under which task is cloned and grouped with Code__c]
    */
    @AuraEnabled
    public static void linkActionItems(Id taskId, String actionItemIds) {
        Task objTask;
        List < Task > tasksToInsert = new List < Task > ();
        Set < String > actionItemIdSet;
        try {
            if (String.isNotBlank(actionItemIds)) {
                actionItemIdSet = new Set < String > (actionItemIds.split(','));
                objTask = ActivitySelector.getTaskDetailsById(taskId);
                tasksToInsert = getTasksToInsert(objTask, actionItemIdSet);
            }
            if (!tasksToInsert.isEmpty()) {
                insert tasksToInsert;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }
    /**
    * @description         [De-link/Delete all of the tasks created with same Code under Action Items in actionItemIds ]
    *
    * @param code          [Code value -  Used to identify cloned task linked to Action Items in actionItemIds]
    * @param actionItemIds [Action Item Ids under which task is cloned and grouped with Code__c]
    */
    @AuraEnabled
    public static void delinkActionItems(String code, String actionItemIds) {

        List < Task > tasksToDelete = new List < Task > ();
        Set < String > actionItemIdSet;
        try {
            if (String.isNotBlank(actionItemIds)) {
                actionItemIdSet = new Set < String > (actionItemIds.split(','));
                for (Task obj : ActivitySelector.getTaskDetailsByCode(new Set < String >{
                        code
                })) {
                    if (obj.WhatId != null && actionItemIdSet.contains(obj.WhatId)) {
                        tasksToDelete.add(obj);
                    }
                }
                if (!tasksToDelete.isEmpty()) {
                    Database.delete(tasksToDelete, false);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }


    }
    /**
    * @description            [Gets list of Tasks to insert under each Action Items in actionItemIdSet ]
    * @param task             [Task to clone]
    * @param actionItemIdSet  [Set of action item Ids]
    *
    * @return
    */
    public static List < Task > getTasksToInsert(Task task, Set < String > actionItemIdSet) {
        Task newTask;
        List < Task > tasksToInsert = new List < Task > ();
        for (ActionItem__c obj : ActionItemSelector.getActionItemsById(actionItemIdSet)) {
             if (!isTaskAlreadyLinked(task.Code__c, obj)) {
                newTask = task.clone(false, true, false, false);
                newTask.WhatId = obj.Id;
                tasksToInsert.add(newTask);
            }
        }
        return tasksToInsert;
    }
    /**
    * @description         [Creates Action Item Wrapper list ]
    * @param code          [Code to display isLinked column on action item table]
    * @param actionItems   [List of Action Items associated to Account]
    *
    * @return
    */
    public static List < ActionItemsWrapper > getActionItemsWrapperList(String code, List < ActionItem__c > actionItems) {
        List < ActionItemsWrapper > retList = new List < ActionItemsWrapper > ();
        ActionItemsWrapper objWrapper;
        for (ActionItem__c obj : actionItems) {
            objWrapper = new ActionItemsWrapper(obj, isTaskAlreadyLinked(code, obj));
            retList.add(objWrapper);
        }
        return retList;
    }
    /**
    * @description          [Determines if task is already linked to Action Item ]
    * @param code           [Tak Code value]
    * @param objActionItem  [Action Item to check if Task is already linked]
    * @return
    */
    public static Boolean isTaskAlreadyLinked(String code,ActionItem__c objActionItem) {
        Boolean isLinked = false;
        isLinked = objActionItem.Tasks.isEmpty() ? false : true;
        for (Task obj : objActionItem.Tasks) {
            if (String.isNotBlank(code) && code.equals(obj.Code__c)) {
                isLinked = true;
            }
        }
        return isLinked;
    }
    /**
    * @description  [Wrapper class used to display Action Item table on Task link screen ]
    */
    public class ActionItemsWrapper {
        @AuraEnabled public Id actionItemId;
        @AuraEnabled public String name;
        @AuraEnabled public Boolean isLinked;
        @AuraEnabled public String actionType;
        @AuraEnabled public String priority;
        /**
        *
        * @description [Constructor method]
        * @param obj   [Action Item Object]
        * @param isLinked [ Boolean indicator to identify if task with same code is associated already]
        */
        public ActionItemsWrapper(ActionItem__c obj, Boolean isLinked) {
            this.actionItemId = obj.Id;
            this.name = obj.Name;
            this.priority = obj.Priority__c;
            this.isLinked = isLinked;
            this.actionType = obj.Type__c;
        }
    }


}