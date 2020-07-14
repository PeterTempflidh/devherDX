/*
    This class is used as a reusable util class for Lead object
*/
public inherited sharing class LeadSelector {

    /**
	 * Retrieves record type related to specified country and Lead
	 * @param  country name
	 * @return reordTypeId
	 */
    public static String getLeadRecordTypeByCountry(String countryName) {
        List<lead> leadList = new List<Lead>([SELECT RecordTypeId FROM Lead WHERE Country = :countryName LIMIT 1]);
        return !leadList.isEmpty() && String.isNotBlank(leadList[0].RecordTypeId) ? String.valueOf(leadList[0].RecordTypeId) : '';
    }
  

}
