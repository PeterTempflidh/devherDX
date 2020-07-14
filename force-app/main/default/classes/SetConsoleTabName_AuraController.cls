public with sharing class SetConsoleTabName_AuraController {
    @AuraEnabled
    public static String getChatDetails(String recId){
        Case c=null;
        List<LiveChatTranscript> chats=new List<LiveChatTranscript>();
        chats=LiveChatTranscriptSelector.getChatCaseFieldsByChatTranscriptsId(recId);
        if(chats.size()>0){
            if(chats[0].caseId!=null){
                c=CaseSelector.getCaseDetailsById(chats[0].caseId);
                if(c!=null){
                    if(c.Country__c!=null){
                        Country__c country=CountrySelector.getCountryByName(c.Country__c);
                        return country.Iso__c+'&&'+c.Case_Reason_Level_3__c;
                    }
                    else{
                        return null;
                    }
                }
                else{
                    return null;
                }
            }
            else{
                if(chats[0].Country__c!=null){
                    Country__c country=CountrySelector.getCountryByName(chats[0].Country__c);
                    return country.Iso__c+'&&'+chats[0].Case_Reason_Level_3__c;
                }
                else{
                    return null;
                }
            }
        }
        else{
            return null;
        }
    }
}