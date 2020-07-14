/**
 * Created by w.novoa on 04.09.2019.
 */

public without sharing class ClsShipmentOrderLineItemHandler implements ITrigger{

    private list<Stock_Item__c> lstStockItemsUpdate	= new list<Stock_Item__c>();
    private List<Asset__c> updatedAssets;
    
    public void bulkBefore() {

    }

    public void bulkAfter() {
        if(Trigger.oldMap != null) {
            updatedAssets = ClsShipmentOrderLineItemHelper.CopyStockItemToAsset((List<Shipment_Order_Line_Item__c>)Trigger.new, (Map<Id, Shipment_Order_Line_Item__c>)Trigger.oldMap);
        }
    }

    public void beforeInsert(SObject so) {

    }

    public void beforeUpdate(SObject oldSo, SObject so) {

    }

    public void beforeDelete(SObject so) {
    }

    public void afterInsert(SObject so) {
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        lstStockItemsUpdate.addAll(ClsShipmentOrderLineItemHelper.AssignStockItemStatus((Shipment_Order_Line_Item__c)so,(Shipment_Order_Line_Item__c)oldSo));
        system.debug('lstStockItemsUpdate-->'+lstStockItemsUpdate);
    }

    public void afterDelete(SObject so) {
    }

    public void andFinally() {
        update lstStockItemsUpdate;
        if(updatedAssets != null) {
            update updatedAssets;
        }
    }

}