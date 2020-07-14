public class ClsOpportunityProcessor{
  public static final String RT_CHAIN = 'Chain_Opportunity';
  public static final String BT_UPGRADE = 'Upgrade/Upsell';
  public static boolean PreventQCValidation				= false;
  public static boolean disableOppUpdateFromActivity 	= false;
  public static final string ERROR_UPDATE_ACCOUNT_FAILED = 'Update Failed On Account Object';
  public static final string METHOD_UPDATE_ACCOUNT_ADDRESS = 'updateAccountRevenueModel Method : ';
	@TestVisible
  private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
	
/************************************* GENERAL (COMMON) METHODS START *****************************************************/      
   /**
	* @Description: This method shortlists all the closed won opportunities
			@Process		: General
      		@Input Params	: List of opportunities, Old map
      		@Return			: Closed Won opp map
	*/
	public static Map<Id,Opportunity> getClosedWonOpps(List<SObject> opps,Map<Id,SObject> oldMap){
		Map<Id,Opportunity> opportunitiesMap = new Map<Id,Opportunity>();
		
		if(oldMap == null)
			return opportunitiesMap; 
		
        for(Opportunity opp : (List<Opportunity>)opps){
            Opportunity oldRecord = (Opportunity)oldMap.get(opp.Id);
        	if(opp.stageName == 'Closed Won' && opp.stageName != oldRecord.stageName){
        		opportunitiesMap.put(opp.id,opp);
        	}
        }
        
        return opportunitiesMap;
	}
	
	/**
	* @Description: This method shortlists all the closed Lost opportunities
			@Process		: General
      		@Input Params	: List of opportunities, Old map
      		@Return			: Closed Lost opp map
	*/
	public static Map<Id,Opportunity> getClosedLostOpps(List<SObject> opps,Map<Id,SObject> oldMap){
		Map<Id,Opportunity> opportunitiesMap = new Map<Id,Opportunity>();
		
		if(oldMap == null)
			return opportunitiesMap; 
		
        for(Opportunity opp : (List<Opportunity>)opps){
            Opportunity oldRecord = (Opportunity)oldMap.get(opp.Id);
        	if(opp.stageName == 'Closed Lost' && opp.stageName != oldRecord.stageName){
        		opportunitiesMap.put(opp.id,opp);
        	}
        }
        
        return opportunitiesMap;
	}
      
      /**
      * @Description: This method fetches the accouunts based on opportunities
      		@Process		: General
      		@Input Params	: List of opportunities
      		@Return			: Account Map
      */
	public static Map<Id,Account> getAccountMapFromOpps(List<Opportunity> opps){
		Map<Id,Account> accountMap;
		List<Schema.FieldSetMember> fields_Account = readFieldSet('OptTriggerQuery', 'Account');
		List<Schema.FieldSetMember> fields_Contact = readFieldSet('OptTriggerQuery', 'Contact');
		List<Schema.FieldSetMember> fields_Address = readFieldSet('OptTriggerQuery', 'AddressDetail__c');

		if(opps.size() == 0)
			return null;
		Set<Id> accountIds  = new Set<Id>();
		for(Opportunity opp : opps){
			accountIds.add(opp.accountId);
		}

		String queryString = 'select id, RecordTypeId ';

		// Query the account fields
		if (fields_Account != null) {
			for (Schema.FieldSetMember fsm : fields_Account) {
				String filedName = fsm.getFieldPath();
				queryString += ', ' + filedName;

			}
		}

		// Query the contact and AccountContactRelation fields
		if (fields_Contact != null) {
			queryString += ' ,(select id  ';
			for (Schema.FieldSetMember fsm : fields_Contact) {
				String filedName = fsm.getFieldPath();
				queryString += ', ' + filedName;
			}
			queryString += ' FROM Contacts where Contact_Role__c  = \'Owner\' )';

			queryString += ' ,(select id  ';
			for (Schema.FieldSetMember fsm : fields_Contact) {
				String filedName = fsm.getFieldPath();
				queryString += ',Contact.' + filedName;
			}
			queryString += ' FROM AccountContactRelations WHERE isactive = true and contact.contact_role__c=\'Owner\' )';
		}

		// Query the Address fields
		if(fields_Address != null){
			queryString += ' ,(select id  ';
			for (Schema.FieldSetMember fsm : fields_Address) {
				String filedName = fsm.getFieldPath();
				queryString += ', ' + filedName;
			}
			queryString += ' FROM AddressDetails__r WHERE Type__c INCLUDES (\'Restaurant Address\') )';
		}

		// Query the platform performane fields
		queryString += ' ,(SELECT id, name FROM Platforms_Performance__r)';

		queryString += ' from Account where id IN : accountIds';

		if(accountIds.size() > 0){
			System.debug(queryString);
			accountMap = new Map<Id,Account>((List<Account>)Database.query(queryString));
		}

		return accountMap;
	}
      
      /**
      	@Description: This method fetches the cases associated with the opportunties
      		@Process		: General
      		@InputParam		: List of opportunity Ids
      		@Return			: Map of opp id and list of cases
      */
      public static List<Case> fetchCasesFromOppIds(List<Opportunity> opportunities){
  			List<Case> cases = [SELECT id, Opportunity__c, Opportunity__r.Recordtype.developerName,Type, 
									AccountId, Status, Closed_Reason__c, isClosed,RecordType.DeveloperName,
									Opportunity__r.Non_Contracted__c ,Stage_1_Completed__c,case_reason__c
								FROM Case 
								WHERE Opportunity__c in : opportunities];
			return cases; 
      }
      
      /**
      	@Description: This method populates the opp vs the cases map
      		@Process		: General
      		@InputParam		: List of opportunity Ids
      		@Return			: Map of opp id and list of cases
      */
      public static Map<Id,List<Case>> populateOppVsCaseMap(List<Case> cases){
      		Map<Id,List<Case>> caseMap = new Map<Id,List<Case>>();
      		
      		for(Case cs : cases){
      			if(!caseMap.containsKey(cs.opportunity__c))
      				caseMap.put(cs.opportunity__c,new List<Case>());
  				caseMap.get(cs.opportunity__c).add(cs);
      		} 
      		
      		return caseMap;
      }
      
      /**
      	@Description: This method fetches the cases associated with the opportunties
      		@Process		: General
      		@InputParam		: List of opportunity Ids
      		@Return			: Map of account id against the list of cases
      */
      public static Map<String,List<Case>> fetchCasesFromAccountIds(List<Opportunity> opportunities){
      		Map<String,List<Case>> accountVsCasesMap 	= new Map<String,List<Case>>();
      		Set<String> accountIds						= new Set<String>();
      		
      		for(Opportunity opp : opportunities){
      			accountIds.add(opp.accountId);
      		}
      		
  			List<Case> cases = [SELECT id, Opportunity__c, AccountId 
									FROM Case 
									WHERE accountId in : accountIds
										AND type = 'Convert to Contract'];
			
			for(Case cs : cases){
				if(!accountVsCasesMap.containsKey(cs.accountId))
					accountVsCasesMap.put(cs.accountId,new List<Case>());
				accountVsCasesMap.get(cs.accountId).add(cs);
			}
			
			return accountVsCasesMap; 
      }
      
   
      
      /**
	   * @Description: This method populates the map of opportunity against the Menu processing case
	   		@Process		: General
      		@InputParam		: List of cases
      		@Return			: Map of Opportunity Id and MP case
	   */
	 public static Map<Id,List<Case>> getOppVsSpecificCaseMap(List<Case> cases,String type){
		Map<Id, List<Case>> CaseMap = new Map<Id, List<Case>>();
		
		for(Case cs : cases){
			if(cs.type == type){
				if(!caseMap.containsKey(cs.Opportunity__c))
					caseMap.put(cs.Opportunity__c,new List<Case>());
				CaseMap.get(cs.Opportunity__c).add(cs);
			}
		}
		
        return CaseMap;
	 }
	 
	 /**
	   * @Description: This method populates the map of opportunities with parent and child records
	   		@Process		: General
      		@InputParam		: Opportunities
      		@Return			: Map of Opportunity 
	   */
	 public static Map<Id,Opportunity> fetchOpportunityMap(List<Opportunity> opportunities){
	 		Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id, Id_Tarif__r.Name, RecordTypeId,
	 																	 account.recordType.developerName,
	 																	 Account.Company_Code__c,
	 																	 account.currencyISOCode,
					                                                     Record_Country__c,
	 																 	(SELECT id,status, closed_reason__c
						                                               		FROM cases__r
						                                               		WHERE isclosed = false),
						                                              	(SELECT id,status__c,Installation_Date__c,type__c
						                                               		FROM branding_content__r),
						                                              	(SELECT id,status__c,retour_date__c
						                                              		FROM assets__r),
						                                              	(SELECT id,status__c
						                                              		FROM add_on_services__r),
																		(SELECT id,status__c,Tracking_Number__c
																			FROM Shipment_Orders__r),
						                                              	(SELECT id,status__c
						                                              		FROM opportunity_quotes__r
						                                              		WHERE status__c
						                                              			Not IN ('Accepted', 'Declined','Expired'))
	 																FROM Opportunity 
	 																WHERE Id in :opportunities]);
	 																
 			return oppMap;
	 }
     
     /**
      	@Description: This method fetches the accepeted opportunity quotes associated with the opportunities
      		@Process		: General
      		@InputParam		: List of opportunity Ids
      		@Return			: map of opportunity Id vs opportunity quote
      */
     public static Map<Id,Opportunity_Quote__c> fetchOppVsQuoteMap(List<Opportunity> opportunities){
     		Map<Id,Opportunity_Quote__c>  oppVsQuoteMap = new Map<Id,Opportunity_Quote__c>();
     		
     		List<Opportunity_Quote__c> quotes = [SELECT id, status__c, Id_Opportunity__c 
     												FROM Opportunity_Quote__c 
     												WHERE Id_Opportunity__c in : opportunities
     													AND status__c = 'Accepted'];
     													
     		for(Opportunity_Quote__c quote : quotes){
     			oppVsQuoteMap.put(quote.Id_Opportunity__c,quote);
     		}
     		
     		return oppVsQuoteMap;
     }
 
     /**
      	@Description: This method fetches the opportunity line items associated with the opportunities
      		@Process		: General
      		@InputParam		: List of opportunity Ids
      		@Return			: map of opportunity Id vs Line Items
      */
      public static Map<String,List<Opportunity_Line_Item__c>> fetchOppIdVsLineItemMap(List<Opportunity> opportunities){
      		Map<String,List<Opportunity_line_item__c>> OppVsLineItemMap	= new  Map<String,List<opportunity_line_item__c>>();
            for(Opportunity_line_item__c lineItem :  [select Name,Specifications__c,Booking_Api_Id__c,Id_Opportunity__c,Line_item_type__c, Id_List_Price_Product__r.Product_Type__c
            											from Opportunity_line_item__c 
            											where Id_Opportunity__c IN:  opportunities]){
            	if(OppVsLineItemMap.get(lineItem.Id_Opportunity__c) == null){
            		OppVsLineItemMap.put(lineItem.Id_Opportunity__c,new List<Opportunity_line_item__c>());
            	}                	
            	OppVsLineItemMap.get(lineItem.Id_Opportunity__c).add(lineItem);
            }
            
            return OppVsLineItemMap;
      }

	/**
         @Description: This method fetches all the oppotunities associated with their account
             @Process		: General
             @InputParam		: List of current opportunity
             @Return			: List of all opportunity & the account
     */
    public static Map<Id,List<Opportunity>> fetchAllOppsPerAccount(List<Opportunity> opportunities){

        Map<id,List<opportunity>> accountOppMap = new Map<id,List<opportunity>>();

        set<id> accountIds = new set<id>();
        for (opportunity opp :opportunities){
            accountIds.add(opp.accountId);
        }
        List<Opportunity> allOppsForCurrentAccount = new List<Opportunity>([select id,StageName,Business_Type__c,accountId from Opportunity where accountId IN :accountIds]);
        for (opportunity opp :allOppsForCurrentAccount){
            if(!accountOppMap.containsKey(opp.accountId)){
                accountOppMap.put(opp.accountId,new List<Opportunity>());
                accountOppMap.get(opp.accountId).add(opp);

            }else{
                accountOppMap.get(opp.accountId).add(opp);
            }
        }
        system.debug('accountOppMap...'+accountOppMap);
        return accountOppMap;
    }
      
      /**
      	@Description: This method fetches the opportunity quote line items associated with the opportunities
      		@Process		: General
      		@InputParam		: List of opportunity Ids
      		@Return			: map of opportunity Id vs quote Line Items
      */
      public static Map<String,List<Opportunity_Quote_Line_Item__c>> fetchOppIdVsQuoteLineItemMap(List<Opportunity> opportunities){
      		Map<String,List<Opportunity_Quote_line_item__c>> OppVsQuoteLineItemMap 
      								= new Map<String,List<opportunity_Quote_line_item__c>>();
            for(Opportunity_Quote_line_item__c lineItem :  [SELECT Id,(SELECT id,name, Account__c, CurrencyIsoCode,
            															 RecordTypeId, Id_Opportunity_Quote_Line_Item__c, 
            															 Opportunity__c, Status__c,retour_date__c 
            														   FROM Assets__r), 
            													(SELECT id FROM Branding_Content__r),
            													(SELECT id FROM Add_on_Services__r),
            													(SELECT Id,Id_Contract__c from Tiers__r),
            													name, CurrencyIsoCode, 
            											   		Id_List_Product_Price__r.Requires_Asset__c, 
            											   		Id_List_Product_Price__r.Product_Type__c,
                    									   		Id_Opportunity_Quote__r.Id_Account__c, Id_Opportunity__c, 
                    									   		Id_Opportunity__r.Parent_Opportunity__r.accountId,
                    									   		Id_Opportunity__r.Parent_Opportunity__c,
                    									   		Id_Opportunity__r.OwnerId, 
                    									   		Id_Opportunity__r.RecordType.DeveloperName,
					                                            Id_Opportunity__r.Start_Date_uk__c,
					                                            Id_Opportunity__r.Schedule_into_the_past__c,
					                                            Id_Opportunity__r.Time_Based_Tier_Type__c,
					                                            Id_Opportunity__r.Business_Type__c,
							                                    Quantity__c,id_opportunity__r.accountid,
                    									   		Id_List_Product_Price__c,id_opportunity__r.Company_Code__c,
                    									   		Number_of_Copies__c,Id_List_Product_Price__r.Requires_Branding__c,
                    									   		Id_Opportunity_Quote__r.status__c,sub_type__c,
                    									   		line_item_type__c,id_list_Service_price__c,
                                                                id_list_Service_price__r.company__r.name,
                                                                Commission_In_Percentage__c, Commission_Per_Order__c, Start_Date__c, 
                                                                End_Date__c,Id_Opportunity_Quote__c,Recurring_Fee__c,
                                                                Id_Opportunity__r.RecordTypeId,Id_Opportunity__r.Account.Non_Contracted__c,
                                                                recordtype.DeveloperName,Id_Replacement_Order__c,Specifications__c,
                                                                Id_list_Add_On__c,Id_list_Add_On__r.name,Id_Opportunity__r.CloseDate,
                                                                Id_List_Product_Price__r.Requires_Additional_Charge__c,
                                                                Id_List_Product_Price__r.Requires_Add_On__c, 
                                                                Id_List_Product_Price__r.Product_Name__c,
																Id_List_Service_Price__r.Based_On__c,
																Id_List_Service_Price__r.Scaled__c,
																Id_List_Service_Price__r.Commission_Type__c,
														Has_Related_Tarif__c, Installments__c, Listed_Price__c,
                                                                weight__c, size__c, Min__c, Max__c, index__c,IsTiered__c,
                                                                Product_Group__c, Discount__c,Contract_Addition__c, 
                                                                Deposit_Method__c,Id_Opportunity_Quote__r.Non_Standard_Contract_Components__c, 
                                                                Total_Amount__c,Category__c, Category_Id__c, District__c, District_Id__c, 
                                                                City_ZipCode__c,Booking_Api_Id__c, Position__c, Online_Payment_Fee__c,
                                                                Billable_Account__c, Based_On__c,Scaled__c, Commission_Type_Picklist__c, Commission_Type__c, Delivery__c,
																Unit_Cost__c, Interval__c, Budget__c, Sub_Product_Name__c
			FROM Opportunity_Quote_Line_Item__c
                    									WHERE Id_Opportunity__c in: opportunities
                    									ORDER BY index__c]){
            	if(OppVsQuoteLineItemMap.get(lineItem.Id_Opportunity__c) == null){
            		OppVsQuoteLineItemMap.put(lineItem.Id_Opportunity__c,new List<Opportunity_Quote_line_item__c>());
            	}                	
            	OppVsQuoteLineItemMap.get(lineItem.Id_Opportunity__c).add(lineItem);
            }
            
            return OppVsQuoteLineItemMap;
      }
      
      /**
       @Description: This method returns the Add-On specification string
       		@Process		: General
      		@InputParam		: List of Line Items
      		@Return			: Description populated from specifications
      */
      private static String populateSpecifications(List<Opportunity_Line_Item__c> lineItems){
    	String description = '';
    	for(Opportunity_Line_Item__c lineItem : lineItems){
    		if(lineItem.specifications__c != null && lineItem.Line_item_type__c == 'AddOn'){
    			description += lineItem.Name + ' : ' + lineItem.specifications__c + '\n\n';
    		}
    	}
	
    	return description;
      }
      
      /**
      * @Description: This method check whether mp case with proper conidition is present or not
      		@Process			: General
      		@InputParams		: List of MP cases
      		@Return				: Boolean (True if MP Case with proper conditions are present)
      */
      public static Boolean checkForMenuProcessingCase(List<Case> cases, String businessConfig){
      	if(cases == null || cases.size() == 0)
      		return false;
      		
      	Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get(businessConfig);
        for (Case c : cases){	
			if(c.type == 'Menu Processing'){
	            Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(c.Opportunity__r.Recordtype.developerName);
	            if (mapBusinessRules.get('ClosedReason') != null 
	            	&& mapBusinessRules.get('ClosedReason').Business_Rule_Value__c != null) {
		                List<String> closedReason =  mapBusinessRules.get('ClosedReason').Business_Rule_Value__c.split(',');
	                    if (c.isClosed && !closedReason.contains(c.Closed_Reason__c)) {
	                        return true;
	                    } else if (!c.isClosed) {
	                        return true;
	                    }
	            }			
			}  
         }
         
         return false;
      }
      
    /**
		* @Description: This method updates the closed date on the opportunity
			@Process	   : General
	 		@TriggerContext: Before Update
	 		@BusinessConfig: updateCloseDateProcess
	*/
	public static void populateCloseDate(Opportunity opp,Opportunity oldRecord){
		Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('updateCloseDateProcess');
        Map<String, Business_Config__c> mapBusinessRules = new Map<String, Business_Config__c>();
        
        if(mapBusinessLogic == null || mapBusinessLogic.isEmpty())
        	return;
        	
    	mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
    	if(mapBusinessRules != null && mapBusinessRules.get('stage') != null && mapBusinessRules.get('isEnabled') != null){
    		if(mapBusinessRules.get('isEnabled').Business_rule_value__c == 'True'){
        		if(opp.stageName != oldRecord.stageName && opp.stageName == mapBusinessRules.get('stage').Business_rule_value__c){
        			opp.closeDate = Date.Today();
        		}
    		}
    	}
	}
	
	/**
		* @Description: This method populates the currency iso code and company code on the opportunity
			@Process	   : General
	 		@TriggerContext: Before Insert,Before Update
	 		@BusinessConfig: updateCloseDateProcess
	*/
	public static void populateCurrencyISOCodeAndCompanyCode(Opportunity opp,String companyCode,String accountCurrencyISO){
		opp.currencyISOCode		= accountCurrencyISO;
		opp.company_code__c		= companyCode;
	}
      
/************************************* GENERAL (COMMON) METHODS END *****************************************************/  

/************************************* NON CONTRACTED MENU PROCESSING METHODS START**************************************/     
	  /**
      * @Description: This method shortlists all the opps for the creation of NON CONTRACTED Menu Processing Cases
      		@Process Name		: Non Contracted Menu Processing Creation
      		@Business Config 	: NonContractedMenuProcessing
      		@Input Params		: List of updated opps
      		@Return				: Shortlisted Opportunity Map
      		@TriggerContext		: after insert, after update
      */
	  public static Map<Id,Opportunity> getNonContractedMPOpps(List<SObject> SObjects){
	  		List<Opportunity> opps 					= (List<Opportunity>)SObjects;
	  		Map<Id,Opportunity> nonContractedOppMap = new Map<Id,Opportunity>();
	        List<Opportunity> newOpps 				= new List<Opportunity>();
	        
	        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('NonContractedMenuProcessing');
	        
	        if(mapBusinessLogic == null || mapBusinessLogic.isEmpty())
	            	return nonContractedOppMap;
	            	
	        for (Opportunity opp : opps) {
	            Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
	            	
	            if (mapBusinessRules != null && !mapBusinessRules.isEmpty() 
	            	&& opp.Non_Contracted__c == Boolean.valueOf(mapBusinessRules.get('Non_Contracted__c').Business_Rule_Value__c)){
	            		nonContractedOppMap.put(opp.id,opp);
	            }
	            
	        }
	        
	        return nonContractedOppMap;
	  }
	  
	  /**
      * @Description: Non contracted menu processing opportunity update. this method updates the opportunity stage and 
      					probability
      		@Process Name		: Non Contracted Menu Processing Creation
      		@Business Config 	: NonContractedMenuProcessing
      		@Input Params		: Opportunity record, MP Case record
      		@Return 			: void
      		@TriggerContext		: before insert, before update
      */
	  public static void nonContractedMenuProcessingOppUpdate(Opportunity opp, List<Case> mpCases){
	  		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('NonContractedMenuProcessing');
	  		Boolean existingMP 	                    						= false;
	  		List<Opportunity> nonContractedOppList  						= new List<Opportunity>();
	  		List<SObject> SObjectsList										= new List<SObject>();
			Case cs;
			
			if(mapBusinessLogic == null || mapBusinessLogic.isEmpty())
	            	return;

	  		if(mpCases != null){
		  		for(Case mpCase : mpCases){	
	  				if(mpCase.Opportunity__r.Non_Contracted__c)
	  					existingMP = true;
		  		}
	  		}
            	
            if (existingMP)
            	return;
            	
             Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
	            if (mapBusinessRules != null && !mapBusinessRules.isEmpty() 
	            	&& opp.Non_Contracted__c == Boolean.valueOf(mapBusinessRules.get('Non_Contracted__c').Business_Rule_Value__c)){
	            		opp.Probability 	= Decimal.valueOf(mapBusinessRules.get('set Probability').Business_Rule_Value__c);
            			opp.StageName 		= mapBusinessRules.get('set StageName').Business_Rule_Value__c;
	         }
	  }
	  
	  /**
      * @Description: This method Creates MP cases for Non Contracted opportunities
      		@Process Name		: Non Contracted Menu Processing Creation
      		@Business Config 	: NonContractedMenuProcessing
      		@TriggerContext		: after insert
      		@Return				: List of cases
      		@Input Params		: Opportunity record, MP Case record
      */
	  public static List<SObject> nonContractedMenuProcessing(Opportunity opp, List<Case> mpCases){
	  		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('NonContractedMenuProcessing');
	  		Boolean existingMP 	                    						= false;
	  		List<Opportunity> nonContractedOppList  						= new List<Opportunity>();
	  		List<SObject> SObjectsList										= new List<SObject>();
			Case cs;

	  		if(mpCases != null){
		  		for(Case mpCase : mpCases){	
	  				if(mpCase.Opportunity__r.Non_Contracted__c)
	  					existingMP = true;
		  		}
	  		}
            
            	
            if (existingMP)
            	return SObjectsList;
            	
            Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
            Map<String, String> mapFields = new Map<String, String>();
            if (mapBusinessRules.get('Menu Processing Case').Business_Rule_Value__c != null) {
                cs = new Case(Opportunity__c = opp.id, AccountId = opp.AccountId, CurrencyIsoCode = opp.CurrencyIsoCode);
                for (String fieldAndValue : (mapBusinessRules.get('Menu Processing Case').Business_Rule_Value__c).split(',')) {
                    List<String> fields = fieldAndValue.split('=');
                    cs.put(fields[0], fields[1]);
                }
                SObjectsList.add(cs);
            }
            return SObjectsList;
	  }
