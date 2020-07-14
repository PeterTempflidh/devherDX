/**
* @author Aleksejs Jedamenko
* @date 28.10.2019
*
* @description Controller for GenericCustomPicklist component
*/
public class GenericCustomPicklist_AuraController {
    
    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;

    /**
    * @author Aleksejs Jedamenko
    * @date 28.10.2019
    *
    * @description Inner class to wrap data received from GenericCustomPicklist component js controller
    */
    public class BusinessConfigWrapperReceived {

        public String fieldToDisplay, fieldToUpdate, picklistCustomLabel, messageTitleCustomLabel, messageBodyCustomLabel, messageSeverity, SOQLQuery;
        public Boolean isPleaseSelectOptionDisplayed, isNoneOptionDisplayed, isMessageDisplayed;
        
    }

    /**
    * @author Aleksejs Jedamenko
    * @date 28.10.2019
    *
    * @description Inner class to wrap data sent to GenericCustomPicklist component js controller
    */
    public class BusinessConfigWrapperToSend {

        public String fieldToDisplay, fieldToUpdate, picklistCustomLabel, messageTitleCustomLabel, messageBodyCustomLabel, messageSeverity, currentValue;
        public Boolean isPleaseSelectOptionDisplayed, isNoneOptionDisplayed, isMessageDisplayed;
        public List<String> picklistData;
        
    }

