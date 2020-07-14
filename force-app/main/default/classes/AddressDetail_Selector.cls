/**
* @author Mantas Jurkunas
* @date 21.05.2019
*
* @description Selector class for AddressDetail sObject
*/
public with sharing class AddressDetail_Selector {

    public static final string ERROR_QUERY_ADDRESS_ACCOUNT = 'Query On Address with Account Id Filter';
    public static final string METHOD_GET_ADDRESS_BY_ACCOUNT = 'getAddressByAccountIds Method : ';

    public static AddressDetail__c getXalById(Id addressId) {
        AddressDetail__c addressDetail;
        try {
            addressDetail = [
                    SELECT
                            Account__c,
                            AddressLine__c,
                            AdministrativeAreaCode__c,
                            AdministrativeAreaType__c,
                            AdministrativeAreaName__c,
                            AdministrativeAreaDevName__c,
                            CountryName__c,
                            CountryDevName__c,
                            CountryCode__c,
                            DependentlocalityCode_1__c,
                            DependentLocalityDevName_1__c,
                            DependentLocalityName_1__c,
                            DependentLocalityType_1__c,
                            DependentlocalityCode_2__c,
                            DependentLocalityDevName_2__c,
                            DependentLocalityName_2__c,
                            DependentLocalityType_2__c,
                            DependentlocalityCode_3__c,
                            DependentLocalityDevName_3__c,
                            DependentLocalityName_3__c,
                            DependentLocalityType_3__c,
                            LocalityCode__c,
                            LocalityName__c,
                            LocalityType__c,
                            LocalityDevName__c,
                            PostalCodeName__c,
                            PostalCodeDevName__c,
                            SubAdministrativeAreaCode__c,
                            SubAdministrativeAreaName__c,
                            SubAdministrativeAreaType__c,
                            SubAdministratriveAreaDevName__c,
                            Type__c,
                            LatLng__Longitude__s,
                            LatLng__Latitude__s,
                            Translated_Street_Name__c,
                            Translated_City_Name__c,
                            Translated_Area_Name__c
                    FROM AddressDetail__c
                    WHERE Id = :addressId
                       ];
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }
        return addressDetail;
    }

    public static AddressDetail__c getById(Id addressId) {
        AddressDetail__c addressDetail;
        try {
            addressDetail = [
                    SELECT
                            Id,
                            Account__c,
                            Account__r.Record_Country__c,
                            Type__c,
                            LatLng__Latitude__s,
                            LatLng__Longitude__s,
                            DAUM_Address_Model__c,
                            DAUM_Building_Name_long_name__c,
                            DAUM_Building_Name_short_name__c,
                            DAUM_Building_Number_long_name__c,
                            DAUM_Building_Number_short_name__c,
                            DAUM_Detailed_Address_long_name__c,
                            DAUM_Detailed_Address_short_name__c,
                            DAUM_Additional_Description_long_name__c,
                            DAUM_Additional_Description_short_name__c,
                            GPA_Country_long_name__c,
                            GPA_Country_short_name__c,
                            GPA_Admin_area_level_1_short_name__c,
                            GPA_Admin_area_level_1_long_name__c,
                            GPA_Locality_long_name__c,
                            GPA_Locality_short_name__c,
                            GPA_Sublocality_level_1_long_name__c,
                            GPA_Sublocality_level_1_short_name__c,
                            GPA_Sublocality_level_2_long_name__c,
                            GPA_Sublocality_level_2_short_name__c,
                            GPA_Sublocality_level_3_long_name__c,
                            GPA_Sublocality_level_3_short_name__c,
                            GPA_Sublocality_level_4_long_name__c,
                            GPA_Sublocality_level_4_short_name__c,
                            GPA_Route_long_name__c,
                            GPA_Route_short_name__c,
                            GPA_Street_number_long_name__c,
                            GPA_Street_number_short_name__c,
                            GPA_Postal_code_long_name__c,
                            GPA_Postal_code_short_name__c,
                            GPA_Premise_long_name__c,
                            GPA_Premise_short_name__c,
                            GPA_formatted_address__c,
                            GPA_Place_id__c,
                            GPA_Was_modified_manually__c,
                            LocalityName__c,
                            LocalityDevName__c,
                            LocalityCode__c,
                            LocalityType__c
                    FROM AddressDetail__c
                    WHERE Id = :addressId
            ];
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }

        return addressDetail;
    }

    public static List<AddressDetail__c> getByIdAndAccountId(Id addressId, Id accountId) {
        List<AddressDetail__c> addressDetails = new List<AddressDetail__c>();
        try {
            addressDetails = [
                    SELECT
                            Id,
                            Account__c,
                            Account__r.Record_Country__c,
                            Type__c,
                            LatLng__Latitude__s,
                            LatLng__Longitude__s,
                            DAUM_Address_Model__c,
                            DAUM_Building_Name_long_name__c,
                            DAUM_Building_Name_short_name__c,
                            DAUM_Building_Number_long_name__c,
                            DAUM_Building_Number_short_name__c,
                            DAUM_Detailed_Address_long_name__c,
                            DAUM_Detailed_Address_short_name__c,
                            DAUM_Additional_Description_long_name__c,
                            DAUM_Additional_Description_short_name__c,
                            GPA_Country_long_name__c,
                            GPA_Country_short_name__c,
                            GPA_Admin_area_level_1_short_name__c,
                            GPA_Admin_area_level_1_long_name__c,
                            GPA_Locality_long_name__c,
                            GPA_Locality_short_name__c,
                            GPA_Sublocality_level_1_long_name__c,
                            GPA_Sublocality_level_1_short_name__c,
                            GPA_Sublocality_level_2_long_name__c,
                            GPA_Sublocality_level_2_short_name__c,
                            GPA_Sublocality_level_3_long_name__c,
                            GPA_Sublocality_level_3_short_name__c,
                            GPA_Sublocality_level_4_long_name__c,
                            GPA_Sublocality_level_4_short_name__c,
                            GPA_Route_long_name__c,
                            GPA_Route_short_name__c,
                            GPA_Street_number_long_name__c,
                            GPA_Street_number_short_name__c,
                            GPA_Postal_code_long_name__c,
                            GPA_Postal_code_short_name__c,
                            GPA_Premise_long_name__c,
                            GPA_Premise_short_name__c,
                            GPA_formatted_address__c,
                            GPA_Place_id__c,
                            GPA_Was_modified_manually__c,
                            LocalityName__c,
                            LocalityDevName__c,
                            LocalityCode__c,
                            LocalityType__c
                    FROM AddressDetail__c
                    WHERE Id = :addressId
                    OR Account__c = :accountId
            ];
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }

        return addressDetails;
    }

    public static List<AddressDetail__c> getByAccountId(String accountId) {
        List<AddressDetail__c> addressDetails = new List<AddressDetail__c>();
        try {
            addressDetails = [SELECT Id,FormattedAddress__c,Type__c,AddressLine__c FROM AddressDetail__c WHERE Account__c = :accountId];
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }
        return addressDetails;
    }

    /*
    * @description Selector class for AccountId -> AddressDetail map
    */
    public static Map<Id, AddressDetail__c> getAccountIdBillingAddressMap(Set<Id> accountIds) {
        Map<Id, AddressDetail__c> addMap = new Map<Id, AddressDetail__c>();
        List<AddressDetail__c> addresses =  [SELECT Id, Account__c, FormattedAddress__c,Type__c, Global_City_Label__c, CountryName__c,Global_Country_Label__c, CountryCode__c 
                                             FROM AddressDetail__c 
                                             WHERE Account__c IN :accountIds
                                             AND Type__c INCLUDES ('Billing Address')];
        if(addresses != null && !addresses.isEmpty()) {
            for(AddressDetail__c addr : addresses) {
                addMap.put(addr.Account__c, addr);
            }
        } 
        
        return addMap;
    }

    /*
    * @description Selector class for AccountId -> AddressDetail map
    */
    public static Map<Id, AddressDetail__c> getAccountIdREstaurantAddressMap(Set<Id> accountIds) {
        Map<Id, AddressDetail__c> addMap = new Map<Id, AddressDetail__c>();
        List<AddressDetail__c> addresses =  [SELECT Id, Account__c, FormattedAddress__c,Type__c, Global_City_Label__c, CountryName__c,Global_Country_Label__c, Account__r.Record_Country__c , CountryCode__c
        FROM AddressDetail__c
        WHERE Account__c IN :accountIds
        AND Type__c INCLUDES ('Restaurant Address')];
        if(addresses != null && !addresses.isEmpty()) {
            for(AddressDetail__c addr : addresses) {
                addMap.put(addr.Account__c, addr);
            }
        }

        return addMap;
    }

    public static List<AddressDetail__c> getByAccountIdsFilterIds(final Set<Id> accountIds, final Set<Id> addressIds) {
        List<AddressDetail__c> addressDetails = new List<AddressDetail__c>();
        try {
            addressDetails = [
                    SELECT
                            Id,
                            Type__c,
                            DAUM_Address_Model__c,
                            Global_Country_Code__c,
                            Account__r.RecordType.DeveloperName,
                            Account__c
                    FROM AddressDetail__c
                    WHERE Account__c IN :accountIds
                    AND Id NOT IN :addressIds
            ];
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }

        return addressDetails;
    }

    public static List<AddressDetail__c> getByAccountIds(final Set<Id> accountIds) {
        List<AddressDetail__c> addressDetails = new List<AddressDetail__c>();
        try {
            addressDetails = [
                    SELECT
                            Id,
                            Type__c,
                            DAUM_Address_Model__c,
                            Global_Country_Code__c,
                            Account__r.RecordType.DeveloperName,
                            Account__c
                    FROM AddressDetail__c
                    WHERE Account__c IN :accountIds
            ];
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }

        return addressDetails;
    }

    public static List<AddressDetail__c> getByAccountIdsAndDaumModel(final Set<Id> accountIds, final String daumModel) {
        List<AddressDetail__c> addressDetails = new List<AddressDetail__c>();
        try {
            addressDetails = [
                    SELECT
                            Id,
                            Type__c,
                            DAUM_Address_Model__c,
                            Global_Country_Code__c,
                            Account__r.RecordType.DeveloperName,
                            Account__c
                    FROM AddressDetail__c
                    WHERE Account__c IN :accountIds
                    AND DAUM_Address_Model__c = :daumModel
            ];
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }

        return addressDetails;
    }
    /*******************************************************************************************************
    * @description Get List of Addresses based on Account Id.added fieldS for GPA address (SSC-2794)
    * @param setOfAccountIds Set of Ids of the Account
    * @return List<AddressDetail__c>
    * @jira SSC-335
    */
    public static List<AddressDetail__c> getAddressByAccountIds(final Set<Id> setOfAccountIds) {
        List<AddressDetail__c> addressDetails = new List<AddressDetail__c>();
        try {
            addressDetails = [
                    SELECT
                            Id,
                            Account__c,
                            Account__r.Record_Country__c,
                            Type__c,
                            LatLng__Latitude__s,
                            LatLng__Longitude__s,
                            LocalityName__c,
                            LocalityDevName__c,
                            LocalityCode__c,
                            LocalityType__c,
                            AdministrativeAreaName__c,
                            AdministrativeAreaType__c,
                            SubAdministrativeAreaCode__c,
                            SubAdministrativeAreaName__c,
                            SubAdministrativeAreaType__c,
                            SubAdministratriveAreaDevName__c,
                            CountryCode__c,
                            AdministrativeAreaDevName__c,
                            AdministrativeAreaCode__c,
                            Translated_City_Name__c,
                            Translated_Street_Name__c,
                            AddressLine__c,
                            CountryDevName__c,
                            CountryName__c,
                            Account__r.RecordType.DeveloperName,
                            PostalCodeDevName__c,
                            PostalCodeName__c,
                            Translated_Area_Name__c,
                            DependentlocalityCode_1__c,
                            DependentLocalityDevName_1__c,
                            DependentLocalityName_1__c,
                            DependentLocalityType_1__c,
                            DependentlocalityCode_2__c,
                            DependentLocalityDevName_2__c,
                            DependentLocalityName_2__c,
                            DependentLocalityType_2__c,
                            DependentlocalityCode_3__c,
                            DependentLocalityDevName_3__c,
                            DependentLocalityName_3__c,
                            DependentLocalityType_3__c,
                            GPA_Route_long_name__c,
                            GPA_Route_short_name__c,
                            GPA_Street_number_long_name__c,
                            GPA_Street_number_short_name__c,
                            GPA_Postal_code_long_name__c,
                            GPA_Postal_code_short_name__c,
                            GPA_Locality_long_name__c,
                            GPA_Locality_short_name__c,
                            GPA_Country_long_name__c,
                            GPA_Country_short_name__c,
                            GPA_Admin_area_level_1_short_name__c,
                            GPA_Admin_area_level_1_long_name__c,
                            GPA_formatted_address__c,
                            GPA_Place_id__c,
                            GPA_Was_modified_manually__c
                    FROM AddressDetail__c
                    WHERE Account__c IN :setOfAccountIds
            ];
        } catch (Exception ex) { ClsLogErrorMessage.logMessages(ERROR_QUERY_ADDRESS_ACCOUNT,
                METHOD_GET_ADDRESS_BY_ACCOUNT + ex.getMessage() + ex.getStackTraceString());
        }

        return addressDetails;
    }

    /**
    * @date     : [18/06/2020]
    * @method name  : getAddressByType
    * @description  : method to return the the address details
    * @param addressType [Address Type Field]
    * @return List<AddressDetail__c>
    */
    public static List<AddressDetail__c> getAddressByType(String addressType) {

        List<AddressDetail__c> addressDetails = [SELECT Id, Account__c, Type__c FROM AddressDetail__c where Type__c =: addressType];
        return addressDetails;
    }

}
