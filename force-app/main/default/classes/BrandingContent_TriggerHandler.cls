/**
* @author Mantas Jurkunas
* @date 08.10.2019
*
* @description Handler class for Branding Content trigger
*/

public class BrandingContent_TriggerHandler implements ITrigger {


    public void bulkBefore() {
        if (Trigger.isInsert) {
            ClsBrandingContent.updateRecordCountry(Trigger.new);
        }
        if (Trigger.isDelete) {
            ClsBrandingContent.updateAccountBrandingStatus(Trigger.old);
        }
    }

    public void bulkAfter() {
        if (Trigger.isUpdate) {
            ClsBrandingContent.updateOppOnBrandingActivation(Trigger.new, (Map<Id, Branding_Content__c>) Trigger.oldMap);
            ClsBrandingContent.updateAccountBrandingStatus(Trigger.new, (Map<Id, Branding_Content__c>) Trigger.oldMap);
            ClsBrandingContent.createBackendEntryCase(Trigger.new, (Map<Id, Branding_Content__c>) Trigger.oldMap);
        }

        if (Trigger.isInsert) {
            ClsBrandingContent.updateAccountBrandingStatus(Trigger.new);
        }
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