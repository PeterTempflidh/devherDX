/**
 * File:        Add_On_Service_Helper.cls<br/> 
 * Project:     Tariff Management Refactoring <br/>
 * Date:        November 17, 2017<br/>
 * Created By:  <br/>
 * *************************************************************************<br/>
 * Description:  Helper for the logic inside of the Add on service Trigger<br/>
 * *************************************************************************<br/>
 * History:<br/>
 * Date:                Modified By:            Description:<br/>
 * 12-May-2020          Danish Farooq        Add "Activated Successfully" check in asset query for creation of onboarding case during asset activation
 *                                                SSC-1698
 * 22-Jun-2020          Danish Farooq           Check the close case from Business Config
 * 
 */
public without sharing class Add_On_Service_Helper {
     private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
	
	private List<Add_on_Service__c> lstAddOnUpdate;
	public static set<ID> stAlreadyProdcess = new set<ID>();
	/**
	* @author william Castillo
	* @date November 17, 2017
	* @description SP-1619, Control creation Add ons.
	* @param lstAddOnNew, the new records from trigger. 
	*/		
  public void ControlCreationAddOn(list<Add_on_Service__c > lstAddOnNew) {
  	

  	map<string,List<Add_on_Service__c>> mpAddOnByAcc = new map<string,List<Add_on_Service__c>>();
  	List<Add_on_Service__c> lstAddSer = new List<Add_on_Service__c>();
  	//Add_on_Service__c addOnCurrent = new Add_on_Service__c();
  	lstAddOnUpdate = new List<Add_on_Service__c>();
  	set<ID> stAcc = new set<ID>();
  	
  	map<String,List<Add_on_Service__c>> mpAccByAddOn = new map<String,List<Add_on_Service__c>>();
  	
  	for(Add_on_Service__c addOnCurrent : lstAddOnNew){
  		stAcc.add(addOnCurrent.Account_Name__c);
  		if(mpAccByAddOn.containsKey(addOnCurrent.Account_Name__c+'-'+addOnCurrent.Id_List_Add_On__c)){
  			for(Add_on_Service__c addOn:  mpAccByAddOn.get(addOnCurrent.Account_Name__c+'-'+addOnCurrent.Id_List_Add_On__c)){
	  			ValidateAddOn (addOnCurrent,addOn,true);				
  			}
  			mpAccByAddOn.get(addOnCurrent.Account_Name__c+'-'+addOnCurrent.Id_List_Add_On__c).add(addOnCurrent);
  			
  		}else{
  			mpAccByAddOn.put(addOnCurrent.Account_Name__c+'-'+addOnCurrent.Id_List_Add_On__c,new list<Add_on_Service__c>{addOnCurrent});
  		}
  	}
  	
  	mpAddOnByAcc = getAddOnByAccount(stAcc);
  	
  	for(Add_on_Service__c addOnCurrent : lstAddOnNew){
  		if(mpAddOnByAcc.containsKey(addOnCurrent.Account_Name__c+'-'+addOnCurrent.Id_List_Add_On__c)){
  			system.debug('-->'+addOnCurrent.Account_Name__c+'-'+addOnCurrent.Id_List_Add_On__c);
  			for(Add_on_Service__c addOn: mpAddOnByAcc.get(addOnCurrent.Account_Name__c+'-'+addOnCurrent.Id_List_Add_On__c)){
				ValidateAddOn (addOnCurrent,addOn,false);			
  			}
 		}
  		
  	}
 	
  	if(lstAddOnUpdate.size()>0){
  		update lstAddOnUpdate;
  	}
  	
  }
  


  /**
	* @author william Castillo
	* @date November 17, 2017
	* @description VAlidate the Add on with the criterial on SP-1619
	* @param Add_on_Service__c addOnCurrent
			 Add_on_Service__c addOn
			 boolean newRecord - indicate that the record is new or an existing record on the database
	*/
  private void ValidateAddOn(Add_on_Service__c addOnCurrent, Add_on_Service__c addOn, boolean newRecord){
  	
		if(addOnCurrent.Opportunity__c == null){ // The current add on in the trigger is not contractual
			if(addOn.Opportunity__c != null){
 				if(addOn.Status__c != 'Terminated'
	  				&& (addOnCurrent.Id == null ||  addOnCurrent.Id != addOn.Id)){
		  			addOnCurrent.Id_List_Add_On__c.addError(Label.Add_On_trigger_error_1 +' '+addOn.Id_List_Add_On__r.Name +Label.Add_On_trigger_error_2); 
					addOnCurrent.addError(Label.Add_On_trigger_error_1 +' '+ addOn.Id_List_Add_On__r.Name +Label.Add_On_trigger_error_2); 
					
					if(newRecord){
		  				addOn.Status__c.addError(Label.Add_On_trigger_error_3 +' '+addOn.Id_List_Add_On__c +Label.Add_On_trigger_error_4); 
						addOn.addError(Label.Add_On_trigger_error_3 +' '+ addOn.Id_List_Add_On__c +Label.Add_On_trigger_error_4); 						
					}
				}
  			}else{
  				if(addOnCurrent.Status__c == 'Active' && addOn.Status__c == 'Active'
                  && (addOnCurrent.Id == null ||  addOnCurrent.Id != addOn.Id)){
  					
			  		addOnCurrent.Status__c.addError(Label.Add_On_trigger_error_3 +' '+addOn.Id_List_Add_On__r.Name +Label.Add_On_trigger_error_4); 
					addOnCurrent.addError(Label.Add_On_trigger_error_3 +' '+ addOn.Id_List_Add_On__r.Name +Label.Add_On_trigger_error_4); 
					
					
					if(newRecord){
						addOn.Status__c.addError(Label.Add_On_trigger_error_3 +' '+addOn.Id_List_Add_On__c +Label.Add_On_trigger_error_4); 
						addOn.addError(Label.Add_On_trigger_error_3 +' '+ addOn.Id_List_Add_On__c +Label.Add_On_trigger_error_4); 						
					}
	  			}
  			}
  		}else{
  			if(addOnCurrent.Status__c == 'Active'
  			&& (addOnCurrent.Status__c != 'Terminated' &&  addOn.Status__c != 'Terminated')
  			&& (addOnCurrent.Id == null ||  addOnCurrent.Id != addOn.Id)){
  				
				if(newRecord){
  					addOn.addError(Label.Add_On_trigger_error_5 +addOn.Id_List_Add_On__c);
					addOnCurrent.addError(Label.Add_On_trigger_error_5+addOnCurrent.Id_List_Add_On__c);					
				}else{
	  				addOn.Status__c = 'Terminated';
	  				if(!stAlreadyProdcess.contains(addOn.id)){
	  					lstAddOnUpdate.add(addOn);	
	  				}
				}
  			}
  		} 	
  }  
  
  /**
	* @author william Castillo
	* @date November 17, 2017
	* @description get in a Map the Add ons by Account
	* @param set<ID> stAccId set the Id from the account that we wanna request. 
	*/
  private map<string,List<Add_on_Service__c>> getAddOnByAccount(set<ID> stAccId){
  	
  	map<string,List<Add_on_Service__c>> mpAddOnByAcc = new map<string,List<Add_on_Service__c>>();
  	List<Add_on_Service__c> lstAddOnTmp = new List<Add_on_Service__c>();
  	
  	for(Add_on_Service__c addOn : queryAddOnByAccount(stAccId)){
  		if(mpAddOnByAcc.containsKey(addOn.Account_Name__c+'-'+addOn.Id_List_Add_On__c)){
  			mpAddOnByAcc.get(addOn.Account_Name__c+'-'+addOn.Id_List_Add_On__c).add(addOn);
  		}else{
  			mpAddOnByAcc.put(addOn.Account_Name__c+'-'+addOn.Id_List_Add_On__c,new List<Add_on_Service__c> {addOn});
  		}
  	}
  	
  	return mpAddOnByAcc;
  }
  
   private List<Add_on_Service__c> queryAddOnByAccount(set<ID> stAccId){
  	return [SELECT Account_Name__c,Activated_Date__c,Exclusive_with_us__c,Id,Id_List_Add_On__c,
  					Name,Opportunity__c,Quantity__c,RecordTypeId,Start_Date__c,Status__c,Type__c,
  					Id_List_Add_On__r.Name
  			FROM Add_on_Service__c
  			WHERE Account_Name__c =:stAccId];
  }
    public void OpportunityUpdateAddonByStatusChange(List<Add_on_Service__c> newList, Map<Id, Add_on_Service__c> oldMap){

        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('OnboardingCaseCreationAfterAddOnActivationProcess');
        Map<String, Business_Config__c> mapBusinessRule;
        Set<String> stActiveStatus;
        map<Id,Add_on_Service__c> newMpAddonCreatedOnBoarding = new map<Id,Add_on_Service__c>();
        map<String,Opportunity> mpUpdateOpp = new map<string,Opportunity>();
        set<Id> oppAddonSt = new set<Id>();
        set<Id> stOppAddon = new set<Id> ();
        Set<Id> oppWithAddOns = new Set<Id>();
        Set<Id> oppWithAssets = new Set<Id>();
        Set<Id> oppWithCases = new Set<Id>();
    set<id> oppWithUndeliveredShipments = new Set<Id>();
        set<Id> oppPending = new Set<Id>();

        set<String> stStatus = new set<String>();
        stStatus.add('Delivered');
        stStatus.add('Activated Successfully'); //SSC-1698

        if(mapBusinessLogic != null){


            for (Add_on_Service__c addOnService : newList) {
                mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(addOnService.RecordTypeId));
                if(mapBusinessRule != null && mapBusinessRule.containsKey('ActiveStatuses')) {
                    stActiveStatus = new Set<String>(mapBusinessRule.get('ActiveStatuses').Business_Rule_Value__c.split(','));
                    if (stActiveStatus.contains(addOnService.Status__c) &&
                            (oldMap == null || addOnService.Status__c != oldMap.get(addOnService.id).Status__c)) {
                        stOppAddon.add(addOnService.opportunity__c);
                    }
                }
            }

            oppWithAddOns = LibHelper.checkForNonActiveAddon(stOppAddon);
            oppWithAssets = LibHelper.checkForInactiveAsset(stOppAddon,stStatus);
            oppWithCases  = LibHelper.checkForOpencase(stOppAddon);
            oppWithUndeliveredShipments = LibHelper.checkForUndeliveredShipments(stOppAddon);

            for (Opportunity opp : Opportunity_Selector.getOpportunityByIdStage(stOppAddon,'Delivery Pending')){
                oppPending.add(opp.id);
            }

            for(string strId : stOppAddon){
                if(!oppWithAddOns.contains(strId)
                        &&!oppWithAssets.contains(strId)
                        &&!oppWithCases.contains(strId)
                        &&!oppWithUndeliveredShipments.contains(strId)
                        &&!oppPending.contains(strId)){
                    If(mapBusinessRule.ContainsKey('StageOpportunity') ){
                        mpUpdateOpp.put(strId, new Opportunity(id = strId, StageName = mapBusinessRule.get('StageOpportunity').Business_Rule_Value__c));
                    }
                }
            }


            if(mpUpdateOpp.size()>0){
                try{
                  update mpUpdateOpp.Values();
                }catch (Exception e){
                    LoggingUtility.logError(Add_On_Service_Helper.class.getName(),'Error => ' + e.getMessage() + '\nLine Number : ' + e.getLineNumber());
                }

            }
        }

    }

   public void updateOppOnAddOnActivation(List<Add_On_Service__c> addOnServiceLst, Map<Id,Add_On_Service__c>addOnMap){

       try {
           Map<String, Map<String, Business_Config__c>> mapProcessData = moam.get('AddOnActivation');
           Set<Id> oppIds = new set<Id>();
           Map<ID, Map<string, List<string>>> mapOfCloseCaseConditions = new Map<ID, Map<string, List<string>>>();
           boolean hasBusinessConfig = false;

           // checks for null values
           if (mapProcessData == null || mapProcessData.isEmpty()) {
               return;
           }

           Map<String, Business_Config__c> mapBusinessData;
           string jsonString = '';

           for (Add_On_Service__c iAddOn : addOnServiceLst) {

               String recordTypeId = LibRecordTypeHelper.getRecordTypeValue(iAddOn.RecordTypeId);
               hasBusinessConfig = String.isNotBlank(recordTypeId) &&
                       mapProcessData.get(recordTypeId) != null &&
                       !mapProcessData.get(recordTypeId).isEmpty();

               if (!hasBusinessConfig) {
                   continue;
               }

               mapBusinessData = mapProcessData.get(recordTypeId);

               hasBusinessConfig = mapBusinessData.get('CheckForAddon') != null &&
                       Boolean.valueOf(mapBusinessData.get('CheckForAddon').Business_Rule_Value__c) &&
                       !iAddOn.status__c.equals(addOnMap.get(iAddOn.id).status__c) &&
                       iAddOn.status__c.equals(mapBusinessData.get('AddOnActivationStatus').Business_Rule_Value__c);

               if (hasBusinessConfig) {
                   oppIds.add(iAddOn.Opportunity__c);
               }
               hasBusinessConfig = mapBusinessData.containsKey(Constants.BUSINESSCONIFG_RULENAME_CHECKCLOSEDCASES) &&
                       !mapOfCloseCaseConditions.containsKey(iAddOn.Opportunity__c);

               if (!hasBusinessConfig) {
                   continue;   
               }
               jsonString = mapBusinessData.get(Constants.BUSINESSCONIFG_RULENAME_CHECKCLOSEDCASES).Business_Rule_Value__c;
               Map<string, List<string>> mapOfCaseOfConfig = (Map<string, List<string>>) JSON.deserialize(jsonString, Map<string, List<string>>.class) ;
               mapOfCloseCaseConditions.put(iAddOn.Opportunity__c, mapOfCaseOfConfig);
           }

           if (oppIds.isEmpty()) {
               return;
           }
           oppIds = checkCloseCase(mapOfCloseCaseConditions, oppIds);

           if (oppIds.isEmpty()) {
               return;
           }
           oppIds = checkAssetsAddOnFilter(oppIds,addOnServiceLst);

           if (oppIds.isEmpty()) {
               return;
           }

           set<id> oppWithUndeliveredShipments = new Set<Id>();
           oppWithUndeliveredShipments = LibHelper.checkForUndeliveredShipments((Set<Id>) JSON.deserialize(JSON.serialize(oppIds), Set<Id>.class));
           oppIds.removeAll((Set<Id>) JSON.deserialize(JSON.serialize(oppWithUndeliveredShipments), Set<Id>.class));

           if (oppIds.isEmpty()) {
               return;
           }

           List<Opportunity> opptyLst = Opportunity_Selector.getOpportunityByIdStage(oppIds,'Closed Won');
           for (Opportunity iOpportunity : opptyLst) {
               iOpportunity.stageName = 'Closed Won';
           }

           if (!opptyLst.isEmpty()) {
               update opptyLst;
           }
       }
       catch(DmlException dmlException){
           string recordErrorMessage = '';
           for (Integer index = 0; index < dmlException.getNumDml(); index++) {
               recordErrorMessage += dmlException.getDmlMessage(index) + '\n';
           }
           LoggingUtility.logError(Add_On_Service_Helper.class.getName(),'Error => ' + dmlException.getMessage() +
               '\nLine Number : ' + dmlException.getLineNumber() +
               '\nStack Trace : ' + dmlException.getStackTraceString() +
                '\nRecordFailingMsg :'   + recordErrorMessage);
       }
       catch(QueryException queryException){
           LoggingUtility.logError(Add_On_Service_Helper.class.getName(),'Error => ' + queryException.getMessage() +
                                   '\nLine Number : ' + queryException.getLineNumber() +
                                    '\nStack Trace : ' + queryException.getStackTraceString());
       }
       catch(Exception ex){
           LoggingUtility.logError(Add_On_Service_Helper.class.getName(),'Error => ' + ex.getMessage() +
                   '\nLine Number : ' + ex.getLineNumber() +
                   '\nStack Trace : ' + ex.getStackTraceString());
       }
   }
    /**
   * @description this method checks for all Active Assets, Branding Content and AddOns
   * @param setOfOppty contains set Of Opportunity which cases are closed
   * @param addOnServiceLst contains current add Ons which are active
   * @return set of opportunities
   * Jira Ticket SSC-3462
   */
    private set<Id> checkAssetsAddOnFilter(set<Id> setOfOppty,  List<Add_on_Service__c> addOnServiceLst){

        Set<Id> assetActivatedSet = new Set<Id>();
        List<Asset__c> assetLst =  AssetSelector.getAssetByStatus(setOfOppty, new Set<string> { Constants.ASSET_STATUS_ACTIVATED_SUCCESSFULLY });
        for (Asset__c iAssetObj : assetLst) {
            assetActivatedSet.add(iAssetObj.opportunity__c);
        }

        if(assetActivatedSet.isEmpty()){
            return assetActivatedSet;
        }

        Set<Id> setOfBrandingStatusOpptys = new Set<Id>();
        for (Branding_Content__c iBrandingContent : BrandingContent_Selector.getBrandingByOpptyId(assetActivatedSet,'White Label',
                                                    new Set<string> { Constants.BRANDINGCONTENT_STATUS_INSTALLED_SUCCESSFULLY })) {
            setOfBrandingStatusOpptys.add(iBrandingContent.Opportunity__c);
        }
        if(setOfBrandingStatusOpptys.isEmpty()){
            return setOfBrandingStatusOpptys;
        }
        Set<Id> setOfActiveAddOns = new Set<Id>();

        for (Add_On_Service__c iAddOns : Add_On_Service_Selector.getAddOnServicesByOppty(setOfBrandingStatusOpptys,
                                                                                      new Set<string> { 'Active'})){
            setOfActiveAddOns.add(iAddOns.opportunity__c);

        }
        return setOfActiveAddOns;
    }
    /**
    * @description this method checks that all the related cases for that opportunity are closed or not.
    * @param mapOfCloseCaseConditions contains close case conditions which are defined in business config
    * @param oppIdsList contains opportunity list
    * @return set of opportunity list which all cases are closed
    * Jira Ticket SSC-3462
    */
   private set<Id> checkCloseCase(Map<ID,Map<string,List<string>>> mapOfCloseCaseConditions,
                                  Set<Id> oppIdsList){
       boolean isClosedCase = false;
       Map<string,List<string>> mapOfCaseConfig;

       for (Case iCaseObj : ClsCaseSelector.getCaseInOpportunitiesOrderASC(oppIdsList)) {

           //if opportunity is remove from set then don't iterate for that opportunity
           if(!oppIdsList.contains(iCaseObj.Opportunity__c)){
               continue;
           }
           mapOfCaseConfig = mapOfCloseCaseConditions.containsKey(iCaseObj.Opportunity__c) ?
                             mapOfCloseCaseConditions.get(iCaseObj.Opportunity__c) : new Map<string,List<string>>();

           if(mapOfCaseConfig.isEmpty()){
               continue;
           }

           isClosedCase = iCaseObj.Status.equals(Constants.CASE_STATUS_CLOSE) &&
                          mapOfCaseConfig.containsKey(iCaseObj.Type) &&
                          (string.isBlank(iCaseObj.Closed_Reason__c) ? true :  mapOfCaseConfig.get(iCaseObj.Type).contains(iCaseObj.Closed_Reason__c));

           if(!isClosedCase){
               oppIdsList.remove(iCaseObj.Opportunity__c);
           }
       }
       return oppIdsList;
   }



}