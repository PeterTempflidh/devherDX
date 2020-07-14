@isTest
private class UnitTestLibScarfaceCryptor {

    @testsetup static void setup() {
        UnitTestDataFactory.getRecordtypeValues();

    }

    @isTest static void test_method_one() {

        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'unittestUser@deliveryhero.com', 'Yogiyo', 'KR');
        Account acc;
        String Encrypted;
        String Decrypted;

        Test.startTest();
        System.runAs(testUser) {
            Country__c c = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            insert c;

            acc = UnitTestDataFactory.createAccount('TestAccount', c, 'Yogiyo_Account');
            insert acc;

            LibScarfaceCryptor obj = new LibScarfaceCryptor();
            Blob cryptoKey = Crypto.generateAesKey(256);
            Encrypted = LibScarfaceCryptor.encrypt(acc.id, cryptoKey);
            Decrypted = LibScarfaceCryptor.decrypt(Encrypted, cryptoKey);

        }
        Test.stopTest();
        System.assertNotEquals(Encrypted, null);
        System.assertEquals(Decrypted, acc.id);
    }
}