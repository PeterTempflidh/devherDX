@IsTest
public class AutoCloseTab_AuraControllerTest {

    @TestSetup
    static void testsetup(){
        UnitTestDataFactory.getRecordtypeValues();

        Country__c bh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        insert bh;

        List<Business_Config__c> configs = new List<Business_Config__c>();

        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Talabat_Inbound_Case').getRecordTypeId();

        configs.add(
                new Business_Config__c(
                        Process_Name__c = 'ChatToCase',
                        Business_Rule_Name__c = 'Platform',
                        Business_Rule_Value__c = 'Talabat',
                        Id_Country__c = bh.id,
                        Is_Active__c = true,
                        Record_Type_Id__c = 'Talabat',
                        Type__c = 'Process',
                        Parent__c = true
                ));
        String businessRuleValue =  '[  {    "CaseField": "RecordTypeId",    "Value": "' + recordTypeId + '"  }, { "CaseField": "Origin",   "Value": "Chat"  }, { "ChatField": "Country__c",   "CaseField": "Country__c"  }, { "ChatField": "OwnerId",   "CaseField": "OwnerId"  },  {    "ChatField": "Platform__c",    "CaseField": "Platform__c"  },  {    "ChatField": "Order_Number__c",    "CaseField": "Order_Number__c"  },';
        businessRuleValue += '{    "ChatField": "My_Problem__c",    "CaseField": "Description"  },  {    "ChatField": "My_Problem__c",    "CaseField": "Subject"  },';
        businessRuleValue += '{    "ChatField": "Case_Reason_Level_1__c",    "CaseField": "Case_Reason_Level_1__c"  }, {    "ChatField": "Case_Reason_Level_2__c",    "CaseField": "Case_Reason_Level_2__c"  }, {    "ChatField": "Case_Reason_Level_3__c",    "CaseField": "Case_Reason_Level_3__c"  }, {    "ChatField": "Type__c",    "CaseField": "Type"  }]';
        configs.add(
                new Business_Config__c(
                        Process_Name__c = 'ChatToCase',
                        Business_Rule_Name__c = 'FieldsMap',
                        Business_Rule_Value__c = businessRuleValue,
                        Id_Country__c = bh.id,
                        Is_Active__c = true,
                        Record_Type_Id__c = 'Talabat',
                        Type__c = 'Process',
                        Parent__c = true
                )
        );
        configs.add(
                new Business_Config__c(
                        Process_Name__c = 'PostChatSurvey',
                        Business_Rule_Name__c = 'Endpoint',
                        Business_Rule_Value__c = 'dummy',
                        Id_Country__c = bh.id,
                        Is_Active__c = true,
                        Record_Type_Id__c = 'Global_Config',
                        Type__c = 'Process',
                        Parent__c = true
                )
        );
        configs.add(
                new Business_Config__c(
                        Process_Name__c = 'PostChatSurvey',
                        Business_Rule_Name__c = 'SurveyURLMapping',
                        Business_Rule_Value__c = '{"case_number":"case&&casenumber","type":"case&&type","origin":"case&&origin","order_id":"case&&order_number__c"}',
                        Id_Country__c = bh.id,
                        Is_Active__c = true,
                        Record_Type_Id__c = 'Global_Config',
                        Type__c = 'Process',
                        Parent__c = false
                )
        );
        configs.add(
                new Business_Config__c(
                        Process_Name__c = 'PostChatSurvey',
                        Business_Rule_Name__c = 'Body',
                        Business_Rule_Value__c = '{"app_group_id":"<app_group_id>","external_user_ids":["<email__c>"],"campaign_id":"<campaign_id>","messages":{"<platform_push>":{"alert":"Tell us about your last customer care experience!","title":"Experience","custom_uri":"<surveyURL>","message_variation_id":"<message_variation_id>"}}}',
                        Id_Country__c = bh.id,
                        Is_Active__c = true,
                        Record_Type_Id__c = 'Global_Config',
                        Type__c = 'Process',
                        Parent__c = false
                )
        );
        configs.add(
                new Business_Config__c(
                        Process_Name__c = 'PostChatSurvey',
                        Business_Rule_Name__c = 'Talabat_STG',
                        Business_Rule_Value__c = '{"app_group_id":"1234","campaign_id":"1234","platform_push":"Android=dummy,iOS=dummy","message_variation_id":"Android=dummy2,iOS=dummy2","surveyURL":"testurl"}',
                        Id_Country__c = bh.id,
                        Is_Active__c = true,
                        Record_Type_Id__c = 'Global_Config',
                        Type__c = 'Process',
                        Parent__c = false
                )
        );
        configs.add(
                new Business_Config__c(
                        Process_Name__c = 'PostChatSurvey',
                        Business_Rule_Name__c = 'Talabat',
                        Business_Rule_Value__c = '{"app_group_id":"1234","campaign_id":"1234","platform_push":"Android=dummy,iOS=dummy","message_variation_id":"Android=dummy2,iOS=dummy2","surveyURL":"testurl"}',
                        Id_Country__c = bh.id,
                        Is_Active__c = true,
                        Record_Type_Id__c = 'Global_Config',
                        Type__c = 'Process',
                        Parent__c = false
                )
        );
        configs.add(
                new Business_Config__c(
                    Business_Rule_Name__c='platformEntityMapping ',
                    Business_Rule_Value__c='{"Talabat_Bahrain":"TB_BH"}',
                    Id_Country__c=bh.id,
                    Is_Active__c=true,
                    Parent__c=true,
                    Process_Name__c='ChatBotConfigs',
                    Record_Type_Id__c='Global_Config',
                    Type__c='Process'
            )
        );

        insert configs;
        LiveChatVisitor visitor=new LiveChatVisitor();
        insert visitor;

        LiveChatTranscript chat = new LiveChatTranscript(
                Platform__c = 'Talabat',
                Order_Number__c = '1234567890001',
                Email__c = 'test@deliveryhero.com',
                User_Name__c = 'test name',
                My_Problem__c = 'Kunde - Anderes Problem',
                Body='Hello',
                LiveChatVisitorId = visitor.id,
                Country__c = 'Bahrain',
                Platform='Android',
                ownerId = userinfo.getUserId()
        );

        insert chat;

        chat.OwnerId = userinfo.getUserId();
        update chat;
    }

    @IsTest
    static void testFetchCaseFromChat() {
        LiveChatTranscript chat=[SELECT Id FROM LiveChatTranscript limit 1];
        String status=AutoCloseTab_AuraController.isCaseClosed(chat.id);
        system.assertNotEquals(null,status);
    }
    @IsTest
    static void testFetchCase() {
        Case caseRec=[SELECT Id FROM Case limit 1];
        String status=AutoCloseTab_AuraController.isCaseClosed(caseRec.id);
        system.assertNotEquals(null,status);
    }

    @IsTest
    static void testSendSurvey(){
        insert new Logging__c(SetupOwnerId=UserInfo.getOrganizationId());
        LiveChatTranscript chat=[SELECT Id FROM LiveChatTranscript limit 1];
        Test.setMock(HttpCalloutMock.class, new MockCaseReason3ValueResponseGenerator(false,''));
        Test.startTest();
        String status=AutoCloseTab_AuraController.sendSurvey(chat.id);
        Test.stopTest();
        List<Log_Error_Message__c> logErrorMessage = [SELECT Id FROM Log_Error_Message__c];
        system.assertEquals('Success',status);
        system.assertNotEquals(0,logErrorMessage.size());
    }
}