/**
* @author Mantas Jurkunas
* @date 18.03.2019
*
* @description Selector class for retrieving Opportunity records
*/

public with sharing class Opportunity_Selector {

    //Constants
    public static final String OPPORTUNITY_EMAILPATH_DOCUSIGN = 'DocuSign';
    public static final String OPPORTUNITY_EMAILPATH_CLASSIC = 'Classic';

    @TestVisible
    private static List<Opportunity> getAll() {
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities = [SELECT Id, StageName, Opportunity.Business_Type__c, Type,AccountId FROM Opportunity];
        return opportunities;
    }

    @TestVisible
    private static List<Opportunity> getAllWithChildren() {
        List<Opportunity> opportunities = new List<Opportunity>();
        try {
            opportunities = [
                    SELECT Id, StageName, Type, Business_Type__c,
                        (SELECT Id FROM Opportunity_Line_Items__r LineItems),
                        (SELECT Id, Status__c FROM Opportunity_Quotes__r Quotes),
                        (SELECT Id FROM Opportunity_Quote_Line_Items__r QuoteLineItems),
                        (SELECT Id, RecordType.DeveloperName, Type, Status, Closed_Reason__c FROM Cases__r Cases)
                    FROM Opportunity];
          } catch (Exception e) {
            System.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
          }
    return opportunities;
    }

    /*******************************************************************************************************
    * @description Get quote records based on quote Id.
    * @param keys set of Opprtunity Quote Ids
    * @return Opportunity Quotes Map
    */
    public static Map<Id, Opportunity_Quote__c> getQuotesMap(final Set<Id> oppQuoteIds) {
        return new Map<Id, Opportunity_Quote__c> ([
            SELECT Id, Id_Account__r.Record_Country__c, Id_Account__r.Platform__c, Id_Account__r.Company_Code__c, 
            Id_Account__r.BillingCountry, Id_Account__r.BillingCity
            FROM Opportunity_Quote__c
            WHERE Id IN :oppQuoteIds
        ]);
    }
    
    public static Map<Id,Opportunity> getFromOppIdSet(Set<Id> oppIdsSet) {
        Map<Id,Opportunity> oppMap;
        try {
            oppMap = new Map<Id,Opportunity>([SELECT Business_Type__c,Type, Account.RecordTypeId, RecordTypeId, RecordType.developername, Record_Country__c,Preferred_Language__c
                                                FROM Opportunity 
                                                WHERE Id IN :oppIdsSet ]);
        } catch (Exception e) {
            System.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return oppMap;
    }
    
    public static List<Opportunity> getSelected(List<ID> listOppID) {
        List<Opportunity> opportunities = new List<Opportunity>();
        try {
            opportunities = [SELECT Id, Business_Type__c, Type, RecordTypeId, Record_Country__c, Start_Date_uk__c, Probability, StageName,
                                    Email_Path__c, DocuSign_Envelopes_Consumed__c, Owner.Email
                                FROM Opportunity
                                WHERE Id IN: listOppID];
        } catch (QueryException e) {
            System.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return opportunities;
    }
  
      public static List<Opportunity> getOpportunityClosed(set<Id> oppId) {
        List<Opportunity> opportunities = new List<Opportunity>();
        try {
            opportunities = [Select Id from opportunity where Id IN : oppId and isClosed = true];
        } catch (Exception e) {
            System.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }

        return opportunities;
    }


    public static List<Opportunity> getOpportunityByIdStage(set<Id> oppId,String strStage) {
        List<Opportunity> opportunities = new List<Opportunity>();
        try {
            opportunities = [Select Id from opportunity where Id IN : oppId and StageName != :strStage];
        } catch (Exception e) {
            System.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return opportunities;
    }


    public static Opportunity getOpportunityById(Id oppId) {
        return [SELECT Id, StageName,Name, Selfbooking_Owner__c, Lost_Reason__c FROM Opportunity WHERE Id = :oppId LIMIT 1];
    }
    
      /*******************************************************************************************************
  * @description Get opportunites for selected Account to update the country
  * @param Set of Account Ids
  * @return List<Opportunity> to update country
  * @ticket : SSC-1533
  */

    public static List<Opportunity> getOpportunityAgainstAccounts(Set<Id> setOfAccountIds){

        List<Opportunity> lstOppty = new List<Opportunity>();
        try{
            lstOppty = [SELECT Id ,AccountId, Opportunity_Country__c
                        FROM Opportunity WHERE AccountId IN : setOfAccountIds
                        LIMIT : Limits.getLimitDMLRows()];
        }
        catch (QueryException e) {
            System.debug('Error: '+e.getMessage());
        }
        return lstOppty;
    }
    /*******************************************************************************************************
    * @Description: Get product name based on quote Id.
    * @Inputparam: Id of the opportunity
    * @return: String of Product Name
    */
    public static String fetchOQLIProductName(Id opptyId){
        String productName;
        List<Opportunity_Quote_line_item__c> listOfOpptylineItem =[SELECT Id,Id_Opportunity__c,Id_List_Product_Price__r.Product_Name__c
        FROM Opportunity_Quote_Line_Item__c
        WHERE Id_Opportunity__c =: opptyId limit 1];
        if(!listOfOpptylineItem.isEmpty() && String.isNotBlank(listOfOpptylineItem[0].Id_List_Product_Price__r.Product_Name__c)){
            productName = listOfOpptylineItem[0].Id_List_Product_Price__r.Product_Name__c;
        }
        return productName;
    }

}
