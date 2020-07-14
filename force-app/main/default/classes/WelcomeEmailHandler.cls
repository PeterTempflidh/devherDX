/**
 * Created by g.singh on 18/05/2020.
 */

public with sharing class WelcomeEmailHandler {
	
    private static Map<String, Map<String,Map<String,Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    
    /**
    * @Description: Sends welcome email on quote status change 
    * @param List<Opportunity_Quote__c> newQuoteList
    * @param List<Opportunity_Quote__c> oldQuoteMap
    * @return void
    */
    public static void sendWelcomeEmail(List<Opportunity_Quote__c> newQuoteList, Map<Id,Opportunity_Quote__c> oldQuoteMap){
        EmailTemplate welcomEmailTemplate;
        Set<Id> accountIdSet = new Set<Id>();
        List<Id> opportunityIdList = new List<Id>();
        List<Opportunity_Quote__c> oppQuoteForProcessList = new List<Opportunity_Quote__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Map<String,Map<String,Business_Config__c>> bConfigByRecordTypeIdMap = moam.get('QuoteWelcomeEmail');
        List<String> emailTemplateNames = new List<String>();
        Map<String, EmailTemplate> emailTemplateByDevName = new Map<String, EmailTemplate>();

        if(bConfigByRecordTypeIdMap == null){
            return;
        }

        for (Opportunity_Quote__c oppQuote : newQuoteList) {
            Map<String,Business_Config__c> bConfigByBRuleNameMap = bConfigByRecordTypeIdMap.get(LibRecordTypeHelper.getRecordTypeValue(oppQuote.RecordTypeId));

            if (bConfigByBRuleNameMap == null
                || bConfigByBRuleNameMap.keyset().isEmpty()
                || !bConfigByBRuleNameMap.containsKey('QuoteStatus')
                || !bConfigByBRuleNameMap.containsKey('EmailTemplate'))
            {
                    continue;
            }
            
            if (oppQuote.Status__c != oldQuoteMap.get(oppQuote.Id).Status__c
                && bConfigByBRuleNameMap.get('QuoteStatus').Business_Rule_Value__c.contains(oppQuote.Status__c))
            {
                oppQuoteForProcessList.add(oppQuote);
                accountIdSet.add(oppQuote.Id_Account__c);
                opportunityIdList.add(oppQuote.Id_Opportunity__c);
                emailTemplateNames.add(bConfigByBRuleNameMap.get('EmailTemplate').Business_Rule_Value__c);
            }
        }

        accountMap.putAll(AccountSelector.getByIds(accountIdSet));
        Map<Id, Opportunity> relatedOpportunityMap = new Map<Id, Opportunity>(Opportunity_Selector.getSelected(opportunityIdList));
        List<EmailTemplate> emailTemplateList = EmailTemplateSelector.getTemplatesByDeveloperName(emailTemplateNames);

        for (EmailTemplate emailTemplate : emailTemplateList) {
            emailTemplateByDevName.put(emailTemplate.DeveloperName, emailTemplate);
        }

        for (Opportunity_Quote__C oppQuote : oppQuoteForProcessList) {
            if (accountMap.containsKey(oppQuote.Id_Account__c) && accountMap.get(oppQuote.Id_Account__c).Contacts.size() > 0) {
                Contact con = accountMap.get(oppQuote.Id_Account__c).Contacts[0];
                Opportunity relatedOpp = relatedOpportunityMap.get(oppQuote.Id_Opportunity__c);
                Map<String,Business_Config__c> bConfigByBRuleNameMap = bConfigByRecordTypeIdMap.get(LibRecordTypeHelper.getRecordTypeValue(oppQuote.RecordTypeId));
                
                if (bConfigByBRuleNameMap == null
                    || bConfigByBRuleNameMap.keyset().isEmpty()
                    || !bConfigByBRuleNameMap.containsKey('businessTypes'))
                {
                    continue;
                }

                if (bConfigByBRuleNameMap.get('businessTypes').Business_Rule_Value__c.contains(relatedOpp.Business_Type__c) && isOpportunityTypeValid(relatedOpp, oppQuote.RecordTypeId)) {
                    welcomEmailTemplate = emailTemplateByDevName.get(bConfigByBRuleNameMap.get('EmailTemplate').Business_Rule_Value__c);
                    emailList.add(createEmail(welcomEmailTemplate.Id, oppQuote.Id_Opportunity__c, con.Id, relatedOpp.Owner.Email));
                }
            }
        }

        if (!emailList.isEmpty()) {
            try {
                Messaging.sendEmail(emailList);
            } catch (Exception exc) {
                // TO-DO
                if(Test.isRunningTest()){
                    throw exc;
                }
                system.debug('Error : ' + exc.getMessage() + '>>> Stacktrace : ' + exc.getStackTraceString());
            }
        }
    }

    /**
    * @description check if the opportunity type is valid
    * @param opportunity opportunity to check
    * @param quoteRecordTypeId record type id to retrieve configuration
    * @return boolean result if the type is valid
    */
    private static Boolean isOpportunityTypeValid(Opportunity opportunity, Id quoteRecordTypeId) {
        Business_Config__c oppTypeConfig = LibBusinessConfig.getBusinessConfigFromRuleMap('QuoteWelcomeEmail', quoteRecordTypeId, 'opportunityTypes');
        if (oppTypeConfig == null) {
            return true;
        }
        return oppTypeConfig.Business_Rule_Value__c.containsIgnoreCase(opportunity.Type);
    }

    /**
    * @Description: Creates SingleEmailMessage
    * @param Id emailTemplateId
    * @param Id whatId
    * @param Id targetId
    * @return Messaging.SingleEmailMessage
    */
    private static Messaging.SingleEmailMessage createEmail(Id emailTemplateId, Id whatId, Id targetId, String replyToEmail){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setReplyTo(replyToEmail);
        mail.setTargetObjectId(targetId);
        mail.setWhatId(whatId);
        mail.setTreatTargetObjectAsRecipient(true);
        mail.setTemplateId(emailTemplateId);

        return mail;
    }
}