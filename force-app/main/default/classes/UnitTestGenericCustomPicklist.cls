/*
@author : Aleksejs Jedamenko
@reviewer : 
@creation : 22.10.2019
*/
/**
 * This class contains unit tests for GenericCustomPicklist_AuraController class
 *
 * GenericCustomPicklist_AuraController contains 2 aura enabled methods which are tested here separately. 
 * for both methods we test positive an negative scenario
 */
@isTest
public class UnitTestGenericCustomPicklist {
	
    @testSetup 
    static void setup() {
    	
    	Country__c testCountry = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'HKD');
        insert testCountry;
        RecordType testAccountRecordType = UnitTestDataFactory.getRecordType('FP_Account');
        RecordType testOpptyQuoteRecordType = UnitTestDataFactory.getRecordType('FP_Opportunity_Quote');
        RecordType testContactRecordType = UnitTestDataFactory.getRecordType('FP_Contact');
        RecordType testOpptyRecordType = UnitTestDataFactory.getRecordType('FP_Opportunity');
        RecordType testStockItemRecordType = UnitTestDataFactory.getRecordType('UK_Stock_Item');
        RecordType testAssetRecordType = UnitTestDataFactory.getRecordType('FP_Asset');
        RecordType testProductGroupRecordType =  UnitTestDataFactory.getRecordType('FP_List_Product_Group');
        RecordType testProductPriceRecordType =  UnitTestDataFactory.getRecordType('FP_List_Product_Price');
        RecordType testAdditionalChargesRecordType =  UnitTestDataFactory.getRecordType('FP_Additional_Charges');
        system.debug('record type id: '+testAdditionalChargesRecordType.Id);
        List<RecordType__c> customSettings = new List<RecordType__c>();
        customSettings.add(new RecordType__c(Name = testAccountRecordType.Id,
                                                     Value__c = 'FP_Account'));
        customSettings.add(new RecordType__c(Name = testOpptyQuoteRecordType.Id,
                                                     Value__c = 'FP_Opportunity_Quote'));
        customSettings.add(new RecordType__c(Name = testContactRecordType.Id,
                                                     Value__c = 'FP_Contact'));
        customSettings.add(new RecordType__c(Name = testOpptyRecordType.Id,
                                                     Value__c = 'FP_Opportunity'));
        customSettings.add(new RecordType__c(Name = testStockItemRecordType.Id,
                                                     Value__c = 'UK_Stock_Item'));
        customSettings.add(new RecordType__c(Name = testAssetRecordType.Id,
                                                     Value__c = 'FP_Asset'));
        customSettings.add(new RecordType__c(Name = testProductGroupRecordType.Id,
                                                     Value__c = 'FP_List_Product_Group'));
        customSettings.add(new RecordType__c(Name = testProductPriceRecordType.Id,
                                                     Value__c = 'FP_List_Product_Price'));
        customSettings.add(new RecordType__c(Name = testAdditionalChargesRecordType.Id,
                                                     Value__c = 'FP_Additional_Charges'));
		insert customSettings;
        List<RecordType__c> additionalSettings = new List<RecordType__c>();
        additionalSettings.add(new RecordType__c(Name = 'FP_Account',
                                                     Value__c = customSettings[0].Id));
        insert additionalSettings;
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(UnitTestDataFactory.createAccount('testacc', testCountry, 'FP_Account'));
        testAccounts[0].Phone = '+85265541700';
        insert testAccounts;
        Opportunity testOpp = UnitTestDataFactory.createOpportunity('test',testAccounts[0],'FP_Opportunity', Date.today()); 
        testOpp.Business_Type__c = 'New Business';
        insert testOpp;
        List<Contact> testContacts1 = UnitTestDataFactory.createContacts(testAccounts, 'TestSoname1','TestName1', 'Mr.','Owner', 1, 'testcontact1', 'FP_Contact'); 
        List<Contact> testContacts2 = UnitTestDataFactory.createContacts(testAccounts, 'TestSoname2','TestName2', 'Mr.','Manager', 1, 'testcontact2', 'FP_Contact');
        testContacts1.addAll(testContacts2);
        insert testContacts1;
        List<Business_Config__c> dcList = new List<Business_Config__c>();
        dcList.add(UnitTestDataFactory.createBusinessConfig('CustomPicklistSettings', 'Process', 'ProductForAdditionalCharges', 
        '{"fieldToDisplay": "Displayed_Name__c","fieldToUpdate": "Product__c","picklistCustomLabel": "Custom_Picklist_Product_Title", "isPleaseSelectOptionDisplayed": true, "isNoneOptionDisplayed": false, "isMessageDisplayed": true, "messageTitleCustomLabel": "Custom_Picklist_Product_Messege_Title", "messageBodyCustomLabel" : "Custom_Picklist_Product_Message","messageSeverity" : "warning","SOQLQuery" : "Select id, Displayed_Name__c,Id_List_Product_Group__r.name from List_Product_Price__c where RecordType.Name = \'FP List Product Price\'"}', String.valueOf(testCountry.Id), 'FP_Additional_Charges', true, true));
        dcList.add(UnitTestDataFactory.createBusinessConfig('populateFieldsAfterProductUpdate','Process','ListProductPriceRecordType','FP_List_Product_Price', String.valueOf(testCountry.Id), 'FP_Additional_Charges', true, true));
        insert dcList; 
        List<Opportunity_Quote__c> testQuote = UnitTestDataFactory.createOpportunityQuotes(testOpp, 1, 'FP_Opportunity_Quote', 'Draft', 'test description', 100.00, 110.00, '','',10.00);
        testQuote[0].Quote_Type__c = 'Contract Amendment'; 
        testQuote[0].RecordType = testOpptyQuoteRecordType; 
        insert testQuote;
        List<Consignment__c> testConsigments = UnitTestDataFactory.createConsignments(1, false, 'Ordered', 'Supplier A', 'google.com');
        insert testConsigments;
        List<Stock_Item__c> testStockItems = UnitTestDataFactory.createStockItems(2, 'UK_Stock_Item',testAccounts[0] , testConsigments[0], 'A - New', date.today().addDays(-2),date.today().addDays(-1), date.today().addDays(-10),
        '2445452', '+852342232333', 'SKT', 'Ordered', 'test');
        insert testStockItems;
        List<Asset__c> testAssets = UnitTestDataFactory.createAssets(1, testAccounts[0], testOpp, date.today().addDays(-1), true, testStockItems[0], testStockItems[1], 'FP_Asset',
        '2242342323', '2', '2',  date.today().addDays(-2), date.today().addDays(-2), 'En Route', true, 'Delivery refused', 'test info', 'test info', 
        'Invalid', date.today().addDays(2), 'DH Staff', '2342234342', 'Arrange Pick up');
        insert testAssets;
        Company__c testCompany = UnitTestDataFactory.createCompany('Tset Company', '1111111', testCountry);
        insert testCompany;
        List<List_Product_Group__c> testProductGroup = UnitTestDataFactory.createProductGroups(testCompany, testCountry, 1, 'FP_List_Product_Group');
        insert testProductGroup; 
        List_Product_Price__c testProductPrice = UnitTestDataFactory.createProduct(testCompany, testCountry, 'LPP-999999', testProductGroup[0].Id, 'FP_List_Product_Price', 6, true, 100.00, 1, false, 25.00);
        testProductPrice.Displayed_Name__c = 'test value';
        insert testProductPrice;
        List<Additional_Charges__c> testCharges = UnitTestDataFactory.createAdditionalChargesWithRecordType(testAccounts[0], testAssets[0], testOpp, testQuote[0], testProductPrice, testProductGroup[0] ,
           '25' , 1, 100.00, 10, 100.00, 1, testAdditionalChargesRecordType.Id, date.today().addDays(3));
        insert testCharges;
       
    }
    
    @isTest
    static void positiveScenarioGetDataTest(){
        
        List<Additional_Charges__c> additionalCharges = [SELECT Id, RecordTypeId, Product__c FROM Additional_Charges__c LIMIT 1];
        Test.startTest();
        String stringifiedResult = GenericCustomPicklist_AuraController.getDataFromBusinessConfig('ProductForAdditionalCharges', additionalCharges[0].Id, 'Additional_Charges__c');
        GenericCustomPicklist_AuraController.BusinessConfigWrapperToSend resultWrapper = (GenericCustomPicklist_AuraController.BusinessConfigWrapperToSend)JSON.deserialize(stringifiedResult, GenericCustomPicklist_AuraController.BusinessConfigWrapperToSend.class);
        Test.stopTest();
        system.assertEquals('Displayed_Name__c',resultWrapper.fieldToDisplay);
        system.assertEquals('Product__c',resultWrapper.fieldToUpdate);
        system.assertEquals('Custom_Picklist_Product_Title',resultWrapper.picklistCustomLabel);
        system.assertEquals('Custom_Picklist_Product_Messege_Title',resultWrapper.messageTitleCustomLabel);
        system.assertEquals('Custom_Picklist_Product_Message',resultWrapper.messageBodyCustomLabel);
        system.assertEquals('warning',resultWrapper.messageSeverity);
        system.assertEquals(additionalCharges[0].Product__c, resultWrapper.currentValue);
        system.assert(resultWrapper.isPleaseSelectOptionDisplayed);
        system.assert(resultWrapper.isMessageDisplayed);
        system.assert(!resultWrapper.isNoneOptionDisplayed);
        system.assert(resultWrapper.picklistData.size()>0);

    }
    
    @isTest
    static void negativeScenarioGetDataTest(){
    	
        List<Business_Config__c> businessConfig = [SELECT Id FROM Business_Config__c LIMIT 1];
        delete businessConfig;
        List<Additional_Charges__c> additionalCharges = [SELECT Id, RecordTypeId, Product__c FROM Additional_Charges__c LIMIT 1];
        Test.startTest();
        String stringifiedResult = GenericCustomPicklist_AuraController.getDataFromBusinessConfig('ProductForAdditionalCharges', additionalCharges[0].Id, 'Additional_Charges__c');
        Test.stopTest();
        JSONParser parser = JSON.createParser(stringifiedResult);
        parser.nextToken();
        parser.nextToken();
       	system.assertEquals('error',parser.getText());
        parser.nextToken();
        system.assertEquals(System.Label.Custom_Picklist_No_Business_Config_Error_Message,parser.getText());
    }
    
    @isTest
    static void positiveScenarioSaveValue(){
     
         List<Additional_Charges__c> additionalCharges = [SELECT Id, RecordTypeId, Product__c FROM Additional_Charges__c LIMIT 1];
         Test.startTest();
         String saveResult = GenericCustomPicklist_AuraController.saveSelectedValue('test value', 'Product__c', additionalCharges[0].Id, 'Additional_Charges__c');
         List<Additional_Charges__c> additionalChargesAfterUpdate = [SELECT Id, RecordTypeId, Product__c, Product_Group__c FROM Additional_Charges__c LIMIT 1];
         Test.stopTest();
         system.assertEquals('OK',saveResult);
         system.assertEquals('Test_Product_Group_0', additionalChargesAfterUpdate[0].Product_Group__c);
    }
    
    @isTest
    static void negativeScenarioSaveValue(){
     
         List<Additional_Charges__c> additionalCharges = [SELECT Id, RecordTypeId, Product__c FROM Additional_Charges__c LIMIT 1];
         String testRecordId = additionalCharges[0].Id;
         delete additionalCharges;
         Test.startTest();
         String saveResult = GenericCustomPicklist_AuraController.saveSelectedValue('test value', 'Product__c', testRecordId, 'Additional_Charges__c');
         Test.stopTest();
         system.assertNotEquals('OK',saveResult);
    }
}