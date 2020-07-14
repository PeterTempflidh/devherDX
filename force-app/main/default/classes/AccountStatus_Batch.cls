/**
* @author William Castillo
* @date 28.02.2020
*
* @description Batch to set the correct account status with the conditions requiried on : SSS-948
*/
public with sharing class AccountStatus_Batch implements Database.Batchable<SObject>, Database.Stateful {

    public String queryString;
    /*******************************************************************************************************
     * @description Contructor with the query that we will use to process in this batch :
     * String query = 'select id,Account_Status__c from account where RecordType.DeveloperName = \'FP_Account\'';
        AccountStatus_Batch accBatch = new AccountStatus_Batch(query);
        ID batchprocessid = Database.executeBatch(accBatch);
     * @param currentAccount an account that will be determinate witch is the status
     * @return void
     */
    public AccountStatus_Batch (String sQuery){
        queryString = sQuery;
    }

    public void execute(Database.BatchableContext param1, List<sObject> objectList) {

        set<Id> currentAccountIds = ClsSObjectUtils.extractSetIds(objectList,'Id');
        set<String> serviceTypes = new set<string> {'Logistics Fee','Commission Fee'};
        set<string> opportunityBusinessType = new set<string> {'New Business','Owner Change', 'Win Back'};

        List<Account> lstAccount = new List<Account>();

        //Query to get all thee contracts and the oportunitied in the Service and the bussiness type defined in the set. in this case get all the contracts with the servicetype Logistic fee and commission fee, and the opportunities with the types New bussiness onwer change and win Back for the accounts that are processing
        String queryAccountWithContractOpportunity = 'select id,Account_Status__c , (select id,Service_Type__c , Status from contracts where Service_Type__c IN :serviceTypes ), (select id,StageName from Opportunities where Business_Type__c IN : opportunityBusinessType order by CreatedDate Desc limit 1) from Account where id in : currentAccountIds';

        lstAccount = database.Query(queryAccountWithContractOpportunity);

        for (Account acc: lstAccount) {
            AccountStatus_helper.evaluatedStatus(acc);
        }
        Database.update(lstAccount,false);
        //update lstAccount;
    }

    public void finish(Database.BatchableContext param1) {
    }

    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        //String databaseQuery = 'select id,Account_Status__c from account ';

        return Database.getQueryLocator(queryString);
    }


}