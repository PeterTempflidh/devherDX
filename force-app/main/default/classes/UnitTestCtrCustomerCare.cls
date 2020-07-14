@isTest
private class UnitTestCtrCustomerCare {

    static List<Account> accList;

    @testsetup static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
        List<Platform_Country__c> platformCountry = new List<Platform_Country__c>();
        platformCountry.add(new Platform_Country__c(name = 'TalabatPlatform', country__c = 'Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name = 'FOCPlatform', country__c = 'Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
    }

    static void setupUserData(User u) {
        Country__c c = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        insert c;
        accList = UnitTestDataFactory.createAccounts(2, c, 'Yogiyo_Account');
        accList[0].Menu_Typing_Date_Start__c = datetime.now();
        accList[0].Menu_Typing_By_User__c = u.id;
        insert accList;
    }

    @isTest static void test_method_positive() {
        User testCCUser = UnitTestDataFactory.createUser('Yogiyo Customer Care Team', 'testCCUser@deliveryhero.com', 'Yogiyo', 'KR');
        Test.startTest();
        System.runAs(testCCUser) {
            setupUserData(testCCUser);

            ApexPages.currentPage().getParameters().put('accId', accList[0].Id);
            CtrCustomerCare testObject = new CtrCustomerCare();
            testObject.startProgress();

        }
        Account result = [select id, Menu_Typing_Progress_Status__c from Account where id = :accList[0].Id];
        System.assertEquals(result.Menu_Typing_Progress_Status__c, 'In Progress');
        Test.stopTest();
    }

    @isTest static void test_method_negative() {
        User testCCUser = UnitTestDataFactory.createUser('Yogiyo Customer Care Team', 'testCCUser@deliveryhero.com', 'Yogiyo', 'KR');
        Test.startTest();
        System.runAs(testCCUser) {
            setupUserData(testCCUser);

            ApexPages.currentPage().getParameters().put('accId', accList[1].Id);
            CtrCustomerCare testObject = new CtrCustomerCare();
            testObject.startProgress();

        }
        Account result = [select id, Menu_Typing_Progress_Status__c from Account where id = :accList[1].Id];
        System.assertNotEquals(result.Menu_Typing_Progress_Status__c, 'In Progress');
        Test.stopTest();
    }

}