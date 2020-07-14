/**
 * Created by t.jain on 2019-05-13.
 */

@IsTest
private class UpdateCaseChatRelationshipBatch_Test {
    @testSetup
    static void setupTestData(){
        LiveChatVisitor visitor=new LiveChatVisitor();
        insert visitor;
        LiveChatTranscript chat = new LiveChatTranscript(
                Platform__c = 'Talabat',
                Order_Number__c = '1234567890001',
                Email__c = 'test@deliveryhero.com',
                User_Name__c = 'test name',
                My_Problem__c = 'Order',
                Body='Hello',
                LiveChatVisitorId=visitor.id,
                ownerId=userinfo.getUserId()
        );

        insert chat;
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
        cs1.Status = 'In Progress';
        cs1.Closed_Reason__c = 'Successful';
        cs1.Live_Chat_Transcript_Id__c=chat.Id;
        insert cs1;
    }
    @IsTest
    static void executeBatch() {
        Test.startTest();
        UpdateCaseChatRelationship_Batch batch = new UpdateCaseChatRelationship_Batch('');
        Id batchjobId = Database.executebatch(batch);
        Test.stopTest();
        List<Case> cases = [Select Id,Live_Chat_Transcript_Id__c from Case where Live_Chat_Transcript_Id__c != null];
        system.debug(cases);
        system.assertEquals(0,cases.size());
    }
}