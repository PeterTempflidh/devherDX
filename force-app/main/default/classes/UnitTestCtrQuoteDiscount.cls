@isTest
private with sharing class UnitTestCtrQuoteDiscount {

    private static User testUser;
    private static User testManager;
    private static Country__c country;
    private static Company__c company;
    private static List<Account> accounts;
    private static List<Opportunity> opportunities;
    private static List<Opportunity_Quote__c> quotes;
    private static EmailTemplate templateApprovalDiscount;

    static {
        UnitTestDataFactory.getRecordtypeValues();
        testManager = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'yogiyo_manager@deliveryhero.com', 'Yogiyo', 'KR');
        testManager.FirstName = 'Tom';
        testManager.LastName = 'Ted';
        insert testManager;
        testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'yogiyouser@deliveryhero.com', 'Yogiyo', 'KR');
        testUser.ManagerId = testManager.Id;
        insert testUser;
        UnitTestDataFactory.getRecordtypeValues();
        System.runAs(testUser){
            country = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            insert country;

            accounts = UnitTestDataFactory.createAccounts(1, country, 'Yogiyo_Account');
            
            insert accounts;

            opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'Yogiyo_Opportunity', Date.today().addMonths(2));
            insert opportunities;

            quotes = UnitTestDataFactory.createOpportunityQuotes(opportunities[0], 1, 'Yogiyo_Opportunity_Quote', 'draft', 'TEST', 100, 100, 'Test', 'Test', 10);
            insert quotes;

            templateApprovalDiscount = UnitTestDataFactory.createEmailTemplate('Quote_Approved_Discount', 'Quote Approval Template', 'Quote_Approved_Discount', true, 'Quote Approval Template', 'Text', testUser.Id);
            insert templateApprovalDiscount;

        }
    }

    @isTest static void testCreateApprovalProcess(){
        Test.startTest();
        System.runAs(testUser){
            ClsQuoteProcessor cqp = new ClsQuoteProcessor();
            cqp.submitQuoteForApproval(quotes[0].Id);
            Id approvalProcessId = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: quotes[0].Id].Id;
            System.assertNotEquals(approvalProcessId, null);
        }
        Test.stopTest();
    }

    @isTest static void testEmailTemplateCtr(){
        Test.startTest();
        CtrQuoteDiscount cqd;
        Id workItemId;
        Id approvalProcessId;
        String absoluteUrl;
        System.runAs(testUser){
            ClsQuoteProcessor cqp = new ClsQuoteProcessor();
            cqp.submitQuoteForApproval(quotes[0].Id);
            approvalProcessId = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: quotes[0].Id].Id;
            cqd = new CtrQuoteDiscount();
            cqd.targetObjectId = quotes[0].Id;
            workItemId = cqd.getWorkItemId();
            absoluteUrl = cqd.getDiscountUrl();
        }
        System.assertEquals(cqd.quoteName, null);
        System.assertEquals(cqd.opportunityName, null);
        System.assertEquals(cqd.accountName, null);
        System.assertEquals(cqd.salutation, 'Tom Ted');
        System.assertEquals(approvalProcessId, workItemId);
        System.assertNotEquals(absoluteUrl.indexOf(workItemId), -1);
        Test.stopTest();
    }
}