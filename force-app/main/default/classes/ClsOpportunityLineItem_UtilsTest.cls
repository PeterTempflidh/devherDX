/**
* @author Danish Farooq
* @date 06.04.2020
*
* @description Test class for ClsOpportunityLineItem_Utils
*/

@IsTest
private class ClsOpportunityLineItem_UtilsTest {

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
        // Create commissions
        List<List_Service_price__c> commissions = UnitTestDataFactory.createServices(com, hk, 3,'FP_List_Service_Price',12,12,16, 8, 1,'Commission Fee',
                true, 0,'','Percentage', 'Commission Fee');

        insert commissions;

        // Create Product Group
        List<List_Product_group__c> groups = UnitTestDataFactory.createProductGroups(Com, hk, 1, 'FP_List_Product_Group');
        insert groups;

        // Create Products
        List<List_Product_price__c> products = UnitTestDataFactory.createProducts(com, hk,groups[0].id, 2,'FP_List_Product_Price',
                0, true, 100, 1, false,20);
        insert products;

        // Create Add Ons
        List<List_Add_On__c> addOns = UnitTestDataFactory.createAddOns(com,hk,2,'FP_List_Add_On','test','Deal / Promotion',true);
        insert addOns;

        // Create Tarif
        Tarif__c tarifObj = new Tarif__c(Company__c = com.id, Id_Country__c = hk.id, Is_Active__c = false, Name = 'testTarif1', RecordTypeId = mapRecordtypesKR.get('FP_Tarif').id);
        tarifObj.is_Locked__c     = false;
        tarifObj.Product_only__c   = false;
        tarifObj.categories__c   = groups[0].name;
        insert tarifObj;
        tarifObj.Is_Active__c = true;
        update tarifObj;

        // create tarif Member
        List<Tarif_Member__c> members = new List<Tarif_Member__c>();
        for(List_Service_price__c comm :  commissions){
            Tarif_Member__c tm = new Tarif_Member__c(Id_Tarif_Item__c = comm.id, RecordTypeId = mapRecordtypesKR.get('FP_Tariff_Member').id, Tarif_Name__c = tarifObj.id, Type__c = 'Service');
            members.add(tm);
        }
        for(List_Product_price__c prod : products){
            Tarif_Member__c tm = new Tarif_Member__c(Id_Tarif_Item__c = prod.id, RecordTypeId = mapRecordtypesKR.get('FP_Tariff_Member').id, Tarif_Name__c = tarifObj.id, Type__c = 'Product');
            members.add(tm);
        }
        for(List_Add_On__c addOn : addOns){
            Tarif_Member__c tm = new Tarif_Member__c(Id_Tarif_Item__c = addOn.id, RecordTypeId = mapRecordtypesKR.get('FP_Tariff_Member').id, Tarif_Name__c = tarifObj.id, Type__c = 'AddOn');
            members.add(tm);
        }
        insert members;

        oppt.Id_Tarif__c = tarifObj.Id;
        update oppt;

        //CREATE DDP TEST DATA
        Loop__DDP__c ddp    = new Loop__DDP__c(Name='Quotes');
        insert ddp;

        Loop__DDP_Integration_Option__c delivOpt = new Loop__DDP_Integration_Option__c(Name='Attachment',Loop__DDP__c=ddp.Id);
        insert delivOpt;
    }
    @IsTest
    static void testSelfSignUp() {

        test.startTest();

        Opportunity oppty = [Select id, leadSource from opportunity limit 1];
        oppty.LeadSource = 'Self Sign Up';
        update oppty;

        test.stopTest();

        List<Opportunity_Line_Item__c> lstOppty = [Select Id from Opportunity_Line_Item__c];
        system.assertEquals(7,lstOppty.size());

        List<Opportunity_Quote_Line_Item__c> lstOpptyQuote = [Select Id from Opportunity_Quote_Line_Item__c];
        system.assertEquals(7,lstOpptyQuote.size());

    }
}