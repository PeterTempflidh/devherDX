/**
* @author Chaitali Kumari
* @date 29.05.2019
*
* @description Selector class to retrieve OrgWideEmailAddress to use in apex email templates
*/
public with sharing class OrgWideEmailAddressSelector {

    /*******************************************************************************************************
    * @description Query for OrgWideEmailAddress based on Email Address.
    * @param keys Email address
    * @return Respective OrgWideEmailAddress Id
    */

    public static List<OrgWideEmailAddress> getOrgWideEmailAddressId (final string paramEmailAddress) {
        OrgWideEmailAddress[] owea;
        try {
            owea = [select Id from OrgWideEmailAddress where Address =:paramEmailAddress];
        } catch (QueryException e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return owea;
    } 

    /*******************************************************************************************************
    * @description Query for all OrgWideEmailAddress records
    * @return List of OrgWideEmailAddress records
    */ 

    public static List<OrgWideEmailAddress> getOrgWideEmailAddresses() {
        
        OrgWideEmailAddress[] owea;
         try {
            owea = [select id, Address from OrgWideEmailAddress];
        } catch (QueryException e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return owea;
    } 

}