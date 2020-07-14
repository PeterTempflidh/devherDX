/* Created By: Preeti Bansal
 * Description: Helper class to Call Salesforce Rest APIs for DMLs on special objects from API_SalesforceInternalController
 * Created Date: 03-Jan-2020
 */

public with sharing class API_SalesforceInternal_Utils {
    public static Map<String,String> apiConstVals = new Map<String,String>();
    
    public static String callDeleteRecords(List<Id> pRecIds, String pEndPoint){
		apiConstVals = CustomMetadataSelector.getAPIConstanst(CustomPresenceConfig_LWCController.namesList) ;   
        IF(pRecIds.isEmpty() && !apiConstVals.isEmpty() && apiConstVals.containsKey('API_noRecsReceived')){   return apiConstVals.get('API_noRecsReceived') ;}        
        Set<Id> listOfIds = new Set<Id>(pRecIds);
        String strRecIds = !pRecIds.isEmpty()?String.join(new List<Id>(listOfIds),','):'';
        String resultString = '';
        IF(!String.isEmpty(strRecIds)){
            resultString = API_SalesforceInternal_Service.deleteRecords(strRecIds, pEndPoint);
        }
        return  resultString;
    }

	 /* 
       @param: list of records,do all or none boolean, endpoint, content type, HTTP method
       @return: String of status and records list.
    */
    public static String callCreateRecords(List<sObject> pSobjRecs, Boolean pAllOrNone, String pEndPoint, String pContentType, String pMethod){
        apiConstVals = CustomMetadataSelector.getAPIConstanst(CustomPresenceConfig_LWCController.namesList) ;   
        IF(pSobjRecs.isEmpty() && !apiConstVals.isEmpty() && apiConstVals.containsKey('API_noRecsReceived')){   apiConstVals.get('API_noRecsReceived') ;}

        apiRequestParams obj = new apiRequestParams();
        obj.records = pSobjRecs;
        obj.allOrNone = pAllOrNone ;
        String jsonStr = JSON.serialize(obj);
        String resultString = JSON.serialize(obj);
        IF(!String.isEmpty(jsonStr)){
            resultString = API_SalesforceInternal_Service.createRecords(jsonStr, pEndPoint, pContentType, pMethod);
        }
        return resultString;
        }   
    
    /* Wrapper for json request */    
    public class apiRequestParams{
        public List<Sobject> records = new List<Sobject>();
        public Boolean allOrNone ;      
    }
}
