global class CtrAccountList {
    
    private static String userEmail = UserInfo.getUserEmail();
    private static String userRole = '';

    global CtrAccountList(){
        
    }
   @RemoteAction
    public static List<String> getCountryPerCurrentUser() {
       MidasIntegration__c integrationConfigs = MidasIntegration__c.getValues('PP');
       Map<String,String> countryBrand =(Map<String, String>)JSON.deserialize(integrationConfigs.CountryBrand__c, Map<String, String>.class);
           

        List< String> res = new List<String>();

        User current = [SELECT CountryCode__c FROM User WHERE Id = :UserInfo.getUserId()];
        if (String.isBlank(current.CountryCode__c)) {
            return res; // empty map
        }

        Set<String> isoCodes = new Set<String>(current.CountryCode__c.split(';'));

        // get available counties per current suer
        for (Country__c cnt : [
                    SELECT
                    Name     
                    FROM Country__c
                    WHERE Iso__c IN :isoCodes and Name In :countryBrand.keySet()
                
                ]) {
            res.add(cnt.Name);
        }

        return res;
    }
	
	/**
	* @Description: This method loads the account for multiple platforms using continuation
	*/
	@RemoteAction
	global static Object loadAccountListContinuation(Boolean compleateList,String userRl,String country){
		try{
            userRole = userRl;
            String api = '/restaurants?number_of_leads=30';  //TAJ:31-10-2016  will not work as not supported by API. will always return full list
            if(compleateList){
                api = '/restaurants';
            }
            
            // check for the company codes associated with the Country
            MidasIntegration__c integrationConfigs = MidasIntegration__c.getValues('PP');
            if(integrationConfigs ==  null){
            	return 'Error: MidasIntegration__c is not configured';
            }
            
            
            if(CountryCompanyBrand__c.getValues(country)  == null){
            	return 'Error: CountryCompanyBrand__c setting not present for country ' + country;
            }
            String entityCodes = CountryCompanyBrand__c.getValues(country).code__c;
            
            List<String> codes = entityCodes.split(',');
            List<String> state = new List<String>();
            
            // Create a Continuation for the HTTPRequest        
			Continuation con = new Continuation(60);
			
            for(String code : codes){
            	HttpResponse res = new HttpResponse();      
            	Http http = new Http();    
            	String uri = '/v2/sites/'+code+api;
            	HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest('PP',uri,'GET',null);        
            	state.add(con.addHttpRequest(req));
            }      
	            
            con.state 				= state;
		    con.continuationMethod 	= 'processContinuationResponse';
		    
		    return con;
            
        }catch(System.CalloutException e){
            system.debug('Error: '+e.getMessage());
            return 'Error: '+e.getMessage();
        }
	}
	
	
    @RemoteAction
    global static dataWrapper loadAccountList(Boolean compleateList,String userRl,String country,list<String> nextCodes,List<Restaurant> previousRestaurants){
        String logName = 'loadRestaurants'; 
        try{
        	
        	if(previousRestaurants != null)
        		System.debug(previousRestaurants.size());
        	
        	dataWrapper finalWrapper 	= new dataWrapper();
            userRole 					= userRl;
            String api = '/restaurants?number_of_leads=30';  //TAJ:31-10-2016  will not work as not supported by API. will always return full list
            if(compleateList){
                api = '/restaurants';
            }
            
            // check for the company codes associated with the Country
            MidasIntegration__c integrationConfigs = MidasIntegration__c.getValues('PP');
            if(integrationConfigs ==  null){
            	return setErrorMessage('Error: MidasIntegration__c is not configured');
            	
            }
            
            if(CountryCompanyBrand__c.getValues(country)  == null){
            	return setErrorMessage('Error: CountryCompanyBrand__c setting not present for country ' + country);
            }
            String entityCodes = CountryCompanyBrand__c.getValues(country).code__c;
	        
	        List<String> codes;
	        
	        List<Restaurant> allRestaurants = new List<Restaurant>();
	        if(nextCodes == null || nextCodes.size() == 0){
	        	codes 			= entityCodes.split(',');
	        }else{
	        	codes 			= nextCodes;
	        	allRestaurants	= previousRestaurants;
	        }
           
           	// Process the first code 
            String code = codes[0];  
        	HttpResponse res = new HttpResponse();      
        	Http http = new Http();    
        	String uri = '/v2/sites/'+code+api;
        	HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest('PP',uri,'GET',null);       
        	
        	// Logging
        	LoggingUtility.createLog(logName,'MIDAS','FETCH RESTAURANTS',null);
        	LoggingUtility.log(logName,'URI :'+Uri + '\nType : GET' );
        	if(req!=null){
        		LoggingUtility.captureTimeStamp(logName,'BEGIN');
                res = http.send(req);
                LoggingUtility.captureTimeStamp(logName,'END');
                LoggingUtility.log(logName,'\Response status code : '+res.getStatusCode() + '\nResponse size :' + res.getBody().length());
                if(res.getStatusCode()==200) {
                    DataWrapper wrapper = (DataWrapper)JSON.Deserialize(res.getBody(),dataWrapper.class);
                    allRestaurants.addAll(wrapper.data.restaurants);
                }else{
            		return setErrorMessage('Error: '+res.getStatus()+': '+res.getBody());
                }
            }else{
            	
            }	
            
            // Create a list of remaining codes for the next calls
            if(codes.size() > 1){
            	for(integer i=1;i<codes.size();i++){
            		finalWrapper.nextCodes.add(codes[i]);
            	}
            }else{
            	finalWrapper.nextCodes.clear();
            }
            
            finalWrapper.populateDataWrapper(allRestaurants);
            System.debug('Restaurants size ' + finalWrapper.data.restaurants.size());
            
            LoggingUtility.commitLogs();
            return finalWrapper;
            
        }catch(System.CalloutException e){
        	LoggingUtility.logError(logName,e.getMessage());
        	loggingUtility.commitLogs();
            system.debug('Error: '+e.getMessage());
    		return setErrorMessage('Error: '+e.getMessage());
        }
    }
	
	public static Datawrapper setErrorMessage(String errorMessage){
		Datawrapper finalWrapper 	= new DataWrapper();
		finalWrapper.isError 		= true;
		finalWrapper.errorMessage 	= errorMessage;
		return finalWrapper;
	}
	
    @RemoteAction
    global static String loadPPSlots(String zipcode,String userRl,String begDate,String endDate,String country){
        try{
            userRole = userRl;
            if(!String.isBlank(zipcode)){
                // check for the company codes associated with the Country
	            MidasIntegration__c integrationConfigs = MidasIntegration__c.getValues('PP');
	            if(integrationConfigs ==  null){
	            	return 'Error: MidasIntegration__c is not configured';
	            }

		        if(CountryCompanyBrand__c.getValues(country)  == null){
	            	return 'Error: CountryCompanyBrand__c setting not present for country ' + country;
	            }
	            String entityCodes = CountryCompanyBrand__c.getValues(country).code__c;
		        
	            List<String> codes 				= entityCodes.split(',');
	            dataWrapper finalWrapper 		= new dataWrapper();
	            List<Booking> allbookings 		= new List<Booking>();
	            
	            for(String code : codes){
	            	String api = '/postcodes/'+zipcode+'/bookings?filter_date_begin=' +begDate + '&filter_date_end='+endDate;
	                System.debug('url3' + api);
	                HttpResponse res = new HttpResponse();      
	                Http http = new Http();
	                String uri = '/v2/sites/'+code+api;
	                
            		HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest('PP',uri,'GET',null);
            		
            		if(req!=null){
	                    res = http.send(req);
	                    if(res.getStatusCode()==200) {
	                        DataWrapper wrapper = (DataWrapper)JSON.Deserialize(res.getBody(),dataWrapper.class);
	                    	allBookings.addAll(wrapper.data.bookings);
	                    }else{
	                        return 'Error: '+res.getStatus()+': '+res.getBody();
	                    }
	                }else{
	                    return 'Error: MidasIntegration__c is not configured';
	                }
	            }
	            
	            finalWrapper.populateDataWrapper(allBookings);
            	return JSON.serialize(finalWrapper);
            }else{
               return 'Error: Enter zip code'; 
            }
        }catch(System.CalloutException e){
            system.debug('Error: '+e.getMessage());
            return 'Error: '+e.getMessage();
        }
    }
	
	/**
	* @Description: This method performs callout to MIDAS for fectching the accounts using continuation 
	*/
	@RemoteAction
	global static Object loadPPAccountsConitnuation(String zipcode,String userRl,Boolean compleateList,String dateISO,String country){
		try{
            userRole = userRl;
            if(!String.isBlank(zipCode)){
                
                // check for the company codes associated with the Country
	            MidasIntegration__c integrationConfigs = MidasIntegration__c.getValues('PP');
	            if(integrationConfigs ==  null){
	            	return 'Error: MidasIntegration__c is not configured';
	            }
		        if(CountryCompanyBrand__c.getValues(country)  == null){
	            	return 'Error: CountryCompanyBrand__c setting not present for country ' + country;
	            }
	            String entityCodes = CountryCompanyBrand__c.getValues(country).code__c;
	            List<String> codes = entityCodes.split(','); 
	            List<String> state = new List<String>();
	            
	            // Create a Continuation for the HTTPRequest        
				Continuation con = new Continuation(60); 
				
	            for(String code : codes){
	            	String api = '/postcodes/' + zipcode  + '/restaurants?status_date='+ dateISO;
	                if(compleateList){
	                      api = '/postcodes/' + zipcode  + '/restaurants?status_date='+ dateISO;
	                      System.debug('url2 = ' + api);
	                }
	                String uri = '/v2/sites/'+code+api;
	                
                 	HttpResponse res = new HttpResponse();      
            		Http http = new Http();
            		HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest('PP',uri,'GET',null);
            		
            		
				    state.add(con.addHttpRequest(req));
	            }      
	            
	            con.state 				= state;
			    con.continuationMethod 	= 'processContinuationResponse';
	            
	            // Return it to the system for processing	            
	            return con;
            }else{
               return 'Error: Enter zip code'; 
            }
        }catch(System.CalloutException e){
            system.debug('Error: '+e.getMessage());
            return 'Error: '+e.getMessage();
        }
	}

	/**
	* @Description: This method processes the response received from continuation callout
	*/
	public static Object processContinuationResponse(Object state){
		List<String> labels = (List<String>)state;
		dataWrapper finalWrapper 		= new dataWrapper();
	    List<Restaurant> allRestaurants = new List<Restaurant>();
	    
		for(String label : labels){
			HttpResponse response = Continuation.getResponse(label);
			Integer statusCode = response.getStatusCode();
		    if (statusCode >= 2000) {
		        return 'Continuation error: ' + statusCode;
		    }
			DataWrapper wrapper = (DataWrapper)JSON.Deserialize(response.getBody(),dataWrapper.class);
        	allRestaurants.addAll(wrapper.data.restaurants);			
		}
		
		finalWrapper.populateDataWrapper(allRestaurants);
    	return JSON.serialize(finalWrapper);		
	}

    @RemoteAction
    global static String loadPPAccounts(String zipcode,String userRl,Boolean compleateList,String dateISO,String country){
        try{
            userRole = userRl;
            if(!String.isBlank(zipCode)){
                
                // check for the company codes associated with the Country
	            MidasIntegration__c integrationConfigs = MidasIntegration__c.getValues('PP');
	            if(integrationConfigs ==  null){
	            	return 'Error: MidasIntegration__c is not configured';
	            }
		        if(CountryCompanyBrand__c.getValues(country)  == null){
	            	return 'Error: CountryCompanyBrand__c setting not present for country ' + country;
	            }
	            String entityCodes 				= CountryCompanyBrand__c.getValues(country).code__c;
	            List<String> codes 				= entityCodes.split(',');
	            dataWrapper finalWrapper 		= new dataWrapper();
	            List<Restaurant> allRestaurants = new List<Restaurant>();
	            
	            for(String code : codes){
	            	String api = '/postcodes/' + zipcode  + '/restaurants?status_date='+ dateISO;
	                if(compleateList){
	                      api = '/postcodes/' + zipcode  + '/restaurants?status_date='+ dateISO;
	                      System.debug('url2 = ' + api);
	                }
	                String uri = '/v2/sites/'+code+api;
	                
                 	HttpResponse res = new HttpResponse();      
            		Http http = new Http();
            		HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest('PP',uri,'GET',null);
	                if(req!=null){
	                    res = http.send(req);
	                    if(res.getStatusCode()==200) {
	                        DataWrapper wrapper = (DataWrapper)JSON.Deserialize(res.getBody(),dataWrapper.class);
	                    	allRestaurants.addAll(wrapper.data.restaurants);
	                    }else{
	                        return 'Error: '+res.getStatus()+': '+res.getBody();
	                    }
	                }else{
	                    return 'Error: MidasIntegration__c is not configured';
	                }
	            }      
	            
	            finalWrapper.populateDataWrapper(allRestaurants);
            	return JSON.serialize(finalWrapper);
            }else{
               return 'Error: Enter zip code'; 
            }
        }catch(System.CalloutException e){
            system.debug('Error: '+e.getMessage());
            return 'Error: '+e.getMessage();
        }
    }
    
    @RemoteAction
    global static String createOpportunity(String accountId){

        try{
        // Check whether the account Id is the ID of the account or its the GRID of the account
        List<Account> aclist;
        if(accountId InstanceOf ID){	
        	aclist = [select id,company_code__c, record_country__c  from Account where id=:accountId];
        }else{
        	aclist = [select id,company_code__c, record_country__c  from Account where GRID__c =:accountId];
        }
        
        if(aclist!=null && !aclist.isEmpty()){
			accountId = aclist[0].Id;
            List<Opportunity> opps = [select Id from Opportunity where AccountId=:accountId and name='Premium Placement' and StageName not in ('Closed Won','Closed Lost') limit 1];
            if(!opps.isEmpty()){
                return opps[0].Id;
            }   
            Tarif__c tr = [select id from Tarif__c where Name='Premium Placement' and recordtype.developername=:aclist[0].company_code__c+'_Tarif' and id_country__r.name=:aclist[0].record_country__c limit 1];
            Opportunity opp = new Opportunity(name='Premium Placement',Type='Product Only',business_type__c='Upgrade/Upsell',accountId = accountId,recordtypeId=LibRecordTypeHelper.getRecordTypeValue(aclist[0].company_code__c+'_Opportunity'),Id_Tarif__c=tr.Id,stageName='Verbal Agreement',closeDate=Date.today());
            insert opp;
            return opp.Id;
        }else{
            return 'Error: SF Account id does not exist.';
        }
        }catch(Exception e){
            System.debug('Error: '+e.getMessage());
            return 'Error: '+e.getMessage();
        }
        
    }

    @RemoteAction
    global static String getOppLineItems(String backendId,String bookingId,String country){
        try{
        	List<Opportunity_Line_item__c> lineItems = new List<Opportunity_Line_item__c>();
        	
        	if(backendId!=null && backendId.trim().length()>2){
                lineItems = searchByBackendId(backendId,country);
               
            }else if(bookingId!=null && bookingId.trim().length()>0){
            	lineItems = searchByBookingId(bookingId,country);
            }

            return JSON.serialize(lineItems);
        }catch(Exception e){
            System.debug('error: '+e.getMessage());
            return 'Error: '+e.getMessage();
        }
    }

	/**
	* @Description: This method searched all the line items based on the back end id
	*/
	public static List<Opportunity_Line_item__c> searchByBackendId(String backendId,String country){
		 // Check the backend Ids and grid
         List<String> backendIdsOrGrid 	= new List<String>(); 
		 List<Opportunity_Line_item__c> lineItems = new List<Opportunity_Line_Item__c>();
		 backendIdsOrGrid = backendId.split(',');
        // Fetch the accounts
    	List<Account> accounts = [SELECT Id FROM Account
    								WHERE (Backend_Id__c in: backendIdsOrGrid
    									OR GRID__c in: backendIdsOrGrid)
    									AND record_country__c =: country];
    	
    	// If the size of accounts is zero, it means that we have to fetch the Account from the platform object								
		if(accounts.size() == 0){
			// Fetch all the platforms
			List<Platform_performance__c> platforms = [SELECT Account__c FROM Platform_Performance__c
														WHERE Backend_Id__c in : backendIdsOrGrid];
			Set<String> accountIds = new Set<String>();
			for(Platform_performance__c plat : platforms){
				accountIds.add(plat.account__c);
			}							
			if(accountIds.size() > 0){
				accounts = [SELECT Id FROM Account
    								WHERE Id in: accountIds];
			}
		}
		
		if(accounts.size() > 0){
			lineItems = [SELECT id,Booking_Api_Id__c,Position_fm__c,City_ZipCode__c,Id_Opportunity__c,Id_Opportunity__r.name,
								Id_Opportunity__r.Account.name,Id_Opportunity__r.Account.Grid__c,Id_Opportunity__r.Account.Backend_ID__c,
								Id_Opportunity__r.AccountId,Id_List_Price_Product__r.Company__r.Name 
							FROM Opportunity_Line_Item__c 
							where Id_Opportunity__r.StageName!= 'Closed Won' 
								AND Id_Opportunity__r.StageName!= 'Closed Lost'
								AND Id_Opportunity__r.record_country__c = : country
								AND Booking_Api_Id__c != null
								AND Id_Opportunity__r.AccountId in : accounts];
		}
		
		return lineItems;
	}


	/**
	* @Description: This method searches for the PP opportunity line items based on the booking ids
	*/
	public static List<Opportunity_Line_Item__c> searchByBookingId(String bookingId,String country){
		List<Opportunity_Line_item__c> lineItems 	= new List<Opportunity_Line_Item__c>();
		List<String> bookingIds						= new List<String>();
		bookingIds 									= bookingId.split(',');
		
    	lineItems = [SELECT id,Booking_Api_Id__c,Position_fm__c,City_ZipCode__c,Id_Opportunity__c,Id_Opportunity__r.name,
							Id_Opportunity__r.Account.name,Id_Opportunity__r.Account.Grid__c,Id_Opportunity__r.Account.Backend_ID__c,
							Id_Opportunity__r.AccountId,Id_List_Price_Product__r.Company__r.Name 
						FROM Opportunity_Line_Item__c 
						where Id_Opportunity__r.StageName!= 'Closed Won' 
							AND Id_Opportunity__r.StageName!= 'Closed Lost'
							AND Id_Opportunity__r.record_country__c = : country
							AND Booking_Api_Id__c != null
							AND Booking_Api_Id__c in : bookingIds];
								
		return lineItems;
	}
    @RemoteAction
    global static String cancelBookings(List<Bookings> bookings,String usrRole,String usrEmail,String country,Boolean isCancel){
        if(bookings.isEmpty()){
            return Label.SELECT_BOOKING_ID;
        }
        try{
            userRole 			= usrRole;
            userEmail 			= usrEMail;
            String errorMessage = 'Error occured: ';
            Boolean isError		= false;
            
            String oppId = [select Id_Opportunity__c from Opportunity_Line_Item__c where id =: bookings[0].opplineId limit 1].Id_Opportunity__c;
            
			Map<String,List<Bookings>> companyVsBookingsMap 			= populateBookingMap(bookings);
			Set<String> bookingids										= populateBookingIds(bookings);
			Map<Integer,Opportunity_Quote_Line_Item__c> oppQuoteMap 	= getOppQuoteMap(bookingids,country); 
			List<Opportunity_Line_item__c> lineItemsToBeUpdated 		= new List<Opportunity_Line_item__c>();
			List<Opportunity_Quote_Line_item__c> quoteItemsToBeUpdated 	= new List<Opportunity_Quote_Line_item__c>();
			
			 
			for(String company : companyVsBookingsMap.keySet()){
				String bodyparam 	= ' {"meta": {"username": "'+userEmail+'","sf_role": "'+userRole+'","sf_opportunity_id": "'+oppId+'"},"data": {"bookings": [';
                String arrays 		= '';
                Map<Integer,Opportunity_line_item__c> oppLineMap 	= new Map<Integer,Opportunity_Line_Item__c>();
                Map<String,String> mapOfbooks 						= new Map<String,String>();
                
                for(Bookings bk : companyVsBookingsMap.get(company)){
                    mapOfbooks.put(bk.bookingId,bk.opplineId);
                    arrays+='{"type":"booking", "id":'+bk.bookingId+'},';
                    oppLineMap.put(Integer.valueOf(bk.bookingId),new Opportunity_Line_Item__c(id=bk.opplineId,Booking_Api_Id__c = bk.bookingId));
                }
                bodyparam 			+= arrays.removeEnd(',');
	            bodyparam 			+= ']}}';
                System.debug('bodyparam: '+bodyparam);
                HttpResponse res 	= new HttpResponse();      
                Http http 			= new Http();
                String api 			= '/bookings/cancel';
	                
                if(CountryCompanyBrand__c.getInstance(company) == null){
                	return 'Error: CountryCompanyBrand__c setting not present for ' + company;
                }
                String code 	= CountryCompanyBrand__c.getInstance(company).Code__c;
                String uri 		= '/v2/sites/'+code+api;
                HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest('PP',uri,'POST',bodyparam);
                
                // Initialize Log
                String logName	= code+'_CANCELLATION';
                LoggingUtility.createLog(logName,'MIDAS','CANCELLATION',oppId);
                LoggingUtility.log(logName,'Code :'+code +'\nURI : '+ uri + '\nType : POST' + '\nBody : ' + bodyparam);
        
                if(req == null){
                	return 'Error: MidasIntegration__c is not configured';
                }
                try{
                  LoggingUtility.captureTimeStamp(logName,'Begin');
                  res = http.send(req);
                  LoggingUtility.captureTimeStamp(logName,'End');
                  System.debug('response :'+res.getBody());
                  system.debug('##status code'+res.getStatusCode());
                  LoggingUtility.log(logName,'\nResponse Body : ' + res.getBody() + '\n Response status code : ' + res.getStatusCode());  
                  if(res.getStatusCode()==207) {
                    cancellationWrapper wrapper = (cancellationWrapper)JSON.deserialize(res.getBody(),cancellationWrapper.class);
                    for(Data dt : wrapper.data){
                      	if(dt.status == 204 || dt.status == 409){
	                      	Opportunity_Quote_Line_Item__c qli 	= oppQuoteMap.get(dt.Id);
	                      	Opportunity_line_Item__c li			= oppLineMap.get(dt.Id);
	                      	/* If the call for cancelling the PP bookings are made after the opportunity is 
	                    		Closed Lost/Won then dont delete the line Items , just updated the line items 
	                   			with Booking id appended with _CANCELED*/
	                        if(isCancel){
	                          if(qli != null)
					qli.Booking_Api_Id__c 	= qli.Booking_Api_Id__c + '_CANCELED';
	                          li.Booking_Api_Id__c 	= li.Booking_Api_Id__c + '_CANCELED';
	                        }                        	
	                        lineItemsToBeUpdated.add(li);
				if(qli != null)
	                        	quoteItemsToBeUpdated.add(qli);
                   		}else{
	                        isError = true;
	                        errorMessage = 'Booking Id ' + dt.Id + ' Error : ' + dt.message +'\n';
				LoggingUtility.logError(logName,errorMessage);
                    	}
                   	}		                        
                  }else{
                    LoggingUtility.logError(logName,res.getBody());
                    LoggingUtility.commitLogs();
                    return 'Error: '+res.getBody();
                  }
                }catch(System.CalloutException e){
                  LoggingUtility.captureTimeStamp(logName,'End');
                  LoggingUtility.logError(logName,e.getMessage());
                  throw e;
                } 
			}
				
			if(isCancel){
				if(lineItemsToBeUpdated.size() > 0)
					update lineItemsToBeUpdated;
				if(quoteItemsToBeUpdated.size() > 0)
					update 	quoteItemsToBeUpdated;
			}else{
				if(lineItemsToBeUpdated.size() > 0)
					delete lineItemsToBeUpdated;
				if(quoteItemsToBeUpdated.size() > 0)
					delete quoteItemsToBeUpdated;
			}
			
			if(isError){
        		LoggingUtility.commitLogs();
				return errorMessage;
			}
      		LoggingUtility.commitLogs();
			return 'Success'; 
		}catch(System.CalloutException e){
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
            return 'Error: '+e.getMessage();
        }
        
    }

	public static Map<String,List<Bookings>> populateBookingMap(List<Bookings> bookings){
		Map<String,List<Bookings>> bookingMap = new Map<String,List<Bookings>>();
		for(Bookings book : bookings){
			if(bookingMap.containsKey(book.companyName)){
				bookingMap.get(book.companyName).add(book);
			}else{
				List<Bookings> temp = new List<Bookings>();
				temp.add(book);
				bookingMap.put(book.companyName,temp);
			}
		}
		
		return bookingMap;
	}
	
	public static Set<String> populateBookingIds(List<Bookings> bookings){
		Set<String> bookingIds = new Set<String>();
		for(Bookings book : bookings){
			bookingIds.add(book.bookingId);
		}
		return bookingIds;
	} 
	
	public static Map<Integer,Opportunity_Quote_line_item__c> getOppQuoteMap(Set<String> bookingIds,String country){
		Map<Integer,Opportunity_Quote_Line_Item__c> oppQuoteMap =  new Map<Integer,Opportunity_Quote_Line_Item__c>();
		List<Opportunity_Quote_Line_Item__c> oppQuotes = [select id,Booking_Api_Id__c from Opportunity_Quote_Line_Item__c 
        													where Booking_Api_Id__c in : bookingids
        													and id_opportunity__r.record_country__c=:country];
        													
		for(Opportunity_Quote_Line_item__c qli : oppQuotes){
			oppQuoteMap.put(Integer.valueOf(qli.Booking_Api_Id__c),qli);
		}
		
		return oppQuoteMap;
	}

    global class Bookings{
        String bookingId;
        String opplineId;
        string companyName;
        global bookings(String bookingId,String opplineId,String companyName){
            this.bookingId = bookingId;
            this.opplineId = opplineId;
            this.companyName = companyName;
        }
    }
    
    global class dataWrapper {
    	public Data data;
    	public List<String> nextCodes;
    	public Boolean isError;
    	public String errorMessage;
    	
    	public dataWrapper(){
    		nextCodes	= new List<String>();
    	}
    	
    	public void populateDataWrapper(List<Restaurant> restaurants){
    		data 		= new Data();
    		data.populateRestaurants(restaurants);
    	}
    	
    	public void populateDataWrapper(List<Booking> bookings){
    		data = new Data();
    		data.populateBookings(bookings);
    	}
    }
    
    global class cancellationWrapper{
    	public List<Data> data;
    }
    
    global class Data{
    	public List<restaurant> restaurants;
    	public List<Booking> bookings;
    	public Integer Id;
    	public Integer status;
    	public String message;
    	
    	public void populateRestaurants(List<Restaurant> allRestaurants) {
			this.restaurants 			= new List<Restaurant>();
    		Set<String> restaurantIdSet = new Set<String>();
    		
    		// Remove the duplicate restaurants from the list
    		for(Restaurant res : allRestaurants) {
    			if(!restaurantIdSet.contains(res.sf_restaurant_id)) {
    				restaurantIdSet.add(res.sf_restaurant_id);
    				this.restaurants.add(res);
    			}
    		}
			List<Account> accounts = ClsAccountSelector.findAccountsByGrid(restaurantIdSet);
			if(accounts == null || accounts.isEmpty()) {
				return;
			}
			Map<String, Account> gridAccounts = (Map<String, Account>) ClsSObjectUtils.convertToSingleStringMap(accounts, Account.GRID__c.getDescribe().getLocalName());
			for(Restaurant res: this.restaurants) {
				if(gridAccounts.containsKey(res.sf_restaurant_id)) {
					res.sf_restaurant_id = gridAccounts.get(res.sf_restaurant_id).Id;
				}
			}
    	}
    	
    	public void populateBookings(List<Booking> allBookings){
    		bookings = allBookings;
    	}
    }
    
    global class restaurant{
    	public String status;
        public String sf_restaurant_id;
        public String name;
        public String ownership_reason;
        public Integer rating;
        public String postcode;
        public String owner;
        public Integer id;
    }
    
    
    global class Booking{
    	public String status;
        public String sf_restaurant_id;
        public String date_begin;
        public Integer restaurant_id;
        public String site;
        public String created_by;
        public String restaurant_package_description;
        public decimal amount;
        public String postcode;
        public String restaurant_name;
        public Integer id;
        public Integer position;
        public String date_end;
    }
    
}
