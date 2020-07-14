/**
* @author William Castillo
* @date 03.03.2020
*
* @description Test for AccountStatus_Batch class
* @see CommissionRemediation_Batch
*/
@IsTest
public with sharing class AccountStatus_Test {
    @TestSetup
    public static void setup() {
        Trigger_Manager__c triggerManager = new Trigger_Manager__c( Deactivate_Contract_Trigger__c = true );
        insert triggerManager;
        Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Opportunity', 'Contract'});
        UnitTestDataFactory.getRecordtypeValues();

        Country__c bahrainCountry = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        insert new List<Country__c> { bahrainCountry};

        Company__c com = UnitTestDataFactory.createCompany('Talabat', 'Talabat', bahrainCountry);
        insert com;

        Account acc1 = UnitTestDataFactory.createAccount('BatchTestClassAccount1', bahrainCountry, 'Talabat_Account');
        Account acc2 = UnitTestDataFactory.createAccount('cd BatchTestClassAccount1', bahrainCountry, 'Talabat_Account');
        insert new List<Account> {acc1, acc2};

        List_Service_Price__c listServicePrice = UnitTestDataFactory.createService(com,bahrainCountry,'testService1','Talabat_List_Service_Price',12,12,25,5,null,true,null,'Commission Fee','ServiceType');
        listServicePrice.Based_On__c = 'Orders';
        listServicePrice.Commission_Type__c = 'Percentage';
        listServicePrice.Scaled__c = true;
        insert listServicePrice;
        Tarif__c t = UnitTestDataFactory.createTarif(com, bahrainCountry , 'Free Tarif', 'Talabat_Tarif', false);
        insert t;

        Opportunity opp1 = UnitTestDataFactory.createOpportunity('BatchTestOpp',acc1,'Talabat_Opportunity','Verbal Agreement',Date.newInstance(2014, 12, 21));
        Opportunity opp2 = UnitTestDataFactory.createOpportunity('BatchTestOpp',acc2,'Talabat_Opportunity','Verbal Agreement',Date.newInstance(2014, 12, 21));
        insert new List<Opportunity> {opp1,opp2};

        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=opp1.Id,Status__c='Approved',Id_Account__c=acc1.Id);
        insert newQuote;

        Opportunity_Line_Item__c oppService = UnitTestDataFactory.createOpportunityLineItemService('testService3',opp1,listServicePrice.Id,true,'Talabat_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        insert oppService;

        List<Opportunity_Quote_Line_Item__c> oppQuoteLine =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,false,'Talabat_Opportunity_Quote_Line_Item',12,1,true, 0, Date.today(),'Commission Fee','Service');
        oppQuoteLine[0].Id_Opportunity__c=opp1.Id;
        oppQuoteLine[0].Id_List_Service_Price__c=listServicePrice.Id;
        insert oppQuoteLine ;
        newQuote.Status__c='Accepted';
        update newQuote;

        Contract con1 = UnitTestDataFactory.createContracts(acc1, Date.today().addYears(-1), Date.today().addDays(1), 'Draft', 'Talabat_Contract', 1,'Logistics Fee')[0];
        Contract con2 = UnitTestDataFactory.createContracts(acc2, Date.today().addYears(-1), Date.today().addDays(1), 'Draft', 'Talabat_Contract', 1,'Commission Fee')[0];

        insert new List<Contract> {con1, con2};

        con1.Status = 'Activated';
        con2.Status = 'Activated';
        update new List<Contract> {con1, con2};

        acc1.Account_Status__c = 'New';
        acc2.Account_Status__c = 'New';
        update new List<Account> {acc1, acc2};

    }
    @IsTest
    public static void test_ActiveAccountStatusWithActiveContracts() {
        test.startTest();
        String query = 'select id,Account_Status__c from account';
        AccountStatus_Batch accBatch = new AccountStatus_Batch(query);
        ID batchprocessid = Database.executeBatch(accBatch);
        test.stopTest();
        for(Account acc: [select id,Account_Status__c  from Account]){
            system.assertEquals('Active',acc.Account_Status__c);
        }

    }

    @IsTest
    public static void test_ActiveAccountStatusWithoutContracts() {
        delete [select id from Contract];
        test.startTest();
        String query = 'select id,Account_Status__c from account';
        AccountStatus_Batch accBatch = new AccountStatus_Batch(query);
        ID batchprocessid = Database.executeBatch(accBatch);
        test.stopTest();
        for(Account acc: [select id,Account_Status__c  from Account]){
            system.assertEquals('Negotiation',acc.Account_Status__c);
        }

    }
}