global class EmailActionOverride implements  QuickAction.QuickActionDefaultsHandler {
    global EmailActionOverride() {}

    // The main interface method
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = (QuickAction.SendEmailQuickActionDefaults)defaults.get(0);
        Case reqCase = CaseSelector.getCaseWithDynamicFields('EmailTemplatePrepopulateCriteriaFields',string.valueOf(sendEmailDefaults.getContextId()));
        if(reqCase!=null) {
            //Get the business config record for CaseEmailPrepoulateConfigs for the correct platform
            Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
            Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('CaseEmailPrepoulateConfigs');
            Map<String, Business_Config__c> mapBusinessRules=new map<String, Business_Config__c>();
            if(mapBusinessLogic!=null) {
                mapBusinessRules = mapBusinessLogic.get(reqCase.Platform__c);
                if(mapBusinessRules!=null) {
                    Map<String,String> paramValueMap=new map<String,String>();
                    if(mapBusinessRules.containsKey('Parameters')){
                        List<String> params=mapBusinessRules.get('Parameters').Business_Rule_Value__c.split(',');
                        for(String param:params){
                            String businessConfigValue=fetchKeyValue(reqCase, mapBusinessRules, param);
                            if(businessConfigValue.contains('&&')){
                                String paramValue=businessConfigValue.split('&&')[0];
                                String emailField=businessConfigValue.split('&&')[1];
                                paramValueMap.put(emailField,paramValue);
                            }
                        }
                    }
                    if(paramValueMap!=null && paramValueMap.containsKey('Template')){
                        EmailTemplate temp=EmailTemplateSelector.getTemplateByName(paramValueMap.get('Template'));
                        if(temp!=null) {
                            sendEmailDefaults.setTemplateId(temp.id);
                            sendEmailDefaults.setInsertTemplateBody(true);
                            sendEmailDefaults.setIgnoreTemplateSubject(false);
                        }
                    }
                    EmailMessage emailMessage = (EmailMessage) sendEmailDefaults.getTargetSObject();
                    for(String param:paramValueMap.keyset()){
                        if(param!='Template'){
                            if(param=='ToAddress'){
                                String toAddress='';
                                if(reqCase.Customer_Email__c!=null)
                                    toAddress = reqCase.Customer_Email__c+','+paramValueMap.get(param);
                                else
                                    toAddress = paramValueMap.get(param);
                                emailMessage.put(param,toAddress);
                            }
                            else
                                emailMessage.put(param,paramValueMap.get(param));
                        }
                    }
                }
            }
        }
    }

    private Map<String, Map<String,String>> createBusinessRuleMaps(Map<String, Business_Config__c> mapBusinessRules, String keyValue){
        return (Map<String, Map<String,String>>) JSON.deserialize(mapBusinessRules.get(keyValue).Business_Rule_Value__c, Map<String, Map<String,String>>.class);
    }

    private String fetchKeyValue(Case reqCase,Map<String, Business_Config__c> mapBusinessRules, String keyValue){
        Map<String, Map<String,String>> criteriaValues=createBusinessRuleMaps(mapBusinessRules,keyValue);
        String returnValue='';
        for(String i:criteriaValues.keySet()){
            Boolean flag=true;
            if(criteriaValues.get(i).get('Criteria')!=null){
                List<String> criteriaStrings=new List<String>();
                if(criteriaValues.get(i).get('Criteria').contains('&&'))
                    criteriaStrings=criteriaValues.get(i).get('Criteria').split('&&');
                else{
                    criteriaStrings.add(criteriaValues.get(i).get('Criteria'));
                }
                for(Integer j=0;j<criteriaStrings.size();j++){
                    if(reqCase.get(criteriaStrings[j])!=criteriaValues.get(i).get(criteriaStrings[j])) {
                        flag = false;
                        break;
                    }
                }
                if(flag){
                    //For Params other than template
                    if(criteriaValues.get(i).containsKey('TargetField'))
                        returnValue=criteriaValues.get(i).get(keyValue)+'&&'+criteriaValues.get(i).get('TargetField');
                }
            }
        }
        return returnValue;
    }
    

}