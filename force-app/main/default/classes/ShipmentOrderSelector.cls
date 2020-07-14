/**
 * Created by w.novoa on 11.09.2019.
 */

public inherited sharing class ShipmentOrderSelector {
    public static List<Shipment_Order__c> getShipmentOrderbyTracking(Set<String> trackingNumbers) {
        List<Shipment_Order__c> shipmentOrders = [SELECT id,Tracking_Number__c,account__c,Aftership_ID__c,Tracking_Active__c,
                Last_Tracking_Update__c,Tracking_Exception__c,Shipping_Company__c
                FROM Shipment_Order__c
                WHERE Tracking_Number__c in : trackingNumbers
                AND Aftership_ID__c = null
                AND status__c = 'Shipped'
                AND tracking_active__c=false];
        return shipmentOrders;

    }

    public static List<Shipment_Order__c> getShipmentOrderActivebyTracking(String trackingNumber, String aftershipId) {
        List<Shipment_Order__c> shipmentOrders = [select id,
                                                            status__c,
                                                            tracking_number__c,
                                                            Last_Tracking_Update__c,
                                                            Date_Shipped__c,
                                                            Tracking_Exception__c,
                                                            tracking_active__c
                                                    from Shipment_Order__c
                                                    where tracking_active__c = true
                                                    and tracking_number__c =: trackingNumber
                                                    and aftership_id__c =:aftershipId];

        return shipmentOrders;

    }


    /*******************************************************************************************************
    * @description Query for get shipment order by Id with line items
    * @param  shipmentID shipment order Id
    * @return Shipment_Order__c
    */

    public static Shipment_Order__c getShipmentOrderbyIdWithLineItems(id shipmentID) {
        Shipment_Order__c shipmentOrder = [select Account__c,
                                                            Opportunity__c,
                                                            Opportunity_Quote__c,
                                                            is_cloned__c,
                                                            Status__c, (
                                                            select id,Name,
                                                                    Opportunity_Quote_Line_Item__c,
                                                                    List_Product_Price__c,
                                                                    SKU__c
                                                            from shipment_order_line_items__r
                                                    )
                                                    FROM Shipment_Order__c
                                                    WHERE id = :shipmentID
                                                    ];
        return shipmentOrder;

    }

    /*******************************************************************************************************
    * @description Query for get all open shipment orders for account Id
    * @param  accountId account Id
    * @return List<Shipment_Order__c>
    */
    public static List<Shipment_Order__c> getOpenShipmentOrdersForAccount(Id accountId) {
        return [SELECT Id, Status__c, Type__c, Account__c
                FROM Shipment_Order__c
                WHERE Account__c = :accountId
                AND Status__c = 'Open'];
    }
    /**
* @Description: Query to return shipment orders against account
  @Params       : Set of Account Ids
  @Return       : Map of Shipment Orders against Account
 */
    public static Map<Id,List<Shipment_Order__c>> getShipmentOrdersForAccount(Set<Id> setOfAccount) {

        Map<Id,List<Shipment_Order__c>> mapOfShipmentOrders = new Map<Id,List<Shipment_Order__c>>();
        for(Shipment_Order__c iShipmentOrder :[SELECT Id, Account_Country__c,Account__c
                                            FROM Shipment_Order__c WHERE
                                            Account__c IN : setOfAccount
                                            LIMIT : Limits.getLimitDMLRows()]){

            if(mapOfShipmentOrders.containsKey(iShipmentOrder.Account__c)){
                mapOfShipmentOrders.get(iShipmentOrder.Account__c).add(iShipmentOrder);
                continue;
            }
            mapOfShipmentOrders.put(iShipmentOrder.Account__c, new List<Shipment_Order__c> { iShipmentOrder });
        }
        return mapOfShipmentOrders;
    }
}