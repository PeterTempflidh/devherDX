/**
* @author Mantas Jurkunas
* @date 25.01.2019
*
* @description Selector class for retrieving Opportunity Quote records
*/

public with sharing class OpportunityQuoteSelector {

    @TestVisible
    private static List<Opportunity_Quote__c> findAll() {

        List<Opportunity_Quote__c> opportunityQuotes = new List<Opportunity_Quote__c>();

        try {
            opportunityQuotes = [ SELECT Id, Name, Id_Account__r.Key_VIP_Account__c, Status__c,RecordTypeId,Id_Account__r.Record_Country__c,
                                 Id_Opportunity__r.Business_Type__c, Id_Opportunity__r.Email_Path__c, Id_Opportunity__r.Probability,
                                 RecordType.DeveloperName, Id_Opportunity__r.Record_Country__c FROM Opportunity_Quote__c];
        } catch (Exception e) {
            System.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return  opportunityQuotes;

    }

    /*******************************************************************************************************
  * @description Query quote records based on quote Id.
  * @param keys set of Opprtunity Quote
  * @return Opportunity Quotes
  */

    public static List<Opportunity_Quote__c> findQuotesbyIds(final set<ID> quoteIds) {

        return  [ Select Id,Name,Id_tarif__r.Name,Id_Account__r.Record_Country__c,
        Quote_Comment__c,Id_Opportunity__c,Id_Account__c,
        Id_Opportunity__r.Owner.FirstName,Id_Opportunity__r.Owner.LastName,
        Id_Account__r.Name,Template_Name__c,RecordTypeId,
        Quote_Type__c, Id_Opportunity__r.Owner.Email,Status__c,Id_Opportunity__r.Email_Path__c,
        Id_Opportunity__r.Owner.Phone, Id_opportunity__r.Business_Type__c, RecordType.DeveloperName
        from Opportunity_Quote__c where Id =:quoteIds];
    }
    
    /*******************************************************************************************************
    * @description Get quote records based on quote Id.
    * @param keys set of Opprtunity Quote Ids
    * @return Opportunity Quotes Map
    */
    public static Map<Id, Opportunity_Quote__c> getQuotesMap(final Set<Id> oppQuoteIds) {
        return new Map<Id, Opportunity_Quote__c> ([
            SELECT Id, Name, Id_Account__r.Record_Country__c, Id_Account__r.Platform__c, Id_Account__r.Company_Code__c,
            Id_Account__r.BillingCountry, Id_Account__r.BillingCity, Id_Account__c, Quote_Type__c, Template_Name__c, Id_Opportunity__c,
            Id_Opportunity__r.Business_Type__c, Id_Opportunity__r.Type, Id_Opportunity__r.RecordType.DeveloperName, Id_Account__r.Vertical_Segment__c
            FROM Opportunity_Quote__c
            WHERE Id IN :oppQuoteIds
        ]);
    }

    public static List<Opportunity_Quote__c> getQuotesFromStatus(String status, String oppId) {

        return  [ SELECT Id FROM Opportunity_Quote__c WHERE Status__c =: status AND Id_opportunity__c =: oppId];
    }

    public static List<Opportunity_Quote__c> getQuotesByOppId(List<ID> oppIDs) {

        return [Select ID, Id_Opportunity__c from Opportunity_Quote__c where Id_Opportunity__c IN: oppIDs];
    }

}