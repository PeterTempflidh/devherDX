global class MigrationScriptInsertBatch implements Database.Batchable<sObject> {
	

	List<sObject> listObjects{get;set;}
	String mapping {get;set;}


	String query;
	
	global MigrationScriptInsertBatch(List<sObject> listObjects,String mapping) {
		this.listObjects = listObjects;
		this.mapping = mapping;
	}
	
	global List<sObject> start(Database.BatchableContext BC) {
		return this.listObjects;
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		System.debug('%%% - scope: ' + scope);
   		List<sObject> list2Insert = new List<sObject>();

   		Map<String,String> mapMapping = (Map<String,String>) JSON.deserialize(this.mapping, Map<String,String>.class);

   		for(sObject obj : scope){

   			Sobject newObj = Schema.getGlobalDescribe().get(obj.getSobjectType().getDescribe().getName()).newSobject();


   			for(String key : mapMapping.keySet()){

   				String targetField = mapMapping.get(key);
   				String sourceField = key;

   				newObj.put(targetField,obj.get(sourceField));

   			}

   			list2Insert.add(newObj);
   		}

		insert list2Insert;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}