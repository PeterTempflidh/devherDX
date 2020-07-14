public class ClsAssetProcessor {
    //private static Map<Id,RecordType> mapRecordTypesForIds = LibRecordTypeHelper.getRecordTypeForIds(new Set<String>{'Case','Asset__c'});
    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    //private static Map<String,Map<String,Business_Config__c>> mapAssetStockProcessData = LibBusinessConfig.getGenericProcessData('AssetStockProcess');
    private static Map<String, Map<String, Business_Config__c>> mapAssetStockProcessData = moam.get('AssetStockProcess');
    //private static Map<String,RecordType> mapRecordTypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Asset_Cancellation__c'});
    private static Map<Id, Asset__c> sourceAssets = new Map<Id, Asset__c>();// used both for reference and update values
    public static void setAssignedStockStatus(List<Asset__c> newAssetList, Map<Id, Asset__c> oldAssetMap) {
        try {
            List<Id> stockIdList = new List<Id>();
            //List<Id> stockUnassignedIdList = new List<Id>();
            //Map<String,Business_Config__c> mapBusinessData;
            //List<Stock_Item__c> updateStock = new List<Stock_Item__c>();
            //SP-453
            //1. if return status is Delivered to warehouse then update the Stock stage to In-Stock
            for (Asset__c asset : newAssetList) {
                if (asset.Stock_Item__c != null && oldAssetMap.get(asset.id).Stock_Item__c == null && asset.Stock_Item__c != oldAssetMap.get(asset.id).Stock_Item__c) {
                    stockIdList.add(asset.Stock_Item__c);
                }
                if (asset.Stock_Item__c != null && oldAssetMap.get(asset.id).Stock_Item__c != null && asset.Stock_Item__c != oldAssetMap.get(asset.id).Stock_Item__c) {
                    //stockUnassignedIdList.add(oldAssetMap.get(asset.id).Stock_Item__c);
                    stockIdList.add(asset.Stock_Item__c);
                }
                /*if(asset.Stock_Item__c==null && oldAssetMap.get(asset.id).Stock_Item__c!=null){
                    stockUnassignedIdList.add(oldAssetMap.get(asset.id).Stock_Item__c);
                }*/




                //SP-453
                /*System.debug('mapAssetStockProcessData: '+mapAssetStockProcessData);
                if(mapAssetStockProcessData!=null && !mapAssetStockProcessData.isEmpty() && mapAssetStockProcessData.get(mapRecordTypesForIds.get(asset.RecordTypeId).developerName)!=null){
                    mapBusinessData = mapAssetStockProcessData.get(mapRecordTypesForIds.get(asset.RecordTypeId).developerName);
                    if(mapBusinessData!=null && !mapBusinessData.isEmpty()){
                        Stock_Item__c updatedStock = new Stock_Item__c();
                        if(mapBusinessData.get('AllowUpdateStockStatusUpdate')!=null && mapBusinessData.get('AllowUpdateStockStatusUpdate').Business_Rule_Value__c!=null && Boolean.valueOf(mapBusinessData.get('AllowUpdateStockStatusUpdate').Business_Rule_Value__c)){
                            if(asset.Return_Status__c!=null && asset.Return_Status__c==mapBusinessData.get('updateStockStatusIfAssetReturn').Business_Rule_Value__c && asset.Return_Status__c!=oldAssetMap.get(asset.id).Return_Status__c){
                                updatedStock.id=asset.Replaced_Stock_Item__c;
                                updatedStock.status__c=mapBusinessData.get('updateStockStatusTo').Business_Rule_Value__c;
                            }
                        }
                        if(mapBusinessData.get('AllowStockInShipmentRule')!=null && mapBusinessData.get('AllowStockInShipmentRule').Business_Rule_Value__c!=null && Boolean.valueOf(mapBusinessData.get('AllowStockInShipmentRule').Business_Rule_Value__c)){
                            Set<String> setAssetReturnStatus = new Set<String>();
                            if(mapBusinessData.get('updateStockInShipmentIfAssetRStatus').Business_Rule_Value__c!=null && mapBusinessData.get('updateStockInShipmentIfAssetRStatus').Business_Rule_Value__c.indexOf(',')>1){
                                setAssetReturnStatus.addAll(mapBusinessData.get('updateStockInShipmentIfAssetRStatus').Business_Rule_Value__c.split(','));
                            }else if(mapBusinessData.get('updateStockInShipmentIfAssetRStatus').Business_Rule_Value__c!=null){
                                setAssetReturnStatus.add(mapBusinessData.get('updateStockInShipmentIfAssetRStatus').Business_Rule_Value__c);
                            }
                            if(asset.Return_Status__c!=null && setAssetReturnStatus.contains(asset.Return_Status__c) && asset.Return_Status__c!=oldAssetMap.get(asset.id).Return_Status__c){
                                if(asset.Stock_Item__c!=null){
                                     updatedStock.id=asset.Stock_Item__c;
                                }else{
                                     updatedStock.id=asset.Replaced_Stock_Item__c;
                                }
                                updatedStock.status__c=mapBusinessData.get('updateStockInShipmentStatusTo').Business_Rule_Value__c;
                            }
                        }
                        if(updatedStock.status__c!=null){
                            updateStock.add(updatedStock);
                        }
                    }
                }*/
            }
            List<Stock_Item__c> stockList = [select id, status__c, condition__c, recordtype.developername from Stock_Item__c where Id in : stockIdList];
            Map<String, Map<String, Business_Config__c>>StockUpdateProcess = moam.get('StockUpdateProcess');
            // if(){
            for (Stock_Item__c st : stockList) {
                if (StockUpdateProcess != null && StockUpdateProcess.get(st.recordtype.developername) != null) {
                    Map<String, Business_Config__c> mapStockUpdateProcessConfig = StockUpdateProcess.get(st.recordtype.developername);
                    if (!mapStockUpdateProcessConfig.isEmpty() && mapStockUpdateProcessConfig.get('ReturnedStockItemStatus') != null && st.status__c == mapStockUpdateProcessConfig .get('ReturnedStockItemStatus').Business_Rule_Value__c && st.condition__c == mapStockUpdateProcessConfig.get('ReturnedStockItemCondition').Business_Rule_Value__c) {
                        st.condition__c = mapStockUpdateProcessConfig.get('UpdateAssignedStockCondition').Business_Rule_Value__c;

                    }
                }

                st.status__c = 'Assigned';
            }
            // }
            // commented below lines for SP-413
            /*List<Stock_Item__c> stockUnassignedList = [select id, status__c from Stock_Item__c where Id in : stockUnassignedIdList];
            for(Stock_Item__c st : stockUnassignedList){
                st.status__c = 'In Stock';
            }*/
            update stockList;
            //SP-453
            //update updateStock;
            //update stockUnassignedList;
        } catch (Exception e) {
            newAssetList[0].addError(e.getMessage());
        }

    }


    public static void resetAllReturnFields(List<Asset__c> newValueAssets, Map<Id, Asset__c> oldAssetMap) {
        //SP-453
        //1. Blank out all the return relaed fields when retuning stock item is removed or changed
        //2. Remove Stock Item ID from "Stock item field" and place it in the "Returning stock item field" and set status to "arrange pick up"
        Map<String, Business_Config__c> mapBusinessData;
        List<Asset_Cancellation__c> listAssetCanceled = new List<Asset_Cancellation__c>();
        Map<String, Schema.SObjectField> M = Schema.SObjectType.Asset__c.fields.getMap();
        Set<String> doNotOverWriteAssetStatus;
        try {
            for (Asset__c asset : newValueAssets) {

                //if(asset.Stock_Item__c!=null && mapAssetStockProcessData!=null && !mapAssetStockProcessData.isEmpty() && mapAssetStockProcessData.get(mapRecordTypesForIds.get(asset.RecordTypeId).developerName)!=null){
                //    mapBusinessData = mapAssetStockProcessData.get(mapRecordTypesForIds.get(asset.RecordTypeId).developerName);



                if (mapAssetStockProcessData != null && !mapAssetStockProcessData.isEmpty() && mapAssetStockProcessData.get(LibRecordTypeHelper.getRecordTypeValue(asset.RecordTypeId)) != null) {

                    mapBusinessData = mapAssetStockProcessData.get(LibRecordTypeHelper.getRecordTypeValue(asset.RecordTypeId));


                    if (mapBusinessData != null && !mapBusinessData.isEmpty()) {
                        if (mapBusinessData.get('AllowUpdateAssetActivationDate') != null && mapBusinessData.get('AllowUpdateAssetActivationDate').Business_Rule_Value__c != null && Boolean.valueOf(mapBusinessData.get('AllowUpdateAssetActivationDate').Business_Rule_Value__c)) {
                            if (asset.status__c == mapBusinessData.get('UpdateAssetActivationIfStatus').Business_Rule_Value__c && oldAssetMap.get(asset.id).status__c != asset.status__c) {
                                asset.Activation_Date__c = Date.today();
                            }
                        }


                        if (asset.Stock_Item__c != null) {
                            if (mapBusinessData.get('AllowStockToReturnStock') != null && mapBusinessData.get('AllowStockToReturnStock').Business_Rule_Value__c != null && Boolean.valueOf(mapBusinessData.get('AllowStockToReturnStock').Business_Rule_Value__c)) {
                                if (asset.status__c == mapBusinessData.get('AssetStatus').Business_Rule_Value__c && oldAssetMap.get(asset.id).status__c != asset.status__c &&  mapBusinessData.get('ReturningStatus') != null) {
                                    asset.Stock_Item__c = null;
                                }
                            }

                            /* if(mapBusinessData.get('AllowUpdateAssetActivationDate')!=null && mapBusinessData.get('AllowUpdateAssetActivationDate').Business_Rule_Value__c!=null && Boolean.valueOf(mapBusinessData.get('AllowUpdateAssetActivationDate').Business_Rule_Value__c)){
                                 if(asset.status__c == mapBusinessData.get('UpdateAssetActivationIfStatus').Business_Rule_Value__c && oldAssetMap.get(asset.id).status__c!=asset.status__c){
                                     asset.Activation_Date__c = Date.today();
                                 }
                             }*/


                            Set<String> fieldsToReset = new Set<String>();
                            Set<String> skipStatus = new Set<String>();
                            fieldsToReset.add('Returned_Reason__c');
                            if (asset.Stock_Item__c != null && oldAssetMap.get(asset.id).Stock_Item__c == null && mapBusinessData.get('AllowResetingStockFileds') != null && Boolean.valueOf(mapBusinessData.get('AllowResetingStockFileds').Business_Rule_Value__c)) {
                                if (mapBusinessData.get('skipResetForStatus') != null) {
                                    skipStatus.add(mapBusinessData.get('skipResetForStatus').Business_Rule_Value__c);
                                }
                                if (mapBusinessData.get('FieldsToReset') != null) {
                                    if (mapBusinessData.get('FieldsToReset').Business_Rule_Value__c.indexOf(',') > -1) {
                                        fieldsToReset.addAll(mapBusinessData.get('FieldsToReset').Business_Rule_Value__c.split(','));
                                        for (String f : fieldsToReset) {
                                            system.debug('f: ' + f);
                                            if (f.equalsIgnoreCase('status__c') && skipStatus.contains(String.valueOf(asset.get(f)))) {
                                                continue;
                                            }
                                            if (asset.get(f) == oldAssetMap.get(asset.id).get(f)) {
                                                if (M.get(f).getDescribe().getType() == Schema.DisplayType.BOOLEAN) {
                                                    asset.put(f, false);
                                                } else {
                                                    asset.put(f, null);
                                                }
                                                System.debug('f: ' + f + ' value' + asset.get(f));
                                            }
                                        }
                                    }
                                }
                            }
                            doNotOverWriteAssetStatus = new Set<String>();
                            if (mapBusinessData.get('DoNotOverWriteAssetStatus') != null) {
                                if (mapBusinessData.get('DoNotOverWriteAssetStatus').Business_Rule_Value__c.indexOf(',') > -1) {
                                    doNotOverWriteAssetStatus.addAll(mapBusinessData.get('DoNotOverWriteAssetStatus').Business_Rule_Value__c.split(','));
                                } else {
                                    doNotOverWriteAssetStatus.add(mapBusinessData.get('DoNotOverWriteAssetStatus').Business_Rule_Value__c);
                                }
                            }
                        }
                    }
                }
                System.debug('asset:1 ' + asset);

                //Sp-472
                if (asset.Stock_Item__c != null && mapBusinessData != null && !mapBusinessData.isEmpty() && mapBusinessData.get('AllowUpdateAssetStatusFromAssetPage') != null && mapBusinessData.get('AllowUpdateAssetStatusFromAssetPage').Business_Rule_Value__c != null && Boolean.valueOf(mapBusinessData.get('AllowUpdateAssetStatusFromAssetPage').Business_Rule_Value__c)) {
                    Set<String> setAssetReturnStatus = new Set<String>();
                    if (mapBusinessData.get('updateAssetStatusIfReturnedStatus').Business_Rule_Value__c != null && mapBusinessData.get('updateAssetStatusIfReturnedStatus').Business_Rule_Value__c.indexOf(',') > 1) {
                        setAssetReturnStatus.addAll(mapBusinessData.get('updateAssetStatusIfReturnedStatus').Business_Rule_Value__c.split(','));
                    } else if (mapBusinessData.get('updateAssetStatusIfReturnedStatus').Business_Rule_Value__c != null) {
                        setAssetReturnStatus.add(mapBusinessData.get('updateAssetStatusIfReturnedStatus').Business_Rule_Value__c);
                    }
                    System.debug('setAssetReturnStatus: ' + setAssetReturnStatus);
                    System.debug('con1: ' + setAssetReturnStatus.contains(asset.Initiate_Return__c));
                    System.debug('oldAssetMap.get(asset.id).Initiate_Return__c: ' + oldAssetMap.get(asset.id).Initiate_Return__c);
                    System.debug('asset.Initiate_Return__c: ' + asset.Initiate_Return__c);
                    if (setAssetReturnStatus.contains(asset.Initiate_Return__c) && oldAssetMap.get(asset.id).Initiate_Return__c != asset.Initiate_Return__c) {
                        if (asset.Status__c != mapBusinessData.get('AssetStatus').Business_Rule_Value__c) {

                            if (!doNotOverWriteAssetStatus.contains(asset.Status__c)) {
                                if (doNotOverWriteAssetStatus.contains(asset.Initiate_Return__c)) {
                                    asset.Status__c = asset.Initiate_Return__c;
                                } else {
                                    asset.Status__c = mapBusinessData.get('updateAssetStatusTo').Business_Rule_Value__c;
                                }
                            }

                            asset.Stock_Item__c = null;
                        }
                    }
                }
                if (asset.Stock_Item__c == null && oldAssetMap.get(asset.id).Stock_Item__c != null) {
                    asset.Is_Active__c = false;
                }
                System.debug('asset:2 ' + asset);
            }
        } catch (Exception e) {
            newValueAssets[0].addError('Error: ' + e.getMessage());
        }
    }



    //after update
    public static void createAssetCancellation(List<Asset__c> newValueAssets, Map<Id, Asset__c> oldAssetMap) {
        String stampTerminationField;
        Map<String, Business_Config__c> mapBusinessData;
        List<Asset_Cancellation__c> listAssetCanceled = new List<Asset_Cancellation__c>();
        //Map<Id,Set<Id>> existingMap = new Map<Id,Set<Id>>();

        List<Id> stockIds = new List<Id>();
        for (Asset__c astc : newValueAssets) {
            System.debug('Stock_Item__c: ' + astc.Stock_Item__c);
            if (astc.Stock_Item__c == null && oldAssetMap.get(astc.id).Stock_Item__c != null) {
                stockIds.add(oldAssetMap.get(astc.id).Stock_Item__c);
            }
        }
        System.debug('stockIds: ' + stockIds);
        try {
            Map<Id, Boolean> mapStockNotAssigned = new Map<Id, Boolean>();
            for (Stock_Item__c stk : [select id, (select id, Stock_Item__c from Asset_Assignment__r where Stock_Item__c != null), (select Returning_Stock_Item__c, Id from Asset_Cancellations__r where Returning_Stock_Item__c != null and return_status__c != 'No Return Needed') from Stock_Item__c where id in : stockIds]) {
                System.debug('stk.Asset_Assignment__r: ' + stk.Asset_Assignment__r);
                System.debug('stk.Asset_Cancellations__r: ' + stk.Asset_Cancellations__r);
                if (stk.Asset_Assignment__r == null && stk.Asset_Cancellations__r == null) {
                    mapStockNotAssigned.put(stk.id, true);
                } else if (stk.Asset_Assignment__r == null && stk.Asset_Cancellations__r != null && stk.Asset_Cancellations__r.size() == 1) {
                    mapStockNotAssigned.put(stk.id, true);
                } else if (stk.Asset_Cancellations__r == null && stk.Asset_Assignment__r != null && stk.Asset_Assignment__r.size() > 0) {
                    mapStockNotAssigned.put(stk.id, false);
                } else if (stk.Asset_Assignment__r != null && stk.Asset_Cancellations__r != null && stk.Asset_Assignment__r.size() > 0) {
                    mapStockNotAssigned.put(stk.id, false);
                }
            }


            System.debug('mapStockNotAssigned:' + mapStockNotAssigned);

            //Set<String> doNotOverWriteAssetStatus;
            for (Asset__c asset : newValueAssets) {
                //doNotOverWriteAssetStatus = new Set<String>();
                //if(asset.Stock_Item__c==null && oldAssetMap.get(asset.id).Stock_Item__c!=null && mapAssetStockProcessData!=null && !mapAssetStockProcessData.isEmpty() && mapAssetStockProcessData.get(mapRecordTypesForIds.get(asset.RecordTypeId).developerName)!=null){
                //    mapBusinessData = mapAssetStockProcessData.get(mapRecordTypesForIds.get(asset.RecordTypeId).developerName);
                if (asset.Stock_Item__c == null && oldAssetMap.get(asset.id).Stock_Item__c != null && mapAssetStockProcessData != null && !mapAssetStockProcessData.isEmpty() && mapAssetStockProcessData.get(LibRecordTypeHelper.getRecordTypeValue(asset.RecordTypeId)) != null) {
                    mapBusinessData = mapAssetStockProcessData.get(LibRecordTypeHelper.getRecordTypeValue(asset.RecordTypeId));

                    if (mapBusinessData != null && !mapBusinessData.isEmpty()) {
                        if (mapBusinessData.get('StampTerminationDateOnField') != null) {
                            stampTerminationField = mapBusinessData.get('StampTerminationDateOnField').Business_Rule_Value__c;
                        }
                        if (mapBusinessData.get('AllowStockToReturnStock') != null && mapBusinessData.get('AllowStockToReturnStock').Business_Rule_Value__c != null && Boolean.valueOf(mapBusinessData.get('AllowStockToReturnStock').Business_Rule_Value__c)) {
                            if (asset.status__c == mapBusinessData.get('AssetStatus').Business_Rule_Value__c && oldAssetMap.get(asset.id).status__c != asset.status__c &&  mapBusinessData.get('ReturningStatus') != null) {

                                //Asset_Cancellation__c astCan = new Asset_Cancellation__c(Asset__c=asset.id,Returning_Stock_Item__c=oldAssetMap.get(asset.id).Stock_Item__c,Return_Status__c=mapBusinessData.get('ReturningStatus').Business_Rule_Value__c,Returned_Reason__c=asset.Returned_Reason__c,RecordTypeId=mapRecordTypes.get(mapBusinessData.get('AssetCancellationRecordType').Business_Rule_Value__c).Id);
                                Asset_Cancellation__c astCan = new Asset_Cancellation__c(Asset__c = asset.id, Returning_Stock_Item__c = oldAssetMap.get(asset.id).Stock_Item__c, Return_Status__c = mapBusinessData.get('ReturningStatus').Business_Rule_Value__c, Returned_Reason__c = asset.Returned_Reason__c, RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessData.get('AssetCancellationRecordType').Business_Rule_Value__c));
                                astCan.Return_Shipping_Company__c = asset.Shipping_Company__c;
                                astCan.Activated_Date__c = asset.Activation_Date__c;
                                if (stampTerminationField != null) {
                                    astCan.put(stampTerminationField, asset.termination_date__c);
                                }
                                listAssetCanceled.add(astCan);
                                system.debug('*assetcan' + listAssetCanceled);
                            }
                        }
                    }

                }
                System.debug('asset:3 ' + asset);

                if (asset.Stock_Item__c == null && oldAssetMap.get(asset.id).Stock_Item__c != null && mapBusinessData != null && !mapBusinessData.isEmpty() && mapBusinessData.get('AllowUpdateAssetStatusFromAssetPage') != null && mapBusinessData.get('AllowUpdateAssetStatusFromAssetPage').Business_Rule_Value__c != null && Boolean.valueOf(mapBusinessData.get('AllowUpdateAssetStatusFromAssetPage').Business_Rule_Value__c)) {
                    Set<String> setAssetReturnStatus = new Set<String>();
                    if (mapBusinessData.get('updateAssetStatusIfReturnedStatus').Business_Rule_Value__c != null && mapBusinessData.get('updateAssetStatusIfReturnedStatus').Business_Rule_Value__c.indexOf(',') > 1) {
                        setAssetReturnStatus.addAll(mapBusinessData.get('updateAssetStatusIfReturnedStatus').Business_Rule_Value__c.split(','));
                    } else if (mapBusinessData.get('updateAssetStatusIfReturnedStatus').Business_Rule_Value__c != null) {
                        setAssetReturnStatus.add(mapBusinessData.get('updateAssetStatusIfReturnedStatus').Business_Rule_Value__c);
                    }
                    /*if(mapBusinessData.get('DoNotOverWriteAssetStatus')!=null){
                        if(mapBusinessData.get('DoNotOverWriteAssetStatus').Business_Rule_Value__c.indexOf(',')>-1){
                            doNotOverWriteAssetStatus.addAll(mapBusinessData.get('DoNotOverWriteAssetStatus').Business_Rule_Value__c.split(','));
                        }else{
                            doNotOverWriteAssetStatus.add(mapBusinessData.get('DoNotOverWriteAssetStatus').Business_Rule_Value__c);
                        }
                    }*/
                    System.debug('setAssetReturnStatus: ' + setAssetReturnStatus);
                    System.debug('con1: ' + setAssetReturnStatus.contains(asset.Initiate_Return__c));
                    System.debug('oldAssetMap.get(asset.id).Initiate_Return__c: ' + oldAssetMap.get(asset.id).Initiate_Return__c);
                    System.debug('asset.Initiate_Return__c: ' + asset.Initiate_Return__c);
                    System.debug('mapStockNotAssigned: ' + mapStockNotAssigned);
                    if (setAssetReturnStatus.contains(asset.Initiate_Return__c) && oldAssetMap.get(asset.id).Initiate_Return__c != asset.Initiate_Return__c) {
                        if (asset.Status__c != mapBusinessData.get('AssetStatus').Business_Rule_Value__c) {
                            //Asset_Cancellation__c astCan = new Asset_Cancellation__c(Asset__c=asset.id,Returning_Stock_Item__c=oldAssetMap.get(asset.id).Stock_Item__c,Return_Status__c=asset.Initiate_Return__c,RecordTypeId=mapRecordTypes.get(mapBusinessData.get('AssetCancellationRecordType').Business_Rule_Value__c).Id);
                            Asset_Cancellation__c astCan = new Asset_Cancellation__c(Asset__c = asset.id, Returning_Stock_Item__c = oldAssetMap.get(asset.id).Stock_Item__c, Return_Status__c = asset.Initiate_Return__c, RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessData.get('AssetCancellationRecordType').Business_Rule_Value__c));
                            astCan.Return_Shipping_Company__c = asset.Shipping_Company__c;
                            astCan.Activated_Date__c = asset.Activation_Date__c;
                            /*if(stampTerminationField!=null){
                                    astCan.put(stampTerminationField,Date.today());
                                }*/
                            if (!mapStockNotAssigned.isEmpty() && mapStockNotAssigned.get(astCan.Returning_Stock_Item__c) != null && !mapStockNotAssigned.get(astCan.Returning_Stock_Item__c)) {
                                if (mapBusinessData.get('DefaultStatusIfAssetExistwithStock') != null) {
                                    astCan.Return_Status__c = mapBusinessData.get('DefaultStatusIfAssetExistwithStock').Business_Rule_Value__c;
                                }
                            }
                            listAssetCanceled.add(astCan);
                        }
                    }
                }
                System.debug('asset:4 ' + asset);
            }
            insert listAssetCanceled;
        } catch (Exception e) {
            newValueAssets[0].addError('An error occured while updating the asset. Please contact the admin');
            system.debug('The following error occured while updating the Additional Charge Shadow object during Asset update : ' + e.getMessage() + e);
        }
    }

    public static void checkIfAssetIsInUse(List<Account> listUpdatedAccounts, Map<Id, Account> mapOldAccounts) {
        Set<Id> setAccountIdsToUncheckCheckBoxOnAsset = new Set<Id>();
        Set<Id> setAccountIdsToCheckCheckBoxOnAsset = new Set<Id>();

        //gather the ids of accounts of those which relay method has added or removed the value 'terminal';
        //these ids are used to query the assets to update
        for (Account updatedAccount : listUpdatedAccounts) {
            //if "terminal" gets added as a value
            if (updatedAccount.Relay_Method__c != null && updatedAccount.Relay_Method__c.contains('Terminal') && mapOldAccounts.get(updatedAccount.Id).Relay_Method__c != null && !mapOldAccounts.get(updatedAccount.Id).Relay_Method__c.contains('Terminal')) {
                if (!setAccountIdsToCheckCheckBoxOnAsset.contains(updatedAccount.Id)) {
                    setAccountIdsToCheckCheckBoxOnAsset.add(updatedAccount.Id);
                }
            }

            //if "terminal" gets removed as a value
            if (updatedAccount.Relay_Method__c != null && !updatedAccount.Relay_Method__c.contains('Terminal') && mapOldAccounts.get(updatedAccount.Id).Relay_Method__c != null && mapOldAccounts.get(updatedAccount.Id).Relay_Method__c.contains('Terminal')) {
                if (!setAccountIdsToUncheckCheckBoxOnAsset.contains(updatedAccount.Id)) {
                    setAccountIdsToUncheckCheckBoxOnAsset.add(updatedAccount.Id);
                }
            }
        }

        //handling of setting the checkox on asset to true
        if (!setAccountIdsToCheckCheckBoxOnAsset.isEmpty()) {
            List<Asset__c> listAssetsToUpdate = [SELECT Id, Is_Active__c FROM Asset__c WHERE Account__c IN: setAccountIdsToCheckCheckBoxOnAsset];
            if (!listAssetsToUpdate.isEmpty()) {
                listAssetsToUpdate[0].Is_Active__c = true;

                update listAssetsToUpdate;
            }
        }

        //handling of setting the checkox on asset to false
        if (!setAccountIdsToUncheckCheckBoxOnAsset.isEmpty()) {
            List<Asset__c> listAssetsToUpdate = [SELECT Id, Is_Active__c FROM Asset__c WHERE Account__c IN: setAccountIdsToUncheckCheckBoxOnAsset AND Is_Active__c = true];
            if (!listAssetsToUpdate.isEmpty()) {
                listAssetsToUpdate[0].Is_Active__c = false;

                update listAssetsToUpdate;
            }
        }


    }

    public static void updateAdditionalChargeShadowRecord(Map<Id, Asset__c> newMap, Map<Id, Asset__c> oldMap) {
        Map<Id, Stock_Item__c> stockItemMap;
        Set<Id> stockItemIds = new Set<Id>();
        Set<Id> shadowIds = new Set<Id>();
        List<Additional_Charge_Shadow__c> additionalChargeShadowToUpdate = new List<Additional_Charge_Shadow__c>();

        for (Asset__c asset : newMap.values()) {
            if (asset.Stock_Item__c != null) {
                stockItemIds.add(asset.Stock_Item__c);
            }
        }

        if (!stockItemIds.isEmpty()) {
            stockItemMap = new Map<Id, Stock_Item__c>([SELECT Id, Name, Status__c, Simcard_Number__c, SIM_Mobile_Number__c, Condition__c  FROM Stock_Item__c WHERE Id IN: stockItemIds]);
        }


        for (Asset__c asset : newMap.Values()) {

            if ((asset.Stock_Item__c != oldMap.get(asset.Id).Stock_Item__c) && (asset.Status__c == oldMap.get(asset.Id).Status__c)) {
                Additional_Charge_Shadow__c acsOld = updateAdditionalChargeShadowRecordInfo(asset, stockItemMap, false, false);
                if (acsOld != null) additionalChargeShadowToUpdate.add(acsOld);

            } else if ((asset.Stock_Item__c == oldMap.get(asset.Id).Stock_Item__c) && (asset.Status__c != oldMap.get(asset.Id).Status__c)) {
                Additional_Charge_Shadow__c acsOld = updateAdditionalChargeShadowRecordInfo(asset, stockItemMap, true, false);
                if (acsOld != null) additionalChargeShadowToUpdate.add(acsOld);
            } else {
                Additional_Charge_Shadow__c acsOld = updateAdditionalChargeShadowRecordInfo(asset, stockItemMap, true, true);
                if (acsOld != null) additionalChargeShadowToUpdate.add(acsOld);
            }
        }
        try {
            if (!additionalChargeShadowToUpdate.isEmpty()) {
                upsert additionalChargeShadowToUpdate;
            }
        } catch (Exception e) {
            newMap.values()[0].addError('An error occured while updating the asset. Please contact the admin');
            system.debug('The following error occured while updating the Additional Charge Shadow object during Asset update : ' +  e.getMessage());
        }

    }

    private static Additional_Charge_Shadow__c updateAdditionalChargeShadowRecordInfo(Asset__c asset, Map<Id, Stock_Item__c> stockItemMap, Boolean isAsset, Boolean both) {
        if (asset.Additional_Charge_Shadow__c != null) {
            Additional_Charge_Shadow__c acsOld = new Additional_Charge_Shadow__c(
                Id = asset.Additional_Charge_Shadow__c
            );
            List<Asset_Cancellation__c> listAssetCancellation = [SELECT Id, Returning_Stock_Item_Serial_No__c, Returned_Reason__c, Return_Status__c FROM Asset_Cancellation__c WHERE Asset__c = : asset.Id ];



            if (isAsset || both) {
                acsOld.Asset_Status__c = asset.Status__c != null ? asset.Status__c : null;
                //start changes for SP-502
                if (!listAssetCancellation.isEmpty()) {
                    acsOld.Asset_Returning_Stock_Item_Serial_No__c = listAssetCancellation[0].Returning_Stock_Item_Serial_No__c != null ? listAssetCancellation[0].Returning_Stock_Item_Serial_No__c : null;
                    acsOld.Asset_Return_Reason__c = listAssetCancellation[0].Returned_Reason__c != null ? listAssetCancellation[0].Returned_Reason__c : null;
                    acsOld.Asset_Return_Status__c = listAssetCancellation[0].Return_Status__c != null ? listAssetCancellation[0].Return_Status__c : null;
                }
                //end changes for SP-502
            }
            if (!isAsset || both) {
                acsOld.StockItem_Id__c = asset.Stock_Item__c != null ? stockItemMap.get(asset.Stock_Item__c).Id : null;
                acsOld.StockItem_Name__c = asset.Stock_Item__c != null ? stockItemMap.get(asset.Stock_Item__c).name : null;
                //start changes for SP-502
                acsOld.Stock_Item_SIM_Mobile_Number__c = (asset.Stock_Item__c != null && stockItemMap.get(asset.Stock_Item__c).SIM_Mobile_Number__c != null) ? stockItemMap.get(asset.Stock_Item__c).SIM_Mobile_Number__c : null;
                acsOld.Stock_Item_Stage__c = (asset.Stock_Item__c != null && stockItemMap.get(asset.Stock_Item__c).Status__c != null ) ? stockItemMap.get(asset.Stock_Item__c).Status__c : null;
                acsOld.Stock_Item_Condition__c = (asset.Stock_Item__c != null && stockItemMap.get(asset.Stock_Item__c).Condition__c != null ) ? stockItemMap.get(asset.Stock_Item__c).Condition__c : null;
                //acsOld.StockItem_Simcard_Number__c = (asset.Stock_Item__c != null && stockItemMap.get(asset.Stock_Item__c).Simcard_Number__c != null) ? stockItemMap.get(asset.Stock_Item__c).Simcard_Number__c : null;
                ////end changes for SP-502
            }
            return acsOld;
        }
        return null;
    }

    /**
    * SP-442 Stock Item received without agreement
    * @param
    *   assets: List of new Trigger values
    *   oldAssetMap:  Map of old trigger values
    * @return void
    */

    public static void stockItemFollowUp(list<Asset__c> assets, Map<Id, Asset__c> oldAssetMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('StockItemFollowUp');
        if(mapBusinessLogic == null)
        	return;
        List<Case> listCase = new List<Case>();
        for (Asset__c ass : assets) {
            //Map<String,Business_Config__c> mapBusinessRule = mapBusinessLogic.get(mapRecordTypesForIds.get(ass.recordtypeid).developerName);
            Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(ass.recordtypeid));
            if (mapBusinessRule != null && !mapBusinessRule.isEmpty()) {
                String assStatus = mapBusinessRule.get('Status').Business_Rule_Value__c;
                if (oldAssetMap.get(ass.id).status__c != assStatus && ass.status__c == assStatus) {
                    if (mapBusinessRule.get('StockFollowUpCase') != null && mapBusinessRule.get('StockFollowUpCase').Business_Rule_Value__c != null) {
                        Case cs = new Case(Opportunity__c = ass.Opportunity__c, AccountId = ass.Account__c, CurrencyIsoCode = ass.CurrencyIsoCode);
                        for (String fieldAndValue : (mapBusinessRule.get('StockFollowUpCase').Business_Rule_Value__c).split(',')) {
                            List<String> fields = fieldAndValue.split('=');
                            cs.put(fields[0], fields[1]);
                        }
                        listCase.add(cs);
                    }
                }
            }
        }
        insert listCase;
    }

    /**
    * SP-497 AU - Automate "Product Only" Opp as closed -won
    * @param
    *   assets: List of new Trigger values
    *   oldAssetMap:  Map of old trigger values
    * @return void
    */
    public static void assetStatusUpdateProcess(list<Asset__c> assets, Map<Id, Asset__c> oldAssetMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('AssetStatusUpdateProcess');
        if(mapBusinessLogic == null)
        	return;
        Map<Id, Asset__c> mapAssets = new Map<Id, Asset__c>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id, Asset__c> mapProcessAssets = new Map<Id, Asset__c>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Map<Id, String> mapRPStatus = new Map<Id, String>();
        try {
            for (Asset__c ass : [Select Id, Opportunity__r.StageName, Opportunity__c, Opportunity__r.type from Asset__c where id in : assets and Opportunity__c != null]) {
                mapAssets.put(ass.id, ass);
                oppIds.add(ass.Opportunity__c);
            }
            Map<Id, List<Asset__c>> mapOppAssets = new Map<Id, List<Asset__c>>();
            for (Asset__c ass : [select id, status__c, Opportunity__c from Asset__c where Opportunity__c in : oppIds]) {
                if (mapOppAssets.get(ass.Opportunity__c) == null) {
                    List<Asset__c> otherAsstList = new List<Asset__c>();
                    otherAsstList.add(ass);
                    mapOppAssets.put(ass.Opportunity__c, otherAsstList);
                } else {
                    List<Asset__c> otherAsstList = mapOppAssets.get(ass.Opportunity__c);
                    otherAsstList.add(ass);
                    mapOppAssets.remove(ass.Opportunity__c);
                    mapOppAssets.put(ass.Opportunity__c, otherAsstList);
                }
            }
            if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
                for (Asset__c ass : assets) {
                    //Map<String,Business_Config__c> mapBusinessRule = mapBusinessLogic.get(mapRecordTypesForIds.get(ass.recordtypeid).developerName);
                    Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(ass.recordtypeid));
                    if (mapBusinessRule != null && !mapBusinessRule.isEmpty()) {
                        if (ass.status__c == mapBusinessRule.get('Status').Business_Rule_Value__c && oldAssetMap.get(ass.id).status__c != ass.status__c) {
                            if (mapBusinessRule.get('UpdateRPStatusFromTo') != null) {
                                mapRPStatus.put(ass.id, mapBusinessRule.get('UpdateRPStatusFromTo').Business_Rule_Value__c);
                            }
                        }
                        if (mapAssets.get(ass.id).Opportunity__r.type == mapBusinessRule.get('OppType').Business_Rule_Value__c && ass.status__c == mapBusinessRule.get('Status').Business_Rule_Value__c && oldAssetMap.get(ass.id).status__c != ass.status__c && mapAssets.get(ass.id).Opportunity__r.StageName != mapBusinessRule.get('SetOppStageName').Business_Rule_Value__c && mapBusinessRule.get('chkForOpenCase') != null && !Boolean.valueof(mapBusinessRule.get('chkForOpenCase').Business_Rule_Value__c)) {
                            mapProcessAssets.put(ass.id, mapAssets.get(ass.id));
                            if (!mapOppAssets.isEmpty() && (mapOppAssets.get(ass.Opportunity__c)).size() > 1) {
                                for (Asset__c asst : mapOppAssets.get(ass.Opportunity__c)) {
                                    if (asst.id != ass.id && asst.status__c != mapBusinessRule.get('Status').Business_Rule_Value__c) {
                                        mapProcessAssets.remove(ass.id);
                                        break;
                                    }
                                }
                            }
                            oppMap.put(ass.Opportunity__c, new Opportunity(id = ass.Opportunity__c, StageName = mapBusinessRule.get('SetOppStageName').Business_Rule_Value__c, Probability = Decimal.valueOf(mapBusinessRule.get('SetOppProbability').Business_Rule_Value__c)));
                        }
                    }
                }
                Set<Opportunity> opps = new Set<Opportunity>();
                System.debug('mapProcessAssets: ' + mapProcessAssets);
                for (Asset__c ast : mapProcessAssets.values()) {
                    opps.add(oppMap.get(ast.Opportunity__c));
                }
                System.debug('opps: ' + opps);
                update new List<Opportunity>(opps);
                List<Replacement_Order__c> rps = new List<Replacement_Order__c>();
                for (Replacement_Order__c rp : [select id, status__c, Id_Asset__c from Replacement_Order__c where Id_Asset__c in: mapRPStatus.keySet()] ) {
                    List<String> fromToStatus = mapRPStatus.get(rp.Id_Asset__c).split('=');
                    if (rp.status__c == fromToStatus[0]) {
                        rp.status__c = fromToStatus[1];
                        rps.add(rp);
                    }
                }
                update rps;
            }
        } catch (Exception e) {
            System.debug('ERROR: ' + e.getMessage());
            assets[0].addError(e.getMessage());
        }
    }
    /**
    * SP - 1882 filter the assets by stage to update the opportunity in a specific stage
    * @param
    *   newList: List of new Trigger values
    *   oldMap:  Map of old trigger values
    * @return void
    */
    public static void OpportunityUpdateAssetByStatusChange(List<Asset__c> newList, Map<Id, Asset__c> oldMap){

        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('OnboardingCaseCreationAfterAssetActivationProcess');
        Map<String, Business_Config__c> mapBusinessRule;
        Set<String> stActiveStatus;
        map<Id,Asset__c> newMpAssetCreatedOnBoarding = new map<Id,Asset__c>();
        map<String,Opportunity> mpUpdateOpp = new map<string,Opportunity>();
        set<Id> oppAssetSt = new set<Id>();
        Map<Id, Asset__C> oppAssetMap = new Map<Id, Asset__c>();
        Set<Id> oppWithAddOns = new Set<Id>();

        if(mapBusinessLogic != null){


            for (Asset__c ass : newList) {
                oppAssetMap.put(ass.opportunity__c, ass);
            }

            oppWithAddOns=LibHelper.checkForNonActiveAddon(oppAssetMap.keySet());

            for(Asset__c ass: newList){
                mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(ass.RecordTypeId));
                if(mapBusinessRule != null && mapBusinessRule.containsKey('ActiveStatuses')){
                    stActiveStatus = new Set<String>(mapBusinessRule.get('ActiveStatuses').Business_Rule_Value__c.split(','));
                    if(!oppWithAddOns.contains(ass.opportunity__c)&& stActiveStatus.contains(ass.Status__c) &&(oldMap == null || ass.Status__c != oldMap.get(ass.id).Status__c)){
                        if(!mpUpdateOpp.ContainsKey(ass.opportunity__c)) {
                            if(mapBusinessRule.ContainsKey('StageOpportunity')){
                                mpUpdateOpp.put(ass.opportunity__c, new Opportunity(id = ass.opportunity__c, StageName = mapBusinessRule.get('StageOpportunity').Business_Rule_Value__c));
                                oppAssetSt.add(ass.opportunity__c);
                            }
                        }
                    }
                }
            }

            for (Opportunity opp : Opportunity_Selector.getOpportunityByIdStage(oppAssetSt,'Delivery Pending')){
                mpUpdateOpp.remove(opp.id);
            }

            if(mpUpdateOpp.size()>0){
                try{
                    update mpUpdateOpp.Values();
                }catch (Exception e){
                    LoggingUtility.logError(ClsAssetProcessor.class.getName(),'Error => ' + e.getMessage() + '\nLine Number : ' + e.getLineNumber());
                }
            }
        }

    }

    public static void opportunityUpdateonAssetStatusChange(List<Asset__c> newList, Map<Id, Asset__c> oldMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('RestaurantCareClosingAction');

        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        Set<String> assetIDs = new set<String>();
        Set<Id> oppWithAddOns = new Set<Id>();
        Map<Id, Asset__C> oppAssetMap = new Map<Id, Asset__c>();
        Map<String, Branding_content__c> oppBrandingMap = new Map<String, Branding_Content__C>();
        Map<String, String> oppBrandingStatusMapNeg = new Map<String, String>();

        if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) {
            return;
        }

        for (Asset__c a : newList) {
            if (a.status__C == 'Activated Successfully'
                    && a.status__c != oldmap.get(a.id).status__c) {
                assetIDs.add(a.id);
                if(a.opportunity__c != null) {
                    oppAssetMap.put(a.opportunity__c, a);
                }
            }
        }

        // discard already closed Opps
        for (Opportunity opp : Opportunity_Selector.getOpportunityClosed(oppAssetMap.keySet())) {
            oppAssetMap.remove(opp.Id);
        }

        for (Asset__c a : AssetSelector.getAssetsNotActivated(newList,oppAssetMap.keySet())) {
            oppAssetMap.remove(a.Opportunity__c);
        }

        // checks if there are opps
        if (oppAssetMap.isEmpty()) {
            return;
        }

        for (Branding_Content__c b : [select id, status__c, opportunity__c from branding_Content__c where opportunity__c in :oppAssetMap.keyset() and type__c Like 'White Label%']) {
            if (b.status__c != 'Installed successfully') {
                oppBrandingStatusMapNeg.put(b.Opportunity__c, b.status__c);
            }
        }

        oppWithAddOns=LibHelper.checkForNonActiveAddon(oppAssetMap.keySet());

        for (Case c : [select id, status, opportunity__c, type, Closed_Reason__c,Case_Reason__c, RecordTypeId from Case where opportunity__c in:oppAssetMap.keyset() and isClosed = true]) {
            Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(c.RecordTypeId));

            if (!oppAssetMap.containsKey(c.Opportunity__c)) {
                continue;
            }


            if (mapBusinessRule == null
                    || mapBusinessRule.isEmpty()
                    || c.Type != mapBusinessRule.get('Type').Business_Rule_Value__c
                    || c.case_reason__c !=mapBusinessRule.get('CaseReason').Business_Rule_Value__c) {
                continue;
            }

            Map<String, String> closedReason = (Map<String, String>)JSON.deserialize(mapBusinessRule.get('closingReason').Business_Rule_Value__c, Map<String, String>.class);
            Set<String> closingReasonPositiveSet = new Set<String>(closedReason.get('Positive').split(','));
            String AssetStatus;
            Boolean chkAssetStatus = false;
            String BrandingStatus;
            Boolean chkBrandingStatus = false;
            Boolean checkForNonActiveAddon = false;

            if (mapBusinessRule.get('chkAssetStatus') != null && Boolean.valueOf(mapBusinessRule.get('chkAssetStatus').Business_Rule_Value__c)) {
                chkAssetStatus = Boolean.valueOf(mapBusinessRule.get('chkAssetStatus').Business_Rule_Value__c);

                if (mapBusinessRule.get('AssetStatus') != null  ) {
                    AssetStatus = mapBusinessRule.get('AssetStatus').Business_Rule_Value__c;
                }

                if (mapBusinessRule.get('chkBrandingStatus') != null) {
                    chkBrandingStatus = Boolean.valueOf(mapBusinessRule.get('chkBrandingStatus').Business_Rule_Value__c);
                    if (mapBusinessRule.get('BrandingStatus') != null ) {
                        BrandingStatus = mapBusinessRule.get('BrandingStatus').Business_Rule_Value__c;
                    }
                }

                if (mapBusinessRule.get('CheckForAddon') != null) {
                    checkForNonActiveAddon = Boolean.valueOf(mapBusinessRule.get('CheckForAddon').Business_Rule_Value__c);
                }

                if (closingReasonPositiveSet.contains(c.Closed_Reason__c)) {
                    if (mapBusinessRule.get('PositiveStageName') != null ) {
                        if (String.isNotBlank(AssetStatus) && oppAssetMap.get(c.opportunity__c).status__c == AssetStatus) {
                            if ((!chkBrandingStatus || ( oppBrandingStatusMapNeg.get(c.opportunity__c) == null))
                                && (!checkForNonActiveAddon ||  !oppWithAddOns.contains(c.opportunity__c) )) {
                                oppsToUpdate.add(
                                    new Opportunity(
                                        Id = c.opportunity__c,
                                        StageName = mapBusinessRule.get('PositiveStageName').Business_Rule_Value__c)
                                );
                            }
                        }
                    }
                }
            }
        }

        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }

    /**
    * SP-2449 GLOBAL - Takeover/Sharing Assets connection to Source Assets
    * Copy the values from Original Source records to Takeover records
    * @param
    *   assets: List of new Trigger values
    *   oldAssetMap:  Map of old trigger values
    * @return void
    */
    public static void updateTakeoverSharingAssetValues(List<Asset__c> newList, Map<Id, Asset__c> oldMap) {
        Set<Id> sourceAssetIds = new Set<Id>();
        Set<Id> sharedSourceAssetIds = new Set<Id>();
        List<Asset__c> takeoverAssetsToUpdate = new List<Asset__c>();
        sourceAssets.clear();
        for(Asset__c ass : newList){
            if(ass.Source_Asset__c != null && ass.Source_Asset__c != oldMap.get(ass.Id).Source_Asset__c && (ass.Type__c == 'Takeover' || ass.Type__c == 'Sharing')){
                takeoverAssetsToUpdate.add(ass);
                sourceAssetIds.add(ass.Source_Asset__c);
                if(ass.Type__c == 'Sharing')
                sharedSourceAssetIds.add(ass.Source_Asset__c);
            }
        }
        //copy the value from original asset to takeover asset
        if(!sourceAssetIds.isEmpty()){
            sourceAssets = AssetSelector.getAssetsbyId(sourceAssetIds);
            for(Asset__c ass : takeoverAssetsToUpdate){
                Asset__c sourceAsset = sourceAssets.get(ass.Source_Asset__c);
                ass.Status__c = sourceAsset.Status__c;
                ass.SIM_Activated__c = sourceAsset.SIM_Activated__c;
                ass.SIM_Card_Provider__c = sourceAsset.SIM_Card_Provider__c;
                ass.SIM_Id__c = sourceAsset.SIM_Id__c;
                ass.Telephone_Number__c  = sourceAsset.Telephone_Number__c;
                ass.Stock_Item_Serial_No__c = sourceAsset.Stock_Item_Serial_No__c;
                ass.Termination_Date__c = sourceAsset.Termination_Date__c;
                ass.Activation_Date__c = sourceAsset.Activation_Date__c;
                ass.Stock_Item__c = sourceAsset.Stock_Item__c;
                if(ass.Type__c == 'Takeover')
                    ass.Type__c = 'Original';
            }
        }
        //remove source assets those connected with shared Assets
        if(!sharedSourceAssetIds.isEmpty()) {
            for (Id said: sharedSourceAssetIds){
                sourceAssets.remove(said);
            }
        }
    }
    /**
    * SP-2449 GLOBAL - Takeover/Sharing Assets connection to Source Assets
    * Update Orginal Source Asset status to - Taken Over
    * @param
    *   assets: List of new Trigger values
    *   oldAssetMap:  Map of old trigger values
    * @return void
    */
    public static void updateTakenoverAssetValues(){
        //Update the status of original asset record with Taken over value
       if(!sourceAssets.isEmpty()){
            for(Asset__c ass : sourceAssets.values()){
                ass.Stock_Item__c = null;
                ass.Status__c = 'Taken Over';
            }
           try{
               update sourceAssets.values();// can use database.update(); for better error handling
           }catch (Exception e){
               LoggingUtility.logError(ClsAssetProcessor.class.getName(),'Error => ' + e.getMessage() + '\nLine Number : ' + e.getLineNumber());
           }

        }

    }

    /**
    * SP-2449 GLOBAL - Takeover/Sharing Assets connection to Source Assets
    * Data synch from Original record to Sharing records
    * @param
    *   assets: List of new Trigger values
    *   oldAssetMap:  Map of old trigger values
    * @return void
    */

    public static void synchSharedAssetValues(List<Asset__c> newList, Map<Id, Asset__c> oldMap){

        Map<String, Map<String, Business_Config__c>> businessData = moam.get('SharedAssetDataSynch');
        Map<Id, Asset__c> identifiedAssetsToSynch = new Map<Id, Asset__c>();
        Map<Id, Set<String>> assetRcrdTypeIdAndFields = new Map<Id,Set<String>>();
        Set<String> assetFieldsToQuery = new Set<String>();

        for(Asset__c ass : newList) {
            if(ass.Type__c == 'Original') {
                Set<String> assetFieldsListToSynch = new Set<String>();
                if(businessData != null){
                    Map<String, Business_Config__c> rules = businessData.get(LibRecordTypeHelper.getRecordTypeValue(ass.RecordTypeId));
                    if(rules != null){
                        if (!assetRcrdTypeIdAndFields.containsKey(ass.RecordTypeId)) {
                            if (rules.containsKey('AssetFieldstoSynch')) {
                                assetFieldsListToSynch.addAll(rules.get('AssetFieldstoSynch').Business_Rule_Value__c.split(','));
                                assetRcrdTypeIdAndFields.put(ass.RecordTypeId, assetFieldsListToSynch);
                                assetFieldsToQuery.addAll(assetFieldsListToSynch);
                            }
                        } else {
                            assetFieldsListToSynch.addAll(assetRcrdTypeIdAndFields.get(ass.RecordTypeId));
                        }

                        for (String assetField : assetFieldsListToSynch) {
                            if (ass.get(assetField) != oldMap.get(ass.Id).get(assetField)) {
                                identifiedAssetsToSynch.put(ass.id, ass);
                                break;
                            }
                        }
                    }
                }
            }
        }

        if(!identifiedAssetsToSynch.isEmpty() && !assetFieldsToQuery.isEmpty()){
            String assetSOQLFields = 'Id, RecordtypeId, Source_Asset__c, ';
            for(String field : assetFieldsToQuery){
                assetSOQLFields += field+',';
            }
            assetSOQLFields = assetSOQLFields.removeEnd(',');
            system.debug('SOQL Fields: '+assetSOQLFields);
            Set<Id> identifiedAssetsToSynchIds = identifiedAssetsToSynch.keySet();
                    List<Asset__c> assetsToUpdate = Database.Query('SELECT '+assetSOQLFields+ ' FROM Asset__c WHERE Source_Asset__c IN : identifiedAssetsToSynchIds AND Type__c =\'Sharing\'');
            for(Asset__c sharedAsset : assetsToUpdate){
                for(String assetField : assetRcrdTypeIdAndFields.get(sharedAsset.RecordTypeId)){
                    sharedAsset.put(assetField, identifiedAssetsToSynch.get(sharedAsset.Source_Asset__c).get(assetField));
                }
            }

            try{
                Update assetsToUpdate; // Use Database Update method
            }catch (Exception e){
                LoggingUtility.logError(ClsAssetProcessor.class.getName(),'Error => ' + e.getMessage() + '\nLine Number : ' + e.getLineNumber());
            }
        }

    }

    /**
     * Change asset status according to product type.
     * Runs only before insert
     * @param assets [description]
     */
    public static void changeAssetStatusByProductType(List<Asset__c> assets) {
        Map<String, Map<String, Business_Config__c>> businessData = moam.get('ChangeAssetStatusByProductType');

        if (businessData == null) return;

        Map<Id, List<Asset__c>> oppQLIToAssets = new Map<Id, List<Asset__c>>();

        // filters valid assets
        for (Asset__c ast : assets) {

            String rtDevName = LibRecordTypeHelper.getRecordTypeValue(ast.RecordTypeId);
            
            if (!businessData.containsKey(rtDevName)) {
                continue; // skip invalid asset
            }

            if (!oppQLIToAssets.containsKey(ast.Id_Opportunity_Quote_Line_Item__c)) {
                oppQLIToAssets.put(ast.Id_Opportunity_Quote_Line_Item__c, new List<Asset__c>());
            }
            oppQLIToAssets.get(ast.Id_Opportunity_Quote_Line_Item__c).add(ast);
        }

        // checks if there's at least one valid asset
        if (oppQLIToAssets.isEmpty()) {
            return;
        }

        // gets related product type
        for (Opportunity_Quote_Line_Item__c oppQLI : [
                    SELECT
                    Id_List_Product_Price__r.Product_Type__c
                    FROM Opportunity_Quote_Line_Item__c
                    WHERE Id IN :oppQLIToAssets.keySet()
                    AND Id_List_Product_Price__c != ''
                ]) {

            // update asset status according to product type
            for (Asset__c ast : oppQLIToAssets.get(oppQLI.Id)) {

                Map<String, Business_Config__c> rules = businessData.get(LibRecordTypeHelper.getRecordTypeValue(ast.RecordTypeId));
                Map<String, String> typeToStatus = (Map<String, String>) JSON.deserialize(rules.get('productTypeToAssetStatus').Business_Rule_Value__c, Map<String, String>.class);

                if (typeToStatus.containsKey(oppQLI.Id_List_Product_Price__r.Product_Type__c)) {
                    ast.Status__c = typeToStatus.get(oppQLI.Id_List_Product_Price__r.Product_Type__c);
                }
            }
        }

        // done, no need to update this method fires before insert
    }
    
    /**
    * @Description: This method links the asset to the onboarding cases if onboarding cases are present
    */
    public static void linkAssetToOnBoardingCase(List<Asset__c> assets){
    	Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('linkAssetProcess');
    	if(mapBusinessLogic ==  null)
    		return; 
    	List<Asset__c> assetsToBeProcessed = new List<Asset__c>();
    	// Short List the assets
    	for(Asset__c asst : assets){
    		Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(asst.RecordTypeId));
    		if(mapBusinessRule != null && mapBusinessRule.get('isEnabled').Business_Rule_Value__c == 'TRUE'){
    			// replacement assets will not be linked to an onboarding case
                if(asst.Replaced_Asset__c == null) {
                    assetsToBeProcessed.add(asst);
                }
    		}
    	}
    	
    	if(assetsToBeProcessed.size() > 0){
    		// Create Asset map
    		List<Id> oppIds = new List<Id>();
    		Map<Id,Asset__c> assetMap = new Map<Id,Asset__c>();
    		for(Asset__c asst : assetsToBeProcessed){
    			assetMap.put(asst.Opportunity__c,asst);
    			oppIds.add(asst.Opportunity__c);
    		}
    		List<Case> cases = [SELECT Asset__c,Opportunity__c 
    								FROM Case
    								WHERE opportunity__c in: oppIds
    								AND type = 'Onboarding'
                                    AND case_reason__c ='Onboarding'
    								AND Status != 'Closed'
    								AND Asset__c = null];
    		
    		List<Case> casesToBeUpdated = new List<Case>();						
			if(cases.size() > 0){
				for(Case cs : cases){
					cs.Asset__c = assetMap.get(cs.Opportunity__c).Id;
					casesToBeUpdated.add(cs);
				}
			}
			
			if(casesToBeUpdated.size() > 0){
				update casesToBeUpdated;
			}
    	}
    }

    /**
     * @description  Copy account country to assets
     *
     * @param assets
     *
     */
    public static void updateRecordCountry(List<Asset__c> assets) {
        Set<Id> accountIds = ClsSObjectUtils.extractSetIds(assets, Asset__c.Account__c.getDescribe().getLocalName());
        Map<Id,Account> accountMap = new Map<Id, Account>(AccountSelector.getByIds(accountIds));
        for (Asset__c asset: assets) {
            if (asset.Account__c == null || !accountMap.containsKey(asset.Account__c)) {
                continue;
            }
            asset.Account_Country__c = accountMap.get(asset.Account__c).Record_Country__c;
        }
    }
}