/**
* @author Krunoslav Bilicic
* @date 28.1.2019.
* 
* @group Case
*
* @description Lightning component server side controller for case related operations. This class is used for all Case related lightning components
* All methods are self-explanatory.
*/
public class CaseControllerLightning {

    private static String sessionId;
    private static Map<String, Map<String,Map<String,Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;

    @AuraEnabled
    public static Boolean isCloseCaseButtonDisabled(String caseIdString) {
        return false;
    }

    @AuraEnabled
    public static String closeCase(String caseIdString) {
        Case record = CaseSelector.getCaseDetailsById((Id)caseIdString);
        if(record == null) {
            String error = Label.Case_not_found_for_id + caseIdString;
            return JSON.serialize(new ResultWrapperBuilder(false)
                    .setUserMessage(error)
                    .Build());
        }
        try {
            record.Status = CaseConstants.statusClosed;

            Database.SaveResult saveResult = Database.update(record, true);
            if(saveResult.isSuccess()){
                return JSON.serialize(new ResultWrapperBuilder(true)
                        .setId(record.Id)
                        .setOwnerId(record.OwnerId)
                        .setUserMessage(Label.Case_closed)
                        .Build());
            } else {
                return JSON.serialize(new ResultWrapperBuilder(false)
                        .setId(record.Id)
                        .setOwnerId(record.OwnerId)
                        .setUserMessage(Label.Error_while_closing_case)
                        .setErrorMessage(saveResult.getErrors())
                        .Build());
            }
        } catch (Exception ex) {
            return JSON.serialize(new ResultWrapperBuilder(false)
                    .setId(record.Id)
                    .setOwnerId(record.OwnerId)
                    .setUserMessage(ex.getMessage())
                    .setErrorMessage(ex.getMessage())
                    .Build());
        }
    }

