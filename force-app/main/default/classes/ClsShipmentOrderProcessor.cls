/**
 * Created by w.novoa on 17.08.2018.
 */

public without  sharing class ClsShipmentOrderProcessor {

    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    private static Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('ShipmentOrders');



    /**
     @Description: This method created the assets when the Shipment is delivered.// SP-2414
         @Process		    : General
         @InputParam		: Mas with the old and the New values of the Shipment object.
         @Return			: void
 */
    public static void  createAssets(Map<id,Shipment_Order__c> mpOldOrder, Map<id,Shipment_Order__c> mpNewOrder ){

        set<Id> shiOrdSt = new set<Id>();

        for(Shipment_Order__c shiOrd : mpNewOrder.Values()){
            if(shiOrd.Status__c != mpOldOrder.get(shiOrd.id).Status__c
                     && shiOrd.Status__c == 'Delivered'){
                shiOrdSt.add(shiOrd.id);

            }
        }
        map<ID,Shipment_Order_Line_Item__c> mpShipOrd = new map<ID,Shipment_Order_Line_Item__c> ();

        for(Shipment_Order_Line_Item__c shipOrdLine : ShipmentOrderLineItemSelector.getShipmentLineItemsByOrder(shiOrdSt).Values() ){

            mpShipOrd.put(shipOrdLine.Opportunity_Quote_Line_Item__c, shipOrdLine);

        }

        List<Opportunity_Quote_Line_Item__c> lstOppQuoLine = OpportunityQuoteLineItemSelector.getQuoteLineItemByShipmentOrder(shiOrdSt,true,false);

        if(lstOppQuoLine.size()>0){
            LibHelper.createAssets(lstOppQuoLine,mpShipOrd);
        }
        lstOppQuoLine = OpportunityQuoteLineItemSelector.getQuoteLineItemByShipmentOrder(shiOrdSt,false,true);

        if(lstOppQuoLine.size()>0){
            LibHelper.createBranding(lstOppQuoLine,mpShipOrd);
        }
    }

    public static map<ID, List<Shipment_Order_Line_Item__c>> groupShipmentLineItems ( map<Id, Shipment_Order_Line_Item__c> mpShipmentOrderlineItems){

        map<Id, List<Shipment_Order_Line_Item__c>>  mpShipmentOrderLineItemsByOrder = new map<Id, List<Shipment_Order_Line_Item__c>>();
        for(Shipment_Order_Line_Item__c shipLinItem : mpShipmentOrderlineItems.values()){
            if(mpShipmentOrderLineItemsByOrder.containsKey(shipLinItem.Shipment_Order__c)){
                mpShipmentOrderLineItemsByOrder.get(shipLinItem.Shipment_Order__c).add(shipLinItem);
            }else{
                mpShipmentOrderLineItemsByOrder.put(shipLinItem.Shipment_Order__c,new List<Shipment_Order_Line_Item__c>{shipLinItem});
            }
        }
        return mpShipmentOrderLineItemsByOrder;
    }

    public static Shipment_Order__c validateShipmentOrders(map<Id, List<Shipment_Order_Line_Item__c>> mpShipmentOrderLineItems, Shipment_Order__c shipmentOrderOld , Shipment_Order__c shipmentOrder){
        if(!mpShipmentOrderLineItems.isEmpty()){
        for(Shipment_Order_Line_Item__c shipmentOrderLineItem : mpShipmentOrderLineItems.get(shipmentOrder.id)){
            if(shipmentOrderOld.Status__c != 'Shipped' &&
                    shipmentOrder.Status__c == 'Shipped'){

                if(String.isBlank(shipmentOrder.Tracking_Number__c)  ){
                    shipmentOrder.addError(Label.Tracking_number_Mandatory_Error);
                }

                if(shipmentOrderLineItem.Stock_Item__c == null &&
                        shipmentOrderLineItem.Opportunity_Quote_Line_Item__r.id_list_product_price__r.Requires_Asset__c == true &&
                        shipmentOrderLineItem.Opportunity_Quote_Line_Item__r.id_list_product_price__r.Product_Type__c != 'Software'){
                    shipmentOrder.addError(Label.Stock_Item_Mandatory_Error +  shipmentOrderLineItem.Name);
                }
            }



        }
        }
        //for
        return null;
    }

    /**
        @Description:   This method updates asset status based on SO status during replacement process
        @Process:       Replacement
        @InputParam:    Mas with the old and the New values of the Shipment object.
        @Return:        void
    */
    public static void updateReplacementAssetStatus(Map<id,Shipment_Order__c> oldOrder, Map<id,Shipment_Order__c> newOrder) {
        Map<String,Map<String,Business_Config__c>> mapBusinessLogic = moam.get('AssetReplacementProcess');
        
        Map<Id, List<Asset__c>> assetsMap = AssetSelector.getAssetsMapForShipmentOrders(newOrder.keySet());
        Set<Id> siIds = new Set<Id>();

        for(List<Asset__c> aL : assetsMap.values()) {
            for(Asset__c a : aL) {
                siIds.add(a.Stock_Item__c);
            }
        }

        Map<Id, Stock_Item__c> stockItems = new Map<Id, Stock_Item__c>(StockItem_Selector.getStockItems(siIds));
        
        // update shipment orders for Type__c = 'DH To Vendor'
        for(Shipment_Order__c so : newOrder.values()) {
            
            List<Asset__c> assets = assetsMap.get(so.Id);

            if(assets == null) {
                continue;
            }
            
            // changing status to shipped
            if (oldOrder != null 
                && oldOrder.get(so.Id) != null 
                && oldOrder.get(so.Id).Status__c != 'Shipped'
                && so.Status__c == 'Shipped'
                && so.Type__c == 'DH to Vendor') {
                    for(Asset__c a : assets) {
                        a.Status__c = 'Sent - Awaiting Activation';
                    }
            }
            // changing status to delivered
            else if(oldOrder != null 
                    && oldOrder.get(so.Id) != null 
                    && oldOrder.get(so.Id).Status__c != 'Delivered'
                    && so.Status__c == 'Delivered'
                    && so.Type__c == 'DH to Vendor') {
                        for(Asset__c a : assets) {
                            a.Status__c = 'Delivered';
                            
                            Stock_Item__c si = (stockItems.get(a.Stock_Item__c) != null) ? stockItems.get(a.Stock_Item__c) : null;
                            if(si != null) {
                                si.Status__c = 'Assigned';
                            }
                        }
            }
            // changing asset and stock item status for returned asset
            else if(oldOrder != null 
               && oldOrder.get(so.Id) != null 
               && oldOrder.get(so.Id).Status__c != 'Delivered'
               && so.Status__c == 'Delivered'
               && so.Type__c == 'Vendor to DH') {
                   for(Asset__c a : assets) {
                       a.Status__c = 'Delivered';
                       Stock_Item__c si = (stockItems.get(a.Stock_Item__c) != null) ? stockItems.get(a.Stock_Item__c) : null;
                       if(si != null) {
                           si.Status__c = 'In Stock';
                           si.Condition__c = 'U - Undefined';
                       }
                   }
            }
        }
        List<Asset__c> allAssets = new List<Asset__c>();
        for(List<Asset__c> aL : assetsMap.values()) {
            allAssets.addAll(aL);
        }
        
        update allAssets;
        update stockItems.values();
    }
    /**
    * @Description: This method updates Account Country on Creation of Shipping orders
      @Params       : List Shipment Orders records
      @Return             : Void
      @TriggerContext     : Before Insert,Before Update
      @Ticket #           : SSC-1665
    */

    public static void updateAccountCountry(List<Shipment_Order__c> lstShipmentOrders,Map<Id, SObject> oldSobjectMap){

        Set<Id> SetOfAccountId = new Set<Id>();
        Map<Id, Account> mapOfAccount;
        if(oldSobjectMap != null){

            Map<Id,Shipment_Order__c> mapOfShipmentOrder = (Map<Id,Shipment_Order__c>)oldSobjectMap;
            for(Shipment_Order__c iShipmentOrder : lstShipmentOrders){
                if(iShipmentOrder.Account__c != mapOfShipmentOrder.get(iShipmentOrder.Id).Account__c) {
                    SetOfAccountId.add(iShipmentOrder.Account__c);
                }
            }
        }
        else{
            for(Shipment_Order__c iShipmentOrder : lstShipmentOrders){
                SetOfAccountId.add(iShipmentOrder.Account__c);
            }
        }
        try{
            mapOfAccount = new Map<Id,Account> (ClsAccountSelector.getAccountByOppty(SetOfAccountId));
            for(Shipment_Order__c iShipmentOrder : lstShipmentOrders){
                iShipmentOrder.Account_Country__c = mapOfAccount.get(iShipmentOrder.Account__c).Record_Country__c;
            }
        }
        catch(Exception e){
            System.debug('Error: '+e.getMessage());
        }
    }
}
