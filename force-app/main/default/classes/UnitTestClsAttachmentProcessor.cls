@isTest
private class UnitTestClsAttachmentProcessor {

   

    static Country__c testCountry;
    static List<Account> accList;
    static Case cs;
    static Branding_Content__c bc;
    static EmailMessage em;

     static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
        List<Platform_Country__c> platformCountry = new List<Platform_Country__c>();
        platformCountry.add(new Platform_Country__c(name = 'TalabatPlatform', country__c = 'Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name = 'FOCPlatform', country__c = 'Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
        testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        Company__c com = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', testCountry);
        insert new List<sObject> {testCountry, com};

        accList = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
        insert accList;

        cs = UnitTestDataFactory.CreateCase(accList[0], 'test', 'test', 'test', 'email', testCountry, 'Yogiyo_Entry_Case', 'test');
        insert cs;



        bc = new Branding_Content__c(Competitor_branding__c = 'Takeaway.com', Description__c = 'side wall', Restaurant_Name__c = accList[0].id, Type__c = 'Other branded consumables');
        insert bc;

        em = new EmailMessage(fromaddress = 'test@test.com', toaddress = 'test@test2.com', parentid = cs.id);
        insert em;
    }


    @isTest static void test_updateLastBranding_positive() {
        Test.startTest();
        setup();

        
        Attachment att = new Attachment(name = 'Test attachment1', body = Blob.valueOf('my test attachment1'), parentId = bc.id);
        insert att;

        List<Branding_Content__c> result = [select id, Last_Branding__c from Branding_Content__c where id = :bc.id];
        System.assertEquals(result[0].Last_Branding__c, Date.today());
        Test.stopTest();
    }

    @isTest static void test_updateLastBranding_negative() {
        Test.startTest();
        setup();

        
        Attachment att = new Attachment(name = 'Test attachment1', body = Blob.valueOf('my test attachment1'), parentId = accList[0].id);
        insert att;


        List<Branding_Content__c> result = [select id, Last_Branding__c from Branding_Content__c where id = :bc.id];
        System.assertEquals(result[0].Last_Branding__c, null);
        Test.stopTest();
    }

    @isTest static void test_emailAttach() {
        Test.startTest();
        setup();

        
        Attachment att = new Attachment(name = 'Test attachment1', body = Blob.valueOf('my test attachment1'), parentId = em.id);
        insert att;

        test.stopTest();
        // List<Branding_Content__c> result = [select id,Last_Branding__c from Branding_Content__c where id=:bc.id];
        //System.assertEquals(result[0].Last_Branding__c,null);
    }

}