/**
 * Created by marco.zeuli on 14/2/2018.
 */

@IsTest
private class UnitTestctrDH_AU_QuoteVFTemplate {

    @TestSetup
    static void setup() {
        UnitTestDataFactory.getRecordtypeValues();

        Country__c ec = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
        insert ec;

        Account acc = UnitTestDataFactory.createAccount('test', ec, 'CD_Account');
        insert acc;

        Opportunity opp = UnitTestDataFactory.createOpportunity('test', acc, 'CD_Opportunity', Date.today());
        insert opp;

        Opportunity_Quote__c oppQuote = UnitTestDataFactory.createOpportunityQuotes(opp, 1, 'CD_Opportunity_Quote', 'New', 'whatever', 10.0, 10.0, 'test', 'test', 1.0)[0];
        insert oppQuote;
    }

    @IsTest
    static void testPremiumPlacementQuote() {
        Opportunity_Quote__c qt = [SELECT Id FROM Opportunity_Quote__c LIMIT 1];
        Opportunity opp = [SELECT Id, Id_Tarif__c FROM Opportunity LIMIT 1];

        Tarif__c t = new Tarif__c(Name = 'Premium Placement');
        insert t;

        t.Is_Active__c = true;
        update t;

        opp.Id_Tarif__c = t.Id;
        update opp;

        PageReference pref = Page.CD_QuoteVFTemplate;
        pref.getParameters().put('id', qt.Id);

        ctrDH_AU_QuoteVFTemplate ctr;

        Test.startTest();

        Test.setCurrentPage(pref);

        ctr = new ctrDH_AU_QuoteVFTemplate();

        Test.stopTest();

        System.assert(ctr.premiumPlacement);
        System.assert(!ctr.ukQuote);
    }

    @IsTest
    static void testAdditionalContractQuote() {
        Opportunity_Quote__c qt = [SELECT Id FROM Opportunity_Quote__c LIMIT 1];
        Opportunity opp = [SELECT Id, Id_Tarif__c, Type FROM Opportunity LIMIT 1];

        Tarif__c t = new Tarif__c(Name = 'whatever');
        insert t;

        t.Is_Active__c = true;
        update t;

        opp.Id_Tarif__c = t.Id;
        opp.Type = 'Additional Contract';
        update opp;

        PageReference pref = Page.CD_QuoteVFTemplate;
        pref.getParameters().put('id', qt.Id);

        ctrDH_AU_QuoteVFTemplate ctr;

        Test.startTest();

        Test.setCurrentPage(pref);

        ctr = new ctrDH_AU_QuoteVFTemplate();

        Test.stopTest();

        System.assert(ctr.addContract);
        System.assert(!ctr.ukQuote);
    }

    @IsTest
    static void testMenuPrintingQuote() {
        Opportunity_Quote__c qt = [SELECT Id FROM Opportunity_Quote__c LIMIT 1];
        Opportunity opp = [SELECT Id, Id_Tarif__c FROM Opportunity LIMIT 1];

        Tarif__c t = new Tarif__c(Name = 'Menu Printing');
        insert t;

        t.Is_Active__c = true;
        update t;

        opp.Id_Tarif__c = t.Id;
        update opp;

        PageReference pref = Page.CD_QuoteVFTemplate;
        pref.getParameters().put('id', qt.Id);

        ctrDH_AU_QuoteVFTemplate ctr;

        Test.startTest();

        Test.setCurrentPage(pref);

        ctr = new ctrDH_AU_QuoteVFTemplate();

        Test.stopTest();

        System.assert(ctr.menuPrinting);
        System.assert(!ctr.ukQuote);
    }

    @IsTest
    static void testFoodoraQuote() {
        Opportunity_Quote__c qt = [SELECT Id FROM Opportunity_Quote__c LIMIT 1];
        Opportunity opp = [SELECT Id, Id_Tarif__c FROM Opportunity LIMIT 1];

        Tarif__c t = new Tarif__c(Name = Label.Logistics_Fee.split(',')[0]);
        insert t;

        t.Is_Active__c = true;
        update t;

        opp.Id_Tarif__c = t.Id;
        update opp;

        PageReference pref = Page.CD_QuoteVFTemplate;
        pref.getParameters().put('id', qt.Id);

        ctrDH_AU_QuoteVFTemplate ctr;

        Test.startTest();

        Test.setCurrentPage(pref);

        ctr = new ctrDH_AU_QuoteVFTemplate();

        Test.stopTest();

        System.assert(ctr.foodoraEcuador);
        System.assert(ctr.foodora);
    }

    @IsTest
    static void testProductOnlyQuote() {
        Opportunity_Quote__c qt = [SELECT Id FROM Opportunity_Quote__c LIMIT 1];
        Opportunity opp = [SELECT Id, Id_Tarif__c, Type FROM Opportunity LIMIT 1];

        Tarif__c t = new Tarif__c(Name = 'whatever');
        insert t;

        t.Is_Active__c = true;
        update t;

        opp.Id_Tarif__c = t.Id;
        opp.Type = 'Product Only';
        update opp;

        PageReference pref = Page.CD_QuoteVFTemplate;
        pref.getParameters().put('id', qt.Id);

        ctrDH_AU_QuoteVFTemplate ctr;

        Test.startTest();

        Test.setCurrentPage(pref);

        ctr = new ctrDH_AU_QuoteVFTemplate();

        Test.stopTest();

        System.assert(ctr.prodOnly);
        System.assert(!ctr.colombia);
        System.assert(!ctr.peru);
        System.assert(!ctr.ecuador);
    }
}