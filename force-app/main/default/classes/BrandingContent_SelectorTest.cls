/**
 * Created by danish.farooq on 6/25/20.
 * @description Test class for BrandingContent_Selector
 */

@isTest
public  class BrandingContent_SelectorTest {

    @testSetup
    static void setup() {

        UnitTestDataFactory.getRecordtypeValues();
        Country__c testCountryMY = UnitTestDataFactory.createCountry('MY', Constants.COUNTRY_NAME_MALAYSIA, 'MYR');
        insert testCountryMY;

        Company__c testCompanyMY = UnitTestDataFactory.createCompany('FoodPanda', 'FoodPanda', testCountryMY);
        insert testCompanyMY;

        List<Account> fpAccount = UnitTestDataFactory.createAccounts(2, testCountryMY, Constants.FP_ACCOUNT_DEVELOPERNAME);
        fpAccount[0].phone = '+6012345678';
        fpAccount[1].phone = '+6012345678';
        insert fpAccount;

        List<Opportunity> fpOpportunity = UnitTestDataFactory.createOpportunities(fpAccount, 1, Constants.FP_OPPORTUNITY_DEVELOPERNAME, Date.today().addMonths(2));
        insert fpOpportunity;

        Branding_Content__c bContent = new Branding_Content__c(Restaurant_Name__c = fpAccount[0].Id, Opportunity__c = fpOpportunity[0].Id);
        bContent.Status__c = Constants.BRANDINGCONTENT_STATUS_INSTALLED_SUCCESSFULLY;
        bContent.Type__c = Constants.BRANDINGCONTENT_TYPE_WHITE_LABEL_APP;
        insert bContent;

    }

    @IsTest
    static void testBrandingSelector() {

        test.startTest();
        Opportunity opptyObj = Opportunity_Selector.getAll()[0];
        List<Branding_Content__c> lstBrandingContents = BrandingContent_Selector.findByAccountIds(new Set<Id>{ opptyObj.AccountId});
        system.assertEquals(1,lstBrandingContents.size());

        lstBrandingContents = BrandingContent_Selector.getBrandingByOpptyId(new Set<Id>{ opptyObj.Id}, Constants.BRANDINGCONTENT_TYPE_WHITE_LABEL_APP, new Set<string> {Constants.BRANDINGCONTENT_STATUS_INSTALLED_SUCCESSFULLY });
        system.assertEquals(1,lstBrandingContents.size());
        test.stopTest();
    }
}