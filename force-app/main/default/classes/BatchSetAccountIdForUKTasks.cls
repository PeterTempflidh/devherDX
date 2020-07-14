global class BatchSetAccountIdForUKTasks implements Database.Batchable<sObject> {
	
	String query;
	
	global BatchSetAccountIdForUKTasks(String q) {
		query = q;//'SELECT Id, WhatId, AccountId FROM Task WHERE AccountId = null AND WhatId != null AND RecordType.DeveloperName = \'UK_Task\'';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Task> taskScope = (List<Task>) scope;

		List<Task> updateTaskWhatId = new List<Task>();
		Set<Id> whatIds = new Set<Id>();

		//List<Task> taskList = [SELECT Id, WhatId, AccountId FROM Task WHERE AccountId = null AND WhatId != null AND RecordType.DeveloperName = 'UK_Task' LIMIT 1];
		
		for(Task tsk : taskScope) {
		    System.debug('RIJAD: Task ID: ' + tsk.Id);
		    if(tsk.WhatId != null)
		        whatIds.add(tsk.WhatId);
		}

		Map<Id, Case> casesList = new Map<Id, Case>([SELECT AccountId FROM Case WHERE AccountId != null AND Id IN :whatIds]);
		Set<Id> accountIds = new Set<Id>();
		for(Case c : casesList.values()) {
		    accountIds.add(c.AccountId);
		}

		List<Contact> contactList = [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds];
		Map<Id, Contact> contactByAcc = new Map<Id, COntact>();
		for(Contact c : contactList) {
		    contactByAcc.put(c.AccountId, c);
		}
		for(Task t : taskScope) {
		   Case ce = casesList.get(t.WhatId);
		    if(ce != null) {
		        Contact con = contactByAcc.get(ce.AccountId);
		        if(con != null) {
		            t.WhoId = con.Id;
		            updateTaskWhatId.add(t);
		        }
		    }
		}
		if(updateTaskWhatId.size() > 0)
			update updateTaskWhatId;
		for(Task result : updateTaskWhatId) {
		    System.debug('RIJAD Result Id: ' + result.Id);
		    System.debug('RIJAD Result WhoId: ' + result.WhoId);
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}