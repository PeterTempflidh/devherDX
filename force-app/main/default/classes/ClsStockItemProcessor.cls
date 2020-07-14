public without sharing class ClsStockItemProcessor {
    //private static Map<Id,RecordType> mapRecordTypesForIds = LibRecordTypeHelper.getRecordTypeForIds(new Set<String>{'Stock_Item__c','Asset__c'});
    private static Map<String, Map<String,Map<String,Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    /**
    * SP-446 Global Search issue for Stock Item
    * @param 
    *   listNewAssets: List of new Trigger values
    *   mapOldAssets:  Map of old trigger values
    * @return void
    */

    public static void copySerialNumberForGlobalSearchAssetCancellation(List<Asset_Cancellation__c> listNew, Map<Id,Asset_Cancellation__c> mapOld){
        Set<Id> setStockItemIds = new Set<Id>();
        Map<Id,String> mapStockItemIdSerialNumber = new Map<Id,String>();
        for(Asset_Cancellation__c astCan : listNew){
            if(mapOld!=null && !mapOld.isEmpty() && astCan.Returning_Stock_Item__c!=null && astCan.Returning_Stock_Item__c!= mapOld.get(astCan.Id).Returning_Stock_Item__c){
                setStockItemIds.add(astCan.Returning_Stock_Item__c);   
            }else if(mapOld==null && astCan.Returning_Stock_Item__c!=null){
                setStockItemIds.add(astCan.Returning_Stock_Item__c);
            }
        }

        if(!setStockItemIds.isEmpty()){
            for(Stock_Item__c si : [SELECT Id,Name FROM Stock_Item__c WHERE Id IN: setStockItemIds]){
                mapStockItemIdSerialNumber.put(si.Id,si.Name);
            }
        }
        if(!mapStockItemIdSerialNumber.isEmpty()){
            for(Asset_Cancellation__c astCan : listNew){
                if(mapStockItemIdSerialNumber.get(astCan.Returning_Stock_Item__c)!=null){
                    astCan.Returning_Stock_Item_Serial_No__c = mapStockItemIdSerialNumber.get(astCan.Returning_Stock_Item__c);
                }
            }
        }
    }

    public static void copySerialNumberForGlobalSearch(List<Asset__c> listNew, Map<Id,Asset__c> mapOld){
        Set<Id> setStockItemIds = new Set<Id>();
        Map<Id,String> mapStockItemIdSerialNumber = new Map<Id,String>();
        for(Asset__c asst : listNew){
            /*if(mapOld!=null && !mapOld.isEmpty() && asst.Stock_Item__c!=null && asst.Stock_Item__c!= mapOld.get(asst.Id).Stock_Item__c){
                setStockItemIds.add(asst.Stock_Item__c);
            }else if(mapOld==null && asst.Stock_Item__c!=null){*/
            if(asst.Stock_Item__c!=null){
                setStockItemIds.add(asst.Stock_Item__c);
            }
        }

        if(!setStockItemIds.isEmpty()){
            for(Stock_Item__c si : [SELECT Id,Name FROM Stock_Item__c WHERE Id IN: setStockItemIds]){
                mapStockItemIdSerialNumber.put(si.Id,si.Name);
            }
        }
        if(!mapStockItemIdSerialNumber.isEmpty()){
            for(Asset__c asst : listNew){
                if(mapStockItemIdSerialNumber.get(asst.Stock_Item__c)!=null){
                    asst.Stock_Item_Serial_No__c = mapStockItemIdSerialNumber.get(asst.Stock_Item__c);
                }
            }
        }
    }
    /*public static void copySerialNumberForGlobalSearch(List<Asset__c> listNewAssets, Map<Id,Asset__c> mapOldAssets){
        Set<Id> setStockItemIds = new Set<Id>();
        Set<Id> setReturningStockItemIds = new Set<Id>();
        Map<Id,String> mapStockItemIdSerialNumber = new Map<Id,String>();
        Map<Id,String> mapReturningStockItemIdSerialNumber = new Map<Id,String>();
        Map<String,Business_Config__c> mapBusinessData;
        //Map<String,Map<String,Business_Config__c>> mapReturningStockItemProcessData = LibBusinessConfig.getGenericProcessData('ReturningStockItemProcess');
        Map<String,Map<String,Business_Config__c>> mapReturningStockItemProcessData = moam.get('ReturningStockItemProcess');
        System.debug('$$$ copySerialNumber entry');
        for(Asset__c updatedAsset : listNewAssets){
            
            if(mapOldAssets != null){
                //update branch
                System.debug('$$$ update branch entered');
                if(mapOldAssets.get(updatedAsset.Id).Stock_Item__c != updatedAsset.Stock_Item__c){
                    if(updatedAsset.Stock_Item__c != null){
                        System.debug('$$$ changed stockItem found!');
                        setStockItemIds.add(updatedAsset.Stock_Item__c);
                    }else{
                        updatedAsset.Stock_Item_Serial_No__c = null;
                    }
                }
                
                System.debug('$$$ changed returningstockItem found!');
                System.debug('$$$ updatedAsset.Replaced_Stock_Item__c ' + updatedAsset.Replaced_Stock_Item__c);
                setReturningStockItemIds.add(updatedAsset.Replaced_Stock_Item__c);
            
            }else{
                System.debug('$$$ insert branch');
                //insert branch
                if(updatedAsset.Replaced_Stock_Item__c != null){
                    System.debug('$$$ changed returningstockItem found!');
                    setReturningStockItemIds.add(updatedAsset.Replaced_Stock_Item__c);
                }else{
                    updatedAsset.Returning_Stock_Item_Serial_No__c = null;
                } 
                
                if(updatedAsset.Stock_Item__c != null){
                    System.debug('$$$ changed stockItem found!');
                    setStockItemIds.add(updatedAsset.Stock_Item__c);
                }else{
                    updatedAsset.Stock_Item_Serial_No__c = null;
                }
            }                               
        }
        
        if(!setStockItemIds.isEmpty() || !setReturningStockItemIds.isEmpty()){
            for(Stock_Item__c si : [SELECT Id,Name FROM Stock_Item__c WHERE Id IN: setStockItemIds]){
                System.debug('$$$ query loop for changed stockitem');
                mapStockItemIdSerialNumber.put(si.Id,si.Name);
            }
            
            for(Stock_Item__c si : [SELECT Id,Name FROM Stock_Item__c WHERE Id IN: setReturningStockItemIds]){
                System.debug('$$$ query loop for changed returning stockitem');
                mapReturningStockItemIdSerialNumber.put(si.Id,si.Name);
            }
               
            for(Asset__c updatedAsset : listNewAssets){
                if(mapStockItemIdSerialNumber.get(updatedAsset.Stock_Item__c) != null){
                    System.debug('$$$ update stockitem serialnumber: ' + mapStockItemIdSerialNumber.get(updatedAsset.Stock_Item__c));
                    updatedAsset.Stock_Item_Serial_No__c = mapStockItemIdSerialNumber.get(updatedAsset.Stock_Item__c);
                }
                System.debug('$$$ update returning stockitem serialnumber: ' + mapReturningStockItemIdSerialNumber.get(updatedAsset.Replaced_Stock_Item__c));
                updatedAsset.Returning_Stock_Item_Serial_No__c = mapReturningStockItemIdSerialNumber.get(updatedAsset.Replaced_Stock_Item__c);
                
                    //changes for SP-484
                if((mapOldAssets != null && mapOldAssets.get(updatedAsset.Id).Replaced_Stock_Item__c != updatedAsset.Replaced_Stock_Item__c
                  && mapOldAssets.get(updatedAsset.Id).Replaced_Stock_Item__c != null) || (mapOldAssets != null && updatedAsset.Replaced_Stock_Item__c == null && mapOldAssets.get(updatedAsset.Id).Replaced_Stock_Item__c !=null) ){
                    
                    System.debug('$$$ mapBusinessconfig: ' + mapReturningStockItemProcessData);
                    String commentText;
                    if(mapReturningStockItemProcessData!=null && !mapReturningStockItemProcessData.isEmpty() && mapReturningStockItemProcessData.get(mapRecordTypesForIds.get(updatedAsset.RecordTypeId).developerName)!=null){
                        mapBusinessData = mapReturningStockItemProcessData.get(mapRecordTypesForIds.get(updatedAsset.RecordTypeId).developerName);
                        if(mapBusinessData!=null && !mapBusinessData.isEmpty()){
                            for(String field : mapBusinessData.get('fieldsToCopy').Business_Rule_value__c.split(',')){
                                String fieldLabel = Schema.describeSObjects(new List<String>{'Asset__c'})[0].Fields.getMap().get(field).getDescribe().getLabel();
                                
                                if(commentText == null){
                                    if(mapOldAssets.get(updatedAsset.Id).get(field) != null){
                                        commentText = fieldLabel + ': ' + mapOldAssets.get(updatedAsset.Id).get(field) + '\n'; 
                                    }
                                }else{
                                    if(mapOldAssets.get(updatedAsset.Id).get(field) != null){
                                        commentText += fieldLabel + ': ' + mapOldAssets.get(updatedAsset.Id).get(field) + '\n';    
                                    }
                                } 
                            }
                        }
                    }
                    if(updatedAsset.Return_Comments__c == null || updatedAsset.Return_Comments__c.length() >= 32000){
                        updatedAsset.Return_Comments__c = commentText;    
                    }else{
                        updatedAsset.Return_Comments__c += '\n\n' + commentText;
                    }
                }
            }
        }                    
    }*/


/**
    * SP-366 History of Stock Item
    * @param 
    *   listNewAssets: List of new Trigger values
    *   mapOldAssets:  Map of old trigger values
    * @return void
    */
    
    //blank restaurant name if stockItem status is "in stock"

    public static void trackAccountHistory(Map<Id,Asset__c> mapNewAssets, Map<Id,Asset__c> mapOldAssets){
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setStockItemIds = new Set<Id>();
        for(Asset__c updatedAsset : mapNewAssets.values()){
        
            if(mapOldAssets == null){ //insert branch
                if(updatedAsset.Stock_Item__c != null && updatedAsset.Is_Data_Loaded__c == false){
                    if(!setAccountIds.contains(updatedAsset.Account__c)){
                        setAccountIds.add(updatedAsset.Account__c);
                    }
                    if(!setStockItemIds.contains(updatedAsset.Stock_Item__c)){
                        setStockItemIds.add(updatedAsset.Stock_Item__c);
                    }   
                }
                //update branch
            }else if(updatedAsset.Stock_Item__c != null && updatedAsset.Is_Data_Loaded__c == false && updatedAsset.Stock_Item__c != mapOldAssets.get(updatedAsset.Id).Stock_Item__c){
                if(!setAccountIds.contains(updatedAsset.Account__c)){
                    setAccountIds.add(updatedAsset.Account__c);
                }
                if(!setStockItemIds.contains(updatedAsset.Stock_Item__c)){
                    setStockItemIds.add(updatedAsset.Stock_Item__c);
                }
            }
            
        }

        if(!setStockItemIds.isEmpty() && !setAccountIds.isEmpty()){
            Map<Id,Account> mapAccounts = new Map<Id,Account>([SELECT Id,Restaurant_Name__c, Migration_Id__c FROM Account WHERE Id IN: setAccountIds]);
            Map<Id,Stock_Item__c> mapStockItems = new Map<Id,Stock_Item__c>([SELECT Id, Restaurant_Name__c, Migration_Account_Id__c FROM Stock_Item__c WHERE Id IN: setStockItemIds]);

            Set<Stock_Item__c> listStockItems2Update = new Set<Stock_Item__c>();
            
            for(Asset__c updatedAsset : mapNewAssets.values()){
                if(mapStockItems.containsKey(updatedAsset.Stock_Item__c)) {
                    Stock_Item__c item = mapStockItems.get(updatedAsset.Stock_Item__c);

                    item.Restaurant_Name__c = mapAccounts.get(updatedAsset.Account__c).Restaurant_Name__c;
                    item.Migration_Account_Id__c = mapAccounts.get(updatedAsset.Account__c).Migration_Id__c;
                    //item.Id_Account__c = mapAccounts.get(updatedAsset.Account__c).Id;
                    listStockItems2Update.add(item);
                }
            }

            if(!listStockItems2Update.isEmpty()){
                try{
                    update new List<Stock_Item__c>(listStockItems2Update);   
                }catch(Exception e){
                    System.debug('Error occured: ' + e.getMessage() + ' StackTrace: ' + e.getStackTraceString());
                }
                
            }
        }
        
    }
    
    public static void resetRestaurantsNameOnStockItem(Map<Id,Stock_Item__c> mapNewStockItems, Map<Id,Stock_Item__c> mapOldStockItems){
        //List<Stock_Item__c> listStockItemsToUpdate = new List<Stock_Item__c>();
        for(Stock_Item__c item : mapNewStockItems.values()){
            if(mapOldStockItems.get(item.Id).Status__c != item.Status__c && item.Status__c == 'In Stock'){
                item.Restaurant_Name__c = '';
                item.Migration_Account_Id__c = '';
            }
        }
    }



    public static void stockBeforUpdate(List<Stock_Item__c> newList, Map<Id,Stock_Item__c> oldMap){
        Map<String,Business_Config__c> mapBusinessData;
        //Map<String,Map<String,Business_Config__c>> mapassetCancellationProcessData = LibBusinessConfig.getGenericProcessData('StockUpdateProcess');
        Map<String,Map<String,Business_Config__c>> mapassetCancellationProcessData = moam.get('StockUpdateProcess');
        Map<Id,Stock_Item__c> mapStockAssignedAsset = new Map<Id,Stock_Item__c>();
        for(Stock_Item__c stk: [select id, (select id from Asset_Assignment__r where Stock_Item__c!=null) from Stock_Item__c where id in: newList]){
            mapStockAssignedAsset.put(stk.id,stk);
        }
        
        try{
            if(mapassetCancellationProcessData!=null && !mapassetCancellationProcessData.isEmpty()){
                for(Stock_Item__c stk : newList){
                    //mapBusinessData = mapassetCancellationProcessData.get(mapRecordTypesForIds.get(stk.RecordTypeId).developerName);
                    mapBusinessData = mapassetCancellationProcessData.get(LibRecordTypeHelper.getRecordTypeValue(stk.RecordTypeId));
                    if(mapBusinessData!=null && !mapBusinessData.isEmpty() && mapStockAssignedAsset.get(stk.id).Asset_Assignment__r.isEmpty()){
                        if(stk.Status__c==mapBusinessData.get('status').Business_Rule_value__c && stk.Status__c!=oldMap.get(stk.id).Status__c){
                            if(mapBusinessData.get('AllowUpdateStockCondition')!=null && mapBusinessData.get('AllowUpdateStockCondition').Business_Rule_value__c!=null && Boolean.valueOf(mapBusinessData.get('AllowUpdateStockCondition').Business_Rule_value__c)){
                                Set<String> stockPreviouseStatusSet = new Set<String>();
                                if(mapBusinessData.get('UpdateStockConditionIfPreviouseStatus').Business_Rule_value__c!=null){
                                    if(mapBusinessData.get('UpdateStockConditionIfPreviouseStatus').Business_Rule_value__c.indexOf(',')>1){
                                       stockPreviouseStatusSet.addAll(mapBusinessData.get('UpdateStockConditionIfPreviouseStatus').Business_Rule_value__c.split(',')); 
                                    }else{
                                        stockPreviouseStatusSet.add(mapBusinessData.get('UpdateStockConditionIfPreviouseStatus').Business_Rule_value__c);
                                    }
                                    if(stockPreviouseStatusSet.contains(oldMap.get(stk.id).Status__c)){
                                        if(mapBusinessData.get('UpdateStockConditionTo')!=null){
                                            stk.Condition__c = mapBusinessData.get('UpdateStockConditionTo').Business_Rule_value__c;
                                        }
                                    }
                                    if(mapBusinessData.get('AllowFieldAgentOwnerToBeBlank')!=null && mapBusinessData.get('AllowFieldAgentOwnerToBeBlank').Business_Rule_value__c!=null && Boolean.valueOf(mapBusinessData.get('AllowFieldAgentOwnerToBeBlank').Business_Rule_value__c)){
                                        stk.Field_Agent_Owner__c = null;
                                    }
                                    if(mapBusinessData.get('AllowUpdateStockOwnership')!=null && mapBusinessData.get('AllowUpdateStockOwnership').Business_Rule_value__c!=null && Boolean.valueOf(mapBusinessData.get('AllowUpdateStockOwnership').Business_Rule_value__c)){
                                        stk.Stock_Item_Ownership__c = mapBusinessData.get('UpdateStockOwnershipTo').Business_Rule_value__c;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }catch(Exception e){
            newList[0].addError(e.getMessage());
        }
    }

    public static void calculateStockUsedDays(List<Stock_Item__c> newList){
        Map<Id,Decimal> mapStkIdWithDays = new Map<Id,Decimal>();
        for(Asset_Cancellation__c ast : [select id,Returning_Stock_Item__c, Stock_Used__c from Asset_Cancellation__c where Returning_Stock_Item__c in : newList]){
            if(ast.Stock_Used__c!=null){
                if(mapStkIdWithDays.get(ast.Returning_Stock_Item__c)!=null){
                    Decimal days = mapStkIdWithDays.get(ast.Returning_Stock_Item__c) + ast.Stock_Used__c;
                    mapStkIdWithDays.put(ast.Returning_Stock_Item__c,days);
                }else{
                    mapStkIdWithDays.put(ast.Returning_Stock_Item__c,ast.Stock_Used__c);
                }
            }
            
        }
        for(Stock_Item__c stk : newList){
            if(mapStkIdWithDays.get(stk.Id)!=null){
                stk.Total_Days_In_Use__c = mapStkIdWithDays.get(stk.Id);
            }
        }
    }

}
