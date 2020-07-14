public without sharing class CtrTarifManager extends ClsManagementConsoleBase {

    public Tarif__c myTarif 									{ get; set; }
    public String selectedService 								{ get; set; }
    public String selectedProduct 								{ get; set; }
    public String selectedAddOn 								{ get; set; }
    public String selectedServiceToDelete 						{ get; set; }
    public String selectedProductToDelete 						{ get; set; }
    public String selectedAddOnToDelete 						{ get; set; }
    public String selectedTarif 								{ get; set; }
    public Map<Id, List_Service_Price__c> mapSelectedServices 	{ get; set; }
    public Map<Id, List_Product_Price__c> mapSelectedProducts 	{ get; set; }
    public Map<Id, List_Add_On__c> mapSelectedAddOns 			{ get; set; }    
    public List<SelectOption> selectedCategories				{ get; set; }

    private transient Map<Id, List_Service_Price__c> servicesMapCache;
    public Map<Id, List_Service_Price__c> servicesMap {
        get {
            // in this way we avoid to make the soql query multiple time during the same transaction
            // and on the same time we tremendously reduce the view state size
            if (servicesMapCache == null) {
                servicesMapCache = ListServicePriceSelector.getActiveServicesForAccounts(this.userCountryIds,this.userCompanyIds);
            }
            return servicesMapCache;
        }
    }

    private transient Map<Id, List_Product_Price__c> productsMapCache;
    public Map<Id, List_Product_Price__c> productsMap {
        get {
            // in this way we avoid to make the soql query multiple time during the same transaction
            // and on the same time we tremendously reduce the view state size
            if (productsMapCache == null) {
                productsMapCache = new Map<Id, List_Product_Price__c>([
                    SELECT Id, Default_Quantity__c, Installments__c, Is_Active__c, List_Price__c, 
                    	Id_List_Product_Group__c, Id_List_Product_Group__r.Name, Product_Name__c, 
                    	Id_Country__c, Company__c
                    FROM List_Product_Price__c
                    WHERE Id_Country__c IN : this.userCountryIds
                    AND Company__c IN : this.userCompanyIds
                    LIMIT 500
                ]);
            }
            return productsMapCache;
        }
    }
    
    private transient map<Id,List_Add_On__c> addOnMapCache;
    public Map<Id,List_Add_On__c> addOnMap{
    	get {
    		if(addOnMapCache == null){
    			addOnMapCache = new Map<Id,List_Add_On__c>([
    				SELECT Id,Name,Id_Country__c,Company__c,Type__c,Contract_Addition__c,Is_Active__c
    				FROM List_Add_On__c
    				WHERE Id_Country__c IN : this.userCountryIds
    				AND Company__c IN : this.userCompanyIds
    				LIMIT 500
    			]);
    		}
    		
    		return addOnMapCache;
    	}    	
    } 

    private transient Map<Id, Tarif__c> tariffsMapCache;
    public Map<Id, Tarif__c> tariffsMap {
        get {
            // in this way we avoid to make the soql query multiple time during the same transaction
            // and on the same time we tremendously reduce the view state size
            if (tariffsMapCache == null) {
                tariffsMapCache = TarifSelector.findTarifRecordByCountries(this.userCountryIds);
            }
            return tariffsMapCache;
        }
        set;
    }

    public Integer selectedProductsSize {
        get {
            if (this.mapSelectedProducts == null) {
                return  0;
            } else {
                return this.mapSelectedProducts.size();
            }
        }
        set;
    }

    public Integer selectedServicesSize {
        get{
            if (this.mapSelectedServices == null) {
                return 0;
            } else {
                return this.mapSelectedServices.size();
            }

        }
        set;
    }
    
    public Integer selectedAddOnsSize {
        get{
            if (this.mapSelectedAddOns == null) {
                return 0;
            } else {
                return this.mapSelectedAddOns.size();
            }

        }
        set;
    }

    public List<Tarif__c> tariffs {
        get{
            system.debug('*tariffsmap' + tariffsMap );
            List<Tarif__c> tariffs = this.tariffsMap.values();
            //List<country__C> c =[select id, name from country__C];
            //system.debug('*tariffs'+ c);
            return tariffs;
        }
        private set;
    }

    public List<SelectOption> products {
        get{ 
            List<SelectOption> products = new List<SelectOption>();
            products.add(new SelectOption('null', Label.Please_select));

            if (!this.productsMap.isEmpty()) {
                for (Id productId : this.productsMap.keySet()) {
                    if (((String)productsMap.get(productId).Id_Country__c).equals(this.selectedCountry) && productsMap.get(productId).Is_Active__c == true) {
                        products.add(new SelectOption(productsMap.get(productId).Id, productsMap.get(productId).Product_Name__c));
                    }
                }
            }
            return products;
        }
        private set;
    }

    public List<SelectOption> services {
        get {
            List<SelectOption> services = new List<SelectOption>();
            services.add(new SelectOption('null', Label.Please_select));
            if (!servicesMap.isEmpty()) {
                for (Id serviceId : servicesMap.keySet()) {
                    if (((String)servicesMap.get(serviceId).Id_Country__c).equals(this.selectedCountry) && servicesMap.get(serviceId).Is_Active__c == true) {
                        services.add(new SelectOption(servicesMap.get(serviceId).Id, servicesMap.get(serviceId).Name));
                    }
                }
            }
            return services;
        }
        private set;
    }
    
    public List<SelectOption> addOns {
        get {
            List<SelectOption> addOns = new List<SelectOption>();
            addOns.add(new SelectOption('null', Label.Please_select));
            if (!addOnMap.isEmpty()) {
                for (Id addOnId : addOnMap.keySet()) {
                    if (((String)addOnMap.get(addOnId).Id_Country__c).equals(this.selectedCountry) && 
                    	addOnMap.get(addOnId).Is_Active__c == true) {
                        	addOns.add(new SelectOption(addOnMap.get(addOnId).Id, addOnMap.get(addOnId).Name));
                    }
                }
            }
            return addOns;
        }
        private set;
    }
    
    public List<SelectOption> availableCategories {
    	get {
    		this.availableCategories = new List<Selectoption>();
    		for(List_Product_Group__c pg : [SELECT Id,Name 
    											FROM List_Product_Group__c
    											WHERE Id_Country__c = : this.selectedCountry
								                AND Company__c IN : this.userCompanyIds 
								                ORDER BY LastModifiedDate DESC]){
                String alreadySelectedCategories = getCategories(selectedCategories);
                if(alreadySelectedCategories == null || alreadySelectedCategories == '' ||
                    !alreadySelectedCategories.contains(pg.name) )
				        this.availableCategories.add(new SelectOption(pg.name,pg.name));
			}
			return this.availableCategories;
    	}
    	
    	set;
    }

    public CtrTarifManager() {
        this.mapSelectedServices 	= new Map<Id, List_Service_Price__c>();
        this.mapSelectedProducts 	= new Map<Id, List_Product_Price__c>();
        this.mapSelectedAddOns 		= new Map<Id, List_Add_On__c>();
        this.selectedCategories		= new List<SelectOption>();
        this.myTarif = new Tarif__c();
    }

    private void reset() {
        this.mapSelectedProducts.clear();
        this.mapSelectedServices.clear();
        this.mapSelectedAddOns.clear();
        this.selectedProduct 	= 'null';
        this.selectedService 	= 'null';
        this.selectedAddOn		= 'null ';
        this.selectedCategories	=  new List<SelectOption>();
        this.myTarif = new Tarif__c();
        tariffsMapCache = null;
    }

    public void addService() {
        if (selectedService != null && selectedService != 'null') {
            this.mapSelectedServices.put(selectedService, this.servicesMap.get(selectedService));
        } else {
            ClsUtilsApexPages.addErrorMessage(Label.SMC_Tariff_Invalid_Service);
        }
    }

    public void addProduct() {
        if (selectedProduct != null && selectedProduct != 'null') {
            this.mapSelectedProducts.put(selectedProduct, this.productsMap.get(selectedProduct));
        } else {
            ClsUtilsApexPages.addErrorMessage(Label.SMC_Tariff_Invalid_Product);
        }
    }
    
    public void addAddOn() {
        if (selectedAddOn != null && selectedAddOn != 'null') {
            this.mapSelectedAddOns.put(selectedAddOn, this.addOnMap.get(selectedAddOn));
        } else {
            ClsUtilsApexPages.addErrorMessage(Label.SMC_Tariff_Invalid_AddOn);
        }
    }

    public void deleteServiceItem() {
        if (selectedServiceToDelete != null) {
            mapSelectedServices.remove(selectedServiceToDelete);
        }
    }

    public void deleteProductItem() {
        if (selectedProductToDelete != null) {
            mapSelectedProducts.remove(selectedProductToDelete);
        }
    }
    
    public void deleteAddOnItem() {
        if (selectedAddOnToDelete != null) {
            mapSelectedAddOns.remove(selectedAddOnToDelete);
        }
    }
    

    public boolean saveValidation() {
        return true;
    }

    public void chooseTarifToDelete() {
        this.myTarif = this.tariffsMap.get(this.selectedTarif);
    }

    public void initiateTariffAdd() {

    }

    public void deleteTarif() {
        try {
            delete myTarif;
            reset();
            ClsUtilsApexPages.addInfoMessage(Label.SMC_Tariff_Successful_Delete);
        } catch (Exception e) {
            ClsUtilsApexPages.addInfoMessage(Label.SMC_Tariff_Delete_Error);
            system.debug('@@@@ calling deleteTarif - The following error occured while deleting tarif: ' + myTarif.Name + ' - ' + myTarif.Id + ' : ' + e.getMessage());
        }
    }

    public void editTarif() {
        try {
            this.myTarif = this.tariffsMap.get(this.selectedTarif);
            this.selectedCountry 	= this.myTarif.Id_Country__c;
            selectedCategories		= populateSelectedCategories(this.myTarif.categories__c);
        } catch (Exception e) {
            ClsUtilsApexPages.addErrorMessage( Label.SMC_Tariff_Error_Loading_Tariff + e.getStackTraceString());
        }


        this.mapSelectedProducts.clear();
        this.mapSelectedServices.clear();
        this.mapSelectedAddOns.clear();

        for (Tarif_Member__c theTarifMember : this.myTarif.Tarif_Members__r) {
            if (getObject(theTarifMember.Id_Tarif_Item__c) == 'List_Product_Price__c') {
                if (this.productsMap.get(theTarifMember.Id_Tarif_Item__c) != null) {
                    this.mapSelectedProducts.put(theTarifMember.Id_Tarif_Item__c, this.productsMap.get(theTarifMember.Id_Tarif_Item__c));
                }
            } else if (getObject(theTarifMember.Id_Tarif_Item__c) == 'List_Service_Price__c') {
                if (this.servicesMap.get(theTarifMember.Id_Tarif_Item__c) != null) {
                    this.mapSelectedServices.put(theTarifMember.Id_Tarif_Item__c, this.servicesMap.get(theTarifMember.Id_Tarif_Item__c));
                }
            } else if (getObject(theTarifMember.Id_Tarif_Item__c) == 'List_Add_On__c') {
                if (this.addOnMap.get(theTarifMember.Id_Tarif_Item__c) != null) {
                    this.mapSelectedAddOns.put(theTarifMember.Id_Tarif_Item__c, this.addOnMap.get(theTarifMember.Id_Tarif_Item__c));
                }
            }
        }

    }

    private String getObject(String id) {
        Id theId = (Id)id;

        return theId.getSobjectType().getDescribe().getName();
    }

    public void save() {
        if (saveValidation()) {
            if (isValid()) {
                String recordTypeDeveloperName = populateRecordType();//this.determineCompanyCode() + '_Tarif';
                RecordType rt = LibRecordTypeHelper.getRecordType(recordTypeDeveloperName,  'Tarif__c');
                this.myTarif.RecordTypeId = rt.Id;
                this.myTarif.Id_Country__c = this.selectedCountry;
                //this.myTarif.Company__c = this.selectedCompany;
                this.myTarif.categories__c = getCategories(selectedCategories);
                if(this.myTarif.is_Locked__c){
                    this.myTarif.Product_only__c  = false;
                    this.myTarif.categories__c	  = null;
                }
                savePoint sp;
                try {
                	sp = Database.setSavepoint();
                    upsert myTarif;
                    delete myTarif.Tarif_Members__r;
					
					List<Tarif_Member__c> TariffMembersToInsert 	= new List<Tarif_Member__c>();
					
                    if(!this.myTarif.Product_only__c) {
                        for (String key : this.mapSelectedServices.keySet()) {
                            Tarif_Member__c theServiceMember = new Tarif_Member__c(Tarif_Name__c = myTarif.Id, Id_Tarif_Item__c = key, Type__c = 'Service');
                            TariffMembersToInsert.add(theServiceMember);
                        }
                    }else{
                        // Delete the commissions if they are already associated with the Tarif
                        deleteCommissions();
                    }

                    for (String key : this.mapSelectedProducts.keySet()) {
                        Tarif_Member__c theProductMember = new Tarif_Member__c(Tarif_Name__c = myTarif.Id, Id_Tarif_Item__c = key, Type__c = 'Product');
                        TariffMembersToInsert.add(theProductMember);
                    }
                    
                    for (String key : this.mapSelectedAddOns.keySet()) {
                        Tarif_Member__c theAddOnMember = new Tarif_Member__c(Tarif_Name__c = myTarif.Id, Id_Tarif_Item__c = key, Type__c = 'AddOn');
                        TariffMembersToInsert.add(theAddOnMember);
                    }

                    insert TariffMembersToInsert;

                    this.reset();
                    this.reInitCountryAndCompanyDropdowns();

                    ClsUtilsApexPages.addInfoMessage( Label.Save_Edit_Tarif_Success);
                } catch (Exception e) {
                	Database.rollback(sp);
                    ApexPages.addMessages(e);
                    system.debug('@@@@ The following error occured while saving changes to the tarif with name : ' + myTarif.Name + ' : ' + e.getMessage());
                }
            }
        }
    }

	/**
	* @Description: populate the tarif name based on the country code 
	*/
	public String populateRecordType(){
		string recordType = '';
		if(!String.isBlank(this.selectedCountry)){
			for(SelectOption opt : this.countries){
				if(opt.getValue() == this.selectedCountry){
					if(CountryCompanyMapping__c.getInstance(opt.getLabel()) != null){
						string companyCode = CountryCompanyMapping__c.getInstance(opt.getLabel()).Company_code__c;
						recordType = companyCode + '_Tarif';
					}else{
						throw new SMCException('Country and company maping not present ' + opt.getValue());
					} 
				}
			}
		}
		
		return recordType;
	}
	

    /* Delete commissions if the Tarif is changed to Product Only tarif*/
    private void deleteCommissions(){
        List<Tarif_Member__c> tarifMembers = [SELECT Id,Id_Tarif_Item__c FROM Tarif_Member__c
                                                    WHERE Tarif_name__c =: this.myTarif.id];
        List<Tarif_Member__c> serviceMembers = new List<Tarif_Member__c>();
        for(Tarif_Member__c member : tarifMembers){
            if (getObject(member.Id_Tarif_Item__c) == 'List_Service_Price__c') {
                serviceMembers.add(member);
            }
        }

        if(serviceMembers.size() > 0){
            delete serviceMembers;
        }
    }

    public void cancel() {
        reset();
        this.reInitCountryAndCompanyDropdowns();
    }
    
    private String getCategories(List<SelectOption> categories){
    	String multiselectString = '';
    	for(SelectOption so : categories){
    		multiselectString += multiselectString == '' ? so.getValue() : ';' + so.getValue();
    	}
    	
    	return multiselectString;
    }
    
    private List<SelectOption> populateSelectedCategories(String categories){
    	List<SelectOption> options = new List<SelectOption>();
        if(!string.isBlank(categories)) {
            for (String cat : categories.split(';')) {
                options.add(new Selectoption(cat, cat));
            }
        }
    	return options;
   }
   
   private boolean isValid(){
   		Boolean isValid = true;
   		String missingFields = '';
   		if(this.selectedCountry == 'null' || this.selectedCountry == null || this.selectedCountry.length() == 0){
   			isValid = false;
   			missingFields = Label.country;
   		}
   		if(!this.myTarif.Is_Locked__c && (selectedCategories == null || selectedCategories.size() == 0)){
   			isValid = false;
   			missingFields += missingFields == '' ? Label.Category : ', ' + Label.Category;
   		}
   		
   		if(!isValid){
   			String errorString = Label.Required_Fields_Missing + ' [' + missingFields + ']';
   			ClsUtilsApexPages.addErrorMessage(errorString);
   			
   		}
   		
   		return isValid;
   }
   
   public class SMCException extends exception{}

}