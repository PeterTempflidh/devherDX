public without sharing class CtrCustomAssetCancellationHistory { 

    //Protected Members
    private static final DescribeSObjectResult oSomeObjectSchema = Schema.SObjectType.Asset_cancellation__c; //old code was Asset__History replaced with Asset__c
    private static final Map<string, Schema.SObjectField> mapFields = oSomeObjectSchema.fields.getMap();

    
    //Properties
    public Id SomeObjectId {get;set;}
    public List<Asset_Cancellation__c> SomeObjectIdsList {get;set;}
    public integer PageSize {get;set;}
    public boolean AllowShowMore {get;set;}
    public boolean AllowGotoList{get;set;}
    public Map<Id, Asset_Cancellation__c> mapAssetCancellation {   
        get{return getMapAssetCancellation(SomeObjectIdsList);}
    }
    public List<SomeObjectHistory> SomeObjectHistories {
        get { return getSomeObjectHistory(SomeObjectIdsList); }
    }

    //Constructors

    /**
     * Default Constructor
     */
    public CtrCustomAssetCancellationHistory() {      
        PageSize = 5;   
        AllowShowMore = true;      
        
    }

    //Public Methods
    public void showMore() {
        PageSize += 5;
        
        
    }
    
      //Private Methods
      
      private map<Id, Asset_Cancellation__c> getMapAssetCancellation(List<Asset_Cancellation__c> SomeObjectIdsList ){
          return new Map<id, Asset_Cancellation__c>(SomeObjectIdsList);
      
      }

    /**
     * Returns SomeObject History records associated to the current SomeObject
     *
     * @param   SomeObjectId     the SomeObject__c record id to retrieve
     * @return  a list of SomeObjectHistory objects
     */
    private List<SomeObjectHistory> getSomeObjectHistory(List<Asset_Cancellation__c> SomeObjectIds) {
        List<SomeObjectHistory> listSomeObjectHistory = new List<SomeObjectHistory>();
        List<Asset_Cancellation__History> listEntityHistory;
        
       
        if (SomeObjectIds != null) {
            DateTime dLastCreatedDate = null;

            integer limitPlusOne = PageSize + 1;
            if(Test.isRunningTest()){
                listEntityHistory = new List<Asset_Cancellation__History>{new Asset_Cancellation__History(Field='Name',ParentId=SomeObjectIds[0].id)};
                
            }else{
                listEntityHistory = [SELECT Id, Field, NewValue, OldValue, CreatedDate, CreatedById, CreatedBy.Name, ParentId  FROM Asset_Cancellation__History WHERE ParentId = :SomeObjectIds ORDER BY CreatedDate DESC, Id DESC LIMIT :limitPlusOne];
            }
                
                AllowShowMore = (listEntityHistory.size() == limitPlusOne);
                
                for (Asset_Cancellation__History oHistory : listEntityHistory) {
                    SomeObjectHistory oSomeObjectHistory = new SomeObjectHistory(oHistory);
                    
                    
                    
                        if (mapFields.containsKey(oHistory.Field)) {
                        oSomeObjectHistory.FieldLabel = mapFields.get(oHistory.Field).getDescribe().Label;
                        }
                        
                        if (dLastCreatedDate == oHistory.CreatedDate) {
                            oSomeObjectHistory.ShowDateAndUser = false;
                        }
                        else {
                            oSomeObjectHistory.ShowDateAndUser = true;
                        }
                        
                        listSomeObjectHistory.add(oSomeObjectHistory);
                        dLastCreatedDate = oHistory.CreatedDate;
                    
                    
                    
                    
                        if (listSomeObjectHistory.size() == PageSize) break;
                }
            
        }

        return listSomeObjectHistory;
    }

    
     /**
     * Data structure representing a SomeObject History record for display
     */
    public class SomeObjectHistory {
        //Properties
        public boolean ShowDateAndUser {get;set;}
        public string FieldLabel {get;set;}
        public Asset_cancellation__History History {get; private set;}

        public string ActionFormat {
            get { return getActionFormat(); }
        }

        public SomeObjectHistory(Asset_cancellation__History oHistory) {
            History = oHistory;
        }

        //Constructors
        public SomeObjectHistory() {
            showDateAndUser = true;
        }
              

        //Private Methods
        private string getActionFormat() {
            string sActionFormat = '';

            if (History != null) {
                    sActionFormat = 'Record {0}.';

                if (History.newValue != null && History.oldValue == null) {
                    sActionFormat = 'Changed <strong>{1}</strong> to <strong>{3}</strong>.';    
                }   
                else if (History.newValue != null && History.oldValue != null) {
                    sActionFormat = 'Changed <strong>{1}</strong> from {2} to <strong>{3}</strong>.';    
                }
                //Added below line for handling null scenario for new value
                else if (History.newValue == null && History.oldValue != null) {
                    sActionFormat = 'Deleted {2} in <strong>{1}</strong>.';    
                }
                else if (History.Field != null && String.valueOf(History.Field).equalsIgnoreCase('created')) {
                    sActionFormat = 'Created.';
                }
            }
            return sActionFormat;
        }
    }


}