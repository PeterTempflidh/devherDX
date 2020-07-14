public with sharing class CtrserviceManager extends ClsManagementConsoleBase {
	
	private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    private Map < String, Business_Config__c > mapBusinessData {
        get;
        set;
    }
    public Map < String, Map < String, Business_Config__c >> mapProcessData {
        get;
        set;
    }
    public List_Service_Price__c myService {
        Get;
        Set;
    }
    public Boolean showParentLookup {
        get;
        set;
    }
    public Boolean showServiceType {
        get;
        set;
    }
    public Boolean readOnlyCommissionType {
        get;
        set;
    }
    public Boolean showCommissionPerOrder {
        get;
        set;
    }
    //SP-682
    public Boolean showRequiresApproval {
        get;
        set;
    }
    public Map < String, List_Service_Price__c > mapMyServices {
        Get {
            this.mapMyServices = new Map < String, List_Service_Price__c > ();
            this.mapMyServices.putAll(this.listServices);

            return this.mapMyServices;
        }
        Set;
    }

    public List < List_Service_Price__c > listServices {
        Get {
            return this.listServices = ListServicePriceSelector.getActiveServicesForAccounts(this.userCountryIds,this.userCompanyIds).values();
        }
        Set;
    }

    public String serviceId {
        Set {
            serviceId = value;
        }
        Get;
    }

    public CtrserviceManager() {
        this.readOnlyCommissionType = false;
        system.debug('CtrserviceManager ');
        this.myService = new List_Service_Price__c();
        this.myService.Commission_Type__c = 'Percentage';
        mapProcessData = moam.get('SalesManagementProcessService');
        this.showCommissionPerOrder = false;
        this.showServiceType = false;
        this.setShowServiceType();
        this.setShowRequiresApproval();
        this.determineCompanyCode();


    }

    public void toggleComponents() {
        this.setShowServiceType();
        //this.setShowRequiresApproval();
    }
    //SP-682
    public void toggleRequiredApprovalFlag() {
        this.setShowRequiresApproval();
    }
    //SP-682
    public void setShowRequiresApproval() {
        if (this.determineCompanyCode() != null) {
            System.debug('$$$ companyCode: ' + this.determineCompanyCode());
            if (mapProcessData.get(this.determineCompanyCode() + '_List_Service_Price').get('showRequiresApprovalSwitch') != null && this.myService.Commission_Type__c == 'Per Order') {
                System.debug('businessConfig: ' + mapProcessData.get(this.determineCompanyCode() + '_List_Service_Price').get('showRequiresApprovalSwitch'));
                this.showRequiresApproval = Boolean.valueOf(mapProcessData.get(this.determineCompanyCode() + '_List_Service_Price').get('showRequiresApprovalSwitch').Business_Rule_Value__c);
            } else {
                this.showRequiresApproval = false;
            }
        } else {
            System.debug('$$$ companyCode is null!');
            this.showRequiresApproval = false;
        }
    }

    public void setShowServiceType() {
        if (this.determineCompanyCode() != null) {
            if (!mapProcessData.isEmpty()) {
                this.mapBusinessData = mapProcessData.get(this.determineCompanyCode() + '_List_Service_Price');
                this.myService.RecordTypeId = LibRecordTypeHelper.getRecordType(this.determineCompanyCode() + '_List_Service_Price', 'List_Service_Price__c').Id;
                if (this.mapBusinessData != null && !this.mapBusinessData.isEmpty()) {
                    if (this.mapBusinessData.get('useServiceTypes') != null && (String.isNotBlank(this.mapBusinessData.get('useServiceTypes').Business_Rule_Value__c) && this.mapBusinessData.get('useServiceTypes').Business_Rule_Value__c != 'false')) {
                        this.showServiceType = true;
                    } else {
                        this.showServiceType = false;
                    }
                    if (this.mapBusinessData.get('showCommissionPerOrder') != null && Boolean.valueOf(this.mapBusinessData.get('showCommissionPerOrder').Business_Rule_Value__c)) {
                        this.showCommissionPerOrder = true;
                    } else {
                        this.showCommissionPerOrder = false;
                    }
                }

            }
        } else {
            this.showServiceType = false;
        }
    }

    public void cancel() {
        this.readOnlyCommissionType = false;
        this.showCommissionPerOrder = false;
        this.myService = new List_Service_Price__c();
        this.myService.Commission_Type__c = 'Percentage';
        this.reInitCountryAndCompanyDropdowns();
        this.setShowServiceType();
        this.setShowRequiresApproval();
    }

    public void addService() {
        if (this.updateItem()) {
            try {
                String recordTypeDeveloperName = this.determineCompanyCode() + '_List_Service_Price';
                this.mapBusinessData = mapProcessData.get(recordTypeDeveloperName);
                if (this.mapBusinessData.get('useServiceTypes') != null && (String.isNotBlank(this.mapBusinessData.get('useServiceTypes').Business_Rule_Value__c) && this.mapBusinessData.get('useServiceTypes').Business_Rule_Value__c != 'false')) {
                    if (this.myService.Service_Type__c == null) {
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, Label.SMC_Service_Type_Missing));
                        return;
                    }
                }
                RecordType rt = LibRecordTypeHelper.getRecordType(recordTypeDeveloperName, 'List_Service_Price__c');
                this.myService.RecordTypeId = rt.Id;
                this.myService.Id_Country__c = this.selectedCountry;
                this.myService.Company__c = this.selectedCompany;
                if(!this.myService.Scaled__c){
                    this.myService.Based_On__c = null;
                }
                if (this.myService.Commission_Type__c == 'Percentage') {
                    this.myService.Commission_Per_Order__c = null;
                } else if (this.myService.Commission_Type__c == 'Per Order') {
                    this.myService.Commission_In_Percentage__c = null;
                    this.myService.Minimum_Commission_in_Percentage__c = null;
                    this.myService.Maximum_Commission_In_Percentage__c = null;
                }
                if (validateServiceName(this.myService)) {
                    upsert this.myService;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Save_Service_Successful + ' : ' + this.myService.Name));
                    this.readOnlyCommissionType = false;
                    this.myService = new List_Service_Price__c();
                    this.myService.Commission_Type__c = 'Percentage';
                    this.reInitCountryAndCompanyDropdowns();
                    this.setShowServiceType();
                    this.showCommissionPerOrder = false;
                } else {
                    this.myService.addError('Commission name is already in use. Commission name needs to be unique. Please use Display Name field to create Name that will be displayed on Quote');
                }
            } catch (Exception e) {
                system.debug('@@@@ calling addService in CtrserviceManager - The following error occured while add a service : ' + e.getMessage() + ' ' + e.getTypeName());
                /*if(e.getMessage().contains('parent service')){
                Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.ERROR, Label.SMC_ParentId_missing));
                }*/
                Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.ERROR,'Error ' + e.getStackTraceString()));
            }
        } else {
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, Label.SMC_Required_Fields_Missing));
        }
    }

    public boolean validateServiceName(List_Service_Price__c servicePrice) {
        List<List_Service_Price__c> servicePriceList = [SELECT Id FROM List_Service_Price__c WHERE Name = :servicePrice.Name AND RecordTypeId = :servicePrice.RecordTypeId AND Id_Country__c = :servicePrice.Id_Country__c];
        if (servicePriceList.size() == 0)
            return true;
        else if (servicePriceList.size() == 1) {
            if (servicePrice.Id == servicePriceList[0].Id) {
                return true;
            } else {
                return false;
            }
        } else return false;
    }

    public void chooseServiceToDelete() {
        this.myService = this.mapMyServices.get(this.serviceId);
    }

    public void deleteItem() {
        String serviceName = this.mapMyServices.get(this.serviceId).Name;
        try {
            delete this.mapMyServices.get(this.serviceId);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Delete_Service_Successful + ' : ' + serviceName));
            this.myService = new List_Service_Price__c();
        } catch (Exception e) {
            if (e.getTypeName() == 'System.DMLException' && e.getMessage().contains('opportunity service')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Delete_Service_Error + ' : ' + Label.the_service_is_currently_in_use));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Delete_Service_Error + ' : ' + serviceName));
            }
        }
    }

    public void editItem() {
        this.myService = this.mapMyServices.get(this.serviceId);
        this.readOnlyCommissionType = true;
        System.debug('this.myService: ' + this.myService.Is_Active__c);
        this.selectedCountry = this.myService.Id_Country__c;
        this.selectedCompany = this.myService.Company__c;
        this.setShowServiceType();
        this.setShowRequiresApproval();
    }
}