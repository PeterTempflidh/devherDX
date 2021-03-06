/**
 * Class CaseHandler
 *
 * Trigger Handler for the Case SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public without sharing class ClsCaseHandler
        implements ITrigger
{

    private static Map<Id, Id> accountOwnerIdMap = new Map<Id, Id>();

    private List<CaseShare> childParentInsertShares = new List<CaseShare>();
    private List<CaseShare> childParentDeleteShares = new List<CaseShare>();
    private List<Case> escalationCasesToInsert = new List<Case>();
    private Boolean hasElastixPermissionSet = false;

    // Constructor
    public ClsCaseHandler()
    {
        if(userinfo.getUserName().startsWith('api.elastix')){
            hasElastixPermissionSet = true;
        }
    }

    /**
     * bulkBefore
     *
     * This method is called for before trigger
     */
    public void bulkBefore()
    {
        if(hasElastixPermissionSet){
            DH_InboundCaseProcessor.setElastixCaseOwner(Trigger.New);
        }
        else {	
			accountOwnerIdMap = ClsCaseProcessor.fetchOwnerInfo(Trigger.New);

			ClsCaseProcessor.validateSharedMenu(Trigger.new, (Map<Id,Case>) Trigger.oldMap);
			ClsCaseProcessor.captureAccountOnCase(Trigger.new);
			ClsCaseProcessor.validateQualityCheckClosing(Trigger.new, (Map<Id,Case>) Trigger.oldMap);
			DH_InboundCaseProcessor.backToQueueLogic((List<Case>)Trigger.new,(Map<Id,Case>)Trigger.oldMap);
			DH_InboundCaseProcessor.fieldValidations(Trigger.new,(Map<Id,Case>)Trigger.oldMap);

			if (Trigger.isInsert)
			{
				 // SSC - 2547 block duplicate retention case for PY internal 
				ClsCaseProcessor.blockAnotherRetentionCaseCreationForAccount(Trigger.new);
				
				if(null != accountOwnerIdMap && !accountOwnerIdMap.isEmpty())
				ClsCaseProcessor.populateContactOwnerIdOnCase(Trigger.New, accountOwnerIdMap);
				 
			   
				clsCaseProcessor.prepMenuUpdateMjr(Trigger.new);
				clsCaseProcessor.setOwnerOfMenuCase(Trigger.new);
				LibBusinessConfig.setCaseCurrencyAndCompanyCodeFromAccount(Trigger.new);
				DH_InboundCaseProcessor.caseSetups((List<Case>)Trigger.new,(Map<Id,Case>)Trigger.oldMap); //SCC-41&SCC-101


			}else if(Trigger.isUpdate)
			{
				clsCaseProcessor.setOwnerOfMenuCase(Trigger.new);
				LibBusinessConfig.setCaseCurrencyAndCompanyCodeFromAccount(Trigger.new);
				ClsCaseProcessor.updateCaseAge((List<Case>)Trigger.new,(Map<Id,Case>)Trigger.oldMap);
				escalationCasesToInsert = DH_InboundCaseProcessor.escalateCase((List<Case>)Trigger.new,(Map<Id,Case>)Trigger.oldMap,(Map<Id,Case>)Trigger.newMap);
				DH_InboundCaseProcessor.caseSetups((List<Case>)Trigger.new,(Map<Id,Case>)Trigger.oldMap); //SCC-41&SCC-101

			}else if(Trigger.isDelete){

			}
		}
    }

    public void bulkAfter()
	{
		if(!hasElastixPermissionSet) {			
			Map<String,List<CaseShare>> apexSharingRecords = new Map<String,List<CaseShare>>();
			if (Trigger.isInsert)
			{
				//to check if it works without this
				clsCaseProcessor.updateAccountOnlineStatus((List<Case>)Trigger.new,null);
				// SSC - 2547 update Account status for PY internal retention case 
				clsCaseProcessor.updateAccountStatusForRetentionCase((List<Case>)Trigger.new,null);
				apexSharingRecords = ClsCaseProcessor.childToParentCaseShare(false,(Map<Id,Case>)Trigger.newMap,(Map<Id,Case>)Trigger.oldMap);
				if(apexSharingRecords.get('insert')!=null && apexSharingRecords.get('insert').size()>0) {
					childParentInsertShares.addAll(apexSharingRecords.get('insert'));
				}
				if(apexSharingRecords.get('delete')!=null && apexSharingRecords.get('delete').size()>0) {
					childParentDeleteShares.addAll(apexSharingRecords.get('delete'));
				}

				clsCaseProcessor.menuChangeMajorWithImageCreateCase(Trigger.new);

			}else if(Trigger.isUpdate)
			{
				ClsCaseProcessor.updateAccountOnlineStatus((List<Case>)Trigger.new,(Map<Id,Case>) Trigger.oldMap);
				// SSC - 2547 update Account status for PY internal retention case 
				clsCaseProcessor.updateAccountStatusForRetentionCase((List<Case>)Trigger.new,(Map<Id,Case>)Trigger.oldMap);
				ClsCaseProcessor.nonContractedMenuChange((List<Case>)Trigger.new);
				ClsCaseProcessor.menuProcessingClosingAction((List<Case>)Trigger.new,(Map<Id,Case>) Trigger.oldMap);
				ClsCaseProcessor.terminationCaseFlow((List<Case>)Trigger.new,(Map<Id,Case>) Trigger.oldMap);
				ClsCaseProcessor.retentionCaseFlow((List<Case>)Trigger.new,(Map<Id,Case>) Trigger.oldMap);
				ClsCaseProcessor.qualityCheckClosingAction((List<Case>)Trigger.new,(Map<Id,Case>) Trigger.oldMap);
				ClsCaseProcessor.NonContractedMenuProcessingClosingAction((List<Case>)Trigger.new,(Map<Id,Case>) Trigger.oldMap);
				ClsCaseProcessor.dishLevelProcessClosingAction((List<Case>)Trigger.new,(Map<Id,Case>)Trigger.oldMap);
				ClsCaseProcessor.photoListingProcessClosingAction((List<Case>)Trigger.new,(Map<Id,Case>)Trigger.oldMap);
				ClsCaseProcessor.onboardingCaseClosingAction((List<Case>)Trigger.new,(Map<Id,Case>) Trigger.oldMap);
				ClsCaseProcessor.inboundUKPPUpdateMidasAPI((List<Case>)Trigger.new,(Map<Id,Case>) Trigger.oldMap);
				ClsCaseProcessor.qualityCheckReplacementClosingAction((List<Case>)Trigger.new,(Map<Id,Case>) Trigger.oldMap);
				ClsCaseProcessor.backendShippingCaseClosure((List<Case>)Trigger.new,(Map<Id,Case>) Trigger.oldMap);
				ClsCaseProcessor.brandingCaseClosure((List<Case>)Trigger.new,(Map<Id,Case>) Trigger.oldMap);
				ClsCaseProcessor.processFailedOnboarding((List<Case>)Trigger.new);
				clsCaseProcessor.menuChangeMajorWithImageCloseCase(Trigger.new);

				if(!Test.isRunningTest()){
					apexSharingRecords = ClsCaseProcessor.childToParentCaseShare(true,(Map<Id,Case>)Trigger.newMap,(Map<Id,Case>)Trigger.oldMap);
					if(apexSharingRecords.get('insert')!=null && apexSharingRecords.get('insert').size()>0) {
						childParentInsertShares.addAll(apexSharingRecords.get('insert'));
					}
					if(apexSharingRecords.get('delete')!=null && apexSharingRecords.get('delete').size()>0) {
						childParentDeleteShares.addAll(apexSharingRecords.get('delete'));
					}
				}


			}else if(Trigger.isDelete){

			}
		}
    }

    public void beforeInsert(SObject so)
    {
    }

    public void beforeUpdate(SObject oldSo, SObject so)
    {
      
    }

    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so)
    {


    }

    public void afterInsert(SObject so)
    {

    }

    public void afterUpdate(SObject oldSo, SObject so)
    {
 
    }

    public void afterDelete(SObject so)
    {
    }

    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally()
    {
        try {
            if (childParentInsertShares != null && childParentInsertShares.size() > 0) {
                insert childParentInsertShares;
            }
            if (childParentDeleteShares != null && childParentDeleteShares.size() > 0) {
                delete childParentDeleteShares;
            }
            if(!DH_InboundCaseProcessor.triggerEscalation && escalationCasesToInsert.size() > 0){
				DH_InboundCaseProcessor.triggerEscalation = TRUE;
                List<Database.SaveResult> srList = database.insert(escalationCasesToInsert);
                for (Integer i = 0; i < srList.size(); i++) {
                    if (!srList[i].isSuccess()) {
                        system.debug(LoggingLevel.ERROR, 'Exception: '+srList[i].errors);
                        trigger.newMap.get(escalationCasesToInsert[i].ParentId).put('Status',trigger.oldMap.get(escalationCasesToInsert[i].ParentId).get('Status'));
                        trigger.newMap.get(escalationCasesToInsert[i].ParentId).put('Escalate__c',false);
                        trigger.newMap.get(escalationCasesToInsert[i].ParentId).addError(Label.Case_Escalation_Error);
                    }
                }
            }
        } catch(Exception e){
            if(escalationCasesToInsert.size() > 0){
                for(Case escalationFailed:escalationCasesToInsert){
                    trigger.newMap.get(escalationFailed.ParentId).put('Status',trigger.oldMap.get(escalationFailed.ParentId).get('Status'));
                    trigger.newMap.get(escalationFailed.ParentId).put('Escalate__c',false);
                    trigger.newMap.get(escalationFailed.ParentId).addError(Label.Case_Escalation_Error);
                }
            }
            system.debug(LoggingLevel.ERROR, 'Exception:::: '+e+' **** Line Number:::: '+e.getStackTraceString());
        }

    }
}