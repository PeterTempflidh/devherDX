/**
 * Created by w.novoa on 19.11.2018.
 */

@IsTest
private class UnitTestBatchAssetMigration {

    private static Country__c c;
    private static Account  acc;
    private static Opportunity  opp;
    private static Company__c com;

    @testsetup static void setup() {
        UnitTestDataFactory.getRecordtypeValues();

        c = UnitTestDataFactory.createCountry('AR', 'Argentina', 'ARS');
        insert c;

        acc = UnitTestDataFactory.createAccount('TestAccount', c, 'PY_Account');
        insert acc;

        com = UnitTestDataFactory.createCompany('PedidosYA', 'PY', c);
        insert com;

        opp = UnitTestDataFactory.createOpportunity('TestOpp123', acc, 'PY_Opportunity', Date.today());
        insert  opp;

        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com, c , 'Apple', 'PY_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com, c , 'Menu Printing', 'PY_List_Product_Group');
        insert new List<SObject> {lpg, lpg1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com, c , 'Menu Printing with website', lpg.id, 'UK_List_Product_Price', 1, true, 100, 1, false, 20);
        lpp.product_type__c = 'Menu Printing';
        lpp.Requires_Branding__c = true;
        lpp.Requires_Asset__c = true;

        insert new List<sobject> {lpp};

        Additional_Charges__c addCharges = new Additional_Charges__c();
        addCharges.Id_Opportunity__c = opp.id;
        addCharges.Id_List_Product_Price__c = lpp.id;
        addCharges.Id_Account__c = acc.id;
        addCharges.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue('PY_Additional_Charges');

        insert addCharges;

        case caso = new case();

        caso.AccountId = acc.id;
        caso.Opportunity__c = opp.id;
        caso.Type = 'Onboarding';
        caso.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue('PY_Restaurant_Operations');

        insert caso;

    }

    @IsTest
    static void testBehavior() {

        Test.startTest();
        Id batchJobId = Database.executeBatch(new BatchAssetMigration(), 200);
        Test.stopTest();

        system.assert([Select id From Asset__c].size()>0);
    }
}