/**
 * Created by c.kumari on 17.12.2018.
 */

@isTest
public class UnitTestBatchOnboardingSendSurvey {

    @testSetup
    public static void setupData() {
        UnitTestDataFactory.getRecordtypeValues();

        Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{
                'Case'
        });
        Country__c coun = UnitTestDataFactory.createCountry('DE', 'Germany', 'EUR');
        insert coun;
        Account acc = UnitTestDataFactory.createAccount('BatchSendSurvey', coun, 'DE_Account');
        insert acc;

        Case cs1 = new Case();
        cs1.accountId = acc.Id;
        cs1.type = 'Restaurant Operations';
        cs1.origin = 'Chat';
        cs1.subject = 'Test';
        cs1.recordtypeid = mapRecordtypes.get('DE_Restaurant_Operations').Id;
        cs1.order_number__c = '90123456789012';
        cs1.customer_email__c = 'test@test.com';
        cs1.Case_Reason__c='Bad Restaurant Service';
        cs1.Platform__c = 'PizzaDE';
        cs1.Description = 'test';
        cs1.Status = 'Closed';
        cs1.Closed_Reason__c = 'Successful';
        cs1.Send_Survey__c = false;
        insert cs1;

        // create configs
        Business_Config__c config = UnitTestDataFactory.createBusinessConfig('BatchOnboardingSurvey', 'Process', 'recordTypes', 'DE_Restaurant_Operations', null, 'Global_Config', true, true);
        Business_Config__c config1 = UnitTestDataFactory.createBusinessConfig('BatchOnboardingSurvey', 'Process', 'numberOfDays', '-1', null, 'Global_Config', true, false);
        Business_Config__c config2 = UnitTestDataFactory.createBusinessConfig('BatchOnboardingSurvey', 'Process', 'closedReason', 'Successful', null, 'Global_Config', true, false);
        Business_Config__c config3 = UnitTestDataFactory.createBusinessConfig('BatchOnboardingSurvey', 'Process', 'Status', 'Closed', null, 'Global_Config', true, false);

        insert new List<sObject>{config, config1, config2, config3};

    }

    @isTest
    public static void testBatchOnboardingSendSurvey(){
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        Case casse = [SELECT Id,Status,ClosedDate,RecordType.Id,Closed_Reason__c,Send_Survey__c from Case limit 1];
        system.debug('idd..'+casse.id+'status...'+casse.Status+'RecordTypeId...'+casse.RecordType.Id+'ClosedDate...'+casse.ClosedDate+'Closed_Reason__c....'+casse.Closed_Reason__c+'Send_Survey__c...'+casse.Send_Survey__c);

        Test.startTest();
        BatchOnboardingSendSurvey batch = new BatchOnboardingSendSurvey();
        Database.executebatch(batch);
        Test.stopTest();
        List<Case> cases = [Select Id from Case where Send_Survey__c = true];
        system.assertEquals(1,cases.size());
    }

}