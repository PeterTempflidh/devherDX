/*
@author : Magesh Mani Yadav
@creation : 01.09.2014

*/
global without sharing class CtrCreateProductLineItems {
    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    private static String userEmail = UserInfo.getUserEmail();
    private static String userRole = '';
    public Opportunity opp {get; set;}
    public String selectedProductGroup {get; set;}
    public List<SelectOption> groupItems {get; set;}
    public List<SelectOption> tarifItems {get; set;}
    public List<SelectOption> myOptions {get; set;}
    public List<SelectOption> serviceItems {get; set;}
    public List<SelectOption> productItems {get; set;}
    public List<SelectOption> ppProductItems {get; set;}
    public List<SelectOption> mpProductItems {get; set;}
    public List<SelectOption> msProductItems {get; set;}
    public List<SelectOption> dpProductItems {get; set;}
    public List<List_Product_Price__c> listProductPrice {get; set;}
    public String selectedProductLineItem {get; set;}
    public String selectedServiceItem {get; set;}
    public String selectedTarifItem {get; set;}
    public String selectedTarifItemName {get; set;}
    public String selectedMY {get; set;}
    public List_Product_Price__c selectedProduct {get; set;}
    public Opportunity_Line_Item__c selectedService {get; set;}
    public Opportunity_Line_Item__c selectedProductItem { get; set; }
    public Opportunity_Line_Item__c selectedProd { get; set; }
    //public List<Opportunity_Tarif_Item__c> selectedTarifList { get; set; }
    //public List<Opportunity_Tarif_Item__c> selectedTarifToDeleteList { get; set; }
    //public Opportunity_Tarif_Item__c selectedTarif { get; set; }
    public Integer productQuantity { get; set; }
    public double totalAmount { get; set; }

    public List<LineItemWrapper> serviceLineItems { get; set; }
    public List<LineItemWrapper> productLineItems { get; set; }
    public List<LineItemWrapper> productLineIterator { get; set; }
    public Integer recurringChargeToRemove { get; set; }
    public Integer productToRemove { get; set; }
    public Integer serviceToRemove { get; set; }
    private List<Opportunity_Line_Item__c> listDeleteOppLineItems { get; set; }
    public Decimal subTotal { get; set; }
    public String rabbat { get; set; }
    public Date startDate { get; set; }
    public Date endDate { get; set; }
    private Map<String, Business_Config__c> mapBusinessData { get; set; }
    //private List<Tarif_Member__c> listSelectedTarifMembers { get; set; }
    //public Opportunity_Tarif_Item__c deleteExistingTarif { get; set; }
    private Map<Id, Tarif__c> mapTarifItems { get; set; }
    //public Decimal vatinPercentage { get; set; }
    //public Decimal vatTotal { get; set; }
    //public Decimal grandTotal { get; set; }
    private Map<id, List_Service_Price__c> mapListServicePrice { get; set; }
    public Boolean availableForQuote { get; set; }
    public Boolean lockLineItems { get; set; }
    //public Boolean validateTarif { get; set; }

    public Boolean requiresApproval { get; set; }
    //public Boolean businessApprovalProcess {get;set;}
    //commission type
    public Map<Id, String> mapCommissionType {get; set;}

    //Quote
    public Opportunity_Quote__c oppQuote { get; set; }
    //private Map<String,Business_Config__c> mapAcceptButtonBusinessData { get; set; }
    public Map<Id, Opportunity_Quote_Line_Item__c> mapExistingLineItems { get; set; }
    //private List<OpportunityContactRole> listContact { get; set; }
    private boolean emailError { get; set; }


    //additional
    public Boolean showProductLineItems { get; set; }
    public Boolean showServiceLineItems { get; set; }
    public Boolean showProductSection { get; set; }
    public Boolean showQuoteSection { get; set; }
    public Boolean showQuoteSectionError { get; set; }
    public Boolean showAdSalesBlock { get; set; }
    public Boolean showPPBlock {get; set;}
    public Boolean showAPIPPBlock {get; set;}
    public Boolean showMPBlock {get; set;}
    public Boolean showMSBlock {get; set;}
    public Boolean showDPBlock {get; set;}
    public Boolean showTieredBlock {get; set;}


    public Boolean showApprovalCommentsSection {get; set;}
    public Boolean useCombinedSaveAndCreateQuote {get; set;}
    public Boolean showNonStandardContractComponentsSection {get; set;}
    public Boolean showNonStandardContractTerms {get; set;}
    public Boolean multiStageApprovalNeeded {get; set;}
    public Boolean isRegionalApproval{get;set;}
    public Country__c opportunityCountry { get; set; }
    public String opportunityCompany { get; set; }
    private Map<ID, Decimal> mapMaximumDiscount {get; set;}
    private Map<Id, Boolean> mapHasApproval {get; set;}
    private Decimal mainCommissionFee { get; set; }
    private Decimal mainOnlinePaymentFee { get; set; }
    private Decimal mainOrderTransmissionFee { get; set; }
    //Commission type
    private Decimal mainFixedAmount {get; set;}

    //public String htmlEmailQuote { get; set; }
    //private Map<Id,RecordType> recordTypeMap = LibRecordTypeHelper.getRecordTypeForIds(new Set<String>{'Opportunity'});

    public Boolean isMenuPrinting { get; set; }
    public Boolean hasAsset { get; set; }
    public Boolean hasService { get; set; }
    private Boolean isAdsales {get; set;}
    public Boolean isCarLease {get; set;}
    public Boolean isOwnerChange {get; set;}
    private static List_Product_Price__c premiumPlaceApiProd;
    private static Opportunity oppForAPi;
    public List<Opportunity_Line_Item__c> ppAPILineItems { get; set; }

    //private List<String> typesOfServices { get; set; }

    // Recurring fee section data
    public List<SelectOption> recurringChargesList { get; set; }
    public List<Opportunity_Line_Item__c> recurringCharges { get; set; }
    public List<LineItemWrapper> recurringChargeLineItems { get; set; }
    public Boolean usesRecurringCharges { get; set; }
    public Map<String, String> recuringChargeTypes { get; set; }
    public Map<Id, List_Product_Price__c> recuringChargesMap { get; set; }
    public String selectedRecurringCharge { get; set; }
    private String recurringFeeProductGroup { get; set; }
    public String adSalesTarif {get; set;}
    public List<SelectOption> categories {get; set;}
    public List<SelectOption> districts {get; set;}
    public List<SelectOption> typeDistricts {get; set;}
    public List<LineItemWrapper> adSalesProductLineItems { get; set; }

    private Map<String, String> mapCategories {get; set;}
    private Map<String, String> mapDistricts {get; set;}
    private Map<String, Decimal> mapDistrictPrice {get; set;}
    private Map<String, String> mapTypeDistrictPriceInfo {get; set;}
    private Map<String, String> mapApproval {get; set;}
    public Integer adSalesProductToRemove { get; set; }
    private String adSalesProductPrice {get; set;}
    public Opportunity_Line_Item__c adSalesProductDates {get; set;}

    private Map<String, String> mapCategoriesFlat {get; set;}
    private Map<String, String> mapDistrictsFlat {get; set;}

    //Adsales changes on 15.10.15
    public List<SelectOption> adSalesTypes {get; set;}
    public String selectedAdSalesTypes {get; set;}
    public String selectedCategories { get; set; }
    public String selectedDistricts { get; set; }
    //public String[] selectedCategories { get; set; }
    //public String[] selectedDistricts{ get; set; }


    //private Map<String,Decimal> mapDistrictPriceFlat {get;set;}
    //private Map<String,String> mapDistrictPriceInfoFlat {get;set;}
    public Integer flatProductToRemove { get; set; }
    //public Integer ppProductToRemove { get; set; }
    private String flatProductPrice {get; set;}
    //private String ppProductPrice {get;set;}
    public Opportunity_Line_Item__c flatProductDates {get; set;}
    //public Opportunity_Line_Item__c ppProductDates {get;set;}
    public String[] selectedFlatCategories { get; set; }
    public String[] selectedFlatDistricts { get; set; }
    public List<LineItemWrapper> flatProductLineItems { get; set; }
    public List<LineItemWrapper> ppProductLineItems { get; set; }
    public List<SelectOption> districtsFlat {get; set;}
    public List<SelectOption> categoriesFlat {get; set;}
    public String flatProductTarif {get; set;}
    private Boolean isFlatProduct {get; set;}
    private Boolean isPPProduct {get; set;}
    private Boolean isPPProductDiscount {get; set;}
    public Boolean showFlatProductBlock { get; set; }
    private Boolean skipAutoApprovalQuote {get; set;}
    //private List<String> listNotificationChain {get;set;}

    private Set<String> overlappingDisabledCountrySet {get; set;}
    private Set<String> annualEndDateCountrySet {get; set;}

    private TLB_Approval_Matrix__c approvalLimits {get; set;}
   /* private Map<String, TLB_Approval_Matrix__c> mapApprovalEntriesLevel2 {get; set;}
    private Map<String, TLB_Approval_Matrix__c> mapApprovalEntriesLevel3 {get; set;}*/

    private Map<String,OpportunityTeamMember> mapApprovalEntriesLevel1 {get; set;}
    private Map<String,OpportunityTeamMember> mapApprovalEntriesLevel2 {get; set;}
    private Map<String,OpportunityTeamMember> mapApprovalEntriesLevel3 {get; set;}



    private String accountName {get; set;}
    private String nonStandardPicKValue {get; set;}
    public Boolean showCommissionPerOrder {get; set;}

    private Set<String> annualRenewalFeeCountrySet {get; set;}
    public Map<Id, String> mapProductType {get; set;}
    private Integer annualRenewalInMonths {get; set;}
    private Map<String, String> renewalFeeMap {get; set;}
    private Map<String, String> registrationFeeMap {get; set;}
    public String ppTarif {get; set;}
    private Map<Id, List_Product_Price__c> mapPPProducts {get; set;}
    Map<String, Integer> mapNumberOfRecords = new Map<String, Integer> {'Premium placement - 1 Month' => 1 , 'Premium placement - 3 Months' => 3 , 'Premium placement - 6 Months' => 6, 'Premium placement - 12 Months' => 12};
    // private Boolean approvalProcessService {get;set;}
    public Boolean openSubTAbForQuote {get; set;}
    public Boolean showQuoteDetail {get; set;}
    public Boolean lockTariffSelection {get; set;}
    public String mpTarif {get; set;}
    public List<LineItemWrapper> mpProductLineItems { get; set; }
    public List<LineItemWrapper> msProductLineItems { get; set; }
    public List<LineItemWrapper> dpProductLineItems { get; set; }
    private Map<Id, List_Product_Price__c> mapMPProducts {get; set;}
    private Set<String> marketingShippingProdTypes {get; set;}
    private Set<String> designProductTypes {get; set;}
    public String mstarif {get; set;}
    public String dpTarif {get; set;}
    private Map<Id, List_Product_Price__c> mapMSProducts {get; set;}
    private Map<Id, List_Product_Price__c> mapDPProducts {get; set;}
    public Decimal ExclusiveCommission {get; set;}
    public String tieredKeyWord {get; set;}
    private boolean  displayError {get; set;}
    private boolean ppapi{get;set;}

    public set<String> comissiontypeForReg{get;set;}


    Map<String,Map<string,OpportunityTeamMember>> mapOppTeam {get;set;}

    //public String recurringChargesAllowed { get; set; } //comma separated string of recurring charges allowed. Read from business config and will be used by jquery on page to deside when to show or hide input fields

    public CtrCreateProductLineItems(ApexPages.StandardController controller){
        if (!Test.isRunningTest()) {
            controller.addFields(new List<String> {'Account.Vendor_Grade__c', 'stageName', 'Account.Backend_ID__c', 'AccountId', 'CurrencyIsoCode', 'RecordType.DeveloperName', 'Country__c', 'Record_Country__c', 'Quote_Comment_Menu_Printing__c', 'Quote_Comment__c', 'Account.Name', 'Account.Invoice_Frequency__c', 'Id_Tarif__c', 'Id_Tarif__r.name', 'Company_Code__c','account.RecordType.developerName'});
        }

        this.opp = (Opportunity)controller.getRecord();
        this.accountName = this.opp.Account.Name;
        this.selectedService = new Opportunity_Line_Item__c();
        this.selectedProd = new Opportunity_Line_Item__c();
        this.selectedService.Start_Date__c = null;
        this.selectedService.End_Date__c = null;
        this.lockLineItems = false;
        if (this.opp.StageName == 'Closed Lost') {
            this.lockLineItems = true;
        }
        this.subTotal = 0;
        //this.vatTotal=0;
        //this.grandTotal =0;
        //this.vatinPercentage = 0;
        this.groupItems = new List<SelectOption>();
        this.tarifItems = new List<SelectOption>();
        this.myOptions = new List<SelectOption>();
        this.serviceItems = new List<SelectOption>();
        this.productItems = new List<SelectOption>();
        this.ppProductItems = new List<SelectOption>();
        this.mpProductItems = new List<SelectOption>();
        this.msProductItems = new List<SelectOption>();
        this.dpProductItems = new List<SelectOption>();
        //this.listDeleteProductLineItems = new List<Opportunity_Line_Item__c>();
        //this.listDeleteServiceLineItems = new List<Opportunity_Line_Item__c>();
        this.listDeleteOppLineItems = new List<Opportunity_Line_Item__c>();
        this.serviceLineItems = new List<LineItemWrapper>();
        this.productLineItems = new List<LineItemWrapper>();
        this.productLineIterator = new List<LineItemWrapper>();
        this.recurringChargesList = new List<SelectOption>();
        this.recuringChargeTypes = new Map<String, String>();

        this.listProductPrice = new List<List_Product_Price__c>();
        //this.selectedTarif = new Opportunity_Tarif_Item__c();
        this.mapTarifItems = new Map<Id, Tarif__c>();
        this.mapListServicePrice = new Map<id, List_Service_Price__c>();
        this.availableForQuote = false;
        //this.validateTarif = true;
        this.showProductSection = true;
        this.showServiceLineItems = true;
        this.showProductLineItems = true;
        this.showQuoteSection = false;
        this.showQuoteSectionError = false;
        this.showAdSalesBlock = false;
        this.showPPBlock = false;
        this.showAPIPPBlock = false;
        this.showMPBlock = false;
        this.showMSBlock = false;
        this.showDPBlock = false;
        this.showTieredBlock = false;
        this.showApprovalCommentsSection = false;
        this.showNonStandardContractComponentsSection = false;
        this.showNonStandardContractTerms = false;
        this.useCombinedSaveAndCreateQuote = false;
        this.multiStageApprovalNeeded = false;
        this.isRegionalApproval = false;
        this.isMenuPrinting = false;
        this.hasAsset = false;
        this.hasService = false;
        this.isAdsales  = false;
        this.isCarLease = false;
        this.isOwnerChange = false;
        this.usesRecurringCharges = false;
        //this.businessApprovalProcess = false;
        this.recurringChargeLineItems = new List<LineItemWrapper>();
        this.recuringChargesMap = new Map<Id, List_Product_Price__c>();
        this.mapMaximumDiscount = new Map<Id, Decimal>();
        this.mapHasApproval = new Map<id, Boolean>();
        //this.selectedTarifToDeleteList = new List<Opportunity_Tarif_Item__c>();
        this.determineCompany();
        //commission type
        this.mapCommissionType = new Map<Id, String>();
        this.mapCommissionType.put(null, '');

        this.categories = new List<SelectOption>();
        this.districts = new List<SelectOption>();
        this.typeDistricts = new List<SelectOption>();
        this.mapCategories = new Map<String, String>();
        this.mapDistricts = new Map<String, String>();
        this.mapDistrictPrice = new Map<String, Decimal>();
        this.mapTypeDistrictPriceInfo = new Map<String, String>();
        this.mapApproval = new Map<String, String>();
        this.adSalesProductLineItems = new List<LineItemWrapper>();
        this.adSalesProductDates = new Opportunity_Line_Item__c();
        this.ppAPILineItems = new List<Opportunity_Line_Item__c>();
        //this.selectedCategories = new String[]{};
        //this.selectedDistricts = new String[]{};

        this.ExclusiveCommission = 0.0;
        //Adsales changes on 15.10.15
        this.adSalesTypes = new List<SelectOption>();

        this.mapCategoriesFlat = new Map<String, String>();
        this.mapDistrictsFlat = new Map<String, String>();
        //this.mapDistrictPriceFlat = new Map<String,Decimal>();
        //this.mapDistrictPriceInfoFlat = new Map<String,String>();
        this.districtsFlat = new List<SelectOption>();
        this.categoriesFlat = new List<SelectOption>();
        this.flatProductDates = new Opportunity_Line_Item__c();
        this.selectedFlatCategories = new String[] {};
        this.selectedFlatDistricts = new String[] {};
        this.flatProductLineItems = new List<LineItemWrapper>();
        this.isFlatProduct  = false;
        this.ppProductLineItems = new List<LineItemWrapper>();
        this.isPPProduct  = false;
        this.isPPProductDiscount = false;
        this.showFlatProductBlock = false;
        this.skipAutoApprovalQuote = false;
        //this.listNotificationChain = new List<String>();
        this.overlappingDisabledCountrySet = new Set<String>();
        this.annualEndDateCountrySet = new Set<String>();
        this.showCommissionPerOrder = false;
        this.annualRenewalFeeCountrySet = new Set<String>();
        this.mapProductType = new Map<Id, String>();
       
        this.renewalFeeMap = new Map<String, String>();
        this.registrationFeeMap = new Map<String, String>();
        this.mapPPProducts = new Map<Id, List_Product_Price__c>();
        // this.approvalProcessService = false;
        this.openSubTAbForQuote = false;

        this.showQuoteDetail = false;
        this.lockTariffSelection = false;
        this.ppapi=false;


        this.mpProductLineItems = new List<LineItemWrapper>();
        this.msProductLineItems = new List<LineItemWrapper>();
        this.dpProductLineItems = new List<LineItemWrapper>();
        this.mapMPProducts = new Map<Id, List_Product_Price__c>();
        this.mapMSProducts = new Map<Id, List_Product_Price__c>();
        this.mapDPProducts = new Map<Id, List_Product_Price__c>();
        this.marketingShippingProdTypes = new Set<String>();
        this.designProductTypes = new Set<String>();
        this.requiresApproval = false;
        this.displayError = false;
        this.mapOppTeam =new Map<String,Map<string,OpportunityTeamMember>> (); 

        this.comissiontypeForReg = new Set<String>();

        try {
            //Map<String,Map<String,Business_Config__c>> mapProcessData= LibBusinessConfig.getGenericProcessData('addOpportunityLineItems');
            Map<String, Map<String, Business_Config__c>> mapProcessData = moam.get('addOpportunityLineItems');

            system.debug('mapProcessData: ' + mapProcessData + ' : ' + mapProcessData.isEmpty());

            if (!mapProcessData.isEmpty()) {
                if (!Test.isRunningTest()) {
                    this.mapBusinessData = mapProcessData.get(this.opp.RecordType.DeveloperName);
                } else {
                    this.mapBusinessData = new Map<String, Business_Config__c>();
                    for (Business_Config__c bc : [SELECT Id, Business_Rule_Value__c, Business_Rule_Name__c FROM Business_Config__c WHERE Process_Name__c = 'addOpportunityLineItems' AND Record_Type_Id__c = : this.opp.RecordType.DeveloperName]) {
                        //System.debug('$$$ adding ' + bc.Business_Rule_Name__c +' : ' + bc.Business_Rule_Value__c);
                        this.mapBusinessData.put(bc.Business_Rule_Name__c, bc);
                    }
            }
                //this.mapBusinessData = mapProcessData.get(this.opp.RecordType.DeveloperName);
                //System.debug('this.opp.RecordType.DeveloperName: ' + this.opp.RecordType.DeveloperName);
                //System.debug('mapBusinessData: ' + mapBusinessData);
                if (this.mapBusinessData != null && !this.mapBusinessData.isEmpty()) {
                    if (this.mapBusinessData.get('nonStandardContractValue') != null &&  String.isNotBlank(this.mapBusinessData.get('nonStandardContractValue').Business_Rule_Value__c)) {
                        this.nonStandardPicKValue = this.mapBusinessData.get('nonStandardContractValue').Business_Rule_Value__c;
                    }
                    if (this.mapBusinessData.get('Registration fee') != null &&  String.isNotBlank(this.mapBusinessData.get('Registration fee').Business_Rule_Value__c)) {
                        if (this.mapBusinessData.get('Registration fee').Business_Rule_Value__c.indexOf('::') > 1) {
                            for (String ct : this.mapBusinessData.get('Registration fee').Business_Rule_Value__c.split('::')) {
                                List<String> values = ct.split('=');
                                this.registrationFeeMap.put(values[0], values[1]);
                            }
                        } else {
                            List<String> values = this.mapBusinessData.get('Registration fee').Business_Rule_Value__c.split('=');
                            this.registrationFeeMap.put(values[0], values[1]);
                        }
                    }
                    if (this.mapBusinessData.get('Renewal fee') != null &&  String.isNotBlank(this.mapBusinessData.get('Renewal fee').Business_Rule_Value__c)) {
                        if (this.mapBusinessData.get('Renewal fee').Business_Rule_Value__c.indexOf('::') > 1) {
                            for (String ct : this.mapBusinessData.get('Renewal fee').Business_Rule_Value__c.split('::')) {
                                List<String> values = ct.split('=');
                                this.renewalFeeMap.put(values[0], values[1]);
                            }
                        } else {
                            List<String> values = this.mapBusinessData.get('Renewal fee').Business_Rule_Value__c.split('=');
                            this.renewalFeeMap.put(values[0], values[1]);
                        }
                    }
                    if(this.mapBusinessData.get('PremiumAPI')!=null  && Boolean.valueof(this.mapBusinessData.get('PremiumAPI').Business_Rule_Value__c)){
                        this.ppapi=true;
                    }
                    //if(this.mapBusinessData.get('VATInPercentage')!=null &&  String.isNotBlank(this.mapBusinessData.get('VATInPercentage').Business_Rule_Value__c)){
                    //    this.vatinPercentage = Double.valueOf(this.mapBusinessData.get('VATInPercentage').Business_Rule_Value__c);
                    //}
                    if (this.mapBusinessData.get('tieredKeyword') != null &&  String.isNotBlank(this.mapBusinessData.get('tieredKeyword').Business_Rule_Value__c)) {
                        this.tieredKeyWord = this.mapBusinessData.get('tieredKeyword').Business_Rule_Value__c;
                    }
                    /* if(this.mapBusinessData.get('approvalProcess')!=null &&  String.isNotBlank(this.mapBusinessData.get('approvalProcess').Business_Rule_Value__c)){
                        this.businessApprovalProcess = Boolean.valueOf(this.mapBusinessData.get('approvalProcess').Business_Rule_Value__c);
                     }*/
                    /*if(this.mapBusinessData.get('ApprovalProcessService')!=null &&  String.isNotBlank(this.mapBusinessData.get('ApprovalProcessService').Business_Rule_Value__c)){
                       this.approvalProcessService = Boolean.valueOf(this.mapBusinessData.get('ApprovalProcessService').Business_Rule_Value__c);
                    }*/
                    if (this.mapBusinessData.get('skipAutoApprovalQuote') != null &&  String.isNotBlank(this.mapBusinessData.get('skipAutoApprovalQuote').Business_Rule_Value__c)) {
                        this.skipAutoApprovalQuote = Boolean.valueOf(this.mapBusinessData.get('skipAutoApprovalQuote').Business_Rule_Value__c);
                    }
                    if (this.mapBusinessData.get('skipAutoOverlappingServiceStartDate') != null &&  String.isNotBlank(this.mapBusinessData.get('skipAutoOverlappingServiceStartDate').Business_Rule_Value__c)) {
                        if (this.mapBusinessData.get('skipAutoOverlappingServiceStartDate').Business_Rule_Value__c.indexOf(',') > 1) {
                            for (String ct : this.mapBusinessData.get('skipAutoOverlappingServiceStartDate').Business_Rule_Value__c.split(',')) {
                                this.overlappingDisabledCountrySet.add(ct);
                            }
                        } else {
                            this.overlappingDisabledCountrySet.add(this.mapBusinessData.get('skipAutoOverlappingServiceStartDate').Business_Rule_Value__c);
                        }

                    }
                    if (this.mapBusinessData.get('autoAnnualEndDate') != null &&  String.isNotBlank(this.mapBusinessData.get('autoAnnualEndDate').Business_Rule_Value__c)) {
                        if (this.mapBusinessData.get('autoAnnualEndDate').Business_Rule_Value__c.indexOf(',') > 1) {
                            for (String ct : this.mapBusinessData.get('autoAnnualEndDate').Business_Rule_Value__c.split(',')) {
                                this.annualEndDateCountrySet.add(ct);
                            }
                        } else {
                            this.annualEndDateCountrySet.add(this.mapBusinessData.get('autoAnnualEndDate').Business_Rule_Value__c);
                        }
                    }
                    if (this.mapBusinessData.get('annualRenewalFeeAdditionalCharge') != null &&  String.isNotBlank(this.mapBusinessData.get('annualRenewalFeeAdditionalCharge').Business_Rule_Value__c)) {
                        if (this.mapBusinessData.get('annualRenewalFeeAdditionalCharge').Business_Rule_Value__c.indexOf(',') > 1) {
                            for (String ct : this.mapBusinessData.get('annualRenewalFeeAdditionalCharge').Business_Rule_Value__c.split(',')) {
                                this.annualRenewalFeeCountrySet.add(ct);
                            }
                        } else {
                            this.annualRenewalFeeCountrySet.add(this.mapBusinessData.get('annualRenewalFeeAdditionalCharge').Business_Rule_Value__c);
                        }
                    }
                    if (this.mapBusinessData.get('updateAnnualAdditionalChargeStartDateWithMonths') != null &&  String.isNotBlank(this.mapBusinessData.get('updateAnnualAdditionalChargeStartDateWithMonths').Business_Rule_Value__c)) {
                        this.annualRenewalInMonths = Integer.valueOf(this.mapBusinessData.get('updateAnnualAdditionalChargeStartDateWithMonths').Business_Rule_Value__c);
                    }
                    /* Name of the product group for recurring charges */
                    if (this.mapBusinessData.get('productGroupName') != null &&  String.isNotBlank(this.mapBusinessData.get('productGroupName').Business_Rule_Value__c)) {
                        this.recurringFeeProductGroup = this.mapBusinessData.get('productGroupName').Business_Rule_Value__c;
                    }
                    if (this.mapBusinessData.get('adSalesTarif') != null &&  String.isNotBlank(this.mapBusinessData.get('adSalesTarif').Business_Rule_Value__c)) {
                        this.adSalesTarif = this.mapBusinessData.get('adSalesTarif').Business_Rule_Value__c;
                    }
                    if (this.mapBusinessData.get('FlatCommissionTarif') != null &&  String.isNotBlank(this.mapBusinessData.get('FlatCommissionTarif').Business_Rule_Value__c)) {
                        this.flatProductTarif = this.mapBusinessData.get('FlatCommissionTarif').Business_Rule_Value__c;
                    }
                    if (this.mapBusinessData.get('PremiumPlaceTarif') != null &&  String.isNotBlank(this.mapBusinessData.get('PremiumPlaceTarif').Business_Rule_Value__c)) {
                        this.ppTarif = this.mapBusinessData.get('PremiumPlaceTarif').Business_Rule_Value__c;
                    }
                    if (this.mapBusinessData.get('MenuPrintingTarif') != null &&  String.isNotBlank(this.mapBusinessData.get('MenuPrintingTarif').Business_Rule_Value__c)) {
                        this.mpTarif = this.mapBusinessData.get('MenuPrintingTarif').Business_Rule_Value__c;
                    }

                    if (this.mapBusinessData.get('useCombinedSaveAndCreateQuote') != null &&  String.isNotBlank(this.mapBusinessData.get('useCombinedSaveAndCreateQuote').Business_Rule_Value__c)) {
                        this.useCombinedSaveAndCreateQuote = Boolean.valueOf(this.mapBusinessData.get('useCombinedSaveAndCreateQuote').Business_Rule_Value__c);
                    }
                    if (this.mapBusinessData.get('showCommissionPerOrder') != null &&  String.isNotBlank(this.mapBusinessData.get('showCommissionPerOrder').Business_Rule_Value__c)) {
                        this.showCommissionPerOrder = Boolean.valueOf(this.mapBusinessData.get('showCommissionPerOrder').Business_Rule_Value__c);
                    }
                    if (this.mapBusinessData.get('commTypeForRegApproval') != null ) {
                         if (this.mapBusinessData.get('commTypeForRegApproval').Business_Rule_Value__c.indexOf(',') > 1) {
                            this.comissiontypeForReg.addAll(this.mapBusinessData.get('commTypeForRegApproval').Business_Rule_Value__c.split(','));
                        } else {
                            this.comissiontypeForReg.add(this.mapBusinessData.get('commTypeForRegApproval').Business_Rule_Value__c);

                        }
                    }
                    if (this.mapBusinessData.get('MarketingShippingTariff') != null &&  String.isNotBlank(this.mapBusinessData.get('MarketingShippingTariff').Business_Rule_Value__c)) {
                        this.mstarif = this.mapBusinessData.get('MarketingShippingTariff').Business_Rule_Value__c;
                    }
                    if (this.mstarif != null && this.mapBusinessData.get('MarketingShippingProdTypes') != null &&  String.isNotBlank(this.mapBusinessData.get('MarketingShippingProdTypes').Business_Rule_Value__c)) {
                        if (this.mapBusinessData.get('MarketingShippingProdTypes').Business_Rule_Value__c.indexOf(',') > 1) {
                            this.marketingShippingProdTypes.addAll(this.mapBusinessData.get('MarketingShippingProdTypes').Business_Rule_Value__c.split(','));
                        } else {
                            this.marketingShippingProdTypes.add(this.mapBusinessData.get('MarketingShippingProdTypes').Business_Rule_Value__c);

                        }
                    } if (this.mapBusinessData.get('DesignTarif') != null &&  String.isNotBlank(this.mapBusinessData.get('DesignTarif').Business_Rule_Value__c)) {


                        this.dpTarif = this.mapBusinessData.get('DesignTarif').Business_Rule_Value__c;


                    } if (this.dptarif != null && this.mapBusinessData.get('DesignProductTypes') != null &&  String.isNotBlank(this.mapBusinessData.get('DesignProductTypes').Business_Rule_Value__c)) {
                        if (this.mapBusinessData.get('DesignProductTypes').Business_Rule_Value__c.indexOf(',') > 1) {
                            this.designProductTypes.addAll(this.mapBusinessData.get('DesignProductTypes').Business_Rule_Value__c.split(','));
                        } else {
                            this.designProductTypes.add(this.mapBusinessData.get('DesignProductTypes').Business_Rule_Value__c);

                        }
                    }

                    this.tarifItems.add(new SelectOption('--', '-- ' +  Label.Opportunity_Select_Reset_Tariff + ' --'));
                    this.groupItems.add(new SelectOption('--', '-- ' + Label.Opportunity_Select_Product_Group + ' --'));
                    this.serviceItems.add(new SelectOption('--', '-- ' + Label.Opportunity_Select_A_Service +  ' --'));
                    this.opportunityCountry = [SELECT Id, Name, Iso__c FROM Country__c WHERE Name = : this.opp.Record_Country__c LIMIT 1];
                    Date today = Date.today();
                    this.myOptions.add(new SelectOption(today.month() + '-' + today.year(), today.month() + '-' + today.year()));
                    selectedMY = today.month() + '-' + today.year();

                    for (integer i = 0; i < 10; i++) {
                        Date nextDate = today.addMonths(i + 1);
                        this.myOptions.add(new SelectOption(nextDate.month() + '-' + nextDate.year(), nextDate.month() + '-' + nextDate.year()));
                    }
                    //System.debug('$$$ try to loop tarif:' + this.opportunityCompany);
                    /*for(Tarif__c tr:[
                        SELECT Id, Name FROM Tarif__c
                        WHERE RecordTypeId =: recordTypesByDevNameMap.get(this.opportunityCompany + '_Tarif').Id  AND Id_Country__c =: this.opportunityCountry.Id AND Is_Active__c=true order by Name ASC]){
                        */
                    for (Tarif__c tr : [
                                SELECT Id, Name FROM Tarif__c
                                WHERE RecordTypeId = : LibRecordTypeHelper.getRecordTypeValue(this.opportunityCompany + '_Tarif')  AND Id_Country__c = : this.opportunityCountry.Id AND Is_Active__c = true order by Name ASC]) {
                        if (tr.Name.equalsIgnoreCase('Premium Placement')) {
                            if (!this.ppapi || this.opp.Id_Tarif__c == tr.id) {
                                this.tarifItems.add(new SelectOption(tr.id, tr.Name));
                            }
                        } else {
                            this.tarifItems.add(new SelectOption(tr.id, tr.Name));
                        }
                        mapTarifItems.put(tr.id, tr);
                    }

                    /*for(List_Product_Group__c pg : [SELECT Id, Name FROM List_Product_Group__c
                        WHERE RecordTypeId =: recordTypesByDevNameMap.get(this.opportunityCompany + '_List_Product_Group').Id  AND Id_Country__c =: this.opportunityCountry.Id AND Name != :this.recurringFeeProductGroup]){
                        this.groupItems.add(new SelectOption(pg.id,pg.Name));
                    }*/
                    for (List_Product_Group__c pg : [SELECT Id, Name FROM List_Product_Group__c
                                                     WHERE RecordTypeId = : LibRecordTypeHelper.getRecordTypeValue(this.opportunityCompany + '_List_Product_Group')  AND Id_Country__c = : this.opportunityCountry.Id AND Name != :this.recurringFeeProductGroup]) {
                        this.groupItems.add(new SelectOption(pg.id, pg.Name));
                    }


                    //Comment Commission_Per_Order__c,Commission_Type__c for the deployment
                    /*for(List_Service_Price__c st : [SELECT Id, Name,  Maximum_Commission_In_Percentage__c, Requires_Approval__c, Minimum_Commission_in_Percentage__c,Commission_Per_Order__c,Commission_Type__c,Recurring_Fee__c,Is_Active__c FROM List_Service_Price__c
                        WHERE RecordTypeId =: recordTypesByDevNameMap.get(this.opportunityCompany + '_List_Service_Price').Id  AND Id_Country__c =: this.opportunityCountry.Id ]){
                        *///
                    for (List_Service_Price__c st : [SELECT Id, Name, Service_Type__c, Maximum_Commission_In_Percentage__c, Requires_Approval__c, Minimum_Commission_in_Percentage__c, Commission_Per_Order__c, Commission_Type__c, Recurring_Fee__c, Is_Active__c, Minimum_Commission_per_order__c, Maximum_Commission_per_order__c FROM List_Service_Price__c
                                                     WHERE RecordTypeId = : LibRecordTypeHelper.getRecordTypeValue(this.opportunityCompany + '_List_Service_Price')  AND Id_Country__c = : this.opportunityCountry.Id ]) {

                        this.mapListServicePrice.put(st.id, st);
                        //chnages for commission per order
                        if (st.Is_Active__c) {
                            if (st.Commission_Type__c == 'Per Order') {
                                if (this.showCommissionPerOrder) {
                                    this.serviceItems.add(new SelectOption(st.id, st.Name));
                                }
                            } else {
                                this.serviceItems.add(new SelectOption(st.id, st.Name));
                            }
                        }

                        //commission type
                        if (this.mapCommissionType.get(st.id) == null) {
                            this.mapCommissionType.put(st.id, st.Commission_type__c);
                        }
                    }
                    mapProductType.put(null, 'null');

                    List<List_Product_Price__c> lpplist = new List<List_Product_Price__c>();
                    for (List_Product_Price__c lpp : [ SELECT Id, Product_Type__c, Id_List_Product_Group__r.Name, Unapproved_Discount_Limit__c, Maximum_discount__c, Default_Quantity__c, Installments__c, Is_Active__c, Product_Name__c, List_Price__c, Requires_Replacement__c, RecordType.DeveloperName
                                                       FROM List_Product_Price__c where RecordTypeId = : LibRecordTypeHelper.getRecordTypeValue(this.opportunityCompany + '_List_Product_Price') and Id_Country__c = :this.opportunityCountry.id]) {
                        lpplist.add(lpp);
                        mapProductType.put(lpp.Id, lpp.Product_Type__c);
                        if (lpp.Product_Type__c != null && lpp.Product_Type__c.indexOf('Premium placement -') > -1) {
                            mapPPProducts.put(lpp.Id, lpp);
                        } else if (lpp.Product_Type__c != null && lpp.Product_Type__c == 'Menu Printing') {
                            mapMPProducts.put(lpp.ID, lpp);
                        } else if (lpp.Product_Type__c != null && !marketingShippingProdTypes.isEmpty() && marketingShippingProdTypes.contains(lpp.Product_Type__c)) {
                            mapMSProducts.put(lpp.ID, lpp);
                        } else if (lpp.Product_Type__c != null && !designProductTypes.isEmpty() && designProductTypes.contains(lpp.Product_Type__c)) {
                            mapDPProducts.put(lpp.ID, lpp);
                        }
                    }
                    if (this.ppTarif != null) {
                        getRelatedPPProducts();

                    }
                    if (this.mpTarif != null) {
                        getRelatedMPProducts();
                    }
                    if (this.msTarif != null) {
                        getRelatedMarketingShippingProducts();
                    }
                    if (this.dptarif != null) {
                        getRelatedDesignProducts();
                    }
                    //System.debug('mapProductType:'+mapProductType);
                    /* Logic for recurring charges. The business config rules "usesRecurringCharges" indicates that the company uses recurring charges and "recurringFee"
                     * is a comma separated value of product types that are a recurring fee. This will determine products and product items that shall be considered recurring charge
                    */
                    if (this.mapBusinessData.get('usesRecurringCharges') != null
                            && String.isNotBlank(this.mapBusinessData.get('recurringFee').Business_Rule_Value__c)
                            && !this.mapBusinessData.get('usesRecurringCharges').Business_Rule_Value__c.equals('false')) {
                        this.usesRecurringCharges = true;
                        this.recurringChargesList.add(new SelectOption('null', '-- ' + Label.Opportunity_Select_Charge + ' --'));
                        Opportunity_Line_Item__c opi =  new Opportunity_Line_Item__c(Line_Item_Type__c = 'Product');
                        //this.recurringChargeLineItems = new List<LineItemWrapper>();
                        this.recurringChargeLineItems.add(new LineItemWrapper(opi, false, 0, 'product'));
                        if (this.mapBusinessData.get('recurringFee') != null && String.isNotBlank(this.mapBusinessData.get('recurringFee').Business_Rule_Value__c)) {


                            //this.recuringChargesMap = new Map<Id, List_Product_Price__c>();
                            for (String str : this.mapBusinessData.get('recurringFee').Business_Rule_Value__c.split(',')) {
                                this.recuringChargeTypes.put(str, str);
                            }

                            for (List_Product_Price__c lpp : lpplist) {

                                if (recuringChargeTypes.get(lpp.Product_Type__c) != null) {
                                    if (lpp.RecordType.DeveloperName.indexOf('CD_') == 0 && (lpp.Product_Type__c == '' || lpp.Product_Type__c == '')) {

                                    } else {
                                        this.recurringChargesList.add(new SelectOption(lpp.Id, lpp.Product_Name__c));
                                        recuringChargesMap.put(lpp.Id, lpp);
                                    }
                                }
                            }
                        }
                    }
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.BusinessProcessNotActive));
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.BusinessProcessNotActive));
            }
            this.mapOppTeam = LibBusinessConfig.determineApproverMap(this.opp.Id);
            this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 0, Total_Amount__c = 0, Discount__c = '0', Line_Item_Type__c = 'Product');
            this.productLineItems.add(new LineItemWrapper(this.selectedProductItem, false, 0, 'product'));
            this.selectedService = new Opportunity_Line_Item__c();
            this.serviceLineItems.add(new LineItemWrapper(this.selectedService, false, 0, 'service'));

            List<Opportunity_Line_Item__c> listPreviouslySelectedProducts = new List<Opportunity_Line_Item__c>(
                [
                    SELECT
                    Name,
                    Id_List_Price_Product__c,
                    Id_List_Price_Product__r.Product_Type__c,
                    Id_List_Price_Product__r.Unapproved_Discount_Limit__c,
                    Id_List_Price_Product__r.maximum_discount__c,
                    Id_List_Price_Product__r.requires_add_on__c,
                    Listed_Price__c,
                    Quantity__c,
                    Total_Amount__c,
                    Product_Group__c,
                    Discount__c,
                    Installments__c,
                    Booking_Api_Id__c,
                    Position__c,
                    Position_fm__c,
                    Has_Related_Tarif__c,
                    CurrencyIsoCode,
                    Start_Date__c,
                    End_Date__c,
                    Line_Item_Type__c,
                    Category__c,
                    Category_Id__c,
                    District__c,
                    District_Id__c,
                    sub_type__c,
                    City_ZipCode__c ,
                    deposit__c,
                    deposit_method__c,
                    Size__c,
                    Weight__c,
                    Number_of_Copies__c,
                    Design_Note__c,
                    Recurring_Fee__c,
                    Commission_In_Percentage__c,
                    Commission_Per_Order__c,
                    Commission_Type__c,
                    online_payment_fee__c,
                    Id_List_Service_Price__c,
                    Id_List_Service_Price__r.Maximum_Commission_In_Percentage__c,
                    Id_List_Service_Price__r.Minimum_Commission_in_Percentage__c,
                    Id_List_Service_Price__r.Minimum_Commission_per_order__c,
                    Id_List_Service_Price__r.Maximum_Commission_per_order__c,
                    Min__c,
                    Max__c,
                    index__c,
                    IsTiered__c,
                    subsidy__c
                    FROM Opportunity_Line_Item__c WHERE Id_Opportunity__c = : this.opp.Id order by Booking_Api_Id__c, Start_Date__c, index__c ASC]);


            if (!listPreviouslySelectedProducts.isEmpty()) {
                Integer recurringFeeCount = 0;
                Integer productCount = 0;
                Integer adSalesCount = 0;
                Integer flatProductCount = 0;
                Integer ppProductCount = 0;
                Integer mpProductCount = 0;
                Integer msProductCount = 0;
                Integer dpProductCount = 0;
                for (Integer i = 0; i < listPreviouslySelectedProducts.size(); i++) {
                    if (listPreviouslySelectedProducts[i].Line_Item_Type__c == 'Product') {
                        mapProductType.put(listPreviouslySelectedProducts[i].Id, listPreviouslySelectedProducts[i].Id_List_Price_Product__r.Product_Type__c);
                        if (!this.mapMaximumDiscount.containsKey(listPreviouslySelectedProducts[i].Id_List_Price_Product__c)) {
                            if (listPreviouslySelectedProducts[i].Id_List_Price_Product__r.Unapproved_Discount_Limit__c != null) {
                                this.mapMaximumDiscount.put(listPreviouslySelectedProducts[i].Id_List_Price_Product__c, listPreviouslySelectedProducts[i].Id_List_Price_Product__r.Unapproved_Discount_Limit__c);
                            }
                        }
                        if (!this.mapHasApproval.containsKey(listPreviouslySelectedProducts[i].Id)) {
                            // if(this.selectedProduct.Unapproved_Discount_Limit__c!=null){
                            this.mapHasApproval.put(listPreviouslySelectedProducts[i].Id_List_Price_Product__c, listPreviouslySelectedProducts[i].Id_List_Price_Product__r.requires_add_on__c);
                            // }
                        }
                        /*if(this.recuringChargesMap.get(listPreviouslySelectedProducts[i].Id_List_Price_Product__c) == null && listPreviouslySelectedProducts[i].Ad_Sales_Type__c==null && listPreviouslySelectedProducts[i].API_Type__c==null){
                            LineItemWrapper lineItem = new LineItemWrapper(listPreviouslySelectedProducts[i], false, productCount+1);
                            this.subTotal += lineItem.product.Total_Amount__c != null ? lineItem.product.Total_Amount__c : 0;
                            this.productLineItems.add(lineItem);
                            productCount++;
                        }

                        if(this.recuringChargesMap.get(listPreviouslySelectedProducts[i].Id_List_Price_Product__c) != null && listPreviouslySelectedProducts[i].Ad_Sales_Type__c==null && listPreviouslySelectedProducts[i].API_Type__c==null){
                            this.recurringChargeLineItems.add(new LineItemWrapper(listPreviouslySelectedProducts[i], false, this.recurringChargeLineItems.size() + recurringFeeCount));
                            recurringFeeCount++;
                        }*/

                        if (listPreviouslySelectedProducts[i].sub_type__c == 'Ad Sales') {
                            setVisibility(true, false, false, false, false, false, false, false, false, false);

                            LineItemWrapper lineItem = new LineItemWrapper(listPreviouslySelectedProducts[i], false, adSalesCount, 'product');
                            this.subTotal += lineItem.product.Total_Amount__c != null ? lineItem.product.Total_Amount__c : 0;
                            this.adSalesProductLineItems.add(lineItem);
                            adSalesCount++;
                        } else if (/*listPreviouslySelectedProducts[i].API_Type__c!=null && */listPreviouslySelectedProducts[i].sub_Type__c == 'Flat Commission') {
                            setVisibility(false, true, false, false, false, false, false, false, false, false);

                            LineItemWrapper lineItem = new LineItemWrapper(listPreviouslySelectedProducts[i], false, flatProductCount, 'product');
                            this.subTotal += lineItem.product.Total_Amount__c != null ? lineItem.product.Total_Amount__c : 0;
                            this.flatProductLineItems.add(lineItem);
                            flatProductCount++;
                        } else if (listPreviouslySelectedProducts[i].sub_Type__c != null && listPreviouslySelectedProducts[i].sub_Type__c == 'Premium Placement') {
                            if (this.ppapi) {
                                setVisibility(false, false, false, false, false, true, false, false, false, false);
                                this.ppAPILineItems.add(listPreviouslySelectedProducts[i]);
                                this.lockTariffSelection = true;
                            } else {
                                setVisibility(false, false, true, false, false, false, false, false, false, false);
                            }

                            if (ppProductLineItems.isEmpty()) {
                                this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 0, Total_Amount__c = 0, Discount__c = '0');
                                this.ppProductLineItems.add(new LineItemWrapper(this.selectedProductItem, false, 0, 'Product'));
                            }
                            LineItemWrapper lineItem = new LineItemWrapper(listPreviouslySelectedProducts[i], false, ppProductCount + 1, 'Product');
                            this.subTotal += lineItem.product.Total_Amount__c != null ? lineItem.product.Total_Amount__c : 0;
                            this.ppProductLineItems.add(lineItem);
                            ppProductCount++;
                        } else if (listPreviouslySelectedProducts[i].sub_Type__c != null && listPreviouslySelectedProducts[i].sub_Type__c == 'Menu Printing' && this.mptarif != null) {
                            //if(this.opportunityCountry.Iso__c=='UK'){
                            setVisibility(false, false, false, false, false, false, true, false, false, false);
                            if (mpProductLineItems.isEmpty()) {
                                this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 1, Total_Amount__c = 0, Discount__c = '0');
                                this.mpProductLineItems.add(new LineItemWrapper(this.selectedProductItem, false, 0, 'Product'));
                            }
                            LineItemWrapper lineItem = new LineItemWrapper(listPreviouslySelectedProducts[i], false, mpProductCount + 1, 'Product');
                            this.subTotal += lineItem.product.Total_Amount__c != null ? lineItem.product.Total_Amount__c : 0;
                            this.mpProductLineItems.add(lineItem);
                            mpProductCount++;
                        } else if (this.mstarif != null && listPreviouslySelectedProducts[i].sub_Type__c != null && !marketingShippingProdTypes.isEmpty() && marketingShippingProdTypes.contains(listPreviouslySelectedProducts[i].sub_Type__c) ) {
                            setVisibility(false, false, false, false, false, false, false, false, true, false);
                            if (msProductLineItems.isEmpty()) {
                                this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 1, Total_Amount__c = 0, Discount__c = '0');
                                this.msProductLineItems.add(new LineItemWrapper(this.selectedProductItem, false, 0, 'Product'));
                            }
                            LineItemWrapper lineItem = new LineItemWrapper(listPreviouslySelectedProducts[i], false, msProductCount + 1, 'Product');
                            this.subTotal += lineItem.product.Total_Amount__c != null ? lineItem.product.Total_Amount__c : 0;
                            this.msProductLineItems.add(lineItem);
                            msProductCount++;
                        } else if (this.dptarif != null && listPreviouslySelectedProducts[i].sub_Type__c != null && !designProductTypes.isEmpty() && designProductTypes.contains(listPreviouslySelectedProducts[i].sub_Type__c) ) {
                            setVisibility(false, false, false, false, false, false, false, false, false, true);
                            if (dpProductLineItems.isEmpty()) {
                                //this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 1, Total_Amount__c = 0, Discount__c = '0');
                                //this.dpProductLineItems.add(new LineItemWrapper(this.selectedProductItem, false, 0,'Product'));
                            }
                            LineItemWrapper lineItem = new LineItemWrapper(listPreviouslySelectedProducts[i], false, dpProductCount + 1, 'Product');
                            this.subTotal += lineItem.product.Total_Amount__c != null ? lineItem.product.Total_Amount__c : 0;
                            this.dpProductLineItems.add(lineItem);
                            system.debug('***prev' + this.dpProductLineItems);
                            dpProductCount++;
                        } else if (listPreviouslySelectedProducts[i].sub_type__c != 'Ad Sales' || listPreviouslySelectedProducts[i].sub_type__c != 'Flat Commission' || listPreviouslySelectedProducts[i].sub_type__c == 'Premium Placement') {
                            if (this.recuringChargesMap.get(listPreviouslySelectedProducts[i].Id_List_Price_Product__c) == null ) {
                                LineItemWrapper lineItem = new LineItemWrapper(listPreviouslySelectedProducts[i], false, productCount + 1, 'product');
                                this.subTotal += lineItem.product.Total_Amount__c != null ? lineItem.product.Total_Amount__c : 0;
                                this.productLineItems.add(lineItem);
                                productCount++;
                            }

                            if (this.recuringChargesMap.get(listPreviouslySelectedProducts[i].Id_List_Price_Product__c) != null ) {
                                this.recurringChargeLineItems.add(new LineItemWrapper(listPreviouslySelectedProducts[i], false, this.recurringChargeLineItems.size() + recurringFeeCount, 'product'));
                                recurringFeeCount++;
                            }
                        }
                    } else {
                        //service
                        //System.debug('listPreviouslySelectedServices[i]: '+listPreviouslySelectedServices[i].Commission_Per_Order__c+' ,+listPreviouslySelectedServices[i].Commission_In_Percentage__c: '+listPreviouslySelectedServices[i].Commission_In_Percentage__c);
                        if (listPreviouslySelectedProducts[i].IsTiered__c) {
                            setVisibility(false, false, false, false, false, false, false, true, false, false);

                            if (!this.serviceLineItems.isEmpty() && this.serviceLineItems[0].position == 0) {
                                this.serviceLineItems.remove(0);
                            }
                            LineItemWrapper lineItem = new LineItemWrapper(listPreviouslySelectedProducts[i], false, Integer.valueOf(listPreviouslySelectedProducts[i].index__c), 'Service');
                            this.serviceLineItems.add(lineItem);
                            if (this.mapListServicePrice.get(lineItem.service.Id_List_Service_Price__c) == null) {
                                this.mapListServicePrice.put(lineItem.service.Id_List_Service_Price__c, lineItem.service.Id_List_Service_Price__r);
                            }
                        } else {
                            LineItemWrapper lineItem = new LineItemWrapper(listPreviouslySelectedProducts[i], false, i + 1, 'Service');
                            this.serviceLineItems.add(lineItem);
                            if (this.mapListServicePrice.get(lineItem.service.Id_List_Service_Price__c) == null) {
                                this.mapListServicePrice.put(lineItem.service.Id_List_Service_Price__c, lineItem.service.Id_List_Service_Price__r);
                            }
                        }
                    }
                }
            }

            if (!ppProductLineItems.isEmpty()) {
                this.ppProductLineItems.add(new LineItemWrapper(this.subTotal, this.ppProductLineItems.size()));
            }
            if (!mpProductLineItems.isEmpty()) {
                this.mpProductLineItems.add(new LineItemWrapper(this.subTotal, this.mpProductLineItems.size()));
            }
            if (!msProductLineItems.isEmpty()) {
                this.msProductLineItems.add(new LineItemWrapper(this.subTotal, this.msProductLineItems.size()));
            }
            if (!dpProductLineItems.isEmpty()) {
                this.dpProductLineItems.add(new LineItemWrapper(this.subTotal, this.dpProductLineItems.size()));
            }

            if (this.showAdSalesBlock) {
                //done changes for adsales on 15.10.15

                if (this.mapCategories.isEmpty()) {
                    adSalesAPICallout();
                }
                /*if(this.mapDistrictPrice.isEmpty()){
                    adSalesAPICallout();
                }*/

                this.adSalesProductLineItems.add(new LineItemWrapper(this.subTotal, this.adSalesProductLineItems.size()));

            }

            if (this.showFlatProductBlock) {
                if (this.mapDistrictsFlat.isEmpty()) {
                    flatCommissionAPICallout();
                }
                this.flatProductLineItems.add(new LineItemWrapper(this.subTotal, this.flatProductLineItems.size()));

            }

            this.productLineItems.add(new LineItemWrapper(this.subTotal, this.productLineItems.size()));

            
            if ((!this.productLineItems.isEmpty() && this.productLineItems.size() > 2) || (!this.serviceLineItems.isEmpty() && this.serviceLineItems.size() > 1)) {
                //changes for ME approval flow.
                if (!this.useCombinedSaveAndCreateQuote) {
                    this.availableForQuote = true;
                }

            }
            if (!this.adSalesProductLineItems.isEmpty() && this.adSalesProductLineItems.size() > 1) {
                if (!this.useCombinedSaveAndCreateQuote) {
                    this.availableForQuote = true;
                }
            }
            if (!this.flatProductLineItems.isEmpty() && this.flatProductLineItems.size() > 1) {
                if (!this.useCombinedSaveAndCreateQuote) {
                    this.availableForQuote = true;
                }
            }
            //System.debug('sizes: '+this.productLineItems.size()+', '+this.serviceLineItems.size()+', '+this.adSalesProductLineItems.size()+', '+this.flatProductLineItems.size());
            //System.debug('mapMaximumDiscount in const: '+mapMaximumDiscount);
            this.checkIfOpportunityIsLocked();
            this.determineOpportunityTarifItems();
            //this.retrieveServiceTypes();
        } catch (Exception e) {
            //System.debug('error at constructor: '+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));

        }
    }

    private void setVisibility(boolean adSales, boolean flatProd, boolean ppBlock, boolean servLine, boolean prodLine, boolean apiPPBlock, boolean mpBlock, boolean tieredBlock, boolean msBlock, boolean dpBlock) {
        this.showAdSalesBlock = adSales;
        this.showFlatProductBlock = flatProd;
        this.showPPBlock = ppBlock;
        this.showServiceLineItems = servLine;
        this.showProductLineItems = prodLine;
        this.showAPIPPBlock = apiPPBlock;
        this.showMpBlock = mpBlock;
        this.showTieredBlock = tieredBlock;
        this.showMSBlock = msBlock;
        this.showDPBlock = dpBlock;

    }
    private void adSalesAPICallout() {
        /*if(this.opp.Account.Backend_ID__c!=null){
             DistrictPriceCategoryWrapper diPrCaWr = ClsWebserviceCalloutAdSalesKR.getAvailableDistrictsAndCategories(this.opp.Account.Backend_ID__c);
             System.debug('diPrCaWr: '+diPrCaWr);
             if(!diPrCaWr.errorFlag){
                 //Populating all the category select list
                 this.categories.clear();
                 if(!diPrCaWr.mapCategories.isEmpty()){
                     System.debug('diPrCaWr.mapCategories: '+diPrCaWr.mapCategories);
                     for(Integer cId : diPrCaWr.mapCategories.keySet()){
                         this.categories.add(new SelectOption(''+cId, diPrCaWr.mapCategories.get(cId)));
                         this.mapCategories.put(''+cId, diPrCaWr.mapCategories.get(cId));
                     }
                 }else{
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,Label.Adsales_api_category_error));
                 }
                 //Populate all the district in a map
                 this.mapDistricts.clear();
                 if(!diPrCaWr.mapDistricts.isEmpty()){

                     for(Integer dId : diPrCaWr.mapDistricts.keySet()){
                         this.mapDistricts.put(''+dId,diPrCaWr.mapDistricts.get(dId));
                     }
                 }else{
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,Label.Adsales_api_district_error));
                 }

                 // Populate all the type
                 this.mapDistrictPrice.clear();
                 if(!diPrCaWr.mapDistrictPrices.isEmpty()){
                     System.debug('diPrCaWr.mapDistrictPrices size: '+diPrCaWr.mapDistrictPrices.size());
                     this.mapDistrictPrice.putAll(diPrCaWr.mapDistrictPrices);
                 }else{
                      ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,Label.Adsales_api_district_price_error));

                 }

                 //Populate All the type district price combination
                 this.mapTypeDistrictPriceInfo.clear();
                 this.typeDistricts.clear();
                 if(!diPrCaWr.mapTypeDistrictPricesInfo.isEmpty()){
                     System.debug('diPrCaWr.mapTypeDistrictPricesInfo size : '+diPrCaWr.mapTypeDistrictPricesInfo.size());
                     this.mapTypeDistrictPriceInfo.putAll(diPrCaWr.mapTypeDistrictPricesInfo);

                     for(String typeKey : this.mapTypeDistrictPriceInfo.keySet()){
                         this.typeDistricts.add(new SelectOption(typeKey, this.mapTypeDistrictPriceInfo.get(typeKey)));
                     }
                 }else{
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,label.Adsales_api_type_district_price_error));
                  return;
                 }

             }else{
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,diPrCaWr.errorMessage));
                 return;
             }
         }else{
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,Label.Account_does_not_have_backend_Id));
             return;
         } */


        //Adsales changes on 15.10.15
        this.mapCategories.clear();
        this.categories.clear();
        String adSalesCat = AdSales__c.getValues('Category').Values__c;
        for (String str : adSalesCat.split(',')) {
            this.categories.add(new SelectOption(str, str));
            this.mapCategories.put(str, str);
        }
        this.adSalesTypes.clear();
        this.adSalesTypes.add(new SelectOption('Super', 'Super'));
        this.adSalesTypes.add(new SelectOption('Basic', 'Basic'));

    }

    //flat commission callout to yogiyo
    @TestVisible
    private void flatCommissionAPICallout() {
        if (this.opp.Account.Backend_ID__c != null) {
            FixedCommissionWrapper diPrCaWr = ClsWebserviceCalloutsKR.getFixAmountCommissionDistricts(this.opp.Account.Backend_ID__c);
            //System.debug('diPrCaWr: '+diPrCaWr);
            if (!diPrCaWr.errorFlag) {
                //Populating all the category select list
                this.categoriesFlat.clear();
                if (!diPrCaWr.mapCategories.isEmpty()) {
                    //System.debug('diPrCaWr.mapCategories: '+diPrCaWr.mapCategories);
                    for (String cId : diPrCaWr.mapCategories.keySet()) {
                        this.categoriesFlat.add(new SelectOption('' + cId, diPrCaWr.mapCategories.get(cId)));
                        this.mapCategoriesFlat.put('' + cId, diPrCaWr.mapCategories.get(cId));
                    }
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.Flat_Commission_api_category_error));
                }
                //Populate all the district in a map
                this.mapDistrictsFlat.clear();
                this.districtsFlat.clear();
                if (!diPrCaWr.mapDistricts.isEmpty()) {

                    for (String dId : diPrCaWr.mapDistricts.keySet()) {
                        this.mapDistrictsFlat.put('' + dId, diPrCaWr.mapDistricts.get(dId));
                        this.districtsFlat.add(new SelectOption('' + dId, diPrCaWr.mapDistricts.get(dId)));
                    }
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.Flat_Commission_api_district_error));
                }



                // Populate all the type
                /*this.mapDistrictPriceFlat.clear();
                if(!diPrCaWr.mapDistrictPrices.isEmpty()){
                    System.debug('diPrCaWr.mapDistrictPrices size: '+diPrCaWr.mapDistrictPrices.size());
                    this.mapDistrictPriceFlat.putAll(diPrCaWr.mapDistrictPrices);
                }else{
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,Label.Flat_Commission_api_district_price_error));

                }*/

                //Populate All the type district price combination
                //this.mapDistrictPriceInfoFlat.clear();
                //this.districtsFlat.clear();
                /*if(!diPrCaWr.mapDistrictPricesInfo.isEmpty()){
                    System.debug('diPrCaWr.mapDistrictPricesInfo size : '+diPrCaWr.mapDistrictPricesInfo.size());
                    this.mapDistrictPriceInfoFlat.putAll(diPrCaWr.mapDistrictPricesInfo);

                    for(String typeKey : this.mapDistrictPriceInfoFlat.keySet()){
                        this.districtsFlat.add(new SelectOption(''+typeKey, this.mapDistrictPriceInfoFlat.get(typeKey)));
                    }
                }else{
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,label.Flat_Commission_api_district_price_error));
                 return;
                }*/

            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, diPrCaWr.errorMessage));
                return;
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.Account_does_not_have_backend_Id));
            return;
        }
    }

    

    public void determineCompany() {
        List<String> recordTypeParts = (this.opp.RecordType.DeveloperName).split('_');
        if (recordTypeParts.size() > 2 && recordTypeParts[1].length() == 2) {
            this.opportunityCompany = recordTypeParts[0] + '_' + recordTypeParts[1];
        } else {
            this.opportunityCompany = recordTypeParts[0];
        }
    }


    

    /**
    * Lock the opportunity product items if an existing quote has the status either 'Accepted' or 'Waiting for answer'.
    *
    *
    * @param none
    * @return boolean (true if locked, false if editable)
    */
    public boolean checkIfOpportunityIsLocked() {
        List<Opportunity_Quote__c> listOppQuote =  [SELECT Id FROM Opportunity_Quote__c WHERE Id_Opportunity__c = : this.opp.Id AND Status__c IN ('Waiting for answer', 'Accepted')];
        if (!listOppQuote.isEmpty()) {
            this.lockLineItems = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.lockOpportunityItems));
            return true;

        } else {
            return false;
        }
    }

    

    // Limit of 1 becuase an opportunity should have only a single tarif
    public void determineOpportunityTarifItems() {

        //this.selectedTarifList = [SELECT Id, Id_Tarif__c, Id_Tarif__r.Name, Id_Opportunity__c FROM Opportunity_Tarif_Item__c WHERE Id_Opportunity__c =: this.opp.Id LIMIT 1];

        if (opp.Id_Tarif__c != null) {
            this.selectedTarifItem = this.opp.Id_Tarif__c;
        } else {
            this.selectedTarifItem = '--';
        }

        if (this.showPPBlock || (this.opp.Id_Tarif__c != null && this.ppTarif != null && this.opp.Id_Tarif__r.Name == this.ppTarif)) {
            if (this.ppapi) {
                this.lockTariffSelection = true;
                setVisibility(false, false, false, false, false, true, false, false, false, false);
            } else {
                setVisibility(false, false, true, false, false, false, false, false, false, false);
            }
            if (ppProductLineItems.isEmpty()) {
                this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 0, Total_Amount__c = 0, Discount__c = '0');
                this.ppProductLineItems.add(new LineItemWrapper(this.selectedProductItem, false, 0, 'Product'));
                this.ppProductLineItems.add(new LineItemWrapper(this.subTotal, this.ppProductLineItems.size()));
            }

            /*if(this.ppProductLineItems.size()==0){
                    this.ppProductLineItems.add(new LineItemWrapper(this.subTotal, this.ppProductLineItems.size()));
            }*/
            //List<Tarif_Member__c> trMem =  [SELECT Id, Tarif_Name__c, Id_Tarif_Item__c, Type__c FROM Tarif_Member__c WHERE Tarif_Name__c =: this.selectedTarifItem and type__c = 'Product'];

        } if (this.showTieredBlock || (this.opp.Id_Tarif__c != null && this.tieredKeyWord != null && this.tieredKeyWord != '' && this.opp.Id_Tarif__r.Name.containsIgnoreCase(this.tieredKeyWord))) {
            setVisibility(false, false, false, false, false, false, false, true, false, false);

        } else if (this.showMPBlock || (this.opp.Id_Tarif__c != null && this.mpTarif != null && this.opp.Id_Tarif__r.Name == this.mpTarif)) {
            system.debug('#####mp');
            //if(this.opportunityCountry.Iso__c=='UK'){
            setVisibility(false, false, false, false, false, false, true, false, false, false);
            //}
            if (mpProductLineItems.isEmpty()) {
                this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 1, Total_Amount__c = 0, Discount__c = '0');
                this.mpProductLineItems.add(new LineItemWrapper(this.selectedProductItem, false, 0, 'Product'));
                this.mpProductLineItems.add(new LineItemWrapper(this.subTotal, this.mpProductLineItems.size()));
            }

        } else if (this.showMSBlock || (this.opp.Id_Tarif__c != null && this.msTarif != null && this.opp.Id_Tarif__r.Name == this.msTarif)) {
            system.debug('#####ms');
            setVisibility(false, false, false, false, false, false, false, false, true, false);
            if (msProductLineItems.isEmpty()) {
                this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 1, Total_Amount__c = 0, Discount__c = '0');
                this.msProductLineItems.add(new LineItemWrapper(this.selectedProductItem, false, 0, 'Product'));
                this.msProductLineItems.add(new LineItemWrapper(this.subTotal, this.msProductLineItems.size()));
            }

        } else if (this.showDPBlock || (this.opp.Id_Tarif__c != null && this.dpTarif != null && this.opp.Id_Tarif__r.Name.containsignorecase(this.dpTarif)) ) {
            system.debug('#####dp');
            setVisibility(false, false, false, false, false, false, false, false, false, true);
            if (dpProductLineItems.isEmpty()) {
                // this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 1, Total_Amount__c = 0, Discount__c = '0');
                // this.dpProductLineItems.add(new LineItemWrapper(this.selectedProductItem, false, 0,'Product'));
                // this.dpProductLineItems.add(new LineItemWrapper(this.subTotal, this.dpProductLineItems.size()));
            }

        }

        else if (this.showAdSalesBlock || (this.opp.Id_Tarif__c != null && this.adSalesTarif != null && this.opp.Id_Tarif__r.Name == this.adSalesTarif)) {
            setVisibility(true, false, false, false, false, false, false, false, false, false);
            if (this.adSalesProductLineItems.size() == 0) {
                this.adSalesProductLineItems.add(new LineItemWrapper(this.subTotal, this.adSalesProductLineItems.size()));
            }
            List<Tarif_Member__c> trMem =  [SELECT Id, Tarif_Name__c, Id_Tarif_Item__c, Type__c FROM Tarif_Member__c WHERE Tarif_Name__c = : this.selectedTarifItem and type__c = 'Product' limit 1];
            if (trMem != null && !trMem.isEmpty() && trMem[0].Id_Tarif_Item__c != null) {
                this.adSalesProductPrice = trMem[0].Id_Tarif_Item__c;
                if (this.mapDistrictPrice.isEmpty()) {
                    adSalesAPICallout();
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.Adsales_product_is_inactive));
                return;
            }
        } else if (this.showFlatProductBlock || (this.opp.Id_Tarif__c != null && this.flatProductTarif != null && this.opp.Id_Tarif__r.Name == this.flatProductTarif)) {
            setVisibility(false, true, false, false, false, false, false, false, false, false);
            if (this.flatProductLineItems.size() == 0) {
                this.flatProductLineItems.add(new LineItemWrapper(this.subTotal, this.flatProductLineItems.size()));
            }
            List<Tarif_Member__c> trMem =  [SELECT Id, Tarif_Name__c, Id_Tarif_Item__c, Type__c FROM Tarif_Member__c WHERE Tarif_Name__c = : this.selectedTarifItem and type__c = 'Product' limit 1];
            if (trMem != null && !trMem.isEmpty() && trMem[0].Id_Tarif_Item__c != null) {
                this.flatProductPrice = trMem[0].Id_Tarif_Item__c;
                if (this.mapDistrictsFlat.isEmpty()) {
                    flatCommissionAPICallout();
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.Flat_Commission_product_is_inactive));
                return;
            }
        }

    }

    /**
    * called when a tariff is selected from the tariff dropdown on the createProductLineItems page.
    * - removes opportunity line items for previously selected tariff
    * - retrieves tariff members for currently selected tariff and adds opportunity line items (services, recurring charges & products) for these tariff members
    *
    * @param
    * @return void
    */
    public void getRelatedTarifMember() {
        this.availableForQuote = false;
        this.subTotal = 0;
        this.hasAsset = false;
        this.hasService = false;
        this.isMenuPrinting = false;
        this.isAdsales = false;
        this.isFlatProduct = false;
        this.isCarLease = false;
        this.isOwnerChange = false;
        this.isPPProduct = false;
        this.isPPProductDiscount = false;

        List<ID> listServiceTarifmember = new List<ID>();
        List<ID> listProductTarifmember = new List<ID>();
        //System.debug('this.selectedTarifList: '+this.selectedTarifList);
        //if(!this.selectedTarifList.isEmpty()){
        // for(Opportunity_Tarif_Item__c opti : this.selectedTarifList){
        if (this.opp.Id_Tarif__c != null) {
            this.opp.Id_Tarif__c = null;
            //selectedTarifToDeleteList.add(opti);
        }
        //}
        //selectedTarifList.clear();
        //}

        this.removeTariffProducts();            //remove opportunity product line items for previously selected tariff
        this.removedTariffRecurringCharge();    //add opportunity recurring charge line items for previously selected tariff
        this.removeTariffServices();            //add opportunity service line items for previously selected tariff
        this.removeTariffAdsales();             //remove opportunity Ad sales product line items for previously selected tariff
        this.removeTariffFlatProd();            //remove opportunity  flat product line items for previously selected tariff
        this.removeTariffPPProd();
        this.removeTariffMPProd();
        this.removeTariffMSProd();
        this.removeTariffDPProd();

        this.selectedServiceItem = '--';


        this.subTotal = 0;
        if (this.selectedTarifItem != '--') {
            this.selectedTarifItemName = this.mapTarifItems.get(selectedTarifItem).Name;
            this.showAdSalesBlock = false;
            if (( this.adSalesTarif == null || (this.adSalesTarif != null && this.adSalesTarif != this.selectedTarifItemName)) &&  (this.flatProductTarif == null || (this.flatProductTarif != null && this.flatProductTarif != this.selectedTarifItemName)) && (this.ppTarif == null || (this.ppTarif != null && this.ppTarif != this.selectedTarifItemName))  && (this.mpTarif == null || (this.mpTarif != null && this.mpTarif != this.selectedTarifItemName)) && (this.msTarif == null || (this.msTarif != null && this.msTarif != this.selectedTarifItemName)) && (this.dpTarif == null || (this.dpTarif != null && !this.selectedTarifItemName.containsIgnoreCase(this.dpTarif))) && ( this.tieredKeyWord == null || (this.tieredKeyWord != null && !this.selectedTarifItemName.containsIgnoreCase(this.tieredKeyWord)))) {
                setVisibility(false, false, false, true, true, false, false, false, false, false);
                this.opp.Id_Tarif__c = this.selectedTarifItem;
                for (Tarif_Member__c trMem :  [SELECT Id, Tarif_Name__c, Id_Tarif_Item__c, Type__c FROM Tarif_Member__c WHERE Tarif_Name__c = : this.selectedTarifItem]) {
                    if (trMem.Id_Tarif_Item__c != null) {
                        if (trMem.Type__c == 'Service') {
                            listServiceTarifmember.add(trMem.Id_Tarif_Item__c);
                        } else {
                            listProductTarifmember.add(trMem.Id_Tarif_Item__c);
                        }
                    }
                }
            } else if (this.tieredKeyWord != null && this.selectedTarifItemName.containsIgnoreCase(this.tieredKeyWord)) {
                this.opp.Id_Tarif__c = this.selectedTarifItem;
                setVisibility(false, false, false, false, false, false, false, true, false, false);
                for (Tarif_Member__c trMem :  [SELECT Id, Tarif_Name__c, Id_Tarif_Item__c, Type__c FROM Tarif_Member__c WHERE Tarif_Name__c = : this.selectedTarifItem ]) {
                    if (trMem.Id_Tarif_Item__c != null) {
                        if (trMem.Type__c == 'Service') {
                            listServiceTarifmember.add(trMem.Id_Tarif_Item__c);
                            break;
                        }
                    }
                }

            } else if (this.ppTarif != null && this.ppTarif == this.selectedTarifItemName) {
                if (this.ppapi) {
                    setVisibility(false, false, false, false, false, true, false, false, false, false);
                } else {
                    setVisibility(false, false, true, false, false, false, false, false, false, false);
                }
                this.opp.Id_Tarif__c = this.selectedTarifItem;

                //this.selectedTarifList.add(new Opportunity_Tarif_Item__c(name = mapTarifItems.get(selectedTarifItem).name, Id_Opportunity__c = this.opp.Id, Id_Tarif__c = this.selectedTarifItem, recordtypeId = LibRecordTypeHelper.getRecordTypeValue(this.opportunityCompany + '_Opportunity_Tarif_Item'), CurrencyIsoCode=this.opp.CurrencyIsoCode));
                this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 0, Total_Amount__c = 0, Discount__c = '0', Line_Item_Type__c = 'Product');
                this.ppProductLineItems.add(new LineItemWrapper(this.selectedProductItem, false, 0, 'Product'));
                for (Tarif_Member__c trMem :  [SELECT Id, Tarif_Name__c, Id_Tarif_Item__c, Type__c FROM Tarif_Member__c WHERE Tarif_Name__c = : this.selectedTarifItem]) {
                    if (trMem.Id_Tarif_Item__c != null) {
                        if (trMem.Type__c == 'Product') {
                            listProductTarifmember.add(trMem.Id_Tarif_Item__c);
                        }
                    }
                }

            } else if (this.mpTarif != null && this.mpTarif == this.selectedTarifItemName) {
                //if(this.opportunityCountry.Iso__c=='UK'){
                setVisibility(false, false, false, false, false, false, true, false, false, false);

                this.opp.Id_Tarif__c = this.selectedTarifItem;

                //this.selectedTarifList.add(new Opportunity_Tarif_Item__c(name = mapTarifItems.get(selectedTarifItem).name, Id_Opportunity__c = this.opp.Id, Id_Tarif__c = this.selectedTarifItem, recordtypeId = LibRecordTypeHelper.getRecordTypeValue(this.opportunityCompany + '_Opportunity_Tarif_Item'), CurrencyIsoCode=this.opp.CurrencyIsoCode));
                this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 1, Total_Amount__c = 0, Discount__c = '0', Line_Item_Type__c = 'Product');
                this.mpProductLineItems.add(new LineItemWrapper(this.selectedProductItem, false, 0, 'Product'));
                this.mpProductLineItems.add(new LineItemWrapper(this.subTotal, this.mpProductLineItems.size()));

                for (Tarif_Member__c trMem :  [SELECT Id, Tarif_Name__c, Id_Tarif_Item__c, Type__c FROM Tarif_Member__c WHERE Tarif_Name__c = : this.selectedTarifItem]) {
                    if (trMem.Id_Tarif_Item__c != null) {
                        if (trMem.Type__c == 'Product') {
                            listProductTarifmember.add(trMem.Id_Tarif_Item__c);
                        }
                    }
                }

                //}
            } else if (this.msTarif != null && this.msTarif == this.selectedTarifItemName) {
                setVisibility(false, false, false, false, false, false, false, false, true, false);

                this.opp.Id_Tarif__c = this.selectedTarifItem;

                this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 1, Total_Amount__c = 0, Discount__c = '0', Line_Item_Type__c = 'Product');
                this.msProductLineItems.add(new LineItemWrapper(this.selectedProductItem, false, 0, 'Product'));
                this.msProductLineItems.add(new LineItemWrapper(this.subTotal, this.msProductLineItems.size()));

                for (Tarif_Member__c trMem :  [SELECT Id, Tarif_Name__c, Id_Tarif_Item__c, Type__c FROM Tarif_Member__c WHERE Tarif_Name__c = : this.selectedTarifItem]) {
                    if (trMem.Id_Tarif_Item__c != null) {
                        if (trMem.Type__c == 'Product') {
                            listProductTarifmember.add(trMem.Id_Tarif_Item__c);
                        }
                    }
                }
            } else if (this.dpTarif != null && this.selectedTarifItemName.containsIgnoreCase(this.dpTarif)) {
                setVisibility(false, false, false, false, false, false, false, false, false, true);

                this.opp.Id_Tarif__c = this.selectedTarifItem;

               
                for (Tarif_Member__c trMem :  [SELECT Id, Tarif_Name__c, Id_Tarif_Item__c, Type__c FROM Tarif_Member__c WHERE Tarif_Name__c = : this.selectedTarifItem]) {
                    if (trMem.Id_Tarif_Item__c != null) {
                        if (trMem.Type__c == 'Product') {
                            listProductTarifmember.add(trMem.Id_Tarif_Item__c);
                        }
                    }
                }
            } else if (this.adSalesTarif != null && this.adSalesTarif == this.selectedTarifItemName) {
                setVisibility(true, false, false, false, false, false, false, false, false, false);
                if (this.mapDistrictPrice.isEmpty()) {
                    adSalesAPICallout();
                }
                //this.selectedTarifList.add(new Opportunity_Tarif_Item__c(name = mapTarifItems.get(selectedTarifItem).name, Id_Opportunity__c = this.opp.Id, Id_Tarif__c = this.selectedTarifItem, recordtypeId = recordTypesByDevNameMap.get(this.opportunityCompany + '_Opportunity_Tarif_Item').Id, CurrencyIsoCode=this.opp.CurrencyIsoCode));
                //this.selectedTarifList.add(new Opportunity_Tarif_Item__c(name = mapTarifItems.get(selectedTarifItem).name, Id_Opportunity__c = this.opp.Id, Id_Tarif__c = this.selectedTarifItem, recordtypeId = LibRecordTypeHelper.getRecordTypeValue(this.opportunityCompany + '_Opportunity_Tarif_Item'), CurrencyIsoCode=this.opp.CurrencyIsoCode));
                this.opp.Id_Tarif__c = selectedTarifItem;
                if (this.adSalesProductLineItems.size() == 0) {
                    this.adSalesProductLineItems.add(new LineItemWrapper(this.subTotal, this.adSalesProductLineItems.size()));
                }
                List<Tarif_Member__c> trMem =  [SELECT Id, Tarif_Name__c, Id_Tarif_Item__c, Type__c FROM Tarif_Member__c WHERE Tarif_Name__c = : this.selectedTarifItem and type__c = 'Product' limit 1];
                if (trMem != null && !trMem.isEmpty() && trMem[0].Id_Tarif_Item__c != null) {
                    this.adSalesProductPrice = trMem[0].Id_Tarif_Item__c;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.Adsales_product_is_inactive));
                    return;
                }
            } else if (this.flatProductTarif != null && this.flatProductTarif == this.selectedTarifItemName) {
                setVisibility(false, true, false, false, false, false, false, false, false, false);

                if (this.mapDistrictsFlat.isEmpty()) {
                    if (!Test.isRunningTest()) {
                        flatCommissionAPICallout();
                    }
                }
                //this.selectedTarifList.add(new Opportunity_Tarif_Item__c(name = mapTarifItems.get(selectedTarifItem).name, Id_Opportunity__c = this.opp.Id, Id_Tarif__c = this.selectedTarifItem, recordtypeId = recordTypesByDevNameMap.get(this.opportunityCompany + '_Opportunity_Tarif_Item').Id, CurrencyIsoCode=this.opp.CurrencyIsoCode));
                //this.selectedTarifList.add(new Opportunity_Tarif_Item__c(name = mapTarifItems.get(selectedTarifItem).name, Id_Opportunity__c = this.opp.Id, Id_Tarif__c = this.selectedTarifItem, recordtypeId = LibRecordTypeHelper.getRecordTypeValue(this.opportunityCompany + '_Opportunity_Tarif_Item'), CurrencyIsoCode=this.opp.CurrencyIsoCode));
                this.opp.Id_Tarif__c = selectedTarifItem;
                if (this.flatProductLineItems.size() == 0) {
                    this.flatProductLineItems.add(new LineItemWrapper(this.subTotal, this.flatProductLineItems.size()));
                }
                
                List<Tarif_Member__c> trMem =  [SELECT Id, Tarif_Name__c, Id_Tarif_Item__c, Type__c FROM Tarif_Member__c WHERE Tarif_Name__c = : this.selectedTarifItem and type__c = 'Product'  limit 1];
                if (trMem != null && !trMem.isEmpty() && trMem[0].Id_Tarif_Item__c != null) {
                    //System.debug('$$$ user value for type: ' + trMem[0].Type__c);
                    this.flatProductPrice = trMem[0].Id_Tarif_Item__c;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.Flat_Commission_product_is_inactive));
                    return;
                }
            }
        } else {
            setVisibility(false, false, false, true, true, false, false, false, false, false);
        }
        this.addTariffServices(listServiceTarifmember); //add opportunity service line items for selected tariff
        this.addTariffProducts(listProductTarifmember); //add opportunity product/recurring charge line items for selected tariff
    }

    /**
    * called when a tariff is selected from the tariff dropdown on the createProductLineItems page. It removes product line items that are part of the tariff that was previously selected. Products that
    * are not part of a tariff are not affected by this change. This is what the "productsToRetain" variable is required for.
    *
    * @param
    * @return void
    */
    public void removeTariffProducts() {
        List<Opportunity_Line_Item__c> productsToRetain = new List<Opportunity_Line_Item__c>();
        for (LineItemWrapper lineItem : this.productLineItems) {
            if (lineItem.position != 0 && (lineItem.position != this.productLineItems.size() - 1)) {
                if (lineItem.product.Has_Related_Tarif__c) {
                    if (lineItem.product.Total_Amount__c != null) {
                        this.subTotal -= lineItem.product.Total_Amount__c;
                    }
                    if (lineItem.product.Id != null) {
                        //listDeleteProductLineItems.add(lineItem.product);
                        listDeleteOppLineItems.add(lineitem.product);
                    }
                } else if (!lineItem.product.Has_Related_Tarif__c) {
                    if (lineItem.product.Total_Amount__c != null) {
                        this.subTotal -= lineItem.product.Total_Amount__c;
                    }
                    if (lineItem.product.Id != null) {
                        listDeleteOppLineItems.add(lineItem.product);
                    }
                } else {
                    productsToRetain.add(lineItem.product);
                }

            }
        }
        this.productLineItems.clear();

        this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 0, Total_Amount__c = 0, Discount__c = '0', Line_Item_Type__c = 'Product');
        this.productLineItems.add(new LineItemWrapper(this.selectedProductItem, false, 0, 'Product'));
        if (!productsToRetain.isEmpty()) {
            for (Integer i = 0; i < productsToRetain.size(); i++) {
                this.productLineItems.add(new LineItemWrapper(productsToRetain[i], false, i + 1, 'Product'));
            }
        }
    }

    /**
    * called when a tariff is selected from the tariff dropdown on the createProductLineItems page. It removes recurring charge line items that are part of the tariff that was previously selected.
    * Recurring charges that are not part of a tariff are not affected by this change. This is what the "productsToRetain" variable is required for.
    *
    * @param
    * @return void
    */
    public void removedTariffRecurringCharge() {
        List<Opportunity_Line_Item__c> productsToRetain = new List<Opportunity_Line_Item__c>();
        for (LineItemWrapper lineItem : this.recurringChargeLineItems) {
            if (lineItem.position != 0) {
                if (lineItem.product.Has_Related_Tarif__c) {
                    if (lineItem.product.Id != null) {
                        //this.listDeleteProductLineItems.add(lineItem.product);
                        this.listDeleteOppLineItems.add(lineitem.product);
                    }
                } else {
                    productsToRetain.add(lineItem.product);
                }
            }
        }
        this.recurringChargeLineItems.clear();
        Opportunity_Line_Item__c opi =  new Opportunity_Line_Item__c();
        this.recurringChargeLineItems.add(new LineItemWrapper(opi, false, 0, 'Product'));

        if (!productsToRetain.isEmpty()) {
            for (Integer i = 0; i < productsToRetain.size(); i++) {
                this.recurringChargeLineItems.add(new LineItemWrapper(productsToRetain[i], false, i + 1, 'Product'));
            }
        }
    }

    /**
    * called when a tariff is selected from the tariff dropdown on the createProductLineItems page. It removes service line items that are part of the tariff that was previously selected.
    * Services that are not part of a tariff are not affected by this change. This is what the "servicesToRetain" variable is required for.
    *
    * @param
    * @return void
    */
    public void removeTariffServices() {
        List<Opportunity_Line_Item__c> servicesToRetain = new List<Opportunity_Line_Item__c>();

        for (LineItemWrapper lineItem : this.serviceLineItems) {
            if (lineItem.position != 0) {
                //if(lineItem.service.Has_Related_Tarif__c){
                if (lineItem.service.Id != null) {
                    listDeleteOppLineItems.add(lineItem.service);
                }
                //} else {
                //servicesToRetain.add(lineItem.service);
                //}
            }
        }

        this.serviceLineItems.clear();
        if (!servicesToRetain.isEmpty()) {
            for (Integer i = 0; i < servicesToRetain.size(); i++) {
                this.serviceLineItems.add(new LineItemWrapper(servicesToRetain[i], false, i + 1, 'Service'));
            }
        }
    }

    /**
    * called when a tariff is selected from the tariff dropdown on the createProductLineItems page. It adds opportunity product items that are part of the selected tariff to the opportunity line items.
    * Since recurring charges are it themselves also products, product line items for opportunity product items which are recurring charges is also created.
    * The "recuringChargesMap" holds the information about which products are recurring charges. This map is constructed in the constructor by using the business configs
    * to determine which product types are recurring charges for the record type of the opportunity in question.
    *
    * @param
    * @return void
    */
    public void addTariffProducts(List<Id> listProductTarifmember) {
        if (!listProductTarifmember.isEmpty()) {
            List<List_Product_Price__c> listProduct = new List<List_Product_Price__c>([SELECT Id, Name, requires_add_on__c, Id_List_Product_Group__r.Name, Unapproved_Discount_Limit__c, Maximum_discount__c, Default_Quantity__c, Installments__c, Is_Active__c, Product_Name__c, List_Price__c, Product_Type__c
                    FROM List_Product_Price__c
                    WHERE Id IN :listProductTarifmember AND Is_Active__c = true]);
            string recType = LibRecordTypeHelper.getRecordTypeValue(this.opportunityCompany + '_Opportunity_Line_Item');
            for (Integer i = 0; i < listProduct.size(); i++) {
                this.mapProductType.put(listProduct[i].Id, listProduct[i].Product_Type__c);
                if (!this.mapMaximumDiscount.containsKey(listProduct[i].Id)) {
                    if (listProduct[i].Unapproved_Discount_Limit__c != null) {
                        this.mapMaximumDiscount.put(listProduct[i].Id, listProduct[i].Unapproved_Discount_Limit__c);
                    }
                }
                if (!this.mapHasApproval.containsKey(listProduct[i].Id)) {
                    // if(this.selectedProduct.Unapproved_Discount_Limit__c!=null){
                    this.mapHasApproval.put(listProduct[i].Id, listProduct[i].requires_add_on__c);
                    // }
                }

                /* Opportunity_Product_Item__c product = new Opportunity_Product_Item__c(Id_List_Price_Product__c = listProduct[i].id, name = listProduct[i].Product_Name__c, Listed_Price__c = listProduct[i].List_Price__c, Quantity__c = 1,
                                               Total_Amount__c = listProduct[i].List_Price__c, Product_Group__c = listProduct[i].Id_List_Product_Group__r.Name,
                                               Installments__c = listProduct[i].Installments__c, Id_Opportunity__c = opp.id,Has_Related_Tarif__c = true, recordtypeid = recordTypesByDevNameMap.get(this.opportunityCompany + '_Opportunity_Product_Item').Id,
                                               CurrencyIsoCode = this.opp.CurrencyIsoCode);*/

                Opportunity_Line_Item__c product = new Opportunity_Line_Item__c(Id_List_Price_Product__c = listProduct[i].id, name = listProduct[i].Product_Name__c, Listed_Price__c = listProduct[i].List_Price__c, Quantity__c = 1,
                        Total_Amount__c = listProduct[i].List_Price__c, Product_Group__c = listProduct[i].Id_List_Product_Group__r.Name,discount__c='0',
                        Installments__c = listProduct[i].Installments__c, Id_Opportunity__c = opp.id, Has_Related_Tarif__c = true, recordtypeid = recType,
                        CurrencyIsoCode = this.opp.CurrencyIsoCode, Line_Item_Type__c = 'Product', sub_type__c = listProduct[i].Product_Type__c);

                if (this.recuringChargesMap.get(product.Id_List_Price_Product__c) == null ) {
                    if (listProduct[i].Product_Type__c == null || (listProduct[i].Product_Type__c != null && listProduct[i].Product_Type__c.indexOf('Premium placement -') == -1)) {
                        LineItemWrapper lineItem = new LineItemWrapper(product, false, this.productLineItems.size(), 'Product');
                        this.productLineItems.add(lineItem);
                        this.subTotal += listProduct[i].List_Price__c;
                    }

                }

                if (this.recuringChargesMap.get(product.Id_List_Price_Product__c) != null ) {
                    this.recurringChargeLineItems.add(new LineItemWrapper(product, false, this.recurringChargeLineItems.size(), 'Product'));
                } else if (listProduct[i].Product_Type__c != null && listProduct[i].Product_Type__c.indexOf('Premium placement -') > -1) {
                    this.ppProductLineItems.add(new LineItemWrapper(product, false, this.ppProductLineItems.size(), 'Product'));
                } else if (listProduct[i].Product_Type__c != null && designProductTypes.contains(listProduct[i].Product_Type__c)) {
                    this.dpProductLineItems.add(new LineItemWrapper(product, false, this.dpProductLineItems.size(), 'Product'));
                }
            }
            //calculateVat();
        }
        if (this.selectedTarifItemName != null && this.dpTarif != null && this.selectedTarifItemName.containsignorecase(this.dpTarif))
            this.dpProductLineItems.add(new LineItemWrapper(this.subTotal, this.dpProductLineItems.size()));
        //
        else if (!this.ppProductLineItems.isEmpty() && this.ppProductLineItems.size() >= 1) {
            this.ppProductLineItems.add(new LineItemWrapper(this.subTotal, this.ppProductLineItems.size()));
        } else
            this.productLineItems.add(new LineItemWrapper(this.subTotal, this.productLineItems.size()));
    }

    /**
    * called when a tariff is selected from the tariff dropdown on the createProductLineItems page.
    * It adds opportunity service items that are part of the selected tariff to the opportunity line items.
    *
    * @param
    * @return void
    */
    public void addTariffServices(List<Id> listServiceTarifmember) {
        if (!listServiceTarifmember.isEmpty()) {
            //comment commission type below for deployment
            List<List_Service_Price__c> listService = new List<List_Service_Price__c>(
                [
                    SELECT
                    Name,
                    Service_Type__c,
                    Commission_In_Percentage__c,
                    Commission_Per_Order__c,
                    Commission_Type__c,
                    Default_Commission_In_Percentage__c,
                    Is_Active__c,
                    Maximum_Commission_In_Percentage__c,
                    Minimum_Commission_in_Percentage__c,
                    Maximum_Commission_per_order__c,
                    Minimum_Commission_per_order__c,
                    Type__c,
                    Recurring_Fee__c
                    FROM List_Service_Price__c
                    WHERE Id IN :listServiceTarifmember AND Is_Active__c = true]);
            String recType = LibRecordTypeHelper.getRecordTypeValue(this.opportunityCompany + '_Opportunity_Line_Item');
            for (Integer i = 0; i < listService.size(); i++) {
                //commission type
                if (this.mapCommissionType.get(listService[i].id) == null) {
                    this.mapCommissionType.put(listService[i].id, listService[i].Commission_type__c);
                }
                /*Opportunity_Service_Item__c service = new Opportunity_Service_Item__c(Id_List_Service_Price__c = listService[i].id, Service_Type__c = listService[i].Service_Type__c,
                                         name = listService[i].name, Commission_In_Percentage__c = listService[i].Commission_In_Percentage__c,
                                         Commission_Per_Order__c = listService[i].Commission_Per_Order__c,Id_Opportunity__c = opp.id, Type__c=listService[i].Type__c,Has_Related_Tarif__c = true,
                                         recordtypeid = recordTypesByDevNameMap.get(this.opportunityCompany + '_Opportunity_Service_Item').Id, CurrencyIsoCode = this.opp.CurrencyIsoCode, Recurring_Fee__c = listService[i].Recurring_Fee__c);
                */
                Opportunity_Line_Item__c service = new Opportunity_Line_Item__c(Id_List_Service_Price__c = listService[i].id, Sub_Type__c = listService[i].Service_Type__c,
                        name = listService[i].name, Commission_In_Percentage__c = listService[i].Commission_In_Percentage__c,
                        Commission_Per_Order__c = listService[i].Commission_Per_Order__c, Id_Opportunity__c = opp.id/*, Type__c=listService[i].Type__c*/, Has_Related_Tarif__c = true,
                        recordtypeid = recType, CurrencyIsoCode = this.opp.CurrencyIsoCode, Recurring_Fee__c = listService[i].Recurring_Fee__c, Line_Item_Type__c = 'Service');

                if (showTieredBlock) {
                    service.Min__c = 1;

                    LineItemWrapper lineItem1 = new LineItemWrapper(service.clone(), false, 1, 'Service');
                    lineItem1.service.IsTiered__c = true;
                    //lineitem1.service.Min__c = 0;
                    lineItem1.service.index__c = 1;
                    this.serviceLineItems.add(lineItem1);
                    Opportunity_Line_Item__c service1 = service.clone();
                    service1.Min__c = null;
                    service1.Commission_In_Percentage__c = null;
                    service1.online_payment_fee__c = null;
                    service1.commission_per_order__C = null;
                    LineItemWrapper lineItem2 = new LineItemWrapper(service1, false, 2, 'Service');
                    lineItem2.service.IsTiered__c = true;
                    lineItem2.service.index__c = 2;
                    lineItem2.service.Max__c = null;
                    this.serviceLineItems.add(lineItem2);
                    LineItemWrapper lineItem3 = new LineItemWrapper(service1.clone(), false, 3, 'Service');
                    lineItem3.service.IsTiered__c = true;
                    lineItem3.service.index__c = 3;
                    lineItem3.service.Max__c = null;
                    this.serviceLineItems.add(lineItem3);
                    LineItemWrapper lineItem4 = new LineItemWrapper(service1.clone(), false, 4, 'Service');
                    lineItem4.service.IsTiered__c = true;
                    lineItem4.service.index__c = 4;
                    lineItem4.service.Max__c = null;
                    this.serviceLineItems.add(lineItem4);
                    LineItemWrapper lineItem5 = new LineItemWrapper(service1.clone(), false, 5, 'Service');
                    lineItem5.service.IsTiered__c = true;
                    lineItem5.service.index__c = 5;
                    lineItem5.service.Max__c = null;
                    this.serviceLineItems.add(lineItem5);
                    LineItemWrapper lineItem6 = new LineItemWrapper(service1.clone(), false, 6, 'Service');
                    lineItem6.service.IsTiered__c = true;
                    lineItem6.service.index__c = 6;
                    lineItem6.service.Max__c = null;
                    this.serviceLineItems.add(lineItem6);

                    LineItemWrapper lineItem7 = new LineItemWrapper(service1.clone(), false, 7, 'Service');
                    lineItem7.service.IsTiered__c = true;
                    lineItem7.service.index__c = 7;
                    lineItem7.service.Max__c = null;
                    this.serviceLineItems.add(lineItem7);
                    break;
                } else {
                    LineItemWrapper lineItem = new LineItemWrapper(service, false, this.serviceLineItems.size() + i, 'Service');
                    this.serviceLineItems.add(lineItem);
                }
            }
            if (!showTieredBlock) {
                sortListWithoutUpsert();

            }

        } else if (this.serviceLineItems.size() == 0) {
            this.selectedService = new Opportunity_Line_Item__c(Line_Item_Type__c = 'Service');
            this.serviceLineItems.add(new LineItemWrapper(this.selectedService, false, 0, 'Service'));
        } else {
            if (!showTieredBlock) {
                sortListWithoutUpsert();
            }
        }
        //System.debug('addTariffServices serviceLineItems: '+serviceLineItems);
    }

    public void getRelatedGroupProducts() {
        resetErrorFalg();
        if (!checkIfOpportunityIsLocked()) {
            this.productItems.clear();
            if (selectedProductGroup != '--' ) {
                this.productItems.add(new SelectOption('--', '-- ' + Label.Opportunity_Select_Product + ' --'));
                for (List_Product_Price__c ProductPriceItem : [
                            SELECT Id, Product_Name__c, Requires_Replacement__c
                            FROM List_Product_Price__c
                            WHERE Id_List_Product_Group__c = :this.selectedProductGroup AND Is_Active__c = true and id not in : mapPPProducts.keySet() and id not in : mapMSProducts.keySet() and id not in : mapDPProducts.keySet()
                        ]) {
                    if (!ProductPriceItem.Requires_Replacement__c) {
                        this.productItems.add(new SelectOption(ProductPriceItem.Id, ProductPriceItem.Product_Name__c));
                    }
                }
            } else {
                this.selectedProductLineItem = '--';
            }
        }
    }


    public void getRelatedPPProducts() {
        resetErrorFalg();
        if (!checkIfOpportunityIsLocked()) {
            this.ppProductItems.clear();
            if (selectedProductGroup != '--' ) {
                this.ppProductItems.add(new SelectOption('--', '-- ' + Label.Opportunity_Select_Product + ' --'));
                for (List_Product_Price__c ProductPriceItem : mapPPProducts.values()) {
                    this.ppProductItems.add(new SelectOption(ProductPriceItem.Id, ProductPriceItem.Product_Name__c));
                }
            } else {
                this.selectedProductLineItem = '--';
            }
        }
    }

    public void getRelatedMPProducts() {
        resetErrorFalg();
        if (!checkIfOpportunityIsLocked()) {
            this.mpProductItems.clear();
            if (selectedProductGroup != '--' ) {
                this.mpProductItems.add(new SelectOption('--', '-- ' + Label.Opportunity_Select_Product + ' --'));
                for (List_Product_Price__c ProductPriceItem : mapMPProducts.values()) {
                    this.mpProductItems.add(new SelectOption(ProductPriceItem.Id, ProductPriceItem.Product_Name__c));
                }
            } else {
                this.selectedProductLineItem = '--';
            }
        }
    }

    public void getRelatedMarketingShippingProducts() {
        resetErrorFalg();
        if (!checkIfOpportunityIsLocked()) {
            this.msProductItems.clear();
            if (selectedProductGroup != '--' ) {
                this.msProductItems.add(new SelectOption('--', '-- ' + Label.Opportunity_Select_Product + ' --'));
                for (List_Product_Price__c ProductPriceItem : mapMSProducts.values()) {
                    this.msProductItems.add(new SelectOption(ProductPriceItem.Id, ProductPriceItem.Product_Name__c));
                }
            } else {
                this.selectedProductLineItem = '--';
            }
        }
    }

    public void getRelatedDesignProducts() {
        resetErrorFalg();
        if (!checkIfOpportunityIsLocked()) {
            this.dpProductItems.clear();
            if (selectedProductGroup != '--' ) {
                this.dpProductItems.add(new SelectOption('--', '-- ' + Label.Opportunity_Select_Product + ' --'));
                for (List_Product_Price__c ProductPriceItem : mapDPProducts.values()) {
                    this.dpProductItems.add(new SelectOption(ProductPriceItem.Id, ProductPriceItem.Product_Name__c));
                }
            } else {
                this.selectedProductLineItem = '--';
            }
        }
    }



    public void getRelatedProduct() {
        resetErrorFalg();
        if (!checkIfOpportunityIsLocked()) {
            this.selectedProduct = new List_Product_Price__c();
            if (this.selectedProductLineItem != '--') {
                this.selectedProduct = [
                                           SELECT Id, Id_List_Product_Group__r.Name, requires_add_on__c, Unapproved_Discount_Limit__c, Maximum_discount__c, Default_Quantity__c, Installments__c, Is_Active__c, Product_Name__c, List_Price__c, Product_Type__c
                                           FROM List_Product_Price__c
                                           WHERE Id = :selectedProductLineItem
                                       ];
                this.mapProductType.put(selectedProduct.Id, selectedProduct.Product_Type__c);
                //System.debug('this.selectedProduct.Unapproved_Discount_Limit__c: '+this.selectedProduct.Unapproved_Discount_Limit__c);
                if (!this.mapMaximumDiscount.containsKey(this.selectedProduct.id)) {
                    if (this.selectedProduct.Unapproved_Discount_Limit__c != null) {
                        this.mapMaximumDiscount.put(this.selectedProduct.Id, this.selectedProduct.Unapproved_Discount_Limit__c);
                    }
                }
                if (!this.mapHasApproval.containsKey(this.selectedProduct.id)) {
                    // if(this.selectedProduct.Unapproved_Discount_Limit__c!=null){
                    this.mapHasApproval.put(this.selectedProduct.Id, this.selectedProduct.requires_add_on__c);
                    // }
                }
                system.debug('this.mapMaximumDiscount:: ' + this.mapMaximumDiscount);
                if (mapPPProducts.get(this.selectedProduct.Id) != null) {
                    Integer noOfQuantity = mapNumberOfRecords.get(this.selectedProduct.Product_Type__c);
                    this.selectedProductItem = new Opportunity_Line_Item__c(
                        Id_List_Price_Product__c = this.selectedProduct.Id,
                        Name = this.selectedProduct.Product_Name__c,
                        Id_Opportunity__c = this.opp.id,
                        Quantity__c = noOfQuantity,
                        Discount__c = '0',
                        //API_Type__c='Premium Placement',
                        Installments__c = this.selectedProduct.Installments__c,
                        Listed_Price__c = this.selectedProduct.List_Price__c,
                        Total_Amount__c = this.selectedProduct.List_Price__c * noOfQuantity,
                        Product_Group__c = this.selectedProduct.Id_List_Product_Group__r.Name,
                        CurrencyIsoCode = this.opp.CurrencyIsoCode,
                        Line_Item_Type__c = 'Product',
                        sub_type__c = 'Premium Placement',
                        /*RecordtypeId = recordTypesByDevNameMap.get(this.opportunityCompany + '_Opportunity_Product_Item').Id*/
                        RecordtypeId = LibRecordTypeHelper.getRecordTypeValue(this.opportunityCompany + '_Opportunity_Line_Item')
                    );
                    this.ppProductLineItems[0] = new LineItemWrapper(this.selectedProductItem, false, 0, 'Product');
                    this.totalAmount = this.selectedProduct.List_Price__c * noOfQuantity;
                } else if (mapMPProducts.get(this.selectedProduct.Id) != null && this.mpTarif != null) {
                    // Integer noOfQuantity = mapNumberOfRecords.get(this.selectedProduct.Product_Type__c);
                    this.selectedProductItem = new Opportunity_Line_Item__c(
                        Id_List_Price_Product__c = this.selectedProduct.Id,/*pass menu printing add charge */
                        Name = this.selectedProduct.Product_Name__c,
                        Id_Opportunity__c = this.opp.id,
                        Quantity__c = 1,
                        Discount__c = '0',
                        Installments__c = 1,
                        Listed_Price__c = this.selectedProduct.List_Price__c,
                        Total_Amount__c = this.selectedProduct.List_Price__c * 1,
                        Product_Group__c = this.selectedProduct.Id_List_Product_Group__r.Name,
                        CurrencyIsoCode = this.opp.CurrencyIsoCode,
                        Line_Item_Type__c = 'Product',
                        sub_type__c = 'Menu Printing',
                        Deposit__c = 0,

                        //Design_Notes__c=this.selectedProduct.Design_Notes__c,
                        /*RecordtypeId = recordTypesByDevNameMap.get(this.opportunityCompany + '_Opportunity_Product_Item').Id*/
                        RecordtypeId = LibRecordTypeHelper.getRecordTypeValue(this.opportunityCompany + '_Opportunity_Line_Item')
                    );
                    this.mpProductLineItems[0] = new LineItemWrapper(this.selectedProductItem, false, 0, 'Product');
                    this.totalAmount = this.selectedProduct.List_Price__c * 1;
                } else if (this.msTarif != null && mapMSProducts.get(this.selectedProduct.Id) != null) {
                    // Integer noOfQuantity = mapNumberOfRecords.get(this.selectedProduct.Product_Type__c);
                    //System.debug('inside marketing');
                    this.selectedProductItem = new Opportunity_Line_Item__c(
                        Id_List_Price_Product__c = this.selectedProduct.Id,
                        Name = this.selectedProduct.Product_Name__c,
                        Id_Opportunity__c = this.opp.id,
                        Quantity__c = this.selectedProduct.Default_Quantity__c,
                        Discount__c = '0',
                        Installments__c = 1,
                        Listed_Price__c = this.selectedProduct.List_Price__c,
                        Total_Amount__c = this.selectedProduct.List_Price__c * (this.selectedProduct.Default_Quantity__c != null ? this.selectedProduct.Default_Quantity__c : 1),
                        Product_Group__c = this.selectedProduct.Id_List_Product_Group__r.Name,
                        CurrencyIsoCode = this.opp.CurrencyIsoCode,
                        Line_Item_Type__c = 'Product',
                        sub_type__c = this.selectedProduct.Product_Type__c,
                        RecordtypeId = LibRecordTypeHelper.getRecordTypeValue(this.opportunityCompany + '_Opportunity_Line_Item')
                    );
                    //System.debug('this.selectedProductItem: '+this.selectedProductItem);
                    this.msProductLineItems[0] = new LineItemWrapper(this.selectedProductItem, false, 0, 'Product');
                    this.totalAmount = this.selectedProduct.List_Price__c * 1;
                } else if (this.dpTarif != null && mapDPProducts.get(this.selectedProduct.Id) != null) {
                    // Integer noOfQuantity = mapNumberOfRecords.get(this.selectedProduct.Product_Type__c);
                    //System.debug('inside marketing');
                    this.selectedProductItem = new Opportunity_Line_Item__c(
                        Id_List_Price_Product__c = this.selectedProduct.Id,
                        Name = this.selectedProduct.Product_Name__c,
                        Id_Opportunity__c = this.opp.id,
                        Quantity__c = this.selectedProduct.Default_Quantity__c,
                        Discount__c = '0',
                        Installments__c = 1,
                        Listed_Price__c = this.selectedProduct.List_Price__c,
                        Total_Amount__c = this.selectedProduct.List_Price__c * (this.selectedProduct.Default_Quantity__c != null ? this.selectedProduct.Default_Quantity__c : 1),
                        Product_Group__c = this.selectedProduct.Id_List_Product_Group__r.Name,
                        CurrencyIsoCode = this.opp.CurrencyIsoCode,
                        Line_Item_Type__c = 'Product',
                        subsidy__c = 0,

                        sub_type__c = this.selectedProduct.Product_Type__c,
                        RecordtypeId = LibRecordTypeHelper.getRecordTypeValue(this.opportunityCompany + '_Opportunity_Line_Item')
                    );
                    //System.debug('this.selectedProductItem: '+this.selectedProductItem);
                    this.dpProductLineItems[0] = new LineItemWrapper(this.selectedProductItem, false, 0, 'Product');
                    this.totalAmount = this.selectedProduct.List_Price__c * 1;
                } else {

                    this.selectedProductItem = new Opportunity_Line_Item__c(
                        Id_List_Price_Product__c = this.selectedProduct.Id,
                        Name = this.selectedProduct.Product_Name__c,
                        Id_Opportunity__c = this.opp.id,
                        Quantity__c = this.selectedProduct.Default_Quantity__c != null ? this.selectedProduct.Default_Quantity__c : 1,
                        Discount__c = '0',
                        Installments__c = this.selectedProduct.Installments__c,
                        Listed_Price__c = this.selectedProduct.List_Price__c,
                        Total_Amount__c = this.selectedProduct.List_Price__c * (this.selectedProduct.Default_Quantity__c != null ? this.selectedProduct.Default_Quantity__c : 1),
                        Product_Group__c = this.selectedProduct.Id_List_Product_Group__r.Name,
                        CurrencyIsoCode = this.opp.CurrencyIsoCode,
                        Line_Item_Type__c = 'Product',
                        sub_type__C = this.selectedProduct.Product_Type__c,

                        /*RecordtypeId = recordTypesByDevNameMap.get(this.opportunityCompany + '_Opportunity_Product_Item').Id*/
                        RecordtypeId = LibRecordTypeHelper.getRecordTypeValue(this.opportunityCompany + '_Opportunity_Line_Item')
                    );
                    this.productLineItems[0] = new LineItemWrapper(this.selectedProductItem, false, 0, 'Product');
                    this.totalAmount = this.selectedProduct.List_Price__c;
                }


                this.productQuantity = 1;

            }
        }
    }

    public void getServiceDetails() {
        resetErrorFalg();
        if (!checkIfOpportunityIsLocked()) {
            this.selectedService = new Opportunity_Line_Item__c(Line_Item_Type__c = 'Service');
            if (this.selectedServiceItem != '--') {
                //comment commission type for the deployment
                List_Service_Price__c serviceItem = [
                                                        SELECT Name,
                                                        Service_Type__c,
                                                        Commission_In_Percentage__c,
                                                        Commission_Per_Order__c,
                                                        Commission_Type__c,
                                                        Default_Commission_In_Percentage__c,
                                                        Is_Active__c,
                                                        Maximum_Commission_In_Percentage__c,
                                                        Minimum_Commission_in_Percentage__c,
                                                        Maximum_Commission_per_order__c,
                                                        Minimum_Commission_per_order__c,
                                                        Type__c,
                                                        Recurring_Fee__c
                                                        FROM List_Service_Price__c
                                                        WHERE id = :this.selectedServiceItem
                                                    ];
                //commission type
                if (this.mapCommissionType.get(serviceItem.id) == null) {
                    this.mapCommissionType.put(serviceItem.id, serviceItem.Commission_type__c);
                }
                this.selectedService.name = serviceItem.name;
                this.selectedService.Id_List_Service_Price__c = serviceItem.id;
                this.selectedService.Id_Opportunity__c = opp.id;
                this.selectedService.Sub_Type__c  = serviceItem.Service_Type__c != null ?  serviceItem.Service_Type__c : null;
                //this.selectedService.Type__c = serviceItem.Type__c;
                this.selectedService.Has_Related_Tarif__c = false;
                this.selectedService.Commission_In_Percentage__c = serviceItem.Commission_In_Percentage__c;
                this.selectedService.Commission_Per_Order__c = serviceItem.Commission_Per_Order__c;
                //this.selectedService.recordtypeid = recordTypesByDevNameMap.get(this.opportunityCompany + '_Opportunity_Service_Item').Id;
                this.selectedService.recordtypeid = LibRecordTypeHelper.getRecordTypeValue(this.opportunityCompany + '_Opportunity_Line_Item');
                this.selectedService.CurrencyIsoCode = this.opp.CurrencyIsoCode;
                this.selectedService.Recurring_Fee__c = serviceItem.Recurring_Fee__c;
            }
        }
        this.serviceLineItems[0] = new LineItemWrapper(selectedService, false, 0, 'Service');
        system.debug('selected service: ' + this.selectedService);

    }

    public void getRecurringProduct() {
        resetErrorFalg();
        if (String.isNotBlank(this.selectedRecurringCharge) && this.selectedRecurringCharge != 'null' && this.recuringChargesMap != null) {
            this.recurringChargeLineItems[0].product.Listed_Price__c = this.recuringChargesMap.get(this.selectedRecurringCharge).List_Price__c;
            this.recurringChargeLineItems[0].product.Name = this.recuringChargesMap.get(this.selectedRecurringCharge).Product_Name__c;
        }
    }




    public void addRecurringCharge() {
        resetErrorFalg();
        this.availableForQuote = false;
        if (String.isNotBlank(this.selectedRecurringCharge) && this.selectedRecurringCharge != 'null') {
            if (this.recurringChargeLineItems[0].product.Start_Date__c != null) {
                Opportunity_Line_Item__c prod = this.recurringChargeLineItems[0].product;
                prod.Id_Opportunity__c = this.opp.Id;
                prod.Id_List_Price_Product__c = this.selectedRecurringCharge;
                prod.CurrencyIsoCode = this.opp.CurrencyIsoCode;
                //prod.recordtypeid = recordTypesByDevNameMap.get(this.opportunityCompany + '_Opportunity_Product_Item').Id;
                prod.recordtypeid = LibRecordTypeHelper.getRecordTypeValue(this.opportunityCompany + '_Opportunity_Line_Item');
                Opportunity_Line_Item__c opi =  new Opportunity_Line_Item__c(Line_Item_Type__c = 'Product');
                this.recurringChargeLineItems[0] = new LineItemWrapper(opi, false, 0, 'Product');

                LineItemWrapper lineItem = new LineItemWrapper(prod, false, this.recurringChargeLineItems.size(), 'Product');
                this.recurringChargeLineItems.add(lineItem);
                this.selectedRecurringCharge = 'null';
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.Opportunity_Recurring_Charge_Start_Missing));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.Opportunity_Recurring_Charges_Select_Product));
        }
    }

    public void removeRecurringCharge() {
        resetErrorFalg();
        this.availableForQuote = false;
        List<Opportunity_Line_Item__c> productsToRetain = new List<Opportunity_Line_Item__c>();
        for (LineItemWrapper lineItem : this.recurringChargeLineItems) {
            if (lineItem.position != 0) {
                if (lineItem.position == this.recurringChargeToRemove) {
                    if (lineItem.product.Id != null) {
                        //this.listDeleteProductLineItems.add(lineItem.product);
                        this.listDeleteOppLineItems.add(lineitem.product);
                    }
                } else {
                    productsToRetain.add(lineItem.product);
                }
            }
        }
        this.recurringChargeLineItems.clear();
        Opportunity_Line_Item__c opi =  new Opportunity_Line_Item__c();
        this.recurringChargeLineItems.add(new LineItemWrapper(opi, false, 0, 'Product'));

        if (!productsToRetain.isEmpty()) {
            for (Integer i = 0; i < productsToRetain.size(); i++) {
                this.recurringChargeLineItems.add(new LineItemWrapper(productsToRetain[i], false, i + 1, 'Product'));
            }
        }
    }


    //Calculate Amount based on the start date and the end date
    public void calculateAdSalesAmountWithDate() {
        resetErrorFalg();
        String indexOfAdsales = Apexpages.currentPage().getParameters().get('indexOfAdsales');
        //System.debug('indexOfAdsales: '+indexOfAdsales);
        if (indexOfAdsales != null) {
            Integer selectedIndex = Integer.valueOf(indexOfAdsales);
            LineItemWrapper lineItem = adSalesProductLineItems[selectedIndex];
            Opportunity_Line_Item__c  oppProd = lineItem.product;
            if (oppProd.Start_Date__c != null && oppProd.End_Date__c != null && oppProd.Listed_Price__c != null) {
                Decimal totalAmt = 0;
                if (oppProd.Start_Date__c < oppProd.End_Date__c) {
                    Integer noOfDays = oppProd.Start_Date__c.daysBetween(oppProd.End_Date__c);
                    if (oppProd.Start_Date__c.month() == oppProd.End_Date__c.month()) {
                        Integer daysInMonth = date.daysInMonth(oppProd.Start_Date__c.year(), oppProd.Start_Date__c.month());
                        totalAmt = (oppProd.Listed_Price__c / daysInMonth) * (noOfDays + 1);

                    } else {
                        totalAmt = (oppProd.Listed_Price__c / 30) * (noOfDays + 1);
                    }
                    oppProd.Total_Amount__c = totalAmt.setScale(2);
                } else {
                    oppProd.Total_Amount__c = 0;

                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.EndDateGreaterValidation));
                    this.availableForQuote = false;
                    return;
                }
            } else {
                oppProd.Total_Amount__c = oppProd.Listed_Price__c;
            }
            lineItem.product = oppProd;
            adSalesProductLineItems[selectedIndex] = lineItem;
            this.subTotal = 0;
            this.adSalesProductLineItems.remove(this.adSalesProductLineItems.size() - 1);
            for (LineItemWrapper lineItem1  : adSalesProductLineItems) {
                this.subTotal +=  lineItem1.product.Total_Amount__c;
            }
            //calculateVat();
            this.adSalesProductLineItems.add(new LineItemWrapper(this.subTotal, this.adSalesProductLineItems.size()));
        }
    }


    public void calculateFlatCommissionAmountWithDate() {
        resetErrorFalg();
        String indexOfFlatProd = Apexpages.currentPage().getParameters().get('indexOfFlatProd');
        //System.debug('indexOfFlatProd: '+indexOfFlatProd);
        if (indexOfFlatProd != null) {
            Integer selectedIndex = Integer.valueOf(indexOfFlatProd);
            LineItemWrapper lineItem = flatProductLineItems[selectedIndex];
            Opportunity_Line_Item__c  oppProd = lineItem.product;
            if (oppProd.Start_Date__c != null && oppProd.End_Date__c != null && oppProd.Listed_Price__c != null) {
                Decimal totalAmt = 0;
                if (oppProd.Start_Date__c < oppProd.End_Date__c) {
                    Integer noOfDays = oppProd.Start_Date__c.daysBetween(oppProd.End_Date__c);
                    if (oppProd.Start_Date__c.month() == oppProd.End_Date__c.month()) {
                        Integer daysInMonth = date.daysInMonth(oppProd.Start_Date__c.year(), oppProd.Start_Date__c.month());
                        totalAmt = (oppProd.Listed_Price__c / daysInMonth) * (noOfDays + 1);

                    } else {
                        totalAmt = (oppProd.Listed_Price__c / 30) * (noOfDays + 1);
                    }
                    oppProd.Total_Amount__c = totalAmt.setScale(2);
                } else {
                    oppProd.Total_Amount__c = 0;

                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.EndDateGreaterValidation));
                    this.availableForQuote = false;
                    return;
                }
            } else {
                oppProd.Total_Amount__c = oppProd.Listed_Price__c;
            }
            lineItem.product = oppProd;
            flatProductLineItems[selectedIndex] = lineItem;
            this.subTotal = 0;
            this.flatProductLineItems.remove(this.flatProductLineItems.size() - 1);
            for (LineItemWrapper lineItem1  : flatProductLineItems) {
                this.subTotal +=  lineItem1.product.Total_Amount__c == null ? 0 : lineItem1.product.Total_Amount__c;
            }
            //calculateVat();
            this.flatProductLineItems.add(new LineItemWrapper(this.subTotal, this.flatProductLineItems.size()));
        }
    }


    public Boolean validateAdsalesProductItems() {
        resetErrorFalg();
        if (!this.adSalesProductLineItems.isEmpty()) {
            for (LineItemWrapper lineItem : this.adSalesProductLineItems) {
                if (lineItem.position != this.adSalesProductLineItems.size() - 1) {
                    if (lineItem.product.Start_Date__c >= lineItem.product.End_Date__c) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.EndDateGreaterValidation));
                        lineItem.showError = true;
                        this.availableForQuote = false;
                        return false;
                    }
                    if (lineItem.product.Start_Date__c == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.Opportunity_AdSales_Start_Missing));
                        lineItem.showError = true;
                        this.availableForQuote = false;
                        return false;
                    }
                }
            }
        }
        this.availableForQuote = false;
        return true;
    }

    public Boolean validateFlatProductItems() {
        resetErrorFalg();
        if (!this.flatProductLineItems.isEmpty()) {
            for (LineItemWrapper lineItem : this.flatProductLineItems) {
                if (lineItem.position != this.flatProductLineItems.size() - 1) {
                    /*if(lineItem.product.Start_Date__c >= lineItem.product.End_Date__c){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,Label.EndDateGreaterValidation));
                        lineItem.showError = true;
                        this.availableForQuote = false;
                        return false;
                    }*/
                    if (lineItem.product.Start_Date__c == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.Opportunity_AdSales_Start_Missing));
                        lineItem.showError = true;
                        this.availableForQuote = false;
                        return false;
                    }
                    if (lineItem.product.Total_Amount__c == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.Flat_Commission_Amount_missing));
                        lineItem.showError = true;
                        this.availableForQuote = false;
                        return false;
                    }
                }
            }
            this.subTotal = 0;
            this.flatProductLineItems.remove(this.flatProductLineItems.size() - 1);
            for (LineItemWrapper lineItem1  : flatProductLineItems) {
                this.subTotal +=  lineItem1.product.Total_Amount__c;
            }
            //calculateVat();
            this.flatProductLineItems.add(new LineItemWrapper(this.subTotal, this.flatProductLineItems.size()));
        }
        this.availableForQuote = false;
        return true;
    }


    //Adsales changes 15.10.15
    public void addAdSalesProduct() {
        resetErrorFalg();
        this.availableForQuote = false;
        //System.debug('this.selectedDistricts: '+this.selectedDistricts);
        //System.debug('this.this.selectedCategories: '+this.selectedCategories);
        if (this.selectedAdSalesTypes == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.Opportunity_AdSales_Category_Missing));
            return;
        }

        if (this.selectedCategories == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.Opportunity_AdSales_Category_Missing));
            return;
        }

        if (this.adSalesProductDates.District__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.Opportunity_AdSales_District_Missing));
            return;
        }

        if (this.adSalesProductDates.Start_Date__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.Opportunity_AdSales_Start_Missing));
            return;
        }
        this.adSalesProductLineItems.remove(this.adSalesProductLineItems.size() - 1);
        Opportunity_Line_Item__c prod = new Opportunity_Line_Item__c();
        prod.Id_Opportunity__c = this.opp.Id;
        prod.Name = selectedAdSalesTypes + ' / ' + selectedCategories + ' / ' + this.adSalesProductDates.District__c;
        prod.CurrencyIsoCode = this.opp.CurrencyIsoCode;
        prod.sub_Type__c = selectedAdSalesTypes;
        prod.Category_Id__c = selectedCategories;
        prod.Category__c = selectedCategories;
        prod.District_Id__c = this.adSalesProductDates.District__c;
        prod.District__c = this.adSalesProductDates.District__c;
        prod.Listed_Price__c = this.adSalesProductDates.Listed_Price__c.setScale(2);
        prod.Start_Date__c = this.adSalesProductDates.Start_Date__c;
        prod.End_Date__c = this.adSalesProductDates.End_Date__c;
        prod.Total_Amount__c = prod.Listed_Price__c.setScale(2);
        prod.Line_Item_Type__c = 'Product';
        //Dummy ad sales product is linked in order to skip required field validation
        prod.Id_List_Price_Product__c = this.adSalesProductPrice;
        //prod.recordtypeid = recordTypesByDevNameMap.get(this.opportunityCompany + '_Opportunity_Product_Item').Id;
        prod.recordtypeid = LibRecordTypeHelper.getRecordTypeValue(this.opportunityCompany + '_Opportunity_Line_Item');
        LineItemWrapper lineItem = new LineItemWrapper(prod, false, this.adSalesProductLineItems.size(), 'Product');
        this.adSalesProductLineItems.add(lineItem);
        this.subTotal += prod.Total_Amount__c;
        //calculateVat();
        this.adSalesProductLineItems.add(new LineItemWrapper(this.subTotal, this.adSalesProductLineItems.size()));
        this.adSalesProductDates = new Opportunity_Line_Item__c(Line_Item_Type__c = 'Product');
    }

    

    public void addFlatProduct() {
        resetErrorFalg();
        this.availableForQuote = false;
        //System.debug('this.selectedFlatDistricts: '+this.selectedFlatDistricts);
        //System.debug('this.selectedFlatCategories: '+this.selectedFlatCategories);
        if (this.selectedFlatCategories == null ||  this.selectedFlatCategories.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.Opportunity_Flat_Commission_Category_Missing));
            return;
        }
        if (this.selectedFlatDistricts == null || this.selectedFlatDistricts.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.Opportunity_Flat_District_Missing));
            return;
        }
        if (flatProductDates.Start_Date__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.Opportunity_AdSales_Start_Missing));
            return;
        }

        Boolean dupicatelineItemViolation  = false;
        Boolean duplicateSameMonthViolation = false;
        this.flatProductLineItems.remove(this.flatProductLineItems.size() - 1);
        for (String selectCat : selectedFlatCategories) {
            for (String selectDist : selectedFlatDistricts) {
                if (this.flatProductLineItems.size() > 0) {
                    for (LineItemWrapper lineItem : this.flatProductLineItems) {
                        if (lineItem.product != null) {
                            if (lineItem.product.Category_Id__c == selectCat && lineItem.product.District_Id__c == selectDist) {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.Adsales_product_error + ' (' + lineItem.product.Category__c + ') ' + lineItem.product.District__c + ' ' + Label.Flat_Commission_already_exist));
                                dupicatelineItemViolation = true;
                            }/*else{
                                if(lineItem.product.End_Date__c==null && (this.flatProductDates.Start_Date__c==lineItem.product.Start_Date__c || (this.flatProductDates.Start_Date__c.month()==lineItem.product.Start_Date__c.month() && this.flatProductDates.Start_Date__c.year()==lineItem.product.Start_Date__c.year()))){
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,Label.Adsales_product_error+' ('+lineItem.product.Category__c+') '+lineItem.product.District__c +' '+Label.Adsales_overlapping_on_same_month));
                                    duplicateSameMonthViolation=true;
                                }else if(lineItem.product.End_Date__c!=null && (lineItem.product.Start_Date__c <= this.flatProductDates.Start_Date__c && lineItem.product.End_Date__c >= this.flatProductDates.Start_Date__c)){
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,Label.Adsales_product_error+' ('+lineItem.product.Category__c+') '+lineItem.product.District__c +' '+Label.Adsales_already_exist));
                                    dupicatelineItemViolation = true;
                                }
                            }*/
                        }
                    }
                }
                if (!dupicatelineItemViolation && !duplicateSameMonthViolation) {
                    String typeDist = selectDist;
                    Opportunity_Line_Item__c prod = new Opportunity_Line_Item__c();
                    prod.Id_Opportunity__c = this.opp.Id;
                    prod.Name = this.mapCategoriesFlat.get(selectCat) + ' / ' + this.mapDistrictsFlat.get(typeDist);
                    prod.CurrencyIsoCode = this.opp.CurrencyIsoCode;
                    prod.sub_Type__c = null;
                    prod.Category_Id__c = selectCat;
                    prod.Category__c = this.mapCategoriesFlat.get(selectCat);
                    prod.District_Id__c = typeDist;
                    prod.District__c = this.mapDistrictsFlat.get(typeDist);
                    //prod.Listed_Price__c = (this.mapDistrictPriceFlat.get(selectDist)).setScale(2);
                    prod.Start_Date__c = this.flatProductDates.Start_Date__c;
                    //prod.End_Date__c = this.flatProductDates.End_Date__c;
                    //prod.Total_Amount__c = prod.Listed_Price__c.setScale(2);
                    //prod.API_Type__c = 'Flat Commission';
                    prod.sub_type__c = 'Flat Commission';
                    prod.Line_Item_Type__c = 'Product';
                    //Dummy flat commission product is linked in order to skip required field validation
                    prod.Id_List_Price_Product__c = this.flatProductPrice;
                    //prod.recordtypeid = recordTypesByDevNameMap.get(this.opportunityCompany + '_Opportunity_Product_Item').Id;
                    prod.recordtypeid = LibRecordTypeHelper.getRecordTypeValue(this.opportunityCompany + '_Opportunity_Line_Item');
                    LineItemWrapper lineItem = new LineItemWrapper(prod, false, this.flatProductLineItems.size(), 'Product');
                    this.flatProductLineItems.add(lineItem);
                    if (prod.Total_Amount__c != null) {
                        this.subTotal += prod.Total_Amount__c;
                        //calculateVat();
                    }

                }
            }
        }
        this.flatProductLineItems.add(new LineItemWrapper(this.subTotal, this.flatProductLineItems.size()));
    }

    public void removeAdSalesProduct() {
        resetErrorFalg();
        this.availableForQuote = false;
        List<Opportunity_Line_Item__c> productsToRetain = new List<Opportunity_Line_Item__c>();
        if (this.adSalesProductLineItems.get(this.adSalesProductToRemove).product != null) {
            this.subTotal -= this.adSalesProductLineItems.get(this.adSalesProductToRemove).product.Total_Amount__c;
            //    calculateVat();
        }
        for (LineItemWrapper lineItem : this.adSalesProductLineItems) {
            if (lineItem.position != this.adSalesProductLineItems.size() - 1) {
                if (lineItem.position == this.adSalesProductToRemove) {
                    if (lineItem.product.Id != null) {
                        //this.listDeleteProductLineItems.add(lineItem.product);
                        this.listDeleteOppLineItems.add(lineitem.product);
                    }
                } else {
                    productsToRetain.add(lineItem.product);
                }
            }
        }
        this.adSalesProductLineItems.clear();
        if (!productsToRetain.isEmpty()) {
            for (Integer i = 0; i < productsToRetain.size(); i++) {
                this.adSalesProductLineItems.add(new LineItemWrapper(productsToRetain[i], false, i, 'Product'));
            }
        }
        this.adSalesProductLineItems.add(new LineItemWrapper(this.subTotal, this.adSalesProductLineItems.size()));
    }


    public void removeFlatProduct() {
        resetErrorFalg();
        this.availableForQuote = false;
        List<Opportunity_Line_Item__c> productsToRetain = new List<Opportunity_Line_Item__c>();
        if (this.flatProductLineItems.get(this.flatProductToRemove).product != null) {
            this.subTotal -= this.flatProductLineItems.get(this.flatProductToRemove).product.Total_Amount__c == null ? 0 : this.flatProductLineItems.get(this.flatProductToRemove).product.Total_Amount__c;
            //    calculateVat();
        }
        for (LineItemWrapper lineItem : this.flatProductLineItems) {
            if (lineItem.position != this.flatProductLineItems.size() - 1) {
                if (lineItem.position == this.flatProductToRemove) {
                    if (lineItem.product.Id != null) {
                        //this.listDeleteProductLineItems.add(lineItem.product);
                        this.listDeleteOppLineItems.add(lineItem.product);
                    }
                } else {
                    productsToRetain.add(lineItem.product);
                }
            }
        }
        this.flatProductLineItems.clear();
        if (!productsToRetain.isEmpty()) {
            for (Integer i = 0; i < productsToRetain.size(); i++) {
                this.flatProductLineItems.add(new LineItemWrapper(productsToRetain[i], false, i, 'Product'));
            }
        }
        this.flatProductLineItems.add(new LineItemWrapper(this.subTotal, this.flatProductLineItems.size()));
    }


    /**
    * called when a tariff is selected from the tariff dropdown on the createProductLineItems page. It removes Adsales line items that are part of the tariff that was previously selected.
    *
    *
    * @param
    * @return void
    */
    public void removeTariffAdsales() {
        for (LineItemWrapper lineItem : this.adSalesProductLineItems) {
            if (lineItem.position != this.adSalesProductLineItems.size() - 1) {
                if (lineItem.product.Id != null) {
                    //listDeleteProductLineItems.add(lineItem.product);
                    listDeleteOppLineItems.add(lineitem.product);
                }
            }
        }
        this.adSalesProductLineItems.clear();
    }

    public void removeTariffFlatProd() {
        for (LineItemWrapper lineItem : this.flatProductLineItems) {
            if (lineItem.position != this.flatProductLineItems.size() - 1) {
                if (lineItem.product.Id != null) {
                    //listDeleteProductLineItems.add(lineItem.product);
                    listDeleteOppLineItems.add(lineitem.product);
                }
            }
        }
        this.flatProductLineItems.clear();
    }
    public void removeTariffPPProd() {
        //this.subTotal = 0;
        for (LineItemWrapper lineItem : this.ppProductLineItems) {
            if (lineItem.position != this.ppProductLineItems.size() - 1) {
                if (lineItem.product.Id != null) {
                    //listDeleteProductLineItems.add(lineItem.product);
                    listDeleteOppLineItems.add(lineItem.product);
                }
            }
        }
        this.ppProductLineItems.clear();
    }

    public void removeTariffMPProd() {
        //this.subTotal = 0;
        for (LineItemWrapper lineItem : this.mpProductLineItems) {
            if (lineItem.position != this.mpProductLineItems.size() - 1) {
                if (lineItem.product.Id != null) {
                    //listDeleteProductLineItems.add(lineItem.product);
                    listDeleteOppLineItems.add(lineItem.product);
                }
            }
        }
        this.mpProductLineItems.clear();
    }

    public void removeTariffMSProd() {
        for (LineItemWrapper lineItem : this.msProductLineItems) {
            if (lineItem.position != this.msProductLineItems.size() - 1) {
                if (lineItem.product.Id != null) {
                    listDeleteOppLineItems.add(lineItem.product);
                }
            }
        }
        this.msProductLineItems.clear();
    }

    public void removeTariffDPProd() {
        for (LineItemWrapper lineItem : this.dpProductLineItems) {
            system.debug('%%lineitems' + lineItem);
            system.debug(this.dpProductLineItems);
            system.debug(this.dpProductLineItems.size());
            //if(lineItem.position != this.dpProductLineItems.size() - 1 ){
            if (lineItem.product != null && lineItem.product.Id != null) {
                listDeleteOppLineItems.add(lineItem.product);
            }
            // }
        }
        this.dpProductLineItems.clear();
    }


    //used for clearing product informations in the page
    public void clearproductData() {
        this.selectedProduct = new List_Product_Price__c();
        this.productQuantity = 0;
        this.totalAmount = 0;
        this.rabbat = '0';
    }

    public void addProduct() {
        resetErrorFalg();
        this.availableForQuote = false;
        /*if(this.selectedProductItem != null && this.selectedProductLineItem != null && this.selectedProductLineItem != '--' && this.mapProductType.get(this.selectedProductItem.Id_List_Price_Product__c)!=null && this.selectedProductItem.start_date__c==null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.Opportunity_AdSales_Start_Missing));
            return;
        }else*/
        if (this.selectedProductItem != null && this.selectedProductLineItem != null && this.selectedProductLineItem != '--' && this.selectedProductItem.Quantity__c != 0) {
            system.debug('**^' + this.selectedProductItem.Id_List_Price_Product__r.requires_add_on__c);
            if (/*this.businessApprovalProcess || (!this.businessApprovalProcess &&*/ validateMaximumDiscount(this.selectedProductItem.Listed_Price__c, Integer.valueOf(this.selectedProductItem.Quantity__c), this.mapMaximumDiscount.get(this.selectedProductItem.Id_List_Price_Product__c), this.selectedProductItem.Discount__c, this.mapHasApproval.get(this.selectedProductItem.Id_List_Price_Product__c))) {
                Opportunity_Line_Item__c prod = this.productLineItems[0].product;

                this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 0, Total_Amount__c = 0, Discount__c = '0', Line_Item_Type__c = 'Product');
                this.productLineItems[0] = new LineItemWrapper(this.selectedProductItem, false, 0, 'Product');
                this.productLineItems.remove(this.productLineItems.size() - 1);
                LineItemWrapper lineItem = new LineItemWrapper(prod, false, this.productLineItems.size(), 'Product');
                this.productLineItems.add(lineItem);
                this.subTotal += prod.Total_Amount__c;
                //calculateVat();
                this.selectedProductLineItem = '--';
                this.productLineItems.add(new LineItemWrapper(this.subTotal, this.productLineItems.size()));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.MissingFieldForProduct));
        }
    }

    public void addPPProduct() {
        resetErrorFalg();
        this.availableForQuote = false;
        if (this.selectedProductItem != null && this.selectedProductLineItem != null && this.selectedProductLineItem != '--' && this.mapProductType.get(this.selectedProductItem.Id_List_Price_Product__c) != null && this.mapProductType.get(this.selectedProductItem.Id_List_Price_Product__c).indexOf('Premium placement -') > -1 && this.selectedProductItem.start_date__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.Opportunity_AdSales_Start_Missing));
            return;
        } else if (this.selectedProductItem != null && this.selectedProductLineItem != null && this.selectedProductLineItem != '--' && this.selectedProductItem.Quantity__c != 0) {
            //System.debug('added product: '+this.selectedProductItem+'== this.selectedProductLineItem: '+this.selectedProductLineItem+' ==this.ppproductLineItems[0]: '+this.ppProductLineItems[0]);
            //System.debug('this.mapMaximumDiscount: '+this.mapMaximumDiscount);
            //System.debug('this.businessApprovalProcess: '+this.businessApprovalProcess);
            if (/*this.businessApprovalProcess || (!this.businessApprovalProcess &&*/ validateMaximumDiscount(this.selectedProductItem.Listed_Price__c, Integer.valueOf(this.selectedProductItem.Quantity__c), this.mapMaximumDiscount.get(this.selectedProductItem.Id_List_Price_Product__c), this.selectedProductItem.Discount__c, this.mapHasApproval.get(this.selectedProductItem.Id_List_Price_Product__c))) {
                Opportunity_Line_Item__c prod = this.ppProductLineItems[0].product;

                this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 0, Total_Amount__c = 0, Discount__c = '0', Line_Item_Type__c = 'Product');
                this.ppProductLineItems[0] = new LineItemWrapper(this.selectedProductItem, false, 0, 'Product');
                this.ppProductLineItems.remove(this.ppProductLineItems.size() - 1);
                LineItemWrapper lineItem = new LineItemWrapper(prod, false, this.ppProductLineItems.size(), 'Product');
                this.ppProductLineItems.add(lineItem);
                this.subTotal += prod.Total_Amount__c;
                //calculateVat();
                this.selectedProductLineItem = '--';
                this.ppProductLineItems.add(new LineItemWrapper(this.subTotal, this.ppProductLineItems.size()));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.MissingFieldForProduct));
        }
    }

    public void addMPProduct() {
        resetErrorFalg();
        this.availableForQuote = false;
        /*if(this.selectedProductItem != null && this.selectedProductLineItem != null && this.selectedProductLineItem != '--' /*&& this.mapProductType.get(this.selectedProductItem.Id_List_Price_Product__c)!=null && this.mapProductType.get(this.selectedProductItem.Id_List_Price_Product__c).indexOf('Premium placement -') > -1 && this.selectedProductItem.start_date__c==null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.Opportunity_AdSales_Start_Missing));
            return;
        }else */
        if (this.selectedProductItem != null && this.selectedProductLineItem != null && this.selectedProductLineItem != '--' && this.selectedProductItem.Quantity__c != 0 && this.mapProductType.get(this.selectedProductItem.Id_List_Price_Product__c) != null && this.selectedProductItem.Number_of_Copies__c != null && this.selectedProductItem.Size__c != null && this.selectedProductItem.Listed_Price__c != null && this.selectedProductItem.Listed_Price__c > 0) {
            // System.debug('added product: '+this.selectedProductItem+'== this.selectedProductLineItem: '+this.selectedProductLineItem+' ==this.ppproductLineItems[0]: '+this.ppProductLineItems[0]);
            // System.debug('this.mapMaximumDiscount: '+this.mapMaximumDiscount);
            // System.debug('this.businessApprovalProcess: '+this.businessApprovalProcess);
            /* if(this.businessApprovalProcess || (!this.businessApprovalProcess && validateMaximumDiscount(this.selectedProductItem.Listed_Price__c,Integer.valueOf(this.selectedProductItem.Quantity__c), this.mapMaximumDiscount.get(this.selectedProductItem.Id_List_Price_Product__c), this.selectedProductItem.Discount__c))){
              */   Opportunity_Line_Item__c prod = this.mpProductLineItems[0].product;

            this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 1, Total_Amount__c = 0, Discount__c = '0', Line_Item_Type__c = 'Product');
            this.mpProductLineItems[0] = new LineItemWrapper(this.selectedProductItem, false, 0, 'Product');
            this.mpProductLineItems.remove(this.mpProductLineItems.size() - 1);
            LineItemWrapper lineItem = new LineItemWrapper(prod, false, this.mpProductLineItems.size(), 'Product');
            this.mpProductLineItems.add(lineItem);
            this.subTotal += prod.Total_Amount__c;
            //calculateVat();
            this.selectedProductLineItem = '--';
            system.debug('@@' + this.subTotal + this.mpProductLineItems.size());
            this.mpProductLineItems.add(new LineItemWrapper(this.subTotal, this.mpProductLineItems.size()));
            //}
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.MissingFieldForProduct));
        }
    }

    public void addMSProduct() {
        resetErrorFalg();
        this.availableForQuote = false;

        if (this.selectedProductItem != null && this.selectedProductLineItem != null && this.selectedProductLineItem != '--' && this.selectedProductItem.Quantity__c != 0 && this.mapProductType.get(this.selectedProductItem.Id_List_Price_Product__c) != null && this.selectedProductItem.Listed_Price__c != null ) {
            Opportunity_Line_Item__c prod = this.msProductLineItems[0].product;
            this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 1, Total_Amount__c = 0, Discount__c = '0', Line_Item_Type__c = 'Product');
            this.msProductLineItems[0] = new LineItemWrapper(this.selectedProductItem, false, 0, 'Product');
            this.msProductLineItems.remove(this.msProductLineItems.size() - 1);
            LineItemWrapper lineItem = new LineItemWrapper(prod, false, this.msProductLineItems.size(), 'Product');
            this.msProductLineItems.add(lineItem);
            this.subTotal += prod.Total_Amount__c;
            this.selectedProductLineItem = '--';
            system.debug('@@' + this.subTotal + this.msProductLineItems.size());
            this.msProductLineItems.add(new LineItemWrapper(this.subTotal, this.msProductLineItems.size()));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.MissingFieldForProduct));
        }
    }

    public void addDPProduct() {
        resetErrorFalg();
        this.availableForQuote = false;

        if (this.selectedProductItem != null && this.selectedProductLineItem != null && this.selectedProductLineItem != '--' && this.selectedProductItem.Quantity__c != 0 && this.mapProductType.get(this.selectedProductItem.Id_List_Price_Product__c) != null && this.selectedProductItem.Listed_Price__c != null && this.selectedProductItem.Listed_Price__c > 0 && this.selectedProductItem.end_date__c != null && this.selectedProductItem.discount__c != null && this.selectedProductItem != null ) {
            Opportunity_Line_Item__c prod = this.dpProductLineItems[0].product;
            // this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 1, Total_Amount__c = 0, Discount__c = '0', Line_Item_Type__c='Product');
            // this.dpProductLineItems[0] = new LineItemWrapper(this.selectedProductItem, false, 0,'Product');
            this.dpProductLineItems.remove(this.dpProductLineItems.size() - 1);
            LineItemWrapper lineItem = new LineItemWrapper(prod, false, this.dpProductLineItems.size(), 'Product');
            this.dpProductLineItems.add(lineItem);
            this.subTotal += prod.Total_Amount__c;
            this.selectedProductLineItem = '--';
            system.debug('@@' + this.subTotal + this.dpProductLineItems.size());
            this.dpProductLineItems.add(new LineItemWrapper(this.subTotal, this.dpProductLineItems.size()));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.MissingFieldForProduct));
        }
    }

    public void removeProduct() {
        resetErrorFalg();
        this.availableForQuote = false;
        try {
            if (this.productToRemove != null && this.productLineItems.get(this.productToRemove) != null) {
                if (this.productLineItems.get(this.productToRemove).product != null) {
                    this.subTotal -= this.productLineItems.get(this.productToRemove).product.Total_Amount__c;
                    //calculateVat();
                }

                List<Opportunity_Line_Item__c> productsToRetain = new List<Opportunity_Line_Item__c>();
                for (LineItemWrapper lineItem : this.productLineItems) {
                    if (lineItem.position != 0 && (lineItem.position != this.productLineItems.size() - 1)) {
                        if (lineItem.position == this.productToRemove) {
                            if (lineItem.product.Id != null) {
                                //this.listDeleteProductLineItems.add(lineItem.product);
                                this.listDeleteOppLineItems.add(lineitem.product);
                            }
                        } else {
                            productsToRetain.add(lineItem.product);
                        }
                    }
                }
                this.productLineItems.clear();

                this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 0, Total_Amount__c = 0, Discount__c = '0', Line_Item_Type__c = 'Product');
                this.productLineItems.add(new LineItemWrapper(this.selectedProductItem, false, 0, 'Product'));

                if (!productsToRetain.isEmpty()) {
                    for (Integer i = 0; i < productsToRetain.size(); i++) {
                        this.productLineItems.add(new LineItemWrapper(productsToRetain[i], false, i + 1, 'Product'));
                    }
                }
                this.productLineItems.add(new LineItemWrapper(this.subTotal, this.productLineItems.size()));
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.Opportunity_Error_Occurred));
            system.debug('@@@@ calling removeProduct. The following error occurred while removing the product : ' + e.getMessage());
        }
    }

    public void removePPProduct() {
        resetErrorFalg();
        this.availableForQuote = false;
        try {
            if (this.productToRemove != null && this.ppProductLineItems.get(this.productToRemove) != null) {
                if (this.ppProductLineItems.get(this.productToRemove).product != null) {
                    this.subTotal -= this.ppProductLineItems.get(this.productToRemove).product.Total_Amount__c;
                    //    calculateVat();
                }

                List<Opportunity_Line_Item__c> productsToRetain = new List<Opportunity_Line_Item__c>();
                for (LineItemWrapper lineItem : this.ppProductLineItems) {
                    if (lineItem.position != 0 && (lineItem.position != this.ppProductLineItems.size() - 1)) {
                        if (lineItem.position == this.productToRemove) {
                            System.debug('lineItem.product remove: ' + lineItem.product);
                            if (lineItem.product.Id != null) {
                                //this.listDeleteProductLineItems.add(lineItem.product);
                                this.listDeleteOppLineItems.add(lineitem.product);
                            }
                        } else {
                            productsToRetain.add(lineItem.product);
                        }
                    }
                }
                this.ppProductLineItems.clear();

                this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 0, Total_Amount__c = 0, Discount__c = '0');
                this.ppProductLineItems.add(new LineItemWrapper(this.selectedProductItem, false, 0, 'Product'));

                if (!productsToRetain.isEmpty()) {
                    for (Integer i = 0; i < productsToRetain.size(); i++) {
                        this.ppProductLineItems.add(new LineItemWrapper(productsToRetain[i], false, i + 1, 'Product'));
                    }
                }
                this.ppProductLineItems.add(new LineItemWrapper(this.subTotal, this.ppProductLineItems.size()));
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.Opportunity_Error_Occurred));
            system.debug('@@@@ calling removeProduct. The following error occurred while removing the product : ' + e.getMessage());
        }
    }

    public void removeMPProduct() {
        resetErrorFalg();
        this.availableForQuote = false;
        try {
            if (this.productToRemove != null && this.mpProductLineItems.get(this.productToRemove) != null) {
                if (this.mpProductLineItems.get(this.productToRemove).product != null) {
                    this.subTotal -= this.mpProductLineItems.get(this.productToRemove).product.Total_Amount__c;
                    //    calculateVat();
                }

                List<Opportunity_Line_Item__c> productsToRetain = new List<Opportunity_Line_Item__c>();
                for (LineItemWrapper lineItem : this.mpProductLineItems) {
                    if (lineItem.position != 0 && (lineItem.position != this.mpProductLineItems.size() - 1)) {
                        if (lineItem.position == this.productToRemove) {
                            System.debug('lineItem.product remove: ' + lineItem.product);
                            if (lineItem.product.Id != null) {
                                //this.listDeleteProductLineItems.add(lineItem.product);
                                this.listDeleteOppLineItems.add(lineitem.product);
                            }
                        } else {
                            productsToRetain.add(lineItem.product);
                        }
                    }
                }
                this.mpProductLineItems.clear();

                this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 1, Total_Amount__c = 0, Discount__c = '0');
                this.mpProductLineItems.add(new LineItemWrapper(this.selectedProductItem, false, 0, 'Product'));

                if (!productsToRetain.isEmpty()) {
                    for (Integer i = 0; i < productsToRetain.size(); i++) {
                        this.mpProductLineItems.add(new LineItemWrapper(productsToRetain[i], false, i + 1, 'Product'));
                    }
                }
                this.mpProductLineItems.add(new LineItemWrapper(this.subTotal, this.mpProductLineItems.size()));
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.Opportunity_Error_Occurred));
            system.debug('@@@@ calling removeProduct. The following error occurred while removing the product : ' + e.getMessage());
        }
    }



    public void removeMSProduct() {
        resetErrorFalg();
        this.availableForQuote = false;
        try {
            if (this.productToRemove != null && this.msProductLineItems.get(this.productToRemove) != null) {
                if (this.msProductLineItems.get(this.productToRemove).product != null) {
                    this.subTotal -= this.msProductLineItems.get(this.productToRemove).product.Total_Amount__c;
                }

                List<Opportunity_Line_Item__c> productsToRetain = new List<Opportunity_Line_Item__c>();
                for (LineItemWrapper lineItem : this.msProductLineItems) {
                    if (lineItem.position != 0 && (lineItem.position != this.msProductLineItems.size() - 1)) {
                        if (lineItem.position == this.productToRemove) {
                            //System.debug('lineItem.product remove: '+lineItem.product);
                            if (lineItem.product.Id != null) {
                                this.listDeleteOppLineItems.add(lineitem.product);
                            }
                        } else {
                            productsToRetain.add(lineItem.product);
                        }
                    }
                }
                this.msProductLineItems.clear();

                this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 1, Total_Amount__c = 0, Discount__c = '0');
                this.msProductLineItems.add(new LineItemWrapper(this.selectedProductItem, false, 0, 'Product'));

                if (!productsToRetain.isEmpty()) {
                    for (Integer i = 0; i < productsToRetain.size(); i++) {
                        this.msProductLineItems.add(new LineItemWrapper(productsToRetain[i], false, i + 1, 'Product'));
                    }
                }
                this.msProductLineItems.add(new LineItemWrapper(this.subTotal, this.msProductLineItems.size()));
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.Opportunity_Error_Occurred));
            system.debug('@@@@ calling removeProduct. The following error occurred while removing the product : ' + e.getMessage());
        }
    }

    public void removeDPProduct() {
        resetErrorFalg();
        this.availableForQuote = false;
        try {
            if (this.productToRemove != null && this.dpProductLineItems.get(this.productToRemove) != null) {
                if (this.dpProductLineItems.get(this.productToRemove).product != null) {
                    this.subTotal -= this.dpProductLineItems.get(this.productToRemove).product.Total_Amount__c;
                }

                List<Opportunity_Line_Item__c> productsToRetain = new List<Opportunity_Line_Item__c>();
                for (LineItemWrapper lineItem : this.dpProductLineItems) {
                    if (lineItem.position != 0 && (lineItem.position != this.dpProductLineItems.size() - 1)) {
                        if (lineItem.position == this.productToRemove) {
                            //System.debug('lineItem.product remove: '+lineItem.product);
                            if (lineItem.product.Id != null) {
                                this.listDeleteOppLineItems.add(lineitem.product);
                            }
                        } else {
                            productsToRetain.add(lineItem.product);
                        }
                    }
                }
                this.dpProductLineItems.clear();

                this.selectedProductItem = new Opportunity_Line_Item__c(Quantity__c = 1, Total_Amount__c = 0, Discount__c = '0');
                this.dpProductLineItems.add(new LineItemWrapper(this.selectedProductItem, false, 0, 'Product'));

                if (!productsToRetain.isEmpty()) {
                    for (Integer i = 0; i < productsToRetain.size(); i++) {
                        this.dpProductLineItems.add(new LineItemWrapper(productsToRetain[i], false, i + 1, 'Product'));
                    }
                }
                this.dpProductLineItems.add(new LineItemWrapper(this.subTotal, this.dpProductLineItems.size()));
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.Opportunity_Error_Occurred));
            system.debug('@@@@ calling removeProduct. The following error occurred while removing the product : ' + e.getMessage());
        }
    }


    /*
    changes for SP-597
    calculation of how much the max discount was exceeded.
    needed for multi stage talabat quote apporval flow
    */
    // Checks the maximum discount allowed for the product line items
    private Boolean validateMaximumDiscount(Decimal listPrice, Integer quantity, Decimal maximumDiscount, String discountAdded, Boolean hasApproval) {
        System.debug('listPrice: '+listPrice+' quantity: '+quantity+' maximumDiscount: '+maximumDiscount+' discountAdded: '+discountAdded+'hasApproval'+hasApproval);
        system.debug('####approval'+this.requiresApproval);
        List<String> discountInPercent = new List<String>();
        Decimal discountResult;

        Decimal discountLimitExceed;
        if (maximumDiscount != null) {
            if(maximumDiscount==0 && hasApproval){
                //if (hasApproval) {
                        if (!this.requiresApproval)
                            this.requiresApproval = true;
                        return true;
               // }
            
            }else{
                if (discountAdded.indexOf('%') > -1) {
                    discountInPercent = discountAdded.split('%');
                    if (Decimal.valueOf(discountInPercent[0]) > maximumDiscount ) {
                        //this.mapBusinessData
                        discountLimitExceed = maximumDiscount - Decimal.valueOf(discountInPercent[0]);
                        if (!hasApproval) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.MaximumDiscountAllowed + ' ' + maximumDiscount + '%'));
                            return false;
                        } else if (hasApproval) {
                            if (!this.requiresApproval)
                                this.requiresApproval = true;
                            return true;

                        }
                    } else {
                        return true;
                    }
                } else {
                //Decimal discountValue = (listPrice * quantity) * (maximumDiscount/100);
                    Decimal discountValue = listPrice * (maximumDiscount / 100);
                    discountResult = discountValue.setScale(2);
                    if (Decimal.valueOf(discountAdded) > discountResult) {
                        if (!hasApproval) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.MaximumDiscountAmountAllowed + ' ' + discountResult));
                            return false;
                        } else if (hasApproval) {
                            if (!this.requiresApproval)
                                this.requiresApproval = true;
                            return true;

                        }
                    } else {
                        return true;
                    }

                }
                return false;
            }
        }
        return true;
    }

    @TestVisible
    private Boolean isSoftLimitDiscountViolated (Decimal listPrice, Decimal quantity, Decimal softDiscount, String discountAdded) {
        List<String> discountInPercent = new List<String>();
        Decimal discountResult;
        if (softDiscount != null) {
            if(softDiscount==0 ){
                //if (hasApproval) {
                        if (!this.requiresApproval)
                            this.requiresApproval = true;
                        return true;
               // }
            
            }else{
                if (discountAdded.indexOf('%') > -1) {
                    discountInPercent = discountAdded.split('%');
                    if (Decimal.valueOf(discountInPercent[0]) <= softDiscount) {
                        return false;
                    } else {
                        return true;
                    }
                } else {
                    //Decimal discountValue = (listPrice * quantity) * (softDiscount/100);
                    Decimal discountValue = listPrice * (softDiscount / 100);
                    discountResult = discountValue.setScale(2);
                    if (Decimal.valueOf(discountAdded) <= discountResult) {
                        return false;
                    } else {
                        return true;
                    }

                }
            }
            return false;
        }
        return false;
    }

    public void addService() {
        System.debug('CtrCreateProductLineItems.addService: start');

        resetErrorFalg();
        this.availableForQuote = false;

        System.debug('CtrCreateProductLineItems.addService: selected service is: ' + this.selectedService);

        // checks for null values
        if (this.selectedService == null
                || String.isBlank(this.selectedService.name)
                || this.selectedService.Start_Date__c == null ) {

            System.debug('CtrCreateProductLineItems.addService: selected service has some null values');

            ClsUtilsApexPages.addErrorMessage(label.MissingFieldForService);
            return;
        }

        // validate start date and end date
        if (this.selectedService.Start_Date__c >= this.selectedService.End_Date__c) {

            System.debug('CtrCreateProductLineItems.addService: start date and end date are not valid');

            ClsUtilsApexPages.addErrorMessage(Label.EndDateGreaterValidation);
            return;
        }

        List_Service_Price__c service = this.mapListServicePrice.get(this.selectedService.Id_List_Service_Price__c);

        System.debug('CtrCreateProductLineItems.addService: list service price is: ' + service);
        System.debug('CtrCreateProductLineItems.addService: starting commission checks...');

        // checks commission type Per Order
        if (service.Commission_type__c == 'Per Order') {

            System.debug('CtrCreateProductLineItems.addService: per order commission');

            // checks commission per order
            if (this.selectedService.Commission_Per_Order__c == null) {
                ClsUtilsApexPages.addErrorMessage(Label.Commission_Per_Order_Mandatory);
                return;
            }

            // checks if value exceeds maximum
            if (this.selectedService.Commission_Per_Order__c > service.Maximum_Commission_Per_Order__c) {
                ClsUtilsApexPages.addErrorMessage(
                    String.format(
                        Label.CommissionInPercentageRange,
                        new List<String> {String.valueOf(service.Minimum_Commission_Per_Order__c), String.valueOf(service.Maximum_Commission_Per_Order__c)}
                    )
                );
                return;
            }

            // checks minimum value
            if (this.selectedService.Commission_Per_Order__c < service.Minimum_Commission_Per_Order__c
                    && !service.Requires_Approval__c) {
                ClsUtilsApexPages.addErrorMessage(
                    String.format(
                        Label.CommissionPerOrderNotLessThan,
                        new List<String> {String.valueOf(service.Minimum_Commission_Per_Order__c)}
                    )
                );
                return;
            }

            // everything is fine for per order commission
            System.debug('CtrCreateProductLineItems.addService: per order commission is valid');
        }

        // checks commission type Percentage
        else {
            System.debug('CtrCreateProductLineItems.addService: percentage commission');

            // checks commission value
            if (this.selectedService.Commission_In_Percentage__c == null) {
                ClsUtilsApexPages.addErrorMessage(Label.CommisionInPercentageMandatory);
                return;
            }

            // checks maximum percentage
            if (this.selectedService.Commission_In_Percentage__c > service.Maximum_Commission_In_Percentage__c) {
                ClsUtilsApexPages.addErrorMessage(Label.CommissionInPercentageRange + ' ' + service.Minimum_Commission_in_Percentage__c + ' & ' + service.Maximum_Commission_In_Percentage__c);
                return;
            }

            // checks minimum percentage
            if (this.selectedService.Commission_In_Percentage__c < service.Minimum_Commission_in_Percentage__c
                    && !service.Requires_Approval__c) {
                ClsUtilsApexPages.addErrorMessage(Label.CommissionInPercentageNotLessThan + ' ' + service.Minimum_Commission_in_Percentage__c);
                return;
            }

            // everything is fine for percentage commission
            System.debug('CtrCreateProductLineItems.addService: percentage commission is valid');
        }

        System.debug('CtrCreateProductLineItems.addService: adding new service item');

        // add line item
        LineItemWrapper lineItem = new LineItemWrapper(this.selectedService, false, this.serviceLineItems.size(), 'Service');
        this.serviceLineItems.remove(0);
        this.serviceLineItems.add(lineItem);
        this.sortListWithoutUpsert();
        this.selectedService = new Opportunity_Line_Item__c();
        this.selectedServiceItem = '--';

        System.debug('CtrCreateProductLineItems.addService: done');
    }

    public void removeService() {
        resetErrorFalg();
        this.availableForQuote = false;
        List<Opportunity_Line_Item__c> servicesToRetain = new List<Opportunity_Line_Item__c>();
        for (LineItemWrapper lineItem : this.serviceLineItems) {
            if (lineItem.position != 0) {
                if (lineItem.position == this.serviceToRemove) {
                    if (lineItem.service.Id != null) {
                        //this.listDeleteServiceLineItems.add(lineItem.service);
                        this.listDeleteOppLineItems.add(lineitem.service);
                    }
                } else {
                    servicesToRetain.add(lineItem.service);
                }
            }
        }

        this.serviceLineItems.clear();
        if (!servicesToRetain.isEmpty()) {
            for (Integer i = 0; i < servicesToRetain.size(); i++) {
                this.serviceLineItems.add(new LineItemWrapper(servicesToRetain[i], false, i, 'Service'));
            }
        }
        //Added by Bhupendra for SP1347-Start
        this.selectedService = new Opportunity_Line_Item__c();
        this.selectedServiceItem = '--';
        //Added by Bhupendra for SP1347-End
        if (!this.serviceLineItems.isEmpty()) {
            sortListWithoutUpsert();
        } else {
            this.serviceLineItems.add(new LineItemWrapper(new Opportunity_Line_Item__c(), false, 0, 'Service'));
        }

    }

    public void sortLineItems() {
        this.selectedServiceItem = '--';
        this.serviceLineItems.remove(0);
        sortListWithoutUpsert();
    }

    public void autoEndDate(){
        List<Opportunity_Line_Item__c> listSelectedServices = new List<Opportunity_Line_Item__c>();
        for (LineItemWrapper lineItem : this.serviceLineItems) {
            listSelectedServices.add(lineItem.service);
        }
        
        for (Integer i = 0; i < listSelectedServices.size(); i++) {
            if (annualEndDateCountrySet.contains(this.opp.Record_Country__c)) {
                if (listSelectedServices[i].Start_Date__c != null ) {
                    listSelectedServices[i].End_Date__c = listSelectedServices[i].Start_Date__c.addYears(1).addDays(-1);
                } else if (listSelectedServices[i].Start_Date__c == null && listSelectedServices[i].End_Date__c != null) {
                    listSelectedServices[i].End_Date__c = null;
                }
            }
        }

    }

    public void sortListWithoutUpsert() {
        List<Opportunity_Line_Item__c> services = new List<Opportunity_Line_Item__c>();
        Map<String, List<Opportunity_Line_Item__c>> mapOfServicesByType = new Map<String, List<Opportunity_Line_Item__c>>();
        List<Opportunity_Line_Item__c> listSelectedServices = new List<Opportunity_Line_Item__c>();
        for (LineItemWrapper lineItem : this.serviceLineItems) {
            listSelectedServices.add(lineItem.service);
        }

        if (this.mapBusinessData.get('usesServiceTypes') != null && (String.isNotBlank(this.mapBusinessData.get('usesServiceTypes').Business_Rule_Value__c) && this.mapBusinessData.get('usesServiceTypes').Business_Rule_Value__c != 'false')) {
            mapOfServicesByType = this.groupLineItemsByServiceType(listSelectedServices);

            if (mapOfServicesByType != null) {
                Integer control = 0;
                for (String str : mapOfServicesByType.keySet()) {
                    if (control == 0) {
                        this.performSort(mapOfServicesByType.get(str), true);
                    } else {
                        this.performSort(mapOfServicesByType.get(str), false);
                    }
                    control++;
                }
            } else {
                this.performSort(listSelectedServices, true);
            }
        } else {
            this.performSort(listSelectedServices, true);
        }
    }

    private Map<String, List<Opportunity_Line_Item__c>> groupLineItemsByServiceType(List<Opportunity_Line_Item__c> listSelectedServices) {
        Map<String, List<Opportunity_Line_Item__c>> mapOfServicesByType = new Map<String, List<Opportunity_Line_Item__c>>();
        for (Opportunity_Line_Item__c osi : listSelectedServices) {
            if (osi.Sub_Type__c != null) {
                if (mapOfServicesByType.get(osi.Sub_Type__c) != null) {
                    mapOfServicesByType.get(osi.Sub_Type__c).add(osi);
                } else {
                    mapOfServicesByType.put(osi.Sub_Type__c, new List<Opportunity_Line_Item__c> {osi});
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.Line_Items_Missing_Service_Type));
                return null;
            }
        }
        return mapOfServicesByType;
    }

    private Boolean servicesAreOverlapping(Map<String, List<Opportunity_Line_Item__c>> mapOfServicesByType) {
        for (String str : mapOfServicesByType.keySet()) {
            Set<Date> startDates = new Set<Date>();
            for (Opportunity_Line_Item__c osi : mapOfServicesByType.get(str)) {
                if (startDates.contains(osi.Start_Date__c)) {
                    return true;
                } else {
                    startDates.add(osi.Start_Date__c);
                }
            }
        }
        return false;
    }

    private void performSort(List<Opportunity_Line_Item__c> listSelectedServices, Boolean isFirst) {
        Integer ind = 0;
        if (listSelectedServices.size() > 1) {
            LibOpportunityLineItemsHelper.sortList(listSelectedServices, 'Start_Date__c', 'asc');
        }
        if (this.mapBusinessData.get('usesServiceTypes') != null && (String.isNotBlank(this.mapBusinessData.get('usesServiceTypes').Business_Rule_Value__c) && this.mapBusinessData.get('usesServiceTypes').Business_Rule_Value__c != 'false')) {
            this.setMainFees(listSelectedServices);
        }

        if (listSelectedServices.size() > 1) {
            System.debug('overlappingDisabledCountrySet: ' + overlappingDisabledCountrySet);
            for (Integer i = 0; i < listSelectedServices.size(); i++) {
                if (!overlappingDisabledCountrySet.contains(this.opp.Record_Country__c)) {
                    if (i != listSelectedServices.size() - 1) {
                        if (listSelectedServices[i + 1].Start_Date__c != null) {
                            listSelectedServices[i].End_Date__c = listSelectedServices[i + 1].Start_Date__c.addDays(-1);
                        }
                    } else {
                        listSelectedServices[i].End_Date__c = null;
                    }
                }
                //System.debug('listSelectedServices[i]: '+listSelectedServices[i]);
                if (annualEndDateCountrySet.contains(this.opp.Record_Country__c)) {
                    if (listSelectedServices[i].Start_Date__c != null &&   listSelectedServices[i].End_Date__c==null) {
                        listSelectedServices[i].End_Date__c = listSelectedServices[i].Start_Date__c.addYears(1).addDays(-1);
                    } else if (listSelectedServices[i].Start_Date__c == null && listSelectedServices[i].End_Date__c != null) {
                        listSelectedServices[i].End_Date__c = null;
                    }
                }
            }

            if (isFirst) {
                this.serviceLineItems.clear();
                this.serviceLineItems.add(new LineItemWrapper(new Opportunity_Line_Item__c(), false, 0, 'Service'));
            }
            ind = this.serviceLineItems.size();
            for (Integer i = 0; i < listSelectedServices.size(); i++) {
                Integer len = i + ind;
                LineItemWrapper lineItem = new LineItemWrapper(listSelectedServices[i], false, len, 'Service');
                this.serviceLineItems.add(lineItem);
            }
        } else if (listSelectedServices.size() == 1) {
            if (isFirst) {
                this.serviceLineItems.clear();
                this.serviceLineItems.add(new LineItemWrapper(new Opportunity_Line_Item__c(), false, 0, 'Service'));
            }
            ind = this.serviceLineItems.size();
            LineItemWrapper lineItem = new LineItemWrapper(listSelectedServices[0], false, ind, 'Service');
            this.serviceLineItems.add(lineItem);
        } else {
            this.serviceLineItems.clear();
        }
    }
    //Sets the Main fees details in opportunity for Quote
    private void setMainFees(List<Opportunity_Line_Item__c> listSelectedServices) {
        for (Opportunity_Line_Item__c osi : listSelectedServices) {
            if (osi.Sub_Type__c != null) {
                //commission type
                if (osi.Sub_Type__c.equals('Fixed Amount') && osi.End_Date__c == null) {
                    this.mainFixedAmount = osi.Commission_Per_Order__c != null ? osi.Commission_Per_Order__c : 0.0;
                } else if (osi.Sub_Type__c.equals('Commission Fee') && osi.End_Date__c == null) {
                    this.mainCommissionFee = osi.Commission_In_Percentage__c != null ? osi.Commission_In_Percentage__c : 0.0;
                } else if (osi.Sub_Type__c.equals('Online Payment Fee') && osi.End_Date__c == null) {
                    this.mainOnlinePaymentFee = osi.Commission_In_Percentage__c != null ? osi.Commission_In_Percentage__c : 0.0;
                } else if (osi.Sub_Type__c.equals('Transmission Fee') && osi.End_Date__c == null) {
                    this.mainOrderTransmissionFee = osi.Commission_In_Percentage__c != null ? osi.Commission_In_Percentage__c : 0.0;
                }
            }
            if (annualEndDateCountrySet.contains(this.opp.Record_Country__c)) {
                if (osi.Start_Date__c != null) {
                    osi.End_Date__c = osi.Start_Date__c.addYears(1).addDays(-1);
                } else if (osi.Start_Date__c == null && osi.End_Date__c != null) {
                    osi.End_Date__c = null;
                }
            }
        }
    }

    public Boolean validateServiceItems() {
        system.debug('Service******');
        resetErrorFalg();
        Set<String> uniqueStartDates = new Set<String>();
        Date startDate = null;
        Date endDate = null;
        Decimal min = null;
        //this.isRegionalApproval=false;
        //this.requiresApproval=false;
        //this.multiStageApprovalNeeded =false;
         system.debug('Service2******');

        if (this.serviceLineItems.isEmpty()) {
            return true;
        }

        for (LineItemWrapper lineItem : this.serviceLineItems) {
            system.debug('$$'+lineItem.service);
            // skip first one, no idea why...
            if (lineitem.position == 0) {
                continue;
            }

            Opportunity_Line_Item__c ss = lineItem.service;
            List_Service_Price__c servicePrice = this.mapListServicePrice.get(ss.Id_List_Service_Price__c);
            system.debug(lineitem.position);
            system.debug(ss.max__c);

            if (!ss.IsTiered__c
                    && servicePrice != null
                    && servicePrice.Service_Type__c == 'Commission Fee'
                    && servicePrice.Commission_type__c == 'Percentage') {
                this.ExclusiveCommission = 20 - ss.Commission_In_Percentage__c;
            }

            if (ss.IsTiered__c) {
                // first index pilot startdate and endsate
                String m = lineItem.min;
                        String mx = lineitem.max;
                        String cm = lineitem.commission;

                        system.debug('min'+m);

                        //String cm = lineitem.commission;
                if (ss.index__c == 1) {
                    if (ss.Max__c == null ||(ss.Max__c != null && ss.Max__c <= 0)) {
                        ClsUtilsApexPages.addErrorMessage(Label.Max_Validation + ' ' + ss.Min__c);
                        lineItem.showError = true;
                        return false;
                    }

                    startDate = ss.Start_Date__c;
                    endDate = ss.End_Date__c;
                } else {
                    ss.start_date__c = startDate;
                    ss.End_Date__c = endDate;
                }

                min = ss.Min__c;
              

                if (String.isNotBlank(lineitem.onlinePayment) && !lineitem.onlinePayment.isWhitespace()) {
                    ss.online_payment_fee__c = Decimal.valueof(lineitem.onlinePayment);
                }

                if (String.isNotBlank(lineItem.comissionperorder) && !lineitem.comissionperorder.isWhitespace()) {
                    ss.commission_per_order__C = Decimal.valueof(lineitem.comissionperorder);
                }
            }

            // checks on start date
            if (ss.Start_Date__c == null ) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.MandatoryStartDate));
                lineItem.showError = true;
                return false;
            }

            if (ss.IsTiered__c && (ss.index__c >= 2 || ss.index__c <= 4) && ss.Max__c != null && ss.Max__c <= min) {
                ClsUtilsApexPages.addErrorMessage(Label.Max_Validation + ' ' + min);
                lineItem.showError = true;
                return false;
            } else if (ss.IsTiered__c && ss.Min__c != null && (ss.Commission_In_Percentage__c == null && servicePrice.Commission_Type__c == 'Percentage')) {
                ClsUtilsApexPages.addErrorMessage(Label.CommisionInPercentageMandatory);
                lineItem.showError = true;
                return false;
            } else if (ss.IsTiered__c && ss.Min__c != null && ( servicePrice.Commission_Type__c == 'Per Order' && ss.Commission_Per_Order__c == null)) {
                ClsUtilsApexPages.addErrorMessage(Label.Commission_Per_Order_Mandatory);
                lineItem.showError = true;
                return false;
            } else if (ss.Start_Date__c >= ss.End_Date__c) {
                ClsUtilsApexPages.addErrorMessage(Label.EndDateGreaterValidation);
                lineItem.showError = true;
                return false;
            } else if (!ss.IsTiered__c && servicePrice.Commission_Type__c == 'Per Order' && ss.Commission_Per_Order__c == null) {
                ClsUtilsApexPages.addErrorMessage(Label.Commission_Per_Order_Mandatory);
                lineItem.showError = true;
                return false;
            } else if (servicePrice != null) {

                // validate per order commission

                if (servicePrice.Commission_Type__c == 'Per Order') {

                    if (ss.Commission_Per_Order__c < servicePrice.Minimum_Commission_Per_Order__c
                            && !servicePrice.Requires_Approval__c) {

                        String errorMsg = servicePrice.Maximum_Commission_Per_Order__c == null
                                          ? Label.CommissionPerOrderNotLessThan + ' ' + servicePrice.Minimum_Commission_Per_Order__c
                                          : String.format(Label.CommissionPerOrderRange, new List<String> {String.valueOf(servicePrice.Minimum_Commission_Per_Order__c), String.valueOf(servicePrice.Maximum_Commission_Per_Order__c)});

                        ClsUtilsApexPages.addErrorMessage(errorMsg);
                        lineItem.showError = true;
                        return false;
                    }

                    if (ss.Commission_Per_Order__c > servicePrice.Maximum_Commission_Per_Order__c) {
                        ClsUtilsApexPages.addErrorMessage(
                            String.format(
                                Label.CommissionPerOrderRange,
                                new List<String> {String.valueOf(servicePrice.Minimum_Commission_Per_Order__c), String.valueOf(servicePrice.Maximum_Commission_Per_Order__c)}
                            )
                        );
                        lineItem.showError = true;
                        return false;
                    }

                    // NOTE: maybe we need to refactor this logic related to approval process - @CreatedBy m.zeuli

                    if (servicePrice.Requires_Approval__c
                            && ss.Commission_Per_Order__c < servicePrice.Minimum_Commission_Per_Order__c) {
                            system.debug('&&approval^^');
                        
                            if(this.mapOppTeam!=null && !this.mapOppTeam.isEmpty()){
                                 if (!this.mapOppTeam.containskey('HOS') ) {
                                    ClsUtilsApexPages.addErrorMessage(Label.No_Approver);
                                    lineItem.showError = true;
                                      return false;
                                }
                                
                                this.mapApprovalEntriesLevel1=this.mapOppTeam.get('HOS');
                                
                                //this.mapApproval.put(otm.user.Email, otm.UserId);
                                if (this.mapApprovalEntriesLevel1 != null && !this.mapApprovalEntriesLevel1.isEmpty() ) {
                                    OpportunityTeamMember otm =this.mapApprovalEntriesLevel1.values()[0];
                                    //this.isRegionalApproval = false;                                    
                                    this.mapApproval.put(otm.user.Email, otm.UserId);
                                    this.multiStageApprovalNeeded = true;
                                    this.approvalLimits = LibBusinessConfig.determineApprover(this.opp.Record_Country__c,'HOS' );
                                    
                                    
                                    if(this.approvalLimits.ApprovalLimit_PerOrder__c != null && ss.Commission_Per_Order__c < this.approvalLimits.ApprovalLimit_PerOrder__c && comissiontypeForReg.contains(ss.sub_type__c)){
                                        this.mapApprovalEntriesLevel3 = this.mapOppTeam.get('Regional HOS');
                                        if (this.mapApprovalEntriesLevel3 != null && !this.mapApprovalEntriesLevel3.values().isEmpty() && this.mapApprovalEntriesLevel3.values()[0] != null) {
                                            //ClsUtilsApexPages.addInfoMessage('Approval needed. Approver is: ' + this.mapApprovalEntriesLevel3.values()[0].TeamMemberRole);
                                            this.isRegionalApproval = true;
                                        }

                                    }if(!isRegionalApproval){
                                           // ClsUtilsApexPages.addInfoMessage('Approval needed. Approver is: ' + otm.TeamMemberRole);
                                            this.multiStageApprovalNeeded = true;
                                        }
                                }
                            }  else{
                                ClsUtilsApexPages.addErrorMessage(Label.No_Approver);
                                        this.displayError = true;
                                        lineItem.showError = true;
                                      return false;



                            }  

                        }

                    }
                   
                // validate percentage commission
                else {
                    // checks minimum commission value
                    if (ss.Commission_In_Percentage__c < servicePrice.Minimum_Commission_in_Percentage__c
                            && !servicePrice.Requires_Approval__c) {

                        String errorMsg = servicePrice.Maximum_Commission_In_Percentage__c == null
                                          ? Label.CommissionInPercentageNotLessThan + ' ' + servicePrice.Minimum_Commission_in_Percentage__c
                                          : Label.CommissionInPercentageRange + ' ' + servicePrice.Minimum_Commission_in_Percentage__c + ' & ' + servicePrice.Maximum_Commission_In_Percentage__c;
                        ClsUtilsApexPages.addErrorMessage(errorMsg);
                        lineItem.showError = true;
                        return false;
                    }

                    if (ss.Commission_In_Percentage__c > servicePrice.Maximum_Commission_In_Percentage__c) {
                        ClsUtilsApexPages.addErrorMessage(Label.CommissionInPercentageRange + ' ' + servicePrice.Minimum_Commission_in_Percentage__c + ' & ' + servicePrice.Maximum_Commission_In_Percentage__c);
                        lineItem.showError = true;
                        return false;
                    }

                    if (servicePrice.Requires_Approval__c
                            && ss.Commission_In_Percentage__c < servicePrice.Minimum_Commission_in_Percentage__c) {

                        if(this.mapOppTeam!=null && !this.mapOppTeam.isempty()){
                             if (!this.mapOppTeam.containskey('HOS') ) {
                                    ClsUtilsApexPages.addErrorMessage(Label.No_Approver);
                                    lineItem.showError = true;
                                      return false;
                                }else{
                                    this.mapApprovalEntriesLevel1=this.mapOppTeam.get('HOS');
                                    system.debug('**oppteam'+this.mapOppTeam);
                                   // system.debug('*this.mapApprovalEntriesLevel1'+this.mapApprovalEntriesLevel1);
                                    OpportunityTeamMember otm =this.mapApprovalEntriesLevel1.values()[0];
                                    this.mapApproval.put(otm.user.Email, otm.UserId);
                                    if (this.mapApprovalEntriesLevel1 != null && !this.mapApprovalEntriesLevel1.isEmpty() ) {
                                       // this.isRegionalApproval = false;                                    
                                        this.mapApproval.put(otm.user.Email, otm.UserId);
                                        this.multiStageApprovalNeeded = true;
                                        this.approvalLimits = LibBusinessConfig.determineApprover(this.opp.Record_Country__c,'HOS' );
                                        if(approvalLimits.ApprovalLimitForHOS__c != null && ss.Commission_In_Percentage__c < approvalLimits.ApprovalLimitForHOS__c && comissiontypeForReg.contains(ss.sub_type__c)){
                                            this.mapApprovalEntriesLevel3 = this.mapOppTeam.get('Regional HOS');
                                            if (this.mapApprovalEntriesLevel3 != null && !this.mapApprovalEntriesLevel3.values().isEmpty() && this.mapApprovalEntriesLevel3.values()[0] != null) {
                                                //ClsUtilsApexPages.addInfoMessage('Approval needed. Approver is: Regional HOS ');
                                                this.isRegionalApproval = true;
                                                this.displayError = true;
                                                
                                            }
                                        }if(!isRegionalApproval){
                                           // ClsUtilsApexPages.addInfoMessage('Approval needed. Approver is: ' + otm.TeamMemberRole);
                                            this.displayError = true;
                                        }            
                                    }
                                } 
                            }
                            else{
                                ClsUtilsApexPages.addErrorMessage(Label.No_Approver);
                                        this.displayError = true;
                                        lineItem.showError = true;
                                      return false;

                            }
                        }

                     }
                }
                
                
            
        }

        return true;
    }

    public Boolean validateProductItems() {
        resetErrorFalg();
        if (!this.productLineItems.isEmpty()) {
            for (LineItemWrapper lineItem : this.productLineItems) {
                if (lineItem.position != 0 && (lineItem.position != this.productLineItems.size() - 1)) {

                    if (lineItem.product.Quantity__c == null || lineItem.product.Quantity__c == 0) {

                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.MissingQuantity));
                        lineItem.showError = true;
                        return false;
                    }
                    if (/*!this.businessApprovalProcess &&*/ lineItem.product.Discount__c != null && lineItem.product.Discount__c != '' ) {
                        Decimal maximumDiscount = this.mapMaximumDiscount.get(lineItem.product.Id_List_Price_Product__c);
                        if (!validateMaximumDiscount(lineItem.product.Listed_Price__c, Integer.valueOf(lineItem.product.Quantity__c), maximumDiscount, lineItem.product.Discount__c, this.mapHasApproval.get(lineItem.product.Id_List_Price_Product__c))) {
                            lineItem.showError = true;
                            return false;
                        }
                    }

                    if (annualRenewalFeeCountrySet.contains(this.opp.Record_Country__c) && !this.mapProductType.isEmpty() && this.mapProductType.get(lineItem.product.Id_List_Price_Product__c) != null && this.mapProductType.get(lineItem.product.Id_List_Price_Product__c).equalsIgnoreCase('Renewal Fee') && this.annualRenewalInMonths != null) {
                        if (!this.serviceLineItems.isEmpty() && this.serviceLineItems.size() > 1 && this.serviceLineItems[1].service != null && this.serviceLineItems[1].service.Start_Date__c != null) {
                            Opportunity_Line_Item__c pp =  lineItem.product;
                            pp.Start_Date__c = this.serviceLineItems[1].service.Start_Date__c.addMonths(this.annualRenewalInMonths).addDays(-1);
                            lineItem.product = pp;

                        }
                    }

                }

            }
        }
        return true;
    }

    public Boolean validatePPProductItems() {
        resetErrorFalg();
        if (!this.ppProductLineItems.isEmpty()) {
            for (LineItemWrapper lineItem : this.ppProductLineItems) {
                if (lineItem.position != 0 && (lineItem.position != this.ppProductLineItems.size() - 1)) {
                    if (!this.mapProductType.isEmpty()  && this.mapProductType.get(lineItem.product.Id_List_Price_Product__c) != null && this.mapProductType.get(lineItem.product.Id_List_Price_Product__c).indexOf('Premium placement -') > -1 && lineItem.product.start_date__c == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.MandatoryStartDate));
                        lineItem.showError = true;
                        return false;
                    }
                    if (lineItem.product.Quantity__c == null || lineItem.product.Quantity__c == 0) {

                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.MissingQuantity));
                        lineItem.showError = true;
                        return false;
                    }
                    if (/*!this.businessApprovalProcess &&*/ lineItem.product.Discount__c != null && lineItem.product.Discount__c != '') {
                        Decimal maximumDiscount = this.mapMaximumDiscount.get(lineItem.product.Id_List_Price_Product__c);
                        if (!validateMaximumDiscount(lineItem.product.Listed_Price__c, Integer.valueOf(lineItem.product.Quantity__c), maximumDiscount, lineItem.product.Discount__c, this.mapHasApproval.get(this.selectedProductItem.Id_List_Price_Product__c))) {
                            lineItem.showError = true;
                            return false;
                        }
                    }
                }

            }
        }
        return true;
    }

    public Boolean validateDPProductItems() {
        resetErrorFalg();
        if (!this.dpProductLineItems.isEmpty()) {
            for (LineItemWrapper lineItem : this.dpProductLineItems) {
                //if( (lineItem.position == this.dpProductLineItems.size())){
                if (!this.mapProductType.isEmpty()  && this.mapProductType.get(lineItem.product.Id_List_Price_Product__c) != null &&  lineItem.product.start_date__c == null) {
                    lineItem.showError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.MandatoryStartDate));

                    return false;
                }
                if (!this.mapProductType.isEmpty()  && this.mapProductType.get(lineItem.product.Id_List_Price_Product__c) != null &&  lineItem.product.end_date__c == null) {
                    lineItem.showError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.MandatoryEndDate));

                    return false;
                }
                if (!this.mapProductType.isEmpty()  && this.mapProductType.get(lineItem.product.Id_List_Price_Product__c) != null &&  lineItem.product.discount__c == null) {
                    lineItem.showError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.MandatoryDiscount));
                    return false;


                }
                if (!this.mapProductType.isEmpty()  && this.mapProductType.get(lineItem.product.Id_List_Price_Product__c) == null ) {
                    lineItem.showError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.MandatoryPrice));

                    return false;
                }
                if (!this.mapProductType.isEmpty()  &&  lineItem.product.end_date__c != null &&   lineItem.product.start_date__c != null && lineItem.product.end_date__c < lineItem.product.start_date__c) {
                    lineItem.showError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.EndDateGreaterValidation));

                    return false;
                }

                //}
                break;
            }
        }
        return true;
    }

    

    private List<Opportunity_Line_Item__c> getListOfProductValuesFromWrapperMap() {
        List<Opportunity_Line_Item__c> listResult = new List<Opportunity_Line_Item__c>();
        List<LineItemWrapper> allProductLineItems = new List<LineItemWrapper>();
        allProductLineItems.addAll(this.productLineItems);
        allProductLineItems.addAll(this.recurringChargeLineItems);
        allProductLineItems.addAll(this.adSalesProductLineItems);
        allProductLineItems.addAll(this.flatProductLineItems);
        allProductLineItems.addAll(this.ppProductLineItems);
        allProductLineItems.addAll(this.mpProductLineItems);
        allProductLineItems.addAll(this.msProductLineItems);
        allProductLineItems.addAll(this.dpProductLineItems);
        for (LineItemWrapper lineItem : allProductLineItems) {
            listResult.add(lineItem.product);
        }
        return listResult;
    }

    private List<Opportunity_Line_Item__c> getListOfServiceValuesFromWrapperMap() {
        List<Opportunity_Line_Item__c> listResult = new List<Opportunity_Line_Item__c>();
        for (LineItemWrapper lineItem : this.serviceLineItems) {
            listResult.add(lineItem.service);
        }
        return listResult;
    }

    /* Set the subtotal for the products if any */
    /*private void setSubTotal(){
        if(!this.productLineItems.isEmpty()){
            for(LineItemWrapper lineItem : this.productLineItems){
                if(lineItem.lastRecord){
                    this.subTotal = lineItem.subTotalAmount;
                }
            }
        }

        System.debug('showFlatProductBlock: '+showFlatProductBlock+' this.flatProductLineItems.isEmpty(): '+this.flatProductLineItems.isEmpty());

        if(showAdSalesBlock && !this.adSalesProductLineItems.isEmpty() && this.adSalesProductLineItems.size()>1){
            for(LineItemWrapper lineItem : this.adSalesProductLineItems){
                if(lineItem.lastRecord){
                    this.subTotal = lineItem.subTotalAmount;
                }
            }
        }else if(showFlatProductBlock && !this.flatProductLineItems.isEmpty() && this.flatProductLineItems.size()>1){
            for(LineItemWrapper lineItem : this.flatProductLineItems){
                system.debug('lineItem: '+lineItem);
                if(lineItem.lastRecord){
                    this.subTotal = lineItem.subTotalAmount;
                }
            }
        }

    }*/

    public PageReference saveLineItems() {
        try {
            System.debug('$$$ saveLineItems called');
            if (!checkIfOpportunityIsLocked()) {
                //this.requiresApproval=false;
                //this.isRegionalApproval=false;
                if (this.validateServiceItems() && this.validateProductItems() && this.validateAdsalesProductItems() && this.validateFlatProductItems() && this.validatePPProductItems() && this.validateDPProductItems()) {
                    //this.setSubTotal(); // set the subtotal of the products before removing the last entry in the product line items list below
                    if(this.isRegionalApproval){
                         ClsUtilsApexPages.addInfoMessage('Approval needed. Approver is: Regional HOS');
                         

                    }else if(multiStageApprovalNeeded || requiresApproval){
                         ClsUtilsApexPages.addInfoMessage('Approval needed. Approver is: HOS');
                         
                    }
                    if (!this.serviceLineItems.isEmpty()) {
                        if (this.serviceLineItems[0].position == 0) {
                            this.serviceLineItems.remove(0);
                        }
                    }
                    if (!this.productLineItems.isEmpty()) {
                        this.productLineItems.remove(0);
                        if (this.productLineItems.size() > 0) {
                            this.productLineItems.remove(this.productLineItems.size() - 1);
                        }

                    }


                    if (this.recurringChargeLineItems.size() >= 1) {
                        this.recurringChargeLineItems.remove(0);
                    }
                    if (this.adSalesProductLineItems.size() >= 1) {
                        this.adSalesProductLineItems.remove(this.adSalesProductLineItems.size() - 1);
                    }
                    if (this.flatProductLineItems.size() >= 1) {
                        this.flatProductLineItems.remove(this.flatProductLineItems.size() - 1);
                    }

                    if (!this.ppProductLineItems.isEmpty()) {
                        this.ppProductLineItems.remove(0);
                        if (this.ppProductLineItems.size() > 0) {
                            this.ppProductLineItems.remove(this.ppProductLineItems.size() - 1);
                        }
                    }
                    if (!this.mpProductLineItems.isEmpty()) {
                        this.mpProductLineItems.remove(0);
                        if (this.mpProductLineItems.size() > 0) {
                            this.mpProductLineItems.remove(this.mpProductLineItems.size() - 1);
                        }
                    }
                    if (!this.msProductLineItems.isEmpty()) {
                        this.msProductLineItems.remove(0);
                        if (this.msProductLineItems.size() > 0) {
                            this.msProductLineItems.remove(this.msProductLineItems.size() - 1);
                        }
                    }
                    if (!this.dpProductLineItems.isEmpty()) {
                        //this.dpProductLineItems.remove(0);
                        if (this.dpProductLineItems.size() > 0) {
                            this.dpProductLineItems.remove(this.dpProductLineItems.size() - 1);
                        }
                    }

                    if (!this.showTieredBlock && this.mapBusinessData.get('usesServiceTypes') != null && (String.isNotBlank(this.mapBusinessData.get('usesServiceTypes').Business_Rule_Value__c) && this.mapBusinessData.get('usesServiceTypes').Business_Rule_Value__c != 'false')) {
                        if (!overlappingDisabledCountrySet.contains(this.opp.Record_Country__c)) {
                            if (servicesAreOverlapping(this.groupLineItemsByServiceType(this.getListOfServiceValuesFromWrapperMap()))) {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Line_Items_Same_Start_Date_for_Same_Service_Types));
                                return null;
                            }
                        }

                    }

                    List<Opportunity_Line_Item__c> listOppProdLines;
                    if (!this.productLineItems.isEmpty() || !this.recurringChargeLineItems.isEmpty() || !this.adSalesProductLineItems.isEmpty() || !this.flatProductLineItems.isEmpty() || !this.ppProductLineItems.isEmpty() || !this.mpProductLineItems.isEmpty() || !this.msProductLineItems.isEmpty() || !this.dpProductLineItems.isEmpty()) {
                        listOppProdLines = this.getListOfProductValuesFromWrapperMap();
                        upsert listOppProdLines;
                    }

                    List<Opportunity_Line_Item__c> listOppServLines;
                    if (!this.serviceLineItems.isEmpty()) {
                        if (this.showTieredBlock) {

                            listOppServLines = this.getListOfServiceValuesFromWrapperMap();
                        } else {
                            sortListWithoutUpsert();
                            //upsert this.getListOfServiceValuesFromWrapperMap();
                            listOppServLines = this.getListOfServiceValuesFromWrapperMap();
                            listOppServLines.remove(0);
                        }

                        system.debug('**&&listOppServLines' + listOppServLines);

                        upsert listOppServLines;
                    }
                    constructlineItemsForCancel(listOppProdLines, listOppServLines);
                    
                    for (Opportunity_Line_Item__c opi : [SELECT Id, Listed_Price__c, Id_List_Price_Product__r.Product_Name__c, Id_List_Price_Product__r.Product_Type__c FROM Opportunity_Line_Item__c WHERE Id_Opportunity__c = :this.opp.Id and Line_Item_Type__c = 'Product']) {
                        if (opi.Id_List_Price_Product__r.Product_Name__c.indexOf('Setup') != -1) {
                            this.opp.Set_Up_Fee__c = opi.Listed_Price__c;
                        }
                        if (opi.Id_List_Price_Product__r.Product_Type__c != null) {
                            if (opi.Id_List_Price_Product__r.Product_Type__c.equals('Menu Printing')) {
                                ClsQuoteProcessor cqp = new ClsQuoteProcessor();
                                List<Opportunity> opps = cqp.setDefaultValueForOpportunityQuoteComment(new List<Opportunity> {this.opp}, true);
                                this.opp.Quote_Comment_Menu_Printing__c = opps[0].Quote_Comment_Menu_Printing__c;
                            }
                        }
                    }
                    if (!this.showTieredBlock && this.mapBusinessData.get('usesServiceTypes') != null && (String.isNotBlank(this.mapBusinessData.get('usesServiceTypes').Business_Rule_Value__c) && this.mapBusinessData.get('usesServiceTypes').Business_Rule_Value__c != 'false')) {
                        this.opp.Main_Commission_Fee__c = this.mainCommissionFee;
                        this.opp.Main_Order_Transmission_Fee__c = this.mainOrderTransmissionFee;
                        this.opp.Main_Online_Payment_Fee__c = this.mainOnlinePaymentFee;
                        //comment below line for the deployment
                        //this.opp.Main_Fixed_Amount__c = this.mainFixedAmount;
                    }
                    
                    update this.opp;
                    
                    if (!this.listDeleteOppLineItems.isEmpty())
                        delete this.listDeleteOppLineItems;
                    
                    this.listDeleteOppLineItems.clear();
                    //this.availableForQuote = true;
                    if (!this.useCombinedSaveAndCreateQuote) {
                        this.availableForQuote = true;
                    }
                } else {
                    return null;
                }
                ClsRemoteController.updateOpportunityType(this.opp.id);
            }
        } catch (Exception e) {
            if (e.getMessage().contains('ACCESS_OR_READONLY') || e.getMessage().contains('ACCESS_ON_CROSS_REFERENCE')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.Cant_edit_opportunity));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, e.getMessage()));
            }

            return null;
        }
        return null;
    }

    private void constructlineItemsForCancel(List<Opportunity_Line_Item__c> prodLines, List<Opportunity_Line_Item__c> servLines) {
        if (prodLines != null && !prodLines.isEmpty()) {
            this.productLineItems.clear();
            this.recurringChargeLineItems.clear();
            this.adSalesProductLineItems.clear();
            this.flatProductLineItems.clear();
            this.ppProductLineItems.clear();
            this.mpProductLineItems.clear();
            this.msProductLineItems.clear();
            this.dpProductLineItems.clear();
            Integer recurringFeeCount = 0;
            Integer productCount = 0;
            Integer adSalesCount = 0;
            Integer flatProductCount = 0;
            Integer ppProductCount = 0;
            Integer mpProductCount = 0;
            Integer msProductCount = 0;
            Integer dpProductCount = 0;
            this.subTotal = 0;
            this.requiresApproval=false;
            this.selectedProductLineItem = '--';
            this.productLineItems.add(new LineItemWrapper(new Opportunity_Line_Item__c(Quantity__c = 0, Total_Amount__c = 0, Discount__c = '0'), false, 0, 'Product'));

            if (this.usesRecurringCharges) {
                this.recurringChargeLineItems.add(new LineItemWrapper(new Opportunity_Line_Item__c(), false, 0, 'Product'));
            }

            for (Integer i = 0; i < prodLines.size(); i++) {

                /*if(this.recuringChargesMap.get(prodLines[i].Id_List_Price_Product__c) == null && prodLines[i].Ad_Sales_Type__c==null && prodLines[i].API_Type__c==null){
                    LineItemWrapper lineItem = new LineItemWrapper(prodLines[i], false, productCount+1,'Product');
                    this.subTotal += lineItem.product.Total_Amount__c != null ? lineItem.product.Total_Amount__c : 0;
                    this.productLineItems.add(lineItem);
                    productCount++;
                }

                if(this.recuringChargesMap.get(prodLines[i].Id_List_Price_Product__c) != null && prodLines[i].Ad_Sales_Type__c==null && prodLines[i].API_Type__c==null){
                    this.recurringChargeLineItems.add(new LineItemWrapper(prodLines[i], false, this.recurringChargeLineItems.size() + recurringFeeCount,'Product'));
                    recurringFeeCount++;
                }*/

                if (/*prodLines[i].Ad_Sales_Type__c!=null*/ prodLines[i].sub_type__c == 'Ad Sales' ) {
                    LineItemWrapper lineItem = new LineItemWrapper(prodLines[i], false, adSalesCount, 'Product');
                    this.subTotal += lineItem.product.Total_Amount__c != null ? lineItem.product.Total_Amount__c : 0;
                    this.adSalesProductLineItems.add(lineItem);
                    adSalesCount++;
                } else if (/*prodLines[i].API_Type__c!=null && prodLines[i].API_Type__c=='Flat Commission'*/ prodLines[i].sub_type__c == 'Flat Commission') {
                    LineItemWrapper lineItem = new LineItemWrapper(prodLines[i], false, flatProductCount, 'Product');
                    this.subTotal += lineItem.product.Total_Amount__c != null ? lineItem.product.Total_Amount__c : 0;
                    this.flatProductLineItems.add(lineItem);
                    flatProductCount++;
                } else if (/*prodLines[i].API_Type__c!=null && prodLines[i].API_Type__c=='Premium Placement'*/prodLines[i].sub_type__c != null && prodLines[i].sub_type__c == 'Premium Placement') {
                    if (this.ppProductLineItems.isEmpty()) {
                        this.ppProductLineItems.add(new LineItemWrapper(new Opportunity_Line_Item__c(Quantity__c = 0, Total_Amount__c = 0, Discount__c = '0'), false, 0, 'Product'));
                    }
                    LineItemWrapper lineItem = new LineItemWrapper(prodLines[i], false, ppProductCount + 1, 'Product');
                    this.subTotal += lineItem.product.Total_Amount__c != null ? lineItem.product.Total_Amount__c : 0;
                    this.ppProductLineItems.add(lineItem);
                    ppProductCount++;
                } else if (/*prodLines[i].API_Type__c!=null && prodLines[i].API_Type__c=='Premium Placement'*/prodLines[i].sub_type__c != null && prodLines[i].sub_type__c == 'Menu Printing' && this.mptarif != null) {
                    if (this.mpProductLineItems.isEmpty()) {
                        this.mpProductLineItems.add(new LineItemWrapper(new Opportunity_Line_Item__c(Quantity__c = 1, Total_Amount__c = 0, Discount__c = '0'), false, 0, 'Product'));
                    }
                    LineItemWrapper lineItem = new LineItemWrapper(prodLines[i], false, mpProductCount + 1, 'Product');
                    this.subTotal += lineItem.product.Total_Amount__c != null ? lineItem.product.Total_Amount__c : 0;
                    this.mpProductLineItems.add(lineItem);
                    mpProductCount++;
                } else if (prodLines[i].sub_type__c != null && !marketingShippingProdTypes.isEmpty() && marketingShippingProdTypes.contains(prodLines[i].sub_type__c) && this.mstarif != null) {
                    if (this.msProductLineItems.isEmpty()) {
                        this.msProductLineItems.add(new LineItemWrapper(new Opportunity_Line_Item__c(Quantity__c = 1, Total_Amount__c = 0, Discount__c = '0'), false, 0, 'Product'));
                    }
                    LineItemWrapper lineItem = new LineItemWrapper(prodLines[i], false, msProductCount + 1, 'Product');
                    this.subTotal += lineItem.product.Total_Amount__c != null ? lineItem.product.Total_Amount__c : 0;
                    this.msProductLineItems.add(lineItem);
                    msProductCount++;
                } else if (prodLines[i].sub_type__c != null && !designProductTypes.isEmpty() && designProductTypes.contains(prodLines[i].sub_type__c) && this.dptarif != null) {
                    if (this.dpProductLineItems.isEmpty()) {
                        // this.dpProductLineItems.add(new LineItemWrapper(new Opportunity_Line_Item__c(Quantity__c = 1, Total_Amount__c = 0, Discount__c = '0'), false, 0,'Product'));
                    }
                    LineItemWrapper lineItem = new LineItemWrapper(prodLines[i], false, dpProductCount + 1, 'Product');
                    this.subTotal += lineItem.product.Total_Amount__c != null ? lineItem.product.Total_Amount__c : 0;
                    this.dpProductLineItems.add(lineItem);
                    dpProductCount++;
                }

                else {
                    if (this.recuringChargesMap.get(prodLines[i].Id_List_Price_Product__c) == null &&  (prodLines[i].sub_type__c == null || (prodLines[i].sub_type__c != null && prodLines[i].sub_type__c != 'Ad Sales' && prodLines[i].sub_type__c != 'Flat Commission' && prodLines[i].sub_type__c != 'Premium Placement'))) {
                        LineItemWrapper lineItem = new LineItemWrapper(prodLines[i], false, productCount + 1, 'Product');
                        this.subTotal += lineItem.product.Total_Amount__c != null ? lineItem.product.Total_Amount__c : 0;
                        this.productLineItems.add(lineItem);
                        productCount++;
                    }

                    if (this.recuringChargesMap.get(prodLines[i].Id_List_Price_Product__c) != null && prodLines[i].sub_type__c != 'Ad Sales' && prodLines[i].sub_type__c != 'Flat Commission' && prodLines[i].sub_type__c == 'Premium Placement'/*&& prodLines[i].Ad_Sales_Type__c==null && prodLines[i].API_Type__c==null*/) {
                        this.recurringChargeLineItems.add(new LineItemWrapper(prodLines[i], false, this.recurringChargeLineItems.size() + recurringFeeCount, 'Product'));
                        recurringFeeCount++;
                    }


                }
            }

            if (this.productLineItems.size() > 1) {
                //calculateVat();
                this.productLineItems.add(new LineItemWrapper(this.subTotal, this.productLineItems.size()));
            }
            if (this.ppProductLineItems.size() > 1) {
                //calculateVat();
                this.ppProductLineItems.add(new LineItemWrapper(this.subTotal, this.ppProductLineItems.size()));
            }
            if (this.mpProductLineItems.size() > 1) {
                //calculateVat();
                system.debug('##this.mpProductLineItems.size()' + this.mpProductLineItems.size());
                this.mpProductLineItems.add(new LineItemWrapper(this.subTotal, this.mpProductLineItems.size()));
            }
            if (this.msProductLineItems.size() > 1) {
                system.debug('##this.msProductLineItems.size()' + this.msProductLineItems.size());
                this.msProductLineItems.add(new LineItemWrapper(this.subTotal, this.msProductLineItems.size()));
            } if (this.dpProductLineItems.size() >= 1) {
                system.debug('##this.dpProductLineItems.size()' + this.dpProductLineItems.size());
                this.dpProductLineItems.add(new LineItemWrapper(this.subTotal, this.dpProductLineItems.size()));
            }
            if (this.adSalesProductLineItems.size() > 1) {
                //calculateVat();
                this.adSalesProductLineItems.add(new LineItemWrapper(this.subTotal, this.adSalesProductLineItems.size()));
            }
            if (this.flatProductLineItems.size() > 1) {
                //calculateVat();
                this.flatProductLineItems.add(new LineItemWrapper(this.subTotal, this.flatProductLineItems.size()));
            }

        } else {
            this.productLineItems.clear();
            this.recurringChargeLineItems.clear();
            this.productLineItems.add(new LineItemWrapper(new Opportunity_Line_Item__c(Quantity__c = 0, Total_Amount__c = 0, Discount__c = '0'), false, 0, 'Product'));

            if (this.usesRecurringCharges) {
                this.recurringChargeLineItems.add(new LineItemWrapper(new Opportunity_Line_Item__c(), false, 0, 'Product'));
            }

            this.productLineItems.add(new LineItemWrapper(0, this.productLineItems.size()));
        }
        if (servLines != null && !servLines.isEmpty()) {
            this.serviceLineItems.clear();
            if (!this.showTieredBlock) {
                this.serviceLineItems.add(new LineItemWrapper(new Opportunity_Line_Item__c(), false, 0, 'Service'));
            }
            for (Integer i = 0; i < servLines.size(); i++) {
                //System.debug('servLines[i]: '+servLines[i].Commission_Per_Order__c+' ,+servLines[i].Commission_In_Percentage__c: '+servLines[i].Commission_In_Percentage__c);
                LineItemWrapper lineItem = new LineItemWrapper(servLines[i], false, i + 1, 'Service');
                this.serviceLineItems.add(lineItem);
            }
        } else {
            this.serviceLineItems.clear();
            if (!this.showTieredBlock) {
                this.serviceLineItems.add(new LineItemWrapper(new Opportunity_Line_Item__c(), false, 0, 'Service'));
            }
        }

    }

    //this initializes the quote process for the opportunity
    /* changes: check if quote approval comments section should be shown.
        for ME approval flow
    */
    public void showQuotePage() {
        system.debug('###showQuotePAge');
        if (this.opportunityCompany == 'DH_AU') {
            if (this.opp.Account.Invoice_Frequency__c != null && this.opp.Account.Invoice_Frequency__c != '') {
                showQuotePageExt();
            } else {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Invoice Frequency is not yet set.'); //Same old drama
                ApexPages.addMessage(myMsg);
            }
        } else {
            showQuotePageExt();

        }

    }

    public void showQuotePageForAPIPP() {
        this.opp = [select  Id, SubTotalRF__c, Total_fm__c, VAT_fm__c, CurrencyIsoCode, accountId, StageName, Probability, 
        			Quote_Comment__c, Quote_Comment_Menu_Printing__c, Record_Country__c, RecordTypeId, 
        			Account.Backend_ID__c, Account.Invoice_Frequency__c,account.recordType.developerName
                    from Opportunity where Id = :this.opp.Id];
        showQuotePage();
    }

    public void showQuotePageExt() {
        //InitiateQuote();
        InitiateQuoteData();
        
        this.showProductSection = false;
        //showNonStandardContractComponentsSection

        if (this.mapBusinessData.get('showNonStandardContractComponentsSection') != null &&  String.isNotBlank(this.mapBusinessData.get('showNonStandardContractComponentsSection').Business_Rule_Value__c)) {
            this.showNonStandardContractComponentsSection = Boolean.valueOf(this.mapBusinessData.get('showNonStandardContractComponentsSection').Business_Rule_Value__c);
            this.showQuoteSection = false;
        }

        if (this.mapBusinessData.get('showNonStandardContractTerms') != null && String.isNotBlank(this.mapBusinessData.get('showNonStandardContractTerms').Business_Rule_Value__c)) {
            showNonStandardContractTerms = Boolean.valueOf(this.mapBusinessData.get('showNonStandardContractTerms').Business_Rule_Value__c);
        }
        //change for ME approval flow v6.0: comments section shall appear every time
        if (this.mapBusinessData.get('showApprovalCommentsSection') != null &&  String.isNotBlank(this.mapBusinessData.get('showApprovalCommentsSection').Business_Rule_Value__c) /*&& this.multiStageApprovalNeeded*/) {
            this.showApprovalCommentsSection = Boolean.valueOf(this.mapBusinessData.get('showApprovalCommentsSection').Business_Rule_Value__c);
            this.showQuoteSection = false;
        }
        this.openSubTAbForQuote = false;
        if (!this.showNonStandardContractComponentsSection && !this.showQuoteSection && !showNonStandardContractTerms) {
            saveQuoteData();
            this.openSubTAbForQuote = true;
        }
    }

    public void saveLineItemsAndShowQuotePage() {
        if (!(this.showFlatProductBlock || this.showAdSalesBlock ||  this.showMPBlock || this.showMSBlock || this.showDPBlock) && this.productLineItems.size() <= 2 && this.serviceLineItems.size() <= 1 ) {
            if ( this.ppProductLineItems.size() <= 2) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Quote_validation_product_and_service));
                return;
            }
        }
        if (this.showPPBlock && this.ppProductLineItems.size() <= 2) {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Quote_validation_product_and_service));
            return;
        }
        if (this.showmPBlock && this.mpProductLineItems.size() <= 2) {
            system.debug('##2this.mpProductLineItems.size()' + this.mpProductLineItems.size());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Quote_validation_product_and_service));
            return;
        } else if (this.showMSBlock && this.msProductLineItems.size() <= 2) {
            system.debug('##2this.msProductLineItems.size()' + this.msProductLineItems.size());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Quote_validation_product_and_service));
            return;
        } else if (this.showDPBlock && this.dpProductLineItems.size() <= 1) {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Quote_validation_product_and_service));
            return;
        }
        saveLineItems();
        if (checkForError()) {
            return;

        }

        else
            showQuotePage();
    }

    public void cancelShowQuote() {
        this.showProductSection = true;
        this.showQuoteSection = false;
        this.showQuoteSectionError = false;
        this.showApprovalCommentsSection = false;
        showNonStandardContractComponentsSection = false;
        this.requiresApproval=false;
        this.isRegionalApproval=false;
        this.multiStageApprovalNeeded=false;
    }

    @TestVisible
    private Boolean isPickValueAdded = false;
    @TestVisible
    private Boolean isPickValueRegitrationAdded = false;
    @TestVisible
    private Boolean isPickValueRenewalAdded = false;

    public void addNonstandardcontract() {
        if (this.oppQuote.Non_Standard_Contract_Components__c == null) {
            if (isPickValueAdded || isPickValueRegitrationAdded || isPickValueRenewalAdded) {
                this.oppQuote.Non_Standard_Contract_Terms__c = null;
                isPickValueAdded = false;
                isPickValueRegitrationAdded = false;
                isPickValueRenewalAdded = false;
            }

        } else if (this.oppQuote.Non_Standard_Contract_Components__c != null) {
            if (this.nonStandardPicKValue != null) {
                String talabatnonCon = Label.Talabat_non_standard_contract.replace('{accName}', this.accountName).replace('{currCode}', this.oppQuote.CurrencyIsoCode);
                system.debug('%%' + this.ExclusiveCommission);
                String CDPlatformExcl = Label.CD_Platform_Exclusivity.replace('xx', String.valueof(this.ExclusiveCommission));
                if (this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase(this.nonStandardPicKValue) && !isPickValueAdded && OppQuote.recordtypeid == LibRecordTypeHelper.getRecordTypeValue('Talabat_Opportunity_Quote')) {
                    isPickValueAdded = true;
                    if (this.oppQuote.Non_Standard_Contract_Terms__c != null) {
                        this.oppQuote.Non_Standard_Contract_Terms__c = this.oppQuote.Non_Standard_Contract_Terms__c + '\n' + talabatnonCon;
                    } else {
                        this.oppQuote.Non_Standard_Contract_Terms__c = talabatnonCon;
                    }


                } else if (!this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase(this.nonStandardPicKValue) && isPickValueAdded && OppQuote.recordtypeid == LibRecordTypeHelper.getRecordTypeValue('Talabat_Opportunity_Quote')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = null;
                    isPickValueAdded = false;
                }

                if (this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase(this.nonStandardPicKValue) && !isPickValueAdded && OppQuote.recordtypeid == LibRecordTypeHelper.getRecordTypeValue('UK_Opportunity_Quote')) {
                    isPickValueAdded = true;
                    if (this.oppQuote.Non_Standard_Contract_Terms__c != null) {
                        this.oppQuote.Non_Standard_Contract_Terms__c = this.oppQuote.Non_Standard_Contract_Terms__c + '\n' + Label.UK_Special_Offer;
                    } else {
                        this.oppQuote.Non_Standard_Contract_Terms__c = Label.UK_Special_Offer;
                    }

                } else if (this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase(this.nonStandardPicKValue) && !isPickValueAdded && OppQuote.recordtypeid == LibRecordTypeHelper.getRecordTypeValue('CD_Opportunity_Quote')) {
                    isPickValueAdded = true;
                    if (this.oppQuote.Non_Standard_Contract_Terms__c != null) {
                        this.oppQuote.Non_Standard_Contract_Terms__c = this.oppQuote.Non_Standard_Contract_Terms__c + '\n' + CDPlatformExcl;
                    } else {
                        this.oppQuote.Non_Standard_Contract_Terms__c = CDPlatformExcl;
                    }

                } else if (!this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase(this.nonStandardPicKValue) && isPickValueAdded && OppQuote.recordtypeid == LibRecordTypeHelper.getRecordTypeValue('Talabat_Opportunity_Quote')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = null;
                    isPickValueAdded = false;
                }
            }if (  /*!isPickValueAdded &&*/ OppQuote.recordtypeid == LibRecordTypeHelper.getRecordTypeValue('Talabat_Opportunity_Quote')) {
                isPickValueAdded = true;
                this.oppQuote.Non_Standard_Contract_Terms__c='';
                
                if (this.oppQuote.Non_Standard_Contract_Terms__c != null && this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase('Exclusivity: KSP Lite')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = this.oppQuote.Non_Standard_Contract_Terms__c + '\n' + Label.TLB_Excl_KSP_Lite;
                } else if (this.oppQuote.Non_Standard_Contract_Terms__c == null && this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase('Exclusivity: KSP Lite')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = Label.TLB_Excl_KSP_Lite;
                }
                if (this.oppQuote.Non_Standard_Contract_Terms__c != null && this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase('Exclusivity: KSP Classic')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = this.oppQuote.Non_Standard_Contract_Terms__c + '\n' +Label.TLB_Excl_KSP_Lite+'\n'+ Label.TLB_Excl_KSP_Classic;
                } else if (this.oppQuote.Non_Standard_Contract_Terms__c == null && this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase('Exclusivity: KSP Classic')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = Label.TLB_Excl_KSP_Lite+'\n'+Label.TLB_Excl_KSP_Classic;
                }
                if (this.oppQuote.Non_Standard_Contract_Terms__c != null && this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase('Exclusivity: KSP+')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = this.oppQuote.Non_Standard_Contract_Terms__c + '\n' +Label.TLB_Excl_KSP_Lite+'\n'+ Label.TLB_Excl_KSP;
                } else if (this.oppQuote.Non_Standard_Contract_Terms__c == null && this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase('Exclusivity: KSP+')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = Label.TLB_Excl_KSP_Lite+'\n'+Label.TLB_Excl_KSP;
                }
                if (this.oppQuote.Non_Standard_Contract_Terms__c != null && this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase('Exclusivity: KSP PGA')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = this.oppQuote.Non_Standard_Contract_Terms__c + '\n' + Label.TLB_Excl_KSP_Lite+'\n'+ Label.TLB_Exc_KSP_PGA;
                } else if (this.oppQuote.Non_Standard_Contract_Terms__c == null && this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase('Exclusivity: KSP PGA')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = Label.TLB_Exc_KSP_PGA;
                }
                if (this.oppQuote.Non_Standard_Contract_Terms__c != null && this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase('Cancellation Reimbursement')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = this.oppQuote.Non_Standard_Contract_Terms__c + '\n\n' + Label.Talabat_Cancellation_reimbursement;
                } else if (this.oppQuote.Non_Standard_Contract_Terms__c == null && this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase('Cancellation Reimbursement')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = Label.Talabat_Cancellation_reimbursement;
                }


            }
            if (  /*!isPickValueAdded &&*/ OppQuote.recordtypeid == LibRecordTypeHelper.getRecordTypeValue('AT_Opportunity_Quote')) {
                isPickValueAdded = true;
                this.oppQuote.Non_Standard_Contract_Terms__c='';
                String backendId = '';
                if (this.opp.Account.Backend_ID__c != null) {
                    backendId = this.opp.Account.Backend_ID__c;
                }

                //String austrianonCon = Label.+'';
                if (this.oppQuote.Non_Standard_Contract_Terms__c != null && this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase('Partial prepayment')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = this.oppQuote.Non_Standard_Contract_Terms__c + '\n' + Label.AT_Anzahlung.replace('$Backend-ID$', backendId ) + '\n\n' + LAbel.AT_Note;
                } else if (this.oppQuote.Non_Standard_Contract_Terms__c == null && this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase('Partial prepayment')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = Label.AT_Anzahlung.replace('$Backend-ID$', backendId) + '\n\n' + LAbel.AT_Note;
                }
                if (this.oppQuote.Non_Standard_Contract_Terms__c != null && this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase('Settlement')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = this.oppQuote.Non_Standard_Contract_Terms__c + '\n' + Label.AT_Verrechnung;
                } else if (this.oppQuote.Non_Standard_Contract_Terms__c == null && this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase('Settlement')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = Label.AT_Verrechnung;
                }
                if (this.oppQuote.Non_Standard_Contract_Terms__c != null && this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase('Cash before delivery')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = this.oppQuote.Non_Standard_Contract_Terms__c + '\n' + Label.AT_Vorauskasse.replace('$Backend-ID$', backendId ) + '\n\n' + LAbel.AT_Note;
                } else if (this.oppQuote.Non_Standard_Contract_Terms__c == null && this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase('Cash before delivery')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = Label.AT_Vorauskasse.replace('$Backend-ID$', backendId  ) + '\n\n' + LAbel.AT_Note;
                }
                if (this.oppQuote.Non_Standard_Contract_Terms__c != null && this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase('Mjam Web')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = this.oppQuote.Non_Standard_Contract_Terms__c + '\n\n' + Label.AT_MjamWeb;
                } else if (this.oppQuote.Non_Standard_Contract_Terms__c == null && this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase('Mjam Web')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = Label.AT_MjamWeb;
                }
                if (this.oppQuote.Non_Standard_Contract_Terms__c != null && this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase('Menu Flyer Terms')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = this.oppQuote.Non_Standard_Contract_Terms__c + '\n\n' + Label.AT_Menu_Flyer_Terms;
                } else if (this.oppQuote.Non_Standard_Contract_Terms__c == null && this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase('Menu Flyer Terms')) {
                    this.oppQuote.Non_Standard_Contract_Terms__c = Label.AT_Menu_Flyer_Terms;
                }


            }
            
        }
    }

    //new changes for quote

    public void InitiateQuoteData() {
        system.debug('InitiateQuoteData');
        this.mapExistingLineItems = new Map<Id, Opportunity_Quote_Line_Item__c>();
        //this.mapExistingServices = new Map<Id,Opportunity_Quote_Line_Item__c>();
        this.emailError = false;
        this.oppQuote = new Opportunity_Quote__c();
        this.oppQuote.id_tarif__c = this.opp.Id_Tarif__c;

        //this.oppQuote.recordtypeId = recordTypesByDevNameMap.get(this.opportunityCompany + '_Opportunity_Quote').Id;
        this.oppQuote.recordtypeId = LibRecordTypeHelper.getRecordTypeValue(this.opportunityCompany + '_Opportunity_Quote');
        
        this.oppQuote.Id_Opportunity__c = this.opp.Id;
        this.oppQuote.CurrencyIsoCode = this.opp.CurrencyIsoCode;
        this.oppQuote.status__c = 'Draft';
        this.oppQuote.Id_Account__c = this.opp.accountId;
        //this.listContact = new List<OpportunityContactRole>();
        if (this.mapApproval != null && !this.mapApproval.isEmpty()) {

            if (this.multiStageApprovalNeeded && !this.isRegionalApproval) {
                if (this.mapApprovalEntriesLevel1 != null && !this.mapApprovalEntriesLevel1.isEmpty()) {
                    //System.debug('$$$ initiateQuote: setting Apporval_L1 to true');
                    this.oppQuote.Approval_L1__c = true;
                    //System.debug('$$$ initiateQuote: Apporval_L1 : ' + this.oppQuote.Approval_L1__c);
                }
            }
        }

        this.requiresApproval = false;



        for (Opportunity_Line_Item__c existingProduct :
                [
                    SELECT
                    Id_Opportunity__c,
                    OldOppQuoteLineId__c,
                    Name,
                    Listed_Price__c,
                    Quantity__c,
                    Id_List_Price_Product__c,
                    Id_List_Price_Product__r.Product_Type__c,
                    Id_List_Price_Product__r.requires_add_on__c,
                    Id_List_Price_Product__r.Unapproved_Discount_Limit__c,
                    Total_Amount__c,
                    Product_Group__c,
                    Discount__c,
                    Installments__c,
                    Has_Related_Tarif__c,
                    Category__c,
                    Line_Item_Type__c,
                    Category_Id__c,
                    District__c,
                    District_Id__c,
                    City_ZipCode__c,
                    Commission_In_Percentage__c,
                    Commission_Per_Order__c,
                    Commission_Type__c,
                    End_Date__c,
                    Start_Date__c,
                    Recurring_Fee__c,
                    Sub_Type__c,
                    Id_List_Service_Price__c,
                    Id_List_Service_Price__r.Minimum_Commission_in_Percentage__c,
                    Id_List_Service_Price__r.Maximum_Commission_in_Percentage__c,
                    Id_List_Service_Price__r.Minimum_Commission_per_order__c,
                    Id_List_Service_Price__r.Maximum_Commission_per_order__c,
                    Position__c,
                    Position_fm__c,
                    Booking_Api_Id__c,
                    deposit__c,
                    deposit_method__c,
                    Size__c,
                    Weight__c,
                    Number_of_Copies__c,
                    Design_Note__c,
                    Min__c,
                    Max__c,
                    index__c,
                    IsTiered__c,
                    online_payment_fee__c,
                    subsidy__c
                    FROM Opportunity_Line_Item__c
                    WHERE Id_Opportunity__c = : this.opp.Id
                ]) {
            String recType = LibRecordTypeHelper.getRecordTypeValue(this.opportunityCompany + '_Opportunity_Quote_Line_Item');
            if (existingProduct.Line_Item_Type__c == 'Product') {
                if (/*this.businessApprovalProcess &&*/ existingProduct.Id_List_Price_Product__r.requires_add_on__c && !this.requiresApproval && (existingProduct.Listed_Price__c != null && existingProduct.Id_List_Price_Product__r.Unapproved_Discount_Limit__c != null && String.isNotBlank(existingProduct.Discount__c))) {
                    this.requiresApproval = isSoftLimitDiscountViolated(existingProduct.Listed_Price__c, existingProduct.Quantity__c, existingProduct.Id_List_Price_Product__r.Unapproved_Discount_Limit__c, existingProduct.Discount__c);
                }
                


            }
            system.debug(this.requiresApproval);
            system.debug(this.displayError);
            if (this.requiresApproval && !this.displayError) {
                this.mapApprovalEntriesLevel1 = this.mapOppTeam.get('HOS');
                system.debug('ApprovalMap&&'+this.mapOppTeam);
                if (this.mapApprovalEntriesLevel1 != null && !this.mapApprovalEntriesLevel1.isEmpty()) {
                    OpportunityTeamMember approvalEntry = this.mapApprovalEntriesLevel1.values()[0];
                    this.mapApproval.put(approvalEntry.user.Email, approvalEntry.UserId);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Approval needed. Approver is: ' + approvalEntry.TeamMemberRole));

                }else{
                    ClsUtilsApexPages.addErrorMessage(Label.No_Approver);
                                        this.displayError = true;
                                        return;
                                      
                }
            }

            this.mapExistingLineItems.put(existingProduct.id, new Opportunity_Quote_Line_Item__c(name = existingProduct.name, OldOppQuoteLineId__c = existingProduct.OldOppQuoteLineId__c, Id_List_Product_Price__c = existingProduct.Id_List_Price_Product__c, Listed_Price__c = existingProduct.Listed_Price__c, Quantity__c = existingProduct.Quantity__c, Min__c = existingProduct.Min__c, Max__c = existingProduct.Max__c, index__c = existingProduct.index__c, IsTiered__c = existingProduct.IsTiered__c,
                                          Total_Amount__c = existingProduct.Total_Amount__c, Id_Opportunity__c = existingProduct.Id_Opportunity__c, Id_List_Service_Price__c = existingProduct.Id_List_Service_Price__c, Product_Group__c = existingProduct.Product_Group__c, discount__c = existingProduct.Discount__c, Installments__c = existingProduct.Installments__c, Has_Related_Tarif__c = existingProduct.Has_Related_Tarif__c, Line_Item_Type__c = existingProduct.line_item_type__c, sub_type__c = existingProduct.sub_type__c, online_payment_fee__c = existingProduct.Online_Payment_Fee__c,
                                          recordtypeId = recType, CurrencyIsoCode = this.opp.CurrencyIsoCode, Commission_In_Percentage__c = existingProduct.Commission_In_Percentage__c, Commission_Per_Order__c = existingProduct.Commission_Per_Order__c, Recurring_Fee__c = existingProduct.Recurring_Fee__c, Category__c = existingProduct.Category__c, Category_Id__c = existingProduct.Category_Id__c, District__c = existingProduct.District__c, District_Id__c = existingProduct.District_Id__c, Start_Date__c = existingProduct.Start_Date__c, End_Date__c = existingProduct.End_Date__c, City_ZipCode__c = existingProduct.City_ZipCode__c, design_note__c = existingProduct.design_note__c, Number_of_Copies__c = existingProduct.Number_of_Copies__c, Size__c = existingProduct.Size__c, weight__c = existingProduct.weight__c, deposit__c = existingProduct.deposit__c, deposit_method__c = existingProduct.deposit_method__c, subsidy__c = existingProduct.subsidy__c));
        }


    }

    public Boolean saveQuoteData() {
        Boolean noApprover =false;
        ClsQuoteProcessor cqp1 = new ClsQuoteProcessor(this.opp, this.oppQuote,opp.account.RecordType.developerName, this.mapExistingLineItems.values());
        this.oppQuote.Template_Name__c = cqp1.vfTemplateName;
        if (!this.requiresApproval) {
            this.oppQuote.Status__c = 'Approved';
        }
        if (this.skipAutoApprovalQuote) {
            this.oppQuote.Status__c = 'Draft';
        }

        if (this.mapBusinessData.get('initialApprovalStatus') != null && (this.multiStageApprovalNeeded || this.requiresApproval) && !this.isRegionalApproval) {
            this.oppQuote.Status__c = this.mapBusinessData.get('initialApprovalStatus').Business_Rule_Value__c;

        }if(this.isRegionalApproval){
            this.oppQuote.Status__c = this.mapBusinessData.get('initialApprovalStatusLevel3').Business_Rule_Value__c;
        }

        if (this.mapBusinessData.get('pushStageNameAfterInitialApprovalEntry') != null && (this.multiStageApprovalNeeded || this.requiresApproval)) {
            this.opp.StageName = this.mapBusinessData.get('pushStageNameAfterInitialApprovalEntry').Business_Rule_Value__c;
            //update this.opp;
        }
        if (this.mapBusinessData.get('noViolationQuoteStatus') != null && !this.multiStageApprovalNeeded && !this.requiresApproval && !this.isRegionalApproval) {
            this.oppQuote.Status__c = this.mapBusinessData.get('noViolationQuoteStatus').Business_Rule_Value__c;
            //update this.opp;
        }
        //SP-707
        Set<String> setApprovalExceptions = new Set<String>();
        Set<String> setNonStandardComponents;
        if (this.mapBusinessData.get('skipApprovalForTheseNonStandardComponents') != null && this.oppQuote.Non_Standard_Contract_Components__c != null) {
            if (this.oppQuote.Non_Standard_Contract_Components__c.indexOf(';') > 0) {

                setNonStandardComponents = new Set<String>(this.oppQuote.Non_Standard_Contract_Components__c.split(';'));
                //System.debug('$$$ setNonStandardComponents index hit this.oppQuote'+setNonStandardComponents);
            } else {
                //System.debug('$$$ this.oppQuote.Non_Standard_Contract_Components__c ' + this.oppQuote.Non_Standard_Contract_Components__c);
                setNonStandardComponents = new Set<String>();
                setNonStandardComponents.add(this.oppQuote.Non_Standard_Contract_Components__c);
                //System.debug('$$$ setNonStandardComponents one value this.oppQuote'+setNonStandardComponents);
            }

            if (this.mapBusinessData.get('skipApprovalForTheseNonStandardComponents').Business_Rule_Value__c.indexOf(',') > 0) {
                setApprovalExceptions = new Set<String>(this.mapBusinessData.get('skipApprovalForTheseNonStandardComponents').Business_Rule_Value__c.split(','));
                //System.debug('$$$ setApprovalExceptions index hit bc'+setApprovalExceptions);
            } else {
                setApprovalExceptions = new Set<String>();
                setApprovalExceptions.add(this.mapBusinessData.get('skipApprovalForTheseNonStandardComponents').Business_Rule_Value__c);
                //System.debug('$$$ setApprovalExceptions one value bc'+setApprovalExceptions);
            }

        }



        if (this.oppQuote.Non_Standard_Contract_Components__c != null) {
            //SP-707
            Boolean nonApprovalComponent = false;
            if (setNonStandardComponents != null) {
                for (String selectedComponent : setNonStandardComponents) {
                    //System.debug('iterating selecetd components: ' + selectedComponent);
                    if (setApprovalExceptions.contains(selectedComponent)) {
                        //System.debug('$$$ non approval comp found');
                        nonApprovalComponent = true;
                    } else {
                        //System.debug('$$$ approval comp found!break!');
                        nonApprovalComponent = false;
                        break;//enforce approval if any component is not in exception list
                    }
                }
            }
            //System.debug('$$$ flag after non approval component check : ' + nonApprovalComponent);
            //SP-707
            if (!nonApprovalComponent) {
                

                if (this.mapBusinessData.get('enableLevel1ApprovalForNonStand') != null && Boolean.valueOf(this.mapBusinessData.get('enableLevel1ApprovalForNonStand').Business_Rule_Value__c)) {
                    this.mapApprovalEntriesLevel2 = this.mapOppTeam.get('Legal');
                     if (this.mapApprovalEntriesLevel2 == null || this.mapApprovalEntriesLevel2.isEmpty()) {
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,Label.No_Approver));
                         noApprover = true;
                        
                    }
                    else if (this.mapApprovalEntriesLevel2 != null && !this.mapApprovalEntriesLevel2.isEmpty()) {
                        this.oppQuote.Approval_L2__c = true;
                    }

                    if (this.oppQuote.Approval_L1__c == false && !this.isRegionalApproval) {
                        if (this.mapBusinessData.get('initialApprovalStatusLevel2') != null) {
                            this.oppQuote.Status__c = this.mapBusinessData.get('initialApprovalStatusLevel2').Business_Rule_Value__c;
                        }

                        if (this.mapBusinessData.get('pushStageNameAfterInitialApprovalEntryLevel2') != null ) {
                            this.opp.StageName = this.mapBusinessData.get('pushStageNameAfterInitialApprovalEntryLevel2').Business_Rule_Value__c;
                        }
                    }if(this.isRegionalApproval){
                             this.oppQuote.Status__c = this.mapBusinessData.get('initialApprovalStatusLevel3').Business_Rule_Value__c;
                    }
                }

            }

        }
        update this.opp;

        try {
            if (!this.emailError && !noApprover) {
                upsert this.oppQuote;

                for (Opportunity_Quote_Line_Item__c item : this.mapExistingLineItems.values()) {
                    //System.debug('$$$ this.oppQuote.Id : ' + this.oppQuote.Id);
                    item.Id_Opportunity_Quote__c = this.oppQuote.Id;
                }


                upsert this.mapExistingLineItems.values();

                

                this.isMenuPrinting = this.isMenuPrinting();
                if (this.isMenuPrinting) {
                    this.oppQuote.Quote_Comment__c = this.opp.Quote_Comment_Menu_Printing__c;
                } else {
                    this.oppQuote.Quote_Comment__c = this.opp.Quote_Comment__c;
                }




                

                if (this.requiresApproval) {
                    this.mapApprovalEntriesLevel1 = this.mapOppTeam.get('HOS');
                    system.debug('approvalmap' + this.mapApprovalEntriesLevel1);
                    this.approvalLimits=LibBusinessConfig.determineApprover(this.opp.Record_Country__c,'HOS' );
                    this.oppQuote.Approval_L1__c = true;
                    if(!this.isRegionalApproval)
                        this.oppQuote.Status__c = this.mapBusinessData.get('initialApprovalStatus').Business_Rule_Value__c;
                    else
                        this.oppQuote.Status__c = this.mapBusinessData.get('initialApprovalStatusLevel3').Business_Rule_Value__c;
                }

                system.debug(this.oppQuote.Approval_L1__c );
                system.debug(this.oppQuote.Status__c);
                system.debug(this.approvalLimits.Notification__C);
                system.debug(this.approvalLimits);

                if (this.oppQuote.Approval_L1__c == true && this.oppQuote.Status__c == this.mapBusinessData.get('initialApprovalStatus').Business_Rule_Value__c && this.approvalLimits.Notification__C) {
                    ClsEmailProcessor.notifyApprovers(this.mapApprovalEntriesLevel1.values(), this.opportunityCompany + '_Opportunity_Quote', this.oppQuote.Id);
                } else if (this.oppQuote.Approval_L1__c == false && this.oppQuote.Approval_L2__c == true && !this.isRegionalApproval ) {
                    if(LibBusinessConfig.determineApprover(this.opp.Record_Country__c,'Legal' )!=null && LibBusinessConfig.determineApprover(this.opp.Record_Country__c,'Legal' ).Notification__C)
                        ClsEmailProcessor.notifyApprovers(this.mapApprovalEntriesLevel2.values(), this.opportunityCompany + '_Opportunity_Quote', this.oppQuote.Id);
                }else if (this.isRegionalApproval) {
                    if(LibBusinessConfig.determineApprover(this.opp.Record_Country__c,'Regional HOS' )!=null && LibBusinessConfig.determineApprover(this.opp.Record_Country__c,'Regional HOS' ).Notification__C)
                        ClsEmailProcessor.notifyApprovers(this.mapApprovalEntriesLevel3.values(), this.opportunityCompany + '_Opportunity_Quote', this.oppQuote.Id);
                }

            }
            this.showQuoteDetail = true;
            return true;
        } catch (Exception e) {
            this.showQuoteDetail = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, e.getMessage()));
            //System.debug('error at quote save: '+e.getMessage() + e.getLineNumber() + e.getStackTraceString());
            return false;
        }
    }

    



    public Boolean hasAsset() {
        Boolean hasAsset = false;
        Set<Id> productItemIds = this.mapExistingLineItems.keySet();
        if (productItemIds.size() >= 1) {
            return true;
        }
        return hasAsset;
    }

    public boolean isMenuPrinting() {
        Boolean isMenuPrinting = false;
        for (Opportunity_Quote_Line_Item__c oqpi : this.mapExistingLineItems.values()) {
            if (oqpi.sub_Type__c != null && oqpi.Line_Item_Type__c == 'Product') {
                if (oqpi.sub_Type__c.equals('Menu Printing')) {
                    return true;
                }
            }
        }
        return isMenuPrinting;
    }

    

    public void createQuote() {
        //saveQuote();
        saveQuoteData();
    }

    //For resetting error highlight on page
    public void resetErrorFalg() {
        for (LineItemWrapper lineItem : this.serviceLineItems) {
            lineItem.showError = false;
        }
        for (LineItemWrapper lineItem : this.productLineItems) {
            lineItem.showError = false;
        }
        for (LineItemWrapper lineItem : this.adSalesProductLineItems) {
            lineItem.showError = false;
        }
        for (LineItemWrapper lineItem : this.flatProductLineItems) {
            lineItem.showError = false;
        }
        for (LineItemWrapper lineItem : this.dpProductLineItems) {
            lineItem.showError = false;
        }
    }

    public Boolean checkForError() {
        Boolean fl = false;
        for (LineItemWrapper lineItem : this.serviceLineItems) {
            if (lineItem.showError != null && lineItem.showError) {
                fl = true;
                return fl;
            }
        }
        for (LineItemWrapper lineItem : this.productLineItems) {
            if (lineItem.showError != null && lineItem.showError) {
                fl = true;
                return fl;
            }
        }
        for (LineItemWrapper lineItem : this.adSalesProductLineItems) {
            if (lineItem.showError != null && lineItem.showError) {
                fl = true;
                return fl;
            }
        }
        for (LineItemWrapper lineItem : this.flatProductLineItems) {
            if (lineItem.showError != null && lineItem.showError) {
                fl = true;
                return fl;
            }
        }
        for (LineItemWrapper lineItem : this.dpProductLineItems) {
            if (lineItem.showError != null && lineItem.showError) {
                fl = true;
                return fl;
            }
        }
        return fl;
    }

    /**
    * Wrapper for lineItems.
    */
    public class LineItemWrapper {
        public Opportunity_Line_Item__c product { get; set; }
        public Opportunity_Line_Item__c service { get; set; }
        public Boolean showError { get; set; }
        public Integer position { get; set; }
        public Boolean firstRecord { get; set; }
        public Boolean lastRecord { get; set; }
        public Decimal subTotalAmount { get; set; }
        public String min {get{
                if (min != null && !min.isWhitespace()) {
                    //System.debug('min: '+min);
                    service.Min__c = Decimal.valueOf(min);
                }
                return min;
            } set;
        }
        public String max {get{
                if (max != null && !max.isWhitespace()) {
                    //System.debug('max: '+max);
                    service.Max__c = Decimal.valueOf(max);
                }
                return max;
            } set;
        }
        public String commission {get{
                if (commission != null && !commission.isWhitespace()) {
                    //System.debug('commission: '+commission);
                    service.Commission_In_Percentage__c = Decimal.valueOf(commission);
                }
                return commission;
            } set;
        }

        public string comissionperorder {get{
                if (comissionperorder != null && !comissionperorder.isWhitespace()) {
                    //System.debug('commission: '+commission);
                    service.Commission_Per_Order__c = Decimal.valueOf(comissionperorder);
                }
                return comissionperorder;
            } set;
        }


        public String onlinePayment {get{
                if (onlinePayment != null && !onlinePayment.isWhitespace()) {

                    service.Online_Payment_Fee__c = Decimal.valueOf(onlinePayment);
                }
                return onlinePayment;
            } set;
        }


        public LineItemWrapper(Opportunity_Line_Item__c lineItem, Boolean showError, Integer position, String type) {

            if (type == 'Product') {
                this.product = lineItem;

            } else {
                this.service = lineItem;
                if (lineitem.Min__c != null) {
                    this.min = '' + (lineitem.Min__c).stripTrailingZeros();

                }
                if (lineitem.Max__c != null) {
                    this.max = '' + ((lineitem.Max__c).stripTrailingZeros()).toPlainString();

                }
                if (lineitem.Commission_In_Percentage__c != null) {
                    this.commission = '' + lineitem.Commission_In_Percentage__c;
                }
                if (lineitem.Commission_per_order__c != null) {
                    this.comissionperorder = '' + lineitem.Commission_per_order__c;


                } if (lineitem.online_payment_fee__c != null) {
                    this.onlinePayment = '' + lineitem.online_payment_fee__c;
                }

            }
            this.showError = showError;
            this.position = position;
            if (position == 0) {
                this.firstRecord = true;
            } else {
                this.firstRecord = false;
            }
            this.lastRecord = false;

        }

        public LineItemWrapper(Decimal amount, Integer position) {
            this.position = position;
            this.subTotalAmount = amount;
            this.lastRecord = true;
            this.firstRecord = false;
        }

        
    }



    public void getOppLines() {
        ppAPILineItems = [SELECT Id, Name, Booking_Api_Id__c, Id_List_Price_Product__c, Listed_Price__c, Quantity__c, Total_Amount__c, Product_Group__c, Discount__c, Installments__c,
                          Has_Related_Tarif__c, CurrencyIsoCode, Start_Date__c, End_Date__c, Line_Item_Type__c, sub_type__c, City_ZipCode__c, Position__c, Position_fm__c
                          FROM Opportunity_Line_Item__c WHERE Id_Opportunity__c = : this.opp.Id order by Booking_Api_Id__c ASC];
        if (!ppAPILineItems.isEmpty()) {
            this.lockTariffSelection = true;
        }
    }

    @RemoteAction
    global static string getRestaurantInfo(String sfId, String monthYear, String urole) {
        userRole = urole;
        Account acc = [select Backend_ID__c,record_country__c from account where id = : sfid];
        String errorDiv = '<span style="color:#cc0000"><h4>Error:</h4></span>';
        if (monthYear == null) {
            return errorDiv + ' Month and year not set properly';
        }
        if (acc == null) {
            return errorDiv + 'Account does not exist';
        }
        try {
            List<String> myyyy = monthYear.split('-');
            Integer year = Integer.valueOf(myyyy[1]);
            Integer month = Integer.valueOf(myyyy[0]);
            Integer days = Date.daysInMonth(year, month);

            String startdate = year + '-' + month + '-' + '1';
            String enddate = year + '-' + month + '-' + days;

            HttpResponse res = new HttpResponse();
            Http http = new Http();
            //HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest('UK','restaurants/UKHH/'+sfId+'/'+myyyy[1]+'/'+myyyy[0]+'/','GET',null);
            HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest('PP', '/restaurants/id:' + acc.Backend_ID__c + '/postcodes/availability?availability_date_end=' + endDate + '&availability_date_begin=' + startDate,acc.record_country__c, 'GET', null);
            if (req != null) {
                //req.setHeader('user-info','{"user_email":"'+userEmail+'", "user_role":"'+userRole+'"}');
                res = http.send(req);
                System.debug('response :' + res.getBody());
                //System.debug('response :'+res.getBody());
                system.debug('##status code' + res.getStatusCode());
                if (res.getStatusCode() == 200) {
                    return res.getBody();
                } else {
                    return errorDiv + res.getBody();
                }
            } else {
                return errorDiv + 'MidasIntegration__c is not configured';
            }
        } catch (Exception e) {
            system.debug('Error: ' + e.getMessage());
            return errorDiv + e.getMessage();
        }
    }

    @RemoteAction
    global static String savePPLines(String accId, String oppId, List<SelectedPostcodes> selectedPos, String monthYear, String urole) {
        if (selectedPos != null && !selectedPos.isEmpty() && monthYear != null && accId != null && oppId != null) {
            oppForAPi = [select id, account.Backend_ID__c,account.RecordType.developerName, CurrencyIsoCode,record_country__c, Company_Code__c, Id_Tarif__c from Opportunity where id = :oppId];
            premiumPlaceApiProd = [select id, Id_List_Product_Group__r.Name from List_Product_Price__c where Product_Name__c = 'Premium Placement API' and RecordTypeId = : LibRecordTypeHelper.getRecordTypeValue(oppForAPi.Company_Code__c + '_List_Product_Price') and Id_Country__r.name=:oppForApi.Record_Country__c];
            userRole = urole;

            String errorDiv = '<span style="color:#cc0000"><h4>Error:</h4></span>';
            Map<String, Opportunity_Line_Item__c> oppLineMap = new Map<String, Opportunity_Line_Item__c>();
            try {
                if (monthYear == null) {
                    return errorDiv + ' Month and year not set properly';
                }
                List<String> myyyy = monthYear.split('-');
                Integer year = Integer.valueOf(myyyy[1]);
                Integer month = Integer.valueOf(myyyy[0]);
                String bodyparam = '{"meta": {"username": "' + userEmail + '","sf_role": "' + userRole + '","sf_opportunity_id": "' + oppId + '"},"data": {"bookings": [';
                String arrays = '';
                //System.debug('oppForAPi: '+oppForAPi);
                //System.debug('premiumPlaceApiProd: '+premiumPlaceApiProd);
                Date startDate2 = Date.today();
                Integer startDay = startDate2.day();

                if (month != startDate2.month()) {
                    startDate2 = date.newinstance(year, month, 1);
                    startDay = 1;
                }
                Integer days = Date.daysInMonth(year, month);
                Date endDate2 = date.newinstance(year, month, days);

                String startdate = year + '-' + month + '-' + startDay;
                String enddate = year + '-' + month + '-' + days;
                for (SelectedPostcodes ss : selectedPos) {
                    Decimal disc = 0;
                    if (ss.price < ss.listedPrice) {
                        disc = ss.listedPrice - ss.price;
                    }
                    //arrays += '{"postcode":"'+ss.postcode+'","price":'+ss.price+',"package_type":"'+ss.package_type+'"},';
                    arrays += '{"date_begin": "' + startdate + '","postcode": "' + ss.postcode + '","date_end": "' + enddate + '","price":' + ss.price + ',"restaurant_package_id":' + ss.package_type + ',"status":"new"},';


                    oppLineMap.put(ss.postcode, new Opportunity_Line_Item__c(Start_Date__c = startDate2, Booking_Api_Id__c = null, End_Date__c = endDate2, Line_Item_Type__c = 'Product', Id_List_Price_Product__c = premiumPlaceApiProd.Id, Name = 'Premium Placement', Id_Opportunity__c = oppForAPi.Id, Quantity__c = 1, Discount__c = '' + disc, Installments__c = 1, Listed_Price__c = ss.listedPrice, Total_Amount__c = ss.price, Product_Group__c = premiumPlaceApiProd.Id_List_Product_Group__r.Name, CurrencyIsoCode = oppForAPi.CurrencyIsoCode, sub_type__c = 'Premium Placement', Position__c = ss.package_description, City_ZipCode__c = ss.postcode, RecordtypeId = LibRecordTypeHelper.getRecordTypeValue(oppForAPi.Company_Code__c + '_Opportunity_Line_Item')));
                }
                bodyparam += arrays.removeEnd(',');
                bodyparam += ']}}';
                //System.debug('oppLineMap: '+oppLineMap.values());
                HttpResponse res = new HttpResponse();
                Http http = new Http();
                //System.debug('bodyparam: '+bodyparam);
                //HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest('UK','book/UKHH/'+accId+'/','POST',bodyparam);
                HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest('PP', '/restaurants/id:' + oppForAPi.account.Backend_ID__c + '/bookings',oppForAPi.record_country__c , 'POST', bodyparam);
                if (req != null) {
                    //req.setHeader('opportunity-info','{"opportunity_id":"'+oppId+'","account_id":"'+accId+'"}');
                    //req.setHeader('user-info','{"user_email":"'+userEmail+'", "user_role":"'+userRole+'"}');
                    res = http.send(req);
                    //System.debug('response :'+res.getBody());
                    system.debug('##status code' + res.getStatusCode());
                    if (res.getStatusCode() == 201 || res.getStatusCode() == 200) {
                        JSONParser parser = JSON.createParser(res.getBody());
                        while (parser.nextToken() != null) {
                            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                                while (parser.nextToken() != null) {
                                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                        // Read entire invoice object, including its array of line items.
                                        bookings bk = (bookings)parser.readValueAs(bookings.class);
                                        if (oppLineMap.containsKey(bk.postcode)) {
                                            oppLineMap.get(bk.postcode).Booking_Api_Id__c = bk.id;
                                        }
                                    }
                                }
                            }
                        }
                        insert oppLineMap.values();
                        //if(selectedTarif!=null && selectedTarif!=oppForAPi.Id_Tarif__c){
                        //    oppForAPi.Id_Tarif__c = selectedTarif;
                        // }
                        update oppForAPi;
                        return 'success';
                    } else {
                        return errorDiv + res.getBody();
                    }
                } else {
                    return errorDiv + 'MidasIntegration__c is not configured';
                }
            } catch (Exception e) {
                system.debug('Error: ' + e.getMessage());
                return errorDiv + e.getMessage();
            }
        }
        return 'success';
    }

    @RemoteAction
    global static string createQuotePP(String oppId) {
        String errorDiv = '<span style="color:#cc0000"><h4>Error:</h4></span>';
        try {

            List<Opportunity_Line_Item__c> ppAPILineItems = [SELECT Id, Name, Booking_Api_Id__c, Id_List_Price_Product__c, Listed_Price__c, Quantity__c, Total_Amount__c, Product_Group__c, Discount__c, Installments__c,
                                           Id_Opportunity__c, Has_Related_Tarif__c, CurrencyIsoCode, ID_opportunity__r.ID_tarif__c, Start_Date__c, End_Date__c, Line_Item_Type__c, sub_type__c, City_ZipCode__c, Position__c, Position_fm__c
                                           FROM Opportunity_Line_Item__c WHERE Id_Opportunity__c = : oppId];

            Opportunity oppt = [select  Id, Company_Code__c, CurrencyIsoCode, accountId, StageName, Probability, 
            						Quote_Comment__c, Quote_Comment_Menu_Printing__c, Record_Country__c, RecordTypeId, 
            						Account.Backend_ID__c, Account.Invoice_Frequency__c,account.recordType.developerName
                                from Opportunity where Id = :oppId];

            List<Opportunity_Quote_Line_Item__c> existingLineItems = new List<Opportunity_Quote_Line_Item__c>();
            String recType = LibRecordTypeHelper.getRecordTypeValue(oppt.Company_Code__c + '_Opportunity_Quote_Line_Item');

            for (Opportunity_Line_Item__c existingProduct : ppAPILineItems) {

                existingLineItems.add(new Opportunity_Quote_Line_Item__c(name = existingProduct.name, Id_List_Product_Price__c = existingProduct.Id_List_Price_Product__c, Listed_Price__c = existingProduct.Listed_Price__c, Quantity__c = existingProduct.Quantity__c,
                                      Total_Amount__c = existingProduct.Total_Amount__c, Id_Opportunity__c = existingProduct.Id_Opportunity__c, Product_Group__c = existingProduct.Product_Group__c, discount__c = existingProduct.Discount__c, Installments__c = existingProduct.Installments__c, Has_Related_Tarif__c = existingProduct.Has_Related_Tarif__c, Line_Item_Type__c = existingProduct.line_item_type__c, sub_type__c = existingProduct.sub_type__c,
                                      recordtypeId = recType, CurrencyIsoCode = oppt.CurrencyIsoCode, Start_Date__c = existingProduct.Start_Date__c, End_Date__c = existingProduct.End_Date__c, City_ZipCode__c = existingProduct.City_ZipCode__c, Position__c = existingProduct.Position__c, Booking_Api_Id__c = existingProduct.Booking_Api_Id__c));
            }

            Opportunity_Quote__c oppQuote = new Opportunity_Quote__c();
            oppQuote.recordtypeId = LibRecordTypeHelper.getRecordTypeValue(oppt.Company_Code__c + '_Opportunity_Quote');
            oppQuote.Id_Opportunity__c = oppt.Id;
            oppQuote.CurrencyIsoCode = oppt.CurrencyIsoCode;
            oppQuote.status__c = 'Approved';
            oppQuote.Id_Account__c = oppt.accountId;
            oppQuote.ID_tarif__C = ppAPILineItems[0].ID_Opportunity__r.ID_tarif__c;
            insert oppQuote;

            for (Opportunity_Quote_Line_Item__c qplines : existingLineItems) {
                qplines.Id_Opportunity_Quote__c = oppQuote.Id;
            }
            insert existingLineItems;

            ClsQuoteProcessor cqp1 = new ClsQuoteProcessor(oppt, oppQuote, LibRecordTypeHelper.getRecordTypeValue(oppt.RecordTypeId), existingLineItems);
            oppQuote.Template_Name__c = cqp1.vfTemplateName;
            update oppQuote;
            return '' + oppQuote.Id;
        } catch (Exception e) {
            //System.debug('error: '+e.getMessage());
            return errorDiv + e.getMessage();

        }
        return 'success';

    }


    public class bookings {
        String id;
        String postcode;
        public bookings(String booking_id, String postcode) {
            this.id = booking_id;
        }
    }

    global class SelectedPostcodes {
        String distance;
        String postcode;
        Decimal coverage;
        Decimal price;
        String package_type;
        Decimal listedPrice;
        String package_description;
        global  SelectedPostcodes(String distance,String package_description, String postcode, Decimal coverage, Decimal price, String package_type, Decimal listedPrice) {
            this.distance = distance;
            this.package_description = package_description;
            this.postcode = postcode;
            this.coverage = coverage;
            this.price = price;
            this.package_type = package_type;
            this.listedPrice = listedPrice;
        }
    }
}