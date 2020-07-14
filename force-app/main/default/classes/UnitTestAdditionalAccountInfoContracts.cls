/*
@author : Alexander Faust
@reviewer :
@creation : 02.12.2015
*/
@isTest
private class UnitTestAdditionalAccountInfoContracts {
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
        // Implement test code
        System.runAs(testUser) {
            Account myTestAccount = new Account(
                Name = 'My pretty test account',
                Menu_Typing_Progress_Status__c = 'Not Started',
                Menu_Typing_By_User__c = testUser.Id,
                Menu_Typing_Date_Start__c = Datetime.now(),
                Restaurant_Status__c = 'Taking Restaurant Online'
            );
            insert myTestAccount;

            Contract myTestContract = new Contract(
                Name__c = 'My pretty test contract',
                Commission__c = 12.50,
                End_Date__c = Date.today() + 30,
                StartDate = Date.today() - 5,
                //ActivatedDate = Date.today(),
                Status = 'Draft',
                AccountId = myTestAccount.Id
            );
            insert myTestContract;
            myTestContract.Status = 'Activated';
            update myTestContract;


            ApexPages.StandardController stdCtr = new ApexPages.StandardController(myTestAccount);
            CtrAccountAdditionalInfoContracts ctr = new CtrAccountAdditionalInfoContracts(stdCtr);

            Account extraInfo = ctr.extraInfo;
            Contract ctrContract = ctr.mapContracts.get(myTestContract.Id);
            System.debug('ctrContract: ' + ctrContract);


            System.assertEquals(myTestAccount.Name, extraInfo.Name);
            System.assertEquals(myTestAccount.Menu_Typing_Progress_Status__c, extraInfo.Menu_Typing_Progress_Status__c);
            System.assertEquals(myTestAccount.Menu_Typing_Date_Start__c, extraInfo.Menu_Typing_Date_Start__c);
            System.assertEquals(myTestAccount.Menu_Typing_By_User__c, extraInfo.Menu_Typing_By_User__c);
            System.assertEquals(myTestAccount.Restaurant_Status__c, extraInfo.Restaurant_Status__c);

            System.assertEquals(myTestContract.Name__c, ctrContract.Name__c);
            System.assertEquals(myTestContract.Commission__c, ctrContract.Commission__c);
            System.assertEquals(myTestContract.End_Date__c, ctrContract.End_Date__c);
            System.assertEquals(myTestContract.StartDate, ctrContract.StartDate);

            String[] assertDateStringArray = String.valueOf(Date.today()).split(' ');


            System.assert(String.valueOf(ctrContract.ActivatedDate).contains(assertDateStringArray[0]));
            System.assertEquals('Activated', ctrContract.Status);

        }
        Test.stopTest();

    }

}