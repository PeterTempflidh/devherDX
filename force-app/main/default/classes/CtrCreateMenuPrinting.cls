global with sharing class CtrCreateMenuPrinting {
    public CtrCreateMenuPrinting() {}
    public CtrCreateMenuPrinting(ApexPages.StandardController controller) {}

    // Method for populating ProductName column in Additional Charges & Assets table
    @RemoteAction
    global static Map<Id, String> getMenuPrintingProducts(String country){
        Map<Id, String> options = new Map<Id, String>();
        for(List_Product_Price__c productPrice : [SELECT Id, Product_Name__c FROM List_Product_Price__c WHERE Product_Type__c = 'Menu Printing' AND Is_Active__c = true AND Id_Country__r.Name = :country]) {
            options.put(productPrice.Id, productPrice.Product_Name__c);
        }        
        return options;
    }

    @RemoteAction
    global static Map<String, String> getSizes(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult size = Opportunity_Line_Item__c.Size__c.getDescribe();

        List<Schema.PicklistEntry> sizeValues = size.getPicklistValues();
        for(Schema.PicklistEntry picklist : sizeValues) {
            options.put(picklist.getLabel(), picklist.getValue());
        }
        return options;
    }

    @RemoteAction
    global static Map<String, String> getWeights(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult size = Opportunity_Line_Item__c.Weight__c.getDescribe();

        List<Schema.PicklistEntry> sizeValues = size.getPicklistValues();
        for(Schema.PicklistEntry picklist : sizeValues) {
            options.put(picklist.getLabel(), picklist.getValue());
        }
        return options;
    }


    @RemoteAction
    global static Map<String, String> getNumberOfCopies(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult size = Opportunity_Line_Item__c.Number_of_Copies__c.getDescribe();

        List<Schema.PicklistEntry> sizeValues = size.getPicklistValues();
        for(Schema.PicklistEntry picklist : sizeValues) {
            options.put(picklist.getLabel(), picklist.getValue());
        }
        return options;
    }

    @RemoteAction
    global static Map<String, String> getDepositMethods(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult size = Opportunity_Line_Item__c.Deposit_Method__c.getDescribe();

        List<Schema.PicklistEntry> sizeValues = size.getPicklistValues();
        for(Schema.PicklistEntry picklist : sizeValues) {
            options.put(picklist.getLabel(), picklist.getValue());
        }
        return options;
    }

    @RemoteAction
    global static List<opportunity_Quote_Line_Item__c> saveMenuPrinting(List<String> products, String country, String accId) {
        List<Opportunity_Line_Item__c> oppLineItemList =new  List<Opportunity_Line_Item__c>();
        List<opportunity_Quote_Line_Item__c> oppQuoteLineItemList =new  List<opportunity_Quote_Line_Item__c>();

        Tarif__c tarif = [SELECT Id FROM Tarif__c WHERE Id_Country__r.Name = :country AND Name = 'Menu Printing'];
        Opportunity opp = new Opportunity();
        opp.AccountId = accId;
        opp.CloseDate = Date.today();
        opp.StageName = 'Prospecting';
        opp.Name = 'Menu Printing';
        opp.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue('UK_Opportunity');
        opp.Id_Tarif__c = tarif.Id;
        insert opp;

        //Opportunity opp = [SELECT Id, Id_Tarif__c, CurrencyIsoCode, AccountId FROM Opportunity WHERE Id = :oppId];

        if(!products.isEmpty()) {
            // CREATE QUOTE
            Opportunity_Quote__c oppQuote = new Opportunity_Quote__c();
            oppQuote.recordtypeId = LibRecordTypeHelper.getRecordTypeValue('UK_Opportunity_Quote');
            oppQuote.Id_Opportunity__c = opp.Id;
            oppQuote.CurrencyIsoCode = opp.CurrencyIsoCode;
            oppQuote.Status__c = 'Approved';
            oppQuote.Id_Account__c = opp.accountId;
            oppQuote.Template_Name__c = 'UK_QuoteVFTemplate_Unique';

            insert oppQuote;


            for(String product : products) {
                String[] oppProdLineItems = product.split(';');
                            //oppLineItemList = new List <Opportunity_Line_Item__c>();
                System.debug('RIJAD: ' + decimal.valueOf(oppProdLineItems[8]));
                oppLineItemList.add(new Opportunity_Line_Item__c(
                    Id_Opportunity__c = opp.Id, 
                    Name = oppProdLineItems[0], 
                    Size__c = oppProdLineItems[1],
                    Weight__c = oppProdLineItems[2],
                    Number_of_Copies__c =oppProdLineItems[3],
                    Listed_Price__c = oppProdLineItems[4] != null ? Decimal.valueOf(oppProdLineItems[4]) : null,
                    Deposit_Method__c = oppProdLineItems[5],
                    Deposit__c = oppProdLineItems[6] != null ? Decimal.valueOf(oppProdLineItems[6]) : null,
                    Design_Note__c = oppProdLineItems[7],
                    Total_Amount__c = oppProdLineItems[8] != null ? Decimal.valueOf(oppProdLineItems[8]) : null,
                    Id_List_Price_Product__c = oppProdLineItems[9],
                    Sub_Type__c = 'Menu Printing',
                    Quantity__c=1,
                    Line_Item_Type__c = 'Product'));
                
                oppQuoteLineItemList.add(new Opportunity_Quote_Line_Item__c(
                    Id_Opportunity__c = opp.Id, 
                    Name = oppProdLineItems[0], 
                    Size__c = oppProdLineItems[1],
                    Weight__c = oppProdLineItems[2],
                    Number_of_Copies__c =oppProdLineItems[3],
                    Listed_Price__c = oppProdLineItems[4] != null ? Decimal.valueOf(oppProdLineItems[4]) : null,
                    Deposit_Method__c = oppProdLineItems[5],
                    Deposit__c = oppProdLineItems[6] != null ? Decimal.valueOf(oppProdLineItems[6]) : null,
                    Design_Note__c = oppProdLineItems[7],
                    Total_Amount__c = 0,
                    Quantity__c=1,
                    Id_List_Product_Price__c = oppProdLineItems[9],
                    Line_Item_Type__c = 'Product',
                    Sub_Type__c = 'Menu Printing',
                    Id_Opportunity_Quote__c = oppQuote.Id));
            }

            if(!oppLineItemList.isEmpty()) {
                
                insert oppLineItemList;
                insert oppQuoteLineItemList;

            }
            return oppQuoteLineItemList;
        }
        return null;

    }

    @RemoteAction
    global static String setTotalAmountForOppQuoteLineItems(List<String> products, List<opportunity_Quote_Line_Item__c> oppQuoteLineItemList) {
        //for(String product : products) {
            //String[] oppProdLineItems = product.split(';');
            for(opportunity_Quote_Line_Item__c opqli : oppQuoteLineItemList) {
                 opqli.Total_Amount__c = opqli.Listed_Price__c;
            }
        //}
        
        update oppQuoteLineItemList;
        
        return oppQuoteLineItemList[0].Id_Opportunity_Quote__c;

    }
}