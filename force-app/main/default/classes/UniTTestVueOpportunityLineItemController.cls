@isTest
public with sharing class UniTTestVueOpportunityLineItemController {
    private static Map<String, RecordType> mapRecordtypesKR = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Opportunity', 'Account', 'List_Product_Group__c', 'List_Product_Price__c', 'List_Service_Price__c', 'List_Add_On__c','Tarif__c', 'Tarif_Member__c', 'Tarif_Item__c', 'Opportunity_Line_Item__c'});
    
    @TestSetup
    public static void setupData(){
    	// create Country
    	Country__c c = UnitTestDataFactory.createCountry('UK', 'United Kingdom', 'GBP');
        insert c;
    	
    	// create country
    	Company__c com = UnitTestDataFactory.createCompany('Hungryhouse', 'uk', c);
        insert com;
    	
    	// Create commissions
    	List<List_Service_price__c> commissions = UnitTestDataFactory.createServices(com, c, 3,'UK_List_Service_Price',12,12,16, 8, 1,'Commission Fee', 
																						true, 0,'','Percentage', 'Commission Fee');
		
		Integer i=0;																					
		for(List_Service_Price__c comm : commissions){
			//comm.start_date__c = Date.today().addDays(10*i); 
		}
		insert commissions;
		
		// Create Product Group
    	List<List_Product_group__c> groups = UnitTestDataFactory.createProductGroups(Com, c, 1, 'UK_List_Product_Group');
    	insert groups;
    	
    	// Create Products
    	List<List_Product_price__c> products = UnitTestDataFactory.createProducts(com, c,groups[0].id, 2,'UK_List_Product_Price',
        																		0, true, 100, 1, false,20);
		insert products;
    	
    	// Create Add Ons
    	List<List_Add_On__c> addOns = UnitTestDataFactory.createAddOns(com,c,2,'UK_List_Add_On','test','Deal / Promotion',true);
    	insert addOns;
    }
    
    @isTest
    public static void testFetchCommissionDetails(){
    	List<List_Service_Price__c> comms = [Select Id from List_Service_price__c];
    	Test.startTest();
    		Tarif.Commission comm = VueOpportunityLineItemController.fetchCommissionDetails(comms[0].id);
    		System.assertNotEquals(comm,null);
    		
    		Tarif.Commission comm2 = VueOpportunityLineItemController.fetchCommissionDetails('');
    		System.assertNotEquals(comm2,null);
    	Test.stopTest();
    }
    
    @isTest
    public static void testFetchProducts(){
    	List<List_Product_Price__c> prods = [Select Id from List_Product_Price__c];
    	Test.startTest();
    		Tarif.Product prod = VueOpportunityLineItemController.fetchProductDetails(prods[0].id);
    		System.assertNotEquals(prod,null);
    		
    		Tarif.Product prod2 = VueOpportunityLineItemController.fetchProductDetails('');
    		System.assertNotEquals(prod2,null);
    	Test.stopTest();
    }
    
    @isTest
    public static void testFetchAddOns(){
    	List<List_Add_On__c> addOns = [Select Id from List_Add_On__c];
    	Test.startTest();
    		Tarif.AddOn addOn = VueOpportunityLineItemController.fetchAddOnDetails(addOns[0].id);
    		System.assertNotEquals(addOn,null);
    		 
    		Tarif.AddOn addOn2 = VueOpportunityLineItemController.fetchAddOnDetails('');
    		System.assertNotEquals(addOn2,null);
    	Test.stopTest();
    }
    
    @isTest
    public static void testEndDateCalculation(){
    	List<List_Service_Price__c> comms = [Select Id from List_Service_price__c];
    	List<Tarif.Commission> commissions = new List<Tarif.Commission>();
    	commissions.add(VueOpportunityLineItemController.fetchCommissionDetails(comms[0].id));
    	commissions.add(VueOpportunityLineItemController.fetchCommissionDetails(comms[1].id));
    	commissions.add(VueOpportunityLineItemController.fetchCommissionDetails(comms[2].id));
    	commissions[0].startDate = Date.today();
    	Commissions[1].startDate = Date.today().addDays(10);
    	commissions[2].startDate = null; 
    	
    	String serializedWrapper = JSON.serialize(commissions);
    	Test.startTest();
    		List<Tarif.Commission> commissions2 = VueOpportunityLineItemController.popuateEndDate(serializedWrapper);
    		System.assertEquals(commissions2[1].endDate,Date.today().addDays(9));
    		
    		// Same start Date should throw an error
    		commissions[0].startDate = Date.today();
    		Commissions[1].startDate = Date.today();
    		serializedWrapper = JSON.serialize(commissions);
    		try{
    			List<Tarif.Commission> commissions3 = VueOpportunityLineItemController.popuateEndDate(serializedWrapper);
    			System.assert(false);
    		}catch(Exception e){}
    	Test.stopTest();
    }
    
    @isTest
    public static void testFetchProductsFromGroup(){
    	List_product_group__c grp = [Select Id from List_Product_Group__c];
    	Test.startTest();
    		List<CtrOpportunityLineItems.option> options = VueOpportunityLineItemController.fetchProducts(grp.id);
    		System.assertEquals(2,options.size());
    	Test.stopTest();
    }
    
}