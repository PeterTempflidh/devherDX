/**
 * Created by c.kumari on 24.09.2019.
 */

trigger BankDetail_Trigger on Bank_Detail__c (before insert, before update, after insert, after update) {
    // checks if trigger is disabled
    if (Trigger_Manager__c.getInstance().Deactivate_BankDetail_Trigger__c) return;

    TriggerFactory.createAndExecuteHandler(BankDetail_TriggerHandler.class);

}