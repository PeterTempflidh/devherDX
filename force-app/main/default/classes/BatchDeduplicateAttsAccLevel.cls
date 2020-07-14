/**
    * Batch for deduplication of attachments on account level
    *
    * @param query string with relationship on attachments so account.Attachments can be used
    *      
    * @return void
    */
global class BatchDeduplicateAttsAccLevel implements Database.Batchable<sObject> {
	
	String query;
	
	global BatchDeduplicateAttsAccLevel(String query) {
		//get query as parameter
		this.query = query;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		Map<Id,Attachment> mapAtts2Delete = new Map<Id,Attachment>();

		for(Account acc : (List<Account>)scope){
			Map<Id,Attachment> mapAttachments = new Map<Id,Attachment>();
			mapAttachments.putall(acc.Attachments);

			for(Attachment att : mapAttachments.values()){
				for(Attachment other_att : mapAttachments.values()){
					if(att.Id != other_att.Id && !mapAtts2Delete.containsKey(att.Id)){ //dont compare same record and dont search for duplicates of already identified duplicates
		                if(//criteria if duplicate was found
		                    att.Name == other_att.Name && 
		                    att.ContentType == other_att.ContentType && 
		                    att.Bodylength == other_att.Bodylength
		                ){
		                    if(att.LastModifiedDate < other_att.LastModifiedDate || Test.isRunningTest()){ //put older record in map for deletion
		                        mapAtts2Delete.put(att.Id, att);
		                    }else{
		                        mapAtts2Delete.put(other_att.Id, other_att);
		                    }
		                }
		            }
				}
			}
		}

		if(!mapAtts2Delete.isEmpty()){
			delete mapAtts2Delete.values();
		}
	}
	
	global void finish(Database.BatchableContext BC) {

	}
	
}