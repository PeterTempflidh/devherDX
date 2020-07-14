public without sharing class ReplacementLightningController {
    
    @AuraEnabled
    public static String getCurrentData(String assetIdString) {
        // current asset and stock item
        Asset__c oldAsset = AssetSelector.getAssetDetailsById(assetIdString);
        
        Account vendor = AccountSelector.getAccountDetailsforId(oldAsset.Account__r.Id);
        
        String accJSON = '{ "Id" : "' + vendor.Id + '", "Name" : "' + vendor.Name +  '", "Email" : "'+ vendor.Account_Email__c +'", "Status" : "'+ vendor.Account_Status__c +'" }';
        
        String newAssetJson = '{}';
        if(oldAsset.Status__c == 'Return In Progress') {
            Asset__c newAsset = AssetSelector.getNewAsset(assetIdString);
            newAssetJson = '{ "Id" : "' + newAsset.Id + '", "Name" : "' + newAsset.Name +  '", "Status" : "'+ newAsset.Status__c +'" }';
        }
        
        return JSON.Serialize(
            new ResultWrapperBuilder(true)
                .setId((id)assetIdString)
                .setUserMessage('Done')
                .setKeyValuePair('Account', accJSON)
                .setKeyValuePair('AccountId', '' + oldAsset.Account__c)
                .setKeyValuePair('Name', '' + oldAsset.Name)
                .setKeyValuePair('Status', '' + oldAsset.Status__c)
                .setKeyValuePair('NewAsset', newAssetJson)
                .setKeyValuePair('StockItem_SerialNumber', '' + oldAsset.Stock_Item__r.Name)
                .setKeyValuePair('StockItem_Status', '' + oldAsset.Stock_Item__r.Status__c)
                .Build());
    }
    
    @AuraEnabled
    public static String startReplacement(String assetIdString) {
        // current asset and stock item
        Asset__c oldAsset = AssetSelector.getAssetDetailsById(assetIdString);
        
        // find if there are existing shipment orders
        List<Shipment_Order__c> openSOs = ShipmentOrderSelector.getOpenShipmentOrdersForAccount(oldAsset.Account__r.Id);
        
        Shipment_Order__c openSoVDH = null;
        Shipment_Order__c openSoDHV = null;
        for(Shipment_Order__c so : openSOs) {
            if(so.Type__c == 'Vendor to DH') {
                openSoVDH = so;
            } else if(so.Type__c == 'DH to Vendor') {
                openSoDHV = so;
            }
        }
        
        List<Stock_Item__c> stis = StockItem_Selector.getStockItems(new Set<Id> {oldAsset.Stock_Item__c});
        if(stis.size() == 0) {
            return JSON.Serialize(
                new ResultWrapperBuilder(false)
                .setId((id)assetIdString)
                .setUserMessage(Label.Stock_Item_Missing)
                .Build());
        }
        
        Stock_Item__c sti = stis[0];

        Shipment_Order__c so_vdh = openSoVDH;
        if(so_vdh == null) {
            so_vdh = new Shipment_Order__c(Status__c = 'Open', Type__c = 'Vendor to DH', Account__c = oldAsset.Account__r.Id);
            insert so_vdh;
        }
        
        String savedStatus = sti.Status__c;
        sti.Status__c = 'In Stock';
        update sti;
        Shipment_Order_Line_Item__c soli_vdh = new Shipment_Order_Line_Item__c(Quantity__c = 1, 
                                                                               List_Product_Price__c = oldAsset.Id_Opportunity_Quote_Line_Item__r.Id_List_Product_Price__c, 
                                                                               SKU__c = oldAsset.Id_Opportunity_Quote_Line_Item__r.Id_List_Product_Price__r.SKU__c, 
                                                                               Name = oldAsset.Name, 
                                                                               Shipment_Order__c = so_vdh.Id, 
                                                                               Serial_Number__c = sti.Name, 
                                                                               CurrencyIsoCode = oldAsset.CurrencyIsoCode, 
                                                                               Stock_Item__c = oldAsset.Stock_Item__c);
        insert soli_vdh;
        sti.Status__c = savedStatus;
        update sti;
        
        Shipment_Order__c so_dhv = openSoDHV;
        if(so_dhv == null) {
            so_dhv = new Shipment_Order__c(Status__c = 'Open', Type__c = 'DH to Vendor', Account__c = oldAsset.Account__r.Id);
            insert so_dhv;
        }
        Shipment_Order_Line_Item__c soli_dhv = new Shipment_Order_Line_Item__c(Shipment_Order__c = so_dhv.Id, 
                                                                               Name = oldAsset.Name, 
                                                                               CurrencyIsoCode = oldAsset.CurrencyIsoCode );
        insert soli_dhv;
        
        oldAsset.Shipment_Order_Line_Item__c = soli_vdh.Id;
        oldAsset.Shipment_Order__c = so_vdh.Id;
        oldAsset.Status__c = 'Return In Progress';
        update oldAsset;
        
        Asset__c newAsset = new Asset__c(Name = oldAsset.Name, 
                                         Account__c = oldAsset.Account__c,
                                         RecordTypeId = oldAsset.RecordTypeId,
                                         Status__c = 'New - Awaiting Shipping', 
                                         Shipment_Order__c = so_dhv.Id,
                                         Shipment_Order_Line_Item__c = soli_dhv.Id,
                                         Replaced_Asset__c = oldAsset.Id,
                                         Opportunity__c = oldAsset.Opportunity__c);
        insert newAsset;
        
        // Source asset needs to be updated from old to this new asset
        List<Asset__c> toBeUpdated = AssetSelector.getSourcedAssets(oldAsset.Id);
        
        for(Asset__c a : toBeUpdated) {
            a.Source_Asset__c = newAsset.Id;
        }
        update toBeUpdated;
        
        String accJSON = '{ "Id" : "' + oldAsset.Account__r.Id + '", "Name" : "' + oldAsset.Account__r.Name +  '", "Email" : "'+ oldAsset.Account__r.Account_Email__c +'", "Status" : "'+ oldAsset.Account__r.Account_Status__c +'" }';
        String newAssetJson = '{ "Id" : "' + newAsset.Id + '", "Name" : "' + newAsset.Name +  '", "Status" : "'+ newAsset.Status__c +'" }';
        
        return JSON.Serialize(
            new ResultWrapperBuilder(true)
                .setId((id)assetIdString)
                .setUserMessage(Label.Replacement_process_initiated)
                .setKeyValuePair('Account', accJSON)
                .setKeyValuePair('NewAsset', newAssetJson)
                .setKeyValuePair('Name', '' + oldAsset.Name)
                .setKeyValuePair('Status', '' + oldAsset.Status__c)
                .setKeyValuePair('StockItem_SerialNumber', '' + oldAsset.Stock_Item__r.Name)
                .setKeyValuePair('StockItem_Status', '' + oldAsset.Stock_Item__r.Status__c)
                .setKeyValuePair('NewAsset_Id', '' + newAsset.Id)
                .setKeyValuePair('NewAsset_Status', '' + newAsset.Status__c)
                .Build());
    }
}