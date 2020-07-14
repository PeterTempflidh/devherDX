/**
 * Created by w.novoa on 27.06.2018.
 */

@IsTest
private class UnitTestClsPlatformPerfomanceHandler {

    @testSetup
    static void setup() {
        UnitTestDataFactory.getRecordtypeValues();

        Country__c bh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        company__c com = UnitTestDataFactory.createCompany('Talabat', 'Talabat', bh);
        insert com;

        Business_Config__c b1 = UnitTestDataFactory.createBusinessConfig('UpdateAccountStatusParent', 'Process', 'ParentTypes', 'Brand,Group', bh.id, 'Talabat_Account', true, true);

        insert b1;

        Platform_Country__c pt2 = new Platform_Country__c(name = 'TalabatPlatform', Country__c = 'Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates');
        Account accParent = UnitTestDataFactory.createAccount('BatchTestClassAccount1', bh, 'Talabat_Account');
        accParent.ParentId = accParent.id;
        accParent.Type = 'Brand';
        insert accParent;
        System.debug('accParent-->'+accParent);
        Account accParent1 = UnitTestDataFactory.createAccount('BatchTestClassAccount2', bh, 'Talabat_Account');
        accParent1.ParentId = accParent.id;
        accParent1.Type = 'Brand';
        insert accParent1;
        Account accParent2 = UnitTestDataFactory.createAccount('BatchTestClassAccount3', bh, 'Talabat_Account');
        accParent2.ParentId = accParent1.id;
        accParent2.Type = 'Brand';
        insert accParent2;
        Account accParent3 = UnitTestDataFactory.createAccount('BatchTestClassAccount4', bh, 'Talabat_Account');
        accParent3.ParentId = accParent2.id;
        accParent3.Type = 'Brand';
        insert accParent3;
        Account accParent4 = UnitTestDataFactory.createAccount('BatchTestClassAccount5', bh, 'Talabat_Account');
        accParent4.ParentId = accParent3.id;
        accParent4.Type = 'Brand';
        insert accParent4;
        Account accChild = UnitTestDataFactory.createAccount('TestChild', bh, 'Talabat_Account');
        accChild.ParentId = accParent4.id;
        insert accChild;

    }

    @IsTest
    static void testUpdateOnlineStatusOnParentsAccount() {
        Account accChild = [select id from Account where ParentId != null and Name = 'TestChild'];
        Platform_Performance__c platPer = new Platform_Performance__c();

        List<Account> lstAccParent = new List<Account>();
        lstAccParent = [select id, Account_Status__c from Account where Account_Status__c = 'Online'];
        system.assertEquals(lstAccParent.size(),0);

        platPer.Account__c = accChild.id;
        platPer.Backend_ID__c = '';

        insert platPer;

        test.startTest();
        platPer.Backend_ID__c = '1234';
           update platPer;
        test.stopTest();

        lstAccParent = [select id,Name, Account_Status__c from Account where Account_Status__c = 'Online'];
        System.debug('lstAccParent-->'+lstAccParent);
        system.assertEquals(lstAccParent.size(),4);



    }
}