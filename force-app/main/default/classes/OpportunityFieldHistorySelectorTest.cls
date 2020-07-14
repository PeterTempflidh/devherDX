/**
* @author Mantas Jurkunas
* @date 25.06.2020
*
* @description Test class for OpportunityFieldHistory_Selector
*/
@IsTest
private class OpportunityFieldHistorySelectorTest {

    @TestSetup
    private static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c country = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'GBP');
        insert country;
        Company__c com = UnitTestDataFactory.createCompany('FoodPanda', 'FP', country);
        insert com;
        Account acc = UnitTestDataFactory.createAccount('Test Account#1',country,'FP_Account');
        insert acc;
        Opportunity opp = UnitTestDataFactory.createOpportunity('Test #1',acc,'FP_Opportunity', Date.today().addDays(20));
        opp.Company_Code__c = 'FP';
        opp.Business_Type__c = 'New Business';
        opp.StageName = 'New';
        insert opp;
    }
    /**
     * @description This test method does not have accurate testing capabilities due to the fact that field history cannot be inserted
     */
    @IsTest
    private static void testFieldHistorySelector() {
        Opportunity opportunity = Opportunity_Selector.getAll().get(0);
        List<OpportunityFieldHistory> opportunityFieldHistories = OpportunityFieldHistory_Selector.getByOpportunityIds(new Set<Id> {opportunity.Id});
        System.assert(opportunityFieldHistories.isEmpty());
    }
}