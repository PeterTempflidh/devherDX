/**
* @author Mantas Jurkunas
* @date 08.10.2019
*
* @description Handler class for stock item trigger
*/

public class StockItem_TriggerHandler implements ITrigger {


    public void bulkBefore() {
        if (Trigger.isInsert) {
        }
        if (Trigger.isUpdate) {
            ClsStockItemProcessor.resetRestaurantsNameOnStockItem((Map<Id, Stock_Item__c>) Trigger.newMap, (Map<Id, Stock_Item__c>) Trigger.oldMap);
            ClsStockItemProcessor.stockBeforUpdate(Trigger.new, (Map<Id, Stock_Item__c>) Trigger.oldMap);
            ClsStockItemProcessor.calculateStockUsedDays(Trigger.new);
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