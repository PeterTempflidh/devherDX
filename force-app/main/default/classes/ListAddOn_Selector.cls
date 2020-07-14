/**
 * Created by danish.farooq on 4/5/20.
 */
/**
 * Created by danish.farooq on 4/5/20.
* @Description: selector class use for return list add on data

 */
public with sharing class ListAddOn_Selector {
    /**
  * @Description: This method returns list of AddOn from Id
    @param            : List of Add on id
    @Return             : Map of AddOn
    @Ticket #            : SSC-1979
   */
    public static Map<Id, List_Add_On__c> getListAddOnById(List<Id> setOfAddOnIds){

        Map<Id, List_Add_On__c> addOnMap ;

        try{
            addOnMap = new Map<Id,List_Add_On__c>([SELECT Company__c,
                            Contract_Addition__c,Id,Id_Country__c,
                            Is_Active__c,Name,CurrencyIsoCode,
                            RecordTypeId,Requires_Approval__c,type__c
                            FROM List_Add_On__c
                            WHERE Id IN : setOfAddOnIds
                            LIMIT : limits.getLimitDmlRows()]);
        }
        catch(Exception ex){
            system.debug('Error : '  + ex.getMessage());
            LoggingUtility.commitLogs();
        }
        return addOnMap;
    }
}