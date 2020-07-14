/**
    * This class is created to handle trigger logic for the Inbound Cases or cases for service cloud.
    * CreatedBy: Tarun Jain
	* Update - SCC-303- Added escalataion logic for Apac based primary on Language code field and then on country field value on Case.
	*          A new custom setting is introduced to store the mapping of CRL2 and CRL3 as there are 65 values which needs to be considered. 
	*          The same can be further extended to set escalation when there are huge value sets on case reasons.
*/
public class DH_InboundCaseProcessor {
    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
	/**SC-303 **/
	public static Set<String> exceptionCountryCodes = new Set<String>();
    public static Map<String,String> countryQueuesCodesMap = new Map<String,String>();
    public static Map<String,String> languageQueuesCodesMap = new Map<String,String>();
    public static List<Service_Recovery_Escalation__c> recoveryCRLs = Service_Recovery_Escalation__c.getall().values();
	//SCC-303
	public static final String excludeEscRuleKey = 'Exclude This Rule';
    public static final String excludeEscRuleCriteriaKey = 'Exclude Rule Criteria';
    public static final String additionalCaseRule = 'Additional Cases';
	//Avoid duplicate child cases
	public static Boolean triggerEscalation = FALSE ;


    /* @description Logic for case escalation for inbound cases for CS & PS
     *
     * @param newCases - Trigger.new
     * @param oldCases - Trigger.oldMap()
     * @param newCases - Trigger.newMap()
     */
    public static List<Case> escalateCase(List<Case> newCases, Map<Id,Case> oldCases, Map<Id,Case> newCasesMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('CaseEscalationLogic');
        Map<String, List<Case>> caseOwnerMap = new Map<String, List<Case>>();
        //SC-303
		Map<String,String> countryQueueNameMap = new Map<String,String>();       
        boolean isQueueAssignmentForRecovery ;
        boolean useLanguageForRecoveryQueueAssignment =false;
		Set<String> countryCodesQueuesNames = new Set<String>();
        Set<String> languageCodesQueuesNames = new Set<String>();
		Boolean additionalEscCases = false ;

        //Loop through trigger.new to check escalation logic
        for (Case newCase : newCases) {
            boolean isCCRSameForEscalatedCase = (oldCases.get(newCase.id).escalate__c &&
                    newCase.escalate__c &&
                    oldCases.get(newCase.id).Case_reason_Level_3__c == newCase.Case_Reason_Level_3__c &&
                    newCase.escalate__c && oldCases.get(newCase.id).Case_reason_Level_2__c == newCase.Case_Reason_Level_2__c);
            if ((!newCase.escalate__c) || isCCRSameForEscalatedCase) {
                continue;
            }
            if(mapBusinessLogic.get(newCase.Platform__c) == null){
                continue;
            }
            try {
                Map<String, Business_Config__c> escalationConfigMap = mapBusinessLogic.get(newCase.Platform__c);
                Boolean isEscalationLogicFound=false;
                for (String key : escalationConfigMap.keySet()) {
                    Map<String, String> escalationLogicMap = (Map<String, String>) JSON.deserialize(escalationConfigMap.get(key).Business_Rule_Value__c, Map<String, String>.class);

                    //Validate if escalationParams are correct
                    boolean isParamsListValid = validateEscalationParams(newCase,escalationLogicMap);
                    if(!isParamsListValid){
                        continue;
                    }
					//SCC-303 - skip current escalation to trigger another specific escalation
					Boolean skipCurrentEscalation = false;
                    skipCurrentEscalation = checkIfNeedToExcludeCurrEsc(newCase,escalationLogicMap);
                    if(skipCurrentEscalation){
                        continue;
                    }
                    isEscalationLogicFound=true;
                    if (escalationLogicMap.get('New Case') == 'FALSE') {
                        //Create ownerMap for Case
                        caseOwnerMap  = setEscalatedCaseOwner(newCase,escalationLogicMap.get('Queue'),caseOwnerMap);
                        break;
                    }
                    else {
                        if(escalationLogicMap.containsKey('Status')) {
                            Boolean statusHasAdditionalOperator = escalationLogicMap.get('Status').contains('::')?true:false ;
                            newCase.Status = statusHasAdditionalOperator?escalationLogicMap.get('Status').substringAfter('::'):escalationLogicMap.get('Status');
                        }
                        boolean isStatusClosedOrResolved = (newCase.Status == 'Closed' || newCase.Status == 'Resolved');

                        //Close Current Case
                        if (isStatusClosedOrResolved) {
                            newCase.Override_Validations__c = true;
                            newCase.Override_Validation_Reason__c = 'Case Escalated To Sales Admin';
                        }
						 if(escalationLogicMap.containsKey(additionalCaseRule)
                            && !String.isEmpty(escalationLogicMap.get(additionalCaseRule))){
                            additionalEscCases = true;
                        }

                        //Create child case & assign ownerMap
                        caseOwnerMap = createEscalatedCases(newCase,escalationLogicMap,caseOwnerMap,additionalEscCases,escalationConfigMap);

                        boolean isQueueAssignmentDynamic =  (escalationLogicMap.get('Queue').contains('<Country_Code>') ||
                                (escalationLogicMap.get('Queue').contains('-') &&
                                        escalationLogicMap.get('Queue').contains(',')));
						//Language based queue assignment logic
						isQueueAssignmentForRecovery = escalationLogicMap.get('Queue').contains('<Language_Code>')?true:false;
						//In language based assignment, need to check when language is not there then consider country else language code on case
                        boolean useCountryForRecoveryQueueAssignment = (String.isEmpty(newCase.Language_Code__c) && !String.isEmpty(newCase.Country__c))?true:false ;
                        //Additional or statement to get country queue name in 'countryCodesQueuesNames' when language code is not there
                        if(isQueueAssignmentDynamic || (isQueueAssignmentForRecovery && useCountryForRecoveryQueueAssignment)){
                            countryQueueNameMap.put(newCase.Country__c,escalationLogicMap.get('Queue'));
							if(escalationLogicMap.containsKey('Country_Queue') && !String.isEmpty(escalationLogicMap.get('Country_Queue'))){
                                if(escalationLogicMap.get('Country_Queue').contains(',')){
                                    countryCodesQueuesNames = new Set<String>(escalationLogicMap.get('Country_Queue').split(','));
                                }else{
                                    countryCodesQueuesNames.add(escalationLogicMap.get('Country_Queue'));
                                }
                            }
                        }//Else language based queue name in 'languageCodesQueuesNames'
						else if(!isQueueAssignmentDynamic && !useCountryForRecoveryQueueAssignment){
                            useLanguageForRecoveryQueueAssignment = true ;                          
                            if(escalationLogicMap.containsKey('Language_Queue') && !String.isEmpty(escalationLogicMap.get('Language_Queue'))){
                                if(escalationLogicMap.get('Language_Queue').contains(',')){
                                    languageCodesQueuesNames = new Set<String>(escalationLogicMap.get('Language_Queue').split(','));
                                }else{
                                    languageCodesQueuesNames.add(escalationLogicMap.get('Language_Queue'));
                                }
                            }
                        
						}
						break;
                }
                
				}
				if(!isEscalationLogicFound){
                    system.debug(LoggingLevel.ERROR, 'Case Escalation is not applicable');
                    newCase.addError(Label.Case_Escalation_Not_Applicable);
                }
            } catch (Exception e) {
                system.debug(LoggingLevel.ERROR, 'Exception: '+e+'Stack Trace: '+e.getStackTraceString());
                newCase.addError(Label.Case_Escalation_Error);
            }
        }

        //Identify queues for cases process above to either create child case of update existing case
        if (caseOwnerMap == null || caseOwnerMap.keySet().size() == 0) {
            return new List<Case>();
        }
		if(!countryCodesQueuesNames.isEmpty()){
            countryQueuesCodesMap = getLanguageOrCountryQueueSuffixMap(countryCodesQueuesNames);
        }
        if(countryQueueNameMap!=null && countryQueueNameMap.keySet().size()!=0) {
            caseOwnerMap = getEscalationQueueName(countryQueueNameMap.keySet(),caseOwnerMap);
        }
		if(useLanguageForRecoveryQueueAssignment){
            caseOwnerMap.putAll(getEscalationQueueNameOnLanguage(caseOwnerMap,languageCodesQueuesNames));
        }
        List<Case> casesToInsert = new List<Case>();
        List<String> queueNames = new List<String>();
        queueNames.addAll(caseOwnerMap.keyset());
        List<Group> queueOwners = GroupSelector.getQueuesByDeveloperName(queueNames);
        Map<String, Group> queueOwnersMap = new Map<String, Group>();
        for(Group gr : queueOwners){
            queueOwnersMap.put(gr.DeveloperName, gr);
        }
        Set<Id> caseIdWithEscalationError = new Set<Id>();
        for (String queueName : caseOwnerMap.keySet()) {
            if(queueName.contains('<Country_Code>') || queueName.contains('-') || queueName.contains('<Language_Code>')){
                continue;
            }
            for (Case childCase : caseOwnerMap.get(queueName)) {
                if(!queueOwnersMap.containsKey(queueName)) {
                    caseIdWithEscalationError.add(childCase.ParentId);
                    continue;
                }
                Group ownerQueue = queueOwnersMap.get(queueName);
                childCase.OwnerId = ownerQueue.Id;
                if (childCase.ParentId != null) {
                    casesToInsert.add(childCase);
                }
            }
        }
        for(String caseId:caseIdWithEscalationError){
            system.debug(LoggingLevel.ERROR, 'Case Escalation is not applicable');
            newCasesMap.get(caseId).addError(Label.Case_Escalation_Not_Applicable);
        }
        return casesToInsert;
    }

