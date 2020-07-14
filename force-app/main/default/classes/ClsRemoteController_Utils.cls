/**
* @author Mantas Jurkunas
* @date 26.07.2019
*
* @description Utility class for ClsRemoteController
* @see ClsRemoteController
*/

public with sharing class ClsRemoteController_Utils {

    /**
     * @description Check if there should be a person in charge assigned and if he is assigned.
     *
     * @param mapProcessData
     * @param theCase
     *
     * @return True if the person in charge should be assigned, but is not.
     */
    public static Boolean personInChargeNotAssigned( final Map<String, Business_Config__c> mapProcessData, final Case theCase ) {
        final Boolean checkForPersonInCharge = mapProcessData.get('chkForPersonInCharge') != null
                && Boolean.valueOf(mapProcessData.get('chkForPersonInCharge').Business_Rule_Value__c)
                && mapProcessData.get('personInchargeMap') != null;

        if (!checkForPersonInCharge) {
            return false;
        }
        Map<String, String> personInchargeTochk = (Map<String, String>) JSON.deserialize(mapProcessData.get('personInchargeMap').Business_Rule_Value__c, Map<String, String>.class);
        final Boolean personInChargeNotAssigned =  personInchargeTochk != null
                && !personInchargeTochk.isEmpty()
                && personInchargeTochk.containsKey(theCase.Status)
                && theCase.get(personInchargeTochk.get(theCase.Status)) == null;

        return personInChargeNotAssigned;
    }

    /**
     * @description Update case field, specific for the process, defined in business config.
     *
     * @param mapProcessData
     * @param theCase
     *
     * @return Case with the updated field.
     */
    public static Case updateCaseField( final Map<String, Business_Config__c> mapProcessData, Case theCase ) {
        Map<String, String> fieldStatusMap = new Map<String, String>();
        if (mapProcessData.get('fieldMap') != null) {
            fieldStatusMap = (Map<String, String>) JSON.deserialize(mapProcessData.get('fieldMap').Business_Rule_Value__c, Map<String, String>.class);
        }
        if (fieldStatusMap != null && !fieldStatusMap.isEmpty() && fieldStatusMap.containsKey(theCase.Status)) {
            theCase.put(fieldStatusMap.get(theCase.Status), System.now());
        }
        return theCase;
    }

    /**
     * @description Update case to next status and relevant queue when it is marked complete.
     *
     * @param mapProcessData
     * @param theCase
     * @param ownerId
     *
     * @return SaveResult of the case.
     */
    public static Database.SaveResult updateCaseOwnerAndStatus( final Map<String, Business_Config__c> mapProcessData, Case theCase, String ownerId ) {
        Map<String, String> typeStatus = (Map<String, String>) JSON.deserialize(mapProcessData.get(theCase.Type).Business_Rule_Value__c, Map<String, String>.class);
        if (typeStatus.isEmpty()) { return null; }
        if (typeStatus.containsKey('FinalStatus') && typeStatus.get('FinalStatus') == theCase.Status) {
            theCase.Status = 'Closed';
            theCase.Closed_Reason__c = mapProcessData.get('ClosingReasonPositive').Business_Rule_Value__c;
        } else {
            if (typeStatus.containsKey(theCase.Status)) {
                theCase.Status = typeStatus.get(theCase.Status);
            }
            theCase = updateKeyAccount(mapProcessData, theCase, ownerId);
        }
        return Database.update(theCase, true);
    }

    /**
     * @description Update case to previous status and relevant queue when it is undone as complete.
     *
     * @param mapProcessData
     * @param theCase
     * @param ownerId
     *
     * @return SaveResult of the case.
     */
    public static Database.SaveResult updateToPreviousCaseOwnerAndStatus( final Map<String, Business_Config__c> mapProcessData, Case theCase, String ownerId ) {
        Map<String, String> typeStatus = (Map<String, String>) JSON.deserialize(mapProcessData.get(theCase.Type).Business_Rule_Value__c, Map<String, String>.class);
        typeStatus = ClsSObjectUtils.reverseStringMap(typeStatus);
        if (typeStatus.isEmpty()) { return null; }
        if (typeStatus.containsKey(theCase.Status) ) {
                theCase.Status = typeStatus.get(theCase.Status);
        }
        theCase = updateKeyAccount(mapProcessData, theCase, ownerId);
        return Database.update(theCase, true);
    }

    /**
     * @description Check if the customer is key account and, if yes, assign him to a higher priority queue.
     *
     * @param mapProcessData
     * @param theCase
     * @param ownerId
     *
     * @return Case with updated OwnerId if it's the key account.
     */
    private static Case updateKeyAccount(final Map<String, Business_Config__c> mapProcessData, Case theCase, String ownerId) {
        // If the Account is Key account
        if (mapProcessData.get(theCase.Type + '_CHECK_FOR_KEY_ACCOUNT') != null
                && Boolean.valueOf(mapProcessData.get(theCase.Type + '_CHECK_FOR_KEY_ACCOUNT').Business_Rule_Value__c)
                && theCase.Account.Key_VIP_Account__c) {
            theCase.OwnerId = mapProcessData.get(theCase.Type + '_KEY_ACCOUNT_QUEUE').Business_Rule_Value__c;
        } else if ((mapProcessData.get(theCase.Type + 'NextStatusQueue ' + theCase.Status) != null) && (mapProcessData.get(theCase.Type + 'NextStatusQueue ' + theCase.Status).Business_Rule_Value__c != null)) {
            
            String queueToAssign = mapProcessData.get(theCase.Type + 'NextStatusQueue ' + theCase.Status).Business_Rule_Value__c;
            if (queueToAssign != 'ownerId') {

                theCase.OwnerId = mapProcessData.get(theCase.Type + 'NextStatusQueue ' + theCase.Status).Business_Rule_Value__c;
            } else {

                theCase.OwnerId = theCase.Opportunity__r.OwnerId;
            }
        } else {
            theCase.OwnerId = ownerId;
        }
        return theCase;
    }

    /**
     * @description Get Id of the queue that the case should be assigned to.
     *
     * @param mapProcessData
     * @param theCase
     *
     * @return Id of the queue.
     */
    public static String getMarkCompleteOwnerId( final Map<String, Business_Config__c> mapProcessData, Case theCase ) {
        if (!mapProcessData.containsKey('ownerId')) { return null;}
        Map<String, Object> mpJsonOwner = (Map<String, Object>) JSON.deserializeUntyped(mapProcessData.get('ownerId').Business_Rule_Value__c);
        if (mpJsonOwner.containsKey(theCase.Type)) {
            return (String) mpJsonOwner.get(theCase.Type);
        }
        return null;
    }

    /**
     * @description Undo the case as complete and return it to previous step.
     *
     * @param caseId
     * @param moam
     *
     * @return List<String> with the outcome results.
     */
    public static List<String> undoComplete(String caseId, Map<String, Map<String,Map<String,Business_Config__c>> > moam) {
        List<String> listResult = new List<String>();
        try {
            Case theCase = CaseSelector.getCaseDetailsById(caseId);
            if (moam.get('MarkCompleteBtn').get(theCase.RecordType.DeveloperName) == null) {
                listResult.add(Label.Undo_Complete_Unsuccessful);
                return listResult;
            } else if (theCase.IsClosed) {
                listResult.add(Label.Undo_Complete_Case_Closed);
                return listResult;
            }

            Map<String, Business_Config__c> mapProcessData = moam.get('MarkCompleteBtn').get(theCase.RecordType.DeveloperName);
            Set<String> caseType = new Set<String>(mapProcessData.get('Type').Business_Rule_Value__c.split(','));
            if (!caseType.contains(theCase.Type) || mapProcessData.get(theCase.Type) == null) {
                listResult.add(Label.Undo_Complete_Unsuccessful);
                return listResult;
            }

            String ownerId = ClsRemoteController_Utils.getMarkCompleteOwnerId(mapProcessData, theCase);
            if (theCase.OwnerId != ownerId && theCase.OwnerId != UserInfo.getUserId()) {
                listResult.add(Label.Undo_Complete_NoAccess);
                return listResult;
            }
            Database.SaveResult saveResult = ClsRemoteController_Utils.updateToPreviousCaseOwnerAndStatus(mapProcessData, theCase, ownerId);
            if (saveResult != null && saveResult.getErrors().isEmpty()) {
                listResult.add(Label.Undo_Complete_Success);
            } else {
                listResult.add(Label.Undo_Complete_Unsuccessful);
            }
        } catch (Exception e) {
            listResult.add(e.getMessage());
        }
        return listResult;
    }

    /**
     * @description Mark the case as complete and go to the next step.
     *
     * @param caseId
     * @param moam
     *
     * @return List<String> with the outcome results.
     */
    public static List<String> markComplete(String caseId, Map<String, Map<String,Map<String,Business_Config__c>> > moam) {
        List<String> listResult = new List<String>();
        try {
            Case theCase = CaseSelector.getCaseDetailsById(caseId);
            if (moam.get('MarkCompleteBtn').get(theCase.RecordType.DeveloperName) == null) {
                listResult.add(Label.Mark_Complete_Unsuccessful);
                return listResult;
            } else if (theCase.IsClosed) {
                listResult.add(Label.Mark_Complete_Case_Closed);
                return listResult;
            }

            Map<String, Business_Config__c> mapProcessData = moam.get('MarkCompleteBtn').get(theCase.RecordType.DeveloperName);
            Set<String> caseType = new Set<String>(mapProcessData.get('Type').Business_Rule_Value__c.split(','));

            if (!caseType.contains(theCase.Type) || mapProcessData.get(theCase.Type) == null) {
                listResult.add(Label.Mark_Complete_Unsuccessful);
                return listResult;
            } 

            String theObjTypeName = Id.valueOf(theCase.OwnerId).getSobjectType().getDescribe().getName();
            if (theObjTypeName == 'Group') {
                listResult.add(Label.Mark_Complete_Queue);
                return listResult;
            } else if (theObjTypeName != 'User') {
                return listResult;
            }

            String ownerId = ClsRemoteController_Utils.getMarkCompleteOwnerId(mapProcessData, theCase);
            if (theCase.OwnerId == ownerId || theCase.OwnerId != UserInfo.getUserId()) {
                listResult.add(Label.Mark_Complete_NoAccess);
                return listResult;
            }

            if (ClsRemoteController_Utils.personInChargeNotAssigned(mapProcessData, theCase)) {
                listResult.add(theCase.Status + ' ' + Label.Mark_Complete_Person);
                return listResult;
            }

            Database.SaveResult saveResult;
            //this code is only accessed by SP-3791 Menu change
            if (theCase.RecordType.DeveloperName == 'FP_Entry_Case' && theCase.Type == 'Menu Change') 
            {   
                //imagery close case here error message here
                if(theCase.Case_Reason__c == 'Imagery only update' && theCase.Menu_Upd_Mjr_Check__c == true && theCase.status == 'Final Check')
                {
                    if(ClsRemoteController_Utils.menuChangeValidate(theCase.Id))
                    {  
                        theCase = ClsRemoteController_Utils.menuChangeProcessCase(mapProcessData, theCase);
                        saveResult  = Database.update(theCase, true);                        
                    }
                    else
                    {  
                        listResult.add(Label.Mark_Complete_Parent_Check);
                    }
                }
                else if(theCase.Status != 'New')
                {   system.debug('in 55');
                    theCase = ClsRemoteController_Utils.menuChangeProcessCase(mapProcessData, theCase);
                    saveResult  = Database.update(theCase, true);
                }            
            }
            else
            {
                theCase = ClsRemoteController_Utils.updateCaseField(mapProcessData, theCase);
                saveResult = ClsRemoteController_Utils.updateCaseOwnerAndStatus(mapProcessData, theCase, ownerId);
            }

            if (saveResult != null && saveResult.getErrors().isEmpty()) {
                listResult.add(Label.Mark_Complete_Success);
            } else {
                listResult.add(Label.Mark_Complete_Unsuccessful);
            }
        } catch(DMLException de) { // SP-3399
            listResult.add(de.getDmlMessage(0));
        } 
        catch (Exception e) {
            listResult.add(e.getMessage());
        }

        return listResult;
    }


   /**
    * @author Hugh Crinion
    * @date 20-Oct-19
    * @description re useable method to find the queue base on the status and vertical
    * SP-3791 : Global - Pandora Menu Change Process
    * @return String
    */
    public static Id getCaseQueue(final Map<String, Business_Config__c> mapProcessData, Case theCase)   
    {
        Id queueID;
        Account theAcc = AccountSelector.getAccountDetailsforId(theCase.AccountId);

        if(mapProcessData.ContainsKey('ownerId')){
            map<String,Object> mpJsonOwner= (map<String,Object>)JSON.deserializeUntyped(mapProcessData.get('ownerId').Business_Rule_Value__c);
            //naming convention = Case Reason + 'MenuChange' + Account.vertical Example:'Menu Update Major with Images MenuChange Restaurant' 
            
            if(theAcc != NULL && mpJsonOwner != NULL)
            {
                if(mpJsonOwner.Containskey(theCase.Case_Reason__c + theCase.Status + ' MenuChange ' + theAcc.Vertical__c))
                {
                    queueID = GroupSelector.getQueueByName((String)mpJsonOwner.get(theCase.Case_Reason__c + theCase.Status +  ' MenuChange ' + theAcc.Vertical__c)).Id;
                }
            }

        }
        return queueID;

    }


   /**
    * @author Hugh Crinion
    * @date 20-Oct-19
    * @description Mark complete button used to push the case through the different stages
    * The stages and confiuration is pulled from the business config files 
    * SP-3791 : Global - Pandora Menu Change Process
    * @return String
    */
    public static Case menuChangeProcessCase( final Map<String, Business_Config__c> mapProcessData, Case theCase ) 
    {
        String newStageVal;
        //check if case is in approval process
        Set<Id> targetIds = new Set<Id>();
        targetIds.add(theCase.Id);
        List<ProcessInstanceWorkitem> approvalChckCase = ProcessInstanceWorkItemSelector.findActiveWorkItemsByTargetIds(targetIds);
        if(!approvalChckCase.isEmpty())
        {
            //no changes made return
            return theCase;
        }

        if(mapProcessData == null)
        {
            return theCase; 
        }

        Account theAcc = AccountSelector.getAccountDetailsforId(theCase.AccountId);

        //set the new value for the status if possible
        if(mapProcessData.ContainsKey(theCase.Case_Reason__c + ' ' + theAcc.Vertical__c) && theAcc.Vertical__c != NULL)
        {
            //Enter here if the business config is found
            map<String,Object> mpJsonStage= (map<String,Object>)JSON.deserializeUntyped(mapProcessData.get(theCase.Case_Reason__c + ' ' + theAcc.Vertical__c).Business_Rule_Value__c);
            newStageVal = (String)mpJsonStage.get(theCase.Status);
            
            if(theCase.Case_Reason__c == 'Menu Update Minor')
            {
                if(theCase.Due_Date__c != NULL && newStageVal == 'Closed' && theCase.Status != 'Pending Activation')
                {
                    theCase.Status = 'Pending Activation';
                    theCase.OwnerID = ClsRemoteController_Utils.getCaseQueue(mapProcessData, theCase);             
                }
                else if((theCase.Due_Date__c == NULL && newStageVal == 'Closed') || (theCase.Due_Date__c != NULL && theCase.Status == 'Pending Activation'))
                {
                    //next stage is closed should remain with same owner and set 2 values
                    theCase.Status = newStageVal;
                    theCase.Closed_Reason__c = 'Successful';
                }
                else
                {
                    theCase.Status = newStageVal;
                }
            }
            else if(theCase.Case_Reason__c == 'Imagery only update')
            {
                if(theCase.Due_Date__c != NULL && newStageVal == 'Closed' && theCase.Status != 'Pending Activation')
                {
                    theCase.Status = 'Pending Activation';
                    theCase.OwnerID = ClsRemoteController_Utils.getCaseQueue(mapProcessData, theCase);                
                }
                else if(newStageVal == 'Upload')
                {
                    theCase.Status = newStageVal;
                    theCase.OwnerID = ClsRemoteController_Utils.getCaseQueue(mapProcessData, theCase);                                
                }
                else if(newStageVal == 'Final Check')
                {
                    theCase.Status = newStageVal;
                    theCase.OwnerID = ClsRemoteController_Utils.getCaseQueue(mapProcessData, theCase);                                
                }
                else if((theCase.Due_Date__c == NULL && newStageVal == 'Closed') || (theCase.Due_Date__c != NULL && theCase.Status == 'Pending Activation'))
                {
                    //next stage is closed should remain with same owner and set 2 values
                    theCase.Status = newStageVal;
                    theCase.Closed_Reason__c = 'Successful';
                }
                else if(theCase.Status == 'Please Correct Errors')
                {
                    theCase.Status = newStageVal;
                    theCase.OwnerID = ClsRemoteController_Utils.getCaseQueue(mapProcessData, theCase);
                }                        
                else
                {
                    theCase.Status = newStageVal;
                }                
            }
            else if(theCase.Case_Reason__c == 'Menu Update Major')
            {
                if(theCase.Status == 'Please Correct Errors')
                {
                    theCase.Status = newStageVal;
                    theCase.OwnerID = ClsRemoteController_Utils.getCaseQueue(mapProcessData, theCase);
                }
                if(newStageVal == 'Final Check' && theCase.Status == 'Menu Typing')
                {
                    theCase.Status = newStageVal;
                    theCase.OwnerID = ClsRemoteController_Utils.getCaseQueue(mapProcessData, theCase);
                }
                else if(newStageVal == 'Closed')
                {
                    //next stage is closed should remain with same owner and set 2 values
                    theCase.Status = newStageVal;
                    theCase.Closed_Reason__c = 'Successful';
                }                
                else
                {
                    theCase.Status = newStageVal;
                }  
            }
            else if(theCase.Case_Reason__c == 'Menu Update Major with Images')
            {
                if(theCase.Status == 'Please Correct Errors')
                {
                    theCase.Status = newStageVal;
                    theCase.OwnerID = ClsRemoteController_Utils.getCaseQueue(mapProcessData, theCase);
                }
                if(newStageVal == 'Final Check' && theCase.Status == 'Menu Typing')
                {
                    theCase.Status = newStageVal;
                    theCase.OwnerID = ClsRemoteController_Utils.getCaseQueue(mapProcessData, theCase);
                }
                else if(newStageVal == 'Closed')
                {
                    //next stage is closed should remain with same owner and set 2 values
                    theCase.Status = newStageVal;
                    theCase.Closed_Reason__c = 'Successful';
                }                
                else
                {
                    theCase.Status = newStageVal;
                }
            }
            return theCase;
        }
        else
        {
            return theCase;
        }
    }

    /**
    * @author Hugh Crinion
    * @date 20-Oct-19
    * @description ONLY VALIDATION: The case "FP Entry", "Menu Change", "Imagery Only" can go to the status "Upload" ONLY WHEN the child case is
    *  closed successful.
    * SP-3791 : Global - Pandora Menu Change Process
    * @return String
    */
    public static boolean menuChangeValidate(String caseId) 
    {
        Case chldCs = CaseSelector.getCasesByParentId(caseId);

        //validate check
        if(chldCs == null)
        {
            return false;
        }

        if(chldCs.Case_Reason__c == 'Menu Update Major with Images' && chldCs.Menu_Upd_Mjr_Check__c == true && chldCs.status == 'Closed' && chldCs.Closed_Reason__c == 'Successful') 
        {
            return true;
        }
        return false;
    }
 
}
