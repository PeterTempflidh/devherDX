public with sharing class xALCountry {

	public String developerName								{get; set;}
	public String label										{get; set;}
	public String code										{get; set;}
	public xALAdministrativeArea adminArea 					{get; set;}
	public List<xALAdministrativeArea> adminAreas 			{get; set;}

	/**
	 * Creates a new instance of xALCountry from specified xAL_Country__mdt
	 * record.
	 * @param  country  Country record
	 * @param  deepLoad If true then load also related entities
	 * @return          [description]
	 */
	private xALCountry(xAL_Country__mdt country, Boolean deepLoad) {
		developerName = country.DeveloperName;
		label = country.MasterLabel;
		code = country.Code__c;

		if (deepLoad) {
			adminAreas = xALAdministrativeArea.byCountry(developerName);
		}
	}

	public xALCountry() {}

	public xALCountry(Country__c country) {
		this.developerName = country.Name;
		this.label = country.Name;
		this.code = country.Iso__c;
	}

	public static xALCountry byLabel(String countryLabel) {
		return new xALCountry([
		                          SELECT
		                          DeveloperName,
		                          MasterLabel,
		                          Code__c
		                          FROM xAL_Country__mdt
		                          WHERE MasterLabel = :countryLabel
		                                  LIMIT 1
		                      ], true);
	}

	/**
	 * Retrieves a country instance by county's developer name
	 * @param  countryName Country developer name
	 * @return             A country instance or null
	 */
	public static xALCountry byName(String countryName) {
		return new xALCountry([
		                          SELECT
		                          DeveloperName,
		                          MasterLabel,
		                          Code__c
		                          FROM xAL_Country__mdt
		                          WHERE DeveloperName = :countryName
		                                  LIMIT 1
		                      ], true);
	}

	/**
	 * Retrieves a list of countries based on specified code
	 * @param  codes List of countries' code
	 * @return       A list of xALCountry or an empty list
	 */
	public static List<xALCountry> byCodes(List<String> codes) {
		return fromList([
		                    SELECT
		                    DeveloperName,
		                    MasterLabel,
		                    Code__c
		                    FROM xAL_Country__mdt
		                    WHERE Code__c in :codes
		                    ORDER BY MasterLabel
		                ]);
	}

	private static List<xALCountry> fromList(List<xAL_Country__mdt> records) {
		List<xALCountry> res = new List<xALCountry>();
		for (xAL_Country__mdt record : records) {
			res.add(new xALCountry(record, false));
		}
		return res;
	}
}