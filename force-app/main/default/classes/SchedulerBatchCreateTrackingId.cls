global class SchedulerBatchCreateTrackingId implements Schedulable{

global void execute(SchedulableContext SC){
        BatchCreateTrackingIdOnAfterShip batch = new BatchCreateTrackingIdOnAfterShip();
        Database.executeBatch(batch,100);
    }
}