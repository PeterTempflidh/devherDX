@isTest
private class LiveChatTranscriptTriggerHandlerTest {

    @TestSetup
    static void setupTestData(){
        UnitTestDataFactory.getRecordtypeValues();
        //List<sObject> ls = Test.loadData(Business_Config__c.sObjectType, 'BusinessConfigData');

        Group q = new Group( Name = 'Inbound Queue', Type = 'Queue' );
        insert q;

        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr)
        {
            Test.startTest();
            insert new queuesobject (queueid=q.id, sobjecttype='Case');
            Test.stopTest();
        }

        Country__c py = UnitTestDataFactory.createCountry('PY', 'Uruguay', 'EUR');
        insert py;

        List<Business_Config__c> configs = new List<Business_Config__c>();

        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PY_Inbound_Case').getRecordTypeId();

        configs.add(
            new Business_Config__c(
                Process_Name__c = 'ChatToCase',
                Business_Rule_Name__c = 'Platform',
                Business_Rule_Value__c = 'PedidosYa',
                Id_Country__c = py.id,
                Is_Active__c = true,
                Record_Type_Id__c = 'PedidosYa',
                Type__c = 'Process',
                Parent__c = true
            ));
        String businessRuleValue = '[  {    "CaseField": "RecordTypeId",    "Value": "' + recordTypeId + '"  },  {    "ChatField": "OwnerId",    "CaseField": "OwnerId"  },  {    "ChatField": "Platform__c",    "CaseField": "Platform__c"  },  {    "ChatField": "Order_Number__c",    "CaseField": "Order_Number__c"  },';
        businessRuleValue+='  {    "ChatField": "My_Problem__c",    "CaseField": "Description"  },{    "ChatField": "My_Problem__c",    "CaseField": "Subject"  },';
        businessRuleValue+= ' {    "ChatField": "Country__c",    "CaseField": "Country__c"  }]';
        configs.add(
            new Business_Config__c(
                Process_Name__c = 'ChatToCase',
                Business_Rule_Name__c = 'FieldsMap',
                Business_Rule_Value__c = businessRuleValue,
                Id_Country__c = py.id,
                Is_Active__c = true,
                Record_Type_Id__c = 'PedidosYa',
                Type__c = 'Process',
                Parent__c = true
            )
        );

        insert configs;

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