/************************************* NON CONTRACTED MENU PROCESSING METHODS END**************************************/

/************************************* CONTRACTED MENU PROCESSING METHODS START **************************************/
	 /**
      * @Description: This method shortlists all the opps for the creation of contracted menu Processing Cases
      		@Process Name		: contracted Menu Processing Creation
      		@Business Config 	: ContractedMenuProcessing
      		@Input Params		: List of updated opps, Map of opps before updation
      		@Return				: Shortlisted Opportunity Map
      		@TriggerContext		: After Update
      */
      public static Map<Id, Opportunity> shortListOppsForContractedMenuProcessing(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('ContractedMenuProcessing');
      	List<Opportunity> newOpps  	= (List<Opportunity>)sobjects;
      	Map<Id,Opportunity> oldMap	= (Map<Id,Opportunity>)oldSobjectMap;	
      	Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
      	List<String> oppTypes 		= new List<String>();
		
		if (mapBusinessLogic == null || mapBusinessLogic.isEmpty())
			return oppMap;
        
        for (Opportunity opp : newOpps) {
                
            Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
            
            if (mapBusinessRules == null || mapBusinessRules.isEmpty())
            	continue;
            
            if (opp.Non_Contracted__c  != Boolean.valueOf(mapBusinessRules.get('Non_Contracted__c').Business_Rule_Value__c))
            	continue;
                
            if(mapBusinessRules.get('StageName').Business_Rule_Value__c == null 			||
            	mapBusinessRules.get('OpportunityType') == null								||
            	opp.StageName != mapBusinessRules.get('StageName').Business_Rule_Value__c	||
            	opp.StageName == oldMap.get(opp.Id).StageName)
            	continue;
            
            if (mapBusinessRules.get('Menu Processing Case') == null || 
	            mapBusinessRules.get('Menu Processing Case').Business_Rule_Value__c == null)
	            continue;
            
            oppTypes = (mapBusinessRules.get('OpportunityType').Business_Rule_Value__c).split(',');
            if (oppTypes.contains(opp.type)) {
                oppMap.put(opp.Id, opp);
            }  
        }
        
        return oppMap;
      
      }
/************************************* CONTRACTED MENU PROCESSING METHODS END **************************************/

/************************************* MENU PROCESSING CASE CREATION PROCESS METHODS START **************************************/      
      /**
      * @Description: This method shortlists all the opps for the creation of Menu Processing Cases
      		@Process Name		: Menu Processing Creation
      		@Business Config 	: GenericMenuProcessing
      		@Input Params		: List of updated opps, Map of opps before updation
      		@Return				: Shortlisted Opportunity Map
      		@TriggerContext		: After Update
      */
      public static Map<Id, Opportunity> shortListOppsForMenuProcessing(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){
      	List<Opportunity> newOpps  	= (List<Opportunity>)sobjects;
      	Map<Id,Opportunity> oldMap	= (Map<Id,Opportunity>)oldSobjectMap;
      	
      	Map<Id, Opportunity> oppMap 									= new Map<Id, Opportunity>();
      	Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('GenericMenuProcessing');
      	if(mapBusinessLogic == null || mapBusinessLogic.isEmpty())
      		return oppMap;
      	// loop for picking selected opportunity
        for (Opportunity opp : newOpps) {
			List<String> oppTypes = new List<String>();
            	
            Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
            if (mapBusinessRules == null || mapBusinessRules.isEmpty())
            	continue;
            	
            if ( mapBusinessRules.get('StageName').Business_Rule_Value__c == null 		|| 
            	 mapBusinessRules.get('OpportunityType') == null						||
            	 mapBusinessRules.get('OpportunityType').Business_Rule_Value__c == null	||
            	 opp.StageName == oldMap.get(opp.Id).StageName  						|| 
            	 opp.StageName != mapBusinessRules.get('StageName').Business_Rule_Value__c)
            	 	continue;
                
            // Check for the valid opportunity types
            oppTypes = mapBusinessRules.get('OpportunityType').Business_Rule_Value__c.split(',');
            if (oppTypes.contains(opp.type)) {
                oppMap.put(opp.Id, opp);
            }        
      	 }
      	 
      	 return oppMap;
      }
  	  
  	  /**
  	   @Description: This method creates Menu Processing cases
  	   		@Process			: Menu Processing Creation
  	   		@Business Config 	: GenericMenuProcessing
  	   		@InputParams		: Opportunity,Opportunity line items, Account assosiated with opp, AT case
  	   		@Return				: List of Sobjects (Cases)	
  	   		@TriggerContext		: After Update
  	  */
  	  public static List<SObject> createMenuProcessingCase(Opportunity opp,List<Opportunity_Line_Item__c> lineItems,
  	  												Account account,List<Case> MPCases,List<Case> atCases){

  	  		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('GenericMenuProcessing');
  	  		List<SObject> listCase 											= new List<SObject>();

            Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
            	
        	if(checkForMenuProcessingCase(MPCases,'GenericMenuProcessing'))
        		return listCase;
            	
            if (mapBusinessRules.get('Menu Processing Case') != null 
            	 && mapBusinessRules.get('Menu Processing Case').Business_Rule_Value__c != null) {
                	// Popualte the case
                	Case cs = new Case(Opportunity__c = opp.id, AccountId = opp.AccountId, CurrencyIsoCode = opp.CurrencyIsoCode);

                	// Populate ContactId to send out the menu preview link to owner
					cs.ContactId = populateContactId('RestaurantCare', 'copyOwnertoCaseContact', account, opp.RecordTypeId);

                    for (String fieldAndValue : (mapBusinessRules.get('Menu Processing Case').Business_Rule_Value__c).split(',')) {
                        List<String> fields = fieldAndValue.split('='); 
                        cs.put(fields[0], fields[1]); 
                    }
                    // populate the description on the case
                    if(lineItems != null && lineItems.size() != 0){
                    	cs.Description =  populateSpecifications(lineItems);
                    }
                    // populate more fields on case based on Business type 
                    if (mapBusinessRules.get('BusinessType-' + opp.Business_Type__c) != null 
                    	&& mapBusinessRules.get('BusinessType-' + opp.Business_Type__c).Business_Rule_Value__c != null) {
	                        if (mapBusinessRules.get('BusinessType-' + opp.Business_Type__c).Business_Rule_Value__c.indexOf(',') > 1) {
	                            for (String fieldAndValue : (mapBusinessRules.get('BusinessType-' + opp.Business_Type__c).Business_Rule_Value__c).split(',')) {
	                                List<String> fields = fieldAndValue.split('=');
	                                cs.put(fields[0], fields[1]);
	                            }
	                        } else {
	                            List<String> fields = (mapBusinessRules.get('BusinessType-' + opp.Business_Type__c).Business_Rule_Value__c).split('=');
	                            cs.put(fields[0], fields[1]);
	                        }
                    }
                    // Check for the key account. If the account is key account then assign to special key account queue
                    if (mapBusinessRules.get('checkForKeyAccount') != null 
                    	 && Boolean.valueOf(mapBusinessRules.get('checkForKeyAccount').Business_Rule_Value__c)
                    	 && account.Key_VIP_Account__c ){
                    		cs.ownerId = mapBusinessRules.get('keyAccountOwnerId').Business_rule_value__c;
                    }
                            
                    listCase.add(cs);
                }
                if (mapBusinessRules.get('Menu Processing Case 2') != null && mapBusinessRules.get('Menu Processing Case 2').Business_Rule_Value__c != null) {
                    if(atCases != null && atCases.size() > 0){
                        Case cs = new Case(Opportunity__c = opp.id, AccountId = opp.AccountId, CurrencyIsoCode = opp.CurrencyIsoCode);
                        for (String fieldAndValue : (mapBusinessRules.get('Menu Processing Case 2').Business_Rule_Value__c).split(',')) {
                            List<String> fields = fieldAndValue.split('=');
                            cs.put(fields[0], fields[1]);
                        }
                        listCase.add(cs);
                    }
                }
                
            
            return listCase;            
  	  }

/************************************* MENU PROCESSING CASE CREATION PROCESS METHODS END **************************************/


/************************************* AD SALES CASE CREATION PROCESS METHODS START *****************************************/
	/**
      * @Description: This method shortlists all the opps for the creation of Menu Processing Cases
      		@Process Name		: Ad sales case reation process
      		@Business Config 	: AdSalesCaseProcessing
      		@Input Params		: List of updated opps, Map of opps before updation
      		@Return				: Shortlisted Opportunity Map
      		@TriggerContext		: After Update
      */
      public static Map<Id, Opportunity> shortListOppsAdSalesProcessing(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){
      		List<Opportunity> newOpps  	= (List<Opportunity>)sobjects;
      		Map<Id,Opportunity> oldMap	= (Map<Id,Opportunity>)oldSobjectMap;
      		Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        	Set<String> oppTypes = new Set<String>();

        	Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('AdSalesCaseProcessing');
			
			if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) 
				return oppMap;
				
            // loop for picking selected opportunity
            for (Opportunity opp : newOpps) {
           		Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
	            if (mapBusinessRules == null || mapBusinessRules.isEmpty()) 
	            	continue;
				
				if ( mapBusinessRules.get('StageName').Business_Rule_Value__c == null 			|| 
	            	 mapBusinessRules.get('OpportunityType') == null							||
	            	 mapBusinessRules.get('OpportunityType').Business_Rule_Value__c == null		||
	            	 opp.StageName == oldMap.get(opp.Id).StageName  							|| 
	            	 opp.StageName != mapBusinessRules.get('StageName').Business_Rule_Value__c	||
	            	 mapBusinessRules.get('AdSales Processing Case') == null 					|| 
	            	 mapBusinessRules.get('AdSales Processing Case').Business_Rule_Value__c == null)
	            	 	continue;
				
                oppTypes.add(mapBusinessRules.get('OpportunityType').Business_Rule_Value__c);
                if (oppTypes.contains(opp.type)) {
                    oppMap.put(opp.Id, opp);
                }
            }
                
           return oppMap;     
      }
      
      /**
  	   @Description: This method creates Menu Processing cases
  	   		@Process			: Ad sales case reation process
  	   		@Business Config 	: AdSalesCaseProcessing
  	   		@InputParams		: Opportunity record
  	   		@Return				: SObject (Case)	
  	   		@TriggerContext		: After Update
  	  */
  	  public static SObject createAdSalesCase(Opportunity opp){
  	  		Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('AdSalesCaseProcessing');
			Case cs;
				
			Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
            cs = new Case(Opportunity__c = opp.id, AccountId = opp.AccountId, CurrencyIsoCode = opp.CurrencyIsoCode);
            for (String fieldAndValue : (mapBusinessRules.get('AdSales Processing Case').Business_Rule_Value__c).split(',')) {
				List<String> fields = fieldAndValue.split('=');
                cs.put(fields[0], fields[1]);
            }
            
            return cs;
  	  }
/************************************* AD SALES CASE CREATION PROCESS METHODS END *****************************************/

/************************************* PHOTO LISTING CASE CREATION PROCESS METHODS START *****************************************/
	/**
      * @Description: This method shortlists all the opps for the creation of photo listing Cases
      		@Process Name		: Photo listing case creation process
      		@Business Config 	: PhotoListingProcess
      		@Input Params		: List of updated opps, Map of opps before updation
      		@Return				: Shortlisted Opportunity Map
      		@TriggerContext		: After Update
      */
      public static Map<Id, Opportunity> shortlistPhotoListOpps(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){
      		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('PhotoListingProcess');
      		List<Opportunity> newOpps  										= (List<Opportunity>)sobjects;
      		Map<Id,Opportunity> oldMap										= (Map<Id,Opportunity>)oldSobjectMap;
    		Map<Id,Opportunity> oppsTobeProcessed 							= new Map<Id,Opportunity>();    		
    		
    		if(mapBusinessLogic == null || mapBusinessLogic.isEmpty())
    			return oppsTobeProcessed;
    		
	    	// shortlist opportunties based on stageName
	    	for(Opportunity opp : newOpps){
	    	 	Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
	    		if (mapBusinessRules == null || mapBusinessRules.isEmpty()) 
	            	continue;
				
				if (mapBusinessRules.get('stageName').Business_Rule_Value__c == null 			|| 
	            	 mapBusinessRules.get('PhotoListingCaseFields') == null						||
	            	 mapBusinessRules.get('PhotoListingCaseFields').Business_Rule_Value__c == null)
	            	 	continue;

	 			oppsTobeProcessed.put(opp.Id,Opp);
	    	}
    	 
    	 	return oppsToBeProcessed;
      }
      
      /**
  	   @Description: This method creates Menu Processing cases
  	   		@Process Name		: Photo listing case creation process
      		@Business Config 	: PhotoListingProcess
  	   		@InputParams		: Opportunity record, List of existing photo listing cases
  	   		@Return				: SObject (Case)	
  	   		@TriggerContext		: After Update
  	  */
      public static SObject createPhotoListingCase(Opportunity opp, List<Case> photoListingCases, Opportunity oldOpp){
      		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('PhotoListingProcess');
      		Map<String, Business_Config__c> mapBusinessRules 				= mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
      		Case cs;

      		// If there are already existing photo listing cases check if the List Photo Comments changed
      		if(photoListingCases != null && photoListingCases.size() > 0 && opp.List_Photo_Comments__c != oldOpp.List_Photo_Comments__c && photoListingCases[0].isClosed == false){
				photoListingCases[0].List_Photo_Comments__c = opp.List_Photo_Comments__c;
				return photoListingCases[0];
			}
			if(photoListingCases != null && photoListingCases.size() > 0){
				return null;
			}

      		// create the case
			if(opp.StageName != oldOpp.StageName && opp.StageName == mapBusinessRules.get('stageName').Business_Rule_Value__c){
				cs = new Case(Opportunity__c = opp.id, AccountId = opp.AccountId, CurrencyIsoCode = opp.CurrencyIsoCode);
				for (String fieldAndValue : (mapBusinessRules.get('PhotoListingCaseFields').Business_Rule_Value__c).split(',')) {
					List<String> fields = fieldAndValue.split('=');
					cs.put(fields[0], fields[1]);
				}
				cs.List_Photo_Comments__c = opp.List_Photo_Comments__c;
				return cs;
			}else{
				return null;
			}

      }
/************************************* PHOTO LISTING CASE CREATION PROCESS METHODS END *****************************************/

/************************************* DISH LEVEL PHOTO CASE CREATION PROCESS METHODS START *****************************************/
	/**
      * @Description: This method shortlists all the opps for the creation of Menu Processing Cases
      		@Process Name		: Dish level photo case creation process
      		@Business Config 	: CreatePhotoListingCase
      		@Input Params		: List of updated opps, Map of opps before updation
      		@Return				: Shortlisted Opportunity Map
      		@TriggerContext		: After Update
      */
      public static Map<Id, Opportunity> shortlistDishLevelPhototOpps(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){
      		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('CreatePhotoListingCase');
      		List<Opportunity> newOpps  										= (List<Opportunity>)sobjects;
      		Map<Id,Opportunity> oldMap										= (Map<Id,Opportunity>)oldSobjectMap;
    		Map<Id,Opportunity> oppsTobeProcessed 							= new Map<Id,Opportunity>();    		
    		
    		if(mapBusinessLogic == null || mapBusinessLogic.isEmpty())
    			return oppsTobeProcessed;

        Set<Id> oppIds = new Set<Id>();
        for(Opportunity opp : newOpps) {
            oppIds.add(opp.Id);
        }
        Map<Id, Boolean> oppsWithClosedDish = CaseSelector.getDishCasesForOpportunities(oppIds);
    			
    		// shortlist the opps
    		for(Opportunity opp : newOpps){
    			Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
    			
    			if(mapBusinessRules ==  null)
    				continue;
    			
    			if(!mapBusinessRules.containsKey('stage') || !mapBusinessRules.containsKey('Fields') || oppsWithClosedDish.containsKey(opp.Id))
    				continue;
    				
    			if(mapBusinessRules.get('stage').Business_rule_value__c != opp.StageName
                       || oldMap.get(opp.id).StageName == opp.StageName)
                    continue;
                    
    			oppsTobeProcessed.put(opp.Id,Opp);
    		}
    		
    		return oppsTobeProcessed;
      }


	 /**
  	   @Description: This method creates Dish Level Cases
  	   		@Process Name		: Dish level photo case creation process
      		@Business Config 	: CreatePhotoListingCase
  	   		@InputParams		: Opportunity record, List of existing photo listing cases
  	   		@Return				: SObject (Case)	
  	   		@TriggerContext		: After Update
  	  */
      public static SObject createDishLevelPhotoCase(Opportunity opp,List<Opportunity_Line_Item__c> lstOptLineItems){
  			Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('CreatePhotoListingCase');
  			Map<String, Business_Config__c> mapBusinessRules 				= mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
			boolean createCase = false;
		  	Case csTemp;

			if(lstOptLineItems != null){
				for(Opportunity_Line_Item__c optLinItem: lstOptLineItems){
					if (optLinItem.Id_List_Price_Product__r.Product_Type__c != null) {
						if (optLinItem.Id_List_Price_Product__r.Product_Type__c.containsIgnoreCase('Dish Level Photoshoot')) {
							createCase = true;
						}
					}
				}
			}

		  	if(createCase){
				csTemp = new case();
				csTemp.RecordTypeId 	= LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('RecordType').Business_rule_value__c);
				csTemp.Opportunity__c 	= opp.id;
				csTemp.AccountId 		= opp.AccountId;
				map<String,Object> mpJsonPhotoListing = (map<String,Object>)JSON.deserializeUntyped(mapBusinessRules.get('Fields').Business_rule_value__c);
				for(string kyStr:mpJsonPhotoListing.keyset()){
					if (kyStr == 'OwnerId' && mapBusinessRules.get('OwnerIsOpptyOwner') !=null && mapBusinessRules.get('OwnerIsOpptyOwner').Business_rule_value__c == 'true') {
 						//SSC-1603 Override owner
						if(mapBusinessRules.containsKey('OverrideOwner') != null){

							map<string,Object> mapOfOwner = (map<String,Object>)JSON.deserializeUntyped(mapBusinessRules.get('OverrideOwner').Business_rule_value__c);

							if(mapOfOwner.containskey(opp.Record_Country__c)){
								csTemp.put(kyStr,string.valueOf(mapOfOwner.get(opp.Record_Country__c)));
								continue;
							}
						}
						csTemp.put(kyStr,opp.OwnerId);
                    } else {
                        
						csTemp.put(kyStr,mpJsonPhotoListing.get(kyStr));
                    }
				}
			}

            return csTemp;	
      }

/************************************* DISH LEVEL PHOTO CASE CREATION PROCESS METHODS END *****************************************/


/************************************* NON CONTRACTED MENU CHANGE CASE CREATION METHODS START *****************************************/
	/**
      * @Description: This method shortlists all the opps for the creation of Menu Processing Cases
      		@Process Name		: non contracted menu change process
      		@Business Config 	: NonContractedMenuChange
      		@Input Params		: List of updated opps, Map of opps before updation
      		@Return				: Shortlisted Opportunity Map
      		@TriggerContext		: After Update
      */
      public static Map<Id, Opportunity> shortListNonContractedMenuChangeOpps(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){
      		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('NonContractedMenuChange');
      		List<Opportunity> newOpps  										= (List<Opportunity>)sobjects;
      		Map<Id,Opportunity> oldMap										= (Map<Id,Opportunity>)oldSobjectMap;
      		Map<Id,Opportunity> oppsTobeProcessed 							= new Map<Id,Opportunity>();
      		
			if(mapBusinessLogic == null || mapBusinessLogic.isEmpty())
    			return oppsTobeProcessed;
    			
	        for (Opportunity opp : newOpps) {
	            Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
	            if(mapBusinessRules == null || mapBusinessRules.isEmpty())
	            	continue;

	            if (!opp.Non_Contracted__c)
	            	continue;
	            	
	            if (mapBusinessRules.get('StageName').Business_Rule_Value__c == null 				|| 
            	 	opp.StageName != mapBusinessRules.get('StageName').Business_Rule_Value__c       ||
            		opp.StageName == oldMap.get(opp.Id).StageName 									||
            		mapBusinessRules.get('Menu Change Case') == null								||
            		mapBusinessRules.get('Menu Change Case').Business_Rule_Value__c == null)  
	            	continue;	
	            		
	            oppsTobeProcessed.put(opp.id,opp);
	        	
	        }
	        
	        return oppsTobeProcessed;
      }
      
      /**
  	   @Description: This method creates Menu Processing cases
  	   		@Process Name		: non contracted menu change process
      		@Business Config 	: NonContractedMenuChange
  	   		@InputParams		: Opportunity record, List of existing cases associated with the account, list of MP cases
  	   		@Return				: SObject (Case)	
  	   		@TriggerContext		: After Update
  	  */
      public static SObject createMenuChangeCase(Opportunity opp,Opportunity oldRecord,List<Case> convertToContractCases,List<Case> mpCases, Account account){
      		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('NonContractedMenuChange');
      		Map<String, Business_Config__c> mapBusinessRules 				= mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
      		Case cs;
      		Boolean existingMenuChange 	= false;
      		String menuProcessingStatus	= '';
      		if(convertToContractCases != null && convertToContractCases.size() > 0)
      			existingMenuChange = true;
      		if(mpCases != null && mpCases.size() > 0)
      			menuProcessingStatus	= mpCases[0].status;
  				
  			if (existingMenuChange) 
  				return null;
  				
            
            if(menuProcessingStatus != mapBusinessRules.get('Menu Processing Status').Business_Rule_Value__c)
             	return null;
            	
            cs = new Case(Opportunity__c = opp.id, AccountId = opp.AccountId, CurrencyIsoCode = opp.CurrencyIsoCode);
	    // populate contactId on menu change case SP-4553
            cs.ContactId = populateContactId('NonContractedMenuChange', 'copyOwnertoCaseContact', account, opp.RecordTypeId);
	      
            for (String fieldAndValue : (mapBusinessRules.get('Menu Change Case').Business_Rule_Value__c).split(',')) {
                List<String> fields = fieldAndValue.split('=');
                //mapFields.put(fields[0],fields[1]);
                cs.put(fields[0], fields[1]);
            }
           
            return cs;		
      }
      
	
/************************************* NON CONTRACTED MENU CHANGE CASE CREATION METHODS END *****************************************/

