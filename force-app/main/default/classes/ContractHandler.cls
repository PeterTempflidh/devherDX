/**
* @author g.singh
* @date 2019-04-30
* @description Trigger Handler for the Case SObject. This class implements the ITrigger
* interface to help ensure the trigger code is bulkified and all in one place.
*/
public with sharing class ContractHandler implements ITrigger {

    private List<Platform_Performance__c> platformPerformanceToUpdate;

    // Constructor
    public ContractHandler() {}

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
            ClsContractProcessor.processSwitchOpportunityContracts(Trigger.new);
            // publish to eventBus
            ClsContractProcessor.publishCommissionOnEventBus((List<Contract>)Trigger.new, (Map<Id,Contract>)Trigger.oldMap);
            // set platofrm status on platform performance object
            platformPerformanceToUpdate = ClsContractProcessor.setPlatformStatus((Map<Id, Contract>)Trigger.newMap);
        } else if(Trigger.isUpdate) {
            ClsContractProcessor.updateAccountDeliveryService((List<Contract>)Trigger.new);
            // publish to eventBus
            ClsContractProcessor.publishCommissionOnEventBus((List<Contract>)Trigger.new, (Map<Id,Contract>)Trigger.oldMap);
            // set platofrm status on platform performance object
            platformPerformanceToUpdate = ClsContractProcessor.setPlatformStatus((Map<Id, Contract>)Trigger.newMap);
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
        if (platformPerformanceToUpdate != null) {
            update platformPerformanceToUpdate;
        }
    }
}