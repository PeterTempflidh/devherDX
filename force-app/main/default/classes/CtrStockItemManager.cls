global with sharing class CtrStockItemManager {
    
    public Stock_Item__c generalStockItem {Get;Set;}
    //public Asset__c generalAsset {Get;Set;}

    public List<SelectOption> listAssetSelection {Get;Set;}
    public  String assetSelected {Get;Set;}

    /*public RecordType assetRecordType{
        get {
            if(assetRecordType == null){
                assetRecordType = LibBusinessConfig.getRecordTypeId('Asset');
            }
            return assetRecordType;
        }
        set;
    }*/

    public CtrStockItemManager() {

        this.generalStockItem = new Stock_Item__c();
        //this.generalAsset = new Asset__c();

        this.listAssetSelection = new List<SelectOption>();
        this.listAssetSelection.add(new SelectOption('null','--None-'));
        /*for(Asset__c ass : [SELECT Id, Name FROM Asset__c WHERE RecordTypeId =: this.mapBusinessLogic.get(thisUser.Country)]){
            this.listAssetSelection.add(new SelectOption(ass.Id,ass.Name));
        }*/
        /*for(Asset__c ass : [SELECT Id, Name FROM Asset__c WHERE RecordTypeId =: this.assetRecordType.Id]){
            this.listAssetSelection.add(new SelectOption(ass.Id,ass.Name));
        }*/
    }
    @RemoteAction
    global static String save(String parameter){

        List<Stock_Item__c> listStockItemsToInsert = new List<Stock_Item__c>();

        JSONParser parser = JSON.createParser(parameter);
        while(parser.nextToken() != null){
             if (parser.getCurrentToken() == JSONToken.START_ARRAY) { //beginning of item array
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) { //beginning of item
                        StockItemJSON theStockItemWrapper = (StockItemJSON)parser.readValueAs(StockItemJSON.class);
                        listStockItemsToInsert.add(new Stock_Item__c(
                                                        Date_arrived__c = Date.parse(theStockItemWrapper.arrivalDate),
                                                        Date_ordered__c = Date.parse(theStockItemWrapper.orderDate),
                                                        Production_date__c = Date.parse(theStockItemWrapper.productionDate),
                                                        Type__c = theStockItemWrapper.type,
                                                        Simcard_number__c = theStockItemWrapper.simcardNumber,
                                                        Simcard_provider__c = theStockItemWrapper.simcardProvider
                                                    ));
                    }
                }
            }
        }
        

        insert listStockItemsToInsert;



        if(parameter.contains('type')){
            return 'ok';    
        }
        return 'not ok';
    }



    public class StockItemJSON {
        public String terminalType {get;set;}
        public String productionDate {get;set;}
        public String orderDate {get;set;}
        public String arrivalDate {get;set;}
        public String type {get;set;}
        public String simcardProvider {get;set;}
        public String simcardNumber {get;set;}
        public String assetId {get;set;}

        public StockItemJSON(String terminalType, String productionDate, String orderDate, String arrivalDate, String type, String simcardProvider, String simcardNumber, String assetId){
            this.terminalType = terminalType;
            this.productionDate = productionDate;
            this.orderDate = orderDate;
            this.arrivalDate = arrivalDate;
            this.type = type;
            this.simcardProvider = simcardProvider;
            this.simcardNumber = simcardNumber;
            this.assetId = assetId;
        }
    }

}