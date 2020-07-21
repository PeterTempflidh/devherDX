@isTest
public with sharing class ListProductPriceSelector_Test {
    @TestSetup
    public static void setUpData(){
        // create RecordType__c custom setting
        UnitTestDataFactory.getRecordtypeValues();	
        
        // create Country
        Country__c HKCoutry = UnitTestDataFactory.createCountry('HK','Hong Kong', 'HKD');
        insert HKCoutry;
        
        // create company
        Company__c com = UnitTestDataFactory.createCompany('Hungryhouse', 'uk', HKCoutry);
        insert com;

                
        // Create commissions
        List<List_Service_price__c> commissions = UnitTestDataFactory.createServices(com, HKCoutry, 3,'FP_List_Service_Price',12,12,16, 8, 1,'Commission Fee', 
                                                                                     true, 0,'','Percentage', 'Commission Fee');
        
        insert commissions;
        
        // Create Product Group
        List<List_Product_group__c> groups = UnitTestDataFactory.createProductGroups(Com, HKCoutry, 1, 'FP_List_Product_Group');
        insert groups;
        
        // Create Products
        List<List_Product_price__c> products = UnitTestDataFactory.createProducts(com, HKCoutry,groups[0].id, 2,'FP_List_Product_Price',
                                                                                  0, true, 100, 1, false,20);
        insert products;
        
    }
    
    @isTest
    public static void TestAll(){
        List<List_Product_Price__c> lppList = ListProductPriceSelector.findListProdPriceByrecTypeandCountry('FP_List_Product_Price','Hong Kong');
        ListProductPriceSelector.getListProductPriceRecordsFilteredByRecordTtype(new Set<String>{},new Set<String>{});
        ListProductPriceSelector.getActiveProductsById(new List<Id>{});
        System.assertEquals(False, lppList.isEmpty());
    }
}