    /**
    * @author ?
    * @date LAST MODIFIED 20-Oct-19
    * @description This is a button on the page when clicked attempts to change ownerID of the record as logged in user
    * Last modified realted to: SP-3791 : Global - Pandora Menu Change Process - Hugh Crinion
    * @return String
    */
    @AuraEnabled
    public static String takeOwnership(String caseIdString) {
        String newOwnerIdString = UserInfo.getUserId();

        Case record = CaseSelector.getCaseDetailsByIdMenuChange((Id)caseIdString);
        String caseRecordType = record.RecordType.Name;
        String ownerName = record.Owner.Name;
        String status = record.Status;
        String type = record.Type;

        //SP-3791: need to be approved from the approval process
        //FP record type prior to approval process
        if(ownerName != null && record.type == 'Menu Change' && caseRecordType.indexOf('FP') > -1)
        {
                record.queue_id__c = record.OwnerId;
                record.OwnerId = newOwnerIdString;

                if(status == 'New' && (record.Case_Reason__c == 'Menu Update Minor' || record.Case_Reason__c == 'Menu Update Major' || record.Case_Reason__c == 'Menu Update Major with Images')) //status == 'Approved' && 
                {
                    record.status = 'Menu Typing';
                }
                else if(status == 'New' && record.Case_Reason__c == 'Imagery only update') //(status == 'Approved' && 
                {
                    record.status = 'Editing';
                }
                Database.SaveResult saveResult = Database.update(record, true);
                if(saveResult.getErrors().isEmpty()){
                    return JSON.Serialize(new ResultWrapperBuilder(true)
                            .setId(record.Id)
                            .setOwnerId(record.OwnerId)
                            .setQueueId(record.queue_id__c)
                            .setUserMessage(Label.BackToQueue_successful)
                            .Build());
                } else {
                    return JSON.Serialize(new ResultWrapperBuilder(false)
                            .setId(record.Id)
                            .setOwnerId(record.OwnerId)
                            .setUserMessage(Label.Back_to_Queue_Unsucessful_AU)
                            .setErrorMessage(Label.Back_to_Queue_Unsucessful_AU)
                            .Build());
                }
        }
        else if (caseRecordType.indexOf('SE') > -1
                || caseRecordType.indexOf('FI') > -1
                || caseRecordType.indexOf('CD') > -1
                || caseRecordType.indexOf('Talabat') > -1
                || caseRecordType.indexOf('DE') > -1
                || caseRecordType.indexOf('PY') > -1
                || caseRecordType.indexOf('AT') > -1
                || caseRecordType.indexOf('FP') > -1
                || caseRecordType.indexOf('HU') > -1
		|| caseRecordType.indexOf('CZ') > -1){
            if (CaseConstants.ownersToCheck.indexOf(ownerName) >= 0) {

                record.Queue_ID__c = record.OwnerId;
                record.OwnerId = newOwnerIdString;
		if (status == 'New' && (type == 'Dish Level Photo' || type == 'Menu Change') && caseRecordType.indexOf('CZ') > -1) {
                    record.status = 'Make Appointment';
                }
                else if (status == 'New' && type == 'Menu Processing') {
                    record.Status = 'Menu Typing';
                } else if (status == 'New' && type == 'Menu Change') {
                    record.Status = 'Menu Typing';
                } else if (status == 'New' && type == 'BE Data Entry' && caseRecordType.indexOf('CD') > -1) {
                    record.Status = 'Finalize Design';
                } else if (status == 'New' && (type == 'Restaurant - Data' || type == 'Dish Level Photo') && (caseRecordType.indexOf('CD') > -1 || caseRecordType.indexOf('SE') > -1)) {
                    record.Status = 'In Progress';
                }
		
		    
                Database.SaveResult saveResult = Database.update(record, true);
                if(saveResult.getErrors().isEmpty()){
                    return JSON.serialize(new ResultWrapperBuilder(true)
                            .setId(record.Id)
                            .setOwnerId(record.OwnerId)
                            .setQueueId(record.Queue_ID__c)
                            .setUserMessage(Label.BackToQueue_successful)
                            .Build());
                } else {
                    return JSON.serialize(new ResultWrapperBuilder(false)
                            .setId(record.Id)
                            .setOwnerId(record.OwnerId)
                            .setUserMessage(Label.Back_to_Queue_Unsucessful_AU)
                            .setErrorMessage(Label.Back_to_Queue_Unsucessful_AU)
                            .Build());
                }
            } else if (record.OwnerId != newOwnerIdString) {
                // replace with label
                return JSON.serialize(new ResultWrapperBuilder(false)
                        .setId(record.Id)
                        .setOwnerId(record.OwnerId)
                        .Build());
            }
        } else {
            record.OwnerId = newOwnerIdString;

            Database.SaveResult saveResult = Database.update(record, true);
            if(saveResult.getErrors().isEmpty()){
                return JSON.serialize(new ResultWrapperBuilder(true)
                        .setId(record.Id)
                        .setOwnerId(record.OwnerId)
                        .setQueueId(record.Queue_ID__c)
                        .setUserMessage(Label.BackToQueue_successful)
                        .Build());
            } else {
                return JSON.serialize(new ResultWrapperBuilder(false)
                        .setOwnerId(record.OwnerId)
                        .setQueueId(record.Queue_ID__c)
                        .setUserMessage(Label.Back_to_Queue_Unsucessful_AU)
                        .setErrorMessage(saveResult.getErrors())
                        .Build());
            }
        }
        return JSON.Serialize(new ResultWrapperBuilder(false)
                .setId(record.Id)
                .setOwnerId(record.OwnerId)
                .Build());
    }

