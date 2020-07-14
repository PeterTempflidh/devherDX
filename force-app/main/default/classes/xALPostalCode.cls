public with sharing class xALPostalCode {
	public String developerName			{get; set;}
	public String label					{get; set;}
	public String value				{get; set;}

	private xALPostalCode(xAL_PostalCode__mdt postalCode) {
		developerName = postalCode.DeveloperName;
		label = postalCode.MasterLabel;
		value = postalCode.Number__c;
	}

	/**
	 * Retrieves specified postal code record
	 * @param  developerName Postal Code developer name
	 * @return               
	 */
	public static xALPostalCode byName(String developerName) {
		return new xALPostalCode([
		                             SELECT
		                             DeveloperName,
		                             MasterLabel,
		                             Number__c
		                             FROM xAL_PostalCode__mdt
		                             WHERE DeveloperName = :developerName
		                                     LIMIT 1
		                         ]);
	}

	/**
	 * Retrieves a list of postal codes related to a specified Administrative Area
	 * @param  areaName Administrative area developer name
	 * @return          A list of postal codes or an empty list
	 */
	public static List<xALPostalCode> byAdministrativeArea(String areaName) {
		return fromList([
		                    SELECT
		                    DeveloperName,
		                    MasterLabel,
		                    Number__c
		                    FROM xAL_PostalCode__mdt
		                    WHERE xAL_AdministrativeArea__r.DeveloperName = :areaName
		                    ORDER BY MasterLabel
		                ]);
	}

	/**
	 * Retrieves all postal codes related to a specified locality
	 * @param  locality LocalityName developer name
	 * @return          A list of postal codes or an empty list
	 */
	public static List<xALPostalCode> byLocality(String localityName)  {
		return fromList([
		                    SELECT
		                    DeveloperName,
		                    MasterLabel,
		                    Number__c
		                    FROM xAL_PostalCode__mdt
		                    WHERE xAL_Locality__r.DeveloperName = :localityName
		                    ORDER BY MasterLabel
		                ]);
	}

	/**
	 * Retrieves all postal code related to a specified sub administrative area
	 * @param  subAreaName SubAdminitrative area developer name
	 * @return          A list of postal code or an empty list
	 */
	public static List<xALPostalCode> bySubAdministrativeArea(String subAreaName) {
		return fromList([
		                    SELECT
		                    DeveloperName,
		                    MasterLabel,
		                    Number__c
		                    FROM xAL_PostalCode__mdt
		                    WHERE xAL_SubAdministrativeArea__r.DeveloperName = :subAreaName
		                    ORDER BY MasterLabel
		                ]);
	}

	/**
	 * returns a list of class instances from a list of records
	 * @param  records Postal code records
	 * @return
	 */
	private static List<xALPostalCode> fromList(List<xAL_PostalCode__mdt> records) {
		List<xALPostalCode> res = new List<xALPostalCode>();
		for (xAL_PostalCode__mdt record : records) {
			res.add(new xALPostalCode(record));
		}
		return res;
	}

}