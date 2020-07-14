/**
 * Created by danish.farooq on 3/31/20.
* @Description: This is queable class to generate opportunity and quote line items
  @TriggerContext     :  After Update
  @Ticket #            : SSC-1979
 */
public class OpportunityLineItemCreation_Queable implements Queueable {

    List<Opportunity> lstOppty;
    Set<Id> setOfTarif;

    public OpportunityLineItemCreation_Queable(list<Opportunity> aLstOppty,Set<Id> aSetOfTarif){
        lstOppty = aLstOppty;
        setOfTarif = aSetOfTarif;
    }
    /**
* @Description: This method executes asynchornous with different set of transaction and governor limits
  @param       : Queable context
  @Return      : void
 */
    public void execute(QueueableContext context) {
        ClsOpportunityLineItem_Utils.getOpportunityLineItemsFromTariff(setOfTarif, new Map<Id,Opportunity>(lstOppty));
    }
}