    /* @description Validate the params in the business config
     *
     * @param c - Case in trigger context
     * @param escalationLogicMap - Map<String, String> Map of business rule in CaseEscalationLogic Business Config
	   @Updated - SCC-303 - to include CRLs values through custom setting
    */
    public static boolean validateEscalationParams(Case newCase, Map<String, String> escalationLogicMap){
        String params = escalationLogicMap.get('Parameters');
        List<String> paramsList = new List<String>();
		//SCC-303
		Map<String, String> mapOfCLR1And2 ;
        Boolean isThroughCustomSetting = false;
        Boolean hasCaseReasonLevel2And3ForApacRecovery = false;
		
        if (params.contains(',')) {
            paramsList = params.split(',');
        }
        else {
            paramsList.add(params);
        }
		
		isThroughCustomSetting = !paramsList.isEmpty() && paramsList.contains('CLRThroughCustomSetting') && !escalationLogicMap.isEmpty() && escalationLogicMap.containsKey('Type')?true:false;
        if(isThroughCustomSetting){
            Map<String, String> clrsMapping = new Map<String, String>();
            if(!escalationLogicMap.isEmpty() && escalationLogicMap.containsKey('Type') && !String.isEmpty(escalationLogicMap.get('Type'))){
                clrsMapping = getclrs1_2Mapping(escalationLogicMap.get('Type'));
            }
            mapOfCLR1And2 = !clrsMapping.isEmpty()?clrsMapping:new Map<String,String>();
        }
		
        if(!paramsList.isEmpty() && paramsList.contains('CLRThroughCustomSetting')){
            Set<String> setString = new Set<String>(paramsList);
            setString.remove('CLRThroughCustomSetting');
            paramsList = new List<String>(setString);
        }
        Integer i = 0;
        for (String param : paramsList) {
            if (newCase.get(param)==null || (!escalationLogicMap.get(param).contains(string.valueOf(newCase.get(param))) && 		   escalationLogicMap.get(param) != 'NOTNULL' && !isThroughCustomSetting)) {
                continue;
            }
            if(param == 'Case_Reason_Level_3__c') {
				 hasCaseReasonLevel2And3ForApacRecovery = checkIfCaseReasonsValidationIsThroughCustomSetting(newCase, isThroughCustomSetting, mapOfCLR1And2 );
               
                if (escalationLogicMap.keyset().contains(newCase.Case_Reason_Level_2__c)|| hasCaseReasonLevel2And3ForApacRecovery) {
                    i++;
                }
            }
            else {
                i++;
            }

        }
        if (paramsList.size() != i) {
            return false;
        }
        return true;
    }

