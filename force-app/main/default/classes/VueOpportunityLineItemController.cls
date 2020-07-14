/**
 * Created by t.holawala on 27.09.2017.
 */

global with sharing class VueOpportunityLineItemController {
    public static Map<Id,List_Service_Price__c> commissionMap;


    /**
        @Description: fetch the commission details based on the commission Id.
     */
    @RemoteAction
    global static Tarif.commission fetchCommissionDetails(String commissionId){
    	Tarif.Commission comm = new tarif.Commission();
    	if(string.isBlank(commissionId)){
			return comm;
		}
        List_Service_Price__c commObj    = [SELECT Based_On__c,Commission_In_Percentage__c,Commission_Per_Order__c,Commission_Type__c,Company__c,
                                                    Default_Commission_In_Percentage__c,Displayed_Name__c,Id,Id_Asset__c,Id_Country__c,Is_Active__c,
                                                    Maximum_Commission_In_Percentage__c,Maximum_Commission_Per_Order__c,Minimum_Commission_in_Percentage__c,
                                                    Minimum_Commission_Per_Order__c,Name,Recurring_Fee__c,Recurring_Interval__c,Requires_Approval__c,
                                                    Scaled__c,Service_Type__c,Type__c,RecordTypeId
                                            FROM List_Service_Price__c
                                            WHERE Id =: commissionId];

        comm.populateValuesFromObject(commObj,false);
        return comm;
  
    }

    /**
	 * @description Fetch fixed commission wrapper based on Account backend Id
	 *
	 * @return FixedCommissionWrapper
	 * @see ClsWebserviceCalloutsKR
	 */
    @RemoteAction
    global static FixedCommissionWrapper getFlatCommissionWrapper(String backendId) {
        if(String.isBlank(backendId)) {
            return null;
        }
        FixedCommissionWrapper diPrCaWr = ClsWebserviceCalloutsKR.getFixAmountCommissionDistricts(backendId);
        return diPrCaWr;
    }

    @RemoteAction
    global static Tarif.Product fetchProductDetails(String productId){
        Tarif.Product productWrapper = new Tarif.product();
        if(string.isBlank(productId)){
			return productWrapper;
		}
        List_Product_Price__c product = [SELECT Allow_Installments__c,Company__c,Default_Quantity__c,Displayed_Name__c,Id,Id_Asset__c,Id_Country__c,
                                                Id_List_Product_Group__c,Installments__c,Is_Active__c,List_Price__c,Maximum_Discount__c,Name,Product_Name__c,
                                                Product_Type__c,RecordTypeId,Requires_Additional_Charge__c,Requires_Add_On__c,Requires_Asset__c,SKU__c,
                                                Requires_Branding__c,Requires_Replacement__c,Unapproved_Discount_Limit__c ,Id_List_Product_Group__r.name
                                            FROM List_Product_Price__c
                                            WHERE id =: productId
                                            AND requires_additional_charge__c= true
                                            AND requires_asset__c= false
                                            AND requires_branding__c= false];

        productWrapper.populateProductFromObject(product,false);
        return productWrapper;
    }
    @RemoteAction
    global static Tarif.Product fetchAssetDetails(String productId){
        Tarif.Product productWrapper = new Tarif.product();
        if(string.isBlank(productId)){
            return productWrapper;
        }
        List_Product_Price__c product = [SELECT Allow_Installments__c,Company__c,Default_Quantity__c,Displayed_Name__c,Id,Id_Asset__c,Id_Country__c,
                Id_List_Product_Group__c,Installments__c,Is_Active__c,List_Price__c,Maximum_Discount__c,Name,Product_Name__c,
                Product_Type__c,RecordTypeId,Requires_Additional_Charge__c,Requires_Add_On__c,Requires_Asset__c,sku__c,
                Requires_Branding__c,Requires_Replacement__c,Unapproved_Discount_Limit__c ,Id_List_Product_Group__r.name
        FROM List_Product_Price__c
        where id =: productId
        and (requires_asset__c= true
        OR requires_branding__c= true)];

        productWrapper.populateProductFromObject(product,false);
        return productWrapper;
    }
    
    @RemoteAction
    global static Tarif.AddOn fetchAddOnDetails(String addOnId){
		Tarif.AddOn addOnWrapper	= new Tarif.AddOn();
		if(string.isBlank(addOnId)){
			return addOnWrapper;
		}
    	List_Add_On__c addOn		= [SELECT Company__c,Contract_Addition__c,Id,Id_Country__c,Is_Active__c,Name,
											RecordTypeId,Requires_Approval__c,type__c 
										FROM List_Add_On__c
										WHERE Id =: addOnId];
										
		addOnWrapper.populateAddOnFromObject(addOn,false);
		return addOnWrapper;		
    }


	/**
	* @Description: This method validates the start dates and calculate the end date
					1. Two commissions of same service type of the same company cannot have the same start date
	*/
    @RemoteAction  
    global static List<Tarif.Commission> popuateEndDate(String serializedCommissions){
        List<Tarif.Commission> commissions = (List<Tarif.Commission>)JSON.deserialize(serializedCommissions,List<Tarif.Commission>.class);
        List<Tarif.Commission> finalCommissionList = new List<Tarif.Commission>();
        // A map of Service type vs the start date vs the commission
        //Map<String,Map<Date,Tarif.Commission>> serviceTypeVsDateMap =  new Map<String,Map<Date,Tarif.Commission>>();
        Map<String,Map<String,Map<Date,Tarif.Commission>>> companyVsServiceTypeMap = new  Map<String,Map<String,Map<Date,Tarif.Commission>>>();
        RecordType talabatRecordType = LibRecordTypeHelper.getRecordType('Talabat_List_Service_Price','List_Service_price__c');

        //populate the map
        for(Tarif.Commission comm : commissions){
            if(comm.startDate != null) {
            	if(companyVsServiceTypeMap.containsKey(comm.company)){
            		Map<String,Map<Date,Tarif.Commission>> serviceTypeVsDateMap = companyVsServiceTypeMap.get(comm.company);
            		if (serviceTypeVsDateMap.containsKey(comm.serviceType)) {
	                    if(serviceTypeVsDateMap.get(comm.serviceType).get(comm.startDate) == null) {
	                        serviceTypeVsDateMap.get(comm.serviceType).put(comm.startDate, comm);
	                    }else{
	                    	throw new TarifException('Two commissions of same service type cannot have same start date');
	                    }
	                } else {
	                    Map<Date, Tarif.Commission> startDateMap = new Map<Date, Tarif.Commission>();
	                    startDateMap.put(comm.startDate, comm);
	                    serviceTypeVsDateMap.put(comm.serviceType, startDateMap);
	                }
            	}else{
            		Map<String,Map<Date,Tarif.Commission>> serviceTypeVsDateMap =  new Map<String,Map<Date,Tarif.Commission>>();
            		Map<Date, Tarif.Commission> startDateMap = new Map<Date, Tarif.Commission>();
                    startDateMap.put(comm.startDate, comm);
                    serviceTypeVsDateMap.put(comm.serviceType, startDateMap);
                    companyVsServiceTypeMap.put(comm.company,serviceTypeVsDateMap);
            	}
          
            }else{
                finalCommissionList.add(comm);
            }
        }

        // Sort the commissions based on the startDate and service type
        for(Map<String,Map<Date,Tarif.Commission>> serviceTypeVsDateMap : companyVsServiceTypeMap.values()){
        	for(Map<Date, Tarif.Commission> startDateMap : serviceTypeVsDateMap.values()){
	            Set<Date> keys = startDateMap.keySet();
	            List<Date> startDates = new List<Date>(keys);
	            startDates.sort();
	
	            for(Integer i=0;i< startDates.size();i++){
	                Tarif.Commission comm = startDateMap.get(startDates[i]);
	                if(i+1 < startDates.size() && startDateMap.get(startDates[i+1]) != null){
	                    comm.endDate = startDateMap.get(startDates[i+1]).startDate.addDays(-1);
	                }else{
	                	// for the last commission populate the end date after an year for Talabat
	                	if(comm.recordTypeId == talabatRecordType.Id){
	                    	//comm.endDate = comm.startDate.addYears(1).addDays(-1);
	                    	comm.endDate = null;	
	                	}else{
	                		comm.endDate = null;
	                	}
	                }
	                finalCommissionList.add(comm);
	            }
	        }
        }
        
        return finalCommissionList;
    }
	
    @RemoteAction
    global static List<CtrOpportunityLineItems.Option> fetchProducts(String categoryId){
        List<CtrOpportunityLineItems.Option> productOptions = new List<CtrOpportunityLineItems.Option>();
        List<List_Product_Price__c> products = [SELECT Id, Displayed_Name__c, Name,Product_name__c
                                                    FROM List_Product_Price__c
                                                    WHERE Id_List_Product_Group__c = :categoryId
                                                    AND is_Active__c = true
                                                    AND requires_additional_charge__c= true
                                                    AND requires_asset__c= false
                                                    AND requires_branding__c= false];
 
        for(List_Product_Price__c product : products){
            productOptions.add(new CtrOpportunityLineItems.Option(product.Product_name__c,product.Id));
        }

        return productOptions;
    }

    @RemoteAction
    global static List<CtrOpportunityLineItems.Option> fetchAssets(String categoryId){
        List<CtrOpportunityLineItems.Option> productOptions = new List<CtrOpportunityLineItems.Option>();
        List<List_Product_Price__c> products = [SELECT Id, Displayed_Name__c, Name,Product_name__c
        FROM List_Product_Price__c
        WHERE Id_List_Product_Group__c = :categoryId
        AND is_Active__c = true
        AND (requires_asset__c= true
        OR requires_branding__c= true)];

        for(List_Product_Price__c product : products){
            productOptions.add(new CtrOpportunityLineItems.Option(product.Product_name__c,product.Id));
        }

        return productOptions;
    }

    public class TarifException extends Exception{}
}
