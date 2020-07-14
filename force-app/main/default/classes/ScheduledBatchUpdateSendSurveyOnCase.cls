/**
*  Created By - Chaitali Kumari
*  Date - 18.10.2018
*  Description - SP-2430, Scheduler for Batch to Send Survey flag on Case object.
*                This is scheduled to run every hour.
*   Below is the sample code to run the batch hourly---
*
*   String query = 'Select id,recordtype.developername, status,Date_Time_Resolved__c,Survey_Date__c, Send_Survey__c from Case where status = \'Resolved\' AND Survey_Date__c = null AND recordtype.developername = \'Talabat_Inbound_Case\' and  Send_Survey__c  != true and Date_Time_Resolved__c < ';
*   String CRON_EXP = '0 0 * * * ?';
*   ScheduledBatchUpdateSendSurveyOnCase sch = new ScheduledBatchUpdateSendSurveyOnCase();
*   sch.queryString = query;
*   sch.batchSize = 200;
*   system.schedule('Batch To Update SendSurvey Flag', CRON_EXP, sch);
**/

global class ScheduledBatchUpdateSendSurveyOnCase implements Schedulable{

    global String queryString{get;set;}
    global Integer batchSize{get;set;}

    global void execute(SchedulableContext SC){

        DateTime currentDateTime = DateTime.Now().addHours(-3);
        String actualTime = currentDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        BatchUpdateSendSurveyOnCase batch = new BatchUpdateSendSurveyOnCase(queryString+actualTime);
        Database.executeBatch(batch,batchSize);
    }
}