/**
* @author Mantas Jurkunas
* @date 15.07.2019
*
* @description Batch to perform data remediation on Commission, Opportunity_Line_Item and Opportunity_Quote_Line_Item - Based_On__c, Commission_Type__c fields
*/

public with sharing class CommissionRemediation_Batch implements Database.Batchable<SObject>, Database.Stateful {
    private final Type batchType;
    private List<String> queryFields;
    private String recordType;
    private Boolean allOrNothing;

    public CommissionRemediation_Batch(Type batchType) {
        this(batchType, null, true);
    }

    public CommissionRemediation_Batch(Type batchType, String opportunityRecordType) {
        this(batchType, opportunityRecordType, true);
    }

    public CommissionRemediation_Batch(Type batchType, String opportunityRecordType, Boolean stopOnException) {
        this.batchType = batchType;
        this.recordType = opportunityRecordType;
        allOrNothing = stopOnException;
    }

    public void execute(Database.BatchableContext batchableContext, List<SObject> objectList) {
        for (SObject value: objectList) {
            value.put('Based_On__c', ClsSObjectUtils.getFieldValue(value, queryFields.get(1)));
            value.put(queryFields.get(0), ClsSObjectUtils.getFieldValue(value, queryFields.get(2)));
            value.put('Scaled__c', ClsSObjectUtils.getFieldValue(value, queryFields.get(3)));
        }
        Database.update(objectList, allOrNothing);
    }

    public void finish(Database.BatchableContext batchableContext) {
    }

    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        String databaseQuery = 'SELECT Id, Based_On__c, Scaled__c, {0}, {1}, {2}, {3} FROM ' + batchType.toString() + ' WHERE ({1} != NULL OR {2} != NULL OR {3} != NULL) AND Based_On__c = NULL AND {0} = NULL';
        if (batchType.equals(Opportunity_Line_Item__c.class) || batchType.equals(Opportunity_Quote_Line_Item__c.class)) {
            queryFields = new List<String>{'Commission_Type_Picklist__c', 'Id_List_Service_Price__r.Based_On__c', 'Id_List_Service_Price__r.Commission_Type__c', 'Id_List_Service_Price__r.Scaled__c'};
        } else if (batchType.equals(Contract.class)) {
            queryFields = new List<String>{'Commission_Type__c', 'Id_Opportunity_Quote_Line_Item__r.Id_List_Service_Price__r.Based_On__c', 'Id_Opportunity_Quote_Line_Item__r.Id_List_Service_Price__r.Commission_Type__c', 'Id_Opportunity_Quote_Line_Item__r.Id_List_Service_Price__r.Scaled__c'};
        } else {
            throw new CommissionRemediationException('Invalid object type');
        }
        if (recordType != null) {
            databaseQuery = databaseQuery + ' AND Id_Opportunity__r.RecordType.DeveloperName = :recordType';
        }
        return Database.getQueryLocator(String.format(databaseQuery, queryFields));
    }

    @TestVisible
    private class CommissionRemediationException extends Exception { }
}