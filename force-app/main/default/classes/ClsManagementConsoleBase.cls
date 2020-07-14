public virtual with sharing class ClsManagementConsoleBase {
	public List<SelectOption> countries { get; set; }
    public String selectedCountry { get; set; }
    public String defaultCountry { get; set; }
    public List<Company__c> companyList { get; set; }
    public List<SelectOption> companies { get; set; } 
    public String selectedCompany { get; set; }
    public String defaultCompany { get; set; }
    public Set<Id> userCompanyIds { get; set; }
    public Set<Id> userCountryIds { get; set; }
    public Boolean showCountryDropdown { get; set; }
    public Boolean showCompanyDropdown { get; set; }
    public Boolean hideCountryDropdown { get; set; }
    public Boolean hideCompanyDropdown { get; set; }

	public ClsManagementConsoleBase() {
		this.createCountryAndCompanyDropdownData();
	}

	private void createCountryAndCompanyDropdownData(){
        this.countries = new List<SelectOption>();
        this.countries.add(new SelectOption('null',Label.SMC_Please_Select_A_Country));
        this.companies = new List<SelectOption>();
        this.companies.add(new SelectOption('null',Label.SMC_Please_Select_A_Company));
        this.userCountryIds = new Set<Id>();
        this.userCompanyIds = new Set<Id>();

        List<Country__c> countryList = LibBusinessConfig.getUserCountries();
        for(Country__c country : countryList){
            this.userCountryIds.add(country.Id);
            this.countries.add(new SelectOption(country.Id, country.Name));
        }

        this.companyList = LibBusinessConfig.getUserCompanies();
        for(Company__c company: companyList){
            this.userCompanyIds.add(company.Id);
            this.companies.add(new SelectOption(company.Id, company.Name));
        }
        
        if(this.userCountryIds.size() != 1){
            this.showCountryDropdown = true;
            this.hideCountryDropdown = false;
        } else {
            this.showCountryDropdown = false;
            this.hideCountryDropdown = true;
            this.defaultCountry = this.countries[1].getLabel();
            this.selectedCountry = this.countries[1].getValue();
        }

        if(this.userCompanyIds.size() != 1){
            this.showCompanyDropdown = true;
            this.hideCompanyDropdown = false;
        } else {
            this.showCompanyDropdown = false;
            this.hideCompanyDropdown = true;
            this.defaultCompany = this.companies[1].getLabel();
            this.selectedCompany = this.companies[1].getValue();
        }
    }

    public String determineCompanyCode(){
        for(Company__c comp : this.companyList){
            if(this.selectedCompany == String.valueOf(comp.Id)){
                return comp.Company_Code__c;
            }
        }
        return null;
    }

    public void reInitCountryAndCompanyDropdowns(){
        if(this.userCountryIds.size() != 1){
            this.selectedCountry = 'null';
        }
        if(this.userCompanyIds.size() != 1){
           this.selectedCompany  = 'null'; 
       }
    }

    public Boolean updateItem(){
    	if((this.selectedCountry != 'null' && this.selectedCountry != null && this.selectedCountry.length() != 0) && 
            (this.selectedCompany != 'null' && this.selectedCompany != null && this.selectedCompany.length() != 0)){
    		return true;
    	} else {
    		return false;
    	}
    }
}