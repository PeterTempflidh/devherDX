public with sharing class CtrAddOnManager extends ClsManagementConsoleBase{
    public List_Add_On__c newAddOnItem			{ get; set; }
    public String addOnId 						{ get; set; }
    
    public Map<String,List_Add_On__c> mapListAddOns {
        get {

            this.mapListAddOns = new Map<String, List_Add_On__c>();
            this.mapListAddOns.putall(this.listAddOns);

            return this.mapListAddOns;
        }        
       set;
   } 

    public List<List_Add_On__c> listAddOns {
        get{
            this.listAddOns = new List<List_Add_On__c>([
					                Select id, Name, CreatedDate, LastModifiedDate, LastModifiedBy.Name, Is_Active__c,
					                		Id_Country__c,Id_Country__r.name, Company__c,type__c,Contract_Addition__c,
                                            requires_approval__c,Requires_Esignature__c
					                FROM List_Add_On__c 
					                WHERE Id_Country__c IN : this.userCountryIds
					                AND Company__c IN : this.userCompanyIds
					                ORDER BY LastModifiedDate DESC
            ]);
			
			for(List_Add_On__c addOn : listAddOns){
				if(addOn.contract_Addition__c != null)
					addOn.contract_addition__c = addOn.contract_Addition__c.replaceAll('\n','<br/>');
			}
			
            return listAddOns;
        }
        set;
    }

    public CtrAddOnManager() {
        this.newAddOnItem = new List_Add_On__c();
    }

    private void reinit(){
        this.newAddOnItem = new List_Add_On__c();
    }

    public void cancel(){
         this.newAddOnItem = new List_Add_On__c(); 
         this.reInitCountryAndCompanyDropdowns();
    }
    
    public void addAddOn(){
        if(validate()){
                String recordTypeDeveloperName = this.determineCompanyCode() + '_List_Add_On';
                RecordType rt = LibRecordTypeHelper.getRecordType(recordTypeDeveloperName,  'List_Add_On__c');
                this.newAddOnItem.RecordTypeId = rt.Id;
                this.newAddOnItem.Id_Country__c = this.selectedCountry; 
                this.newAddOnItem.Company__c = this.selectedCompany;  
                try {
                    upsert this.newAddOnItem;
                    Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.INFO, Label.Add_On_Saved_Successfully + ' : ' + this.newAddOnItem.Name));
                    this.reinit();
                    this.reInitCountryAndCompanyDropdowns();
                } catch (Exception e){
                    System.debug('@@@@ The following error occured while saving an Add On : ' + e.getMessage());
                }
        } else {
            Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.ERROR, Label.SMC_AddON_Required_Fields_Missing));
        }
       
    }

    private boolean validate(){
        if(String.isNotBlank(this.selectedCompany) && String.isNotBlank(this.selectedCountry) &&
                this.newAddOnItem.Type__c != null && this.newAddOnItem.Contract_Addition__c != null &&
                this.newAddOnItem.name != null){
            return true;
        }else{
            return false;
        }
    }

    public void chooseAddOnToDelete(){
        this.newAddOnItem = this.mapListAddOns.get(this.addOnId);
    }

    public void editItem(){
        this.newAddOnItem 		= this.mapListAddOns.get(this.addOnId);
        if(this.newAddOnItem.contract_addition__c != null)
        	this.newAddOnItem.contract_addition__c = this.newAddOnItem.contract_addition__c.replaceAll('<br/>','\n');
        this.selectedCountry 	= this.newAddOnItem.Id_Country__c;
        this.selectedCompany 	= this.newAddOnItem.Company__c;
    }

    public void deleteItem(){
        String addOnName = this.mapListAddOns.get(this.addOnId).Name;

        try {
            delete this.mapListAddOns.get(this.addOnId);
            Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.INFO, Label.Add_On_Deleted_Successfully + ' : ' + addOnName));
            this.reinit();
            this.reInitCountryAndCompanyDropdowns();
        } catch (Exception e){
            Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.INFO, Label.Add_On_Delete_Error + ' : ' + addOnName));
            System.debug('@@@@ calling deleteItem in CtrProductGroupManager - The following error occurred while deleting a product group : ' + e.getMessage());
        }
    }
}