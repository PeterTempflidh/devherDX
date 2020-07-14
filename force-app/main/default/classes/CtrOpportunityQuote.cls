/*
@author : Magesh Mani Yadav
@reviewer : 
@creation : 16.09.2014
*/
public class CtrOpportunityQuote {

	private static Map<String, Map<String,Map<String,Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;

	public Opportunity opp {get;set;}
	public Opportunity_Quote__c oppQuote {get;set;}
	private Map<String,Business_Config__c> mapBusinessData {get;set;}
	public Map<Id,Opportunity_Quote_Product_Item__c> mapExistingProducts {get;set;}
	public Map<Id,Opportunity_Quote_Service_Item__c> mapExistingServices {get;set;}
	public String company { get; set; }
	public EmailTemplate theEmailTemplate { get; set; }
	/*public EmailTemplate theEmailTemplate{
        get {
            if(theEmailTemplate == null){
                theEmailTemplate = LibBusinessConfig.getEmailTemplateRecord('quoteVFTemplate');
            }
            return theEmailTemplate;
        }
        set;
    }

    public RecordType oppQuoteProductItemRecordType{
        get {
            if(oppQuoteProductItemRecordType == null){
                oppQuoteProductItemRecordType = LibBusinessConfig.getRecordTypeId('Opportunity_Quote_Product_Item');
            }
            return oppQuoteProductItemRecordType;
        }
        set;
    }

    public RecordType oppQuoteServiceItemRecordType{
        get {
            if(oppQuoteServiceItemRecordType == null){
                oppQuoteServiceItemRecordType = LibBusinessConfig.getRecordTypeId('Opportunity_Quote_Service_Item');
            }
            return oppQuoteServiceItemRecordType;
        }
        set;
    }*/

	/* opportunity whose quotes should be rendered as pdf */
	public String opportunityId { get; set; }

