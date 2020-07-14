/**
 * Created by c.kumari on 24.09.2019.
 */

public with sharing class BankDetail_TriggerHandler implements ITrigger{

    public void bulkBefore() {
        if(trigger.isUpdate){
            //SSC-3006
            BankDetail_Utils.validateApprovals(Trigger.new,Trigger.oldMap);
        }
        BankDetail_Utils.blockUpsertOnQualityCheckOpp(Trigger.new); 
        BankDetail_Utils.activateBankDetailRecord(Trigger.new,Trigger.oldMap);
    }

    public void bulkAfter() {
    }

    public void beforeInsert(SObject so) {
    }

    public void beforeUpdate(SObject oldSo, SObject so) {
    }

    public void beforeDelete(SObject so) {
    }

    public void afterInsert(SObject so) {
    }

    public void afterUpdate(SObject oldSo, SObject so) {
    }

    public void afterDelete(SObject so) {
    }

    public void andFinally() {
        BankDetail_Utils.updateChildRecordStatus();
    }
}
