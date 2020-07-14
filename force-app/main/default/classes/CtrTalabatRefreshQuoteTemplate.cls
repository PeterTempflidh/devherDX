public with sharing class CtrTalabatRefreshQuoteTemplate{
  public Opportunity_Quote__c theQuote {get;set;}

  public CtrTalabatRefreshQuoteTemplate() {

    Id objId = ApexPages.currentPage().getParameters().get('id');

    theQuote = [SELECT Id, Id_Account__c FROM Opportunity_Quote__c WHERE Id =: objId];
  }
}