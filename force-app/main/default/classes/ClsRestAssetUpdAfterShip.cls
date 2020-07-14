@RestResource(urlMapping='/UpdateAssetStatus/*')
global with sharing class ClsRestAssetUpdAfterShip{
	public static String logName = 'assetStatusUpdate';
	
	@HttpPost	
 	global static void  updateAssetStatus() {
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
                    updateInfoOnAsset(tc);
                    break;
                }
            } 
        }
    }


    public static void updateInfoOnAsset(Tracker tc){
        List<Asset__c> assets = [select id,
	    								status__c, 
	    								tracking_number__c,
	    								Last_Tracking_Update__c,
	    								Date_Shipped__c,
	    								Tracking_Exception__c,
	    								tracking_active__c
									from Asset__c 
									where tracking_active__c = true 
									and tracking_number__c =: tc.tracking_number
									and aftership_id__c =:tc.id];

		if(tc.tracking_number == null || tc.tracking_number == '')
			return;
		
    	if(assets.size() == 0)
    		return;
    		
		for(Asset__c ast : assets){
			if(tc.tag=='Exception'){
	            system.debug(tc.checkpoints);
	            for(CheckPoint ch:tc.checkpoints){
	                if(ch.tag=='Exception'){
	                    ast.Tracking_Exception__c=ch.message;
	                    ast.tracking_active__c=false;
	                          
	                }
	            }
			}
			ast.status__c=tc.tag;
	        if(tc.tag=='Delivered')
	            ast.tracking_active__c=false;
	
	        if(tc.updated_at!=null)
	        	ast.Last_Tracking_Update__c=tc.updated_at;
	        if(ast.Date_Shipped__c==null && tc.tracking_ship_date!=null)
	        	ast.Date_Shipped__c=tc.tracking_ship_date;
		}
    	try{
    		update assets;
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
        //public Datetime shipment_pickup_date;
        public Datetime updated_at;
        public List<CheckPoint> checkpoints;

    }

     public class CheckPoint{
        public String message;
        public String tag;
        

    }
}