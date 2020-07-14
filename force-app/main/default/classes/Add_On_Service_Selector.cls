/**
 * Created by danish.farooq on 6/25/20.
 */

public  inherited Sharing class Add_On_Service_Selector {
    /**
   * @description return AddOns for that opportunity
   * @param opptySet contains set Of Opportunity
   * @param addOnServiceLst contains current add Ons which are active
   * @param setOfStatus statuses of Addons
   * @return List of AddOns
   * @Jira SSC-3462
   */
    public static List<Add_on_Service__c> getAddOnServicesByOppty(Set<Id> opptySet,
                                                                  Set<string> setOfStatus){

        List<Add_on_Service__c> lstAddOnServices = new List<Add_on_Service__c>();

        lstAddOnServices = [SELECT ID, status__c, opportunity__c from
                            Add_On_Service__c where opportunity__c in :opptySet
                            AND Status__c IN : setOfStatus];
        return lstAddOnServices;
    }
}