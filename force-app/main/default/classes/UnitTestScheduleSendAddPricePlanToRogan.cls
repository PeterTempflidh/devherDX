/**
 * Created by marco.zeuli on 14/2/2018.
 */

@IsTest
private class UnitTestScheduleSendAddPricePlanToRogan {
    @isTest static void scheduleWorksCorrectly() {
        Id jobId;

        Test.startTest();
        jobId = System.schedule('test job', '0 0 0 * * ?', new ScheduleSendAddPricePlanToRogan());
        Test.stopTest();

        CronTrigger[] jobs = [Select Id from CronTrigger Where Id = : jobId];

        System.assert(!jobs.isEmpty());
    }
}