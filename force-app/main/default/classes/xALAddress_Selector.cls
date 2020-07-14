/**
* @author Mantas Jurkunas
* @date 09.09.2019
*
* @description Selector class for xAL_Address
*/

public with sharing class xALAddress_Selector {

    public static List<xAL_Address__c> getByIdAndType(xAL_Address__c address, String addressType, String valueField) {
        List<xAL_Address__c> addresses = new List<xAL_Address__c>();
        String addressId = address.Address_Id__c + '%';
        String query = 'SELECT '+
                'xAL_Country__c,'+
                'xAL_AdministrativeAreaName__c,'+
                'xAL_SubAdministrativeAreaName__c,'+
                'xAL_LocalityName__c,'+
                'xAL_DependentLocalityName__c,'+
                'Type__c,'+
                'Code__c,'+
                'Address_Id__c,'+
                'xAL_TranslatedAdministrativeArea__c,'+
                'xAL_TranslatedSubAdministrativeArea__c'+
                ' FROM xAL_Address__c'+
                ' WHERE Address_Id__c LIKE :addressId'+
                ' AND Type__c = :addressType'+
                ' AND ' + valueField + ' = \''+ String.escapeSingleQuotes((String) address.get(valueField)) + '\''+
                ' Order by xAL_Country__c,xAL_AdministrativeAreaName__c,xAL_SubAdministrativeAreaName__c,xAL_LocalityName__c';
        try {
            addresses = Database.query(query);
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }
        return addresses;
    }

    public static xAL_Address__c  getById(String addressId) {
        xAL_Address__c addresses;
        try {
            addresses = [SELECT
                    xAL_Country__c,
                    xAL_AdministrativeAreaName__c,
                    xAL_SubAdministrativeAreaName__c,
                    xAL_LocalityName__c,
                    xAL_DependentLocalityName__c,
                    Type__c,
                    Code__c,
                    Address_Id__c,
                    xAL_TranslatedAdministrativeArea__c,
                    xAL_TranslatedSubAdministrativeArea__c
            FROM xAL_Address__c
            WHERE  Id = :addressId
            Order by xAL_Country__c,xAL_AdministrativeAreaName__c,xAL_SubAdministrativeAreaName__c,xAL_LocalityName__c];
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }
        return addresses;
    }

}
