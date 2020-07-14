/**
 * Expose methods to encapsulate the logic to interact with metadata records
 * related to back-end settings
 */
public class ClsBEIntegrationUtils {

	// cache the custom setting
	private static Map<String, BEIntegration_CountriesToCities__c> allValues = BEIntegration_CountriesToCities__c.getAll();

	/**
	 * Given a country code returns the set of available cities in that country
	 * @param  countryCode Country iso code
	 * @return             set of cities related to specified country or an empty
	 * list if country not exist or there aren't cities
	 */
	public static Set<String> getCitiesByCountryCode(String countryCode) {
		Set<String> res = new Set<String>();

		for (BEIntegration_CountriesToCities__c conf : allValues.values()) {
			if (conf.Country_Code__c == countryCode) {
				res.add(conf.Name);
			}
		}

		return res;
	}

	/**
	 * Given a city and a country code checks if city's value is a valid one
	 * @param  city City Name
	 * @param countryCode Country iso code
	 * @return      true if city is a valid value and country code match
	 */
	public static Boolean isValidCity(String city, String countryCode) {
		return allValues.containsKey(city) ? allValues.get(city).Country_Code__c == countryCode : false;
	}
}