    /* @description Fetch Queue Name if the queue name is dynamic in the Business Config
     *
     * @param countryNames - Set<String> Country names for cases in the trigger context
     * @param caseOwnerMap - Map<String, List<Case>> Map of queue name with List of cases to be updated
    */
    public static Map<String, List<Case>> getEscalationQueueName(Set<String> countryNames,Map<String, List<Case>> caseOwnerMap){
        Map<String,String> countryNameIsoCodeMap = new Map<String,String>();
        List<Country__c> countries = CountrySelector.getCountryList(countryNames);
        for (Country__c country : countries) {
            countryNameIsoCodeMap.put(country.name, country.Iso__c);
        }
        for (String queueName : caseOwnerMap.keySet()) {
            Map<String, String> countryQueueMap = new Map<String, String>();
            if (queueName.contains('-') && queueName.contains(',')) {
                List<String> queueList = queueName.split(',');
                for (String countryQueueName : queueList) {
                    countryQueueMap.put(countryQueueName.split('-')[0], countryQueueName.split('-')[1]);
                }
            }
            for (Case newCase : caseOwnerMap.get(queueName)) {
                String queueNameString = '';
                if (queueName.contains('-') && queueName.contains(',')) {
                    queueNameString = countryQueueMap.containsKey(newCase.Country__c)?countryQueueMap.get(newCase.Country__c):countryQueueMap.get('Others');
                }
                else if(queueName.contains('<Country_Code>') && countryNameIsoCodeMap.containsKey(newCase.Country__c)){
                    queueNameString = queueName.replace('<Country_Code>', countryNameIsoCodeMap.get(newCase.Country__c));
                }
                else if(queueName.contains('<Language_Code>') && countryNameIsoCodeMap.containsKey(newCase.Country__c)){                   
                    if(!countryQueuesCodesMap.isEmpty() && countryQueuesCodesMap.containsKey(countryNameIsoCodeMap.get(newCase.Country__c))){  
                         queueNameString = queueName.replace('<Language_Code>', countryQueuesCodesMap.get(countryNameIsoCodeMap.get(newCase.Country__c)));                  
                    }
                }
				else{
					 //Placeholder for future enhancements
				}
                if(queueNameString!=''){
                    caseOwnerMap =  setEscalatedCaseOwner(newCase,queueNameString,caseOwnerMap);
                }
            }
        }
        return caseOwnerMap;
    }

    /* @description Create escalated child cases for the inbound case
     *
     * @param c - Case in the trigger context
     * @param escalationLogicMap - Map<String, String> Map of business rule in CaseEscalationLogic Business Config
     * @param caseOwnerMap - Map<String, List<Case>> Map of queue name with List of cases to be updated
    */
    public static Map<String, List<Case>> createEscalatedCases(Case caseToEscalate, Map<String, String> escalationLogicMap,Map<String, List<Case>> caseOwnerMap, Boolean pAdditionalCase, Map<String, Business_Config__c> escalationConfigMap){
        if(triggerEscalation){  return new Map<String, List<Case>>();}
		Case newCase = new Case();
        newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(escalationLogicMap.get('New Case RecordType')).getRecordTypeId();
        newCase.Customer_Email__c = caseToEscalate.Customer_Email__c;
        newCase.Country__c = caseToEscalate.Country__c;
        newCase.Subject = caseToEscalate.Subject;
        newCase.Description = caseToEscalate.Description;
        newCase.ParentId = caseToEscalate.Id;
        newCase.Platform__c = caseToEscalate.Platform__c;
        List<String> fieldsToSet = escalationLogicMap.get('Fields').split(',');
        for (String field : fieldsToSet) {
            String newFieldValue = escalationLogicMap.get('New.'+field);
            if(newFieldValue.contains('Parent.')){
                newCase.put(field, caseToEscalate.get(newFieldValue.split('Parent.')[1]));
            }
            else {
                newCase.put(field, newFieldValue);
            }
        }
		//Second escalation child case on same parent case.
        Boolean triggerAdditionalCase = (pAdditionalCase && escalationConfigMap.containskey(escalationLogicMap.get(additionalCaseRule)) 
        && escalationConfigMap.get(escalationLogicMap.get(additionalCaseRule))!=null)?true:false;
        if(triggerAdditionalCase){
            String additionalRuleName  = escalationLogicMap.get(additionalCaseRule);
            Map<String,String> newEscRule = new Map<String, String>();           
            newEscRule = (Map<String, String>) JSON.deserialize(escalationConfigMap.get(escalationLogicMap.get(additionalCaseRule)).Business_Rule_Value__c, Map<String, String>.class);
            Boolean validateAdditionalEsc = validateEscalationParams(caseToEscalate, newEscRule);
			if(validateAdditionalEsc){
				createEscalatedCases(caseToEscalate,newEscRule,caseOwnerMap, false, escalationConfigMap);
			}
          
        }
        caseOwnerMap  = setEscalatedCaseOwner(newCase,escalationLogicMap.get('Queue'),caseOwnerMap);
        return caseOwnerMap;
    }


    /* @description Create/Update caseOwnerMap to map queue names against list of cases for that queue
     *
     * @param c - Case in the trigger context
     * @param queueName - Name of the queue to be assigned
     * @param caseOwnerMap - Map<String, List<Case>> Map of queue name with List of cases to be updated
    */
    public static Map<String, List<Case>> setEscalatedCaseOwner(Case c, String queueName,Map<String, List<Case>> caseOwnerMap){
        if (caseOwnerMap != null && caseOwnerMap.keySet() != null && caseOwnerMap.containsKey(queueName)) {
            List<Case> cases = new List<Case>();
            cases = caseOwnerMap.get(queueName);
            cases.add(c);
            caseOwnerMap.put(queueName, cases);
        }
        else {
            List<Case> cases = new List<Case>();
            cases.add(c);
            caseOwnerMap.put(queueName, cases);
        }
        return caseOwnerMap;
    }
	
	 /* @description : SCC-303 - Get CRL1 and CLR2 based on Type field on business config 
     * @param c - Type from business config which must match the Type__c field on custom setting
	 */
	public static Map<String, String> getclrs1_2Mapping(String ruleType){
       Map<String, String> mapOfCRL1And2 = new Map<String, String>();
        if(!recoveryCRLs.isEmpty()){
            for(Service_Recovery_Escalation__c rec: recoveryCRLs){
                if(rec.Type__c == ruleType ){
					mapOfCRL1And2.put(rec.CLR3__c+'::'+rec.CLR2__c,rec.CLR2__c);
				}
			}
        }
        return mapOfCRL1And2 ;
    }
	
	/* @description : SCC-303 - Validate that CRLs on Case are available in custom type for a given Type in business config
     * @param c - Case, IsThroughCustomSetting in business config, map of CRLs 1 and 2 for a Type
	 */
	
