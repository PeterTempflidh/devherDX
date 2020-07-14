/**
* @author Mantas Jurkunas
* @date 15.07.2019
*
* @description Selector for Opportunity_Line_Item__c records
*
*/

public with sharing class OpportunityLineItem_Selector {

    /**
     * @description selector method for test purposes
     *
     * @return List<Opportunity_Line_Item__c>
     */
    @TestVisible
    private static List<Opportunity_Line_Item__c> getAll() {
        List<Opportunity_Line_Item__c> listObj = new List<Opportunity_Line_Item__c>();
        try {
            listObj = [SELECT Based_On__c, Commission_Type__c, Scaled__c, Commission_Type_Picklist__c, Midas_Exception__c, Booking_Api_Id__c, Id_Opportunity__c  FROM Opportunity_Line_Item__c];
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }
        return listObj;
    }

    /**
     * @description selector method to query OpportunityLineItems based on OpportunityId
     * @Param Set of Opportunity Id
     * @return List<Opportunity_Line_Item__c>
     */
    public static List<Opportunity_Line_Item__c> getOLIByOpportunityId(final set<Id> oppIds) {
        List<Opportunity_Line_Item__c> listObj = new List<Opportunity_Line_Item__c>();
        try {
            listObj = [SELECT Id,Booking_Api_Id__c,Id_Opportunity__c,Id_Opportunity__r.Source_System__c from Opportunity_Line_Item__c where Id_Opportunity__c =:oppIds ];
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }
        return listObj;
    }

    /**
     * @description selector method to query OpportunityLineItems based on Booking Id
     * @Param Set of Opportunity Id
     * @return List<Opportunity_Line_Item__c>
     */
    public static List<Opportunity_Line_Item__c> getOLIByBookingId(List<string> bookingIds) {
        List<Opportunity_Line_Item__c> listObj = new List<Opportunity_Line_Item__c>();
        try {
            listObj = [select id, Booking_Api_Id__c, Id_Opportunity__r.record_country__c,Id_Opportunity__c,
                    Id_Opportunity__r.Source_System__c,Id_List_Price_Product__r.company__r.name, Interval__c,
                    Quantity__c, Unit_Cost__c, Sub_Product_Name__c, Budget__c, Name
            from Opportunity_line_item__c
            where Booking_Api_Id__c in: bookingIds];
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }
        return listObj;
    }

    /**
     * @description selector method to query OpportunityLineItems based on OpportunityId.
     *  this returns large amount of data and should be only used if most of the data is necessary, otherwise use getOLIByOpportunityId instead.
     * @Param Set of Opportunity Id
     * @return List<Opportunity_Line_Item__c>
     */
    public static List<Opportunity_Line_Item__c> getByOpportunityIdsForTariff(Set<Id> opportunityIds) {
        return [SELECT Ad_Sales_Type__c,Booking_Api_Id__c,Category_Id__c,Category__c,City_ZipCode__c,Commission_In_Percentage__c,Commission_Per_Order__c,
                Commission_Type__c,Deposit_Method__c,Deposit__c,Design_Note__c,Discount__c,District_Id__c,District__c,End_Date__c,Has_Related_Tarif__c,
                Id,Id_List_Price_Product__c,Id_List_Service_Price__c,Id_Opportunity__c,Id_Replacement_Order__c,index__c,Installments__c,IsTiered__c,
                Line_Item_Type__c,Listed_Price__c,Max__c,Min__c,Name,Number_of_Copies__c,OldOppQuoteLineId__c,Online_Payment_Fee__c,Position_fm__c,
                Position__c,Product_Group__c,Quantity__c,RecordTypeId,Recurring_Fee__c,Size__c,Start_Date__c,Subsidy__c,Sub_type__c,Total_Amount__c,
                Weight__c,Id_List_Add_On__c,ContractAddition__c,Billable_Account__c,Specifications__c,Scaled__c,Id_List_Price_Product__r.Company__r.Name,
                Commission_Type_Picklist__c,  Based_On__c, Source_grid__c, Delivery__c,
        (SELECT Min__c,Max__c,Commission_in_percentage__c,Commission_per_order__c,Id_Opportunity_Quote_Line_Item__c,Id_Opportunity_Line_Item__c
        FROM Tiers__r
        ORDER BY Min__c)
        FROM Opportunity_Line_Item__c
        WHERE Id_Opportunity__c IN :opportunityIds
        ORDER BY Id_List_Price_Product__r.Company__r.Name];
    }
}