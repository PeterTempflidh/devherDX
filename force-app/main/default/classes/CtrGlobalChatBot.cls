global without sharing class CtrGlobalChatBot {
	global static String requestLabel;
	global static ResponseWrapper responseWrap = new ResponseWrapper();
	private static Map<String, Map<String,Map<String,Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;

	/**
    * @description: This method fetches the case details from the chat record
    * @param: String objrecId: CaseId/ChatId to get case info.
    * @return: String key value pair of field values for case
	*/
	@AuraEnabled
	global static String getCaseFromChat(String objrecId) {
		return CaseControllerLightning.getCaseFromChat(objrecId);
	}
	/**
    * @description: This method fetches the order details based on the order id and the entity id
    * @param: order number, platform, country
    * @return: Continuation Object
	*/
	@AuraEnabled(continuation=true)
    global static Object fetchOrder(String orderId,String platform,String country){
		HttpRequest req=DataFridgeUtility.fetchOrderDetails(orderId,country,platform);
		Continuation con = new Continuation(40);
		con.continuationMethod='processResponse';
		requestLabel=con.addHttpRequest(req);
		con.state='DF Response';
		return con;
    }

    /**
    * @description: This method fetches the order history based on the customer id and the entity id
    * @param: customer id (from datafridge), platform, country
    * @return: Continuation Object
	*/
	@AuraEnabled(continuation=true)
    global static Object fetchOrderHistory(String customerId,String platform,String country){
		HttpRequest req=DataFridgeUtility.fetchOrderAggregateDetails(customerId,country,platform);
		Continuation con = new Continuation(40);
		con.continuationMethod='processResponse';
		con.state='DF Response';
		requestLabel=con.addHttpRequest(req);
		con.addHttpRequest(req);
		return con;
    }

    /**
    * @description: This method fetches the restaurant data based on the vendor id (backendId) and the entity id
    * @param: vendorId from datafridge, platform
    * @return: ResponseWrapper
    */
	@AuraEnabled
    global static ResponseWrapper fetchRestaurantDetails(String vendorId,String platform){

	        List<Platform_Performance__c> platforms = [SELECT id,Account__c
														FROM Platform_Performance__c
														WHERE Backend_Id__c =: vendorId
															AND Platform__c =: platform];

			platform = platform.replaceAll('[^a-zA-Z0-9]', '_');
			DataFridgeEntityIdMapping__mdt metaData = [SELECT Account_Record_Type__c
														FROM DataFridgeEntityIdMapping__mdt
														WHERE QualifiedApiName =: platform];

			String accountId;
			if(platforms.size() > 0){
				accountId = platforms[0].account__c;
			}

			if(accountId != null){
				Account acc = [SELECT Id,Name,Restaurant_Name__c,Account_Email__c,phone,backend_id__c,GRID__c
								FROM Account
								WHERE id =: accountId];
				return new ResponseWrapper(acc);
			}


			List<Account> accounts = [SELECT Id,Name,Restaurant_Name__c,Account_Email__c,phone,backend_id__c,GRID__c
										FROM Account
										WHERE backend_id__c =: vendorId
										 AND recordType.developerName =: metaData.Account_Record_type__c];

			if(accounts.size() > 0){
				return new ResponseWrapper(accounts[0]);
			}

    	return new ResponseWrapper(true,System.Label.No_Account_found_for_the_backend_id + ' ' + vendorId);
    }

	/**
    * @description: Wrapper class for capturing data fridge response
    */
    global class ResponseWrapper{
		@AuraEnabled public Boolean isError;
		@AuraEnabled public String errorMessage;
		@AuraEnabled public String result;
		@AuraEnabled public Account account;
		@AuraEnabled public String voucherToolLink;
		@AuraEnabled public String voucherCountryName;

    	public ResponseWrapper(String result){
    		this.result			= result;
    		this.isError		= false;
    		this.errorMessage	= '';
    	}

    	public ResponseWrapper(Account account){
    		this.account		= account;
    		this.isError		= false;
    		this.errorMessage	= '';
    	}

    	public ResponseWrapper(Boolean isError,String errorMessage){
    		this.isError		= isError;
    		this.errorMessage	= errorMessage;
    	}

		public ResponseWrapper(){
			this.isError        = false;
			this.errorMessage   = '';
		}
    }

	/**
    * @description: Callback method for the continuation process to make the callout and return the response to the lightning components.
    * @param: continuation request labels, continuation state
    * @return: ResponseWrapper
    */
	@AuraEnabled(cacheable=true)
	global static Object processResponse(List<String> labels, Object state) {
		HttpResponse dFResponse = new HttpResponse();
		dFResponse=Continuation.getResponse(labels[0]);
		if(dFResponse.getStatusCode()==200) {
			responseWrap = new ResponseWrapper(dFResponse.getBody());
		}
		else{
			responseWrap = new ResponseWrapper(true,dFResponse.getBody());
		}
		return responseWrap;
	}

	/**
    * @description: Callback method for the continuation process to make the callout and return the response to the visualforce page.
    * This is used primarily for covering the test cases due to the limitations in the apex testing methods for Continuation class.
    * @return: ResponseWrapper
    */
	@AuraEnabled(cacheable=true)
	global static Object processResponse() {
		HttpResponse dFResponse = new HttpResponse();
		dFResponse=Continuation.getResponse(requestLabel);
		if(dFResponse.getStatusCode()==200) {
			responseWrap = new ResponseWrapper(dFResponse.getBody());
		}
		else{
			responseWrap = new ResponseWrapper(true,dFResponse.getBody());
		}
		return responseWrap;
	}

	/**
    * @description: Fetch Hurrier Links, Order Details & Customer Details for the order details section.
    * @param platform, country, deliveryType(platform delivery/vendor delivery)(from datafridge)
    * @return: Map of links with type of link
    */
	@AuraEnabled
	global static Map<String,String> getLinks(String platform,String country,String deliveryType){
		Map<String,String> linksMap=new Map<String,String>();
		linksMap.put('HurrierDetails','Not Found');
		linksMap.put('OrderDetails','Not Found');
		linksMap.put('CustomerDetails','Not Found');
		Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('ChatBotConfigs');
		Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get('Global_Config');
		if (mapBusinessRules == null) {
			return linksMap;
		}
		try {
			if (deliveryType == 'platform delivery') {
				if (mapBusinessRules.containsKey('hurrierDetails')) {
					linksMap.put('HurrierDetails', CaseControllerLightning.getUrlString('hurrierDetails', mapBusinessRules.get('hurrierDetails').Business_Rule_Value__c, platform, country));
				}
			}
			if (mapBusinessRules.containsKey('orderDetailsLink')) {
				linksMap.put('OrderDetails', CaseControllerLightning.getUrlString('orderDetailsLink', mapBusinessRules.get('orderDetailsLink').Business_Rule_Value__c, platform, country));
			}
			if (mapBusinessRules.containsKey('customerDetailsLink')) {
				linksMap.put('CustomerDetails', CaseControllerLightning.getUrlString('customerDetailsLink', mapBusinessRules.get('customerDetailsLink').Business_Rule_Value__c, platform, country));
			}
		} catch (Exception e) {
			system.debug(e);
		}
		return linksMap;
	}

	/**
     * @description : SCC-40/SCC-376 Moving logic from CaseControllerLightning to CtrGlobalChatBot
     * @param: case recordId and paymentMethod from DF
     * @return - if payment method gets updated successfully, then payment method else 'Failed'
     */
	@AuraEnabled
	global static String updatePaymentMethod(String caseIdString, String paymentMethod) {
		IF(!String.isEmpty(caseIdString)){
			Case cas = new Case(Id=caseIdString,Partial_Refund_Type__c=paymentMethod);
			try {
				Database.SaveResult saveResult = Database.update(cas, true);
				if(saveResult.isSuccess()){
					return paymentMethod;
				} else {
					return 'Failed';
				}
			} catch (Exception ex) {
				system.debug('Exception occurred: '+ex.getMessage());

			}
		}
		return '';
	}

    global class chatBotException extends Exception{}
}
