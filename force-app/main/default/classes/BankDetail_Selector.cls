/**
 * Created by c.kumari on 26.09.2019.
 */

public with sharing class BankDetail_Selector {

    /**
   * Retrieves Bank Detail Record based on status and account Id
   * @param  account
   * @return Bank Detail Record
   */

    public static List<Bank_Detail__c> getByAccountIds(set<Id> accountIds){

        List<Bank_Detail__c> bankInfo = new List<Bank_Detail__c>();
        try {
            bankInfo = [SELECT
                    Id, Status__c, Account__c,CreatedById
            FROM Bank_Detail__c
            WHERE Account__c IN :accountIds
            AND Status__c != 'Inactive'];
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }
        return bankInfo;

    }


}