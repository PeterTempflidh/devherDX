public with sharing class ctrDH_AU_QuoteVFTemplate {
    public List<Opportunity_Quote_Line_Item__c> oppProdItems {get; set;}
    public List<Opportunity_Quote_Line_Item__c> oppQLItems {get; set;}

    public Opportunity_Quote__c theOppQ {get; set;}
    public Boolean premiumPlacement { get; set; }
    public Boolean ukQuote { get; set; }
    public Boolean menuPrinting {get; set;}
    public Boolean colombia { get; set; }
    public Boolean peru { get; set; }
    public Boolean ecuador { get; set; }
    public Boolean prodOnly {get; set;}
    public Boolean foodora {get; set;}
    public Boolean foodoraColombia {get; set;}
    public Boolean foodoraPeru {get; set;}
    public Boolean foodoraEcuador {get; set;}
    public Boolean addContract {get; set;}
    public Boolean isNewBusiness {get;set;}
    public Boolean isARLogisticFee {get;set;}
    public Boolean isARMarketPlace {get;set;}
    public Boolean isNonARLogisticFee {get;set;}
    public Boolean isNonARMarketPlace {get;set;}
    public Boolean isARUpgradeUpsell {get;set;}
    public Boolean isNonARUpgradeUpsell {get;set;}
    public Boolean isQuoteProductOnly {get;set;}
    public Boolean isDRLogisticFee {get;set;}
    public Boolean isDRMarketPlace {get;set;}
    public Boolean isDRUpgradeUpsell {get;set;}
    /**
     * @description Is set based on Tarif names defined in Business Config "CPC Products" whether cpc quote should be loaded.
     */
    public Boolean isCpcQuote {get;set;}

    public ctrDH_AU_QuoteVFTemplate() {
        Id objId = ApexPages.currentPage().getParameters().get('id');
        this.premiumPlacement = false;
        this.ukQuote = true;
        this.menuPrinting = false;
        this.colombia = false;
        this.peru = false;
        this.ecuador = false;
        this.foodora = false;
        this.addContract = false;
        this.foodoraColombia = false;
        this.foodoraPeru = false;
        this.foodoraEcuador = false;
        this.isARLogisticFee = false;
        this.isARMarketPlace = false;
        this.isNonARLogisticFee = false;
        this.isNonARMarketPlace = false;
        this.isARUpgradeUpsell = false;
        this.isNonARUpgradeUpsell = false;
        this.isQuoteProductOnly =false;
        theOppQ = [SELECT Id_Account__c,
                Id_Account__r.Name,
                Id_Account__r.Invoice_Frequency__c,
                Id_Opportunity__c,
                SubTotalRF__c,
                VAT_fm__c,
                Total_fm__c,
                RecordTypeId,
                Id_Opportunity__r.Main_Commission_Fee__c ,
                Id_Opportunity__r.Invoice_Transmission_method__c,
                Id_Opportunity__r.Main_Online_Payment_Fee__c ,
                Id_Opportunity__r.Quote_Comment_Menu_Printing__c,
                Id_Opportunity__r.Type
        FROM Opportunity_Quote__c
        WHERE Id = : objId];

        oppProdItems = [SELECT
                    Name,
                    Listed_Price__c,
                    Quantity__c,
                    Total_Amount__c,
                    Sub_type__c
                FROM Opportunity_Quote_Line_Item__c
                WHERE Id_Opportunity_Quote__c = :theOppQ.Id and Line_Item_Type__c = 'Product'];

        oppQLItems = [SELECT
                    Id_Opportunity_Quote__c,
                    Sub_type__c,Id_Opportunity__r.Record_Country__c,
                    Id_Opportunity__r.Business_Type__c
                FROM Opportunity_Quote_Line_Item__c
                WHERE Id_Opportunity_Quote__c = :theOppQ.Id and Line_Item_Type__c = 'Service'];

        Opportunity opt = [
                SELECT
                    Record_Country__c,
                    Id_Tarif__r.Name,
                    Type,
                    Business_Type__c,
                    Name
                FROM Opportunity
                WHERE Id = :theOppQ.Id_Opportunity__c];

        Set<String> logisticFees = new Set<String>(Label.logistics_fee.split(','));
        this.isCpcQuote = isCPCQuote(theOppQ, oppProdItems);

        if ((opt.Name != null && opt.Name == 'Premium Placement') || (opt.Id_Tarif__r.Name != null && opt.Id_Tarif__r.Name.contains('Premium Placement'))) {
            this.premiumPlacement = true;
            this.ukQuote = false;
        } else if (opt.Type == 'Additional Contract') {
            this.addContract = true;
            this.ukQuote = false;
        } else if (opt.Id_Tarif__r.Name == 'Menu Printing') {
            this.menuPrinting = true;
            this.ukQuote = false;
        }

        if (logisticFees.contains(opt.Id_Tarif__r.Name)) {
            if (opt.Record_Country__c == 'Colombia')
                this.foodoraColombia = true;
            if (opt.Record_Country__c == 'Peru')
                this.foodoraPeru = true;
            if (opt.Record_Country__c == 'Ecuador')
                this.foodoraEcuador = true;
            this.foodora = true;
        }

        if (!this.foodora) {
            if (opt.Record_Country__c == 'Colombia')
                this.colombia = true;
            else if (opt.Record_Country__c == 'Peru')
                this.peru = true;
            else if (opt.Record_Country__c == 'Ecuador')
                this.ecuador = true;

            if (opt.Type != null && opt.Type.indexOf('Contract') == -1) {
                this.prodOnly = true;
                this.colombia = false;
                this.peru = false;
                this.ecuador = false;
            }
        }

        if(opt.Business_Type__c == 'New Business' || opt.Business_Type__c == 'Win Back'
                || opt.Business_Type__c == 'Owner Change'){
            this.isNewBusiness = true;
        }
        else {
            this.isNewBusiness = false;
        }

        if(opt.Type == 'Product Only'){
            this.isQuoteProductOnly = true;
        }

        /*Peya quote changes SP-2777
        Peya Prod only quotes SP-2832*/
        if(!oppQLItems.isEmpty()) {
            for (Opportunity_Quote_Line_Item__c oppQLI : oppQLItems) {
                if (oppQLI.Sub_type__c == 'Logistics Fee') {
                    if (oppQLI.Id_Opportunity__r.Record_Country__c == 'Argentina') {
                        this.isARLogisticFee = true;
                    } 
                    else if(oppQLI.Id_Opportunity__r.Record_Country__c == 'Dominican Republic'){
                    	this.isDRLogisticFee = true;
                    }
                    else {
                        this.isNonARLogisticFee = true;
                    }
                } else {
                    if (oppQLI.Id_Opportunity__r.Record_Country__c == 'Argentina') {
                        this.isARMarketPlace = true;
                    } 
                    else if(oppQLI.Id_Opportunity__r.Record_Country__c == 'Dominican Republic'){
                    	this.isDRMarketPlace = true;
                    }
                    else {
                        this.isNonARMarketPlace = true;
                    }
                }
            }
        }else{
            if (opt.Record_Country__c == 'Argentina') {
                this.isARUpgradeUpsell = true;
            }
            else if(opt.Record_Country__c == 'Dominican Republic'){
            	this.isDRUpgradeUpsell = true;
			}
            else {
                this.isNonARUpgradeUpsell = true;
            }
        }

    }

    private Boolean isCPCQuote(Opportunity_Quote__c oppQuote, List<Opportunity_Quote_Line_Item__c> lineItems) {
        Business_Config__c config = LibBusinessConfig.getBusinessConfigFromRuleMap('QuoteScreenProcess', oppQuote.RecordTypeId, 'CPC Products');
        if (config == null || String.isBlank(config.Business_Rule_Value__c)) {
            return false;
        }
        Set<String> productNames = new Set<String>(config.Business_Rule_Value__c.replaceAll(' ,|, ', ',').split(','));
        for (Opportunity_Quote_Line_Item__c lineItem: lineItems) {
            if (productNames.contains(lineItem.Name)) {
                return true;
            }
        }
        return false;
    }
}
