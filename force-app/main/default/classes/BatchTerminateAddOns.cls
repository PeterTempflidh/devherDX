global class BatchTerminateAddOns implements Database.Batchable<sObject>, Database.Stateful{
   
   // business rules
   Map<String, Map<String, Business_Config__c>> mapBusinessLogic = LibBusinessConfig.motherOfAllBusinessMaps.get('BatchAddOnTermination');
   
   global Database.QueryLocator start(Database.BatchableContext BC) {
      return Database.getQueryLocator([SELECT Id,End_Date__c,Status__c,recordtype.developername,
  												Account_Name__r.record_country__c,Termination_Reason__c
  											FROM Add_On_Service__c
  											WHERE end_date__c <= TODAY
  												AND Status__c = 'Active']);
   }
   
   global void execute(Database.BatchableContext BC, List<sObject> scope) {
      System.debug('BatchTerminateAddOns.execute: scope list size is: ' + scope.size());
	  List<Add_On_Service__c> toUpdate = new List<Add_On_Service__c>();

      if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) {
         System.debug('BatchTerminateAddOns.execute: empty business rules');
         return; // nothing to do
      }


      for (Add_On_Service__c addOn : (List<Add_On_Service__c>) scope) {

         System.debug('BatchTerminateAddOns.execute: processing Add On: ' + addOn.Id);

         Map<String, Business_Config__c> businessData = mapBusinessLogic.get(addOn.RecordType.developername);

	     if (businessData == null || businessData.isEmpty()) {
	        System.debug('BatchTerminateAddOns.execute: nothing to do for this one');
	        continue; // nothing to do for this Add On
	     }

		// checks whether to mark as expired or terminated
		if (businessData.containsKey('terminateAddOns')
	        && Boolean.valueOf(businessData.get('terminateAddOns').Business_Rule_Value__c)){

			System.debug('BatchTerminateAddOns.execute: terminating: ' + addOn.id);
				
			if(String.isBlank(addOn.Termination_Reason__c)){
				addOn.Status__c = businessData.get('expiredStatus').Business_Rule_Value__c;
			}else{
				addOn.Status__c = businessData.get('terminationStatus').Business_Rule_Value__c;
			}

			toUpdate.add(addOn);
		}
         
      }

      System.debug('BatchTerminateAddOns.execute: toUpdate size is: ' + toUpdate.size());

      if (!toUpdate.isEmpty()) {
         update toUpdate;
      }

      System.debug('BatchTerminateAddOns.execute: done');
   }

   global void finish(Database.BatchableContext BC) {}
    
}