    @AuraEnabled
    public static String getAllPicklistValuesReason3(String caseId){
        picklistWrapper allLevel3=new picklistWrapper();
        sessionId=getSessionIdFromVfPage();
        allLevel3=getValuesBasedOnRecordType(caseId,'Case_Reason_Level_3__c');
        Map<String,List<String>> typeListByLevel1 = DependingPicklistHelper.getDependentPicklistValues(Case.Case_Reason_Level_1__c, Case.Type);
        Map<String,List<String>> L1ListByL2 = DependingPicklistHelper.getDependentPicklistValues(Case.Case_Reason_Level_2__c, Case.Case_Reason_Level_1__c);
        Map<String,List<String>> L2ListByL3 = DependingPicklistHelper.getDependentPicklistValues(Case.Case_Reason_Level_3__c, Case.Case_Reason_Level_2__c);

        String selected2 = '';
        String selected1 = '';
        String type='';
        List<String> combinations = new List<String>();
        if(allLevel3!=null && allLevel3.values!=null) {
            for (picklistValues pickVal : allLevel3.values) {
                if (L2ListByL3.containsKey(pickVal.value.unescapeHtml4())) {
                    selected2 = '';
                    selected1 = '';
                    type='';
                    if(L2ListByL3.get(pickVal.value.unescapeHtml4()).size()==1) {
                        selected2 = L2ListByL3.get(pickVal.value.unescapeHtml4())[0];
                        if(selected2!=null && L1ListByL2.containsKey(selected2) && L1ListByL2.get(selected2)!=null)
                            selected1 = L1ListByL2.get(selected2)[0];
                        if(selected1!=null && typeListByLevel1.containsKey(selected1) && typeListByLevel1.get(selected1)!=null)
                            type = typeListByLevel1.get(selected1)[0];
                        if (selected2!='' && selected1!='' && type!='') {
                            combinations.add(pickVal.value.unescapeHtml4() + '&&' + selected2 + '&&' + selected1 + '&&' + type);
                        }
                    }
                    else if(L2ListByL3.get(pickVal.value.unescapeHtml4()).size()>1){
                        for(String level2:L2ListByL3.get(pickVal.value.unescapeHtml4())){
                            selected2 = '';
                            selected1 = '';
                            type='';
                            selected2 = level2;
                            if(selected2!=null && L1ListByL2.containsKey(selected2) && L1ListByL2.get(selected2)!=null)
                                selected1 = L1ListByL2.get(selected2)[0];
                            if(selected1!=null && typeListByLevel1.containsKey(selected1) && typeListByLevel1.get(selected1)!=null)
                                type = typeListByLevel1.get(selected1)[0];
                            if (selected2!='' && selected1!='' && type!='') {
                                combinations.add(pickVal.value.unescapeHtml4()+' (related to '+selected2+')' + '&&' + selected2 + '&&' + selected1 + '&&' + type);
                            }
                        }
                    }
                }
            }
        }
        return JSON.serialize(combinations);
    }

    @AuraEnabled
    public static Map<String,Map<String,String>> getAllPicklistValues(String caseId){
        sessionId=getSessionIdFromVfPage();
        Map<String,Map<String,String>> fieldValues = new Map<String,Map<String,String>>();
        picklistWrapper allType=new picklistWrapper();
        allType=getValuesBasedOnRecordType(caseId,'Type');
        Map<String,String> allTypeValueLabelMap=new Map<String,String>();
        allTypeValueLabelMap=getValueLabel(Case.Type);
        Map<String,String> selectedTypeValueLabelMap=new Map<String,String>();
        if(allType!=null && allType.values!=null) {
            for (picklistValues pickVal : allType.values) {
                if (allTypeValueLabelMap.containsKey(pickVal.value)) {
                    selectedTypeValueLabelMap.put(pickVal.value, allTypeValueLabelMap.get(pickVal.value));
                }
            }
        }
        fieldValues.put('type',selectedTypeValueLabelMap);
        fieldValues.put('level1',getValueLabel(Case.Case_Reason_Level_1__c));
        fieldValues.put('level2',getValueLabel(Case.Case_Reason_Level_2__c));
        fieldValues.put('level3',getValueLabel(Case.Case_Reason_Level_3__c));
        return fieldValues;
    }

    @AuraEnabled
    public static Case getCurrentCaseReason(String caseId){
        try {
            Case c = CaseSelector.getCaseDetailsById(caseId);
            if(c!=null) {
                return c;
            }
            return null;
        } catch (Exception ex) {
            return null;
        }
    }

