/**
* @author Mantas Jurkunas
* @date 09.01.2019
*
* @description Selector class for retrieving Tarif Member records
*/
public with sharing class TarifMember_Selector {

    /*******************************************************************************************************
   * @description Queries for tarif member with 0 commission
   * @return Tarif_Member__c
   */

    public static Tarif_Member__c findTarifMemberByTarifName(String tarifName) {
        Tarif_Member__c tarifMember;
        try {
            tarifMember = [SELECT Id, Name, Tarif_Name__c, Id_Tarif_Item__c, Type__c FROM Tarif_Member__c WHERE Tarif_Name__r.Name = :tarifName AND Type__c = 'Product' LIMIT 1];
        } catch(Exception e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return tarifMember;
    }
    /**
   * @Description: This method get tarif member details from tarif Ids
     @param             : Set of Tarif Ids
     @Return             : List of Tarif Member
     @TriggerContext     :  After Update
     @Ticket #           : SSC-1979
    */
    public static List<Tarif_Member__c> getTarifMembersByTarifIds(Set<Id> setOfTarifIds){

        List<Tarif_Member__c> lstOfTarifMembers = new List<Tarif_Member__c>();

        try{
            lstOfTarifMembers = [SELECT Id,Name,Tarif_Name__c,
                                Id_Tarif_Item__c, Type__c FROM
                                Tarif_Member__c WHERE Tarif_Name__c IN : setOfTarifIds];
        }
        catch(Exception e){
            system.debug('Error: '+e.getMessage());
        }
        return lstOfTarifMembers;
    }
}
