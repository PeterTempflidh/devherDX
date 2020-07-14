public inherited sharing class AssetSelector {
    
    public static List<Asset__c> getActiveAssetsForAccount(Id accountId) {
        return [SELECT id, Status__c FROM Asset__c WHERE Account__c =:accountId and termination_date__c = null];
    }
    /*******************************************************************************************************
    * @description Query for get asset not Activated
    * @param  ExcludeAssets list of Asset that should be exclude
    *         OpportunitiesIds Ids of the opportunities related to the assets.
    * @return List of Assets
    */
    public static List<Asset__c> getAssetsNotActivated(List<Asset__c> ExcludeAssets,set<id> OpportunitiesIds ) {
        List<Asset__c> lstAssets = new List<Asset__c>();

        lstAssets = [Select opportunity__c
                        From Asset__c
                        Where opportunity__c in :OpportunitiesIds
                            AND Id not in: ExcludeAssets
                            AND (Status__c NOT IN ('Activated Successfully' , 'Replaced'))
                            AND Retour_date__c = null];
        return lstAssets;
    }
    /*******************************************************************************************************
    * @description Query for get asset by Id
    * @param  assetIds set of Ids that should be query
    * @return map of Assets
    */
    public static Map<Id, Asset__c> getAssetsbyId(set<Id> assetIds ) {
        Map<Id, Asset__c> mpAssets = new Map<Id, Asset__c>();
        mpAssets = new Map<Id, Asset__c>([SELECT Id,
                                                Name,
                                                Telephone_Number__c,
                                                Status__c,
                                                SIM_Activated__c,
                                                SIM_Card_Provider__c,
                                                SIM_Id__c,
                                                Stock_Item_Serial_No__c,
                                                Termination_Date__c,
                                                Stock_Item__c,
                                                Activation_Date__c
                                            FROM Asset__c
                                            WHERE Id IN : assetIds]);
        return mpAssets;
    }


    /*******************************************************************************************************
    * @description Query for get asset details by Id
    * @param  assetId
    * @return asset details
    */
    public static Asset__c getAssetDetailsById(Id assetId)  {
        return [SELECT Id, Name, Status__c, Source_Asset__c, RecordTypeId,
                    Stock_Item__c, Stock_Item__r.RecordTypeId, Stock_Item__r.Name, 
                    Stock_Item__r.Status__c, Stock_Item__r.Condition__c, 
                    Account__r.Name, Account__r.Id, Account__r.Account_Email__c, Account__r.Account_Status__c, CurrencyIsoCode,
                    Id_Opportunity_Quote_Line_Item__r.Id_List_Product_Price__c,
                    Id_Opportunity_Quote_Line_Item__r.Id_List_Product_Price__r.SKU__c, Opportunity__c
                FROM Asset__c
                WHERE Id = :assetId
                LIMIT 1];
    }

    /*******************************************************************************************************
    * @description Query for get new asset details by old asset Id
    * @param  oldAssetId
    * @return asset details
    */
    public static Asset__c getNewAsset(Id oldAssetId)  {
        return [SELECT Id, Name, Status__c
                FROM Asset__c
                WHERE Replaced_Asset__c = :oldAssetId
                LIMIT 1];
    }

    /*******************************************************************************************************
    * @description Query for get all sourced assets based on source asset Id
    * @param  sourceAssetId
    * @return All assets that have this asset as a source
    */
    public static List<Asset__c> getSourcedAssets(Id sourceAssetId)  {
        return [SELECT Id, Source_Asset__c
                FROM Asset__c
                WHERE Source_Asset__c = :sourceAssetId];
    }


    /*******************************************************************************************************
    * @description get list of assets associated to these shipment orders
    * @param  shipmentOrders: st of SO ids
    * @return: map of SO Id and Assets
    */
    public static Map<Id, List<Asset__c>> getAssetsMapForShipmentOrders(Set<Id> shipmentOrders){
        List<Asset__c> assets = [SELECT Id, Name, Status__c, Shipment_Order__c, Shipment_Order_Line_Item__c, Stock_Item__c,
                                 RecordTypeId, RecordType.DeveloperName
                                 FROM Asset__c
                                 WHERE Shipment_Order__c IN :shipmentOrders]; 
        Map<Id, List<Asset__c>> assetsMap = new Map<Id, List<Asset__c>>();
        for(Asset__c a : assets) {
            if(assetsMap.get(a.Shipment_Order__c) != null) {
                assetsMap.get(a.Shipment_Order__c).add(a);
            } else {
                assetsMap.put(a.Shipment_Order__c, new List<Asset__c> {a});
            }
        }
        return assetsMap;
    }

    /*******************************************************************************************************
    * @description get list of assets associated to these shipment order line items
    * @param  soliIds: set of SOLI ids
    * @return: map of SOLI Id and Assets
    */
    public static Map<Id, Asset__c> getAssetsMapForShipmentOrderLineItems(Set<Id> soliIds) {
        Map<Id, Asset__c> soliAssets = new Map<Id, Asset__c>();
        List<Asset__c> assets = [SELECT Id, Name, Status__c, Shipment_Order__c, Shipment_Order_Line_Item__c, Stock_Item__c
                                 FROM Asset__c
                                 WHERE Shipment_Order_Line_Item__c IN :soliIds];
        for(Asset__c a : assets) {
            soliAssets.put(a.Shipment_Order_Line_Item__c, a);
        }
        return soliAssets;
    }
    /**
     *  @description get active assets by their account ids
     *
     * @param Ids
     *
     * @return List<Asset__c>
     */
    public static List<Asset__c> findActiveByAccountIds(Set<Id> Ids) {
        List<Asset__c> assets = new List<Asset__c>();
        assets = [SELECT Id, Status__c, Account__c, Account_Country__c FROM Asset__c WHERE Account__c IN :Ids AND Termination_Date__c = NULL];
        return assets;
    }
    /*******************************************************************************************************
   * @description get list of assets associated opportunity and Status
   * @param  opptyIdSet of oppty Id
   * @param  assetStageSet set of Asset Status
   * @return  List of Assets
   */
    public static List<Asset__c> getAssetByStatus(Set<Id> opptyIdSet,Set<string> assetStatusSet){
        List<Asset__c> assetLst = new List<Asset__c>();
        assetLst = [SELECT id, status__c,
                    opportunity__c FROM asset__c WHERE opportunity__c IN  :opptyIdSet
                    AND Status__c IN : assetStatusSet];
        return assetLst;
    }

}