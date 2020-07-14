global class BatchLinkQuoteServiceWithQuoteLine implements Database.Batchable<sObject> {
	
	String query;
	
	global BatchLinkQuoteServiceWithQuoteLine() {
		query = 'select id, (select id,name,Id_List_Service_Price__c,Commission_In_Percentage__c,Commission_Per_Order__c,start_date__c from  Opportunity_Quote_Line_Items__r where Line_Item_Type__c=\'Service\' and Id_List_Service_Price__c=null), (select id,name,Commission_In_Percentage__c,Commission_Per_Order__c,start_date__c,Id_List_Service_Price__c from Opportunity_Quote_Service_Items__r) from Opportunity_Quote__c where id in (select Id_Opportunity_Quote__c from Opportunity_Quote_Service_Item__c)';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {

   		List<Opportunity_Quote__c> oppQuotes = (List<Opportunity_Quote__c>) scope;
   		List<Opportunity_Quote_Line_Item__c> updateQLList = new List<Opportunity_Quote_Line_Item__c>(); 
   		Map<id,id> mapOppQSerWithOppQline = new Map<Id,Id>();
   		for(Opportunity_Quote__c oppQ : oppQuotes){
   			if(!oppQ.Opportunity_Quote_Line_Items__r.isEmpty()){
   				for(Opportunity_Quote_Line_Item__c oppQline : oppQ.Opportunity_Quote_Line_Items__r){
   					if(oppQline.Id_List_Service_Price__c==null){
   						for(Opportunity_Quote_Service_Item__c oppQS : oppQ.Opportunity_Quote_Service_Items__r){
	   						if(oppQline.Commission_In_Percentage__c==oppQS.Commission_In_Percentage__c && oppQline.Commission_Per_Order__c==oppQS.Commission_Per_Order__c && oppQline.name==oppQS.name && oppQline.start_date__c==oppQS.start_date__c){
	   							if(mapOppQSerWithOppQline.containsKey(oppQS.Id)){
                              continue;
                           }
                           updateQLList.add(new Opportunity_Quote_Line_Item__c(Id=oppQline.Id,Id_List_Service_Price__c=oppQS.Id_List_Service_Price__c));
	   							mapOppQSerWithOppQline.put(oppQS.Id,oppQline.Id);
	   							break;
	   						}
	   					}
   					}
   				}
   			}
   		}
   		List<Contract> listCont = [select id,Id_Opportunity_Quote_Service_Item__c,Id_Opportunity_Quote_Line_Item__c from Contract where Id_Opportunity_Quote_Service_Item__c in:mapOppQSerWithOppQline.keySet() and Id_Opportunity_Quote_Line_Item__c=null];
   		for(Contract c : listCont){
   			c.Id_Opportunity_Quote_Line_Item__c = mapOppQSerWithOppQline.get(c.Id_Opportunity_Quote_Service_Item__c);
   		}

   		System.debug('updateQLList: '+updateQLList);
   		System.debug('listCont: '+listCont);
   		update updateQLList;
   		update listCont;
   		
   		
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}