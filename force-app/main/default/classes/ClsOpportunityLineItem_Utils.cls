/**
 * Created by danish.farooq on 4/1/20.
 */
/**
 * Created by danish.farooq on 3/31/20.
* @Description: This is generic class to generate opportunity and quote line items
  @TriggerContext     :  After Update
 */

public with sharing class ClsOpportunityLineItem_Utils {

    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    /**
   * @Description: This is the generic method which is used for creating
   *                 Opportunity Line item
   *                 Quotes
   *                 Quote line item
   *                 it take tarif and opportunity as an argument
     @param       : Tariff record, Opportunity record
     @Return             : Void
     @TriggerContext     :  After Update
     @Ticket #            : SSC-1979
    */
    public static void getOpportunityLineItemsFromTariff(Set<Id> setOfTariff, Map<Id,Opportunity> mapOfOpportunity){

        Savepoint sp = Database.setSavepoint();
        try {
            LoggingUtility.captureTimeStamp('CreationOpptyLineItem_SelfService','Begin');
            List<Tarif_Member__c> lstOfTarifMembers = TarifMember_Selector.getTarifMembersByTarifIds(setOfTariff);
            Map<Id, List<Tarif_Member__c>> mapOfTarifMember = new Map<Id, List<Tarif_Member__c>>();
            Map<Id, Id> mapOfTariffProductPrice = new Map<Id, Id>();
            Map<Id, Id> mapOfTariffServicePrice = new Map<Id, Id>();
            Map<Id, Id> mapOfTariffAddOn = new Map<Id,Id>();
            Map<Id, List_Service_Price__c> mapOfServicePrice = new Map<Id, List_Service_Price__c>();
            Map<Id, List_Product_Price__c> mapOfProductPrice = new Map<Id, List_Product_Price__c>();
            Map<Id, List_Add_On__c> mapOfAddOn = new Map<Id, List_Add_On__c>();
            List<Opportunity_Line_Item__c> lstOpptylineitem = new List<Opportunity_Line_Item__c>();
            Map<Id, Opportunity_Quote__c> mapOfOpportunityQuotesByIds = new Map<Id, Opportunity_Quote__c>();
            //fetching service and product price from Traif Members
            mapOfTarifMember = getListPriceFromTariff(lstOfTarifMembers,mapOfTariffProductPrice,mapOfTariffServicePrice);
            //fetching addon from tarif Members
            getAddOnFromTarif(lstOfTarifMembers,mapOfTariffAddOn);
            //get details of all commission service
            mapOfServicePrice = getListServices(mapOfTariffServicePrice);
            //get details of all product services
            mapOfProductPrice = getProductServices(mapOfTariffProductPrice);
            //get details of all AddOn Services
            mapOfAddOn = getAddOns(mapOfTariffAddOn);

            for (Opportunity iOppty : mapOfOpportunity.values()) {

                if (!mapOfTarifMember.containskey(iOppty.Id_Tarif__c)) {
                    continue;
                }
                for (Tarif_Member__c iTarifMember : mapOfTarifMember.get(iOppty.Id_Tarif__c)) {
                    //creating oppotunity line items
                    switch on iTarifMember.Type__c {
                        when 'Product' {
                            if(mapOfProductPrice.containsKey(iTarifMember.Id_Tarif_Item__c)){
                                lstOpptylineitem.add(createProdOpptyLineItem(mapOfProductPrice.get(iTarifMember.Id_Tarif_Item__c), iOppty));
                            }
                        }
                        when 'Service' {
                            if(mapOfServicePrice.containsKey(iTarifMember.Id_Tarif_Item__c)){
                                lstOpptylineitem.add(createServiceOpptyLineItem(mapOfServicePrice.get(iTarifMember.Id_Tarif_Item__c), iOppty));
                            }
                        }
                        when 'AddOn'{
                            if(mapOfAddOn.containsKey(iTarifMember.Id_Tarif_Item__c)){
                                lstOpptylineitem.add(createAddOnOpptyLineItem(mapOfAddOn.get(iTarifMember.Id_Tarif_Item__c), iOppty));
                            }
                        }
                    }
                }
                //creating opportunity Quotes
                mapOfOpportunityQuotesByIds.put(iOppty.ID, createOpportunityQuote(iOppty));
            }
            // inserting opportunity line items
            if (!lstOpptylineitem.isEmpty()) {
                insert lstOpptylineitem;
            }
            // inserting opportunity quotes
            if (!mapOfOpportunityQuotesByIds.isEmpty()) {
                insert mapOfOpportunityQuotesByIds.values();
            }

            generateQuoteLineItem(lstOpptylineitem,mapOfOpportunityQuotesByIds);

            for (string opptyId : mapOfOpportunityQuotesByIds.keySet()) {
                generateQuoteFromOpptyQuote(mapOfOpportunityQuotesByIds.get(opptyId), mapOfOpportunity.get(opptyId).recordTypeId);
            }
        }
        catch(Exception ex){
            Database.rollback(sp);
            system.debug('Errror :' + ex.getMessage() + '  ' + ex.getLineNumber());
            LoggingUtility.logError('CreationOpptyLineItem_SelfService','Error :' + ex.getMessage() + '  ' + ex.getLineNumber());
        }
    }
    /**
   * @Description: This method gets list of service line items from Ids
     @param       :  Map of service Id
     @Return             : Map of list service
    */

    static Map<Id, List_Service_Price__c> getListServices(Map<Id, Id> mapOfTariffServicePrice){

        Map<Id, List_Service_Price__c> mapOfServicePrice = new Map<Id,List_Service_Price__c>();
        if(!mapOfTariffServicePrice.isEmpty()){
            mapOfServicePrice = ListServicePriceSelector.getActiveServicesById(mapOfTariffServicePrice.values());
        }
        return mapOfServicePrice;
    }
    /**
  * @Description: This method gets list of product line items from Ids
    @param       :  Map of product Id
    @Return             : Map of list product
   */

    static Map<Id, List_Product_Price__c>  getProductServices(Map<Id, Id> mapOfTariffProductPrice){

        Map<Id, List_Product_Price__c> mapOfProductPrice = new Map<Id, List_Product_Price__c>();
        if(!mapOfTariffProductPrice.isEmpty()){
            mapOfProductPrice = ListProductPriceSelector.getActiveProductsById(mapOfTariffProductPrice.values());
        }
        return mapOfProductPrice;
    }
    /**
  * @Description: This method gets list of addons from Ids
    @param       :  Map of addons ids
    @Return      : Map of Addons
   */

    static Map<Id, List_Add_On__c> getAddOns(Map<Id, Id> mapOfTariffAddOn){

        Map<Id, List_Add_On__c> mapOfAddOn = new Map<Id,List_Add_On__c>();
        if(!mapOfTariffAddOn.isEmpty()){
            mapOfAddOn = ListAddOn_Selector.getListAddOnById(mapOfTariffAddOn.values());
        }
        return mapOfAddOn;
    }
    /**
   * @Description: This method insert quotelineitems from opportunity line items
     @param       : List of opportunity line item, map of opportunity and quotes
     @Return             : Void
     @TriggerContext     :  After Update
     @Ticket #            : SSC-1979
    */
    static void generateQuoteLineItem(List<Opportunity_Line_Item__c> lstOpptylineitem,
            Map<Id, Opportunity_Quote__c> mapOfOpportunityQuotesByIds){

        List<Opportunity_Quote_Line_Item__c> lstQuoteLineItems = new List<Opportunity_Quote_Line_Item__c>();
        //generating opportunity quote line items
        for (Opportunity_Line_Item__c iOpportunityLineItem : lstOpptylineitem) {

            if (!mapOfOpportunityQuotesByIds.containsKey(iOpportunityLineItem.Id_Opportunity__c)) {
                continue;
            }
            lstQuoteLineItems.add(createOpportunityQuoteLineItem(iOpportunityLineItem, mapOfOpportunityQuotesByIds.get(iOpportunityLineItem.Id_Opportunity__c)));
        }
        //inserting quote line items
        if (!lstQuoteLineItems.isEmpty()) {
            insert lstQuoteLineItems;
        }
    }
    /**
  * @Description: This method returns Listprice from tariff
    @param       : List of tarif member , map of product price, map of service price
    @Return             : Map of Tarif Member
    @TriggerContext     :  After Update
    @Ticket #            : SSC-1979
   */
    static  Map<Id, List<Tarif_Member__c>> getListPriceFromTariff(List<Tarif_Member__c> lstOfTarifMembers,
            Map<Id, Id> mapOfTariffProductPrice,
            Map<Id, Id> mapOfTariffServicePrice){

        Map<Id, List<Tarif_Member__c>> mapOfTarifMember = new Map<Id, List<Tarif_Member__c>>();
        for (Tarif_Member__c iTarifMember : lstOfTarifMembers) {
            switch on iTarifMember.Type__c {
                when 'Product' {
                    mapOfTariffProductPrice.put(iTarifMember.Id, iTarifMember.Id_Tarif_Item__c);
                }
                when 'Service' {
                    mapOfTariffServicePrice.put(iTarifMember.Id, iTarifMember.Id_Tarif_Item__c);
                }
            }
            if (mapOfTarifMember.containsKey(iTarifMember.Tarif_Name__c)) {
                mapOfTarifMember.get(iTarifMember.Tarif_Name__c).add(iTarifMember);
                continue;
            }
            mapOfTarifMember.put(iTarifMember.Tarif_Name__c, new List<Tarif_Member__c>{
                    iTarifMember
            });
        }
        return mapOfTarifMember;
    }
    /**
 * @Description: This method gets addon list of tariff members
   @param       : List of tarif member , map of addons
   @Return             : void
   @Ticket #            : SSC-1979
  */
    static void getAddOnFromTarif(List<Tarif_Member__c> lstOfTarifMembers,
                                Map<Id, Id> mapOfTariffAddOn){

        for (Tarif_Member__c iTarifMember : lstOfTarifMembers) {
            switch on iTarifMember.Type__c {
                when 'AddOn'{
                    mapOfTariffAddOn.put(iTarifMember.Id, iTarifMember.Id_Tarif_Item__c);
                }
            }
        }
    }
    /**
   * @Description: This method create Service Product opportunity line item from Service price
     @param        : Service Price record, Opportunity record
     @Return             : Opportunity Line item
     @TriggerContext     :  After Update
     @Ticket #            : SSC-1979
    */
    static Opportunity_Line_Item__c createServiceOpptyLineItem(List_Service_Price__c objServicePrice, Opportunity oppty){

        Opportunity_Line_Item__c opptyLineItem = new Opportunity_Line_Item__c();
        opptyLineItem.Name = objServicePrice.Name;
        opptyLineItem.Line_Item_Type__c = 'Service';
        opptyLineItem.start_date__c      = Date.today();
        opptyLineItem.Sub_type__c = objServicePrice.Service_Type__c;
        opptyLineItem.Commission_In_Percentage__c = objServicePrice.Commission_In_Percentage__c;
        opptyLineItem.CurrencyIsoCode = oppty.CurrencyIsoCode;
        opptyLineItem.Id_List_Service_Price__c = objServicePrice.Id;
        opptyLineItem.Id_Opportunity__c = oppty.Id;
        opptyLineItem.Commission_Type_Picklist__c = objServicePrice.Commission_Type__c;
        opptyLineItem.RecordTypeId =  LibRecordTypeHelper.getRecordTypeValue(oppty.company_code__c + '_Opportunity_Line_Item');
        return opptyLineItem;
    }
    /**
   * @Description: This method create Product Price opportunity line item from Service price
     @param       : Product Price record, Opportunity record
     @Return             : Opportunity Line item
     @TriggerContext     :  After Update
     @Ticket #            : SSC-1979
    */
    static Opportunity_Line_Item__c createProdOpptyLineItem(List_Product_Price__c objProductPrice,Opportunity oppty){

        Opportunity_Line_Item__c opptyLineItem = new Opportunity_Line_Item__c();
        opptyLineItem.Name = objProductPrice.Displayed_Name__c;
        opptyLineItem.Line_Item_Type__c = 'Product';
        opptyLineItem.start_date__c      = Date.today();
        opptyLineItem.Quantity__c = objProductPrice.Default_Quantity__c;
        opptyLineItem.Listed_Price__c = objProductPrice.List_Price__c;
        opptyLineItem.Product_Group__c = objProductPrice.Id_List_Product_Group__c;
        opptyLineItem.Id_List_Price_Product__c = objProductPrice.Id;
        opptyLineItem.Id_Opportunity__c = oppty.Id;
        opptyLineItem.Product_Group__c = objProductPrice.Id_List_Product_Group__r.Name;
        opptyLineItem.Sub_type__c = objProductPrice.Product_Type__c;
        opptyLineItem.RecordTypeId =  LibRecordTypeHelper.getRecordTypeValue(oppty.company_code__c + '_Opportunity_Line_Item');
        opptyLineItem.CurrencyIsoCode = oppty.CurrencyIsoCode;
        opptyLineItem.Discount__c = '0'; // this is temporary Fixed
        opptyLineItem.total_Amount__c = (opptyLineItem.Listed_Price__c * opptyLineItem.Quantity__c) - decimal.valueOf(opptyLineItem.Discount__c);
        return opptyLineItem;
    }
    /**
   * @Description: This method create opportunity line item from add on
     @param       : AddOn record, Opportunity record
     @Return             : Opportunity Line item
     @TriggerContext     :  After Update
     @Ticket #            : SSC-1979
    */
    static Opportunity_Line_Item__c createAddOnOpptyLineItem(List_Add_On__c objAddOn,Opportunity oppty){

        Opportunity_Line_Item__c opptyLineItem = new Opportunity_Line_Item__c();
        opptyLineItem.contractAddition__c = objAddOn.Contract_Addition__c;
        opptyLineItem.Line_Item_Type__c = 'AddOn';
        opptyLineItem.Id_List_Add_On__c    = objAddOn.Id;
        opptyLineItem.Id_Opportunity__c    = oppty.Id;
        opptyLineItem.name          = objAddOn.name;
        opptyLineItem.start_date__c      = Date.today();
        opptyLineItem.Has_related_tarif__c = true;
        opptyLineItem.Sub_type__c = objAddOn.type__c;
        opptyLineItem.RecordTypeId =  LibRecordTypeHelper.getRecordTypeValue(oppty.company_code__c + '_Opportunity_Line_Item');
        opptyLineItem.CurrencyIsoCode = oppty.CurrencyIsoCode;
        return opptyLineItem;
    }
    /**
   * @Description: This method create Opportunity Quotes
     @param        :  Opportunity record
     @Return             : Opportunity Quote
     @TriggerContext     :  After Update
     @Ticket #            : SSC-1979
    */
    static Opportunity_Quote__c createOpportunityQuote(Opportunity opp){

        Opportunity_Quote__c quote = new Opportunity_Quote__c();
        quote.Id_tarif__c   = opp.Id_Tarif__c;
        quote.recordtypeId   = LibRecordTypeHelper.getRecordTypeValue(opp.company_code__c + '_Opportunity_Quote');
        quote.Id_Opportunity__c = opp.Id;
        quote.CurrencyISOCode = opp.CurrencyISOCode;
        quote.Id_Account__c = opp.accountId;
        quote.Status__c = 'Approved';
        return quote;
    }
    /**
   * @Description: This method create Opportunity Quotes Line item from Opportunity line item
     @param      :  Opportunity line item , opportunity quote
     @Return             : Quote line item
     @TriggerContext     :  After Update
     @Ticket #            : SSC-1979
    */
    static Opportunity_Quote_Line_Item__c createOpportunityQuoteLineItem(Opportunity_Line_Item__c opptyLineitem,Opportunity_Quote__c quote){

        Opportunity_Quote_Line_Item__c quoteLineItem = new Opportunity_Quote_Line_Item__c();
        quoteLineItem.Id_Opportunity_Quote__c = quote.Id;
        quoteLineItem.Id_Opportunity__c = opptyLineitem.Id_Opportunity__c;
        quoteLineItem.Name = opptyLineitem.Name;
        quoteLineItem.Line_Item_Type__c = opptyLineitem.Line_Item_Type__c;
        quoteLineItem.Sub_type__c = opptyLineitem.Sub_type__c;
        quoteLineItem.CurrencyIsoCode = opptyLineitem.CurrencyIsoCode;
        quoteLineItem.Start_Date__c = Date.Today();

        switch on opptyLineitem.Line_Item_Type__c{
            when 'Product' {
                quoteLineItem.Id_List_Product_Price__c = opptyLineitem.Id_List_Price_Product__c;
                quoteLineItem.Quantity__c = opptyLineitem.Quantity__c;
                quoteLineItem.Listed_Price__c = opptyLineitem.Listed_Price__c;
                quoteLineItem.Total_Amount__c = opptyLineitem.Total_Amount__c;
                quoteLineItem.Discount__c = opptyLineitem.Discount__c;
                quoteLineItem.Delivery__c = (String.isBlank(opptyLineitem.Delivery__c)) ? 'Shipment' : opptyLineitem.Delivery__c;
            }
            when 'Service' {
                quoteLineItem.Id_List_Service_Price__c = opptyLineitem.Id_List_Service_Price__c;
                quoteLineItem.Commission_In_Percentage__c = opptyLineitem.Commission_In_Percentage__c;
                quoteLineItem.Commission_Type_Picklist__c = opptyLineitem.Commission_Type_Picklist__c;
            }
            when 'AddOn'{
                quoteLineItem.Id_List_Add_On__c = opptyLineitem.Id_List_Add_On__c;
            }
        }
        return quoteLineItem;
    }
    /**
   * @Description: This method generate doc Gen package quote from opportunity quote
     @param      :   opportunity quote, opportunity record type
     @Return             : void
     @TriggerContext     :  After Update
     @Ticket #            : SSC-1979
    */
    public static void generateQuoteFromOpptyQuote(Opportunity_Quote__c opportunityQuote, String oppRecordTypeId){

        String docGenPackageId;
        String deliveryOptionId;
        String docGenLabel;

        List<Loop__DDP_Integration_Option__c> lstDDPInt = new List<Loop__DDP_Integration_Option__c>();

        docGenLabel = label.nintexDocumentGeneration;
        if(string.isBlank(docGenLabel)){
            return;
        }

        lstDDPInt = [SELECT Id, Loop__DDP__r.Id FROM
                Loop__DDP_Integration_Option__c WHERE
                Name = :docGenLabel.split(';')[1] AND
                Loop__DDP__r.Name = :docGenLabel.split(';')[0]];

        if(!lstDDPInt.isEmpty()){
            Loop__DDP_Integration_Option__c ddpIntObj = lstDDPInt[0];
            docGenPackageId = ddpIntObj.Loop__DDP__r.Id;
            deliveryOptionId = ddpIntObj.Id;
            opportunityQuote.Automate_quote_generation__c = true;
            opportunityQuote.Drawloop_Next_Text__c = String.Format('SFOpportunity_Quote__c:{0};DDPId:{1};Deploy:{2}', new String[] { opportunityQuote.Id, docGenPackageId,deliveryOptionId });
            update opportunityQuote;
        }
    }
}