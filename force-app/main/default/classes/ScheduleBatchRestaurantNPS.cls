global class ScheduleBatchRestaurantNPS implements Schedulable{

global void execute(SchedulableContext SC){
        BatchRestaurantNPS batch = new BatchRestaurantNPS (500);
        Database.executeBatch(batch);
    }
}