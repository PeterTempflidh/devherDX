@IsTest
private class HistoricalCases_AuraControllerTest {
    private static User testUser = UnitTestDataFactory.createUser('PY Customer Care', 'testpy@deliveryhero.com', 'PedidosYa', 'UY');
    private static List<Account> accounts;
    private static Country__c country;
    private static List<Contact> contacts;
    private static Case caseRec;
    private static LiveChatTranscript chat;

    @TestSetup
    static void TestSetup(){
        insert testUser;
        UnitTestDataFactory.getRecordtypeValues();
        country = UnitTestDataFactory.createCountry('UY', 'Uruguay', 'UYU');
        insert country;
        accounts = UnitTestDataFactory.createAccounts(1, country, 'PY_Account');
        insert accounts;
        contacts = UnitTestDataFactory.createContacts(accounts, 'test Lastname', 'test FirstName', 'Mr', 'Owner', 1, 'testme', 'PY_Contact');
        insert contacts;
        List<Case> cases=new List<Case>();
        for(Integer i=0;i<10;i++){
            caseRec = UnitTestDataFactory.createCase(accounts[0], 'New', '', '', 'Chat', country, 'PY_Inbound_Case', 'Testing'+i);
            caseRec.OwnerId=testUser.Id;
            caseRec.Platform__c='PedidosYa';
            caseRec.Customer_Email__c='test@test.com';
            caseRec.Order_Number__c='123456789';
            cases.add(caseRec);
        }
		caseRec = UnitTestDataFactory.createCase(accounts[0], 'New', '', '', 'Chat', country, 'PY_Inbound_Case', 'Testing-0');
        caseRec.OwnerId=testUser.Id;
        caseRec.Platform__c='PedidosYa';
        caseRec.Customer_Email__c='test@test.com';
        caseRec.Order_Number__c='0';
        cases.add(caseRec);
        caseRec = UnitTestDataFactory.createCase(accounts[0], 'New', '', '', 'Chat', country, 'PY_Inbound_Case', 'Testing-xxxx');
        caseRec.OwnerId=testUser.Id;
        caseRec.Platform__c='PedidosYa';
        caseRec.Customer_Email__c='test@test.com';
        caseRec.Order_Number__c='xxxx-xxxx';
        cases.add(caseRec);
        insert cases;
        LiveChatVisitor visitor=new LiveChatVisitor();
        insert visitor;

        chat = new LiveChatTranscript(
                Platform__c = 'PedidosYa',
                Order_Number__c = '1234567890001',
                Email__c = 'test@test.com',
                User_Name__c = 'test name',
                My_Problem__c = 'Kunde - Anderes Problem',
                Body='Hello',
                LiveChatVisitorId=visitor.id,
                caseId=cases[0].Id,
                case=cases[0],
                ownerId=testUser.id
        );
        insert chat;
        Business_Config__c config = UnitTestDataFactory.createBusinessConfig('HistoricalCaseConfigs', 'Process', 'Parameters', 'Customer_Email__c,Customer_Phone_Number_1__c', country.id, 'Global_Config', true, true);
        Business_Config__c config1 = UnitTestDataFactory.createBusinessConfig('HistoricalCaseConfigs', 'Process', 'ColumnOrderRelatedList', '[  {    "Sno":"1",    "ColumnName": "Case Number",    "FieldAPIName": "CaseNumber",    "Object": "Case",    "Type":"url"  },  {    "Sno":"2",    "ColumnName": "Chat Name",    "FieldAPIName": "Name",    "Object": "LiveChatTranscript",    "Type":"url"  },  {    "Sno":"3",    "ColumnName": "Opened Date",    "FieldAPIName": "CreatedDate",    "Object": "Case",    "Type":"text"  },  {    "Sno":"4",    "ColumnName": "Case Reason Level 3",    "FieldAPIName": "Case_Reason_Level_3__c",    "Object": "Case",    "Type":"text"  },  {    "Sno":"5",    "ColumnName": "Order Number",    "FieldAPIName": "Order_Number__c",    "Object": "Case",    "Type":"text"}]', null, 'Global_Config', true, false);
        Business_Config__c config2 = UnitTestDataFactory.createBusinessConfig('HistoricalCaseConfigs', 'Process', 'ColumnOrderFull', '[  {    "Sno":"1",    "ColumnName": "Case Number",    "FieldAPIName": "CaseNumber",    "Object": "Case",    "Type":"url"  },  {    "Sno":"2",    "ColumnName": "Chat Name",    "FieldAPIName": "Name",    "Object": "LiveChatTranscript",    "Type":"url"  },  {    "Sno":"3",    "ColumnName": "Opened Date",    "FieldAPIName": "CreatedDate",    "Object": "Case",    "Type":"text"  },  {    "Sno":"4",    "ColumnName": "Status",    "FieldAPIName": "Status",    "Object": "Case",    "Type":"text"  },  {    "Sno":"5",    "ColumnName": "Origin",    "FieldAPIName": "Origin",    "Object": "Case",    "Type":"text"  },  {    "Sno":"6",    "ColumnName": "Type",    "FieldAPIName": "Type",    "Object": "Case",    "Type":"text"  },  {    "Sno":"7",    "ColumnName": "Case Reason Level 1",    "FieldAPIName": "Case_Reason_Level_1__c",    "Object": "Case",    "Type":"text"  },  {    "Sno":"8",    "ColumnName": "Case Reason Level 2",    "FieldAPIName": "Case_Reason_Level_2__c",    "Object": "Case",    "Type":"text"  },  {    "Sno":"9",    "ColumnName": "Case Reason Level 3",    "FieldAPIName": "Case_Reason_Level_3__c",    "Object": "Case",    "Type":"text"  },  {    "Sno":"10",    "ColumnName": "Order Number",    "FieldAPIName": "Order_Number__c",    "Object": "Case",    "Type":"text"  }]', null, 'Global_Config', true, false);
		 Business_Config__c config3 = UnitTestDataFactory.createBusinessConfig('HistoricalCaseConfigs', 'Process', 'PatternToExclude', '[{ "Case":[{"Order_Number__c":"x,0,X,xxxx-xxxx,0000-0000"}]}]', null, 'Global_Config', true, false);
        insert new List<sObject>{config,config1,config2,config3};
    }
    @IsTest
    static void testGetCasesFromChat_NonRelatedList() {
        LiveChatTranscript chat=[SELECT Id FROM LiveChatTranscript LIMIT 1];
        HistoricalCases_AuraController.CaseDetailsWrapper cw = HistoricalCases_AuraController.getCases(chat.Id,false,'On Init');
        system.assertEquals(cw.caseList.size()>0,true);
    }
    @IsTest
    static void testGetCasesFromChat_RelatedList() {
        LiveChatTranscript chat=[SELECT Id FROM LiveChatTranscript LIMIT 1];
        HistoricalCases_AuraController.CaseDetailsWrapper cw = HistoricalCases_AuraController.getCases(chat.Id,true,'On Init');
        system.assertEquals(cw.caseList.size()>0,true);
    }
    @IsTest
    static void testGetCasesFromCase_RelatedList() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        HistoricalCases_AuraController.CaseDetailsWrapper cw = HistoricalCases_AuraController.getCases(c.Id,true,'ordersList');
        system.assertEquals(cw.caseList.size()>0,true);
    }
    @IsTest
    static void testGetCasesFromCase_NonRelatedList() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        HistoricalCases_AuraController.CaseDetailsWrapper cw = HistoricalCases_AuraController.getCases(c.Id,false,'On Init');
        system.assertEquals(cw.caseList.size()>0,true);
    }
}