global class BatchUpdContactRole implements Database.Batchable<sObject> {
  
  
  
    global BatchUpdContactRole() {
    
    }
  
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT name,id,(SELECT id FROM Contacts) FROM Account where recordtype.developername='UK_Account']);
    }
  
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<account> acclst = (List<Account>)scope;
        List<account> validAccLst=new List<Account>();
        for(account a:accLst){
            if(a.Contacts!=null && !a.Contacts.isEmpty() && a.contacts.size()==1){
                validAccLst.add(a);
            }
        }
        system.debug(validAccLst.size());
        //List<contact> contactlist = [select id,Contact_Role__c,accountid from contact where  Contact_Role__c=null and recordtype.developername='UK_Contact' and account];
        List<contact> conToBeUpdated = new List<contact>();
        for(Contact c:[select id,Contact_Role__c from contact where  recordtype.developername='UK_Contact' and accountid in:validacclst and Contact_Role__c=null]){
            c.Contact_Role__c='Owner';
            conToBeUpdated.add(c);
        }
        
        
        system.debug(contobeupdated.size());
        update contobeupdated;
    }

 global void finish(Database.BatchableContext BC) {
    
  }

}