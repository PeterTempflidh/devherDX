@isTest
private class LiveChatTranscriptProcessorTest {

    @TestSetup
    static void setupTestData(){
        Group q = new Group( Name = 'Inbound Queue', Type = 'Queue' );
        insert q;
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr)
        {
            Test.startTest();
            insert new queuesobject (queueid=q.id, sobjecttype='Case'); 
            Test.stopTest();
        }

        Country__c uy = UnitTestDataFactory.createCountry('UY', 'Uruguay', 'UYU');
        insert uy;

        List<Business_Config__c> configs = new List<Business_Config__c>();

        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PY_Inbound_Case').getRecordTypeId();

        configs.add(
            new Business_Config__c(
                Process_Name__c = 'ChatToCase',
                Business_Rule_Name__c = 'Platform',
                Business_Rule_Value__c = 'PedidosYa',
                Id_Country__c = uy.id,
                Is_Active__c = true,
                Record_Type_Id__c = 'PedidosYa',
                Type__c = 'Process',
                Parent__c = true
            ));
        String businessRuleValue = '[  {    "CaseField": "RecordTypeId",    "Value": "' + recordTypeId + '"  },  {    "CaseField": "OwnerId",    "Value": "' + q.Id + '"  },  {    "ChatField": "Platform__c",    "CaseField": "Platform__c"  },  {    "ChatField": "Order_Number__c",    "CaseField": "Order_Number__c"  },';
        businessRuleValue+='  {    "ChatField": "My_Problem__c",    "CaseField": "Description"  },  {    "ChatField": "My_Problem__c",    "CaseField": "Subject"  },';
        businessRuleValue+= '{    "ChatField": "Case_Reason_Level_1__c",    "CaseField": "Case_Reason_Level_1__c"  }, {    "ChatField": "Case_Reason_Level_2__c",    "CaseField": "Case_Reason_Level_2__c"  }, {    "ChatField": "Case_Reason_Level_3__c",    "CaseField": "Case_Reason_Level_3__c"  }, {    "ChatField": "Type__c",    "CaseField": "Type"  }]';
        configs.add(
            new Business_Config__c(
                Process_Name__c = 'ChatToCase',
                Business_Rule_Name__c = 'FieldsMap',
                Business_Rule_Value__c = businessRuleValue,
                Id_Country__c = uy.id,
                Is_Active__c = true,
                Record_Type_Id__c = 'PedidosYa',
                Type__c = 'Process',
                Parent__c = true
            )
        );

