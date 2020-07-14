global class BatchSalesTarget implements Database.Batchable<sObject>,Database.Stateful {
    
    List<Id> salesTargetIds;
    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    
    global BatchSalesTarget(List<Id> salesTIds) {
        this.salesTargetIds = salesTIds;
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([Select Id,NoOfCommissionInPercent__c,TotalCommissionForAvgCal__c,RecordType.developerName,Name,Business_Type__c,Product_Group__c,Closed_Deals__c,Commission_Target__c,From__c,Product_Target__c,Revenue_Achieved__c,Sales_Rep__c,Target_Deals__c,Target_Product_Name__c,Target_Revenue__c,Target_Units__c,To__c,Type__c,Units_Achieved__c 
                from Sales_Target__c where Id in : salesTargetIds]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Map<String,Map<String,Business_Config__c>> mapBusinessLogic = moam.get('SalesTargetProcess');
        Map<Id,List<Sales_Target__c>> mapUserSTarget = new Map<Id,List<Sales_Target__c>>();
        List<Sales_Target__c> updateSalesTrgt = new List<Sales_Target__c>();
        Map<id,String> oppStageMap = new Map<Id,String>();
        Map<Id,Opportunity_Quote__c> updateOppQuoteMap = new Map<Id,Opportunity_Quote__c>();

        for(Sales_Target__c st : (List<Sales_Target__c>) scope){
          st.Revenue_Achieved__c = null;
            st.Closed_Deals__c=null;
            st.Units_Achieved__c = null;
            st.TotalCommissionForAvgCal__c = null;
            if(mapUserSTarget.get(st.Sales_Rep__c)==null){
                mapUserSTarget.put(st.Sales_Rep__c,new List<Sales_Target__c>{st});
            }else{
                List<Sales_Target__c> lis = mapUserSTarget.get(st.Sales_Rep__c);
                lis.add(st);
                mapUserSTarget.put(st.Sales_Rep__c,lis);
            }
        }
        //ClsRemoteController.processSalesTarget(mapUserSTarget,mapBusinessLogic);
           
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}