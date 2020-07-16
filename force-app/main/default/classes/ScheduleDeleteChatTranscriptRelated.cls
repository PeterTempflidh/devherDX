/**
* @author Peter Tempfli
* @date 16.07.2020
*
* @description Ticket SC-547
* This schedulable class removes all the ConversationContextEntry records which are older than 30 days
* and removes all the LiveChatTranscriptEvent records which are older than 180 days
*/

public with sharing class ScheduleDeleteChatTranscriptRelated implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        System.enqueueJob(new DeleteConversationContextEntry());
        System.enqueueJob(new DeleteLiveChatTranscriptEvent());
    }

    public class DeleteConversationContextEntry implements Queueable {
        
        public DeleteConversationContextEntry() {}

        public void execute(System.QueueableContext ctx) {

            ConversationContextEntry[] cceList = [SELECT Id
                                                    FROM ConversationContextEntry
                                                    WHERE CreatedDate < LAST_N_DAYS:30
                                                    LIMIT 10000];
            
            if (!cceList.isEmpty()) {
                Database.DeleteResult[] deleteResultList = Database.delete(cceList, false);
                logError(deleteResultList);

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
                                                    LIMIT 10000];
            
            if (!lcteList.isEmpty()) {
                Database.DeleteResult[] deleteResultList = Database.delete(lcteList, false);
                logError(deleteResultList);

                if (!Test.isRunningTest()) {
                    System.enqueueJob(new DeleteLiveChatTranscriptEvent());
                }
            }
        }        
    }


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
