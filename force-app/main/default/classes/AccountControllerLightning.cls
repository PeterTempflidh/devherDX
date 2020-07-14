/**
* @author Krunoslav Bilicic
* @date 28.1.2019.
* 
* @group Accounts
*
* @description Lightning component server side controller for Account related operations. This class is used for all Account related lightning components
*/
public class AccountControllerLightning {
    
    @AuraEnabled
    public static string newCallCase(String accountId){
        
        if(String.isEmpty(accountId)) {
            return JSON.Serialize(new ResultWrapperBuilder(false).setUserMessage(Label.AccountId_is_not_specified).Build());
        }

        Account acc = AccountSelector.getAccountDetailsforId((Id)accountId);
        
        Case newCase = new Case();
        newCase.AccountId = acc.Id;
        newCase.OwnerId = UserInfo.getUserId();
        newCase.Origin = 'Phone';
        newCase.Contact_Email__c= acc.Account_Email__c;

        if(acc.RecordType.DeveloperName =='DE_Account'){// check for the DE Account
            newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('DE_Inbound_Case').getRecordTypeId(); 
            if (acc.Id =='0011r00001lGG13') { // DE Dummy Account
                newCase.Type = 'Customer Request';
                newCase.Queue_ID__c = GroupSelector.getQueueByName('DE Customer Request').Id;
            } 
            else {
                newCase.Type = 'Restaurant Request';
                newCase.Queue_ID__c = GroupSelector.getQueueByName('DE Restaurant Request').Id;
            }
        } else if (acc.RecordType.DeveloperName =='CD_Account') {
            newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CD_Inbound_Case').getRecordTypeId();  // set the CD_Inbound_Case
            if (acc.Id =='0011r00001osxZ4'){ // CD Dummy Account
                newCase.Type = 'Customer Request';
                newCase.Queue_ID__c = GroupSelector.getQueueByName('CD Customer Request').Id;
            } 
            else {
                newCase.Type = 'Restaurant Request';
                newCase.Queue_ID__c = GroupSelector.getQueueByName('CD Restaurant Request').Id;
            }
        }

        Database.SaveResult saveResult = Database.insert(newCase, true);

        if (saveResult.isSuccess()){
            String userMessage = newCase.Type + ' case created';
            return JSON.Serialize(new ResultWrapperBuilder(true).setId(newCase.Id)
                                                                .setUserMessage(userMessage)
                                                                .Build());
        } else {
            return JSON.Serialize(new ResultWrapperBuilder(false).setErrorMessage(saveResult.getErrors()).Build());
        }
    }

    @AuraEnabled
    public static string terminateRestaurant(String accountId) {
        List<Asset__c> listAssets = AssetSelector.getActiveAssetsForAccount((Id)accountId);
        List<Additional_Charges__c> listAddCharge = AdditionalChargesSelector.getActiveAdditionalChargesForAccount((id)accountId);
        List<Contract> allContracts = ContractSelector.getActiveContractsForAccount((id)accountId);
        
        if(!listAssets.isEmpty() || !listAddCharge.isEmpty() || !allContracts.isEmpty()) {
            String userMessage = String.format(Label.Restaurant_contract_count, new List<Integer> {listAssets.size(), listAddCharge.size(), allContracts.size() });
            
            return JSON.Serialize(new ResultWrapperBuilder(true).setId((Id)accountId)
                                                                .setUserMessage(userMessage)
                                                                .Build());
        } else {
            String userMessage = Label.Restaurant_Nothing_to_terminate;

            return JSON.Serialize(new ResultWrapperBuilder(false).setId((Id)accountId)
                                                                .setUserMessage(userMessage)
                                                                .Build());
        }
    }
    /*
    private static Id getQueueId(String queueDeveloperName) {
        try {
            Group queue = GroupSelector.getQueueByDeveloperName(queueDeveloperName);
            if(queue != null) {
                return queue.Id;
            } else {
                return null;
            }
        } catch (Exception ex) {
            return null;
        }
    }

    private static Id getCaseRecordTypeId(String developerName) {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
    }*/
   
}