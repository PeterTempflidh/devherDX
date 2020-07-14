/**
 * Created by g.singh on 18/05/2020.
 */

@IsTest
private class WelcomeEmailHandler_Test {
    
    @testSetup
    static void testSetup(){
        UnitTestDataFactory.getRecordtypeValues();
    }

    @isTest
    Static Void testSendWelcomeEmail(){
        //CREATE COUNTRY
        Country__c czCountry = UnitTestDataFactory.createCountry('CZ', 'Czech Republic', 'CZK');
        insert new List<Country__c>{czCountry};
        
        //CREATE COMPANY
        Company__c czCompany = UnitTestDataFactory.createCompany('Damejidlo', 'CZ', czCountry);
        insert czCompany;

        //CREATE BUSINESS CONFIG
        List<Business_Config__c> bConfigList = new List<Business_Config__c>();
        bConfigList.add(
            UnitTestDataFactory.createBusinessConfig('QuoteWelcomeEmail', 'Process','EmailTemplate','CZ_Welcome_Email', czCountry.id, 'CZ_Opportunity_Quote', true, true)
        );
        bConfigList.add(
            UnitTestDataFactory.createBusinessConfig('QuoteWelcomeEmail', 'Process','QuoteStatus','Signed', czCountry.id, 'CZ_Opportunity_Quote', true, false)
        );
        bConfigList.add(
            UnitTestDataFactory.createBusinessConfig('QuoteWelcomeEmail', 'Process','businessTypes','Upgrade/Upsell', czCountry.id, 'CZ_Opportunity_Quote', true, false)
        );
        insert bConfigList;

        //CREATE ACCOUNT
        List<Account> accountList = new List<Account>();
        for(Integer counter = 0; counter < 5; counter++){
            Account czAccount = UnitTestDataFactory.createAccount('Test CZ Account ' + (counter + 1), czCountry, 'CZ_Account');
            czAccount.Type = 'Branch - main';

            accountList.add(czAccount);
        }
        insert accountList;

        //CREATE CONTACT
        List<Contact> czContactList = UnitTestDataFactory.createContacts(accountList, 'CZ Contact', 'Test', '', 'Owner', 1, 'testCZContact', 'CZ_Contact');
        insert czContactList;

        //CREATE OPPORTUNITY
        List<Opportunity> opportunityList = new List<Opportunity>();
        for(Account czAccount : accountList){
            Opportunity czOpportunity = UnitTestDataFactory.createOpportunity(czAccount.Name, czAccount, 'CZ_Opportunity', Date.today());
            czOpportunity.Business_Type__c = 'Upgrade/Upsell';
            czOpportunity.Type = 'Contract & Product';
            czOpportunity.StageName = 'New';

            opportunityList.add(czOpportunity);
        }
        
        insert opportunityList;

        //CREATE OPPORTUNITY QUOTE
        List<Opportunity_Quote__c> opportunityQuoteList = new List<Opportunity_Quote__c>();        
        for(Opportunity opp : opportunityList){
            Opportunity_Quote__c oppQuote = UnitTestDataFactory.createOpportunityQuotes(opp, 1, 'CZ_Opportunity_Quote', 'Approved','test opp Quote',10, 10, null,null,0)[0];
            opportunityQuoteList.add(oppQuote);
        }
        insert opportunityQuoteList;

        Test.startTest();
            for(Opportunity_Quote__c oppQuote : opportunityQuoteList){
                oppQuote.Status__c = 'Signed';
            }

            try{
                update opportunityQuoteList;
            } catch(Exception exc){
                system.assert(false, exc.getMessage() + ' >>> ' + exc.getStackTraceString());
            }
            
        Test.stopTest();
    }

    @IsTest
    private static void testSendWelcomeEmailOppTypes(){
        UnitTestDataFactory.getRecordtypeValues();
        //CREATE COUNTRY
        Country__c hkCountry = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'EUR');
        insert new List<Country__c>{hkCountry};

        //CREATE COMPANY
        Company__c czCompany = UnitTestDataFactory.createCompany('Foodpanda', 'FP', hkCountry);
        insert czCompany;

        //CREATE BUSINESS CONFIG
        List<Business_Config__c> bConfigList = new List<Business_Config__c>();
        bConfigList.add(
                UnitTestDataFactory.createBusinessConfig('QuoteWelcomeEmail', 'Process','EmailTemplate','FP_Welcome_Email', hkCountry.Id, 'FP_Opportunity_Quote', true, true)
        );
        bConfigList.add(
                UnitTestDataFactory.createBusinessConfig('QuoteWelcomeEmail', 'Process','QuoteStatus','Signed', hkCountry.Id, 'FP_Opportunity_Quote', true, false)
        );
        bConfigList.add(
                UnitTestDataFactory.createBusinessConfig('QuoteWelcomeEmail', 'Process','businessTypes','Upgrade/Upsell', hkCountry.Id, 'FP_Opportunity_Quote', true, false)
        );
        bConfigList.add(
                UnitTestDataFactory.createBusinessConfig('QuoteWelcomeEmail', 'Process','opportunityTypes','Contract Only', hkCountry.id, 'FP_Opportunity_Quote', true, false)
        );
        insert bConfigList;

        //CREATE ACCOUNT
        List<Account> accountList = new List<Account>();
        for(Integer counter = 0; counter < 5; counter++){
            Account fpAccount = UnitTestDataFactory.createAccount('Test FP Account ' + (counter + 1), hkCountry, 'FP_Account');
            fpAccount.Type = 'Branch - main';

            accountList.add(fpAccount);
        }
        insert accountList;

        //CREATE CONTACT
        List<Contact> fpContactList = UnitTestDataFactory.createContacts(accountList, 'FP Contact', 'Test', '', 'Owner', 1, 'testFPContact', 'FP_Contact');
        insert fpContactList;

        //CREATE OPPORTUNITY
        List<Opportunity> opportunityList = new List<Opportunity>();
        for(Account fpAccount : accountList){
            Opportunity fpOpportunity = UnitTestDataFactory.createOpportunity(fpAccount.Name, fpAccount, 'FP_Opportunity', Date.today());
            fpOpportunity.Business_Type__c = 'Upgrade/Upsell';
            fpOpportunity.Type = 'Contract & Product';
            fpOpportunity.StageName = 'New';

            opportunityList.add(fpOpportunity);
        }
        opportunityList.get(0).Type = 'Contract Only';
        insert opportunityList;

        //CREATE OPPORTUNITY QUOTE
        List<Opportunity_Quote__c> opportunityQuoteList = new List<Opportunity_Quote__c>();
        for(Opportunity opp : opportunityList){
            Opportunity_Quote__c oppQuote = UnitTestDataFactory.createOpportunityQuotes(opp, 1, 'FP_Opportunity_Quote', 'Approved','test opp Quote',10, 10, null,null,0)[0];
            opportunityQuoteList.add(oppQuote);
        }
        insert opportunityQuoteList;

        Test.startTest();
        for(Opportunity_Quote__c oppQuote : opportunityQuoteList){
            oppQuote.Status__c = 'Signed';
        }

        try{
            update opportunityQuoteList;
        } catch(Exception exc){
            System.assert(false, exc.getMessage() + ' >>> ' + exc.getStackTraceString());
        }

        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(1, invocations, 'An email should be sent');
    }
}