/**
* @Description: This class is a utility class for connecting to Data fridge. This performs the following operations
				1. Fetch the order details based on the order id
				2. Fetch the order aggregate details for a customer based on the customer id and time duration
*/
public without sharing class DataFridgeUtility {

    /**
    * @Description: This method fetches the order details from the Data fridge based on the order Id
    		@inputparams: OrderId: Order Id, entity Id: entity to which the order belongs (e.g LH_DE)
    */
    public static HttpRequest fetchOrderDetails(String orderId,String country, String platform){
    	String uri = '/' +orderId; // add the order Id
    	return makeCalloutToDataFridge(platform,country,uri);
    }
    
    /**
    * @Description: This method fetches all the orders and their statuses based on the customer id
    	@InputParam: customerId: Id of the customer,entity Id: entity to which the order belongs (e.g LH_DE)
    */
    public static HttpRequest fetchOrderAggregateDetails(String customerId,String country, String platform){
    	Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    	Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('ChatBotConfigs');
    	Map<String, Business_Config__c> mapBusinessRules 				= mapBusinessLogic.get('Global_Config');
    	
    	Integer startDateMonths	= Integer.valueOf(mapBusinessRules.get('startDateMonths').Business_Rule_Value__c);
    	
    	String startDate	= getFormattedDate(Date.today().addMonths(-startDateMonths));
    	String endDate		= getFormattedDate(Date.today().addDays(1));

    	// Set from and to date and customer id
    	String uri =  '?from='+startDate + '&to=' + endDate + '&customer_id=' + customerId;

        return makeCalloutToDataFridge(platform,country,uri);
    }

    public static HttpRequest makeCalloutToDataFridge(String platform,String country, String uri){
		String platformEntityString;
		if(country!=null && country!=''){
			platformEntityString=platform+'_'+country;
		}
		else{
			platformEntityString=platform;
		}
    	Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    	Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('ChatBotConfigs');
    	Map<String, Business_Config__c> mapBusinessRules 				= mapBusinessLogic.get('Global_Config');
    	Map<String,String> entityMap	= 
    			(Map<String,String>)JSON.deserialize(mapBusinessRules.get('platformEntityMapping').Business_Rule_Value__c,Map<String, String>.class);
    	
    	Integration_Config__c integrationConfigs = Integration_Config__c.getValues('DataFridgeOrderDetails');
    	String endpoint 	= integrationConfigs.endpoint__c + uri;
    	String authToken	= integrationConfigs.AuthenticationToken__c + integrationConfigs.AuthTokenExtension__c; 
    	Integer timeout		= Integer.valueOf(integrationConfigs.timeout__c);
    	
    	endpoint = endpoint.replaceAll('@ENTITY_ID',entityMap.get(platformEntityString));
    	HttpRequest req = new HttpRequest();
    	req.setHeader('Authorization',authToken);
    	req.setHeader('Content-Type','application/json');
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        req.setTimeout(timeout);
        return req;
    }
    
    /**
    * @Description: This method returns the date in YYYY-MM-DD format
    */
    public static String getFormattedDate(Date dt){
    	Datetime newDate = DateTime.newInstance(dt.year(),dt.month(),dt.day());
    	return newDate.format('YYYY-MM-dd');
    }
    
    public class DataFridgeException extends Exception{}
}