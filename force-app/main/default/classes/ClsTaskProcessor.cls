public with sharing class ClsTaskProcessor {
	private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    public static final string ERROR_MAPPING_TASK_RECORD = 'Mapping Of Task Failed';
    public static final string METHOD_SYNC_TASK_OBJECT = 'syncTaskObject Method : ';
    public static final string ERROR_UPDATE_TASK_FAILED = 'Update Failed On Task Object';
    public static final string METHOD_UPDATE_TASK = 'relatedTaskWithAssociatedCode Method : ';
	
    /**
     * Updates case's Last_Call_Date__c field when a new call is logged
     * @param tasksList Logged calls
     */
    public static void updateCaseLastCallDate(List<task> tasksList) {
        System.debug('ClsTaskProcessor.updateCaseLastCallDate: start');

        Map<Id, Task> caseIdToLastCall = new Map<Id, Task>();
        List<Case> toUpdate = new List<Case>();

        try {
            // filter tasks
            for (Task ts : tasksList) {

                if (ts.Type == 'Call'
                        && ts.WhatId != null
                        && String.valueOf(ts.WhatId).startsWith('500') // is a case
                        && ts.Status == 'Completed') {
                    caseIdToLastCall.put(ts.WhatId, ts);
                }
            }

            System.debug('ClsTaskProcessor.updateCaseLastCallDate: caseIdToLastCall size is: ' + caseIdToLastCall.size());

            if (caseIdToLastCall.isEmpty()) {
                return; // nothing to do
            }

            // gets cases
            for (Case cs : [
                        Select Last_Call_Date__c
                        From Case
                        Where Id in :caseIdToLastCall.keySet()
                    ]) {
                cs.Last_Call_Date__c = caseIdToLastCall.get(cs.Id).CreatedDate;
                toUpdate.add(cs);
            }

            System.debug('ClsTaskProcessor.updateCaseLastCallDate: cases to update are: ' + toUpdate);

            // updates cases
            if (!toUpdate.isEmpty()) {
                update toUpdate;
            }

        } catch (Exception e ) {
            System.debug('ClsTaskProcessor.updateCaseLastCallDate: exception occurred. Message is: ' + e.getMessage());
        }

        System.debug('ClsTaskProcessor.updateCaseLastCallDate: done');
    }

    /**
     * Updates lead's Last_Call_Date__c field when a new call is logged
     * @param tasksList Logged calls
     */
    public static void updateLeadLastCallDate(List<task> tasksList) {
        System.debug('ClsTaskProcessor.updateLeadLastCallDate: start');

        Map<Id, Task> leadIdToLastCall = new Map<Id, Task>();
        List<Lead> toUpdate = new List<Lead>();

        try {

            // filter calls
            for (Task ts : tasksList) {
                if (ts.Type == 'Call'
                        && ts.WhoId != null
                        && String.valueOf(ts.WhoId).startsWith('00Q') // is a Lead
                        && ts.Status == 'Completed') {
                    leadIdToLastCall.put(ts.WhoId, ts);
                }
            }

            System.debug('ClsTaskProcessor.updateLeadLastCallDate: leadIdToLastCall size is: ' + leadIdToLastCall.size());

            if (leadIdToLastCall.isEmpty()) {
                return; // nothing to do
            }

            // gets Leads
            for (Lead ld : [
                        Select Last_Call_Date__c
                        From Lead
                        Where Id in :leadIdToLastCall.keySet()
                    ]) {
                ld.Last_Call_Date__c = leadIdToLastCall.get(ld.Id).CreatedDate;
                toUpdate.add(ld);
            }

            System.debug('ClsTaskProcessor.updateLeadLastCallDate: lead to update are: ' + toUpdate);

            // updates leads
            if (!toUpdate.isEmpty()) {
                update toUpdate;
            }

        } catch (Exception e ) {
            System.debug('ClsTaskProcessor.updateLeadLastCallDate: exception occurred. Message is: ' + e.getMessage());
        }

        System.debug('ClsTaskProcessor.updateLeadLastCallDate: done');
    }


    /*public static void convertTaskToCases(List<Task> tasks){
        system.debug('Inside Trigger : Task_Trigger: ' + tasks);
        List<Task> taskToDelete = new List<Task>();
        List<Case> newCases = new List<Case>();

        for(Task t : tasks){
            if(t.IsClosed && t.Subject.indexOf('Email') != -1){
                newCases.add(createClosedCase(t));
                taskToDelete.add(new Task(Id = t.Id));
            }
        }

        try {
            delete taskToDelete;
        } catch(Exception e){
            system.debug('@@@@ calling Task_Trigger  - ERROR OCCURRED:  '  + e.getMessage());
        }

        system.debug('Inside Trigger : newCases: ' + newCases);

        try{
            List<Database.Saveresult> result = Database.insert(newCases);
            system.debug('Inside Trigger : result: ' + result);
        } catch(Exception e){
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, Label.Quote_Email_Activity_History_Creation_Error));
            System.debug('@@@@ The following error occured while creating the email log for the quote email : ' + e.getMessage());
        }
    }

    public static Case createClosedCase(Task t){
        Case closedCase = new Case();
        closedCase.Subject = 'Email : ' + t.Subject;
        closedCase.Priority = 'Normal';
        closedCase.AccountId = t.AccountId;
        closedCase.OwnerId = Userinfo.getUserId();
        closedCase.Status = 'Closed';
        return closedCase;

    }*/





    public static void updateLeadStatus(List<Task> tasksList, Map<Id, Task> oldTaskMap) {
        Map<Id, Task> leadTaskMap = new Map<Id, Task>();
        for (Task ts : tasksList) {
            if (ts.Type != null && ts.WhoId != null) {
                if (ts.Type == 'Call' && string.valueof(ts.WhoId).indexof('00Q') == 0) {
                    leadTaskMap.put(ts.WhoId, ts);
                }
            }
        }
        List<Lead> updateOppList = new List<Lead>();
        if (!leadTaskMap.isEmpty()) {
            for (Lead lead : [SELECT Status FROM Lead WHERE Id IN :leadTaskMap.keySet() FOR UPDATE]) {
                if (leadTaskMap.get(lead.Id) != null) {
                    if (leadTaskMap.get(lead.Id).Activity_Subject__c != null) {
                        if (lead.Status == 'Lost' || lead.Status == 'Contacted') {
                            return;
                        }
                        if (leadTaskMap.get(lead.Id).Activity_Subject__c.containsIgnoreCase('decision maker reached') && lead.Status != 'Contacted') {
                            lead.Status = 'Contacted';
                            updateOppList.add(lead);
                        }
                        if (lead.Status != 'Open' && leadTaskMap.get(lead.Id).Activity_Subject__c.containsIgnoreCase('employee reached') || leadTaskMap.get(lead.Id).Activity_Subject__c.containsIgnoreCase('nobody reached')) {
                            lead.Status = 'Open';
                            updateOppList.add(lead);
                        }
                    }
                }
            }
        }
        if (!updateOppList.isEmpty())
            update updateOppList;
    }
    
    /**
    * @Description: This method updates the Opportunity stage based on the logged call activity
    				1. WHEN logging the call related to the Opp with Activity_Subject__c = "Call - Nobody reached" OR 
    					"Call - Employee reached" AND the stage is not already at a higher stage
						THEN opportunity stage automatically goes to "Open"
					2. WHEN logging the call with Activity_Subject__c = "Call - Decision maker reached" AND the stage is not 
						already at a higher stage THEN opportunity stage automatically goes to "Contact Established"
	 @TriggerContext: After Insert, After Update					
    */
    public static void updateOpportunityStage(List<Task> tasks){
    	// If the tasks are getting transfered to opportunity from lead on lead conversion, return
    	if(ClsOpportunityProcessor.disableOppUpdateFromActivity)
    		return;
    		
    	// Shortlist the tasks 
    	List<Task> shortlistedTasks  = shortListTasksForOpportunityStageUpdate(tasks);
    	if(shortlistedTasks.size()== 0)
    		return;
    		
    	// Fetch the related Opportunities
    	Set<Id> opportunityIds = new Set<Id>();
    	for(Task ts : shortlistedTasks){ 
    		opportunityIds.add(ts.whatId);
    	}
    	clsOpportunityProcessor.updateOpportunityOnActivity(opportunityIds,shortlistedTasks,null);
    }
    
    /**
    * @Description: Shortlist task based on the Type and Acitivity subject
    */
    public static List<Task> shortListTasksForOpportunityStageUpdate(List<Task> tasks){
    	List<Task> shortListedTask = new List<Task>();
    	Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('opportunityUpdateFromTaskProcess');
    	// If no business configs are defined, return
    	if(mapBusinessLogic == null || mapBusinessLogic.isEmpty())
    		return shortListedTask;
		
		Map<String, Business_Config__c> mapBusinessRules =	mapBusinessLogic.get('Generic_Activity');
		
		if(mapBusinessRules == null || mapBusinessRules.isEmpty())
			return shortListedTask;
    	
    	List<String> validActivitySubjectsForCEStage 	= mapBusinessRules.get('CEAcitvitySubject').Business_rule_value__c.split(',');
	   	List<String> validActivitySubjectsForOpenStage 	= mapBusinessRules.get('openAcitvitySubject').Business_rule_value__c.split(',');		
    	List<String> taskTypes 							= mapBusinessRules.get('taskTypes').Business_rule_value__c.split(',');
    	List<String> taskStatuses 						= mapBusinessRules.get('taskStatus').Business_rule_value__c.split(',');
    	
    	for(Task task : tasks){
    		// check that the task is associated with the opportunity
    		if(task.WhatId == null || !String.valueOf(task.WhatId).startsWith('006'))
    			continue;
    		// if the type is not the desired type, continue
    		if(!taskTypes.contains(task.type))
    			continue;
    		// If the task tatus is not the desired status, continue
    		if(!taskStatuses.contains(task.status))
    			continue;
    			
    		if(!validActivitySubjectsForCEStage.contains(task.Activity_Subject__c) &&
    		    !validActivitySubjectsForOpenStage.contains(task.Activity_Subject__c))
    		    	continue;
    				
    		shortListedTask.add(task);
    	}
    	
    	return shortListedTask;
    }

    /**
    * @date     : [18/05/2020]
    * @method name  : setTaskCode
    * @description  : Add Code field on the Task Object
    * @param  newTasks List<Task>
    * @retun : None
    */
    public static void setTaskCode(List<Task> newTasks){
        List<Task> tasksToUpdate = new List<Task>();
        for(Task objTask : newTasks){
            if(String.isBlank(objTask.Code__c)){
                tasksToUpdate.add(new Task(Id = objTask.Id,Code__c = objTask.Id));
            }
        }
        if(!tasksToUpdate.isEmpty()){
            update tasksToUpdate;
        }
    }

    /**
    * @date     : [06/05/2020]
    * @method name  : syncTaskObject
    * @description  : Copy Task Fields to another task on the basis of Code
    * @param taskList [List Of New Task Object]
    * @param taskMap [Old Map of Task Id and Task Object]
    */
    public static void syncTaskObject(List<Task> taskList, Map<Id, Task> taskMap) {

        Map<String,Task> mapOfCodeWithTask = new Map<String,Task>();
        Map<Id,Task> mapOfIdWithTask = new Map<Id,Task>();
        try {
            for (Task objTask : taskList) {
                if (String.isNotBlank(objTask.WhatId) && checkTaskFieldValues(objTask, taskMap)
                        && String.valueOf(objTask.WhatId.getsobjecttype()) == Constants.SOBJECT_ACTION_ITEM) {
                    mapOfIdWithTask.put(objTask.Id,objTask);
                    mapOfCodeWithTask.put(objTask.Code__c,objTask);
                }
            }

            if(!mapOfCodeWithTask.isEmpty()){
                updateAllTaskAssociatedWithCode(mapOfIdWithTask,mapOfCodeWithTask);
            }
        } catch (Exception ex) { ClsLogErrorMessage.logMessages(ERROR_MAPPING_TASK_RECORD,
                METHOD_SYNC_TASK_OBJECT + ex.getMessage() + ex.getStackTraceString());
        }
    }

    /**
    * @date     : [06/05/2020]
    * @method name  : updateAllTaskAssociatedWithCode
    * @description  : Logic to update all the task associated with the Code
    * @param mapOfIdWithTask [Map Of Task Id and Task Object]
    * @param mapOfCodeWithTask [Map of Task Code and Task Object]
    */
    private static void updateAllTaskAssociatedWithCode(Map<Id,Task> mapOfIdWithTask,
            Map<String,Task> mapOfCodeWithTask) {

        List<Task> listOfTaskToUpdate = new List<Task>();
        try {
            for (Task objTask : ActivitySelector.getTaskDetailsByCode(mapOfCodeWithTask.keySet())) {
                if (!mapOfIdWithTask.containsKey(objTask.Id)) {
                    Boolean checkUpdatedField = false;
                    Task taskInstance = mapOfCodeWithTask.get(objTask.Code__c);
                    for (String taskField : getTaskFieldToMap()) {
                        if(objTask.get(taskField) != taskInstance.get(taskField)){
                            objTask.put(taskField, taskInstance.get(taskField));
                            checkUpdatedField = true;
                        }
                    }
                    if(checkUpdatedField){
                        listOfTaskToUpdate.add(objTask);
                    }
                }
            }
            if (!listOfTaskToUpdate.isEmpty()) {
                Database.update(listOfTaskToUpdate, false);
            }

        }catch (Exception ex) { ClsLogErrorMessage.logMessages(ERROR_UPDATE_TASK_FAILED,
                METHOD_UPDATE_TASK + ex.getMessage() + ex.getStackTraceString());
        }
    }

    /**
    * @date     : [17/05/2020]
    * @method name  : getTaskFieldToMap
    * @description  : Get taskFields to Map
    * @return : List<String>
    */
    private static List<String> getTaskFieldToMap() {
        Map<String, Business_Config__c> mapOfTaskData =  new Map<String, Business_Config__c>();
        List<String> taskFieldToMap = new List<String>();

        mapOfTaskData = moam.get(Constants.BUSINESSCONFIG_PROCESSNAME_SYNCTASKS).get(Constants.BUSINESSCONFIG_RECORDTYPE_TALABATTASK);
        taskFieldToMap = mapOfTaskData.get(Constants.BUSINESSCONIFG_RULENAME_TASKFIELDTOMAP) != null ?
                mapOfTaskData.get(Constants.BUSINESSCONIFG_RULENAME_TASKFIELDTOMAP).Business_Rule_Value__c.split(',') : new List<String>();

        return taskFieldToMap;
    }

    /**
    * @date     : [06/05/2020]
    * @method name  : checkTaskFieldValues
    * @description  : Logic to check the Task Object old and new values
    * @param objTask [Task Instance Object]
    * @param taskMap [Old Map of Task Id and Object]
    * @return : Boolean
    */
    private static Boolean checkTaskFieldValues(Task objTask, Map<Id, Task> taskMap) {

        for (String taskField : getTaskFieldToMap()) {
            if(taskMap.get(objTask.Id).get(taskField) != objTask.get(taskField)){
                return true;
            }
        }
        return false;
    }
}