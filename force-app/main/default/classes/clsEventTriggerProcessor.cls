public class clsEventTriggerProcessor {
    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    
    /**
    * @Description: This method updates the opportunity stage based on the event created
    				1. When creating an event of Type = Meeting AND the stage is not already at a higher stage
					   THEN opportunity stage automatically goes to "Contact Established"
    */
    public static void updateOpportunityStage(List<Event> events){
    	// If the tasks are getting transfered to opportunity from lead on lead conversion, return
    	if(ClsOpportunityProcessor.disableOppUpdateFromActivity)
    		return;
    	
    	// Shortlist the events 
    	List<Event> shortListedEvents = shortListEventsForOppUpdate(events);
    	if(shortListedEvents.size() == 0)
    		return;
    	
    	// Fetch the related Opportunities
    	Set<Id> opportunityIds = new Set<Id>();
    	for(Event  evt : shortListedEvents){
    		opportunityIds.add(evt.whatId);
    	}
    	
    	clsOpportunityProcessor.updateOpportunityOnActivity(opportunityIds,null,shortListedEvents);
    	
    }
    
    public static List<Event> shortListEventsForOppUpdate(List<Event> events){
    	List<Event> shortListedEvents = new List<Event>();
    	Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('opportunityUpdateFromTaskProcess');
    	// If no business configs are defined, return
    	if(mapBusinessLogic == null || mapBusinessLogic.isEmpty())
    		return shortListedEvents;
		
		Map<String, Business_Config__c> mapBusinessRules =	mapBusinessLogic.get('Generic_Activity');
		
		if(mapBusinessRules == null || mapBusinessRules.isEmpty())
			return shortListedEvents;
		
		List<String> eventTypes 		= mapBusinessRules.get('eventTypes').Business_rule_value__c.split(',');
    	for(Event evt : events){
    		// check that the Event is associated with the opportunity
    		if(evt.WhatId == null || !String.valueOf(evt.WhatId).startsWith('006'))
    			continue;
    		if(!eventTypes.contains(evt.type))
	    		continue;
    		
    		shortListedEvents.add(evt);
    	}
    	return shortListedEvents;
    }
    
}