/************************************* QUALITY CHECK CASE CREATION METHODS START *****************************************/
	/**
      * @Description: This method shortlists all the opps for the creation of Quality check Cases
      		@Process Name		: Quality check process
      		@Business Config 	: QualityCheckInternalCase
      		@Input Params		: List of updated opps, Map of opps before updation
      		@Return				: Shortlisted Opportunity Map
      		@TriggerContext		: After Update
      */
      public static Map<Id, Opportunity> shortListOppsForQCProcessing(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){
      		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('QualityCheckInternalCase');
      		List<Opportunity> newOpps  										= (List<Opportunity>)sobjects;
      		Map<Id,Opportunity> oldMap										= (Map<Id,Opportunity>)oldSobjectMap;
      		Map<Id,Opportunity> oppsTobeProcessed 							= new Map<Id,Opportunity>();
      		
			if(mapBusinessLogic == null || mapBusinessLogic.isEmpty())
    			return oppsTobeProcessed;
    		
	        Set<Id> oppIdSet = new Set<Id>();
		Set<Id> openQACaseOppIdSet = new Set<Id>();
		for(Opportunity opp : newOpps) {
		    oppIdSet.add(opp.Id);
		}

		if(!oppIdSet.isEmpty()) {
		   openQACaseOppIdSet =  ClsCaseSelector.findOpenCaseByOpportunity(oppIdSet, 'Quality Check');
		}
	        
	      for (Opportunity opp : newOpps) {
	        	Set<String> stageNameSet;
	        	
                Map<String, Business_Config__c> rules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));

                if (rules == null || !rules.containsKey('StageName')) {
                    continue;
                }
	            
	            stageNameSet = new Set<String>(rules.get('StageName').Business_Rule_Value__c.split(','));
	            if (stageNameSet.contains(opp.stageName) && 
	            	 (oldMap ==  null || (oldMap.get(opp.id).stageName != opp.stageName)) && !openQACaseOppIdSet.contains(opp.Id)) {
	            		oppsTobeProcessed.put(opp.Id,opp);
	            }
	        }
	        return oppsTobeProcessed;
      }
      
       /**
  	   @Description: This method creates Menu Processing cases
  	   		@Process Name		: Quality check process
      		@Business Config 	: QualityCheckInternalCase
  	   		@InputParams		: Opportunity record, List of cases associated with opp, Account associated with the opp
  	   		@Return				: SObject (Case)	
  	   		@TriggerContext		: After Update
  	  */
      public static SObject createQualityCheckCase(Opportunity opp,List<Case> cases,Account account){
      		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('QualityCheckInternalCase');
      		Map<String, Business_Config__c> rules 	= mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
      		Set<String> caseTypes 					= new Set<String>();
      		Boolean oppWithFirstStageQC				= false;
		  Boolean checkForMIDASPackage            = false; //SSC-1332 Changes
      		
      		if (rules.containsKey('CheckOpenCaseType')) {
      			caseTypes.addAll(rules.get('CheckOpenCaseType').Business_Rule_Value__c.split(','));
      		}
      		
      		if(Cases != null){
	      		for(Case cs : cases){
	      			if(caseTypes.contains(cs.type) && !cs.isClosed){
	      				return null;
	      			}else if (cs.Type == 'Quality Check' && cs.Stage_1_Completed__c) {
	                    oppWithFirstStageQC = true;
	                }
	      		}
      		}
      		
      		Case cs = new Case(
                Opportunity__c = opp.Id,
                AccountId = opp.AccountId,
                CurrencyIsoCode = opp.CurrencyIsoCode
            );
            
            /* following logic was added for talabat SP-1447
                Only for New Business Opp related to Brand Account the Quality Check
                could have two different stages */

            Set<String> validAccountForSecondStage = rules.containsKey('validAccountForSecondStage') 
										? new Set<String>(rules.get('validAccountForSecondStage').Business_Rule_Value__c.split(',')) 
										: new Set<String>();
            Set<String> validOppBusinessTypeForSecondStage = rules.containsKey('validOppBusinessTypeForSecondStage') 
            							? new Set<String>(rules.get('validOppBusinessTypeForSecondStage').Business_Rule_Value__c.split(',')) 
            							: new Set<String>();

            String ruleName = 'QualityCheckCase';
            if (validAccountForSecondStage.contains(account.Type)
                    && validOppBusinessTypeForSecondStage.contains(opp.Business_Type__c)) {
                if (!oppWithFirstStageQC){
                    ruleName = 'QualityCheckCaseFirstStage';
                } else {
                    ruleName = 'QualityCheckCaseSecondStage';
                }
            }
            
            // Check if the Opportunity is Refund opportunity and assign it to finance team
            if(rules.get('refundBusinessTypes') != null){
	            List<String> refundBusinessTypes = rules.get('refundBusinessTypes').Business_Rule_Value__c.split(',');
				if(refundBusinessTypes.contains(opp.Business_type__c)){
					ruleName = 'QualityCheckCaseForFinanceTeam';
				}
            }

            for (String fieldAndValue : rules.get(ruleName).Business_Rule_Value__c.split(',')) {
                List<String> fields = fieldAndValue.split('=');
                cs.put(fields[0], fields[1]);
            }

		  //SSC-1332 Starts Here:
		  if(rules.containsKey('MIDASPackagesCaseQueueAssignment')){
			  checkForMIDASPackage = validateIfThereIsMidasPackage(rules,opp.id,cs);
		  }
		  if(!checkForMIDASPackage){ //SSC-1332 - Checking if it's not MIDAS Packages
			  // populate Case assignments
			  if(rules.containsKey('assignmentMap')){
				  Map<String,String> assignmentMap =
						  (Map<String, String>)JSON.deserialize(rules.get('assignmentMap').business_rule_value__c,
								  Map<String, String>.class);
				  if(assignmentMap.containsKey(account.record_country__c)){
					  cs.ownerId  = assignmentMap.get(account.record_country__c);
				  }
			  }
		  }
		  //SSC-1332 Ends Here:
            // populate Case assignments
            if(rules.containsKey('assignmentMap')){
            	Map<String,String> assignmentMap = 
            			(Map<String, String>)JSON.deserialize(rules.get('assignmentMap').business_rule_value__c, 
            													Map<String, String>.class);
            	if(assignmentMap.containsKey(account.record_country__c)){
            		cs.ownerId	= assignmentMap.get(account.record_country__c);
            	}
            }
            // populate Case recordtypes
            if(rules.containsKey('recordTypeMap')){
            	Map<String,String> recordTypeMap = 
            			(Map<String, String>)JSON.deserialize(rules.get('recordTypeMap').business_rule_value__c, 
            													Map<String, String>.class);
            	if(recordTypeMap.containsKey(account.record_country__c)){
            		cs.recordTypeId	= recordTypeMap.get(account.record_country__c);
            	}
            }

            /* SP-491
            needs to be hardcoded, since concatination
            with fieldnames doesnt work from business configs */
            if (rules.containsKey('UseBusinessTypeForCaseSubject')
                    && Boolean.valueOf(rules.get('UseBusinessTypeForCaseSubject').Business_Rule_Value__c)) {
                cs.Subject += ' ' + opp.Business_Type__c;
            }

            return cs;
      		
      }
/************************************* QUALITY CHECK CASE CREATION METHODS START *****************************************/

/************************************* ASSET CREATION PROCESS METHODS START *****************************************/
	/**
      * @Description: This method shortlists all the opps for the creation of assets
      		@Process Name		: Asset creation process
      		@Business Config 	: AssetCreationProcess
      		@Input Params		: List of updated opps, Map of opps before updation
      		@Return				: Shortlisted Opportunity Map
      		@TriggerContext		: After Update
      */
      public static Map<Id, Opportunity> shortListOppsForAssetCreationProcess(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){
      		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('AssetCreationProcess');
      		List<Opportunity> newOpps  										= (List<Opportunity>)sobjects;
      		Map<Id,Opportunity> oldMap										= (Map<Id,Opportunity>)oldSobjectMap;
      		Map<Id,Opportunity> oppsTobeProcessed 							= new Map<Id,Opportunity>();	

            if (mapBusinessLogic == null || mapBusinessLogic.isEmpty())
            	return oppsTobeProcessed;
            	
            for (Opportunity opp : newOpps) {
                    
                Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                if (mapBusinessRules == null || mapBusinessRules.isEmpty())
                	continue;
                
                if (opp.StageName == mapBusinessRules.get('StageName').Business_Rule_Value__c 	&& 
                	opp.StageName != oldMap.get(opp.id).StageName 								&& 
                	opp.Type == mapBusinessRules.get('Type').Business_Rule_Value__c) {
                    	oppsTobeProcessed.put(opp.id,opp);
                }
            }
            
            return oppsTobeProcessed;
      }
      
      /**
  	   @Description: This method creates Assets
  	   		@Process Name		: Asset creation process
      		@Business Config 	: AssetCreationProcess
  	   		@InputParams		: Opportunity record, Quote Line Items
  	   		@Return				: List of SObject (Assets)	
  	   		@TriggerContext		: After Update
  	  */
      public static List<SObject> createAssets(Opportunity opp,List<Opportunity_Quote_Line_Item__c> quoteLineItems){
      		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('AssetCreationProcess');
      		List<Asset__c> listAssets 										= new List<Asset__c>();
			
			if(quoteLineItems == null)
				return listAssets;
            
            for(Opportunity_Quote_Line_Item__c qq1 : quoteLineItems) {
				if(qq1.Line_Item_Type__c != 'Product' ||  qq1.Id_Opportunity_Quote__r.status__c != 'Accepted' ||
					!qq1.Id_List_Product_Price__r.Requires_Asset__c ||
					(qq1.Assets__r != null && !qq1.Assets__r.isEmpty()))
						continue;           	

                Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(qq1.Id_Opportunity__r.RecordType.DeveloperName);
                if (mapBusinessRules == null || mapBusinessRules.isEmpty())
                	return listAssets;

                //Itereate over number of quantity
                for (integer i = 1; i <= qq1.Quantity__c; i++) {
                    Asset__c newAsset 			= new Asset__c();
                    newAsset.name 				= qq1.name;
                    newAsset.OwnerId 			= qq1.Id_Opportunity__r.OwnerId;
                    newAsset.Account__c 		= qq1.Id_Opportunity_Quote__r.Id_Account__c;
                    newAsset.CurrencyIsoCode 	= qq1.CurrencyIsoCode;
                    newAsset.RecordTypeId 		= LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('AssetRecordType').Business_Rule_Value__c);
                    newAsset.Opportunity__c 	= qq1.Id_Opportunity__c;
                    newAsset.Status__c 			= mapBusinessRules.get('AssetStatus').Business_Rule_Value__c;
                    newAsset.Id_Opportunity_Quote_Line_Item__c = qq1.Id;
                    listAssets.add(newAsset);
                }         
            }
            return listAssets;
      }	  
      
        
/************************************* ASSET CREATION PROCESS METHODS END ***********************************************/

/************************************* BRANDING CREATION PROCESS METHODS START ******************************************/
	/**
      * @Description: This method shortlists all the opps for the creation of Branding
      		@Process Name		: branding creation process
      		@Business Config 	: Opportunity Contract Process
      		@Input Params		: List of updated opps, Map of opps before updation
      		@Return				: Shortlisted Opportunity Map
      		@TriggerContext		: After Update
      */
      public static Map<Id, Opportunity> shortListOppsForBrandingCreation(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){
      		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('Opportunity Contract Process');
      		List<Opportunity> newOpps  										= (List<Opportunity>)sobjects;
      		Map<Id,Opportunity> oldMap										= (Map<Id,Opportunity>)oldSobjectMap;
      		Map<Id,Opportunity> oppsTobeProcessed 							= new Map<Id,Opportunity>();
      		
      		if (mapBusinessLogic == null || mapBusinessLogic.isEmpty())
            	return oppsTobeProcessed;
            	
            for (Opportunity opp : newOpps) {
                Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                if (mapBusinessRules != null && !mapBusinessRules.isEmpty() 	&& 
                	opp.stageName != oldMap.get(opp.id).stagename 				&& 
                	mapBusinessRules.get('createBrandingOnQuoteAccept') != null && 
                	mapBusinessRules.get('createBrandingOnQuoteAccept') != null && 
                	mapBusinessRules.get('stageNameBranding') != null 			&&  
                	Boolean.valueOf(mapBusinessRules.get('createBrandingOnQuoteAccept').Business_Rule_Value__c) && 
                	opp.stageName == mapBusinessRules.get('stageNameBranding').Business_Rule_Value__c 			&& 
                	oldMap.get(opp.id).stagename != mapBusinessRules.get('stageNameBranding').Business_Rule_Value__c ) {
	                    oppsTobeProcessed.put(opp.id,opp);
                }
            }
            
            return oppsTobeProcessed;
      }	
      
      /**
  	   @Description: This method creates Branding
  	   		@Process Name		: branding creation process
      		@Business Config 	: Opportunity Contract Process
  	   		@InputParams		: Opportunity record, Quote Line Items
  	   		@Return				: List of SObject (Assets)	
  	   		@TriggerContext		: After Update
  	  */
      public static List<SObject> createBrandings(Opportunity opp,List<Opportunity_Quote_Line_Item__c> quoteLineItems){
      		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('Opportunity Contract Process');
      		Map<String, Business_Config__c> mapBusinessRules 				= mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
      		List<Branding_Content__C> newBrandingContentLst 				= new List<Branding_content__c>();
      		
            for (Opportunity_quote_line_item__C oqli : quoteLineItems) {
                if(!oqli.Id_List_Product_Price__r.Requires_Branding__c 		|| 
                	oqli.Id_Opportunity_Quote__r.status__c != 'Accepted')
                		continue;
                if (oqli.branding_content__r != null && !oqli.branding_content__r.isEmpty()) 
                	continue;
                
                Branding_Content__C branding 				= new Branding_Content__c();
                branding.Opportunity__c 					= oqli.id_opportunity__c;
                branding.Id_Opportunity_Quote_Line_Item__c 	= oqli.id;
                branding.Quantity__c 						= oqli.quantity__c;
                branding.Restaurant_Name__c 				= oqli.id_opportunity__r.accountid;
                branding.type__c 							= oqli.Id_List_Product_Price__r.Product_Type__c;
                branding.Number_of_Copies__c 				= oqli.Number_of_Copies__c;
                branding.Product__c 						= oqli.Id_List_Product_Price__c;
                branding.status__c 							= 'New';
                branding.recordtypeid 						= LibRecordTypeHelper.getRecordTypeValue(oqli.id_opportunity__r.Company_Code__c + '_Branding_Content');
                branding.ownerid 							= mapBusinessRules.get('DesignQueueId').Business_Rule_Value__c;
                newBrandingContentLst.add(branding);
            }
            
            return newBrandingContentLst;
      }
      
/************************************* BRANDING CREATION PROCESS METHODS END ********************************************/

/************************************* FLAT COMMISSION ENTRY CASE METHODS START *****************************************/
	/**
      * @Description: This method shortlists all the opps for the creation of flat commission entry case
      		@Process Name		: Flat commission entry case process
      		@Business Config 	: FlatCommissionEntryCaseProcess
      		@Input Params		: List of updated opps, Map of opps before updation
      		@Return				: Shortlisted Opportunity Map
      		@TriggerContext		: After Update
      */
      public static Map<Id, Opportunity> shortListOppsForflatCommissionEntryProcess(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){
      		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('FlatCommissionEntryCaseProcess');
      		List<Opportunity> newOpps  										= (List<Opportunity>)sobjects;
      		Map<Id,Opportunity> oldMap										= (Map<Id,Opportunity>)oldSobjectMap;
      		Map<Id,Opportunity> oppsTobeProcessed 							= new Map<Id,Opportunity>();
      		Set<String> oppTypes 											= new Set<String>();
      		
      		if (mapBusinessLogic == null || mapBusinessLogic.isEmpty())
      			return oppsTobeProcessed;
      			
            for (Opportunity opp : newOpps) {
                	
                Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                if (mapBusinessRules == null || mapBusinessRules.isEmpty())
                	continue;
                
                if ( mapBusinessRules.get('StageName').Business_Rule_Value__c == null 			|| 
	            	 mapBusinessRules.get('OpportunityType') == null							||
	            	 mapBusinessRules.get('OpportunityType').Business_Rule_Value__c == null		||
	            	 opp.StageName == oldMap.get(opp.Id).StageName  							|| 
	            	 opp.StageName != mapBusinessRules.get('StageName').Business_Rule_Value__c	||
	            	 mapBusinessRules.get('OpportunityTarif') == null							||
	            	 mapBusinessRules.get('EntryCase') == null 									||
	            	 mapBusinessRules.get('EntryCase').Business_Rule_Value__c == null)
	            	 continue;
                
	            oppTypes = new Set<String>((mapBusinessRules.get('OpportunityType').Business_Rule_Value__c).split(','));
	            if (oppTypes.contains(opp.type)) {
	                oppsTobeProcessed.put(opp.Id, opp);
	            }
            }   
            
            return oppsTobeProcessed;           
      }
      
      /**
  	   @Description: This method creates Menu Processing cases
  	   		@Process Name		: Flat commission entry case process
      		@Business Config 	: FlatCommissionEntryCaseProcess
  	   		@InputParams		: Opportunity record, Opportunity record with parents
  	   		@Return				: SObject (Case)	
  	   		@TriggerContext		: After Update
  	  */
      public static SObject createFlatCommissionEntryCase(Opportunity opp,Opportunity oppWithParent){
      		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('FlatCommissionEntryCaseProcess');
            Map<String, Business_Config__c> mapBusinessRules 				= mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
            Case cs;
             
            if (oppWithParent.Id_Tarif__r.Name != mapBusinessRules.get('OpportunityTarif').Business_Rule_Value__c)
            	return null;

            cs = new Case(Opportunity__c = opp.id, AccountId = opp.AccountId, CurrencyIsoCode = opp.CurrencyIsoCode);
            for (String fieldAndValue : (mapBusinessRules.get('EntryCase').Business_Rule_Value__c).split(',')) {
                List<String> fields = fieldAndValue.split('=');
                cs.put(fields[0], fields[1]);
            }
 
            return cs;
      }
/************************************* FLAT COMMISSION ENTRY CASE METHODS END *****************************************/

/************************************* PREMIUM PLACEMENT (MIDAS) CANCELLATION METHODS START *****************************************/
	/**
      * @Description: This method shortlists all the opps for the cancellation of PP bookings
      		@Process Name		: premium placement cancellation process
      		@Business Config 	: PermiumPlacementOpp
      		@Input Params		: List of updated opps, Map of opps before updation
      		@Return				: Shortlisted Opportunity Map
      		@TriggerContext		: After Update
      */
      public static Map<Id, Opportunity> shortListOppsForPPCancellation(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){
      		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('PermiumPlacementOpp');
       		List<Opportunity> newOpps  										= (List<Opportunity>)sobjects;
      		Map<Id,Opportunity> oldMap										= (Map<Id,Opportunity>)oldSobjectMap;
       		Map<Id,Opportunity> oppsTobeProcessed 							= new Map<Id,Opportunity>();
       		
       		if(mapBusinessLogic ==null || mapBusinessLogic.isEmpty())
       			return oppsTobeProcessed;
			
			for(Opportunity opp : newOpps){
				
       			Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.recordTypeId));
				
				if (mapBusinessRules == null 						|| 
                	mapBusinessRules.isEmpty() 						|| 
                	opp.StageName != 'Closed Lost'  				|| 
                	oldMap.get(opp.id).stageName == opp.stageName 	|| 
                	opp.Id_Tarif__c == null                         ||
                	!mapBusinessRules.get('EnabledForCountry').Business_Rule_Value__c.containsIgnorecase(opp.record_country__c)){
                		continue;
					
                }
                
                oppsTobeProcessed.put(opp.id,opp);
				system.debug('oppsTobeProcessed...'+oppsTobeProcessed);
			}
			
            return oppsTobeProcessed;
      }
      
      /**
      * @Description: This method shortlists all the opps for the cancellation of PP bookings
      		@Process Name		: premium placement cancellation process
      		@Business Config 	: NONE
      		@Input Params		: Opportunity record
      		@Return				: void
      		@TriggerContext		: After Update
      */
      public static void cancelMidasPP(Opportunity opp){
      		Boolean interested 		= false;
            String reason 			= 'no_interest';
            String intrestedData 	= InterestedOppClosedLost__c.getValues('Interested').values__c;
            
            if (intrestedData == null) {
                opp.addError('Custom setting InterestedOppClosedLost__c is not defined with values');
                return;
            }
            
	        Set<String> intrestedReasons = new Set<String>(intrestedData.split(','));
	        if (intrestedReasons.contains(opp.Lost_Reason__c)) {
	            interested 	= true;
	            reason 		= 'opp_interest';
	        }
                    
            callMidasOPPLostAPI(opp.Id, opp.AccountId, interested, reason,opp.record_country__c );      		
      }
      
     @future(callout = true)
     public static void callMidasOPPLostAPI(String oppId, String accId, Boolean interested, String reason,String Country){
        Opportunity opp = [select id, MidasAPIException__c from Opportunity where id = :oppId];
        List<Opportunity_Line_Item__c> PPLineItems = [SELECT Id,Booking_Api_Id__c,Id_List_price_product__r.company__r.name
        												FROM Opportunity_Line_Item__c
        												WHERE Id_opportunity__c =: oppId
        												AND Booking_Api_Id__c != null];
                    												
		Id currentUserId 	= UserInfo.getUserId();
        User userData 		= [SELECT Id, Email, UserRole.Name FROM User where id = :currentUserId];
        
        try { 
        	registerInterest(opp,interested,reason,accId,Country,currentUserId,userData);
        	String result = cancelBookings(userData,PPLineItems,country);
        	opp.MidasAPIException__c = opp.MidasAPIException__c == null ? result : ',' + opp.MidasAPIException__c + result;
            update opp;

        } catch (System.CalloutException e) {
            system.debug('Error: ' + e.getMessage());
            String err = e.getMessage();
            if (err.length() > 250) {
                err = err.left(250);
            }
            opp.MidasAPIException__c = 'Er-' + err;
            update opp;
        }
    }
    
    public static void registerInterest(Opportunity opp,Boolean interested, String reason,String accId,String Country,Id currentUserId,User userData){     
        // check for the company codes associated with the Country
        MidasIntegration__c integrationConfigs = MidasIntegration__c.getValues('PP');
        if(integrationConfigs ==  null){
        	opp.MidasAPIException__c = 'Error: MidasIntegration__c is not configured';
        	return;
        }
        Map<String,String> countryBrand =(Map<String, String>)JSON.deserialize(integrationConfigs.CountryBrand__c, Map<String, String>.class);
        if(!countryBrand.containsKey(country)){
        	opp.MidasAPIException__c = 'Error: CountryBrand setting not present in MidasIntegration__c';
        	return;
        }
        List<String> codes = countryBrand.get(country).split(',');
        
        for(String code : codes){
        	String bodyparam 	= '{"meta": {"username": "' + userData.Email + '","sf_role": "' + userData.UserRole.Name + '","sf_opportunity_id": "' + opp.Id + '"},"data": {"reason":"' + reason + '","expressed_interest":' + interested + '}}';
        	String api = '/restaurants/sf:' + accId + '/register_interest';
        	String uri = '/v2/sites/'+code+api;
        	HttpRequest req 	= LibWebserviceHelper.constructMidasHttpRequest('PP',uri,'POST', bodyparam);
	        HttpResponse res = new HttpResponse();
	        Http http = new Http();
    		System.debug('bodyparam: ' + bodyparam);
    		if (req != null) {
            res = http.send(req);
            System.debug('response :' + res.getBody());
            system.debug('##status code' + res.getStatusCode());
            if (res.getStatusCode() == 201) {
	                if (opp.MidasAPIException__c != null) {
	                    opp.MidasAPIException__c = null;
	                }
	            } else {
	                opp.MidasAPIException__c = res.getStatusCode() + '-' + res.getBody();
	            }
	
	        } else {
	            opp.MidasAPIException__c = 'MidasIntegration__c is not configured';
	        }
        }            
    }
    
    public static String cancelBookings(User userData,List<Opportunity_Line_item__c> PPLineItems,String country){
    	List<CtrAccountList.Bookings> wrapper = populateWrapper(PPLineItems);
    	String result = CtrAccountList.cancelBookings(wrapper,userData.UserRole.Name,userData.email,country,true);
    	return result;
    }
    
    public static List<CtrAccountList.Bookings> populateWrapper(List<Opportunity_Line_Item__c> ppLineItems){
    	List<CtrAccountList.Bookings> wrapper = new List<CtrAccountList.Bookings>();
    	for(Opportunity_Line_item__c lineItem : ppLineItems){
    		CtrAccountList.Bookings bk = new CtrAccountList.Bookings(lineItem.Booking_Api_Id__c,lineItem.Id,lineItem.Id_List_price_product__r.company__r.name);
    		wrapper.add(bk);
    	}
    	
    	return wrapper;
    }

	/**
		@Description	 Cancel Premium Placement Opportunities
		@Param			 Opportunity Id
		@Return			 None
		@triggerEvent	AfterUpdate
      */
	@future(callout=true)
	public static void cancelPremiumPlacementInMidas(Id oppId){

		string logName = 'Booking_Cancellation';
		LoggingUtility.createLog(logName,'MIDAS_SELFBOOKING',' OPP ID- '+oppId,null);
		List<Opportunity> listOpps = Opportunity_Selector.getSelected(new List<ID>{oppId});
		List<LibWebserviceHelper.oppLineItemBookingData> listBookData = prepareDataForMidasCallout(oppId);
		HttpResponse response;
		try {
			LoggingUtility.log(logName,'Request Body: ' +listBookData);
			LoggingUtility.captureTimeStamp(logName,'Begin');
			response = LibWebserviceHelper.constructMidasRequestForBookingCancellation(listOpps[0].Record_Country__c,listBookData,logName);
			if (response.getStatusCode() != 204 && response.getStatusCode() != 208) {
				LoggingUtility.logError(logName, ' Failed to cancel bookings- ' + response.getStatus() + ' ' + response.getStatusCode());
				updateExceptionInOpp(listBookData);
			}
		} catch(exception e){
			System.debug('Error: '+e.getMessage());
			LoggingUtility.logError(logName, e.getStackTraceString());
			if (response == null || (response.getStatusCode() != 204 && response.getStatusCode() != 208)) {
				updateExceptionInOpp(listBookData);
			}
		}
		LoggingUtility.captureTimeStamp(logName,'End');
		LoggingUtility.commitLogs();
	}

	/**
    * @description To prepare data to send as body to Midas. This is used in booking
    * 				approvals and cancellations
    * @Param        ID oppId
    * @return       Wrapper oppLineItemBookingData
    */
	public static List<LibWebserviceHelper.oppLineItemBookingData> prepareDataForMidasCallout(ID oppId){

		List<LibWebserviceHelper.oppLineItemBookingData> wrapper = new List<LibWebserviceHelper.oppLineItemBookingData>();
		try {
			List<Opportunity_Line_Item__c> premPlacementLineItems =
					OpportunityLineItem_Selector.getOLIByOpportunityId(new set<Id>{oppId});
			for (Opportunity_Line_item__c lineItem : premPlacementLineItems) {
				LibWebserviceHelper.oppLineItemBookingData bookData = new LibWebserviceHelper.oppLineItemBookingData(Integer.valueOf(lineItem.Booking_Api_Id__c), UserInfo.getUserEmail());
				wrapper.add(bookData);
			}
		}catch(exception e){
			system.debug('Error: '+e.getMessage());
		}
		return wrapper;
	}
	
