/**
* @author Mantas Jurkunas
* @date 09.09.2019
*
* @description Utility class for xAL_Address
*/

public with sharing class xALAddress_Utils {

    public static final Set<String> ID_FIELDS = new Set<String> {
            xAL_Address__c.xAL_Country__c.getDescribe().getLocalName(),
            xAL_Address__c.xAL_AdministrativeAreaName__c.getDescribe().getLocalName(),
            xAL_Address__c.xAL_SubAdministrativeAreaName__c.getDescribe().getLocalName(),
            xAL_Address__c.xAL_LocalityName__c.getDescribe().getLocalName(),
            xAL_Address__c.xAL_DependentLocalityName__c.getDescribe().getLocalName()
    };

    public static void populateAddressIds(List<xAL_Address__c> addresses) {
        for (xAL_Address__c address: addresses) {
            address.Address_Id__c = combineAddressFieldsToId(address, ID_FIELDS);
        }
    }

    private static String combineAddressFieldsToId(xAL_Address__c address, Set<String> fieldNames) {
        String addressId = '';
        for (String fieldName: fieldNames) {
            addressId += address.get(fieldName) == null ? '' : address.get(fieldName);
        }
        return addressId;
    }

    public static List<xAL_Address__c> getNextAddressLineValues(xAL_Address__c xALAddress) {
        List<xAL_Address__c> addresses = new List<xAL_Address__c>();
        CountryCompanyMapping__c companyInfo = CountryCompanyMapping__c.getInstance(xALAddress.xAL_Country__c);
        String recordTypeId = LibRecordTypeHelper.getRecordTypeValue(companyInfo.Company_Code__c + '_Account');
        Business_Config__c businessConfig = LibBusinessConfig.getBusinessConfigFromRuleMap('xALAddressObject', recordTypeId,xALAddress.xAL_Country__c + 'AddressMappingJSON');
        if(businessConfig == null) {
            businessConfig = LibBusinessConfig.getBusinessConfigFromRuleMap('xALAddressObject', recordTypeId,'AddressMappingJSON');
        }
        if (businessConfig == null) {
            return addresses;
        }
        Map<String, String> typeMap = (Map<String, String>) JSON.deserialize(businessConfig.Business_Rule_Value__c, Map<String, String>.class);
        if (!typeMap.containsKey(xALAddress.Type__c)) {
            return addresses;
        }
        addresses = xALAddress_Selector.getByIdAndType(xALAddress, typeMap.get(xALAddress.Type__c), getValueField(xALAddress));
        return addresses;
    }

    private static String getValueField(xAL_Address__c xALAddress) {
        String valueField;
        List<String> fieldNames = new List<String>(ID_FIELDS);
        for (Integer index=fieldNames.size()-1; index >= 0; index--) {
            if (xALAddress.get(fieldNames.get(index)) != null) {
                valueField = fieldNames.get(index);
                break;
            }
        }
        return valueField;
    }
  
    /**
    * @author William Castillo
    * @date 05.02.2020
    * @description get a map with the visibility of the text fields that should be display in the xal address moodel
    * @param CountryString
    * @return map<String,Boolean> key fielsd, values visible or not.
    */
    public static map<String,Boolean> getNextAddresslineText(String CountryString) {
        Map<String, map<String,Boolean>> mpFieldsbyCountry  = new Map<String, map<String,Boolean>>();
        map<String,Boolean> mpFields = new map<String,Boolean>();
        CountryCompanyMapping__c companyInfo = CountryCompanyMapping__c.getInstance(CountryString);
        String recordTypeId = LibRecordTypeHelper.getRecordTypeValue(companyInfo.Company_Code__c + '_Account');
        Business_Config__c businessConfig = LibBusinessConfig.getBusinessConfigFromRuleMap('xALAddressObject', recordTypeId,'TextFieldVisibility');

        if (businessConfig == null) {
            return mpFields;
        }
        mpFieldsbyCountry = (Map<String, map<String,Boolean>>) JSON.deserialize(businessConfig.Business_Rule_Value__c, Map<String, map<String,Boolean>>.class);
        if(mpFieldsbyCountry.containsKey(CountryString)){
            return mpFieldsbyCountry.get(CountryString);
        }
        return mpFields;
    }

}
