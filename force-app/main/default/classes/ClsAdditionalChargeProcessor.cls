public without sharing class ClsAdditionalChargeProcessor {
    //private static Map<String,RecordType> mapRecordTypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Additional_Charge_Shadow__c'});
    //private static Map<Id,RecordType> mapRecordTypesForIds = LibRecordTypeHelper.getRecordTypeForIds(new Set<String>{'Additional_Charges__c'});
    private static Map<String, Map<String,Map<String,Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
        
    public static void createAdditionalChargeShadow(List<Additional_Charges__c> additionalCharges){
        List<Additional_Charge_Shadow__c> additionalChargeShadows = new List<Additional_Charge_Shadow__c>();
        Map<Id, Additional_Charge_Shadow__c> additionalChargeIdShadowsMap = new Map<Id, Additional_Charge_Shadow__c>();
        Set<Id> assetIds = new Set<Id>();
        Set<Id> acIds = new Set<Id>();
        Map<Id, Id> assetIdShadowIdMap = new Map<Id, Id>();
        //Map<String,Map<String,Business_Config__c>> mapProcessData= LibBusinessConfig.getGenericProcessData('Custom Report Settings');
        Map<String,Map<String,Business_Config__c>> mapProcessData= moam.get('Custom Report Settings');
        Map<String,Business_Config__c> mapBusinessData;
        if(mapProcessData!=null && !mapProcessData.isEmpty()){
          for(Additional_Charges__c ac : additionalCharges){
            /*if(mapRecordTypesForIds!=null && !mapRecordTypesForIds.isEmpty()){
              if(mapProcessData.get(mapRecordTypesForIds.get(ac.RecordTypeId).DeveloperName) != null){
                  mapBusinessData = mapProcessData.get(mapRecordTypesForIds.get(ac.RecordTypeId).DeveloperName);*/
                String recordtypeName = LibRecordTypeHelper.getRecordTypeValue(ac.RecordTypeId);
                if(recordtypeName!=null){
                if(mapProcessData.get(recordtypeName) != null){
                    mapBusinessData = mapProcessData.get(recordtypeName);
                  if(mapBusinessData.get('createAdditionalChargeShadow') != null && String.isNotBlank(mapBusinessData.get('createAdditionalChargeShadow').Business_Rule_Value__c) && !mapBusinessData.get('createAdditionalChargeShadow').Business_Rule_Value__c.equals('false')){
                      acIds.add(ac.Id);
                      if(!assetIds.contains(ac.Id_Asset__c)){
                          assetIds.add(ac.Id_Asset__c);
                      }
                  }
              }
            }
          }
      }
        system.debug('@@@@ createAdditionalChargeShadow - acIds : ' + acIds);

        //key => AssetId, value => cancellation object
        Map<String,Asset_Cancellation__c> mapAssetCancellations = new Map<String,Asset_Cancellation__c>();
        for(Asset_Cancellation__c assetCan : [SELECT Id, Asset__c, Returning_Stock_Item_Serial_No__c, Returned_Reason__c, Return_Status__c FROM Asset_Cancellation__c WHERE Asset__c =:assetIds ]){
            mapAssetCancellations.put(assetCan.Asset__c, assetCan);
        }

        for(Additional_Charge_Shadow__c acs : [SELECT Id, Additional_Charge__c FROM Additional_Charge_Shadow__c WHERE Additional_Charge__c IN: acIds]){
            additionalChargeIdShadowsMap.put(acs.Additional_Charge__c, acs);
        }
        system.debug('@@@@ createAdditionalChargeShadow - additionalChargeIdShadowsMap : ' + additionalChargeIdShadowsMap);

        for(Additional_Charges__c ac : [
                                        SELECT 
                                            Id, Name, CreatedDate, Start_Date__c, Termination_Date__c, Termination_Reason__c, Total_Amount__c, CurrencyIsoCode,
                                            Id_Account__r.Name, Id_Account__r.Id, Id_Account__r.Company_Number__c, Id_Account__r.Company_Code__c,
                                            Id_Opportunity__r.Amount, 
                                            Id_Asset__r.Id, Id_Asset__r.Name, Id_Asset__r.Date_Shipped__c, Id_Asset__r.Return_Due_Date__c, Id_Asset__r.Status__c, Id_Asset__r.First_Payment_Date__c, Id_Asset__r.Charge_Free__c, Id_Asset__r.Bill_Number__c,
                                            Id_Asset__r.Stock_Item__r.Id, Id_Asset__r.Stock_Item__r.Name, Id_Asset__r.Stock_Item__r.Status__c, Id_Asset__r.Stock_Item__r.SIM_Mobile_Number__c,
                                            Id_Asset__r.Returning_Stock_Item_Serial_No__c, Id_Asset__r.Returned_Reason__c, Id_Asset__r.Retour_Status__c,
                                            Id_Asset__r.Stock_Item__r.Condition__c
                                        FROM Additional_Charges__c 
                                        WHERE Id IN: acIds]){

            
            if(ac.Id_Asset__r.Id != null && !assetIds.contains(ac.Id_Asset__r.Id)){
                assetIds.add(ac.Id_Asset__r.Id);
            }
            Additional_Charge_Shadow__c acs = new Additional_Charge_Shadow__c(
                //start changes for SP-502
                Asset_Returning_Stock_Item_Serial_No__c = mapAssetCancellations.get(ac.Id_Asset__r.Id) != null && mapAssetCancellations.get(ac.Id_Asset__r.Id).Returning_Stock_Item_Serial_No__c != null ? mapAssetCancellations.get(ac.Id_Asset__r.Id).Returning_Stock_Item_Serial_No__c : null, 
                //Asset_Returning_Stock_Item_Serial_No__c = ac.Id_Asset__r.Returning_Stock_Item_Serial_No__c != null ? ac.Id_Asset__r.Returning_Stock_Item_Serial_No__c : null,
                Asset_Return_Reason__c = mapAssetCancellations.get(ac.Id_Asset__r.Id) != null && mapAssetCancellations.get(ac.Id_Asset__r.Id).Returned_Reason__c != null ? mapAssetCancellations.get(ac.Id_Asset__r.Id).Returned_Reason__c : null,
                //Asset_Return_Reason__c = ac.Id_Asset__r.Returned_Reason__c != null ? ac.Id_Asset__r.Returned_Reason__c : null,
                Asset_Return_Status__c = mapAssetCancellations.get(ac.Id_Asset__r.Id) != null && mapAssetCancellations.get(ac.Id_Asset__r.Id).Return_Status__c != null ? mapAssetCancellations.get(ac.Id_Asset__r.Id).Return_Status__c : null,
                //Asset_Return_Status__c = ac.Id_Asset__r.Retour_Status__c != null ? ac.Id_Asset__r.Retour_Status__c : null,
                Stock_Item_SIM_Mobile_Number__c = ac.Id_Asset__r.Stock_Item__r.SIM_Mobile_Number__c != null ? ac.Id_Asset__r.Stock_Item__r.SIM_Mobile_Number__c : null,
                Stock_Item_Stage__c = ac.Id_Asset__r.Stock_Item__r.Status__c != null ? ac.Id_Asset__r.Stock_Item__r.Status__c : null,
                Stock_Item_Condition__c = ac.Id_Asset__r.Stock_Item__r.Condition__c != null ? ac.Id_Asset__r.Stock_Item__r.Condition__c : null, 
                //end changes for SP-502
                Additional_Charge__c = ac.Id,
                CurrencyIsoCode = ac.CurrencyIsoCode,
                AC_Name__c = ac.Name,
                AC_Total_Amount__c = ac.Total_Amount__c != null ? ac.Total_Amount__c : null,
                AC_Start_Date__c = ac.Start_Date__c,
                AC_Termination_Date__c = ac.Termination_Date__c != null ? ac.Termination_Date__c : null,
                AC_Termination_Reason__c = ac.Termination_Reason__c != null ? ac.Termination_Reason__c : null,
                AC_CreatedDate__c = ac.CreatedDate,
                Account_Id__c = ac.Id_Account__r.Id,
                Account_Name__c = ac.Id_Account__r.Name,
                Account_Company_Number__c = ac.Id_Account__r.Company_Number__c != null ? ac.Id_Account__r.Company_Number__c : null,
                Opportunity_Amount__c = ac.Id_Opportunity__r.Amount != null ? ac.Id_Opportunity__r.Amount : null,
                Asset_Id__c = ac.Id_Asset__r.Id,
                Asset_Name__c = ac.Id_Asset__r.Name,
                Asset_Return_Due_Date__c = ac.Id_Asset__r.Return_Due_Date__c != null ? ac.Id_Asset__r.Return_Due_Date__c : null,
                Asset_Date_Shipped__c = ac.Id_Asset__r.Date_Shipped__c != null ? ac.Id_Asset__r.Date_Shipped__c : null,
                Asset_First_Payment_Date__c = ac.Id_Asset__r.First_Payment_Date__c != null ? ac.Id_Asset__r.First_Payment_Date__c : null,
                Asset_Status__c = ac.Id_Asset__r.Status__c != null ? ac.Id_Asset__r.Status__c : null,
                Asset_Charge_Free__c = ac.Id_Asset__r.Charge_Free__c,
                Asset_Bill_Number__c = ac.Id_Asset__r.Bill_Number__c,
                StockItem_Id__c = ac.Id_Asset__r.Stock_Item__r.Id,
                StockItem_Name__c = ac.Id_Asset__r.Stock_Item__r.Name
                //StockItem_Simcard_Number__c = ac.Id_Asset__r.Stock_Item__r.Simcard_Number__c != null ? ac.Id_Asset__r.Stock_Item__r.Simcard_Number__c : null
            );

            // set the id which is required by the upsert fxn to function properly
            if(!additionalChargeIdShadowsMap.isEmpty() && additionalChargeIdShadowsMap.get(ac.Id) != null){
                acs.Id = additionalChargeIdShadowsMap.get(ac.Id).Id;
            }

            // Set record type
            if(ac.Id_Account__r.Company_Code__c != null){
                //if(mapRecordTypesForIds!=null && !mapRecordTypesForIds.isEmpty()){
                    //acs.RecordTypeId = mapRecordTypes.get(ac.Id_Account__r.Company_Code__c  + '_Add_l_Charge_Shadow').Id;
                    acs.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(ac.Id_Account__r.Company_Code__c  + '_Add_l_Charge_Shadow');
                 //}
            }
            additionalChargeShadows.add(acs);
        }

        if(!additionalChargeShadows.isEmpty()){
            try {
                system.debug('@@@@ createAdditionalChargeShadow - additionalChargeShadows : ' + additionalChargeShadows);
                upsert additionalChargeShadows;

                List<Asset__c> assets = [SELECT Id, Additional_Charge_Shadow__c FROM Asset__c WHERE Id IN: assetIds];
                system.debug('@@@@ createAdditionalChargeShadow - assets : ' + assets);

                if(!assets.isEmpty()){
                    for(Additional_Charge_Shadow__c acs : additionalChargeShadows){
                        if(acs.Asset_Id__c != null){
                            assetIdShadowIdMap.put((Id)acs.Asset_Id__c, acs.Id);    
                        }
                    }
                    for(Asset__c asset : assets){
                        asset.Additional_Charge_Shadow__c = assetIdShadowIdMap.get(asset.Id);
                    }
                    update assets;
                }
            } catch(Exception e){
                additionalChargeShadows[0].addError('An error occured. Please contact the admin');
                system.debug('The following error occured while created additional charge shadow objects : ' +  e.getMessage());
            }
        }
    }


    public static void createEntryCaseForFlatCommissionCancelation(List<Additional_Charges__c> additionalCharges, Map<Id,Additional_Charges__c> oldMap){
        //Map<String,Map<String,Business_Config__c>> mapProcessData= LibBusinessConfig.getGenericProcessData('FlatCommissionAddChargeTerminate');
        Map<String,Map<String,Business_Config__c>> mapProcessData= moam.get('FlatCommissionAddChargeTerminate');
        Map<String,Business_Config__c> mapBusinessData;
        List<Case> listCase  = new List<Case>();
        Map<Id,Additional_Charges__c> mapOfOppIdWithAddCharge = new Map<Id,Additional_Charges__c>();
        Map<Id,String> oppWithAddIdsMap = new Map<Id,String>();
        try{
            if(mapProcessData!=null && !mapProcessData.isEmpty()){
                for(Additional_Charges__c ac : additionalCharges){
                    //mapBusinessData = mapProcessData.get(mapRecordTypesForIds.get(ac.RecordTypeId).DeveloperName);
                    mapBusinessData = mapProcessData.get(LibRecordTypeHelper.getRecordTypeValue(ac.RecordTypeId));
                    System.debug('ac.Type__c: '+ac.Type__c);
                    System.debug('ac.Termination_Date__c: '+ac.Termination_Date__c);
                    
                    if(mapBusinessData!=null && !mapBusinessData.isEmpty() && ac.Type__c == mapBusinessData.get('API_Type').Business_Rule_Value__c && ac.Termination_Date__c!=null && ac.Termination_Date__c!=oldMap.get(ac.id).Termination_Date__c){
                        mapOfOppIdWithAddCharge.put(ac.Id_Opportunity__c,ac);
                        String addChDetails = ac.name+' / '+ac.District__c+' / '+ac.Category__c+' / '+ac.Start_Date__c.format()+' / '+ac.Termination_Date__c.format()+' / '+ac.Total_Amount__c;
                        if(oppWithAddIdsMap.get(ac.Id_Opportunity__c)!=null){
                            String addChargeIds = oppWithAddIdsMap.get(ac.Id_Opportunity__c)+',\n'+addChDetails;
                            oppWithAddIdsMap.remove(ac.Id_Opportunity__c);
                            oppWithAddIdsMap.put(ac.Id_Opportunity__c,addChargeIds);
                        }else{
                            oppWithAddIdsMap.put(ac.Id_Opportunity__c,addChDetails);
                        }
                    }
                }
                // loop for the creation of Entry case 
                for(Additional_Charges__c  addch : mapOfOppIdWithAddCharge.values()){
                    //Map<String,Business_Config__c> mapBusinessRules = mapProcessData.get(mapRecordTypesForIds.get(addch.RecordTypeId).DeveloperName);
                    Map<String,Business_Config__c> mapBusinessRules = mapProcessData.get(LibRecordTypeHelper.getRecordTypeValue(addch.RecordTypeId));
                    if(mapBusinessRules!=null && !mapBusinessRules.isEmpty()){
                        if(mapBusinessRules.get('EntryCase')!=null && mapBusinessRules.get('EntryCase').Business_Rule_Value__c!=null){
                            Case cs = new Case(Opportunity__c=addch.Id_Opportunity__c,AccountId=addch.Id_Account__c,CurrencyIsoCode=addch.CurrencyIsoCode);
                            cs.description = oppWithAddIdsMap.get(addch.Id_Opportunity__c);
                            for(String fieldAndValue : (mapBusinessRules.get('EntryCase').Business_Rule_Value__c).split(',')){
                                List<String> fields = fieldAndValue.split('=');
                                cs.put(fields[0],fields[1]);
                            }
                            listCase.add(cs);
                        }
                    }
                    
                }               
                insert listCase;
            }
        }catch(Exception e){
            additionalCharges[0].addError(e.getMessage());
            System.debug('error at additional charge trigger: '+e.getMessage());
        }
    }
    /**
     * @description populates Product_Group__c, Id_List_Product_Price__c fields after update of Product__c field 
     *
     * @param additionalCharges - list of new Additional_Charges__c records
     * @param oldMap - map of old Additional_Charges__c records
     *
     * @return
     */
    public static void populateFieldsAfterProductUpdate(List<Additional_Charges__c> additionalCharges, Map<Id,Additional_Charges__c> oldMap){

        Map<String,Map<String,Business_Config__c>> mapProcessData= moam.get('populateFieldsAfterProductUpdate');
        if (mapProcessData == null || mapProcessData.isEmpty()) {

            return;
        }
        Map<String, List<Additional_Charges__c>> filteredProductToChargeMap = new  Map<String, List<Additional_Charges__c>>();
        Set<String> recordTypeSet = new Set<String>();
        Set<String> productSet = new Set<String>(); 
        for (Additional_Charges__c additionalCharge : additionalCharges) {

            Map<String,Business_Config__c> rulesMap = mapProcessData.get(LibRecordTypeHelper.getRecordTypeValue(additionalCharge.RecordTypeId));
            if (rulesMap == null || rulesMap.isEmpty() || rulesMap.get('ListProductPriceRecordType') == null) {

                continue;
            } 
            if (additionalCharge.Product__c != oldMap.get(additionalCharge.Id).Product__c) {

                recordTypeSet.add(rulesMap.get('ListProductPriceRecordType').Business_Rule_Value__c);
                productSet.add(additionalCharge.Product__c);
                if (filteredProductToChargeMap.get(additionalCharge.Product__c) != null) {

                    filteredProductToChargeMap.get(additionalCharge.Product__c+rulesMap.get('ListProductPriceRecordType').Business_Rule_Value__c).add(additionalCharge);   
                } else {

                    List<Additional_Charges__c> chargesForProduct = new List<Additional_Charges__c>();
                    chargesForProduct.add(additionalCharge);
                    filteredProductToChargeMap.put(additionalCharge.Product__c+rulesMap.get('ListProductPriceRecordType').Business_Rule_Value__c,chargesForProduct);
                }
            }
        }  
        List<List_Product_Price__c> listOfListProductPrices = ListProductPriceSelector.getListProductPriceRecordsFilteredByRecordTtype(recordTypeSet, productSet);
        for (List_Product_Price__c listProductPrice : listOfListProductPrices) {

            List<Additional_Charges__c> additionalChargesToUpdate = filteredProductToChargeMap.get(listProductPrice.Displayed_Name__c+listProductPrice.RecordType.DeveloperName);
            for (Additional_Charges__c chargeToUpdate : additionalChargesToUpdate) {

                chargeToUpdate.Product_Group__c = listProductPrice.Id_List_Product_Group__r.Name;
            }
        }     
    }
     /**
     * @description this method prevents self-approval for Approval Process for Additional Charegs  
     *
     * @param newAdditionalCharges - map of new Additional_Charges__c records
     *
     * @return
     */
     public static void preventSelfApproval(Map<Id, Additional_Charges__c> newAdditionalCharges) {

        Set<Id> approvedAddChargesIds = new Set<Id>(); 
        for (Id addChargeId : newAdditionalCharges.keyset()) {

            if (newAdditionalCharges.get(addChargeId).Run_Approval_Trigger__c) {

                approvedAddChargesIds.add(addChargeId);
            }
        }
        List<Additional_Charges__c> approvedCharges = AdditionalChargesSelector.getAdditionalChargesWithProcessInstances(approvedAddChargesIds);
        Id currentUserId = userInfo.getUserId();
        for (Additional_Charges__c approvedCharge : approvedCharges) {
            
            if (currentUserId == approvedCharge.ProcessInstances[0].SubmittedById) {

                newAdditionalCharges.get(approvedCharge.Id).addError(Label.Approval_Process_Self_Approval_Error);
            } else {

                newAdditionalCharges.get(approvedCharge.Id).Run_Approval_Trigger__c = false;
            }
        } 

    }
}