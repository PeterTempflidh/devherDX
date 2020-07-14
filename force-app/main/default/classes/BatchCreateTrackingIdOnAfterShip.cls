global class BatchCreateTrackingIdOnAfterShip implements Database.Batchable<sObject>, Database.AllowsCallouts{
    Integration_Config__c intConfig;
     Integer v;
    static List<string> acc;
    Set<string> setOfCountries;

    global BatchCreateTrackingIdOnAfterShip(){
        intConfig = Integration_Config__c.getValues('AfterShip');
        setOfCountries = new Set<string>();
        if(!string.isEmpty(intConfig.Countries__c)){
            setOfCountries.addAll(intConfig.Countries__c.split(','));

        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){           
        return Database.getQueryLocator([select id,Tracking_Number__c,account__c,Shipping_Company__c
                                            from Shipment_Order__c
                                            where Tracking_Number__c!=null
                                                and Shipping_Company__c !=null
                                            	and Aftership_ID__c=null
                                            	and  status__c='Shipped'
                                            	and tracking_active__c=false
                                                and Account__r.Record_Country__c IN : setOfCountries
                                        ]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Shipment_Order__c> shippingOrderLst  			    = (List<Shipment_Order__c>)scope;
        acc 										= new List<String>();
        Map<String,List<Shipment_Order__c>>	trackingNumberVsShippingOrderMap 	= new Map<String,List<Shipment_Order__c>>(); // Map of tracking number vs the list of assets
        Set<String> trackingNumbers								= new Set<String>();
        List<Shipment_Order__c> shpOrdersToBeUpdated						= new List<Shipment_Order__c>();
        
        // Populate tracking numbers set
        for(Shipment_Order__c so : shippingOrderLst){
        	trackingNumbers.add(so.Tracking_number__c);
        }
        
        // populate the tracking number vs the shipping orders map
        trackingNumberVsShippingOrderMap = populateTrackingNumberVsShippingOrdersMap(trackingNumbers);

    	if(trackingNumberVsShippingOrderMap.isEmpty())
    		return;
    	
    	// fetch the account map with contacts and addresses	
    	Map<id,Account> accContactLst = fetchAccountMap(acc);	
		
		// make callout for each individual tracking number one by one
		for(String trackingNumber : trackingNumberVsShippingOrderMap.keySet()){
            Shipment_Order__c so		= trackingNumberVsShippingOrderMap.get(trackingNumber)[0];
            Account a 			= accContactLst.get(so.account__c);
            String body			= populateRequestBody(so,a);
			string logName 		= 'aftershipIdUpdate'+so.Id;

            try{
				HttpResponse res	= makeCallout(intConfig,body,so.id,logName);
                parseResponse(res,trackingNumber,trackingNumberVsShippingOrderMap,shpOrdersToBeUpdated,logName);
            }catch(Exception e){
            	LoggingUtility.logError(logName,'Error ' + e.getMessage());
                system.debug(e.getMessage());
            }
		}
		
		// update the assets
		if(shpOrdersToBeUpdated.size() > 0)
			update shpOrdersToBeUpdated;
		LoggingUtility.commitLogs();

    }
    
    
     global void finish(Database.BatchableContext BC){ 
          
     }

	 private static Map<String,List<Shipment_Order__c>> populateTrackingNumberVsshippingOrdersMap(Set<String> trackingNumbers){
	 	Map<String,List<Shipment_Order__c>>	trackingNumberVsShipmentsMap 	= new Map<String,List<Shipment_Order__c>>();
	 	List<Shipment_Order__c> shipmentOrders = ShipmentOrderSelector.getShipmentOrderbyTracking (trackingNumbers);
    	
    	// populate the tracking number vs the list of assets map
    	for(Shipment_Order__c so : shipmentOrders){
    		if(!trackingNumberVsShipmentsMap.containsKey(so.tracking_number__c)){
                trackingNumberVsShipmentsMap.put(so.tracking_number__c,new List<Shipment_Order__c>());
    		}
            trackingNumberVsShipmentsMap.get(so.tracking_number__c).add(so);
            acc.add(so.Account__c); //SSC-1617
    	}
    	
    	return trackingNumberVsShipmentsMap;
	 }
	 
	 private static Map<Id,Account> fetchAccountMap(List<String> accIds){
	 	 Map<id,Account> accContactLst = new Map<id,account>([select id,
                                                                    (select id,
                                                                            phone,
                                                                            email,
                                                                            name,
                                                                            mobilePhone
                                                                            from contacts
                                                                            where contact_role__c='Owner'),
                                                                    (select id,
                                                                            GPA_Country_long_name__c,
                                                                            GPA_Postal_code_long_name__c
                                                                            from AddressDetails__r
                                                                            where Type__c INCLUDES ('Shipping Address'))
                                                                from account
                                                                where id in :accIds ]);
		
		return accContactLst;
	 }
	 
	 private static String populateRequestBody(Shipment_Order__c so,Account a){
	 	String cEmail 	='';
        String cPhone 	= '';
        String cName	='';
        String postCode ='';
        String country 	= '';
        
        String body		= '{"tracking": {' +
                        		+' "tracking_number":'+ ' "'+so.Tracking_Number__c +'",';
	 body += '"slug":"'+so.Shipping_Company__c+'"';

        for(Contact cn: a.contacts){
            if(cn.mobilePhone!=null)
                cPhone+='"'+cn.mobilePhone+'",';
            if(cn.email!=null )
                cEmail+='"'+cn.email+'",';
            cName=cn.name;
        }
        for(AddressDetail__c addr:a.AddressDetails__r ){
            if(addr.GPA_Postal_code_long_name__c!=null)
                postCode=addr.GPA_Postal_code_long_name__c;
            if(addr.GPA_Country_long_name__c!=null)
                Country=addr.GPA_Country_long_name__c;
        }

        if(cEmail!=null && cEmail!='')
        	body+=',"emails" :['+cemail.removeEndIgnorecase(',')+']';
        if(cPhone!=null && cPhone!='')
        	body+=',"smses" :['+cPhone.removeEndIgnorecase(',')+']';
        if(Country!=null && Country!='')
        	body+=',"tracking_postal_code":'+'"'+postCode+'"';
        if(postCode!=null && postCode!='')
        	body+=',"tracking_destination_country":'+'"'+country+'"';
        
        body +=',"customer_name" :'+'"'+cName+'"';
        body +='}}';
        
        return body;
	 }
	 
	 private static HttpResponse makeCallout(Integration_Config__c intConfig,String body,String assetId,String logName){
	 	Loggingutility.createLog(logName,'AFTERSHIP','ID_UPDATE',assetId);
        LoggingUtility.log(logName,'Body => ' + body);
	 	HttpResponse res 	= new HttpResponse();
	 	HttpRequest req 	= new HttpRequest();
        Http http 			= new Http();
        
	 	req.setEndpoint(intConfig.EndPoint__c+'trackings');
        req.setMethod('POST');
        req.setHeader('aftership-api-key',intConfig.AuthenticationToken__c);
        req.setHeader('Content-Type','application/json');
        req.setBody(body);
        LoggingUtility.captureTimeStamp(logName,'BEGIN');
        res = http.send(req);
        LoggingUtility.captureTimeStamp(logName,'END');
        LoggingUtility.log(logName,'\nResponse status : ' + res.getStatusCode() + '\nResponse => ' + res.getBody());
        return res;
	 }
	 
	 private static void parseResponse(HttpResponse res,String trackingNumber,
	 									Map<String,List<Shipment_Order__c>> trackingNumberVsAssetsMap,List<Shipment_Order__c> assetsToBeUpdated,
	 									String logName){
	 	
	 	if(res.getStatusCode()!=201  )
	 		return;
	 	
        system.debug(res.getBody());
        JSONParser parser = JSON.createParser(res.getBody());
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'tracking') {
                system.debug(parser.getCurrentName());
                while (parser.nextToken() != null) {
                    system.debug(parser.getText());
                    ClsRestAssetUpdAfterShip.Tracker trk=  (ClsRestAssetUpdAfterShip.Tracker)parser.readValueAs(ClsRestAssetUpdAfterShip.Tracker.class);
                    system.debug(trk);
                    if(trk!=null){
                    	LoggingUtility.log(logName,'\nNumber of assets ' + trackingNumberVsAssetsMap.get(trackingNumber).size());
                    	// update the after ship Id on all the assets having same tracking number
                    	for(Shipment_Order__c so : trackingNumberVsAssetsMap.get(trackingNumber)){
                    		so.Aftership_ID__c			= trk.id;
                            so.status__c 				= trk.tag;
                            so.Last_Tracking_Update__c	= trk.updated_at;
                            if(trk.tag=='Exception'){
                               for(ClsRestAssetUpdAfterShip.CheckPoint ch:trk.checkpoints){
                                    if(ch.tag=='Exception'){
                                        so.Tracking_Exception__c=ch.message;
                                        so.tracking_active__c=false;
                                    }
                                }
                            }else{
                                so.tracking_active__c=true;
                            }
                            assetsToBeUpdated.add(so);
                    	}
                        break;
                    }
            	}
        	}
    	}    
        	
	 }
}
