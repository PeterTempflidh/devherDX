/**
 * @Class       : ClsKeyAccountUpdateSchedulable 
 * @Created Date : [20/05/2020]
 * @description This is the scheduler class used on the Key Account Update
*/

public class ClsKeyAccountUpdateSchedulable implements Schedulable {
    public Map<Id,Boolean> accountKeyAccountMap = new Map<Id,Boolean>();
    
    /**
     * @Class       : ClsKeyAccountUpdateSchedulable
     * @Created Date : [20/05/2020]
     * @description This is used on the Key Account Update
     * @param  accountKeyAccountMap Map<Id,Boolean>
    */
    public ClsKeyAccountUpdateSchedulable(Map<Id,Boolean> accountKeyAccountMap){
        this.accountKeyAccountMap = accountKeyAccountMap;
    }
    
    /**
    * @date     : [20/05/2020]
    * @method name  : execute
    * @description  : Schedule Job
    * @param  sc SchedulableContext
    */
    public void execute(SchedulableContext sc) {
        System.enqueueJob(new ClsKeyAccountUpdateQueueable(accountKeyAccountMap));
        // Abort the job once the job is queued
        System.abortJob(sc.getTriggerId());
    }
}