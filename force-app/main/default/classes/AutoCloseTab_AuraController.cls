public class AutoCloseTab_AuraController {
    @AuraEnabled
    public static String isCaseClosed(Id recId){
        Case caseRec = new Case();
        String caseId='';
        try {
            if (string.valueOf(recId.getSobjectType()) == 'LiveChatTranscript') {
                List<LiveChatTranscript> chats = LiveChatTranscriptSelector.getChatCaseFieldsByChatTranscriptsId(recId);
                if (chats.size() > 0) {
                    caseId = chats[0].CaseId;
                }
            } else if (string.valueOf(recId.getSobjectType()) == 'Case') {
                caseId = recId;
            }
            if (caseId == '') {
                return null;
            }
            caseRec = CaseSelector.getCaseDetailsById(caseId);
            if (caseRec == null) {
                caseRec.Status = null;
            }
            return caseRec.Status;
        } catch(Exception e){
            system.debug('Logging error: '+e);
            return null;
        }
    }

    /* Name: sendSurvey
     * @description Method to set the callout parameters (endpoint and body) based on the platform & invoke the sendSurveyCallout method.
     * @return String (generic message to notify of the failure in sending survey)
     * Params recId: Record Id of the chat
     * Dependency: PostChatSurvey business config
     */
    @AuraEnabled
    public static String sendSurvey(String recId){
        //Initial null checks on business config.
        Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
        Map<String, Map<String, Business_Config__c>> mapPostChatBusinessLogic = moam.get('PostChatSurvey');
        Map<String, Map<String, Business_Config__c>> mapChatBotConfigBusinessLogic = moam.get('ChatBotConfigs');
        Boolean isBusinessConfigNull = mapChatBotConfigBusinessLogic==null || mapChatBotConfigBusinessLogic.isEmpty() || mapChatBotConfigBusinessLogic.get('Global_Config')==null ||
                mapPostChatBusinessLogic==null || mapPostChatBusinessLogic.isEmpty() || mapPostChatBusinessLogic.get('Global_Config')==null;
        if(isBusinessConfigNull){
            return 'No business config present';
        }
        Map<String, Business_Config__c> mapPostChatBusinessRules = mapPostChatBusinessLogic.get('Global_Config');
        Map<String, Business_Config__c> mapPlatformEntityBusinessRules = mapChatBotConfigBusinessLogic.get('Global_Config');
        List<LiveChatTranscript> currentRecord = LiveChatTranscriptSelector.getChatCaseFieldsByChatTranscriptsId(recId);
        if(currentRecord.isEmpty() || String.isBlank(currentRecord[0].Platform__c)){
            return 'No platform on chat';
        }

        //setting business config value to _STG if sandbox
        String keyForBusinessConfig='';
        if([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox){
            keyForBusinessConfig = currentRecord[0].Platform__c+Label.Staging_Suffix;
        }
        else{
            keyForBusinessConfig = currentRecord[0].Platform__c;
        }
        if(!mapPostChatBusinessRules.containsKey(keyForBusinessConfig)){
            return 'No business config present for the platform';
        }

        //Getting values from business config
        String endpoint=mapPostChatBusinessRules.get('Endpoint').Business_Rule_Value__c;
        String bodyStructure=mapPostChatBusinessRules.get('Body').Business_Rule_Value__c;
        Map<String,String> platformBusinessRuleRec = (Map<String,String>) JSON.deserialize(mapPostChatBusinessRules.get(keyForBusinessConfig).Business_Rule_Value__c, Map<String,String>.class);
        Map<String,String> entityMap	= (Map<String,String>)JSON.deserialize(mapPlatformEntityBusinessRules.get('platformEntityMapping').Business_Rule_Value__c,Map<String, String>.class);
        boolean isPlatformEntityRecordByCasePresent = currentRecord[0].CaseId!=null && entityMap.containsKey(currentRecord[0].Case.Platform__c+'_'+currentRecord[0].Case.Country__c);
        if(!isPlatformEntityRecordByCasePresent) {
            return 'No platform entity mapping found';
        }
        String platformEntityValue = entityMap.get(currentRecord[0].Case.Platform__c+'_'+currentRecord[0].Case.Country__c);
        //Setting values for custom URL and Request Body based on business config
        String customSurveyURI = setSurveyURL(platformBusinessRuleRec.get('surveyURL'),currentRecord[0],platformEntityValue,mapPostChatBusinessRules.get('SurveyURLMapping').Business_Rule_Value__c);
        if(customSurveyURI=='') {
            return 'Failed to create survey url';
        }
        String requestBody = setRequestBody(bodyStructure, platformBusinessRuleRec, customSurveyURI, currentRecord[0]);

        //make callout to send survey
        sendSurveyCallout(endpoint, requestBody, currentRecord[0].Id);
        return 'Success';
    }

    /* Name: setSurveyURL
     * @description Method to set the survey url to be sent to the customer.
     * @return String (formulated survey url)
     * Params surveyURL: surveylink, chatRec: chat transcript rercord, platformEntityValue: global entity id based on platform and country, surveyURLMapping: url parameters
     */
    public static String setSurveyURL(String surveyURL, LiveChatTranscript chatRec, String platformEntityValue, String surveyURLMapping){
        Map<String,String> surveyURLMap = (Map<String,String>)JSON.deserialize(surveyURLMapping,Map<String, String>.class);
        String urlParams='';
        for(String param:surveyURLMap.keySet()){
            List<String> field=surveyURLMap.get(param).split('&&');
            String fieldValue= (string)chatRec.getSObject(field[0]).get(field[1]);
            if(fieldValue == null){
                continue;
            }
            urlParams=urlParams+'&'+param+'='+fieldValue.toLowerCase();
        }
        if(urlParams=='') {
            return '';
        }
        surveyURL = surveyURL + '?survey_origin=braze&global_entity_id=' + platformEntityValue.toLowerCase() + urlParams;
        return surveyURL;
    }

    /* Name: setRequestBody
     * @description Method to set the request body to be sent to braze system.
     * @return String (formulated request body)
     * Params bodyStructure: json request body, paramMapping: key value map for body parameters, surveyURL: url of the survey to be sent to the customer, chatRec: live chat transcript record
     */
    public static String setRequestBody(String bodyStructure, Map<String,String> paramMapping, String surveyURL, LiveChatTranscript chatRec){
        String body='';
        body=bodyStructure.replace('<email__c>',chatRec.Email__c);
        //Updating keys/params in body based on platform
        boolean valueSet=true;
        for(String paramKey:paramMapping.keySet()){
            String value='';
            if(paramKey=='surveyURL'){
                body=body.replace('<surveyURL>',surveyURL);
                continue;
            }
            boolean isComplexCondition = paramMapping.get(paramKey).containsIgnoreCase('Android=') || paramMapping.get(paramKey).containsIgnoreCase('iOS=');
            if(isComplexCondition){
                List<String>  platformSpecificValues = paramMapping.get(paramKey).split(',');
                for(String platformValue: platformSpecificValues){
                    if(platformValue.split('=')[0]==chatRec.Platform){
                        value=platformValue.split('=')[1];
                    }
                }
            }
            else{
                value=paramMapping.get(paramKey);
            }
            if(value=='') {
                valueSet=false;
                break;
            }
            body=body.replace('<' + paramKey + '>', value);
        }

        if(valueSet==false){
            return 'Request body could not be formulated as all the parameters are not defined';
        }
        return body;
    }

    /* Name: sendSurveyCallout
     * Type: Future: callouts=true.
     * @description Method to make a REST call.
     * @return Type: void
     * Params endpoint: URL of the target environment, body: JSON body to send as part of the request, recordId: Record Id of the chat
     */
    @Future(Callout=true)
    public static void sendSurveyCallout(String endpoint,String body,String recordId){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(body);
        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() != 201 && response.getStatusCode() != 200) {
                LoggingUtility.createLog('PostChatSurveys', 'PostChatSurveys', '', '');
                LoggingUtility.logError('PostChatSurveys', 'PostChatSurveyFailure: Unable to send survey after chat completion ' + recordId + ' Errors ' + response.getStatusCode() + '\n' + response.getStatus());
                LoggingUtility.commitLogs();
            }
        }catch(Exception e){
            LoggingUtility.createLog('PostChatSurveys', 'PostChatSurveys', '', '');
            LoggingUtility.logError('PostChatSurveys', 'PostChatSurveyFailure: Unable to send survey after chat completion ' + recordId + ' Errors ' + e.getMessage());
            LoggingUtility.commitLogs();
        }
    }
}