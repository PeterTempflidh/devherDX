public inherited sharing class LiveChatTranscriptTriggerHandler implements ITrigger {
    @TestVisible
    private Map<LiveChatTranscript, Case> chatCaseMap;
    @TestVisible
    private Map<LiveChatTranscript, Case> newChatCaseMap;
    @TestVisible
    private List<Case> oldChatCases;

    public LiveChatTranscriptTriggerHandler() {
        if(chatCaseMap == null)
            chatCaseMap = new Map<LiveChatTranscript, Case>();
        if(newChatCaseMap == null)
            newChatCaseMap = new Map<LiveChatTranscript, Case>();
        if(oldChatCases == null)
            oldChatCases = new List<Case>();
    }
    
    /**
    * bulkBefore
    *
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkBefore() {
        List<LiveChatTranscript> chats = (List<LiveChatTranscript>)Trigger.New;
        Set<Id> caseIds = new Set<Id>();
        Set<Id> chatIds = new Set<Id>();
        for(LiveChatTranscript ch : chats) {
            chatIds.add(ch.Id);
            if(ch.CaseId != null) {
                caseIds.add(ch.CaseId);
            }
        }
        Map<Id, Case> casesMap = CaseSelector.getCasesByIds(caseIds);
        for(LiveChatTranscript chat : chats) {
            chatCaseMap.put(chat, casesMap.get(chat.CaseId));
        }
    }

    /**
    * bulkAfter
    *
    * This method is called prior to execution of an AFTER trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkAfter() {
        List<LiveChatTranscript> chats = (List<LiveChatTranscript>)Trigger.new;
        Set<Id> caseIds = new Set<Id>();
        Set<Id> chatIds = new Set<Id>();
        for(LiveChatTranscript ch : chats) {
            chatIds.add(ch.Id);
            if(ch.CaseId != null) {
                caseIds.add(ch.CaseId);
            }
        }
        Map<Id, Case> casesMap = CaseSelector.getCasesByIds(caseIds);
        for(LiveChatTranscript chat : chats) {
            chatCaseMap.put(chat, casesMap.get(chat.CaseId));
        }
    }

    /**
    * beforeInsert
    *
    * This method is called iteratively for each record to be inserted during a BEFORE
    * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
    */
    public void beforeInsert(SObject so) {}

    /**
    * beforeUpdate
    *
    * This method is called iteratively for each record to be updated during a BEFORE
    * trigger.
    */
    public void beforeUpdate(SObject oldSo, SObject so) {
        LiveChatTranscript oldVal=(LiveChatTranscript)oldSo;
        LiveChatTranscript newVal=(LiveChatTranscript)so;
        Case newChatCase = null;
        if(newVal.Status!='Missed') {
            newChatCase = LiveChatTranscriptProcessor.CreateCaseFromChat(newVal);
        }
        if(newChatCase != null) {
            newChatCaseMap.put(newVal, newChatCase);
        }
        if(oldVal.Status!=newVal.Status && newVal.Status=='InProgress') {
            Case oldChatCase = LiveChatTranscriptProcessor.UpdateCaseOwner(newVal, chatCaseMap.get((LiveChatTranscript) so));
            if(oldChatCase != null) {
                oldChatCases.add(oldChatCase);
            }
        }
    }

    /**
    * beforeDelete
    *
    * This method is called iteratively for each record to be deleted during a BEFORE
    * trigger.
    */
    public void beforeDelete(SObject so) {}

    /**
    * afterInsert
    *
    * This method is called iteratively for each record inserted during an AFTER
    * trigger. Always put field validation in the 'After' methods in case another trigger
    * has modified any values. The record is 'read only' by this point.
    */
    public void afterInsert(SObject so) {}

    /**
    * afterUpdate
    *
    * This method is called iteratively for each record updated during an AFTER
    * trigger.
    */
    public void afterUpdate(SObject oldSo, SObject so) {
        LiveChatTranscript chat = (LiveChatTranscript)so;
        if(chat.CaseId!=null) {
            Case caseRec=chatCaseMap.get(chat);
            if(chat.status=='MISSED' || (chat.status=='COMPLETED' && chat.VisitorMessageCount==0)) {
                caseRec.status = 'Closed';
                caseRec.Override_Validations__c = true;
                caseRec.Override_Validation_Reason__c = 'Missed/Spam Chat';
                oldChatCases.add(caseRec);
            }
        }
    }

    /**
    * afterDelete
    *
    * This method is called iteratively for each record deleted during an AFTER
    * trigger.
    */
    public void afterDelete(SObject so) {}

    /**
    * andFinally
    *
    * This method is called once all records have been processed by the trigger. Use this
    * method to accomplish any final operations such as creation or updates of other records.
    */
    public void andFinally() {
        if(!newChatCaseMap.isEmpty()) {
            // insert new cases
            try {
                insert newChatCaseMap.values();
            } catch (Exception ex) {
                System.debug(ex);
            }
            
            // populate chat lookup to case
            for(LiveChatTranscript chat : newChatCaseMap.keySet()) {
                chat.CaseId = newChatCaseMap.get(chat).Id;
            }
        }
        
        if(!oldChatCases.isEmpty()) {
            update oldChatCases;
        }
    }
}