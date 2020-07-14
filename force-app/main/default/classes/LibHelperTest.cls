/**
* @author Krunoslav Bilicic
* @date 14.05.2020.
*
* @description Test for LibHelper class
*/
@IsTest
public class LibHelperTest {
    
    @testSetup 
    public static void setup() {
        
        Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Opportunity', 'Contract', 'Branding_Content__c'});
        UnitTestDataFactory.getRecordtypeValues();
        
        Country__c hkCountry = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'HKD');
        insert new List<Country__c> { hkCountry};
            
        Business_Config__c bc1 = UnitTestDataFactory.createBusinessConfig('AssetCreation','Process','AssetStatus','Delivered',hkCountry.Id,'FP_Opportunity_Quote_Line_Item',true,true);
        Business_Config__c bc2 = UnitTestDataFactory.createBusinessConfig('AssetCreation','Process','AssetRecordType','FP_Asset',hkCountry.Id,'FP_Opportunity_Quote_Line_Item',true,false);
        Business_Config__c bc3 = UnitTestDataFactory.createBusinessConfig('AssetCreation','Process','AssetStatusShipment','Delivered',hkCountry.Id,'FP_Opportunity_Quote_Line_Item',true,false);
        Business_Config__c bc4 = UnitTestDataFactory.createBusinessConfig('AssetCreation','Process','AssetStatus-Software','Delivered',hkCountry.Id,'FP_Opportunity_Quote_Line_Item',true,false);
        
        Business_Config__c bc11 = UnitTestDataFactory.createBusinessConfig('BrandingCreation','Process','BrandingContentRecordType','FP_Branding_Content',hkCountry.Id,'FP_Opportunity_Quote_Line_Item',true,true);
        Business_Config__c bc12 = UnitTestDataFactory.createBusinessConfig('BrandingCreation','Process','TemplateType','TRUE',hkCountry.Id,'FP_Opportunity_Quote_Line_Item',true,false);
        Business_Config__c bc13 = UnitTestDataFactory.createBusinessConfig('BrandingCreation','Process','DefaultBrandingQtyProdType','Packaging,Online Marketing',hkCountry.Id,'FP_Opportunity_Quote_Line_Item',true,false);
        Business_Config__c bc14 = UnitTestDataFactory.createBusinessConfig('BrandingCreation','Process','BrandingStatusShipment','Delivered',hkCountry.Id,'FP_Opportunity_Quote_Line_Item',true,false);
        Business_Config__c bc15 = UnitTestDataFactory.createBusinessConfig('BrandingCreation','Process','BrandingStatus','Delivered',hkCountry.Id,'FP_Opportunity_Quote_Line_Item',true,false);
        
        Business_Config__c bc21 = UnitTestDataFactory.createBusinessConfig('Opportunity Contract Process','Process','opportunity stage','Closed Won',hkCountry.Id,'FP_Opportunity',true,true);
        Business_Config__c bc22 = UnitTestDataFactory.createBusinessConfig('Opportunity Contract Process','Process','BrandingContentRecordType','FP_Branding_Content',hkCountry.Id,'FP_Opportunity',true,false);
        Business_Config__c bc23 = UnitTestDataFactory.createBusinessConfig('Opportunity Contract Process','Process','DefaultBrandingQtyProdType','Packaging,Online Marketing,Menu Printing',hkCountry.Id,'FP_Opportunity',true,false);
        
        
        insert new List<Business_Config__c> {bc1, bc2, bc3, bc4, bc11, bc12, bc13, bc14, bc15, bc21, bc22};

        Company__c com = UnitTestDataFactory.createCompany('Foodpanda', 'Hong Kong', hkCountry);
        insert com;

        Account acc1 = UnitTestDataFactory.createAccount('test1', hkCountry, 'FP_Account');
        
        insert acc1;
        
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = acc1.Id;
        testOpp.Name = 'test';
        testOpp.StageName = 'New';
        testOpp.CloseDate = Date.today();
        insert testOpp;
        
