public inherited sharing class TrgQuoteProcessor {
    private static Boolean linkingAssetFlag = false;
    private static Map<String, Map<String,Map<String,Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    public static final String ERROR_UPDATE_CONTACT_FAILED = 'UpdateFailed On Contact Object'; //SSC-2815
    public static final String METHOD_UPDATE_CONTACT_PASS_NUMBER = 'updateContactPassportNumber Method : '; //SSC-2815
    public static final String TRGQUOTEPROCESSOR = 'TrgQuoteProcessor'; //SSC-2815
    public static final String APEX_CLASS = 'Apex Class'; //SSC-2815
    public static final String ERROR_MSG = 'Error : These records are failing'; //SSC-2815

    public static void quoteAcceptAndDecline(List<Opportunity_Quote__c> newList, Map<Id,Opportunity_Quote__c> oldMap){

        Map<Id,Opportunity_Quote__c> mapQuotes = new Map<Id,Opportunity_Quote__c>();
        Set<Id> setOpportuintyIds = new Set<Id>();
        Map<id,Opportunity_Quote__c > oppQuoteMap = new Map<id,Opportunity_Quote__c >();
        Set<string> updateQuoteLine = new Set<String>();
        Set<ID> oppIDs = new Set<ID>();
        List<opportunity>oppTarifToUpd =new List<Opportunity>();
        List<Id> quoteIds = new List<Id>();
        for(Opportunity_Quote__c qt : newList){
            if(qt.Status__c == 'Accepted' && (oldMap==null || (oldMap!=null && oldMap.get(qt.id).Status__c!=qt.Status__c))){
                setOpportuintyIds.add(qt.Id_Opportunity__c);
                oppQuoteMap.put(qt.id_opportunity__c,qt);
                quoteIds.add(qt.id);
            }
        }
        if(!System.isBatch() && !System.isQueueable() && !System.isFuture() && !quoteIds.isEmpty() && !linkingAssetFlag){
            System.debug('quoteIds: '+quoteIds);
            processLinkingOfAssetAndBranding(quoteIds);
            linkingAssetFlag = true;
        }
        if(!setOpportuintyIds.isEmpty()){
            List<Opportunity_Quote__c> listOtherQuotes = new List<Opportunity_Quote__c>();
            for(Opportunity_Quote__c qq : [select id,Status__c,Id_Opportunity__c, createddate 
                                            From Opportunity_Quote__c 
                                            where Id_Opportunity__c in : setOpportuintyIds and Status__c!='Accepted' and Status__c!='Expired' and Status__c!='Declined']){
                qq.Status__c = 'Declined';
                listOtherQuotes.add(qq);
                if(!System.isBatch() && qq.createddate>oppQuoteMap.get(qq.Id_Opportunity__c).createddate){
                    updateQuoteLine.add(oppQuoteMap.get(qq.Id_Opportunity__c).id);                    
                      if(oppIds==null || !oppIds.contains(qq.Id_Opportunity__c))
                        oppTarifToUpd.add(new Opportunity(id=qq.Id_Opportunity__c,Id_Tarif__c=oppQuoteMap.get(qq.Id_Opportunity__c).ID_tarif__c));
                    oppIds.add(qq.Id_Opportunity__c);
                    
                }
                
                
            }
            try {
                update listOtherQuotes;
                ClsSObjectUtils.updateApprovalProcesses(new Map<Id, Opportunity_Quote__c>(listOtherQuotes).keySet(), 'Removed');
            } catch(DmlException e) {
                System.debug('Error: '+e.getMessage());
            }
        }
        if(!updateQuoteLine.isEmpty() && updateQuoteLine!=null ){
            if(!oppTarifToUpd.isEmpty() && oppTarifToUpd!=null){
                update oppTarifToUpd;
        
            }
            updateOppLineItems(updateQuoteLine,oppIds);
            
       } 
    }
    @future
     public static void updateOppLineItems(Set<string> updateQuoteLine,Set<ID> oppIds){
        if(!updateQuoteLine.isEmpty() && updateQuoteLine!=null){
            system.debug('**updating line items**');  
            List<Opportunity_Line_Item__c> oppLst = new List<Opportunity_Line_Item__c>();
            List<TierOpportunityLineItemWrapper> lienItemWrapper = new List<TierOpportunityLineItemWrapper>(); 
            for(opportunity_quote_line_item__c oqli:[SELECT id,recordtype.developername,Booking_Api_Id__c,Category__c,Subsidy__c,online_payment_fee__C,name,
            												Category_Id__c,City_ZipCode__c,Commission_In_Percentage__c,Commission_Per_Order__c,Deposit__c,
            												Deposit_Method__c,Design_Note__c,Discount__c,District_Id__c,End_Date__c,Has_Related_Tarif__c,
            												Id_List_Service_Price__c,Id_Opportunity__c,Id_Replacement_Order__c,Installments__c,
            												Line_Item_Type__c,Listed_Price__c,Id_List_Product_Price__c,Number_of_Copies__c,Position__c,
            												Product_Group__c,Quantity__c,Recurring_Fee__c,Size__c,Start_Date__c,Sub_type__c,Total_Amount__c,
            												Weight__c,IsTiered__c,index__c,Max__c,Min__c,Billable_Account__c,Contract_Addition__c,Id_list_Add_on__c,
            												Specifications__c,
            												(SELECT Id,Min__c,Max__c,Commission_In_Percentage__c,Commission_Per_Order__c,
            													Id_Opportunity_Quote_Line_item__c,Id_Opportunity_Line_item__c from tiers__r)
        												from opportunity_quote_line_item__c where id_opportunity_quote__c IN:updateQuoteLine ]){
                if(oqli.Sub_type__c=='Premium Placement' && oqli.recordtype.developername=='UK_Opportunity_Quote_Line_Item')
                    oppIds.remove(oqli.ID_Opportunity__C);
                else{
                	TierOpportunityLineItemWrapper wrapper = new TierOpportunityLineItemWrapper();
                	wrapper.lineItem = new Opportunity_Line_Item__c(Booking_Api_Id__c=oqli.Booking_Api_Id__c,Category__c=oqli.Category__c,Category_Id__c=oqli.Category_Id__c,City_ZipCode__c=oqli.City_ZipCode__c,Commission_In_Percentage__c=oqli.Commission_In_Percentage__c,Commission_Per_Order__c=oqli.Commission_Per_Order__c,Deposit__c=oqli.Deposit__c,Deposit_Method__c=oqli.Deposit_Method__c,Design_Note__c=oqli.Design_Note__c,
					                    Discount__c=oqli.Discount__c,District_Id__c=oqli.District_Id__c,End_Date__c=oqli.End_Date__c,Has_Related_Tarif__c=oqli.Has_Related_Tarif__c,Id_List_Service_Price__c=oqli.Id_List_Service_Price__c,Id_Opportunity__c=oqli.Id_Opportunity__c,Id_Replacement_Order__c=oqli.Id_Replacement_Order__c,Installments__c=oqli.Installments__c,Line_Item_Type__c=oqli.Line_Item_Type__c,Listed_Price__c=oqli.Listed_Price__c,
					                    Id_List_Price_Product__c=oqli.Id_List_Product_Price__c,name=oqli.name,Subsidy__c=oqli.Subsidy__c,online_payment_fee__c=oqli.online_payment_fee__c,Number_of_Copies__c=oqli.Number_of_Copies__c,Position__c=oqli.Position__c,Product_Group__c=oqli.Product_Group__c,Quantity__c=oqli.Quantity__c,Recurring_Fee__c=oqli.Recurring_Fee__c,Size__c=oqli.Size__c,Start_Date__c=oqli.Start_Date__c,Sub_type__c=oqli.Sub_type__c,Total_Amount__c=oqli.Total_Amount__c,Weight__c=oqli.Weight__c,IsTiered__c= oqli.IsTiered__c,index__c= oqli.index__c,Max__c= oqli.Max__c,Min__c= oqli.Min__c,
					                    Id_list_Add_on__c= oqli.Id_list_Add_on__c,contractAddition__c = oqli.Contract_Addition__c,
					                    Billable_Account__c = oqli.Billable_Account__c,Specifications__c = oqli.Specifications__c);
                   for(Tier__c tier : oqli.tiers__r){
                   		Tier__c lineItemTier 							= tier.clone();
                   		lineItemTier.Id_Opportunity_Quote_Line_item__c 	= null;
                   		wrapper.tiers.add(lineItemTier);
                   } 	
                   
                   lienItemWrapper.add(wrapper);
                }
            }
             
     	List<Opportunity_line_item__c> opliToDelete =[select id,(select Id from Tiers__r) from opportunity_line_item__c where id_opportunity__c in:oppIds];
        
        if(!opliToDelete.isEmpty() && opliToDelete!=null){
            // Delete the tiers if present
            List<Tier__c> tiersToBeDeleted = new List<Tier__c>();
            for(Opportunity_line_item__c li: opliToDelete){
            	if(li.tiers__r.size() > 0){
            		tiersToBeDeleted.addAll(li.tiers__r);
            	}
            }
            if(tiersToBeDeleted.size() > 0){
            	delete tiersToBeDeleted;
            }
            delete opliToDelete;
        }
        
        
        for(TierOpportunityLineItemWrapper wrapper : lienItemWrapper){
        	oppLst.add(wrapper.lineItem);
        }        
        if(!oppLst.isEmpty() && oppLst!=null){
            insert oppLst;
        }
        
        // Insert tiers after the opportunity line items are inserted
        List<Tier__c> tiersToBeInserted = new List<Tier__c>();
        for(TierOpportunityLineItemWrapper wrapper : lienItemWrapper){
        	for(Tier__c tier : wrapper.tiers){
        		tier.Id_Opportunity_Line_item__c  = wrapper.lineItem.Id;
        		tiersToBeInserted.add(tier);
        	}
        }
        
        if(tiersToBeInserted.size() > 0){
        	insert tiersToBeInserted;
        }
            
       } 
        
        
        
    }



    public static void quoteDeclineAcceptValidation(List<Opportunity_Quote__c> newList, Map<Id,Opportunity_Quote__c> oldMap){
        for(Opportunity_Quote__c qt : newList){
            if( oldMap.get(qt.id).Status__c=='Declined' && qt.Status__c != oldMap.get(qt.id).Status__c){
                qt.addError(Label.Declined_quote_validation+' '+qt.Status__c);
                return;
            }
        }
    }


    public static void oppTypeAndStageProcess(List<Opportunity_Quote__c> listOppQuotes, Map<Id,Opportunity_Quote__c> oldMapOppQuotes){
        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('OppTypeAndStageProcess');
        Map<String,Map<String,Business_Config__c>> mapBusinessLogic = moam.get('OppTypeAndStageProcess');
        Map<Id,Opportunity_Quote__c> oppQuoteMap = new Map<Id,Opportunity_Quote__c>();
        List<Opportunity> listOppUpdates = new List<Opportunity>();
        Map<Id,Case> oppWithQC = new Map<Id,Case>();

        for(Opportunity_Quote__c oppQuote : [select recordtype.developerName, Id_Opportunity__r.type,Id_Opportunity__c,Id_Opportunity__r.Is_DataLoaded__c,status__c,Id_Opportunity__r.Id_Tarif__r.name from Opportunity_Quote__c where id in: listOppQuotes]){
            oppQuoteMap.put(oppQuote.id,oppQuote);
        }
        try{
            if(mapBusinessLogic!=null && !mapBusinessLogic.isEmpty()){
                for(Opportunity_Quote__c oppQuote : listOppQuotes){
                    Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(oppQuoteMap.get(oppQuote.id).recordtype.developerName);

                    if(mapBusinessRules!=null && !mapBusinessRules.isEmpty()){
                        System.debug('type: '+oppQuote.Id_Opportunity__r.type);
                        
                        String quoteStatus = mapBusinessRules.get('Status__c').Business_Rule_Value__c;
                        if(quoteStatus == oppQuote.status__c && (oldMapOppQuotes==null || (oldMapOppQuotes!=null && !oldMapOppQuotes.isEmpty() && oldMapOppQuotes.get(oppQuote.id).status__c!= quoteStatus))){
                            if(oppQuote.isReplacementQuote__c==false){    
                                if(oppQuoteMap.get(oppQuote.Id).Id_Opportunity__r.type==null && !oppQuoteMap.get(oppQuote.Id).Id_Opportunity__r.Is_DataLoaded__c){
                                    listOppQuotes[0].addError(Label.OpportunityTypeStageValidation);
                                    return;
                                }
                                if(mapBusinessRules.get(oppQuoteMap.get(oppQuote.id).Id_Opportunity__r.type)!=null){
                                    Opportunity opp = new Opportunity(id=oppQuote.Id_Opportunity__c);
                                    Set<String> tariffs = new Set<String>();

                                    if(mapBusinessRules.get('SetToClosedWonForTariff')!=null){
                                       if(mapBusinessRules.get('SetToClosedWonForTariff').Business_Rule_Value__c.indexOf(',') > 1 ){
                                            for(String str : mapBusinessRules.get('SetToClosedWonForTariff').Business_Rule_Value__c.split(',')){
                                                tariffs.add(str);
                                            }
                                       }else{
                                            tariffs.add(mapBusinessRules.get('SetToClosedWonForTariff').Business_Rule_Value__c);
                                       } 
                                    }
                                    if(!tariffs.isEmpty() && tariffs.contains(oppQuoteMap.get(oppQuote.id).Id_Opportunity__r.Id_Tarif__r.name)){
                                        opp.put('StageName','Closed Won');
                                        opp.put('Probability',100);
                                    }else if(mapBusinessRules.get('IfTariff-'+oppQuoteMap.get(oppQuote.id).Id_Opportunity__r.Id_Tarif__r.name)!=null){
                                        for(String newStr : mapBusinessRules.get('IfTariff-'+oppQuoteMap.get(oppQuote.id).Id_Opportunity__r.Id_Tarif__r.name).Business_Rule_Value__c.split(',')){
                                            String[] filedStr = newStr.split('=');
                                            if(filedStr[0].toLowerCase().contains('name')){
                                                opp.put(filedStr[0],filedStr[1]);
                                            }else{
                                                opp.put(filedStr[0],Decimal.valueOf(filedStr[1]));
                                            }
                                        }
                                    }else{
                                        for(String newStr : mapBusinessRules.get(oppQuoteMap.get(oppQuote.id).Id_Opportunity__r.type).Business_Rule_Value__c.split(',')){
                                            String[] filedStr = newStr.split('=');
                                            if(filedStr[0].toLowerCase().contains('name')){
                                                opp.put(filedStr[0],filedStr[1]);
                                            }else{
                                                opp.put(filedStr[0],Decimal.valueOf(filedStr[1]));
                                            }
                                        }
                                    }
                                    if(oppQuote.Non_Standard_Contract_Components__c!=null){
                                        opp.Non_Standard_Contract_Components__c=oppQuote.Non_Standard_Contract_Components__c;
                                    }
                                    listOppUpdates.add(opp);
                                }
                            }else{
                                if(mapBusinessRules.get('UpdateStageToIfReplacementQuote')!=null){
                                    Opportunity opp = new Opportunity(id=oppQuote.Id_Opportunity__c);
                                    for(String newStr : mapBusinessRules.get('UpdateStageToIfReplacementQuote').Business_Rule_Value__c.split(',')){
                                        String[] filedStr = newStr.split('=');
                                        if(filedStr[0].toLowerCase().contains('name')){
                                            opp.put(filedStr[0],filedStr[1]);
                                        }else{
                                            opp.put(filedStr[0],Decimal.valueOf(filedStr[1]));
                                        }
                                    }
                                    if(oppQuote.Non_Standard_Contract_Components__c!=null){
                                            opp.Non_Standard_Contract_Components__c=oppQuote.Non_Standard_Contract_Components__c;
                                        }
                                    listOppUpdates.add(opp);
                                    if(oppWithQC.isEmpty() || (!oppWithQC.isEmpty() && oppWithQC.get(oppQuote.Id_Opportunity__c)==null)){
                                        ReplacementOrderSettings__c rpsettings = ReplacementOrderSettings__c.getValues('UK');
                                        if(rpsettings.QualityCheckCaseSP__c!=null){
                                            Case cs = new Case(Opportunity__c=oppQuote.Id_Opportunity__c,AccountId=oppQuote.Id_Account__c);
                                            for(String fieldAndValue : rpsettings.QualityCheckCaseSP__c.split(',')){
                                                List<String> fields = fieldAndValue.split('=');
                                                cs.put(fields[0],fields[1]);
                                            }
                                            oppWithQC.put(oppQuote.Id_Opportunity__c,cs);
                                        }
                                    }
                                }

                            }   
                        }
                    }
                }
                update listOppUpdates;
                if(!oppWithQC.isEmpty()){
                    insert oppWithQC.values();
                }
            }

        }catch(Exception e){
            if(e.getDmlType(0)==StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                   listOppQuotes[0].addError(e.getDmlMessage(0));
                    return;
                }
            System.debug('Error: '+e.getMessage());
            listOppQuotes[0].addError(e.getMessage());
        }
    }

    public static void checkIfAlreadyAcceptedQuoteExist(List<Opportunity_Quote__c> listOppQuotes){
        Set<ID> opp = new Set<ID>();
        for(Opportunity_Quote__c oppQuote : listOppQuotes){
            if(!oppQuote.isReplacementQuote__c){
                opp.add(oppQuote.Id_Opportunity__c);
             }
        }
        for(Opportunity_Quote__c oppq : [select id,Id_Opportunity__c from Opportunity_Quote__c where Id_Opportunity__c in :opp and status__c='Accepted']){
            listOppQuotes[0].addError(Label.Opportunity_Quote_Save_Validation);
        }
    }


    @future
    public static void processLinkingOfAssetAndBranding(List<Id> quoteIds){
        Map<Id,Id> mapQlines = new Map<Id,Id>();
        System.debug('quoteIds: '+quoteIds);
        for(Opportunity_Quote_Line_Item__c oppQline : [select id,OldOppQuoteLineId__c from Opportunity_Quote_Line_Item__c where Id_Opportunity_Quote__c in : quoteIds and Id_Opportunity_Quote__r.Status__c='Accepted' and OldOppQuoteLineId__c!=null]){
            mapQlines.put(Id.valueOf(oppQline.OldOppQuoteLineId__c),oppQline.Id);
        }
        List<sObject> updateRecords = new List<sObject>();
        if(!mapQlines.isEmpty()){
            for(Asset__c ast : [select id,Id_Opportunity_Quote_Line_Item__c from Asset__c where Id_Opportunity_Quote_Line_Item__c in : mapQlines.keySet()]){
                ast.Id_Opportunity_Quote_Line_Item__c = mapQlines.get(ast.Id_Opportunity_Quote_Line_Item__c);
                updateRecords.add(ast); 
            }
            for(Branding_Content__c bdc : [select id,Id_Opportunity_Quote_Line_Item__c from Branding_Content__c where Id_Opportunity_Quote_Line_Item__c in : mapQlines.keySet()]){
                bdc.Id_Opportunity_Quote_Line_Item__c = mapQlines.get(bdc.Id_Opportunity_Quote_Line_Item__c);
                updateRecords.add(bdc);
            }
            update updateRecords;
        }
    }
    
    public static void premiumPlacementMultipleQuote(List<Opportunity_Quote__c> newQuotes){
        List<Id>OppIds = new List<ID>();
        List<opportunity_Quote__c> oppQuotes = new List<Opportunity_Quote__c>();
        Map<Id,Opportunity_Quote__C> oppQuoteMap = new Map<ID,Opportunity_Quote__c>();
        for(Opportunity_quote__c oq:newQuotes){
            if(LibRecordTypeHelper.getRecordTypeValue(oq.recordtypeid)=='UK_Opportunity_Quote')
                oppQuoteMap.put(oq.ID_Opportunity__c,oq);
            
        }
        if(!oppQuoteMap.isEmpty() && oppQuoteMap!=null) {
            for(opportunity_quote__C q:[select id,createddate,id_tarif__r.name,status__c,Id_Opportunity__c  from opportunity_quote__c where id_opportunity__c in:oppQuoteMap.keySet() and id_tarif__r.name='Premium Placement' and recordtype.developername='UK_Opportunity_Quote' and status__c!='Accepted' and status__c!='Declined']){
                if(oppQuoteMap.get(q.Id_opportunity__c)!=null && oppQuoteMap.get(q.Id_opportunity__c).Id!=q.id){
                    q.status__c='Expired';
                    system.debug('**update');
                    oppQuotes.add(q);
                }
            }
           update oppQuotes;  
        }   
    }
    
    public class TierOpportunityLineItemWrapper {
        public Opportunity_Line_Item__c lineItem;
        public List<Tier__c> tiers;

        public TierOpportunityLineItemWrapper(){
            tiers = new List<Tier__c>();
        }
    }

    public static void populateQuoteType(List<Opportunity_Quote__c> newQuotes){


        Set<Id> oppIdsSet = new Set<Id>();
        for(Opportunity_quote__c oq:newQuotes){
            oppIdsSet.add(oq.ID_Opportunity__c);
        }

        Map<Id,Opportunity> oppMap = Opportunity_Selector.getFromOppIdSet(oppIdsSet);
        Set<Id> oppIdsToCheckSet = new Set<Id>(); // Specific to FP Opportunity quote to check the premium placement line items

        Set<Id> oppIdsForPYSet = new Set<Id>(); // Specific to PY Opportunity quote to check the Logistic line items

        /* Adding variables to store countryname and recordtype name */
        List<String> recordTypeNamesList = new List<String>();
        List<String> countryNamesList = new List<String>();
        Map<String,String> oppRecordIdToUpdatedRecordtypeMap = new Map<String,String>();
        Set<Id> oppIdsForSubtype = new Set<Id>(); //SSC-1927
        Set<String> setOfCommissionTypes = new Set<String>(); //SSC-1927

        for(Opportunity_quote__c oq:newQuotes){
            if(String.isNotBlank(oppMap.get(oq.ID_Opportunity__C).Record_Country__c)){
                countryNamesList.add(oppMap.get(oq.ID_Opportunity__C).Record_Country__c);
            }
            /* For Chain Opportunities, checking the account recordtype to apply validation rules */
            String oppRecordTypeName = oppMap.get(oq.ID_Opportunity__C).RecordType.developername;
            if(oppRecordTypeName == 'Chain_Opportunity'){
                /* getting account recordtype and checking if validation rules are applicable */
                String accRecordTypeName = LibRecordTypeHelper.getRecordTypeValue(oppMap.get(oq.ID_Opportunity__C).Account.RecordTypeId);
                Business_Config__c chainOppBC = LibBusinessConfig.getBusinessConfigFromRuleMap('nintexForChainOpp',oppMap.get(oq.ID_Opportunity__C).RecordTypeId,accRecordTypeName);
                if(chainOppBC == null || chainOppBC.business_rule_value__c == null){
                    continue;
                }
                else{
                    oppRecordTypeName = chainOppBC.business_rule_value__c;
                    recordTypeNamesList.add(oppRecordTypeName);
                }
            }
            else{

                recordTypeNamesList.add(oppRecordTypeName);
            }
            oppRecordIdToUpdatedRecordtypeMap.put(oq.Id,oppRecordTypeName);

        }

        if(countryNamesList.isEmpty() || recordTypeNamesList.isEmpty()){
            return;
        }

        Map<String,Map<String,Map<String, Business_Config__c>>> fullBCMap =  LibBusinessConfig.getBCDataWithProAndCountryAndRecType('nintexQuoteFilters', countryNamesList, recordTypeNamesList);
        if(fullBCMap == null ||fullBCMap.isempty()){
            return;
        }

        for(Opportunity_quote__c oq:newQuotes){
            /* Adding temporary variables */
            Map<String,Map<String, Business_Config__c>> countryMap = fullBCMap.get(oppRecordIdToUpdatedRecordtypeMap.get(oq.Id));
            Map<String, Business_Config__c> mapBusinessRules = countryMap == null || countryMap.isempty() ? null : countryMap.get(oppMap.get(oq.ID_Opportunity__C).Record_Country__c) == null ? countryMap.get('ALL') : countryMap.get(oppMap.get(oq.ID_Opportunity__C).Record_Country__c);

            if(mapBusinessRules == null){
                continue;
            }



            String ruleName = '';
            String singleRule;
            List<String> rulesList = new List<String>();
            List<String> fieldNameList = new List<String>();

            //Getting first rule name to find the referenced field api names
            for(String brName : mapBusinessRules.keyset()){
                if(brName!='checkCommissionTypes') { //SSC-1927
                    singleRule = brName;
                    break;
                }
            }
            rulesList = singleRule.split(';');

            //Rules are defined in the format fieldapiname:fieldvalue. Thereby getting the api name before the the char ':'
            for(String rule : rulesList ){
                fieldNameList.add(rule.SubstringBefore(':'));
            }

            //Forming the entire rule name for the current quote
            for(String field : fieldNameList){
                ruleName += field + ':' + oppMap.get(oq.ID_Opportunity__C).get(field) + ';';
            }
            ruleName = ruleName.removeEnd(';');


            if(mapBusinessRules.containsKey(ruleName)){
                oq.Quote_type__c = mapBusinessRules.get(ruleName).Business_rule_value__c;
                oq.Template_Name__c = mapBusinessRules.get(ruleName).Business_rule_value__c;

                if(oppMap.get(oq.ID_Opportunity__C).RecordType.developername == 'FP_Opportunity' && String.valueOf(mapBusinessRules.get(ruleName).Business_rule_value__c).contains('checkArea')){
                    oppIdsToCheckSet.add(oq.id_opportunity__c);
                }
                if(oppMap.get(oq.ID_Opportunity__c).RecordType.developername == 'PY_Opportunity'){
                    oppIdsForPYSet.add(oq.id_opportunity__c);
                }
                //SSC-1927 Changes
                if(mapBusinessRules.containsKey('checkCommissionTypes')){
                    oppIdsForSubtype.add(oq.id_opportunity__c);
                    setOfCommissionTypes.add(String.valueOf(mapBusinessRules.get('checkCommissionTypes').Business_rule_value__c));
                }

            }



        }

        //Determining Opportunity Ids containing prepium placement line items - specific to FP recortype
        if(!oppIdsToCheckSet.isEmpty() ){
            Set<Id> ppOppIdsSet = new Set<Id>();
            for(Opportunity_Line_Item__c ol : OppLineItems_Selector.getLineitemsBasedOnSubtype('Premium Listing', oppIdsToCheckSet)){
                ppOppIdsSet.add(ol.Id_Opportunity__c);
            }

            for(Opportunity_quote__c oq:newQuotes){
                if(oq.Quote_type__c.contains('checkArea') && !ppOppIdsSet.contains(oq.ID_Opportunity__C)){
                    oq.Quote_type__c = oq.Quote_type__c.remove('checkArea');
                    oq.Template_Name__c = oq.Quote_type__c.remove('checkArea');

                }
            }
        }
        //Determining Opportunity Ids containing prepium placement line items

        //Determining Opportunity Ids containing Logistics Fee line items - specific to PY recortype
        if(!oppIdsForPYSet.isEmpty() ){
            Set<Id> pyOppIdsSet = new Set<Id>();
            for(Opportunity_Line_Item__c ol : OppLineItems_Selector.getLineitemsBasedOnSubtype('Logistics Fee', oppIdsForPYSet)){
                pyOppIdsSet.add(ol.Id_Opportunity__c);
            }
            for(Opportunity_Line_Item__c ol : OppLineItems_Selector.getLineitemsBasedOnSubtype('Commission Fee', oppIdsForPYSet)){
                pyOppIdsSet.add(ol.Id_Opportunity__c);
            }
            for(Opportunity_quote__c oq : newQuotes){
                if(!pyOppIdsSet.contains(oq.ID_Opportunity__c)){
                    oq.Quote_type__c = (oppMap.get(oq.ID_Opportunity__c).Business_Type__c == 'New Business') ? 'PY Non-Commission' : 'PY Non-Commission Upgrade';
                    oq.Template_Name__c = (oppMap.get(oq.ID_Opportunity__c).Business_Type__c == 'New Business') ? 'PY Non-Commission' : 'PY Non-Commission Upgrade';
                }
            }

        }
        //SSC-1927: Determining Opportunity Ids containing sub types line items - specific to AT recortype
        if(!oppIdsForSubtype.isEmpty() && !setOfCommissionTypes.isEmpty()){
            Set<Id> atOppIdsSet = new Set<Id>();

            for(Opportunity_Line_Item__c ol : OppLineItems_Selector.getLineItemsBasedOnSubtypesAndOppty(setOfCommissionTypes, oppIdsForSubtype)){
                atOppIdsSet.add(ol.Id_Opportunity__c);
            }
            for(Opportunity_quote__c oq:newQuotes){
                if(oq.Quote_type__c.contains('LogicticsFee') && !atOppIdsSet.contains(oq.ID_Opportunity__C)){
                    oq.Quote_type__c = oq.Quote_type__c.remove('LogicticsFee');
                }
            }
        }
        //SSC-1927: Determining Opportunity Ids containing sub types line items - specific to AT recortype

    }

    // **
    // * @author        : Sundra Anand
    // * @date          : 27.01.20
    // * @description   : Method to void envelope when Quote status is Declined.
    // * @return        : void
    // **
    public static void voidDocuSignOnDeclined(List<Opportunity_Quote__c> newQuotes, Map<Id,Opportunity_Quote__c> oldMap){

        Set<Id> quoteIdsSet = new Set<Id>();
        for(Opportunity_quote__c oq : newQuotes){
            if( oq.Status__c == 'Declined' && oq.Status__c != oldMap.get(oq.id).Status__c){
                quoteIdsSet.add(oq.Id);
            }
        }

        if(!quoteIdsSet.isEmpty())
            DocuSignUtilityController.voidEnvelopeBuilder(quoteIdsSet,null,'Quote Declined');
    }
    /*********************************************************************************************
    *   @description        : Populate National Id on Contact after entered by docusign user on document
    *   @param                sobjects List<SObject>
    *   @param                oldSobjectMap Map<Id,SObject>
    *   @return             : null
    *   @jira               : SSC-2815
    */
    public static void updateNationalIdOnContact(List<SObject> sobjects, Map<Id,SObject> oldSobjectMap) {
        List<Opportunity_Quote__c> newListOpptyQuote = (List<Opportunity_Quote__c>) sobjects;
        Map<Id, Opportunity_Quote__c> oldMapBankDetail = (Map<Id, Opportunity_Quote__c>) oldSobjectMap;
        Map<Id,String> mapOfAccountIdWithNationalNumber = new Map<Id,String>();
        for (Opportunity_Quote__c opptyQuoteObj : newListOpptyQuote) {
            if(opptyQuoteObj.National_Id_Number__c!=null && opptyQuoteObj.Id_Account__c!=null
                    && opptyQuoteObj.National_Id_Number__c!=oldMapBankDetail.get(opptyQuoteObj.id).National_Id_Number__c){
                mapOfAccountIdWithNationalNumber.put(opptyQuoteObj.Id_Account__c,opptyQuoteObj.National_Id_Number__c);
            }
        }
        if(!mapOfAccountIdWithNationalNumber.values().IsEmpty()) {
            updateContactPassportNumber(mapOfAccountIdWithNationalNumber);
        }
    }
    /*********************************************************************************************
    *   @description        : This method update the contact Passport Number
    *   @param                mapOfAccountIdWithNationalNumber Map<Id, String>
    *   @return             : null
    *   @jira               : SSC-2815
    */
    private static void updateContactPassportNumber(Map<Id,String> mapOfAccountIdWithNationalNumber){
        try{
            List<Contact> listOfContactToUpdate = new List<Contact>();
            for(Contact contactObj : ContactSelector.fetchContactsWithOwnerRole(mapOfAccountIdWithNationalNumber.keyset())){
                contactObj.Passport_ID_Number__c =mapOfAccountIdWithNationalNumber.get(contactObj.AccountId);
                listOfContactToUpdate.add(contactObj);
            }
            if(!listOfContactToUpdate.isEmpty()){
                String recordIds = '';
                Boolean isError = false;
                LoggingUtility.createLog(TRGQUOTEPROCESSOR,APEX_CLASS,METHOD_UPDATE_CONTACT_PASS_NUMBER,null);
                List<Database.SaveResult> results = Database.update(listOfContactToUpdate,false);
                for (Database.SaveResult resultObj : results) {
                    if (!resultObj.isSuccess()){
                        isError = true;
                        for (Database.Error iError : resultObj.getErrors()){
                            recordIds += resultObj.getId() + ':' + iError.getMessage() + ';';
                        }
                    }
                }
                if(isError){
                    LoggingUtility.logError(TRGQUOTEPROCESSOR,ERROR_MSG);
                    LoggingUtility.log(TRGQUOTEPROCESSOR,recordIds);
                    LoggingUtility.commitLogs();
                }
            }
        }
        catch (Exception excptnObj) { ClsLogErrorMessage.logMessages(ERROR_UPDATE_CONTACT_FAILED,
                METHOD_UPDATE_CONTACT_PASS_NUMBER + excptnObj.getMessage() + excptnObj.getStackTraceString());
        }
    }
}
