global class ScheduleBatchContractRenewal implements Schedulable {

    Map<String, Map<String, Business_Config__c>> mapBusinessLogic = LibBusinessConfig.motherOfAllBusinessMaps.get('BatchContractRenewal');
    global void execute(SchedulableContext sc) {
        BatchContractRenewal batch = new BatchContractRenewal();
        Map<String, Business_Config__c> businessData = mapBusinessLogic.get('Global_Config');
        if(businessData != null && businessData.ContainsKey('BatchSize')!= null){
            Database.executeBatch(batch,Integer.valueOf(businessData.get('BatchSize').Business_Rule_Value__c));
        }else{
            Database.executeBatch(batch,10);
        }
    }
}