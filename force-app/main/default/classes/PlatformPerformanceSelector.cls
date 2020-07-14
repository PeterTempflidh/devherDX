/**
* @author g.singh
* @date 2019-05-03.
*
* @description Selector class for retrieving platformPerformance records
*/

public inherited sharing class PlatformPerformanceSelector {
    /*******************************************************************************************************
    * @description Returns Platfrom Performances for a set of Accounts
    * @param accountIds - Set<Id> - Ids of related Accounts
    * @return List<Platform_Performance__c>
    */
    public static List<Platform_Performance__c> getPlatformPerformancesForAccounts(Set<Id> accountIds) {
        return [SELECT Id, Account__c, Platform__c, Platform_Online_Status__c, Vendor_Status__c, GMVClass__c
            FROM Platform_Performance__c
            WHERE Account__c IN :accountIds];
    }

  

    /**
    * @author Tarun Jain
    * @date 25-Feb-20
    * @description This method returns the platform performance records based on backend ids
    * SCC-124
    * @return List<Platform_Performance__c>
    * @param  List<String> backendIds
    */
    public static List<Platform_Performance__c> getPlatformPerformancesByBackendIds(Set<String> backendIds) {
        List<Platform_Performance__c> platformPerformances = new List<Platform_Performance__c>();
        platformPerformances = [SELECT Id,Account__c,Backend_ID__c,Platform__c FROM Platform_Performance__c WHERE Backend_ID__c IN:backendIds];
        return platformPerformances;
    }

    /**
     * @author William Castillo.
     * @date 30-Apr-20
     * @description This method return the platform performance by contract number from sap
     * SCC-14
     * @return List<Platform_Performance__c>
     * @param  set<String> contractsNumbers
     */
    public static List<Platform_Performance__c> getPlatformPerformancesByContracts(Set<String> contractsNumbers, String country, string recordType) {
        List<Platform_Performance__c> platformPerformances = new List<Platform_Performance__c>();
        platformPerformances = [select id,Debt_Value__c,Number_Pending_Invoices__c,Contract_Number_SAP__c,Account__r.Record_Country__c, Account__r.RecordType.DeveloperName
                                    from Platform_Performance__c
                                    where Contract_Number_SAP__c IN:contractsNumbers
                                      AND Account__r.Record_Country__c =: country
                                      AND Account__r.RecordType.DeveloperName =: recordType];
        return platformPerformances;
    }
}
