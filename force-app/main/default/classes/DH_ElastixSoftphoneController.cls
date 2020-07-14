public with sharing class DH_ElastixSoftphoneController {
    public static String recordId{get;set;}
    public static String username{get;set;}
    public static String password{get;set;}

    public static String getRecordId(String phoneNumber,String callDateTime) {
        Map<Id,User> userMap=UserSelector.getUsersWithDynamicCondition('Id,Elastix_Agent_Id__c','Id=\''+UserInfo.getUserId()+'\'');
        if(userMap==null || userMap.keySet().size()==0 || userMap.values()[0].Elastix_Agent_Id__c==null){
            return 'Agent not found';
        }
        //Setting datetime to capture the incoming call time.
        List<String> callDateTimeParams = callDateTime.split(',');
        dateTime callDateGMT = DateTime.newInstance(Integer.valueOf(callDateTimeParams[0]),Integer.valueOf(callDateTimeParams[1]),Integer.valueOf(callDateTimeParams[2]),Integer.valueOf(callDateTimeParams[3]),Integer.valueOf(callDateTimeParams[4]),Integer.valueOf(callDateTimeParams[5]));

        //Formatting the date as required by Salesforce to compare with createdDate. Adding timezone as GMT since the time coming from Javascript call is already in local time.
        String callDateTZ = callDateGMT.format('yyyy-MM-dd HH:mm:ss','GMT').replace(' ','T')+'Z';

        String whereClause='Elastix_Agent_Extension__c = \''+userMap.values()[0].Elastix_Agent_Id__c+'\' AND Vendor_Phone_Number__c = \''+phoneNumber+'\' AND Status=\'In Progress\' AND CreatedDate >='+callDateTZ+' ORDER BY caseNumber DESC LIMIT 1';
        String fields='Id';
        Map<Id,Case> elastixInboundCase = CaseSelector.getCaseWithDynamicCondition(whereClause,fields);
        if(elastixInboundCase==null){
            return 'Agent not found';
        }
        return new List<Id>(elastixInboundCase.keySet())[0];
    }
    public static void getUserDetails(){
        Map<Id,User> userMap=UserSelector.getUsersWithDynamicCondition('Id,Elastix_Agent_Id__c,Elastix_Password__c','Id=\''+UserInfo.getUserId()+'\'');
        if(userMap==null){
            return;
        }
        String elastixUsernamePasswordString = '';
        User elsetixUser = userMap.values()[0];
        if(elsetixUser.Elastix_Agent_Id__c!=null && elsetixUser.Elastix_Password__c!=null){
            username=elsetixUser.Elastix_Agent_Id__c;
            password=elsetixUser.Elastix_Password__c;
            elastixUsernamePasswordString = 'Username:'+elsetixUser.Elastix_Agent_Id__c+',Password:'+elsetixUser.Elastix_Password__c;
        }
    }
   
    public static string createRecord(String phoneNumber,String recordId){
        task taskRec = new task();
        if(recordId.startsWith('570')){
            List<LiveChatTranscript> chat=LiveChatTranscriptSelector.getChatCaseFieldsByChatTranscriptsId(recordId);
            if(chat!=null && chat.size()>0){
                recordId = chat[0].CaseId;
            }
        }
        taskRec.WhatId = recordId;

        //Setting default values for fields on task to set task type as a 'Call log' to ensure correct feed item on case is created
        taskRec.ActivityDate = system.today();
        taskRec.Status = 'Completed';
        taskRec.Type = 'Call';
        taskRec.TaskSubtype = 'Call';
        taskRec.CallType = 'Outbound';
        taskRec.CallObject = 'Call';
        taskRec.Subject = 'Outbound call to '+phoneNumber;
        taskRec.Description = 'Outbound call to '+phoneNumber;
        insert taskRec;
        return taskRec.Id;
    }

    public static string getPhoneNumberWithPrefix(String phoneNumber,String recordId){
        Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('ElastixQueuePrefixes');
        if(mapBusinessLogic==null){
            return phoneNumber;
        }
        Map<String, Business_Config__c> countryPrefixMap = mapBusinessLogic.get('Global_Config');
        if(recordId.startsWith('570')){
            List<LiveChatTranscript> chat=LiveChatTranscriptSelector.getChatCaseFieldsByChatTranscriptsId(recordId);
            if(chat!=null && chat.size()>0){
                recordId = chat[0].CaseId;
            }
        }
        Case caseRecord = CaseSelector.getCaseDetailsById(recordId);
        if(caseRecord==null){
            return phoneNumber;
        }
        String caseCountry = caseRecord.Country__c;
        Map<String,String> countryCodePrefixMap = (Map<String, String>) JSON.deserialize(countryPrefixMap.get(caseCountry).Business_Rule_Value__c, Map<String, String>.class);
        if(countryCodePrefixMap==null){
            return phoneNumber;
        }
        String countryCode = countryCodePrefixMap.get('Country Code');
        String prefix = countryCodePrefixMap.get('Prefix');
        if(phoneNumber.startsWith(countryCode)){
            phoneNumber = phoneNumber.replaceFirst('\\'+countryCode,prefix);
        }
        else if(phoneNumber.startsWith(countryCode.replace('+','00'))){
            phoneNumber = phoneNumber.replaceFirst(countryCode.replace('+','00'),prefix);
        }
        else{
            phoneNumber = prefix+phoneNumber;
        }
        return phoneNumber;
    }
}