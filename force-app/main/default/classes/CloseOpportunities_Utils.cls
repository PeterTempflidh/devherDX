/**
* @author Mantas Jurkunas
* @date 14.04.2020
*
* @description Utility class containing methods related to closing opportunities with failed onboarding
*/
public without sharing class CloseOpportunities_Utils {
    private static CloseOpportunities_Utils utilsInstance;
    private static final String LOG_NAME = 'CloseOpportunities';
    private static final String LOG_TYPE = 'LOGGING';
    private static final String LOG_SUBTYPE = 'CLose Lost Opportunities';
    /**
     * @description Business config process name
     */
    public static final String AUTO_CLOSE_PROCESS_NAME = 'OpportunityAutoClose';
    private static final String CASE_LIMIT = 'OnboardingFailedCaseLimit';
    private static final String FOLLOWUP_LIMIT = 'FailedOpportunitiesFollowupLimit';

    private CloseOpportunities_Utils() {
    }

    /**
    * @description get instance of the utility class
    *
    * @return instance of this class
    */
    public static CloseOpportunities_Utils getInstance() {
        if (utilsInstance == null) {
            utilsInstance = new CloseOpportunities_Utils();
        }
        return utilsInstance;
    }

    /**
    * @description Method checks if opportunity has reached the limit of onboarding failed cases and closes the opportunity.
    *
    * @param failedCases filtered cases with onboarding failed
    *
    * @return opportunities that have to be closed
    */
    public List<Opportunity> checkFailedOpportunities(List<Case> failedCases) {
        Set<Id> opportunityIds = ClsSObjectUtils.extractSetIds(failedCases, Case.Opportunity__c.getDescribe().getLocalName());
        List<Case> relatedCases = CaseSelector.getOnboardingFailedByOppIds(opportunityIds);
        if (relatedCases.isEmpty()) { return new List<Opportunity>(); }
        Map<Id, List<Case>> oppCaseMap = ClsSObjectUtils.convertToIdMap(relatedCases, Case.Opportunity__c.getDescribe().getLocalName());
        return filterOpportunitiesForUpdate(oppCaseMap);
    }

    /**
    * @description Checks opportunities that are stuck in onboarding failed for too long and closes them.
    *
    * @param opportunities records that are in status 'Onboarding Failed'
    *
    * @return opportunities that have to be closed
    */
    public List<Opportunity> checkFailedOpportunities(List<Opportunity> opportunities) {
        List<OpportunityFieldHistory> fieldHistories = getOpportunityFieldHistories(new Map<Id, Opportunity>(opportunities).keySet());
        if (fieldHistories.isEmpty()) { return new List<Opportunity>(); }
        Map<Id, List<OpportunityFieldHistory>> oppFieldHistoryMap = ClsSObjectUtils.convertToIdMap(fieldHistories, OpportunityFieldHistory.OpportunityId.getDescribe().getLocalName());
        return filterOpportunitiesForUpdate(opportunities, oppFieldHistoryMap);
    }

    private List<Opportunity> filterOpportunitiesForUpdate(Map<Id, List<Case>> relatedOppCaseMap) {
        Set<Opportunity> filteredOpportunities = new Set<Opportunity>();
        for (Id opportunityId: relatedOppCaseMap.keySet()) {
            List<Case> relatedCases = relatedOppCaseMap.get(opportunityId);
            Business_Config__c caseLimitConfig = LibBusinessConfig.getBusinessConfigFromRuleMap(AUTO_CLOSE_PROCESS_NAME, relatedCases.get(0).Opportunity__r.RecordTypeId, CASE_LIMIT);
            Boolean isCaseLimitNotReached = caseLimitConfig == null || relatedCases.size() < Integer.valueOf(caseLimitConfig.Business_Rule_Value__c);
            if (isCaseLimitNotReached) { continue; }
            Opportunity failedOpp = setOpportunityLost(new Opportunity(Id = opportunityId));
            filteredOpportunities.add(failedOpp);
        }
        return new List<Opportunity> (filteredOpportunities);
    }

    private List<Opportunity> filterOpportunitiesForUpdate(List<Opportunity> opportunities, Map<Id, List<OpportunityFieldHistory>> oppFieldHistoryMap) {
        List<Opportunity> filteredOpportunities = new List<Opportunity>();
        for (Opportunity opp: opportunities) {
            if (!oppFieldHistoryMap.containsKey(opp.Id)) { continue; }
            Business_Config__c followupLimitConfig = LibBusinessConfig.getBusinessConfigFromRuleMap(AUTO_CLOSE_PROCESS_NAME, opp.RecordTypeId, FOLLOWUP_LIMIT);
            Datetime historyDate = oppFieldHistoryMap.get(opp.Id).get(0).CreatedDate;
            // Check if test is running since created date cannot be set on the field history when testing
            Boolean isOpportunityNotExpired = followupLimitConfig == null || !Test.isRunningTest() && historyDate.date().daysBetween(Date.today()) <= Integer.valueOf(followupLimitConfig.Business_Rule_Value__c);
            if (isOpportunityNotExpired) { continue; }
            filteredOpportunities.add(setOpportunityLost(opp));
        }
        return filteredOpportunities;
    }

    /**
    * @description method updates opportunities and logs any errors while saving
    *
    * @param opportunities records to update
    *
    * @return class instance
    */
    public CloseOpportunities_Utils updateOpportunities(List<Opportunity> opportunities) {
        List<Database.SaveResult> saveResults = Database.update(opportunities, false);
        for (Integer index = 0; index < opportunities.size(); index++) {
            if (saveResults.get(index).isSuccess()) {
                continue;
            }
            String errorMessage = ClsSObjectUtils.getErrorString(saveResults.get(index), opportunities.get(index));
            if (String.isNotEmpty(errorMessage)) {
                LoggingUtility.createLog(LOG_NAME + index, LOG_TYPE, LOG_SUBTYPE, null);
                LoggingUtility.logError(LOG_NAME + index, errorMessage);
            }
        }
        return this;
    }

    /**
    * @description commit logs that were created throughout the process
    */
    public void commitLogs() {
        LoggingUtility.commitLogs(true);
    }

    private Opportunity setOpportunityLost(Opportunity opp) {
        opp.StageName = 'Closed Lost';
        opp.Lost_Reason__c = 'Onboarding Failed';
        return opp;
    }

    private List<OpportunityFieldHistory> getOpportunityFieldHistories(Set<Id> opportunityIds) {
        // Need to return mock data since field history cannot be inserted.
        if (Test.isRunningTest()) {
            return UnitTestDataFactory.createOpportunityFieldHistories(opportunityIds);
        }
        return OpportunityFieldHistory_Selector.getByOpportunityIds(opportunityIds);
    }
}