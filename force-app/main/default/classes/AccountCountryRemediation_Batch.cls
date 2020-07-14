/**
* @author Mantas Jurkunas
* @date 13.11.2019
*
* @description Batch class that copies the account country field from Account to Asset and Branding objects.
*/

public without sharing class AccountCountryRemediation_Batch implements Database.Batchable<SObject>, Database.Stateful {

    private String objectQuery;
    private String accountField;
    private Integer errorCount;


    public static void run(Type objectType) {
        Database.executeBatch(new AccountCountryRemediation_Batch(objectType));
    }

    private AccountCountryRemediation_Batch(Type objectType) {
        if (objectType == Asset__c.class) {
            accountField = 'Account__r.Record_Country__c';
            objectQuery = 'SELECT Id, Status__c, Account__c, Account_Country__c, Account__r.Record_Country__c FROM Asset__c WHERE Account_Country__c = NULL AND Account__r.Record_Country__c != NULL';
        } else if (objectType == Branding_Content__c.class) {
            accountField = 'Restaurant_Name__r.Record_Country__c';
            objectQuery = 'SELECT Id, Status__c, Restaurant_Name__c, Account_Country__c, Restaurant_Name__r.Record_Country__c FROM Branding_Content__c WHERE Account_Country__c = NULL AND Restaurant_Name__r.Record_Country__c != NULL';
        } else {
            throw new AccountCountryRemediation_BatchException('Object Type not supported');
        }
        errorCount = 0;
    }

    public void execute(Database.BatchableContext param1, List<SObject> objects) {
        for (SObject obj: objects) {
            obj.put('Account_Country__c', ClsSObjectUtils.getFieldValue(obj, accountField));
        }
        List<Database.SaveResult> saveResults = Database.update(objects, false);

        System.debug('------------ Update Errors -------------');
        for ( Database.SaveResult saveRes: saveResults) {
            if (saveRes.getErrors().isEmpty()) {
                continue;
            }
            System.debug(saveRes.getErrors());
        }
        errorCount += saveResults.size();
    }

    public void finish(Database.BatchableContext param1) {
        toggleTriggers(false);
        System.debug('------------ Total Errors: ' + errorCount + ' -------------');
    }

    public Iterable<SObject> start(Database.BatchableContext param1) {
        toggleTriggers(true);
        return Database.query(objectQuery);
    }

    private void toggleTriggers(Boolean isDisabled) {
        Trigger_Manager__c manager = Trigger_Manager__c.getInstance();
        manager.Deactivate_Branding_Trigger__c = isDisabled;
        manager.Deactivate_Asset_Trigger__c = isDisabled;
        upsert manager;
    }

    public class AccountCountryRemediation_BatchException extends Exception {}

}