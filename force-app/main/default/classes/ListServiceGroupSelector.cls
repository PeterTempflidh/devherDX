/**
* @author Krunoslav Bilicic
* @date 15.10.2019
*
* @description Selector class for List_Product_Group__c
*/
public inherited sharing class ListServiceGroupSelector {
    public static List_Product_Group__c getProductGroupByName(String name) {
        return [SELECT Id, Name, Company__c, Id_Country__c, RecordtypeId FROM List_Product_Group__c WHERE Name = :name];
    }
}