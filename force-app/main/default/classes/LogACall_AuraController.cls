public with sharing class LogACall_AuraController {

    @AuraEnabled
    public static Task getTaskDetails(Id chatId){
        LiveChatTranscript chatDetails = new LiveChatTranscript();
        List<LiveChatTranscript> chatList = LiveChatTranscriptSelector.getChatCaseFieldsByChatTranscriptsId(chatId);
        if(chatList.size() > 0) {
            chatDetails = chatList[0];
        }
        if(chatDetails.CaseId != null) {
            List<Task> taskList = ActivitySelector.getTaskDetailsByParent(chatDetails.CaseId);
            if(taskList.size()>0){
                return taskList[0];
            }
        }
        return null;
    }

    @AuraEnabled
    public static String saveTask(Id chatId,Task taskRec,Task taskTemp) {
        LiveChatTranscript chatDetails = new LiveChatTranscript();
        map<Id,TaskRelation> taskRelationIdMap = new Map<Id,TaskRelation>();
        List<LiveChatTranscript> chatList = LiveChatTranscriptSelector.getChatCaseFieldsByChatTranscriptsId(chatId);
        if(chatList.size() > 0) {
            chatDetails = chatList[0];
        }
        if(chatDetails.CaseId != null) {

            if(taskRec.Id!=null){
                Task taskInDB = ActivitySelector.getTaskDetailsById(taskRec.Id);
                taskRec.ActivityDate = system.today();
                taskRec.Comments__c = taskRec.Description;
                for(TaskRelation tr:taskInDB.TaskRelations){
                    taskRelationIdMap.put(tr.RelationId,tr);
                }
            }
            else{
                //Associate case with the task as task 'Related To'
                taskRec.WhatId = chatDetails.CaseId;

                //Set task record type id based on the record type of the case. Ex. CD_Inbound_Case will have task of record type CD_Task
                taskRec.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(chatDetails.case.RecordType.DeveloperName.split('_')[0] + '_Task').getRecordTypeId();

                //Setting default values for fields on task to set task type as a 'Call log' to ensure correct feed item on case is created
                taskRec.ActivityDate = system.today();
                taskRec.Comments__c = taskRec.Description;
                taskRec.Status = 'Completed';
                taskRec.Type = 'Call';
                taskRec.TaskSubtype = 'Call';
                taskRec.CallType = 'Outbound';
                taskRec.CallObject = 'Call';
            }

            //Setting multiple WhoId for the task using the standard TaskRelation object
            List<TaskRelationWrapper> whoIdList = new List<TaskRelationWrapper>();

            /* Reason for checking if a test method is running:
               WhoIds are stored as a complex data structure by salesforce backend.
               When trying to cover this functionality with Test class, WhoId cannot be a complex data type.*/

            if(!Test.isRunningTest()) {
                if (taskTemp.whoId != null) {
                    whoIdList = (List<TaskRelationWrapper>) (JSON.deserialize(taskTemp.whoId, List<TaskRelationWrapper>.class));
                }
            }
            else{
                if (taskTemp.whoId != null) {
                    TaskRelationWrapper wrap = new TaskRelationWrapper();
                    wrap.id = taskTemp.whoId;
                    whoIdList.add(wrap);
                }
            }
            Database.UpsertResult sr = Database.upsert(taskRec);
            Id taskId;
            if (sr.isSuccess()) {
                taskId=sr.getId();
                Boolean isTrSaved = true;
                List<TaskRelation> trList = new List<TaskRelation>();
                List<TaskRelation> trListToInsert = new List<TaskRelation>();
                List<TaskRelation> trListToDelete = new List<TaskRelation>();
                if (whoIdList != null && whoIdList.size() > 0) {
                    for (TaskRelationWrapper wrap : whoIdList) {
                        TaskRelation tr = new TaskRelation();
                        tr.RelationId = wrap.Id;
                        tr.TaskId = taskRec.Id;
                        tr.IsWhat = false;
                        trList.add(tr);
                    }
                    if(taskRelationIdMap.keySet().size()>0) {
                        for (Id relId : taskRelationIdMap.keySet()) {
                            Boolean isDeleted = false;
                            for (TaskRelation tr : trList) {
                                if (tr.RelationId != relId) {
                                    isDeleted = true;
                                    if (!taskRelationIdMap.containsKey(tr.RelationId)) {
                                        trListToInsert.add(tr);
                                        isDeleted = false;

                                    }
                                } else {
                                    isDeleted = false;

                                }
                            }
                            if (isDeleted == true) {
                                trListToDelete.add(taskRelationIdMap.get(relId));
                            }
                        }
                    }
                    else{
                        trListToInsert.addAll(trList);
                    }
                }
                else{
                    trListToDelete=taskRelationIdMap.values();
                }
                if(trListToInsert.size()>0){
                    List<Database.SaveResult> srWhoList = Database.insert(trListToInsert);
                    for (Database.SaveResult srWho : srWhoList) {
                        if (!srWho.isSuccess()) {
                            isTrSaved = false;
                        }
                    }
                }
                if(trListToDelete.size()>0){
                    List<Database.DeleteResult> drWhoList = Database.delete(trListToDelete);
                    for (Database.DeleteResult drWho : drWhoList) {
                        if (!drWho.isSuccess()) {
                            isTrSaved = false;
                        }
                    }
                }
                if(isTrSaved) {
                    return ('Success:'+taskId);
                }
                else {
                    return 'Error';
                }
            }
            else {
                return 'Error: ' + sr.getErrors()[0].getMessage();
            }
        }
        else {
            return 'No Case Present';
        }
    }

    //Wrapper class to deserialize the whoId associated with the task.
    public class TaskRelationWrapper {
        public String id;
        public Map<String,String> context;
    }
}