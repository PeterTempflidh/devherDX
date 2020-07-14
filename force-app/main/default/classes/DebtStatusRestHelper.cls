
/**
 @Description: This is the helper with the funticions for update the debt status from the rest service
*/

global with sharing class DebtStatusRestHelper {
    /**
     @Description: Wrapper for the request
    */
    global class RequestWrapper{
        private String recordTypeName;
        private String countryName;
        private List<debtInformationWrapper> debtInformation;
    }
    /**
     @Description: Wrapepr for the response
    */
    global class ResponseWrapper{
        @TestVisible
        private String status;
        @TestVisible
        private List<errorWrapper> errors;
    }
    /**
    * @author William Castillo
    * @date 30-APR-20
    * @description This method tranform an string json to a request wrapper
    * @param  String json
    * @return RequestWrapper
    */
    global static RequestWrapper parseRequest(String json){
        return (RequestWrapper) System.JSON.deserialize(json, RequestWrapper.class);
    }

    /**
    * @author William Castillo
    * @date 30-APR-20
    * @description This method Serialize into a json a ResponseWrapper
    * @param  ResponseWrapper response
    * @return String
    */
    global static String serializeResponse(ResponseWrapper response){
        return System.JSON.serialize(response);
    }
    /**
     @Description: DebtInformation Wrapper
    */
    public class DebtInformationWrapper {
        private String contractSAP;
        private double debtValue;
        private integer numberPendingInvoices;
    }

    /**
     @Description: DebtInformation Wrapper
    */
    public class ErrorWrapper {
        private DebtInformationWrapper debtInformation;
        private String description;
        private errorWrapper (String description, DebtInformationWrapper debtInformation) {
            this.description = description;
            this.debtInformation = debtInformation;
        }
    }

    /**
    * @author William Castillo
    * @date 30-APR-20
    * @description This method get the request, check the platforms related with the contracts in the request and update
    *              the platform performance, the result of the update it will be return like a response of the restService
    * @param  RequestWrapper request
    * @return ResponseWrapper
    */

    global static ResponseWrapper processRequest (RequestWrapper request) {
        ResponseWrapper response = new ResponseWrapper();
        response.status = 'SUCCESS';
        response.errors = new List<errorWrapper>();
        LoggingUtility.createLog('SAP-DEBT_STATUS','DEBT_STATUS','',null);
        LoggingUtility.log('SAP-DEBT_STATUS','Request Body: ' +request);

        if(request == null || request.debtInformation == null ){
            return response;
        }
        map<String,DebtInformationWrapper> mpDebInformationByContract = new map<String,DebtInformationWrapper>();
        for(DebtInformationWrapper debt: request.debtInformation){
            mpDebInformationByContract.put(debt.contractSAP,debt);
        }

        List<Platform_Performance__c> lstPlatformPerformacesWithContract = new List<Platform_Performance__c>();

        lstPlatformPerformacesWithContract =PlatformPerformanceSelector.getPlatformPerformancesByContracts(mpDebInformationByContract.keySet(),request.countryName, request.recordTypeName) ;

        map<String,DebtInformationWrapper> mpDebInformationById = new map<String,DebtInformationWrapper>();

        for(Platform_Performance__c platformPerformance:lstPlatformPerformacesWithContract){
            platformPerformance.Debt_Value__c = mpDebInformationByContract.get(platformPerformance.Contract_Number_SAP__c).debtValue;
            platformPerformance.Number_Pending_Invoices__c = mpDebInformationByContract.get(platformPerformance.Contract_Number_SAP__c).numberPendingInvoices;
            mpDebInformationById.put(platformPerformance.id,mpDebInformationByContract.get(platformPerformance.Contract_Number_SAP__c));
        }

        List<Database.SaveResult> resultsUpdatePlatformPerformance = Database.update(lstPlatformPerformacesWithContract,false);

        Integer position = 0;
        for(Database.SaveResult saveResult: resultsUpdatePlatformPerformance){
            if(!saveResult.isSuccess()){
                response.status = 'FAIL';
                response.errors.add(new errorWrapper (String.valueOf(saveResult.getErrors()), mpDebInformationById.get(lstPlatformPerformacesWithContract[position].id)) );
            }
            position++;
        }

        if(response.status == 'FAIL'){
            LoggingUtility.logError('SAP-DEBT_STATUS',String.valueOf(response.errors));
        }

        LoggingUtility.captureTimeStamp('SAP-DEBT_STATUS','End');
        LoggingUtility.commitLogs();
        return response;
    }
}