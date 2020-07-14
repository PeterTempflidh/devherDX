/**
* @author Sundra Anand
* @date 05.03.2020
*
* @description Selector class for retrieving DocuSignStatus records
*/
public class DocuSignStatus_Selector {
	
    /*******************************************************************************************************
    * @description Query DocuSignStatus records
    * @param List of DocuSignStatus
    * @return List of DocuSignStatus
    */
    public static List<dsfs__DocuSign_Status__c> getDocuSignStatusbyIds(List<dsfs__DocuSign_Status__c> envelopeList) {

        List<dsfs__DocuSign_Status__c> DocuSignStatus = new List<dsfs__DocuSign_Status__c>();

        try {
            DocuSignStatus = [SELECT Id, Opportunity_Quote__c, dsfs__Envelope_Status__c, Opportunity_Quote__r.Id_Opportunity__c, Opportunity_Quote__r.Status__c,
                              Opportunity_Quote__r.RecordTypeId, dsfs__Sent_Age__c, Opportunity_Quote__r.Id_Opportunity__r.Email_Path__c,
                              Opportunity_Quote__r.Id_Opportunity__r.StageName,dsfs__Declined_Reason__c, dsfs__Voided_Reason__c
                              FROM dsfs__DocuSign_Status__c
                              WHERE Id IN : envelopeList
                              AND Opportunity_Quote__r.Status__c NOT IN ('Accepted','Declined')
                             ];
        } catch (Exception e) {
            System.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return  DocuSignStatus;
    }
    
    /*******************************************************************************************************
    * @description Query DocuSignStatus records based on quote Id.
    * @param  Set of Opportunity Quote Ids
    * @return List of DocuSignStatus
    */
    public static List<dsfs__DocuSign_Status__c> getDocuSignStatusbyQuoteIds(Set<Id> quoteIds) {

        List<dsfs__DocuSign_Status__c> DocuSignStatus = new List<dsfs__DocuSign_Status__c>();

        try {
            DocuSignStatus = [SELECT Id, Opportunity_Quote__c, Opportunity_Quote__r.RecordTypeId, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c WHERE Opportunity_Quote__c IN : quoteIds];
        } catch (Exception e) {
            System.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return  DocuSignStatus;
    }

    /*******************************************************************************************************
    * @description Query Active DocuSignStatus records based on quote.
    * @param  Set of Opportunity Quote Ids
    * @return Map<Id,dsfs__DocuSign_Status__c>
    */
    public static Map<Id,dsfs__DocuSign_Status__c> getActiveEnvelopeForQuote(List<dsfs__DocuSign_Status__c> envelopeList) {

        Map<Id,dsfs__DocuSign_Status__c> activeEnvelopeMap = new Map<Id,dsfs__DocuSign_Status__c>();
        Set<Id> quoteIdSet = new Set<Id>();

        try {
            for(dsfs__DocuSign_Status__c ds : envelopeList) {
                quoteIdSet.add(ds.Opportunity_Quote__c);
            }

            for(dsfs__DocuSign_Status__c dst : getDocuSignStatusbyQuoteIds(quoteIdSet)) {
                if(dst.dsfs__Envelope_Status__c != 'Voided') {
                    activeEnvelopeMap.put(dst.Opportunity_Quote__c,dst);
                }
            }
        } catch (Exception e) {
            System.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return  activeEnvelopeMap;
    }

    /**
     * @description Get docusign recipient statuses that were Viewed N days ago and belong to provided DocuSign statuses
     *  and were not sent to the opportunity owner. The N amount of days are described in the business config process DocuSignSystemActions
     *  @param statuses docusign statuses that are in status Delivered
     *  @return DocuSign recipient statuses that were Viewed N days ago
    */
    public static List<dsfs__DocuSign_Recipient_Status__c> getDeliveredExcludingOpportunityOwnerEmail(List<dsfs__DocuSign_Status__c> statuses){
        List<dsfs__DocuSign_Recipient_Status__c> recipientStatuses = new List<dsfs__DocuSign_Recipient_Status__c>();
        Set<String> opportunityOwnerEmails = ClsSObjectUtils.extractSetStrings(statuses, 'Opportunity_Quote__r.Id_Opportunity__r.Owner.Email');
        Map<String, Integer> recordTypeDeliveredAgeMap = getRecordTypeDeliveredAgeMap();
        if (recordTypeDeliveredAgeMap.isEmpty()) {
            return recipientStatuses;
        }
        final String deliveryAgeCondition = buildDeliveredAgeCondition(recordTypeDeliveredAgeMap);
        final String docuSignParentStatusQuery = 'SELECT Id, dsfs__Parent_Status_Record__c, dsfs__Parent_Status_Record__r.Opportunity_Quote__r.RecordType.DeveloperName,' +
                ' dsfs__Parent_Status_Record__r.Opportunity_Quote__r.RecordTypeId' +
                ' FROM dsfs__DocuSign_Recipient_Status__c' +
                ' WHERE dsfs__DocuSign_Recipient_Email__c NOT IN :opportunityOwnerEmails AND dsfs__Parent_Status_Record__c IN :statuses AND (' +
                deliveryAgeCondition + ')';
        try {
            recipientStatuses = Database.query(docuSignParentStatusQuery);
        } catch (QueryException e) {
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }
        return recipientStatuses;
    }

    private static Map<String, Integer> getRecordTypeDeliveredAgeMap() {
        Map<String, Integer> rcDeliveredAgeMap = new Map<String, Integer>();
        Map<String, Map<String, Business_Config__c>> businessRulesMap = LibBusinessConfig.motherOfAllBusinessMaps.get(DocusignSystemActions_Utils.PROCESS_NAME);
        for (String recordTypeName : businessRulesMap.keySet()) {
            if (!businessRulesMap.get(recordTypeName).containsKey(DocusignSystemActions_Utils.RULE_DELIVERED_AGE)) {
                continue;
            }
            rcDeliveredAgeMap.put(recordTypeName, Integer.valueOf(businessRulesMap.get(recordTypeName).get(DocusignSystemActions_Utils.RULE_DELIVERED_AGE).Business_Rule_Value__c));
        }
        return rcDeliveredAgeMap;
    }

    private static String buildDeliveredAgeCondition(Map<String, Integer> recordTypeDeliveredAgeMap) {
        final String baseCondition = '(dsfs__Parent_Status_Record__r.Opportunity_Quote__r.RecordType.DeveloperName = \'\'{0}\'\' AND DAY_ONLY(dsfs__Date_Delivered__c) = {1})';
        List<String> conditionList = new List<String>();
        for (String recordTypeName: recordTypeDeliveredAgeMap.keySet()) {
            Date deliveredDate = Date.today().addDays(recordTypeDeliveredAgeMap.get(recordTypeName) * -1);
            String formattedDate = Datetime.newInstance(deliveredDate.year(), deliveredDate.month(), deliveredDate.day()).format('yyyy-MM-dd');
            conditionList.add(String.format(baseCondition, new List<Object>{recordTypeName, formattedDate}));
        }
        return String.join(conditionList, ' OR ');
    }
       
}