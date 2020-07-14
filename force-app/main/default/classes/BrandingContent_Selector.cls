/**
* @author Mantas Jurkunas
* @date 08.10.2019
*
* @description Selector class for branding content
*/

public class BrandingContent_Selector {

    public static List<Branding_Content__c> findByAccountIds(Set<Id> ids) {
        List<Branding_Content__c> brandings = new List<Branding_Content__c>();
        try {
            brandings = [SELECT Id, Restaurant_Name__c, Account_Country__c FROM Branding_Content__c WHERE Restaurant_Name__c IN :ids];
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }
        return brandings;
    }
    /**
   * @description return Brands against opportunity Id
   * @param opptySet contains set Of Opportunity
   * @param typeOfBrand type of branding Contents
   * @param setOfStatus statuses of that brand
   * @return List of Branding_Content__c
   * Jira Ticket SSC-3462
   */
    public static List<Branding_Content__c> getBrandingByOpptyId(Set<Id> opptySet, string typeOfBrand, Set<String> setOfStatus){

        typeOfBrand = '%' + typeOfBrand + '%';
        List<Branding_Content__c> brandingLst = new List<Branding_Content__c>();
        brandingLst = [select id, status__c, opportunity__c
                        from branding_Content__c
                        where type__c like : typeOfBrand and opportunity__c in :opptySet
                        AND Status__c IN : setOfStatus];
        return brandingLst;
    }

}