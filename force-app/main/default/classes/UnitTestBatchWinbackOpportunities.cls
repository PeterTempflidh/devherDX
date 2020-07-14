/**
 * Created by w.novoa on 29.08.2018.
 */

@IsTest
private class UnitTestBatchWinbackOpportunities {
    private static Account acc_de;
    private static country__c c_de;
    private static Opportunity opp;
    private static Company__c com_de;
    private static case cs_de;
    static Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Case'});

    @testSetup static void setup() {

        UnitTestDataFactory.getRecordtypeValues();

        c_de = UnitTestDataFactory.createCountry('DE', 'Germany', 'EUR');
        insert c_de;
        com_de = UnitTestDataFactory.createCompany('Hungryhouse', 'DE', c_de);
        insert com_de;
        acc_de = UnitTestDataFactory.createAccount('TestAccount', c_de, 'DE_Account');
        acc_de.Account_Status__c = 'Terminated';
        acc_de.Type = 'Branch - Main';

        insert acc_de;


        List<Business_Config__c> listConfigs = new List<Business_Config__c>();
        listConfigs.add(UnitTestDataFactory.createBusinessConfig('WinbackOpportunities', 'Process', 'InvalidStatusReason', 'Business Closed,Duplicate,Fraud,Invalid,Legal Form Change,New Owner - New contract,New Owner - No new contract, Poor Performance,Cannot Contact,Obsolete,Downgrade,Upgrade', c_de.Id, 'DE_Account', true, true));
        listConfigs.add(UnitTestDataFactory.createBusinessConfig('WinbackOpportunities', 'Process', 'AccountType', 'Branch - Main,Brand,Group,Holding', c_de.Id, 'DE_Account', true, false));
        listConfigs.add(UnitTestDataFactory.createBusinessConfig('WinbackOpportunities', 'Process', 'OwnerId', String.valueof(System.userInfo.getUserId()), c_de.Id, 'DE_Account', true, false));
        listConfigs.add(UnitTestDataFactory.createBusinessConfig('WinbackOpportunities', 'Process', 'OpportunityRecordType', 'DE_Opportunity', c_de.Id, 'DE_Account', true, false));

        insert listConfigs;

        Contract con = new Contract();

        con.AccountId = acc_de.id;
        con.Service_Type__c = 'Commission Fee';
        con.End_Date__c = Date.TODAY().addDays(-180);

        insert con;
    }

    @IsTest
    static void testBehavior() {
        ScheduleBatchWinbackDE sch =new ScheduleBatchWinbackDE();

        Test.startTest();
        sch.execute(null);
        Test.stopTest();

        List<Opportunity> lstOptRes= [Select id from Opportunity where Business_Type__c = 'Win Back'];

        System.assert(lstOptRes.size()>0);
    }

}