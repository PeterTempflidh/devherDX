/**
* @author Mantas Jurkunas
* @date 08.10.2019
*
* @description Selector class for stock items
*/

public class StockItem_Selector {
    
    public static List<Stock_Item__c> getStockItems(Set<Id> ids) { 
    	return [SELECT Id, Name, Status__c, Condition__c, Id_Account__c 
                FROM Stock_Item__c 
                WHERE Id IN :ids];
    }
}

