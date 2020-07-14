/**
 * Created by w.novoa on 07.09.2018.
 */

public without sharing class ClsShipmentOrderLineItemHelper {

    /*** @Description: This method send the Shipment Order line from the Trigger and call the Queable class
            @Process		: General
              @Input Params	: List Shipment Order Line Item
              @Return		:
    */
    public Static Boolean isBatchProcess ; // if the excution comes from the batch process it's not necesary sent it again because is redundat


    /**
  * @Description: This method assing the status of the stock items depending of the shipmentlineorderlineitem
         @Process		: General
           @Input Params	: new and old value of the shipment order line item.
           @Return		:
 */
    static public List<Stock_Item__c> AssignStockItemStatus(Shipment_Order_Line_Item__c shipmentOrderLineItem,Shipment_Order_Line_Item__c shipmentOrderLineItemOld ){

        List<Stock_Item__c> lstStockItem = new List<Stock_Item__c>();
        if(shipmentOrderLineItem.Stock_Item__c != shipmentOrderLineItemOld.Stock_Item__c){
            if(shipmentOrderLineItem.Stock_Item__c!= null){
                lstStockItem.add(new Stock_Item__c(id= shipmentOrderLineItem.Stock_Item__c , Status__c = 'Assigned'));
            }
            if(shipmentOrderLineItemOld.Stock_Item__c!= null){
                lstStockItem.add(new Stock_Item__c(id= shipmentOrderLineItemOld.Stock_Item__c , Status__c = 'In Stock'));
            }
        }
        return lstStockItem;
    }

    public static List<Asset__c> CopyStockItemToAsset(List<Shipment_Order_Line_Item__c> soliNew, Map<Id, Shipment_Order_Line_Item__c> soliOldMap) {
        Map<Id, Asset__c> soliAssets = AssetSelector.getAssetsMapForShipmentOrderLineItems(soliOldMap.keySet());
        for(Shipment_Order_Line_Item__c soli : soliNew) {
            if(soliAssets.get(soli.Id) != null && soliOldMap.get(soli.Id) != null && soli.Stock_Item__c != soliOldMap.get(soli.Id).Stock_Item__c) {
                soliAssets.get(soli.Id).Stock_Item__c = soli.Stock_Item__c;
            }
        }
        
        return soliAssets.values();
    }

}