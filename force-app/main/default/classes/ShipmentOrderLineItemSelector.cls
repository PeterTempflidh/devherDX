/**
 * Created by w.novoa on 30.08.2019.
 */

public inherited sharing class ShipmentOrderLineItemSelector {
    public static map<Id, Shipment_Order_Line_Item__c> getShipmentLineItemsByOrder(set<Id> ShipmentOrderIds) {
        map<Id, Shipment_Order_Line_Item__c> mpShipmentOrderLineItems = new map<Id, Shipment_Order_Line_Item__c>();

        try {
            mpShipmentOrderLineItems = new map<Id, Shipment_Order_Line_Item__c>([select id,
                                                                                        Shipment_Order__c,
                                                                                        Opportunity_Quote_Line_Item__c,
                                                                                        Serial_Number__c,
                                                                                        Quantity__c ,
                                                                                        Shipment_Order__r.Status__c,
                                                                                        Stock_Item__c,
                                                                                        Name ,
                                                                                        Opportunity_Quote_Line_Item__r.id_list_product_price__r.Requires_Asset__c,
                                                                                        Opportunity_Quote_Line_Item__r.id_list_product_price__r.Product_Type__c
                                                                                from Shipment_Order_Line_Item__c
                                                                                where Shipment_Order__c IN : ShipmentOrderIds
                                                                                Order by Shipment_Order__c]);
        } catch (Exception e) {
            System.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }

        return mpShipmentOrderLineItems;

    }


}