/************************************* PREMIUM PLACEMENT (MIDAS) CANCELLATION METHODS END *****************************************/

/************************************* PREMIUM PLACEMENT (MIDAS) BOOKINGS UPDATE METHODS START ******************************/
	/**
      * @Description: This method updates the bookings' status in Midas after the opportunity is closed won
      		@Process Name		: premium placement bookings update process
      		@Input Params		: List of Closed Won opportunities, Map of Complete opportunity
      		@Return				: VOID
      		@TriggerContext		: After Update
      */
      public static void updateBookingsStatusInMidas(Map<Id,Opportunity> closedWonOppMap,Map<Id,Opportunity> oppMap){
      		List<Opportunity> oppsToBeProcessed = new List<Opportunity>();
      		for(Opportunity opp : closedWonOppMap.values()){
      			if(oppMap.get(opp.id).Id_Tarif__r.name == 'Premium Placement'){
      				oppsToBeProcessed.add(opp);
      			}
      		}

      		if(oppsToBeProcessed.size() == 0)
      			return;
      			
      		sentBookingsStatusToMidas(oppsToBeProcessed[0].Id);
      }
      
      @Future(callout=true)
      public static void sentBookingsStatusToMidas(String oppId){
      		List<Opportunity_Line_Item__c> opplIineItems = [SELECT Id,Booking_Api_Id__c,Id_list_price_product__r.company__r.name,Id_Opportunity__r.Source_System__c,
																Id_Opportunity__r.Record_Country__c
      															FROM Opportunity_LIne_item__c
      															WHERE Booking_Api_Id__c != null
      																AND Id_Opportunity__c =: oppId];
      																
      		if(opplIineItems.size() == 0)
      			return;

		  //Call MIDAS API only when Sales area is blank or null to avoid conflicts with new integration
		  if(opplIineItems[0].Id_Opportunity__r.Source_System__c == null || opplIineItems[0].Id_Opportunity__r.Source_System__c == '' ){
		  		makePatchCalloutToMidas(opplIineItems,oppId);
	       }
      }
      
      public static void makePatchCalloutToMidas(List<Opportunity_Line_Item__c> lineItems,String oppId) {
		  String userRole = [Select Name from UserRole where Id = :UserInfo.getUserRoleId()].Name;
		  String userEmail = UserInfo.getUserEmail();
		  String logName = 'PatchBookings';

		  // Prepare the wrapper to be sent
		  Tarif.BookingData dataToBePatched = new Tarif.BookingData();
		  Tarif.Meta metaData = new Tarif.Meta();
		  metaData.username = userEmail;
		  metaData.sf_role = userRole;
		  metaData.sf_opportunity_id = oppId;

		  Tarif.DataWrapper wrapper = new Tarif.DataWrapper();

		  List<Tarif.Booking> bookings = new List<Tarif.Booking>();
		  for (Opportunity_Line_Item__c li : lineItems) {
			  Tarif.Booking bk = new Tarif.Booking();
			  bk.status = 'open';
			  bk.id = Integer.valueOf(li.Booking_Api_Id__c);
			  bk.site = CountryCompanyBrand__c.getInstance(li.Id_list_price_product__r.company__r.name).Code__c;
			  bk.packageOptions = null;
			  bk.booked = null;
			  bookings.add(bk);
		  }
		  wrapper.bookings = bookings;
		  dataToBePatched.meta = metaData;
		  dataToBePatched.data = wrapper;

		  // create log
		  LoggingUtility.createLog(logName, 'MIDAS', 'BOOKINGS_PATCH', oppId);

			  try {
				  // Create the HTTP Request
				  HttpResponse res = new HttpResponse();
				  Http http = new Http();
				  String body = JSON.serialize(dataToBePatched, true);
				  HttpRequest req = LibWebserviceHelper.constructMidasHttpRequestForBookingsPatch('PP', body);

				  // Log
				  LoggingUtility.log(logName, 'Request Body : ' + body);

				  if (req != null) {
					  LoggingUtility.captureTimeStamp(logName, 'Begin');
					  res = http.send(req);
					  LoggingUtility.captureTimeStamp(logName, 'End');
					  LoggingUtility.log(logName, '\nResponse status code :' + res.getStatusCode() + '\nResponse Body => ' + res.getBody());
					  if (res.getStatusCode() != 207) {
						  LoggingUtility.captureTimeStamp(logName, 'End');
						  LoggingUtility.logError(logName, 'Error : Patch Request for the bookings failed');
					  }
				  }
			  }catch(Exception e){
				  LoggingUtility.captureTimeStamp(logName, 'End');
				  LoggingUtility.logError(logName, 'Error : ' + e.getMessage());
			  }

            
            LoggingUtility.commitLogs();
      }


	/**
		@Description	 Shortlist Premium Placement Opportunities for Approval in Midas v2
		@Param			 Opportunity Id
		@Return			 None
		@triggerEvent	AfterUpdate
      */
	public static Map<Id,Opportunity> shortListOppsForPPApproval(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){
		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('PermiumPlacementOpp');
		List<Opportunity> newOpps  										= (List<Opportunity>)sobjects;
		Map<Id,Opportunity> oldMap										= (Map<Id,Opportunity>)oldSobjectMap;
		Map<Id,Opportunity> oppsTobeProcessed 							= new Map<Id,Opportunity>();
		if(mapBusinessLogic ==null || mapBusinessLogic.isEmpty())
			return oppsTobeProcessed;

		for(Opportunity opp : newOpps){
			Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.recordTypeId));
			if (mapBusinessRules == null 						||
					mapBusinessRules.isEmpty() 						||
					opp.StageName != 'Closed Won'  				||
					oldMap.get(opp.id).stageName == opp.stageName 	||
					opp.Id_Tarif__c == null							||
					opp.Source_System__c == null							||
					!mapBusinessRules.get('EnabledForCountry').Business_Rule_Value__c.containsIgnorecase(opp.record_country__c)){
				continue;
			}
			oppsTobeProcessed.put(opp.id,opp);
		}
		return oppsTobeProcessed;
	}

	/**
		@Description	 Approve Premium Placement Opportunities
		@Param			 Opportunity Id
		@Return			 None
		@triggerEvent	AfterUpdate
      */
	@future(callout=true)
	public static void approvePremiumPlacementInMidas(Id oppId){

		string logName = 'Booking_Approval';
		LoggingUtility.createLog(logName,'MIDAS_SELFBOOKING',' OPP ID- '+oppId,null);
		List<Opportunity> listOpps = Opportunity_Selector.getSelected(new List<ID>{oppId});
		List<LibWebserviceHelper.oppLineItemBookingData> listBookData = prepareDataForMidasCallout(oppId);
		HttpResponse response;
		try {
			LoggingUtility.log(logName,'Request Body: ' +listBookData);
			LoggingUtility.captureTimeStamp(logName,'Begin');
			response = LibWebserviceHelper.constructMidasRequestForBookingApproval(listOpps[0].Record_Country__c,listBookData,logName);
			if(response.getStatusCode() != 204 && response.getStatusCode() != 208) {
				LoggingUtility.logError(logName, ' Failed to approve bookings- ' + response.getStatus() + ' Status Code ' + response.getStatusCode());
				updateExceptionInOpp(listBookData);
			}
		} catch(exception e) {
			system.debug('Error: '+e.getMessage());
			LoggingUtility.logError(logName, e.getStackTraceString());
			if (response == null || (response.getStatusCode() != 204 && response.getStatusCode() != 208)) {
				updateExceptionInOpp(listBookData);
			}
		}
		LoggingUtility.captureTimeStamp(logName,'End');
		LoggingUtility.commitLogs();
	}
/************************************* PREMIUM PLACEMENT (MIDAS) BOOKINGS UPDATE METHODS END ******************************/ 

/************************************* PREMIUM PLACEMENT (MIDAS) HANDLE EXCEPTION METHOD START *****************************************/
public static void updateExceptionInOpp(List<LibWebserviceHelper.oppLineItemBookingData> bookingsData){
	Set<String> bookingIds = new Set<String>();
	for (LibWebserviceHelper.oppLineItemBookingData bookingData: bookingsData) {
		bookingIds.add(String.valueOf(bookingData.Id));
	}
	List<Opportunity_Line_Item__c> lineItems = OpportunityLineItem_Selector.getOLIByBookingId(new List<String>(bookingIds));
	for (Opportunity_Line_Item__c lineItem: lineItems) {
		lineItem.Midas_Exception__c = true;
	}
	update lineItems;
}
/************************************* PREMIUM PLACEMENT (MIDAS) HANDLE EXCEPTION METHOD END *****************************************/

/************************************* BACKEND ID CREATION METHODS START *****************************************/
	/**
      * @Description: This method shortlists all the opps for the creation of backend Id
      		@Process Name		: backend id creation process
      		@Business Config 	: SendToBackendProcess
      		@Input Params		: List of updated opps, Map of opps before updation
      		@Return				: List of account Ids for which backend id is to be created
      		@TriggerContext		: After Update
      */
      public static List<String> shortListOppsForBackendIdCreation(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){
      		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('SendToBackendProcess');
       		List<Opportunity> newOpps  										= (List<Opportunity>)sobjects;
      		Map<Id,Opportunity> oldMap										= (Map<Id,Opportunity>)oldSobjectMap;
       		Map<Id,Opportunity> oppsTobeProcessed 							= new Map<Id,Opportunity>();
   			List<String> accIDLst 											= new List<String>();
       		
       		if(mapBusinessLogic ==null || mapBusinessLogic.isEmpty())
       			return accIDLst;
   			
            
            for (Opportunity opp : newOpps) {
                Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                if (mapBusinessRules == null || mapBusinessRules.isEmpty() || mapBusinessRules.get('BusinessType') == null ) 
                	continue;
                	
                Set<string> opptype = new set<string>((mapBusinessRules.get('BusinessType').Business_Rule_Value__c).split(','));
                
                if (mapBusinessRules.containsKey('stageName') && 
                	opp.stageName == mapBusinessRules.get('stageName').Business_Rule_Value__c 	&&
                    mapBusinessRules.get('BusinessType') != null 								&& 
                    opptype.contains(opp.Business_Type__c) 										&& 
                    opp.stagename != oldMap.get(opp.id).stageName) {
                    accIDLst.add(opp.accountId);
                }
      		}
      		
      		return accIDLst;
      }
      
      /**
      * @Description: This method shortlists all the opps for the creation of backend Id
      		@Process Name		: backend id creation process
      		@Business Config 	: SendToBackendProcess
      		@Input Params		: List of Account Ids
      		@Return				: void
      		@TriggerContext		: After Update
      */
      public static void createBackendId(List<String> accountIds){
      		List<string> accLst = new List<string>();
      		List<string> accIds = new List<String>();
      		
      		List<Account> accounts = [SELECT id,restaurant_name__c, backend_id__c, BillingPostalCode, Record_Country__c 
      									FROM account 
      									WHERE id IN:accountIds 
      										AND Backend_ID__c = null 
      										AND type != 'Parent' 
      										AND restaurant_name__c != null ];
            for (Account a : accounts) {
                accLst.add(JSON.serialize(a));
                accIds.add(a.id);
            }
            if (!accLst.isEmpty()) {
                createBackendCallout(accLst, accIds);
            }
      }
      
       @future(callout = true)
    public static void createBackendCallout(List<String> accLst, List<string> accIds) {
        List<Account>accsToUpd = new List<Account>();
        List<opportunity_Quote_Line_Item__c> oppQuoteLine = [select Start_Date__c, Id_Opportunity__r.accountid from opportunity_Quote_Line_Item__c where sub_type__c = 'Commission Fee' and Id_Opportunity_Quote__r.status__c = 'Accepted' and Id_Opportunity__r.accountid = :accIds];
        Map<string, String> accLeadMap = new Map<string, string>();
        Map<string, string> accOQliMap = new Map<string, string>();
        Map<string, string> accBackendIdMap = new Map<string, string>();
        //List<Lead> convLeadSrc = [Select  LeadSource,ConvertedAccountId From Lead Where IsConverted = True and ConvertedAccountId=: accIds];

        /*for(Lead l:convLeadSrc){
            accLeadMap.put(l.ConvertedAccountId,l.LeadSource);
        }*/
        for (opportunity_Quote_Line_Item__c oq : oppQuoteLine) {
            accOQliMap.put(oq.Id_Opportunity__r.accountid, String.Valueof(oq.start_date__c));
        }


        for (String a : accLst) {
            Account acc = (Account) JSON.deserialize(a, Account.class);
            Map<string, string> fieldValueMap = new Map<string, string>();
            fieldValueMap.put('name', acc.restaurant_name__c);
            fieldValueMap.put('salesforce_id', acc.id);
            fieldValueMap.put('date_joined', accOQliMap.get(acc.id));
            fieldValueMap.put('postcode', acc.BillingPostalCode);

            String jsonStr = LibJSONHelper.generateJSONMsg(fieldValueMap);
            List<string> calloutValues = LibWebserviceHelper.createBackendCalloutHeader(acc.record_country__c, 'create');

            System.debug(LoggingLevel.Error, 'm.zeuli - record country is: ' + acc.Record_Country__c);

            //String jsonStr= generateJSONMsg(acc.restaurant_name__c, acc.id,accOQliMap.get(acc.id)/*,accLeadMap.get(acc.id)*/, acc.BillingPostalCode);

            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            req.setEndpoint(calloutValues[0]);
            req.setMethod('POST');
            req.setHeader('Authorization', calloutValues[1] );
            req.setBody(jsonStr);


            try {
                res = http.send(req);
                System.debug('Send account response :' + res.getBody());
                system.debug('##status code' + res.getStatusCode());
                if (res.getStatusCode() == 201) {

                    String  sBackendId = parseResponseForId(res.getBody());
                    acc.backend_id__c = sBackendId;
                    accsToUpd.add(acc);
                    accBackendIdMap.put(acc.id, sBackendId);

                }
            } catch (System.CalloutException e) {
                system.debug(e.getMessage());
            }
        }
        if (accsToUpd != null && !accsToUpd.isEmpty()) {
            Map<String, String> conFieldValueMap = new Map<string, string>();
            List<contact> conLstToUpd = new List<contact>();
            List<contact> conLst = [select id, accountid, Backend_sync__c, account.backend_id__c, account.record_country__c, Contact_Role__c, lastname, firstname, MobilePhone, salutation, email from contact where accountid = :accsToUpd and Contact_Role__c != null and Backend_sync__c = false and recordtype.developername = 'UK_Contact'];
            String jsonBdy = '[';
            for (Contact c : conLst) {

                jsonBdy += '{"restaurant_id":' + accBackendIdMap.get(c.accountid) + ',"surname":"' + c.lastname + '","email":"' + c.email + '","position":"' + c.Contact_Role__c + '"';
                if (c.MobilePhone != null) {
                    String mob = c.mobilePhone.removeStart('0044');
                    mob = '0' + mob;
                    if (mob.length() == 11)
                        jsonBdy += ',"mobile":"' + mob + '"';
                }
                if (c.firstname != null)
                    jsonBdy += ',"first_name":"' + c.firstname + '"';

                if (c.salutation != null)
                    jsonBdy += ',"title":"' + c.salutation + '"';


                jsonBdy += '},';
            }
            String body = jsonBdy.removeEnd(',') + ']';
            List<string>calloutValues = LibWebserviceHelper.createBackendCalloutHeader('United Kingdom', 'add-contacts');
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            req.setEndpoint(calloutValues[0]);
            req.setMethod('POST');
            req.setHeader('Authorization', calloutValues[1]);
            req.setBody(body);

            try {
                integer i = 0;
                res = http.send(req);
                if (res.getStatusCode() == 207 ) {
                    JSONParser parser = JSON.createParser(res.getBody());
                    while (parser.nextToken() != null) {
                        if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                            while (parser.nextToken() != null) {
                                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                    ClsRoganAddContactResponseWrapper result = (ClsRoganAddContactResponseWrapper)parser.readValueAs(ClsRoganAddContactResponseWrapper.class);

                                    if (result.success) {
                                        conLst[i].Backend_sync__c = true;
                                        conLstToUpd.add(conLst[i]);
                                        i++;
                                    } else
                                        i++;
                                }
                            }
                        }
                    }
                }

            } catch (System.CalloutException e) {
                system.debug(e.getMessage());
            }

            try {

                update accsToUpd;
                if (conLstToUpd != null && !conLstToUpd.isEmpty()) {
                    update conLstToUpd;
                }
            } catch (Exception e) {
                system.debug(e.getMessage());

            }
        }

    }



    private static String parseResponseForId(String responseBody) {
        String sBackendId;
        JSONParser parser = JSON.createParser(responseBody);
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'restaurant_id') {
                parser.nextToken();
                //System.debug('repsonse id: '+parser.getText());
                sBackendId = parser.getText();
                return sBackendId;
                //break;
            }
        } return null;

    }
/************************************* BACKEND ID CREATION METHODS END *****************************************/

/************************************* RESTAURANT CARE (ONBOARDING) CASE METHODS START **************************************/

	/**
	  * @Description: This method shortlists all the opportunities valid for the creation of onboarding case
	  			@Process			: Restaurant Care Case process
	  			@Business Config	: RestaurantCare
	  			@Input Params		: List of updated opps, Map of opps before updation
      			@Return				: Shortlisted Opportunity Map
      			@TriggerContext		: After Update
  	*/
  	public static Map<Id, Opportunity> shortListOppsForOnboardingCase(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){
	    Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('RestaurantCare');
	    List<Opportunity> newOpps  										= (List<Opportunity>)sobjects;
      	Map<Id,Opportunity> oldMap										= (Map<Id,Opportunity>)oldSobjectMap;
	    Map<Id, Opportunity> oppMap 									= new Map<Id, Opportunity>();
	    
	    if(mapBusinessLogic ==null || mapBusinessLogic.isEmpty())
	    	return oppMap;	    	
	   
        for (Opportunity opp : newOpps) {
            Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
            if (mapBusinessRules == null || mapBusinessRules.isEmpty())
            	continue;
            if (opp.StageName == mapBusinessRules.get('stageName').Business_Rule_Value__c && 
            	opp.StageName != oldMap.get(opp.id).StageName) {
               		oppMap.put(opp.id, opp);
            }
            
        }
        	    
	    return oppMap;
  	}
	
	/**
	  * @Description: This method shortlists all the opportunities valid for updating formstack description to onboarding case
	  			@Process			: Restaurant Care Case process
	  			@Business Config	: RestaurantCare
	  			@Input Params		: List of updated opps, Map of opps before updation
      			@Return				: Shortlisted Opportunity Map
      			@TriggerContext		: After Update
  	*/
  	public static Map<Id, Opportunity> shortListOppsForFormstackUpdate(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){
	    Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('RestaurantCare');
	    List<Opportunity> newOpps  										= (List<Opportunity>)sobjects;
      	Map<Id,Opportunity> oldMap										= (Map<Id,Opportunity>)oldSobjectMap;
	    Map<Id, Opportunity> oppMap 									= new Map<Id, Opportunity>();
	    
	    if(mapBusinessLogic ==null || mapBusinessLogic.isEmpty())
	    	return oppMap;	    	
	   
        for (Opportunity opp : newOpps) {
            Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
            if (mapBusinessRules == null || mapBusinessRules.isEmpty())
            	continue;
            if (mapBusinessRules.containsKey('CopyFormstackDescription') 
                && String.isBlank(oldMap.get(opp.Id).Onboarding_Formstack_Description__c)  
                && String.isNotblank(opp.Onboarding_Formstack_Description__c)) {
               		oppMap.put(opp.id, opp);
            }
        }   
	    return oppMap;
  	}
  	
  	/**
	* @Description: Update formstack Description on onboarding cases
				@Process			: Restaurant Care Case process
	  			@Business Config	: RestaurantCare
	  			@Input Params		: Opportunity record, List of onboarding cases
      			@Return				: SOBject (Case)
      			@TriggerContext		: After Update
	*/
	public static List<SObject> updateFormstackDescriptionOnCase(Opportunity opp,List<Case> obCases,Account account){
	    List<SObject> listCase 											= new List<SObject>();
		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('RestaurantCare');
		Map<String, Business_Config__c> mapBusinessRules 				= mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordtypeId));
		
		if(mapBusinessRules.containsKey('CopyFormstackDescription')) {
		    for(Case newCase : obCases) {
		        newCase.Description = opp.Onboarding_Formstack_Description__c;
		        listCase.add(newCase);
		    }
		}
		return listCase;
	}
	
	/**
	* @Description: Create onboarding case
				@Process			: Restaurant Care Case process
	  			@Business Config	: RestaurantCare
	  			@Input Params		: Opportunity record, List of onboarding cases, account associated with the opp
      			@Return				: SOBject (Case)
      			@TriggerContext		: After Update
	*/
	public static SObject createOnboardingCase(Opportunity opp,List<Case> obCases,Account account,List<Asset__c> assets){
		List<Case> listCase 											= new List<Case>();
		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('RestaurantCare');
		Map<String, Business_Config__c> mapBusinessRules 				= mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordtypeId));
		Case cs;
			
		// check for existing cases
		if(obCases != null){
			for (Case c : obCases) {
	            if(mapBusinessRules.get('ClosedReason') == null || mapBusinessRules.get('ClosedReason').Business_Rule_Value__c == null) 
	            	return null;
	            	
	            Set<String> closedReason = new Set<String>(mapBusinessRules.get('ClosedReason').Business_Rule_Value__c.split((',')));
	            if (c.isClosed && !closedReason.contains(c.Closed_Reason__c)) {
	                return null;
	            } else if (!c.isClosed) {
	                return null;
	            }
	        }
		}
        
        // check for the assets
    	if(mapBusinessRules.get('checkForAssets') != null 
    		&& mapBusinessRules.get('checkForAssets').Business_Rule_Value__c == 'True'){
    			if(!checkForAssets(assets,mapBusinessRules))
    				return null;
    	}
		
        if (mapBusinessRules.get('Case') == null) 
        	return null;
        	
        cs = new Case(Opportunity__c = opp.id, AccountId = opp.AccountId, CurrencyIsoCode = opp.CurrencyIsoCode);
        if(account.Delivery_Service__c != null && account.Delivery_Service__c.contains('Mixed')) {
            cs.Case_reason__c  = 'Mixed';
        }else if(account.Delivery_Service__c != null && account.Delivery_Service__c.contains('All Inclusive')) {
            cs.Case_reason__c  = 'All Inclusive';
   		}

        for (String fieldAndValue : (mapBusinessRules.get('Case').Business_Rule_Value__c).split(',')) {
            List<String> fields = fieldAndValue.split('=');
            cs.put(fields[0], fields[1]);
        }
                    
        // Check for the key account. If the account is key account then assign to special key account queue
        if (mapBusinessRules.get('checkForKeyAccount') != null 
        	 && Boolean.valueOf(mapBusinessRules.get('checkForKeyAccount').Business_Rule_Value__c)
        	 && account.Key_VIP_Account__c ){
        		cs.ownerId = mapBusinessRules.get('keyAccountOwnerId').Business_rule_value__c;
        }

        // Check if the business rule is present then copy restaurant owner to contact lookup
        /*
        if (mapBusinessRules.containsKey('copyOwnertoCaseContact') ){
            if(account.AccountContactRelations != null && !account.AccountContactRelations.isEmpty()) {
                for(AccountContactRelation accountContRel: account.AccountContactRelations) {
                    cs.ContactId = accountContRel.ContactId;
                }
            }
        }
        */
		
	// Copy formstack Description 
	cs.Description = mapBusinessRules.containsKey('CopyFormstackDescription') && String.isNotblank(opp.Onboarding_Formstack_Description__c) 
	    ? opp.Onboarding_Formstack_Description__c 
	    : String.isNotblank(cs.Description) ? cs.Description : '';

        // Putting this logic as this is now a common logic needed in create menu processing as well
		cs.ContactId = populateContactId('RestaurantCare', 'copyOwnertoCaseContact', account, opp.RecordTypeId);
                    
        return cs;
	}	  

	/**
	* @Description: returns the contactId
				@Process			: Restaurant Care Case process
	  			@Business Config	: RestaurantCare
	  			@Input Params		: processName, businessRuleName, account, oppRecTypeId
      			@Return				: Id ContactId
      			@TriggerContext		: Before Update, Before Insert
	*/
	private static Id populateContactId(String processName, String businessRuleName, Account account, Id oppRecTypeId) {
		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get(processName);
		Map<String, Business_Config__c> mapBusinessRules 				= mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(oppRecTypeId));

        // Check if the business rule is present then copy restaurant owner to contact lookup
        if(null == mapBusinessRules) {
            return null;
        }
		if (mapBusinessRules.containsKey(businessRuleName)){
			if(account.AccountContactRelations != null && !account.AccountContactRelations.isEmpty()) {
				for(AccountContactRelation accountContRel: account.AccountContactRelations) {
					return accountContRel.ContactId;
				}
			}
		}
		return null;
	}
    
    /**
	* @Description: Create onboarding case
				@Process			: Restaurant Care Case process
	  			@Business Config	: RestaurantCare
	  			@Input Params		: List of assets, Map of business rules
      			@Return				: Boolean (false if does not have an activated asset)
      			@TriggerContext		: After Update
	*/
    public static Boolean checkForAssets(List<Asset__c> assets,Map<String, Business_Config__c> mapBusinessRules){
		Boolean hasActivatedAsset	= false;
		Boolean hasInactiveAsset	= false;
		
		// If there are no assets associated with the opportunity, allow creation of onboarding case
		if(assets.size() == 0){
			return true;
		}
		for(Asset__c ast : assets){	
			List<String> exceptionStatuses 	= mapBusinessRules.get('exceptionStatuses').Business_rule_value__c.split(',');
			List<String> activeStatuses		= mapBusinessRules.get('activeStatuses').Business_rule_value__c.split(',');
			if(activeStatuses.contains(ast.status__c)){
				hasActivatedAsset 	= true;
			}else if(!exceptionStatuses.contains(ast.status__c)){
				hasInactiveAsset	= true;
			}
		}
		
		// If there are no activated assets or there is any inactivated asset do not create onboarding case
		if(!hasActivatedAsset || hasInactiveAsset){
			return false;
		}
		
		return true;
    }
