global class ScheduleBatchTerminateAddOns implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchTerminateAddOns batch = new BatchTerminateAddOns();
        Database.executeBatch(batch,500);
    }
}