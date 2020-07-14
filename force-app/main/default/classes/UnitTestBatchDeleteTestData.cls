@isTest
private class UnitTestBatchDeleteTestData {

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
    
    
    static testmethod void deletionOfTestData(){
      Test.startTest();
        BatchDeleteTestData b = new BatchDeleteTestData(UserInfo.getUserId());
        Database.executeBatch(b,200);
        Test.stopTest();
    }

}