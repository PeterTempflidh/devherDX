/**
* @author William Castillo
* @date 28.02.2019
*
* @description Selector class for retrieving ProcessDefinition records
*/
public with sharing class ClsProcessDefinitionSelector {


    /*******************************************************************************************************
    * @description Query for approval process on quote object  records by Name.
    * @param keys String strName : name of the process
    * @return ProcessDefinition
    */
    public static ProcessDefinition getApprovalProcessDefinition (final String strName) {
        ProcessDefinition currentApproval = new ProcessDefinition();
        try {
            currentApproval   = [SELECT Id,Name,DeveloperName,Type,Description,TableEnumOrId,State,CreatedDate
                                                    FROM ProcessDefinition
                                                    where TableEnumOrId = 'Opportunity_Quote__c' and Name = : strName and State = 'Active' limit 1];
        } catch (Exception e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return currentApproval;
    }
    
    /*******************************************************************************************************
    * @description Query for approval process on Additional chrages object  records Like Name.
    * @param keys String strName : name of the process
    * @return ProcessDefinition
    */
    public static ProcessDefinition getApprovalProcessDefinitionLIKE (final String strName) {
        ProcessDefinition currentApproval = new ProcessDefinition();
        try {
            currentApproval   = [SELECT Id,Name,DeveloperName,Type,Description,TableEnumOrId,State,CreatedDate
                                                    FROM ProcessDefinition
                                                    where TableEnumOrId = 'Additional_Charges__c' and DeveloperName LIKE : strName+'%' and State = 'Active' limit 1];
        } catch (Exception e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return currentApproval;
    }

}
