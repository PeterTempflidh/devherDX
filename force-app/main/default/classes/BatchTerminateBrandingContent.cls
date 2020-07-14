global class BatchTerminateBrandingContent implements Database.Batchable<sObject>, Database.Stateful{
   
   // business rules
   Map<String, Map<String, Business_Config__c>> mapBusinessLogic = LibBusinessConfig.motherOfAllBusinessMaps.get('BatchBrandingContentTermination');
   
   global Database.QueryLocator start(Database.BatchableContext BC) {
      Set<String> statusSet = new Set<String>{'Terminated','Canceled','Expired'};
      return Database.getQueryLocator([SELECT Id,End_Date__c,Status__c,recordtype.developername,
      											Restaurant_Name__r.record_country__c,Termination_Reason__c
  											FROM Branding_Content__c
  											WHERE end_date__c <= TODAY
  												AND Status__c NOT IN :statusSet]);
   }		
   
   global void execute(Database.BatchableContext BC, List<sObject> scope) {
      System.debug('BatchTerminateBrandingContent.execute: scope list size is: ' + scope.size());
	  List<Branding_Content__c> toUpdate = new List<Branding_Content__c>();

      if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) {
         System.debug('BatchTerminateBrandingContent.execute: empty business rules');
         return; // nothing to do
      }


      for (Branding_Content__c content : (List<Branding_Content__c>) scope) {

         System.debug('BatchTerminateBrandingContent.execute: processing branding content: ' + content.Id);

         Map<String, Business_Config__c> businessData = mapBusinessLogic.get(content.RecordType.developername);

	     if (businessData == null || businessData.isEmpty()) {
	        System.debug('BatchTerminateBrandingContent.execute: nothing to do for this one');
	        continue; // nothing to do for this Add On
	     }

		// checks whether to mark as expired or terminated
		if (businessData.containsKey('terminateBradningContent')
	        && Boolean.valueOf(businessData.get('terminateBradningContent').Business_Rule_Value__c)){

			System.debug('BatchTerminateBrandingContent.execute: terminating: ' + content.id);
				
			if(String.isBlank(content.Termination_Reason__c)){
				content.Status__c = businessData.get('expiredStatus').Business_Rule_Value__c;
			}else{
				content.Status__c = businessData.get('terminationStatus').Business_Rule_Value__c;
			}

			toUpdate.add(content);
		}
         
      }

      System.debug('BatchTerminateBrandingContent.execute: toUpdate size is: ' + toUpdate.size());

      if (!toUpdate.isEmpty()) {
         update toUpdate;
      }

      System.debug('BatchTerminateBrandingContent.execute: done');
   }

   global void finish(Database.BatchableContext BC) {}
   
   
}