        insert configs;
    }

    @isTest
    static void testCreateCaseFromChat_CorrectContactReasons() {
        LiveChatTranscript chat = new LiveChatTranscript(
            Platform__c = 'PedidosYa',
            Order_Number__c = '1234567890001',
            Email__c = 'test@deliveryhero.com',
            User_Name__c = 'test name',
            My_Problem__c = 'Kunde - Anderes Problem',
            Type__c = 'Customer',
            Case_Reason_Level_3__c = 'Food quality',
            Case_Reason_Level_2__c = 'Food issue',
            Case_Reason_Level_1__c = 'Post-Delivery'
        );

        Case newCase;
        Test.startTest();
            newCase = LiveChatTranscriptProcessor.CreateCaseFromChat(chat);
        Test.stopTest();

        System.assertNotEquals(null, newCase, 'Case from chat was not created!');
    }

    @isTest
    static void testCreateCaseFromChat_InCorrectContactReasons() {
        LiveChatTranscript chat = new LiveChatTranscript(
                Platform__c = 'PedidosYa',
                Order_Number__c = '1234567890001',
                Email__c = 'test@deliveryhero.com',
                User_Name__c = 'test name',
                My_Problem__c = 'Kunde - Anderes Problem',
                Type__c = 'Customer',
                Case_Reason_Level_3__c = 'Food quality'
        );

        Case newCase;
        Test.startTest();
        newCase = LiveChatTranscriptProcessor.CreateCaseFromChat(chat);
        Test.stopTest();

        System.assertNotEquals(null, newCase, 'Case from chat was not created!');
    }

    @isTest
    static void testCreateCaseFromChat_negative() {
        LiveChatTranscript chat = new LiveChatTranscript(
            Platform__c = 'WrongPlatform',
            Order_Number__c = '1234567890001'
        );

        Case newCase;
        Test.startTest();
            newCase = LiveChatTranscriptProcessor.CreateCaseFromChat(chat);
        Test.stopTest();

        System.assertEquals(null, newCase, 'Case chould not have been created!');
    }

    // just to increase coverage
    @isTest
    static void testFieldMappingClass() {
        LiveChatTranscriptProcessor.FieldMapping mapping = new LiveChatTranscriptProcessor.FieldMapping();
        mapping.CaseField = 'Description';
        mapping.ChatField = 'Subject';
        mapping.Value = 'test val';
    }
    
    @isTest
    static void testUpdateCaseOwner() {
        Map<String,RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Case','Contact','Account'});
        
        insert new Trigger_Manager__c(Deactivate_LiveChatTranscript_Trigger__c = true, Deactivate_Case_Trigger__c = true);
        
        List<User> uList = new List<User>();
        uList.add(UnitTestDataFactory.createUser('PY Customer Care', 'user1asdggdsa@deliveryhero.com', 'test company', 'UY'));
        uList.add(UnitTestDataFactory.createUser('PY Customer Care', 'user2asdggadsgas@deliveryhero.com', 'test company', 'UY'));
        insert uList;
        Case testCase = new Case();
        testCase.OwnerId = uList[0].Id;
        testCase.RecordTypeId = (Id)mapRecordtypes.get('PY_Inbound_Case').Id;
        insert testCase;
        
        LiveChatTranscript chat = new LiveChatTranscript(
            Platform__c = 'PedidosYa',
            Order_Number__c = '1234567890001',
            Email__c = 'test@deliveryhero.com',
            User_Name__c = 'test name',
            My_Problem__c = 'Kunde - Anderes Problem',
            CaseId = testCase.Id,
            OwnerId = uList[1].Id,
            Type__c = 'Customer'
        );
        
        Case oldCase;
        Test.startTest();
            oldCase = LiveChatTranscriptProcessor.UpdateCaseOwner(chat, testCase);
        Test.stopTest();

        System.assertEquals(chat.OwnerId, oldCase.OwnerId, 'Case and chat owens should match');
    }
    
    @isTest
    static void testUpdateCaseOwner_Negative() {
        Map<String,RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Case','Contact','Account'});
        
        insert new Trigger_Manager__c(Deactivate_LiveChatTranscript_Trigger__c = true, Deactivate_Case_Trigger__c = true);
        
        List<User> uList = new List<User>();
        uList.add(UnitTestDataFactory.createUser('PY Customer Care', 'user1asdggdsa@deliveryhero.com', 'test company', 'UY'));
        uList.add(UnitTestDataFactory.createUser('PY Customer Care', 'user2asdggadsgas@deliveryhero.com', 'test company', 'UY'));
        insert uList;
        Case testCase = new Case();
        testCase.OwnerId = uList[0].Id;
        testCase.RecordTypeId = (Id)mapRecordtypes.get('PY_Inbound_Case').Id;
        insert testCase;
        
        LiveChatTranscript chat = new LiveChatTranscript(
            Platform__c = 'PedidosYa',
            Order_Number__c = '1234567890001',
            Email__c = 'test@deliveryhero.com',
            User_Name__c = 'test name',
            My_Problem__c = 'Kunde - Anderes Problem',
            CaseId = null
        );
        
        Case oldCase;
        Test.startTest();
            oldCase = LiveChatTranscriptProcessor.UpdateCaseOwner(chat, testCase);
        Test.stopTest();

        System.assertEquals(null, oldCase, 'Returned case should be null');
    }
}