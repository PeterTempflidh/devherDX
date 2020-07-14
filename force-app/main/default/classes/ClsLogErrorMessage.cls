public without sharing class ClsLogErrorMessage {

public static void attachErrorMessage(String typeOfError, String errorMessage){
    if(String.isNotEmpty(errorMessage)){
    Log_Error_Message__c logJobMsg = new Log_Error_Message__c(Type__c = typeOfError);
    try{
    insert logJobMsg;
    Blob attachmentContent = Blob.valueOf(errorMessage);
    Attachment attachFile = new Attachment();
    attachFile.Body = attachmentContent;
    attachFile.name = logJobMsg.Type__c;
    attachFile.ParentId = logJobMsg.id;
    insert attachFile;
    }catch(Exception e){
    System.debug('error message'+ e.getMessage());
    }
    }
}

public static void logMessages(String typeOfError, String errorMessage){
    if(String.isNotEmpty(errorMessage)){
        Log_Error_Message__c logJobMsg = new Log_Error_Message__c(Type__c = typeOfError,Dump__c=errorMessage);
        try{
           insert logJobMsg; 
        }catch(Exception e){
            System.debug('error message'+ e.getMessage());
        }
    }
}

}