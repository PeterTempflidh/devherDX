/**
 * Created by danish.farooq on 6/6/20.
 */

public with sharing class MultiSelectLookUp_AuraController {

    /**
   * @description keywords user has entered for searching records
   */
    @AuraEnabled public string searchKeyWord {get;set;}
    /**
    * @description object name where search will apply
    */
    @AuraEnabled public string objectName {get;set;}
    /**
   * @description removed the records which are already selected by user
   */
    @AuraEnabled public List<sObject> excludedItemLst {get;set;}
    /**
  * @description fields need to show in search result
  */
    @AuraEnabled public string fieldToQuery {get;set;}

    /**
    * @description this is the generic method to used for search records in lightning component on the basis of input
    * @param jsonString jsonString is used to avoid long param list contains (search keyword,object name, already selected Values,Addition field to query)
    * @return List of sObject (Queried)
    * Jira Ticket SSC-3101
    */
    @AuraEnabled
    public static List <sObject> fetchLookUpValues(String jsonString) {

        try {
            ParametersWrapper parameterObj = (ParametersWrapper) JSON.deserialize(jsonString, ParametersWrapper.class);
            String searchKey = '%' + parameterObj.searchKeyWord + '%';
            List < sObject > returnList = new List < sObject > ();

            List<string> lstExcludeitems = new List<string>();
            for (ExcludedItemWrapper iWrapperObj : parameterObj.excludedItemLst) {
                lstExcludeitems.add(iWrapperObj.id);
            }
            if (!string.isBlank(parameterObj.fieldToQuery)) {
                parameterObj.fieldToQuery = ',' + parameterObj.fieldToQuery;
                parameterObj.fieldToQuery = parameterObj.fieldToQuery.removeEnd(',');
            }
            // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 and exclude already selected records
            String sQuery = 'SELECT ID, Name' + parameterObj.fieldToQuery + ' FROM ' + parameterObj.ObjectName;
            sQuery += ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems ';
            sQuery += 'order by createdDate DESC limit 5';

            for (sObject obj : Database.query(sQuery)) {
                returnList.add(obj);
            }
            return returnList;
        }
        catch(Exception ex){
            throw new AuraHandledException('Something went wrong: ' + ex.getMessage());
        }
    }

   /**
     * @description Parameter wrapper class used to get values from lightning controller to Apex controller
     */
    public class ParametersWrapper{
        /**
     * @description keywords user has entered for searching records
     */
        public String searchKeyWord;
        /**
     * @description object name where search will apply
     */
        public String objectName;
        /**
     * @description removed the records which are already selected by user
     */
        public List<ExcludedItemWrapper> excludedItemLst;
        /**
     * @description fields need to show in search result
     */
        public String fieldToQuery;

    }
    /**
     * @description selected record needs to remove wrapper class
     */
    public class ExcludedItemWrapper {
        /**
     * @description Id of the selected records
     */
        public String id;
        /**
     * @description Name of the selected records
     */
        public String name;
        /**
       * @description Email of the selected records
       */
        public String email;
    }
}