	public CtrOpportunityQuote(){
		opportunityId = ApexPages.currentPage().getParameters().get('opportunityId');
		this.opp = [SELECT Id, RecordTypeId, RecordType.DeveloperName,account.recordtype.developerName, AccountId, CurrencyIsoCode, SubTotalRF__c, Total_fm__c, VAT_fm__c FROM Opportunity WHERE Id = :opportunityId];
		this.mapExistingProducts = new Map<Id,Opportunity_Quote_Product_Item__c>();
		system.debug('@@@@ calling CtrOpportunityQuote this.opp : ' + this.opp);
		this.mapExistingServices = new Map<Id,Opportunity_Quote_Service_Item__c>();
		//Map<String,Map<String,Business_Config__c>> mapProcessData= LibBusinessConfig.getGenericProcessData('OppQuoteProcess');
		Map<String,Map<String,Business_Config__c>> mapProcessData= moam.get('OppQuoteProcess');
		this.oppQuote = new Opportunity_Quote__c();
		//this.oppQuote.Subtotal__c = this.opp.Subtotal__c;
		//this.oppQuote.Total__c = this.opp.Total__c;
		//this.oppQuote.VAT__c = this.opp.VAT__c;
		this.oppQuote.Id_Opportunity__c = this.opp.id;
		this.oppQuote.status__c = 'Draft';
		this.oppQuote.CurrencyIsoCode=this.opp.CurrencyIsoCode;
		this.oppQuote.Id_Account__c = this.opp.accountId;
		this.company = LibBusinessConfig.determineCompany(this.opp.account.recordtype.developerName);
		system.debug('@@@@ calling CtrOpportunityQuote this.oppQuote : ' + this.oppQuote);
		if(mapProcessData!=null && !mapProcessData.isEmpty()){
			this.mapBusinessData = mapProcessData.get(this.opp.RecordType.DeveloperName);
			if(this.mapBusinessData!=null && !this.mapBusinessData.isEmpty()){
				//Id productItemRecordTypeId = LibRecordTypeHelper.getRecordType(this.company + '_Opportunity_Quote_Product_Item', 'Opportunity_Quote_Product_Item__c').Id;
				//Id serviceItemRecordTypeId = LibRecordTypeHelper.getRecordType(this.company + '_Opportunity_Quote_Service_Item', 'Opportunity_Quote_Service_Item__c').Id;
				Id productItemRecordTypeId = Id.valueOf(LibRecordTypeHelper.getRecordTypeValue(this.company + '_Opportunity_Quote_Product_Item'));
				Id serviceItemRecordTypeId = Id.valueOf(LibRecordTypeHelper.getRecordTypeValue(this.company + '_Opportunity_Quote_Service_Item'));
				/*if(Boolean.valueOf(this.mapBusinessData.get('IncludeProduct').Business_Rule_Value__c)){
					for(Opportunity_Product_Item__c existingProduct : [select id,name, Listed_Price__c, Quantity__c, Total_Amount__c, Product_Group__c, Rabbat__c, Installments__c,Has_Related_Tarif__c from Opportunity_Product_Item__c where Id_Opportunity__c=:this.opp.id]){
                    	this.mapExistingProducts.put(existingProduct.id,new Opportunity_Quote_Product_Item__c(name = existingProduct.name, Listed_Price__c = existingProduct.Listed_Price__c, Quantity__c = existingProduct.Quantity__c, Total_Amount__c = existingProduct.Total_Amount__c, Product_Group__c = existingProduct.Product_Group__c, Rabbat__c = existingProduct.Rabbat__c, Installments__c = existingProduct.Installments__c, Has_Related_Tarif__c = existingProduct.Has_Related_Tarif__c, recordtypeid = oppQuoteProductItemRecordType.Id, CurrencyIsoCode = this.opp.CurrencyIsoCode));
              		}
    			}
    			if(Boolean.valueOf(this.mapBusinessData.get('IncludeService').Business_Rule_Value__c)){
    				for(Opportunity_Service_Item__c existingService : [select id,name,Commission_In_Percentage__c, Commission_Per_Order__c, Type__c,Has_Related_Tarif__c,End_Date__c,Start_Date__c,Recurring_Fee__c from Opportunity_Service_Item__c where Id_Opportunity__c=:this.opp.id]){
                      	this.mapExistingServices.put(existingService.id,new Opportunity_Quote_Service_Item__c(name = existingService.name, Commission_In_Percentage__c = existingService.Commission_In_Percentage__c, Commission_Per_Order__c = existingService.Commission_Per_Order__c, Type__c = existingService.Type__c, Has_Related_Tarif__c = existingService.Has_Related_Tarif__c, End_Date__c = existingService.End_Date__c, Start_Date__c = existingService.Start_Date__c, recordtypeid = oppQuoteServiceItemRecordType.Id, CurrencyIsoCode = this.opp.CurrencyIsoCode,Recurring_Fee__c=existingService.Recurring_Fee__c));
              		}
				}*/
				if(Boolean.valueOf(this.mapBusinessData.get('IncludeProduct').Business_Rule_Value__c)){
					for(Opportunity_Product_Item__c existingProduct : [select id,name, Listed_Price__c, Quantity__c, Total_Amount__c, Product_Group__c, Rabbat__c, Installments__c,Has_Related_Tarif__c from Opportunity_Product_Item__c where Id_Opportunity__c=:this.opp.id]){
                    	this.mapExistingProducts.put(existingProduct.id,new Opportunity_Quote_Product_Item__c(name = existingProduct.name, Listed_Price__c = existingProduct.Listed_Price__c, Quantity__c = existingProduct.Quantity__c, Total_Amount__c = existingProduct.Total_Amount__c, Product_Group__c = existingProduct.Product_Group__c, Rabbat__c = existingProduct.Rabbat__c, Installments__c = existingProduct.Installments__c, Has_Related_Tarif__c = existingProduct.Has_Related_Tarif__c, recordtypeid = productItemRecordTypeId, CurrencyIsoCode = this.opp.CurrencyIsoCode));
              		}
    			}
    			if(Boolean.valueOf(this.mapBusinessData.get('IncludeService').Business_Rule_Value__c)){
    				for(Opportunity_Service_Item__c existingService : [select id,name,Commission_In_Percentage__c, Commission_Per_Order__c, Type__c,Has_Related_Tarif__c,End_Date__c,Start_Date__c,Recurring_Fee__c from Opportunity_Service_Item__c where Id_Opportunity__c=:this.opp.id]){
                      	this.mapExistingServices.put(existingService.id,new Opportunity_Quote_Service_Item__c(name = existingService.name, Commission_In_Percentage__c = existingService.Commission_In_Percentage__c, Commission_Per_Order__c = existingService.Commission_Per_Order__c, Type__c = existingService.Type__c, Has_Related_Tarif__c = existingService.Has_Related_Tarif__c, End_Date__c = existingService.End_Date__c, Start_Date__c = existingService.Start_Date__c, recordtypeid = serviceItemRecordTypeId, CurrencyIsoCode = this.opp.CurrencyIsoCode,Recurring_Fee__c=existingService.Recurring_Fee__c));
              		}
				}
			}
		}else{
			 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info,Label.BusinessProcessNotActive));
		}

	}
	
	/*public void createQuote(){

	}

	public void cancel(){
		
	}*/
}