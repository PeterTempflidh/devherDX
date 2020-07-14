@isTest
private class UnitTestBatchUpdateSendSurveyOnCase{


    static Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Case'});
    @isTest static void testBatchUpdateSendSurveyOnCase() {
        UnitTestDataFactory.getRecordtypeValues();
        DateTime dateValue =  System.Now() - 3;
        Case newCase = new Case(RecordTypeId =mapRecordtypes.get('Talabat_Inbound_Case').id,status = 'Resolved',Date_Time_Resolved__c = dateValue,Country__c = 'Oman',
                Subject = 'test',Description = 'Test Desc', Platform__c = 'Talabat',Type='Customer',Order_Number__c = '0',Customer_Email__c = 'test@test.com',
                Case_Reason_Level_1__c ='Across Journey',Case_Reason_Level_2__c ='Technical issue',Case_Reason_Level_3__c ='Website issue');
        insert newCase;

        Database.QueryLocator queryLoc;
        Database.BatchableContext batchConx;
        List<Case> caseList = new List<Case>();
        BatchUpdateSendSurveyOnCase batchUpdate = new BatchUpdateSendSurveyOnCase('Select id,recordtype.developername, status,Date_Time_Resolved__c,Survey_Date__c, Send_Survey__c from Case where status = \'Resolved\' AND Survey_Date__c = null AND recordtype.developername = \'Talabat_Inbound_Case\'');
        queryLoc = batchUpdate.start(batchConx);

        Database.QueryLocatorIterator QIT = queryLoc.iterator();
        while (QIT.hasNext()) {
            Case caseRec = (Case) QIT.next();
            System.debug(caseRec);
            caseList.add(caseRec);
        }
        Test.startTest();
        batchUpdate.execute(batchConx, caseList);
        batchUpdate.finish(batchConx);
        Test.stopTest();

        Case caseRec = [select id,Send_Survey__c from Case where id IN :caseList];
        System.assertEquals(true,caseRec.Send_Survey__c);
    }

    @isTest static void testScheduleBatchUpdateSendSurveyOnCase() {
        UnitTestDataFactory.getRecordtypeValues();
        Id jobId;

        Test.startTest();
        ScheduledBatchUpdateSendSurveyOnCase scdJob = new ScheduledBatchUpdateSendSurveyOnCase();
        scdJob.batchSize = 200;
        DateTime currentDateTime = DateTime.Now().addHours(-3);
        String actualTime = currentDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        scdJob.queryString = 'Select id,recordtype.developername, status,Date_Time_Resolved__c,Survey_Date__c, Send_Survey__c from Case where status = \'Resolved\' AND Survey_Date__c = null AND recordtype.developername = \'Talabat_Inbound_Case\' and Date_Time_Resolved__c < ';
        jobId = System.schedule('test job', '0 0 0 * * ?', scdJob);
        Test.stopTest();

        CronTrigger[] jobs = [Select Id from CronTrigger Where Id = : jobId];

        System.assert(!jobs.isEmpty());

    }
}