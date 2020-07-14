/**
 * Created by danish.farooq on 6/29/20.
 * @description  test class for ClsCaseSelector
 */

@IsTest
private class ClsCaseSelector_Test {


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

        Case caseObj = UnitTestDataFactory.createCase(new Account(Id = fpAccount[0].Id),Constants.CASE_STATUS_NEW,
                Constants.CASE_TYPE_MENU_PROCESSING,
                '', '',testCountryMY,
                Constants.FP_ENTRY_CASE_DEVELOPERNAME,
                Constants.CASE_TYPE_MENU_PROCESSING);
        caseObj.Closed_Reason__c = Constants.CASE_CLOSED_REASON_TAKE_ONLINE;
        caseObj.Opportunity__c = fpOpportunity[0].ID;
        caseobj.Menu_URL__c = 'test';
        insert caseObj;
    }

    @IsTest
    static void testCaseSelector() {

        test.startTest();

        List<Case> lstCaseType = clsCaseselector.getApprovalProcessDefinition(Constants.CASE_TYPE_MENU_PROCESSING);
        Set<Id> setOpptyId = new Set<Id>();
        system.assertEquals(lstCaseType.size(), 1);
        lstCaseType = clsCaseselector.getAll();
        system.assertEquals(lstCaseType.size(), 1);
        setOpptyId.add(lstCaseType[0].Opportunity__c );
        lstCaseType = clsCaseselector.getCaseInOpportunitiesOrderASC(setOpptyId);
        system.assertEquals(lstCaseType.size(), 1);
        lstCaseType = clsCaseselector.findCasesByOpportunity(setOpptyId);
        system.assertEquals(lstCaseType.size(), 1);
        Set<Id>  caseSet = clsCaseselector.findOpenCaseByOpportunity( setOpptyId ,Constants.CASE_TYPE_MENU_PROCESSING);
        system.assertEquals(caseSet.size(), 1);
        test.stopTest();

    }
}