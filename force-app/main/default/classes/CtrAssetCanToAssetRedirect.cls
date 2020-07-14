public without sharing class CtrAssetCanToAssetRedirect {
	private Asset_Cancellation__c assetCanObj;
	public CtrAssetCanToAssetRedirect(ApexPages.StandardController stdController) {
		this.assetCanObj = (Asset_Cancellation__c) stdController.getRecord();
	}

	public PageReference redirectToAssetPage(){
		PageReference pf = new PageReference('/'+this.assetCanObj.Asset__c);
		return pf;
	}
}