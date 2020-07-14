@isTest
global class UnitTestTarif {
    private static Map<String, RecordType> mapRecordtypesKR = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Opportunity', 'Account', 'List_Product_Group__c', 'List_Product_Price__c', 'List_Service_Price__c', 'List_Add_On__c','Tarif__c', 'Tarif_Member__c', 'Tarif_Item__c', 'Opportunity_Line_Item__c'});
    private static String responseType;
    @TestSetup
    public static void testSetup(){
    	
		// create RecordType__c custom setting
		UnitTestDataFactory.getRecordtypeValues();	
				
    	// create Country
    	Country__c c = UnitTestDataFactory.createCountry('UK', 'United Kingdom', 'GBP');
		Country__c czCountry = UnitTestDataFactory.createCountry('CZ', 'Czech Republic', 'CZK');
		insert new List<Country__c>{c, czCountry};
    	
    	// create company
		Company__c com = UnitTestDataFactory.createCompany('hungryhouse', 'uk', c);
		Company__c czCompany = UnitTestDataFactory.createCompany('Damejidlo', 'CZ', czCountry);
        insert new List<Company__c>{com, czCompany};
        
		// Create Business Config
		Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='OppQuoteEmailTemplate',Business_Rule_Value__c='UK_QuoteVFTemplate',Id_Country__c=c.id,Is_Active__c=true,Parent__c=true,Process_Name__c='OppQuoteProcess',Record_Type_Id__c='UK_Account',Type__c='Process');
		insert b1;
		
        // Create Account
    	Account acc = UnitTestDataFactory.createAccount('test',c,'UK_Account');
    	insert acc;
    	
    	// Create Platform Perforance 
    	Platform_Performance__c per = new Platform_performance__c();
    	per.Account__c = acc.Id;
    	per.Platform__c = 'hungryhouse';
    	per.backend_id__c = '123';
    	insert per;
    	
    	// Create Opportunity
    	Opportunity opp = UnitTestDataFactory.createOpportunity('test',acc,'UK_Opportunity', Date.today());
    	opp.Company_Code__c = 'UK';
    	insert opp;
    	
    	// Create commissions
    	List<List_Service_price__c> commissions = UnitTestDataFactory.createServices(com, c, 3,'UK_List_Service_Price',12,12,16, 8, 1,'Commission Fee', 
																						true, 0,'','Percentage', 'Commission Fee');
		
		insert commissions;
		
		// Create Product Group
    	List<List_Product_group__c> groups = UnitTestDataFactory.createProductGroups(Com, c, 1, 'UK_List_Product_Group');
    	insert groups;
    	
    	// Create Products
    	List<List_Product_price__c> products = UnitTestDataFactory.createProducts(com, c,groups[0].id, 2,'UK_List_Product_Price',
        																		0, true, 100, 1, false,20);
		insert products;
    	
    	// Create Add Ons
    	List<List_Add_On__c> addOns = UnitTestDataFactory.createAddOns(com,c,2,'UK_List_Add_On','test','Deal / Promotion',true);
    	insert addOns;
    	
    	// Create Tarif
    	Tarif__c t = new Tarif__c(Company__c = com.id, Id_Country__c = c.id, Is_Active__c = false, Name = 'testTarif1', RecordTypeId = mapRecordtypesKR.get('UK_Tarif').id);
		t.is_Locked__c 		= false;
		t.Product_only__c 	= false;
		t.categories__c 	= groups[0].name;
		insert t;
		t.Is_Active__c = true;
		update t;
		
		// create tarif Member
		List<Tarif_Member__c> members = new List<Tarif_Member__c>();
		for(List_Service_price__c comm :  commissions){
			Tarif_Member__c tm = new Tarif_Member__c(Id_Tarif_Item__c = comm.id, RecordTypeId = mapRecordtypesKR.get('UK_Tarif_Member').id, Tarif_Name__c = t.id, Type__c = 'Service');
    		members.add(tm);
		}
		for(List_Product_price__c prod : products){
			Tarif_Member__c tm = new Tarif_Member__c(Id_Tarif_Item__c = prod.id, RecordTypeId = mapRecordtypesKR.get('UK_Tarif_Member').id, Tarif_Name__c = t.id, Type__c = 'Product');
    		members.add(tm);
		}
		for(List_Add_On__c addOn : addOns){
			Tarif_Member__c tm = new Tarif_Member__c(Id_Tarif_Item__c = addOn.id, RecordTypeId = mapRecordtypesKR.get('UK_Tarif_Member').id, Tarif_Name__c = t.id, Type__c = 'AddOn');
    		members.add(tm);
		}
		insert members;
		
		// create country company brands
		List<CountryCompanyBrand__c> countryBrandSettings = new List<CountryCompanyBrand__c>();
        CountryCompanyBrand__c config = new CountryCompanyBrand__c();
        config.name = 'hungryhouse';
        config.code__c = 'UKHH';
        countryBrandSettings.add(config);
        
        CountryCompanyBrand__c config2 = new CountryCompanyBrand__c();
        config2.name = 'United Kingdom';
        config2.code__c = 'UKHH';
        countryBrandSettings.add(config2);
        
        CountryCompanyBrand__c config3 = new CountryCompanyBrand__c();
        config3.name = 'Kuwait';
        config3.code__c = 'KWTB';
        countryBrandSettings.add(config3);
        insert countryBrandSettings;
	 	
	 	// CREATE MIDAS CONF
	 	MidasIntegration__c conf = new MidasIntegration__c();
	 	conf.name = 'PP';
	 	conf.AuthenticationToken__c = '123';
	 	conf.EndPoint__c = 'https://www.eaxmple.com';
	 	conf.CountryBrand__c = '{"hungryhouse":"UKHH"}';
	 	insert conf;
	 	
	 	
	 	// Create premium placement product
	 	List_Product_Price__c premiumPlaceApiProd = new List_Product_price__c();
	 	premiumPlaceApiProd.Id_List_Product_Group__c = groups[0].Id;  
		premiumPlaceApiProd.Product_Name__c = 'Premium Placement API'; 
		premiumPlaceApiProd.RecordTypeId =  LibRecordTypeHelper.getRecordTypeValue('UK_List_Product_Price');
		premiumPlaceApiProd.List_price__c = 0;
		premiumPlaceApiProd.Default_Quantity__c	= 1;
		premiumPlaceApiProd.company__c = com.Id;
		insert premiumPlaceApiProd;
		
		// Create PlatformPerformce custom setting
		PlatformCompanyMapping__c mapping = new PlatformCompanyMapping__c();
		mapping.name = 'hungryhouse';
		mapping.company_code__c = 'hungryhouse'; 
		insert mapping;
    }
    
    @isTest
    public static void testTarifCreation(){
		Opportunity opp		= [SELECT id, account.Backend_ID__c, CurrencyIsoCode, Company_Code__c, Record_Country__c,Id_Tarif__c,
				Country__c,accountId,account.recordTypeId,account.recordType.developerName, RecordTypeId
		FROM Opportunity Limit 1];
    	Tarif__c tarifObj = [Select Id from Tarif__c limit 1];
    	Test.startTest();
    		Tarif tar 	= new tarif();
    		tar 		= new Tarif(tarifObj.Id, opp.RecordTypeId);
    		tar.fetchCommissionsFromTarif();
    		tar.fetchProductsFromTarif();
    		tar.fetchAddOnsFromTarif();
    		
    		System.assertEquals(tar.commissions.size(),3);
    		System.assertEquals(tar.products.size(),2);
    		System.assertEquals(tar.addOns.size(),2);
    	Test.stopTest();
    }
    
    @isTest
    public static void testSaveAndCreateQuote(){
    	Tarif__c tarifObj 	= [Select Id from Tarif__c limit 1];
    	Opportunity opp		= [SELECT id, account.Backend_ID__c, CurrencyIsoCode, Company_Code__c, Record_Country__c,Id_Tarif__c,
		            				Country__c,accountId,account.recordTypeId,account.recordType.developerName, RecordTypeId, Account.Commission_Base__c, RecordType.DeveloperName
		                        FROM Opportunity Limit 1];
		                        
        Tarif tar 	= new tarif();
		tar 		= new Tarif(tarifObj.Id, opp.RecordTypeId);
		tar.fetchCommissionsFromTarif();
		tar.fetchProductsFromTarif();
		tar.fetchAddOnsFromTarif();
		
    	Test.startTest();
    		
    		// This should throw a validation error
    		try{
    			tar.save(opp);
    			System.assert(false);
    		}catch(Exception e){}
    		 
    		// populate commission data
    		Integer i=0;
    		for(Tarif.commission comm : tar.commissions){
    			comm.CommissionInPercentage = 12;
    			comm.startDate				= Date.today().addDays(10*i);
    			i++;
    		}
    		
    		
    		// populate Products data
    		for(Tarif.product prod : tar.products){
    			prod.ListPrice 	= 100;
    			prod.discount	= '0';
    			prod.quantity	= 1;
    			prod.totalAmount= 100;	
    		}
    		
    		for(Tarif.Addon addOn : tar.addOns){
    			addOn.specifications = 'test';
    		}
    		
    		Country__c oppCountry = [SELECT Id, Name, Iso__c 
    									FROM Country__c 
    									WHERE Name = : opp.Record_Country__c LIMIT 1];
    		//tar.save(opp);
    		tar.createQuote(opp,oppCountry);
    		
    	Test.stopTest();
		List<Opportunity_line_item__c> lineItems = [Select Id from Opportunity_line_Item__c where Id_Opportunity__c =: opp.Id];
		List<Opportunity_Quote__c> quote = [select id from Opportunity_Quote__c where Id_Opportunity__c =: opp.Id];
		System.assertEquals(7,lineItems.size());
		System.assertEquals(1,quote.size());
    }
    
    
    @isTest
    public static void testDataPopulationFromLineItems(){
    	Tarif__c tarifObj 	= [Select Id from Tarif__c limit 1];
    	Opportunity opp		= [SELECT id, account.Backend_ID__c, CurrencyIsoCode, Company_Code__c, Record_Country__c,Id_Tarif__c,
		            				Country__c,accountId, RecordTypeId
		                        FROM Opportunity Limit 1];
		Tarif tar 	= new tarif();
		tar 		= new Tarif(tarifObj.Id, opp.RecordTypeId);
		tar.fetchCommissionsFromTarif();
		tar.fetchProductsFromTarif();
		tar.fetchAddOnsFromTarif();
		
		// This should throw a validation error
		try{
			tar.save(opp);
			System.assert(false);
		}catch(Exception e){}
		
		// populate commission data
		Integer i=0;
		for(Tarif.commission comm : tar.commissions){
			comm.CommissionInPercentage = 12;
			comm.startDate				= Date.today().addDays(10*i);
			i++;
		}
		
		// populate Products data
		for(Tarif.product prod : tar.products){
			prod.ListPrice 	= 100;
			prod.discount	= '0';
			prod.quantity	= 1;
			prod.totalAmount= 100;	
		}
		
		for(Tarif.Addon addOn : tar.addOns){
			addOn.specifications = 'test';
		}
		
		tar.save(opp);
    		
		Test.startTest();
			List<Opportunity_Line_Item__c> lineItems = new List<Opportunity_Line_Item__c>();
            lineItems = [SELECT Ad_Sales_Type__c,Booking_Api_Id__c,Category_Id__c,Category__c,City_ZipCode__c,Commission_In_Percentage__c,Commission_Per_Order__c,
                                Commission_Type__c,Deposit_Method__c,Deposit__c,Design_Note__c,Discount__c,District_Id__c,District__c,End_Date__c,Has_Related_Tarif__c,
                                Id,Id_List_Price_Product__c,Id_List_Service_Price__c,Id_Opportunity__c,Id_Replacement_Order__c,index__c,Installments__c,IsTiered__c,
                                Line_Item_Type__c,Listed_Price__c,Max__c,Min__c,Name,Number_of_Copies__c,OldOppQuoteLineId__c,Online_Payment_Fee__c,Position_fm__c,
                                Position__c,Product_Group__c,Quantity__c,RecordTypeId,Recurring_Fee__c,Size__c,Start_Date__c,Subsidy__c,Sub_type__c,Total_Amount__c,
                                Weight__c,Id_List_Add_on__c,ContractAddition__c,Billable_Account__c,Specifications__c,Scaled__c,
								Id_List_Price_Product__r.requires_asset__c,Id_List_Price_Product__r.requires_branding__c,delivery__c,Source_GRID__c,
                            	(SELECT Min__c,Max__c,Commission_In_percentage__c,Commission_Per_Order__c
                                    FROM Tiers__r
                                    ORDER BY min__c)
                        FROM Opportunity_Line_Item__c
                        WHERE Id_Opportunity__c =: opp.Id];

           tar = new Tarif(opp.Id_tarif__c, opp.RecordTypeId);
            
        	tar.fetchCommissionsFromLineItems(lineItems);
            tar.fetchProductsFromLineItems(lineItems);
			tar.fetchAddOnsFromLineItems(lineItems);
		Test.stopTest();
		
		System.assertEquals(3,tar.commissions.size());
		System.assertEquals(2,tar.products.size());
		System.assertEquals(2,tar.addOns.size());
    }
    
    @isTest
    public static void testFetchAvailibility(){
    	Tarif__c tarifObj 	= [Select Id from Tarif__c limit 1];
    	Opportunity opp		= [SELECT id, account.Backend_ID__c, CurrencyIsoCode, Company_Code__c, Record_Country__c,Id_Tarif__c,
		            				Country__c,accountId, RecordTypeId
		                        FROM Opportunity Limit 1];
		Tarif tar 		= new Tarif(tarifObj.Id, opp.RecordTypeId);
		Country__c oppCountry = [SELECT Id, Name, Iso__c 
    									FROM Country__c 
    									WHERE Name = : opp.Record_Country__c LIMIT 1];
    	Test.startTest();
	    	Test.setMock(HttpCalloutMock.class, new MockMIDASGetAvailibility());
	    	RESPONSETYPE = 'PULL';
    		tar.fetchAvailableBookings(opp,oppCountry,'12-2017');
    		System.assertEquals(1,tar.availableBookings.size(),tar.errorMsg);
    		System.assertEquals(1,tar.availableBookings[0].Bookings.size());
    		
    		for(Tarif.Booking booking : tar.availableBookings[0].bookings){
				booking.booked = true;
				booking.listPrice = 100;
				booking.totalAmount = 100;
				booking.discount = '0';
				booking.position = 1;
				booking.restaurantPosition = 'Default Position';
				Booking.packageId 	= '1';
				booking.date_end	= '2017-12-31';
            	booking.date_begin	= '2017-12-1';
            	booking.price		= 100;
            	booking.postcode	= '12345';
            	booking.site		= 'UKHH';
            	booking.platformBackendId = '1234';
            	booking.restaurant_id = 1234;
			}
			
			RESPONSETYPE = 'PUSH';
			tar.savePPLineItems(opp,oppCountry);
		
    	Test.stopTest();
    	
    	List<Opportunity_Line_Item__c> lineItems = [Select Id from Opportunity_line_item__c];
    	System.assertEquals(1,lineItems.size());
    }
    
    global class MockMIDASGetAvailibility implements HttpCalloutMock {
    	global HTTPResponse respond(HTTPRequest req) {
    		// Create a fake response
	        HttpResponse res = new HttpResponse();
	        res.setHeader('Content-Type', 'application/json');
	        if(RESPONSETYPE == 'PULL'){
	        	res.setBody('{"data":{"postcodes":[{"status":"open","sf_restaurant_id":"0012000001KRlvm","price_base":7.75,"distance":5.52,"restaurant_packages":[{"is_default":true,"price":15,"description":"Default booking","id":5},{"is_default":false,"price":22.5,"description":"Second position","id":12},{"is_default":false,"price":30,"description":"First position","id":11}],"restaurant_id":30906,"distance_units":"km","minimum_order_value":0,"postcode":"20095","coverage":100,"available_items":2}]}}');
	        }else if(RESPONSETYPE == 'PUSH'){
	        	res.setBody('{"data":{"bookings":[{"status":"open","sf_restaurant_id":"0012000001KRlvm","date_begin":"2017-12-01","restaurant_id":30906,"date_end":"2017-12-31","restaurant_package_description":"Default booking","created_by":"taha.holawala@deliveryhero.com","site":"UKHH","amount":100,"postcode":"12345","restaurant_name":"Midnight Alk","position":0,"id":566947}]}}');
	        }
	        res.setStatusCode(200);
	        return res;
    	}
    }

   @isTest
    public static void test_checkShopVertical() {
        UnitTestDataFactory.getRecordtypeValues();
        UnitTestDataFactory.testDataForApacApprovals();
        
        Country__c hk = Country_Selector.getByName('Hong Kong');
        Account acco = AccountSelector.getAccountByName('FP TestAccount');
        acco.Record_Country__c = 'Hong Kong';
        acco.Vertical__c = 'Shop';
        acco.Vertical_Segment__c = 'Flowers';
        update acco;
        
        Opportunity opp = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'FP_Opportunity', Date.today());
        opp.StageName = 'Quality Check';
        opp.Business_Type__c = 'New Business';
        insert opp;
        opp.RecordType = new RecordType(DeveloperName = 'FP_Opportunity');
        opp.Account = new Account();
        opp.Account.Vertical__c = 'Shop';
        
        List_Product_Group__c lpg = ListServiceGroupSelector.getProductGroupByName('Apple');
        List_Service_Price__c lsp = ListServicePriceSelector.getServiceByName('testService1');
        
        List<Opportunity_Quote__c> quotes = UnitTestDataFactory.createOpportunityQuotes(opp, 1, 'FP_Opportunity_Quote', 'Draft', 'desc', 100, 119, '', '', 19);
        insert quotes;
        
        List<Opportunity_Quote_Line_Item__c> quoteLineItems = UnitTestDataFactory.createOpportunityQuoteLineItems(quotes[0], lsp.Id, 'Apple', 1, true, 'FP_Opportunity_Quote_Line_Item', 0, '0', 100, 1, 100, 'Service');
        List<Opportunity_Line_Item__c> oppLineItems = new List<Opportunity_Line_Item__c>();
        for(Opportunity_Quote_Line_Item__c oqli : quoteLineItems) {
            oppLineItems.add(new Opportunity_Line_Item__c(Id_List_Price_Product__r = new List_Product_Price__c(Product_Type__c = 'Wrong Product Type')));
        }
        
        // set business configs
        Business_Config__c businessConfig1 = UnitTestDataFactory.createBusinessConfig('DishLevelCheck', 'Process','OpportunityFieldName', 'Business_Type__c', hk.Id, 'FP_Opportunity', true, true );
        Business_Config__c businessConfig2 = UnitTestDataFactory.createBusinessConfig('DishLevelCheck', 'Process','New Business', 'Dish Level Photoshoot', hk.Id, 'FP_Opportunity', true, false );
        insert businessConfig1;
        insert businessConfig2;
        Map<String, Business_Config__c> bconfMap_1 = new Map<String, Business_Config__c>{
            businessConfig1.Business_Rule_Name__c => businessConfig1,
            businessConfig2.Business_Rule_Name__c => businessConfig2
        };
        Map<String, Map<String, Business_Config__c>> bconfMap_1f = new Map<String, Map<String, Business_Config__c>>{'FP_Opportunity' => bconfMap_1};
        LibBusinessConfig.setMotherOfAllBusinessMaps(new Map<String, Map<String, Map<String, Business_Config__c>>>{businessConfig1.Process_Name__c => bconfMap_1f});

        
        Exception exx = null;
        Test.startTest();
            try {
                Tarif.checkShopVertical(opp, oppLineItems);
            } catch(Tarif.TarifException ex) {
                exx = ex;
            }
        Test.stopTest();
        
        System.assertNotEquals(null, exx, 'Exception should have been thrown!');
    }

	/**
	* @description  Test if the Dish Level validation works for ~Chain opportunity
	*/
	@isTest
	public static void test_checkShopVerticalChain() {
		UnitTestDataFactory.getRecordtypeValues();
		UnitTestDataFactory.testDataForApacApprovals();

		Country__c hk = Country_Selector.getByName('Hong Kong');
		Account acco = AccountSelector.getAccountByName('FP TestAccount');
		acco.Record_Country__c = 'Hong Kong';
		acco.Vertical__c = 'Shop';
		acco.Vertical_Segment__c = 'Flowers';
		acco.Type = 'Group';
		update acco;

		Opportunity opp = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'Chain_Opportunity', Date.today());
		opp.StageName = 'Quality Check';
		opp.Business_Type__c = 'New Business';
		insert opp;
		opp.RecordType = new RecordType(DeveloperName = 'Chain_Opportunity');
		opp.Account = new Account();
		opp.Account.Vertical__c = 'Shop';

		List_Product_Group__c lpg = ListServiceGroupSelector.getProductGroupByName('Apple');
		List_Service_Price__c lsp = ListServicePriceSelector.getServiceByName('testService1');

		List<Opportunity_Quote__c> quotes = UnitTestDataFactory.createOpportunityQuotes(opp, 1, 'FP_Opportunity_Quote', 'Draft', 'desc', 100, 119, '', '', 19);
		insert quotes;

		List<Opportunity_Quote_Line_Item__c> quoteLineItems = UnitTestDataFactory.createOpportunityQuoteLineItems(quotes[0], lsp.Id, 'Apple', 1, true, 'FP_Opportunity_Quote_Line_Item', 0, '0', 100, 1, 100, 'Service');
		List<Opportunity_Line_Item__c> oppLineItems = new List<Opportunity_Line_Item__c>();
		for(Opportunity_Quote_Line_Item__c oqli : quoteLineItems) {
			oppLineItems.add(new Opportunity_Line_Item__c(Id_List_Price_Product__r = new List_Product_Price__c(Product_Type__c = 'Wrong Product Type'), RecordTypeId=LibRecordTypeHelper.getRecordTypeValue('FP_Opportunity_Line_Item')));
		}

		// set business configs
		Business_Config__c businessConfig1 = UnitTestDataFactory.createBusinessConfig('DishLevelCheck', 'Process','OpportunityFieldName', 'Business_Type__c', hk.Id, 'FP_Opportunity', true, true );
		Business_Config__c businessConfig2 = UnitTestDataFactory.createBusinessConfig('DishLevelCheck', 'Process','New Business', 'Dish Level Photoshoot', hk.Id, 'FP_Opportunity', true, false );
		insert businessConfig1;
		insert businessConfig2;
		Map<String, Business_Config__c> bconfMap_1 = new Map<String, Business_Config__c>{
				businessConfig1.Business_Rule_Name__c => businessConfig1,
				businessConfig2.Business_Rule_Name__c => businessConfig2
		};
		Map<String, Map<String, Business_Config__c>> bconfMap_1f = new Map<String, Map<String, Business_Config__c>>{'FP_Opportunity' => bconfMap_1};
		LibBusinessConfig.setMotherOfAllBusinessMaps(new Map<String, Map<String, Map<String, Business_Config__c>>>{businessConfig1.Process_Name__c => bconfMap_1f});


		Exception exx = null;
		Test.startTest();
		try {
			Tarif.checkShopVertical(opp, oppLineItems);
		} catch(Tarif.TarifException ex) {
			exx = ex;
		}
		Test.stopTest();

		System.assertNotEquals(null, exx, 'Exception should have been thrown!');
	}
    
    @isTest
    public static void test_checkShopVertical_Negative() {
        UnitTestDataFactory.getRecordtypeValues();
        UnitTestDataFactory.testDataForApacApprovals();
        
        Country__c hk = Country_Selector.getByName('Hong Kong');
        Account acco = AccountSelector.getAccountByName('FP TestAccount');
        Opportunity opp = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'FP_Opportunity', Date.today());
        opp.StageName = 'Quality Check';
        opp.Business_Type__c = 'New Business';
        insert opp;
        opp.RecordType = new RecordType(DeveloperName = 'FP_Opportunity');
        
        List_Product_Group__c lpg = ListServiceGroupSelector.getProductGroupByName('Apple');
        List_Service_Price__c lsp = ListServicePriceSelector.getServiceByName('testService1');
        
        List<Opportunity_Quote__c> quotes = UnitTestDataFactory.createOpportunityQuotes(opp, 1, 'FP_Opportunity_Quote', 'Draft', 'desc', 100, 119, '', '', 19);
        insert quotes;
        
        List<Opportunity_Quote_Line_Item__c> quoteLineItems = UnitTestDataFactory.createOpportunityQuoteLineItems(quotes[0], lsp.Id, 'Apple', 1, true, 'FP_Opportunity_Quote_Line_Item', 0, '0', 100, 1, 100, 'Service');
        List<Opportunity_Line_Item__c> oppLineItems = new List<Opportunity_Line_Item__c>();
        for(Opportunity_Quote_Line_Item__c oqli : quoteLineItems) {
            oppLineItems.add(new Opportunity_Line_Item__c(Id_List_Price_Product__r = new List_Product_Price__c(Product_Type__c = 'Dish Level Photoshoot')));
        }
        
        // set business configs
        Business_Config__c businessConfig1 = UnitTestDataFactory.createBusinessConfig('DishLevelCheck', 'Process','OpportunityFieldName', 'Business_Type__c', hk.Id, 'FP_Opportunity', true, true );
        Business_Config__c businessConfig2 = UnitTestDataFactory.createBusinessConfig('DishLevelCheck', 'Process','New Business', 'Dish Level Photoshoot', hk.Id, 'FP_Opportunity', true, false );
        insert businessConfig1;
        insert businessConfig2;
        Map<String, Business_Config__c> bconfMap_1 = new Map<String, Business_Config__c>{
            businessConfig1.Business_Rule_Name__c => businessConfig1,
            businessConfig2.Business_Rule_Name__c => businessConfig2
        };
        Map<String, Map<String, Business_Config__c>> bconfMap_1f = new Map<String, Map<String, Business_Config__c>>{'FP_Entry_Case' => bconfMap_1};
        LibBusinessConfig.setMotherOfAllBusinessMaps(new Map<String, Map<String, Map<String, Business_Config__c>>>{businessConfig1.Process_Name__c => bconfMap_1f});
        
        
        Exception exx = null;
        Test.startTest();
        
        try {
            Tarif.checkShopVertical(opp, oppLineItems);
        } catch(Tarif.TarifException ex) {
            exx = ex;
        }
        Test.stopTest();
        
        System.assertEquals(null, exx, 'Exception should not have been thrown!');
    }
    
    
    @isTest
    public static void test_assignApprovalRules_Positive() {
        UnitTestDataFactory.getRecordtypeValues();
        UnitTestDataFactory.testDataForApacApprovals();
        User usr = UnitTestDataFactory.createUser('System Administrator','test@deliveryhero.com','FP','HK');
        usr.Entity__c = 'APAC FoodPanda';
        insert usr;

        System.runAs(usr){
        Country__c hk = Country_Selector.getByName('Hong Kong');
        Account acco = AccountSelector.getAccountByName('FP TestAccount');
        acco.Record_Country__c = 'Hong Kong';
        acco.Vertical__c = 'Shop';
        acco.Vertical_Segment__c = 'Flowers';
        update acco;
        
        Opportunity opp = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'FP_Opportunity', Date.today());
        opp.StageName = 'Quality Check';
        insert opp;
        opp.Account = new Account();
        opp.Account.Vertical__c = 'Shop';
        
        List_Product_Group__c lpg = ListServiceGroupSelector.getProductGroupByName('Apple');
        List_Service_Price__c lsp = ListServicePriceSelector.getServiceByName('testService1');
        
        Approval_Rule__c newRule = UnitTestDataFactory.createApprovalRule(lsp.Id, null, null, UserInfo.getUserId(), '50%', '25%', null);
        insert newRule;
        
        List<Opportunity_Quote__c> quotes = UnitTestDataFactory.createOpportunityQuotes(opp, 1, 'FP_Opportunity_Quote', 'Draft', 'desc', 100, 119, '', '', 19);
        insert quotes;
        
        List<Opportunity_Quote_Line_Item__c> quoteLineItems = UnitTestDataFactory.createOpportunityQuoteLineItems(quotes[0], null, 'Apple', 1, true, 'FP_Opportunity_Quote_Line_Item', 0, '0', 100, 1, 100, 'Service');
        quoteLineItems[0].Id_List_Service_Price__c = lsp.Id;
        quoteLineItems[0].Commission_In_Percentage__c = 30;
        insert quoteLineItems;
        
        // set business configs
        Business_Config__c businessConfig1 = UnitTestDataFactory.createBusinessConfig('DishLevelCheck', 'Process','RequiredAddOnName', 'Dish Level Photoshoot', hk.Id, 'FP_Opportunity', true, true );
        insert businessConfig1;
        
        Map<String, Business_Config__c> bconfMap_1 = new Map<String, Business_Config__c>{businessConfig1.Business_Rule_Name__c => businessConfig1};
		Map<String, Map<String, Business_Config__c>> bconfMap_1f = new Map<String, Map<String, Business_Config__c>>{'FP_Opportunity' => bconfMap_1};
        
        Exception exx = null;
        
        Test.startTest();
            LibBusinessConfig.setMotherOfAllBusinessMaps(new Map<String, Map<String, Map<String, Business_Config__c>>>{businessConfig1.Process_Name__c => bconfMap_1f});
            Tarif.assignApprovalRules(quoteLineItems, null, null);
        Test.stopTest();
        
        System.assertEquals(newRule.Id, quoteLineItems[0].Approval_Rule__c, 'Rule should have been applied to this line item');
        }
    }
    
    @isTest
    public static void test_assignApprovalRules_Negative() {
        UnitTestDataFactory.getRecordtypeValues();
        UnitTestDataFactory.testDataForApacApprovals();
        User usr = UnitTestDataFactory.createUser('System Administrator','test@deliveryhero.com','FP','HK');
        usr.Entity__c = 'APAC FoodPanda';
        insert usr;

        System.runAs(usr){
        Country__c hk = Country_Selector.getByName('Hong Kong');
        Account acco = AccountSelector.getAccountByName('FP TestAccount');
        acco.Record_Country__c = 'Hong Kong';
        acco.Vertical__c = 'Shop';
        acco.Vertical_Segment__c = 'Flowers';
        update acco;
        
        Opportunity opp = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'FP_Opportunity', Date.today());
        opp.StageName = 'Quality Check';
        insert opp;
        opp.Account = new Account();
        opp.Account.Vertical__c = 'Shop';
        
        List_Product_Group__c lpg = ListServiceGroupSelector.getProductGroupByName('Apple');
        List_Service_Price__c lsp = ListServicePriceSelector.getServiceByName('testService1');
        
        Approval_Rule__c newRule = UnitTestDataFactory.createApprovalRule(lsp.Id, null, null, UserInfo.getUserId(), '50%', '25%', null);
        insert newRule;
        
        List<Opportunity_Quote__c> quotes = UnitTestDataFactory.createOpportunityQuotes(opp, 1, 'FP_Opportunity_Quote', 'Draft', 'desc', 100, 119, '', '', 19);
        insert quotes;
        
        List<Opportunity_Quote_Line_Item__c> quoteLineItems = UnitTestDataFactory.createOpportunityQuoteLineItems(quotes[0], null, 'Apple', 1, true, 'FP_Opportunity_Quote_Line_Item', 0, '0', 100, 1, 100, 'Service');
        quoteLineItems[0].Id_List_Service_Price__c = lsp.Id;
        quoteLineItems[0].Commission_In_Percentage__c = 51;
        insert quoteLineItems;
        
        // set business configs
        Business_Config__c businessConfig1 = UnitTestDataFactory.createBusinessConfig('DishLevelCheck', 'Process','RequiredAddOnName', 'Dish Level Photoshoot', hk.Id, 'FP_Opportunity', true, true );
        insert businessConfig1;
        
        Map<String, Business_Config__c> bconfMap_1 = new Map<String, Business_Config__c>{businessConfig1.Business_Rule_Name__c => businessConfig1};
		Map<String, Map<String, Business_Config__c>> bconfMap_1f = new Map<String, Map<String, Business_Config__c>>{'FP_Opportunity' => bconfMap_1};
        
        Exception exx = null;
        
        Test.startTest();
            LibBusinessConfig.setMotherOfAllBusinessMaps(new Map<String, Map<String, Map<String, Business_Config__c>>>{businessConfig1.Process_Name__c => bconfMap_1f});
            Tarif.assignApprovalRules(quoteLineItems, null, null);
        Test.stopTest();
        
        System.assertEquals(null, quoteLineItems[0].Approval_Rule__c, 'Rule should have been applied to this line item');
        }
    }
	
	@isTest
    public static void testCheckCommissionFeeCheck() {
		Country__c czCountry = [SELECT Id, Name, CurrencyIsoCode FROM Country__c WHERE Name = 'Czech Republic'];
		Company__c czCompany = [SELECT Id, Name FROM Company__c WHERE Name = 'Damejidlo'];

		List<Business_Config__c> bConfigList = new List<Business_Config__c>();
		bConfigList.add(
            UnitTestDataFactory.createBusinessConfig('CommissionFeeCheck','Process','Enable','TRUE', czCountry.id, 'CZ_Opportunity', true, true)
		);
		insert bConfigList;

		//CREATE ACCOUNT
		Account czAccount = UnitTestDataFactory.createAccount('Test CZ Account 1', czCountry, 'CZ_Account');
		czAccount.Type = 'Branch - main';
		czAccount.Commission_Base__c = 'comm1';
        insert czAccount;

        //CREATE OPPORTUNITY
		Opportunity czOpportunity = UnitTestDataFactory.createOpportunity(czAccount.Name, czAccount, 'CZ_Opportunity', Date.today());
		czOpportunity.Business_Type__c = 'Upgrade/Upsell';
		czOpportunity.Type = 'Contract & Product';
		czOpportunity.StageName = 'New';
        
		insert czOpportunity;

        List_Service_Price__c listServicePrice = UnitTestDataFactory.createService(czCompany, czCountry, 'Commission 1', 'CZ_List_Service_Price', 10, 10, 30, 5, 1, true, 0, 'Commission', 'Logistics Fee');
        insert listServicePrice;

        List<Opportunity_Line_Item__c> lineItems = UnitTestDataFactory.createOpportunityLineItems(czOpportunity, listServicePrice.Id, 1, true, 'CZ_Opportunity_Line_Item', 10, 1, Date.today(), 'Logistics Fee', 10, 'Service');
		insert lineItems;

		czOpportunity = [SELECT Id, Name, Account.Commission_Base__c, RecordType.DeveloperName FROM Opportunity WHERE Id =: czOpportunity.Id];
		lineItems = [SELECT Id, Name, Id_List_Service_Price__c, Id_List_Service_Price__r.Service_Type__c FROM Opportunity_Line_Item__c WHERE Id IN: lineItems];

		Test.startTest();
			try{
				Tarif.checkCommissionFee(czOpportunity, lineItems);
				system.assert(false, 'Must throw an error');
			} catch(Exception e){
				system.assert(e.getMessage().contains(Label.CZ_Commission_Fee_Check_Error_Message));
			}
		Test.stopTest();
	}
}
