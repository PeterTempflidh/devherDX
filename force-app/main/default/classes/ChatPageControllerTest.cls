@isTest
private class ChatPageControllerTest {
    @testsetup
    static void testSetup(){
        UnitTestDataFactory.getRecordtypeValues();
        Id userId = UserInfo.getUserId();
        Test.startTest();
        Country__c c = UnitTestDataFactory.createCountry('TW','Taiwan', 'EUR');
        Country__c c2 = UnitTestDataFactory.createCountry('SG','Singapore', 'SGD');

        insert new List<Country__c>{c,c2};

        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;

        UnitTestDataFactory.getRecordtypeValues();

        Case cs = new Case(subject='Test',Description='Test',Type='Customer',Origin='Chat',Platform__c='Foodpanda',OwnerId=userInfo.getUserId(),RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('FP_Inbound_Case').getRecordTypeId(),Customer_ID__c = '1234',Order_Number__c='1234-0014',Country__c= 'Singapore');
        insert cs;

        LiveChatTranscript chat = UnitTestDataFactory.createChat('Taiwan','Foodpanda',visitor.Id,'12-0014',userId);
        chat.Customer_ID__c = '4576';


        LiveChatTranscript chat2 = UnitTestDataFactory.createChat('Singapore','Foodpanda',visitor.Id,'1234-0014',userId);
        chat2.Customer_ID__c = '1234';
        chat2.CaseId=cs.Id;



        insert new List<LiveChatTranscript>{chat,chat2};

        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='platformEntityMapping ',Business_Rule_Value__c='{"Foodpanda_Taiwan":"FP_TW","Foodpanda_Singapore":"FP_SG","PizzaDE":"PD_DE"}',Id_Country__c=c.id,Is_Active__c=true,Parent__c=true,Process_Name__c='ChatBotConfigs',Record_Type_Id__c='Global_Config',Type__c='Process');
        insert b1;
    }

    @isTest
    static void testOneViewUrl(){

        List<LiveChatTranscript> chat = [Select Id,Case.Platform__c,Case.Country__c from LiveChatTranscript where Platform__c='Foodpanda' AND Country__c='Singapore' Limit 1];
        Case caseRecord = [Select Id,Order_Number__c,Platform__c,Customer_ID__C from Case];
        String baseUrl = 'https://gccov-frontend.deliveryhero.io';
        String expected =  'https://gccov-frontend.deliveryhero.io?userId=1234&orderId=1234-0014&globalEntityId=FP_SG';
        Test.startTest();
        String url = ChatPageController.getOneViewUrl(chat[0].Id,baseUrl);
        Test.stopTest();
        system.assertEquals(expected, url);
    }
    @isTest
    static void testOneViewUrlNegative(){

        List<LiveChatTranscript> chat = [Select Id,Case.Platform__c,Case.Country__c from LiveChatTranscript where Platform__c='Foodpanda' AND Country__c='Taiwan' Limit 1];
        String baseUrl = 'https://gccov-frontend.deliveryhero.io';
        String expectedUrl = 'https://gccov-frontend.deliveryhero.io?userId=1234&orderId=1234-0014&globalEntityId=FP_SG';
        Test.startTest();
        String url = ChatPageController.getOneViewUrl(chat[0].Id,baseUrl);
        Test.stopTest();
        system.assertEquals(baseUrl, url);
    }
}