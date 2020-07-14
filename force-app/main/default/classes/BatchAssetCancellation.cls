global class BatchAssetCancellation implements Database.Batchable<sObject> {
	
	String query;
	
	global BatchAssetCancellation() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([select id,name,Activated_Date__c,Asset__c from Asset_Cancellation__c where activated_Date__c=null]);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		//Set<Id> assetIds = new Set<Id>();
   		Map<Id,List<Id>> assetAssetCanMap = new Map<Id,List<Id>>();
   		Set<Asset_Cancellation__c> updateAssetCan = new Set<Asset_Cancellation__c>();
   		List<Asset_Cancellation__c> listAstCan = new List<Asset_Cancellation__c>();
   		List<Asset_Cancellation__c> updateListAssetCan = new List<Asset_Cancellation__c>();
   		Map<Id,Asset_Cancellation__c> mapUpdateAssetCan = new Map<Id,Asset_Cancellation__c>();
   		listAstCan = (List<Asset_Cancellation__c>) scope;
   		for(Asset_Cancellation__c astCan: listAstCan){
            //assetIds.add(astCan.Asset__c);
            if(assetAssetCanMap.get(astCan.Asset__c)!=null){
            	List<Id> temp = assetAssetCanMap.get(astCan.Asset__c);
            	temp.add(astCan.Id);
            	assetAssetCanMap.remove(astCan.Asset__c);
            	assetAssetCanMap.put(astCan.Asset__c,temp);
            }else{
            assetAssetCanMap.put(astCan.Asset__c,new List<Id>{astCan.Id});
            }
        }
		for(Additional_Charges__c ad : [select Id_Asset__c, createdDate from Additional_Charges__c where Id_Asset__c in :assetAssetCanMap.keySet()]){
			if(assetAssetCanMap.get(ad.Id_Asset__c)!=null){
				for(Id idd : assetAssetCanMap.get(ad.Id_Asset__c)){
					mapUpdateAssetCan.put(idd,new Asset_Cancellation__c(id=idd,Activated_Date__c=ad.createdDate.date()));
				}
			}
		}
		//System.debug('updateAssetCan: '+updateAssetCan);
		//System.debug('updateAssetCan size: '+updateAssetCan.size());
		//updateListAssetCan.addAll(updateAssetCan);
		update mapUpdateAssetCan.values();
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}