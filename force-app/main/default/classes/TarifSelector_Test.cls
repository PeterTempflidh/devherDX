@isTest
public with sharing class TarifSelector_Test {
    private static Map<String, RecordType> mapRecordtypesKR = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Tarif__c','List_Product_Group__c'});

    @TestSetup
    public static void setUpData(){
        // create RecordType__c custom setting
        UnitTestDataFactory.getRecordtypeValues();	
        
        // create Country
        Country__c c = UnitTestDataFactory.createCountry('HK','Hong Kong', 'HKD');
        insert new List<Country__c>{c};
        
        // create company
        Company__c com = UnitTestDataFactory.createCompany('Hungryhouse', 'uk', c);
        insert com;

        // Create Product Group
        List<List_Product_group__c> groups = UnitTestDataFactory.createProductGroups(Com, c, 1, 'FP_List_Product_Group');
        insert groups;

        // Create Tarif
        Tarif__c t = new Tarif__c(Company__c = com.id, Id_Country__c = c.id, Is_Active__c = false, Name = 'testTarif1', RecordTypeId = mapRecordtypesKR.get('FP_Tarif').id);
        t.is_Locked__c 		= false;
        t.Product_only__c 	= false;
        t.categories__c 	= groups[0].name;
        insert t;
        t.Is_Active__c = true;
        update t;
    }
    
    @isTest
    public static void TestAll(){
        Tarif__c tar = TarifSelector.findTarifRecordByTarifName('testTarif1','FP','Hong Kong');
        TarifSelector.findTarifRecordByCountries(new set<Id>{});
        System.assertEquals(true, tar != null);
    }
}