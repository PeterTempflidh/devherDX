/***
 * @description Batch class for FP opportunity migration. It creates Shipment Order, Shipment Order Line item, Opportunity Line Item, Opportunity Quote Line Item
 * @date 07.05.2020
 * @author Konrad Czykin
 */
global class MigrationScriptShipmentOrders_Batch implements Database.Batchable<SObject>, Database.Stateful {
    
    List<String> lstCountries;
    Map<String, Map<String, String>> mapCountryLPP;
    String recordTypeDevName;

    /**
    * @description Batch class constructor
    * @param recordTypeDevName - prefix of recordtype (e.g. FP)
    * @param countries - countries for which shipment order should be assigned
    */
    global MigrationScriptShipmentOrders_Batch(String recordTypeDevName, String countries) {
        this.lstCountries = countries.split(',');
        this.recordTypeDevName = recordTypeDevName + '_Opportunity';
        mapCountryLPPcreation();
    }

    global Database.QueryLocator start (Database.BatchableContext BC){
        return Database.getQueryLocator([select id, AccountId, Account.Account_Country_Code__c, Account.CurrencyIsoCode, Account.Company_Code__c, Record_Country__c, 
                                        (SELECT Id FROM Opportunity_Quotes__r WHERE Status__c = 'Accepted'),
                                        (SELECT Id, Name, Quantity__c, Total_Amount__c, CurrencyIsoCode, Id_List_Price_Product__c FROM Opportunity_Line_Items__r) 
                                            FROM Opportunity 
                                            WHERE recordtype.DeveloperName = :recordTypeDevName and Record_Country__c IN :lstCountries 
                                            and Business_Type__c = 'New Business' and StageName IN ('Onboarding','Editorial Queue') 
                                            and AccountId NOT IN (SELECT Account__c FROM Asset__c) and AccountId NOT IN (SELECT Account__c FROM Shipment_Order__c)]);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope){
        List<Opportunity> lstOpp = new List<Opportunity>();
        lstOpp = (List<Opportunity>)scope;
        Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>(lstOpp);
        MigrationScriptShipmentOrders_Utils migUtil = new MigrationScriptShipmentOrders_Utils(mapOpp, mapCountryLPP);
        migUtil.createOpportunityLineItem().createOppQuoteLineItem().createShipmentOrder().createShipmentOrderLineItem();
    }


    global void finish(Database.BatchableContext BC){
    }

    /***
    * @description Method creates map of <CountryName, <ProductName, ListProducPrice Id>>. Used to assign List Product Price to:
    * Opportunity Quote Line Items, Shipment Order Line Items, Opportunity Line Item
    */
    private void mapCountryLPPcreation(){
        List<List_Product_Price__c> lstPPrice = [SELECT Id, Product_Name__c, Id_Country__r.Name FROM List_Product_Price__c WHERE Product_Name__c IN ('SIM Card', 'Tablet') and Id_Country__r.Name IN :lstCountries];
        mapCountryLPP = new Map<String, Map<String, String>>();
        for(List_Product_Price__c lpp : lstPPrice){
            String country = lpp.Id_Country__r.Name;
            String product = lpp.Product_Name__c;
            String strId = lpp.Id;
            Map<String, String> tempMap = new Map<String, String>{product => strId};
            if(mapCountryLPP.get(country) == null){
                mapCountryLPP.put(country, tempMap);
                continue;
            }
            mapCountryLPP.get(country).putAll(tempMap);
        }
    }
}