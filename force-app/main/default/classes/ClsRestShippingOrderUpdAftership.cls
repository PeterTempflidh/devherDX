/**
 * Used in Aftership webhook to update the status of shipping order.
 */
@RestResource(urlMapping='/UpdateShippingStatus/*')
global with sharing class ClsRestShippingOrderUpdAftership{
    public static String logName = 'ShipmentStatusUpdate';

    @HttpPost
    global static void  updateShippingStatus() {
        LoggingUtility.createLog(logName,'AFTERSHIP','STATUS_UPDATE',null);
        RestRequest res 	= RestContext.request;
        String resp 		= res.requestBody.tostring();
        LoggingUtility.log(logName,'Request Body => '+ resp);
        JSONParser resJSON 	= JSON.createParser(resp);
        parseAftershipGetResponse(resJSON);
        LoggingUtility.commitLogs();

    }

    public static void parseAftershipGetResponse(JSONParser parser ){
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'msg') {
                system.debug(parser.getCurrentName());
                while (parser.nextToken() != null) {
                    Tracker tc=  (Tracker)parser.readValueAs(Tracker.class);
                    updateInfoOnShipment(tc);
                    break;
                }
            }
        }

    }


    public static void updateInfoOnShipment(Tracker tc){


        if(tc.tracking_number == null || tc.tracking_number == '')
            return;

        List<Shipment_Order__c> shipmentOrders = ShipmentOrderSelector.getShipmentOrderActivebyTracking(tc.tracking_number,tc.id) ;

        if(shipmentOrders.size() == 0)
            return;

        for(Shipment_Order__c so : shipmentOrders){
            if(tc.tag=='Exception'){
                system.debug(tc.checkpoints);
                for(CheckPoint ch:tc.checkpoints){
                    if(ch.tag=='Exception'){
                        so.Tracking_Exception__c=ch.message;
                        so.tracking_active__c=false;

                    }
                }
            }
            so.status__c=tc.tag;
            if(tc.tag=='Delivered')
                so.tracking_active__c=false;

            if(tc.updated_at!=null)
                so.Last_Tracking_Update__c=tc.updated_at;
            if(so.Date_Shipped__c==null && tc.tracking_ship_date!=null)
                so.Date_Shipped__c=tc.tracking_ship_date;
        }
        try{
            update shipmentOrders;
        }catch (Exception e){
            LoggingUtility.logError(logName,'Error => ' + e.getMessage() + '\nLine Number : ' + e.getLineNumber());
        }


    }

    public class Tracker{
        public String id;
        public String tracking_number;
        public String expected_delivery;
        public Date tracking_ship_date;
        public String tag;
        public Datetime updated_at;
        public List<CheckPoint> checkpoints;

    }

    public class CheckPoint{
        public String message;
        public String tag;


    }
}