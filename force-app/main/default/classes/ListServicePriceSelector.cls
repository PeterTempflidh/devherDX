
/**
* @author Krunoslav Bilicic
* @date 15.10.2019
*
* @description Selector class for List_Service_Price__c
*/
public inherited sharing class ListServicePriceSelector {
    public static List_Service_Price__c getServiceByName(String name) {
        return [SELECT Id, Name,Company__c,Id_Country__c, Commission_In_Percentage__c,Default_Commission_In_Percentage__c,
                	   Is_Active__c,Maximum_Commission_In_Percentage__c,Minimum_Commission_in_Percentage__c,Type__c,
                	   Recurring_Fee__c,RecordtypeId,CurrencyIsoCode,Service_Type__c 
                FROM List_Service_Price__c 
                WHERE Name = :name
                LIMIT 1];
    }
    
    /*******************************************************************************************************
* @description Queries to get List Product Price record based on contries and companies
* @param CountryIds - Set<Id> - set ids counrties
* @param CompanyIds - Set<Id> - set ids Companies
*
* @return List<Contract>
*/
    public static Map<Id, List_Service_Price__c> getActiveServicesForAccounts(Set<Id> CountryIds,Set<Id> CompanyIds) {

        Map<Id, List_Service_Price__c> servicesMap ;
        try {
            servicesMap = new Map<Id, List_Service_Price__c>([
                    SELECT Service_Type__c, Displayed_Name__c,CreatedDate,LastModifiedDate,Requires_Approval__c,
                            LastModifiedBy.Name,Is_Active__c,Name,Commission_In_Percentage__c,Commission_Per_Order__c,
                            Default_Commission_In_Percentage__c,Maximum_Commission_In_Percentage__c,Minimum_Commission_in_Percentage__c,
                            Minimum_Commission_Per_Order__c,Maximum_Commission_Per_Order__c,Type__c,Recurring_Fee__c,
                            Recurring_Interval__c,Id_Country__c,Id_Country__r.name,Company__c,Commission_Type__c,
                            CurrencyIsoCode,Scaled__c,Based_On__c,Requires_Esignature__c
                    FROM List_Service_Price__c
                    WHERE Id_Country__c = : CountryIds
                    AND Company__c = : CompanyIds
                    And Archived__c = false
                    ORDER BY LastModifiedDate DESC
                    LIMIT 999
            ]);
        } catch(Exception e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }

        return servicesMap;
    }
    /**
   * @Description: This method returns Service Price list from Id
     @param            : List of Service Id
     @Return             : Map of Service Price Id
     @TriggerContext     :  After Update
     @Ticket #            : SSC-1979
    */
    public static Map<Id, List_Service_Price__c> getActiveServicesById(List<Id> listOfService) {

        Map<Id, List_Service_Price__c> servicesMap ;
        try {
            servicesMap = new Map<Id, List_Service_Price__c>([
                    SELECT Service_Type__c, Displayed_Name__c,CreatedDate,LastModifiedDate,Requires_Approval__c,
                            LastModifiedBy.Name,Is_Active__c,Name,Commission_In_Percentage__c,Commission_Per_Order__c,
                            Default_Commission_In_Percentage__c,Maximum_Commission_In_Percentage__c,Minimum_Commission_in_Percentage__c,
                            Minimum_Commission_Per_Order__c,Maximum_Commission_Per_Order__c,Type__c,Recurring_Fee__c,
                            Recurring_Interval__c,Id_Country__c,Id_Country__r.name,Company__c,Commission_Type__c,
                            CurrencyIsoCode,Scaled__c,Based_On__c
                    FROM List_Service_Price__c
                    WHERE Id = : listOfService
                    And Archived__c = false
                    ORDER BY LastModifiedDate DESC
                    LIMIT : limits.getLimitDmlRows()
            ]);
        } catch(Exception e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }

        return servicesMap;
    }
}