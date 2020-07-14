/**
* @author Mantas Jurkunas
* @date 25.01.2019
*
* @description Selector class for retrieving approval process records
*/

public inherited sharing class ProcessInstanceWorkItemSelector {

    public static List<ProcessInstanceWorkitem> findActiveWorkItemsByTargetIds(Set<Id> targetIds) {
        List<ProcessInstanceWorkitem> workItems = new List<ProcessInstanceWorkitem>();
        try {
             workItems = [
                    SELECT Id
                    FROM ProcessInstanceWorkitem
                    WHERE ProcessInstance.TargetObjectId IN :targetIds
                    AND ProcessInstance.Status = 'Pending'
             ];
        } catch (Exception e) {
            System.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return workItems;
    }

}