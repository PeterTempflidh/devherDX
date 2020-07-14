/**
* @author Mantas Jurkunas
* @date 14.04.2020
*
* @description Test class containing test methods related to closing opportunities with failed onboarding
*/
@IsTest
private class CloseOpportunities_Test {

    @TestSetup
    private static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
        Logging__c logConfig =new Logging__c(SetupOwnerId=UserInfo.getUserId());
        logConfig.DISABLE_LOGGING__c = false;
        insert logConfig;

        Country__c country = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'GBP');
        insert country;

        Business_Config__c businessConfig0 = UnitTestDataFactory.createBusinessConfig('OpportunityAutoClose', 'Process', 'OnboardingFailedCaseLimit', '3', country.Id, 'FP_Opportunity', true, true);
        Business_Config__c businessConfig1 = UnitTestDataFactory.createBusinessConfig('OpportunityAutoClose', 'Process', 'FailedOpportunitiesFollowupLimit', '7', country.Id, 'FP_Opportunity', true, false);

        insert new List<Business_Config__c> {businessConfig0, businessConfig1};

        Company__c com = UnitTestDataFactory.createCompany('FoodPanda', 'FP', country);
        insert com;

        Account acc = UnitTestDataFactory.createAccount('Test Account#1',country,'FP_Account');
        Account acc2 = UnitTestDataFactory.createAccount('Test Account#2',country,'FP_Account');
        insert new List<Account> {acc, acc2};

        Opportunity opp = UnitTestDataFactory.createOpportunity('Test #1',acc,'FP_Opportunity', Date.today().addDays(20));
        opp.Company_Code__c = 'FP';
        opp.Business_Type__c = 'New Business';
        opp.StageName = 'New';

        Opportunity opp2 = UnitTestDataFactory.createOpportunity('Test #2',acc2,'FP_Opportunity', Date.today().addDays(20));
        opp2.Company_Code__c = 'FP';
        opp2.Business_Type__c = 'New Business';
        opp2.StageName = 'Onboarding';
        insert new List<Opportunity> {opp, opp2};
        opp.StageName = 'Onboarding Failed';
        update opp;

        Case onboardingCase0 = UnitTestDataFactory.createCase(acc2, 'Closed', 'Onboarding', '', '', country, 'FP_Entry_Case', '');
        Case onboardingCase1 = UnitTestDataFactory.createCase(acc2, 'Closed', 'Onboarding', '', '', country, 'FP_Entry_Case', '');
        Case onboardingCase2 = UnitTestDataFactory.createCase(acc2, 'New', 'Onboarding', '', '', country, 'FP_Entry_Case', '');
        onboardingCase0.Opportunity__c = opp2.Id;
        onboardingCase1.Opportunity__c = opp2.Id;
        onboardingCase2.Opportunity__c = opp2.Id;
        onboardingCase0.Closed_Reason__c = CaseSelector.CR_NOT_SUCCESSFUL;
        onboardingCase1.Closed_Reason__c = CaseSelector.CR_NOT_SUCCESSFUL;
        onboardingCase0.Root_Cause__c = 'Duplicated';
        onboardingCase1.Root_Cause__c = 'Duplicated';

        insert new List<Case> {onboardingCase0, onboardingCase1, onboardingCase2};
    }

    @IsTest
    private static void testTripleOnboardingCaseFailure() {
        List<Case> onboardingCases = CaseSelector.getAll();
        Opportunity opp = Opportunity_Selector.getOpportunityById(onboardingCases.get(0).Opportunity__c);
        System.assertNotEquals('Closed Lost', opp.StageName);
        System.assertNotEquals('Onboarding Failed', opp.Lost_Reason__c);
        for (Case cs: onboardingCases) {
            if (cs.Status.equals('Closed')) {
                continue;
            }
            cs.Status = 'Closed';
            cs.Closed_Reason__c = CaseSelector.CR_NOT_SUCCESSFUL;
            cs.Root_Cause__c = 'Duplicated';
        }
        update onboardingCases;
        opp = Opportunity_Selector.getOpportunityById(onboardingCases.get(0).Opportunity__c);
        System.assertEquals('Closed Lost', opp.StageName);
        System.assertEquals('Onboarding Failed', opp.Lost_Reason__c);
    }

    @IsTest
    private static void testOnboardingFailedOpportunities() {
        List<Opportunity> opportunities = Opportunity_Selector.getAll();
        Opportunity onboardingOpportunity;
        for (Opportunity opp: opportunities) {
            if (opp.StageName.equals('Onboarding Failed')) {
                onboardingOpportunity = opp;
                break;
            }
        }
        System.assertNotEquals(null, onboardingOpportunity);
        Test.startTest();
            Database.executeBatch(new CloseOpportunities_Batch());
        Test.stopTest();

        onboardingOpportunity = Opportunity_Selector.getOpportunityById(onboardingOpportunity.Id);
        System.assertEquals('Closed Lost', onboardingOpportunity.StageName);
        System.assertEquals('Onboarding Failed', onboardingOpportunity.Lost_Reason__c);
    }

    @IsTest
    private static void testTripleOnboardingCaseFailureNoBC() {
        delete [SELECT Id FROM Business_Config__c];
        List<Case> onboardingCases = CaseSelector.getAll();
        Opportunity opp = Opportunity_Selector.getOpportunityById(onboardingCases.get(0).Opportunity__c);
        System.assertNotEquals('Closed Lost', opp.StageName);
        System.assertNotEquals('Onboarding Failed', opp.Lost_Reason__c);
        for (Case cs: onboardingCases) {
            if (cs.Status.equals('Closed')) {
                continue;
            }
            cs.Status = 'Closed';
            cs.Closed_Reason__c = CaseSelector.CR_NOT_SUCCESSFUL;
            cs.Root_Cause__c = 'Duplicated';
        }
        update onboardingCases;
        opp = Opportunity_Selector.getOpportunityById(onboardingCases.get(0).Opportunity__c);
        System.assertNotEquals('Closed Lost', opp.StageName);
        System.assertNotEquals('Onboarding Failed', opp.Lost_Reason__c);
    }

    @IsTest
    private static void testOnboardingFailedOpportunitiesNoBC() {
        delete [SELECT Id FROM Business_Config__c];
        List<Opportunity> opportunities = Opportunity_Selector.getAll();
        Opportunity onboardingOpportunity;
        for (Opportunity opp: opportunities) {
            if (opp.StageName.equals('Onboarding Failed')) {
                onboardingOpportunity = opp;
                break;
            }
        }
        System.assertNotEquals(null, onboardingOpportunity);
        Test.startTest();
        Database.executeBatch(new CloseOpportunities_Batch());
        Test.stopTest();

        onboardingOpportunity = Opportunity_Selector.getOpportunityById(onboardingOpportunity.Id);
        System.assertNotEquals('Closed Lost', onboardingOpportunity.StageName);
        System.assertNotEquals('Onboarding Failed', onboardingOpportunity.Lost_Reason__c);
        //Coverage-only execution. The functionality is tested in other method
        CloseOpportunities_Batch.schedule(CloseOpportunities_Batch.CRON_DAILY);
    }
}