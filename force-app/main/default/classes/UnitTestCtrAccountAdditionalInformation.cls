/*
@author : Alexander Faust
@reviewer :
@creation : 02.12.2015

@notes: maybe better use .addFields of standardController instead of soql in getter method?
*/
@isTest
private class UnitTestCtrAccountAdditionalInformation {

    static User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'testUser@deliveryhero.com', 'Yogiyo', 'KR');

    @testSetup static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
        List<Platform_Country__c> platformCountry = new List<Platform_Country__c>();
        platformCountry.add(new Platform_Country__c(name = 'TalabatPlatform', country__c = 'Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name = 'FOCPlatform', country__c = 'Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
    }

    @isTest static void testInit() {
        Test.startTest();
        System.runAs(testUser) {
            Account myTestAccount = new Account(
                Name = 'My pretty test account',
                Menu_Typing_Progress_Status__c = 'Not Started',
                Menu_Typing_By_User__c = testUser.Id,
                Menu_Typing_Date_Start__c = Datetime.now(),
                Restaurant_Status__c = 'Taking Restaurant Online'
            );
            insert myTestAccount;


            ApexPages.StandardController stdCtr = new ApexPages.StandardController(myTestAccount);
            CtrAccountAdditionalInformation ctr = new CtrAccountAdditionalInformation(stdCtr);

            Account extraInfo = ctr.extraInfo;


            System.assertEquals(myTestAccount.Name, extraInfo.Name);
            System.assertEquals(myTestAccount.Menu_Typing_Progress_Status__c, extraInfo.Menu_Typing_Progress_Status__c);
            System.assertEquals(myTestAccount.Menu_Typing_Date_Start__c, extraInfo.Menu_Typing_Date_Start__c);
            System.assertEquals(myTestAccount.Menu_Typing_By_User__c, extraInfo.Menu_Typing_By_User__c);
            System.assertEquals(myTestAccount.Restaurant_Status__c, extraInfo.Restaurant_Status__c);
        }
        Test.stopTest();
    }

}