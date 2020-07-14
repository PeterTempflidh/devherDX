/**
 * Created by w.novoa on 12.09.2019.
 */

public inherited sharing class OpportunityQuoteLineItemSelector {

    /*******************************************************************************************************
    * @description Query for get Opportunity quote line items.
    * @param  shipmentID shipment order Id
    * @return Shipment_Order__c
    */

    public static List<Opportunity_Quote_Line_Item__c> getQuoteLineItemByShipmentOrder(set<Id> stShipmentOrder,Boolean blnAsset, Boolean blnBranding) {
        String strQuery;

        strQuery =  'select id,';
        strQuery += ' name,';
        strQuery += ' Id_Opportunity__r.OwnerId,';
        strQuery += ' Id_Opportunity_Quote__r.Id_Account__c,';
        strQuery += ' CurrencyIsoCode,';
        strQuery += ' Id_Opportunity__c,';
        strQuery += ' RecordTypeId,';
        strQuery += ' RecordType.DeveloperName,';
        strQuery += ' Source_GRID__c,';
        strQuery += ' Id_Opportunity__r.Account.GRID__c,';
        strQuery += ' Delivery__c,';
        strQuery += ' Quantity__c,';
        strQuery += ' Id_List_Product_Price__c,';
        strQuery += ' Number_of_Copies__c,';
        strQuery += ' Size__c, ';
        strQuery += ' Weight__c,';
        strQuery += ' Deposit_Method__c,';
        strQuery += ' Id_List_Product_Price__r.Product_Name__c,';
        strQuery += ' Id_List_Product_Price__r.Product_Type__c';
        strQuery += ' from Opportunity_Quote_Line_Item__c';
        strQuery += ' where id IN (select Opportunity_Quote_Line_Item__c from Shipment_Order_Line_Item__c where Shipment_Order__c IN : stShipmentOrder)';
        if(blnAsset){
            strQuery += ' AND id_list_product_price__r.Requires_Asset__c = true';
        }
        if(blnBranding){
            strQuery += ' AND id_list_product_price__r.Requires_Branding__c = true';
        }


        List<Opportunity_Quote_Line_Item__c> opportunityQuoteLineItem = new List<Opportunity_Quote_Line_Item__c>();

        try {
            opportunityQuoteLineItem = Database.Query(strQuery);
        } catch (Exception e) {
            System.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }

        return opportunityQuoteLineItem;

    }

    /*******************************************************************************************************
    * @description Query for get Opportunity quote line items which requires ESignature.
    * @param  quoteId  Quote Id
    * @return List<Opportunity_Quote_Line_Item__c>
    */

    public static List<Opportunity_Quote_Line_Item__c> getQuoteLineItemByDocuSign(Id quoteId) {

        List<Opportunity_Quote_Line_Item__c> opportunityQuoteLineItem = new List<Opportunity_Quote_Line_Item__c>();

        try {
            opportunityQuoteLineItem = [SELECT Id, Id_List_Product_Price__r.Requires_Esignature__c, Id_List_Service_Price__r.Requires_Esignature__c, Id_List_Add_On__r.Requires_Esignature__c
                                        FROM Opportunity_Quote_Line_Item__c
                                        WHERE Id_Opportunity_Quote__c = :quoteId
                                        ];

        } catch (Exception e) {
            System.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }

        return opportunityQuoteLineItem;

    }

}