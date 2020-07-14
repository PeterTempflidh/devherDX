/**
* @author Mantas Jurkunas
* @date 13.11.2019
*
* @description Test class for the AccountCountryRemediation_Batch class
*/

@IsTest
private class AccountCountryRemediation_Test {

    @TestSetup
    static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
        Trigger_Manager__c manager = Trigger_Manager__c.getInstance();
        manager.Deactivate_Asset_Trigger__c = true;
        manager.Deactivate_Branding_Trigger__c = true;
        upsert manager;
        Country__c c = UnitTestDataFactory.createCountry('UY', 'Uruguay', 'KWD');
        Country__c c2 = UnitTestDataFactory.createCountry('CL', 'Chile', 'KWD');
        insert new List<Country__c> {c, c2};
        Company__c com = UnitTestDataFactory.createCompany('PY', 'PY', c );
        Company__c com2 = UnitTestDataFactory.createCompany('PY', 'PY', c2 );
        insert new List<Company__c>{com, com2};
        Account pyAccount  = UnitTestDataFactory.createAccount('TestAccount', c, 'PY_Account');
        pyAccount.Record_Country__c = 'Uruguay';
        insert pyAccount;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(new List<Account>{pyAccount}, 1, 'Yogiyo_Opportunity', Date.today());
        insert oppList;
        List<Stock_Item__c> stockItems = UnitTestDataFactory.createStockItems(4, 'Yogiyo_Stock_Item', pyAccount, null, 'A1 - New used', Date.today(), Date.today().addDays(10), Date.today().addDays(-30), '1234567890', '1234567890', 'Korea Telekom', 'In Stock', 'Other');
        insert stockItems;
        Branding_Content__c bContent = new Branding_Content__c(Restaurant_Name__c = pyAccount.Id, Opportunity__c = oppList[0].Id);
        insert bContent;
        List<Asset__c> assets = UnitTestDataFactory.createAssets(10, pyAccount, oppList[0], Date.today().addDays(-10), true, stockItems[0], stockItems[1], 'PY_Asset', '12345674',
                '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'Exchange Requested',
                Date.today().addDays(20), 'Yazi Logistics', '1234', 'none');
        insert assets;

    }


    @IsTest
    static void test_BrandingCountryUpdate() {
        Account pyAccount = AccountSelector.getAll()[0];
        Branding_Content__c bContent = BrandingContent_Selector.findByAccountIds(new Set<Id> {pyAccount.Id})[0];

        System.assertNotEquals(pyAccount.Record_Country__c, bContent.Account_Country__c);

        Test.startTest();
            AccountCountryRemediation_Batch.run(Branding_Content__c.class);
        Test.stopTest();

        bContent = BrandingContent_Selector.findByAccountIds(new Set<Id> {pyAccount.Id})[0];

        System.assertEquals(pyAccount.Record_Country__c, bContent.Account_Country__c);
    }

    @IsTest
    static void test_AssetCountryUpdate() {
        Account pyAccount = AccountSelector.getAll()[0];
        List<Asset__c> assets = AssetSelector.findActiveByAccountIds(new Set<Id> {pyAccount.Id});

        for (Asset__c asset: assets) {
            System.assertNotEquals(pyAccount.Record_Country__c, asset.Account_Country__c);
        }

        Test.startTest();
            AccountCountryRemediation_Batch.run(Asset__c.class);
        Test.stopTest();

        assets = AssetSelector.findActiveByAccountIds(new Set<Id> {pyAccount.Id});

        for (Asset__c asset: assets) {
            System.assertEquals(pyAccount.Record_Country__c, asset.Account_Country__c);
        }
    }
}