/************************************* RESTAURANT CARE (ONBOARDING) CASE METHODS END **************************************/

/************************************* BACKEND SHIPPING CASE METHODS START **************************************/
	/**
	  * @Description: This method shortlists all the opportunities valid for the creation of backend shipping case
	  			@Process			: Backend shipping case process
	  			@Business Config	: BackendShippingCase
	  			@Input Params		: List of updated opps, Map of opps before updation
      			@Return				: Shortlisted Opportunity Map
      			@TriggerContext		: After Update
  	*/
  	public static Map<Id, Opportunity> shortListOppsForBackendShippingCase(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){
  		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('BackendShippingCase');
	    List<Opportunity> newOpps  										= (List<Opportunity>)sobjects;
      	Map<Id,Opportunity> oldMap										= (Map<Id,Opportunity>)oldSobjectMap;
	    Map<Id, Opportunity> oppMap 									= new Map<Id, Opportunity>();
	    
	    if(mapBusinessLogic ==null || mapBusinessLogic.isEmpty())
	    	return oppMap;
	    	
    	for(Opportunity opp : newOpps) {
           Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
           if (mapBusinessRules == null || mapBusinessRules.isEmpty()) 
           		continue;
            
            if (!mapBusinessRules.containsKey('StageName') || mapBusinessRules.get('StageName').Business_Rule_Value__c == null)
            	continue;
            	 
            Set<String> stageNameSet = new Set<String>(mapBusinessRules.get('StageName').Business_Rule_Value__c.split(','));
                
	        if (stageNameSet.contains(opp.stageName) && oldMap.get(opp.id).stageName != opp.stageName) {
	        	oppMap.put(opp.id,opp);    
	        }
    	}    
    	
    	return oppMap;  
  	}
  	
  	/**
	* @Description: Create backend shipping case
				@Process			: Backend shipping case process
	  			@Business Config	: BackendShippingCase
	  			@Input Params		: Opportunity record, List of cases
      			@Return				: list of SOBject (Cases)
      			@TriggerContext		: After Update
	*/
	public static List<SObject> createBackendShippingCase(Opportunity opp,List<Case> cases,
														List<Opportunity_Quote_Line_item__c> quoteLineItems){
		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('BackendShippingCase');
		Map<String, Business_Config__c> mapBusinessRules                = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
		Set<String> caseTypes 											= new Set<String>();
		List<Case> listCase												= new List<Case>();
		
		if (mapBusinessRules.get('CheckOpenCaseType') != null && mapBusinessRules.get('CheckOpenCaseType').Business_Rule_Value__c != null) {
            caseTypes  = new Set<String>(mapBusinessRules.get('CheckOpenCaseType').Business_Rule_Value__c.split(','));
        }
        
        if (caseTypes.isEmpty())
        	return listCase;
        	
        // loop for checking open cases which has types of CaseTypes and removes opportunity from the Map
        if(cases != null){
	        for (Case cs : cases) {
	            if(!caseTypes.contains(cs.type)){
	            	caseTypes.remove(cs.type);
	            	continue;
	            }
	            if ((cs.isClosed && (cs.Closed_Reason__c == 'Take Online' || cs.Closed_Reason__c == 'Successful')) || 
	            	(!cs.isClosed)) {
	                	caseTypes.remove(cs.type);
	            }
	        }
        }
        
         if (caseTypes.isEmpty())
         	return listCase;
         	
        Map<String, Boolean> mapOfProductType 	= new Map<String, Boolean>();
        Set<String> shippingProd 				= new Set<String>();
        Set<String> backendProd 				= new Set<String>();
        Set<String> brandingProd 				= new Set<String>();
        
        mapOfProductType.put('ShippingProducts', false);
        mapOfProductType.put('BackendProducts', false);
        
        if (mapBusinessRules.get('ProductTypeForShipping') != null) {
            shippingProd = new Set<String>(mapBusinessRules.get('ProductTypeForShipping').Business_Rule_Value__c.split(','));	
        }
        if (mapBusinessRules.get('ProductTypeForBackend') != null) {
            backendProd = new Set<String>(mapBusinessRules.get('ProductTypeForBackend').Business_Rule_Value__c.split(','));
        }
        
        if (shippingProd.isEmpty() && backendProd.isEmpty())
        	return listCase;
        	
        for(Opportunity_Quote_Line_Item__c oppQline : quoteLineItems){
        	if(oppQline.Line_Item_Type__c != 'Product' || oppQline.sub_type__c == null)
        		continue;
        	if (shippingProd.contains(oppQline.sub_type__c)) {
                mapOfProductType.put('ShippingProducts', true);
            } else if (backendProd.contains(oppQline.sub_type__c)) {
                mapOfProductType.put('BackendProducts', true);
            }
        }
        
        if (mapOfProductType.get('ShippingProducts') && mapBusinessRules.get('ShippingCase') != null) {
		    Case cs = new Case(Opportunity__c = opp.id, AccountId = opp.AccountId, CurrencyIsoCode = opp.CurrencyIsoCode);
		    for (String fieldAndValue : (mapBusinessRules.get('ShippingCase').Business_Rule_Value__c).split(',')) {
		        List<String> fields = fieldAndValue.split('=');
		        cs.put(fields[0], fields[1]);
		    }
		    if (caseTypes.contains(cs.type)) {
		        listCase.add(cs);
		    }
		}
		
		if (mapOfProductType.get('BackendProducts') && mapBusinessRules.get('BackendCase') != null) {
            Case cs = new Case(Opportunity__c = opp.id, AccountId = opp.AccountId, CurrencyIsoCode = opp.CurrencyIsoCode);
            for (String fieldAndValue : (mapBusinessRules.get('BackendCase').Business_Rule_Value__c).split(',')) {
                List<String> fields = fieldAndValue.split('=');
                cs.put(fields[0], fields[1]);
            }
            if (caseTypes.contains(cs.type)) {
                listCase.add(cs);
            }
        }
        
        return listCase;
        
	}
  	
/************************************* BACKEND SHIPPING CASE METHODS END *******************************************/  

/************************************* CHILD RECORDS TERMINATION PROCESS METHODS START *************************************/
	
	/**
	* @Description: Terminate child records on closed lost
				@Process			: child record termination process
	  			@Business Config	: NONE
	  			@Input Params		: Opportunity record with child records
      			@Return				: list of SOBject (Cases, brandings, assets,opp quotes and add-on services)
      			@TriggerContext		: After Update
	*/
	public static List<SObject> terminateOpportunityChildRecordsOnLost(Opportunity opp){
        List<SObject> sobjectList = new List<SObject>();
        
        for (Case c : opp.cases__r) {
            c.status='Closed';
            c.closed_reason__C='Opportunity Lost';
            sobjectList.add(c);
        }
        for(branding_content__c b:opp.branding_content__r){
            b.status__c='Canceled';
            if(b.Installation_Date__c!=null)
                b.status__c='Uninstalled';
            sobjectList.add(b);
        }
        for(Asset__C a:opp.Assets__r){
            a.status__c='Canceled';
            sobjectList.add(a);
        }
        for(Opportunity_quote__c a:opp.Opportunity_Quotes__r){
            a.status__c='Declined';
            sobjectList.add(a);
        }
        for(Add_On_Service__c a:opp.add_on_services__r){
            a.status__c='Canceled';
            sobjectList.add(a);
        }
		for(Shipment_Order__c shi:opp.Shipment_Orders__r){
            if(String.IsBlank(shi.Tracking_Number__c)){
                shi.status__c='Canceled';
                sobjectList.add(shi);
            }
		}
                
        return sobjectList;
    }	

/************************************* CHILD RECORDS TERMINATION PROCESS METHODS END *************************************/  

/************************************* QUOTE ATTACHMENT INSERTION METHODS START *************************************/
	/**
	  * @Description: This method shortlists all the opportunities for which quotes attachments have to be inserted
	  			@Process			: Quote attachment insertion process
	  			@Business Config	: QuoteAttachOnOpp
	  			@Input Params		: List of updated opps, Map of opps before updation
      			@Return				: VOID
      			@TriggerContext		: After Update
      			
      	NOTE: This method uses pageReference.getContent() hence future method is used.
  	*/
  	public static void insertQuoteAttOnOppWon(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){
  		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('QuoteAttachOnOpp');
	    List<Opportunity> newOpps  										= (List<Opportunity>)sobjects;
      	Map<Id,Opportunity> oldMap										= (Map<Id,Opportunity>)oldSobjectMap;
	    Set<Id> oppIds													= new Set<Id>();
	   
	   if(mapBusinessLogic==null || mapBusinessLogic.isEmpty())
	   	    return;
	   
	   for(opportunity o:newOpps){
          if(o.stagename=='Closed Won' && o.stagename!=oldmap.get(o.id).stagename){
              Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(o.RecordTypeId));
              if(mapBusinessRules!=null && !mapBusinessRules.isEmpty() && 
              	 Boolean.valueof(mapBusinessRules.get('SaveQuotesOnClosedWon').Business_Rule_Value__c))
                  oppIds.add(o.id);
          }
       }
       
       if(oppIds.size() > 0)
       		insertattachments(oppIds);
  	}

	/**
	  * @Description: This method creates the attachments record
	  			@Process			: Quote attachment insertion process
	  			@Business Config	: QuoteAttachOnOpp
	  			@Input Params		: Opportunity record,Opportunity quot
      			@Return				: VOID
  	*/
    @Future(callout=true)
    public static void insertattachments(Set<ID> oppLst){
          List<Attachment> attchLst = new List<Attachment>();
          for(Opportunity_Quote__c oq:[SELECT id,id_opportunity__c,name 
          								FROM opportunity_quote__c 
          								WHERE id_opportunity__c=:oppLst 
          									AND status__c='Accepted']){
              if(!Test.isRunningTest()){
                  Attachment att = new Attachment();
                  PageReference pdfQuote = new PageReference('/apex/RenderQuoteAsPDF?id=' + oq.id);
                  Blob myBlob ;
                  att.body = pdfQuote.getContent();
                  att.parentid=oq.id_opportunity__c;
                  att.name=oq.name;
                  att.ContentType='application/pdf';
                  attchLst.add(att);
	          }
	      }
	      insert attchLst;
    }
/************************************* QUOTE ATTACHMENT INSERTION METHODS END *************************************/

/************************************* PLATFORM RECORD CREATION PROCESS METHODS START *************************************/
	/**
	  * @Description: This method shortlists all the opportunities valid for the creation of platform records
	  			@Process			: platform creation process
	  			@Business Config	: PlatformRecordOnQC
	  			@Input Params		: List of updated opps, Map of opps before updation
      			@Return				: Shortlisted Opportunity Map
      			@TriggerContext		: After Update
  	*/
  	public static Map<Id, Opportunity> shortListOppsForplatformCreation(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){
  		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('PlatformRecordOnQC');
	    List<Opportunity> newOpps  										= (List<Opportunity>)sobjects;
      	Map<Id,Opportunity> oldMap										= (Map<Id,Opportunity>)oldSobjectMap;
	    Map<Id, Opportunity> oppMap 									= new Map<Id, Opportunity>();
	    
	    if(mapBusinessLogic==null || mapBusinessLogic.isEmpty())
	   	    return oppMap;
	   	    
   	    for(Opportunity o: newOpps){
             Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(o.RecordTypeId));
             if(o.stagename == oldmap.get(o.id).stagename	||
             	mapBusinessRules ==null 					|| 
             	mapBusinessRules.isempty()					||
             	!mapBusinessRules.get('StageName').Business_Rule_Value__c.containsignorecase(o.stagename))
             		continue;

             oppMap.put(o.Id,o);      
         }
         
         return oppMap;
         
  	}
  	
  	/**
	* @Description: Create platforms
				@Process			: platform creation process
	  			@Business Config	: PlatformRecordOnQC
	  			@Input Params		: Opportunity record, Quote line items , Account record
      			@Return				: list of SOBject (Cases)
      			@TriggerContext		: After Update
	*/
	public static List<SObject> createPlatforms(Opportunity opp,List<Opportunity_Quote_Line_item__c> quoteLineItems, 
													Account account){
		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('PlatformRecordOnQC');
		Map<String, Business_Config__c> mapBusinessRules                = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
		Integer accPlt								= Integer.valueof(mapBusinessRules.get('TotalPlatforms').Business_Rule_Value__c);
		Map<ID,Set<String>> accWithPlatforms 		= new Map<ID,Set<String>>();
		List<Platform_Performance__c> lstPlatform 	= new List<Platform_Performance__c>();
        Set<String> setPlatformToBeCreated 			= new Set<String>();
        Map<String,String> platformsAvailable 
           		= (Map<String, String>)JSON.deserialize(mapBusinessRules.get('Platforms').Business_Rule_Value__c, Map<String, String>.class);
		set<string> stExclude = new set<string>();
		if( mapBusinessRules.get('ExcludeType') != null){
			stExclude = new set<String> (mapBusinessRules.get('ExcludeType').Business_Rule_Value__c.split(','));
			if(stExclude.contains(account.Type)) {
				return lstPlatform;
			}
		}


		if(account.Platforms_Performance__r!=null && !account.Platforms_Performance__r.isEmpty()){
             if(account.Platforms_Performance__r.size() < accPlt){
                 for(Platform_Performance__c platform : account.Platforms_Performance__r){
                     if(!accWithPlatforms.containskey(account.id)){
                         accWithPlatforms.put(account.id,new Set<String>{platform.name});
                     }
                     accWithPlatforms.get(account.id).add(platform.name);
                 }
             }
         }else{
                 accWithPlatforms.put(account.id,null);
         }
         
         if(quoteLineItems == null)
         	return lstPlatform;
         
         for(Opportunity_Quote_Line_Item__C oq: quoteLineItems){
      		if(oq.line_item_Type__c != 'service' || oq.Id_Opportunity_Quote__r.status__c != 'Accepted')
      			continue;

             if(accWithPlatforms.containskey(oq.id_opportunity__r.accountid)){
	             if(accWithPlatforms.get(oq.id_opportunity__r.accountid)==null){
	                 if(!setPlatformToBeCreated.contains(oq.id_list_Service_price__r.company__r.name)
	                     && platformsAvailable.containskey(oq.id_list_Service_price__r.company__r.name)){
	                     	Platform_Performance__c p = new Platform_Performance__c(
	                         								name=oq.id_list_Service_price__r.company__r.name,
	                         								Platform__c=platformsAvailable.get(oq.id_list_Service_price__r.company__r.name),
	                         								Account__c=oq.id_opportunity__r.accountid);
	                     	lstPlatform.add(p);
	                     	setPlatformToBeCreated.add(p.name);
	                 }
	             }else{
	                 if(platformsAvailable.containskey(oq.id_list_Service_price__r.company__r.name) && 
	                 	!setPlatformToBeCreated.contains(oq.id_list_Service_price__r.company__r.name)
	                     && !accWithPlatforms.get(oq.id_opportunity__r.accountid).contains(oq.id_list_Service_price__r.company__r.name)){
	                     Platform_Performance__c p = new Platform_Performance__c(
							                         name=oq.id_list_Service_price__r.company__r.name,
							                         Platform__c=platformsAvailable.get(oq.id_list_Service_price__r.company__r.name),
							                         Account__c=oq.id_opportunity__r.accountid);
	                     lstPlatform.add(p);
	                     setPlatformToBeCreated.add(p.name);
	                 }
	
	             }
             }
		}
		
		return lstPlatform;
			
	}
		
/************************************* PLATFORM RECORD CREATION PROCESS METHODS END *************************************/

