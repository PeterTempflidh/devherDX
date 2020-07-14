global class BatchAttachOppQuoteOnOpp implements Database.Batchable<sObject> {
String rcType {get;set;}

global BatchAttachOppQuoteOnOpp (String rectype){
    rcType = rectype;
}

global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([select id,name,id_opportunity__c from Opportunity_quote__c where id_opportunity__r.stagename='Closed Won' and status__c='Accepted' and recordtype.developername=:rcType  /*and recordtype.developername Not in('Yogiyo_Opportunity_Quote','Talabat_Opportunity_Quote','DH_AU_Opportunity_Quote')*/]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Opportunity_Quote__c> oppQ = (List<Opportunity_Quote__c>)scope;
        List<Attachment> attchLst = new List<Attachment>();
        for(Opportunity_Quote__c oq:oppQ){
            
                Attachment att = new Attachment();
                PageReference pdfQuote = new PageReference('/apex/RenderQuoteAsPDF?id=' + oq.id);
                Blob myBlob ;
                if(!Test.isRunningTest()){
                    att.body = pdfQuote.getContent();
                }else
                att.body=Blob.valueof('test');  
                att.parentid=oq.id_opportunity__c;
                att.name=oq.name;
                att.ContentType='application/pdf';
                attchLst.add(att);
                        
            }
        
        insert attchLst;
    }



    global void finish(Database.BatchableContext BC) {
        
    }

}