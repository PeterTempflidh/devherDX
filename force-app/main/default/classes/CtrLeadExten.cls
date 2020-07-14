/*
@author : Tajinder Singh
@creation : 08.11.2016
@description:   To add a new country check for the recordtype developersname and construct
        a new method based on its own logic how to parse the postcode. Populate the lists
        'getSurGeoCodes' and 'getSurAccounts'.  On the VF page there is a check if 'getSurGeoCodes'
        is empty. if so a default map is displayed with this currentRecord address details. otherwise list is parsed and geocode
        locations are constructed. 
*/

global with sharing class CtrLeadExten {
    
    public List<Lead> getSurGeoCodes{get;set;}
    public List<Account> getSurAccounts{get;set;} 
    public Boolean listEmpty{get;set;}
    private String postCode;
    //private String recordTypeDevName;
    private Lead currentRecord;
    public List<recordMap> getLeadAcc {get;set;}
    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    private static Map<String, Map<String, Business_Config__c>> mapProcessData = moam.get('Lead Conversion');
    private Map<String, Business_Config__c> mapBusinessData { get; set; }
    public Boolean DisplayButtonDistance {get;set;}
    public Boolean DisplayButtonPostCode {get;set;}
    private Decimal distanceInKm{get;set;}

    public CtrLeadExten(ApexPages.StandardController controller){
        this.currentRecord = (Lead)controller.getRecord();
        getLeadAcc=new List<recordMap>();
        this.DisplayButtonDistance=false;
        
        this.mapBusinessData = mapProcessData.get(LibRecordTypeHelper.getRecordTypeValue(this.currentRecord.RecordTypeId));
        if(this.mapBusinessData!=null && !this.mapBusinessData.isEmpty()){
            
            if(this.mapBusinessData.get('LeadMapDisplay').Business_Rule_Value__c!=null){
                if(mapBusinessData.get('LeadMapDisplay').Business_Rule_Value__c.containsIgnoreCase('Distance') && this.mapBusinessData.get('LeadMapDefault').Business_Rule_Value__c!='Distance'){
                    this.DisplayButtonDistance=true;
                    this.DisplayButtonPostCode=false;
                }else if(mapBusinessData.get('LeadMapDisplay').Business_Rule_Value__c.containsIgnoreCase('Postcode')  && this.mapBusinessData.get('LeadMapDefault').Business_Rule_Value__c!='Postcode'){
                    this.DisplayButtonDistance=false;
                    this.DisplayButtonPostCode=true;
                }
            }
            if(this.mapBusinessData.get('LeadMapDefaultDistance')!=null){
                this.distanceInKm=Decimal.valueOf(this.mapBusinessData.get('LeadMapDefaultDistance').Business_Rule_Value__c);
                system.debug(this.distanceInKm);

            }
            if(this.mapBusinessData.get('LeadMapDefault')!=null )               
                getCodes(this.mapBusinessData.get('LeadMapDefault').Business_Rule_Value__c);
        }
        
        
        // add following countries and construct method. 
    }
    
    /*private void buildListwithUkPostCodes(){
        
    this.postCode = (String)this.currentRecord.PostalCode.substringBefore(' ') + '%';
      this.listEmpty = true;
 
      this.getSurGeoCodes = [Select Id,Name,Status,PostalCode,Restaurant_Name__c,street,Vendor_Grade__c,Last_Call_Date__c,Phone,Longitude,Latitude from Lead 
                               where PostalCode like: this.postCode AND recordTypeId =:this.currentRecord.recordTypeId AND street!=null AND
                 id!=: this.currentRecord.id AND status NOT IN ('Converted','New') and 
                               lost_reason__c NOT IN ('Do not contact','Duplicates',
                                                      'Invalid data','Fraud Restaurant',
                                                       'Low Rating','Hygiene Rating',
                                                       'Closed Down') ORDER BY Longitude DESC,Latitude DESC];

        for(Lead l:this.getSurGeoCodes){
          system.debug(getSurGeoCodes);
          getLeadAcc.add(new recordMap(l));

        }
        if(!(this.getSurGeoCodes.isEmpty())){
            this.listEmpty = false;
        }
         system.debug(this.getSurGeoCodes);

     
        //System.debug('sorting' + this.getSurGeoCodes);
        this.getSurAccounts = [select name,billingstreet,phone,Online_Status_Backend__c,billingLatitude,billingLongitude from account where billingpostalcode like: this.postCode];
        for(Account a:this.getSurAccounts){
          getLeadAcc.add(new recordMap(a));

        }

        system.debug(getLeadAcc);
    }*/
    //get leads and accounts by distance
    public void getCodesByDistance(){
        getCodes('Distance');
         this.DisplayButtonDistance=false;
         this.DisplayButtonPostCode=true;
    }

    public void getCodesByPostcode(){
        getCodes('Postcode');
         this.DisplayButtonDistance=true;
         this.DisplayButtonPostCode=false;
    }

    public void getCodes(String queryType){
        double lat = this.currentRecord.latitude;
        double lon = this.currentRecord.longitude;
        Id recType =this.currentRecord.recordTypeId;
        Id ldID = this.currentRecord.id;
        this.postCode = (String)this.currentRecord.PostalCode.substringBefore(' ') + '%';
        this.listEmpty = true;
        this.getLeadAcc=new List<recordMap>();
        
        system.debug(this.currentRecord.recordTypeId);
        String ldQuery='Select Id,Name,Status,PostalCode,Restaurant_Name__c,street,Vendor_Grade__c,Last_Call_Date__c,Phone,Longitude,Latitude,Address from Lead where';
        if(queryType=='Distance')
            ldQuery+= ' (DISTANCE(Address, GEOLOCATION('+lat+','+lon+'), \'km\') < '+this.distanceInKm+' OR postalCode like \''+postCode+'\')';
        else
            ldQuery+= ' postalCode like \''+postCode+'\'';
        ldQuery+=' AND recordTypeId =\''+recType+'\' AND street!=null AND id!=\''+ldID+'\' AND status NOT IN (\'Converted\',\'New\') and';
        ldQuery+=' lost_reason__c NOT IN (\'Do not contact\',\'Duplicates\',\'Invalid data\',\'Fraud Restaurant\',';
        ldQuery+=' \'Low Rating\',\'Hygiene Rating\',\'Closed Down\') ORDER BY Longitude DESC,Latitude DESC';
                                                       
        system.debug(ldQuery);
        this.getSurGeoCodes = Database.query(ldQuery);
        if(!(this.getSurGeoCodes.isEmpty())){
            this.listEmpty = false;
        }
        system.debug(this.getSurGeoCodes);
        system.debug(this.getSurGeoCodes);
        for(Lead l:this.getSurGeoCodes){
          getLeadAcc.add(new recordMap(l));
        }
        String accQuery='select name,billingstreet,phone,Online_Status_Backend__c,Branding_Status__c,billingLatitude,billingLongitude from account where Online_Status_Backend__c=\'Online\' and ';
        if(queryType=='Distance')
            accQuery+='  (DISTANCE(billingAddress, GEOLOCATION('+lat+','+lon+'), \'km\') < '+this.distanceInKm+' OR billingpostalcode like \''+postCode+'\')';
        else
            accQuery+=' billingpostalcode like \''+postCode+'\'';
        accQuery+=
        this.getSurAccounts = Database.query(accQuery);
        system.debug(this.getSurAccounts);
        for(Account a:this.getSurAccounts){
            getLeadAcc.add(new recordMap(a));
        }

       if(!(this.getSurGeoCodes.isEmpty())){
            this.listEmpty = false;
        }

        system.debug(getLeadAcc);
    }

    public Class recordMap{
        public String name{get;set;}
        public String recId{get;set;}
        public double lt{get;set;}
        public double lng{get;set;}
        public string rcType{get;set;}
      

        public recordMap(Lead ld){
            system.debug(ld);
            this.name=ld.Restaurant_Name__c;
            this.recId=ld.Id;
            this.lt=ld.latitude;
            this.lng=ld.longitude;
            this.rcType='Lead';

        }

        public recordMap(Account acc){
            this.name=acc.Name;
            this.recId=acc.Id;
            this.lt=acc.Billinglatitude;
            this.lng=acc.Billinglongitude;
            this.rcType='Account';
        }
    }  
}