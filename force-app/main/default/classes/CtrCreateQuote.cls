public with sharing class CtrCreateQuote extends CtrAbstractQuote {

    public Id oppQId { get; set;}
    public String acctId { get; set; }
    public String placeHolder { get; set; }
    public Double setUpFee {get; set;}
    public Boolean subsidy {get; set;}
    public Boolean isTalabatGo {get;set;}
    public Boolean isLogisticsFee {get;set;}
    public Boolean isCommissionFee {get;set;}


    public String pizzaDeUrl {
        get {
            return getImageUrl('PizzaDeLogo');
        }
    }

    public String liferheldUrl {
        get {
            return getImageUrl('LiferheldLogo');
        }
    }

    public String deliveryHeroDeUrl {
        get {
            return getImageUrl('DeliveryHeroDELogo');
        }
    }

    public List<Opportunity_Quote_Line_Item__c> listLineItems {
        get {
            if (this.listLineItems == null) {
                this.listLineItems = createLineItemList();

            }
            return this.listLineItems;
        }
        private set;
    }

    public List<Opportunity_Quote_Line_Item__c> listCommisionItems {
        get {
            if (this.listCommisionItems == null) {
                this.listCommisionItems = createComissionItemsList();
            }
            return this.listCommisionItems;
        }
        private set;
    }

    public List<Opportunity_Quote_Line_Item__c> listAddOnItems {
        get {
            if (this.listAddOnItems == null) {
                this.listAddOnItems = createAddOnsList();
            }
            return this.listAddOnItems;
        }
        private set;
    }

    public List<Opportunity_Quote_Line_Item__c> liferheldPPItems {
        get {
            return filterProductsByCompanyName(listLineItems, 'Lieferheld');
        }
    }

    public List<Opportunity_Quote_Line_Item__c> pizzadePPItems {
        get {
            return filterProductsByCompanyName(listLineItems, 'Pizza.de');
        }
    }

    public Double lineItemsTotalAmount {
        get {
            if (this.lineItemsTotalAmount == null) {
                this.lineItemsTotalAmount = calculateLineItemTotalAmount();
            }
            return lineItemsTotalAmount;
        }
        private set;
    }

    public Integer reccuringFeeCount {get;set;}
    public String weekday {get; set;}
    public Date startDate  {get; set;}
    public Date endDate {get; set;}
    public String entityName {get; set;}
    public String entityAddress {get; set;}
    public String entityPhone {get; set;}
    public String entityFax {get; set;}
    public String entityCountry {get; set;}
    public String entityEmail {get; set;}
    public String entityFooter {get; set;}
    public String entityHeader {get; set;}
    public Boolean errorFlag {get; set;}
    public String entityHead {get; set;}
    public String entityRole {get; set;}
    public Opportunity_Quote_Line_Item__c registrationProduct {get; set;}
    public Boolean menuPrinting { get; set; }
    public Boolean marketingMaterial { get; set; }
    public Boolean nineCookies { get; set; }
    public Boolean reccuringFee { get; set; }
    public Boolean isFixedAmt {get; set;}
    public Opportunity_Quote_Line_Item__c commissionFeeItem {get; set;}
    public Opportunity_Quote_Line_Item__c annualRenewalProduct {get; set;}
    public Opportunity_Quote__c oppProductQuote {get; set;}
    public Date acceptedQuoteOn {get; set;}

    public Opportunity opportunity {
        get {
            if (oppQId != null) {
                Opportunity_quote__c oqli = [SELECT id_opportunity__c FROM Opportunity_quote__c WHERE Id = :oppQId];
                return [select owner.name, Payment_Method__c, owner.lastname, owner.firstname, Id_Tarif__r.name, owner.phone, owner.email, SubTotalRF__c, VAT_fm__c, Total_fm__c, CloseDate from opportunity where id = :oqli.id_opportunity__c];
            }
            return new Opportunity();
        } private set;
    }

    // right now used only for CD.
    public String oppCloseDateDayAsLiteral {
        get {
            return UtilsNumberToStringLiteral.getStringLiteralByLocale(opportunity.CloseDate.day(), 'es_ES');
        }
    }

    public String oppCLoseDateMonthName {
        get {
            return Datetime.newInstance(opportunity.CloseDate, System.now().time()).format('MMMM');
        }
    }

    public Boolean comissionsExist { get; set; }
    public Boolean tieredCommissionExist { get; set; }
    public Boolean additionalCostsExist { get; set; }
    public Boolean showOnlinePayment {get; set;}
    public Boolean commPercent {get; set;}
    public Boolean commPerOrder {get; set;}
    public Boolean isDiscount {get; set;}
    public String displayAuto {

        get{
            if (oppQId != null) {
                List<Opportunity_Quote_Line_Item__c > opp = [SELECT Id, Id_List_Product_Price__r.Product_Type__c FROM Opportunity_Quote_Line_Item__c where Id_Opportunity_Quote__c = :oppQId and Line_Item_type__c = 'Product'];
                system.debug('*opp' + opp );
                for (Opportunity_Quote_Line_Item__c o : opp) {

                    if (o.Id_List_Product_Price__r.Product_Type__c == Label.SE_Automatic_CarLease || o.Id_List_Product_Price__r.Product_Type__c == Label.SE_Manual_CarLease) {
                        displayAuto = o.Id_List_Product_Price__r.Product_Type__c;
                        system.debug('**displayauto' + displayAuto);
                    }

                }
            }
            return displayAuto;

        }
        private set;
    }

    //Added this method for SP-1309(Bhupendra) !?!?!?! :O will check one day maybe....
    public String quoteNonstandardTextMjam {
        get{
            if (quoteNonstandardTextMjam == null) {
                if (oppQId != null) {
                    Opportunity_Quote__c oppQ = [select id, Non_Standard_Contract_Terms__c, Non_Standard_Contract_Components__c, Template_Name__c from Opportunity_Quote__c where Id = :oppQId];
                    if (oppQ.Non_Standard_Contract_Terms__c != null && oppQ.Non_Standard_Contract_Components__c != null && oppQ.Non_Standard_Contract_Components__c == 'Mjam Web' && oppQ.Template_Name__c == 'AT_QuoteVFTemplate_Both') {
                        quoteNonstandardTextMjam = oppQ.Non_Standard_Contract_Terms__c;

                    } else if (oppQ.Non_Standard_Contract_Terms__c != null && oppQ.Non_Standard_Contract_Components__c != null && oppQ.Template_Name__c == 'AT_QuoteVFTemplate_Asset') {
                        quoteNonstandardTextMjam = oppQ.Non_Standard_Contract_Terms__c;

                    }
                }
            }
            return quoteNonstandardTextMjam;
        }
        private set;

    }

    public String quoteNonstandardText {
        get{
            if (quoteNonstandardText == null) {
                if (oppQId != null) {

                    Opportunity_Quote__c oppQ = [select id, Non_Standard_Contract_Terms__c from Opportunity_Quote__c where Id = :oppQId];
                    if (oppQ.Non_Standard_Contract_Terms__c != null) {
                        quoteNonstandardText = oppQ.Non_Standard_Contract_Terms__c;

                    }
                }
            }
            return quoteNonstandardText;
        }
        private set;

    }

    public Opportunity_Quote__c oppQuote {
        get{
            if (oppQuote == null) {
                if (oppQId != null) {
                    isDiscount = false;
                    oppQuote = [select id, Total_fm__c, SubTotalRF__c, VAT_fm__c, Approval_Comments__c, Non_Standard_Contract_Components__c, CreatedDate from Opportunity_Quote__c where Id = :oppQId];
                    if (oppQuote.Non_standard_contract_components__c != null && oppQuote.Non_standard_contract_components__c.containsIgnoreCase('Show Discount')) {
                        isDiscount = true;
                    }
                }
            }
            return oppQuote;
        }
        private set;

    }

    public Boolean isPremiumPlacement {
        get{
            if(opportunity.Id_Tarif__r.name != null && opportunity.Id_Tarif__r.name == 'Premium Placement'){
                return true;
            }else{
                return false;
            }
        }
    }

    public CtrCreateQuote() {
        placeHolder = 'place holder';
        this.comissionsExist = true;
        this.tieredCommissionExist = false;
        this.additionalCostsExist = true;
        this.menuPrinting = false;
        this.marketingMaterial = false;
        this.nineCookies = false;
        this.commPercent = false;
        this.commPerOrder = false;
        this.showOnlinePayment = false;
        this.subsidy = false;
        this.reccuringFeeCount = 0;
        //this.totalAmount = 0;
        if (ApexPages.currentPage().getParameters().get('id') != null) {
            oppQId = ApexPages.currentPage().getParameters().get('id');
            oppProductQuote = ([select Id_Account__c,Id_Opportunity__c from Opportunity_Quote__c where id = :oppQId]);
            acctId = oppProductQuote.Id_Account__c;
            // To get the principle agreement created date, SP-2832
            List<Opportunity_Quote__c> listOpptyQuote = New List<Opportunity_Quote__c>([select id,CreatedDate,Status__c,
                                    Id_Opportunity__r.Business_Type__c,Id_Account__c,Id_Opportunity__r.StageName
                                from Opportunity_Quote__c
                                where Id_Account__c = :acctId
                                order by CreatedDate ASC]);
                if(!listOpptyQuote.IsEmpty()){
                for(Opportunity_Quote__c oppQuote :listOpptyQuote)
                    if(oppQuote.Id_Opportunity__r.Business_Type__c == 'New Business' && oppQuote.Status__c == 'Accepted' && oppQuote.Id_Opportunity__r.StageName=='Closed Won') {
                        DateTime tempDateTime = oppQuote.CreatedDate;
                        acceptedQuoteOn = date.newinstance(tempDateTime.year(), tempDateTime.month(), tempDateTime.day());
                    }
            }
        }
    }

    public ClsAccountWrapper getAccountWrapper() {
        ClsAccountWrapper accountWrapper;
        errorFlag = false;
        System.debug('AccountWrapper: ');
        this.entityHeader = '';
        this.entityFooter = '';
        if (acctId != null && accountWrapper == null) {
            accountWrapper = new ClsAccountWrapper(acctId, oppQuote.CreatedDate);

            if (accountWrapper.recordTypeDevName == 'Talabat_Account') {
                if (accountWrapper.accPlatform != null) {
                    if (accountWrapper.accPlatform.contains('Talabat')) {
                        this.entityCountry = accountWrapper.countryName;
                        this.entityName = 'Talabat';
                        Company__c comp = [select id, name, Address__c, Fax__c, Phone__c, Email__c, Header_Name__c, Footer_Name__c, Entity_Name__c, Entity_Head__c, Role__c from Company__c where Country__r.Name = :accountWrapper.countryName limit 1];

                        if (comp.Entity_Name__c != null) {
                            this.entityName = comp.Entity_Name__c;
                        }
                        this.entityHead = comp.Entity_Head__c;
                        this.entityRole = comp.Role__c;
                        this.entityAddress = comp.Address__c;
                        this.entityPhone = comp.Phone__c;
                        this.entityFax = comp.Fax__c;
                        this.entityEmail = comp.Email__c;
                        this.entityHeader = comp.Header_Name__c;
                        this.entityFooter = comp.Footer_Name__c;
                    }
                } else {
                    errorFlag = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Please select a platform'));
                }
            }
        }
        return accountWrapper;
    }

    public Decimal getCommissionFee() {
        Decimal commissionFee = null;
        System.debug('oppQId: ' + oppQId);
        if (oppQId != null) {
            List<Opportunity_Quote_Line_Item__c> qItems = [SELECT Id, Name, Commission_In_Percentage__c, Start_Date__c, end_Date__c FROM Opportunity_Quote_Line_Item__c WHERE Id_Opportunity_Quote__c = : this.oppQId and Line_Item_Type__c = 'Service'];
            if (!qItems.isEmpty()) {
                LibOpportunityLineItemsHelper.sortList(qItems, 'Start_Date__c', 'DESC');
                commissionFeeItem = qItems[0];
                commissionFee = qItems[0].Commission_In_Percentage__c;
                this.startDate = qItems[0].Start_Date__c;
                this.endDate = qItems[0].end_Date__c;
                if (this.startDate != null) {
                    datetime myDate = datetime.newInstance(startDate.year(), startDate.month(), startDate.day());
                    this.weekday = myDate.format('EEEE');
                }

            }
        }
        return commissionFee;
    }

    /**
     * Filter products item by company name. Used in DE PP quote to differentiate
     * Liferheld and Pizza.de line items
     * @param  products Products to filter
     * @param  company  company to search for
     * @return          An empty list or items related to specified company
     */
    private List<Opportunity_Quote_Line_Item__c> filterProductsByCompanyName(List<Opportunity_Quote_Line_Item__c> products, String company) {
        List<Opportunity_Quote_Line_Item__c> res = new List<Opportunity_Quote_Line_Item__c>();

        System.debug('CtrCreateQuote.filterProductsByCompanyName: start, company is: ' + company);

        for (Opportunity_Quote_Line_Item__c prod : products) {
            if (prod.Id_List_Product_Price__r.Company__r.Name == company) {
                res.add(prod);
            }
        }

        System.debug('CtrCreateQuote.filterProductsByCompanyName: done, list size is: ' + res.size());
        return res;
    }

    // Retrieves add. charges
    private List<Opportunity_Quote_Line_Item__c> createLineItemList() {
        List<Opportunity_Quote_Line_Item__c> res = [
                SELECT
                        Billable_Account__c,
                        Billable_Account__r.Name,
                        Id_List_Product_Price__r.Displayed_Name__c,
                        Id_List_Product_Price__r.Company__r.Name,
                        Id_Opportunity__r.Record_Country__c,
                        Category__c,
                        Subsidy__c,
                        Budget__c,
                        Unit_Cost__c,
                        Interval__c,
                        size__c,
                        weight__c,
                        Number_of_Copies__c,
                        Design_Note__c,
                        online_payment_fee__c,
                        Deposit_Method__c,
                        Deposit__c,
                        District__c,
                        sub_type__c,
                        Start_Date__c,
                        Total_Amount__c,
                        End_Date__c,
                        Id_List_Product_Price__r.product_Type__c,
                        Id_List_Product_Price__r.Requires_Asset__c,
                        Id_List_Product_Price__r.Id_list_product_group__r.name,
                        Name,
                        Listed_Price__c,
                        Discount__c,
                        Quantity__c,
                        Installments__c,
                        City_ZipCode__c,
                        Booking_Api_Id__c,
                        Position__c,
                        Position_fm__c,
                        Specifications__c
                FROM Opportunity_Quote_Line_Item__c
                WHERE Id_Opportunity_Quote__c = :oppQId
                AND Line_Item_type__C = 'Product'
                ORDER BY Id_List_Product_Price__r.Company__r.Name ASC
        ];

        for (Opportunity_Quote_Line_Item__c oppProd : res) {
            if (oppProd.Sub_type__c == 'Setup Fee') {
                this.registrationProduct = oppProd;

            } else if (oppProd.Sub_type__c == 'Annual Fee') {
                this.annualRenewalProduct = oppProd;
            } else if ( oppProd.Sub_type__c == 'Exclusive Special Offer') {
                this.subsidy = true;
            } else if (oppProd.Id_List_Product_Price__r.product_Type__c == 'Menu Printing') {
                this.menuPrinting = true;
            } else if (oppProd.Id_List_Product_Price__r.product_Type__c == 'Blade Sign') {
                this.marketingMaterial = true;
            } else if (oppProd.Id_List_Product_Price__r.product_Type__c == '9 Cookies') {
                this.nineCookies = true;
            } else if (oppProd.Id_List_Product_Price__r.product_Type__c == 'Recurring Fee') {
                this.reccuringFee = true;
                this.reccuringFeeCount++;
            }
        }

        this.additionalCostsExist = !res.isEmpty();

        return res;
    }

    // retrieves commissions and add. charges with recurring fee
    private List<Opportunity_Quote_Line_Item__c> createComissionItemsList() {
        List<Opportunity_Quote_Line_Item__c> res = [
                    SELECT
                    Id_List_Service_Price__r.Displayed_Name__c,
                    Id_List_Service_Price__r.Company__r.Name,
                    Sub_Type__c,
                    online_payment_fee__c,
                    Name,
                    Billable_Account__c,
                        Recurring_Fee__c,
                        Commission_In_Percentage__c,
                        Commission_Per_Order__c,
                        Commission_Type__c,
                        Id_Opportunity__c,
                        Id_List_Service_Price__c,
                        Id_List_Service_Price__r.Maximum_Commission_In_Percentage__c,
                        Id_List_Service_Price__r.Minimum_Commission_in_Percentage__c,
                        Id_List_Service_Price__r.Service_type__c,
                        Id_list_service_price__r.Based_On__c,
                        Id_list_service_price__r.Id_Country__r.name,
                        Has_Related_Tarif__c,
                        End_Date__c,
                        Start_Date__c,
                        CurrencyIsoCode,
                        IsTiered__c,
                        Scaled__c,
                        index__c,
                        Min__c,
                        Max__c,
                (SELECT Commission_in_percentage__c,Commission_per_order__c,Max__c,Min__c From Tiers__r Order by Min__c)
                FROM Opportunity_Quote_Line_Item__c
                WHERE Id_Opportunity_Quote__c = : this.oppQId and Line_Item_type__C = 'Service'
                ORDER BY Id_List_Service_Price__r.Company__r.Name, Start_Date__c, index__c ASC
        ];

        this.comissionsExist = !res.isEmpty();

        if ( this.comissionsExist) {
            if ( res[0].commission_per_order__C != null )
                this.commPerOrder = true;
            if ( res[0].Commission_In_Percentage__c != null )
                this.commPercent = true;
        }

        if (res.size() > 1 && res[0].IsTiered__c && res[0].index__c != null) {
            if ( res[0].online_payment_fee__c != null )
                this.showOnlinePayment = true;
            if ( res[0].commission_per_order__C != null )
                this.commPerOrder = true;
            if ( res[0].Commission_In_Percentage__c != null )
                this.commPercent = true;

            this.tieredCommissionExist = true;
            this.comissionsExist = false;
        }

        if (res.size() > 0) {
            for (Opportunity_Quote_Line_Item__c oqli : res) {
                if(oqli.Commission_Type__c == 'Per Order'){
                    this.isFixedAmt = true;
                    if(oqli.Id_list_service_price__r.Id_Country__r.name == 'Kuwait'){
                        if(oqli.commission_per_order__c != null)
                            oqli.commission_per_order__c = oqli.commission_per_order__c.setScale(3);
                    }else{
                        if(oqli.commission_per_order__c != null)
                            oqli.commission_per_order__c = oqli.commission_per_order__c.setScale(2);
                    }
                }
                if(oqli.Id_List_Service_Price__r.Service_type__c == 'Logistics Fee'){
                    this.isTalabatGo = true;
                    //PKALINA: Hungary Implementation: Check if Product in Tarif have Service Type Logistics Fee
                    this.isLogisticsFee = true;
                }
                //PKALINA: Hungary Implementation: Check if Product in Tarif have Service Type Commission Fee
                if(oqli.Id_List_Service_Price__r.Service_type__c == 'Commission Fee'){
                    this.isCommissionFee = true;
                }

                for(Tier__c tier : oqli.tiers__r){
                    if(oqli.Id_list_service_price__r.Id_Country__r.name == 'Kuwait'){
                        if(tier.commission_per_order__c != null)
                            tier.commission_per_order__c = tier.commission_per_order__c.setScale(3);
                    }else{
                        if(tier.commission_per_order__c != null)
                            tier.commission_per_order__c = tier.commission_per_order__c.setScale(2);
                    }

                    if(oqli.Id_list_service_price__r.Based_On__c == 'Orders'){
                        tier.min__c = tier.min__c.intValue();
                        if(tier.max__c != null)
                            tier.max__c = tier.max__c.intValue();
                    }else{
                        if(oqli.Id_list_service_price__r.Id_Country__r.name == 'Kuwait'){
                            tier.min__c = tier.min__c.setScale(3);
                            if(tier.max__c != null)
                                tier.max__c = tier.max__c.setScale(3);
                        }else{
                            tier.min__c = tier.min__c.setScale(2);
                            if(tier.max__c != null)
                                tier.max__c = tier.max__c.setScale(2);
                        }
                    }
                }
            }
        }


        return res;
    }

    // retrieves add ons list
    private List<Opportunity_Quote_Line_Item__c> createAddOnsList() {
        List<Opportunity_Quote_Line_Item__c> res = [
                SELECT
                        Name,
                        Billable_Account__c,
                        Line_Item_Type__c,
                        Sub_type__c,
                        Contract_Addition__c,
                        specifications__c,
                        Id_List_Add_On__c,
                        Id_List_Add_On__r.Company__r.Name,
                        Start_Date__c,
                        End_Date__c,
                        recordtype.developerName
                FROM Opportunity_Quote_Line_Item__c
                WHERE Id_Opportunity_Quote__c = :this.oppQId and Line_Item_type__C = 'AddOn'
                ORDER BY Id_List_Add_On__r.Company__r.Name, Start_Date__c ASC
        ];

        for(Opportunity_Quote_Line_Item__c qli : res){
            if(qli.contract_Addition__c != null && (!qli.recordType.developerName.contains('Talabat') && !qli.recordType.developerName.contains('PY')))
                qli.contract_Addition__c = qli.contract_addition__c.replaceAll('\n','<br/>');
        }

        return res;
    }

    private Double calculateLineItemTotalAmount() {
        Double result = 0.0;
        if (!listLineItems.isEmpty()) {
            for (Opportunity_Quote_Line_Item__c item : listLineItems) {
                result += item.Total_Amount__c;
            }
        }
        return result;
    }

}