/**
* @author Peter Kalina
* @date 14.05.2019
*
* @description Class containing generic methods for Opportunity Line Item Object
*/
public inherited sharing class OppLineItemProcessor {

    /*******************************************************************************************************
    * @description Update Opportunity Start Date with earlier Start Date from Opportunity Line Item.
    * @param objects List<Opportunity_Line_Item__c> List of new Trigger values.
    * @return
    */
    public static List<Opportunity> updateOpportunityStartDate(List<Opportunity_Line_Item__c> OppLineItemList) {

        List<ID> listOppID = new List<ID>();
        Map<ID,Opportunity_Line_Item__c> mapLatestOppLineItemStartDate = new Map<ID,Opportunity_Line_Item__c>();
        Set<ID> setOppID = new Set<ID>(); // SSC-1646 Defect Fix Changes
        List<Opportunity_Line_Item__c> listOppLineItem = new List<Opportunity_Line_Item__c>(); // SSC-1646 Defect Fix Changes
        Set<String> setOfLineItemTypes = new Set<String>(); // SSC-1646 Defect Fix Changes

        for(Opportunity_Line_Item__c fOppLineItemList: OppLineItemList){
            if(fOppLineItemList.Line_Item_Type__c == 'Service'){
                listOppID.add(fOppLineItemList.Id_Opportunity__c);
                // SSC-1646 Defect Fix Changes: Starts Here
                setOppID.add(fOppLineItemList.Id_Opportunity__c);
                setOfLineItemTypes.add(fOppLineItemList.Line_Item_Type__c);
                // SSC-1646 Defect Fix Changes: Ends Here
                if(!mapLatestOppLineItemStartDate.containsKey(fOppLineItemList.Id_Opportunity__c)){
                    mapLatestOppLineItemStartDate.put(fOppLineItemList.Id_Opportunity__c, fOppLineItemList);
                }
                else if(mapLatestOppLineItemStartDate.get(fOppLineItemList.Id_Opportunity__c).Start_Date__c > fOppLineItemList.Start_Date__c){
                   mapLatestOppLineItemStartDate.put(fOppLineItemList.Id_Opportunity__c, fOppLineItemList);
                }
                
            }
        }
        // SSC-1646 Defect Fix Changes: Starts Here
        if(setOppID!=null && setOfLineItemTypes!=null){
            listOppLineItem = OppLineItems_Selector.getLineitemsBasedOnItemTypesAndOppty(setOppID,setOfLineItemTypes);
        }
        List<Opportunity> listOpp = Opportunity_Selector.getSelected(listOppID);
        List<Opportunity> listOppToUpdate = new List<Opportunity>();
        for(Opportunity flistOpp: listOpp){
            if(flistOpp.Start_Date_uk__c == null || flistOpp.Start_Date_uk__c > mapLatestOppLineItemStartDate.get(flistOpp.ID).Start_Date__c ){
                Opportunity recOppToUpdate = new Opportunity(ID = flistOpp.ID, Start_Date_uk__c = mapLatestOppLineItemStartDate.get(flistOpp.ID).Start_Date__c);
                listOppToUpdate.add(recOppToUpdate);
            }
            /** SSC-1646: DefectFix
             * If user add multiple commission back & forth then update the oppty start date with the earlist opli start date
             */
            else if(!listOppLineItem.isEmpty()){
                Opportunity recOppToUpdate = new Opportunity(ID = flistOpp.ID, Start_Date_uk__c = listOppLineItem[0].Start_Date__c);
               listOppToUpdate.add(recOppToUpdate);
            }
        }
        // SSC-1646 Defect Fix Changes: Ends Here
        return listOppToUpdate;
    }
}
