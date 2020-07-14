public without sharing class ClsAttachmentProcessor {
    
    public static void updateLastBranding(List<Attachment> newAttachments){
        Set<Branding_Content__c> updateBranding = new Set<Branding_Content__c>();
        for(Attachment a : newAttachments){
            if(a.ParentId!=null && Schema.Branding_Content__c.SObjectType==a.ParentId.getSobjectType()){
                updateBranding.add(new Branding_Content__c(id = a.ParentId,Last_Branding__c=Date.today()));
            }
        }
        try{
            update new List<Branding_Content__c>(updateBranding);
         }catch(Exception e){
             system.debug('Exception -'+e.getmessage());
         }
    }
    
    
    public static void updateParentToCaseOnEmailAttch(List<Attachment> newAttachments){
        List<String> EmailIds = new List<string>();
        Map<String,string> AttachmentToEmail = new Map<String,string>();
        Map<string,string> EmailtoCase = new Map<string,string>();
        for(Attachment a:newAttachments){
            if(a.ParentId!=null && schema.EmailMessage.SobjectType==a.ParentId.getSobjectType()){
               EmailIds.add(a.ParentId);
               AttachmentToEmail.put(a.id,a.parentId);
            
            }
        
        }
        if(!EmailIds.isEmpty()){
            List<emailmessage> EmailList = [select id, parentid from emailmessage where id=:EmailIds];
            for(emailmessage e : EmailList){
                if(e.parentId!=null && schema.Case.SobjectType==e.ParentId.getSobjectType()){
                       EmailtoCase.put(e.id,e.parentid);   
                
                }
            
            }
            
            if(!EmailtoCase.isEmpty()){
                for(Attachment a:newAttachments){
                  if(AttachmentToEmail.containsKey(a.id) && EmailtoCase.containsKey(AttachmentToEmail.get(a.id))){
                      a.parentid= EmailtoCase.get(AttachmentToEmail.get(a.id));
                  
                  }
                
                }
            
            }
    
        }
    }
}