/******************************************* CONTRACT PROCESS METHODS START *********************************************/
	/**
	  * @Description: This method shortlists all the opportunities valid for contract process
	  			@Process			: contract process (Creation of Assets, Contracts and additional charges)
	  			@Business Config	: Opportunity Contract Process
	  			@Input Params		: List of updated opps, Map of opps before updation
      			@Return				: Shortlisted Opportunity Map
      			@TriggerContext		: After Update
  	*/
  	public static Map<Id, Opportunity> shortListOppsForContractProcess(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){
  		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('Opportunity Contract Process');
	    List<Opportunity> newOpps  										= (List<Opportunity>)sobjects;
      	Map<Id,Opportunity> oldMap										= (Map<Id,Opportunity>)oldSobjectMap;
	    Map<Id, Opportunity> oppMap 									= new Map<Id, Opportunity>();
	    
	    if(mapBusinessLogic==null || mapBusinessLogic.isEmpty())
	   	    return oppMap;
	   	    
   	    for(Opportunity opp: newOpps){

            Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
            if (mapBusinessRules == null || mapBusinessRules.isEmpty())
            	continue; 
            if (mapBusinessRules.get('opportunity stage') != null && 
            	mapBusinessRules.get('opportunity stage').Business_Rule_Value__c == opp.StageName && oldMap.get(opp.id).StageName != opp.StageName) {
                	oppMap.put(opp.id,opp);
            }
            
         }
         
         return oppMap;         
  	}
  	
  	
  	/**
	  * @Description: This method creates contracts, additional charges and assets related to the opportunity
	  			@Process			: contract process (Creation of Assets, Contracts and additional charges)
	  			@Business Config	: Opportunity Contract Process
	  			@Input Params		: Opportunity record
      			@Return				: VOID
      			@TriggerContext		: After Update
      			
      	NOTE: this method performs bulk creation of contracts,assets,add ons and additional charges
  	*/
  	public static void createRelatedRecords(Map<Id,Opportunity> oppMap,
  											Map<String,List<Opportunity_Quote_Line_Item__c>> quoteLineItemsMap){
		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('Opportunity Contract Process');
		Map<Id, Account> updateNonContractAccount 						= new Map<Id, Account>();
		List<Asset__c> listProcessAssetForAddCharge 					= new List<Asset__c>();
		List<Asset__c> listAssets 										= new List<Asset__c>();
		List<Additional_Charges__c> listAdditional 						= new List<Additional_Charges__c>();
		List<Branding_Content__c> listBranding 							= new List<Branding_Content__c>();
		List<ContractTierWrapper> contractTierWrapperList 				= new List<ContractTierWrapper>();
		List<opportunity_quote_line_item__c> addOnLineItems 			= new List<opportunity_quote_line_item__c>();
		Map<Id, Opportunity_Quote_Line_Item__c> mapOppQuoteProd 		= new Map<Id, Opportunity_Quote_Line_Item__c>();
		
		for(Opportunity opp : oppMap.values()){
			Map<String, Business_Config__c> mapBusinessRules  = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
			 
			if(quoteLineItemsMap.get(opp.Id) ==  null)
				continue;
			
			for (Opportunity_Quote_Line_Item__c oppQlineItem : quoteLineItemsMap.get(opp.Id)){
				if(oppQlineItem.Id_Opportunity_Quote__r.status__c != 'Accepted')
					continue;
				
				if(oppQlineItem.Line_Item_Type__c == 'Service'){
					contractTierWrapperList.add(createContract(oppQlineItem,mapBusinessRules,updateNonContractAccount));
				}else if(oppQlineItem.line_item_type__c=='AddOn' ){
                  if (oppQlineItem.Add_on_Services__r == null || oppQlineItem.Add_on_Services__r.isEmpty())
                    	addOnLineItems.add(oppQlineItem);
				}else if (oppQlineItem.Line_Item_Type__c == 'Product') {
					mapOppQuoteProd.put(oppQlineItem.Id, oppQlineItem);
					// Create Assets
					if (oppQlineItem.Id_List_Product_Price__r.Requires_Asset__c ) {
						createAsset(oppQlineItem,listProcessAssetForAddCharge,listAssets,mapBusinessRules);
					}
	                // Create additional charges (Exluding assets)
	                if(oppQlineItem.Id_List_Product_Price__r.Requires_Additional_Charge__c && 
	                	!oppQlineItem.Id_List_Product_Price__r.Requires_Asset__c) {
                	        createAdditionalCharge(oppQlineItem,listAdditional,mapBusinessRules); 
                    }
                    // Create Branding
                    if (oppQlineItem.Id_List_Product_Price__r.Requires_Branding__c
							&& oppQlineItem.Delivery__c != 'Shipment') {
                    	LibHelper.createBrandingRecord(oppQlineItem,listBranding,mapBusinessRules,null);
                    }  
				}
			}
		}
		
		// Create add ons
		if(!addOnLineItems.isempty())
            LibHelper.createAddOn(addOnLineItems);
            
        // insert contracts and tiers
        insertContractsAndTiers(contractTierWrapperList);
        
        /*
        	Activate the contracts.
        	NOTE: Contracts cannot be activated at the time of creation. contracts has to be activated seperately.
        */
        activateContracts(contractTierWrapperList);
        
         // insert assets
        if(listAssets.size() > 0){
        	insert listAssets;
        	listProcessAssetForAddCharge.addAll(listAssets);
        }
        
        // create additional charges from the assets
        if(listProcessAssetForAddCharge.size() > 0){
            createAdditionalChargesFromAssets(listProcessAssetForAddCharge,listAdditional,mapOppQuoteProd,mapBusinessLogic);
        }
        //insert Branding;
        if(listBranding.size() > 0)
        	insert listBranding;
       	
       	//Insert additional charges
       	if(listAdditional.size() > 0)
       		insert listAdditional;
       		
        //if the noncontracted account is given contract then the Account becames contracted
        if (!updateNonContractAccount.isEmpty()) {
            update updateNonContractAccount.values();
        }
	}
	
	/**
	  * @Description: This method creates the wrapper of contract and the child tiers
	  			@Process			: contract process (Creation of Assets, Contracts and additional charges)
	  			@Business Config	: Opportunity Contract Process
	  			@Input Params		: service quote line item, busines rules, and account map for updating non contracted account
      			@Return				: ContractTierWrapper
  	*/
	public static ContractTierWrapper createContract(Opportunity_Quote_line_item__c oppQlineItem,
														Map<String,Business_Config__c> mapBusinessRules,
														Map<Id, Account> updateNonContractAccount){
		ContractTierWrapper wrapper = new contractTierWrapper();
		Id ownerId 					= oppQlineItem.Id_Opportunity__r.OwnerId;
	    Id oppId 					= oppQlineItem.Id_Opportunity__c;
	    Id accId 					= oppQlineItem.Id_Opportunity__r.AccountId;
	    Boolean donotAutoActivate	= false;
		integer gapDayFirstCommision;
		Date newStartDate;
															
		if (updateNonContractAccount.get(oppQlineItem.Id_Opportunity__r.AccountId) == null && 
			oppQlineItem.Id_Opportunity__r.Account.Non_Contracted__c == true) {
            	updateNonContractAccount.put(oppQlineItem.Id_Opportunity__r.AccountId, 
            				new Account(id = oppQlineItem.Id_Opportunity__r.AccountId, Non_Contracted__c = false));
        }

        Contract contr 							= new Contract();
        contr.AccountId  						= accId;
        contr.Id_Opportunity_Quote_Line_Item__c = oppQlineItem.id;
        contr.Id_Opportunity__c 				= oppId;
        contr.Online_Payment_Fee__c 			= oppQlineItem.Online_Payment_Fee__c;
        contr.Id_Opportunity_Quote__c 			= oppQlineItem.Id_Opportunity_Quote__c;
        contr.Service_Type__c 					= oppQlineItem.Sub_type__c;
        contr.OwnerId 							= ownerId;
        contr.Billable_Account__c 				= oppQlineItem.Billable_Account__c;
        contr.CurrencyIsoCode 					= oppQlineItem.CurrencyIsoCode;
        contr.Name__c 							= oppQlineItem.Name;
        contr.Status 							= 'Draft';  // contract cannot be created with an Activated status.

		gapDayFirstCommision = oppQlineItem.Id_Opportunity__r.Start_Date_uk__c == null? 0 : Date.Today().daysBetween(oppQlineItem.Id_Opportunity__r.Start_Date_uk__c);
		newStartDate = oppQlineItem.Id_Opportunity__r.Time_Based_Tier_Type__c == null && oppQlineItem.Id_Opportunity__r.Business_Type__c == 'New Business'? Date.Today():
						oppQlineItem.Id_Opportunity__r.Time_Based_Tier_Type__c == 'Intervals' && oppQlineItem.Id_Opportunity__r.Start_Date_uk__c > Date.Today() && oppQlineItem.Id_Opportunity__r.Business_Type__c != 'New Business' ? oppQlineItem.Start_Date__c :
						oppQlineItem.Id_Opportunity__r.Time_Based_Tier_Type__c == 'Intervals'? oppQlineItem.Start_Date__c.addDays(-1 * gapDayFirstCommision) :
						oppQlineItem.Start_Date__c < Date.today() && oppQlineItem.End_Date__c < Date.today() ? oppQlineItem.Start_Date__c:
						oppQlineItem.Start_Date__c < Date.today()? Date.Today():
						oppQlineItem.Id_Opportunity__r.Business_Type__c == 'New Business'&& oppQlineItem.Id_Opportunity__r.Start_Date_uk__c == oppQlineItem.Start_Date__c ? Date.Today() :oppQlineItem.Start_Date__c;

		if (mapBusinessRules.get('TimeBaseEnable') != null  && mapBusinessRules.get('TimeBaseEnable').Business_Rule_Value__c== 'TRUE') {
			contr.StartDate = oppQlineItem.Id_Opportunity__r.Schedule_into_the_past__c && oppQlineItem.Id_Opportunity__r.Start_Date_uk__c < Date.Today() ? oppQlineItem.Start_Date__c : newStartDate ;
		}else{
			contr.StartDate = oppQlineItem.Start_Date__c;
		}
		if(mapBusinessRules.get('contract_RecordType') != null){
			contr.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('contract_RecordType').Business_Rule_Value__c);
		}


		contr.Based_On__c =  oppQlineItem.Based_On__c;
		contr.Scaled__c =  oppQlineItem.Scaled__c;
		contr.Commission_Type__c =  oppQlineItem.Commission_Type__c;
	    

	    if (String.isNotblank(string.valueof(oppQlineItem.Commission_In_Percentage__c))) {
	        contr.Commission__c 				= oppQlineItem.Commission_In_Percentage__c;
	    }
	    if (String.isNotblank(string.valueof(oppQlineItem.Recurring_Fee__c))) {
	        contr.Recurring_Fee__c 				= oppQlineItem.Recurring_Fee__c;
	    }
	    if (oppQlineItem.Commission_Per_Order__c != null) {
	        contr.Commission_Per_Order__c 		= oppQlineItem.Commission_Per_Order__c;
	    }
	    
	    if (mapBusinessRules.get('donotAutoActivate') != null ) {
            donotAutoActivate = Boolean.valueof(mapBusinessRules.get('donotAutoActivate').Business_Rule_Value__c);
        }

	    
	    if (oppQlineItem.IsTiered__c) {
	        contr.Min__c = oppQlineItem.Min__c;
	        contr.Max__c = oppQlineItem.Max__c;
	        contr.index__c = oppQlineItem.index__c;
	        contr.IsTiered__c = oppQlineItem.IsTiered__c;
	    }
        if (String.isNotblank(string.valueof(oppQlineItem.End_Date__c))) {

			if (mapBusinessRules.get('TimeBaseEnable') != null  && mapBusinessRules.get('TimeBaseEnable').Business_Rule_Value__c == 'TRUE') {
				contr.End_Date__c = oppQlineItem.Id_Opportunity__r.Schedule_into_the_past__c && oppQlineItem.Id_Opportunity__r.Start_Date_uk__c < Date.Today() ? oppQlineItem.End_Date__c
						: oppQlineItem.Id_Opportunity__r.Time_Based_Tier_Type__c == 'Intervals' && oppQlineItem.Id_Opportunity__r.Start_Date_uk__c > Date.Today() && oppQlineItem.Id_Opportunity__r.Business_Type__c != 'New Business' ? oppQlineItem.End_Date__c
								: oppQlineItem.Id_Opportunity__r.Time_Based_Tier_Type__c == 'Intervals' ? oppQlineItem.End_Date__c.addDays(-1 * gapDayFirstCommision) : oppQlineItem.End_Date__c;
			}else{
				contr.End_Date__c= oppQlineItem.End_Date__c;
			}
		}

		wrapper.contr			= contr;
		wrapper.doNotActivate	= donotAutoActivate;
        // If the line item is scaled then transfer tiers to the contract
        if(oppQlineItem.tiers__r.size() > 0){
        	wrapper.tiers	= oppQlineItem.tiers__r;
        }
		
		return wrapper;
                        
	}
	
	/**
	  * @Description: This method inserts the contracts and the child tier records
	  			@Process			: contract process (Creation of Assets, Contracts and additional charges)
	  			@Business Config	: Opportunity Contract Process
	  			@Input Params		: ContractTierWrapper
      			@Return				: void
  	*/
	public static void insertContractsAndTiers(List<ContractTierWrapper> contractTierWrapperList){
		List<Contract> contarctsToBeInserted = new List<Contract>();
		
		for(ContractTierWrapper wrapper : contractTierWrapperList){
			contarctsToBeInserted.add(wrapper.contr);
		}
		
		if(contarctsToBeInserted.size() == 0)
			return;



		insert contarctsToBeInserted;
		
		// After inserting the contracts update the tiers with the contract Id
        List<Tier__c> tiersToBeUpdated 	= new List<Tier__c>();
        for(ContractTierWrapper wrapper : contractTierWrapperList){
        	if(wrapper.tiers!= null && wrapper.tiers.size() > 0){
        		for(Tier__c tier : wrapper.tiers){
        			tier.Id_Contract__c = wrapper.contr.Id;
        			tiersToBeUpdated.add(tier);
        		}
        	}
        }
        
        if(tiersToBeUpdated.size() > 0){
        	update tiersToBeUpdated;
        }
        
        if (!contarctsToBeInserted.isEmpty()) {
            ClsContractProcessor.preventDuplicateContracts(contarctsToBeInserted);
        }
	}
	
	/**
	  * @Description: This method activates the contract
	  			@Process			: contract process (Creation of Assets, Contracts and additional charges)
	  			@Business Config	: Opportunity Contract Process
	  			@Input Params		: ContractTierWrapper
      			@Return				: void
  	*/
	public static void activateContracts(List<ContractTierWrapper> contractTierWrapperList){
		List<Contract> contarctsToBeUpdated = new List<Contract>();
		Map<String,List<Contract>> mapOfAccountIdContract = new Map<String,List<Contract>>(); //SSC-1982
		Map<String, Map<String, Business_Config__c>> mapBusinessLogicTLife = LibBusinessConfig.motherOfAllBusinessMaps.get('TlifeRevenueModel'); //SSC-1982
		Map<String, Business_Config__c> mapOfContractBusinessConfig =  new Map<String, Business_Config__c>(); //SSC-1982
		
		for(ContractTierWrapper wrapper : contractTierWrapperList){
			Contract contr = wrapper.contr;
            if (!wrapper.doNotActivate){
                contr.Status = Constants.CONTRACT_STATUS_ACTIVATED;
            	contarctsToBeUpdated.add(contr);

				//The below logic is added for SSC-1982 : Tlife Commission
				String contractRecordType = String.isNotBlank(contr.RecordTypeId) ? librecordtypehelper.getRecordTypeDeveloperNameById('Contract',contr.RecordTypeId) : '';
				if(mapBusinessLogicTLife != null && null != mapBusinessLogicTLife.get(contractRecordType)){
					List<Contract> listOfContract = !mapOfAccountIdContract.isEmpty() && mapOfAccountIdContract.get(contr.AccountId) != null ?
							mapOfAccountIdContract.get(contr.AccountId) : new List<Contract>();
					listOfContract.add(contr);
					mapOfContractBusinessConfig = mapBusinessLogicTLife.get(contractRecordType);
					mapOfAccountIdContract.put(contr.AccountId,listOfContract);
				}
				//SSC-1982 : Tlife Commission ends here
            }
		}
		
		
		if(contarctsToBeUpdated.size() > 0)
			update contarctsToBeUpdated;

		//The below logic is added for SSC-1982 : Tlife Commission
		if(!mapOfAccountIdContract.isEmpty() && !mapOfContractBusinessConfig.isEmpty()) {
			updateAccountRevenueModel(mapOfAccountIdContract,mapOfContractBusinessConfig);
		}
		//logic ends here for SSC-1982 : Tlife Commission
	}

	/**
   * @date     : [13/05/2020]
   * @method name  : updateAccountRevenueModel
   * @description  : Logic to update account Revenue Model Field : SSC-1982 Tlife Commission
   * @param  mapOfAccountIdContract Map<String,List<Contract>>
   * @param  mapOfContractBusinessConfig Map<String, Business_Config__c
   *
   */
	public static void updateAccountRevenueModel(Map<String,List<Contract>> mapOfAccountIdContract,
			Map<String, Business_Config__c> mapOfContractBusinessConfig){

		List<Account> accountListUpdate = new List<Account>();
		try {
			List<String> contractServiceTypes = mapOfContractBusinessConfig.get('ContractServiceType').Business_Rule_Value__c.split(',');
			for (Account accountInstance : ClsAccountSelector.getAccountByOppty((Set<Id>)JSON.deserialize(JSON.serialize(mapOfAccountIdContract.keySet()), Set<Id>.class))) {
				Boolean checkServiceType = false;
				String allTypeValues = accountInstance.Revenue_Model__c;
				List<String> typeValuesList = String.isNotBlank(allTypeValues) ? allTypeValues.split(';') : new List<String>();
				for (Contract contractInstance : mapOfAccountIdContract.get(accountInstance.Id)) {
					String commissionServiceType = contractInstance.Service_Type__c;
					if (contractServiceTypes.contains(commissionServiceType) &&
							!typeValuesList.contains(mapOfContractBusinessConfig.get(commissionServiceType).Business_Rule_Value__c)) {
						checkServiceType = true;
						typeValuesList.add(mapOfContractBusinessConfig.get(commissionServiceType).Business_Rule_Value__c);
						accountInstance.Revenue_Model__c = String.join(typeValuesList, ';');
					}
				}
				if (checkServiceType) {
					accountListUpdate.add(accountInstance);
				}
			}
			if (!accountListUpdate.isEmpty()) {
				Database.update(accountListUpdate,false);
			}
		}catch (Exception ex) { ClsLogErrorMessage.logMessages(ERROR_UPDATE_ACCOUNT_FAILED,METHOD_UPDATE_ACCOUNT_ADDRESS + ex.getMessage() + ex.getStackTraceString());
		}
	}
	
	/**
	  * @Description: This method creates the assets
	  			@Process			: contract process (Creation of Assets, Contracts and additional charges)
	  			@Business Config	: Opportunity Contract Process
	  			@Input Params		: quote line item, list of assets for which add charge will be created, list of assets
	  								  in which created assets will be added, business rules
      			@Return				: void
  	*/
	public static void createAsset(Opportunity_Quote_line_item__c oppQlineItem,List<Asset__c> listProcessAssetForAddCharge,
									List<Asset__c> listAssets,Map<String,Business_Config__c> mapBusinessRules){
		Id ownerId 					= oppQlineItem.Id_Opportunity__r.OwnerId;
	    Id oppId 					= oppQlineItem.Id_Opportunity__c;
	    Id accId 					= oppQlineItem.Id_Opportunity__r.AccountId;
	    
		if ((oppQlineItem.Assets__r == null || oppQlineItem.Assets__r.isEmpty()) && oppQlineItem.Delivery__c != 'Shipment') {

            for (integer i = 1; i <= oppQlineItem.Quantity__c; i++  ) {
                Asset__c newAsset 							= new Asset__c();
                newAsset.OwnerId 							= ownerId;
                newAsset.name 								= oppQlineItem.name;
                newAsset.Account__c 						= accId;
                newAsset.CurrencyIsoCode 					= oppQlineItem.CurrencyIsoCode;
                newAsset.Id_Opportunity_Quote_Line_Item__c 	= oppQlineItem.Id;
                newAsset.Opportunity__c 					= oppId;
                newAsset.Status__c 							= mapBusinessRules.get('AssetStatus').Business_Rule_Value__c;
                newAsset.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('Asset RecordType').Business_Rule_Value__c);
                listAssets.add(newAsset);
            }
        } else {
        	for(Asset__c asset : oppQlineItem.Assets__r){
        		if(asset.retour_date__c == null){
            		listProcessAssetForAddCharge.add(asset);
        		}
        	}
        }
	}
	
	/**
	  * @Description: This method inserts the additional charges records
	  			@Process			: contract process (Creation of Assets, Contracts and additional charges)
	  			@Business Config	: Opportunity Contract Process
	  			@Input Params		: quote line item, list of additional charges to add newly created add charges, business rules
      			@Return				: void
  	*/
	public static void createAdditionalCharge(Opportunity_Quote_line_item__c oppQlineItem,
												List<Additional_Charges__c> listAdditional,
												Map<String,Business_Config__c> mapBusinessRules){
		Id ownerId 					= oppQlineItem.Id_Opportunity__r.OwnerId;
	    Id oppId 					= oppQlineItem.Id_Opportunity__c;
	    Id accId 					= oppQlineItem.Id_Opportunity__r.AccountId;

	    
	    //create all other Additional Charge except for Asset
        Additional_Charges__c add1 				= new Additional_Charges__c();
        add1.Has_Related_Tarif__c 				= oppQlineItem.Has_Related_Tarif__c;
        add1.Id_List_Product_Price__c 			= oppQlineItem.Id_List_Product_Price__c;
        add1.Installments__c 					= oppQlineItem.Installments__c;
        add1.Listed_Price__c 					= oppQlineItem.Listed_Price__c;
        add1.Id_Opportunity_Quote__c 			= oppQlineItem.Id_Opportunity_Quote__c;
        add1.Product_Group__c 					= oppQlineItem.Product_Group__c;
        add1.product__c 						= oppQlineItem.name;
        add1.Quantity__c 						= oppQlineItem.Quantity__c;
        add1.CurrencyIsoCode 					= oppQlineItem.CurrencyIsoCode;
        add1.Rabbat__c 							= oppQlineItem.Discount__c;
        add1.Total_Amount__c 					= oppQlineItem.Total_Amount__c;
        add1.Id_Account__c 						= accId;
        add1.Id_Opportunity__c 					= oppId;
        add1.Id_Opportunity_Quote_Line_Item__c 	= oppQlineItem.id;
        add1.Category__c 						= oppQlineItem.Category__c;
        add1.Category_Id__c 					= oppQlineItem.Category_Id__c;
        add1.District__c 						= oppQlineItem.District__c;
        add1.District_Id__c 					= oppQlineItem.District_Id__c;
        add1.Type__c 							= oppQlineItem.Sub_type__c;
        add1.Position__c 						= oppQlineItem.Position__c;
        add1.Booking_Api_Id__c 					= oppQlineItem.Booking_Api_Id__c;
        add1.City_ZipCode__c 					= oppQlineItem.City_ZipCode__c;
        add1.Id_Replacement_Order__c 			= oppQlineItem.Id_Replacement_Order__c;
		add1.Billable_Account__c				= oppQlineItem.Billable_Account__c;
        add1.Termination_Date__c 				= oppQlineItem.End_Date__c;
        add1.specifications__c					= oppQlineItem.specifications__c;
        add1.recordTypeId 						= LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('AdditionalCharges RecordType').Business_Rule_Value__c);
		add1.Unit_Cost__c 						= oppQlineItem.Unit_Cost__c;
		add1.Interval__c 						= oppQlineItem.Interval__c;
		add1.Sub_Product_Name__c 				= oppQlineItem.Sub_Product_Name__c;
		add1.Budget__c 							= oppQlineItem.Budget__c;
		// SSC-1220 Changes: Starts Here
		if (add1.Budget__c != null && add1.Unit_Cost__c != null) {
			if(mapBusinessRules.containsKey('setAdditionalChargesStatus')
					&& mapBusinessRules.get('setAdditionalChargesStatus').Business_Rule_Value__c.contains(oppQLineItem.name)){
				add1.Status__c = setMarketingPackageAddtnlChargeStatus(mapBusinessRules);
			}
			else{
				add1.Status__c = Constants.ADD_CHARGES_STATUS_DRAFT; // Adding values in Constant Class
			}

		}
		// SSC-1220 Changes Ends Here
        if (mapBusinessRules.get('startDateIsOppCloseDate') != null && 
        	Boolean.valueOf(mapBusinessRules.get('startDateIsOppCloseDate').Business_Rule_Value__c)) {
            	// SSC-1528: DefectFix Starts Here
		if(mapBusinessRules.containsKey('skipEffectiveStartDateForPremiumRenewalProduct')
				&& mapBusinessRules.get('skipEffectiveStartDateForPremiumRenewalProduct').Business_Rule_Value__c.contains(oppQLineItem.name)){
			add1.Start_Date__c = oppQLineItem.Start_Date__c;
		}
		else{
			add1.Start_Date__c = oppQLineItem.Id_Opportunity__r.CloseDate;
		} // SSC-1528: DefectFix Ends Here
        } else if (oppQlineItem.Start_Date__c != null) {
            add1.Start_Date__c = oppQlineItem.Start_Date__c <= Date.today() ? Date.today() :  oppQlineItem.Start_Date__c;
        } else {
            add1.Start_Date__c = Date.today();
        }
        
        listAdditional.add(add1);
	}
	
	/**
	  * @Description: This method creates additional charges records from the assets
	  			@Process			: contract process (Creation of Assets, Contracts and additional charges)
	  			@Business Config	: Opportunity Contract Process
	  			@Input Params		: list of assets for which add charges has to be created, list of additional charges
	  								  to add new add charges, map of quote line item it and quote line item, business rules
      			@Return				: void
  	*/
	public static void createAdditionalChargesFromAssets(List<Asset__c> listProcessAssetForAddCharge,
														 List<Additional_Charges__c> listAdditional,
														 Map<Id, Opportunity_Quote_Line_Item__c> mapOppQuoteProd,
														 Map<String, Map<String, Business_Config__c>> mapBusinessLogic){
		
		for (Asset__c asst : listProcessAssetForAddCharge) {
		    Opportunity_Quote_line_item__c oppQlineItem         = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c);
            Id oppId 									        = oppQLineItem.Id_Opportunity__c;
            Map<String, Business_Config__c> mapBusinessRules    = mapBusinessLogic.get(oppQlineItem.Id_Opportunity__r.RecordType.DeveloperName);
		    Decimal totalCalculated 					        = calculateTotal(oppQlineItem.Listed_Price__c, oppQLineItem.Discount__c);
	        Additional_Charges__c add1 				= new Additional_Charges__c();
	        add1.Has_Related_Tarif__c 				= oppQLineItem.Has_Related_Tarif__c;
	        add1.Id_List_Product_Price__c 			= oppQLineItem.Id_List_Product_Price__c;
	        add1.Installments__c 					= oppQLineItem.Installments__c;
	        add1.Listed_Price__c 					= oppQLineItem.Listed_Price__c;
	        add1.Id_Opportunity_Quote__c 			= oppQLineItem.Id_Opportunity_Quote__c;
	        add1.Product_Group__c 					= oppQLineItem.Product_Group__c;
	        add1.product__c 						= oppQLineItem.name;
	        add1.Quantity__c 						= 1;
	        add1.CurrencyIsoCode 					= oppQLineItem.CurrencyIsoCode;
	        add1.Rabbat__c 							= oppQLineItem.Discount__c;
	        add1.Total_Amount__c 					= oppQlineItem.Budget__c != null && oppQlineItem.Unit_Cost__c != null ? oppQLineItem.Total_Amount__c : totalCalculated;
	        add1.recordTypeId 						= LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('AdditionalCharges RecordType').Business_Rule_Value__c);
	        add1.Id_Account__c 						= oppQLineItem.Id_Opportunity__r.AccountId;
	        add1.Id_Opportunity__c 					= oppId;
	        add1.Id_Asset__c 						= asst.id;
	        add1.Id_Opportunity_Quote_Line_Item__c 	= asst.Id_Opportunity_Quote_Line_Item__c;
	        add1.Type__c 							= oppQLineItem.Sub_type__c;
	        add1.Id_Replacement_Order__c 			= oppQLineItem.Id_Replacement_Order__c;
	        add1.Billable_Account__c				= oppQLineItem.Billable_Account__c;
	        add1.specifications__c					= oppQlineItem.specifications__c;
			add1.Unit_Cost__c 						= oppQlineItem.Unit_Cost__c;
			add1.Interval__c 						= oppQlineItem.Interval__c;
			add1.Sub_Product_Name__c				= oppQlineItem.Sub_Product_Name__c;
			add1.Budget__c 							= oppQlineItem.Budget__c;
			if (add1.Budget__c != null && add1.Unit_Cost__c != null) {
				add1.Status__c = 'Draft';
			}
	        if (mapBusinessRules.get('startDateIsOppCloseDate') != null && Boolean.valueOf(mapBusinessRules.get('startDateIsOppCloseDate').Business_Rule_Value__c)) {
	            	// SSC-1528: DefectFix Starts Here
			if(mapBusinessRules.containsKey('skipEffectiveStartDateForPremiumRenewalProduct')
					&& mapBusinessRules.get('skipEffectiveStartDateForPremiumRenewalProduct').Business_Rule_Value__c.contains(oppQLineItem.name)){
				add1.Start_Date__c = oppQLineItem.Start_Date__c;
			}
			else{
				add1.Start_Date__c = oppQLineItem.Id_Opportunity__r.CloseDate;
			} // SSC-1528: DefectFix Ends Here
	        } else if (oppQLineItem.Start_Date__c != null) {
	            add1.Start_Date__c = oppQLineItem.Start_Date__c;
	        } else {
	            add1.Start_Date__c = Date.today();
	        }
	        
	        listAdditional.add(add1);
		}
       
	}
	
	/**
	  * @Description: This method calculates the total based on list price and discounr
	  			@Process			: contract process (Creation of Assets, Contracts and additional charges)
	  			@Input Params		: list price, discount
      			@Return				: decimal (total)
  	*/
	public static Decimal calculateTotal(Decimal listPrice, String discountStr) {
        Decimal total;
        Decimal totalResult;
        List<String> discountInPercent = new List<String>();
        if (discountStr != null && discountStr.length() > 0) {
            if (discountStr.indexOf('%') > -1) {
                discountInPercent = discountStr.split('%');
                Decimal discount = listPrice * (Decimal.valueOf(discountInPercent[0]) / 100);
                total = listPrice - discount;
            } else {
                total = listPrice - Decimal.valueOf(discountStr);
            }
        } else {
            total = listPrice;
        }
        totalResult = total.setScale(2);

        return totalResult;
    }
	  	
  	/**
	  * @Description: This wrapper class is a container for the contract and the child tiers. Wrapper is used to create
	  				  relationship between the contracts and their child tiers
  	*/
  	public class ContractTierWrapper{
    	public contract contr;
    	public List<Tier__c> tiers;
    	public Boolean doNotActivate;
    	
    	public ContractTierWrapper(){
    		tiers = new List<Tier__c>();
    	}
    }
  	
