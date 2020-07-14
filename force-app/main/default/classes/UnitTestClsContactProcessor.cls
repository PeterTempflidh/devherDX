@isTest
private class UnitTestClsContactProcessor {

    private static Country__c country;
    private static List<Account> accounts;
    private static List<Contact> contacts;

    @testsetup static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
        List<Platform_Country__c> platformCountry = new List<Platform_Country__c>();
        platformCountry.add(new Platform_Country__c(name = 'TalabatPlatform', country__c = 'Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name = 'FOCPlatform', country__c = 'Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
    }

    static void setupUserData(User u) {

        System.runAs(u) {

            country = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            insert country;

            accounts = UnitTestDataFactory.createAccounts(1, country, 'Yogiyo_Account');
            insert accounts;

            contacts = UnitTestDataFactory.CreateContacts(accounts, 'Best', 'Burger', 'Mr', 'Employee', 201, 'test', 'Yogiyo_Contact');
            insert contacts;


        }
    }

    @isTest static void test_insertingNewContact() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'yogiyounittestuser@deliveryhero.com', 'Yogiyo', 'KR');
        Test.startTest();
        System.runAs(testUser) {
            setupUserData(testUser);
            contacts[0].Contact_Role__c = 'Owner';
            update contacts[0];

            List<Contact> newContact = UnitTestDataFactory.CreateContacts(accounts, 'Best', 'Burger', 'Mr', 'Owner', 1, 'test', 'Yogiyo_Contact');
            try {
                insert newContact;
            } catch (Exception e) {
                System.debug('@@@@ the following Exception was thrown in  test class UnitTestClsContactProcessor in method  test_insertingNewContact ' + e.getMessage());
            }
        }
        Test.stopTest();

        List<Contact> allContacts = [SELECT Id, Contact_Role__c FROM Contact WHERE AccountId = : accounts[0].Id];
        System.assertEquals(contacts.size(), allContacts.size());
    }

    @isTest static void test_upDatingNewContact() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'yogiyounittestuser@deliveryhero.com', 'Yogiyo', 'KR');
        Test.startTest();
        System.runAs(testUser) {
            setupUserData(testUser);
            contacts[0].Contact_Role__c = 'Owner';
            update contacts[0];

        }
        Test.stopTest();

        Contact con = [SELECT Id, Contact_Role__c FROM Contact WHERE AccountId = : accounts[0].Id AND Contact_Role__c = 'Owner' Limit 1];
        System.assertEquals(con.Id, contacts[0].Id);
    }

}