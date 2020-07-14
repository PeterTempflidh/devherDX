/**
 * Created by m.jurkunas on 8/22/19.
 */

public with sharing class xALAddress_TriggerHandler implements ITrigger {

    public void bulkBefore() {
        if (!Trigger.isDelete) {
            xALAddress_Utils.populateAddressIds(Trigger.new);
        }
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
    }
}