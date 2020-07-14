public with sharing class CtrYogiyo_QuoteVFTemplate_Service {
    
    public Opportunity_Quote__c theOppQ {get;set;}

    public CtrYogiyo_QuoteVFTemplate_Service() {

        Id objId = ApexPages.currentPage().getParameters().get('id');



        theOppQ = [SELECT Id, Id_Account__c FROM Opportunity_Quote__c where id=: objId];
    }

}