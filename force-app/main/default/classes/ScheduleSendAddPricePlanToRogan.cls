global class ScheduleSendAddPricePlanToRogan implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchSendAddPricePlanToRogan b = new BatchSendAddPricePlanToRogan();
        Database.executebatch(b,500);
    }
}