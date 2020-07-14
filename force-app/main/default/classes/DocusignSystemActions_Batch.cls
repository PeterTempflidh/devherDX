/**
* @author Mantas Jurkunas
* @date 28.04.20
*
* @description Batch class responsible for creating tasks for Sales people, according to business requirements.
 * Dependant business config: DocuSignSystemActions
*/
public with sharing class DocusignSystemActions_Batch implements Database.Batchable<SObject>, Schedulable {

    /**
     * @description Schedule the job according to provided cron string
     * @param cron cron string
    */
    public static void schedule(String cron) {
        System.schedule('DocuSign System Actions Batch' + (Test.isRunningTest() ? String.valueOf(System.currentTimeMillis()) : ''), cron, new DocusignSystemActions_Batch());
    }

    /**
     * @description Schedulable execute method
     * @param param1 Schedulable context
    */
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new DocusignSystemActions_Batch());
    }

    /**
     * @description Batch execute method that processes DocuSign status records
     * @param param1 batchable context
     * @param docuSignStatuses statuses to be processed
    */
    public void execute(Database.BatchableContext param1, List<dsfs__DocuSign_Status__c> docuSignStatuses) {
        DocusignSystemActions_Utils systemActionsUtils = new DocusignSystemActions_Utils();
        systemActionsUtils.filterData(docuSignStatuses).createTasks().insertRecords();
    }

    /**
     * @description Batch finish method
     * @param param1 batchable context
    */
    public void finish(Database.BatchableContext param1) {
    }

    /**
     * @description Batch start method, that queries DocuSign statuses that are belong to the DocuSignSystemActions process
     * @param param1 batchable context
     * @return query locator
    */
    public Database.QueryLocator start(Database.BatchableContext param1) {
        Set<String> processRecordTypes = LibBusinessConfig.getRecordTypesForProcess(DocusignSystemActions_Utils.PROCESS_NAME);
        return Database.getQueryLocator([
            SELECT dsfs__Sent_Age__c, dsfs__Envelope_Status__c, Opportunity_Quote__c,
                    Opportunity_Quote__r.RecordTypeId,
                    Opportunity_Quote__r.Id_Opportunity__r.Owner.Email,
                    Opportunity_Quote__r.RecordType.DeveloperName
            FROM dsfs__DocuSign_Status__c
            WHERE (dsfs__Envelope_Status__c = :DocusignSystemActions_Utils.ENVELOPE_SENT
            OR dsfs__Envelope_Status__c = :DocusignSystemActions_Utils.ENVELOPE_DELIVERED )
            AND Opportunity_Quote__r.RecordType.DeveloperName IN :processRecordTypes
            AND Opportunity_Quote__r.Id_Opportunity__r.LeadSource = 'Inbound'
        ]);
    }

}