global class ScheduleBatchSendContacts implements Schedulable{

global void execute(SchedulableContext SC){
        BatchSendContacts batch = new BatchSendContacts ();
        Database.executeBatch(batch);
    }
}