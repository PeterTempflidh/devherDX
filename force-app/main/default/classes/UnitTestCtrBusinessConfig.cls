@isTest
private class UnitTestCtrBusinessConfig {

    static Business_Config__c ob1, ob5;

    static Country__c c3 = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');

    @testSetup static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
    }

    static void TestData(User u) {
        System.runAs(u) {
            insert c3;
            Country__c c1 = UnitTestDataFactory.createCountry('DE', 'Germany', 'EUR');
            Country__c c2 = UnitTestDataFactory.createCountry('AU', 'Australia', 'AUD');
            insert new List<Country__c> {c1, c2};
            ob1 = UnitTestDataFactory.createBusinessConfig('TestProcess', 'Process', 'CaseSubject', 'test subject', c1.id, '83756838232932', true, true);
            Business_Config__c ob2 = UnitTestDataFactory.createBusinessConfig('TestProcess', 'Process', 'CaseOwnerId', '654646546546', c1.id, '83756838232932', true, false);
            Business_Config__c ob3 = UnitTestDataFactory.createBusinessConfig('TestProcess', 'Process', 'CaseSubject', 'test subject', c2.id, '83756838232932', true, true);
            Business_Config__c ob4 = UnitTestDataFactory.createBusinessConfig('TestProcess', 'Process', 'CaseOwnerId', '654646546546', c2.id, '83756838232932', true, false);
            ob5 = UnitTestDataFactory.createBusinessConfig('TestTriggerName', 'Trigger', null, null, c2.id, null, true, true);
            insert new List<Business_Config__c> {ob1, ob2, ob3, ob4, ob5};
        }
    }

    static testmethod void unitTestTrigger1() {
        User testUser = UnitTestDataFactory.createUser('System Administrator', 'testUser@deliveryhero.com', 'Yogiyo', 'KR');

        Business_Config__c ob6 = new Business_Config__c();
        ApexPages.StandardController controller = new ApexPages.StandardController(ob6);

        Test.startTest();
        System.runAs(testUser) {
            CtrBusinessConfig testObj = new CtrBusinessConfig(controller);
            testObj.genericObj.Process_Name__c = 'AccountAfterInsertTgr';
            testObj.genericObj.Type__c = 'Trigger';
            testObj.changeType();
            testObj.genericObj.Is_Active__c = true;
            testObj.saveRecords();
        }
        Test.stopTest();
        List<Business_Config__c> listResult = [select id, Is_Active__c from Business_Config__c where Process_Name__c = 'AccountAfterInsertTgr'];
        System.assert(listResult[0].Is_Active__c);
    }

    static testmethod void unitTestTrigger2() {
        User testUser = UnitTestDataFactory.createUser('System Administrator', 'testUser@deliveryhero.com', 'Yogiyo', 'KR');
        TestData(testUser);
        ApexPages.StandardController controller = new ApexPages.StandardController(ob5);
        Test.startTest();
        System.runAs(testUser) {
            CtrBusinessConfig testObj = new CtrBusinessConfig(controller);
            testObj.genericObj.Process_Name__c = 'AccountAfterInsertTgr';
            testObj.genericObj.Type__c = 'Trigger';
            testObj.changeType();
            testObj.genericObj.Is_Active__c = true;
            testObj.saveRecords();
        }
        Test.stopTest();
        List<Business_Config__c> listResult = [select id, Is_Active__c from Business_Config__c where Process_Name__c = 'AccountAfterInsertTgr'];
        System.assert(listResult[0].Is_Active__c);
    }

    static testmethod void unitTestTriggerNegative() {
        User testUser = UnitTestDataFactory.createUser('System Administrator', 'testUser@deliveryhero.com', 'Yogiyo', 'KR');
        Business_Config__c ob6 = new Business_Config__c();
        ApexPages.StandardController controller = new ApexPages.StandardController(ob6);
        Test.startTest();
        System.runAs(testUser) {
            CtrBusinessConfig testObj = new CtrBusinessConfig(controller);
            testObj.genericObj.Type__c = 'Trigger';
            testObj.changeType();
            testObj.genericObj.Is_Active__c = true;
            testObj.saveRecords();
        }
        Test.stopTest();
        List<Business_Config__c> listResult = [select id, Is_Active__c from Business_Config__c where Process_Name__c = 'AccountAfterInsertTgr'];
        System.assert(listResult.isEmpty());
    }

    static testmethod void unitTestProcess1() {
        User testUser = UnitTestDataFactory.createUser('System Administrator', 'testUser@deliveryhero.com', 'Yogiyo', 'KR');
        Business_Config__c ob6 = new Business_Config__c();
        ApexPages.StandardController controller = new ApexPages.StandardController(ob6);

        Test.startTest();
        System.runAs(testUser) {
            CtrBusinessConfig testObj = new CtrBusinessConfig(controller);
            testObj.genericObj.Process_Name__c = 'TestProcess';
            testObj.genericObj.Type__c = 'Process';
            testObj.changeType();
            testObj.genericObj.Business_Rule_Name__c = 'testBusinessRule';
            testObj.genericObj.Business_Rule_Value__c = 'testBusinessvalue';
            testObj.genericObj.Record_Type_Id__c = '65786767jhgy7t88';
            testObj.genericObj.Is_Active__c = true;
            testObj.genericObj.Id_Country__c = c3.id;
            testObj.addBusinessRule();
            testObj.mapBusinessRule.remove(1);
            testObj.mapBusinessRule.put(1, new Business_Config__c(Business_Rule_Name__c = 'business1', Business_Rule_Value__c = 'businessValue'));
            testObj.mapBusinessRule.put(2, new Business_Config__c(Business_Rule_Name__c = 'business2', Business_Rule_Value__c = 'businessValue'));
            testObj.removeBusinessRule = 2;
            testObj.removeBusinessRule();
            testObj.saveRecords();
        }
        Test.stopTest();


    }

    static testmethod void unitTestProcessNegative1() {
        User testUser = UnitTestDataFactory.createUser('System Administrator', 'testUser@deliveryhero.com', 'Yogiyo', 'KR');
        Business_Config__c ob6 = new Business_Config__c();
        ApexPages.StandardController controller = new ApexPages.StandardController(ob6);
        Test.startTest();
        System.runAs(testUser) {
            CtrBusinessConfig testObj = new CtrBusinessConfig(controller);
            testObj.genericObj.Process_Name__c = 'TestProcess';
            testObj.genericObj.Type__c = 'Process';
            testObj.changeType();
            testObj.genericObj.Business_Rule_Name__c = 'testBusinessRule';
            testObj.genericObj.Record_Type_Id__c = '65786767jhgy7t88';
            testObj.genericObj.Is_Active__c = true;
            testObj.genericObj.Id_Country__c = c3.id;
            testObj.addBusinessRule();
            testObj.mapBusinessRule.remove(1);
            testObj.mapBusinessRule.put(1, new Business_Config__c(Business_Rule_Name__c = 'business1'));
            testObj.mapBusinessRule.put(2, new Business_Config__c(Business_Rule_Name__c = 'business2', Business_Rule_Value__c = 'businessValue'));
            testObj.removeBusinessRule = 2;
            testObj.removeBusinessRule();
            testObj.saveRecords();
        }
        Test.stopTest();
        List<Business_Config__c> listResult = [select id, Is_Active__c from Business_Config__c where Process_Name__c = 'TestProcess'];
        System.assert(listResult.isEmpty());
    }

    static testmethod void unitTestProcess2() {
        User testUser = UnitTestDataFactory.createUser('System Administrator', 'testUser@deliveryhero.com', 'Yogiyo', 'KR');
        TestData(testUser);
        ApexPages.StandardController controller = new ApexPages.StandardController(ob1);
        Test.startTest();
        System.runAs(testUser) {
            CtrBusinessConfig testObj = new CtrBusinessConfig(controller);
            testObj.genericObj.Process_Name__c = 'TestProcess';
            testObj.genericObj.Business_Rule_Name__c = 'testBusinessRule';
            testObj.genericObj.Business_Rule_Value__c = 'testBusinessvalue';
            testObj.genericObj.Is_Active__c = true;
            testObj.removeBusinessRule = testObj.counter;
            testObj.removeBusinessRule();
            testObj.mapBusinessRule.remove(testObj.counter - 1);
            testObj.mapBusinessRule.put(testObj.counter + 1, new Business_Config__c(Business_Rule_Name__c = null));
            testObj.saveRecords();
        }
        Test.stopTest();
        List<Business_Config__c> listResult = [select id, Is_Active__c from Business_Config__c where Process_Name__c = 'TestProcess'];
        System.assert(!listResult.isEmpty());
    }
}