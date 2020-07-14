public with sharing class CtrAssetManager {
	public Asset__c myAsset {Get;Set;}
	public Map<Id,Asset__c> mapExistingAssets {Get;Set;}

	public String selectedAssetToEdit {Get;Set;}

	public CtrAssetManager() {
		initAssets();

	}

	private void initAssets(){
		this.myAsset = new Asset__c();

		this.mapExistingAssets = new Map<Id,Asset__c>(
							[SELECT Id,Name,Is_Active__c
							 FROM	Asset__c LIMIT 500
							]);
	}

	private boolean saveValidation(){
		return true;
	}

	private void reset(){
		this.myAsset = new Asset__c();
	}

	public void editAsset(){
		if(selectedAssetToEdit != null){
			this.myAsset = mapExistingAssets.get(selectedAssetToEdit);
		}
	}

	public void save(){
		if(saveValidation()){
			upsert myAsset;

			reset();
		}
	}

}