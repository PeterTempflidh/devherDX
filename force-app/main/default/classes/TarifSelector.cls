/**
* @author Chaitali Kumari
* @date 13.05.2019
*
* @description Selector class for retrieving Tarif records
*/
public with sharing class TarifSelector {

    /*******************************************************************************************************
   * @description Queries to get a tarif record based on certain filters. Should be inactive tarif as used for API only
   * @param String Name, Record Type developerName (String), Company Code (string), Record Country (String)
   * @return Tarif__c
   */

    public static Tarif__c findTarifRecordByTarifName(String pTarifName, String companyCode, String recCountry) {
        Tarif__c tarif;
        String tarifName = '%'+pTarifName+'%';
        try {
            tarif = [select id from Tarif__c where Name like :tarifName and recordtype.developername=:companyCode+'_Tarif'
                     and id_country__r.name=:recCountry LIMIT 1];
        } catch(Exception e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return tarif;
    }

    /*******************************************************************************************************
* @description Queries to get a tarif record by set of country
* @param String   Countries (set<String>)
* @return map<id,Tarif__c>
*/

    public static  Map<Id, Tarif__c> findTarifRecordByCountries(set<Id> Countries) {
        Map<Id, Tarif__c> tariffsMap ;
        try {
            tariffsMap = new Map<Id, Tarif__c>([
                    SELECT Id, Is_Active__c, CreatedDate, LastModifiedDate, LastModifiedBy.Name, Name, Id_Country__c,
                            Id_Country__r.name, Company__c, Is_Locked__c,Product_Only__c,Categories__c,
                    (SELECT Id, Id_Tarif_Item__c, Tarif_Name__c, Type__c FROM Tarif_Members__r )
                    FROM Tarif__c
                    WHERE Id_Country__c IN : Countries
                    And Archived__c = false
                    ORDER BY LastModifiedDate DESC
                    LIMIT 700
            ]);
        } catch(Exception e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return tariffsMap;
    }
}