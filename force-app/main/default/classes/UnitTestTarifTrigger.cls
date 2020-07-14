@isTest
private class UnitTestTarifTrigger {
    private static Map<String, RecordType> mapRecordtypesKR = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Opportunity', 'Account', 'List_Product_Group__c', 'List_Product_Price__c', 'List_Service_Price__c', 'Tarif__c', 'Tarif_Member__c', 'Tarif_Item__c', 'Opportunity_Line_Item__c'});
    static {
        UnitTestDataFactory.getRecordtypeValues();
    }
    @isTest static void unitTest_tarif_validation_active_on_insert_fail() {


        Country__c c = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        insert c;
        Company__c com = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', c);
        insert com;

        Tarif__c t = new Tarif__c(Company__c = com.id, Id_Country__c = c.id, Is_Active__c = true, Name = 'testTarif1', RecordTypeId = mapRecordtypesKR.get('Yogiyo_Tarif').id);

        Test.startTest();
        try {
            insert t;
        } catch (Exception e) {
            System.assert(e.getMessage().contains(Label.Save_Edit_Tariff_Failure));
        }
        Test.stopTest();

    }

    @isTest static void unitTest_tarif_validation_active_on_edit_success() {
        //Map<String,RecordType> mapRecordtypesKR = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Yogiyo_Opportunity','Yogiyo_Account','Yogiyo_List_Product_Group','Yogiyo_List_Product_Price','Yogiyo_List_Service_Price','Yogiyo_Tarif','Yogiyo_Tarif_Item','Yogiyo_Opportunity_Tarif_Item','Yogiyo_Opportunity_Line_Item','Yogiyo_Opportunity_Service_Item'});

        Country__c c = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        insert c;

        Company__c com = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', c);
        insert com;

        List_Product_Group__c lpg = new List_Product_Group__c(Id_Country__c = c.id, Name = 'Apple', recordtypeid = mapRecordtypesKR.get('Yogiyo_List_Product_Group').id, Company__c = com.id);
        insert lpg;

        List_Product_Price__c lpp = new List_Product_Price__c(Company__c = com.id, Id_Country__c = c.id, Id_List_Product_Group__c = lpg.id, Installments__c = 1, Is_Active__c = true, List_Price__c = 100, Product_Name__c = 'Ipad 4 Gen. 16GB', maximum_discount__c = 20, RecordTypeId = mapRecordtypesKR.get('Yogiyo_List_Product_Price').id, Default_Quantity__c = 1);
        insert lpp;

        List_Service_Price__c lsp = new List_Service_Price__c(Company__c = com.id, Commission_In_Percentage__c = 12, Default_Commission_In_Percentage__c = 12, Id_Country__c = c.id, Is_Active__c = true, Maximum_Commission_In_Percentage__c = 25, Minimum_Commission_in_Percentage__c = 5, Name = 'testService1', RecordTypeId = mapRecordtypesKR.get('Yogiyo_List_Service_Price').id, Type__c = 'Commission');
        insert lsp;


        Tarif__c t = new Tarif__c(Company__c = com.id, Id_Country__c = c.id, Is_Active__c = false, Name = 'testTarif1', RecordTypeId = mapRecordtypesKR.get('Yogiyo_Tarif').id);
        insert t;

        Tarif_Member__c tm = new Tarif_Member__c(Id_Tarif_Item__c = lpp.id, RecordTypeId = mapRecordtypesKR.get('Yogiyo_Tarif_Member').id, Tarif_Name__c = t.id, Type__c = 'Product');
        Tarif_Member__c tm1 = new Tarif_Member__c(Id_Tarif_Item__c = lsp.id, RecordTypeId = mapRecordtypesKR.get('Yogiyo_Tarif_Member').id, Tarif_Name__c = t.id, Type__c = 'Service');

        insert new List<sObject> {tm, tm1};

        Test.startTest();

        t.Is_Active__c = true;
        update t;

        Test.stopTest();

        t = [SELECT Id, Is_Active__c FROM Tarif__c WHERE Id = : t.Id];

        System.assert(t.Is_Active__c);


    }

