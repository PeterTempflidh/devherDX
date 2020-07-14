/* @author Chaitali Kumari
* @date 13.05.2019*
* @description Selector class to retrieve List Product Price records
*/

public with sharing class ListProductPriceSelector {

    /*******************************************************************************************************
   * @description Queries to get List Product Price record based on Name
   * @param String Record Type developerName (String), Record Country (String)
   * @return List of List Product Price
   */

    public static List<List_Product_Price__c> findListProdPriceByrecTypeandCountry(String recordType, String recCountry) {
        List<List_Product_Price__c> listProductPrice;
        try {
            listProductPrice = [select id,Displayed_Name__c,company__r.name,
                                Default_Quantity__c,Id_List_Product_Group__r.Name,
                                Product_Type__c,Product_Name__c
                               from List_Product_Price__c
                               where RecordType.DeveloperName = : recordType
                               and id_country__r.name=:recCountry];
        } catch(Exception e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return listProductPrice;
    }
    
     /*******************************************************************************************************
    * @description Query List_Product_Price__c via record type name and product name values
    * @param recordTypeSet - record type api-name record set, productNames - set of products
    * @return List<List_Product_Price__c>
    */
    public static  List<List_Product_Price__c> getListProductPriceRecordsFilteredByRecordTtype (Set<String> recordTypeSet, Set<String> productNames){
        
        List<List_Product_Price__c> listProductPrices = new List<List_Product_Price__c>();
        try{

            listProductPrices = [Select id, Displayed_Name__c,Id_List_Product_Group__r.name, RecordType.DeveloperName, Id_List_Product_Group__c from List_Product_Price__c where RecordType.DeveloperName IN :recordTypeSet AND Displayed_Name__c IN :productNames];
        } catch (Exception e){

            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return listProductPrices;
    }
    /**
    * @Description: This method returns Product Price list from Id
      @param            : List of Product Id
      @Return             : Map of Product Price Id
      @TriggerContext     :  After Update
      @Ticket #            : SSC-1979
     */
    public static Map<Id, List_Product_Price__c> getActiveProductsById(List<Id> lstOfProduct) {
        Map<Id, List_Product_Price__c> productsMap ;
        try {
            productsMap = new Map<Id, List_Product_Price__c>([SELECT id,Displayed_Name__c,company__r.name,
                                                            Default_Quantity__c,Id_List_Product_Group__r.Name,
                                                            Product_Type__c,Product_Name__c,CurrencyIsoCode,List_Price__c,
                                                            Maximum_Discount__c
                                                            FROM List_Product_Price__c
                                                            WHERE Id = : lstOfProduct
                                                            LIMIT : limits.getLimitDmlRows()]);
        } catch(Exception e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }

        return productsMap;
    }



}
