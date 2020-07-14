/*
*   @description Class to query to get all activities(task,events,etc)
*/
public inherited sharing class ActivitySelector {
    public static List<Task> getTaskDetailsByParent(Id parentId) {
        return [SELECT Id,Subject,Activity_Subject__c,Type,Description,Comments__c,TaskSubtype,CallType,CallObject,ActivityDate,WhoId,(SELECT Id,RelationId,IsWhat FROM TaskRelations WHERE IsWhat=false) FROM Task WHERE WhatId = :parentId ORDER BY CreatedDate DESC];
    }
    public static Task getTaskDetailsById(Id taskId) {
        return [SELECT Id,Subject,Activity_Subject__c,Type,Description,Comments__c,TaskSubtype,CallType,CallObject,ActivityDate,WhoId,WhatId,Code__c,RecordTypeId,(SELECT Id,RelationId,IsWhat FROM TaskRelations WHERE IsWhat=false),TYPEOF What WHEN ActionItem__c THEN Id,Account__c END FROM Task WHERE Id = :taskId ORDER BY CreatedDate DESC];
    }
    /**
    *
    * @description  [Get all tasks where Code is in codes]
    * @param codes  [Set of codes]
    *
    * @return [List of tasks]
    */
    public static List<Task> getTaskDetailsByCode(Set<String> codes) {
        return [SELECT Id,Subject,Status,Priority,Activity_Subject__c,Type,Description,Comments__c,TaskSubtype,CallType,CallObject,ActivityDate,WhoId,WhatId,Code__c,RecordTypeId FROM Task WHERE Code__c IN :codes ORDER BY CreatedDate DESC];
    }

    @TestVisible
    private static List<Task> getAll() {
        return [SELECT Id,Subject,Activity_Subject__c,Type,Description,Comments__c,TaskSubtype,CallType,CallObject,ActivityDate,WhoId,(SELECT Id,RelationId,IsWhat FROM TaskRelations WHERE IsWhat=false) FROM Task ORDER BY CreatedDate DESC];
    }
}