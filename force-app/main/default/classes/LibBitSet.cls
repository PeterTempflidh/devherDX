/*
* Apex doesn't expose dependent picklist info directly, but it's possible to expose.
* Approach:
*  * Schema.PicklistEntry doesn't expose validFor tokens, but they are there, and can be accessed by serializing to JSON
*    (and then for convenience, deserializing back into an Apex POJO)
*  * validFor tokens are converted from base64 representations (e.g. gAAA) to binary (100000000000000000000)
*    each character corresponds to 6 bits, determined by normal base64 encoding rules.
*  * The binary bits correspond to controlling values that are active - e.g. in the example above, this dependent option
*    is available for the first controlling field only.
* 
* by Benj Kamm, 2017
* CC BY-SA 3.0 (http://creativecommons.org/licenses/by-sa/3.0/us/)
*/
public class LibBitSet {

    public static Map<String, String> getDependentOptionsImpl(Schema.SObjectField theField, Schema.SObjectField ctrlField) {
        // validFor property cannot be accessed via a method or a property,
        // so we need to serialize the PicklistEntry object and then deserialize into a wrapper.
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries =
                LibBitSet.wrapPicklistEntries(theField.getDescribe().getPicklistValues());

        // Set up the return container - Map<ControllingValue, List<DependentValues>>
        Map<String, String> objResults = new Map<String, String>();
        List<String> controllingValues = new List<String>();

        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getValue();
            //objResults.put(label, new List<String>());
            controllingValues.add(label );
        }

        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.value;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                // For each bit, in order: if it's a 1, add this label to the dependent list for the corresponding controlling value
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.put(label,controllingValues.get(i));
                }
            }
        }

        return objResults;
    }

    // Convert decimal to binary representation (alas, Apex has no native method :-(
    //    eg. 4 => '100', 19 => '10011', etc.
    // Method: Divide by 2 repeatedly until 0. At each step note the remainder (0 or 1).
    // These, in reverse order, are the binary.
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }

    // Convert a base64 token into a binary/bits representation
    // e.g. 'gAAA' => '100000000000000000000'
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';

        String validForBits = '';

        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }

        return validForBits;
    }


    private static final String base64Chars = '' +
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
            'abcdefghijklmnopqrstuvwxyz' +
            '0123456789+/';


    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }

    public class PicklistEntryWrapper {
        public String active {get; set;}
        public String defaultValue {get; set;}
        public String label {get; set;}
        public String value {get; set;}
        public String validFor {get; set;}
    }

}