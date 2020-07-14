global with sharing class CtrRestaurantCare {
    
    public CtrRestaurantCare(ApexPages.StandardController stdController) {
        
        
    }

    

    @RemoteAction
    global static List<case> getCaseLst(string accID, String caseId,String developername, date createddate){
        //system.debug('getlst');
        Date createddate2= Date.valueof(createddate);
        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = moam.get('QuoteApprovalProcess');
       List<case> csLst = [select id,Status,caseNumber, createddate, Subject, Type, Closeddate,closed_reason__c, LastModifiedBy.Name from Case where accountId=:AccID and recordtype.developername=:developername and id!=:caseId  and createddate<:createddate2 order by createddate DESC ];
       //system.debug(csLst);
       return csLst;
        
        
    }

    @RemoteAction
    global static List<Task> getTaskLst(List<string> caseId){
        //List<task> taskRelatedtoCase =new List<task>();
       system.debug(caseId.size());
        List<task> taskLst =[select id,Ownerid,Owner.Name,WhatId, Activity_Subject__c,createddate,Description from Task  where  Type='Call' and whatId!=null and whatId=:caseId];
        /*for (task t:taskLst){
            if(((String)t.whatId).startsWith('500')){
                taskRelatedtoCase.add(t);
            }
        }*/
        //system.debug('**taskRelatedtoCase'+taskRelatedtoCase);
        return taskLst;
    }
   
 


    
}