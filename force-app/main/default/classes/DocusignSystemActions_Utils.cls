/**
* @author Mantas Jurkunas
* @date 28.04.20
*
* @description Utility class for DocuSignSystemActions_Batch.
 * This class is responsible for creating tasks for Sales people, according to business requirements.
 * Dependant business config: DocuSignSystemActions
*/
public with sharing class DocusignSystemActions_Utils {
    /**
     * @description DocuSign_Status status
    */
    public static final String ENVELOPE_SENT = 'Sent';
    /**
     * @description DocuSign_Status status
    */
    public static final String ENVELOPE_DELIVERED = 'Delivered';
    /**
     * @description Business config Process name
    */
    public static final String PROCESS_NAME = 'DocuSignSystemActions';
    /**
     * @description Business Config rule name for after how many days in sent stage task should be created
    */
    public static final String RULE_SENT_AGE = 'SentAge';
    /**
     * @description Business Config rule name for after how many days in viewed stage task should be created
    */
    public static final String RULE_DELIVERED_AGE = 'ViewedAge';
    private final List<dsfs__DocuSign_Status__c> sentDocuSignStatuses;
    private List<dsfs__DocuSign_Status__c> deliveredDocuSignStatuses;
    private List<Task> taskToBeInserted;

    /**
     * @description constructor to initialise status lists
    */
    public DocusignSystemActions_Utils() {
        sentDocuSignStatuses = new List<dsfs__DocuSign_Status__c>();
        deliveredDocuSignStatuses = new List<dsfs__DocuSign_Status__c>();
    }

    /**
     * @description filters data based on status and rule criteria defined in business configs
     * @param statuses unfiltered list of statuses
     * @return return instance of this class for method chaining
    */
    public DocusignSystemActions_Utils filterData(final List<dsfs__DocuSign_Status__c> statuses) {
        for (dsfs__DocuSign_Status__c status : statuses) {
            if (status.dsfs__Envelope_Status__c.equals(ENVELOPE_SENT) && isExceedingSentAge(status)) {
                sentDocuSignStatuses.add(status);
            } else if (status.dsfs__Envelope_Status__c.equals(ENVELOPE_DELIVERED)) {
                deliveredDocuSignStatuses.add(status);
            }
        }
        return filterInternalData();
    }

    /**
     * @description create tasks for filtered DocuSign statuses, based on declaration in Business Config
     * @return return instance of this class for method chaining
    */
    public DocusignSystemActions_Utils createTasks() {
        this.taskToBeInserted = new List<Task>();
        Integer sentSize = sentDocuSignStatuses.size();
        Integer deliveredSize = deliveredDocuSignStatuses.size();
        Integer loopSize = sentSize > deliveredSize? sentSize: deliveredSize;
        for (Integer index = 0; index < loopSize; index++) {
            if (index < sentSize) {
                taskToBeInserted.add(createTask(sentDocuSignStatuses.get(index), TaskType.ENVELOPE_SENT));
            }
            if (index < deliveredSize) {
                taskToBeInserted.add(createTask(deliveredDocuSignStatuses.get(index), TaskType.ENVELOPE_DELIVERED));
            }
        }
        return this;
    }

    private Task createTask(dsfs__DocuSign_Status__c docuSignStatus, TaskType taskType) {
        Task callTask = getTaskFromBusinessConfig(docuSignStatus.Opportunity_Quote__r.RecordTypeId, taskType);
        callTask.WhatId = docuSignStatus.Opportunity_Quote__r.Id_Opportunity__c;
        callTask.OwnerId = docuSignStatus.Opportunity_Quote__r.Id_Opportunity__r.OwnerId;
        return callTask;
    }

    /**
     * @description insert all the created task records
    */
    public void insertRecords() {
        if (taskToBeInserted == null || taskToBeInserted.isEmpty()) {
            return;
        }
        insert taskToBeInserted;
    }

    private Task getTaskFromBusinessConfig(String recordTypeId, TaskType type) {
        String configRuleName = type == TaskType.ENVELOPE_SENT ? 'SentTask' : 'DeliveredTask';
        Business_Config__c systemConfig = LibBusinessConfig.getBusinessConfigFromRuleMap(PROCESS_NAME, recordTypeId, configRuleName);
        Task callTask = (Task) JSON.deserialize(systemConfig.Business_Rule_Value__c, Task.class);
        return callTask;
    }

    private Boolean isExceedingSentAge(dsfs__DocuSign_Status__c docuSignStatus) {
        Id recordTypeId = docuSignStatus.Opportunity_Quote__r.RecordTypeId;
        Business_Config__c ageSystemConfig = LibBusinessConfig.getBusinessConfigFromRuleMap(PROCESS_NAME, recordTypeId, RULE_SENT_AGE);
        if (ageSystemConfig == null) {
            return false;
        }
        return Integer.valueOf(ageSystemConfig.Business_Rule_Value__c) == docuSignStatus.dsfs__Sent_Age__c;
    }

    private DocusignSystemActions_Utils filterInternalData() {
        deliveredDocuSignStatuses = filterDeliveredStatuses(deliveredDocuSignStatuses);
        return this;
    }

    private List<dsfs__DocuSign_Status__c> filterDeliveredStatuses(final List<dsfs__DocuSign_Status__c> statuses) {
        List<dsfs__DocuSign_Status__c> filteredList = new List<dsfs__DocuSign_Status__c>();
        List<dsfs__DocuSign_Recipient_Status__c> recipientStatuses = DocuSignStatus_Selector.getDeliveredExcludingOpportunityOwnerEmail(statuses);
        if (recipientStatuses.isEmpty()) {
            return filteredList;
        }
        Set<String> statusIds = ClsSObjectUtils.extractSetStrings(recipientStatuses, dsfs__DocuSign_Recipient_Status__c.dsfs__Parent_Status_Record__c.getDescribe().getLocalName());
        Set<Object> statusIdsObjects =  new Set<Object>();
        for (String statusId: statusIds) {
            statusIdsObjects.add(statusId);
        }
        filteredList = ClsSObjectUtils.filterFieldValues(statuses, new Map<String, Set<Object>> {
                dsfs__DocuSign_Status__c.Id.getDescribe().getLocalName() => statusIdsObjects
        });
        return filteredList;
    }

    private enum TaskType {
        ENVELOPE_SENT,
        ENVELOPE_DELIVERED
    }
}