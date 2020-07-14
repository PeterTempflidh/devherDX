/**
 * Created by c.kumari on 07.10.2019.
 */

@isTest
private class BankDetail_UtilsTest {

    @testSetup
    static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
        Map<String, String> mapCountryCurrency = LibBusinessConfig.recordCurrencyMap();

        Country__c apacCountry = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'HKD');
        insert apacCountry;

        Account acct = UnitTestDataFactory.createAccount('TEST', apacCountry, 'FP_Account');
        acct.Type = 'Branch - main';
        acct.Account_Status__c = 'New';
        acct.Phone = '+85227367722';
        insert acct;

        List<Bank_Detail__c> bankDetail = new List<Bank_Detail__c>();
        for(Integer i = 0; i < 2; i++) {
            bankDetail.add(new Bank_Detail__c(Account__c = acct.Id,
                    Bank_Account_Number__c = '7674238787388348374'+i,
                    Bank_Name__c = 'testBank'+i,
                    Bank_Account_Owner__c = 'Test User',
                    Status__c = 'New', Activation_Date__c = System.today()));
        }
        insert bankDetail;

        Account acct1 = UnitTestDataFactory.createAccount('TEST', apacCountry, 'FP_Account');
        acct1.Type = 'Branch - main';
        acct1.Account_Status__c = 'Negotiation';
        acct1.Phone = '+85227367722';
        insert acct1;

        List<Bank_Detail__c> bankDetail1 = new List<Bank_Detail__c>();
        for(Integer i = 0; i < 2; i++) {
            bankDetail1.add(new Bank_Detail__c(Account__c = acct1.Id,
                    Bank_Account_Number__c = '7674787367326736'+i,
                    Bank_Name__c = 'testBank'+i,
                    Bank_Account_Owner__c = 'Test User',
                    Status__c = 'New',  Activation_Date__c = System.today()));
        }
        //SSC-1330
        insert bankDetail1;


    }

    @isTest
    static void testBankDataNew() {

        List<Bank_Detail__c> bankDetail = [select id,status__c from Bank_Detail__c where Status__c = 'Active' and Account_Status__c = 'New'];
        system.assertEquals(2,bankDetail.size());
    }

    @isTest
    static void testBankDataApproved() {
        User usr = UnitTestDataFactory.createUser('System Administrator','test1@deliveryhero.com','FP','HK');
        insert usr;
        System.runAs(usr){
            List<Bank_Detail__c> bankDetail = [select id,status__c from Bank_Detail__c where status__c = 'Active'];
            System.assertEquals(4,bankDetail.size());
        }

    }

    @isTest
    static void test(){
        UnitTestDataFactory.getRecordtypeValues();
        Country__c hk = [SELECT Id, Name FROM Country__c WHERE Name = 'Hong Kong'];

        //get account
        Account acc = [Select id,Name,Record_Country__c from Account where Name = 'test' limit 1];
        // CREATE OPPORTUNITIES
        Opportunity childOppt = UnitTestDataFactory.createOpportunity(acc.Name, acc, 'FP_Opportunity', Date.today());
        childOppt.Business_Type__c = 'Upgrade/Upsell';
        childOppt.Type = 'Contract & Product';
        childOppt.StageName = 'Quality Check Request';
        insert childOppt;
        //CREATE BANKDETAIL
        Bank_Detail__c bd = new Bank_Detail__c(Account__c = acc.Id,
                Bank_Account_Number__c = '7674787367326736',
                Bank_Name__c = 'testBank',
                Bank_Account_Owner__c = 'Test User',
                Status__c = 'Approved',  Activation_Date__c = System.today());
        try{
            insert bd;
        }
        catch(Exception e){
            System.assertEquals(e.getMessage().contains(System.label.Cannot_Upsert_Bankdetail_Error), TRUE);
        }
    }
    @isTest
    static void testApprovals(){

        UnitTestDataFactory.getRecordtypeValues();

        //get account
        Account acc = [Select id,Name,Record_Country__c from Account where Name = 'test' limit 1];
        Bank_Detail__c bd = new Bank_Detail__c(Account__c = acc.Id,
                Bank_Account_Number__c = '7674787367326736',
                Bank_Name__c = 'testBank',
                Bank_Account_Owner__c = 'Test User',
                Status__c = Constants.BANKDETAIL_STATUS_APPROVAL_PENDING,  Activation_Date__c = System.today().addDays(2));

        insert bd;

        try{
            bd.Status__c = Constants.BANKDETAIL_STATUS_APPROVED;
            update bd;
        }
        catch(Exception e){
            System.assertEquals(e.getMessage().contains(System.label.ValidateApprovalMessage), TRUE);
        }

    }

}