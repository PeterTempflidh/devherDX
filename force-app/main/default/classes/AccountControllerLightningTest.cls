@isTest
private class AccountControllerLightningTest {

    @isTest
    static void testTerminateRestaurant() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c c = UnitTestDataFactory.createCountry('DE','Germany', 'EUR');
        Company__c com = UnitTestDataFactory.createCompany('testcompany', 'DE', c);
        User ccTestUser = UnitTestDataFactory.createUser('DE Customer Care', 'escalationtestuser@deliveryhero.com', 'DH_AU','AU');
        insert new List<sObject> { c,com,ccTestUser };

        List<Account> accList = UnitTestDataFactory.createAccounts(1,c,'DE_Account');
        insert accList;

        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DE_Opportunity',Date.today());
        insert oppList;
        Opportunity_Line_Item__c oppService = UnitTestDataFactory.createOpportunityLineItemService('testService3',oppList[0],null,true,'DE_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        oppService.Line_item_type__c = 'Service';
        insert oppService;

        List<Asset__c> assets = UnitTestDataFactory.createAssets(1, accList[0], oppList[0], Date.today(), true, null, null, 'DE_Asset', '012345689', '', '', Date.today(),null, '', false, '', '', '', 'Active', null, '', '');
        insert assets;

        Test.startTest();
            String jsonResult = AccountControllerLightning.terminateRestaurant(accList[0].Id);
        Test.stopTest();
        
        ResultWrapper res = ResultWrapper.parse(jsonResult);
        System.assertEquals(true, res.Success,'There should be 1 asset to terminate');
    }

    @isTest
    static void testTerminateRestaurant_Negative() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c c = UnitTestDataFactory.createCountry('DE','Germany', 'EUR');
        Company__c com = UnitTestDataFactory.createCompany('testcompany', 'DE', c);
        User ccTestUser = UnitTestDataFactory.createUser('DE Customer Care', 'escalationtestuser@deliveryhero.com', 'DH_AU','AU');
        insert new List<sObject> { c,com,ccTestUser };

        List<Account> accList = UnitTestDataFactory.createAccounts(1,c,'DE_Account');
        insert accList;

        Test.startTest();
            String jsonResult = AccountControllerLightning.terminateRestaurant(accList[0].Id);
        Test.stopTest();
        
        ResultWrapper res = ResultWrapper.parse(jsonResult);
        System.assertEquals(false, res.Success,'There should be nothhing to terminate');
    }

    @isTest
    static void testNewCallCase() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c c = UnitTestDataFactory.createCountry('DE','Germany', 'EUR');
        Company__c com = UnitTestDataFactory.createCompany('testcompany', 'DE', c);
        User ccTestUser = UnitTestDataFactory.createUser('DE Customer Care', 'escalationtestuser@deliveryhero.com', 'DH_AU','AU');
        insert new List<sObject> { c,com,ccTestUser };

        List<Account> accList = UnitTestDataFactory.createAccounts(1,c,'DE_Account');
        insert accList;
        Account acc = accList[0];

        Test.startTest();
            String jsonResult = AccountControllerLightning.newCallCase(acc.Id);
        Test.stopTest();

        ResultWrapper res = ResultWrapper.parse(jsonResult);
        System.assertEquals(true, res.Success, 'If case was created this szould be true');

        List<Case> newCallCases = [SELECT Id FROM Case WHERE AccountId = :acc.Id];
        System.assertEquals(1, newCallCases.size(), 'One new case should have been created');
    }

    @isTest
    static void testNewCallCase_Negative() {
        Test.startTest();
            String jsonResult = AccountControllerLightning.newCallCase(null);
        Test.stopTest();

        ResultWrapper res = ResultWrapper.parse(jsonResult);
        System.assertEquals(false, res.Success, 'If case was not created this should be false');

        List<Case> newCallCases = [SELECT Id FROM Case];
        System.assertEquals(0, newCallCases.size(), 'No case should have been created');
    }
}