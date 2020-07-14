public with sharing class xALLocality {

    public String label { get; set; }
    public String developerName { get; set; }
    public String type { get; set; }
    public String code { get; set; }
    public String parentLocality { get; set; }
    public xALLocality dependentLocality { get; set; }
    public xALPostalCode postalCode { get; set; }
    public List<xALLocality> dependentLocalities { get; set; }
    public List<xALPostalCode> postalCodes { get; set; }

    private xALLocality(xAL_Locality__mdt locality, Boolean deepLoad) {
        label = locality.MasterLabel;
        developerName = locality.DeveloperName;
        type = locality.Type__c;
        code = locality.Code__c;
        if (deepLoad) {
            parentLocality = locality.xAL_ParentLocality__c;
            dependentLocalities = byParentLocality(developerName);
            postalCodes = xALPostalCode.byLocality(developerName);
        }
    }

    public xALLocality() {}

	/**
	 * Retrieves specified locality record
	 * @param  developerName Locality developer name
	 * @return
	 */
    public static xALLocality byName(String developerName) {
        return new xALLocality([
                SELECT
                        DeveloperName,
                        MasterLabel,
                        Code__c,
                        Type__c,
                        xAL_ParentLocality__c
                FROM xAL_Locality__mdt
                WHERE DeveloperName = :developerName
                LIMIT 1
        ], true);
    }

	/**
	 * Retrieves a list of localities related to a specified Administrative Area
	 * @param  areaName Administrative Area developer name
	 * @return          A list of localities or an empty list
	 */
    public static List<xALLocality> byAdministrativeArea(String areaName) {
        return fromList([
                SELECT
                        DeveloperName,
                        MasterLabel,
                        Code__c,
                        Type__c,
                        xAL_ParentLocality__c
                FROM xAL_Locality__mdt
                WHERE xAL_AdministrativeArea__r.DeveloperName = :areaName
                ORDER BY MasterLabel
        ]);
    }

	/**
	 * Retrieves a list of localities related to a specified sub-administrative area
	 * @param  subAreaName SubAdministrative area developer name
	 * @return             A list of localities or an empty list
	 */

    public static List<xALLocality> bySubAdministrativeArea(String subAreaName) {
        return fromList([
                SELECT
                        DeveloperName,
                        MasterLabel,
                        Code__c,
                        Type__c,
                        xAL_ParentLocality__c
                FROM xAL_Locality__mdt
                WHERE xAL_SubAdministrativeArea__r.DeveloperName = :subAreaName
                ORDER BY MasterLabel
        ]);
    }

	/**
	 * Returns a list of dependent localities
	 * @param  locality Parent locality developer name
	 * @return              A list of localities or an empty list
	 */
    public static List<xALLocality> byParentLocality(String locality) {
        return fromList([
                SELECT
                        DeveloperName,
                        MasterLabel,
                        Code__c,
                        Type__c,
                        xAL_ParentLocality__c
                FROM xAL_Locality__mdt
                WHERE xAL_ParentLocality__c = :locality
                ORDER BY MasterLabel
        ]);
    }

    /**
     * Retrieves a list of localities (neighbourhood) related to a specified sub-administrative area
     * @param  subAreaName SubAdministrative area label
     * @return             A list of localities(neighbourhood) or an empty list
     */

    public static List<xALLocality> bySubAdministrativeAreaLabel(String subAreaName) {
        return fromList([
                SELECT
                        DeveloperName,
                        MasterLabel,
                        Code__c,
                        Type__c,
                        xAL_ParentLocality__c
                FROM xAL_Locality__mdt
                WHERE xAL_SubAdministrativeArea__r.MasterLabel = :subAreaName
                ORDER BY MasterLabel
        ]);
    }

    private static List<xALLocality> fromList(List<xAL_Locality__mdt> records) {
        List<xALLocality> res = new List<xALLocality>();
        for (xAL_Locality__mdt locality : records) {
            res.add(new xALLocality(locality, false));
        }
        return res;
    }
}