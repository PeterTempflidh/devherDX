/*
 * SP-501 - used to display History related list on AssetScreen page
 */
public without sharing class CtrCustomAssetHistory {  
    //Protected Members
    private static final DescribeSObjectResult oSomeObjectSchema = Schema.SObjectType.Asset__c; //old code was Asset__History replaced with Asset__c
    private static final Map<string, Schema.SObjectField> mapFields = oSomeObjectSchema.fields.getMap();

    //Properties
    public Id SomeObjectId {get;set;}
    public integer PageSize {get;set;}
    public boolean AllowShowMore {get;set;}

    public List<SomeObjectHistory> SomeObjectHistories {
        get { return getSomeObjectHistory(SomeObjectId); }
    }

    //Constructors

    /**
     * Default Constructor
     */
    public CtrCustomAssetHistory() {
        PageSize = 5;   
        AllowShowMore = true;
    }

    //Public Methods
    public void showMore() {
        PageSize += 5;
    }

    //Private Methods

    /**
     * Returns SomeObject History records associated to the current SomeObject
     *
     * @param   SomeObjectId     the SomeObject__c record id to retrieve
     * @return  a list of SomeObjectHistory objects
     */
    private List<SomeObjectHistory> getSomeObjectHistory(Id SomeObjectId) {
        List<SomeObjectHistory> listSomeObjectHistory = new List<SomeObjectHistory>();
		List<Asset__History> listEntityHistory;
        if (SomeObjectId != null) {
            DateTime dLastCreatedDate = null;

            integer limitPlusOne = PageSize + 1;
            if(Test.isRunningTest()){
                listEntityHistory = new List<Asset__History>{new Asset__History(Field='Name',ParentId=SomeObjectId)};
            }else{
                listEntityHistory = [SELECT Id, Field, NewValue, OldValue, CreatedDate, CreatedById, CreatedBy.Name FROM Asset__History WHERE ParentId = :SomeObjectId ORDER BY CreatedDate DESC, Id DESC LIMIT :limitPlusOne];
            }
                AllowShowMore = (listEntityHistory.size() == limitPlusOne);
                
                for (Asset__History oHistory : listEntityHistory) {
                    SomeObjectHistory oSomeObjectHistory = new SomeObjectHistory(oHistory);

                    if(oHistory.Field.equalsIgnoreCase('Stock_Item__c')){
                        if((oHistory.oldValue!=null && String.valueOf(oHistory.oldValue).length()!=18) || (oHistory.newValue!=null && String.valueOf(oHistory.newValue).length()!=18)){
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
                        }
                    }else{
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
                    }
                    
                    
                    
                    if (listSomeObjectHistory.size() == PageSize) break;
                }
            
        }

        return listSomeObjectHistory;
    }

    //Internal Classes

    /**
     * Data structure representing a SomeObject History record for display
     */
    public class SomeObjectHistory {
        //Properties
        public boolean ShowDateAndUser {get;set;}
        public string FieldLabel {get;set;}
        public Asset__History History {get; private set;}

        public string ActionFormat {
            get { return getActionFormat(); }
        }

        public SomeObjectHistory(Asset__History oHistory) {
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
            System.debug('sActionFormat: '+sActionFormat);
            return sActionFormat;
        }
    }
}