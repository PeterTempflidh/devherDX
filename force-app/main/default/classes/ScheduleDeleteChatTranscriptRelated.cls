/**
* @author Peter Tempfli
* @date 16.07.2020
*
* @description Ticket SC-547
* This schedulable class removes all the ConversationContextEntry records which are older than 30 days
* and removes all the LiveChatTranscriptEvent records which are older than 180 days
*
* Tests in UnitTestScheduleDeleteChatTranscript
*/

public with sharing class ScheduleDeleteChatTranscriptRelated implements Schedulable, Database.Batchable<SObject> {
    
    private String q;

    public ScheduleDeleteChatTranscriptRelated() {}

    public ScheduleDeleteChatTranscriptRelated(Schema.SObjectType soType, Integer lastNDays) {
        this.q = 'SELECT Id FROM '
                + soType.getDescribe().getName()
                + ' WHERE CreatedDate < LAST_N_DAYS:' + lastNDays;
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new ScheduleDeleteChatTranscriptRelated(ConversationContextEntry.SObjectType, 30));  
        Database.executeBatch(new ScheduleDeleteChatTranscriptRelated(LiveChatTranscriptEvent.SObjectType, 180));  
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.q); 
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        Database.DeleteResult[] deleteResultList = Database.delete(scope, false);
        logError(deleteResultList);
    }

    public void finish(Database.BatchableContext BC) {

    }
    /*public class DeleteConversationContextEntry implements Queueable {
        
        public DeleteConversationContextEntry() {}

        public void execute(System.QueueableContext ctx) {

            ConversationContextEntry[] cceList = [SELECT Id
                                                    FROM ConversationContextEntry
                                                    WHERE CreatedDate < LAST_N_DAYS:30
                                                    LIMIT 5000];
            
            if (!cceList.isEmpty()) {
                Database.DeleteResult[] deleteResultList = Database.delete(cceList, false);
                Boolean isError = logError(deleteResultList);
                if (isError) return;

                 if (!Test.isRunningTest()) {
                    System.enqueueJob(new DeleteConversationContextEntry());
                }
            }
        }        
    }

    public class DeleteLiveChatTranscriptEvent implements Queueable {
        
        public DeleteLiveChatTranscriptEvent() {}

        public void execute(System.QueueableContext ctx) {
            LiveChatTranscriptEvent[] lcteList = [SELECT Id
                                                    FROM LiveChatTranscriptEvent
                                                    WHERE CreatedDate < LAST_N_DAYS:180
                                                    LIMIT 5000];
            
            if (!lcteList.isEmpty()) {
                Database.DeleteResult[] deleteResultList = Database.delete(lcteList, false);
                Boolean isError = logError(deleteResultList);
                if (isError) return;

                if (!Test.isRunningTest()) {
                    System.enqueueJob(new DeleteLiveChatTranscriptEvent());
                }
            }
        }        
    }
    */

    /*
    * Logs errors if there are any, returns true if there is an error
    */
    private static void logError(Database.DeleteResult[] deleteResultList) {

        for (Database.DeleteResult res : deleteResultList) {
            if (!res.isSuccess()) {
                String errorMessages = '';
                for (Database.Error err : res.getErrors()) {
                    errorMessages += ' ' + err.getMessage();
                }

                LoggingUtility.logError(ScheduleDeleteChatTranscriptRelated.class.getName(), 
                                        String.format('Can not delete record {0}; Error message: {1}', new String[]{res.getId(), errorMessages})
                    );
            }
        }
        LoggingUtility.commitLogs();
    }

}
