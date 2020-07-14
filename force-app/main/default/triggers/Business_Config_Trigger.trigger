trigger Business_Config_Trigger on Business_Config__c ( 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

	// clear cache
	LibBusinessConfig.cleanOrgCache();
}