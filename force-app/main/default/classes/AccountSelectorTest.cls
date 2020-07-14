@isTest
public class AccountSelectorTest{
    @TestSetup
    public static void testSetup(){
        UnitTestDataFactory.getRecordtypeValues();
        // CREATE COUNTRY
        List<Country__c> countryList = new List<Country__c>();
        countryList.add(UnitTestDataFactory.createCountry('CZ', 'Czech Republic', 'CZK'));
        insert countryList;
        
        // CREATE COMPANY
        List<Company__c> companyList = new List<Company__c>();

        for(Country__c country : countryList){
            Company__c company = UnitTestDataFactory.createCompany('Damejidlo', 'CZ', country);
        }
        
        insert companyList;

        // CREATE ACCOUNT
        List<Account> accountList = new List<Account>();
        for(Country__c country : countryList){
            for(Integer counter = 0; counter < 5; counter++){
                Account czAccount = UnitTestDataFactory.createAccount('Test CZ Account ' + (counter + 1), country, 'CZ_Account');
                czAccount.Type = 'Branch - main';

                accountList.add(czAccount);
            }
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
    }

    @isTest
    static void testGetAccountDetailsforId(){
        List<Account> accountList = [SELECT Id, Name FROM Account];

        Test.startTest();
            Account resultAccount = AccountSelector.getAccountDetailsforId(accountList[0].Id);
        Test.stopTest();

        system.assert(resultAccount != null);
    }

    @isTest
    static void testGetAccountByName(){
        List<Account> accountList = [SELECT Id, Name FROM Account];

        Test.startTest();
            Account resultAccount = AccountSelector.getAccountByName(accountList[0].Name);
        Test.stopTest();

        system.assert(resultAccount != null);
    }

    @isTest
    static void testGetByCountry(){
        Test.startTest();
            Account resultAccount = AccountSelector.getByCountry('Czech Republic');
        Test.stopTest();

        system.assert(resultAccount != null);
    }

    @isTest
    static void testGetAccountRecordTypeByCountry(){
        Test.startTest();
            String accountRecordTypeId = AccountSelector.getAccountRecordTypeByCountry('Czech Republic');
        Test.stopTest();

        system.assert(accountRecordTypeId != null);
        system.assert(accountRecordTypeId != '');
    }

    @isTest
    static void testGetByIds(){
        Set<Id> accountIdSet = new Set<Id>();
        List<Account> accountList = [SELECT Id, Name FROM Account];

        for(Account account : accountList){
            accountIdSet.add(account.Id);
        }

        Test.startTest();
            List<Account> resultAccountList = AccountSelector.getByIds(accountIdSet);
        Test.stopTest();

        system.assert(resultAccountList != null);
        system.assert(resultAccountList.size() == accountList.size());
    }

    @isTest
    static void testGetAll(){
        List<Account> accountList = [SELECT Id, Name FROM Account];

        Test.startTest();
            List<Account> resultAccountList = AccountSelector.getAll();
        Test.stopTest();

        system.assert(resultAccountList != null);
        system.assert(resultAccountList.size() == accountList.size());
    }

    @isTest
    static void testGetByIdsOpportunityIdsBusinessType(){
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> opportunityIdSet = new Set<Id>();
        List<Account> accountList = [SELECT Id, Name FROM Account];
        List<Opportunity> opportunityList = [SELECT Id, Name, Business_Type__c FROM Opportunity];

        for(Account account : accountList){
            accountIdSet.add(account.Id);
        }

        for(Opportunity opp : opportunityList){
            opportunityIdSet.add(opp.Id);
        }

        Test.startTest();
            List<Account> resultAccountList = AccountSelector.getByIdsOpportunityIdsBusinessType(accountIdSet, opportunityIdSet, 'Upgrade/Upsell');
        Test.stopTest();

        system.assert(resultAccountList != null);
        system.assert(resultAccountList.size() == accountList.size());
    }
    @isTest
    static void testSelectByIdWithChildAccounts(){
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> opportunityIdSet = new Set<Id>();
        List<Account> accountList = [SELECT Id, Name FROM Account];
        for(Account account : accountList){
            accountIdSet.add(account.Id);
        }
        Test.startTest();
        List<Account> resultAccountList = AccountSelector.selectByIdWithChildAccounts(accountIdSet);
        Test.stopTest();

        system.assert(resultAccountList != null);
        system.assert(resultAccountList.size() == accountList.size());
    }
    @isTest
    static void testGetByPlatformAndRecordType(){
        List<Account> accountList = [SELECT Id, Name,RecordType.Name FROM Account];
        List<Country__c> countryList = [SELECT Id, Name FROM Country__c];
        Test.startTest();
        Account resultAccountList = AccountSelector.GetByPlatformAndRecordType(accountList[0].RecordType.Name,countryList[0].Name);
        Test.stopTest();
        system.assert(resultAccountList != null);

    }
    @isTest
    static void testGetAccountMapFromAccIdSet(){
        Set<Id> accountIdSet = new Set<Id>();
        List<Account> accountList = [SELECT Id, Name FROM Account];
        for(Account account : accountList){
            accountIdSet.add(account.Id);
        }
        Test.startTest();
        Map<Id,Account> resultAccountList = AccountSelector.getAccountMapFromAccIdSet(accountIdSet);
        Test.stopTest();
        system.assert(resultAccountList.keySet() != null);
        system.assert(resultAccountList.size() == accountList.size());

    }
}