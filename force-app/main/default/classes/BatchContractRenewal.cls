/**
 * Updates expired Contract, based on Business Config terminates the Contract
 * or renews it
 */
global class BatchContractRenewal implements Database.Batchable<SObject>, Database.Stateful {

   // business rules
   Map<String, Map<String, Business_Config__c>> mapBusinessLogic = LibBusinessConfig.motherOfAllBusinessMaps.get('BatchContractRenewal');
   Map<String, Map<String, Business_Config__c>> mapBusinessLogicTLife = LibBusinessConfig.motherOfAllBusinessMaps.get('TlifeRevenueModel'); //SSC-1982

   global Database.QueryLocator start(Database.BatchableContext BC) {
      Set<String> statusSet = new Set<String>{'Activated','Draft','To be Sent'};
      return Database.getQueryLocator([
                                         SELECT
                                             StartDate,
	                                         End_Date__c,
	                                         Status,
	                                         RecordType.DeveloperName,
	                                         Account.Record_Country__c,
	                                         Renewal_version__c,
	                                         Renewed_by__c,
	                                         Last_renewal_date__c,
                                             Service_Type__c,
                                             AccountId,
	                                         Do_not_auto_renew__c,
	                                         Termination_Reason__c
                                         FROM Contract
                                         WHERE (End_Date__c < TODAY
                                            OR StartDate = TODAY)
                                            AND Status IN : statusSet
                                      ]);
   }

   global void execute(Database.BatchableContext BC, List<SObject> scope) {
      System.debug('BatchContractRenewal.execute: start');

      List<Contract> toUpdate = new List<Contract>();
      Map<String,List<Contract>> mapOfAccountIdContract = new Map<String,List<Contract>>(); //SSC-1982
      Map<String, Business_Config__c> mapOfContractBusinessConfig =  new Map<String, Business_Config__c>(); //SSC-1982

      if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) {
         return; // nothing to do
      }

      for (Contract cont : (List<Contract>) scope) {
          if (cont.StartDate != Date.today()) {
              Map<String, Business_Config__c> businessData = mapBusinessLogic.get(cont.RecordType.DeveloperName);

              if (businessData == null || businessData.isEmpty()) {
                  continue; // nothing to do for this contract
              }

              String countriesEnabledForAutoRenewal = businessData.get('CountriesEnabledForAutoRenewal') != null ? businessData.get('CountriesEnabledForAutoRenewal').Business_Rule_Value__c : '';

              // checks if has to renew the contract
              if (
                      countriesEnabledForAutoRenewal.containsIgnoreCase(cont.Account.Record_Country__c)
                              && businessData.get('RenewForNumberOfMonths') != null
                              && cont.End_Date__c != null
                              && !cont.Do_not_auto_renew__c
                      ) {

                  cont.End_Date__c = cont.End_Date__c.addMonths(Integer.valueOf(businessData.get('RenewForNumberOfMonths').Business_Rule_Value__c)).addDays(-1);
                  cont.Renewal_version__c = cont.Renewal_version__c != null ? cont.Renewal_version__c + 1 : 1;
                  cont.Last_renewal_date__c = Date.today();
                  cont.Renewed_by__c = UserInfo.getUserId();
                  cont.Status = businessData.get('renewalContractStatus').Business_Rule_Value__c;

                  toUpdate.add(cont);
              }
              // checks if has to terminate expired contracts
              else if (businessData.get('updateExpiredContracts') != null && Boolean.valueOf(businessData.get('updateExpiredContracts').Business_Rule_Value__c)) {


                  if (String.isBlank(cont.Termination_Reason__c)) {
                      cont.Status = businessData.get('expiredContractStatus').Business_Rule_Value__c;
                  } else {
                      cont.Status = businessData.get('terminatedContractStatus').Business_Rule_Value__c;

                      //The below logic is added for SSC-1982 : Tlife Commission
                      String contractRecordType = String.isNotBlank(cont.RecordType.DeveloperName) ? cont.RecordType.DeveloperName : '';
                      if(mapBusinessLogicTLife != null && null != mapBusinessLogicTLife.get(contractRecordType)){
                          List<Contract> listOfContract = !mapOfAccountIdContract.isEmpty() && mapOfAccountIdContract.get(cont.AccountId) != null ?
                                  mapOfAccountIdContract.get(cont.AccountId) : new List<Contract>();
                          listOfContract.add(cont);
                          mapOfContractBusinessConfig = mapBusinessLogicTLife.get(contractRecordType);
                          mapOfAccountIdContract.put(cont.AccountId,listOfContract);
                      }
                      //SSC-1982 : Tlife Commission ends here
                  }
                  toUpdate.add(cont);

              }
          } else if (cont.StartDate == Date.today() && cont.End_Date__c != Date.today()) {

             cont.Status = 'Activated';
             toUpdate.add(cont);
         }
      }

      if (!toUpdate.isEmpty()) {
          List<Database.SaveResult> results = Database.update(toUpdate,false);
          LoggingUtility.createLog('BatchContractRenewal','BATCH','Contract Renewal Terminated',null);
          Boolean isError = false;

          for(Integer i=0;i<results.size();i++){
              if(!results[i].isSuccess()){
                  LoggingUtility.logError('BatchContractRenewal','BatchContractRenewal: Update failed for Contract ' + toUpdate[i].Id +
                          ' Errors '  + results[i].getErrors() + '\n');
                  System.debug(LoggingLevel.ERROR,'BatchContractRenewal: Update failed for Contract ' + toUpdate[i].Id +
                          ' Errors '  + results[i].getErrors());
                  isError = true;
              }
          }


          // Do Logging in case of error.
          if(isError){
              LoggingUtility.commitLogs();
          }

          //The below logic is added for SSC-1982 : Tlife Commission
          if(!mapOfAccountIdContract.isEmpty() && !mapOfContractBusinessConfig.isEmpty()) {
              CtrTerminationRestaurantVue.fetchAllContractsWithServiceType(mapOfAccountIdContract,mapOfContractBusinessConfig);
          }
          //logic ends here for SSC-1982 : Tlife Commission


      }

      System.debug('BatchContractRenewal.execute: done');
   }

   global void finish(Database.BatchableContext BC) {}
}