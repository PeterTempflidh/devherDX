/*
@author : Alexander Faust
@reviewer : 
@creation : 05.12.2014
*/
@isTest
private class UnitTestMigrationScriptInsertBatch {
    
    static final String templateMapping = '{"Id":"Migration_ID__c","Name":"Name"}';


    @isTest static void test_method_one() {
        UnitTestDataFactory.getRecordtypeValues();
        Account myTestAccount = new Account(Name='myTestAccount');
        insert myTestAccount;

        List<sObject> listObjects = new List<sObject>();
        listObjects.add(myTestAccount);
        Test.startTest();
        MigrationScriptInsertBatch b = new MigrationScriptInsertBatch(listObjects,templateMapping);
        Database.executeBatch(b, 100);
        Test.stopTest();

        Account resultAccount = [SELECT Id,Migration_ID__c,Name FROM Account WHERE Migration_ID__c =: myTestAccount.Id];

        System.assertEquals(myTestAccount.Id, resultAccount.Migration_ID__c);
        System.assertEquals(myTestAccount.Name, resultAccount.Name);
    }
}