	public static Boolean checkIfCaseReasonsValidationIsThroughCustomSetting(Case pCase, 
                                            Boolean pIsThroughCustomSetting, Map<String,String> pMapOfCRL1AndCRL2){
        String concatenatedCRL2and3 = pCase.Case_Reason_Level_3__c+'::'+pCase.Case_Reason_Level_2__c ;        
		Boolean hasCaseReasonLevel2And3ForApacRecovery = pIsThroughCustomSetting && !pMapOfCRL1AndCRL2.isEmpty()
        && pMapOfCRL1AndCRL2.containsKey(concatenatedCRL2and3)
        && pMapOfCRL1AndCRL2.get(concatenatedCRL2and3) == pCase.Case_Reason_Level_2__c;
        
        return hasCaseReasonLevel2And3ForApacRecovery;
    }
	
	/* @description - SCC-303 - Map of language code/country code and queue suffix based on mapping of business config
     * @param c - Case, IsThroughCustomSetting in business config, map of CRLs 1 and 2 for a Type
	 */
	
	public static Map<String,String> getLanguageOrCountryQueueSuffixMap(Set<String> pLangOrCountryCodes){
        Map<String, String> mapOfCountryOrLangQueueSuffix = new Map<String, String>();
        if(!pLangOrCountryCodes.isEmpty()){
            for(String s: pLangOrCountryCodes){
                mapOfCountryOrLangQueueSuffix.put(s.substringBefore(':'),s.substringAfter(':'));
            }
        }
        return mapOfCountryOrLangQueueSuffix;
    }
	
	/* @description - SCC-303 Fetch Queue Name based on language code if the queue name is dynamic in the Business Config
     * @param pCaseOwnerMap - Queue name and Case
     * @param pLanguageQueueCodeName - complete list of language code and queue suffix in a : separate string set
    */
    public static Map<String, List<Case>> getEscalationQueueNameOnLanguage(Map<String, List<Case>> pCaseOwnerMap, Set<String> pLanguageQueueCodeName){
        Map<String, String> mapOfLangorCountryCode = new Map<String,String>();
        mapOfLangorCountryCode = getLanguageOrCountryQueueSuffixMap(pLanguageQueueCodeName);
        for (String queueName : pCaseOwnerMap.keySet()) {
            for (Case newCase : pCaseOwnerMap.get(queueName)) {
                String queueNameString = '';
                if(queueName.contains('<Language_Code>') && !String.isempty(newCase.Language_Code__c) 
                    && newCase.Language_Code__c.contains('-') && !mapOfLangorCountryCode.isEmpty()
                    && mapOfLangorCountryCode.containsKey(newCase.Language_Code__c)){
                         queueNameString =  queueName.replace('<Language_Code>',mapOfLangorCountryCode.get(newCase.Language_Code__c));
                    } 
                if(queueNameString!=''){
                    pCaseOwnerMap =  setEscalatedCaseOwner(newCase,queueNameString,pCaseOwnerMap);
                }
            }
        }
        return pCaseOwnerMap;
    }
	
	/* @description Logic for skiiping current case escalation based on certain criteria other than
     *              case reasons. For e.g. case reasons matches recovery escalation but is a refund scenario
     *              as partial amount is entered and case is escalated
     * @param - pCase = Case record, escalation logic map     
     */
    public static Boolean checkIfNeedToExcludeCurrEsc(Case pCase, Map<String, String> escalationLogicMap){
        //Validation done in multiple steps based on priority of attributes validation
        Boolean validateSkipEsc = false;
        validateSkipEsc = pCase == null || escalationLogicMap == null?false:true;
        if(!validateSkipEsc) {return false;}
        validateSkipEsc = (!escalationLogicMap.containsKey(excludeEscRuleKey) 
        ||(escalationLogicMap.containsKey(excludeEscRuleKey) && 
        !Boolean.valueOf(escalationLogicMap.get(excludeEscRuleKey))))?false:true;
        if(!validateSkipEsc) {return false;}
        validateSkipEsc = (!escalationLogicMap.containsKey(excludeEscRuleCriteriaKey) ||
        (escalationLogicMap.containsKey(excludeEscRuleCriteriaKey) && 
        String.isEmpty(escalationLogicMap.get(excludeEscRuleCriteriaKey))))?false:true;
        if(!validateSkipEsc) {return false;}
        validateSkipEsc = DH_InboundCaseProcessorHelper.validateSkipEsc(pCase, escalationLogicMap);
        return validateSkipEsc;
	}
	/* @description Set Owner Id of the case created by Elastix
     *
     * @param newCases - Trigger.new
    */
    public static void setElastixCaseOwner(List<Case> newCaseList){
        Map<String,List<Case>> agentIdCasesMap = new Map<String,List<Case>>();
        String agentIds = '';
        for(Case c:newCaseList){
            if(c.Elastix_Agent_Extension__c==null) {
                continue;
            }
            List<Case> caseList = new List<Case>();
            if(agentIdCasesMap.containsKey(c.Elastix_Agent_Extension__c)){
                caseList = agentIdCasesMap.get(c.Elastix_Agent_Extension__c);
                caseList.add(c);
                agentIdCasesMap.put(c.Elastix_Agent_Extension__c,caseList);
            }
            else{
                agentIdCasesMap.put(c.Elastix_Agent_Extension__c,new List<Case>{c});
            }
            agentIds = agentIds+'\''+c.Elastix_Agent_Extension__c+'\',';
        }
        if(agentIds.length()==0){
            return;
        }
        agentIds=agentIds.substring(0,agentIds.length()-1);
        String fields = 'Id,Elastix_Agent_Id__c';
        String whereClause  = 'Elastix_Agent_Id__c IN ('+agentIds+')';
        Map<Id,User> usrMap =  UserSelector.getUsersWithDynamicCondition(fields,whereClause);
        if(usrMap==null){
            return;
        }
        for(User u:usrMap.values()){
            for(Case c:agentIdCasesMap.get(u.Elastix_Agent_Id__c)){
                c.OwnerId = u.Id;
                c.Status = 'In Progress';
            }
        }
    }	
    /**
     * SCC-41 && SCC-101: Move Global Case Setups PB to Trigger.
     * @description case setups : before update and insert.
     *
     * @param Trigger.new
     * @param Trigger.oldMap()
     * */

