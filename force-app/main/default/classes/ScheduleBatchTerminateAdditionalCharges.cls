global class ScheduleBatchTerminateAdditionalCharges implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchTerminateAdditionalCharges batch = new BatchTerminateAdditionalCharges();
        Database.executeBatch(batch,500);
    }
}