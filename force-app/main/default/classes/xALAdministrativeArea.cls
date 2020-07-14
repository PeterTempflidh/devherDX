public with sharing class xALAdministrativeArea {

	public String developerName								{get; set;}
	public String label										{get; set;}
	public String code										{get; set;}
	public String type										{get; set;}
	public String parentCountry 							{get; set;}
	public xALLocality locality								{get; set;}
	public xALPostalCode postalCode							{get; set;}
	public xALSubAdministrativeArea subAdministrativeArea 	{get; set;}
	public List<xALLocality> localities							{get; set;}
	public List<xALSubAdministrativeArea> subAdministrativeAreas	{get; set;}
	public List<xALPostalCode> postalCodes							{get; set;}
	public string translatedCityName                                {get; set;}

	private xALAdministrativeArea(xAL_AdministrativeArea__mdt area, Boolean deepLoad) {
		developerName = area.DeveloperName;
		label = area.MasterLabel;
		code = area.Code__c;
		type = area.Type__c;
		parentCountry = area.xAL_Country__r.DeveloperName;

		if (deepLoad) {
			localities = xALLocality.byAdministrativeArea(developerName);
			subAdministrativeAreas = xALSubAdministrativeArea.byAdministrativeArea(developerName);
			postalCodes = xALPostalCode.byAdministrativeArea(developerName);
		}
	}
	public xALAdministrativeArea() {}
	/**
	 * Retrieves specified Administrative area record
	 * @param  developerName Administrative area developer name
	 * @return
	 */
	public static xALAdministrativeArea byName(String developerName) {
		return new xALAdministrativeArea([
		                                     SELECT
		                                     DeveloperName,
		                                     MasterLabel,
		                                     Code__c,
		                                     Type__c,
		                                     xAL_Country__r.DeveloperName
		                                     FROM xAL_AdministrativeArea__mdt
		                                     WHERE DeveloperName = : developerName
		                                             LIMIT 1
		                                 ], true);
	}

	/**
	 * Retrieves an admin area based on master label. If more than one admin areas
	 * match the specified label returns null
	 * @param  label Label to search for
	 * @return       An instance of xALAdministrativeArea or null
	 */
	public static xALAdministrativeArea byLabel(String label) {
		List<xAL_AdministrativeArea__mdt> adminAreas = [
		            SELECT
		            DeveloperName,
		            MasterLabel,
		            Code__c,
		            Type__c,
		            xAL_Country__r.DeveloperName
		            FROM xAL_AdministrativeArea__mdt
		            WHERE MasterLabel = : label
		        ];

        return adminAreas.size() == 1 ? new xALAdministrativeArea(adminAreas[0], true) : null;
	}

	/**
	 * Returns a list of administrative areas related to a specified country
	 * @param  countryName Country developer name
	 * @return             A list of Administrative Areas or an empty list
	 */
	public static List<xALAdministrativeArea> byCountry(String countryName) {
		return fromList([
		                    SELECT
		                    DeveloperName,
		                    MasterLabel,
		                    Code__c,
		                    Type__c,
		                    xAL_Country__r.DeveloperName
		                    FROM xAL_AdministrativeArea__mdt
		                    WHERE xAL_Country__r.DeveloperName = :countryName
		                            ORDER BY MasterLabel
		                ]);
	}

	private static List<xALAdministrativeArea> fromList(List<xAL_AdministrativeArea__mdt> records) {
		List<xALAdministrativeArea> res = new List<xALAdministrativeArea>();
		for (xAL_AdministrativeArea__mdt record : records) {
			res.add(new xALAdministrativeArea(record, false));
		}
		return res;
	}
}
