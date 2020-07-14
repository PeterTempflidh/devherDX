/**
* @author Mantas Jurkunas
* @date 09.01.2019
*
* @description Selector class for retrieving account records
*/
public class ClsAccountSelector {

    /*******************************************************************************************************
    * @description Queries for account records by provided GRID numbers.
    * @param keys List<String> GRID numbers.
    * @return List<Account>
    */
    public static List<Account> findAccountsByGrid(final Set<String> keys) {
        List<Account> accounts = new List<Account>();
        try {
            accounts = [
                    SELECT
                        Id,
                        Name,
                        GRID__c,
                        Company_code__c,
                        Record_country__c,
                        CurrencyIsoCode
                    FROM
                        Account
                    WHERE
                        GRID__c IN :keys
            ];
        } catch (Exception e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return accounts;
    }

    /**
     * @description get accounts that have shared menu
     *
     * @param accountIds
     *
     * @return
     */
    public static List<Account> getSharedMenuAccountsWOBackendIdFromIds(Set<Id> accountIds) {
        List<Account> lstAccounts = new List<Account>();
        try {
            List<Account> accountsWOBackendId = [SELECT Id, Shared_Menu__r.Backend_ID__c, GRID__c, Shared_Menu__r.GRID__c, Shared_Menu__c FROM Account WHERE Shared_Menu__c != NULL AND Shared_Menu__r.Backend_ID__c = NULL AND Id IN :accountIds];
            Set<Id> sharedMenuIds = ClsSObjectUtils.extractSetIds(accountsWOBackendId, Account.Shared_Menu__c.getDescribe().getLocalName());
            List<Platform_Performance__c> platformPerformances = [SELECT Id FROM Platform_Performance__c WHERE Backend_ID__c != NULL AND Account__c IN :sharedMenuIds];
            if (platformPerformances == null || platformPerformances.isEmpty()) {
                return accountsWOBackendId;
            }
            sharedMenuIds = ClsSObjectUtils.extractSetIds(platformPerformances, Platform_Performance__c.Account__c.getDescribe().getLocalName());
            for (Account acc: accountsWOBackendId) {
                if (!sharedMenuIds.contains(acc.Shared_Menu__c)) {
                    lstAccounts.add(acc);
                }
            }
        } catch (Exception e) {
            System.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return lstAccounts;
    }

    /*******************************************************************************************************
    * @description Queries for account record by provided Id.
    * @param Id accountId.
    * @return Account
    */
    public static Account findAccountById(final Id accountId) {
        Account theAccount = new Account();
        try {
            theAccount = [
                    SELECT
                        Id,
                        ParentId,
                        Franchise_Connection__c,
                        RecordType.DeveloperName,
                        Name,
                        GRID__c,
                        Delivery_Service__c
                    FROM
                        Account
                    WHERE
                        Id = :accountId
                    LIMIT 1
            ];
        } catch (Exception e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
            return null;
        }
        return theAccount;
    }

    /*******************************************************************************************************
    * @description Queries account parent and grandparent type
    * @param accountId
    * @return Account
    */
    public static Account getAccountParentsTypes(Id accountId) {
        return [SELECT Parent.Type, Parent.Parent.Type 
                FROM Account
                WHERE Id = :accountId];
    }

    /*******************************************************************************************************
   * @description Queries accounts and related contracts that are terminated expired or ative
   * @param ids account ids
   * @param serviceTypes contract service types
   * @return List<Account> accounts that have contracts that are active expired or terminated
   */
    public static List<Account> findByIdsAndContractServiceType(final Set<Id> ids, final Set<String> serviceTypes) {
        List<Account> accounts = new List<Account>();
        try {
            accounts = [
                    SELECT
                            Id,
                            Delivery_Service__c,
                            (SELECT RecordTypeId, Status, Service_Type__c
                                FROM Contracts WHERE Service_Type__c IN :serviceTypes AND Status IN ('Activated', 'Expired', 'Terminated') ORDER BY Service_Type__c)
                    FROM
                            Account
                    WHERE
                            Id IN (SELECT AccountId FROM Contract WHERE Service_Type__c IN :serviceTypes AND Status IN ('Activated', 'Expired', 'Terminated') AND AccountId IN :ids)
            ];
        } catch (QueryException e) {
            System.debug('Error: '+e.getMessage());
        }
        return accounts;
    }
    
      /**
     * @Description: This method returns Account against opportunity
       @Input Params       : Set of Account id
       @Return             : List of Account
       @TriggerContext     : Before Update, Before Insert
       @Ticket #           : SSC-1533
    */
    public static List<Account> getAccountByOppty(Set<Id> setOfAccountId){

        List<Account> lstOfAccount = new List<Account>();
        try{
            lstOfAccount = [Select Id, Record_Country__c,Revenue_Model__c from Account WHERE Id IN  : setOfAccountId
                            AND Record_Country__c != NULL LIMIT : Limits.getLimitDMLRows()];
        }
        catch(Exception ex){
            System.debug('Error: '+ex.getMessage());
        }
        return lstOfAccount;
    }
    /*******************************************************************************************************
    * @description Queries facility accounts and related stalls
    * @param ids account facility ids
    * @return List<Account> facility accounts that have associated stalls
    */
    public static List<Account> getStallsByFacilityIds(final Set<Id> ids) {
        List<Account> accounts = new List<Account>();
        accounts = [
                SELECT Id,Stalls_Occupied__c, (SELECT Id,Account_Status__c FROM Stalls__r)
                FROM Account
                WHERE Id IN :ids
        ];
        return accounts;
    }

    /**
    * @date     : [18/06/2020]
    * @method name  : getAccountRecord
    * @description  : method to return the the account
    * @return List<Account>
    */
    public static List<Account> getAccountRecord() {

        List<Account> accountDetails = [SELECT Id, Name, GRID__c  FROM Account limit 1];
        return accountDetails;
    }
}
