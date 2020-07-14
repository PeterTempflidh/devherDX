public with sharing class ClsContactProcessor {
	public static void enforceOneOwnerRoleForAccountContacts(List<Contact> contacts){
		Map<Id, List<Contact>> contactsByAccountIdMap = new Map<Id, List<Contact>>();
		Set<Id> accountIds = new Set<Id>();
		Set<Id> contactIds = new Set<Id>();

		for(Contact con : contacts){
			accountIds.add(con.AccountId);
			contactIds.add(con.Id);
		}

		List<Contact> relevantContacts = [SELECT Id, Contact_Role__c, AccountId FROM Contact WHERE (AccountId IN : accountIds AND Id NOT IN :contactIds)];

		for(Contact con : relevantContacts){
			if(contactsByAccountIdMap.get(con.AccountId) != null){
				contactsByAccountIdMap.get(con.AccountId).add(con);
			} else {
				contactsByAccountIdMap.put(con.AccountId, new List<Contact>{con});
			}
		}

		for(Contact con : contacts){
			if(con.Contact_Role__c != null && contactsByAccountIdMap.get(con.AccountId) != null && con.Contact_Role__c.equals('Owner')){
				for(Contact cn : contactsByAccountIdMap.get(con.AccountId)){
					if(cn.Contact_Role__c != null && cn.Contact_Role__c.equals('Owner')){
						con.addError(Label.Contact_Multiple_Owner_Contact_Role);
					}
				}
			}
		}
	}
}