/******************************************* CONTRACT PROCESS METHODS END *********************************************/

/************************************************** VALIDATIONS START *************************************************/

	/**
	  * @Description: This method validates the opportunity stage
	  			@Process			: validation
	  			@Business Config	: validateClosedOpportunity
	  			@Input Params		: Opportunity records, Opportunity oold record before update
      			@Return				: void
      			@TriggerContext		: Before Update
      			
  	*/
  	public static Boolean validateOpportunityStage(Opportunity opp,Opportunity oldRecord,Boolean isPremiumPlacement,
  													List<Case> cases){
  		Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('validateClosedOpportunity');
  		
  		if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) {
            return true;
        }
        
        Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
        if (mapBusinessRule == null || mapBusinessRule.isEmpty())
                return true;
        
  		if (mapBusinessRule.get('statusMap') != null) {
            Set<string> notAllowedStatus 	= new set <string>();
            Map<String, String> theMap 		= (Map<String, String>)JSON.deserialize(mapBusinessRule.get('statusMap').Business_Rule_Value__c, Map<String, String>.class);

	        if (theMap.containskey(oldRecord.stageName)) {
	            notAllowedStatus = new set<String>(theMap.get(oldRecord.stageName).split(';'));
	            if (notAllowedStatus.contains(opp.stageName) 								&& 
	            	(opp.type != 'Product Only' || oldRecord.stageName != 'Quality Check Request')  && 
	            	!ClsCaseProcessor.donotValidateOppStage 								&& 
	            	!isPremiumPlacement && !BookingServiceHandler.doNotCreateCase) {
		                opp.addError(Label.Opportunity_Stage_Update + ' ' + opp.stageName);
		                return false;
	            }
	        }
	    }
	    
	    if(!checkForSuccessfullCaseType(cases,'Quality Check','Successful',null) && opp.stageName == 'Editorial Queue'
             && opp.type != 'Product Only'){
             opp.addError(Label.Opportunity_QC_Validation);
             return false;	
        }
	    
	    if(!checkForSuccessfullCaseType(cases,'Menu Processing','Take Online',null) && opp.type != 'Product Only'
              && opp.stageName == 'Onboarding' && !ClsRemoteController.chkAcceptQuote){
	    	opp.addError(Label.Opportunity_MP_Validation);
	    	return false;
	    }
	    
	    
	    return true;
  	}

	/**
	  * @Description: This method validates the opportunity stage for the opp without accepted quote 
	  			@Process			: validation
	  			@Business Config	: validateClosedOpportunity
	  			@Input Params		: Opportunity records, Opportunity oold record before update
      			@Return				: void
      			@TriggerContext		: Before Insert.Before Update
  	*/
  	public static Boolean validateOpportunityStageWithoutQuote(Opportunity opp,Boolean hasAcceptedQuote){
  		Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('validateClosedOpportunity');
  		
  		if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) {
            return true;
        }
        
        Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
        if (mapBusinessRule == null || mapBusinessRule.isEmpty())
                return true;
        
         if (!hasAcceptedQuote && !ClsRemoteController.chkAcceptQuote  && !ClsCaseProcessor.donotValidateOppStage){
            if (mapBusinessRule.get('notAllowedWithoutAcceptQuote') != null ) {
                Set<string> notAllowedStages = new set<String>(mapBusinessRule.get('notAllowedWithoutAcceptQuote').Business_Rule_Value__c.split(','));
                if (notAllowedStages.contains(opp.stageName)) {
                    opp.addError(Label.Opportunity_Stage_Update + ' ' + opp.stageName);
                    return false;
                }
            }
         }
         
         return true;
  	}

	/**
	* @Description: This method checks for duplicate New Business opportunity
		@InputParam		: Opportunity record
		@BusinessConfig	: validateClosedOpportunity
		@TriggerContext	: Before Insert/Update
	*/
	public static void checkduplicateNewBusinessValidation(Opportunity opp,List<Opportunity> listAllOpps){
		Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('validateClosedOpportunity');

		if(mapBusinessLogic == null || mapBusinessLogic.isEmpty())
			return;

		Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));

		if (mapBusinessRules == null || mapBusinessRules.isEmpty())
			return;

		String stageName ='';
		String businessType ='';
		Boolean showError = false;

		if (mapBusinessRules.containsKey('allowedStageNewBusiness')) {
			stageName = mapBusinessRules.get('allowedStageNewBusiness').Business_Rule_Value__c;
		}

		if (mapBusinessRules.containsKey('BusinessType')) {
			businessType = mapBusinessRules.get('BusinessType').Business_Rule_Value__c;
		}

		if(businessType.equalsIgnoreCase(opp.Business_Type__c)
				&& ( (!stageName.equalsIgnoreCase(opp.stageName) && Trigger.isUpdate) || Trigger.isInsert )){
			if(listAllOpps.size()>0){
				for(Opportunity oppty :listAllOpps){
                    if(oppty.id != opp.id){
                        if(businessType.equalsIgnoreCase(oppty.Business_Type__c) && (!stageName.equalsIgnoreCase(oppty.StageName))) {
                            showError = true;
                        }
					}
				}
			}
		}
		if (showError) {
			opp.addError(Label.Opportunity_DuplicateBusinessType_error);
			showError = false;
		}

	}

	/**
	* @Description: This method checks for the stage name at the time of opportunity creation
		@InputParam		: Opportunity record
		@BusinessConfig	: validateClosedOpportunity	 
		@TriggerContext	: Before Insert
	*/
    public static void checkOppStageOnCreation(Opportunity opp){
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('validateClosedOpportunity');
        
        if(mapBusinessLogic == null || mapBusinessLogic.isEmpty())
        	return;
        
        if (ClsCaseProcessor.donotValidateOppStage) 
        	return;
        		
        set<string> stageNameSet = new Set<string>();
        Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
        
        if (mapBusinessRules == null || mapBusinessRules.isEmpty())
        	return;
        

        if (mapBusinessRules.get('stageNameNotAllowedOnCreation') != null) {
     		stageNameSet = new Set<String>(mapBusinessRules.get('stageNameNotAllowedOnCreation').Business_Rule_Value__c.split(','));       
        }
        if (stageNameSet.contains(opp.stageName)) {
            opp.addError(Label.Opportunity_Initial_Stage + ' ' + opp.stageName);
        }

    }
	
	/**
	  * @Description: This method validates the opportunity on closed won
	  					1. validates for open or unsuccessfull cases (QC,MP,OB,Shipment,BEEntry,BE Setup)
	  					2. validates the inactive brandings
	  					3. validates the inactive assets
	  					4. validates the inactive add-ons
	  					5. validates opp for having an accepted quote based on opportunity types
	  			@Process			: validation
	  			@Business Config	: validateClosedOpportunity
	  			@Input Params		: Opportunity records,cases
      			@Return				: void
      			@TriggerContext		: Before Update
  	*/
  	public static Boolean validateOpportunityOnClosedWon(Opportunity opp,Opportunity completeOpp,List<Case> cases,Boolean hasAcceptedQuote){
  		Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('validateClosedOpportunity');
  		
  		if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) {
            return true;
        }
        
        Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
        if (mapBusinessRule == null || mapBusinessRule.isEmpty())
                return true;
        
        // check for opportunity having an accepeted quote        
        if (opp.type != null && mapBusinessRule.get('OpportunityType') != null && 
        	(mapBusinessRule.get('OpportunityType').Business_Rule_Value__c).contains(opp.type)) {
	            if (!hasAcceptedQuote) {
	                opp.addError(Label.Opportunity_Quote_Validation);
	                return false;
	            }
        }
           

        if (ClsRemoteController.chkAcceptQuote)
        	return true;
        	
		// check for unsuccessfull quality check cases
		if ((mapBusinessRule.containskey('AllowCheckForQCOpen') && 
			Boolean.valueOf(mapBusinessRule.get('AllowCheckForQCOpen').Business_Rule_Value__c)) 
			|| 
			(mapBusinessRule.containskey('CheckForAtleastOnePositiveQC') && 
        	Boolean.valueOf(mapBusinessRule.get('CheckForAtleastOnePositiveQC').Business_Rule_Value__c))) {
            	if(!checkForSuccessfullCaseType(cases,'Quality Check','Successful',null)){
            		opp.addError(Label.Opportunity_QC_Validation);
            		return false;
            	}
        }
		// check for open or unsuccessfull menu processing cases
		if (mapBusinessRule.containskey('checkForMP') && 
			Boolean.valueOf(mapBusinessRule.get('checkForMP').Business_Rule_Value__c)) {
            	if(!checkForSuccessfullCaseType(cases,'Menu Processing','Take Online',null)){
            		if (!ClsCaseProcessor.talabatFlag) {
	            		opp.addError(Label.Opportunity_MP_Validation);
	            		return false;
            		}
            	}
        }
        // check for open or unsuccessfull onboarding cases
        if (mapBusinessRule.containskey('CheckForAtleastOnePositiveOnboarding') && 
        	Boolean.valueOf(mapBusinessRule.get('CheckForAtleastOnePositiveOnboarding').Business_Rule_Value__c)) {
            	if(!checkForSuccessfullCaseType(cases,'Onboarding','Successful','Onboarding')){
            		opp.addError(Label.Opportunity_Onb_Validation);
            		return false;
            	}
        }
		// check for open or unsuccessfull shipment cases
		if (mapBusinessRule.containsKey('checkForShipmentCase') && 
			Boolean.valueOf(mapBusinessRule.get('checkForShipmentCase').Business_Rule_Value__c)) {
            	if(!checkForSuccessfullCaseType(cases,'Shipment','Successful,Take Online',null)){
            		opp.addError(Label.Opportunity_Sh_Validation);
            		return false;
            	}
        }
		// check for open or unsuccessfull setup backend cases
		if (mapBusinessRule.containsKey('checkForSetupBackEndCase') && 
			Boolean.valueOf(mapBusinessRule.get('checkForSetupBackEndCase').Business_Rule_Value__c)) {
            	if(!checkForSuccessfullCaseType(cases,'Setup Backend','Successful,Take Online',null)){
            		opp.addError(Label.Opportunity_StBE_Validation);
            		return false;
            	}
        }
		// check for open or unsuccessfull backend data entry cases
		if (mapBusinessRule.containsKey('checkForBEDataEntryCase') && 
			Boolean.valueOf(mapBusinessRule.get('checkForBEDataEntryCase').Business_Rule_Value__c)) {
            	if(!checkForSuccessfullCaseType(cases,'BE Data Entry','Successful,Take Online',null)){
            		opp.addError(Label.Opportunity_DtEntry_Validation);
            		return false;
            	}	
        }
		// check for any inactive brandings
		if (mapBusinessRule.containskey('CheckForBranding') && 
			Boolean.valueOf(mapBusinessRule.get('CheckForBranding').Business_Rule_Value__c)) {
            	if(!checkForNotInstalledBrandings(completeOpp.branding_content__r)){
            		opp.addError(Label.Opportunity_branding_Validation);
            		return false;
            	}
        }
		// check for any inactive assets
		if (mapBusinessRule.containskey('checkForAsset') && 
			Boolean.valueOf(mapBusinessRule.get('checkForAsset').Business_Rule_Value__c)) {
            	if(!checkForInactiveAssets(completeOpp.assets__r)){
            		opp.addError(Label.Opportunity_Asset_Validation);
            		return false;
            	}
        }
		// check for any inactive add-ons
		if (mapBusinessRule.containsKey('checkForAddon') && 
			Boolean.valueOf(mapBusinessRule.get('checkForAddon').Business_Rule_Value__c)) {
            	if(!checkForInactiveAddOns(completeOpp.add_on_services__r)){
            		opp.addError(Label.Opportunity_Addon_Validation);
            		return false;
            	}
        }
        
        return true;
  	} 
	
	/**
	  * @Description: This method check whether there is a successfully closed case type 
	  			@Process			: validation
	  			@Input Params		: List of cases, case type, successfully closed reason
      			@Return				: Boolean (True if there is a successfull case, false otherwise)
  	*/
	public static Boolean checkForSuccessfullCaseType(List<Case> cases,string caseType,String successfullClosedReason,
													 String caseReason){
			Boolean isSuccessfull = true;
			
			if(cases == null)
				return isSuccessfull;
			
			List<String> successfullClosedReasons = successfullClosedReason.split(',');
			
			for(Case cs : cases){
				If(cs.type != caseType)
					continue;
				
				if(caseReason != null && cs.case_reason__c != caseReason)
					continue;					
					
                if (!cs.isClosed || !successfullClosedReasons.contains(cs.Closed_Reason__c)) {
                    isSuccessfull = false;
                } else if (successfullClosedReasons.contains(cs.Closed_Reason__c)) {
                    isSuccessfull = true;
                    return isSuccessfull;
                }
			}
			
			return isSuccessfull;
	}
	
	/**
	  * @Description: This method check for any brandings which is yet to be installed 
	  			@Process			: validation
	  			@Input Params		: List of brandings
      			@Return				: Boolean (True if all the brandings are installed, false otherwise)
  	*/
	public static Boolean checkForNotInstalledBrandings(List<Branding_Content__c> brandings){
		for (Branding_Content__C b : brandings) {
            if (b.status__c != 'Installed successfully' && b.type__c.containsIgnoreCase('White Label')) {
                return false;
            }
        }
        
        return true;
	}
	
	/**
	  * @Description: This method check for any inactive assets 
	  			@Process			: validation
	  			@Input Params		: List of assets
      			@Return				: Boolean (True if all the assets are active, false otherwise)
  	*/
	public static Boolean checkForInactiveAssets(List<Asset__c> assets){
		for (Asset__c a : assets) {
            if (a.Status__c != 'Activated Successfully' && a.Status__c != 'Replaced'
					&& a.Status__c != 'Returned Shipment' && a.Status__c != 'Return In Progress' && a.retour_date__c == null) {
                return false;
            }
        }
        return true;
	}
	
	/**
	  * @Description: This method check for any inactive add-on
	  			@Process			: validation
	  			@Input Params		: List of add ons
      			@Return				: Boolean (True if all the add ons are active, false otherwise)
  	*/
	public static Boolean checkForInactiveAddOns(List<Add_on_Service__c> addOns){
        for(Add_on_Service__c ao: addons){
            if(ao.status__c!='Active'){
                return false;
            }
        }
		
		return true;
	}
/************************************************** VALIDATIONS END *************************************************/
	/**
	*	@TriggerContext		: Before Insert
	*/
	public static void setDefaultValueForOpportunityQuoteComment(List<Opportunity> opportunities, Boolean isMenuPrinting) {
        ClsQuoteProcessor cqp = new ClsQuoteProcessor();
        cqp.setDefaultValueForOpportunityQuoteComment(opportunities, isMenuPrinting);
    }
    
/********************************************* OPPORTUNITY UPDATE ON ACTIVITIES START ******************************/
	/**
	* @Description: This method updates the opportunity stage whenever there is any acitvities created against the opportunity
					whenever a task is created or an event is created
					1. WHEN logging the call related to the Opp with Activity_Subject__c = "Call - Nobody reached" OR 
    				   "Call - Employee reached" AND the stage is not already at a higher stage
					   THEN opportunity stage automatically goes to "Open"
					2. WHEN logging the call with Activity_Subject__c = "Call - Decision maker reached" AND the stage is not 
					   already at a higher stage THEN opportunity stage automatically goes to "Contact Established"
					3. When creating an event of Type = Meeting AND the stage is not already at a higher stage
					   THEN opportunity stage automatically goes to "Contact Established" 
		@NOTE: This method is called from Task Trigger and Event Trigger
		@inputParams: List of Opp Ids to be queried, List of Tasks, List of Events.
		@BusinessConfig: opportunityUpdateFromTaskProcess
	*/
	public static void updateOpportunityOnActivity(Set<Id> oppIds,List<Task> tasks,List<Event> events){
		Map<Id,Opportunity> oppsToBeUpdated	= new Map<Id,Opportunity>();
		
		if(oppIds.size() == 0 || (tasks == null && events == null))
			return;
		
		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('opportunityUpdateFromTaskProcess');
    	// If no business configs are defined, return
    	if(mapBusinessLogic == null || mapBusinessLogic.isEmpty())
    		return;
		
		Map<String, Business_Config__c> mapBusinessRules = 
	    									mapBusinessLogic.get('Generic_Activity');
		
		if(mapBusinessRules == null || mapBusinessRules.isEmpty())
    			return;
		Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id,Name,StageName,Probability,recordTypeId
    															FROM Opportunity
    															WHERE Id in: oppIds]);
    															
    	List<String> validActivitySubjectsForCEStage 	= mapBusinessRules.get('CEAcitvitySubject').Business_rule_value__c.split(',');
	   	List<String> validActivitySubjectsForOpenStage 	= mapBusinessRules.get('openAcitvitySubject').Business_rule_value__c.split(',');											
    	
    	// Update the opportunities from the events 
    	if(events != null){
    		for(Event evt : events){
	    		Opportunity opp = oppMap.get(evt.whatId);		
	    		if(opp.probability <= Decimal.valueOf(mapBusinessRules.get('requiredProbabilityForCEStage').Business_rule_Value__c) &&
	    			opp.stageName != mapBusinessRules.get('oppContactEstablishedStageName').Business_rule_value__c){
	    				opp.stageName = mapBusinessRules.get('oppContactEstablishedStageName').Business_rule_value__c;
	    				// creating new instance of opportunity as probability should be be updated automatically,
	    				// probability will not be updated if we update the same instance
	    				oppsToBeUpdated.put(opp.Id,new Opportunity(id=opp.Id,stageName = opp.stageName));
	    		}
    		}
    	}
    	// Updat the opportunities from the tasks 
    	if(tasks != null){
	    	for(Task ts : tasks){
	    		Opportunity opp = oppMap.get(ts.whatId);
				// if the current stage is higher than the stage which is supposed to be updated, dont update the opp. 
	    		if(validActivitySubjectsForCEStage.contains(ts.Activity_Subject__c)){
	    			if(opp.probability <= Decimal.valueOf(mapBusinessRules.get('requiredProbabilityForCEStage').Business_rule_Value__c) &&
		    			opp.stageName != mapBusinessRules.get('oppContactEstablishedStageName').Business_rule_value__c){
		    				opp.stageName = mapBusinessRules.get('oppContactEstablishedStageName').Business_rule_value__c;
		    				oppsToBeUpdated.put(opp.Id,new Opportunity(id=opp.Id,stageName = opp.stageName));	
		    		}
	    		}else if(validActivitySubjectsForOpenStage.contains(ts.Activity_Subject__c)){
		    		if(opp.probability <= Decimal.valueOf(mapBusinessRules.get('requiredProbabilityForOpenStage').Business_rule_Value__c) &&
		    			opp.stageName != mapBusinessRules.get('oppOpenStageName').Business_rule_value__c){
		    				opp.stageName = mapBusinessRules.get('oppOpenStageName').Business_rule_value__c;
		    				if(!oppsToBeUpdated.containsKey(opp.Id)){
		    					oppsToBeUpdated.put(opp.Id,new Opportunity(id=opp.Id,stageName = opp.stageName));
		    				}
		    		}
	    		}    		
	    	}
    	}
    	
    	// update the opps
    	if(!oppsToBeUpdated.isEmpty())
    		update oppsToBeUpdated.values();
    	
	}
/********************************************* OPPORTUNITY UPDATE ON ACTIVITIES END ******************************/

