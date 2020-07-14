trigger Stock_Item_Trigger on Stock_Item__c (before insert, before update) {
	if (Trigger_Manager__c.getInstance().Deactivate_StockItems_Trigger__c) return;
	TriggerFactory.createAndExecuteHandler(StockItem_TriggerHandler.class);
}