global class BatchProcessReplacementOrder implements Database.Batchable<sObject>,Database.Stateful {
	
	String query;
	private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
	
	global BatchProcessReplacementOrder() {
		query = 'select Id,Status__c,Account__c,Account__r.ownerid,recordtype.developername,' +
					'Opportunity__r.ownerId,Opportunity__r.StageName,Opportunity__r.CurrencyIsoCode,'+
					'Opportunity__r.Company_Code__c,' +
							'(select id, Status__c,CurrencyIsoCode,Id_List_Product_Price__c,Id_Asset__c,Id_Opportunity__c,'+
							'Id_Account__c,RecordTypeId,Amount__c,createdById '+ 
								'from Replacement_Orders__r '+
								'where Status__c=\'Transmission-Approved\') '+ 
					'from Asset__c '+
					'where TransmissionNotApproved__c=0 and TransmissionApprovedReplacements__c>0 and '+ 
						'(Opportunity__r.Company_Code__c=\'UK\' or opportunity__r.company_code__c=\'SE\'  or opportunity__r.company_code__c=\'AT\')';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		Map<String,Map<String,Business_Config__c>> mapBusinessLogic = moam.get('BatchReplacementOrder');
   		if(mapBusinessLogic!=null && !mapBusinessLogic.isEmpty()){
	   		Map<Id,Opportunity> oppCreatedMap = new Map<Id,Opportunity>();
	   		List<Replacement_Order__c> updateRepOrder = new List<Replacement_Order__c>();
	   		Map<Id,Opportunity_Quote__c>  newQuoteMap = new Map<Id,Opportunity_Quote__c>();
	   		List<Opportunity_Quote_Line_Item__c> listOppQuoteLines = new List<Opportunity_Quote_Line_Item__c>();
	   		//ReplacementOrderSettings__c rpsettings = ReplacementOrderSettings__c.getValues(Opportunity__r.Company_Code__c);
	   		Set<Id> lppIds = new Set<Id>();
	   		List<Case> csList = new List<Case>();
	   		List<Asset__c> chargeableAssetsRep = new List<Asset__c>();
	   		for(Asset__c theAsset : (List<Asset__c>) scope){
	   			Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(theAsset.recordtype.developerName);
	   			if(mapBusinessRules!=null && !mapBusinessRules.isEmpty()){
		   			if(mapBusinessRules.get('OppStage').Business_Rule_value__c.containsIgnorecase(theAsset.Opportunity__r.StageName)){
			   			for(Replacement_Order__c rp : theAsset.Replacement_Orders__r){
			   				ReplacementOrderSettings__c rpsettings = ReplacementOrderSettings__c.getValues(theAsset.Opportunity__r.Company_Code__c);
			   				lppIds.add(rp.Id_List_Product_Price__c);
			   				if(rp.Amount__c!=null && rp.Amount__c > rpsettings.warranty_amount__c){
								if(oppCreatedMap.isEmpty() || (!oppCreatedMap.isEmpty() && oppCreatedMap.get(rp.Id_Opportunity__c)==null)){
									Opportunity opp = new Opportunity(AccountId=theAsset.Account__c,CloseDate=Date.today(),ownerId=rp.createdById);
									for(String ss: rpsettings.Opportunity__c.split(',')){
										List<String> fileds = ss.split('=');
										opp.put(fileds[0],fileds[1]);
									}
				                	oppCreatedMap.put(rp.Id_Opportunity__c,opp);
								}
							}
			   			}
		   			}else{
		   				for(Replacement_Order__c rp : theAsset.Replacement_Orders__r){
		   					lppIds.add(rp.Id_List_Product_Price__c);
		   					if(rp.Amount__c!=null){
		   						if(newQuoteMap.isEmpty() || (!newQuoteMap.isEmpty() && newQuoteMap.get(rp.Id_Opportunity__c)==null)){
		            				newQuoteMap.put(rp.Id_Opportunity__c,new Opportunity_Quote__c(Id_Opportunity__c=rp.Id_Opportunity__c,CurrencyIsoCode=theAsset.Opportunity__r.CurrencyIsoCode,status__c='Approved',Id_Account__c=theAsset.Account__c,isReplacementQuote__c=true,recordtypeId=LibRecordTypeHelper.getRecordTypeValue(theAsset.Opportunity__r.Company_Code__c+'_Opportunity_Quote')));
		            			}
		   					}
		   				}
		   			}

	   			}

	   		}

	   		insert oppCreatedMap.values();
	   		insert newQuoteMap.values();
	   		Map<Id,Boolean> mapQuoteChargeable = new Map<Id,Boolean>();
	   		Map<Id,Case> oppWithQC = new Map<Id,Case>();
	   		Map<Id,List_Product_Price__c> productItemsMap = new Map<Id,List_Product_Price__c>([SELECT Id, Name,Requires_Additional_Charge__c, Product_Name__c,Requires_Replacement__c,List_Price__c,Id_List_Product_Group__r.Name,Product_Type__c from List_Product_Price__c where id in :lppIds]);
	   		Map<Id,List<Opportunity_line_item__c>> mapOppWithLines = new Map<Id,List<Opportunity_line_item__c>>();
	   		for(Asset__c theAsset : (List<Asset__c>) scope){
	   			Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(theAsset.recordtype.developerName);
	   			if(mapBusinessRules!=null && !mapBusinessRules.isEmpty()){
		   			ReplacementOrderSettings__c rpsettings = ReplacementOrderSettings__c.getValues(theAsset.Opportunity__r.Company_Code__c);
		   			Id opplineRecordtype = LibRecordTypeHelper.getRecordTypeValue(theAsset.Opportunity__r.Company_Code__c + '_Opportunity_Line_Item');
		   			if(mapBusinessRules.get('OppStage').Business_Rule_value__c.containsIgnorecase(theAsset.Opportunity__r.StageName)){
		   				
		   				List<Opportunity_line_item__c> opplines = new List<Opportunity_line_item__c>();
			   			for(Replacement_Order__c rp : theAsset.Replacement_Orders__r){
			   				rp.Status__c = mapBusinessRules.get('RPbackOfficePending').Business_Rule_value__c;
			   				
			   				if(rp.Amount__c!=null && rp.Amount__c > rpsettings.warranty_amount__c){
								if(oppCreatedMap.get(rp.Id_Opportunity__c)!=null){	
									opplines.add(new Opportunity_line_item__c(recordtypeId=opplineRecordtype,Id_Replacement_Order__c=rp.id,Id_List_Price_Product__c=rp.Id_List_Product_Price__c,Name=productItemsMap.get(rp.Id_List_Product_Price__c).Product_Name__c,Id_Opportunity__c = oppCreatedMap.get(rp.Id_Opportunity__c).Id,Quantity__c = 1, Discount__c = '0',Installments__c=1,Listed_Price__c=productItemsMap.get(rp.Id_List_Product_Price__c).List_Price__c,Total_Amount__c = rp.Amount__c,Product_Group__c = productItemsMap.get(rp.Id_List_Product_Price__c).Id_List_Product_Group__r.Name,CurrencyIsoCode= theAsset.Opportunity__r.CurrencyIsoCode,sub_type__c=productItemsMap.get(rp.Id_List_Product_Price__c).Product_Type__c,Line_Item_Type__c='Product'));
									rp.Id_Opportunity__c = oppCreatedMap.get(rp.Id_Opportunity__c).Id;
								}
							}else if(rp.Amount__c!=null){
								rp.Status__c = mapBusinessRules.get('RPbackOfficeApproved').Business_Rule_value__c;
								//oppIds.add(theAsset.Opportunity__c);
								if(oppWithQC.isEmpty() || (!oppWithQC.isEmpty() && oppWithQC.get(rp.Id_Opportunity__c)==null)){
									

					                if(rpsettings.QualityCheckCaseSP__c!=null){
						                Case cs = new Case(Opportunity__c=theAsset.Opportunity__c,AccountId=theAsset.Account__c);
						                for(String fieldAndValue : rpsettings.QualityCheckCaseSP__c.split(',')){
						                    List<String> fields = fieldAndValue.split('=');
						                    cs.put(fields[0],fields[1]);
						                }
						                oppWithQC.put(rp.Id_Opportunity__c,cs);
					            	}
					        	}
							}
							updateRepOrder.add(rp);
			   			}
			   			if(!opplines.isEmpty()){
			   				mapOppWithLines.put(oppCreatedMap.get(theAsset.Opportunity__c).Id,opplines);
			   			}
					}else{
		   				List<Opportunity_line_item__c> opplines = new List<Opportunity_line_item__c>();
						for(Replacement_Order__c rp : theAsset.Replacement_Orders__r){
							rp.Status__c = mapBusinessRules.get('RPbackOfficeApproved').Business_Rule_value__c;
			   				updateRepOrder.add(rp);

			   				if(rp.Amount__c!=null && rp.Amount__c >rpsettings.warranty_amount__c){
								opplines.add(new Opportunity_line_item__c(recordtypeId=opplineRecordtype,Id_Replacement_Order__c=rp.id,Id_List_Price_Product__c=rp.Id_List_Product_Price__c,Has_Related_Tarif__c=false, Start_Date__c=Date.today(),Name=productItemsMap.get(rp.Id_List_Product_Price__c).Product_Name__c,Id_Opportunity__c = rp.Id_Opportunity__c,Quantity__c = 1, Discount__c = '0',Installments__c=1,Listed_Price__c=productItemsMap.get(rp.Id_List_Product_Price__c).List_Price__c,Total_Amount__c = rp.Amount__c,Product_Group__c = productItemsMap.get(rp.Id_List_Product_Price__c).Id_List_Product_Group__r.Name,CurrencyIsoCode= theAsset.Opportunity__r.CurrencyIsoCode,sub_type__c=productItemsMap.get(rp.Id_List_Product_Price__c).Product_Type__c,Line_Item_Type__c='Product'));
		                		listOppQuoteLines.add(new Opportunity_Quote_Line_Item__c(Id_Replacement_Order__c=rp.id,name=productItemsMap.get(rp.Id_List_Product_Price__c).Product_Name__c,Has_Related_Tarif__c=false, Start_Date__c=Date.today(),Line_Item_Type__c='Product',Listed_Price__c = productItemsMap.get(rp.Id_List_Product_Price__c).List_Price__c, Quantity__c = 1, Total_Amount__c = rp.Amount__c,Product_Group__c=productItemsMap.get(rp.Id_List_Product_Price__c).Id_List_Product_Group__r.Name,Installments__c=1,Id_Opportunity_Quote__c = newQuoteMap.get(rp.Id_Opportunity__c).Id,recordtypeId =LibRecordTypeHelper.getRecordTypeValue(theAsset.Opportunity__r.Company_Code__c+'_Opportunity_Quote_Line_Item'),Id_Opportunity__c =rp.Id_Opportunity__c,Id_List_Product_Price__c = rp.Id_List_Product_Price__c, CurrencyIsoCode = theAsset.Opportunity__r.CurrencyIsoCode,Sub_Type__c = productItemsMap.get(rp.Id_List_Product_Price__c).Product_Type__c,Migration_OppId__c=rp.Id_Opportunity__c));
		            			//if(rpsettings.QualityCheckCaseSP__c!=null){
					            //    Case cs = new Case(Opportunity__c=theAsset.Opportunity__c,AccountId=theAsset.Account__c);
					            //    for(String fieldAndValue : rpsettings.QualityCheckCaseSP__c.split(',')){
					            //        List<String> fields = fieldAndValue.split('=');
					            //        cs.put(fields[0],fields[1]);
					            //    }
					            //    oppWithQC.put(rp.Id_Opportunity__c,cs);
				            	//}
				            	if(mapQuoteChargeable.get(newQuoteMap.get(rp.Id_Opportunity__c).Id)==null){
				            		mapQuoteChargeable.put(newQuoteMap.get(rp.Id_Opportunity__c).Id,true);
				            	}else if(mapQuoteChargeable.get(newQuoteMap.get(rp.Id_Opportunity__c).Id)==false){
				            		mapQuoteChargeable.put(newQuoteMap.get(rp.Id_Opportunity__c).Id,true);
				            	}
					        	
		   					}else if(rp.Amount__c!=null){
		   						opplines.add(new Opportunity_line_item__c(recordtypeId=opplineRecordtype,Id_Replacement_Order__c=rp.id,Id_List_Price_Product__c=rp.Id_List_Product_Price__c,Has_Related_Tarif__c=false, Start_Date__c=Date.today(),Name=productItemsMap.get(rp.Id_List_Product_Price__c).Product_Name__c,Id_Opportunity__c = rp.Id_Opportunity__c,Quantity__c = 1, Discount__c = '0',Installments__c=1,Listed_Price__c=productItemsMap.get(rp.Id_List_Product_Price__c).List_Price__c,Total_Amount__c = rp.Amount__c,Product_Group__c = productItemsMap.get(rp.Id_List_Product_Price__c).Id_List_Product_Group__r.Name,CurrencyIsoCode= theAsset.Opportunity__r.CurrencyIsoCode,sub_type__c=productItemsMap.get(rp.Id_List_Product_Price__c).Product_Type__c,Line_Item_Type__c='Product'));
		                		listOppQuoteLines.add(new Opportunity_Quote_Line_Item__c(Id_Replacement_Order__c=rp.id,name=productItemsMap.get(rp.Id_List_Product_Price__c).Product_Name__c,Has_Related_Tarif__c=false, Start_Date__c=Date.today(),Line_Item_Type__c='Product',Listed_Price__c = productItemsMap.get(rp.Id_List_Product_Price__c).List_Price__c, Quantity__c = 1, Total_Amount__c = rp.Amount__c,Product_Group__c=productItemsMap.get(rp.Id_List_Product_Price__c).Id_List_Product_Group__r.Name,Installments__c=1,Id_Opportunity_Quote__c = newQuoteMap.get(rp.Id_Opportunity__c).Id,recordtypeId =LibRecordTypeHelper.getRecordTypeValue(theAsset.Opportunity__r.Company_Code__c+'_Opportunity_Quote_Line_Item'),Id_Opportunity__c =rp.Id_Opportunity__c,Id_List_Product_Price__c = rp.Id_List_Product_Price__c, CurrencyIsoCode = theAsset.Opportunity__r.CurrencyIsoCode,Sub_Type__c = productItemsMap.get(rp.Id_List_Product_Price__c).Product_Type__c,Migration_OppId__c=rp.Id_Opportunity__c));
		            			if(mapQuoteChargeable.get(newQuoteMap.get(rp.Id_Opportunity__c).Id)==null){
				            		mapQuoteChargeable.put(newQuoteMap.get(rp.Id_Opportunity__c).Id,false);
				            	}	
		   				//		if(oppWithQC.isEmpty() || (!oppWithQC.isEmpty() && oppWithQC.get(rp.Id_Opportunity__c)==null)){
									//if(rpsettings.QualityCheckCaseSP__c!=null){
						   //             Case cs = new Case(Opportunity__c=theAsset.Opportunity__c,AccountId=theAsset.Account__c);
						   //             for(String fieldAndValue : rpsettings.QualityCheckCaseSP__c.split(',')){
						   //                 List<String> fields = fieldAndValue.split('=');
						   //                 cs.put(fields[0],fields[1]);
						   //             }
						   //             oppWithQC.put(rp.Id_Opportunity__c,cs);
						   //         }
					    //    	}
		   					}
						}
						if(!opplines.isEmpty()){
							mapOppWithLines.put(theAsset.Opportunity__c,opplines);
						}
					}
					
				}

	   		}
	   		System.debug('newQuoteMap: '+newQuoteMap.values());
	   		Map<Id,Opportunity_Quote_Line_Item__c> oppQlineReparentMap = new Map<Id,Opportunity_Quote_Line_Item__c>();
	   		Map<Id,Opportunity_line_item__c> opplineReparentMap = new Map<Id,Opportunity_line_item__c>();

	   		Map<Id,Opportunity_Quote__c> updateOldQuote = new Map<Id,Opportunity_Quote__c>();
	   		for(Opportunity_Quote_Line_Item__c oppline : [select id,recordtypeid,CurrencyIsoCode,name,Id_Opportunity__r.Company_Code__c,Id_Opportunity_Quote__c,OldOppQuoteLineId__c,Booking_Api_Id__c,
	   			Category__c,Category_Id__c,Commission_In_Percentage__c,Commission_Per_Order__c,Commission_Type__c,Deposit__c,Deposit_Method__c,Design_Note__c,Discount__c,District__c,
	   			District_Id__c,End_Date__c,Has_Related_Tarif__c,Id_List_Service_Price__c,Id_Opportunity__c,Id_Replacement_Order__c,Installments__c,Line_Item_Type__c,Listed_Price__c,
	   			Id_List_Product_Price__c,Id_List_Product_Price__r.Requires_Asset__c,Id_List_Product_Price__r.Requires_Branding__c,Number_of_Copies__c,City_ZipCode__c,Position__c,Position_fm__c,Product_Group__c,Quantity__c,Recurring_Fee__c,Size__c,Start_Date__c,Sub_Type__c,
	   			Total_Amount__c,Weight__c from Opportunity_Quote_Line_Item__c where Id_Opportunity__c in :newQuoteMap.keySet() and Id_Opportunity_Quote__r.status__c = 'Accepted']){
	                //listOppQuoteLines.add(new Opportunity_Quote_Line_Item__c(Id_Replacement_Order__c=oppline.Id_Replacement_Order__c,name=oppline.name,Commission_In_Percentage__c=oppline.Commission_In_Percentage__c,Commission_Per_Order__c =oppline.Commission_Per_Order__c,Has_Related_Tarif__c=oppline.Has_Related_Tarif__c,End_Date__c=oppline.End_Date__c, Start_Date__c=oppline.start_date__c,Line_Item_Type__c=oppline.Line_Item_Type__c,Listed_Price__c = oppline.Listed_Price__c, Quantity__c = oppline.Quantity__c, Total_Amount__c = oppline.Total_Amount__c,Product_Group__c=oppline.Product_Group__c,Installments__c=oppline.Installments__c,Id_Opportunity_Quote__c = newQuoteMap.get(rp.Id_Opportunity__c).Id,recordtypeId =LibRecordTypeHelper.getRecordTypeValue(theAsset.Opportunity__r.Company_Code__c+'_Opportunity_Quote_Line_Item'),Id_Opportunity__c =oppline.Id_Opportunity__c,Id_List_Product_Price__c = oppline.Id_List_Price_Product__c, CurrencyIsoCode = oppline.CurrencyIsoCode,Recurring_Fee__c = oppline.Recurring_Fee__c,Sub_Type__c = oppline.Sub_Type__c,Migration_OppId__c=oppline.Id_Opportunity__c));
	            	if(oppline.Id_List_Product_Price__c!=null && (oppline.Id_List_Product_Price__r.Requires_Asset__c || oppline.Id_List_Product_Price__r.Requires_Branding__c)){
	            		oppQlineReparentMap.put(oppline.Id,new Opportunity_Quote_Line_Item__c(name=oppline.name,Id_Opportunity_Quote__c = newQuoteMap.get(oppline.Id_Opportunity__c).Id,recordtypeId =oppline.recordtypeid,CurrencyIsoCode = oppline.CurrencyIsoCode,Migration_OppId__c=oppline.Id_Opportunity__c,OldOppQuoteLineId__c= oppline.Id,Booking_Api_Id__c=oppline.Booking_Api_Id__c,Category__c=oppline.Category__c,Category_Id__c=oppline.Category_Id__c,Commission_In_Percentage__c=oppline.Commission_In_Percentage__c,Commission_Per_Order__c=oppline.Commission_Per_Order__c,Deposit__c=oppline.Deposit__c,Deposit_Method__c=oppline.Deposit_Method__c,Design_Note__c=oppline.Design_Note__c,Discount__c=oppline.Discount__c,District__c=oppline.District__c,District_Id__c=oppline.District_Id__c,End_Date__c=oppline.End_Date__c,Has_Related_Tarif__c=oppline.Has_Related_Tarif__c,Id_List_Service_Price__c=oppline.Id_List_Service_Price__c,Id_Opportunity__c=oppline.Id_Opportunity__c,Id_Replacement_Order__c=oppline.Id_Replacement_Order__c,Installments__c=oppline.Installments__c,Line_Item_Type__c=oppline.Line_Item_Type__c,Listed_Price__c=oppline.Listed_Price__c,Id_List_Product_Price__c=oppline.Id_List_Product_Price__c,Number_of_Copies__c=oppline.Number_of_Copies__c,City_ZipCode__c=oppline.City_ZipCode__c,Position__c=oppline.Position__c,Product_Group__c=oppline.Product_Group__c,Quantity__c=oppline.Quantity__c,Recurring_Fee__c=oppline.Recurring_Fee__c,Size__c=oppline.Size__c,Start_Date__c=oppline.Start_Date__c,Sub_Type__c=oppline.Sub_Type__c,Total_Amount__c=oppline.Total_Amount__c,Weight__c=oppline.Weight__c));
	            		opplineReparentMap.put(oppline.Id,new Opportunity_Line_Item__c(name=oppline.name,recordtypeId =LibRecordTypeHelper.getRecordTypeValue(oppline.Id_Opportunity__r.Company_Code__c + '_Opportunity_Line_Item'),CurrencyIsoCode = oppline.CurrencyIsoCode,OldOppQuoteLineId__c= oppline.Id,Booking_Api_Id__c=oppline.Booking_Api_Id__c,Category__c=oppline.Category__c,Category_Id__c=oppline.Category_Id__c,Commission_In_Percentage__c=oppline.Commission_In_Percentage__c,Commission_Per_Order__c=oppline.Commission_Per_Order__c,Deposit__c=oppline.Deposit__c,Deposit_Method__c=oppline.Deposit_Method__c,Design_Note__c=oppline.Design_Note__c,Discount__c=oppline.Discount__c,District__c=oppline.District__c,District_Id__c=oppline.District_Id__c,End_Date__c=oppline.End_Date__c,Has_Related_Tarif__c=oppline.Has_Related_Tarif__c,Id_List_Service_Price__c=oppline.Id_List_Service_Price__c,Id_Opportunity__c=oppline.Id_Opportunity__c,Id_Replacement_Order__c=oppline.Id_Replacement_Order__c,Installments__c=oppline.Installments__c,Line_Item_Type__c=oppline.Line_Item_Type__c,Listed_Price__c=oppline.Listed_Price__c,Id_List_Price_Product__c=oppline.Id_List_Product_Price__c,Number_of_Copies__c=oppline.Number_of_Copies__c,City_ZipCode__c=oppline.City_ZipCode__c,Position__c=oppline.Position__c,Product_Group__c=oppline.Product_Group__c,Quantity__c=oppline.Quantity__c,Recurring_Fee__c=oppline.Recurring_Fee__c,Size__c=oppline.Size__c,Start_Date__c=oppline.Start_Date__c,Sub_Type__c=oppline.Sub_Type__c,Total_Amount__c=oppline.Total_Amount__c,Weight__c=oppline.Weight__c));
	        		}else{
	        			oppQlineReparentMap.put(oppline.Id,new Opportunity_Quote_Line_Item__c(name=oppline.name,Id_Opportunity_Quote__c = newQuoteMap.get(oppline.Id_Opportunity__c).Id,recordtypeId =oppline.recordtypeid,CurrencyIsoCode = oppline.CurrencyIsoCode,Migration_OppId__c=oppline.Id_Opportunity__c,Booking_Api_Id__c=oppline.Booking_Api_Id__c,Category__c=oppline.Category__c,Category_Id__c=oppline.Category_Id__c,Commission_In_Percentage__c=oppline.Commission_In_Percentage__c,Commission_Per_Order__c=oppline.Commission_Per_Order__c,Deposit__c=oppline.Deposit__c,Deposit_Method__c=oppline.Deposit_Method__c,Design_Note__c=oppline.Design_Note__c,Discount__c=oppline.Discount__c,District__c=oppline.District__c,District_Id__c=oppline.District_Id__c,End_Date__c=oppline.End_Date__c,Has_Related_Tarif__c=oppline.Has_Related_Tarif__c,Id_List_Service_Price__c=oppline.Id_List_Service_Price__c,Id_Opportunity__c=oppline.Id_Opportunity__c,Id_Replacement_Order__c=oppline.Id_Replacement_Order__c,Installments__c=oppline.Installments__c,Line_Item_Type__c=oppline.Line_Item_Type__c,Listed_Price__c=oppline.Listed_Price__c,Id_List_Product_Price__c=oppline.Id_List_Product_Price__c,Number_of_Copies__c=oppline.Number_of_Copies__c,City_ZipCode__c=oppline.City_ZipCode__c,Position__c=oppline.Position__c,Product_Group__c=oppline.Product_Group__c,Quantity__c=oppline.Quantity__c,Recurring_Fee__c=oppline.Recurring_Fee__c,Size__c=oppline.Size__c,Start_Date__c=oppline.Start_Date__c,Sub_Type__c=oppline.Sub_Type__c,Total_Amount__c=oppline.Total_Amount__c,Weight__c=oppline.Weight__c));
	            		opplineReparentMap.put(oppline.Id,new Opportunity_Line_Item__c(name=oppline.name,recordtypeId =LibRecordTypeHelper.getRecordTypeValue(oppline.Id_Opportunity__r.Company_Code__c + '_Opportunity_Line_Item'),CurrencyIsoCode = oppline.CurrencyIsoCode,Booking_Api_Id__c=oppline.Booking_Api_Id__c,Category__c=oppline.Category__c,Category_Id__c=oppline.Category_Id__c,Commission_In_Percentage__c=oppline.Commission_In_Percentage__c,Commission_Per_Order__c=oppline.Commission_Per_Order__c,Deposit__c=oppline.Deposit__c,Deposit_Method__c=oppline.Deposit_Method__c,Design_Note__c=oppline.Design_Note__c,Discount__c=oppline.Discount__c,District__c=oppline.District__c,District_Id__c=oppline.District_Id__c,End_Date__c=oppline.End_Date__c,Has_Related_Tarif__c=oppline.Has_Related_Tarif__c,Id_List_Service_Price__c=oppline.Id_List_Service_Price__c,Id_Opportunity__c=oppline.Id_Opportunity__c,Id_Replacement_Order__c=oppline.Id_Replacement_Order__c,Installments__c=oppline.Installments__c,Line_Item_Type__c=oppline.Line_Item_Type__c,Listed_Price__c=oppline.Listed_Price__c,Id_List_Price_Product__c=oppline.Id_List_Product_Price__c,Number_of_Copies__c=oppline.Number_of_Copies__c,City_ZipCode__c=oppline.City_ZipCode__c,Position__c=oppline.Position__c,Product_Group__c=oppline.Product_Group__c,Quantity__c=oppline.Quantity__c,Recurring_Fee__c=oppline.Recurring_Fee__c,Size__c=oppline.Size__c,Start_Date__c=oppline.Start_Date__c,Sub_Type__c=oppline.Sub_Type__c,Total_Amount__c=oppline.Total_Amount__c,Weight__c=oppline.Weight__c));
	        		}
	            	
	            	if(updateOldQuote.get(oppline.Id_Opportunity_Quote__c)==null){
	            		updateOldQuote.put(oppline.Id_Opportunity_Quote__c,new Opportunity_Quote__c(Id=oppline.Id_Opportunity_Quote__c,status__c='Expired'));
	            	}
	            }

	        List<Opportunity_line_item__c> oppls = new List<Opportunity_line_item__c>();
	        for(List<Opportunity_line_item__c> listOppLi : mapOppWithLines.values()){
	        	oppls.addAll(listOppLi);
	        }

	        List<Opportunity_line_item__c> exOpplines = [select id from Opportunity_line_item__c where Id_Opportunity__c in :newQuoteMap.keySet()];
	        delete exOpplines;
	   		insert oppls;
	   		update updateRepOrder;
	   		insert listOppQuoteLines;
	   		insert opplineReparentMap.values();
	   		insert oppQlineReparentMap.values();
	   		//insert oppWithQC.values();
	   		List<Asset__c> updateAssets = new List<Asset__c>();
	   		List<Branding_Content__c> updateBranding = new List<Branding_Content__c>();
	   		//for(Asset__c ast : [select id,Id_Opportunity_Quote_Line_Item__c from Asset__c where Opportunity__c in : newQuoteMap.keySet()]){
	   		//	//Id tempId = ast.Id_Opportunity_Quote_Line_Item__c;
	   		//	opplineReparentMap.get(tempId).OldOppQuoteLineId__c = tempId;
	   		//	//ast.Id_Opportunity_Quote_Line_Item__c = oppQlineReparentMap.get(tempId).Id;
	   		//	//oppQlineReparentMap.get(tempId).AssetId__c = ast.Id;
	   		//	//updateAssets.add(ast);
	   		//}
	   		//for(Branding_Content__c bdc : [select id,Id_Opportunity_Quote_Line_Item__c from Branding_Content__c where Opportunity__c in : newQuoteMap.keySet()]){
	   		//	//Id tempId = bdc.Id_Opportunity_Quote_Line_Item__c;
	   		//	opplineReparentMap.get(tempId).OldOppQuoteLineId__c = tempId;
	   		//	//bdc.Id_Opportunity_Quote_Line_Item__c = oppQlineReparentMap.get(tempId).Id;
	   		//	//oppQlineReparentMap.get(tempId).BrandingId__c = bdc.Id;
	   		//	//updateBranding.add(bdc);
	   		//}
	   		//update oppQlineReparentMap.values();
	   		
	   		update updateOldQuote.values();
	   		List<Opportunity> updateOpp = new List<Opportunity>();
	   		List<Opportunity_Quote__c> updateQuote = new List<Opportunity_Quote__c>();
	   		Set<Id> oppIdForLinkingAsset = new Set<Id>();
	   		for(Opportunity_Quote__c oppq : [select id,Id_Opportunity__c, Id_Opportunity__r.Company_Code__c from Opportunity_Quote__c where id in: newQuoteMap.values()]){
	   			//commented out for SP-1397
	   			//if(mapQuoteChargeable.get(oppq.Id)==false){
	   				oppq.status__c = 'Accepted';
	   				updateQuote.add(oppq);
	   				oppIdForLinkingAsset.add(oppq.Id_Opportunity__c);
				/*}else{
					ReplacementOrderSettings__c rpsettings = ReplacementOrderSettings__c.getValues(oppq.Id_Opportunity__r.Company_Code__c);
					system.debug(rpsettings);
					updateOpp.add(new Opportunity(Id=oppq.Id_Opportunity__c,StageName=rpsettings.StageName__c,Probability=rpsettings.Probability__c));
				}*/
	   		}
	   		update updateQuote;
	   		update updateOpp;
	   		if(!oppIdForLinkingAsset.isEmpty()){
	   			for(Asset__c ast : [select id,Id_Opportunity_Quote_Line_Item__c from Asset__c where Opportunity__c in : oppIdForLinkingAsset]){
		   			ast.Id_Opportunity_Quote_Line_Item__c = oppQlineReparentMap.get(ast.Id_Opportunity_Quote_Line_Item__c).Id;
		   			updateAssets.add(ast);
		   		}
		   		for(Branding_Content__c bdc : [select id,Id_Opportunity_Quote_Line_Item__c from Branding_Content__c where Opportunity__c in : oppIdForLinkingAsset]){
		   			bdc.Id_Opportunity_Quote_Line_Item__c = oppQlineReparentMap.get(bdc.Id_Opportunity_Quote_Line_Item__c).Id;
		   			updateBranding.add(bdc);
		   		}
		   		update updateAssets;
	   			update updateBranding;
	   		}
	   	}

	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}