      /**
      * @desc get Case data directly from Case or via chat 
      * @param string - Case Id or chat Id
      * @return - wrapper string containing case attributes
    */
    @AuraEnabled
    public static String getCaseFromChat(String objrecId) {
         Id recId = Id.valueOf(objrecId);
         List<LiveChatTranscript> chats = new List<LiveChatTranscript>();
         Case resCase = new Case() ;
         Id  caseId ;
         IF(!String.isEmpty(recId)){
             TRY{
                    IF(recId.getSObjectType().getDescribe().getName() == 'LiveChatTranscript'){
                         chats = LiveChatTranscriptSelector.getChatCaseFieldsByChatTranscriptsId(recId);
                         if(chats.size() == 1) {
                             caseId = chats[0].CaseId ;
                             return JSON.Serialize(new ResultWrapperBuilder(true).setId(caseId)
                            .setKeyValuePair('Order_Number__c', chats[0].Case.Order_Number__c)
                            .setKeyValuePair('Platform__c', chats[0].Case.Platform__c)
                            .setKeyValuePair('Country__c', chats[0].Case.Country__c)
							.setKeyValuePair('Partial_Refund_Type__c', chats[0].Case.Partial_Refund_Type__c)
                            .setKeyValuePair('Customer_Id__c', chats[0].Case.Customer_ID__c)
                            .setKeyValuePair('Customer_Name__c', chats[0].Case.Customer_Name__c)
                            .Build());
                         }
                     }
                     ELSE IF(recId.getSObjectType().getDescribe().getName() == 'Case'){
                         resCase = CaseSelector.getCaseDetailsById(objrecId);
                         return JSON.Serialize(new ResultWrapperBuilder(true).setId(resCase.Id)
                            .setKeyValuePair('Order_Number__c', resCase.Order_Number__c)
                            .setKeyValuePair('Platform__c', resCase.Platform__c)
                            .setKeyValuePair('Country__c', resCase.Country__c)
							.setKeyValuePair('Partial_Refund_Type__c', resCase.Partial_Refund_Type__c)
                            .setKeyValuePair('Customer_Id__c', resCase.Customer_ID__c)
                            .setKeyValuePair('Customer_Name__c', resCase.Customer_Name__c)
                            .Build());
                     }               
                }catch (Exception ex) {
                        return JSON.Serialize(new ResultWrapperBuilder(false).setErrorMessage(ex.getMessage()).Build());
                }    
            }   
            return JSON.Serialize(new ResultWrapperBuilder(false).Build());    
        }
   
   /* @AuraEnabled
    public static String getCaseFromChat(String chatTranscriptId, String objName) {
         List<LiveChatTranscript> chats = LiveChatTranscriptSelector.getChatCaseFieldsByChatTranscriptsId(chatTranscriptId);
         if(chats.size() == 1) {
            return JSON.Serialize(new ResultWrapperBuilder(true).setId(chats[0].CaseId)
                    .setKeyValuePair('Order_Number__c', chats[0].Case.Order_Number__c)
                    .setKeyValuePair('Platform__c', chats[0].Case.Platform__c)
                    .setKeyValuePair('Country__c', chats[0].Case.Country__c)
                    .Build());

        } else {
            return JSON.serialize(new ResultWrapperBuilder(false).Build());
        }
    }

    @AuraEnabled
    public static String getCaseOrder(String caseId) {
        try {
            Case resCase = CaseSelector.getCaseDetailsById(caseId);
            return JSON.serialize(new ResultWrapperBuilder(true).setId(resCase.Id)
                    .setKeyValuePair('Order_Number__c', resCase.Order_Number__c)
                    .setKeyValuePair('Platform__c', resCase.Platform__c)
                    .setKeyValuePair('Country__c', resCase.Country__c)
                    .Build());
        } catch (Exception ex) {
            return JSON.serialize(new ResultWrapperBuilder(false).setErrorMessage(ex.getMessage()).Build());
        }
    }

    /**
     * @description Mark the case as complete and go to the next step..
     *
     * @param caseId
     *
     * @return List<String> with outcome result.
     * @see ClsRemoteController_Utils.markComplete(String, Map<String, Map<String,Map<String,Business_Config__c>> >)
     */
    @AuraEnabled
    public static String markComplete(String caseIdString) {
        List<String> results = ClsRemoteController_Utils.markComplete(caseIdString, moam);
        try {
            return JSON.serialize(new ResultWrapperBuilder(results.get(0).equals(Label.Mark_Complete_Success))
                    .setId((Id)caseIdString)
                    .setUserMessage(results.get(0))
                    .Build());
        } catch (NullPointerException e) {
            return JSON.serialize(new ResultWrapperBuilder(false).setErrorMessage(e.getMessage()).setUserMessage(e.getMessage()).Build());
        }
    }

