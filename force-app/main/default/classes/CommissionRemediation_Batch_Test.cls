/**
* @author Mantas Jurkunas
* @date 15.07.2019
*
* @description Test for CommissionRemediation_Batch class
* @see CommissionRemediation_Batch
*/
@IsTest
public with sharing class CommissionRemediation_Batch_Test {
    @TestSetup
    public static void setup() {
        Trigger_Manager__c triggerManager = new Trigger_Manager__c( Deactivate_Contract_Trigger__c = true );
        insert triggerManager;
        Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Opportunity', 'Contract'});
        UnitTestDataFactory.getRecordtypeValues();

        Country__c bh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        Country__c ec = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
        insert new List<Country__c> {ec, bh};

        Company__c com = UnitTestDataFactory.createCompany('Talabat', 'Talabat', bh);
        insert com;

        Account acc1 = UnitTestDataFactory.createAccount('BatchTestClassAccount1', bh, 'Talabat_Account');
        Account acc2 = UnitTestDataFactory.createAccount('cd account', ec, 'CD_Account');
        insert new List<Account> {acc1, acc2};

        List_Service_Price__c lsp = UnitTestDataFactory.createService(com,bh,'testService1','Talabat_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType');
        lsp.Based_On__c = 'Orders';
        lsp.Commission_Type__c = 'Percentage';
        lsp.Scaled__c = true;
        insert lsp;
        Tarif__c t = UnitTestDataFactory.createTarif(com, bh , 'Free Tarif', 'Talabat_Tarif', false);
        insert t;

        Opportunity opp1 = new Opportunity(
                Setup_Fee_AU__c = 155,
                Start_Date_uk__c = Date.newInstance(2014, 12, 21),
                Name = 'BatchTestOpp1',
                RecordTypeId = mapRecordtypes.get('Talabat_Opportunity').Id,
                AccountId = acc1.Id,
                CloseDate = Date.newInstance(2014, 12, 21),
                StageName = 'Prospecting',
                TarrifName_AU__c = 'testTarif1',
                Id_Tarif__c=t.Id,
                Is_DataLoaded__c = true,
                Migration_Notes_AU__c = 'Migration');

        insert new List<Opportunity> {opp1};

        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=opp1.Id,Status__c='Approved',Id_Account__c=acc1.Id);
        insert newQuote;

        Opportunity_Line_Item__c oppService = UnitTestDataFactory.createOpportunityLineItemService('testService3',opp1,lsp.Id,true,'Talabat_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        insert oppService;

        List<Opportunity_Quote_Line_Item__c> oppQuoteLine =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,false,'Talabat_Opportunity_Quote_Line_Item',12,1,true, 0, Date.today(),'Commission Fee','Service');
        oppQuoteLine[0].Id_Opportunity__c=opp1.Id;
        oppQuoteLine[0].Id_List_Service_Price__c=lsp.Id;
        insert oppQuoteLine ;
        newQuote.Status__c='Accepted';
        update newQuote;

        Contract con1 = new Contract(Name = 'test1',
                AccountId = acc1.Id,
                Id_Opportunity__c = opp1.Id,
                Status = 'Draft',
                StartDate = Date.today().addYears(-1),
                End_Date__c = Date.today(),
                Id_Opportunity_Quote_Line_Item__c=oppQuoteLine[0].Id,
                RecordTypeId = mapRecordtypes.get('Talabat_Contract').Id);
        Contract con2 = new Contract(Name = 'test2',
                AccountId = acc2.Id,
                Id_Opportunity__c = opp1.Id,
                Status = 'Draft',
                StartDate = Date.today().addYears(-1),
                Id_Opportunity_Quote_Line_Item__c=oppQuoteLine[0].Id,
                End_Date__c = Date.today(),
                RecordTypeId = mapRecordtypes.get('Talabat_Contract').Id);
        insert new List<Contract> {con1, con2};

        con1.Status = 'Activated';
        con2.Status = 'Activated';
        update new List<Contract> {con1, con2};
    }

    @IsTest
    public static void test_OpportunityLineItemRemediation() {
        Test.startTest();
        Database.executeBatch(new CommissionRemediation_Batch(Opportunity_Line_Item__c.class));
        Test.stopTest();
        List<Opportunity_Line_Item__c> listObj = OpportunityLineItem_Selector.getAll();
        for (Opportunity_Line_Item__c obj: listObj) {
            System.assertEquals('Orders', obj.Based_On__c);
            System.assertEquals('Percentage', obj.Commission_Type_Picklist__c);
            System.assert(obj.Scaled__c);
        }
    }

    @IsTest
    public static void test_QuoteLineItemRemediation() {
        Test.startTest();
        Database.executeBatch(new CommissionRemediation_Batch(Opportunity_Quote_Line_Item__c.class));
        Test.stopTest();
        List<Opportunity_Quote_Line_Item__c> listObj = OpportunityQuoteLineItem_Selector.getAll();
        for (Opportunity_Quote_Line_Item__c obj: listObj) {
            System.assertEquals('Orders', obj.Based_On__c);
            System.assertEquals('Percentage', obj.Commission_Type_Picklist__c);
            System.assert(obj.Scaled__c);
        }
    }

    @IsTest
    public static void test_CommissionRemediation() {
        Test.startTest();
        Database.executeBatch(new CommissionRemediation_Batch(Contract.class));
        Test.stopTest();
        List<Contract> listObj = ContractSelector.getAll();
        for (Contract obj: listObj) {
            System.assertEquals('Orders', obj.Based_On__c);
            System.assertEquals('Percentage', obj.Commission_Type__c);
            System.assert(obj.Scaled__c);
        }
    }

    @IsTest
    public static void test_OpportunityLineItemRemediationRecordType() {
        Test.startTest();
        Database.executeBatch(new CommissionRemediation_Batch(Opportunity_Line_Item__c.class, 'Talabat_Opportunity'));
        Test.stopTest();
        List<Opportunity_Line_Item__c> listObj = OpportunityLineItem_Selector.getAll();
        for (Opportunity_Line_Item__c obj: listObj) {
            System.assertEquals('Orders', obj.Based_On__c);
            System.assertEquals('Percentage', obj.Commission_Type_Picklist__c);
            System.assert(obj.Scaled__c);
        }
    }

    @IsTest
    public static void test_QuoteLineItemRemediationRecordType() {
        Test.startTest();
        Database.executeBatch(new CommissionRemediation_Batch(Opportunity_Quote_Line_Item__c.class, 'Talabat_Opportunity'));
        Test.stopTest();
        List<Opportunity_Quote_Line_Item__c> listObj = OpportunityQuoteLineItem_Selector.getAll();
        for (Opportunity_Quote_Line_Item__c obj: listObj) {
            System.assertEquals('Orders', obj.Based_On__c);
            System.assertEquals('Percentage', obj.Commission_Type_Picklist__c);
            System.assert(obj.Scaled__c);
        }
    }

    @IsTest
    public static void test_CommissionRemediationRecordType() {
        Test.startTest();
        Database.executeBatch(new CommissionRemediation_Batch(Contract.class, 'Talabat_Opportunity'));
        Test.stopTest();
        List<Contract> listObj = ContractSelector.getAll();
        for (Contract obj: listObj) {
            System.assertEquals('Orders', obj.Based_On__c);
            System.assertEquals('Percentage', obj.Commission_Type__c);
            System.assert(obj.Scaled__c);
        }
    }

    @IsTest
    public static void test_NegativeRemediation() {
        Boolean batchFailed = true;
        try {
            Test.startTest();
            Database.executeBatch(new CommissionRemediation_Batch(Opportunity.class));
            Test.stopTest();
            batchFailed = false;
        } catch (CommissionRemediation_Batch.CommissionRemediationException e) {}
        System.assert(batchFailed);
    }

    @IsTest
    public static void test_NegativeOpportunityLineItemRemediationRecordType() {
        Test.startTest();
        Database.executeBatch(new CommissionRemediation_Batch(Opportunity_Line_Item__c.class, 'BTS_Opportunity'));
        Test.stopTest();
        List<Opportunity_Line_Item__c> listObj = OpportunityLineItem_Selector.getAll();
        for (Opportunity_Line_Item__c obj: listObj) {
            System.assertNotEquals('Orders', obj.Based_On__c);
            System.assertNotEquals('Percentage', obj.Commission_Type_Picklist__c);
            System.assert(!obj.Scaled__c);
        }
    }

    @IsTest
    public static void test_NegativeQuoteLineItemRemediationRecordType() {
        Test.startTest();
        Database.executeBatch(new CommissionRemediation_Batch(Opportunity_Quote_Line_Item__c.class, 'BTS_Opportunity'));
        Test.stopTest();
        List<Opportunity_Quote_Line_Item__c> listObj = OpportunityQuoteLineItem_Selector.getAll();
        for (Opportunity_Quote_Line_Item__c obj: listObj) {
            System.assertNotEquals('Orders', obj.Based_On__c);
            System.assertNotEquals('Percentage', obj.Commission_Type_Picklist__c);
            System.assert(!obj.Scaled__c);
        }
    }

    @IsTest
    public static void test_NegativeCommissionRemediationRecordType() {
        Test.startTest();
        Database.executeBatch(new CommissionRemediation_Batch(Contract.class, 'BTS_Opportunity'));
        Test.stopTest();
        List<Contract> listObj = ContractSelector.getAll();
        for (Contract obj: listObj) {
            System.assertNotEquals('Orders', obj.Based_On__c);
            System.assertNotEquals('Percentage', obj.Commission_Type__c);
            System.assert(!obj.Scaled__c);
        }
    }

}