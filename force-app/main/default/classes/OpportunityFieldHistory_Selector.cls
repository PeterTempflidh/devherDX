/**
* @author Mantas Jurkunas
* @date 14.04.2020
*
* @description Selector class for retrieving Opportunity Field History records
*/
public with sharing class OpportunityFieldHistory_Selector {

    /**
    * @description retrieve Stage field histories for opportunities
    *
    * @param opportunityIds parent opportunities
    *
    * @return Stage field histories
    */
    public static List<OpportunityFieldHistory> getByOpportunityIds(Set<Id> opportunityIds) {
        List<OpportunityFieldHistory> fieldHistories = new List<OpportunityFieldHistory>();
        try {
            fieldHistories = [
                    SELECT
                            CreatedDate,
                            Field,
                            NewValue,
                            OldValue,
                            OpportunityId
                    FROM
                            OpportunityFieldHistory
                    WHERE
                    Field = 'StageName'
                    AND
                    OpportunityId IN :opportunityIds
                    ORDER BY CreatedDate DESC
            ];
        } catch (QueryException e) {
            System.debug(e.getStackTraceString());
        }
        return fieldHistories;
    }
}