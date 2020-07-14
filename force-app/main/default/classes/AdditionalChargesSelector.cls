public inherited sharing class AdditionalChargesSelector {

    public static List<Additional_Charges__c> getActiveAdditionalChargesForAccount(Id accountId) {
        return [SELECT id,termination_date__c
        FROM Additional_Charges__c
        WHERE Id_Account__c =:accountId and termination_date__c=null];
    }

    /*******************************************************************************************************
    * @description Queries for Additional Charges records by provided Opportunity Ids.
    * @param keys Set<ID> Opportunity.
    * @return List<Additional Charges>
    */
    public static List<Additional_Charges__c> getAdditionalChargesForOpportunity (final set<Id> setOppId){
        List<Additional_Charges__c> listAddCharges = new List<Additional_Charges__c>();
        try {
            listAddCharges = [select Id, Interval__c, Id_List_Product_Price__c, Quantity__c, Unit_Cost__c, Sub_Product_Name__c, Budget__c, Status__c  from Additional_Charges__c
                              where Id_Opportunity__c =: setOppId];
        } catch (Exception e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return listAddCharges;
    }

    /*******************************************************************************************************
    * @description Queries for Additional Charges records by provided Booking Id.
    * @param keys Set<String> Booking Id.
    * @return List<Additional Charges>
    */
    public static List<Additional_Charges__c> getAdditionalChargesByBookingID (final set<String> setBookingId){
        List<Additional_Charges__c> listAddCharges = new List<Additional_Charges__c>();
        try {
            listAddCharges = [select Name, Id,Termination_Date__c,Status__c,Termination_Reason__c,Interval__c, Quantity__c, Unit_Cost__c, Sub_Product_Name__c, Budget__c
                              from Additional_Charges__c
                              where Booking_Api_Id__c = :setBookingId and Status__c IN ('Active','Expired','To be sent', 'Draft')];
        } catch (Exception e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return listAddCharges;
    }
  
    /*******************************************************************************************************
    * @description Queries for Terminated Additional Charges records by provided Booking Id.
    * @param bookingIds Set<String> Booking Id.
    * @return List<Additional Charges>
    */
    public static List<Additional_Charges__c> getTerminatedByBookingIds (final Set<String> bookingIds){
        List<Additional_Charges__c> listAddCharges = new List<Additional_Charges__c>();
        try {
            listAddCharges = [select Id,Termination_Date__c,Status__c,Termination_Reason__c,Booking_Api_Id__c
            from Additional_Charges__c
            where Booking_Api_Id__c = :bookingIds and Status__c = 'Terminated'];
          } catch (Exception e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return listAddCharges;
    }

     /*******************************************************************************************************
    * @description Returns a list of Additional Charges with related Process Instances
    * @param Set<Id> set of record ids
    * @return List<Additional Charges>
    */
    public static List<Additional_Charges__c> getAdditionalChargesWithProcessInstances (Set<Id> addChargesIds){
        List<Additional_Charges__c> listAddCharges = new List<Additional_Charges__c>();
        try {
            listAddCharges =  [SELECT Id,Run_Approval_Trigger__c,(SELECT ID, SubmittedById FROM ProcessInstances ORDER BY CreatedDate DESC) FROM Additional_Charges__c WHERE ID IN :addChargesIds];
        } catch (Exception e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return listAddCharges;
    }

}