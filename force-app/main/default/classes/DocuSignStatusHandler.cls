/**
* @author       : Delivery Hero SE (sundra.anand@deliveryhero.com)
* @date         : 21.01.2020
* @description  : Handler class for DocuSign Status Object
* @Test Class   : DocuSignUtilityController_Test
* @log          :
* -------------------------------------------------------------------------------------------------------------------------------
* Developer            Date       Description                                                                 version
* -------------------------------------------------------------------------------------------------------------------------------
* Sundra              21.01.2020   Newly created                                                                 V1.0

**/
public class DocuSignStatusHandler implements ITrigger {

    private List<Opportunity> opportunityList = new List<Opportunity>();
    private List<Opportunity_Quote__c> quoteList = new List<Opportunity_Quote__c>();

    // Constructor
    public DocuSignStatusHandler() {}

    /*******************************************************************************************************
    * @description This method is called for before trigger to process the records
    * @param none
    * @return null
    */
    public void bulkBefore() {
        if (Trigger.isInsert) {

        } else if (Trigger.isUpdate) {

        } else if (Trigger.isDelete) {

        }
    }

    /*******************************************************************************************************
    * @description This method is called for after trigger to process the records
    * @param none
    * @return null
    */
    public void bulkAfter() {
        if (Trigger.isInsert) {
            opportunityList = DocuSignStatus_Processor.sentEnvelopeUpdate((List<dsfs__DocuSign_Status__c>)Trigger.new);
            quoteList.addAll(DocuSignStatus_Processor.updateOpportunityQuote((List<dsfs__DocuSign_Status__c>)Trigger.new, null));
        } else if(Trigger.isUpdate) {
            quoteList = DocuSignStatus_Processor.declinedEnvelopeUpdate((List<dsfs__DocuSign_Status__c>)Trigger.new, (Map<Id,dsfs__DocuSign_Status__c>)Trigger.oldMap);
            quoteList.addAll(DocuSignStatus_Processor.updateOpportunityQuote((List<dsfs__DocuSign_Status__c>)Trigger.new,( Map<Id, dsfs__DocuSign_Status__c>)Trigger.oldMap));
            opportunityList.addAll(DocuSignStatus_Processor.updateOpportunity((Map<Id, dsfs__DocuSign_Status__c>)Trigger.newMap,( Map<Id, dsfs__DocuSign_Status__c>)Trigger.oldMap));

        } else if(Trigger.isDelete) {

        }
    }

    /*******************************************************************************************************
    * @description to process individual record in a before insert trigger. This method should be called inside a loop.
    * Database operations should not be performed in the method
    * @param SObject An SObject record.
    * @return null
    */
    public void beforeInsert(SObject so) {}

    /*******************************************************************************************************
    * @description to process individual record in a before update trigger. This method should be called inside a loop.
    * Database operations should not be performed in the method
    * @param SObject An SObject record.
    * @return null
    */
    public void beforeUpdate(SObject oldSo, SObject so){}

    /*******************************************************************************************************
    * @description to process individual record in a before delete trigger. This method should be called inside a loop.
    * Database operations should not be performed in the method
    * @param SObject An SObject record.
    * @return null
    */
    public void beforeDelete(SObject so) {}

    /*******************************************************************************************************
    * @description to process individual record in a after insert trigger. This method should be called inside a loop.
    * Database operations should not be performed in the method
    * @param SObject An SObject record.
    * @return null
    */
    public void afterInsert(SObject so) {}

    /*******************************************************************************************************
    * @description to process individual record in after update trigger. This method should be called inside a loop.
    * Database operations should not be performed in the method
    * @param SObject An SObject record.
    * @return null
    */
    public void afterUpdate(SObject oldSo, SObject so) {}

    /*******************************************************************************************************
    * @description to process individual record in after delete trigger. This method should be called inside a loop.
    * Database operations should not be performed in the method
    * @param SObject An SObject record.
    * @return null
    */
    public void afterDelete(SObject so) {}

    /*******************************************************************************************************
    * @description This method is called once all records have been processed by the trigger. Use this
    * method to accomplish any final operations such as creation or updates of other records.
    * @param none
    * @return null
    */
    public void andFinally() {

        if(!opportunityList.isEmpty()) {
            upsert opportunityList;
        }

        if(!quoteList.isEmpty()) {
            upsert quoteList;
        }

    }

}