/* Created By: Preeti Bansal
 * Description: API related variables or configurations
 * Created Date: 03-Jan-2020
 */

public class CustomMetadataSelector {
    
	/* @desc: Gives Map of names and values
	 * @param: DeveloperName of setting
    */
	
    public static Map<String,String>  getAPIConstanst(Set<String> pNames){
        List<API_SalesforceInternalConstants__mdt> mdt = new List<API_SalesforceInternalConstants__mdt>();
        Map<String,String> mapOfConstNames = new Map<String,String>();
        FOR(API_SalesforceInternalConstants__mdt m : [SELECT DeveloperName,Value__c FROM API_SalesforceInternalConstants__mdt WHERE DeveloperName IN:pNames]){
            mdt.add(m);
            mapOfConstNames.put(m.DeveloperName, m.Value__c);
        }
    
    return mapOfConstNames;
    }

    /* @desc: Platform_Country_Mapping__mdt
     * @param: List<String>: platforms
     */
    public static Map<String,Platform_Country_Mapping__mdt> getPlatformCountryMappings(List<String> platforms){
        Map<String,Platform_Country_Mapping__mdt> platformCountriesMap = new Map<String,Platform_Country_Mapping__mdt>();
        for(Platform_Country_Mapping__mdt platformCountryMapping: [SELECT Id,MasterLabel,Platform__c,Region__c,Countries__c,User_Role_Prefix__c,Profiles_to_skip_validation__c FROM Platform_Country_Mapping__mdt WHERE Platform__c IN :platforms]){
            platformCountriesMap.put(platformCountryMapping.MasterLabel,platformCountryMapping);
        }
        return platformCountriesMap;
    }
}
