/**
 * @description Utility methods for CreateFpOpportunityRecords_Batch class
 * @date 29.10.2019
 * @author Mantas Jurkunas
 * @see CreateFpOpportunityRecords_Batch
 */
public with sharing class CreateFpOpportunityRecords_Utils {

    private Map<Id, List<Opportunity_Line_Item__c>> lineItemsMap {
        get {
            if (lineItemsMap != null) {
                return lineItemsMap;
            }
            List<Opportunity_Line_Item__c> lineItems = OpportunityLineItem_Selector.getByOpportunityIdsForTariff(new Map<Id, Opportunity> (this.opportunities).keySet());
            lineItemsMap = ClsSObjectUtils.convertToIdMap(lineItems, Opportunity_Line_Item__c.Id_Opportunity__c.getDescribe().getLocalName());
            return lineItemsMap;
        }
        private set;
    }
    private List<Opportunity> opportunities;
    private Map<Id, List<Opportunity_Quote__c>> quotesMap;
    private List<Opportunity_Quote_Line_Item__c> addonQuoteLineItems;

    public CreateFpOpportunityRecords_Utils (List<Opportunity> opportunities) {
        this.opportunities = opportunities;
        addonQuoteLineItems = new List<Opportunity_Quote_Line_Item__c>();
    }

    /**
     * Creates missing quotes for opportunities
     */
    public CreateFpOpportunityRecords_Utils createQuotes() {
        List<Opportunity_Quote__c> quotes = new List<Opportunity_Quote__c>();
        for (Opportunity opp: this.opportunities) {
            quotes.add(initializeQuote(opp));
        }
        insert quotes;
        this.quotesMap = ClsSObjectUtils.convertToIdMap(quotes, Opportunity_Quote__c.Id_Opportunity__c.getDescribe().getLocalName());
        return this;
    }

    /**
     * @description Creates quote line items for inserted quotes, based on opportunity line items
     */
    public CreateFpOpportunityRecords_Utils createQuoteLineItems() {
        List<Opportunity_Quote_Line_Item__c> quoteLineItems = new List<Opportunity_Quote_Line_Item__c>();
        List<Tarif.TierQuoteLineItemWrapper> quoteLineItemWrapper = new List<Tarif.TierQuoteLineItemWrapper>();
        for (Opportunity opp: opportunities) {
            List<Opportunity_Line_Item__c> lineItems = new List<Opportunity_Line_Item__c>();
            lineItems = lineItemsMap.get(opp.Id);
            //Should not be more that one quote in all cases
            for ( Opportunity_Quote__c quote: quotesMap.get(opp.Id)) {
                for (Opportunity_Line_Item__c lineItem : lineItems) {
                    Tarif.TierQuoteLineItemWrapper wrapper = new Tarif.TierQuoteLineItemWrapper();
                    wrapper.lineItem = mapOpportuntiyLineItemToQuoteLineItem(lineItem);
                    wrapper.lineItem.Id_Opportunity_Quote__c = quote.Id;
                    wrapper.lineItem.Id_Opportunity_Quote__r = quote;
                    wrapper.lineItem.Id_Opportunity__c = opp.Id;
                    wrapper.lineItem.Id_Opportunity__r = opp;
                    wrapper.lineItem.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(opp.Company_Code__c + '_Opportunity_Quote_Line_Item');
                    wrapper.lineItem.CurrencyIsoCode = opp.CurrencyIsoCode;
                    if (lineItem.Tiers__r.size() > 0) {
                        List<Tier__c> tiersToBeadded = new List<Tier__c>();
                        for (Tier__c tier : lineItem.Tiers__r) {
                            Tier__c quoteTier = tier.clone();
                            quoteTier.Id_Opportunity_Line_Item__c = null;
                            tiersToBeadded.add(quoteTier);
                        }
                        wrapper.tiers = tiersToBeadded;
                    }
                    quoteLineItemWrapper.add(wrapper);
                }
            }
        }
        for (Tarif.TierQuoteLineItemWrapper wrapper : quoteLineItemWrapper) {
            quoteLineItems.add(wrapper.lineItem);
            if (wrapper.lineItem.Line_Item_Type__c.equals('AddOn')) {
                wrapper.lineItem.RecordType = new RecordType(Id=wrapper.lineItem.RecordTypeId, DeveloperName = LibRecordTypeHelper.getRecordTypeValue(wrapper.lineItem.RecordTypeId));
                if (wrapper.lineItem.Id_Opportunity__r.StageName.equals('Editorial Queue') ||
                        wrapper.lineItem.Id_Opportunity__r.StageName.equals('Onboarding') ||
                        wrapper.lineItem.Id_Opportunity__r.StageName.equals('Promo and Logistics Queue')) {
                    addonQuoteLineItems.add(wrapper.lineItem);
                }
            }
        }
        insert quoteLineItems;

        // Insert the tiers once the quote line items are inserted
        List<Tier__c> tiersToBeInserted = new List<Tier__c>();
        for (Tarif.TierQuoteLineItemWrapper wrapper : quoteLineItemWrapper) {
            for (Tier__c tier : wrapper.tiers) {
                tier.Id_Opportunity_Quote_Line_Item__c = wrapper.lineItem.Id;
                tiersToBeInserted.add(tier);
            }

        }
        if (!tiersToBeInserted.isEmpty()) {
            insert tiersToBeInserted;
        }

        return this;

    }

    /**
    * @Description: This method maps opporunity line item fields to quote line item fields
    */
    private static Opportunity_Quote_Line_Item__c mapOpportuntiyLineItemToQuoteLineItem(Opportunity_Line_Item__c lineItem){
        Opportunity_Quote_Line_Item__c quoteItem  	= new Opportunity_Quote_Line_Item__c();
        quoteItem.name								= lineItem.name;
        quoteItem.OldOppQuoteLineId__c				= lineItem.OldOppQuoteLineId__c;
        quoteItem.Id_List_Product_Price__c			= lineItem.Id_List_Price_Product__c;
        quoteItem.Listed_Price__c					= lineItem.Listed_Price__c;
        quoteItem.Quantity__c						= lineItem.Quantity__c;
        quoteItem.Min__c							= lineItem.Min__c;
        quoteItem.Max__c							= lineItem.Max__c;
        quoteItem.index__c							= lineItem.index__c;
        quoteItem.IsTiered__c						= lineItem.IsTiered__c;
        quoteItem.Total_Amount__c					= lineItem.Total_Amount__c;
        quoteItem.Id_Opportunity__c					= lineItem.Id_Opportunity__c;
        quoteItem.Id_List_Service_Price__c			= lineItem.Id_List_Service_Price__c;
        quoteItem.Product_Group__c					= lineItem.Product_Group__c;
        quoteItem.discount__c						= lineItem.discount__c;
        quoteItem.Installments__c					= lineItem.Installments__c;
        quoteItem.Has_Related_Tarif__c				= lineItem.Has_Related_Tarif__c;
        quoteItem.Line_Item_Type__c					= lineItem.Line_Item_Type__c;
        quoteItem.sub_type__c						= lineItem.sub_type__c;
        quoteItem.online_payment_fee__c				= lineItem.online_payment_fee__c;
        quoteItem.Commission_In_Percentage__c		= lineItem.Commission_In_Percentage__c;
        quoteItem.Commission_Per_Order__c			= lineItem.Commission_Per_Order__c;
        quoteItem.Recurring_Fee__c					= lineItem.Recurring_Fee__c;
        quoteItem.Category__c						= lineItem.Category__c;
        quoteItem.Category_Id__c					= lineItem.Category_Id__c;
        quoteItem.District__c						= lineItem.District__c;
        quoteItem.District_Id__c					= lineItem.District_Id__c;
        quoteItem.Start_Date__c						= lineItem.Start_Date__c;
        quoteItem.End_Date__c						= LineItem.End_Date__c;
        quoteItem.City_ZipCode__c					= lineItem.City_ZipCode__c;
        quoteItem.design_note__c					= lineItem.design_note__c;
        quoteItem.Number_of_Copies__c				= lineItem.Number_of_Copies__c;
        quoteItem.Size__c							= lineItem.Size__c;
        quoteItem.weight__c							= lineItem.weight__c;
        quoteItem.deposit__c						= lineItem.deposit__c;
        quoteItem.deposit_method__c					= lineItem.deposit_method__c;
        quoteItem.subsidy__c						= lineItem.subsidy__c;
        quoteItem.Billable_Account__c				= lineItem.Billable_Account__c;
        quoteItem.Contract_Addition__c				= lineItem.ContractAddition__c;
        quoteItem.Id_List_Add_On__c					= lineItem.Id_List_Add_On__c;
        quoteItem.Scaled__c							= lineItem.scaled__c;
        quoteItem.specifications__c					= lineItem.specifications__c;
        quoteItem.Position__c						= lineItem.position__c;
        quoteItem.Booking_Api_id__c					= lineItem.Booking_Api_Id__c;
        quoteItem.Commission_Type_PickList__c      = lineItem.Commission_Type_PickList__c;
        quoteItem.Based_On__c                      = lineItem.Based_On__c;
        return quoteItem;
    }

    private Opportunity_Quote__c initializeQuote(Opportunity opp){
        Opportunity_Quote__c quote = new Opportunity_Quote__c();
        quote.Id_Tarif__c 	= opp.Id_Tarif__c;
        quote.RecordTypeId 	= LibRecordTypeHelper.getRecordTypeValue(opp.Company_Code__c + '_Opportunity_Quote');
        quote.Id_Opportunity__c = opp.Id;
        quote.CurrencyIsoCode = opp.CurrencyIsoCode;
        quote.Status__c = 'Accepted';
        quote.Id_Account__c = opp.AccountId;
        return quote;
    }

    /**
     * @description Creates missing addons for quote line items of type addon
     */
    public CreateFpOpportunityRecords_Utils createAddons() {
        LibHelper.createAddOn(this.addonQuoteLineItems);
        return this;
    }

    /**
     * @description Creates missing cases for opportunities based on the stage and business type
     */
    public CreateFpOpportunityRecords_Utils createCases() {
        List<Case> objectList = new List<SObject>();
        for (Opportunity opp : opportunities) {
            if (opp.StageName.equals('New') || opp.StageName.equals('Verbal Agreement')) {
                continue;
            }

            Case qcCase = (Case) ClsOpportunityProcessor.createQualityCheckCase(opp,new List<Case>(), new Account( Record_Country__c = opp.Record_Country__c ));
            if (qcCase != null && !opp.StageName.contains('Quality Check')) {
                closeCase(qcCase);
            }
            if (qcCase != null) {
                objectList.add(qcCase);
            }


        }
        insert objectList;
        return this;
    }

    private void closeCase(Case acase) {
        acase.Status = 'Closed';
        acase.Closed_Reason__c = acase.Type.equals('Menu Processing') ? 'Take Online' : 'Successful';
    }

    public static void toggleTriggers(Boolean enabled) {
        Trigger_Manager__c triggerManager = Trigger_Manager__c.getInstance();
        triggerManager.Deactivate_Account_Trigger__c = !enabled;
        triggerManager.Deactivate_AddOnService_Trigger__c = !enabled;
        triggerManager.Deactivate_Case_Trigger__c = !enabled;
        triggerManager.Deactivate_Quote_Trigger__c = !enabled;
        triggerManager.Deactivate_Opportunity_Trigger__c = !enabled;
        triggerManager.Deactivate_Opp_Line_Item_Trigger__c = !enabled;
        upsert triggerManager;
    }
}