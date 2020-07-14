global with sharing class CtrCreateBladeSign {
    public static List<Opportunity_Line_Item__c> opliList { get; set; }
    public CtrCreateBladeSign() {}
    public CtrCreateBladeSign(ApexPages.StandardController controller) {}

    // Method for populating ProductGroup column in Additional Charges & Assets table
    
   
    @RemoteAction
    global static Map<Id, String> getProductGroups(String countryName){
        Map<Id, String> options = new Map<Id, String>();
        Set<String> productGrpSet=new set<String>();
        String prodGroups= UpgradeProduct__c.getValues('United Kingdom').List_Product_Group__c;
        if(prodGroups.contains(','))
            productGrpSet=new Set<string>(prodGroups.split(','));
        else
            productGrpSet.add(prodGroups);
        for(List_Product_Group__c lpg : [SELECT Id, Name FROM List_Product_Group__c WHERE Id_Country__r.Name = :countryName AND Name != :productGrpSet]){
            options.put(lpg.Id, lpg.Name);
        }
        return options;
    }

    // Method for populating ProductName column in Additional Charges & Assets table
    @RemoteAction
    global static Map<Id, String> getBladeSignProducts(String country, String productGroup){
        Map<Id, String> options = new Map<Id, String>();
        Set<String> productPriceSet=new set<String>();
        String prodPrice= UpgradeProduct__c.getValues('United Kingdom').List_Product_Price__c;
        if(prodPrice.contains(','))
            productPriceSet=new Set<String>(prodPrice.split(','));
        else
            productPriceSet.add(prodPrice);
        for(List_Product_Price__c productPrice : [SELECT Id, Product_Name__c FROM List_Product_Price__c WHERE Id_List_Product_Group__c = :productGroup AND Is_Active__c = true AND Id_Country__r.Name = :country AND Product_Name__c != :prodPrice]) {
            options.put(productPrice.Id, productPrice.Product_Name__c);
        }        
        return options;
    }

       // Populate fields based on the selected Product Name 
    @RemoteAction
    global static List_Product_Price__c getValuesRelatedToSelectedProductName(String selectedProductNameId) {
        List_Product_Price__c productPrice = new List_Product_Price__c();
        if(selectedProductNameId != null && selectedProductNameId != '') {
            productPrice = [SELECT Id, Id_List_Product_Group__r.Name, Unapproved_Discount_Limit__c, Maximum_discount__c, Default_Quantity__c, Installments__c, Is_Active__c, Product_Name__c, List_Price__c,Product_Type__c 
                        FROM List_Product_Price__c 
                        WHERE Id = :selectedProductNameId];
            return productPrice;
        } else return null;
               
    }

    @RemoteAction
    global static List<opportunity_Quote_Line_Item__c> saveBladeSign(List<String> products, String country, String accId) {
        List<Opportunity_Line_Item__c> oppLineItemList =new  List<Opportunity_Line_Item__c>();
        List<opportunity_Quote_Line_Item__c> oppQuoteLineItemList =new  List<opportunity_Quote_Line_Item__c>();
        Savepoint sp = Database.setSavepoint();

       //Tarif__c tarif = [SELECT Id FROM Tarif__c WHERE Id_Country__r.Name = :country AND Name = 'Menu Printing'];
        Opportunity opp = new Opportunity();
        opp.AccountId = accId;
        opp.CloseDate = Date.today();
        opp.StageName = 'Prospecting';
        opp.Name = 'Branding';
        opp.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue('UK_Opportunity');
        //opp.Id_Tarif__c = tarif.Id;
        insert opp;

        //Opportunity opp = [SELECT Id, Id_Tarif__c, CurrencyIsoCode, AccountId FROM Opportunity WHERE Id = :oppId];

        if(!products.isEmpty()) {
            try {
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
                    System.debug('@@@ RIJAD: ' + product);
                    String product2 = product.replace('&amp;', '&');
                    System.debug('@@@ RIJAD2: ' + product2);
                    String[] oppProdLineItems = product2.split(';');
                                //oppLineItemList = new List <Opportunity_Line_Item__c>();
                    oppLineItemList.add(new Opportunity_Line_Item__c(
                        Id_Opportunity__c = opp.Id, 
                        Product_Group__c = oppProdLineItems[0],
                        Name = oppProdLineItems[1], 
                        Listed_Price__c = oppProdLineItems[2] != null ? Decimal.valueOf(oppProdLineItems[2]) : null,
                        Discount__c = oppProdLineItems[3],
                        Quantity__c = oppProdLineItems[4] != null ? Decimal.valueOf(oppProdLineItems[4]) : null,
                        Installments__c = oppProdLineItems[5] != null ? Decimal.valueOf(oppProdLineItems[5]) : 1,
                        Total_Amount__c = oppProdLineItems[6]  != null ? Decimal.valueOf(oppProdLineItems[6]) : null,
                        Id_List_Price_Product__c = oppProdLineItems[7], 
                        Sub_Type__c = oppProdLineItems[1],
                        Line_Item_Type__c = 'Product'));
                    
                    oppQuoteLineItemList.add(new Opportunity_Quote_Line_Item__c(
                        Id_Opportunity__c = opp.Id, 
                        Product_Group__c = oppProdLineItems[0],
                        Name = oppProdLineItems[1], 
                        Listed_Price__c = oppProdLineItems[2] != null ? Decimal.valueOf(oppProdLineItems[2]) : null,
                        Discount__c = oppProdLineItems[3],
                        Quantity__c = oppProdLineItems[4] != null ? Decimal.valueOf(oppProdLineItems[4]) : null,
                        Installments__c = oppProdLineItems[5] != null ? Decimal.valueOf(oppProdLineItems[5]) : 1,
                        Total_Amount__c = 0,
                        Id_List_Product_Price__c = oppProdLineItems[7],
                        Line_Item_Type__c = 'Product',
                        Sub_Type__c = oppProdLineItems[1],
                        Id_Opportunity_Quote__c = oppQuote.Id));
                }

                if(!oppLineItemList.isEmpty()) {
                    
                    insert oppLineItemList;
                    insert oppQuoteLineItemList;

                } 
            } catch(Exception e) {
                Database.rollback(sp);
                System.debug(e.getMessage());
            }
            return oppQuoteLineItemList;
        }
        return null;

    }

    @RemoteAction
    global static String setTotalAmountForOppQuoteLineItems(List<String> products, List<opportunity_Quote_Line_Item__c> oppQuoteLineItemList) {
        for(String product : products) {
           
           String product2 = product.replace('&amp;', '&');
           String[] oppProdLineItems = product2.split(';');
            for(opportunity_Quote_Line_Item__c opqli : oppQuoteLineItemList) {
                if(oppProdLineItems[7] == opqli.Id_List_Product_Price__c)
                    opqli.Total_Amount__c = oppProdLineItems[6] != null ? Decimal.valueOf(oppProdLineItems[6]) : 0;
            }
        }
        
        update oppQuoteLineItemList;
        
        return oppQuoteLineItemList[0].Id_Opportunity_Quote__c;

    }
}