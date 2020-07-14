/**
* @author Danish Farooq
* @date 06.04.2020
*
* @description Test class for OpportunityLineItemCreation_Queable
*/
@IsTest
private class OpportunityLineItemCreation_QueableTest {
    @testSetup
    static void setupData(){

        Map<String, RecordType> mapRecordtypesKR = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Opportunity', 'Account', 'List_Product_Group__c', 'List_Product_Price__c', 'List_Service_Price__c', 'List_Add_On__c','Tarif__c', 'Tarif_Member__c', 'Tarif_Item__c', 'Opportunity_Line_Item__c'});
        UnitTestDataFactory.getRecordtypeValues();
        Country__c hk = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'HKD');
        Database.insert(hk);
        Company__c com = UnitTestDataFactory.createCompany('Foodpanda Hong Kong', 'FP', hk);
        insert com;

        // CREATE ACCOUNT
        Account accTemp;
        List<Account> accountList = new List<Account>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        for(Integer counter = 0; counter < 2; counter++){
            accTemp = UnitTestDataFactory.createAccount('Test FP ' + (counter + 1), hk, 'FP_Account');
            accTemp.Type = 'Branch';
            accountList.add(accTemp);
        }
        insert accountList;

        Opportunity oppt = UnitTestDataFactory.createOpportunity(accountList[0].Name, accountList[0], 'FP_Opportunity', Date.today());
        oppt.Business_Type__c = 'New Business';
        insert oppt;


        // Create Tarif
        Tarif__c tarifObj = new Tarif__c(Company__c = com.id, Id_Country__c = hk.id, Is_Active__c = false, Name = 'testTarif1', RecordTypeId = mapRecordtypesKR.get('FP_Tarif').id);
        tarifObj.is_Locked__c     = false;
        tarifObj.Product_only__c   = false;

        insert tarifObj;
        tarifObj.Is_Active__c = true;
        update tarifObj;

        oppt.Id_Tarif__c = tarifObj.Id;
        update oppt;

    }
    @IsTest
    static void testSelfSignUp() {

        test.startTest();

        Opportunity oppty = [Select id, leadSource from opportunity limit 1];
        oppty.LeadSource = 'Self Sign Up';
        update oppty;
        test.stopTest();

        List<Opportunity_Line_Item__c> lstOppty = [Select Id from Opportunity_Line_Item__c];
        system.assertEquals(0,lstOppty.size());

        List<Opportunity_Quote_Line_Item__c> lstOpptyQuote = [Select Id from Opportunity_Quote_Line_Item__c];
        system.assertEquals(0,lstOpptyQuote.size());
    }
}