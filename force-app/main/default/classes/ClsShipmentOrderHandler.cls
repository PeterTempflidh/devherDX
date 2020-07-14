/**
 * Created by w.novoa on 30.08.2019.
 */

public without sharing class ClsShipmentOrderHandler implements ITrigger{
    private map<Id, List<Shipment_Order_Line_Item__c>> mpShipmentOrderLineItemsByOrder	= new map<Id, List<Shipment_Order_Line_Item__c>>();
    public void bulkBefore() {
        if(trigger.isInsert){
            ClsShipmentOrderProcessor.updateAccountCountry(Trigger.New,null);
        }
        if(trigger.isUpdate){
            map<Id,Shipment_Order_Line_Item__c>  mpShipmentOrderLineItems = ShipmentOrderLineItemSelector.getShipmentLineItemsByOrder( Trigger.newMap.keySet());
            mpShipmentOrderLineItemsByOrder = ClsShipmentOrderProcessor.groupShipmentLineItems(mpShipmentOrderLineItems);
            ClsShipmentOrderProcessor.updateAccountCountry(Trigger.New,Trigger.oldMap);
        }
    }

    public void bulkAfter() {
        if (trigger.isUpdate) {
            ClsShipmentOrderProcessor.updateReplacementAssetStatus((map<Id, Shipment_Order__c>) Trigger.oldMap, (map<Id, Shipment_Order__c>) Trigger.newMap);
        }
    }

    public void beforeInsert(SObject so) {

    }

    public void beforeUpdate(SObject oldSo, SObject so) {
        ClsShipmentOrderProcessor.validateShipmentOrders(mpShipmentOrderLineItemsByOrder,(Shipment_Order__c)oldSo,(Shipment_Order__c) so);
    }

    public void beforeDelete(SObject so) {
    }

    public void afterInsert(SObject so) {
    }

    public void afterUpdate(SObject oldSo, SObject so) {
    }

    public void afterDelete(SObject so) {
    }

    public void andFinally() {

    }


}
