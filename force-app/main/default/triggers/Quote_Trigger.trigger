trigger Quote_Trigger on Opportunity_Quote__c (after update, before update, before insert, after insert) {

    if (Trigger_Manager__c.getInstance().Deactivate_Quote_Trigger__c) return;
    
    if ((Trigger.isUpdate || Trigger.isInsert) && trigger.isAfter && (!BookingServiceHandler.doNotCreateCase)) {
        TrgQuoteProcessor.oppTypeAndStageProcess(Trigger.new, Trigger.oldMap);
        TrgQuoteProcessor_NoSharing.quoteAcceptAndDecline(Trigger.new, Trigger.oldMap);
        TrgQuoteProcessor.voidDocuSignOnDeclined(Trigger.new, Trigger.oldMap);
        if (Trigger.isInsert)
            TrgQuoteProcessor.premiumPlacementMultipleQuote(Trigger.new);
    }
    if (Trigger.isUpdate && Trigger.isBefore) {
        TrgQuoteProcessor.quoteDeclineAcceptValidation(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isInsert && Trigger.isBefore) {
        TrgQuoteProcessor.checkIfAlreadyAcceptedQuoteExist(Trigger.new);
        TrgQuoteProcessor.populateQuoteType(Trigger.new);
        // TrgQuoteProcessor.premiumPlacementMultipleQuote(Trigger.new);
    }

    if(Trigger.isUpdate && Trigger.isAfter){
        WelcomeEmailHandler.sendWelcomeEmail(Trigger.new, Trigger.oldMap);
        TrgQuoteProcessor.updateNationalIdOnContact(Trigger.new, Trigger.oldMap); //SSC-2815
    }
}