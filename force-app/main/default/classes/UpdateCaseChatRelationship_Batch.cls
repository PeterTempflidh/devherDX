/**
 * Created by t.jain on 2019-05-08.
 */

global class UpdateCaseChatRelationship_Batch implements Database.Batchable<sObject>{

    String whereCondition='';

    //whereCondition=' WHERE Origin='Chat' AND RecordTypeId='<Record Type Id>' AND Live_Chat_Transcript_Id__c!=null AND Status!='New''
    public UpdateCaseChatRelationship_Batch(String whereClause){
        whereCondition=whereClause;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Live_Chat_Transcript_Id__c FROM CASE'+whereCondition;
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Map<Id,String> chatIds=new Map<Id,String>();
        List<sObject> recordsToUpdate=new List<sObject>();
        for(Case c:(List<Case>)scope){
            chatIds.put(c.Live_Chat_Transcript_Id__c,c.Id);
            c.Live_Chat_Transcript_Id__c=null;
            recordsToUpdate.add((sObject)c);
        }
        List<LiveChatTranscript> chats=[SELECT Id,CaseId FROM LiveChatTranscript WHERE Id IN :chatIds.keySet()];
        for(LiveChatTranscript chat:chats){
            if(chat.caseId==null) {
                chat.CaseId = chatIds.get(chat.Id);
                recordsToUpdate.add((sObject) chat);
            }
        }
        LoggingUtility.createLog('UpdateCaseChatRelationship_Batch', 'BATCH', 'CASE Chat Relationship Update Error', null);
        try {
            List<Database.SaveResult> sResults = Database.update(recordsToUpdate);
            boolean isError = false;
            for (Database.SaveResult sr : sResults) {
                if (!sr.isSuccess()) {
                    for (Database.Error e : sr.getErrors()) {
                        LoggingUtility.logError('UpdateCaseChatRelationship_Batch', 'UpdateCaseChatRelationship_Batch: Update failed for case ' + sr.Id +
                                ' Errors ' + e.getMessage() + ' ::: ' + e.getFields() + ' :::: ' + e.getStatusCode() + '\n');
                        isError = true;
                    }
                }
            }
            if(isError){
                LoggingUtility.commitLogs();
            }
        }catch(Exception e){
            LoggingUtility.logError('UpdateCaseChatRelationship_Batch', 'UpdateCaseChatRelationship_Batch: Update failed for case :: Errors ' + e.getMessage()+' \n');
            LoggingUtility.commitLogs();
        }

    }

    global void finish(Database.BatchableContext BC) {

    }

}