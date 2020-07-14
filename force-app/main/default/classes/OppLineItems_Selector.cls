/**
* @author Shravya Rama
* @date 24.09.2019
*
* @description Selector class for retrieving Opportunity Line item records
*/

public class OppLineItems_Selector {

    public static List<Opportunity_Line_Item__c> getLineitemsBasedOnSubtype(String subType, Set<Id> oppIdsToCheckSet) {
        List<Opportunity_Line_Item__c> oppLineItemsList = new List<Opportunity_Line_Item__c>();
        try {
            oppLineItemsList = [SELECT Id,Id_Opportunity__c FROM Opportunity_Line_Item__c WHERE Id_Opportunity__c IN: oppIdsToCheckSet AND Sub_type__c = :subType];
        } catch (Exception e) {
            System.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return oppLineItemsList;

    }
    /*******************************************************************************************************
    * @description Get List of OLi based on oppty Id
    * @param oppIdsToCheckSet Set of Ids of the opportunity
    * @param setofLineItemTypes Set of line item types
    * @return List<Opportunity_Line_Item__c>
    * @jira SSC-1646
    */
    public static List<Opportunity_Line_Item__c> getLineitemsBasedOnItemTypesAndOppty(Set<Id> oppIdsToCheckSet, Set<String> setofLineItemTypes) {
        List<Opportunity_Line_Item__c> oppLineItemsList = new List<Opportunity_Line_Item__c>();
        try {
            oppLineItemsList = [SELECT Id,Id_Opportunity__c,Start_Date__c,Line_Item_Type__c FROM Opportunity_Line_Item__c WHERE Id_Opportunity__c IN: oppIdsToCheckSet AND Line_Item_Type__c IN: setofLineItemTypes order by Start_Date__c ASC];
        } catch (Exception e) {
            System.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return oppLineItemsList;
    }
    /*******************************************************************************************************
    * @description      : Get List of OLi based on oppty Id and sub types
    * @return           : List<Opportunity_Line_Item__c>
    * @jira             : SSC-1929
    * *******************************
    * @param             Set<String> setofLineItemTypes
    * @param             Set<Id> oppIdsToCheckSet
    */
    public static List<Opportunity_Line_Item__c> getLineItemsBasedOnSubtypesAndOppty(Set<String> setofLineItemTypes, Set<Id> oppIdsToCheckSet) {
        List<Opportunity_Line_Item__c> oppLineItemsList = new List<Opportunity_Line_Item__c>();
        try {
            oppLineItemsList = [SELECT Id,Id_Opportunity__c FROM Opportunity_Line_Item__c WHERE Id_Opportunity__c IN: oppIdsToCheckSet AND Sub_type__c IN: setofLineItemTypes];
        } catch (Exception e) {
            System.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return oppLineItemsList;

    }
}