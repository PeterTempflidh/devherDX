/**
 * Created by w.novoa on 22.06.2018.
 */

public with sharing class ClsAsyncEventBusExecution implements Queueable{

    public final map<Id,Platform_Performance__c> mpPlatform;

    public ClsAsyncEventBusExecution(map<Id,Platform_Performance__c> mpPlatform){
        this.mpPlatform = mpPlatform;
    }
    public void execute(QueueableContext context) {
        EventBusHelper.ValidateRecordsPlatform('Platform', mpPlatform);
    }

}