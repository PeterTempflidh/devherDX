/**
 *  Created By - Chaitali Kumari
 *  Date - 18.10.2018
 *  Desciption - SP-2430, Batch class to update Send Survey flag on Case object
 */

global class BatchUpdateSendSurveyOnCase implements Database.Batchable<sObject>{

    global final String Query;
    public BatchUpdateSendSurveyOnCase(String queryParam) {
       Query = queryParam;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator(Query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        List<sobject> listSObjectToUpdate = new List<sobject>();

        for(sobject sObjectRecord : scope){
            Schema.SObjectType sObjectType = scope.getSObjectType();

            sObjectRecord.put('Send_Survey__c',true);
            listSObjectToUpdate.add(sObjectRecord);
        }

        if(!listSObjectToUpdate.isEmpty()){
            List<Database.saveResult> saveUpdateResults = Database.update(listSObjectToUpdate);

            LoggingUtility.createLog('BatchUpdateSEndSurveyOCase','BATCH','Update Send Survey Flag',null);
            Boolean isError = false;
            for(Database.saveResult result : saveUpdateResults){
                if(!result.isSuccess()){
                    LoggingUtility.logError('BatchUpdateSEndSurveyOCase','BatchUpdateSEndSurveyOCase: Update failed for case ' + result.getId() +
                            ' Errors '  + result.getErrors() + '\n');
                    isError = true;
                }
            }

            // Do Logging in case of error.
            if(isError){
                LoggingUtility.commitLogs();
            }
        }

    }

    global void finish(Database.BatchableContext BC) {

    }

}