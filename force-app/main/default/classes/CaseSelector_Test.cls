/**
 * Created by t.jain on 2019-04-09.
 */

@IsTest
private class CaseSelector_Test {
    @testSetup
    public static void setupData(){
        UnitTestDataFactory.getRecordtypeValues();
        Country__c c = UnitTestDataFactory.createCountry('DE','Germany', 'EUR');
        insert c;
        Account acc = UnitTestDataFactory.createAccount('CaseQueries',c,'DE_Account');
        insert acc;
        Case cs1 = UnitTestDataFactory.createCase(acc,'Resolved','Customer',null,'Chat',c,'DE_Inbound_Case','test');
        cs1.resolvedDate__c = Date.today().addDays(-20);
        cs1.order_number__c = '90123456789012';
        cs1.Case_Reason_Level_1__c = 'Across Journey';
        cs1.Case_Reason_Level_2__c = 'Customer Account';
        cs1.Case_Reason_Level_3__c = 'Account deletion';
        cs1.customer_email__c = 'test@test.com';
        cs1.Platform__c = 'LieferheldDE';
        cs1.Description = 'test';
        cs1.Status = 'Closed';
        cs1.Closed_Reason__c = 'Successful';
        insert cs1;
    }

    @IsTest
    static void testCaseSelectorStaticQuery() {
        Case c1=[SELECT Id FROM Case limit 1];
        Case c=CaseSelector.getCaseDetailsById(c1.Id);
        system.assertEquals(c1.id,c.id);
    }

    @IsTest
    static void testCaseSelectorDynamicQuery() {
        Case c1=[SELECT Id FROM Case limit 1];
        Case c=CaseSelector.getCaseWithDynamicFields('EmailTemplatePrepopulateCriteriaFields',c1.Id);
        system.assertEquals(c1.id,c.id);
    }

}