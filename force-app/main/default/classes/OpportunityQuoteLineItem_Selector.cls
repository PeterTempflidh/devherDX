/**
* @author Mantas Jurkunas
* @date 15.07.2019
*
* @description Selector for Opportunity_Quote_Line_Item__c records
*
*/

public with sharing class OpportunityQuoteLineItem_Selector {

    /**
     * @description selector method for test purposes
     *
     * @return List<Opportunity_Quote_Line_Item__c>
     */
    @TestVisible
    private static List<Opportunity_Quote_Line_Item__c> getAll() {
        List<Opportunity_Quote_Line_Item__c> listObj = new List<Opportunity_Quote_Line_Item__c>();
        try {
            listObj = [SELECT Based_On__c, Commission_Type__c, Scaled__c, Commission_Type_Picklist__c,
                    Booking_Api_Id__c, Quantity__c, Interval__c, Budget__c, Sub_Product_Name__c, Unit_Cost__c, Id_Opportunity_Quote__c
            FROM Opportunity_Quote_Line_Item__c];
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }
        return listObj;
    }

}