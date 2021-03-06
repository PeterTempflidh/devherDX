/**
* @author Mantas Jurkunas
* @date 08.10.2019
*
* @description Handler class for account trigger
*/

public class Account_TriggerHandler implements ITrigger {

    public void bulkBefore() {
        if (Trigger.isUpdate) {
            ClsAccountProcessor.verifyGRID(Trigger.new, (Map<Id, Account>) Trigger.oldMap);
            ClsAccountProcessor.UpdateAccountCountryOnOpportunity(Trigger.new, (Map<Id, Account>) Trigger.oldMap);
            ClsAccountProcessor.UpdateAccountCountryOnShippingOrders(Trigger.new, (Map<Id, Account>) Trigger.oldMap);
        }
        ClsAccountProcessor.assignRecordCountryToBillingCountry(Trigger.new, (Map<Id, Account>) Trigger.oldMap);
        LibBusinessConfig.setSObjectCurrencyAndCompanyCode(Trigger.new);
        ClsAccountProcessor.checksBillingAndMailingCityValues(Trigger.new, (Map<Id, Account>) Trigger.oldMap);
    }

    public void bulkAfter() {
        if (Trigger.isInsert) {
            ClsAccountProcessor.setGRID(Trigger.new);
            ClsAccountProcessor.copyFacilityAddressToAssociatedKitchen(Trigger.new,null); // SSC-335
        }
        if (Trigger.isUpdate) {
            //ClsAccountProcessor.menuProcessingClosingAction(Trigger.new, Trigger.oldMap);
            ClsAssetProcessor.checkIfAssetIsInUse(Trigger.new, (Map<Id, Account>) Trigger.oldMap);
            EventBusHelper.ValidateRecords('Account',Trigger.newMap, Trigger.oldMap,Trigger.isInsert);
            ClsAccountProcessor.updateOwnershipInMidas(Trigger.new, (Map<Id, Account>) Trigger.oldMap);
            ClsAccountProcessor.updateRelatedRecordCountries(Trigger.new, (Map<Id, Account>) Trigger.oldMap);
            ClsAccountProcessor.updateFacilityDetails(Trigger.new,(Map<Id, Account>)Trigger.oldMap); // SSC-335
            ClsAccountProcessor.copyFacilityAddressToAssociatedKitchen(Trigger.new,(Map<Id, Account>)Trigger.oldMap); // SSC-335
            ClsAccountProcessor.updateChildAccounts(Trigger.New,(Map<Id,Account>) Trigger.oldMap); //SSC-1990
        }
        if(Trigger.isDelete){
            ClsAccountProcessor.updateFacilityDetails(Trigger.old,null); // SSC-335
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
