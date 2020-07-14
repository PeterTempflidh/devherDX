public with sharing class CtrWarehouseShipDevices {
	
	/*public  Map<String, deviceToShip> mapDevicesToShip {Get;Set;}
	public String assetItemId {Get;Set;}

	public Map<Id,Stock_Item_Assigned__c> mapNotAssignedItems {Get;Set;}

	public Map<Id,Account> mapAccount {Get;Set;}
	public Account accountToShipTo {Get;Set;}

	public Map<Id,Stock_Item__c> mapStockItems {Get;Set;}
	public Stock_Item__c assignStockItem {Get;Set;}
	public String barcode {Get;Set;}

	public Stock_Item_Assigned__c assignedStockItem {Get;Set;}

	public CtrWarehouseShipDevices() {
		this.assignedStockItem = new Stock_Item_Assigned__c();
		this.assignStockItem = new Stock_Item__c();
		this.mapDevicesToShip = new Map<String, deviceToShip>();

		this.mapStockItems = new Map<Id,Stock_Item__c>([SELECT Id,Simcard_Number__c,Type__c,
														Production_Date__c,Simcard_Provider__c,Date_ordered__c,Date_arrived__c

														 FROM Stock_Item__c 
									WHERE Id_Account__c = null]);

		this.mapNotAssignedItems = new Map<Id,Stock_Item_Assigned__c>([ SELECT Id,Id_Account__c,
																Asset_Item_Name__c ,
																CreatedDate 
														         FROM Stock_Item_Assigned__c
														         WHERE Id_Stock_Item__c  = null ]);

		Set<Id> setAccountId = new Set<Id>();
		for(Stock_Item_Assigned__c stockItemAssigned : mapNotAssignedItems.values()){
			setAccountId.add(stockItemAssigned.Id_Account__c);
		}
		this.mapAccount = new Map<Id,Account>([SELECT Id, Name,Restaurant_Name__c ,
			ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet
										FROM Account
										WHERE id = :setAccountId]);
		
		for(Stock_Item_Assigned__c stockItemAssigned : mapNotAssignedItems.values()){
			DeviceToShip newDeviceToShip = new DeviceToShip(stockItemAssigned,  mapAccount.get(stockItemAssigned.Id_Account__c));
			this.mapDevicesToShip.put(stockItemAssigned.Id,newDeviceToShip);
		}

		this.accountToShipTo = new Account();
	}

	public void assign(){

		this.accountToShipTo = this.mapAccount.get(this.mapNotAssignedItems.get(this.assetItemId).Id_Account__c);


	}

	public void ship(){
		Boolean notFound = true;
		for(Stock_Item__c sti : this.mapStockItems.values()){
			if(sti.Serial_number__c == barcode){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'FOUND'));
					this.assignStockItem = sti;
					notFound = false;
			}
		}
		if(notFound){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Stock item with this serial number could not be found'));
			this.assignStockItem  = new Stock_Item__c();
		}
	}

	public void doShipment(){
		
	}

	public class DeviceToShip{

		public String deviceName {Get;Set;}
		public String restaurantName {Get;Set;}
		public String accountId {Get;Set;}
		public String stockItemAssignedId {Get;Set;}
		public String opportunityWonDate {Get;Set;}
		
		public deviceToShip(Stock_Item_Assigned__c itemAssigned,Account acc){
			this.deviceName = itemAssigned.Asset_Item_Name__c;
			this.restaurantName = acc.Restaurant_Name__c;
			this.accountId = acc.Id;
			this.stockItemAssignedId = itemAssigned.Id;
			this.opportunityWonDate =  string.valueof(itemAssigned.CreatedDate);
		}
	}*/
}