public with sharing class Tarif_Processor {
	
	//public static Set<Id> validateTarifActivation(Set<Id> setOfIdsToProcess){
	public static Set<Id> validateTarifActivation(List<Tarif__c> listOfTarifs){
		Set<Id> setOfFailedIds = new Set<Id>();
		Map<Id,Id> mapOfServiceIds = new Map<Id,Id>(); //key => ServiceId value=> TarifId
		Map<Id,Id> mapOfProductIds = new Map<Id,Id>(); //key => ProductId value=> TarifId


		//System.debug('validateTarifActivation fired. setOfIdsToProcess is : '+listOfTarifs);

		//getting all tarif memnbers of tarif
		//List<Tarif_Member__c> listMembers = new List<Tarif_Member__c>([SELECT Id_Tarif_Item__c,Type__c,Tarif_Name__c FROM Tarif_Member__c WHERE Tarif_Name__c IN:setOfIdsToProcess]);
		Id theId = listOfTarifs[0].Id;

		System.debug('the id to query is : '+theId);

		String queryString = 'SELECT Id_Tarif_Item__c,Type__c,Tarif_Name__c FROM Tarif_Member__c WHERE Tarif_Name__c = \''+theId+'\'';

		//System.debug('the query now is: '+queryString);

		//List<Tarif_Member__c> listMembers = Database.query(queryString);
		List<SObject> listMembers = Database.query(queryString);

		//system.debug('@@@@ calling validateTarifActivation - listMembers ' + listMembers);

		/*List<Tarif_Member__c> listMembers = new List<Tarif_Member__c>([SELECT Id_Tarif_Item__c,Type__c 
																	   FROM Tarif_Member__c 
																	   WHERE Tarif_Name__c = 'a0O11000000qYezEAE']);*/

		System.debug('list of members : ' + listMembers);
	
		//for(Tarif_Member__c member : listMembers){
		for(SObject theObject : listMembers){
			Tarif_Member__c member = (Tarif_Member__c)theObject;

			if(member.Type__c == 'Service'){
				System.debug('Serivce tarif member found');
				if(!mapOfServiceIds.containsKey(member.Id_Tarif_Item__c)){
					mapOfServiceIds.put(member.Id_Tarif_Item__c,member.Tarif_Name__c);
				}
			}

			if(member.Type__c == 'Product'){
				if(!mapOfProductIds.containsKey(member.Id_Tarif_Item__c)){
					mapOfProductIds.put(member.Id_Tarif_Item__c,member.Tarif_Name__c);
				}
			}

		}


		List<List_Service_Price__c> listInactiveServices = new List<List_Service_Price__c>([SELECT Id, Is_Active__c 
																								FROM List_Service_Price__c
																								WHERE Is_Active__c = false
																								AND Id IN: mapOfServiceIds.keySet() ]);
		
		if(!listInactiveServices.isEmpty()){
			System.debug('inactive service item found');
			for(List_Service_Price__c service : listInactiveServices){
				if(!setOfFailedIds.contains(mapOfServiceIds.get(service.Id))){
					setOfFailedIds.add(mapOfServiceIds.get(service.Id));
					System.debug('id of tarif is added to setOfFailedIds : ' + mapOfServiceIds.get(service.Id));
				}
			}
		}

		List<List_Product_Price__c> listInactiveProducts = new List<List_Product_Price__c>([SELECT Id, Is_Active__c 
																								FROM List_Product_Price__c
																								WHERE Is_Active__c = false
																								AND Id IN: mapOfProductIds.keySet() ]);
		if(!listInactiveProducts.isEmpty()){
			for(List_Product_Price__c product : listInactiveProducts){
				if(!setOfFailedIds.contains(mapOfProductIds.get(product.Id))){
					setOfFailedIds.add(mapOfProductIds.get(product.Id));
				}
			}
		}

		return setOfFailedIds;
	}
}