        insert chat;
    }

    @isTest
    static void testBeforeUpdate() {
        Map<String,RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Case','Contact','Account'});
        
        insert new Trigger_Manager__c(Deactivate_LiveChatTranscript_Trigger__c = true, Deactivate_Case_Trigger__c = true);
        
        List<User> uList = new List<User>();
        uList.add(UnitTestDataFactory.createUser('Talabat Customer Care', 'user1asdggdsa@deliveryhero.com', 'test company', 'AE'));
        uList.add(UnitTestDataFactory.createUser('Talabat Customer Care', 'user2asdggadsgas@deliveryhero.com', 'test company', 'AE'));
        insert uList;
        
        LiveChatTranscriptTriggerHandler handler = new LiveChatTranscriptTriggerHandler();

        LiveChatTranscript chat = new LiveChatTranscript(
            Platform__c = 'PedidosYa',
            Order_Number__c = '1234567890001',
            Email__c = 'test@deliveryhero.com',
            User_Name__c = 'test name',
            My_Problem__c = 'Kunde - Anderes Problem',
            OwnerId = uList[0].Id
        );

        System.assertEquals(true, handler.newChatCaseMap.keySet().isEmpty(), 'This should be empty before test starts');
        Test.startTest();
            handler.beforeUpdate(chat, chat);
        Test.stopTest();

        System.assertEquals(1, handler.newChatCaseMap.keySet().size(), 'This list should have one element after test run');
    }

    @isTest
    static void testAndFinally() {
        LiveChatTranscriptTriggerHandler handler = new LiveChatTranscriptTriggerHandler();

        LiveChatTranscript chat = new LiveChatTranscript(
            Platform__c = 'PedidosYa',
            Order_Number__c = '1234567890001',
            Email__c = 'test@deliveryhero.com',
            User_Name__c = 'test name',
           My_Problem__c = 'Kunde - Anderes Problem',
            ownerId=userinfo.getuserId()
        );
        Test.startTest();
            handler.beforeUpdate(chat, chat);
            // this inserts the case
            handler.andFinally();
        Test.stopTest();

        System.assertEquals(1, handler.newChatCaseMap.keySet().size(), 'This map should have one element before test run');
        System.assertEquals(1, handler.newChatCaseMap.values().size(), 'This map should have one element after test run');

        List<Case> insertCases = [SELECT Id FROM Case];

        // one case is being inserted in testSetup
        System.assertEquals(1, insertCases.size(), 'Case should have been inserted');
    }

    @isTest
    static void testAndFinally_negative() {
        LiveChatTranscriptTriggerHandler handler = new LiveChatTranscriptTriggerHandler();

        LiveChatTranscript chat = new LiveChatTranscript(
            Platform__c = 'Wrong_platform',
            Order_Number__c = '1234567890001',
            Email__c = 'test@deliveryhero.com',
            User_Name__c = 'test name',
            My_Problem__c = 'Kunde - Anderes Problem'
        );
        handler.beforeInsert(chat);
        System.assertEquals(0, handler.chatCaseMap.keySet().size(), 'This map should not have any elements');

        Test.startTest();
            handler.andFinally();
        Test.stopTest();

        List<Case> insertCases = [SELECT Id FROM Case];
        System.assertEquals(0, insertCases.size(), 'Case should not have been inserted');
    }
    
    @isTest
    static void testUnusedMethods() {
        LiveChatTranscriptTriggerHandler handler = new LiveChatTranscriptTriggerHandler();
        
        LiveChatTranscript chat = new LiveChatTranscript(
            Platform__c = 'Wrong_platform',
            Order_Number__c = '1234567890001',
            Email__c = 'test@deliveryhero.com',
            User_Name__c = 'test name',
          My_Problem__c = 'Kunde - Anderes Problem'
        );
        
        Test.startTest();
            handler.beforeInsert(chat);
            handler.afterInsert(chat);
            handler.afterUpdate(chat, chat);
        Test.stopTest();
        
        List<Case> insertCases = [SELECT Id FROM Case];
        System.assertEquals(0, insertCases.size(), 'Case should not have been inserted');
    }

    @isTest
    static void testUpdateTriggerEvent() {
        LiveChatTranscript chat = [SELECT Id, OwnerId, Platform__c, CaseId FROM LiveChatTranscript WHERE Platform__c = 'PedidosYa' LIMIT 1];
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        chat.OwnerId = usr.Id;
        
        Test.startTest();
            update chat;
        Test.stopTest();
        
        chat = [SELECT Id, OwnerId, Platform__c, CaseId FROM LiveChatTranscript WHERE Platform__c = 'PedidosYa' LIMIT 1];
        
        System.assertEquals(usr.Id, chat.OwnerId, 'Chat should be owned by the user');
        System.assertNotEquals(null, chat.CaseId, 'Case should have been created');
    }

    @isTest
    static void testMissedChats() {
        LiveChatTranscript chat = [SELECT Id, OwnerId, Platform__c, CaseId FROM LiveChatTranscript WHERE Platform__c = 'PedidosYa' LIMIT 1];
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        chat.OwnerId=usr.id;

        Test.startTest();
        update chat;
        chat = [SELECT Id, OwnerId, Platform__c, CaseId FROM LiveChatTranscript WHERE Platform__c = 'PedidosYa' LIMIT 1];
        chat.status='MISSED';
        update chat;
        Test.stopTest();

        Case caseRec = [SELECT Id, Status FROM Case WHERE Id = :chat.caseId LIMIT 1];
        system.assertEquals('Closed',caseRec.Status);
    }
}