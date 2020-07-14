/**
 * Created by c.kumari on 23.04.2019.
 * Description - API to book Premium Placement in Salesforce from external system eg. MIDAS
 * The API accepts only one booking request at one time per restaurant
 */

@RestResource(urlMapping='/BookingService')
global with sharing class BookingService {

    public static string errorMessage = '';
    public static integer errorCode = 500;
    public static boolean isError = false;
    public static Map<String, Map<String, Business_Config__c>> mapProcessData =  LibBusinessConfig.motherOfAllBusinessMaps.get('Booking_Service');
    public static Map<String, Business_Config__c> mapBusinessdata;

    @HttpPost
    global static void processRequestWrapper(){

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        ResponseWrapper resp = new ResponseWrapper();
        String requestBody = req.requestBody.toString();
        try {
            String replaceIllegal = requestBody.replaceAll('\n', '').replaceAll('\r', '').replaceAll('\b', '');
            if (!String.isBlank(requestBody)) { //if the request body is NOT white space, empty ('') or null
                bookingDetails deserializeResults = new bookingDetails(); //requestWrapper object for API response
                deserializeResults = (bookingDetails) JSON.deserializeStrict(replaceIllegal, bookingDetails.class);
                if( mapProcessData != null || !mapProcessData.isEmpty()){
                    mapBusinessdata = mapProcessData.get(deserializeResults.Platform+'_Opportunity');
                    if(mapBusinessdata.containsKey('Enable') && mapBusinessdata.get('Enable').Business_Rule_Value__c == 'True'){
                        BookingServiceHandler.processBookingServiceData(deserializeResults);
                    }else{
                        LoggingUtility.createLog('Booking Service','MIDAS_SELFBOOKING','Status disabled',null);
                        LoggingUtility.log('Booking Service','Request Body: ' +deserializeResults);
                        LoggingUtility.commitLogs();
                    }
                    if (deserializeResults.type == 'Create') {
                        if (!isError) {
                            res.StatusCode = 200;
                            res.responseBody = Blob.valueOf(Label.CreateBooking_Success_Message);
                        } else{
                            res.StatusCode = errorCode;
                            res.responseBody = Blob.valueOf(errorMessage+' '+Label.CreateBooking_Error_Message+ BookingServiceHandler.insertedLogName);
                        }
                    }else if (deserializeResults.type == 'Cancel') {
                        if (!isError) {
                            res.StatusCode = 200;
                            res.responseBody = Blob.valueOf(Label.CancelBooking_Success_Message);
                        } else {
                            res.StatusCode = errorCode;
                            res.responseBody = Blob.valueOf(errorMessage + ' ' + Label.CreateBooking_Error_Message + BookingServiceHandler.insertedLogName);
                        }
                    }
                }else{
                    res.StatusCode = errorCode;
                    res.responseBody = Blob.valueOf(Label.Booking_BusinessConfig_Error);
                }
            }
        }catch(exception e){
            res.StatusCode = 500;
            res.responseBody = Blob.valueOf(String.valueOf(e) + '\n\n' + e.getStackTraceString());
        }
    }

    global class bookingDetails{

        public String restaurantGridId;
        public String Platform;
        public String Country;
        public String Owner;
        public String paymentMethod;
        public String sourceSystem;
        public String type;
        public List<OppLineItem> oppLineItem;
    }

    global class OppLineItem{

        public String productName;
        public String subProductName;
        public String promoAreaName;
        public String promoAreaId;
        public String startDate;
        public String endDate;
        public String restaurantPosition;
        public Double listPrice;
        public String discount;
        public Double totalAmount;
        public String bookingId;
        public Double costPerUnit;
        public Double quantity;
        public String interval;
        public Double budget;

    }

    //To be used at later stage to send Additional Charge Id
    global class ResponseWrapper {
        public String StatusMessage;
    }

    /**
     * @description Exception class for BookingService related exceptions
     */
    public class BookingServiceException extends Exception {}

}
