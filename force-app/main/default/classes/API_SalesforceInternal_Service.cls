/* Created By: Preeti Bansal
 * Description: Call Salesforce Rest APIs for DMLs on set up object
 * Created Date: 03-Jan-2020
 */
public with sharing class API_SalesforceInternal_Service {
   
    /* @desc: Delete sobject(s) records 
       @param: accepts List of recordIds in form of comma separated string
       @return: String of status and records list.
    */
     public static String deleteRecords(String pRecIds, String endPoint){ 
              
         HttpResponse res ;
         List<Database.DeleteResult> delRes = new List<Database.DeleteResult>(); 
         IF(!String.isEmpty(pRecIds)){          
             HttpRequest req = new HttpRequest();          
             String endpnt = endPoint+'?ids='+pRecIds  ;          
             req.setEndpoint(endpnt);          
             req.setMethod('DELETE');       
             Http h = new Http();
             res = h.send(req);
             IF(res.getStatusCode() == 200){
               delRes =  (List<Database.DeleteResult >)System.JSON.deserialize(res.getBody(), List<Database.DeleteResult>.class);
            }ELSE{
               Loggingutility.createLog('API_SalesforceInternal_Service','deleteRecords','','');
               LoggingUtility.log('API_SalesforceInternal_Service','\nResponse status : ' + res.getStatusCode() + '\nResponse => ' + res.getBody());
               LoggingUtility.commitLogs();
            }  

        }
       
       IF(!delRes.isEmpty()){	return String.valueOf(res.getStatusCode())+'--'+JSON.serialize(delRes); } 
       return String.valueOf(res.getStatusCode())+'--'+JSON.serialize(res.getBody());
     }
     
    
    /* @desc: Create sobject(s) records using SF Rest request composite end point
       @param: accepts Json request, end point, content type
       @return: String in form of Map of string and List of records, (Success, null), (Partial Success, List of failed record), (Failed, all records)
    */
    public static String createRecords(String pJsonStr, String endPoint, String contentType, String method){
        
        List<Database.SaveResult> saveRes = new List<Database.SaveResult>();
        HttpRequest req = new HttpRequest();      
        req.setHeader('Content-Type', contentType);      
        req.setEndpoint(endPoint);      
        req.setBody(pJsonStr);
        req.setMethod(method);
        Http h = new Http();
        HttpResponse res = h.send(req);
        
        IF(res.getStatusCode() == 200){
          saveRes =  (List<Database.SaveResult>)System.JSON.deserialize(res.getBody(), List<Database.SaveResult>.class);
        }ELSE{
              Loggingutility.createLog('API_SalesforceInternal_Service','createRecords','','');
              LoggingUtility.log('API_SalesforceInternal_Service','\nResponse status : ' + res.getStatusCode() + '\nResponse => ' + res.getBody());
              LoggingUtility.commitLogs();
        }
       IF(!saveRes.isEmpty()){     return String.valueOf(res.getStatusCode())+'--'+JSON.serialize(saveRes);}  
       return String.valueOf(res.getStatusCode())+'--'+JSON.serialize(res.getBody());
     
     }
}
