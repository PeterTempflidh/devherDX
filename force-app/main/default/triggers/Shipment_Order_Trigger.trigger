/**
 * Created by w.novoa on 17.08.2018.
 */

trigger Shipment_Order_Trigger on Shipment_Order__c (after insert, before update,after update,before insert) {

    if (Trigger_Manager__c.getInstance().Deactivate_Shipment_Order_Trigger__c) return;

    TriggerFactory.createAndExecuteHandler(ClsShipmentOrderHandler.class);

    if(Trigger.isBefore && Trigger.isUpdate){
        ClsShipmentOrderProcessor.createAssets(trigger.oldMap,trigger.newMap);
    }
}