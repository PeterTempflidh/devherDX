@isTest
public class UnitTestClsGetBackendIdAccount {
    static List<Account> accounts, tbAcc;
    static {
        UnitTestDataFactory.getRecordtypeValues();

        Integration_Config__c cs1 = new Integration_Config__c(
            Name = 'GoogleMapsSignature', Password__c = 'Abvcd-asdfdgfhjklhnO0=');
        insert cs1;

        Country__c testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        insert testCountry;

        Company__c testCompany = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', testCountry);
        insert testCompany;
        accounts = UnitTestDataFactory.createAccounts(5, testCountry, 'Yogiyo_Account');
        accounts[0].Type = 'Client';
        accounts[1].Type = 'Franchise';
        accounts[2].Type = 'Branch';
        accounts[3].Type = 'Brand';
        accounts[4].Type = 'Group';
        insert accounts;

    }

    @isTest static void testCallout_Company() {
        String res =  ClsGetBackendIdAccount.getBackendIdAccount(accounts[0].Id, 'Client');
        String res1 = ClsGetBackendIdAccount.getBackendIdAccount(accounts[1].Id, 'Franchise');
        String res2 = ClsGetBackendIdAccount.getBackendIdAccount(accounts[0].Id, 'Branch');
        String res3 = ClsGetBackendIdAccount.getBackendIdAccount(accounts[3].Id, 'Brand');

    }



}