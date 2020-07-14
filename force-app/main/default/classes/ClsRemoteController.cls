global without sharing class ClsRemoteController {
     public static Boolean chkAcceptQuote=false;
       public Static Boolean skipOppUpd=false;
    
    //private static Map<String,RecordType> mapRecordTypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Opportunity','Asset__c','Opportunity_Quote__c','Case'});
    //private static Map<Id,RecordType> mapRecordTypesForIds = LibRecordTypeHelper.getRecordTypeForIds(new Set<String>{'Opportunity','Opportunity_Quote__c','Case'});
    private static Map<String, Map<String,Map<String,Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;

    //SP-711
    webservice static List<String> escalateCaseAU(String caseId){
        List<String> listResult = new List<String>();

        Map<String,Business_Config__c> mapProcessData = new Map<String,Business_Config__c>();
        Case theCase = [SELECT Id, OwnerId, Status, IsClosed,recordType.developerName 
        					FROM Case 
        					WHERE Id =: caseId LIMIT 1];
        try{
            if(moam.get('EscalateCaseBtn')!=null && 
              	moam.get('EscalateCaseBtn').get(theCase.recordType.developerName) != null){
	                mapProcessData = moam.get('EscalateCaseBtn').get(theCase.recordType.developerName);
	                system.debug('mapProcessData : ' + mapProcessData);    
	                System.debug('theCase: ' + theCase);
	
	
	                Id theId = Id.valueOf(theCase.OwnerId);
	                Schema.SObjectType theObjType = theId.getSobjectType();
	                String theObjTypeName = theObjType.getDescribe().getName();
	
	                
	                
	                if(theCase.IsClosed){
	                    listResult.add(Label.Escalated_closed_case_AU);
	                    return listResult;
	                }
	                System.debug('theObjTypeName ' + theObjTypeName);
	                if(theObjTypeName == 'Group'){
	                    listResult.add(Label.Escalated_already_AU);
	                    return listResult;
	
	                }else if(theObjTypeName == 'User'){
	
	                    String ownerId = mapProcessData.get('ownerId').Business_Rule_Value__c;
	                    //SP-728
	                    if(UserInfo.getUserId() == theCase.OwnerId){
	                        if(theCase.OwnerId != ownerId){
	                            theCase.OwnerId = ownerId;
	
	                            Database.SaveResult saveResult = Database.update(theCase,true);
	
	                            if(saveResult.getErrors().isEmpty()){
	                                listResult.add(Label.Escalated_successful_AU);
	                            }else{
	                                listResult.add(Label.Escalated_not_sucessful_AU);
	                            }
	                        }else{
	                            listResult.add(Label.Escalated_already_AU);
	                        }
	                    }else{
	                        listResult.add(Label.Escalated_only_if_owner);
	                    }
	                }
	                
	            }
        }catch(Exception e){
            listResult.add(e.getMessage());
            return listResult;
        }

        return listResult;
    }
    
    
    
     webservice static List<String> backToQueue(String caseId){
        List<String> listResult = new List<String>();
        system.debug('*backtoQueue');
        Map<String,Business_Config__c> mapProcessData = new Map<String,Business_Config__c>();
        Case theCase = [SELECT Id, OwnerId, Status, IsClosed,recordtype.developername,queue_id__c FROM Case WHERE Id =: caseId LIMIT 1];
        system.debug('Case Recordtype : ' + theCase.recordtype.developername);
        system.debug('moam  : ' + moam.keyset());
        system.debug('moam BackToQueueBtn : ' + moam.get('BackToQueueBtn'));
        try{
            if(moam.get('BackToQueueBtn').get(theCase.recordtype.developername) != null){
                mapProcessData = moam.get('BackToQueueBtn').get(theCase.recordtype.developername);

                
                System.debug('theCase: ' + theCase);

                System.debug('theCase.ownerId: ' + theCase.OwnerId);
                Id theId = Id.valueOf(theCase.OwnerId);
                system.debug('theId : ' + theId);
                Schema.SObjectType theObjType = theId.getSobjectType();
                String theObjTypeName = theObjType.getDescribe().getName();

                String ownerId='';
                
                if(mapProcessData.get('chkForPrevQueue')!=null && Boolean.valueOf(mapProcessData.get('chkForPrevQueue').Business_Rule_Value__c) && theCase.queue_id__c!=null){
                    ownerId=theCase.queue_id__c;
                }
                else
                    ownerId=mapProcessData.get('ownerId').Business_Rule_Value__c;
                
                if(theCase.IsClosed){
                    listResult.add(Label.Back_to_Queue_Closed_Case);
                    return listResult;
                }
                System.debug('theObjTypeName ' + theObjTypeName);
                if(theObjTypeName == 'Group' && theId == ownerId ){
                    listResult.add(Label.Level_1_Support_Queue);
                    return listResult;

                }
                
                else if(theObjTypeName == 'Group' && theId != ownerId ){
                    listResult.add(Label.BacktoQueue_owner_change);
                    return listResult;

                }
                else if(theObjTypeName == 'User'){

                    //String ownerId = mapProcessData.get('ownerId').Business_Rule_Value__c;

                    if(theCase.OwnerId != ownerId /*&& theCase.OwnerId==UserInfo.getUserId()*/ ){
                        theCase.OwnerId = ownerId;

                        Database.SaveResult saveResult = Database.update(theCase,true);

                        if(saveResult.getErrors().isEmpty()){
                            listResult.add(Label.BackToQueue_successful);
                        }else{
                            listResult.add(Label.Back_to_Queue_Unsucessful_AU);
                        }
                    }else{
                        listResult.add(Label.BacktoQueue_owner_change);
                    }
                }
                
            }
        }catch(Exception e){
            listResult.add(e.getMessage());
            return listResult;
        }

        return listResult;
    }

    /**
     * @description Undo the case as complete and return it to previous step.
     *
     * @param caseId
     *
     * @return List<String> with outcome result
     * @see ClsRemoteController_Utils.undoComplete(String, Map<String, Map<String,Map<String,Business_Config__c>> >)
     */
    webService static List<String> undoComplete(String caseId) {
        return ClsRemoteController_Utils.undoComplete(caseId, moam);
    }

    /**
     * @description Mark the case as complete and go to the next step..
     *
     * @param caseId
     *
     * @return List<String> with outcome result.
     * @see ClsRemoteController_Utils.markComplete(String, Map<String, Map<String,Map<String,Business_Config__c>> >)
     */
    webService static List<String> markComplete(String caseId) {
        return ClsRemoteController_Utils.markComplete(caseId, moam);
    }

    webservice static List<String> createBackendAccountKR(String restaurantName, String salesforceId, String salesRep, String accountType){
        List<String> listResult = new List<String>();
        Boolean profileValid = false;
        /*System.debug('$$$ method started');
        System.debug('$$$ moam : ' + moam);
        System.debug('$$$ moam.get(\'SendToBackendProcess\') '+moam.get('QuoteApprovalProcess'));
        System.debug('query backend : ' + [SELECT Id FROM Business_Config__c WHERE Process_Name__c='SendToBackendProcess'].size());
        System.debug('query approval : ' + [SELECT Id FROM Business_Config__c WHERE Process_Name__c='QuoteApprovalProcess'].size());*/

        Map<String,Business_Config__c> mapProcessData = new Map<String,Business_Config__c>();

        if(!Test.isRunningTest()){
            mapProcessData = moam.get('SendToBackendProcess').get('Yogiyo_Account');
        }else{
            for(Business_Config__c bc : [SELECT Id,Business_Rule_Value__c,Business_Rule_Name__c FROM Business_Config__c WHERE Process_Name__c='SendToBackendProcess']){
                System.debug('config: ' + bc);
                mapProcessData.put(bc.Business_Rule_Name__c,bc);
            }
        }
        



        if(mapProcessData != null){

            if(accountType != mapProcessData.get('allowedAccountType').Business_Rule_Value__c){
                listResult.add(Label.Account_type_not_allowed_for_backend_creation_KR);

                return listResult;
            }

            for(String profile : mapProcessData.get('allowedProfileIds').Business_Rule_Value__c.split(',')){
                System.debug('current profile: ' + Userinfo.getProfileId());
                if(profile == Userinfo.getProfileId() || Test.isRunningTest()){
                    profileValid = true;
                    break;
                }
            }
        

            if(!profileValid){
                listResult.add(Label.Profile_not_allowed_for_backend_creation_KR);

                return listResult;
            }else{

                String backendId = ClsWebserviceCalloutsKR.createBackendAccount(restaurantName, salesforceId, salesRep);

                if(backendId != null){

                    Account theAccount = [SELECT Id, Backend_ID__c FROM Account WHERE Id =: salesforceId LIMIT 1];
                    theAccount.Backend_ID__c = backendId;
                    update theAccount;

                    listResult.add(Label.Successfully_created_in_backend_KR);
                }else{
                    listResult.add(Label.Backend_creation_failed);
                }
            }
        }
        return listResult;
    }
    
    webService static List<String> checkForItemsToTerminate(String accountId){
        List<String> result = new List<String>();

        List<Asset__c> listAssets = [select id,Status__c  from Asset__c where Account__c =:accountId and termination_date__c=null];
        List<Additional_Charges__c> listAddCharge = [select id,termination_date__c from Additional_Charges__c where Id_Account__c =:accountId and termination_date__c=null];
        List<Contract> allContracts = [SELECT Id, ContractNumber, StartDate, End_Date__c, Status, Commission__c, Recurring_Fee__c FROM Contract WHERE AccountId =: accountId AND Status != 'Terminated' ORDER BY StartDate DESC];
        
        if(!listAssets.isEmpty() || !listAddCharge.isEmpty() || !allContracts.isEmpty()){
            result.add('true');
        }else{
            result.add('false');    
        }

        return result;
    }


     webService static List<String> acceptQuote(String quoteId){
        List<String> result = new List<String>();
        System.Savepoint sp = Database.setSavepoint();
        try{
           chkAcceptQuote=true;
            updateOpportunityType(quoteId);
            chkAcceptQuote=false;
            Opportunity_Quote__c quote = [select id,id_opportunity__c,Id_Opportunity__r.type ,status__c,Id_Opportunity__r.OwnerId  from Opportunity_Quote__c where id=:quoteId];
            /*if(quote.Id_Opportunity__r.type==null){
                result.add(Label.Error+' '+Label.OpportunityTypeStageValidation);
                return result;
            }*/
            quote.status__c ='Accepted';
            try{

                update quote;   
            }catch(DmlException e){
                System.debug('Error: '+e.getMessage());
                System.debug('e.getDmlType(0): '+e.getDmlType(0));
                 
                if(e.getDmlType(0)==StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                    if(e.getDmlMessage(0).contains('INSUFFICIENT_ACCESS')){
                        result.add(Label.Accept_quote_Opportunity_Error);
                    }
                    else    
                    result.add(Label.Error+' '+e.getDmlMessage(0));
                    Database.rollback(sp);
                    return result;
                }
                result.add(Label.Accept_Quote_Error);
                Database.rollback(sp);
                return result;
            }
            result.add(Label.Opportunity_Quote_Accepted);
            
            return result;
        }catch(Exception e){
            System.debug('Error: '+e.getMessage());
            result.add(Label.Accept_Quote_Error);
            Database.rollback(sp); 
            return result;
        }

    }

    /*
        SP-581 approval for ME
    */

    webService static List<String> approveQuote(String quoteId) {
        List<String> result = new List<String>();
        System.Savepoint sp = Database.setSavepoint();

        Boolean updateOpp = false;
        try {

            updateOpportunityType(quoteId);
            Opportunity_Quote__c quote = [select id, RecordType.DeveloperName, id_opportunity__c, Id_Opportunity__r.type, Id_Opportunity__r.Record_Country__c , status__c, Approval_L1__c, Approval_L2__c from Opportunity_Quote__c where id = :quoteId];

            Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('QuoteApprovalProcess');
            system.debug('*mapBusinessLogic ' + mapBusinessLogic + quote  );
            Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(quote.RecordType.DeveloperName);
            Map<String,Map<String,OpportunityTeamMember>>mapOppTeam = LibBusinessConfig.determineApproverMap(quote.id_opportunity__c);


            Map<String, OpportunityTeamMember> mapApprovalEntriesLevel1 = mapOppTeam.get('HOS');
            Map<String, OpportunityTeamMember>  mapApprovalEntriesLevel2 = mapOppTeam.get('Legal');
            Map<String, OpportunityTeamMember>  mapApprovalEntriesLevel3 = mapOppTeam.get('Regional HOS');

            if (mapBusinessRules != null && !mapBusinessRules.isEmpty() &&
                    mapBusinessRules.get('level1ApprovedStatus').Business_Rule_Value__c != null &&
                    quote.status__c != mapBusinessRules.get('level1ApprovedStatus').Business_Rule_Value__c &&
                    (quote.status__c == mapBusinessRules.get('initialStatusLevel1').Business_Rule_Value__c || (mapBusinessRules.get('initialStatusLevel3') != null && quote.status__c == mapBusinessRules.get('initialStatusLevel3').Business_Rule_Value__c) )) {
                //Stage1 approval

                //if(quote.Approver_L2__c == null){ //no level 2 approval
                if (quote.Approval_L2__c == false) { //no level 2 approval
                    quote.Status__c = mapBusinessRules.get('finalApprovalStatus').Business_Rule_Value__c;
                    updateOpp = true;
                } else {
                    quote.status__c = mapBusinessRules.get('level1ApprovedStatus').Business_Rule_Value__c;
                    updateOpp = true;
                }



            } else if (mapBusinessRules != null &&
                       !mapBusinessRules.isEmpty() &&
                       quote.status__c == mapBusinessRules.get('level1ApprovedStatus').Business_Rule_Value__c &&
                       (mapApprovalEntriesLevel1!=null && mapApprovalEntriesLevel1.keySet().contains(Userinfo.getUserId()) || (mapApprovalEntriesLevel3 != null && !mapApprovalEntriesLevel3.isEmpty() && mapApprovalEntriesLevel3.keySet().contains(Userinfo.getUserId()) )) && !mapApprovalEntriesLevel2.keySet().contains(Userinfo.getUserId())) {
                //quote.Approver_L1__c == Userinfo.getUserId() && quote.Approver_L2__c != Userinfo.getUserId()){

                result.add(Label.Opportunity_Quote_Approved_Already);
                return result;
            } else if (mapBusinessRules != null &&
                       !mapBusinessRules.isEmpty() &&
                       quote.status__c != mapBusinessRules.get('level2ApprovedStatus').Business_Rule_Value__c &&
                       quote.status__c == mapBusinessRules.get('level1ApprovedStatus').Business_Rule_Value__c) {

                quote.status__c = mapBusinessRules.get('level2ApprovedStatus').Business_Rule_Value__c;
                updateOpp = true;

            } else if (mapBusinessRules != null && !mapBusinessRules.isEmpty() && quote.status__c == mapBusinessRules.get('level2ApprovedStatus').Business_Rule_Value__c) {
                result.add(Label.Opportunity_Quote_Approved_Already);
                return result;
            }
            try {

                update quote;

                if (updateOpp) {
                    Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id = : quote.Id_Opportunity__c LIMIT 1];

                    if (quote.Status__c == mapBusinessRules.get('level1ApprovedStatus').Business_Rule_Value__c ) {
                        opp.StageName = mapBusinessRules.get('pushStageNameAfterLevel1Approval').Business_Rule_Value__c;
                        //ClsEmailProcessor.notifyApprover(quote.Approver_L2__c, quote.RecordType.DeveloperName, quote.Id);
                        if(LibBusinessConfig.determineApprover(quote.Id_Opportunity__r.Record_Country__c,'Legal' )!=null && LibBusinessConfig.determineApprover(quote.Id_Opportunity__r.Record_Country__c,'Legal' ).Notification__C)
                            ClsEmailProcessor.notifyApprovers(mapApprovalEntriesLevel2.values(), quote.RecordType.DeveloperName, quote.Id);

                    } else if (mapBusinessRules.get('level2ApprovedStatus') != null && quote.Status__c == mapBusinessRules.get('level2ApprovedStatus').Business_Rule_Value__c) {
                        opp.StageName = mapBusinessRules.get('pushStageNameAfterLevel2Approval').Business_Rule_Value__c;
                    } else if (  mapBusinessRules.get('finalApprovalStatus').Business_Rule_Value__c != null && quote.Status__c == mapBusinessRules.get('finalApprovalStatus').Business_Rule_Value__c) {
                        opp.StageName = mapBusinessRules.get('pushStageNameAfterFinalApproval').Business_Rule_Value__c;
                    }

                    update opp;
                }


            } catch (DmlException e) {
                System.debug('Error: ' + e.getMessage());
                System.debug('e.getDmlType(0): ' + e.getDmlType(0));

                if (e.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
                	if(e.getDmlMessage(0).contains('INSUFFICIENT_ACCESS'))
                        result.add(Label.Accept_quote_Opportunity_Error);
                    else    
                    result.add(Label.Error + ' ' + e.getDmlMessage(0));
                    Database.rollback(sp);
                    return result;
                }
                result.add(Label.Error + ' ' + e.getMessage());
                Database.rollback(sp);
                return result;
            }
            result.add(Label.Opportunity_Quote_Approved);
            return result;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString());
            result.add(Label.Error + ' ' + e.getMessage());
            Database.rollback(sp);
            return result;
        }

    }

    

    webService static List<String> rejectQuote(String quoteId) {
        List<String> result = new List<String>();
        System.Savepoint sp = Database.setSavepoint();



        try {

            updateOpportunityType(quoteId);
            Opportunity_Quote__c quote = [select id, Id_Opportunity__r.OwnerId, RecordType.DeveloperName, id_opportunity__c, Approval_L2__c, Approval_L1__c , Id_Opportunity__r.Record_Country__c, Id_Opportunity__r.type , status__c from Opportunity_Quote__c where id = :quoteId];
            /*if(quote.Id_Opportunity__r.type==null){
                result.add(Label.Error+' '+Label.OpportunityTypeStageValidation);
                return result;
            }*/

            Map<String,Map<String,OpportunityTeamMember>>mapOppTeam = LibBusinessConfig.determineApproverMap(quote.id_opportunity__c);


            Map<String, OpportunityTeamMember> mapApprovalEntriesLevel1 = mapOppTeam.get('HOS');
            Map<String, OpportunityTeamMember>  mapApprovalEntriesLevel2 = mapOppTeam.get('Legal');
            Map<String, OpportunityTeamMember>  mapApprovalEntriesLevel3 = mapOppTeam.get('Regional HOS');
            quote.status__c = 'Rejected';
            Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id = : quote.Id_Opportunity__c LIMIT 1];

            Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('QuoteApprovalProcess');
            Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(quote.RecordType.DeveloperName);

            //if(quote.Approver_L1__c == UserInfo.getUserId()){
            if (mapApprovalEntriesLevel1!=null && mapApprovalEntriesLevel1.keySet().contains(UserInfo.getUserId()) || (mapApprovalEntriesLevel3 != null && !mapApprovalEntriesLevel3.isEmpty() && mapApprovalEntriesLevel3.keySet().contains(UserInfo.getUserId()))) {
                opp.StageName = mapBusinessRules.get('pushStageNameAfterLevel1Rejection').Business_Rule_Value__c;
            }

            //if(quote.Approver_L2__c == UserInfo.getUserId()){
            if (mapApprovalEntriesLevel2!=null && mapApprovalEntriesLevel2.keySet().contains(UserInfo.getUserId())) {
                opp.StageName = mapBusinessRules.get('pushStageNameAfterLevel2Rejection').Business_Rule_Value__c;
            }

            try {

                update quote;
                update opp;
                ClsEmailProcessor.sendRejectionNotification(quote.Id_Opportunity__r.OwnerId, quote.RecordType.DeveloperName, quote.Id);
            } catch (DmlException e) {
                System.debug('Error: ' + e.getMessage());
                System.debug('e.getDmlType(0): ' + e.getDmlType(0));

                if (e.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
                    result.add(Label.Error + ' ' + e.getDmlMessage(0));
                    Database.rollback(sp);
                    return result;
                }
                result.add(Label.Error + ' ' + e.getMessage());
                Database.rollback(sp);
                return result;
            }
            result.add(Label.Opportunity_Quote_Rejected);
            return result;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            result.add(Label.Error + ' ' + e.getMessage());
            Database.rollback(sp);
            return result;
        }

    }

    webService static List<String> cancelAssetAdditionalCharges(String assetId){
        List<String> result = new List<String>();
        try{
            Asset__c Assetrec = [select id,Status__c,termination_date__c  from Asset__c where Id =:assetId];
            if(Assetrec.termination_date__c==null){
                Assetrec.status__c = 'Cancellation - To Collect';
                Assetrec.termination_date__c = Date.today();
                update Assetrec;
                
                List<Additional_Charges__c> listAddCharge = [select id,termination_date__c from Additional_Charges__c where Id_Asset__c =:assetId and termination_date__c=null];
                for(Additional_Charges__c addch : listAddCharge){
                        addch.termination_date__c = Date.today();
                }
                update listAddCharge;
                result.add(Label.Asset_terminated_successfully);
            }else{
                result.add(Label.Asset_terminated_already);
            }
            return result;

        }catch(Exception e){
            result.add(Label.Error+' '+e.getMessage());
            System.debug('Error: '+e.getMessage());
            return result;
        }
    }
    //SP-1924
    webService static void SendEventBusCreation(String GRID) {
        map<ID,Platform_Performance__c> mpPlat = new map<ID,Platform_Performance__c>();

        For(Platform_Performance__c plt : [SELECT Account__c,Backend_ID__c,GRID__c,Id,LMIV__c,Migration_ID__c,Name,Platform_Online_Status__c,Platform_Payment_Method__c,Platform_Relay_Method__c,Platform__c,SAP_Number__c,White_Label_Website__c
                                            FROM Platform_Performance__c WHERE GRID__c = :GRID]){
                mpPlat.put(plt.id,plt);
        }

        EventBusHelper.ValidateRecordsPlatform('Platform',mpPlat);
    }

    public static List<String> cancelAllAssetAdditionalCharges(String accountId){
        List<String> result = new List<String>();
        try{
            List<Asset__c> listAssets = [select id,Status__c  from Asset__c where Account__c =:accountId and termination_date__c=null];
            for(Asset__c asst : listAssets){
                asst.status__c = 'Cancellation - To Collect';
                asst.termination_date__c = Date.today();
            }
            update listAssets;

            List<Additional_Charges__c> listAddCharge = [select id,termination_date__c from Additional_Charges__c where Id_Account__c =:accountId and termination_date__c=null];
            for(Additional_Charges__c addch : listAddCharge){
                addch.termination_date__c = Date.today();
            }
            update listAddCharge;
            result.add(Label.Asset_terminated_successfully);
            return result;
        }catch(Exception e){
            System.debug('Error: '+e.getMessage());
            result.add(Label.Error+' '+e.getMessage());
            return result;
        }
    }




    /*webService static list<String> qualityCheck(String oppId){
        List<String> result = new List<String>();
        System.Savepoint sp = Database.setSavepoint();
        try{

            Opportunity opp = [select name,RecordType.DeveloperName,stageName,Probability from Opportunity where id =: oppId];
            //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('QualityCheckButton');
            Map<String,Map<String,Business_Config__c>> mapBusinessLogic = moam.get('QualityCheckButton');
            Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(opp.RecordType.DeveloperName);
            if(mapBusinessRules!=null && !mapBusinessRules.isEmpty()){

                Boolean permittedUserProfile = false;
                String currentUserProfile = UserInfo.getProfileId();
                List<String> listPermittedProfileNames = mapBusinessRules.get('permittedProfiles').Business_Rule_Value__c.trim().split(',');
                String currentUserProfileName = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId() ].Name;
                
                for(String profileName : listPermittedProfileNames){
                    if (profileName == currentUserProfileName){
                        permittedUserProfile = true;
                        system.debug('@@@@ permittedUserProfile : '+ permittedUserProfile);
                        break;
                    }
                }


                if(permittedUserProfile){
                    opp.Quality_Check__c = Date.today(); 
                    opp.Quality_Check_By__c = UserInfo.getUserId(); 
                    opp.StageName = mapBusinessRules.get('set StageName').Business_Rule_Value__c;
                    opp.Probability = Decimal.valueOf(mapBusinessRules.get('set Probability').Business_Rule_Value__c);

                    update opp;
                    result.add(Label.Quality_Checked);
                    system.debug('@@@Opportunity updated');
                    if(Boolean.valueOf(mapBusinessRules.get('createAsset').Business_Rule_Value__c)){
                        result.add(createAssets(opp,mapBusinessRules));
                        system.debug('@@@Asset Created');
                    }   
                }else{
                    result.add(Label.QualityCheckProfileIsNotPermitted);
                    system.debug('@@@Label.QualityCheckProfileIsNotPermitted');
                }
                system.debug('@@@ result : ' + result);
                return result;
            }else{
                result.add(Label.QualityCheckButton_Business_validation);
                System.debug('Result : ' + Label.QualityCheckButton_Business_validation+'  :  ' +opp.RecordType.DeveloperName);
                return result;
            }
            }catch(Exception e){
                if(e.getTypeName()=='DmlException' && e.getDmlType(0)==StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                    result.add(Label.Error+' '+e.getDmlMessage(0));
                    return result;
                }
                result.add(Label.Error+' '+e.getMessage());
                System.debug('Error: '+e.getMessage());
                Database.rollback(sp); 
                return result;
            }

    }

    private static String createAssets(Opportunity processOpp, Map<String,Business_Config__c> mapBusinessRules){
    String result = Label.Assets_created;
    try{
            List<Opportunity_Quote__c> opquote = [SELECT Id, Name, Id_Account__c, Status__c, Id_Opportunity__c, RecordType.DeveloperName 
                    FROM Opportunity_Quote__c 
                    WHERE Id_Opportunity__c =:processOpp.id 
                    AND Status__c='Accepted' limit 1];
            if(opquote.isEmpty()){
                result = Label.No_Accepted_Quote;
                return result;

            }
            List<Asset__c> listAssets = new List<Asset__c>();
            Map<Id,Opportunity_Quote_Line_Item__c> mapOppQuoteProd = new Map<Id,Opportunity_Quote_Line_Item__c>([select (select name,Account__c,CurrencyIsoCode,RecordTypeId,Id_Opportunity_Quote_Line_Item__c,Opportunity__c,Status__c from Assets__r),id, name,CurrencyIsoCode,Id_List_Product_Price__r.Requires_Asset__c,Has_Related_Tarif__c,Id_List_Product_Price__c,Installments__c,Listed_Price__c,
                                                        Id_Opportunity_Quote__c,Id_Opportunity_Quote__r.Id_Account__c,Id_Opportunity__c,Quantity__c
                                                            from Opportunity_Quote_Line_Item__c where Id_Opportunity_Quote__c =:opquote[0].id and Line_Item_type__c='Product']);
            for(Opportunity_Quote_Line_Item__c qq1 : mapOppQuoteProd.values()){
                if(qq1.Id_List_Product_Price__r.Requires_Asset__c){
                    System.debug('qq1.Assets__r: '+qq1.Assets__r);
                    if(qq1.Assets__r==null || qq1.Assets__r.isEmpty()){
                        if(mapBusinessRules!=null && !mapBusinessRules.isEmpty()){
                            Boolean createAsset = true;
                            if(mapBusinessRules.get('createAsset')!=null)
                                createAsset = Boolean.valueOf(mapBusinessRules.get('createAsset').Business_Rule_Value__c);
                            if(createAsset){
                                for(integer i=1; i<=qq1.Quantity__c; i++  ){
                                            Asset__c newAsset = new Asset__c();
                                            newAsset.name = qq1.name;
                                            newAsset.Account__c = qq1.Id_Opportunity_Quote__r.Id_Account__c;
                                            newAsset.CurrencyIsoCode = qq1.CurrencyIsoCode;
                                            newAsset.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('Asset RecordType').Business_Rule_Value__c);
                                            //newAsset.Is_Active__c = false;
                                            newAsset.Id_Opportunity_Quote_Line_Item__c = qq1.Id;
                                            newAsset.Opportunity__c = qq1.Id_Opportunity__c;
                                            newAsset.Status__c = mapBusinessRules.get('Asset Status__c').Business_Rule_Value__c;
                                            listAssets.add(newAsset);
                                }
                            }
                        }
                    }
                }
            }
            insert listAssets;
                        
        }catch(Exception e){
            result = ' '+Label.Error+' '+e.getMessage();
            System.debug('Error: '+e.getMessage());
        }
        return result;
    }*/


    public static String updateOpportunityType(String sObId){
        System.debug('@@@@ updateOpportunityType sObId: ' + sObId);
        String result = '';
        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('OppTypeAndServiceType');
        Map<String,Map<String,Business_Config__c>> mapBusinessLogic = moam.get('OppTypeAndServiceType');
        Schema.SObjectType token = Id.valueOf(sObId).getSObjectType();
        Opportunity updateOpp;
        String OppType;
        Set<String> ServiceType = new Set<String>();
        Boolean isProduct = false;
        Boolean isAdditional = false;
        Boolean isOtherService = false;
        Boolean isRecurringCharge = false;
        Boolean isAdSales = false;
        Boolean isSplOffer = false;
        skipOppUpd=false;
        String recordTypeName;
        Map<String, String> recurringChargeTypes;
        String nonStandardComponents;
        String accountId;
        //List<Opportunity_Tarif_Item__c> oppTarif;
         Opportunity opp;

        try{
            if(token == Opportunity.getSObjectType()){
                 //oppTarif = [select name from Opportunity_Tarif_Item__c where Id_Opportunity__c=:sObId limit 1];
                opp = [select RecordType.DeveloperName,Id_Tarif__c,Id_Tarif__r.name,Type,(select Id_List_Price_Product__r.Product_Type__c,Line_Item_type__c,sub_Type__c from Opportunity_Line_Items__r) from Opportunity where id=:sObId];
                recurringChargeTypes =  getRecurringFeeTypes(opp.RecordType.DeveloperName);
                for(Opportunity_Line_Item__c oli : opp.Opportunity_Line_Items__r){
                    if(oli.Line_Item_type__C=='Service'){
                        if(oli.Line_Item_type__c=='Service' && oli.sub_Type__c!=null){
                            ServiceType.add(oli.Sub_Type__c);
                        }else{
                            isOtherService = true;
                        }
                    }
                    else{
                        if(/*oli.Ad_Sales_Type__c!=null*/ oli.sub_Type__c=='Ad Sales'){
                            isAdSales = true;
                        }else if(oli.sub_Type__c==Label.CD_Special_Offer){
                            isSplOffer = true;
                            // skipOppUpd=true;
                            isProduct = true;
                        }else if(oli.Id_List_Price_Product__r.Product_Type__c != null && recurringChargeTypes.get(oli.Id_List_Price_Product__r.Product_Type__c) != null){
                            isRecurringCharge = true;
                        } else {
                            isProduct = true;
                        }

                    }
                }
                /*if(!opp.Opportunity_Product_Items__r.isEmpty()){
                    //isProduct = true;
                    for(Opportunity_Product_Item__c opi : opp.Opportunity_Product_Items__r){
                        if(opi.Ad_Sales_Type__c!=null){
                            isAdSales = true;
                        }else if(opi.Id_List_Price_Product__r.Product_Type__c != null && recurringChargeTypes.get(opi.Id_List_Price_Product__r.Product_Type__c) != null){
                            isRecurringCharge = true;
                        } else {
                            isProduct = true;
                        }
                    }
                }*/
                recordTypeName = opp.RecordType.DeveloperName;
                updateOpp = new Opportunity(Id=opp.Id,Type=opp.Type);

            }else if(token == Opportunity_Quote__c.getSObjectType()){
                Opportunity_Quote__c oppQuote = [SELECT id,Id_Opportunity__c,Id_Opportunity__r.Type,Non_Standard_Contract_Components__c,Id_Account__c,Id_Opportunity__r.RecordType.DeveloperName, (select id, Line_Item_type__c, Sub_Type__c from Opportunity_Quote_Line_Items__r) FROM Opportunity_Quote__c WHERE id =:sObId];
                recurringChargeTypes =  getRecurringFeeTypes(oppQuote.Id_Opportunity__r.RecordType.DeveloperName);
                if(!oppQuote.Opportunity_Quote_Line_Items__r.isEmpty()){
                    for(Opportunity_Quote_Line_Item__c oqpi : oppQuote.Opportunity_Quote_Line_Items__r){
                        if(oqpi.Line_Item_type__c=='Product'){
                            if(oqpi.Sub_Type__c!=null && oqpi.Sub_Type__c=='Ad Sales'){
                                isAdSales = true;
                            }else if(oqpi.sub_Type__c==Label.CD_Special_Offer){
                                isSplOffer = true;
                                //skipOppUpd=true;
                                isProduct = true;
                            }
                            else if(oqpi.Sub_Type__c != null && recurringChargeTypes.get(oqpi.Sub_Type__c) != null){
                                isRecurringCharge = true;
                            } else {
                                isProduct = true;
                            }
                        }else if(oqpi.Line_Item_type__c=='Service'){
                            if(oqpi.Sub_Type__c!=null){
                                ServiceType.add(oqpi.Sub_Type__c);   
                            }else{
                                isOtherService = true;
                            }
                        }
                        
                    }
                }
                recordTypeName = oppQuote.Id_Opportunity__r.RecordType.DeveloperName;
                updateOpp = new Opportunity(Id=oppQuote.Id_Opportunity__c,Type=oppQuote.Id_Opportunity__r.Type);
                nonStandardComponents = oppQuote.Non_Standard_Contract_Components__c;
                accountId=oppQuote.id_account__C;
            }
            Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(recordTypeName);
            if(mapBusinessRules!=null && !mapBusinessRules.isEmpty()){
                

                
                String additionalValue = mapBusinessRules.get('Additional Contract').Business_Rule_Value__c;
                set<String> additionalContract =  new Set<String>();

                if(additionalValue.indexOf(',') > -1){
                    additionalContract.addAll(additionalValue.split(','));
                }else{
                     additionalContract.add(additionalValue); 
                }
                if(mapBusinessRules.get('AdSales Tarif')!=null){
                    String adSalesTarifName = mapBusinessRules.get('AdSales Tarif').Business_Rule_Value__c;
                    if(opp.Id_Tarif__c!=null && opp.Id_Tarif__r.name.equalsIgnoreCase(adSalesTarifName)){
                        isAdSales = true;
                    }
                }
                System.debug('isProduct: '+isProduct);
                System.debug('ServiceType.isEmpty(): '+ServiceType.isEmpty());
                System.debug('isOtherService: '+isOtherService);
                System.debug('isOtherService: '+isOtherService);
                system.debug('servicetype: '+ServiceType);
                system.debug('additionalContract :'+additionalContract);
                system.debug(isSplOffer);
                
                if(isAdSales){
                    OppType = 'AdSales';
                }else if(isSplOffer && mapBusinessRules.get('SplOffer')!=null && Boolean.valueof(mapBusinessRules.get('SplOffer').Business_Rule_Value__c)){
                    oppType= Label.CD_Special_Offer_OppType;
                }else if(isRecurringCharge && !isProduct && ServiceType.isEmpty() && !isOtherService){
                    OppType = 'Administration';
                } else if(isProduct && !ServiceType.isEmpty() && !additionalContract.containsAll(ServiceType)){
                    OppType = 'Contract & Product';
                }else if(isProduct && ServiceType.isEmpty() && isOtherService ){
                    OppType = 'Contract & Product';
                }else if(isProduct && ServiceType.isEmpty()){
                    OppType = 'Product Only';
                }else {
                    for(String ss : ServiceType){
                        if(additionalContract.contains(ss)){
                            isAdditional = true;
                        }else{
                            isOtherService = true;
                        }
                    }
                    if(isAdditional && isOtherService){
                        OppType = 'Contract Only';
                    }else if(isAdditional && !isOtherService){
                        OppType = 'Additional Contract';
                    }else if(isOtherService){
                        OppType = 'Contract Only';
                    }
                }
                
                System.debug('OppType: '+OppType);
                if(OppType!=null){
                    //if(updateOpp.type!=null  && updateOpp.type!=OppType){
                        updateOpp.type = OppType;
                        update updateOpp;
                    /*}else if(updateOpp.type==null){
                        updateOpp.type = OppType;
                        update updateOpp;
                    }*/
                    
                }
                

            }
        }catch(Exception e){
            result = ' ' + Label.Error + ' ' + e.getMessage();
            System.debug('Error - result: ' + e.getMessage());
            System.debug('Error: ' + e.getCause());
        }
        
        return result;
    }

    private static Map<String, String> getRecurringFeeTypes(String recordTypeName){
        Map<String, String> recurringChargeType = new Map<String, String>();
        //Map<String,Map<String,Business_Config__c>> mapProcessData= LibBusinessConfig.getGenericProcessData('addOpportunityLineItems');
        Map<String,Map<String,Business_Config__c>> mapProcessData= moam.get('addOpportunityLineItems');
        Map<String,Business_Config__c> mapBusinessData = mapProcessData.get(recordTypeName);
        if(mapBusinessData!=null && !mapBusinessData.isEmpty()){
            if(mapBusinessData.get('recurringFee') != null && String.isNotBlank(mapBusinessData.get('recurringFee').Business_Rule_Value__c)){
                for(String str : mapBusinessData.get('recurringFee').Business_Rule_Value__c.split(',')){
                    recurringChargeType.put(str, str);
                }
            }
        }
        return recurringChargeType;
    }

    webService static String cloneAssetRemote(String assetId){
        List<String> result = new List<String>();
        CtrAssetScreen ctrAsset = new CtrAssetScreen();
        ctrAsset.theAsset = new Asset__c();

        ctrAsset.theAsset.id = assetId;
        ctrAsset.checkDisplayCloneButton(assetId);
        ctrAsset.cloneAsset();
        if(ctrAsset.strGeneralError != ''){
            return ctrAsset.strGeneralError;
        }
        return ctrAsset.clonedAssetId;
    }
	
    /**
     * clone button on Shipment order page layout
     *
     * @param shipmentID
     *
     * @return
     */
    webService static String cloneShipment(String shipmentID) {
        List<Shipment_Order_Line_Item__c> clonedSOL = new List<Shipment_Order_Line_Item__c>();
        Shipment_Order__C clonedSo;
        try {
            Shipment_Order__c originalSO = ShipmentOrderSelector.getShipmentOrderbyIdWithLineItems(shipmentID);
            clonedSo = new Shipment_Order__c(Account__c = originalSO.Account__c,
                    Opportunity__c = originalSO.Opportunity__c,
                    Opportunity_Quote__c = originalSO.Opportunity_Quote__c,
                    status__c = 'Open');
            insert clonedSo;

            originalSo.is_cloned__c = true;
            update originalSo;

            for (Shipment_Order_Line_Item__c sol : originalSO.shipment_order_line_items__r) {
                clonedSOL.add(new Shipment_Order_Line_Item__c(Opportunity_Quote_Line_Item__c = sol.Opportunity_Quote_Line_Item__c,
                        List_Product_Price__c = sol.List_Product_Price__c,
                        Shipment_Order__c = clonedSo.id,
                        SKU__c = sol.sku__c,
                        Name = sol.name));
            }
            insert clonedSOL;
            return clonedSo.id;
        }catch (Exception e){
            return ('Error '+e.getMessage());
        }
    }
}
