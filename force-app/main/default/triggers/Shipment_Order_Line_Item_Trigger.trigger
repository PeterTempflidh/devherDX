/**
 * Created by w.novoa on 07.09.2018.
 */

trigger Shipment_Order_Line_Item_Trigger on Shipment_Order_Line_Item__c (before insert, before update,after insert, after update) {
    if (Trigger_Manager__c.getInstance().Deactivate_Shipment_Order_Line_Trigger__c) return;

    TriggerFactory.createAndExecuteHandler(ClsShipmentOrderLineItemHandler.class);

}