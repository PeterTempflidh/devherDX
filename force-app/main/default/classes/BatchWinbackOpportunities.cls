/**
 * Created by w.novoa on 27.08.2018.
 */

global with sharing class BatchWinbackOpportunities  implements Database.Batchable<sObject>, Database.Stateful{


    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    private String strRecordType;
    private String StrOppRecordType;
    Private Map<String, Business_Config__c> mapBusinessRule;


    global BatchWinbackOpportunities(String RecordType){
        strRecordType  = RecordType;

        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('WinbackOpportunities');
        System.debug(mapBusinessLogic);
        mapBusinessRule =  mapBusinessLogic.get(strRecordType);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        set<String> stStatusReason = new set<String>();
        set<String> stAccountType = new set<String>();

        System.debug('mapBusinessRule-->'+mapBusinessRule);

        if(mapBusinessRule!= null &&
                mapBusinessRule.get('InvalidStatusReason')!= null &&
                mapBusinessRule.get('AccountType')!= null){
            stStatusReason.addAll(mapBusinessRule.get('InvalidStatusReason').Business_Rule_Value__c.split(','));
            stAccountType.addAll(mapBusinessRule.get('AccountType').Business_Rule_Value__c.split(','));
            StrOppRecordType = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRule.get('OpportunityRecordType').Business_Rule_Value__c);
        }


        System.debug([select id
        from Account
        where Account_Status__c  = 'Terminated'
        AND Key_VIP_Account__c = false
        AND RecordType.DeveloperName = :strRecordType
        AND Type IN : stAccountType
        AND Status_Reason__c NOT IN : stStatusReason]);

        return Database.getQueryLocator([select id
                                            from Account
                                            where Account_Status__c  = 'Terminated'
                                                AND Key_VIP_Account__c = false
                                                AND RecordType.DeveloperName = :strRecordType
                                                AND Type IN : stAccountType
                                                AND Status_Reason__c NOT IN : stStatusReason]);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {

        set<String> stAccountId = new set<String>();
        List<Opportunity> lstOpp = new List<Opportunity>();

        for(Account accTemp: scope){
            stAccountId.add(accTemp.id);
        }

        for(Account accTemp: [Select id,
                                    (Select id from Opportunities where Business_Type__c = 'Win Back' limit 1),
                                    (select id from Platforms_Performance__r where Platform_Online_Status__c = 'Online' limit 1),
                                     (select id,End_Date__c  from Contracts where Service_Type__c = 'Commission Fee' AND End_Date__c < LAST_90_DAYS Order by End_Date__c DESC Limit 1)
                                from Account
                                where id In  :stAccountId]){
            if(accTemp.Opportunities != null &&  accTemp.Opportunities.size() > 0)// check that doesn't have any win back opportunity before
                continue;

            if(accTemp.Platforms_Performance__r != null &&  accTemp.Platforms_Performance__r.size() > 0)// check that there is not platform online
                continue;

            if(accTemp.Contracts != null &&  accTemp.Contracts.size() > 0)// check if there is any contract before that the last 3 months.
                lstOpp.add(new Opportunity(RecordTypeId = StrOppRecordType, AccountId = accTemp.id, Business_Type__c = 'Win Back',OwnerId =  mapBusinessRule.get('OwnerId').Business_Rule_Value__c , StageName = 'New',Name = 'Win Back', CloseDate = Date.Today() ));
        }

        List<Database.saveResult> lstSr =  Database.insert(lstOpp);

        LoggingUtility.createLog('BatchWinbackOpportunities','BATCH','CASE CLOSURE',null);
        Boolean isError = false;
        for(Database.saveResult result : lstSr){
            if(!result.isSuccess()){
                LoggingUtility.logError('BatchWinbackOpportunities','BatchWinbackOpportunities: Update failed for case ' + result.getId() +
                        ' Errors '  + result.getErrors() + '\n');
                isError = true;
            }
        }

        // Do Logging in case of error.
        if(isError){
            LoggingUtility.commitLogs();
        }


    }
    global void finish(Database.BatchableContext BC) {

    }

}