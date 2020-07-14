/*
@author : Alexander Faust
@reviewer : 
@creation : 05.12.2014
*/
public with sharing class LibWebserviceHelper {
    public static string createBillingAuthenticationHeader(String requestMethod,String URI,String JSONMessage){
        String username = 'qa-test';
        String secret = 'u2i7l94apfrrkzjo2lq990u74lp896rk5cgvwd7zdq';
        
        String requestHash = String.valueOf(System.now().getTime() / 1000) + requestMethod + URI + EncodingUtil.convertToHex(Crypto.generateDigest('SHA1',Blob.valueOf(JSONMessage)));
        Blob signatureBlob =Crypto.generateMAC('hmacSHA1',Blob.valueOf(requestHash),Blob.valueOf(secret));
        String signatureString = username+'.'+String.valueOf(System.now().getTime() / 1000)+'.'+EncodingUtil.convertToHex(signatureBlob);
        
        return signatureString;
    }
    
    public static String extractIdFromURI(String param, String param2){
    
    //placeholder for the sake of deployment
        return '';
    }

    public static List<string> createBackendCalloutHeader(string country, string module){
        Integration_Config__c integrationConfigs = Integration_Config__c.getValues(country);            
        String sEndPoint =  integrationConfigs.endpoint__c+module; //'http://staging-hungryhouse.com/api/salesforce/restaurant/add-contact ';
        String sUsername = integrationConfigs.username__c; //'uksfuser';
        String sSecret = integrationConfigs.password__c; //'SFs3cr3tPw';
        Blob headerValue = Blob.valueOf(sUsername + ':' + sSecret );
        String authorizationHeader = 'Basic ' +EncodingUtil.base64Encode(headerValue);
        List<string> reqStringLst = new List<string>();
        reqStringLst.add(sEndPoint); 
        reqStringLst.add(authorizationHeader); 
        return reqStringLst;
        
    }
    public static HttpRequest constructMidasHttpRequest(String module, String ep,String country,String httpMethod,String body){
        System.debug('Module ' + module);
        System.debug('Body ' + body);
        MidasIntegration__c integrationConfigs = MidasIntegration__c.getValues(module);
        if(integrationConfigs!=null){
            String endPoint = integrationConfigs.EndPoint__c ; 
            System.debug('The endpointurl is' + endpoint);
            String authToken = integrationConfigs.AuthenticationToken__c;
            String UserId = integrationConfigs.UserId__c;
            HttpRequest req = new HttpRequest();
            String entityCode = CountryCompanyBrand__c.getValues(country).code__c;
            endpoint+='/v2/sites/'+entityCode+ep;
            req.setHeader('Authorization',authToken);
            req.setEndpoint(endPoint); 
            req.setMethod(httpMethod);
            Integer timeout = integrationConfigs.timeout__c == null ? 10000 : Integer.valueOf(integrationConfigs.timeout__c);
            req.setTimeout(timeout); 
            if(body!=null){
                req.setBody(body); 
                req.setHeader('Content-Type','application/json');
            }
            return req;
        }else{
            return null;
        }
    }
    
    /**
    * @Description: Contructs a request for Booking post codes in MIDAS
    */
    public static HttpRequest constructMidasHttpRequestForBookings(String module,String body){
        System.debug('Module ' + module);
        System.debug('Body ' + body);
        MidasIntegration__c integrationConfigs = MidasIntegration__c.getValues(module);
        if(integrationConfigs!=null){
            String endPoint = integrationConfigs.EndPoint__c ; 
            System.debug('The endpointurl is' + endpoint);
            String authToken = integrationConfigs.AuthenticationToken__c;
            String UserId = integrationConfigs.UserId__c;
            HttpRequest req = new HttpRequest();
            endpoint+='/v2/bookings';
            req.setHeader('Authorization',authToken);
            req.setEndpoint(endPoint);
            req.setMethod('POST');
            Integer timeout = integrationConfigs.timeout__c == null ? 10000 : Integer.valueOf(integrationConfigs.timeout__c);
            req.setTimeout(timeout); 
            if(body!=null){
                req.setBody(body);
                req.setHeader('Content-Type','application/json');
            }
            return req;
        }else{
            return null;
        }
    }
    
    /**
    * @Description: Contructs a request for updating the bookings in MIDAS
    */
    public static HttpRequest constructMidasHttpRequestForBookingsPatch(String module,String body){
        System.debug('Module ' + module);
        System.debug('Body ' + body);
        MidasIntegration__c integrationConfigs = MidasIntegration__c.getValues(module);
        if(integrationConfigs!=null){
            String endPoint = integrationConfigs.EndPoint__c ; 
            System.debug('The endpointurl is' + endpoint);
            String authToken = integrationConfigs.AuthenticationToken__c;
            String UserId = integrationConfigs.UserId__c;
            HttpRequest req = new HttpRequest();
            endpoint+='/v2/bookings';
            req.setHeader('Authorization',authToken);
            req.setEndpoint(endPoint);
            req.setMethod('PUT');
            Integer timeout = integrationConfigs.timeout__c == null ? 10000 : Integer.valueOf(integrationConfigs.timeout__c);
            req.setTimeout(timeout); 
            if(body!=null){
                req.setBody(body);
                req.setHeader('Content-Type','application/json');
            }
            return req;
        }else{
            return null;
        }
    }

    public static HttpRequest constructMidasHttpRequest(String countryCode, String module,String httpMethod,String body){
        MidasIntegration__c integrationConfigs = MidasIntegration__c.getValues(countryCode);
        if(integrationConfigs!=null){
            String endPoint = integrationConfigs.EndPoint__c + module;
            System.debug('The endpointurl is' + endpoint);
            String authToken = integrationConfigs.AuthenticationToken__c;
            String UserId = integrationConfigs.UserId__c;
            HttpRequest req = new HttpRequest();
            if(countryCode == 'Peru' || countryCode == 'Colombia' || countryCode =='Ecuador'){
                endpoint+= '?id='+UserId + '&token=' + authToken; 
            }else{
            	req.setHeader('Authorization',authToken);
                 }
            req.setEndpoint(endPoint);
            req.setMethod(httpMethod);
            Integer timeout = integrationConfigs.timeout__c == null ? 10000 : Integer.valueOf(integrationConfigs.timeout__c);
            req.setTimeout(timeout); 
            if(body!=null){
                req.setBody(body);
                req.setHeader('Content-Type','application/json');
            }
            return req;
        }else{
            return null;
        }
    }

    /******************
     * @description Method to get the access token from Midas
     * @input Param - none
     * @return string token
     */
    public static string constructMidasRequestForAuthentication(string logName){

        string tokenValue;
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Midas_Heimdall?grant_type=client_credentials&scope=sales_force');
        req.setMethod('POST');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                        (parser.getText() == 'access_token')){
                    parser.nextToken();
                    tokenValue = parser.getText();
                }
            }
        } else {
            LoggingUtility.logError(logName, ' Failed to get access token '  + res.getStatus() + ' Status Code ' + res.getStatusCode());
        }
        return tokenValue;
    }

    /******************
     * @description Method to send list of booking Id to Midas for approval
     * @input Param - opportunity record country
     * @return - HttpRequest record
     */
    public static HttpResponse constructMidasRequestForBookingApproval(String country,List<oppLineItemBookingData> bookData, String logType) {
        try {
            String token = constructMidasRequestForAuthentication(logType);
            return constructMidasRequestForBookingApproval(token, country, bookData, logType);
        } catch(System.CalloutException e) {
            LoggingUtility.logError(logType, ' Failed to approve bookings- ' + e.getMessage());
            LoggingUtility.commitLogs();
        }
        return null;
    }

    /******************
     * @description Method to send list of booking Id to Midas for approval
     * @input Param - opportunity record country
     * @return - HttpRequest record
     */
    public static HttpResponse constructMidasRequestForBookingApproval(String token, String country,List<oppLineItemBookingData> bookData, String logType){
        if(token == null) {
            return null;
        }
        Country_Brand_GlobalEntityId__mdt entityName = byCountryName(country);
        String body = JSON.serialize(bookData);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Midas_Hannibal/sites/'+entityName.DeveloperName+'/bookings/approve');
        req.setMethod('POST');
        req.setBody(body);
        req.setHeader( 'Content-Type', 'application/json' );
        req.setHeader( 'Authorization', 'Bearer ' + token );
        req.setTimeout(60000);
        LoggingUtility.log(logType, '\n{' + country + '}\n' + req.getBody() + '\n');
        Http http = new Http();
        return http.send(req);
    }

    /******************
    * @description Method to send list of booking Id to Midas for Cancellations
    * @input Param - opportunity record country
    * @return - HttpResponse
    */
    public static HttpResponse constructMidasRequestForBookingCancellation(String country,List<oppLineItemBookingData> bookData, String logType){
        try {
            String token = constructMidasRequestForAuthentication(logType);
            return constructMidasRequestForBookingCancellation(token, country, bookData, logType);
        } catch(System.CalloutException e) {
            LoggingUtility.logError(logType, ' Failed to cancel bookings- ' + e.getMessage());
            LoggingUtility.commitLogs();
        }
        return null;
    }

    /******************
    * @description Method to send list of booking Id to Midas for Cancellations
    * @input Param - opportunity record country
    * @return - HttpResponse
    */
    public static HttpResponse constructMidasRequestForBookingCancellation(String token, String country,List<oppLineItemBookingData> bookData, String logType){
        if(token == null) {
            return null;
        }
        Country_Brand_GlobalEntityId__mdt entityName = byCountryName(country);
        String body = JSON.serialize(bookData);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Midas_Hannibal/sites/'+entityName.DeveloperName+'/bookings/cancel');
        req.setMethod('POST');
        req.setBody(body);
        req.setHeader( 'Content-Type', 'application/json' );
        req.setHeader( 'Authorization', 'Bearer ' + token );
        req.setTimeout(60000);
        LoggingUtility.log(logType, '\n{' + country + '}\n' + req.getBody() + '\n');
        Http http = new Http();
        return http.send(req);
    }

    /******************
     * @description Returns the record custom metadata type 'Country_Brand_GlobalEntityId__mdt'
     * @input Param - opportunity record country as string
     * @return - Country_Brand_GlobalEntityId__mdt record
     */
    public static Country_Brand_GlobalEntityId__mdt byCountryName(String countryLabel) {
        Country_Brand_GlobalEntityId__mdt globalEntityname;
        try{
            globalEntityName = [SELECT
                                DeveloperName,
                                MasterLabel,
                                Brand__c,
                                Country__c
                                FROM Country_Brand_GlobalEntityId__mdt
                                WHERE Country__c = :countryLabel LIMIT 1
                            ];
        } catch(QueryException e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return globalEntityName;
    }

    /***Wrapper class to hold booking data**/
    public class oppLineItemBookingData {
        public Integer id;
        public String user;
        public oppLineItemBookingData(Integer bookingId, string userId) {
            this.id = bookingId;
            this.user = userId;
        }
    }

}