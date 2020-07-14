@IsTest
private class ActivitySelectorTest {
    private static User testUser = UnitTestDataFactory.createUser('PY Customer Care', 'testpy@deliveryhero.com', 'PedidosYa', 'UY');
    private static List<Account> accounts;
    private static Country__c country;
    private static List<Contact> contacts;
    private static Case caseRec;
    private static Task taskRec;

    static {
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
        caseRec.OwnerId = testUser.Id;
        update caseRec;
        taskRec = new task();
        taskRec.WhatId=caseRec.Id;
        taskRec.Subject='TestClass';
        taskRec.Activity_Subject__c='Call - Employee reached';
        taskRec.Type='Call';
        taskRec.Description='TestClass';
        taskRec.TaskSubtype='Call';
        taskRec.CallType='Outbound';
        taskRec.CallObject='Call';
        taskRec.ActivityDate=system.today();
        taskRec.Status = 'Completed';

        insert taskRec;
    }
    @IsTest
    static void testActivitySelectorByParent() {
        Case c=[SELECT Id FROM Case LIMIT 1];
        List<Task> taskList=ActivitySelector.getTaskDetailsByParent(c.Id);
        system.assertNotEquals(taskList.size(),0);
    }
    @IsTest
    static void testActivitySelectorById() {
        Task t=[SELECT Id FROM Task LIMIT 1];
        Task taskRecord=ActivitySelector.getTaskDetailsById(t.Id);
        system.assertNotEquals(taskRecord.id,null);
    }
    @IsTest
    static void testgetTaskDetailsByCode() {
        Task t=[SELECT Id,Code__c FROM Task LIMIT 1];
        List<Task> tasks = ActivitySelector.getTaskDetailsByCode(new Set<String> {t.Code__c});
        System.assertNotEquals(tasks.isEmpty(),true);
    }
}