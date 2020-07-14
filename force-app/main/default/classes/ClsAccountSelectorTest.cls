/**
 * @description [Test class for ClsAccountSelector]
 * Created by Abhinav.Bhatia on 22/06/2020.
 */

@IsTest
private class ClsAccountSelectorTest {

    @TestSetup static  void setup(){

        UnitTestDataFactory.getRecordtypeValues();
        User testUser = UnitTestDataFactory.createUser('Talabat Sales Team', 'talabattestuser@talabat.com', 'Talabat', 'AE');
        insert testUser;


        System.runAs(testUser) {
            Country__c country = UnitTestDataFactory.createCountry('AE', 'United Arab Emirates', 'AED');
            insert country;
            List<Account> accounts = UnitTestDataFactory.createAccounts(1, country, Constants.ACCOUNT_RT_TALABAT_ACCOUNT);
            insert accounts;

            Platform_Performance__c platformObj = new Platform_Performance__c();
            platformObj.Account__c = accounts[0].Id;
            platformObj.Backend_ID__c = '1234';
            platformObj.Name = '1234';
            insert platformObj;
        }
    }

    /**
    * @date     : [22/06/2020]
    * @method name  : testGetAccountBySet
    * @description  : Test method of the findAccountsByGrid, getSharedMenuAccountsWOBackendIdFromIds and findAccountById
    */
    @IsTest
    static void testGetAccountBySet() {
        List<Account> accountDetails  = ClsAccountSelector.getAccountRecord();
        List<Account> accountByGrid = new List<Account>();
        List<Account> accountBySharedMenu = new List<Account>();
        Account accountById = new Account();

        if(!accountDetails.isEmpty()) {
            Test.startTest();
            accountByGrid = ClsAccountSelector.findAccountsByGrid(new Set<String>{accountDetails[0].GRID__c});
            accountBySharedMenu = ClsAccountSelector.getSharedMenuAccountsWOBackendIdFromIds(new Set<Id>{accountDetails[0].Id});
            accountById = ClsAccountSelector.findAccountById(accountDetails[0].Id);
            Test.stopTest();
        }
        System.assert(!accountByGrid.isEmpty());
        System.assert(null != accountById);
    }

    /**
    * @date     : [22/06/2020]
    * @method name  : testAccountByParent
    * @description  : Test method of the getAccountParentsTypes,getAccountByOppty and getAccountIdREstaurantAddressMap
    */
    @IsTest
    static void testAccountByParent() {
        List<Account> accountDetails  = ClsAccountSelector.getAccountRecord();
        Account accountParentType = new Account();
        List<Account> accountByOpty = new List<Account>();
        List<Account> accountByServiceType = new List<Account>();

        if(!accountDetails.isEmpty()) {
            Test.startTest();
            accountParentType = ClsAccountSelector.getAccountParentsTypes(accountDetails[0].Id);
            accountByOpty = ClsAccountSelector.getAccountByOppty(new Set<Id>{accountDetails[0].Id});
            accountByServiceType = ClsAccountSelector.findByIdsAndContractServiceType(new Set<Id>{accountDetails[0].Id}, new Set<String>{Constants.CONTRACT_SERVICE_COMMISSION_FEE});
            Test.stopTest();
        }
        System.assert(null != accountParentType);
        System.assert(!accountByOpty.isEmpty());
    }

    /**
    * @date     : [22/06/2020]
    * @method name  : testStallGroupAccount
    * @description  : Test method of the getStallsByFacilityIds and getGroupAccounts
    */
    @IsTest
    static void testStallGroupAccount() {
        List<Account> accountDetails  = ClsAccountSelector.getAccountRecord();
        List<Account> accountByStallsFacility = new List<Account>();

        if(!accountDetails.isEmpty()) {
            Test.startTest();
            accountByStallsFacility = ClsAccountSelector.getStallsByFacilityIds(new Set<Id>{accountDetails[0].Id});
            Test.stopTest();
        }
        System.assert(!accountByStallsFacility.isEmpty());
    }
}