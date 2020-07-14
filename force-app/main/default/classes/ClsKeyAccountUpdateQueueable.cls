/**
 * @Class       : ClsKeyAccountUpdateQueueable
 * @Created Date : [20/05/2020]
 * @description This class is used on the Key Account Update
*/

public with sharing class ClsKeyAccountUpdateQueueable implements Queueable{
    public Map<Id,Boolean> accountKeyAccountMap = new Map<Id,Boolean>();

    /**
     * @Class       : ClsKeyAccountUpdateQueueable
     * @Created Date : [20/05/2020]
     * @description This class is used on the Key Account Update
     * @param  accountKeyAccountMap Map<Id,Boolean>
    */
    public ClsKeyAccountUpdateQueueable(Map<Id,Boolean> accountKeyAccountMap){
        this.accountKeyAccountMap = accountKeyAccountMap;
    }

    /**
    * @date     : [20/05/2020]
    * @method name  : execute
    * @description  : Update Key Account
    * @param  context QueueableContext
    */
    public void execute(QueueableContext context) {
        List<Account> accountsToUpdate =  new List<Account>();
        for(Account obj : AccountSelector.selectByIdWithChildAccounts(accountKeyAccountMap.keySet())){
            for(Account childAccount : obj.ChildAccounts){
                childAccount.Key_VIP_Account__c = accountKeyAccountMap.get(childAccount.ParentId);
                childAccount.Is_Apex__c = childAccount.Is_Apex__c == false ? true : false ;
                accountsToUpdate.add(childAccount);
            }
        }
       if(!accountsToUpdate.isEmpty()){
         update accountsToUpdate;
       }
    }
}