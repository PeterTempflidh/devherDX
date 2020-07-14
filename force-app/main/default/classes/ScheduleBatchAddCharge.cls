global class ScheduleBatchAddCharge implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchSendAddChargeToRogan b = new BatchSendAddChargeToRogan();
        Database.executebatch(b,500);
    }
}