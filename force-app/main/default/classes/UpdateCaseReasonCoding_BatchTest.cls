/**
 * Created by c.kumari on 12.03.2019.
 */

@IsTest
public class UpdateCaseReasonCoding_BatchTest {

    @testSetup
    public static void setupData(){
        UnitTestDataFactory.getRecordtypeValues();

        Country__c c = UnitTestDataFactory.createCountry('DE','Germany', 'EUR');
        insert c;
        Account acc = UnitTestDataFactory.createAccount('UpdateCaseReasonCoding_Batch',c,'DE_Account');
        insert acc;

        List<UpdateCaseReasonsCodeMapping__c> crMap=new List<UpdateCaseReasonsCodeMapping__c>();
        UpdateCaseReasonsCodeMapping__c crMap1 = new UpdateCaseReasonsCodeMapping__c();
        crMap1.Name='CaseReason1';
        crMap1.CaseReasonLevelOld1__c='Across Journey';
        crMap1.CaseReasonLevelOld2__c='Technical Issue';
        crMap1.CaseReasonLevelOld3__c='Website issue';
        crMap1.CaseReasonLevelNew1__c='Across Journey';
        crMap1.CaseReasonLevelNew2__c='Technical Issue';
        crMap1.CaseReasonLevelNew3__c='Website issue';
        crMap1.Type__c='Customer';
        crMap.add(crMap1);
        UpdateCaseReasonsCodeMapping__c crMap2 = new UpdateCaseReasonsCodeMapping__c();
        crMap2.Name='CaseReason2';
        crMap2.CaseReasonLevelOld2__c='Technical Issue';
        crMap2.CaseReasonLevelOld3__c='Website issue';
        crMap2.CaseReasonLevelNew2__c='Technical Issue';
        crMap2.CaseReasonLevelNew3__c='Website issue';
        crMap.add(crMap2);
        UpdateCaseReasonsCodeMapping__c crMap3 = new UpdateCaseReasonsCodeMapping__c();
        crMap3.Name='CaseReason3';
        crMap3.CaseReasonLevelOld3__c='Website issue';
        crMap3.CaseReasonLevelNew3__c='Website issue';
        crMap.add(crMap3);
        UpdateCaseReasonsCodeMapping__c crMap4 = new UpdateCaseReasonsCodeMapping__c();
        crMap4.Name='CaseReason4';
        crMap4.CaseReasonLevelOld1__c='Across Journey';
        crMap4.CaseReasonLevelOld2__c='Technical Issue';
        crMap4.CaseReasonLevelNew1__c='Across Journey';
        crMap4.CaseReasonLevelNew2__c='Technical Issue';
        crMap4.Type__c='Customer';
        crMap.add(crMap4);
        UpdateCaseReasonsCodeMapping__c crMap5 = new UpdateCaseReasonsCodeMapping__c();
        crMap5.Name='CaseReason5';
        crMap5.CaseReasonLevelOld1__c='Across Journey';
        crMap5.CaseReasonLevelNew1__c='Across Journey';
        crMap.add(crMap5);
        UpdateCaseReasonsCodeMapping__c crMap6 = new UpdateCaseReasonsCodeMapping__c();
        crMap6.Name='CaseReason6';
        crMap6.CaseReasonLevelOld2__c='Technical Issue';
        crMap6.CaseReasonLevelNew2__c='Technical Issue';
        crMap.add(crMap6);
        insert crMap;

        List<Case> cases = new List<Case>();
        Case cs1 = UnitTestDataFactory.createCase(acc,'Resolved','Customer',null,'Chat',c,'DE_Inbound_Case','test');
        cs1.resolvedDate__c = Date.today().addDays(-20);
        cs1.order_number__c = '90123456789012';
        cs1.Case_Reason_Level_1__c = 'Across Journey';
        cs1.Case_Reason_Level_2__c = 'Technical Issue';
        cs1.Case_Reason_Level_3__c = 'Website issue';
        cs1.customer_email__c = 'test@test.com';
        cs1.Platform__c = 'LieferheldDE';
        cs1.Description = 'test';
        cs1.Status = 'Closed';
        cs1.Closed_Reason__c = 'Successful';
        cases.add(cs1);
        Case cs2 = UnitTestDataFactory.createCase(acc,'Resolved','Customer',null,'Chat',c,'DE_Inbound_Case','test');
        cs2.resolvedDate__c = Date.today().addDays(-2);
        cs2.order_number__c = '90123456789012';
        cs2.Case_Reason_Level_1__c = 'Across Journey';
        cs2.Case_Reason_Level_2__c = 'Technical Issue';
        cs2.customer_email__c = 'test@test.com';
        cs2.Platform__c = 'LieferheldDE';
        cs2.Description = 'test';
        cs2.Status = 'Closed';
        cs2.Closed_Reason__c = 'Successful';
        cases.add(cs2);

        Case cs3 = UnitTestDataFactory.createCase(acc,'Resolved','Customer',null,'Chat',c,'DE_Inbound_Case','test');
        cs3.resolvedDate__c = Date.today().addDays(-2);
        cs3.order_number__c = '90123456789012';
        cs3.Case_Reason_Level_1__c = 'Across Journey';
        cs3.customer_email__c = 'test@test.com';
        cs3.Platform__c = 'LieferheldDE';
        cs3.Description = 'test';
        cs3.Status = 'Closed';
        cs3.Closed_Reason__c = 'Successful';
        cases.add(cs3);
        insert cases;

        //update new List<Case>{cs1};

        // create configs
        Business_Config__c config = UnitTestDataFactory.createBusinessConfig('BatchUpdateCaseResonCoding', 'Process', 'recordTypes', 'DE_Inbound_Case,Talabat_Inbound_Case', null, 'Global_Config', true, true);
        Business_Config__c config1 = UnitTestDataFactory.createBusinessConfig('BatchUpdateCaseResonCoding', 'Process', 'closedDateRange', '-30', null, 'Global_Config', true, false);
        insert new List<sObject>{config,config1};
    }

    @isTest
    public static void testUpdateCaseReasonCoding(){
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        datetime d=datetime.newInstance(2019,1,1);
        Test.startTest();
        UpdateCaseReasonCoding_Batch batch = new UpdateCaseReasonCoding_Batch('IsClosed = true');
        Id batchjobId = Database.executebatch(batch);
        Test.stopTest();
        List<Case> cases = [Select Id from Case where IsCaseReasonUpdated__c = true];
        system.assertEquals(3,cases.size());
    }

}