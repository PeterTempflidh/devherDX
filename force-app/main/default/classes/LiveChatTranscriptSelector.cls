public inherited sharing class LiveChatTranscriptSelector {

    public static List<LiveChatTranscript> getChatCaseFieldsByChatTranscriptsId(Id chatTranscriptId) {
        return [SELECT Id, Case_Reason_Level_3__c,Case.Customer_ID__c,Customer_ID__c,Country__c,Platform__c,Order_Number__c,CaseId, Case.Order_Number__c, Case.Platform__c, Case.Country__c,Case.Partial_Refund_Type__c,Case.RecordType.DeveloperName,Case.Customer_Name__c, Case.Case_Reason_Level_3__c,
                Platform, Email__c, Type__c, Case.CaseNumber, Case.Origin, Case.Type
                FROM LiveChatTranscript 
                WHERE Id =: chatTranscriptId];
    }

    /* -- Commenting unused code to be deleted later (Monitoring for issues)
    public static List<LiveChatTranscript> getChatsByIds(Set<Id> chatIds) {
        return [SELECT Id, CaseId, Case.Order_Number__c, Case.Platform__c 
                FROM LiveChatTranscript 
                WHERE Id IN :chatIds];
    }
    */
}
