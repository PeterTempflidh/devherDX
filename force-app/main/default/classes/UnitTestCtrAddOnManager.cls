/**
 * Created by t.holawala on 15.09.2017.
 */
@isTest
public class UnitTestCtrAddOnManager {

    @TestSetup
    public static void createTestData(){
        Country__c ctr = UnitTestDataFactory.createCountry('AT','Austria','EUR');
        insert ctr;

        Company__c cmp = UnitTestDataFactory.createCompany('Yogiyo','Yogiyo',ctr);
        insert cmp;

        // Create Add On
        List_Add_On__c addOn = UnitTestDataFactory.createAddOn(ctr.id,cmp.id,'test','Deal / Promotion','test');
        insert addOn;
    }

    @isTest
    Public static void testAddOnMapPopulation(){
        CtrAddOnManager manager = new CtrAddOnManager();
        System.assertEquals(1,manager.mapListAddOns.values().size());
    }

    @isTest
    Public static void testAddOnAddition(){
        CtrAddOnManager manager = new CtrAddOnManager();
        Country__c ctr = [Select id from Country__c Limit 1];
        Company__c cmp = [Select Id from Company__c limit 1];
        Test.startTest();
            manager.newAddOnItem.name   = 'test2';
            manager.selectedCountry     = ctr.id;
            manager.selectedCompany     = cmp.id;
            manager.newAddOnItem.type__c    = 'Deal / Promotion';
            manager.newAddOnItem.Contract_Addition__c = 'test';
            manager.addAddOn();
            manager.cancel();
        Test.stopTest();

        List<List_Add_On__c> addOns = [Select Id from List_Add_On__c];
        system.assertEquals(2,addOns.size());
    }

    @isTest
    Public static void testAddOnEdit(){
        List_Add_On__c addOn = [Select Id from List_Add_On__c limit 1];
        CtrAddOnManager manager = new CtrAddOnManager();
        manager.addOnId = addOn.id;
        manager.editItem();
        system.assertEquals(manager.newAddOnItem.id,addon.Id);
    }

    @isTest
    public static void testAddOnDeletion(){
        List_Add_On__c addOn = [Select Id from List_Add_On__c limit 1];
        CtrAddOnManager manager = new CtrAddOnManager();
        manager.addOnId = addOn.Id;
        manager.chooseAddOnToDelete();
        manager.deleteItem();
        List<List_Add_On__c> addOns = [Select Id from List_Add_On__c];
        system.assertEquals(0,addOns.size());
    }

}