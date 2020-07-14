@isTest
public with sharing class UnitTestAddOnTrigger {
    
    private static Map<String, RecordType> mapRecordtypesKR = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Opportunity', 'Account', 'List_Product_Group__c', 'List_Product_Price__c', 'List_Service_Price__c', 'Tarif__c', 'Tarif_Member__c', 'Tarif_Item__c', 'Opportunity_Line_Item__c'});
    
    @TestSetup
    public static void setupData(){
		Country__c c = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        insert c;
        Company__c com = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', c);
        insert com;

        Tarif__c t = new Tarif__c(Company__c = com.id, Id_Country__c = c.id, Is_Active__c = false, Name = 'testTarif1', RecordTypeId = mapRecordtypesKR.get('Yogiyo_Tarif').id);
		insert t;
		
		t.Is_Active__c = true;
		update t;
		  
    	// Create Add Ons
    	List_Add_On__c addon = new List_Add_On__c();
    	addOn.name	= 'test';
    	addOn.is_Active__c = true;
    	addOn.Contract_Addition__c = 'test';
    	addOn.type__c = 'Deal / Promotion';
    	insert addOn;
    	
    	// create tarif Member
    	Tarif_Member__c tm = new Tarif_Member__c(Id_Tarif_Item__c = addOn.id, RecordTypeId = mapRecordtypesKR.get('Yogiyo_Tarif_Member').id, Tarif_Name__c = t.id, Type__c = 'AddOn');
    	insert tm;
    }
    
    @isTest
    public static void testAddOnTrigger(){
		List_Add_on__c addON = [Select Id,Is_Active__c from List_Add_on__c limit 1];
    	Test.startTest();
			addOn.Is_Active__c = false;
			try{
				update addOn;
			}catch(exception e){}
    	Test.stopTest();
    }
    
}