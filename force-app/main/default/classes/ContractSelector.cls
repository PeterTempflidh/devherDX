/**
* @author g.singh
* @date xx.03.2019
*
* @description Selector class for retrieving Contract records
*/
public inherited sharing class ContractSelector {

    public static final String ONLINE_STATUS_ACTIVE = 'Active';
    public static final String ONLINE_STATUS_TERMINATED = 'Terminated';
    public static final String ONLINE_STATUS_PENDINGACTIVATION = 'Pending Activation';

    /*******************************************************************************************************
    * @description Returns Active contracts for a single Account
    * @param accountId - Id - of the related Account
    * @return List<Contract>
    */
    public static List<Contract> getActiveContractsForAccount(Id accountId) {
        return ContractSelector.getActiveContractsForAccounts(new Set<Id>{accountId});
    }

    /*******************************************************************************************************
    * @description Returns Active contracts for a set of Accounts
    * @param accountIds - Set<Id> - Ids of related Accounts
    * @return List<Contract>
    */
    public static List<Contract> getActiveContractsForAccounts(Set<Id> accountIds) {
        return [SELECT Id, AccountId, Company__c, Company_Name__c, ContractNumber, StartDate, End_Date__c, Status, Service_Type__c,
                Commission__c, Recurring_Fee__c, RecordType.DeveloperName
        FROM Contract
        WHERE AccountId =: accountIds AND Status != 'Terminated' ORDER BY StartDate DESC];

    }

    /**
     * @description selector method for test purposes
     *
     * @return List<Contract>
     */
    @TestVisible
    private static List<Contract> getAll() {
        List<Contract> listObj = new List<Contract>();
        try {
            listObj = [SELECT Based_On__c, Commission_Type__c, Scaled__c, StartDate, Status, End_Date__c FROM Contract];
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }
        return listObj;
    }

    public static List<Contract> getContractsFromSwitchAccountsByIds(Set<Id> accountIds, Set<String> businessTypes) {
        List<Contract> contracts = new List<Contract>();
        try {
            contracts = [
                SELECT Id, AccountId, Id_Opportunity__c, Commission_Type__c, StartDate, End_Date__c, Id_Opportunity__r.Business_Type__c, Service_Type__c, RecordTypeId
                FROM Contract
                WHERE AccountId IN (SELECT AccountId FROM Opportunity WHERE Business_Type__c IN :businessTypes AND AccountId IN :accountIds)
                AND Status != 'Terminated'
            ];
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }
        return contracts;
    }

    /**
    * @description Queries all the contracts associated with the account implemented for SSC-1982 : Tlife Commission
    * @param accountIds [Set Of Account Id]
    * @param serviceTypeValues [All Service Types]
    * @param contractStatus [Contract Status]
    * @return List<Contract>
    */
    public static List<Contract> getContractsByServiceType(final Set<String> accountIds, final List<String>  serviceTypeValues,
            String contractStatus) {

        List<Contract> contractList = new List<Contract>();
        contractList = [
                SELECT Id,AccountId,Service_Type__c,Status FROM Contract WHERE AccountId IN : accountIds and
                Service_Type__c IN : serviceTypeValues and Status =: contractStatus
        ];
        return contractList;
    }
}