/**
* @author William Castillo
* @date 28.02.2020
*
* @description helper to determinate the current status of the account  : SSS-948
*/
public with sharing class AccountStatus_helper {
    /*******************************************************************************************************
     * @description Evaluate the status of the account
     * @param currentAccount an account that will be determinate witch is the status
     * @return void
     */
    public static void evaluatedStatus (Account currentAccount){
        map<String,String> mpStatusAccVsOpp = new map<String,String>();
        mpStatusAccVsOpp.put('Closed Lost','Lost');
        mpStatusAccVsOpp.put('Verbal Agreement','Negotiation');
        mpStatusAccVsOpp.put('Please Check','Negotiation');
        mpStatusAccVsOpp.put('Contact Established','Negotiation');
        mpStatusAccVsOpp.put('Quality Check Request','Quality Check');
        mpStatusAccVsOpp.put('Editorial Queue','Menu processing');
        mpStatusAccVsOpp.put('Onboarding','Onboarding');


        currentAccount.Account_Status__c =   'New';

        if(currentAccount.contracts != null && currentAccount.contracts.size()>0){
            currentAccount.Account_Status__c = 'Terminated';
            for(Contract currentContract: currentAccount.contracts){
                if(currentContract.status == 'Activated'){
                    currentAccount.Account_Status__c = 'Active';
                    return;
                }
            }
        }
        if(currentAccount.Opportunities != null){
            for(Opportunity currentOpportunity: currentAccount.Opportunities){
                if(mpStatusAccVsOpp.ContainsKey(currentOpportunity.stageName)){
                     currentAccount.Account_Status__c =   mpStatusAccVsOpp.get(currentOpportunity.stageName);
                }
            }
        }

    }
}