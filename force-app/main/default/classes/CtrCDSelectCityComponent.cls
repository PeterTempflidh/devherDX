public with sharing class CtrCDSelectCityComponent {
	@RemoteAction
	public static Set<String> getCities(String countryCode) {
		return ClsBEIntegrationUtils.getCitiesByCountryCode(countryCode);
	}
}