    /**
     * @description this method collects all necessary data for GenericCustomPicklist component
     *
     * @param businessRuleName - name of business rule which contains JSON with parameters necessary for GenericCustomPicklist component (rule under CustomPicklistSettings process name) 
     * @param recordId - current record id
     * @param sObjectName - current object API-name
     * @return String - returns serialized BusinessConfigWrapperToSend class
     */
    @AuraEnabled
    public static String getDataFromBusinessConfig(String businessRuleName, String recordId, String sObjectName){
        
        String query = 'SELECT RecordTypeId FROM '+ sObjectName + ' WHERE Id=\''+recordId+'\'';
        Integer properNumberOfBusinessConfigRecords = Integer.valueOf(System.Label.Custom_Label_Required_Number_Of_Business_Config_Records);  
        List<SObject> result = Database.query(query);
        String recordTypeName;
        if (result.size()==0) {

            return JSON.serialize(new Map<String,String>{'error' => System.Label.Custom_Picklist_Server_Error_Message});
        } else {
            
            String recordTypeId = (String) result[0].get('RecordTypeId');
            recordTypeName = LibRecordTypeHelper.getRecordTypeValue(recordTypeId);
            if (recordTypeName==null) {
                return JSON.serialize(new Map<String,String>{'error' => System.Label.Custom_Picklist_Server_Error_Message});
            }
        }
        Map<String, Map<String, Business_Config__c>> businessConfigMapOnRecordTypeLevel = moam.get('CustomPicklistSettings');
        if (businessConfigMapOnRecordTypeLevel == null || !businessConfigMapOnRecordTypeLevel.containsKey(recordTypeName) || !businessConfigMapOnRecordTypeLevel.get(recordTypeName).containsKey(businessRuleName)) {

            return JSON.serialize(new Map<String,String>{'error' => System.Label.Custom_Picklist_No_Business_Config_Error_Message});
        }
        String businessRuleValue = (String) businessConfigMapOnRecordTypeLevel.get(recordTypeName).get(businessRuleName).get('Business_Rule_Value__c');
        BusinessConfigWrapperReceived wrappedReceivedBusinessRuleValue; 
        try {

            wrappedReceivedBusinessRuleValue = (BusinessConfigWrapperReceived) JSON.deserialize(businessRuleValue, BusinessConfigWrapperReceived.class);
        } catch (JSONException ex) {

            system.debug('Exception data: '+ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getMessage()+'\n'+ex.getStackTraceString());
            return JSON.serialize(new Map<String,String>{'error' => System.Label.Custom_Picklist_Bad_Business_Config_Bad_Message});
        }
        if (wrappedReceivedBusinessRuleValue.fieldToDisplay==null || wrappedReceivedBusinessRuleValue.fieldToUpdate==null || wrappedReceivedBusinessRuleValue.picklistCustomLabel==null || wrappedReceivedBusinessRuleValue.isPleaseSelectOptionDisplayed==null || wrappedReceivedBusinessRuleValue.isNoneOptionDisplayed==null || wrappedReceivedBusinessRuleValue.isMessageDisplayed==null ||
        wrappedReceivedBusinessRuleValue.messageTitleCustomLabel==null || wrappedReceivedBusinessRuleValue.messageBodyCustomLabel==null || wrappedReceivedBusinessRuleValue.messageSeverity==null || wrappedReceivedBusinessRuleValue.SOQLQuery==null) {

            return JSON.serialize(new Map<String,String>{'error' => System.Label.Custom_Picklist_Bad_Business_Config_Bad_Message});
        }
        BusinessConfigWrapperToSend wrappedBusinessValueToSend = new BusinessConfigWrapperToSend();
        try {

            String configDataQuery = wrappedReceivedBusinessRuleValue.SOQLQuery;
            List<SObject> objectRecordList = Database.query(configDataQuery);
            String currentValueField =  wrappedReceivedBusinessRuleValue.fieldToUpdate;
            String queryForCurrentValue = 'SELECT '+currentValueField+' FROM '+ sObjectName + ' WHERE Id=\''+recordId+'\'';
            List<SObject> resultWithCurrentValue = Database.query(queryForCurrentValue);
            wrappedBusinessValueToSend.currentValue =  (String) resultWithCurrentValue[0].get(currentValueField);
            wrappedBusinessValueToSend.fieldToDisplay = wrappedReceivedBusinessRuleValue.fieldToDisplay;
            wrappedBusinessValueToSend.picklistData = new List<String>();
            for (SObject objectRecord : objectRecordList) {

                String recordValue = (String)objectRecord.get(wrappedBusinessValueToSend.fieldToDisplay);
                wrappedBusinessValueToSend.picklistData.add(recordValue);
            }
            wrappedBusinessValueToSend.messageSeverity = wrappedReceivedBusinessRuleValue.messageSeverity;
            wrappedBusinessValueToSend.messageBodyCustomLabel = wrappedReceivedBusinessRuleValue.messageBodyCustomLabel;
            wrappedBusinessValueToSend.messageTitleCustomLabel = wrappedReceivedBusinessRuleValue.messageTitleCustomLabel;
            wrappedBusinessValueToSend.isMessageDisplayed = wrappedReceivedBusinessRuleValue.isMessageDisplayed;
            wrappedBusinessValueToSend.isNoneOptionDisplayed = wrappedReceivedBusinessRuleValue.isNoneOptionDisplayed;
            wrappedBusinessValueToSend.isPleaseSelectOptionDisplayed = wrappedReceivedBusinessRuleValue.isPleaseSelectOptionDisplayed;
            wrappedBusinessValueToSend.picklistCustomLabel = wrappedReceivedBusinessRuleValue.picklistCustomLabel;
            wrappedBusinessValueToSend.fieldToUpdate = wrappedReceivedBusinessRuleValue.fieldToUpdate;
            return JSON.serialize(wrappedBusinessValueToSend);
        } catch (Exception ex) {

            system.debug('Exception data: '+ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getMessage()+'\n'+ex.getStackTraceString());
            return JSON.serialize(new Map<String,String>{'error' => System.Label.Custom_Picklist_Bad_Business_Config_Bad_Message});
        }
    }
    
    /**
    * @description updates field (defined by parameter fieldToUpdate) value (defined by parameter picklistValue) on object (defined by parameter sObjectName) record (defined by parameter recordId)
    *
    * @param picklistValue - value for field update
    * @param fieldToUpdate - API-name of field to update
    * @param recordId - id of record to update
    * @param sObjectName - API-name of bject which record should be updated
    * @return String - returns serialized BusinessConfigWrapperToSend class
    */
    @AuraEnabled
    public static String saveSelectedValue(String picklistValue, String fieldToUpdate, String recordId, String sObjectName){

        sObject recordToUpdate = Schema.getGlobalDescribe().get(sObjectName).newSObject(recordId);
        recordToUpdate.put(fieldToUpdate, picklistValue);
        try {

            update recordToUpdate;
        } catch (DMLException e) {

            System.debug('The following exception has occurred: ' + e.getMessage());
            return e.getMessage();
        }
        return 'OK';   
    }
}