    public static void caseSetups(List<Case> newCaseList, Map<Id,Case> oldCases){
        if(!moam.containsKey('CaseSetups_New')){
            return ;
        }
        List<Case> casesToProcess = new List<Case>();
        if(Trigger.isInsert){
            RecordType__c pyRecordType = RecordType__c.getValues('PY_Inbound_Case');
            RecordType__c talabatRecordType = RecordType__c.getValues('Talabat_Inbound_Case');
            RecordType__c fpRecordType = RecordType__c.getValues('FP_Inbound_Case');
            for(Case caseRecord: newCaseList) {
                Boolean checkRecordType = (caseRecord.RecordTypeId == pyRecordType.Value__c || caseRecord.RecordTypeId == talabatRecordType.Value__c ||caseRecord.RecordTypeId == fpRecordType.Value__c);
                if (Trigger.isInsert && checkRecordType) {
                    casesToProcess.add(caseRecord);
                }
            }
        }
        if(Trigger.isUpdate){
            casesToProcess.addAll(newCaseList);
        }
        Map<String,List<Case>> casesToUpdateWithLogicMap = caseCriteriaCheck2(casesToProcess,oldCases);
        if(casesToUpdateWithLogicMap.keySet()==null || casesToUpdateWithLogicMap.keySet().size()==0){
            return;
        }
        updateCases(casesToUpdateWithLogicMap,oldCases);
    }


    /**  SCC-41 && SCC-101: Helper method called from caseSetups method
    /**
     * @description : to check the case entry criteria from business configs
     *
     * @param : List of new Cases & Map of oldCases
     *
     */

    public static Map<String,List<Case>> caseCriteriaCheck2(List<Case> newCaseList, Map<Id,Case> oldCases){
        Map<String,Map<String, Business_Config__c>> mapBusinessLogic = moam.get('CaseSetups_New');
        Map <String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get('Global_Config');
        Map<String,Map<String,Map<String,String>>> MapOfFieldValueMap =  new Map<String,Map<String,Map<String,String>>>();
        for(String ruleName: mapBusinessRules.keySet()){
            Map<String,Map<String, String>> fieldValueMap = (Map<String,Map<String, String>>) JSON.deserialize(mapBusinessRules.get(ruleName).Business_Rule_Value__c, Map<String,Map<String, String>>.class);
            MapOfFieldValueMap.put(ruleName,fieldValueMap);
        }
        Map<String,List<Case>> casesToUpdateWithLogicMap = new Map<String,List<Case>>();
        for(Case newCase:newCaseList){
            String recordTypeName = RecordType__c.getValues(newCase.RecordTypeId).Value__c;
            if(!MapOfFieldValueMap.containsKey(recordTypeName)){
                continue;
            }
            Map<String,Map<String,String>> ruleMap = MapOfFieldValueMap.get(recordTypeName);
            for(Map<String,String> rules:ruleMap.values()){
                if(!rules.containsKey('Criteria')){
                    continue;
                }
                List<String> criteriaList = new List<String>();
                if(rules.get('Criteria')!='') {
                    criteriaList = rules.get('Criteria').split('&&');
                }
                Integer conditionsMet=0;
                for(String criteria:criteriaList){
                    String fieldValue = rules.get(criteria);
                    String caseFieldValue = String.valueOf(newCase.get(criteria));
                    if(fieldValue.contains('ISNEW')||fieldValue.contains('ISBLANK')||fieldValue.contains('ISNOTBLANK')||fieldValue.contains('ISCHANGED')||fieldValue.contains('ISNOTEQUALS')){
                        conditionsMet=checkConditions(fieldValue,conditionsMet,caseFieldValue,oldCases,criteria,newCase);
                    }
                    else if(criteria == 'EmailToAddress__c' && newCase.EmailToAddress__c != null ) {
                        List<String> emails = fieldValue.split(',');
                        for(String email: emails){
                            if(newCase.EmailToAddress__c.contains(email)){
                                conditionsMet++;
                            }
                        }
                    }
                    else if(caseFieldValue!=null && fieldValue.contains(caseFieldValue)){
                        conditionsMet++;
                    }
                }
                if(conditionsMet==criteriaList.size()){
                    String entity = rules.get('Entity');
                    if (casesToUpdateWithLogicMap != null && casesToUpdateWithLogicMap.keySet() != null && casesToUpdateWithLogicMap.containsKey(entity)) {
                        List<Case> cases = new List<Case>();
                        cases = casesToUpdateWithLogicMap.get(entity);
                        cases.add(newCase);
                        casesToUpdateWithLogicMap.put(entity, cases);
                    }

                    else {
                        List<Case> cases = new List<Case>();
                        cases.add(newCase);
                        casesToUpdateWithLogicMap.put(entity, cases);
                    }
                    break;
                }
            }
        }
        return casesToUpdateWithLogicMap;
    }

    /**  SCC-41 && SCC-101: Helper method called from caseSetups method
    /**
     * @description : to evaluate special string criteria from business configs and Custom MetaData
     *
     * @param : Param String,integer count,Case value string,map of oldcases, criteria string, case record
     *
     */

    public static Integer checkConditions(String fieldValue, Integer conditionsMet, String caseFieldValue, Map<Id,Case> oldCases, String criteria, Case newCase) {
        switch on fieldValue {
            when 'ISNEW' {
                if (Trigger.isInsert) {
                    conditionsMet++;
                }
            }
            when 'ISBLANK' {
                if (caseFieldValue == '' || caseFieldValue == null) {
                    conditionsMet++;
                }
            }
            when 'ISNOTBLANK' {
                if (caseFieldValue != '' && caseFieldValue!=null) {
                    conditionsMet++;
                }
            }
            when 'ISCHANGED' {
                if (!oldCases.isEmpty() && (oldCases.get(newCase.Id).get(criteria) != caseFieldValue)) {
                    conditionsMet++;
                }
            }
            when else{
                if(fieldValue.contains('ISNOTEQUALS')) {
                    String[] values = fieldValue.subStringBetween('(',')').split(',');
                    integer valuesChecked = 0;
                    for(String checkValue:values){
                        if(caseFieldValue!=checkValue){
                            valuesChecked++;
                        }
                    }if(values.size()==valuesChecked){
                        conditionsMet++;
                    }
                }
            }
        }
        return conditionsMet;
    }

    /**  SCC-41 && SCC-101: Helper method called from caseSetups main method.
    /**
     * @description : To process the metadata criteria and update Case records in before scenarios
     *
     * @param : Map of String:MetaDataLabel, List of Cases
     *
     */

