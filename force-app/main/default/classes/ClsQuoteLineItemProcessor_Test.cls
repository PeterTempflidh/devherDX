@IsTest
public class ClsQuoteLineItemProcessor_Test {
	
    @testSetup 
    static void setup() {
        // CREATE COUNTRY
        Country__c fi = UnitTestDataFactory.createCountry('FI', 'Finland', 'EUR');
        insert fi;

        // CREATE COMPANY
        Company__c com = UnitTestDataFactory.createCompany('PizzaOnline_FI', 'FI', fi);
        insert com;

        // CREATE BUSINESS CONFIGS 
        List<Business_Config__c> businessConfigList = new List<Business_Config__c>();
        Business_Config__c bConfigParent 
            = UnitTestDataFactory.createBusinessConfig(
                'nintexQuoteFilters', 
                'Process',
                'Business_Type__c:New Business;Type:Contract Only', 
                'FI Quote - New Business 1', 
                fi.Id, 
                'FI_Opportunity', 
                true, 
                true);

        Map<String, String> childBRuleMap = new Map<String, String>{
            'Business_Type__c:New Business;Type:Contract Only' => 'FI Quote - New Business 1',
            'Business_Type__c:New Business;Type:Contract & Product' => 'FI Quote - New Business 1',
            'Business_Type__c:Upgrade/Upsell;Type:Product Only' => 'FI Quote - New Business 2',
            'Business_Type__c:Upgrade/Upsell;Type:Product Only;Opportunity_Quote_Line_Item__c:{"Line_Item_Type__c"="Product", "Sub_Type__c"="Premium Listing"}' => 'FI Quote - Premium Listing',
            'Business_Type__c:Upgrade/Upsell;Type:Product Only;Opportunity_Quote_Line_Item__c:{"Line_Item_Type__c"="Product", "Sub_Type__c"="Merchandise"}' => 'FI Quote - Merchandise'
        };

        businessConfigList.add(bConfigParent);
        for(String key : childBRuleMap.keySet()){
            Business_Config__c bConfigTemp = UnitTestDataFactory.createBusinessConfig(
                'nintexQuoteFilters', 'Process', key, childBRuleMap.get(key), fi.Id, 'FI_Opportunity', true, false);
            bConfigTemp.Is_Active__c = true;
            businessConfigList.add(bConfigTemp);
        }

        insert businessConfigList;

        // CREATE LIST PRODUCT GROUP
        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com, fi , 'Merchandise', 'FI_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com, fi , 'Add. Charges', 'FI_List_Product_Group');

        insert new List<List_Product_Group__c> {lpg, lpg1};

        // CREATE LIST PRODUCT PRICE
        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com, fi , 'DH Jacket', lpg.Id, 'FI_List_Product_Price', 1, true, 100, 1, false, 20);
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com, fi , 'Premium Placement', lpg1.Id, 'FI_List_Product_Price', 1, true, 100, 1, false, 20);
        lpp.Product_Type__c = 'Merchandise';
        lpp1.Product_Type__c = 'Premium Listing';
        lpp.Requires_Branding__c = false;
        lpp.Requires_Asset__c = false;
        lpp.Requires_Add_On__c = true;

        insert new List<List_Product_Price__c> {lpp1, lpp};
    }
    
    /*******************************************************************************************************
    * @description test for updating Quote Type in Opportunity Quote
    */
    @IsTest
    public static void testUpdateQuoteType(){
        UnitTestDataFactory.getRecordtypeValues();

        Country__c fi = [SELECT Id, Name, CurrencyIsoCode FROM Country__c WHERE Name = 'Finland'];
        Company__c com = [SELECT Id, Name FROM Company__c WHERE Country__c =: fi.Id];
        
        List<List_Product_Price__c> listProductPriceList = [SELECT Id, Name, Product_Type__c, Id_List_Product_Group__c
                                                            FROM List_Product_Price__c];
        Map<Id, List_Product_Group__c> listProductGroupMap = new Map<Id, List_Product_Group__c>(
            [SELECT Id, Name
             FROM List_Product_Group__c]
        );

        // CREATE ACCOUNT
        Account acc = new Account();
        acc = UnitTestDataFactory.createAccount('Test FI Account 1', fi, 'FP_Account');
        insert acc;

        //CREATE CONTACT
        List<Contact> conList = UnitTestDataFactory.createContacts(new List<Account>{acc}, 'FI Contact', 'Test', '', 'Owner', 1, 'testFPContact', 'FP_Contact');
        insert conList;

        // CREATE OPPORTUNITY
        Opportunity opportunity;
        List<Opportunity> opportunityList = new List<Opportunity>();
        for(Integer counter = 0; counter < 2; counter++){
            opportunity = UnitTestDataFactory.createOpportunity(acc.Name + ' ' + (counter + 1), acc, 'FI_Opportunity', Date.today());
            opportunity.Business_Type__c = 'Upgrade/Upsell';
            opportunity.Type = 'Product Only';
            opportunityList.add(opportunity);
        }
        
        insert opportunityList;

        // CREATE OPPORTUNITY QUOTE
        Opportunity_Quote__c oppQuoteTemp;
        List<Opportunity_Quote__c> oppQuoteList = new List<Opportunity_Quote__c>();
        for(Opportunity oppTemp : opportunityList){
            oppQuoteTemp = new Opportunity_Quote__c(Id_Opportunity__c = oppTemp.Id, Status__c = 'Accepted');
            oppQuoteTemp.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue('FI_Opportunity_Quote');
            oppQuoteTemp.Id_Account__c = acc.Id;
            oppQuoteList.add(oppQuoteTemp);
        }
        
        insert oppQuoteList;

        // CREATE OPPORTUNITY QUOTE LINE ITEM
        Opportunity_Quote_Line_Item__c oppQuoteLineItemTemp;
        List<Opportunity_Quote_Line_Item__c> oppQuoteLineItemList = new List<Opportunity_Quote_Line_Item__c>();
        Integer counter = 0;
        for(Opportunity_Quote__c oppQuoteLoop : oppQuoteList){
            oppQuoteLineItemTemp = UnitTestDataFactory.createOpportunityQuoteLineItems(oppQuoteLoop, listProductPriceList[counter].Id, listProductGroupMap.get(listProductPriceList[counter].Id_List_Product_Group__c).Id, 4, true, 'FI_Opportunity_Quote_Line_Item', 1, '20', 200.0, 2, 300.0, 'Product')[0];
            oppQuoteLineItemTemp.Id_Opportunity__c = oppQuoteLoop.Id_Opportunity__c;
            oppQuoteLineItemTemp.Sub_Type__c = listProductPriceList[counter++].Product_Type__c;

            oppQuoteLineItemList.add(oppQuoteLineItemTemp);
        }

        Test.startTest();
            insert oppQuoteLineItemList;
        Test.stopTest();

        oppQuoteList = [SELECT Id, Name, Quote_Type__c FROM Opportunity_Quote__c];
        
        for(Opportunity_Quote__c oppQuote : oppQuoteList){
            if(oppQuote.Quote_Type__c != 'FI Quote - Merchandise' && oppQuote.Quote_Type__c != 'FI Quote - Premium Listing'){
                system.assert(false, 'Quote Type not correctly updated; ' + oppQuote.Quote_Type__c);
            }
        }
    }
}