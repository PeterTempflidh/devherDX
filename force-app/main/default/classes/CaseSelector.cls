public inherited sharing class CaseSelector {
    public static final String CR_NOT_SUCCESSFUL = 'Not Successful';
    public static final String TYPE_ONBOARDING = 'Onboarding';

    /**
     * @description query to get all cases
     *
     * @return List<Case>
     */
    @TestVisible
    private static List<Case> getAll() {
        List<Case> cases = new List<Case>();
        try {
            cases = [ SELECT Id, Type, Status, Opportunity__c FROM Case ];
        } catch (Exception e) {
            System.debug('Case Query Exception: ' + e.getMessage());
        }
        return cases;
    }

    //updated to add aditional fields from account object SP-3791 : Global - Pandora Menu Change Process
    public static Case getCaseDetailsByIdMenuChange(Id caseId) {
        return [SELECT Id, Type, Order_Number__c, Platform__c, Case_Reason_Level_1__c, Case_Reason_Level_2__c, Case_Reason_Level_3__c,
                    RecordType.DeveloperName, RecordType.Name, RecordTypeId, 
                    queue_id__c, OwnerId, Owner.Name, Status, IsClosed, Case_Reason__c,
                    Account.Key_VIP_Account__c, Country__c, Account.Vertical__c, Menu_Typing_Errors__c,
                    Account.Mark_up_Value__c, Account.Mark_up__c, Account.Vendor_Grade__c,
                    Mark_up_Value__c, Mark_up__c,Menu_Upd_Mjr_Check__c
                FROM Case
                WHERE Id =: caseId];
    }
  
    //updated to add aditional fields from account object SP-3791
    public static Case getCaseDetailsById(Id caseId) {
       try {
           return [
                   SELECT
                           Account.Key_VIP_Account__c,Case_Reason_Level_1__c,Case_Reason_Level_2__c,Case_Reason_Level_3__c,Closed_Reason__c,Country__c,
                           Delivery_Area_Type_Date__c,Final_Check_Date__c,IsClosed,Menu_Typed_Date__c,Order_Number__c,Owner.Name,OwnerId,
                           Person_in_charge_BE__c,Person_in_Charge_Final_Check__c,Person_In_Charge_First_Check__c,Person_in_charge_Menu_Typing__c,
                           Person_In_Charge_Take_Online__c,Platform__c,Queue_ID__c,RecordType.DeveloperName,RecordType.Name,RecordTypeId,Root_Cause__c,
                           Status,Take_Online_Date__c,Type, Opportunity__c, Opportunity__r.OwnerId,Id,Case_Reason__c,Account.Vertical__c,
                           Menu_Typing_Errors__c,Account.Mark_up_Value__c,Account.Mark_up__c,Account.Vendor_Grade__c,Mark_up_Value__c, Mark_up__c,
                           Menu_Upd_Mjr_Check__c,Google_Drive_photo_URL__c,Due_Date__c,Partial_Refund_Type__c,Customer_ID__c,Customer_Name__c
                   FROM Case
                   WHERE Id = :caseId
           ];
       } catch (QueryException e) {
           System.debug(e.getMessage());
       }
       return null;
   }

    public static Case getCaseWithDynamicFields(String fieldSetName,String caseId){
        String queryFields='';
        String query;
        List<Schema.FieldSetMember> fieldSetObj = Schema.getGlobalDescribe().get('Case').getDescribe().fieldSets.getMap().get(fieldSetName).getFields();
        for(Schema.FieldSetMember member:fieldSetObj){
            queryFields=member.getFieldPath()+','+queryFields;
        }
        if(queryFields.length()>0) {
            query = 'SELECT ' + queryFields.substring(0, queryFields.length() - 1) + ' FROM Case WHERE Id=\'' + caseId + '\'';
            return database.query(query);
        }
        return null;
    }

    public static Map<Id, Case> getCasesByIds(Set<Id> caseIds) {
        return new Map<Id, Case>([SELECT Id,  OwnerId, ParentId, Status, Closed_Reason__c, Case_Reason__c
                FROM Case
                WHERE Id IN :caseIds]);
    }

    //Retrieve Case Records based on dynamic SOQL
    public static Map<Id,Case> getCaseWithDynamicCondition(String whereClause, String fields){
        String query = 'SELECT ' + fields + ' FROM Case WHERE '+whereClause;
        List<Case> cases = (List<Case>)database.query(query);
        if(cases.size()>0) {
            return new Map<Id, Case>(cases);
        }
        return null;
    }

    //Retrieve CaseShare Records.
    public static List<CaseShare> getCaseSharesWithDynamicCondition(String whereClause, String fields){
        String query = 'SELECT ' + fields + ' FROM CaseShare WHERE '+whereClause;
        return (List<CaseShare>)database.query(query);
    }
     
    /** 
     * @description query to get opps with closed dish level case   
     *  
     * @return Map<Id, Boolean>     
     */ 
    public static Map<Id, Boolean> getDishCasesForOpportunities(Set<Id> oppIds) {   
        List<Case> cases = [SELECT id, Type, Closed_Reason__c, Opportunity__c   
                            FROM Case   
                            WHERE Opportunity__c IN :oppIds 
                            AND Type = 'Dish Level Photo'   
                            AND Closed_Reason__c = 'Take Online'];  
        Map<Id, Boolean> oppDishClosed = new Map<Id, Boolean>();    
        for(Case c : cases) {   
            oppDishClosed.put(c.Opportunity__c, true);  
        }   

        return oppDishClosed;   
    }   

    public static case getCasesByParentId(Id caseId) {
               return [SELECT Id,  OwnerId, ParentId, Status, Closed_Reason__c, Case_Reason__c, Menu_Upd_Mjr_Check__c FROM Case WHERE ParentId =: caseId limit 1];
    }

    /**
    * @description Select onboarding cases that were closed unsuccessful
    *
    * @param oppIds parent opportunities
    *
    * @return onboarding cases
    */
    public static List<Case> getOnboardingFailedByOppIds(Set<Id> oppIds) {
        List<Case> onboardingFailedCases = new List<Case>();
        try {
            onboardingFailedCases =  [
                    SELECT
                            Id,
                            Opportunity__c,
                            Closed_Reason__c,
                            Opportunity__r.RecordTypeId
                    FROM Case
                    WHERE Opportunity__c IN :oppIds
                    AND Closed_Reason__c = :CR_NOT_SUCCESSFUL
                    AND Type = :TYPE_ONBOARDING
                    AND Opportunity__r.StageName != 'Closed Lost'
            ];
        } catch (QueryException e) {
            System.debug(e.getStackTraceString());
        }
        return onboardingFailedCases;
    }
}
