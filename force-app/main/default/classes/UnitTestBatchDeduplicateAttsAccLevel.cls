@isTest
private class UnitTestBatchDeduplicateAttsAccLevel {
    @isTest static void UnitTestBatchDeduplicateAttsAccLevel() {
    UnitTestDataFactory.getRecordtypeValues();
        String query = 'SELECT Id, Name, (SELECT Id,Name,BodyLength, ContentType, CreatedDate, LastModifiedDate FROM Attachments) FROM Account WHERE Name =\'Test Account\'';
        Account theTestAccount = new Account (Name = 'Test Account');
        insert theTestAccount;

        List<Attachment> listAttachments = new List<Attachment>();

        for(Integer i=0; i < 5; i++){
            Attachment a = new Attachment(Name = 'Att',ContentType =' Text', ParentId = theTestAccount.Id, Body = Blob.valueOf('Hello World'));
            listAttachments.add(a);
        }
        insert listAttachments;

        Test.startTest();
        BatchDeduplicateAttsAccLevel b = new BatchDeduplicateAttsAccLevel(query);
        Database.executeBatch(b,500);
        Test.stopTest();

        List<Account> listAccounts = Database.query(query);

        System.assertEquals(0, listAccounts[0].Attachments.size());
    }
}