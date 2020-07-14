/**
* @author Krunoslav Bilicic
* @date 11.9.2019
*
* @description Selector class for retrieving Approval Rule records
*/

public class ApprovalRuleSelector  {
    public static List<Approval_Rule__c> getApprovalRules(Set<Id> comms, Set<Id> products, Set<Id> addOns, Set<string> country, Set<string> companyCode, Set<string> platforms)  {
        return [
            SELECT Id, Name, Commission__c, Product__c, Add_On__c,
                Level1_Value__c, Level1_Percentage__c, Level1_Approver__c, Level1_Approver2__c, Level1_Approver3__c, Level1_Approver4__c,
                Level2_Value__c, Level2_Percentage__c, Level2_Approver__c, Level2_Approver2__c, Level2_Approver3__c, Level2_Approver4__c,
                AddOn_Approver__c, AddOn_Approver2__c, AddOn_Approver3__c, AddOn_Approver4__c,
                Country__c, Country__r.Name, City__c,
                Platform__c, Company_Code__c, Weight__c,
                Applies_To__c,Vertical_Segment__c
                FROM Approval_Rule__c
                WHERE (Commission__c IN :comms
                OR Product__c IN :products
                OR Add_On__c IN :addOns
                OR Country__r.Name IN :country 
                OR Company_Code__c IN :companyCode 
                OR Platform__c IN :platforms)
                AND Active__c = TRUE
            ];
    }
}