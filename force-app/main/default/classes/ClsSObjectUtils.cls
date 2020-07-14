/**
* @author Mantas Jurkunas
* @date 09.01.2019
*
* @description Utility class containing generic methods for SObjects
*/

public inherited sharing class ClsSObjectUtils {
    //TODO: move all errors to a single class/setting
    private static final String ERROR_DUPLICATE = 'Error! Duplicate value found ({0})! ({1} ,{2})';
    private static final String ERROR_FIELDS= 'Error! No field values provided for filtering a list.';
    private static final String EMPTY_STRING = '';
    
    /*******************************************************************************************************
    * @description Validates Delivery Service field on Account and Lead
    * @param objects List<SObject> list of objects to convert.
    * @return void
    */
    public static void validateLeadDeliveryService(List<SObject> objList) {
        Schema.SObjectType sObjectType = objList.getSObjectType();
        if (sObjectType != null){
            String listType = 'List<' + sObjectType + '>';
            List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
            List<String> deliveryService = new List<String>();
            castRecords.addAll(objList);
            for(sObject obj : castRecords) {
            	deliveryService = null != obj.get('Delivery_Service__c') ? 
                    String.valueof(obj.get('Delivery_Service__c')).split(';') : new List<String>();
                if(!deliveryService.isEmpty()){
                    // None - No other values, Unknown - No other values,
                    if( ( deliveryService.contains('None') || deliveryService.contains('Unknown') ) && deliveryService.size()> 1 ) {
                        obj.addError(Label.Delivery_Service_None_Unknown_Validation);
                    }
                    // DH Delivery; Hybrid - This cobination can not exist , Partner Delivery; Hybrid - This cobination can not exist
                    if( (deliveryService.contains('DH Delivery') && deliveryService.contains('Hybrid'))
                        || (deliveryService.contains('Partner Delivery') && deliveryService.contains('Hybrid'))
                        )  {
                          string deliveryServiceValues = '';
                          for(string val : deliveryService) {
                              deliveryServiceValues += val + ', ';
                          }
                          List<Object> parameters = new List<Object>{deliveryServiceValues};
                          String formattedError = String.format(Label.Delivery_Service_Invalid_Combination, parameters);
                          obj.addError(formattedError);
                    }
                    
                    //DH Delivery;Partner Delivery - Please select Hybrid
                    if (deliveryService.contains('DH Delivery') && deliveryService.contains('Partner Delivery')){
                         obj.addError(Label.Delivery_Service_Hybrid_Validation);
                    }
               }
            }
        }
    }

    public static Set<Id> extractSetIds(List<SObject> objects, String fieldName) {
        Set<Id> idSet = new Set<Id>();
        if (objects.isEmpty() || String.isBlank(fieldName)) {
            return idSet;
        }
        for (SObject aobject: objects) {
            idSet.add( (Id) aobject.get(fieldName));
        }
        return idSet;
    }

    /**
     *  @description Extract set of string based on a provided field name from the object list.
     *  @param objects objects from where the string value should be extracted
     *  @param fieldName field name from which the String value should be extracted
     *  @return extracted field values
    */
    public static Set<String> extractSetStrings(List<SObject> objects, String fieldName) {
        Set<String> idSet = new Set<String>();
        if (objects.isEmpty() || String.isBlank(fieldName)) {
            return idSet;
        }
        for (SObject aobject: objects) {
            idSet.add( (String) getFieldValue(aobject,fieldName));
        }
        return idSet;
    }

    /*******************************************************************************************************
    * @description Converts a list of objects to a Map, by a provided field as a key. Generally used with key fields that are unique.
    * @param objects List<SObject> list of objects to convert.
    * @param fieldName String key field.
    * @return Map<String, SObject>
    */
    public static Map<String, SObject> convertToSingleStringMap(final List<SObject> objects, final String fieldName) {
        String soBjectTypeString = String.valueOf(objects[0].getSObjectType());
        Type t= Type.forName('Map<String,'+soBjectTypeString+'>');
        Map<String,SObject> stringMap =(Map<String,SObject>)t.newInstance();
        for(SObject aObject: objects) {
            String key = (String) aObject.get(fieldName);
            if(stringMap.containsKey(key)) {
                System.debug(String.format(ERROR_DUPLICATE, new List<String> {key, stringMap.get(key).Id, aObject.Id}));
                throw new SObjectUtilsException(String.format(ERROR_DUPLICATE, new List<String> {key, stringMap.get(key).Id, aObject.Id}));
            }
            stringMap.put(key, aObject);
        }

        return stringMap;
    }

    /*******************************************************************************************************
    * @description Converts a list of objects to a Map, by a provided field as a key. The key should be an Id field
    * @param objects List<SObject> list of objects to convert.
    * @param fieldName String key field.
    * @return Map<Id, List<SObject>>
    */
    public static Map<Id, List<SObject>> convertToIdMap(final List<SObject> objects, final String fieldName) {
        Map<Id,List<SObject>> idMap = new Map<Id, List<SObject>>();
        for(SObject aObject: objects) {
            Id key = (Id) aObject.get(fieldName);
            if(idMap.containsKey(key)) {
                idMap.get(key).add(aObject);
                continue;
            }
            idMap.put(key, new List<SObject>{aObject});
        }

        return idMap;
    }

    /*******************************************************************************************************
    * @description Updates existing approval processes to selected action
    * @param targetIds Set<Id> ids of objects that are in approval process.
    * @param action action that the approval should take e.g. 'Removed'.
    */
    public static void updateApprovalProcesses(Set<Id> targetIds, String action)
    {
        List<ProcessInstanceWorkitem> workItems = ProcessInstanceWorkItemSelector.findActiveWorkItemsByTargetIds(targetIds);
        List<Approval.ProcessWorkitemRequest> approvalRequests = new List<Approval.ProcessWorkitemRequest>();
        for(ProcessInstanceWorkitem workItem: workItems) {
            Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
            pwr.setAction(action);
            pwr.setWorkitemId(workItem.Id);
            approvalRequests.add(pwr);
        }
        //TODO: handle the result
        List<Approval.ProcessResult> result = Approval.process(approvalRequests);
    }

    /**
     * @description check whether fields have been updated to specific values or changed.
     *
     * @param newValues
     * @param oldValues
     * @param allOrNothing If set to true all the criteria will have to match.
     * @param fieldMap Map key is the field name. Map value is what value the field should be changed to (e.g Status => { Closed, New }). If the map value Set is empty,
     *                  the field defined in the Map key is checked for any change.
     *
     * @return objects that have been updated
     */
    public static List<SObject> filterFieldValues(final List<SObject> newValues, final Map<Id, SObject> oldValues, final Map<String, Set<Object>> fieldMap, final Boolean allOrNothing) {
        Set<SObject> changedValues = new Set<SObject>();
        if (newValues == null || newValues.isEmpty() || (oldValues != null && oldValues.isEmpty()) || fieldMap == null || fieldMap.isEmpty()) {
            return new List<SObject>(changedValues);
        }
        for (SObject newValue : newValues) {
            SObject oldValue = oldValues == null ? null : oldValues.get(newValue.Id);
            if (!allOrNothing) {
                for (String fieldName : fieldMap.keySet()) {
                    Set<Object> fieldValues = fieldMap.get(fieldName);
                    if (fieldValues == null) {
                        System.debug(System.LoggingLevel.ERROR, ERROR_FIELDS);
                        throw new SObjectUtilsException(ERROR_FIELDS);
                    } else if (oldValues == null && (fieldValues.contains(getFieldValue(newValue, fieldName)) || (fieldValues.isEmpty() && getFieldValue(newValue, fieldName) != null ))) {
                        changedValues.add(newValue);
                    } else if ( oldValues != null && (getFieldValue(newValue, fieldName) != getFieldValue(oldValue, fieldName) &&  (fieldValues.isEmpty() || fieldValues.contains(getFieldValue(newValue, fieldName))))) {
                        changedValues.add(newValue);
                    }
                }
            } else {
                Boolean criteriaMet = true;
                Boolean valueChanged = false;
                for (String fieldName : fieldMap.keySet()) {
                    Set<Object> fieldValues = fieldMap.get(fieldName);
                    if (fieldValues == null) {
                        System.debug(System.LoggingLevel.ERROR, ERROR_FIELDS);
                        throw new SObjectUtilsException(ERROR_FIELDS);
                    } else if (oldValues == null && ((!fieldValues.isEmpty() && !fieldValues.contains(getFieldValue(newValue, fieldName))) || (fieldValues.isEmpty() && getFieldValue(newValue, fieldName) == null ))) {
                        criteriaMet = false;
                        break;
                    } else if (oldValues != null) {
                        if (!fieldValues.isEmpty() && !fieldValues.contains(getFieldValue(newValue, fieldName))) {
                            criteriaMet = false;
                            break;
                        }
                        if (getFieldValue(newValue, fieldName) != getFieldValue(oldValue, fieldName)) {
                            valueChanged = true;
                        }
                    }
                }
                if (criteriaMet && (oldValues == null || valueChanged) ) {
                    changedValues.add(newValue);
                }
            }
        }
        return new List<SObject>(changedValues);
    }

    /**
     * @description check whether fields have been updated to specific values or changed.
     *
     * @param newValues
     * @param oldValues
     * @param fieldMap Map key is the field name. Map value is what value the field should be changed to (e.g Status => { Closed, New }). If the map value Set is empty,
     *                  the field defined in the Map key is checked for any change.
     *
     * @return objects that have been updated
     */
    public static List<SObject> filterFieldValues(final List<SObject> newValues, final Map<Id, SObject> oldValues, final Map<String, Set<Object>> fieldMap) {
        return filterFieldValues(newValues, oldValues, fieldMap, false);
    }

    /**
     * @description check whether fields have specific values.
     *
     * @param newValues
     * @param allOrNothing If set to true all the criteria will have to match.
     * @param fieldMap Map key is the field name. Map value is what value the field should have (e.g Status => { Closed, New }). If empty set is passed, the field will be checked if it is not null.
     *
     * @return objects that match the criteria
     */
    public static List<SObject> filterFieldValues(final List<SObject> objectValues, final Map<String, Set<Object>> fieldMap, Boolean allOrNothing) {
        return filterFieldValues(objectValues, null, fieldMap, allOrNothing);
    }

    /**
     * @description check whether fields have a specific values, this woks if any of the fields match the criteria.
     *
     * @param newValues
     * @param fieldMap Map key is the field name. Map value is what value the field should have (e.g Status => { Closed, New }). If empty set is passed, the field will be checked if it is not null.
     *
     * @return objects that match the criteria
     */
    public static List<SObject> filterFieldValues(final List<SObject> objectValues, final Map<String, Set<Object>> fieldMap) {
        return filterFieldValues(objectValues, null, fieldMap, false);
    }

    public static Object getFieldValue(SObject sfObject, String fieldName) {
        try {
            List<String> fieldHierarchy = fieldName.split('\\.');
            if (fieldHierarchy.size() > 1) {
                sfObject = sfObject.getSObject(fieldHierarchy[0]);
                return sfObject == null ? null : getFieldValue(sfObject, fieldName.substringAfter('.'));
            } else {
                return sfObject.get(fieldName);
            }
        } catch (NullPointerException e) {}
        return null;
    }


    /**
     * @description swap map key with value, for single value maps only.
     *
     * @param valueMap map with one value per key
     *
     * @return reversed map
     */
    public static Map<String, String> reverseStringMap(final Map<String, String> valueMap) {
        if (valueMap == null || valueMap.isEmpty()) {
            return valueMap;
        }
        Map<String, String> reversedMap = new Map<String, String>();
        for (String mapKey: valueMap.keySet()) {
            if (!reversedMap.containsKey(valueMap.get(mapKey))) {
                reversedMap.put(valueMap.get(mapKey), mapKey);
            }
        }
        return reversedMap;
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }

    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.fieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields();
    }

    /**
    * @description Checks unsuccessful save result and concatinate into a single error string
    *
    * @param saveResult saveResult
    * @param record record with error
    *
    * @return error result
    */
    public static String getErrorString(Database.SaveResult saveResult, SObject record) {
        String errorString = EMPTY_STRING;
        for (Database.Error saveError: saveResult.getErrors()) {
            errorString += '\n' + saveError.getMessage();
        }
        if (String.isNotEmpty(errorString)) {
            errorString = 'Record Id: ' + String.valueOf(record.Id) + errorString + '\n';
        }
        return errorString;
    }

    @TestVisible
    private class SObjectUtilsException extends Exception {}

}