    /**
     * @description Undo the case as complete and return it to previous step.
     *
     * @param caseId
     *
     * @return List<String> with outcome result
     * @see ClsRemoteController_Utils.undoComplete(String, Map<String, Map<String,Map<String,Business_Config__c>> >)
     */
    @AuraEnabled
    public static String undoComplete(String caseIdString) {
        List<String> results = ClsRemoteController_Utils.undoComplete(caseIdString, moam);
        try {
            return JSON.serialize(new ResultWrapperBuilder(results.get(0).equals(Label.Undo_Complete_Success))
                    .setId((Id)caseIdString)
                    .setUserMessage(results.get(0))
                    .Build());
        } catch (NullPointerException e) {
            return JSON.serialize(new ResultWrapperBuilder(false).setErrorMessage(e.getMessage()).setUserMessage(e.getMessage()).Build());
        }
    }

    private static string getSessionIdFromVfPage(){
        PageReference visualforcePage = Page.SessionIdPage;
        String content;
        try{
            content = visualforcePage.getContent().toString();
        }
        catch(VisualforceException e){
            content='ID'+userinfo.getSessionId()+'END';
        }
        Integer s = content.indexOf('ID') + 'ID'.length();
        Integer e = content.indexOf('END');
        return content.substring(s, e);
    }

    //Wrapper class to handle the JSON response
    public class picklistWrapper{
        @AuraEnabled public picklistValues[] values;
    }
    public class picklistValues {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    //Method to get case reason level 3 picklist values based on record types by using UI-API.
    public static picklistWrapper getValuesBasedOnRecordType(String caseId,String field){
        String sObjName = ((Id)caseId).getSObjectType().getDescribe().getName();
        string BaseUrl=system.Url.getOrgDomainUrl().toExternalForm();
        Case c=CaseSelector.getCaseDetailsById(caseId);
        httprequest request= new httprequest();
        request.setMethod('GET');
        request.setEndpoint(BaseUrl+'/services/data/v44.0/ui-api/object-info/'+sObjName+'/picklist-values/'+c.RecordTypeId+'/'+field);
        request.setHeader('Authorization', 'Bearer ' + sessionId);
        request.setHeader('Content-Type','application/json; charset=UTF-8');
        request.setHeader('Accept','application/json');

        http http = new http();
        try {
            httpresponse response = http.send(request);
            if (response != null && response.getBody() != null) {
                picklistWrapper obj = (picklistWrapper) JSON.deserialize(response.getBody(), picklistWrapper.class);
                return obj;
            }
        }catch(Exception e) {
            system.debug('Exception occurred: '+e);
        }
        return null;
    }
  
    public static map<String,String> getValueLabel(Schema.sObjectField field){
        map<string,string> valueLabelMap = new map<String,string>();
        for(Schema.PicklistEntry ple:field.getDescribe().getPicklistValues()){
            valueLabelMap.put(ple.getValue(),ple.getLabel());
        }
        return valueLabelMap;
    }
  
 //Getting url from
    public static String getUrlString(String key,String jsonString,String platform, String country){
        String urlString='Not Found';
        List<Map<String, String>> platformCountryMapList = (List<Map<String, String>>) JSON.deserialize(jsonString, List<Map<String, String>>.class);
        for (Map<String, String> platformCountryMap : platformCountryMapList) {
            if (key!='hurrierDetails' || (key=='hurrierDetails' && platformCountryMap.containsKey('Platform') && platformCountryMap.get('Platform') == platform)) {
                if (platformCountryMap.containsKey(country)) {
                    return platformCountryMap.get(country);
                }
            }
        }
        return urlString;
    }
  
	/**
      * @desc get custom setting based on which aura components visibility will be controlled
	  * @param: name of the custom setting
      * @return - Aura Component Visibility custom setting
      */
	
	@AuraEnabled
    public static AuraComponentVisibilityControl__c getOrderCompsVisibilitySetting(String settingName){
        try{ 
			AuraComponentVisibilityControl__c custSettin ;
			if(!String.isEmpty(settingName))
				custSettin = AuraComponentVisibilityControl__c.getValues(settingName) ;     
			return custSettin ;
        }catch(exception e){
            system.debug('exception occured in getCompsVisibilitySetting'+e.getMessage());
        }
			return new AuraComponentVisibilityControl__c() ;
    }
}
