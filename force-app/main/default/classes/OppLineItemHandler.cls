/**
* @author Peter Kalina
* @date 14.05.2019
*
* @description Trigger Handler for the Opportunity Line Item SObject. This class implements the ITrigger
* interface to help ensure the trigger code is bulkified and all in one place.
*/
public without sharing class OppLineItemHandler implements ITrigger{
    private List<Opportunity> listOpportunityToUpdate;

    // Constructor
    public OppLineItemHandler()
    {
    }
    
    public void bulkBefore()
    {    
    }
	   
    public void bulkAfter()
    {
		listOpportunityToUpdate = OppLineItemProcessor.updateOpportunityStartDate((List<Opportunity_Line_Item__c>)Trigger.new);
    }

    public void beforeInsert(SObject so)
    {
    }

    public void beforeUpdate(SObject oldSo, SObject so)
    {
    }

    public void beforeDelete(SObject so)
    {
    }

    public void afterInsert(SObject so)
    {
    }

    public void afterUpdate(SObject oldSo, SObject so)
    {
    }

    public void afterDelete(SObject so)
    {
    }

    public void andFinally()
    {
        try{
            if(listOpportunityToUpdate.size() <> 0){
                update listOpportunityToUpdate;
            }

        }
        catch (Exception e) {
			System.debug('An unexpected error has occurred: ' + e.getMessage());   
        }
    }    
}