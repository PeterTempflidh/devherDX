@isTest
private class SetConsoleTabName_AuraControllerTest {
    @testSetup
    static void setupData(){
        UnitTestDataFactory.getRecordtypeValues();
        Country__c c = UnitTestDataFactory.createCountry('UY','Uruguay', 'UYU');
        insert c;
        List<Account> accList = UnitTestDataFactory.createAccounts(1,c,'PY_Account');
        accList[0].backend_id__c = '12345';
        insert accList;
        Account acc = accList[0];
        Case chatCase = new Case();
        chatCase = UnitTestDataFactory.createCase(acc,'New','Customer','','Chat',c,'PY_Inbound_Case','My Problem');
        chatCase.Case_Reason_Level_1__c = 'Across Journey';
        chatCase.Case_Reason_Level_2__c = 'Feedback';
        chatCase.Case_Reason_Level_3__c = 'Negative';
        insert chatCase;

        LiveChatVisitor visitor=new LiveChatVisitor();
        insert visitor;

        LiveChatTranscript chat = new LiveChatTranscript(
                Platform__c = 'PedidosYa',
                Order_Number__c = '1234567890001',
                Email__c = 'test@deliveryhero.com',
                User_Name__c = 'test name',
                My_Problem__c = 'Kunde - Anderes Problem',
                Body='Hello',
                LiveChatVisitorId=visitor.id,
                ownerId=userinfo.getUserId(),
                Country__c = 'Uruguay'
        );

        insert new List<LiveChatTranscript>{chat};

        List<Business_Config__c> configs = new List<Business_Config__c>();

        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PY_Inbound_Case').getRecordTypeId();

        configs.add(
                new Business_Config__c(
                        Process_Name__c = 'ChatToCase',
                        Business_Rule_Name__c = 'Platform',
                        Business_Rule_Value__c = 'PedidosYa',
                        Id_Country__c = c.id,
                        Is_Active__c = true,
                        Record_Type_Id__c = 'PedidosYa',
                        Type__c = 'Process',
                        Parent__c = true
                ));
        String businessRuleValue = '[  {    "CaseField": "RecordTypeId",    "Value": "' + recordTypeId + '"  },   {    "ChatField": "Platform__c",    "CaseField": "Platform__c"  },  {    "ChatField": "Country__c",    "CaseField": "Country__c"  }, {    "ChatField": "Order_Number__c",    "CaseField": "Order_Number__c"  },';
        businessRuleValue +=' {    "ChatField": "My_Problem__c",    "CaseField": "Description"  },  {    "ChatField": "My_Problem__c",    "CaseField": "Subject"  },';
        businessRuleValue +=' {    "ChatField": "Case_Reason_Level_1__c",    "CaseField": "Case_Reason_Level_1__c"  }, {    "ChatField": "Case_Reason_Level_2__c",    "CaseField": "Case_Reason_Level_2__c"  }, {    "ChatField": "Case_Reason_Level_3__c",    "CaseField": "Case_Reason_Level_3__c"  }, {    "ChatField": "Type__c",    "CaseField": "Type"  }]';
        configs.add(
                new Business_Config__c(
                        Process_Name__c = 'ChatToCase',
                        Business_Rule_Name__c = 'FieldsMap',
                        Business_Rule_Value__c = businessRuleValue,
                        Id_Country__c = c.id,
                        Is_Active__c = true,
                        Record_Type_Id__c = 'PedidosYa',
                        Type__c = 'Process',
                        Parent__c = true
                )
        );

        insert configs;
    }
    @IsTest
    static void testGetChatDetailsForChatWithCase() {
        LiveChatTranscript c1=[SELECT Id FROM LiveChatTranscript Limit 1];
        String tabName=SetConsoleTabName_AuraController.getChatDetails(c1.Id);
        system.assertNotEquals(null,tabName);
    }
    @IsTest
    static void testGetChatDetailsForChatWithoutCase() {
        LiveChatTranscript c1=[SELECT Id,caseId FROM LiveChatTranscript Limit 1];
        c1.caseId=null;
        update c1;
        String tabName=SetConsoleTabName_AuraController.getChatDetails(c1.Id);
        system.assertNotEquals(null,tabName);
    }
}