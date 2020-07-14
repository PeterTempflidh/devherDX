public class UniversalSendEmailButton_AuraController {

    @AuraEnabled
    public static String getDestination(String recordId){
        

        Id convertedRecordId = Id.valueOf(recordId);
        String objectAPIname = convertedRecordId.getSObjectType().getDescribe().getName();
        String query = 'SELECT RecordTypeId FROM '+ objectAPIname + ' WHERE Id=\''+recordId+'\'';
        List<SObject> result = Database.query(query);
        if (result.size()==0) {

            return null;
        } else {
            
            String recordTypeId = (String) result[0].get('RecordTypeId');
            String recordTypeName = convertedRecordId.getSObjectType().getDescribe().getRecordTypeInfosById().get(recordTypeId).getDeveloperName();
            String searchParameter = objectAPIname+'::'+recordTypeName;
            Map<String, Map<String, Business_Config__c>> buisnessRuleMap =  LibBusinessConfig.motherOfAllBusinessMaps.get('UniversalSendSmsButtonProperties');
            if (buisnessRuleMap!= null) {

                Map<String, Business_Config__c> recordTypeBusinessRuleMap = buisnessRuleMap.get('Global_Config');
                if (recordTypeBusinessRuleMap !=null) {

                    Business_Config__c buisnessRule = recordTypeBusinessRuleMap.get(searchParameter);
                    if (buisnessRule!=null) {

                        return String.valueOf(buisnessRule.get('Business_Rule_Value__c'));
                    }
                }
            }
            return  null;
        }
    }
}