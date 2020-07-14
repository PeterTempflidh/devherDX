/**
* @author Goverdhan Singh
*
* @description: This class is only for code coverage.
*               Functionality will be tested by the calling classes
*/
@IsTest
private class Opportunity_Selector_Test {

    @IsTest
    static void testOpportunity_Selector() {
        Opportunity_Selector.getAll();
        Opportunity_Selector.getAllWithChildren();
        Opportunity_Selector.getQuotesMap(new Set<Id>());
        Opportunity_Selector.getFromOppIdSet(new Set<Id>());
        Opportunity_Selector.getSelected(new List<Id>());
        Opportunity_Selector.getOpportunityClosed(new Set<Id>());
        Opportunity_Selector.getOpportunityByIdStage(new Set<Id>(), 'null');
        
        try{
            Opportunity_Selector.getOpportunityById('a0F3O000000YsgFUAS');
        } catch(Exception e){
            system.debug(e.getMessage());
        } 
        
        Opportunity_Selector.getOpportunityAgainstAccounts(new Set<Id>());
        Opportunity_Selector.fetchOQLIProductName('a0F3O000000YsgFUAS');
    }

}
