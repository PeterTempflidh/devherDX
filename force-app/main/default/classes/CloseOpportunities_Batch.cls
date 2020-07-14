/**
* @author Mantas Jurkunas
* @date 14.04.2020
*
* @description Batch class designed to close opportunities that are stuck in onboarding failed status for too long
*/
public with sharing class CloseOpportunities_Batch implements Database.Batchable<SObject>, Schedulable {
    /**
    * @description  Cron expression to run schedule daily
    */
    public static final String CRON_DAILY = '0 0 0 * * ? *';

    /**
    * @description method that initiates the batch schedule
    *
    * @param cron cron expression on how ofter to run the batch
    */
    public static void schedule(String cron) {
        // Checking if test to avoid AsyncException with duplicate names
        System.schedule('Auto-Close Opportunities' + (Test.isRunningTest() ? String.valueOf(System.currentTimeMillis()) : ''), cron, new CloseOpportunities_Batch());
    }

    /**
    * @description batch execute method
    *
    * @param param1 BatchableContext
    * @param opportunities queried opportunities
    */
    public void execute(Database.BatchableContext param1, List<Opportunity> opportunities) {
        CloseOpportunities_Utils batchUtils = CloseOpportunities_Utils.getInstance();
        List<Opportunity> opportunitiesToUpdate = batchUtils.checkFailedOpportunities(opportunities);
        batchUtils.updateOpportunities(opportunitiesToUpdate).commitLogs();
    }

    /**
    * @description finish method of batchable interface
    *
    * @param param1 BatchableContext
    */
    public void finish(Database.BatchableContext param1) {
    }

    /**
    * @description batch start method to query opportunities that are failed in onboarding and have specific business types
    *
    * @param param1 BatchableContext
    *
    * @return QueryLocator
    */
    public Database.QueryLocator start(Database.BatchableContext param1) {
        Set<String> processRecordTypes = LibBusinessConfig.getRecordTypesForProcess(CloseOpportunities_Utils.AUTO_CLOSE_PROCESS_NAME);
        final String baseQuery = 'SELECT {0} FROM Opportunity WHERE {1}';
        final List<String> fieldsToQuery = new List<String>{
                Opportunity.StageName.getDescribe().getLocalName(),
                Opportunity.Id.getDescribe().getLocalName(),
                Opportunity.Business_Type__c.getDescribe().getLocalName(),
                Opportunity.RecordTypeId.getDescribe().getLocalName()
        };
        String whereCondition = 'StageName = \'Onboarding Failed\' AND Business_Type__c IN (\'New Business\', \'Win Back\') AND RecordType.DeveloperName IN :processRecordTypes';
        final String databaseQuery = String.format(baseQuery, new List<String>{String.join(fieldsToQuery, ','), whereCondition});
        return Database.getQueryLocator(databaseQuery);
    }

    /**
    * @description execute method of shcedulable interface
    *
    * @param param1 SchedulableContext
    */
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new CloseOpportunities_Batch());
    }
}