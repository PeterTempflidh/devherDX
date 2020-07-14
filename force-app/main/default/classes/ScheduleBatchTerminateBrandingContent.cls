global class ScheduleBatchTerminateBrandingContent implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchTerminateBrandingContent batch = new BatchTerminateBrandingContent();
        Database.executeBatch(batch,500);
    }
}