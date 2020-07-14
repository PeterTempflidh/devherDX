public without sharing class HistoricalCases_AuraController{

    public static String caseFields='';
    public static String chatFields='';
    public static String whereClause='';
    public static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;

    //Retrieve cases for same customer from chat/case record.
    @AuraEnabled
    public static CaseDetailsWrapper getCases(Id recId,Boolean isRelatedList,String loadCriteria){
        CaseDetailsWrapper caseDetails = new CaseDetailsWrapper();
		try{
			Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('HistoricalCaseConfigs');
			Business_Config__c parameters=new Business_Config__c();
			Business_Config__c columnOrders=new Business_Config__c();
			List<Schema.FieldSetMember> caseFieldSetMembers = new List<Schema.FieldSetMember>();
			List<Schema.FieldSetMember> chatFieldSetMembers = new List<Schema.FieldSetMember>();
			/**SCC-98**/
			Business_Config__c excludeOrders =new Business_Config__c();
			excludeOrders = mapBusinessLogic.get('Global_Config').get('PatternToExclude');

			if(!isRelatedList){
				caseFieldSetMembers = SObjectType.Case.FieldSets.HistoricalCasesColumnsFull.getFields();
			}
			else{
				caseFieldSetMembers = SObjectType.Case.FieldSets.HistoricalCasesColumnsRelatedList.getFields();
			}
			chatFieldSetMembers = SObjectType.LiveChatTranscript.FieldSets.HistoricalCasesColumns.getFields();

			for(Schema.FieldSetMember field:caseFieldSetMembers){
				if(Schema.SObjectType.Case.fields.getMap().get(field.getFieldPath()).getDescribe().getType()==Schema.DisplayType.PICKLIST) {
					caseFields = caseFields + ' toLabel(' + field.getFieldPath() + '),';
				}
				else{
					caseFields = caseFields + ' ' + field.getFieldPath() + ',';
				}
			}
			for(Schema.FieldSetMember field:chatFieldSetMembers){
				chatFields=chatFields+' '+field.getFieldPath()+',';
			}
			if(mapBusinessLogic == null) {
				return null;
			}
			parameters = mapBusinessLogic.get('Global_Config').get('Parameters');
			if(isRelatedList){
				columnOrders = mapBusinessLogic.get('Global_Config').get('ColumnOrderRelatedList');
			}
			else{
				columnOrders = mapBusinessLogic.get('Global_Config').get('ColumnOrderFull');
			}
			String objectName = recId.getSObjectType().getDescribe().getName();
			Case currentCase = new Case();
			List<Case> cases = new List<Case>();
			if(objectName == 'Case') {
				if (isRelatedList) {
					currentCase = CaseSelector.getCaseWithDynamicFields('HistoricalCasesColumnsRelatedList', recId);
				} else {
					currentCase = CaseSelector.getCaseWithDynamicFields('HistoricalCasesColumnsFull', recId);
				}
			}
			else if(objectName == 'LiveChatTranscript') {
				List<LiveChatTranscript> chat = LiveChatTranscriptSelector.getChatCaseFieldsByChatTranscriptsId(recId);
				if (chat.size() > 0 && chat[0].CaseId != null) {
					if (chat[0].CaseId != null) {
						if (isRelatedList) {
							currentCase = CaseSelector.getCaseWithDynamicFields('HistoricalCasesColumnsRelatedList', chat[0].CaseId);
						} else {
							currentCase = CaseSelector.getCaseWithDynamicFields('HistoricalCasesColumnsFull', chat[0].CaseId);
						}
					}
				}
			}
			if(currentCase == null) {
				return null;
			}
			Boolean queryOrders = currentCase.Order_Number__c !=''?checkIfOrderHasZeroesOrXs(currentCase, excludeOrders):TRUE;
			if(loadCriteria!='On Init') {
				if (loadCriteria == 'ordersList') {
					if (currentCase.Order_Number__c != '') {
						whereClause = ' WHERE id!=\'' + currentCase.Id + '\' AND Platform__c=\'' + currentCase.Platform__c + '\'';
						if(queryOrders){
							whereClause+=' AND Order_Number__c=\'' + currentCase.Order_Number__c + '\'';
						}
						whereClause += 'ORDER BY CreatedDate DESC';
					}
				} else {
					List<String> conditions = parameters.Business_Rule_Value__c.split(',');
					if (conditions.size() == 0) {
						return null;
					}
					for (String condition : conditions) {
						if (currentCase.get(condition) != null) {
							whereClause = whereClause + ' ' + condition + '=\'' + currentCase.get(condition) + '\' OR';
						}
					}
					if (whereClause != '') {
						whereClause = ' WHERE CreatedDate = LAST_N_DAYS:30 AND id!=\'' + currentCase.Id + '\' AND Platform__c=\'' + currentCase.Platform__c + '\' AND (' + whereClause.substring(0, whereClause.length() - 3) + ') ORDER BY CreatedDate DESC';
					}
				}
			}
			else{
				List<String> conditions = parameters.Business_Rule_Value__c.split(',');
				if (conditions.size() == 0) {
					return null;
				}
				String conditionsString='';
				for (String condition : conditions) {
					if (currentCase.get(condition) != null) {
						conditionsString = conditionsString + ' ' + condition + '=\'' + currentCase.get(condition) + '\' OR';
					}
				}
				whereClause = ' WHERE id!=\'' + currentCase.Id + '\' AND Platform__c=\'' + currentCase.Platform__c + '\' AND ';
				if(conditionsString.length()>0){
					whereClause += '(((' + conditionsString.substring(0, conditionsString.length() - 3) + ') AND CreatedDate = LAST_N_DAYS:90)';
				}
				if(queryOrders){
					if(conditionsString.length()>0){
						whereClause+=' OR (Order_Number__c=\'' + currentCase.Order_Number__c + '\')';
					}
					else{
						whereClause+=' (Order_Number__c=\'' + currentCase.Order_Number__c + '\'';
					}
				}
				whereClause += ') ORDER BY CreatedDate DESC';
			}
			String query = 'SELECT';
			if (caseFields != '') {
				query = query + caseFields.substring(0, caseFields.length() - 1);
			}
			if(chatFields != ''){
				if(caseFields != ''){
					query = query + ', (SELECT' + chatFields.substring(0, chatFields.length() - 1) + ' FROM LiveChatTranscripts)';
				}
				else{
					query = query + ' (SELECT' + chatFields.substring(0, chatFields.length() - 1) + ' FROM LiveChatTranscripts)';
				}
			}
			if(query != 'SELECT' && whereClause != ''){
				query = query + ',(SELECT qualtrics__Net_Promoter_Score__c FROM Survey_Responses__r) FROM Case' + whereClause;
				cases = database.query(query);
			}
			
			/*if(cases.size() == 0) {
				return null;
			}*/
			caseDetails.currentCase = currentCase;
			caseDetails.caseList = cases;
			caseDetails.columnOrder = (List<Map<String, String>>) JSON.deserialize(columnOrders.Business_Rule_Value__c, List<Map<String, String>>.class);
			caseDetails.showCasesWithSameOrder = queryOrders;
        }catch(Exception e){
            Loggingutility.createLog('HistoricalCases_AuraController','getCases','','');
            LoggingUtility.log('HistoricalCases_AuraController-getCases','\nError : ' + e.getMessage() );
            LoggingUtility.commitLogs();
        }
		return caseDetails;
    }
	/** SCC-98-Exclude Order Number with certain pattern, for e.g. 0s and Xs Pattern Logic **/
	public static Boolean checkIfOrderHasZeroesOrXs(Case pCurrentCase, Business_Config__c pExcludeOrders){         
        List<Map<String, List<Map<String,String>>>> patternConfig = (List<Map<String, List<Map<String,String>>>>) JSON.deserialize(pExcludeOrders.Business_Rule_Value__c, List<Map<String, List<Map<String,String>>>>.class);
        List<String> patternChars = new List<String>();  
        List<Map<String,String>> mptemp = new List<Map<String,String>>();
        Map<String,String> tempMap = new Map<String,String>();
		Boolean showCaseWithSameOrder = TRUE;

        FOR(Map<String, List<Map<String,String>>> mr:patternConfig){
            If(mr.containsKey('Case') && mr.get('Case')!=null){       
                mptemp.addAll(mr.get('Case'));
            }    
        }

        FOR(Map<String,String> mp: mptemp){
            IF(mp.containsKey('Order_Number__c') && !String.isEmpty((String)mp.get('Order_Number__c'))){
                tempMap.put('Order_Number__c',mp.get('Order_Number__c'));
                IF(mp.get('Order_Number__c').contains(',')){
                    patternChars = mp.get('Order_Number__c').split(',');
                }ELSE{
                    patternChars.add(mp.get('Order_Number__c'));
                }
            }
        }
        
        FOR(String s: patternChars){
            IF(!tempMap.isEmpty() && tempMap.containsKey('Order_Number__c') && (String)pCurrentCase.get('Order_Number__c') !=null
               && (((String)pCurrentCase.get('Order_Number__c')).containsOnly(s))){
                showCaseWithSameOrder = FALSE;
                break;
            }
        }
       
        return showCaseWithSameOrder;
    }

    public class CaseDetailsWrapper{
        @AuraEnabled public Case currentCase;
        @AuraEnabled public List<case> caseList;
        @AuraEnabled public List<Map<String,String>> columnOrder;
		/**SCC-98-New property added**/
		@AuraEnabled public Boolean showCasesWithSameOrder  = TRUE ;
    }

}