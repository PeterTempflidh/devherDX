/**
 * Created by s.anand on 22/03/2020.
 */
/**
* @author Sundra Anand
* @date 22.03.2020
*
* @description Trigger Processor class for DocuSignStatus object
*/

public with sharing class DocuSignStatus_Processor {

    // **
    // * @date          : 22.03.20
    // * @description   : Method to update Quote/Opportunity status on insertion of envelope
    // * @params        : List<dsfs__DocuSign_Status__c>
    // * @return        : List<Opportunity>
    // **
    public static List<Opportunity> sentEnvelopeUpdate(List<dsfs__DocuSign_Status__c> envelopeList) {

        List<Opportunity> oppListUpdate = new List<Opportunity>();
        List<Id> sentOppIdSet = new List<Id>();
        Set<Id> sentQuoteIdSet = new Set<Id>();
        Set<Id> newDsStatusIdSet = new Set<Id>();
        //Lock classic email path
        for(dsfs__DocuSign_Status__c ds : DocuSignStatus_Selector.getDocuSignStatusbyIds(envelopeList)) {
            sentOppIdSet.add(ds.Opportunity_Quote__r.Id_Opportunity__c);
            sentQuoteIdSet.add(ds.Opportunity_Quote__c);
            newDsStatusIdSet.add(ds.Id);
        }

        if(!sentOppIdSet.isEmpty()) {
            for (Opportunity opp : Opportunity_Selector.getSelected(sentOppIdSet)) {
                opp.Email_Path__c = 'DocuSign';
                opp.StageName = 'Quote Sent';
                opp.Probability = 60;
                opp.DocuSign_Envelopes_Consumed__c = (opp.DocuSign_Envelopes_Consumed__c == null ? 1 : opp.DocuSign_Envelopes_Consumed__c + 1);
                oppListUpdate.add(opp);
            }
            for (Opportunity_Quote__c oq : OpportunityQuoteSelector.getQuotesByOppId(sentOppIdSet)) {
                sentQuoteIdSet.add(oq.Id);
            }
        }

        if (!sentQuoteIdSet.isEmpty()) {
            DocuSignUtilityController.voidEnvelopeBuilder(sentQuoteIdSet, newDsStatusIdSet, 'New Quote Requested');
        }

        return oppListUpdate;

    }

    // **
    // * @date          : 22.03.20
    // * @description   : SSC-1202 : Method to update quote status when Docusign status is 'Declined'
    // * @params        : List<dsfs__DocuSign_Status__c>
    // * @return        : List<Opportunity_Quote__c>
    // **
    public static List<Opportunity_Quote__c> declinedEnvelopeUpdate(List<dsfs__DocuSign_Status__c> envelopeList,Map<Id,dsfs__DocuSign_Status__c> oldEnvelopeMap) {

        Set<Id> declinedQuoteIdSet = new Set<Id>();
        List<Opportunity_Quote__c> oppQuotesToUpdate = new List<Opportunity_Quote__c>();
        Map<Id,String> declinedStatusMap = new Map<Id,String>();
        Map<Id,dsfs__DocuSign_Status__c> activeEnvelopeMap = DocuSignStatus_Selector.getActiveEnvelopeForQuote(envelopeList);

        for(dsfs__DocuSign_Status__c ds : envelopeList) {

            if(oldEnvelopeMap.get(ds.Id).dsfs__Envelope_Status__c != 'Declined' && ds.dsfs__Envelope_Status__c == 'Declined') {
                declinedQuoteIdSet.add(ds.Opportunity_Quote__c);
                declinedStatusMap.put(ds.Opportunity_Quote__c,ds.dsfs__Declined_Reason__c);
            }
            else if(oldEnvelopeMap.get(ds.Id).dsfs__Envelope_Status__c != 'Voided' && ds.dsfs__Envelope_Status__c == 'Voided' && activeEnvelopeMap.get(ds.Opportunity_Quote__c) == null) {
                declinedQuoteIdSet.add(ds.Opportunity_Quote__c);
                declinedStatusMap.put(ds.Opportunity_Quote__c,ds.dsfs__Voided_Reason__c);
            }

        }

        if(!declinedQuoteIdSet.isEmpty()) {
            for(Opportunity_Quote__c oq : OpportunityQuoteSelector.findQuotesbyIds(declinedQuoteIdSet)) {
                oq.Status__c = 'Declined';
                oq.Declined_Reason__c = declinedStatusMap.get(oq.Id).substringBeforeLast(',');
                oppQuotesToUpdate.add(oq);
            }
        }

        return oppQuotesToUpdate;

    }

    // **
    // * @date          : 28.04.20
    // * @description   : SSC-417 : Method to update Opportunity Quote status on insert/update of dsfs__DocuSign_Status__c
    // * @params        : Trigger.NewMap and Trigger.OldMap of dsfs__DocuSign_Status__c trigger
    // * @return        : List<Opportunity_Quote__c>
    // **
    public static List<Opportunity_Quote__c> updateOpportunityQuote(List<dsfs__DocuSign_Status__c> envelopeNewList, Map<Id,dsfs__DocuSign_Status__c> oldDSStatusMap) {
        List<Opportunity_Quote__c> opptyQuoteUpdateList = new List<Opportunity_Quote__c>();
        Set<String> statuses = new Set<String>{'Sent','Delivered','Completed'};
        for (dsfs__DocuSign_Status__c eachDSS : DocuSignStatus_Selector.getDocuSignStatusbyIds(envelopeNewList)){
            if (statuses.contains(eachDSS.dsfs__Envelope_Status__c)
                    && (oldDSStatusMap == null
                        || (oldDSStatusMap != null
                            && eachDSS.dsfs__Envelope_Status__c  != oldDSStatusMap.get(eachDSS.id).dsfs__Envelope_Status__c)))
            {
                opptyQuoteUpdateList.add(
                    new Opportunity_Quote__c(Id = eachDSS.Opportunity_Quote__c,
                        Status__c = (eachDSS.dsfs__Envelope_Status__c == 'Sent' ? 'Sent' : (
                            eachDSS.dsfs__Envelope_Status__c == 'Delivered' ? 'Viewed' : (
                                eachDSS.dsfs__Envelope_Status__c == 'Completed' ? 'Signed' : eachDSS.dsfs__Envelope_Status__c
                                )
                            )
                        )
                    )
                );
            }
        }
        return opptyQuoteUpdateList;
    }

    // **
    // * @date          : 28.04.20
    // * @description   : SSC-560 : Method to update Opportunity stage on decline of Quote through Docusign
    // * @params        : Trigger.NewMap and Trigger.OldMap of dsfs__DocuSign_Status__c trigger
    // * @return        : List<Opportunity>
    // **
    public static List<Opportunity> updateOpportunity(Map<Id,dsfs__DocuSign_Status__c> newDSStatusMap,Map<Id,dsfs__DocuSign_Status__c> oldDSStatusMap) {
        List<Opportunity> opptyUpdateList = new List<Opportunity>();
        Map<Id,dsfs__DocuSign_Status__c> docuSignStatusMap = new Map<Id,dsfs__DocuSign_Status__c>(DocuSignStatus_Selector.getDocuSignStatusbyIds(newDSStatusMap.values()));
        for (dsfs__DocuSign_Status__c eachDSS : newDSStatusMap.values()){
            Business_Config__c dsConfig;
            if(docuSignStatusMap.get(eachDSS.Id) != null){
                dsConfig = LibBusinessConfig.getBusinessConfigFromRuleMap('docuSignFilters', docuSignStatusMap.get(eachDSS.Id).Opportunity_Quote__r.RecordTypeId, 'opportunityStatusForQuoteDecline');
            }
            if ( dsConfig != null && dsConfig.Business_Rule_Value__c != null &&  eachDSS.dsfs__Envelope_Status__c == 'Declined' && (oldDSStatusMap == null || eachDSS.dsfs__Envelope_Status__c  != oldDSStatusMap.get(eachDSS.id).dsfs__Envelope_Status__c)) {
                opptyUpdateList.add(new Opportunity(Id = docuSignStatusMap.get(eachDSS.Id).Opportunity_Quote__r.Id_Opportunity__c, StageName = dsConfig.Business_Rule_Value__c));
            }
        }
        return opptyUpdateList;
    }

}