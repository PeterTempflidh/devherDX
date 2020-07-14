/**
 * Created by danish.farooq on 6/25/20.
 * @description Test class for Add_On_Service_Selector
 */

@IsTest
private class Add_On_Service_SelectorTest {
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
        List<List_Service_Price__c> fpServices = UnitTestDataFactory.createServices(testCompanyMY, testCountryMY, 10, Constants.FP_LIST_SERVICE_PRICE_DEVELOPERNAME, 13, 13, 15, 10, 1, '% per Order', true, 299, 'Monthly', 'Commission', 'ServiceType');
        List<Contact> fpContact = UnitTestDataFactory.createContacts(fpAccount, 'testContact', 'firstname', null, 'owner', 1, 'testCt', Constants.FP_CONTACT_DEVELOPERNAME);
        List<Opportunity> fpOpportunity = UnitTestDataFactory.createOpportunities(fpAccount, 1, Constants.FP_OPPORTUNITY_DEVELOPERNAME, Date.today().addMonths(2));
        insert fpOpportunity;
        Opportunity_Line_Item__c fpoppServiceItem = UnitTestDataFactory.createOpportunityLineItemService('commission Fee',fpOpportunity[0], fpServices[0].Id, false, Constants.FP_OPPORTUNITY_LINE_ITEM_DEVELOPERNAME, 13, null, Date.today(), 'Commission Fee', null);
        insert fpoppServiceItem;
        List<Opportunity_Quote__c> fpOpportunityQuote = UnitTestDataFactory.createOpportunityQuotes(fpOpportunity[0], 1, Constants.FP_OPPORTUNITY_QUOTE_DEVELOPERNAME, 'Accepted','testdata',10, 10, null,null,0);
        insert fpOpportunityQuote;
        insert UnitTestDataFactory.createOpportunityQuoteLineItem(fpOpportunityQuote[0],fpoppServiceItem,Constants.FP_OPPORTUNITY_QUOTE_LINE_ITEM_DEVELOPERNAME);
        List<List_Add_On__c> fpAddOns   = UnitTestDataFactory.createAddOns(testCountryMY.id,testCompanyMY.id,'Test Add On','Deals','test',
                Constants.FP_LIST_ADD_ON_DEVELOPERNAME,10);

        List<Stock_Item__c> stockItems = UnitTestDataFactory.createStockItems(2, 'FP_Stock_Item', fpAccount[0], null, 'A1 - New used', Date.today(), Date.today().addDays(10), Date.today().addDays(-30), '1234567890', '1234567890', 'Korea Telekom', 'In Stock', 'Other');
        insert stockItems;


        List<Add_on_service__c> lstAddOnServices = new List<Add_on_Service__c>();
        Add_on_service__C addTest1 = new Add_on_Service__c();
        addTest1.Account_Name__c = fpAccount[0].Id;
        addTest1.Opportunity__c  = fpOpportunity[0].Id;
        addTest1.Status__c  = Constants.ADD_ON_SERVICE_STATUS_ACTIVE;
        addTest1.recordtypeid=UnitTestDataFactory.mapRecordtypes.get(Constants.FP_ADD_ON_DEVELOPERNAME).id;
        addTest1.Id_List_Add_On__c = fpAddOns[0].Id;
        lstAddOnServices.add(addTest1);
        insert lstAddOnServices;

    }

    @IsTest
    static void testAddOnSelector() {

        test.startTest();
        Opportunity opptyObj = Opportunity_Selector.getAll()[0];
        List<Add_on_Service__c> lstAddOnServices = Add_On_Service_Selector.getAddOnServicesByOppty(new Set<Id>{ opptyObj.Id},new Set<string> { Constants.ADD_ON_SERVICE_STATUS_ACTIVE });
        system.assertEquals(1,lstAddOnServices.size());
        test.stopTest();
    }
}