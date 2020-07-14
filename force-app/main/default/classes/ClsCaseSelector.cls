/**
* @author William Castillo
* @date 28.02.2019
*
* @description Selector class for retrieving Case records
*/
public with sharing class ClsCaseSelector {
    

    /*******************************************************************************************************
    * @description Query for Cases filter by type .
    * @param keys String strName : name of the process
    * @return ProcessDefinition
    */
    @TestVisible
    private static List<Case> getApprovalProcessDefinition (final String strType) {
        List<Case> lstCases = new List<Case>();
        try {
            lstCases = [Select id, status from Case where type =: strType];
        } catch (Exception e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return lstCases;
    }

    /*******************************************************************************************************
   * @description Query for all Cases. To be used in tests only without seeAllData.
   * @return Case
   * get all the cases.
   */
    @TestVisible
    private static List<Case> getAll() {
        List<Case> lstCases = new List<Case>();
        try {
            lstCases = [SELECT Id, Status, Menu_Type_Age__c, CreatedDate, IsClosed, RecordTypeId, Opportunity__c, Type, Closed_Reason__c, Menu_Change_Date__c, First_Check_Date__c, Menu_Typed_Date__c  FROM Case];
        } catch (Exception e) {
            System.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return lstCases;
    }

  
    /*******************************************************************************************************
    * @description Query for Cases Related an opportunties order by created date .
    * @param set<Id> stIdOpportunities //  Opportunities related to the cases.
    * @return List<case>
    */


    public static List<Case> getCaseInOpportunitiesOrderASC(final set<Id> stIdOpportunities) {
        List<Case> lstCases = new List<Case>();
        try {
            lstCases = [select id, status, type, opportunity__c,case_reason__c, closed_reason__c
                        from Case
                        where opportunity__c in :stIdOpportunities
                        order by CreatedDate DESC ];
        } catch (Exception e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return lstCases;
    }


    /*******************************************************************************************************
    * @description Queries for Cases records by provided Opportunity Ids.
    * @param keys Set<Id> Opportunity .
    * @return List<Case>
    */
    public static List<Case> findCasesByOpportunity(final Set<Id> oppsIds) {
        List<Case> cases  = new List<Case>();
        try {
            cases = [
                    SELECT
                            Id,
                            Status
                    FROM
                            Case
                    WHERE
                            Opportunity__c IN :oppsIds
            ];
        } catch (Exception e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return cases;
    }
    

    /*******************************************************************************************************
    * @description Queries for non closed Cases records by provided Opportunity Ids with the Type.
    * @param keys Set<Id> Opportunity, caseType.
    * @return Set<Id>
    */
    public static Set<Id> findOpenCaseByOpportunity(final Set<Id> oppsIds, String caseType) {
        Set<Id> oppIdSet = new Set<Id>();
        for(Case QCcase : [SELECT Id,Opportunity__c FROM Case WHERE Opportunity__c IN :oppsIds AND Type =: caseType AND Status != 'Closed']) {

            if(String.isNotBlank(QCcase.Opportunity__c))
                oppIdSet.add(QCcase.Opportunity__c);
        }
        return oppIdSet;
    }

}
