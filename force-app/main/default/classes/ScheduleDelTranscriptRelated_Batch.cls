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

public with sharing class ScheduleDelTranscriptRelated_Batch implements Schedulable, Database.Batchable<SObject> {
    
    private String q;

    public ScheduleDelTranscriptRelated_Batch() {}

    public ScheduleDelTranscriptRelated_Batch(Schema.SObjectType soType, Integer lastNDays) {
        if (soType != ConversationContextEntry.SObjectType && soType != LiveChatTranscriptEvent.SObjectType) {
            system.assert(false, 'This SObject is not allowed to delete.');
        }
        if (lastNDays != 30 && lastNDays != 180) {
            system.assert(false, 'This time range is not allowed.');
        }

        this.q = 'SELECT Id FROM '
                + soType.getDescribe().getName()
                + ' WHERE CreatedDate < LAST_N_DAYS:' + lastNDays;
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new ScheduleDelTranscriptRelated_Batch(ConversationContextEntry.SObjectType, 30));  
        Database.executeBatch(new ScheduleDelTranscriptRelated_Batch(LiveChatTranscriptEvent.SObjectType, 180));  
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.q); 
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        if (scope.isEmpty()) return;
        Database.DeleteResult[] deleteResultList = Database.delete(scope, false);
        logError(deleteResultList, scope[0].getSObjectType().getDescribe().getName());
    }

    public void finish(Database.BatchableContext BC) {

    }

    /*
    * Logs errors if there are any, returns true if there is an error
    */
    private static void logError(Database.DeleteResult[] deleteResultList, String objectType) {

        Loggingutility.createLog(ScheduleDelTranscriptRelated_Batch.class.getName(),
                'BATCH',
                'DELETE objectType',
                null
            );

        for (Database.DeleteResult res : deleteResultList) {

            if (!res.isSuccess()) {
                String errorMessages = '';
                for (Database.Error err : res.getErrors()) {
                    errorMessages += ' ' + err.getMessage();
                }

                LoggingUtility.logError(ScheduleDelTranscriptRelated_Batch.class.getName(), 
                                        String.format('Can not delete record {0}; Error message: {1}', new String[]{res.getId(), errorMessages})
                    );
            }
        }
        LoggingUtility.commitLogs();
    }

}
