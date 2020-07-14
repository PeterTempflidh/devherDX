/**
* @author Chaitali Kumari
* @date 24.09.2019
*
* @description Utility class for Bank_Details
*/

public with sharing class BankDetail_Utils {

    public static Map<Id, Map<Id,Bank_Detail__c>> mapAcctBankDetail;
    public static List<Bank_Detail__c> allAccountBD;
    public static List<Bank_Detail__c> listToUpdate;

    public static void activateBankDetailRecord(List<SObject> sobjects, Map<Id,SObject> oldSobjectMap) {

        List<Bank_Detail__c> newListBankDetail = (List<Bank_Detail__c>) sobjects;
        Map<Id, Bank_Detail__c> oldMapBankDetail = (Map<Id, Bank_Detail__c>) oldSobjectMap;
        mapAcctBankDetail = new Map<Id, Map<Id,Bank_Detail__c>>();
        listToUpdate  = new List<Bank_Detail__c>();
        set<id> accountIds = new set<id>();

        for (Bank_Detail__c bankDetailRecord : newListBankDetail) {
            accountIds.add(bankDetailRecord.Account__c);
            //Non Approval automatic activation
            if((bankDetailRecord.Status__c != 'Inactive' && bankDetailRecord.Status__c != 'Approval Pending'
                    && bankDetailRecord.status__c != 'Scheduled Update Failed') && (bankDetailRecord.Account_Status__c == 'New' //SSC-1130
                    || bankDetailRecord.Account_Status__c == 'Negotiation'
                    ||bankDetailRecord.Account_Status__c == 'Collecting Documents')){
                //SSC-1004 For new records, automatic activating only if activation date is less than today
                if( bankDetailRecord.Activation_Date__c <= System.today()){
                    bankDetailRecord.Status__c  = 'Active';
                }
                else{
                    bankDetailRecord.Status__c  = 'Approved';
                }

            }

            //SSC-1004 Automatically activating if record is approved & activation date is less than today
            if(bankDetailRecord.Activation_Date__c <= System.today() && bankDetailRecord.Status__c == 'Approved'){
                bankDetailRecord.Status__c  = 'Active';
            }
        }
        allAccountBD = BankDetail_Selector.getByAccountIds(accountIds);
        //Boolean hasFinancePermission = FeatureManagement.checkPermission('FP_Finance_Permissions');
        //Profile recProfile = Profile_Selector.getProfileInfo(); //SSC-1130

        if (allAccountBD.IsEmpty()) return;
        //Populate the map with Account Id vs bank detail records
        for (Bank_Detail__c bankDet : allAccountBD) {
            if (!mapAcctBankDetail.containsKey(bankDet.Account__c)) {
                mapAcctBankDetail.put(bankDet.Account__c, new Map<Id,Bank_Detail__c>{bankDet.Id => bankDet});
            } else {
                mapAcctBankDetail.get(bankDet.Account__c).putAll(new Map<Id,Bank_Detail__c>{bankDet.Id => bankDet});
            }
        }

        if (mapAcctBankDetail.IsEmpty()) return;
        //SSC-1330 Start
        for (Bank_Detail__c bankDetailRecord : newListBankDetail) {

            if (mapAcctBankDetail.containsKey(bankDetailRecord.Account__c) == false) continue;

            if ((bankDetailRecord.status__c == 'Active' && bankDetailRecord.Id != null && oldMapBankDetail.get(bankDetailRecord.Id).Status__c != bankDetailRecord.Status__c) ||
                    bankDetailRecord.status__c == 'Active' && bankDetailRecord.Id == null){

                for (Bank_Detail__c iExistingBankRecord: mapAcctBankDetail.get(bankDetailRecord.Account__c).values()) {

                    //not same record which is active
                    if (iExistingBankRecord.Id != bankDetailRecord.Id && iExistingBankRecord.status__c != 'Approval Pending') {
                        iExistingBankRecord.status__c = 'Inactive';
                        listToUpdate.add(iExistingBankRecord);
                    }
                }
            }
        }//SSC-1330 end
    }

    /**
   * Method to update remaining record to inactive state
    * when one record is activated manually for an account
   */
    public static void updateChildRecordStatus(){

        try {
            if(!listToUpdate.IsEmpty()){
                update listToUpdate;

            }
        }catch(dmlexception e){
            system.debug('Error: ' + e.getMessage());
        }
    }

    /*Block Insert/Update for any Opportunity with stage 'Quality Check Request' on Account*/
    public static void blockUpsertOnQualityCheckOpp(List<SObject> sobjects){
        List<Bank_Detail__c> newBankDetailList = (List<Bank_Detail__c>) sobjects;
        Set<Id> accountIdSet = new Set<Id>();
        for(Bank_Detail__c bd : newBankDetailList){
            if(bd.Account_Status__c == 'Quality Check' && bd.status__c != 'Scheduled Update Failed'){bd.addError(System.label.Cannot_Upsert_Bankdetail_Error);} //SSC 1130
        }
    }
    /*********************************************************************************************
    *   @description        : Bank Details can not be activated by the same user who created it
    *   @param                lstObject list of sObject
    *   @param                oldSobjectMap map of old record
    *   @jira               : SSC-3006
    */
    public static void validateApprovals(List<SObject> lstObject, Map<Id,SObject> oldSobjectMap){

        List<Bank_Detail__c> newListBankDetail = (List<Bank_Detail__c>) lstObject;
        Map<Id, Bank_Detail__c> oldMapBankDetail = (Map<Id, Bank_Detail__c>) oldSobjectMap;
        boolean hasError = false;
        for(Bank_Detail__c iBank : newListBankDetail){

            hasError = (iBank.status__c.equals(Constants.BANKDETAIL_STATUS_APPROVED) ||
                       iBank.status__c.equals(Constants.BANKDETAIL_STATUS_REJECTED)) &&
                       oldMapBankDetail.get(iBank.ID).Status__c.equals(Constants.BANKDETAIL_STATUS_APPROVAL_PENDING) &&
                       iBank.CreatedById.equals(Userinfo.getUserId());

            if(hasError){
                iBank.addError(Label.ValidateApprovalMessage);
            }
        }
    }

}