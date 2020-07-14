/**
* @author: Nithin Pandhem
* @date 17.03.2020.
* @description:Apex Controller for a oneView Iframe lightning component.
*/
public class ChatPageController{
    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;

    /***
    * @description This apex method is called from Init handler 
    * SCC-141 : OneView Iframe on ChatPage
    * @return String
    */
    @auraEnabled
    public static string getOneViewUrl(String chatRecId,String iFrameUrl){
        String baseUrl =iFrameUrl;
        Map<String,Map<String, Business_Config__c>> mapBusinessLogic = moam.get('ChatBotConfigs');
        Map <String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get('Global_Config');
        Map<String, String> entityMap = (Map<String, String>) JSON.deserialize(mapBusinessRules.get('platformEntityMapping').Business_Rule_Value__c,Map<String, String>.class);
        if(entityMap.isEmpty()){
            return baseUrl;
        }
        String chatId = chatRecId;
        String platform;
        String country;
        string entity;
        string orderId;
        String customerid;
        String oneViewUrl;
        List<LiveChatTranscript>  chatList = LiveChatTranscriptSelector.getChatCaseFieldsByChatTranscriptsId(chatId);
        if(chatList.size()==0){
            return baseUrl;
        }
        try{
            String platformEntityValue = chatList[0].Case.Platform__c+'_'+chatList[0].Case.Country__c;
            if(!entityMap.containsKey(platformEntityValue)){
                return baseUrl;
            }else{
                entity = entityMap.get(platformEntityValue);
            }
            orderId = chatList[0].Case.Order_Number__c;
            customerid  = chatList[0].Case.Customer_ID__c;
            oneViewUrl = baseUrl+'?userId='+customerid+'&orderId='+orderId+'&globalEntityId='+entity;
            return oneViewUrl;
        }catch(Exception ex){
            LoggingUtility.logError(ChatPageController.class.getName(),'Error => ' + ex.getMessage() + '\nLine Number : ' + ex.getLineNumber());
            return  baseUrl;
        }
    }
}