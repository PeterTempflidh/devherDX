global class BatchLinkServiceListWithOppQuoteService implements Database.Batchable<sObject>, Database.Stateful {
	
	String query = 'SELECT Id,Name,Id_List_Service_Price__c,Commission_In_Percentage__c,Id_Opportunity_Quote__r.Id_Opportunity__r.Record_Country__c FROM Opportunity_Quote_Service_Item__c where Id_List_Service_Price__c=null';
	Map<String,List_Service_Price__c> mapofServiceNameCountryWithId;
	Map<String,List_Service_Price__c> mapOfDuplicateServicewithcommission;
	Integer totalRecordsUpdated = 0;
	Integer totalRecodsNotUpdated = 0;
	Integer totalRecords = 0;
	List<Opportunity_Quote_Service_Item__c> recordsNotUpDated = new List<Opportunity_Quote_Service_Item__c>();

	global BatchLinkServiceListWithOppQuoteService() {
		mapofServiceNameCountryWithId = new Map<String,List_Service_Price__c>();
		mapOfDuplicateServicewithcommission = new Map<String,List_Service_Price__c>();
		Set<String> duplicate = new Set<String>();
		//Map<String,Id> duplicateCommisiionMap = new Map<String,Id>();
		for(List_Service_Price__c  result : [SELECT id,Name,Commission_In_Percentage__c,Id_Country__r.name FROM List_Service_Price__c order by name]){
			String nameCountry = result.name+'@'+result.Id_Country__r.name;
   			String nameCountryComm = null;
   			System.debug('nameCountry: '+nameCountry);
   			if(result.name=='요기팩기본 (주)푸디아 / 미스터보쌈5379' && mapofServiceNameCountryWithId.get('요기팩 기본 (주)푸디아 / 미스터보쌈5379@'+result.Id_Country__r.name)==null){
   				mapofServiceNameCountryWithId.put('요기팩 기본 (주)푸디아 / 미스터보쌈5379@'+result.Id_Country__r.name,result);
   			}else if(result.name=='Total Commission' && mapofServiceNameCountryWithId.get('Commission Fee (Super Hero)@'+result.Id_Country__r.name)==null){
   				mapofServiceNameCountryWithId.put('Commission Fee (Super Hero)@'+result.Id_Country__r.name,result);
   			}else if(result.name=='White Label Discount' && mapofServiceNameCountryWithId.get('White Label Website@'+result.Id_Country__r.name)==null){
   				mapofServiceNameCountryWithId.put('White Label Website@'+result.Id_Country__r.name,result);
   			}else if(result.name=='Order Now Discount' && mapofServiceNameCountryWithId.get('Order Now Button@'+result.Id_Country__r.name)==null){
   				mapofServiceNameCountryWithId.put('Order Now Button@'+result.Id_Country__r.name,result);
   			}else if(result.name=='요기팩기본 (주)멕시카나 / 멕시카나치킨' && mapofServiceNameCountryWithId.get('요기팩 기본 (주)멕시카나 / 멕시카나치킨@'+result.Id_Country__r.name)==null){
   				mapofServiceNameCountryWithId.put('요기팩 기본 (주)멕시카나 / 멕시카나치킨@'+result.Id_Country__r.name,result);
   			}else if(result.name=='요기팩기본 (주)한국일오삼농산 / 처갓집양념치킨' && mapofServiceNameCountryWithId.get('요기팩 기본 (주)한국일오삼농산 / 처갓집양념치킨@'+result.Id_Country__r.name)==null){
   				mapofServiceNameCountryWithId.put('요기팩 기본 (주)한국일오삼농산 / 처갓집양념치킨@'+result.Id_Country__r.name,result);
   			}else if(result.name=='요기팩기본 (주)에땅 / 피자에땅' && mapofServiceNameCountryWithId.get('요기팩 기본 (주)에땅 / 피자에땅@'+result.Id_Country__r.name)==null){
   				mapofServiceNameCountryWithId.put('요기팩 기본 (주)에땅 / 피자에땅@'+result.Id_Country__r.name,result);
   			}else if(result.name=='요기팩기본 (주)농협목우촌 / 또래오래' && mapofServiceNameCountryWithId.get('요기팩 기본 (주)농협목우촌 / 또래오래@'+result.Id_Country__r.name)==null){
   				mapofServiceNameCountryWithId.put('요기팩 기본 (주)농협목우촌 / 또래오래@'+result.Id_Country__r.name,result);
   			}else if(result.name=='요기팩기본 (주)원앤원 / 원할머니보쌈' && mapofServiceNameCountryWithId.get('요기팩기본 원앤원(주) / 원할머니보쌈@'+result.Id_Country__r.name)==null){
   				mapofServiceNameCountryWithId.put('요기팩기본 원앤원(주) / 원할머니보쌈@'+result.Id_Country__r.name,result);
   			}else if(result.name=='요기팩기본 (유)비에이치씨 / BHC치킨' && mapofServiceNameCountryWithId.get('요기팩기본 (유)비에이치씨-bhc@'+result.Id_Country__r.name)==null){
   				mapofServiceNameCountryWithId.put('요기팩기본 (유)비에이치씨-bhc@'+result.Id_Country__r.name,result);
   			}else if(result.name=='요기팩기본 (주)맥시칸 / 맥시칸치킨' && mapofServiceNameCountryWithId.get('요기팩기본 (주)계림푸드원 / 맥시칸치킨@'+result.Id_Country__r.name)==null){
   				mapofServiceNameCountryWithId.put('요기팩기본 (주)계림푸드원 / 맥시칸치킨@'+result.Id_Country__r.name,result);
   			}else if(result.name=='요기팩기본 [프로모션 8%] 한국맥도날드(유) / 맥도날드' && mapofServiceNameCountryWithId.get('요기팩기본 한국맥도날드(유) / 맥도날드@'+result.Id_Country__r.name)==null){
   				mapofServiceNameCountryWithId.put('요기팩기본 한국맥도날드(유) / 맥도날드@'+result.Id_Country__r.name,result);
   			}else if(result.name=='요기팩기본 주식회사김가네 / 김가네' && mapofServiceNameCountryWithId.get('요기팩 기본 주식회사김가네 / 김가네@'+result.Id_Country__r.name)==null){
   				mapofServiceNameCountryWithId.put('요기팩 기본 주식회사김가네 / 김가네@'+result.Id_Country__r.name,result);
   			}else if(result.name=='요기팩기본 한국파파존스(주) / 파파존스' && mapofServiceNameCountryWithId.get('요기팩 기본 한국파파존스(주) / 파파존스@'+result.Id_Country__r.name)==null){
   				mapofServiceNameCountryWithId.put('요기팩 기본 한국파파존스(주) / 파파존스@'+result.Id_Country__r.name,result);
   			}else if(result.name=='요기팩기본 (주)롯데리아 / 롯데리아' && mapofServiceNameCountryWithId.get('요기팩 기본 [제휴 0%] (주)롯데리아 / 롯데리아@'+result.Id_Country__r.name)==null){
   				mapofServiceNameCountryWithId.put('요기팩 기본 [제휴 0%] (주)롯데리아 / 롯데리아@'+result.Id_Country__r.name,result);
   			}else if(result.name=='Yogiyo Basic 12%' && mapofServiceNameCountryWithId.get('Basic Yogiyo123@'+result.Id_Country__r.name)==null){
   				mapofServiceNameCountryWithId.put('Basic Yogiyo123@'+result.Id_Country__r.name,result);
   				mapofServiceNameCountryWithId.put('Basic Yogiyo@'+result.Id_Country__r.name,result);
   			}else if(result.name=='Yogiyo Basic (사업자변경) 6%~12.5%' && mapofServiceNameCountryWithId.get('Yogiyo Basic (사업자변경)@'+result.Id_Country__r.name)==null){
   				mapofServiceNameCountryWithId.put('Yogiyo Basic (사업자변경)@'+result.Id_Country__r.name,result);
   				mapofServiceNameCountryWithId.put('요기팩기본 (주)놀부 / 오색천연@'+result.Id_Country__r.name,result);
   			}
   			
   			if(result.Commission_In_Percentage__c!=null){
   				nameCountryComm = nameCountry+'@'+Integer.valueOf(result.Commission_In_Percentage__c);
   			}
			System.debug('nameCountryComm: '+nameCountryComm);
			if(mapofServiceNameCountryWithId.get(nameCountry)==null){
				mapofServiceNameCountryWithId.put(nameCountry,result);
			}else{

				duplicate.add(nameCountry);
				if(mapofServiceNameCountryWithId.get(nameCountry).Commission_In_Percentage__c!=null){
					mapOfDuplicateServicewithcommission.put(nameCountry+'@'+Integer.valueOf(mapofServiceNameCountryWithId.get(nameCountry).Commission_In_Percentage__c),mapofServiceNameCountryWithId.get(nameCountry));
				}
				mapOfDuplicateServicewithcommission.put(nameCountryComm,result);
			}
		}

		for(String str : duplicate){
			mapofServiceNameCountryWithId.remove(str);
		}
		System.debug('mapofServiceNameCountryWithId: '+mapofServiceNameCountryWithId);
		System.debug('mapOfDuplicateServicewithcommission: '+mapOfDuplicateServicewithcommission);
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		//mapofServiceNameCountryWithId

		//List<List_Service_Price__c> listService = [SELECT Id, Name, Company__c,Id_Country__c FROM List_Service_Price__c where name in : listName ];
		List<Opportunity_Quote_Service_Item__c> updateOppQS = new List<Opportunity_Quote_Service_Item__c>();
   		for(Opportunity_Quote_Service_Item__c oppQService : (List<Opportunity_Quote_Service_Item__c>) scope){
   			
   			String nameCountry = oppQService.name+'@'+oppQService.Id_Opportunity_Quote__r.Id_Opportunity__r.Record_Country__c;
   			String nameCountryComm = null;
   			System.debug('nameCountry: '+nameCountry);
   			System.debug('oppQService.id: '+oppQService.Id);
   			Boolean flag = false;
   			if(oppQService.Commission_In_Percentage__c!=null){
   				nameCountryComm = nameCountry+'@'+Integer.valueOf(oppQService.Commission_In_Percentage__c);
   			}
   			if(mapofServiceNameCountryWithId.get(nameCountry)!=null){
   				updateOppQS.add(new Opportunity_Quote_Service_Item__c(Id=oppQService.Id,Id_List_Service_Price__c = mapofServiceNameCountryWithId.get(nameCountry).Id));
   				flag = true;
   			}else if(nameCountryComm!=null && mapOfDuplicateServicewithcommission.get(nameCountryComm)!=null){
   				updateOppQS.add(new Opportunity_Quote_Service_Item__c(Id=oppQService.Id,Id_List_Service_Price__c=mapOfDuplicateServicewithcommission.get(nameCountryComm).Id));
   				flag = true;
   			}
   			if(!flag){
   				recordsNotUpDated.add(oppQService);
   			}

   		}

   		totalRecords += scope.size();
   		System.debug('updateOppQS: '+updateOppQS);
   		if(!updateOppQS.isEmpty()){
   			totalRecordsUpdated += updateOppQS.size();
   			update updateOppQS;
   		}
	
	}
	
	global void finish(Database.BatchableContext BC) {
		totalRecodsNotUpdated = totalRecords - totalRecordsUpdated;
		System.debug('totalRecords: '+totalRecords);
		System.debug('totalRecordsUpdated: '+totalRecordsUpdated);
		System.debug('totalRecodsNotUpdated: '+totalRecodsNotUpdated);

		List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<String> sendTo = new List<String>();
	    sendTo.add('magesh.maniyadav@deliveryhero.com');
	    mail.setToAddresses(sendTo);
	    mail.setSenderDisplayName('BatchLinkServiceListWithOppQuoteService');
	    mail.setSubject('BatchLinkServiceListWithOppQuoteService updates');
	    String body = '';
	    String name = '';
	    for(Opportunity_Quote_Service_Item__c ids : recordsNotUpDated){
	    	body +='\''+ids.Id+'\'=\''+ids.name+'\',';
	    	//name += '\''+ids.name+'\',';
	    }
	    body +='\n\n\n'+name;
	    mail.setPlainTextBody(body);
	    mails.add(mail);
	    Messaging.sendEmail(mails);
	}
	
}