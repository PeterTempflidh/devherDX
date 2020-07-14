/***
 * @description test class for DummyAssetsCreation_Batch class
 * @date 19.05.2020
 * @author Danish Farooq
 */
@IsTest
private class DummyAssetsCreation_BatchTest {

    @testSetup
    static void setup(){

        UnitTestDataFactory.getRecordtypeValues();
        Country__c country = UnitTestDataFactory.createCountry('TH', 'Thailand', 'THB');
        insert country;

        Company__c company = UnitTestDataFactory.createCompany('FP', 'FP', country);
        insert company;

        List<Account> lstAccounts = UnitTestDataFactory.createAccounts(10, country, 'FP_Account');

        for(Account iAccount : lstAccounts){
            iAccount.phone = '+66123456789';
            iAccount.CurrencyIsoCode = 'THB';
            iAccount.Account_status__c = 'Active';
        }
        insert lstAccounts;
    }
    @IsTest
    static void testAssetRecord() {

        Test.startTest();
        Database.executeBatch(new DummyAssetsCreation_Batch('FP','Thailand','SIM'));
        Test.stopTest();

        List<Account> lstAccount = [SELECT ID FROM Account];
        Map<ID,Account> accountMap = new Map<ID,Account>(lstAccount);
        List<Asset__c> lstAssets = AssetSelector.findActiveByAccountIds(accountMap.keySet());
        system.assertEquals(lstAssets.size(),10);

    }
    @IsTest
    static void testFailAssetRecord() {

        Test.startTest();
        Database.executeBatch(new DummyAssetsCreation_Batch('FPP','Thailand','SIM'));
        Test.stopTest();

        List<Account> lstAccount = [SELECT ID FROM Account];
        Map<ID,Account> accountMap = new Map<ID,Account>(lstAccount);
        List<Asset__c> lstAssets = AssetSelector.findActiveByAccountIds(accountMap.keySet());
        system.assertNotEquals(lstAssets.size(),10);

    }
}