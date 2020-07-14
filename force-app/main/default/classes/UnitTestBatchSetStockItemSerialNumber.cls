@isTest
private class UnitTestBatchSetStockItemSerialNumber{
    private static Country__c country;
    private static Company__c company;


    static {
        UnitTestDataFactory.getRecordtypeValues();
        country = UnitTestDataFactory.createCountry('AU', 'Australia', 'AUD');
        insert country;

        company = UnitTestDataFactory.createCompany('DH_AU', 'Australia', country);
        insert company;

        List<Account> accts = UnitTestDataFactory.createAccounts(2, country, 'DH_AU_Account');
        insert accts;

        accts[0].Restaurant_Name__c = 'Test Account_0';
        accts[1].Restaurant_Name__c = 'Test Account_1';
        update accts;
        //Test Account_' + i,

        Opportunity opp = UnitTestDataFactory.createOpportunity('TestOpp123',accts[0],'DH_AU_Opportunity',Date.today());
        insert opp;


        Stock_Item__c stockItem = new Stock_Item__c(RecordTypeId= UnitTestDataFactory.getRecordType('DH_AU_Stock_Item').Id,Name = '123456');
        insert stockItem;

        Stock_Item__c stockItem2 = new Stock_Item__c(RecordTypeId= UnitTestDataFactory.getRecordType('DH_AU_Stock_Item').Id,Name = '654321');
        insert stockItem2;

        Stock_Item__c stockItem3 = new Stock_Item__c(RecordTypeId= UnitTestDataFactory.getRecordType('DH_AU_Stock_Item').Id,Name = '08154711');
        insert stockItem3;



        Asset__c asset = new Asset__c(Name='TestAsset', Account__c = accts[0].Id, Stock_Item__c = stockItem.Id, RecordTypeId = UnitTestDataFactory.getRecordType('DH_AU_Asset').Id);
        insert asset;

        Asset__c asset2 = new Asset__c(Name='TestAsset2', Account__c = accts[1].Id, Replaced_Stock_Item__c= stockItem3.Id, RecordTypeId = UnitTestDataFactory.getRecordType('DH_AU_Asset').Id);
        insert asset2;
    }






    @isTest static void unitTest(){
        Test.startTest();
        String query = 'SELECT Id,Stock_Item__c,Stock_Item__r.Name,Replaced_Stock_Item__c,Replaced_Stock_Item__r.Name,Returning_Stock_Item_Serial_No__c,Stock_Item_Serial_No__c FROM Asset__c WHERE Stock_Item__c != null OR Replaced_Stock_Item__c != null ';
        BatchSetStockItemSerialNumberOnAsset b = new BatchSetStockItemSerialNumberOnAsset(query);
        
        Database.executeBatch(b,500);
        Test.stopTest();
        
        Asset__c a = [SELECT Stock_Item__c, Stock_Item_Serial_No__c FROM Asset__c WHERE Name ='TestAsset'];
        Stock_Item__c s = [SELECT Id,Name FROM Stock_Item__c WHERE Id =: a.Stock_Item__c];
        
        System.assertEquals(a.Stock_Item_Serial_No__c, s.Name);
        
    }
}