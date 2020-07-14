/**
* @author Mantas Jurkunas
* @date 09.09.2019
*
* @description Controller for VueXalAddressComponents.component
*/

public with sharing class VueXalAddressComponents_Controller {

    @RemoteAction
    public static List<AddressLine> getAddressLines(xAL_Address__c address) {
        List<AddressLine> addressLines = new List<AddressLine>();
        if (address.Id != null) {
            address = xALAddress_Selector.getById(address.Id);
        }
        List<xAL_Address__c> addresses = xALAddress_Utils.getNextAddressLineValues(address);
        if (addresses.isEmpty()) {
            return addressLines;
        }
        String valueField = getAddressValueField(addresses.get(0), address);
        if (valueField == null) {
            return addressLines;
        }
        for (xAL_Address__c xALAddress: addresses) {
            for (String addressField: xALAddress_Utils.ID_FIELDS) {
                if (!addressField.equals(valueField)) {
                    xALAddress.put(addressField, null);
                }
            }
            addressLines.add(new AddressLine(xALAddress, valueField));
        }
        return addressLines;
    }

    /**
    * @author William Castillo
    * @date 05.02.2020
    * @description get a map with the visibility of the text fields that should be display in the xal address moodel
    * @param CountryString
    * @return map<String,Boolean> key fielsd, values visible or not.
    */

    @RemoteAction
    public static map<String,Boolean>  getAddressLinesText(String CountryString) {

        return xALAddress_Utils.getNextAddresslineText(CountryString);
    }


    private static String getAddressValueField(xAL_Address__c newAddress, xAL_Address__c previousAddress) {
        for (String addressField: xALAddress_Utils.ID_FIELDS) {
            if (previousAddress.get(addressField) == null && newAddress.get(addressField) != null) {
                return addressField;
            }
        }
        return null;
    }

    private class AddressLine {
        public String addressValue { get; set; }
        public xAL_Address__c address { get; set; }
        public AddressLine (xAL_Address__c address, String fieldName) {
            this.addressValue = (String) address.get(fieldName);
            this.address = address;
        }
    }
}