    public static void updateCases(Map<String,List<Case>> casesToUpdateWithLogicMap,Map<Id,Case> oldCases){
        List<Global_Case_Setup__mdt> globalCS = new List<Global_Case_Setup__mdt>();
        globalCS = [SELECT MasterLabel,Value_Assignment__c FROM Global_Case_Setup__mdt where MasterLabel IN:casesToUpdateWithLogicMap.keySet()];
        for(Global_Case_Setup__mdt meta:globalCS){
            Map<String,String>  mData = (Map<String,String>)JSON.deserialize((meta.Value_Assignment__c), Map<String, String>.class);
            Map<String,List<Case>> ownerIdMap = new Map<String,List<Case>>();
            for(Case c:casesToUpdateWithLogicMap.get(meta.MasterLabel)) {
                List<String> fieldsSet = new List<String>();
                for(String fApi:mData.keySet()){
                    if(fApi.contains('AND')){
                        continue;
                    }
                    String key = fApi.substringAfter(':=');
                    if(fieldsSet.contains(key)) {
                        continue;
                    }
                    String mDataValue=mData.get(fApi);
                    if(mDataValue.contains(',') || mDataValue.contains('==') || mDataValue.contains('&&') ||mDataValue.contains('!=') ){
                        Map<String,String> kValueMap = splitKeyValue(mDataValue.substringBefore(','));
                        String finalValue = mData.get(fApi).substringAfter(',');
                        Boolean keycheck = false;
                        if(kValueMap.isEmpty()){
                            continue;
                        }
                        Integer conditionsMet=0;
                        Integer fieldFilterSize = kValueMap.keySet().size();
                        Boolean isUser = c.get('OwnerId').toString().startsWith('005')?true:false;
                        for(String check : kValueMap.keySet()) {
                            keycheck = false;
                            object caseValue = c.get(check);
                            if((caseValue == '' || caseValue == null) && (kValueMap.get(check)=='' || kValueMap.get(check)==null)){
                                keycheck = true;
                                conditionsMet++;
                            }
                            else{
                                Boolean checkFieldString = (caseValue!=null &&(kValueMap.get(check).containsIgnoreCase(caseValue.toString())||caseValue.toString().containsIgnoreCase(kValueMap.get(check))));
                                switch on check {
                                    when 'EmailToAddress__c'{
                                        List<String> emailadresses = new List<String>();
                                        String metaDataString = kValueMap.get(check);
                                        Boolean checkEmail = false;
                                        if(caseValue!=null){
                                            emailadresses = caseValue.toString().deleteWhiteSpace().split(';');}
                                        if(emailadresses.size()>0){
                                            checkEmail = checkEmailAddresses(emailadresses,metaDataString);
                                        }
                                        if(checkEmail || (caseValue!=null && kValueMap.get(check).contains('ISNOTBLANK'))){
                                            keycheck = true;
                                            conditionsMet++;
                                        }
                                    }
                                    when 'Subject'{
                                        if(checkFieldString){
                                            keycheck = true;
                                            conditionsMet++;
                                        }
                                    }
                                    when 'OwnerId'{
                                        if(isUser && finalValue=='User'){
                                            keycheck = true;
                                            conditionsMet++;
                                        }
                                    }
                                    when else {
                                        if (kValueMap.get(check) == 'ISBLANK' && caseValue==null){
                                            conditionsMet++;
                                        }
                                        else if (kValueMap.get(check).contains('ISNOTEQUALS') || kValueMap.get(check) == 'ISCHANGED' || kValueMap.get(check) == 'ISNEW'){
                                            String caseFieldValue = '';
                                            if(caseValue!=null) {
                                                caseFieldValue = caseValue.toString();
                                            }
                                            conditionsMet = checkConditions(kValueMap.get(check),conditionsMet,caseFieldValue,oldCases,check,c);
                                        }
                                        else if(caseValue != null && caseValue == kValueMap.get(check)){
                                            keycheck = true;
                                            conditionsMet++;
                                        }
                                    }
                                }
                            }
                        }
                        if(conditionsMet == fieldFilterSize){
                            Boolean updateOwnerToUser = finalValue.contains('User')?true:false;
                            if(key=='OwnerId' && !updateOwnerToUser){
                                if (ownerIdMap != null && ownerIdMap.keySet() != null && ownerIdMap.containsKey(finalValue)) {
                                    List<Case> cases = new List<Case>();
                                    cases = ownerIdMap.get(finalValue);
                                    cases.add(c);
                                    ownerIdMap.put(finalValue,cases);
                                }
                                else {
                                    List<Case> cases = new List<Case>();
                                    cases.add(c);
                                    ownerIdMap.put(finalValue,cases);
                                }
                            }else if(key=='OwnerId' && updateOwnerToUser){
                                c.put('OwnerId',c.OwnerId);
                                fieldsSet.add(key);
                            }
                            else{
                                c.put(key,finalValue);
                                fieldsSet.add(key);
                            }
                        }
                    }else{
                        if(mData.get(fApi).contains('Case.')){
                            String mDatasplitValue = mData.get(fApi).substringAfter('.');
                            c.put(key,c.get(mDatasplitValue));
                            fieldsSet.add(key);
                        }else if(key == 'OwnerId'){
                            if (ownerIdMap != null && ownerIdMap.keySet() != null && ownerIdMap.containsKey(mData.get(fApi))) {
                                List<Case> cases = new List<Case>();
                                cases = ownerIdMap.get(mData.get(fApi));
                                cases.add(c);
                                ownerIdMap.put(mData.get(fApi),cases);
                            }
                            else {
                                List<Case> cases = new List<Case>();
                                cases.add(c);
                                ownerIdMap.put(mData.get(fApi),cases);
                            }
                        }
                        else {
                            c.put(key,mData.get(fApi));
                            fieldsSet.add(key);
                        }
                    }
                }
            }
            setOwnerIdLogic(ownerIdMap);
        }
    }


    /**  SCC-472-bugFix: Helper method  from updateCases method
    /**
     * @description : to evaluate emailaddresses on Case : Email_To_Addresss__c field
     *
     */
    public static boolean checkEmailAddresses(List<String> emailAdresses,String metaDataString){
       for(String email : emailAdresses) {
            if (metaDataString.containsIgnoreCase(email)){
                return true;
            }
        }
        return false;
    }

    /**  SCC-41 && SCC-101: Helper method called from caseSetups method
    /**
     * @description : to split the strings
     *
     * @param : Map of Case: fieldApi-value to check
     *
     */

    public static Map<String,String> splitKeyValue(String splitValue){
        String key ='';
        String value = '';
        String[] checkFieldMap ;
        Map<String,String> keyValueMap = new Map<String,String>();
        if(splitValue.contains('&&')){
            checkFieldMap = splitValue.split('&&');
            for(String check : checkFieldMap){
                if(check.contains('==')){
                    key = check.substringBefore('==');
                    value = check.substringAfter('==');
                    keyValueMap.put(key,value);
                }else if(check.contains('!=')){
                    key = check.substringBefore('!=');
                    value = 'ISNOTEQUALS('+check.substringAfter('!=')+')';
                    keyValueMap.put(key,value);
                }
            }
        }else if(splitValue.contains('==')){
            keyValueMap.put(splitValue.substringBefore('=='),splitValue.substringAfter('=='));
        }
        return keyValueMap;
    }

