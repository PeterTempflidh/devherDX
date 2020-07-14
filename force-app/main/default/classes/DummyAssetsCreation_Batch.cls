/***
 * @description Batch class for creation of dummy asset for all migrated active accounts
 *              that don't have any SIM Card or Tablet
 * @date 19.05.2020
 * @author Danish Farooq
 * #ticket : SSC-2928
 * @param {name} {description}
 */
global class  DummyAssetsCreation_Batch implements Database.Batchable<SObject>, Database.Stateful {

    global Integer sequenceNumberStock = 1;
    String assetType;
    List<String> lstCountries;
    String companyCode;
    /**
   * @description Batch class constructor
   * @param companyCode concatenate with recordtype dev Name to generate ID (e.g. FP,Talabat)
   * @param countries countries for which Dummy Assets will be created
   * @param assetType Type of Assets (e.g Sim , Tablet)
   */
    global DummyAssetsCreation_Batch(String companyCode, String countries, String assetType) {

        this.assetType = assetType;
        this.lstCountries = (String.isNotBlank(countries) ? countries.split(',') : new List<string>());
        this.companyCode = companyCode;
    }
    /**
  * @description Batch class Start
  * @param bc BatchableContext
  * @return list of records from query locator
  */
    global Database.QueryLocator start(Database.BatchableContext bc) {

        String assetQueryClause = '%' + assetType + '%';
        return Database.getQueryLocator([
                SELECT id, record_country__c, currencyisocode, Account_Country_Code__c, GRID__c
                FROM account
                WHERE Account_status__c = 'Active' AND
                record_country__c IN :lstCountries AND ID NOT IN (
                SELECT account__c
                FROM asset__c
                WHERE name LIKE :assetQueryClause
                AND account__r.record_country__c IN :lstCountries
                )
        ]);
    }
    /**
    * @description Batch class Execute
    * @param bc BatchableContext
    * @param scope list of sobject
    */
    global void execute(Database.BatchableContext bc, List<SObject> scope) {

        Savepoint sp = Database.setSavepoint();
       try {
            LoggingUtility.createLog('DummyAssetsCreation_Batch', 'BATCH', 'Validate Email Flag', null);
            Map<ID, Account> mapOfAccountsByIds = new Map<ID, Account>((List<Account>) scope);
            List <Stock_item__c> lstStockItems = createStocks(mapOfAccountsByIds);
            insert lstStockItems;
            List <Asset__c> lstAssets = createAssets(lstStockItems, mapOfAccountsByIds);
            insert lstAssets;
       }
        catch(Exception ex){
            Database.rollback(sp);
            LoggingUtility.logError('DummyAssetsCreation_Batch','Error :' + ex.getMessage() + ';Line No : ' + ex.getLineNumber()
                                        + ';Stack Trace : ' + ex.getStackTraceString());
            LoggingUtility.commitLogs();
        }
    }
    /**
   * @description Batch class Finish
   * @param bc BatchableContext
   */
    global void finish(Database.BatchableContext bc) {
    }
    /**
    * @description create stock items
    * @param accountMap Map of Account
    * @return list of stock item to be insert
    */
    private List <Stock_item__c> createStocks(Map<ID, Account> accountMap) {

        List <Stock_item__c> lstStockItems = new List <Stock_item__c>();
        String stockItemRecordTypeId = LibRecordTypeHelper.getRecordTypeIdByDeveloperName('Stock_Item__c', companyCode + '_Stock_Item');
        String stockName = '';
        for (Account iAcc : accountMap.values()) {
            stockName = iAcc.Account_Country_Code__c + ' - Unknown ' + assetType + ' ' + sequenceNumberStock;
            lstStockItems.add(new Stock_item__c(
                    name = stockName,
                    Currencyisocode = iAcc.currencyisocode,
                    Account_Country__c = iAcc.record_country__c,
                    Status__c = 'In Stock',
                    Stock_Item_Ownership__c = 'Restaurant',
                    ID_Account__c = iAcc.Id,
                    Type__c = 'Original',
                    recordtypeid = stockItemRecordTypeId));
            sequenceNumberStock++;
        }

        return lstStockItems;
    }
    /**
   * @description create asset
    * @param lstStockItems list of stock item
    * @param accountMap Map of Account
    * @return list of asset to be insert
   */
    private List <Asset__c> createAssets(List <Stock_item__c> lstStockItems, Map<ID, Account> accountMap) {

        List <Asset__c> lstAssets = new List <Asset__c>();
        String assetRecordTypeId = LibRecordTypeHelper.getRecordTypeIdByDeveloperName('Asset__c', companyCode + '_Asset');
        for (Stock_item__c iStockItem : lstStockItems) {
            lstAssets.add(new Asset__c(
                    name = iStockItem.Name,
                    Currencyisocode = iStockItem.currencyisocode,
                    Account_Country__c = iStockItem.Account_country__c,
                    recordtypeid = assetRecordTypeId,
                    Account__c = iStockItem.ID_Account__c,
                    Stock_item__c = iStockItem.ID,
                    type__c = 'Original',
                    Status__c = 'Activated Successfuly',
                    GRID__c = (accountMap.containsKey(iStockItem.ID_Account__c) ? accountMap.get(iStockItem.ID_Account__c).GRID__c : '')));
        }
        return lstAssets;
    }
}