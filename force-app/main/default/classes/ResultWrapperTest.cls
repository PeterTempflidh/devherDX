@isTest
private class ResultWrapperTest {
    @isTest
    static void testParse() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c c = UnitTestDataFactory.createCountry('DE','Germany', 'EUR');
        Company__c com = UnitTestDataFactory.createCompany('testcompany', 'DE', c);
        List<Account> accList = UnitTestDataFactory.createAccounts(1,c,'DE_Account');
        insert accList;

        ResultWrapper res = new ResultWrapper(true);
        res.Id = accList[0].Id;
        res.UserMessage = 'Test Message';

        String resJson = Json.Serialize(res);

        Test.startTest();
            ResultWrapper parsedRes = ResultWrapper.parse(resJson);
        Test.stopTest();

        System.assertEquals('Test Message', parsedRes.UserMessage, 'Parsing failed!');
    }

    @isTest
    static void testParse_Negative() {
        Test.startTest();
            ResultWrapper parsedRes = ResultWrapper.parse('');
        Test.stopTest();

        System.assertEquals(null, parsedRes, 'Parsed result should be null');
    }

    @isTest
    static void testConstructor() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c c = UnitTestDataFactory.createCountry('DE','Germany', 'EUR');
        Company__c com = UnitTestDataFactory.createCompany('testcompany', 'DE', c);
        List<Account> accList = UnitTestDataFactory.createAccounts(1,c,'DE_Account');
        insert accList;
        
        Group g = new Group();
        g.Name = 'test queue';
        insert g;
        
        Test.startTest();
            ResultWrapper res = new ResultWrapper(true);
            res.Id = accList[0].Id;
        	res.OwnerId = g.Id;
        	res.QueueId = g.Id;
            res.UserMessage = 'Test Message';
            res.Error = '';
            res.Success = true;
            res.UserMessage = '';
        Test.stopTest();
    }
}