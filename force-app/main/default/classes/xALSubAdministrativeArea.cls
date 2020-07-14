public with sharing class xALSubAdministrativeArea {

	public String developerName						{get; set;}
	public String label								{get; set;}
	public String code								{get; set;}
	public String type								{get; set;}
	public xALPostalCode postalCode					{get; set;}
	public xALLocality locality						{get; set;}
	public List<xALPostalCode> postalCodes			{get; set;}
	public List<xALLocality> localities				{get; set;}
	public String translatedAreaName			    {get; set;}

	private xALSubAdministrativeArea(xAL_SubAdministrativeAreas__mdt subArea, Boolean deepLoad) {
		developerName = subArea.DeveloperName;
		label = subArea.MasterLabel;
		code = subArea.Code__c;
		type = subArea.Type__c;
		if (deepLoad) {
			postalCodes = xALPostalCode.bySubAdministrativeArea(developerName);
			localities = xALLocality.bySubAdministrativeArea(developerName);
		}
	}

	public xALSubAdministrativeArea() {}

	/**
	 * Returns specified Sub Administrative area
	 * @param  areaName SubAdministrative area developer name
	 * @return          Specified sub-administrative area
	 */
	public static xALSubAdministrativeArea byName(String areaName) {
		return new xALSubAdministrativeArea([
		                                        SELECT
		                                        DeveloperName,
		                                        MasterLabel,
		                                        Code__c,
		                                        Type__c
		                                        FROM xAL_SubAdministrativeAreas__mdt
		                                        WHERE DeveloperName = :areaName
		                                                LIMIT 1
		                                    ], true);
	}

	/**
	 * Retrieves a list of Subadministrative area related to a specified
	 * Administrative area
	 * @param  areaName Administrative area developer name
	 * @return          A list of SubAdministrative areas or an empty list
	 */
	public static List<xALSubAdministrativeArea> byAdministrativeArea(String areaName) {
		return fromList([SELECT
		                 DeveloperName,
		                 MasterLabel,
		                 Code__c,
		                 Type__c
		                 FROM xAL_SubAdministrativeAreas__mdt
		                 WHERE xAL_AdministrativeArea__r.DeveloperName = :areaName
		                 ORDER BY MasterLabel
		                ]);
	}

	private static List<xALSubAdministrativeArea> fromList(List<xAL_SubAdministrativeAreas__mdt> records) {
		List<xALSubAdministrativeArea> res = new List<xALSubAdministrativeArea>();
		for (xAL_SubAdministrativeAreas__mdt record : records) {
			res.add(new xALSubAdministrativeArea(record, false));
		}
		return res;
	}
}