    @isTest static void unitTest_tarif_validation_active_on_edit_fail_service_inactive() {
        //Map<String,RecordType> mapRecordtypesKR = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Yogiyo_Opportunity','Yogiyo_Account','Yogiyo_List_Product_Group','Yogiyo_List_Product_Price','Yogiyo_List_Service_Price','Yogiyo_Tarif','Yogiyo_Tarif_Item','Yogiyo_Opportunity_Tarif_Item','Yogiyo_Opportunity_Line_Item','Yogiyo_Opportunity_Service_Item'});

        Country__c c = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        insert c;
        Company__c com = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', c);
        insert com;

        List_Product_Group__c lpg = new List_Product_Group__c(Id_Country__c = c.id, Name = 'Apple', recordtypeid = mapRecordtypesKR.get('Yogiyo_List_Product_Group').id, Company__c = com.id);
        insert lpg;

        List_Product_Price__c lpp = new List_Product_Price__c(Company__c = com.id, Id_Country__c = c.id, Id_List_Product_Group__c = lpg.id, Installments__c = 1, Is_Active__c = true, List_Price__c = 100, Product_Name__c = 'Ipad 4 Gen. 16GB', maximum_discount__c = 20, RecordTypeId = mapRecordtypesKR.get('Yogiyo_List_Product_Price').id, Default_Quantity__c = 1);
        insert lpp;

        List_Service_Price__c lsp = new List_Service_Price__c(Company__c = com.id, Commission_In_Percentage__c = 12, Default_Commission_In_Percentage__c = 12, Id_Country__c = c.id, Is_Active__c = false, Maximum_Commission_In_Percentage__c = 25, Minimum_Commission_in_Percentage__c = 5, Name = 'testService1', RecordTypeId = mapRecordtypesKR.get('Yogiyo_List_Service_Price').id, Type__c = 'Commission');
        insert lsp;


        Tarif__c t = new Tarif__c(Company__c = com.id, Id_Country__c = c.id, Is_Active__c = false, Name = 'testTarif1', RecordTypeId = mapRecordtypesKR.get('Yogiyo_Tarif').id);
        insert t;

        Tarif_Member__c tm = new Tarif_Member__c(Id_Tarif_Item__c = lpp.id, RecordTypeId = mapRecordtypesKR.get('Yogiyo_Tarif_Member').id, Tarif_Name__c = t.id, Type__c = 'Product');
        Tarif_Member__c tm1 = new Tarif_Member__c(Id_Tarif_Item__c = lsp.id, RecordTypeId = mapRecordtypesKR.get('Yogiyo_Tarif_Member').id, Tarif_Name__c = t.id, Type__c = 'Service');

        insert new List<sObject> {tm, tm1};

        Test.startTest();

        t.Is_Active__c = true;
        try {
            update t;
        } catch (Exception e) {
            System.assert(e.getMessage().contains(Label.Tarif_activation_failure));
        }


        Test.stopTest();


    }

    @isTest static void unitTest_tarif_validation_active_on_edit_fail_product_inactive() {
        //Map<String,RecordType> mapRecordtypesKR = LibRecordTypeHelper.getRecordTypeOnlyForNames(new Set<String>{'Yogiyo_Opportunity','Yogiyo_Account','Yogiyo_List_Product_Group','Yogiyo_List_Product_Price','Yogiyo_List_Service_Price','Yogiyo_Tarif','Yogiyo_Tarif_Item','Yogiyo_Opportunity_Tarif_Item','Yogiyo_Opportunity_Line_Item','Yogiyo_Opportunity_Service_Item'});

        Country__c c = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        insert c;
        Company__c com = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', c);
        insert com;

        List_Product_Group__c lpg = new List_Product_Group__c(Id_Country__c = c.id, Name = 'Apple', recordtypeid = mapRecordtypesKR.get('Yogiyo_List_Product_Group').id, Company__c = com.id);
        insert lpg;

        List_Product_Price__c lpp = new List_Product_Price__c(Company__c = com.id, Id_Country__c = c.id, Id_List_Product_Group__c = lpg.id, Installments__c = 1, Is_Active__c = false, List_Price__c = 100, Product_Name__c = 'Ipad 4 Gen. 16GB', maximum_discount__c = 20, RecordTypeId = mapRecordtypesKR.get('Yogiyo_List_Product_Price').id, Default_Quantity__c = 1);
        insert lpp;

        List_Service_Price__c lsp = new List_Service_Price__c(Company__c = com.id, Commission_In_Percentage__c = 12, Default_Commission_In_Percentage__c = 12, Id_Country__c = c.id, Is_Active__c = true, Maximum_Commission_In_Percentage__c = 25, Minimum_Commission_in_Percentage__c = 5, Name = 'testService1', RecordTypeId = mapRecordtypesKR.get('Yogiyo_List_Service_Price').id, Type__c = 'Commission');
        insert lsp;


        Tarif__c t = new Tarif__c(Company__c = com.id, Id_Country__c = c.id, Is_Active__c = false, Name = 'testTarif1', RecordTypeId = mapRecordtypesKR.get('Yogiyo_Tarif').id);
        insert t;

        Tarif_Member__c tm = new Tarif_Member__c(Id_Tarif_Item__c = lpp.id, RecordTypeId = mapRecordtypesKR.get('Yogiyo_Tarif_Member').id, Tarif_Name__c = t.id, Type__c = 'Product');
        Tarif_Member__c tm1 = new Tarif_Member__c(Id_Tarif_Item__c = lsp.id, RecordTypeId = mapRecordtypesKR.get('Yogiyo_Tarif_Member').id, Tarif_Name__c = t.id, Type__c = 'Service');

        insert new List<sObject> {tm, tm1};

        Test.startTest();

        t.Is_Active__c = true;
        try {
            update t;
        } catch (Exception e) {
            System.assert(e.getMessage().contains(Label.Tarif_activation_failure));
        }


        Test.stopTest();


    }

}