    /**  SCC-41 && SCC-101: Helper method called from updateCases method
    /**
     * @description : to set the ownerIds to the CaseList
     *
     * @param : Map of Queue DeveloperNames,List of Cases
     *
     */

    public static void setOwnerIdLogic(Map<String,List<Case>> ownerIdMap){
        List<Group> grpList = new List<Group>();
        if(!ownerIdMap.isEmpty()){
            grpList = [SELECT DeveloperName,Id,Name,Type FROM Group where Type = 'Queue' AND DeveloperName IN: ownerIdMap.keySet()];
        }
        for(Group queueId: grpList){
            for(Case setCaseOwner:ownerIdMap.get(queueId.DeveloperName)){
                setCaseOwner.put('OwnerId',queueId.Id);
            }
        }
    }
  
    /**@Author:Nithin Pandhem
     *  @description Back to queue logic for inbound and refund cases.
     * @Jira:SCC-70
     * @param newCaseList - List<Case> Lidt of cases in the trigger context
     * @param oldMap - Map<Id, Case> oldMap of Id and Case
    */

    public static void backToQueueLogic(List<Case> newCaseList,Map<Id,Case> oldMap){
        if(!moam.containsKey('backToQueueLogic')){
            return ;
        }
        Map<String,Map<String, Business_Config__c>> mapBusinessLogic = moam.get('backToQueueLogic');
        Map <String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get('Global_Config');
        String[] statusValues;
        String[] teamLeadQueues;
        Map<String,String> countryNameIsoCodeMap = new Map<String,String>();

        if(mapBusinessRules.containsKey('Status')){
            statusValues = mapBusinessRules.get('Status').Business_Rule_Value__c.split(',');
        }
        if(mapBusinessRules.containsKey('TeamLeadQueues')){
            teamLeadQueues = mapBusinessRules.get('TeamLeadQueues').Business_Rule_Value__c.split(',');
        }

        Map<Id,String> teamLeadQueueMap = new Map<Id,String>();
        List<Group> teamleadGroups = GroupSelector.getQueuesByDeveloperName(teamLeadQueues);
        for(Group grp: teamleadGroups){
            teamLeadQueueMap.put(grp.Id,grp.DeveloperName);
        }

        Map<String,List<Case>> QueueIdCasesMap = new Map<String,List<Case>>();
        Map<String,List<Case>> MapQueueIdCaseList = new Map<String,List<Case>>();
        Map<String, List<Case>> CaseCountryMap = new Map<String, List<Case>>();


        Map<String,Map<String, Map<String, String>>> mapfieldValueMap = new  Map<String,Map<String, Map<String, String>>>();
        for(Case b2QCase : newCaseList ) {
            String recordTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(b2QCase.RecordTypeId).getDeveloperName();
            Boolean checkRecordType = (recordTypeName.contains('_Inbound_Case') || recordTypeName.contains('_CS_Refunds_Case'));
            if (b2QCase.Platform__c == null || !checkRecordType) {
                continue ;
            }
            if (!mapBusinessRules.containsKey(b2QCase.Platform__c)) {
                continue;
            }
            Map<String, Map<String, String>> fieldValueMap = (Map<String, Map<String, String>>) JSON.deserialize(mapBusinessRules.get(b2QCase.Platform__c).Business_Rule_Value__c, Map<String, Map<String, String>>.class);
            if (fieldValueMap.isEmpty()) {
                return;
            }
            mapfieldValueMap.put(b2QCase.Platform__c,fieldValueMap);
            Map<String, String> keyValueMap = new Map<String, String>();
            if (b2QCase.Type != null) {
                keyValueMap = fieldValueMap.get(b2QCase.Type);
            }

            Boolean isNotTeamLeadQueue = (b2QCase.Queue_ID__c == null || !teamLeadQueueMap.containsKey(b2QCase.Queue_ID__c));
            if (keyValueMap!=null && b2QCase.Country__c!=null && isNotTeamLeadQueue && keyValueMap.containsKey('<CountryCode>')) {
                CaseCountryMap = setEscalatedCaseOwner(b2QCase, b2QCase.Country__c, QueueIdCasesMap);
            }

            else{
                MapQueueIdCaseList = setBackToQueueId(isNotTeamLeadQueue, b2QCase, QueueIdCasesMap, keyValueMap,countryNameIsoCodeMap); //method call to set queue Ids
            }
            //setting  owner Id from Queue_ID__C  if Trigger.Isupdate ==true and status changed to 'New Answer' or 'Re-Open'
            if(Trigger.isUpdate && (statusValues.contains(b2QCase.Status))  && b2QCase.Status!=oldMap.get(b2QCase.Id).Status && b2QCase.Queue_ID__c!=null){
                b2QCase.OwnerId = b2QCase.Queue_ID__c;
            }
        }

        List<Case> caseList = new List<Case>();
        List<Country__c> countries = CountrySelector.getCountryList(CaseCountryMap.keySet());
        for (Country__c country : countries) {
            countryNameIsoCodeMap.put(country.name, country.Iso__c);
            caseList.addAll(CaseCountryMap.get(country.name));
        }

        Map<String,List<Case>>  finalQueueCaseMap = new Map<String,List<Case>>();
                for(Case setCase : caseList){
            Map<String, String> keyMap =  mapfieldValueMap.get(setCase.Platform__c).get(setCase.Type);
                    finalQueueCaseMap = setBackToQueueId(true, setCase, QueueIdCasesMap, keyMap, countryNameIsoCodeMap);
        }
        finalQueueCaseMap.putAll(MapQueueIdCaseList);

        List<Group> grpList = new List<Group>();
        List<String> queueNameList = new List<String>();

        if(!finalQueueCaseMap.isEmpty()){
            queueNameList.addAll(finalQueueCaseMap.keySet());
            grpList = GroupSelector.getQueuesByDeveloperName(queueNameList);
        }


        for(Group queue: grpList){   //Setting QueueIds
            if(finalQueueCaseMap.containsKey(queue.DeveloperName)) {
                for(Case setCaseQueue : finalQueueCaseMap.get(queue.DeveloperName)) {
                    setCaseQueue.put('Queue_ID__c', queue.Id);
                }
            }
        }
    }

