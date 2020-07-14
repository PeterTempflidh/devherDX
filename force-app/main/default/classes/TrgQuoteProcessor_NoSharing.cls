/**
* @author Mantas Jurkunas
* @date 2019-01-25
*
* @description TrgQuoteProcessor class that does not use sharing settings
*
* @see TrgQuoteProcessor
*/

public without sharing class TrgQuoteProcessor_NoSharing {

    public static void quoteAcceptAndDecline(List<Opportunity_Quote__c> newList, Map<Id,Opportunity_Quote__c> oldMap) {
        TrgQuoteProcessor.quoteAcceptAndDecline(newList, oldMap);
    }

}