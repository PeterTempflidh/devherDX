trigger EventTrigger on Event (after insert, after update) {
 	if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
 		clsEventTriggerProcessor.updateOpportunityStage(Trigger.New);
 	}   
} 