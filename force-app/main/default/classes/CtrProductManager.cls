public with sharing class CtrProductManager extends ClsManagementConsoleBase {
    @TestVisible
    private static Map<String, Map<String, Business_Config__c>> mapProcessData =  LibBusinessConfig.motherOfAllBusinessMaps.get('SalesManagementProcessService');
    
    public List_Product_Price__c myNewProduct { get; set; }
    public String selectedProductGroup { get; set; }
    public String productId { get; set; }
    public List_Product_Group__c productToUpdate { get; set; }
    private Map<String, Business_Config__c> mapBusinessData { get; set; }
    public Boolean showProductType { get; set; }
    public String recurringChargesAllowed { get; set; } //comma separated string of recurring charges allowed. Read from business config and will be used by jquery on page to deside when to show or hide input fields
    public Map<String, String> recuringChargesMap { get; set; }
    
    public String prodGroupName { get; set; }
    //public Boolean enableSliders {get; set;}
    public Boolean enableAddChargeSlider {get; set;}
    public Boolean enableApprovalSlider {get; set;}
    public Boolean enableAssetSlider {get; set;}
    public Boolean enableBrandSlider {get; set;}
    public Boolean enableReplaceSlider {get; set;}
    public String countryCode {get; set;}
    public Boolean disableReplacement {get; set;}
    public Boolean disableForReplacement {get; set;}

    public List<List_Product_Group__c> productGroups = new List<List_Product_Group__c>();
    private transient List<List_Product_Price__c> listProductsCache;
    
    public List<List_Product_Price__c> listProducts {
        get {
            // in this way we avoid to make the soql query multiple time during the same transaction
            // and on the same time we tremendously reduce the view state size
            if (listProductsCache == null) {
                listProductsCache = new List<List_Product_Price__c>([
                    SELECT Id, Name, Product_Name__c, Displayed_Name__c, CreatedDate, LastModifiedDate,
                            LastModifiedBy.Name, Is_Active__c, Unapproved_Discount_Limit__c, Maximum_discount__c,
                            Default_Quantity__c, Id_List_Product_Group__r.Name, Installments__c, List_Price__c,
                            Id_Country__c, Id_Country__r.name, Requires_Asset__c, Requires_Additional_Charge__c,
                            Requires_Add_On__c, Requires_Branding__c, Company__c, Product_Type__c,
                            Requires_Replacement__c,SKU__c,Requires_Esignature__c
                    FROM List_Product_Price__c
                    WHERE Id_Country__c IN : this.userCountryIds
                    AND Company__c IN : this.userCompanyIds
                    ORDER BY LastModifiedDate DESC LIMIT 500]);
            }
            return listProductsCache;
        }
    }

    public Map<Id, List_Product_Price__c> mapProductListPrice {
        get {
            this.mapProductListPrice = new Map<Id, List_Product_Price__c>();
            this.mapProductListPrice.putall(this.listProducts);
            return this.mapProductListPrice;
        }
        set;
    }

    public List<SelectOption> listProductGroupSelection {
        get {
            this.listProductGroupSelection = new List<SelectOption>();
            this.listProductGroupSelection.add(new SelectOption('null', Label.Please_select_a_Product_Group));
            for (List_Product_Group__c grp : [
                SELECT Id, Name, CurrencyIsoCode, Id_Country__c
                FROM List_Product_Group__c
                WHERE Id_Country__c = : this.selectedCountry
                AND Company__c = : this.selectedCompany
                AND Name != :this.prodGroupName
                ORDER BY LastModifiedDate DESC
            ]) {
                this.listProductGroupSelection.add(new SelectOption(grp.Id, grp.Name));
                productGroups.add(grp);
            }
            return this.listProductGroupSelection;
        }

        set;
    }

    public CtrProductManager() {
        this.myNewProduct = new List_Product_Price__c();
        myNewProduct.Product_Name__c = '';
        this.countryCode = '';
        myNewProduct.Default_Quantity__c = 1;
        myNewProduct.Requires_Additional_Charge__c = true;
        this.showProductType = false;
        this.enableAddChargeSlider = false;
        this.enableApprovalSlider = false;
        this.enableAssetSlider = false;
        this.enableBrandSlider = false;
        this.enableReplaceSlider = false;
        //this.mapProcessData = LibBusinessConfig.getGenericProcessData('SalesManagementProcessProducts');
        //this.mapProcessData = moam.get('SalesManagementProcessProducts');
        this.prodGroupName = '';
        this.recuringChargesMap = new Map<String, String>();
        this.disableReplacement = false;
        this.disableForReplacement = false;
        this.setShowProductType();
    }

    public void setShowProductType() {
        System.debug('mapProcessData: ' + mapProcessData);
        if (mapProcessData != null && this.determineCompanyCode() != null) {
            system.debug('Executing setShowProductType1');
            system.debug('this.determineCompanyCode() : ' + this.determineCompanyCode() );
            if (!mapProcessData.isEmpty()) {
                this.mapBusinessData = mapProcessData.get(this.determineCompanyCode() + '_List_Product_Price');
                system.debug('**mapBusinessData' + mapBusinessData);
                this.countryCode = this.determineCompanyCode();
                if (this.countryCode == 'UK' || this.countryCode == 'SE' ) {
                    disableReplacement = false;
                }
                this.myNewProduct.RecordTypeId = LibRecordTypeHelper.getRecordType(this.countryCode + '_List_Product_Price', 'List_Product_Price__c').Id;
                if (this.mapBusinessData != null && this.mapBusinessData.get('useProductTypes') != null && (String.isNotBlank(this.mapBusinessData.get('useProductTypes').Business_Rule_Value__c) && this.mapBusinessData.get('useProductTypes').Business_Rule_Value__c != 'false')) {
                    this.showProductType = true;
                    //this.enableSliders = Boolean.valueOf(mapBusinessData.get('DisplaySliders').Business_Rule_Value__c);
                    system.debug('Executing setShowProductType3');
                    //Added by Bhupendra for SP-1362 Start
                    system.debug('@@@@mapBusinessData@@@  ' +this.mapBusinessData.get('DisplaySliders'));
                    if(this.mapBusinessData.get('DisplaySliders') != null && (String.isNotBlank(this.mapBusinessData.get('DisplaySliders').Business_Rule_Value__c) ) ){ 
                        for (String ruleValue : (this.mapBusinessData.get('DisplaySliders').Business_Rule_Value__c).split(',')) {
                            system.debug('**ruleValue ' + ruleValue);
                            if(ruleValue == 'addCharge'){
                                this.enableAddChargeSlider = true;
                            }
                            if(ruleValue == 'Approval'){
                                this.enableApprovalSlider = true;
                            }
                            if(ruleValue == 'Asset'){
                                this.enableAssetSlider = true;
                            }
                            if(ruleValue == 'Brand'){
                                this.enableBrandSlider = true;
                            }
                            if(ruleValue == 'Replace'){
                                this.enableReplaceSlider = true;
                            }
                        }
                    }    
                    //Added by Bhupendra for SP-1362 End

                    if (this.mapBusinessData.get('recurringFee') != null && String.isNotBlank(this.mapBusinessData.get('recurringFee').Business_Rule_Value__c)) {
                        this.recurringChargesAllowed = '';
                        /*this.recuringChargesMap = new Map<String, String>();*/
                        for (String str : this.mapBusinessData.get('recurringFee').Business_Rule_Value__c.split(',')) {
                            this.recurringChargesAllowed += str + ',';
                            this.recuringChargesMap.put(str, str);
                        }
                        this.recurringChargesAllowed = this.recurringChargesAllowed.substring(0, this.recurringChargesAllowed.length() - 1);
                    }
                    if (this.mapBusinessData.get('productGroupName') != null && String.isNotBlank(this.mapBusinessData.get('productGroupName').Business_Rule_Value__c)) {
                        this.prodGroupName = this.mapBusinessData.get('productGroupName').Business_Rule_Value__c;
                    }
                } else {
                    this.showProductType = false;
                }
            }
        } else {
            this.showProductType = false;
        }
    }

    public void initiateProductAdd() {
        this.resetSliderFalse();
        this.setShowProductType();
    }

    /*public boolean validatePercentage(){
        if(this.myNewProduct.maximum_discount__c!=null && this.myNewProduct.maximum_discount__c>100){
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR,Label.Maximum_Discount_Invalid));
            return false;
        }
        return true;
    }*/

    public boolean validatePercentage() {
        if (this.myNewProduct.Unapproved_Discount_Limit__c != null && this.myNewProduct.Unapproved_Discount_Limit__c > 100) {
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, Label.Maximum_Discount_Invalid));
            return false;
        }
        return true;
    }

    public void resetSliderFalse(){
        this.enableAddChargeSlider = false;
        this.enableApprovalSlider = false;
        this.enableAssetSlider = false;
        this.enableBrandSlider = false;
        this.enableReplaceSlider = false;
    }
    
    /*public void validateNewProduct(){
         if(this.myNewProduct.Product_Type__c.equals('Recurring Fee')){
            this.myNewProduct.Installments__c = 0;
        } else {
            System.debug('@@@@ validateNewProduct - selectedProductGroup : BEFORE - ' + this.selectedProductGroup);
            if(this.selectedProductGroup != 'null' && String.isNotBlank(this.selectedProductGroup)){
                System.debug('@@@@ validateNewProduct - selectedProductGroup : ' + this.selectedProductGroup);
                this.myNewProduct.Id_List_Product_Group__c = this.selectedProductGroup;
                this.determineProductGroup();
            } else{
                System.debug('@@@@ validateNewProduct - selectedProductGroup ERROR : ' + this.selectedProductGroup);
                Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.ERROR, Label.SMC_Product_Select_Product_Group));
            }
        }
    }*/

    public void addProduct() {
        if (this.updateItem()) {
            this.determineProductGroupForRecurringFee();
            if (this.selectedProductGroup != 'null' && this.selectedProductGroup != null && this.selectedProductGroup.length() != 0) {
                if (validatePercentage()) {
                    String recordTypeDeveloperName = this.determineCompanyCode() + '_List_Product_Price';
                    RecordType rt = LibRecordTypeHelper.getRecordType(recordTypeDeveloperName,  'List_Product_Price__c');
                    this.myNewProduct.RecordTypeId = rt.Id;
                    this.myNewProduct.Id_Country__c = this.selectedCountry;
                    this.myNewProduct.Company__c = this.selectedCompany;
                    this.myNewProduct.Id_List_Product_Group__c = this.selectedProductGroup;
                    /*if(this.myNewProduct.Product_Type__c.equals('Recurring Fee')){
                        this.myNewProduct.Installments__c = 0;
                    }*/
                    if (this.myNewProduct.Product_Type__c != null && this.recuringChargesMap.get(this.myNewProduct.Product_Type__c) != null) {
                        this.myNewProduct.Installments__c = 0;
                    }
                    this.determineProductGroup();
                    try {
                        if (validateProductName(this.myNewProduct)) {
                            upsert this.myNewProduct;
                            if (this.productToUpdate != null) {
                                this.productToUpdate.In_Use__c = true;
                                upsert this.productToUpdate;
                            }
                            Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.INFO, Label.SMC_Product_Group_Saved_Successfully + ' : ' + this.myNewProduct.Product_Name__c));
                            this.reinit();
                            this.reInitCountryAndCompanyDropdowns();
                            this.setShowProductType();
                        } else {
                            this.myNewProduct.addError('Additional Charges Name is already in use. Additional Charges Name needs to be unique. Please use Display Name field to create Name that will be displayed on Quote');
                        }
                    } catch (Exception e) {
                        System.debug('@@@@ calling addProduct - exception type ' + e.getTypeName());
                        System.debug('@@@@ calling addProduct - exception message ' + e.getMessage());
                        Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.INFO, 'Error: ' + e.getMessage() ));
                    }
                }
            } else {
                Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.ERROR, Label.SMC_Product_Select_Product_Group));
            }
        } else {
            Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.ERROR, Label.SMC_Required_Fields_Missing));
        }
    }

    public boolean validateProductName(List_Product_Price__c productPrice) {
        List<List_Product_Price__c> productPriceList = [SELECT Id, Product_Name__c FROM List_Product_Price__c WHERE Product_Name__c = :productPrice.Product_Name__c AND RecordTypeId = :productPrice.RecordTypeId AND Id_Country__c = :productPrice.Id_Country__c];
        if (productPriceList.size() == 0)
            return true;
        else if (productPriceList.size() == 1) {
            if (productPrice.Id == productPriceList[0].Id) {
                return true;
            } else {
                return false;
            }
        } else return false;
    }

    private void reinit() {
        this.myNewProduct = new List_Product_Price__c();
        myNewProduct.Product_Name__c = '';
        myNewProduct.Default_Quantity__c = 1;
        this.selectedProductGroup = 'null';
    }

    public void editItem() {
        this.myNewProduct =  this.mapProductListPrice.get(this.productId);
        this.selectedProductGroup = this.myNewProduct.Id_List_Product_Group__c;
        this.selectedCountry = this.myNewProduct.Id_Country__c;
        this.selectedCompany = this.myNewProduct.Company__c;
        this.setShowProductType();
        this.disableReplacement = true;
        if (this.myNewProduct.Requires_Replacement__c) {
            disableForReplacement = true;
        }
    }

    public void chooseProductToDelete() {
        this.myNewProduct = this.mapProductListPrice.get(this.productId);
    }

    public void deleteItem() {
        try {
            delete this.mapProductListPrice.get(this.productId);
            Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.INFO, Label.Delete_was_successfull));

        } catch (Exception e) {
            if (e.getTypeName() == 'System.DMLException' && e.getMessage().contains('opportunity product')) {
                Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.ERROR, Label.Product_cannot_be_deleted_It_is_used_as_an_opportunity_product));
            }

        }

        reinit();
    }

    public void cancel() {
        disableReplacement = true;
        this.myNewProduct = new List_Product_Price__c();
        myNewProduct.Product_Name__c = '';
        myNewProduct.Default_Quantity__c = 1;
        myNewProduct.Requires_Additional_Charge__c = true;
        this.reInitCountryAndCompanyDropdowns();

        this.setShowProductType();
    }

    public String determineProductGroup() {
        if (this.selectedProductGroup != 'null' && String.isNotBlank(this.selectedProductGroup)) {
            for (List_Product_Group__c pg : productGroups) {
                if (pg.Id.equals(this.selectedProductGroup)) {
                    this.productToUpdate = pg;
                    return pg.CurrencyIsoCode;
                }
            }
        }
        return '';
    }

    public void determineProductGroupForRecurringFee() {
        if (this.myNewProduct.Product_Type__c != null && this.recuringChargesMap.get(this.myNewProduct.Product_Type__c) != null) {
            if (prodGroupName != null) {
                List<List_Product_Group__c> lpg = [SELECT Id, Name FROM List_Product_Group__c WHERE Name = :prodGroupName AND Company__c = :this.selectedCompany LIMIT 1];
                if (!lpg.isEmpty()) {
                    this.selectedProductGroup = lpg[0].Id;
                }
            }
        }
    }
}