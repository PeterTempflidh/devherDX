/**
* @Description: This batch updates the send survey flag on Onboarding Cases after 7 days of closure.
*/
global class BatchOnboardingSendSurvey implements Database.Batchable<sObject>,Schedulable{
    public String recordTypes;
    public String caseStatus;
    public String caseClosedReason;
    public Integer numberOfDays;
    private Map<String, Map<String, Map<String, Business_Config__c>> > moam =
            LibBusinessConfig.motherOfAllBusinessMaps;
    private static Map<String, Business_Config__c> mapBusinessRules;

    public BatchOnboardingSendSurvey(){
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('BatchOnboardingSurvey');
        if(mapBusinessLogic != null){
            mapBusinessRules 	= mapBusinessLogic.get('Global_Config');
            if(mapBusinessRules != null) {
                if(mapBusinessRules.ContainsKey('recordTypes')){
                    recordTypes = mapBusinessRules.get('recordTypes').Business_rule_Value__c;
                }
                if(mapBusinessRules.ContainsKey('numberOfDays')){
                    numberOfDays = Integer.valueOf(mapBusinessRules.get('numberOfDays').Business_Rule_Value__c);
                }
                if(mapBusinessRules.ContainsKey('closedReason')){
                    caseClosedReason = mapBusinessRules.get('closedReason').Business_Rule_Value__c;
                }
                if(mapBusinessRules.ContainsKey('Status')){
                    caseStatus = mapBusinessRules.get('Status').Business_Rule_Value__c;
                }
            }
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        Date resolvedDate;
        Id recordTypeId;
        If(numberOfDays != null) {
            resolvedDate = Date.today().addDays(-numberOfDays);
        }
        If(recordTypes != null) {
            recordTypeId = LibRecordTypeHelper.getRecordTypeValue(recordTypes);
        }

        return Database.getQueryLocator([SELECT Id,Status,
        RecordTypeId,ClosedDate,Closed_Reason__c,Send_Survey__c
        FROM CASE
        WHERE RecordTypeId = :recordTypeId
        AND ClosedDate < :resolvedDate
        AND Status = :caseStatus
        AND Closed_Reason__c = :caseClosedReason
        AND Send_Survey__c = false]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Case> casesTobeClosed = (List<Case>)scope;
        for(Case cs : casesToBeClosed){
            cs.Send_Survey__c = true;
        }

        // In case of failure perform partial update
        List<Database.saveResult> results = Database.update(casesTobeClosed,false);
        LoggingUtility.createLog('BatchOnboardingSendSurvey','BATCH','CASE Onboarding Survey',null);
        Boolean isError = false;
        for(Database.saveResult result : results){
            if(!result.isSuccess()){
                LoggingUtility.logError('BatchOnboardingSendSurvey','BatchOnboardingSendSurvey: Update failed for case ' + result.getId() +
                        ' Errors '  + result.getErrors() + '\n');
                System.debug(Logginglevel.ERROR,'BatchOnboardingSendSurvey: Update failed for case ' + result.getId() +
                        ' Errors '  + result.getErrors());
                isError = true;
            }
        }

        // Do Logging in case of error.
        if(isError){
            LoggingUtility.commitLogs();
        }

    }

    global void finish(Database.BatchableContext BC) {

    }

    // Scheduler for the batch
    global void execute(SchedulableContext sc) {
        BatchOnboardingSendSurvey batch = new BatchOnboardingSendSurvey();
        Database.executebatch(batch);
    }
}