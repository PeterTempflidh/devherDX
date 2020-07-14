public with sharing class CtrProductGroupManager extends ClsManagementConsoleBase{
    public List_Product_Group__c newProductGroupItem { get; set; }
    public String productGroupId { get; set; }
    public Map<String,List_Product_Group__c> mapProductGroups {
        get {

            this.mapProductGroups = new Map<String, List_Product_Group__c>();
            this.mapProductGroups.putall(this.listProductGroups);

            return this.mapProductGroups;
        }        
       set;
   }

    public List<List_Product_Group__c> listProductGroups {
        get{
            this.listProductGroups = new List<List_Product_Group__c>([
                Select id, Name, CreatedDate, LastModifiedDate, LastModifiedBy.Name, In_Use__c, Id_Country__c,Id_Country__r.name, Company__c 
                FROM List_Product_Group__c 
                WHERE Id_Country__c IN : this.userCountryIds
                AND Company__c IN : this.userCompanyIds
                ORDER BY LastModifiedDate DESC
            ]);
            system.debug('$$$ listProductGroups '+listProductGroups);

            return listProductGroups;

        }
        set;
    }

    public CtrProductGroupManager() {
        this.newProductGroupItem = new List_Product_Group__c();
    }

    private void reinit(){
        this.newProductGroupItem = new List_Product_Group__c();
    }

    public void cancel(){
         this.newProductGroupItem = new List_Product_Group__c(); 
         this.reInitCountryAndCompanyDropdowns();
    }
    
    public void addProductGroup(){
        if((this.selectedCountry != 'null' && this.selectedCountry != null && this.selectedCountry.length() != 0) && 
            (this.selectedCompany != 'null' && this.selectedCompany != null && this.selectedCompany.length() != 0)){
                String recordTypeDeveloperName = this.determineCompanyCode() + '_List_Product_Group';
                RecordType rt = LibRecordTypeHelper.getRecordType(recordTypeDeveloperName,  'List_Product_Group__c');
                this.newProductGroupItem.RecordTypeId = rt.Id;
                system.debug('@@@@ addProductGroup - this.newProductGroupItem.RecordTypeId : ' + this.newProductGroupItem.RecordTypeId);
                this.newProductGroupItem.Id_Country__c = this.selectedCountry; 
                this.newProductGroupItem.Company__c = this.selectedCompany;  
                try {
                    upsert this.newProductGroupItem;
                    Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.INFO, Label.Product_Group_Saved_Successfully + ' : ' + this.newProductGroupItem.Name));
                    this.reinit();
                    this.reInitCountryAndCompanyDropdowns();
                } catch (Exception e){
                    System.debug('@@@@ The following error occured while inserting a product group : ' + e.getMessage());
                }
        } else {
            Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.ERROR, Label.SMC_Required_Fields_Missing));
        }
       
    }

    public void chooseProductGroupToDelete(){
        this.newProductGroupItem = this.mapProductGroups.get(this.productGroupId);
        System.debug('@@@@ calling chooseProductGroupToDelete - newProductGroupItem : ' + newProductGroupItem);
    }

    public void editItem(){
        this.newProductGroupItem = this.mapProductGroups.get(this.productGroupId);
        this.selectedCountry = this.newProductGroupItem.Id_Country__c;
        this.selectedCompany = this.newProductGroupItem.Company__c;
    }

    public void deleteItem(){
        String pgName = this.mapProductGroups.get(this.productGroupId).Name;
        System.debug('@@@@ calling deleteItem - pgName : ' + pgName);
        try {
            delete this.mapProductGroups.get(this.productGroupId);
            Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.INFO, Label.Product_Group_Deleted_Successfully + ' : ' + pgName));
            this.reinit();
            this.reInitCountryAndCompanyDropdowns();
        } catch (Exception e){
            if(e.getTypeName() == 'System.DMLException' && e.getMessage().contains('opportunity product')){
                Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.ERROR, Label.Product_Group_Delete_Error + ' : ' + Label.the_product_group_is_currently_in_use));    
                System.debug('@@@@ calling deleteItem in CtrProductGroupManager - The following error occurred while deleting a product group : ' + e.getMessage());
            }else{
                Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.INFO, Label.Product_Group_Delete_Error + ' : ' + pgName));
                System.debug('@@@@ calling deleteItem in CtrProductGroupManager - The following error occurred while deleting a product group : ' + e.getMessage());    
            }
            
        }
    }
}