/********************************************* CHAIN OPPORTUNITY PROCESS START *****************************************/
	/**
	  * @Description: This method creates child opportunities from the chain opportunities along with the quotes,
	  					opportunity line items and quote line items
	  			@Process			: Chain Opportunity process
	  			@Input Params		: Chain Opportunity, List of accounts for which opportunities are to be created
	  			@BusinessConfig		: Chain Opportunity Process
      			@Return				: VOID
  	*/
  	
  	public static void createChildOpportunities(Id chainOppId,List<Id> accountIds){
  		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('HeadquarterDealProcess');
    	// If no business configs are defined, return
    	if(mapBusinessLogic == null || mapBusinessLogic.isEmpty())
    		return;
		
		Map<String, Business_Config__c> mapBusinessRules = 
	    									mapBusinessLogic.get('Global_Config');
		
		if(mapBusinessRules == null || mapBusinessRules.isEmpty())
    			return;
  		
  		String stageName	= mapBusinessRules.get('childOppStageName').Business_Rule_Value__c;
  		
  		// Do not validate the opp stage for the new opps which will be created as they will be created directly in later stage
  		ClsCaseProcessor.donotValidateOppStage = true;
  		
  		// populate the opportunity wrapper with all the related records
  		OpportunityWrapper chainOppWrapper = poulateOppWrapperWithRelatedRecords(chainOppId);
		
		// extract content document link attached to chain oppty
		String pdfQuoteDocumentTitle = 'Contract - '+chainOppWrapper.quote.Name+'.pdf';
        List<ContentDocumentLink> cdLinkList = ContentVersion_Selector.getContentDocumnetLink(chainOppWrapper.quote.Id, pdfQuoteDocumentTitle);
  		// List of opportunity with the related records which will be populated for each account
  		List<OpportunityWrapper> oppsToBeCreated = new List<OpportunityWrapper>();
  		
  		for(Id accountId : accountIds){
  			// clone the opportunity
  			Opportunity opp		= chainOppWrapper.opp.clone(false,false,false,false);
  			opp.stageName		= stageName;
  			opp.accountId		= accountId;
  			opp.recordTypeId	= LibRecordTypeHelper.getRecordTypeValue(opp.Company_Code__c+'_Opportunity');
  			opp.Parent_Opportunity__c = chainOppWrapper.opp.Id;
  			opp.closeDate		= getQuarterEndDate();
  			opp.sub_deal__c		= true;
  			
			// Clone Content Document Link
			ContentDocumentLink cdLink =  cdLinkList.size()>0 ? cdLinkList[0].clone(false,false,false,false) : null;
  			
			// Clone the Quote 
  			Opportunity_Quote__c quote	= chainOppWrapper.quote.clone(false,false,false,false);
  			quote.recordTypeId 			= LibRecordTypeHelper.getRecordTypeValue(opp.Company_Code__c+'_Opportunity_Quote');
  			quote.Id_Account__c			= accountId;
  			
  			// Clone the line Items
  			List<LineItemWrapper> childLineItemWrapper = new List<LineItemWrapper>();
  			for(LineItemWrapper lineItem: chainOppWrapper.lineItems){
  				Opportunity_Line_Item__c li = lineItem.lineItem.clone(false,false,false,false);
  				li.recordtypeId				= LibRecordTypeHelper.getRecordTypeValue(opp.Company_Code__c+'_Opportunity_Line_Item');
  				List<Tier__c> tiers = new List<Tier__c>();
  				for(Tier__c tr: lineitem.lineitem.tiers__r){
  					tiers.add(tr.clone(false,false,false,false));
  				}
  				LineItemWrapper wrapper = new LineItemWrapper(li,tiers);
  				childLineItemWrapper.add(wrapper);
  			}
  			
  			//Clone the quote line Items
  			List<QuoteLineItemWrapper> childQuoteLineItemWrapper = new List<QuoteLineItemWrapper>();
  			for(QuoteLineItemWrapper lineItem: chainOppWrapper.quoteLineItems){
  				Opportunity_Quote_Line_Item__c li = lineItem.quoteLineItem.clone(false,false,false,false);
  				li.recordtypeId				= LibRecordTypeHelper.getRecordTypeValue(opp.Company_Code__c+'_Opportunity_Quote_Line_Item');
  				List<Tier__c> tiers = new List<Tier__c>();
  				for(Tier__c tr: lineitem.quoteLineItem.tiers__r){
  					tiers.add(tr.clone(false,false,false,false));
  				}
  				QuoteLineItemWrapper wrapper = new QuoteLineItemWrapper(li,tiers);
  				childQuoteLineItemWrapper.add(wrapper);
  			}
  			
  			OpportunityWrapper wrapper =  new OpportunityWrapper(opp,quote,cdLink,childLineItemWrapper,childQuoteLineItemWrapper);
  			oppsToBeCreated.add(wrapper);
  		}
  		
  		// create the actual records
  		if(oppsToBeCreated.size() > 0){
  			createRecordsForChainOpportunity(oppsToBeCreated);
  		}
  	}
  	
  	/**
  	* @Description	: This method creates a wrapper from the chain opportunity. The wrapper contains the
  						Opportunity, Quote, Line Items, Quote Line Items and Tiers
  	  @InputParam 	: Opportunity Id
  	  @return		: OpportunityWrapper  
  	*/
  	public static OpportunityWrapper poulateOppWrapperWithRelatedRecords(Id oppId){
  		// Fetch the Opportunit record
  		Opportunity opp = [SELECT Id,Name,Company_Code__c,currencyISOCode,CloseDate,stageName, Schedule_into_the_past__c,
  								  accountId,ownerId,type,Business_type__c,Id_Tarif__c,Start_Date_uk__c,
								Onboarding_Menu_Comments__c, Payment_Method__c,Time_Based_Tier_Type__c,List_Photo_Comments__c
  							FROM Opportunity
  							WHERE Id =: oppId];
        
        // fetch the quote 
	 	Opportunity_Quote__c quote = [SELECT Id, Name, Id_tarif__c,recordtypeId,Id_Opportunity__c,CurrencyISOCode,
  											status__c,Id_Account__c
		  							 	FROM Opportunity_Quote__c
		  							 	WHERE Status__c = 'Accepted'
		  							 		AND Id_Opportunity__c =: oppId];
		
		// Fetch the line Items 
		List<Opportunity_Line_Item__c> lineItems = [SELECT Ad_Sales_Type__c,Booking_Api_Id__c,Category_Id__c,Category__c,
														City_ZipCode__c,Commission_In_Percentage__c,Commission_Per_Order__c,
														Commission_Type__c,Deposit_Method__c,Deposit__c,Design_Note__c,
														Discount__c,District_Id__c,District__c,End_Date__c,Has_Related_Tarif__c,
														Id,Id_List_Price_Product__c,Id_List_Service_Price__c, Based_On__c,
  														Id_Opportunity__c,Id_Replacement_Order__c,index__c,Installments__c,
  														IsTiered__c,Line_Item_Type__c,Listed_Price__c,Max__c,Min__c,Name,
  														Number_of_Copies__c,OldOppQuoteLineId__c,Online_Payment_Fee__c,
  														Position_fm__c,Position__c,Product_Group__c,Quantity__c,RecordTypeId,
  														Recurring_Fee__c,Size__c,Start_Date__c,Subsidy__c,Sub_type__c,
  														Total_Amount__c,Weight__c,Id_List_Add_on__c,ContractAddition__c,
  														Billable_Account__c,Specifications__c,Scaled__c, Delivery__c,
                        								(SELECT Min__c,Max__c,Commission_In_percentage__c,
                        										Commission_Per_Order__c,Id_Opportunity_Quote_Line_item__c,
                        										Id_Opportunity_Line_item__c
                                							FROM Tiers__r
                                							ORDER BY min__c)
                    								FROM Opportunity_Line_Item__c
                    								WHERE Id_Opportunity__c =: oppId];
       
        // Fetch the quote line items
        List<Opportunity_Quote_Line_Item__c> quoteLineItems = 
        										[SELECT Booking_Api_Id__c,Category_Id__c,Category__c,
														City_ZipCode__c,Commission_In_Percentage__c,Commission_Per_Order__c,
														Commission_Type__c,Deposit_Method__c,Deposit__c,Design_Note__c,
														Discount__c,District_Id__c,District__c,End_Date__c,Has_Related_Tarif__c,
														Id,Id_List_Service_Price__c,Id_List_Product_Price__c, Based_On__c,
  														Id_Opportunity__c,Id_Replacement_Order__c,index__c,Installments__c,
  														IsTiered__c,Line_Item_Type__c,Listed_Price__c,Max__c,Min__c,Name,
  														Number_of_Copies__c,OldOppQuoteLineId__c,Online_Payment_Fee__c,
  														Position_fm__c,Position__c,Product_Group__c,Quantity__c,RecordTypeId,
  														Recurring_Fee__c,Size__c,Start_Date__c,Subsidy__c,Sub_type__c,
  														Total_Amount__c,Weight__c,Id_List_Add_on__c,Contract_Addition__c,
  														Billable_Account__c,Specifications__c,Scaled__c, Delivery__c,
                        								(SELECT Min__c,Max__c,Commission_In_percentage__c,
                        										Commission_Per_Order__c,Id_Opportunity_Quote_Line_item__c,
                        										Id_Opportunity_Line_item__c
                                							FROM Tiers__r
                                							ORDER BY min__c)
                    								FROM Opportunity_Quote_Line_Item__c
                    								WHERE Id_Opportunity__c =: oppId
                    									AND Id_Opportunity_Quote__r.status__c = 'Accepted'];		
                    								
          // Prepare the wrapper
          OpportunityWrapper wrapper 	= new OpportunityWrapper(opp,quote,lineItems,quoteLineItems);
          
  		  return wrapper;
  	}
  	
  	
  	/**
  	* @Description: This method creates child records from the List of opportunity wrapper
  					First it inserts the opportunity, then the quote, then the line items and quote line items and
  					at last the tiers
  		@inputParam: List<OpportunityWrapper>
  		@Return	   : VOID
  	*/
  	public static void createRecordsForChainOpportunity(List<OpportunityWrapper> oppWrapper){
  		// Insert Opportunities
  		List<Opportunity> oppsToBeInserted = new List<Opportunity>();
  		for(OpportunityWrapper wrapper : oppWrapper){
  			oppsToBeInserted.add(wrapper.opp);
  		}
  		insert oppsToBeInserted;
  		
  		// Insert Quotes and line items
  		List<Opportunity_Quote__c> quotesToBeInserted 			= new List<Opportunity_Quote__c>();
  		List<Opportunity_Line_Item__c> lineItemsToBeInserted 	= new List<Opportunity_Line_Item__c>();
		List<ContentDocumentLink> cdLinksToBeInserted 	= new List<ContentDocumentLink>();
  		for(OpportunityWrapper wrapper : oppWrapper){
  			// prepate quote for insertion
  			wrapper.quote.Id_Opportunity__c = wrapper.opp.Id;
  			quotesToBeInserted.add(wrapper.quote);
  			
  			// prepare line items for insertion
  			for(LineItemWrapper li : wrapper.lineItems){
  				li.lineItem.Id_Opportunity__c = wrapper.opp.Id;
  				lineItemsToBeInserted.add(li.lineItem);
  			}
  		}
  		insert quotesToBeInserted;
  		insert lineItemsToBeInserted;
		// insert Content Document Link records
		for (OpportunityWrapper wrapper : oppWrapper) {

			if (wrapper.contentDocumentLink!=null) {
				
				wrapper.contentDocumentLink.LinkedEntityId = wrapper.quote.Id;
				cdLinksToBeInserted.add(wrapper.contentDocumentLink);
			}
		}
        if (cdLinksToBeInserted.size()>0) {
			insert cdLinksToBeInserted;
        }
  		
  		// Insert Opportunity Quote Line Items
  		List<Opportunity_Quote_Line_Item__c> quoteLineItemsToBeInserted 	= new List<Opportunity_Quote_Line_Item__c>();
  		for(OpportunityWrapper wrapper : oppWrapper){
  			for(QuoteLineItemWrapper li : wrapper.quoteLineItems){
  				li.quoteLineItem.Id_Opportunity__c 			= wrapper.opp.Id;
  				li.quoteLineItem.Id_Opportunity_Quote__c	= wrapper.quote.Id;
  				quoteLineItemsToBeInserted.add(li.quoteLineItem);
  			}
  		}
  		insert quoteLineItemsToBeInserted;
  		
  		// Insert the Tiers
  		List<Tier__c> tiersToBeInserted = new List<Tier__c>();
  		for(OpportunityWrapper wrapper : oppWrapper){
  			// Prepare the tiers from Line Items
  			for(LineItemWrapper li : wrapper.lineItems){
  				if(li.tiers != null){
	  				for(Tier__c tier : li.tiers){
	  					tier.Id_Opportunity_Line_Item__c = li.lineItem.Id;
	  					tiersToBeInserted.add(tier);
	  				}
  				}
  			}
  			for(QuoteLineItemWrapper li : wrapper.quoteLineItems){
  				if(li.tiers != null){
	  				for(Tier__c tier : li.tiers){
	  					tier.Id_Opportunity_Quote_Line_Item__c = li.quoteLineItem.Id;
	  					tiersToBeInserted.add(tier);
	  				}
  				}
  			}
  		}
  		
  		if(tiersToBeInserted.size() > 0)
  			insert tiersToBeInserted;
  		 		
  	}
  	
  	public static Date getQuarterEndDate(){
  		Date dt = Date.today();
		Integer currentMnt =dt.month();
		Integer currentQ =((currentMnt-1)/3) + 1;
		Date endOfQDate = date.newInstance(dt.year(),currentMnt + (4 - (currentMnt - ((currentQ -1)*3))) , 1).addDays(-1);
		return endOfQDate;
  	}
  	
  	public class OpportunityWrapper{
  		public Opportunity opp;
  		public Opportunity_Quote__c quote;
  		public List<LineItemWrapper> lineItems;
  		public List<QuoteLineItemWrapper> quoteLineItems;
		public ContentDocumentLink contentDocumentLink;
  		
  		public OpportunityWrapper(Opportunity opp,Opportunity_Quote__c quote,List<Opportunity_Line_Item__c> lineItems,
  									List<Opportunity_Quote_Line_Item__c> quoteLineItems){
  			this.opp 	= opp;
  			this.quote 	= quote;							
  			
  			this.lineItems = new List<LineItemWrapper>();
  			for(Opportunity_Line_item__c lineItem : lineItems){
  				LineItemWrapper wrapper = new LineItemWrapper(lineItem,lineItem.Tiers__r);
  				this.lineItems.add(wrapper);
  			}
  			
  			this.quoteLineItems = new List<QuoteLineItemWrapper>();
  			for(Opportunity_Quote_Line_Item__c lineItem : quoteLineItems){
  				QuoteLineItemWrapper wrapper = new QuoteLineItemWrapper(lineItem,lineItem.Tiers__r);
  				this.quoteLineItems.add(wrapper);
  			}
  		}
  		
  		public OpportunityWrapper(Opportunity opp,Opportunity_Quote__c quote,List<LineItemWrapper> lineItems,
  									List<QuoteLineItemWrapper> quoteLineItems){
  			this.opp 			= opp;
  			this.quote 			= quote;
  			this.lineItems		= lineItems;
  			this.quoteLineItems	= quoteLineItems;
  		}

		  public OpportunityWrapper(Opportunity opp,Opportunity_Quote__c quote, ContentDocumentLink contentDocumentLink, List<LineItemWrapper> lineItems, List<QuoteLineItemWrapper> quoteLineItems){
  			this.opp 			= opp;
  			this.quote 			= quote;
			this.contentDocumentLink = contentDocumentLink;
  			this.lineItems		= lineItems;
  			this.quoteLineItems	= quoteLineItems;
  		}
  	}
  	
  	public class LineItemWrapper{
  		public Opportunity_Line_item__c lineItem;
  		public List<Tier__c> tiers;
  		
  		public LineItemWrapper(Opportunity_Line_item__c lineItem,List<Tier__c> tiers){
  			this.lineItem 	= lineItem;
  			this.tiers		= tiers;
  		}
  	}
  	
  	public class QuoteLineItemWrapper{
  		public Opportunity_Quote_Line_item__c quoteLineItem;
  		public List<Tier__c> tiers;
  		
  		public QuoteLineItemWrapper(Opportunity_Quote_Line_item__c quoteLineItem,List<Tier__c> tiers){
  			this.quoteLineItem 	= quoteLineItem;
  			this.tiers			= tiers;
  		} 
  	}

/********************************************* CHAIN OPPORTUNITY PROCESS END*****************************************/
/********************************************* CHILD CHAIN OPP VALIDATIONS START ************************************/
	/**
      * @Description: This method shortlists all the opps(child opps) which are created as a part of chain opportnunities
                      for further validations
            @Process Name       : CHILD CHAIN OPP VALIDATION PROCESS
            @Business Config    : nintexForChainOpp
            @Input Params       : List of updated opps, Map of opps before updation
            @Return             : Shortlisted Opportunity Map
            @TriggerContext     : Before Update.
      */

	public static Map<Id, Opportunity> getChildChainOpps(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){

		Map<Id,Opportunity> oppsTobeProcessed = new Map<Id,Opportunity>();
		List<Opportunity> newOpps = (List<Opportunity>)sobjects;
		Set<string> SetOfParentOppty = new Set<string>();
		Map<Id,Opportunity> mapOfParentOppty = new Map<Id,Opportunity>();

		for (Opportunity opp : newOpps) {
			// Remove the parent opportunity check to validate all opportunities during QC case - 1744
			if (ValidateCaseChainOpportunity(opp, opp.recordTypeId)) // by pass when opportunity is creating
				continue;

			if (CtrOpportunityLineItems.ValidateChainOpportunity(opp, opp.recordTypeId) == false) {
				oppsTobeProcessed.put(opp.Id, opp);
			}
		}
		return oppsTobeProcessed;


	}

	/**
      * @Description: This method shortlists the opportunites on the basis of stagename
            @Process Name       : VALIDATE CHILD CHAIN OPPTY WHEN CASE CLOSE
            @Business Config    : nintexForChainOpp
            @Input Params       : Opportunity record and record type id
            @Return             : boolean true/false
            @TriggerContext     : Before Update.
      */
	private static boolean ValidateCaseChainOpportunity(Opportunity opp,string recordtypeId){
	
		Map<String, Map<String, Business_Config__c>> mapBusinessLogic   = moam.get('nintexForChainOpp');
		if(mapBusinessLogic == null){
			return true;
		}
		Map<String, Business_Config__c> rules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(recordtypeId));

		if (rules == null || !rules.containsKey('StageName')) {
			return true;
		}
		if(rules.get('StageName').Business_Rule_Value__c.split(',').contains(opp.StageName))
		{
			return false;
		}
		return true;
	}

	/**
    * @Description: This method validates all the opps(child opps) which are created as a part of chain opportnunities
                    for further validations
          @Process Name       : CHILD CHAIN OPP VALIDATION PROCESS
          @Business Config    : nintexForChainOpp
          @Input Params       : Opportunity record
          @Return             : Boolean, false if the validation fails
          @TriggerContext     : Before Update
    */
	public static Boolean validateChildChainOpportunity(Opportunity opp){

		if(String.isBlank(opp.Record_Country__c)){
			return true;
		}

		/* Adding variables for Bank Detail */
		String errorMessage = Label.RequiredFieldMissingMessage+ ' \n', accSoqlString, conSoqlString, addSoqlString, oppSoqlString, bankSoqlString;
		Boolean isError = false, isConError = false, isAddError = false, isOppError = false, requiredContactRoleExists = false, isBankError = false ;
		String oppRecordTypeName = LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId);
		errorMessage = CtrOpportunityLineItems.ValidateOpportunity(oppRecordTypeName,opp);

		if(errorMessage != 'No Error'){
			opp.addError(errorMessage);
			return false;
		}
		return true;

	}


/********************************************* CHILD CHAIN OPP VALIDATIONS END*****************************************/

	private static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName) {
		Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
		Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
		Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

		Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
		return fieldSetObj.getFields();
	}
	/**
   * @Description: This method inserts opportunity country from accounts records country
     @Input Params       : Opportunity record
     @Return             : Void
     @TriggerContext     : Before Insert
     @Ticket #            :  SSC-1533
    */
	public static void insertOppsCountryFromAccount(List<Opportunity> listOppty){

		Set<Id> setOfAccount = new Set<Id>();
		Map<Id, Account> mapOfAccount = new Map<Id,Account>();

		for(Opportunity  iOppty : listOppty){

			setOfAccount.add(iOppty.AccountId);
		}

		if(setOfAccount.isEmpty())
			return;

		try{

			mapOfAccount = new Map<Id,Account> (ClsAccountSelector.getAccountByOppty(setOfAccount));
			for(Opportunity  iOppty : listOppty){

				if(mapOfAccount.containsKey(iOppty.AccountId)){
					iOppty.Opportunity_Country__c = mapOfAccount.get(iOppty.AccountId).Record_Country__c;
				}
			}
		}
		catch(Exception e){
			System.debug('Error: '+e.getMessage());
		}

	}
	/**
   * @Description: This method updates opportunity country from accounts records country
     @Input Params       : Opportunity record
     @Return             : Void
     @TriggerContext     :  Before Update
     @Ticket #            : SSC-1533
    */
	public static void updateOppsCountryFromAccount(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){

		Map<Id,Opportunity> mapOfOpportunity = (Map<Id,Opportunity>)oldSobjectMap;
		List<Opportunity>  listOppty = (List<Opportunity>)sobjects;

		Set<Id> setOfAccount = new Set<Id>();
		Map<Id, Account> mapOfAccount = new Map<Id,Account>();

		for(Opportunity  iOppty : listOppty){
			if(iOppty.AccountId != mapOfOpportunity.get(iOppty.Id).AccountId){
				setOfAccount.add(iOppty.AccountId);
			}
		}
		if(setOfAccount.isEmpty())
			return;

		try{

			mapOfAccount = new Map<Id,Account> (ClsAccountSelector.getAccountByOppty(setOfAccount));
			for(Opportunity  iOppty : listOppty){

				if(mapOfAccount.containsKey(iOppty.AccountId)){
					iOppty.Opportunity_Country__c = mapOfAccount.get(iOppty.AccountId).Record_Country__c;
				}
			}
		}
		catch(Exception e){
			System.debug('Error: '+e.getMessage());
		}

	}
	/**
   * @Description: This method create opportunity and quote line item for self sign up process
     @Param       : Opportunity record
     @Return             : Void
     @TriggerContext     :  After Update
     @Ticket #           : SSC-1979
    */
	public static void createOpportunityLineItemForSelfSignUp(List<SObject> sobjects,Map<Id, SObject> oldSobjectMap) {

		List<Opportunity> listOppty = (List<Opportunity>) sobjects;
		Map<Id,Opportunity> mapOfOpportunity = (Map<Id,Opportunity>)oldSobjectMap;
		List<Opportunity> listSelfSignOppty = new List<Opportunity>();
		Set<Id> setOfTarif = new Set<Id>();

		for (Opportunity iOppty : listOppty) {
			if (iOppty.LeadSource == 'Self Sign Up' && iOppty.LeadSource != mapOfOpportunity.get(iOppty.Id).LeadSource) {
				listSelfSignOppty.add(iOppty);
				setOfTarif.add(iOppty.Id_Tarif__c);
			}
		}
		if (!listSelfSignOppty.isEmpty()) {
			system.enqueueJob(new OpportunityLineItemCreation_Queable(listSelfSignOppty,setOfTarif));
		}
  }
	/*********************************************************************************************
    *   @Description: This method check if the OQLI contains MIDAS Package then assigned to a Queue based on business config
    *   @Process Name       : Quality check process
    *   @Business Config    : MIDASPackagesCaseQueueAssignment
    *   @InputParams        : Map<String, Business_Config__c> rules, Id of Oppty, Case object
    *   @Return             : Boolean
    *   @TriggerContext     : After Update
    *   @JIRA        : SSC-1332
    */
	private static Boolean validateIfThereIsMidasPackage(Map<String, Business_Config__c> rules, Id opportunityId,Case cs){
		Boolean midasPackageCheck = false;
		if(rules.containsKey('MIDASPackagesCaseQueueAssignment')){
			String midas_Product_Name = Opportunity_Selector.fetchOQLIProductName(opportunityId);
			Map<String,String> midasPackageQueue =
					(Map<String, String>)JSON.deserialize(rules.get('MIDASPackagesCaseQueueAssignment').business_rule_value__c,
							Map<String, String>.class);
			if(midasPackageQueue.containsKey(midas_Product_Name)){
				cs.ownerid=GroupSelector.getQueueByDeveloperName(midasPackageQueue.get(midas_Product_Name)).id;
				midasPackageCheck =true;
			}
		}
		return midasPackageCheck;
	}
	/*********************************************************************************************
    *   @description        : It assigned the Addtnl Charges Status for CPC Products of MIDAS for TLB
    *   @processname        : Quality check process
    *   @businessconfig     : Opportunity Contract Process
    *   @params             : Map<String, Business_Config__c> rules,
    *   @return             : Boolean
    *   @triggerContext     : After Insert
    *   @jira               : SSC-1220
    */
	private static String setMarketingPackageAddtnlChargeStatus(Map<String, Business_Config__c> rules){
		String additionalChargeStatus='';
		if(rules.containsKey('setAdditionalChargesStatus')){
			additionalChargeStatus =Constants.ADD_CHARGES_STATUS_PENDING_ACTIVATION;
		}
		return additionalChargeStatus;
	}
}