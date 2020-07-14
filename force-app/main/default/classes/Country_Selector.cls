/**
* @author Mantas Jurkunas
* @date 09.09.2019
*
* @description Selector class for Country__c
*/

public with sharing class Country_Selector {

    public static Country__c getByName(String countryName) {
        Country__c country;
        try {
            country = [SELECT Id, Name, Iso__c FROM Country__c WHERE Name = :countryName];
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }
        return country;
    }

}