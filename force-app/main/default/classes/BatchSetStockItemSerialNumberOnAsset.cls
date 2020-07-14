/**
    * Batch for setting the stockitem serial number on the asset object
    *
    * @param query string
    *      
    * @return void
    */
global class BatchSetStockItemSerialNumberOnAsset implements Database.Batchable<sObject> {

  // example query: String query = 'SELECT Id,Stock_Item__c,Stock_Item__r.Name,Replaced_Stock_Item__c,Replaced_Stock_Item__r.Name,Returning_Stock_Item_Serial_No__c,Stock_Item_Serial_No__c FROM Asset__c WHERE Stock_Item__c != null OR Replaced_Stock_Item__c != null ';

  
  String query;
  
  global BatchSetStockItemSerialNumberOnAsset(String query) {
    //get query as parameter
    this.query = query;
  }
  
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<sObject> scope) {
    
    for(Asset__c a : (List<Asset__c>)scope){
        if(a.Stock_Item__c != null){
            a.Stock_Item_Serial_No__c = a.Stock_Item__r.Name;
        }
        
        if(a.Replaced_Stock_Item__c != null){
            a.Returning_Stock_Item_Serial_No__c = a.Replaced_Stock_Item__r.Name;      
        }
    }
    
    update scope;
    
  }
  
  global void finish(Database.BatchableContext BC) {

  }
  
}