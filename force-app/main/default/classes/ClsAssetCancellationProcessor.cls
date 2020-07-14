public without sharing class ClsAssetCancellationProcessor {
	//private static Map<Id,RecordType> mapRecordTypesForIds = LibRecordTypeHelper.getRecordTypeForIds(new Set<String>{'Asset_Cancellation__c'});
	private static Map<String, Map<String,Map<String,Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
	//private static Map<String,Map<String,Business_Config__c>> mapassetCancellationProcessData = LibBusinessConfig.getGenericProcessData('AssetCancellationProcess');
	private static Map<String,Map<String,Business_Config__c>> mapassetCancellationProcessData = moam.get('AssetCancellationProcess');
	public static Set<Id> stockIdToUpdate = new Set<Id>();

	public static void assetCancellationProcess(List<Asset_Cancellation__c> newList, Map<Id,Asset_Cancellation__c> oldMap){
		 Map<String,Business_Config__c> mapBusinessData;
		 //Set<Stock_Item__c> updateStock = new Set<Stock_Item__c>();
		 Map<Id,Stock_Item__c> mapUpdateStock = new Map<Id,Stock_Item__c>();
		 List<Id> AssetIds = new List<Id>();
		 List<Id> stockIds = new List<Id>();
		for(Asset_Cancellation__c astc : newList){
			if(astc.Returning_Stock_Item__c!=null){
				stockIds.add(astc.Returning_Stock_Item__c);	
			}
		}

		 Map<Id,Boolean> mapStockNotAssigned = new Map<Id,Boolean>();


		 for(Stock_Item__c stk: [select id, (select id, Stock_Item__c from Asset_Assignment__r where Stock_Item__c!=null),(select Returning_Stock_Item__c,Id from Asset_Cancellations__r where Returning_Stock_Item__c!=null and return_status__c!='No Return Needed') from Stock_Item__c where id in : stockIds]){
            	System.debug('stk.Asset_Assignment__r1: '+stk.Asset_Assignment__r);
            	System.debug('stk.Asset_Cancellations__r1: '+stk.Asset_Cancellations__r);
            	if(stk.Asset_Assignment__r.isEmpty() && stk.Asset_Cancellations__r.isEmpty()){
            		mapStockNotAssigned.put(stk.id,true);
            	}else if(stk.Asset_Assignment__r.isEmpty() && !stk.Asset_Cancellations__r.isEmpty() && stk.Asset_Cancellations__r.size()==1){
            		mapStockNotAssigned.put(stk.id,true);
            	}else if(stk.Asset_Cancellations__r.isEmpty() && !stk.Asset_Assignment__r.isEmpty() && stk.Asset_Assignment__r.size()>1){
            		mapStockNotAssigned.put(stk.id,false);
            	}else if(!stk.Asset_Assignment__r.isEmpty() && !stk.Asset_Cancellations__r.isEmpty() && stk.Asset_Assignment__r.size()>1){
                    mapStockNotAssigned.put(stk.id,false);
                }else if(!stk.Asset_Assignment__r.isEmpty() && !stk.Asset_Cancellations__r.isEmpty() && stk.Asset_Assignment__r.size()>0){
                    mapStockNotAssigned.put(stk.id,false);
                }else if(stk.Asset_Assignment__r.isEmpty() && !stk.Asset_Cancellations__r.isEmpty()){
                    mapStockNotAssigned.put(stk.id,true);
                }
            }
		 try{
			if(mapassetCancellationProcessData!=null && !mapassetCancellationProcessData.isEmpty()){
				for(Asset_Cancellation__c astCan : newList){
					//mapBusinessData = mapassetCancellationProcessData.get(mapRecordTypesForIds.get(astCan.RecordTypeId).developerName);
					mapBusinessData = mapassetCancellationProcessData.get(LibRecordTypeHelper.getRecordTypeValue(astCan.RecordTypeId));
					if(astCan.Returning_Stock_Item__c!=null && mapBusinessData!=null && !mapBusinessData.isEmpty()){
						Stock_Item__c updatedStock = new Stock_Item__c();
	                    if(mapBusinessData.get('AllowUpdateStockStatusUpdate')!=null && mapBusinessData.get('AllowUpdateStockStatusUpdate').Business_Rule_Value__c!=null && Boolean.valueOf(mapBusinessData.get('AllowUpdateStockStatusUpdate').Business_Rule_Value__c)){
	                        if(astCan.Return_Status__c!=null && astCan.Return_Status__c==mapBusinessData.get('updateStockStatusIfAssetReturn').Business_Rule_Value__c && (oldMap==null || (oldMap!=null && oldMap.get(astCan.id)!=null && astCan.Return_Status__c!=oldMap.get(astCan.id).Return_Status__c))){
	                            updatedStock.id=astCan.Returning_Stock_Item__c;
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
	                        if(astCan.Return_Status__c!=null && setAssetReturnStatus.contains(astCan.Return_Status__c) && (oldMap==null || (oldMap!=null && oldMap.get(astCan.id)!=null && astCan.Return_Status__c!=oldMap.get(astCan.id).Return_Status__c))){
	                            updatedStock.id=astCan.Returning_Stock_Item__c;
	                            updatedStock.status__c=mapBusinessData.get('updateStockInShipmentStatusTo').Business_Rule_Value__c;
	                        }
	                    }
	                    System.debug('mapStockNotAssigned: '+mapStockNotAssigned);
	                    if(updatedStock.status__c!=null){
	                    	if(mapStockNotAssigned.isEmpty()){
	                    		mapUpdateStock.put(updatedStock.id,updatedStock);
	                    		//updateStock.add(updatedStock);
                    		}else if(!mapStockNotAssigned.isEmpty() && mapStockNotAssigned.get(astCan.Returning_Stock_Item__c)!=null && !mapStockNotAssigned.get(astCan.Returning_Stock_Item__c)){
                    		}else if(!mapStockNotAssigned.isEmpty() && mapStockNotAssigned.get(astCan.Returning_Stock_Item__c)!=null && mapStockNotAssigned.get(astCan.Returning_Stock_Item__c)){
                    			//updateStock.add(updatedStock);
                    			mapUpdateStock.put(updatedStock.id,updatedStock);
                    		}
	                    }
					}
				}
				//update new List<Stock_Item__c>(updateStock);
				update mapUpdateStock.values();
			}
		}catch(Exception e){
            newList[0].addError(e.getMessage());
        }
	}


	public static void assetCancellationBeforeHandler(List<Asset_Cancellation__c> newAsstCans, Map<Id,Asset_Cancellation__c> oldMap,Boolean isInsert){
		Map<String,Business_Config__c> mapBusinessData;
		List<Id> stockIds = new List<Id>();
		System.debug('newAsstCans: '+newAsstCans);
		for(Asset_Cancellation__c astc : newAsstCans){
		 	if(astc.Returning_Stock_Item__c!=null){
		 		stockIds.add(astc.Returning_Stock_Item__c);	
		 	}
		}
		system.debug('stockIds: '+stockIds);
		Map<Id,Boolean> mapStockNotAssigned = new Map<Id,Boolean>();
		try{
			for(Stock_Item__c stk: [select id, (select id, Stock_Item__c from Asset_Assignment__r where Stock_Item__c!=null),(select Returning_Stock_Item__c,Id from Asset_Cancellations__r where Returning_Stock_Item__c!=null and return_status__c!='No Return Needed') from Stock_Item__c where id in : stockIds]){
	        	System.debug('stk.Asset_Assignment__r2: '+stk.Asset_Assignment__r);
            	System.debug('stk.Asset_Cancellations__r2: '+stk.Asset_Cancellations__r);
	        	if(stk.Asset_Assignment__r.isEmpty() && stk.Asset_Cancellations__r.isEmpty()){
	        		mapStockNotAssigned.put(stk.id,true);
	        	}else if(stk.Asset_Assignment__r.isEmpty() && !stk.Asset_Cancellations__r.isEmpty() && stk.Asset_Cancellations__r.size()==1){
	        		mapStockNotAssigned.put(stk.id,true);
	        	}else if(isInsert && stk.Asset_Cancellations__r.isEmpty() && !stk.Asset_Assignment__r.isEmpty() && stk.Asset_Assignment__r.size()>0){
	        		mapStockNotAssigned.put(stk.id,false);
	        	}else if(!isInsert && stk.Asset_Cancellations__r.isEmpty() && !stk.Asset_Assignment__r.isEmpty() && stk.Asset_Assignment__r.size()>0){
	        		mapStockNotAssigned.put(stk.id,true);
	        	}else if(isInsert && !stk.Asset_Assignment__r.isEmpty() && !stk.Asset_Cancellations__r.isEmpty() && stk.Asset_Assignment__r.size()>0){
                    mapStockNotAssigned.put(stk.id,false);
                }else if(!isInsert && !stk.Asset_Assignment__r.isEmpty() && !stk.Asset_Cancellations__r.isEmpty() && stk.Asset_Assignment__r.size()>0){
                    mapStockNotAssigned.put(stk.id,true);
                }else if(stk.Asset_Assignment__r.isEmpty() && !stk.Asset_Cancellations__r.isEmpty()){
                	mapStockNotAssigned.put(stk.id,true);
                }
	        }
	        System.debug('mapStockNotAssigned: '+mapStockNotAssigned);
			if(mapassetCancellationProcessData!=null && !mapassetCancellationProcessData.isEmpty()){
				for(Asset_Cancellation__c astCan : newAsstCans){
					//system.debug('mapRecordTypesForIds: '+mapRecordTypesForIds);
					system.debug('astCan'+astCan);
					//System.debug('mapRecordTypesForIds.get(astCan.RecordTypeId).developerName: '+mapRecordTypesForIds.get(astCan.RecordTypeId).developerName);
					system.debug('mapassetCancellationProcessData: '+mapassetCancellationProcessData);
					mapBusinessData = mapassetCancellationProcessData.get(LibRecordTypeHelper.getRecordTypeValue(astCan.RecordTypeId));
					if(astCan.Return_Status__c!=null && mapBusinessData!=null && !mapBusinessData.isEmpty()){
						if(mapBusinessData.get('AllowUpdateWarehouseDate')!=null && mapBusinessData.get('AllowUpdateWarehouseDate').Business_Rule_Value__c!=null && Boolean.valueOf(mapBusinessData.get('AllowUpdateWarehouseDate').Business_Rule_Value__c)){
		                    
		                    if(astCan.Return_Status__c == mapBusinessData.get('UpdateWarehouseDateIfAssetRStatus').Business_Rule_Value__c && (oldMap==null || (oldMap!=null && oldMap.get(astCan.id)!=null && oldMap.get(astCan.id).Return_Status__c!=astCan.Return_Status__c))){
		                        if(mapStockNotAssigned.isEmpty() || (!mapStockNotAssigned.isEmpty() && mapStockNotAssigned.get(astCan.Returning_Stock_Item__c)!=null && mapStockNotAssigned.get(astCan.Returning_Stock_Item__c))){
		                        	astCan.Warehouse_Return_Date__c = Date.today();
	                        	}else{
	                        		astCan.Return_Status__c = mapBusinessData.get('DefaultStatusIfAssetExistwithStock').Business_Rule_Value__c;
	                        	}
		                    }else if(!mapStockNotAssigned.isEmpty() && mapStockNotAssigned.get(astCan.Returning_Stock_Item__c)!=null && !mapStockNotAssigned.get(astCan.Returning_Stock_Item__c)){
		                    	astCan.Return_Status__c = mapBusinessData.get('DefaultStatusIfAssetExistwithStock').Business_Rule_Value__c;
		                    }
		                }else if(!mapStockNotAssigned.isEmpty() && mapStockNotAssigned.get(astCan.Returning_Stock_Item__c)!=null && !mapStockNotAssigned.get(astCan.Returning_Stock_Item__c)){
		                   	astCan.Return_Status__c = mapBusinessData.get('DefaultStatusIfAssetExistwithStock').Business_Rule_Value__c;
		                }
					}
				}
			}
		}catch(Exception e){
			newAsstCans[0].addError(e.getMessage());
		}
	}

	//before trigger
	public static void setStockUsedDays(List<Asset_Cancellation__c> newList, Map<Id,Asset_Cancellation__c> oldMap){
		//Map<Id,Integer> mapStockIdWithUsedDays = new Map<Id,Integer>();
		//List<Stock_Item__c> updateStock = new List<Stock_Item__c>();
		
		Boolean processFlag = false;
		for(Asset_Cancellation__c astCan : newList){
			processFlag = false;
			if(astCan.Activated_Date__c!=null){
				if(oldMap!=null && !oldMap.isEmpty() && oldMap.get(astCan.Id).Return_Request_Date__c!=astCan.Return_Request_Date__c && astCan.Return_Request_Date__c >= astCan.Activated_Date__c){
					processFlag = true;
					stockIdToUpdate.add(astCan.Returning_Stock_Item__c);
				}else if(oldMap==null && astCan.Return_Request_Date__c!=null && astCan.Return_Request_Date__c >= astCan.Activated_Date__c){
					processFlag = true;
					if(astCan.Return_Status__c=='No Return Needed'){
						stockIdToUpdate.add(astCan.Returning_Stock_Item__c);
					}
				}
				if(processFlag){
					astCan.Stock_Used__c = Math.abs( astCan.Return_Request_Date__c.daysBetween(astCan.Activated_Date__c)) + 1;
					/*if(!mapStockIdWithUsedDays.isEmpty() && mapStockIdWithUsedDays.get(astCan.Returning_Stock_Item__c)!=null){
						Integer days = mapStockIdWithUsedDays.get(astCan.Returning_Stock_Item__c) + Integer.valueOf(astCan.Stock_Used__c);
						mapStockIdWithUsedDays.put(astCan.Returning_Stock_Item__c,days);
					}else{
						mapStockIdWithUsedDays.put(astCan.Returning_Stock_Item__c,Integer.valueOf(astCan.Stock_Used__c));
					}*/
				}
			}
		}
		/*for(Stock_Item__c stk : [select Id, Total_Days_In_Use__c from Stock_Item__c where id in : mapStockIdWithUsedDays.keySet()]){
			if(mapStockIdWithUsedDays.get(stk.Id)!=null){
				Integer daysUsed = 0;
				if(stk.Total_Days_In_Use__c!=null){
					daysUsed = Integer.valueOf(stk.Total_Days_In_Use__c);
				}
				daysUsed = daysUsed + mapStockIdWithUsedDays.get(stk.Id);
				updateStock.add(new Stock_Item__c(Id=stk.Id,Total_Days_In_Use__c=daysUsed));
			}
		}
		update updateStock;*/
	}

	public static void refreshStockItemUsedDays(){
		List<Stock_Item__c> updateStock = new List<Stock_Item__c>();
		if(!stockIdToUpdate.isEmpty()){
			for(Id st : stockIdToUpdate){
				updateStock.add(new Stock_Item__c(Id=st));
			}
			update updateStock;
		}
	}
}