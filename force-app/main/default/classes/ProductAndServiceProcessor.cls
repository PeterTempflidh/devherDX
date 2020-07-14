public with sharing class ProductAndServiceProcessor {
	public static Set<Id> validateServiceOrProductDeactivation(Set<Id>setOfIdsToProcess){

		Set<Id> setOfFailedIds = new Set<Id>();

		List<Tarif_Member__c> listMembers = new List<Tarif_Member__c>([SELECT Id,Id_Tarif_Item__c,Name,Tarif_Name__c,Tarif_Name__r.Is_Active__c 
																	   FROM Tarif_Member__c 
																	   WHERE Id_Tarif_Item__c IN: setOfIdsToProcess AND Tarif_Name__r.Is_Active__c = true]);
		
		for(Tarif_Member__c member : listMembers){
			if(!setOfFailedIds.contains(member.Id_Tarif_Item__c)){
				setOfFailedIds.add(member.Id_Tarif_Item__c);
			}
		}

		return setOfFailedIds;
	}
}