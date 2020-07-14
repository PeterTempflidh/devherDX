@IsTest
private class LogACall_AuraControllerTest {
    private static User testUser = UnitTestDataFactory.createUser('PY Customer Care', 'testpy@deliveryhero.com', 'PedidosYa', 'UY');
    private static List<Account> accounts;
    private static Country__c country;
    private static List<Contact> contacts;
    private static Case caseRec;
    private static LiveChatTranscript chat;
    private static LiveChatTranscript chat2;

    static{
        insert testUser;
        UnitTestDataFactory.getRecordtypeValues();
        country = UnitTestDataFactory.createCountry('UY', 'Uruguay', 'UYU');
        insert country;
        accounts = UnitTestDataFactory.createAccounts(1, country, 'PY_Account');
        insert accounts;
        contacts = UnitTestDataFactory.createContacts(accounts, 'test Lastname', 'test FirstName', 'Mr', 'Owner', 1, 'testme', 'PY_Contact');
        insert contacts;
        caseRec = UnitTestDataFactory.createCase(accounts[0], 'New', '', '', 'Chat', country, 'PY_Inbound_Case', 'Testing');
        insert caseRec;
        caseRec.OwnerId=testUser.Id;
        update caseRec;

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
                caseId=caseRec.Id,
                case=caseRec,
                ownerId=testUser.id
        );
        insert chat;

        chat2 = new LiveChatTranscript(
                Order_Number__c = '1234567890002',
                Email__c = 'test2@test.com',
                User_Name__c = 'test2 name',
                My_Problem__c = 'Kunde - Anderes Problem',
                Body='Hello',
                LiveChatVisitorId=visitor.id
        );
        insert chat2;
    }

    @IsTest
    static void testGetTask(){
        Task t=new Task();
        t.Subject='Call';
        t.Activity_Subject__c='Franchise';
        t.Description='Test Class';
        t.WhatId=caseRec.Id;
        insert t;
        Task taskRec=LogACall_AuraController.getTaskDetails(chat.Id);
        system.assertEquals(t.Id,taskRec.Id);
    }

    @IsTest
    static void testsaveTask_Positive() {
        system.runAs(testUser){
            Task t=new Task();
            t.Subject='Call';
            t.Activity_Subject__c='Franchise';
            t.Description='Test Class';
			t.Whoid=contacts[0].Id;
			insert t;
            Task tTemp=new Task();
            tTemp.Whoid=contacts[0].Id;

            String result=LogACall_AuraController.saveTask(chat.Id,t,tTemp);
            system.assertEquals(result.contains('Success'),true);
        }
    }
     
    @IsTest
    static void testsaveTask_withoutAnyOldTask() {
        system.runAs(testUser){
            Task t=new Task();
            t.Subject='Call';
            t.Activity_Subject__c='Franchise';
            t.Description='Test Class';
            Task tTemp=new Task();
            tTemp.Whoid=contacts[0].Id;

            String result=LogACall_AuraController.saveTask(chat.Id,t,tTemp);
            system.assertEquals(result.contains('Success'),true);
        }
    }

    @IsTest
    static void testsaveTask_NoCasePresent() {
        system.runAs(testUser){
            Task t=new Task();
            t.Subject='Call';
            t.Activity_Subject__c='Franchise';
            t.Description='Test Class';

            String result=LogACall_AuraController.saveTask(chat2.Id,t,new Task());
            system.assertEquals(result,'No Case Present');
        }
    }
}