/**
 * Created by w.novoa on 31.08.2018.
 */

global with sharing class ScheduleBatchWinbackDE implements Schedulable{
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new BatchWinbackOpportunities('DE_Account'));
    }
}