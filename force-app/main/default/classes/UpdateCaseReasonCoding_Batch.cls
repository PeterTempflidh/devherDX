/**
* @Description: This batch updates the case reason level 1,2 and 3 and type based on the new reason mapping.
*/
global class UpdateCaseReasonCoding_Batch implements Database.Batchable<sObject>{
    public List<String> recordTypesList = new List<String>();
    public Integer numberOfDays;
    private Map<String, Map<String, Map<String, Business_Config__c>> > moam =
            LibBusinessConfig.motherOfAllBusinessMaps;
    private static Map<String, Business_Config__c> mapBusinessRules;
    public List<UpdateCaseReasonsCodeMapping__c> listCaseMDT;
    public Map<String,UpdateCaseReasonsCodeMapping__c > mapCaseReasonLevel1;
    public Map<String,UpdateCaseReasonsCodeMapping__c > mapCaseReasonLevel2;
    public Map<String,UpdateCaseReasonsCodeMapping__c > mapCaseReasonLevel3;
    public Map<String,UpdateCaseReasonsCodeMapping__c > mapCaseReasonOnlyLevel1;
    public Map<String,UpdateCaseReasonsCodeMapping__c > mapCaseReasonOnlyLevel2;
    public Map<String,UpdateCaseReasonsCodeMapping__c > mapCaseReasonOnlyLevel1And2;
    public String whereClause;


    public UpdateCaseReasonCoding_Batch(String whereCondition){
        whereClause=whereCondition;
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('BatchUpdateCaseResonCoding');
        if(mapBusinessLogic != null){
            mapBusinessRules 	= mapBusinessLogic.get('Global_Config');
            if(mapBusinessRules != null) {
                if(mapBusinessRules.ContainsKey('recordTypes')){
                    recordTypesList = mapBusinessRules.get('recordTypes').Business_rule_Value__c.split(',');
                }
                /*if(mapBusinessRules.ContainsKey('closedDateRange')){
                    numberOfDays = Integer.valueOf(mapBusinessRules.get('closedDateRange').Business_Rule_Value__c);
                }*/
            }
        }
        //Get all the mapping from custom setting and store once
        listCaseMDT = UpdateCaseReasonsCodeMapping__c.getall().values();
        mapCaseReasonLevel1 = new Map<String,UpdateCaseReasonsCodeMapping__c>();
        mapCaseReasonLevel2 = new Map<String,UpdateCaseReasonsCodeMapping__c>();
        mapCaseReasonLevel3 = new Map<String,UpdateCaseReasonsCodeMapping__c>();
        mapCaseReasonOnlyLevel1 = new Map<String,UpdateCaseReasonsCodeMapping__c>();
        mapCaseReasonOnlyLevel1And2 = new Map<String,UpdateCaseReasonsCodeMapping__c>();
        mapCaseReasonOnlyLevel2 = new Map<String,UpdateCaseReasonsCodeMapping__c>();

        for(UpdateCaseReasonsCodeMapping__c caseMDT : listCaseMDT) {
            if ((caseMDT.CaseReasonLevelOld1__c != null && caseMDT.CaseReasonLevelOld2__c != null && caseMDT.CaseReasonLevelOld3__c != null)) {
                mapCaseReasonLevel1.put(caseMDT.CaseReasonLevelOld1__c + caseMDT.CaseReasonLevelOld2__c + caseMDT.CaseReasonLevelOld3__c, caseMDT);
            }
            if ((caseMDT.CaseReasonLevelOld1__c != null && caseMDT.CaseReasonLevelOld2__c != null && caseMDT.CaseReasonLevelOld3__c == null)) {
                mapCaseReasonOnlyLevel1And2.put(caseMDT.CaseReasonLevelOld1__c + caseMDT.CaseReasonLevelOld2__c, caseMDT);
            }
            if ((caseMDT.CaseReasonLevelOld1__c != null && caseMDT.CaseReasonLevelOld2__c == null && caseMDT.CaseReasonLevelOld3__c == null)) {
                mapCaseReasonOnlyLevel1.put(caseMDT.CaseReasonLevelOld1__c, caseMDT);
            }
            if (caseMDT.CaseReasonLevelOld1__c == null && caseMDT.CaseReasonLevelOld2__c != null && caseMDT.CaseReasonLevelOld3__c != null) {
                mapCaseReasonLevel2.put(caseMDT.CaseReasonLevelOld2__c + caseMDT.CaseReasonLevelOld3__c, caseMDT);
            }
            if (caseMDT.CaseReasonLevelOld1__c == null && caseMDT.CaseReasonLevelOld2__c != null && caseMDT.CaseReasonLevelOld3__c == null) {
                mapCaseReasonOnlyLevel2.put(caseMDT.CaseReasonLevelOld2__c, caseMDT);
            }
            if (caseMDT.CaseReasonLevelOld1__c == null && caseMDT.CaseReasonLevelOld2__c == null && caseMDT.CaseReasonLevelOld3__c != null) {
                mapCaseReasonLevel3.put(caseMDT.CaseReasonLevelOld3__c, caseMDT);
            }
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        List<Id> recordTypeIds 	= new List<Id>();
        //DateTime closedDateValue		= Date.today().addDays(-numberOfDays);

        for(String rec : recordTypesList){
            recordTypeIds.add(LibRecordTypeHelper.getRecordTypeValue(rec));
        }
        String query='SELECT Id,Case_Reason_Level_1__c, Case_Reason_Level_2__c, Case_Reason_Level_3__c,Type, IsCaseReasonUpdated__c FROM CASE WHERE RecordTypeId IN :recordTypeIds AND IsCaseReasonUpdated__c = false AND '+whereClause;
        /*return Database.getQueryLocator([SELECT Id,Case_Reason_Level_1__c,
                                         Case_Reason_Level_2__c,
                                         Case_Reason_Level_3__c,Type,
                                         IsCaseReasonUpdated__c
                                            FROM CASE
                                            WHERE RecordTypeId IN :recordTypeIds
                                            AND IsCaseReasonUpdated__c = false
                                            AND ((IsClosed = false)
                                            OR (ClosedDate > :closedDateValue
                                            AND IsClosed = true))
                                            ]);*/
        system.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        String caseKeyString1;
        String caseKeyString2;
        String caseKeyString3;
        List<Case> casesTobeUpdated = (List<Case>)scope;

            for(Case caseRec : casesTobeUpdated){
                caseKeyString1 = '';caseKeyString2 = '';caseKeyString3 = '';
                if(caseRec.Case_Reason_Level_1__c != null){
                    caseKeyString1=caseRec.Case_Reason_Level_1__c;
                }
                if(caseRec.Case_Reason_Level_2__c != null){
                    caseKeyString2= caseRec.Case_Reason_Level_2__c;
                }
                if(caseRec.Case_Reason_Level_3__c != null){
                    caseKeyString3= caseRec.Case_Reason_Level_3__c;
                }
                if(caseRec.Type=='Customer Request' || caseRec.Type=='Other'){
                    caseRec.Type='Customer';
                }
                if(caseRec.Type=='Restaurant Request'){
                    caseRec.Type='Partner';
                }
                //New value assignment for Case Reason level 1
                if(mapCaseReasonLevel1.containsKey(caseKeyString1+caseKeyString2+caseKeyString3)){
                    if(mapCaseReasonLevel1.get(caseKeyString1+caseKeyString2+caseKeyString3).CaseReasonLevelNew1__c != null){
                        caseRec.Case_Reason_Level_1__c = mapCaseReasonLevel1.get(caseKeyString1+caseKeyString2+caseKeyString3).CaseReasonLevelNew1__c;
                        if(mapCaseReasonLevel1.get(caseKeyString1+caseKeyString2+caseKeyString3).Type__c!=null && mapCaseReasonLevel1.get(caseKeyString1+caseKeyString2+caseKeyString3).Type__c!='')
                            caseRec.Type=mapCaseReasonLevel1.get(caseKeyString1+caseKeyString2+caseKeyString3).Type__c;
                    }
                }else if(mapCaseReasonOnlyLevel1And2.containsKey(caseKeyString1+caseKeyString2)){
                    if(mapCaseReasonOnlyLevel1And2.get(caseKeyString1+caseKeyString2).CaseReasonLevelNew1__c != null){
                        caseRec.Case_Reason_Level_1__c = mapCaseReasonOnlyLevel1And2.get(caseKeyString1+caseKeyString2).CaseReasonLevelNew1__c;
                        if(mapCaseReasonOnlyLevel1And2.get(caseKeyString1+caseKeyString2).Type__c!=null && mapCaseReasonOnlyLevel1And2.get(caseKeyString1+caseKeyString2).Type__c!='')
                            caseRec.Type=mapCaseReasonOnlyLevel1And2.get(caseKeyString1+caseKeyString2).Type__c;
                    }
                }else if(mapCaseReasonOnlyLevel1.containsKey(caseKeyString1)){
                    if(mapCaseReasonOnlyLevel1.get(caseKeyString1).CaseReasonLevelNew1__c != null){
                        caseRec.Case_Reason_Level_1__c = mapCaseReasonOnlyLevel1.get(caseKeyString1).CaseReasonLevelNew1__c;
                        if(mapCaseReasonOnlyLevel1.get(caseKeyString1).Type__c!=null && mapCaseReasonOnlyLevel1.get(caseKeyString1).Type__c!='')
                            caseRec.Type=mapCaseReasonOnlyLevel1.get(caseKeyString1).Type__c;
                    }
                }
                //New value assignment for Case Reason level 2
                if(mapCaseReasonLevel2.containsKey(caseKeyString2+caseKeyString3)){
                    if(mapCaseReasonLevel2.get(caseKeyString2+caseKeyString3).CaseReasonLevelNew2__c != null){
                        caseRec.Case_Reason_Level_2__c = mapCaseReasonLevel2.get(caseKeyString2+caseKeyString3).CaseReasonLevelNew2__c;
                    }
                }else if(mapCaseReasonOnlyLevel2.containsKey(caseKeyString2)){
                    if(mapCaseReasonOnlyLevel2.get(caseKeyString2).CaseReasonLevelNew2__c != null){
                        caseRec.Case_Reason_Level_2__c = mapCaseReasonOnlyLevel2.get(caseKeyString2).CaseReasonLevelNew2__c;
                    }
                }
                //New value assignment for Case Reason level 3
                if(mapCaseReasonLevel3.containsKey(caseKeyString3)){
                    if(mapCaseReasonLevel3.get(caseKeyString3).CaseReasonLevelNew3__c != null){
                    caseRec.Case_Reason_Level_3__c = mapCaseReasonLevel3.get(caseKeyString3).CaseReasonLevelNew3__c;
                    }
                }
                caseRec.IsCaseReasonUpdated__c = true;
            }

        // In case of failure perform partial update
        List<Database.saveResult> results = Database.update(casesTobeUpdated,false);
        LoggingUtility.createLog('UpdateCaseReasonCoding_Batch','BATCH','CASE Reason Update Error',null);
        Boolean isError = false;
        for(Integer i=0;i<results.size();i++){
            if(!results[i].isSuccess()){
                LoggingUtility.logError('UpdateCaseReasonCoding_Batch','UpdateCaseReasonCoding_Batch: Update failed for case ' + casesTobeUpdated[i].Id +
                        ' Errors '  + results[i].getErrors() + '\n');
                isError = true;
            }
        }
        // Do Logging in case of error.
        if(isError){
            LoggingUtility.commitLogs();
        }
    }

    global void finish(Database.BatchableContext BC) {

    }

}