    public static Map<String,List<Case>> setBackToQueueId(Boolean isNotTeamLeadQueue,Case b2QCase,Map<String,List<Case>> QueueIdCasesMap,Map<String,String> keyValueMap,Map<String,String> countryNameIsoCodeMap){ //SCC-70

        Map<String,List<Case>> QueueIdCaseMap = QueueIdCasesMap;
        String owner = b2QCase.OwnerId;

        if(owner.startsWith('005') && isNotTeamLeadQueue &&  b2QCase.Queue_ID__c == null){
            if(b2QCase.Country__c!=null && keyValueMap.containsKey('<CountryCode>')) {
                String countryKey = countryNameIsoCodeMap.get(b2QCase.Country__c);
                String queueName  = keyValueMap.get('<CountryCode>');
                String queueNameString = queueName.replace('<CountryCode>',countryKey);
                Map<String,List<Case>> mapQueueIdCases = setEscalatedCaseOwner(b2QCase,queueNameString,QueueIdCasesMap);
                QueueIdCaseMap.putAll(mapQueueIdCases);

            }else if(keyValueMap.containsKey('Other')){
                Map<String,List<Case>>  mapQueueIdCases = setEscalatedCaseOwner(b2QCase,keyValueMap.get('Other'),QueueIdCasesMap);
                QueueIdCaseMap.putAll(mapQueueIdCases);

            }
            else{
                Map<String,List<Case>>  mapQueueIdCases = setEscalatedCaseOwner(b2QCase,keyValueMap.get('All'),QueueIdCasesMap);
                QueueIdCaseMap.putAll(mapQueueIdCases);

            }
        }else if(owner.startsWith('00G') && (owner!=b2QCase.Queue_ID__c || b2QCase.Queue_ID__c == null)) { //Setting Queue_ID__c to the Case Owner Id, if Case Owned by Queue and Queue_ID__c!=OwnerId
            b2QCase.Queue_ID__c = owner;
        }
        return QueueIdCaseMap;
    }

    /* @description All methods for field level validations for cases
     *
     * @param newCases - Trigger.new
     * @param oldCaseMap - Trigger.oldMap()
     */
    public static void fieldValidations(List<Case> newCases, Map<Id,Case> oldCaseMap){
        List<Case> ccCases = new List<Case>();
        for(Case newCase:newCases){
            boolean isCCCase = Schema.SObjectType.Case.getRecordTypeInfosById().get(newCase.RecordTypeId).getDeveloperName().contains('_Inbound_Case') || Schema.SObjectType.Case.getRecordTypeInfosById().get(newCase.RecordTypeId).getDeveloperName().contains('_CS_Refunds');
            if(isCCCase){
                ccCases.add(newCase);
            }
        }
        if(ccCases.isEmpty()){
            return;
        }
        countryValidation(ccCases,oldCaseMap);
    }

    /* @description Country level validation on case based on Platform. This validation is dependent on Custom Metadata: Platform_Country_Mapping__mdt
     *
     * @param newCases - Trigger.new
     * @param newCases - Trigger.oldMap
     */
    public static void countryValidation(List<Case> newCases,Map<Id,Case> oldCaseMap){
        List<String> platforms = new List<String>();
        List<Case> casesToProcess = new List<Case>();
        for(Case newCase: newCases){
            if(newCase.Country__c!=null) {
                platforms.add(newCase.Platform__c);
                casesToProcess.add(newCase);
            }
        }
        Set<Id> userIds = new Set<Id>();
        userIds.add(userinfo.getUserId());
        List<User> usersInfo = UserSelector.getAllByUserId(userIds);
        Map<Id,User> userMap = new Map<Id,User>();
        for(User owner:usersInfo){
            userMap.put(owner.Id, owner);
        }
        if(userMap.isEmpty() || !userMap.containsKey(userinfo.getUserId()) || userMap.get(userinfo.getUserId()).UserRoleId==null){
            return;
        }
        Map<String,Platform_Country_Mapping__mdt> platformCountriesMap = CustomMetadataSelector.getPlatformCountryMappings(platforms);
        if(platformCountriesMap.isEmpty()){
            return;
        }
        Map<String,List<Platform_Country_Mapping__mdt>> platformRegionMap = new Map<String,List<Platform_Country_Mapping__mdt>>();
        for(Platform_Country_Mapping__mdt platformCountry:platformCountriesMap.values()){
            List<Platform_Country_Mapping__mdt> platformCountryMdt = new List<Platform_Country_Mapping__mdt>();
            if (!platformRegionMap.isEmpty() && platformRegionMap.containsKey(platformCountry.Platform__c)) {
                platformCountryMdt = platformRegionMap.get(platformCountry.Platform__c);
            }
            platformCountryMdt.add(platformCountry);
            platformRegionMap.put(platformCountry.Platform__c, platformCountryMdt);
        }
        for(Case newCase: casesToProcess){
            List<Platform_Country_Mapping__mdt> platformCountryList = platformRegionMap.get(newCase.Platform__c);
            if(platformCountryList==null || platformCountryList.isEmpty()){
                continue;
            }
            Boolean throwError=true;
            for(Platform_Country_Mapping__mdt platformCountry:platformCountryList){
                if(platformCountry.Profiles_to_skip_validation__c!=null && platformCountry.Profiles_to_skip_validation__c.contains(userMap.get(userinfo.getUserId()).Profile.Name)){
                    throwError=false;
                    continue;
                }
                Boolean isCountryPartOfSameLogic = platformCountry.Countries__c.contains(newCase.Country__c) &&
                        (oldCaseMap==null || (!oldCaseMap.isEmpty() && oldCaseMap.containsKey(newCase.Id) &&
                                (oldCaseMap.get(newCase.Id).Country__c==null ||
                                        (oldCaseMap.get(newCase.Id).Country__c!=null &&
                                                platformCountry.Countries__c.contains(oldCaseMap.get(newCase.Id).Country__c)))));
                if(!isCountryPartOfSameLogic) {
                    continue;
                }
                if(string.isBlank(platformCountry.User_Role_Prefix__c) || newCase.OwnerId==null || string.valueOf(newCase.OwnerId).startsWith('00G')){
                    throwError = false;
                    break;
                }
                for(String usersrole:platformCountry.User_Role_Prefix__c.split(',')){
                    if(userMap.get(userinfo.getUserId()).UserRole.DeveloperName.startsWith(usersrole)) {
                        throwError = false;
                        break;
                    }
                }
                if(!throwError){
                    break;
                }
            }
            if(throwError) {
                newCase.addError(Label.Case_Platform_Country_Error);
            }
        }
    }
}