/**
 * @description Batch class for FP opportunity migration. It created missing cases, quotes and quote line items for opportunities based on their business type and stage.
 * @date 29.10.2019
 * @author Mantas Jurkunas
 */
public with sharing class CreateFpOpportunityRecords_Batch implements Database.Batchable<SObject>, Database.Stateful {
    private String condition;
    private Boolean isTest;

    /**
     * @description Only use when testing the batch, not in Production.
     *  the batch executes only one time and debugs all the opportunity Ids processed.
     */
    public static void testRun() {
        if (![SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox) {
            throw new CreateFpOpportunityRecords_BatchException('Running testRun in production not allowed');
        }
        String condition = ' WHERE RecordType.DeveloperName = \'FP_Opportunity\' AND StageName IN (\'Quality Check\', \'Quality Check Request\',\'Editorial Queue\',\'Onboarding\',\'Promo and Logistics Queue\')';
        CreateFpOpportunityRecords_Batch batchInstance = new CreateFpOpportunityRecords_Batch(condition);
        batchInstance.isTest = true;
        Database.executeBatch(batchInstance);
    }

    public static void run() {
        String condition = ' WHERE RecordType.DeveloperName = \'FP_Opportunity\' AND StageName IN (\'Quality Check\', \'Quality Check Request\',\'Editorial Queue\',\'Onboarding\',\'Promo and Logistics Queue\')';
        Database.executeBatch(new CreateFpOpportunityRecords_Batch(condition));
    }

    public static void run(String condition) {
        Database.executeBatch(new CreateFpOpportunityRecords_Batch(condition));
    }

    public CreateFpOpportunityRecords_Batch(String condition) {
        this.isTest = false;
        this.condition = condition;
        this.condition += ' AND Id NOT IN (SELECT Id_Opportunity__c FROM Opportunity_Quote__c WHERE RecordType.DeveloperName = \'FP_Opportunity_Quote\') AND Id IN (SELECT Id_Opportunity__c FROM Opportunity_Line_Item__c WHERE Id_Opportunity__r.RecordType.DeveloperName = \'FP_Opportunity\')';
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> opportunities) {
        CreateFpOpportunityRecords_Utils batchUtils = new CreateFpOpportunityRecords_Utils(opportunities);
        batchUtils.createQuotes().createQuoteLineItems().createCases().createAddons();

        if (this.isTest) {
            System.debug('----CreateFpOpportunityRecords_Batch Test Run----');
            for (Opportunity opp: opportunities) {
                System.debug(opp.Id);
            }
            System.abortJob(bc.getJobId());
        }
    }

    public Database.QueryLocator start(Database.BatchableContext param1) {
        CreateFpOpportunityRecords_Utils.toggleTriggers(false);

        final String baseQuery = 'SELECT {0} FROM Opportunity{1}';
        List<String> opportunityFields = new List<String>{
                Opportunity.Id.getDescribe().getLocalName(),
                Opportunity.StageName.getDescribe().getLocalName(),
                Opportunity.Business_Type__c.getDescribe().getLocalName(),
                Opportunity.RecordTypeId.getDescribe().getLocalName(),
                Opportunity.Id_Tarif__c.getDescribe().getLocalName(),
                Opportunity.Time_Based_Tier_Type__c.getDescribe().getLocalName(),
                Opportunity.Source_System__c.getDescribe().getLocalName(),
                Opportunity.CurrencyIsoCode.getDescribe().getLocalName(),
                Opportunity.Company_Code__c.getDescribe().getLocalName(),
                Opportunity.Record_Country__c.getDescribe().getLocalName(),
                Opportunity.Country__c.getDescribe().getLocalName(),
                Opportunity.AccountId.getDescribe().getLocalName(),
                Opportunity.List_Photo_Comments__c.getDescribe().getLocalName(),
                Opportunity.Id_Tarif__r.Name.getDescribe().getLocalName(),
                'Opportunity.Account.Key_VIP_Account__c',
                'Opportunity.Account.Backend_ID__c',
                'Opportunity.Account.RecordType.DeveloperName',
                'Opportunity.RecordType.DeveloperName'

        };

        return Database.getQueryLocator(String.format(baseQuery, new List<String>{ String.join(opportunityFields, ','), this.condition }));
    }

    public void finish(Database.BatchableContext param1) {
        CreateFpOpportunityRecords_Utils.toggleTriggers(true);
    }

    private class CreateFpOpportunityRecords_BatchException extends Exception {

    }

}