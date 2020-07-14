//TODO: Investigate duplicate code
public with sharing class ClsWebserviceCalloutAdSalesKR {

	public static FixedCommissionWrapper getFixAmountCommissionDistricts(String backendId) {
		return ClsWebserviceCalloutsKR.getFixAmountCommissionDistricts(backendId);
	}

	public static DistrictPriceCategoryWrapper getAvailableDistrictsAndCategories(String backendId) {
		return ClsWebserviceCalloutsKR.getAvailableDistrictsAndCategories(backendId);
	}
} 