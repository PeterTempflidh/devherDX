/**
 * Class CaseCloseAction_AuraController
 *
 * Controller for CaseCloseAction lightning component
 * 
 */
public with sharing class CaseCloseAction_AuraController{


    /*******************************************************************************************************
    * @description returns the recordtype of the case
    * @param caseId
    * @return recordTypeId of case
    */
    @AuraEnabled
    public static Case getCurrentRecord(Id caseId) {
        Case aCase = new Case();
        if (caseId != null) {
            aCase = CaseSelector.getCaseDetailsById(caseId);
        }
        return aCase;
    }

    /*******************************************************************************************************
    * @description closing current Case
    * @param caseId
    * @return recordTypeId of case
    */
    @AuraEnabled
    public static string closeCase(String caseIdString, String caseClosedReason, String caseRootCause) {
        Case record = CaseSelector.getCaseDetailsById((Id)caseIdString);
        if(record != null) {
            try {
                record.Status = CaseConstants.statusClosed;
                record.Closed_Reason__c = caseClosedReason;
                record.Root_Cause__c = caseRootCause;

                Database.SaveResult saveResult = Database.update(record, false);
                if(saveResult.isSuccess()){
                    return JSON.Serialize(new ResultWrapperBuilder(true)
                            .setId(record.Id)
                            .setOwnerId(record.OwnerId)
                            .setUserMessage(Label.Case_closed)
                            .Build());
                }
                for(Database.Error err : saveResult.getErrors()) {
                    return JSON.Serialize(new ResultWrapperBuilder(false)
                            .setId(record.Id)
                            .setOwnerId(record.OwnerId)
                            .setUserMessage(err.getMessage())
                            .setErrorMessage(err.getMessage())
                            .Build());
                }
            } catch (Exception ex) {
                return JSON.Serialize(new ResultWrapperBuilder(false)
                        .setId(record.Id)
                        .setOwnerId(record.OwnerId)
                        .setUserMessage(ex.getMessage())
                        .setErrorMessage(ex.getMessage())
                        .Build());
            }
        }
        String error = Label.Case_not_found_for_id + caseIdString;
        return JSON.Serialize(new ResultWrapperBuilder(false)
                .setId(record.Id)
                .setOwnerId(record.OwnerId)
                .setUserMessage(error)
                .Build());
    }
}