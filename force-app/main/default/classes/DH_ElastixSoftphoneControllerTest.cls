@IsTest
private class DH_ElastixSoftphoneControllerTest {

    @testSetup
    static void testSetup() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c bh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        Database.insert(bh);
        Company__c com = UnitTestDataFactory.createCompany('Talabat', 'Talabat', bh);
        insert com;
        Account acco = UnitTestDataFactory.createAccount('TEST', bh, 'Talabat_Account');
        insert acco;
        Group q = new Group();
        q.Name = 'Talabat_BH_Sales_Admin';
        q.Type = 'Queue';
        insert q;
        User u = [SELECT Id FROM User WHERE Id = :userinfo.getUserId()];
        User elastixUser = new User();
        system.runAs(u) {
            QueueSObject qSObj = new QueueSObject(SobjectType = 'Case', QueueId = q.Id);
            insert qSObj;

            Profile talabatProfile = [SELECT Id FROM Profile WHERE Name = 'Talabat Customer Care'];
            elastixUser.Elastix_Agent_Id__c = '9876';
            elastixUser.Elastix_Password__c = 'test1234';
            elastixUser.alias = 'elastUsr';
            elastixUser.email = 'testclassuser@talabat.com';
            elastixUser.emailencodingkey = 'UTF-8';
            elastixUser.lastname = 'Test Class User';
            elastixUser.languagelocalekey = 'en_US';
            elastixUser.localesidkey = 'en_US';
            elastixUser.profileid = talabatProfile.Id;
            elastixUser.timezonesidkey = 'America/Los_Angeles';
            elastixUser.username = 'testclassuser@talabat.com.test';
            elastixUser.FederationIdentifier = 'testclassuser@talabat.com.test';
            insert elastixUser;
        }

        List<Business_Config__c> configs = new List<Business_Config__c>();

        configs.add(
                new Business_Config__c(
                        Process_Name__c = 'ElastixQueuePrefixes',
                        Business_Rule_Name__c = 'Bahrain',
                        Business_Rule_Value__c = '{"Country Code":"+973","Prefix":"30"}',
                        Id_Country__c = bh.id,
                        Is_Active__c = true,
                        Record_Type_Id__c = 'Global_Config',
                        Type__c = 'Process',
                        Parent__c = true
                ));
        insert configs;
        Case testCase = UnitTestDataFactory.createCase(acco, 'New', 'Customer', '', '', bh, 'Talabat_Inbound_Case', 'Testing Escalation');
        testCase.Platform__c = 'Talabat';
        testCase.OwnerId = elastixUser.id;
        testCase.Elastix_Agent_Extension__c = '9876';
        testCase.Vendor_Phone_Number__c = '+973123456789';
        testCase.Status = 'In Progress';
        insert testCase;
    }

    @IsTest
    static void testFetchRecordId() {
        User agent = [SELECT Id FROM User WHERE Elastix_Agent_Id__c = '9876' LIMIT 1];
        String recordId;
        system.runAs(agent) {
            String todayDateTime = System.today().year() + ',' + System.today().month() + ',' + System.today().day() + ',0,0,0';
            recordId = DH_ElastixSoftphoneController.getRecordId('+973123456789', todayDateTime);
        }
        List<Case> cases = [SELECT Id FROM Case Limit 1];
        system.assertEquals(recordId, cases[0].id);
    }

    @IsTest
    static void testFetchUserDetails() {
        User agent = [SELECT Id,Elastix_Agent_Id__c,Elastix_Password__c FROM User WHERE Elastix_Agent_Id__c = '9876' LIMIT 1];
        system.runAs(agent) {
            DH_ElastixSoftphoneController.getUserDetails();
        }
        system.assertEquals(DH_ElastixSoftphoneController.username, agent.Elastix_Agent_Id__c);
        system.assertEquals(DH_ElastixSoftphoneController.password, agent.Elastix_Password__c);
    }

    @IsTest
    static void testCreateTaskRecord() {
        User agent = [SELECT Id,Elastix_Agent_Id__c,Elastix_Password__c FROM User WHERE Elastix_Agent_Id__c = '9876' LIMIT 1];
        Case phoneCase = [SELECT Id,Vendor_Phone_Number__c FROM Case WHERE Elastix_Agent_Extension__c = '9876' LIMIT 1];
        String taskId;
        system.runAs(agent) {
            taskId = DH_ElastixSoftphoneController.createRecord(phoneCase.Vendor_Phone_Number__c,phoneCase.Id);
        }
        system.assertNotEquals(null,taskId);
    }

    @IsTest
    static void testPhoneNumberWithCountryCodeWithPrefix() {
        User agent = [SELECT Id,Elastix_Agent_Id__c,Elastix_Password__c FROM User WHERE Elastix_Agent_Id__c = '9876' LIMIT 1];
        Case phoneCase = [SELECT Id,Vendor_Phone_Number__c FROM Case WHERE Elastix_Agent_Extension__c = '9876' LIMIT 1];
        String phoneNumber;
        system.runAs(agent) {
            phoneNumber = DH_ElastixSoftphoneController.getPhoneNumberWithPrefix(phoneCase.Vendor_Phone_Number__c,phoneCase.Id);
        }
        system.assertEquals('30123456789',phoneNumber);
    }

    @IsTest
    static void testPhoneNumberWithCountryCodeZeroWithPrefix() {
        User agent = [SELECT Id,Elastix_Agent_Id__c,Elastix_Password__c FROM User WHERE Elastix_Agent_Id__c = '9876' LIMIT 1];
        Case phoneCase = [SELECT Id,Vendor_Phone_Number__c FROM Case WHERE Elastix_Agent_Extension__c = '9876' LIMIT 1];
        String phoneNumber;
        system.runAs(agent) {
            phoneNumber = DH_ElastixSoftphoneController.getPhoneNumberWithPrefix('00973123456789',phoneCase.Id);
        }
        system.assertEquals('30123456789',phoneNumber);
    }
}