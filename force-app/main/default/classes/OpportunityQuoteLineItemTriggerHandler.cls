public class OpportunityQuoteLineItemTriggerHandler implements ITrigger {

    private List<Approval.ProcessSubmitRequest> requests;
    private Map<Id, Opportunity_Quote__c> oppQuoteForUpdateMap = new Map<Id, Opportunity_Quote__c>();
    private Map<Id, Opportunity_Quote__c> oppQuoteMap;

    public OpportunityQuoteLineItemTriggerHandler(){
        requests = new List<Approval.ProcessSubmitRequest>();
    }

    public void bulkBefore() {}

    public void bulkAfter() {
        Set<Id> oppQuoteIdSet = new Set<Id>();

        for(Opportunity_Quote_Line_Item__c oqli : (List<Opportunity_Quote_Line_Item__c>)Trigger.New){
            oppQuoteIdSet.add(oqli.Id_Opportunity_Quote__c);

            // conditions to automatically submit for approval
            if(oqli.Status__c != Label.Approved
               // approval status is not being changed in this transaction
               && (Trigger.oldMap != null 
                  && Trigger.oldMap.get(oqli.Id) != null 
                  && ((Opportunity_Quote_Line_Item__c)Trigger.oldMap.get(oqli.Id)).Status__c == oqli.Status__c
                  || oqli.Status__c == Label.Created) 
               && oqli.Approval_Rule__c != null 
               && oqli.Approver__c != null)
            {
                // create new approval request to submit
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments(Label.Submitted_for_Approval_message);
                req.setObjectId(oqli.Id);
                requests.add(req);
            }
        }

        if(Trigger.isInsert){
            oppQuoteMap = OpportunityQuoteSelector.getQuotesMap(oppQuoteIdSet);
        }
    }

    public void beforeInsert(SObject so) {}

    public void afterInsert(SObject so) {
        String oldQuoteType;
        Opportunity_Quote__c oppQuoteTemp;
        Opportunity_Quote_Line_Item__c oppQuoteLineItem = (Opportunity_Quote_Line_Item__c) so;

        if(oppQuoteMap.containsKey(oppQuoteLineItem.Id_Opportunity_Quote__c) && !oppQuoteForUpdateMap.containsKey(oppQuoteLineItem.Id_Opportunity_Quote__c)){
            oppQuoteTemp = oppQuoteMap.get(oppQuoteLineItem.Id_Opportunity_Quote__c);
			oldQuoteType = oppQuoteTemp.Quote_Type__c;
            oppQuoteTemp = ClsQuoteLineItemProcessor.updateQuoteType(oppQuoteTemp, oppQuoteTemp.Id_Opportunity__r, oppQuoteLineItem);

            if(oppQuoteTemp.Quote_Type__c != null && oldQuoteType != oppQuoteTemp.Quote_Type__c){
                oppQuoteForUpdateMap.put(oppQuoteTemp.Id, oppQuoteTemp);
            }
        }
    }

    public void beforeUpdate(SObject oldSo, SObject so) {}

    public void afterUpdate(SObject oldSo, SObject so) {}

    public void beforeDelete(SObject so) {}

    public void afterDelete(SObject so) {}

    public void andFinally() {
        if(requests != null && !requests.isEmpty()) {
            Approval.process(requests, true);
        }

        if(oppQuoteForUpdateMap != null && !oppQuoteForUpdateMap.values().isEmpty()){
            update oppQuoteForUpdateMap.values();
        }
    }
}