        List_Service_Price__c listServicePrice = UnitTestDataFactory.createService(com,hkCountry,'testService1','FP_List_Service_Price',12,12,25,5,null,true,null,'Commission Fee','ServiceType');
        listServicePrice.Based_On__c = 'Orders';
        listServicePrice.Commission_Type__c = 'Percentage';
        listServicePrice.Scaled__c = true;
        insert listServicePrice;
            
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=testOpp.Id, Status__c='Approved', Id_Account__c=testOpp.AccountId);
        insert newQuote;

        Opportunity_Line_Item__c oppService = UnitTestDataFactory.createOpportunityLineItemService('testService3',testOpp,listServicePrice.Id,true,'FP_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        insert oppService;

        List<Opportunity_Quote_Line_Item__c> oppQuoteLine =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,false,'FP_Opportunity_Quote_Line_Item',12,1,true, 0, Date.today(),'Commission Fee','Service');
        oppQuoteLine[0].Quantity__c = 1;
        oppQuoteLine[0].Delivery__c = 'Shipment';
        oppQuoteLine[0].Number_of_Copies__c = '1';
        oppQuoteLine[0].Size__c = 'A4';
        oppQuoteLine[0].Deposit_Method__c = 'Bank Transfer';
        oppQuoteLine[0].Weight__c = '130g';
        oppQuoteLine[0].Id_Opportunity__c=testOpp.Id;
        oppQuoteLine[0].Id_List_Service_Price__c=listServicePrice.Id;
        insert oppQuoteLine ;
        
        newQuote.Status__c = 'Accepted';
        update newQuote;
    }
    
    @isTest
    public static void checkForNonActiveAddonTest_Negative() { 
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'test' LIMIT 1];
        
        Set<Id> oppIds = new Set<Id>();
        oppIds.add(testOpp.Id);
        
        Test.startTest();
            Set<Id> oppsWithNonActive = LibHelper.checkForNonActiveAddon(oppIds);
        Test.stopTest();
        
        System.assertEquals(true, oppsWithNonActive.isEmpty(), 'No opps should be returned');
    }
    
    @isTest
    public static void checkForNonActiveAddonTest_null() { 
        Set<Id> oppIds = new Set<Id>();
        oppIds.add(null);
        
        Test.startTest();
            Set<Id> oppsWithNonActive = LibHelper.checkForNonActiveAddon(oppIds);
        Test.stopTest();
        
        System.assertEquals(true, oppsWithNonActive.isEmpty(), 'No opps should be returned');
    }

    @isTest
    public static void checkForNonActiveAddonTest_null2() { 
        Set<Id> oppIds = null;
        
        Test.startTest();
            Set<Id> oppsWithNonActive = LibHelper.checkForNonActiveAddon(oppIds);
        Test.stopTest();
        
        System.assertEquals(true, oppsWithNonActive.isEmpty(), 'No opps should be returned');
    }
    
    @isTest
    public static void checkForNonActiveAddonTest_Positive() { 
        Opportunity testOpp = [SELECT Id, AccountId FROM Opportunity WHERE Name = 'test' LIMIT 1];
        Add_on_service__c addOn = new Add_on_service__c();
        addOn.Opportunity__c = testOpp.Id;
        addOn.Account_Name__c = testOpp.AccountId;
        insert addOn;
        
        Set<Id> oppIds = new Set<Id>();
        oppIds.add(testOpp.Id);
        
        Test.startTest();
            Set<Id> oppsWithNonActive = LibHelper.checkForNonActiveAddon(oppIds);
        Test.stopTest();
        
        System.assertEquals(true, oppsWithNonActive.contains(testOpp.Id), 'One exact opp should be returned');
    }
    
    @isTest
    public static void checkForOpenPhotoListingCasesTest() {
        Opportunity testOpp = [SELECT Id, AccountId FROM Opportunity WHERE Name = 'test' LIMIT 1];
        Set<Id> oppWithOpenPLcases = LibHelper.checkForOpenPhotoListingCases(new Set<Id> { testOpp.Id });
        
        System.assertEquals(0, oppWithOpenPLCases.size(), 'Returned set should be empty');
    }
    
    @isTest
    public static void createAssetsTest() {
        List<Opportunity_Quote_Line_Item__c> oppQuoteLineData = [SELECT Name, Id_List_Product_Price__c, Id_List_Product_Price__r.Product_Type__c, Source_GRID__c,Delivery__c,
                                                                 Id, Id_Opportunity__c, RecordType.DeveloperName, Id_Opportunity__r.OwnerId, Id_Opportunity_Quote__r.Id_Account__c,
                                                                 Id_Opportunity__r.Account.GRID__c, CurrencyIsoCode, Quantity__c, Id_Opportunity_Quote__c
                                                                 FROM Opportunity_Quote_Line_Item__c];
            
        Test.startTest();
            LibHelper.createAssets(oppQuoteLineData, null);
        Test.stopTest();
        
        List<Asset__c> aList = [SELECT Id FROM Asset__c];
        
        System.assertEquals(1, aList.size(), 'Asset was not created');
    }
    
    @isTest
    public static void createBrandingTest() {
        List<Opportunity_Quote_Line_Item__c> oppQuoteLineData = [SELECT Name, Id_List_Product_Price__c, Id_List_Product_Price__r.Product_Type__c, Source_GRID__c,Delivery__c,
                                                                 Id, Id_Opportunity__c, RecordType.DeveloperName, Id_Opportunity__r.OwnerId, Id_Opportunity_Quote__r.Id_Account__c,
                                                                 Id_Opportunity__r.Account.GRID__c, CurrencyIsoCode, Quantity__c, Id_Opportunity_Quote__c,Number_of_Copies__c, Size__c,
                                                                 weight__c, Deposit_Method__c, Id_List_Product_Price__r.Product_Name__c
                                                                 FROM Opportunity_Quote_Line_Item__c];
        
        Test.startTest();
            LibHelper.createBranding(oppQuoteLineData, null);
        Test.stopTest();
        
        List<Branding_Content__c> brList = [SELECT Id FROM Branding_Content__c];
        
        System.assertEquals(1, brList.size(), 'Branding was not created');
    }
    
    @isTest
    public static void createBrandingRecordTest() {
        List<Opportunity_Quote_Line_Item__c> oppQuoteLineData = [SELECT Name, Id_List_Product_Price__c, Id_List_Product_Price__r.Product_Type__c, Source_GRID__c,Delivery__c,
                                                                 Id, Id_Opportunity__c, RecordType.DeveloperName, Id_Opportunity__r.OwnerId, Id_Opportunity_Quote__r.Id_Account__c,
                                                                 Id_Opportunity__r.Account.GRID__c, CurrencyIsoCode, Quantity__c, Id_Opportunity_Quote__c, Number_of_Copies__c, Size__c,
                                                                 weight__c, Deposit_Method__c, Id_List_Product_Price__r.Product_Name__c
                                                                 FROM Opportunity_Quote_Line_Item__c];
        Country__c hkCountry = [SELECT Id, Name FROM Country__C WHERE Name = 'Hong Kong'];
        
        List<Branding_Content__c> listBranding = new List<Branding_Content__c>();
        
        Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic   = moam.get('Opportunity Contract Process');
        Map<String, Business_Config__c> mapBusinessRules  = new Map<String, Business_Config__c>();
        mapBusinessRules.put('BrandingContentRecordType', UnitTestDataFactory.createBusinessConfig('Opportunity Contract Process','Process','BrandingContentRecordType','FP_Branding_Content',hkCountry.Id,'FP_Opportunity',true,false));
        
        Test.startTest();
            LibHelper.createBrandingRecord(oppQuoteLineData[0], listBranding, mapBusinessRules, new Map<ID,Shipment_Order_Line_Item__c>());
        Test.stopTest();
        
        System.assertEquals(1, listBranding.size(), 'Branding was not created');
        
    }
}