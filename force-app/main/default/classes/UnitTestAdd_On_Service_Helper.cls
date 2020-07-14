/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class UnitTestAdd_On_Service_Helper {

        
    private static Country__c testCountry;
    private static Company__c testCompany;
    private static List<Opportunity> opportunities;
    private static List<Opportunity_Quote__c> oppqsYG;
    private static List<Opportunity_Quote__c> oppqsTb;
    private static List<List_Service_Price__c> services;
    private static List<List_Add_On__c> addOns;
    private static List<Account> accounts;

	/**
	* @author william Castillo
	* @date November 21, 2017
	* @description SP-1619, Test the Single record Validation.
	* @param lstAddOnNew, the new records from trigger. 
	*/	
    static testMethod void TestSingleRecord() {
        // TO DO: implement unit test   
		Boolean blnTestException;

		CreateBasicData();

		Test.startTest();
		
		Add_on_Service__c addTest1 = new Add_on_Service__c();
		
		addTest1.Account_Name__c = accounts[0].Id;
		//addTest1.Opportunity__c  = opportunities[0].id;
		addTest1.Status__c  = 'Active';
		addTest1.Id_List_Add_On__c = addOns[0].id;
		
		insert addTest1;
		
		addTest1 = new Add_on_Service__c();
		
		addTest1.Account_Name__c = accounts[0].Id;
		//addTest1.Opportunity__c  = opportunities[0].id;
		addTest1.Status__c  = 'inActive';
		addTest1.Id_List_Add_On__c = addOns[0].id;
		
		insert addTest1;
		
		addTest1 = new Add_on_Service__c();
		
		addTest1.Account_Name__c = accounts[0].Id;
		//addTest1.Opportunity__c  = opportunities[0].id;
		addTest1.Status__c  = 'Active';
		addTest1.Id_List_Add_On__c = addOns[0].id;
		
		blnTestException = false;
		
		try{
			insert addTest1;
		}catch(exception e){
			blnTestException = true;		
		}
		
		System.assert(blnTestException);
		
				
		addTest1 = new Add_on_Service__c();
		
		addTest1.Account_Name__c = accounts[0].Id;
		addTest1.Opportunity__c  = opportunities[0].id;
		addTest1.Status__c  = 'Active';
		addTest1.Id_List_Add_On__c = addOns[0].id;
		
		blnTestException = false;
		
		try{
			insert addTest1;
		}catch(exception e){
			blnTestException = true;		
		}
		
		System.assert(!blnTestException);
		
		addTest1 = new Add_on_Service__c();
		
		addTest1.Account_Name__c = accounts[0].Id;
		//addTest1.Opportunity__c  = opportunities[0].id;
		addTest1.Status__c  = 'Active';
		addTest1.Id_List_Add_On__c = addOns[0].id;
		
		
		blnTestException = false;
		
		try{
			insert addTest1;
		}catch(exception e){
			blnTestException = true;		
		}
		
		System.assert(blnTestException);
		
		addTest1 = new Add_on_Service__c();
		
		addTest1.Account_Name__c = accounts[0].Id;
		addTest1.Opportunity__c  = opportunities[0].id;
		addTest1.Status__c  = 'Active';
		addTest1.Id_List_Add_On__c = addOns[0].id;
		
		
		
		blnTestException = false;
		
		try{
			insert addTest1;
		}catch(exception e){
			blnTestException = true;		
		}

		System.assert(!blnTestException);
				                                                    
		Test.stopTest();
          
    }
    
    /**
	* @author william Castillo
	* @date November 21, 2017
	* @description SP-1619, Test the Bulk record Validation.
	* @param lstAddOnNew, the new records from trigger. 
	*/	
    static testMethod void TestBulkRecords() {
        // TO DO: implement unit test   
		Boolean blnTestException;
		List<Add_on_Service__c> lstAddSerBulk = new List<Add_on_Service__c>();
		CreateBasicData();

		Test.startTest();
		
		Add_on_Service__c addTest1 = new Add_on_Service__c();
		
		addTest1.Account_Name__c = accounts[0].Id;
		//addTest1.Opportunity__c  = opportunities[0].id;
		addTest1.Status__c  = 'Active';
		addTest1.Id_List_Add_On__c = addOns[0].id;
		
		lstAddSerBulk.add(addTest1);
		
		addTest1 = new Add_on_Service__c();
		
		addTest1.Account_Name__c = accounts[0].Id;
		//addTest1.Opportunity__c  = opportunities[0].id;
		addTest1.Status__c  = 'inActive';
		addTest1.Id_List_Add_On__c = addOns[0].id;
		
		lstAddSerBulk.add(addTest1);
		
		addTest1 = new Add_on_Service__c();
		
		addTest1.Account_Name__c = accounts[0].Id;
		//addTest1.Opportunity__c  = opportunities[0].id;
		addTest1.Status__c  = 'Active';
		addTest1.Id_List_Add_On__c = addOns[0].id;
		
		lstAddSerBulk.add(addTest1);
		
				
		addTest1 = new Add_on_Service__c();
		
		addTest1.Account_Name__c = accounts[0].Id;
		addTest1.Opportunity__c  = opportunities[0].id;
		addTest1.Status__c  = 'Active';
		addTest1.Id_List_Add_On__c = addOns[0].id;
		
		lstAddSerBulk.add(addTest1);
		
		addTest1 = new Add_on_Service__c();
		
		addTest1.Account_Name__c = accounts[0].Id;
		//addTest1.Opportunity__c  = opportunities[0].id;
		addTest1.Status__c  = 'Active';
		addTest1.Id_List_Add_On__c = addOns[0].id;
		
		lstAddSerBulk.add(addTest1);
		
		addTest1 = new Add_on_Service__c();
		
		addTest1.Account_Name__c = accounts[0].Id;
		addTest1.Opportunity__c  = opportunities[0].id;
		addTest1.Status__c  = 'Active';
		addTest1.Id_List_Add_On__c = addOns[0].id;
		
		lstAddSerBulk.add(addTest1);
		
		blnTestException = false;
		

			Database.SaveResult[] srList = Database.insert(lstAddSerBulk, false);
			Integer numErrors = 0;

			// Iterate through each returned result
			for (Database.SaveResult sr : srList) {
			    if (sr.isSuccess()) {
			        // Operation was successful, so get the ID of the record that was processed
			        System.debug('Successfully inserted Add On .  ID: ' + sr.getId());
			    }
			    else {
			        // Operation failed, so get all errors                
			        for(Database.Error err : sr.getErrors()) {
			            System.debug('The following error has occurred.');                    
			            System.debug(err.getStatusCode() + ': ' + err.getMessage());
			            System.debug('Add On service fields that affected this error: ' + err.getFields());
			        }
			        numErrors++;
			    }
			}

			System.assertEquals(numErrors,6);
		//System.assert(blnTestException);
				                                                    
		Test.stopTest();
          
    }
    static testMethod void testaddonOppclosedwon(){
            CreateBasicData();

            Add_on_service__C addTest1 = new Add_on_Service__c();

            addTest1.Account_Name__c = accounts[0].Id;
            addTest1.Opportunity__c  = opportunities[0].id;
            addTest1.Status__c  = 'New';
            addTest1.recordtypeid=Librecordtypehelper.getRecordTypeValue('Yogiyo_Add_On');
            addTest1.Id_List_Add_On__c = addOns[0].id;
            insert addTest1;
            addTest1.status__c='Active';
            Test.starttest();
            update addTest1;
            Test.stoptest();
	}
	//SSC-3462
	static testMethod void testAddonOppCloseWonFP(){

		CreatedBasicDataFP();
		Add_on_service__C addServiceObj = [Select id from Add_on_service__C limit 1];
		addServiceObj.status__c= Constants.ADD_ON_SERVICE_STATUS_ACTIVE;

		Opportunity deliveyPendingOppty = Opportunity_Selector.getAll()[0];

		Country__c malaysiaCountryObj = CountrySelector.getCountryByName(Constants.COUNTRY_NAME_MALAYSIA);

		Case caseObj = UnitTestDataFactory.createCase(new Account(Id = deliveyPendingOppty.AccountId),Constants.CASE_STATUS_NEW,
				Constants.CASE_TYPE_MENU_PROCESSING,
				'', '',malaysiaCountryObj,
				Constants.FP_ENTRY_CASE_DEVELOPERNAME,
				Constants.CASE_TYPE_MENU_PROCESSING);
		caseObj.Closed_Reason__c = Constants.CASE_CLOSED_REASON_TAKE_ONLINE;
		caseObj.Opportunity__c = deliveyPendingOppty.ID;
		caseobj.Menu_URL__c = 'test';
		insert caseObj;

		caseObj.Status = Constants.CASE_STATUS_CLOSED;
		update caseObj;

		deliveyPendingOppty.stageName = Constants.OPPORTUNITY_STAGE_DELIVERY_PENDING;
		update deliveyPendingOppty;

		Test.starttest();
		update addServiceObj;
		Test.stoptest();

		Opportunity oppty = Opportunity_Selector.getAll()[0];
		system.AssertEquals(Constants.OPPORTUNITY_STAGE_CLOSED_WON,oppty.StageName);
	}
	//SSC-3462
	static testMethod void testAddOnOppCloseWonNegativeFP(){

		CreatedBasicDataFP();
		Add_on_service__C addServiceObj = [Select id from Add_on_service__C WHERE Status__c =:
										  Constants.ADD_ON_SERVICE_STATUS_NEW limit 1];
		addServiceObj.status__c= Constants.ADD_ON_SERVICE_STATUS_ACTIVE;

		Opportunity deliveyPendingOppty = Opportunity_Selector.getAll()[0];

		Country__c malaysiaCountryObj = CountrySelector.getCountryByName(Constants.COUNTRY_NAME_MALAYSIA);

		Case caseObj = UnitTestDataFactory.createCase(new Account(Id = deliveyPendingOppty.AccountId),Constants.CASE_STATUS_NEW,
													Constants.CASE_TYPE_MENU_PROCESSING,
													'', '',malaysiaCountryObj,
													Constants.FP_ENTRY_CASE_DEVELOPERNAME,
													Constants.CASE_TYPE_MENU_PROCESSING);

		caseObj.Opportunity__c = deliveyPendingOppty.ID;
		insert caseObj;

		deliveyPendingOppty.stageName = Constants.OPPORTUNITY_STAGE_DELIVERY_PENDING;
		update deliveyPendingOppty;

		Test.starttest();
		update addServiceObj;
		Test.stoptest();

		Opportunity oppty = Opportunity_Selector.getAll()[0];
		system.AssertNotEquals(Constants.OPPORTUNITY_STAGE_CLOSED_WON,oppty.StageName);
	}


	private static void createdBasicDataFP(){

		UnitTestDataFactory.getRecordtypeValues();
		Country__c testCountryMY = UnitTestDataFactory.createCountry('MY', Constants.COUNTRY_NAME_MALAYSIA, 'MYR');
		insert testCountryMY;

		Company__c testCompanyMY = UnitTestDataFactory.createCompany('FoodPanda', 'FoodPanda', testCountryMY);
		insert testCompanyMY;


		Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='ActiveStatuses',Business_Rule_Value__c='Active',Id_Country__c=testCountryMY.id,Is_Active__c=true,Parent__c=false,Process_Name__c='OnboardingCaseCreationAfterAddOnActivationProcess',Record_Type_Id__c='FP_Add_On',Type__c='Process');
		Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='AssetExceptionStatuses',Business_Rule_Value__c='Exception,Technical Issue,Returned',Id_Country__c=testCountryMY.id,Is_Active__c=true,Parent__c=false,Process_Name__c='OnboardingCaseCreationAfterAddOnActivationProcess',Record_Type_Id__c='FP_Add_On',Type__c='Process');
		Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='StageOpportunity',Business_Rule_Value__c='Onboarding',Id_Country__c=testCountryMY.id,Is_Active__c=true,Parent__c=false,Process_Name__c='OnboardingCaseCreationAfterAddOnActivationProcess',Record_Type_Id__c='FP_Add_On',Type__c='Process' );
		Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='CheckClosedCases',Business_Rule_Value__c='{ "Onboarding":[ "Onboarding"],"Menu Processing":[ "Take Online"],"Quality Check":[ "Successful"],"Photo Listing":[ "Successful"] }',Id_Country__c=testCountryMY.id,Is_Active__c=true,Parent__c=false,Process_Name__c='AddOnActivation',Record_Type_Id__c='FP_Add_On',Type__c='Process');
		Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='AddOnActivationStatus',Business_Rule_Value__c='Active',Id_Country__c=testCountryMY.id,Is_Active__c=true,Parent__c=true,Process_Name__c='AddOnActivation',Record_Type_Id__c='FP_Add_On',Type__c='Process');
		Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c='CheckForAddon',Business_Rule_Value__c='true',Id_Country__c=testCountryMY.id,Is_Active__c=true,Parent__c=false,Process_Name__c='AddOnActivation',Record_Type_Id__c='FP_Add_On',Type__c='Process');

		insert new List<sObject>{b1,b2,b3,b4,b5,b6};

		List<Account> fpAccount = UnitTestDataFactory.createAccounts(2, testCountryMY, Constants.FP_ACCOUNT_DEVELOPERNAME);
		fpAccount[0].phone = '+6012345678';
		fpAccount[1].phone = '+6012345678';
		insert fpAccount;
		List<List_Service_Price__c> fpServices = UnitTestDataFactory.createServices(testCompanyMY, testCountryMY, 10, Constants.FP_LIST_SERVICE_PRICE_DEVELOPERNAME, 13, 13, 15, 10, 1, '% per Order', true, 299, 'Monthly', 'Commission', 'ServiceType');
		List<Contact> fpContact = UnitTestDataFactory.createContacts(fpAccount, 'testContact', 'firstname', null, 'owner', 1, 'testCt', Constants.FP_CONTACT_DEVELOPERNAME);
		List<Opportunity> fpOpportunity = UnitTestDataFactory.createOpportunities(fpAccount, 1, Constants.FP_OPPORTUNITY_DEVELOPERNAME, Date.today().addMonths(2));
		insert fpOpportunity;
		Opportunity_Line_Item__c fpoppServiceItem = UnitTestDataFactory.createOpportunityLineItemService('commission Fee',fpOpportunity[0], fpServices[0].Id, false, Constants.FP_OPPORTUNITY_LINE_ITEM_DEVELOPERNAME, 13, null, Date.today(), 'Commission Fee', null);
		insert fpoppServiceItem;
		List<Opportunity_Quote__c> fpOpportunityQuote = UnitTestDataFactory.createOpportunityQuotes(fpOpportunity[0], 1, Constants.FP_OPPORTUNITY_QUOTE_DEVELOPERNAME, 'Accepted','testdata',10, 10, null,null,0);
		insert fpOpportunityQuote;
		insert UnitTestDataFactory.createOpportunityQuoteLineItem(fpOpportunityQuote[0],fpoppServiceItem,Constants.FP_OPPORTUNITY_QUOTE_LINE_ITEM_DEVELOPERNAME);
		List<List_Add_On__c> fpAddOns   = UnitTestDataFactory.createAddOns(testCountryMY.id,testCompanyMY.id,'Test Add On','Deals','test',
				Constants.FP_LIST_ADD_ON_DEVELOPERNAME,10);

		List<Stock_Item__c> stockItems = UnitTestDataFactory.createStockItems(2, 'FP_Stock_Item', fpAccount[0], null, 'A1 - New used', Date.today(), Date.today().addDays(10), Date.today().addDays(-30), '1234567890', '1234567890', 'Korea Telekom', 'In Stock', 'Other');
		insert stockItems;
		Branding_Content__c bContent = new Branding_Content__c(Restaurant_Name__c = fpAccount[0].Id, Opportunity__c = fpOpportunity[0].Id);
		bContent.Status__c = 'Installed Successfully';
		bContent.Type__c = 'White Label App';
		insert bContent;
		List<Asset__c> lstAssets = UnitTestDataFactory.createAssets(10, fpAccount[0], fpOpportunity[0], Date.today().addDays(-10), true, stockItems[0], stockItems[1], 'FP_Asset', '12345674',
				'1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'Activated Successfully',
				Date.today().addDays(20), 'Yazi Logistics', '1234', 'none');
		insert lstAssets;

		List<Add_on_service__c> lstAddOnServices = new List<Add_on_Service__c>();
		Add_on_service__C addTest1 = new Add_on_Service__c();
		addTest1.Account_Name__c = fpAccount[0].Id;
		addTest1.Opportunity__c  = fpOpportunity[0].Id;
		addTest1.Status__c  = Constants.ADD_ON_SERVICE_STATUS_NEW;
		addTest1.recordtypeid=UnitTestDataFactory.mapRecordtypes.get(Constants.FP_ADD_ON_DEVELOPERNAME).id;
		addTest1.Id_List_Add_On__c = fpAddOns[0].Id;
		lstAddOnServices.add(addTest1);
		insert lstAddOnServices;
	}
    
    private static void CreateBasicData(){
		UnitTestDataFactory.getRecordtypeValues();
		testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
		insert testCountry;
		testCompany = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', testCountry);
		insert testCompany;
		Business_Config__c b = new Business_Config__c(Business_Rule_Name__c='AddOnActivationStatus',Business_Rule_Value__c='Active',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='AddOnActivation',Record_Type_Id__c='Yogiyo_Add_On',Type__c='Process');
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='CheckForAddon',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='AddOnActivation',Record_Type_Id__c='Yogiyo_Add_On',Type__c='Process');
        insert new List<sObject>{b,b1};
		
		accounts = UnitTestDataFactory.createAccounts(2, testCountry, 'Yogiyo_Account'); 
		insert accounts; 
		services= UnitTestDataFactory.createServices(testCompany, testCountry, 10, 'Yogiyo_List_Service_Price', 13, 13, 15, 10, 1, '% per Order', true, 299, 'Monthly', 'Commission', 'ServiceType');           
		List<Contact> contactList = UnitTestDataFactory.createContacts(accounts, 'testContact', 'firstname', null, 'owner', 1, 'testCt', 'Yogiyo_Contact');
		opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'Yogiyo_Opportunity', Date.today().addMonths(2));
		insert opportunities;
		Opportunity_Line_Item__c oppServiceItem = UnitTestDataFactory.createOpportunityLineItemService('commission Fee',opportunities[0], services[0].Id, false, 'Yogiyo_Opportunity_Line_Item', 13, null, Date.today(), 'Commission Fee', null);
		insert oppServiceItem;
		oppqsYG = UnitTestDataFactory.createOpportunityQuotes(opportunities[0], 1, 'Yogiyo_Opportunity_Quote', 'Accepted','testdata',10, 10, null,null,0);
		insert oppqsYG;
		insert UnitTestDataFactory.createOpportunityQuoteLineItem(oppqsYG[0],oppServiceItem,'Yogiyo_Opportunity_Quote_Line_Item');
		addOns   = UnitTestDataFactory.createAddOns(testCountry.id,testCompany.id,'Test Add On','Deals','test',
  														'Yogiyo_List_Add_On',10);


		          	
    }
    
}