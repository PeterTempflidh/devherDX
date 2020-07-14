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
 
 
 
@IsTest
private class UnitTestEventBus {
	
	static final String adminAreaLabel = 'admin area 1 test';
	static final String adminArea = 'aat1';
	static final String localityLabel = 'locality';
	static final String locality = 'lco';
	static final String streetLabel = 'street name';
	static final String street = 'str';
	static final String numLabel = '10';
	static final String num = '10';
	static final String zipCOdeLabel = '1010';
	static final String zipCOde = '1010';

        
    private static Country__c testCountry;
    private static Company__c testCompany;
    private static List<Account> accounts;
    
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
       
        UnitTestDataFactory.getRecordtypeValues();
		testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
		insert testCountry;
		testCompany = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', testCountry);
		insert testCompany;
		Integration_Config__c cs1 = new Integration_Config__c(
		Name = 'GoogleMapsSignature', Password__c = 'Abvcd-asdfdgfhjklhnO0=');
		insert cs1;
		
        Business_Config__c b = new Business_Config__c(Business_Rule_Name__c='TypesException',Business_Rule_Value__c='Brand,Group,Holding,Regional / Global HQ',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='FieldsMap',Business_Rule_Value__c='[{"ObjectName":"Account","ObjectField":"Name","EventField":"Account_Name__c"},{"ObjectName":"Account","ObjectField":"ParentId","EventField":"Account_Parent__c"},{"ObjectName":"Account","ObjectField":"Restaurant_Name__c","EventField":"Restaurant_Name__c"},{"ObjectName":"Account","ObjectField":"Phone","EventField":"Account_Phone__c"},{"ObjectName":"Account","ObjectField":"Record_Country__c","EventField":"Account_Country__c"},{"ObjectName":"Account","ObjectField":"Delivery_Service__c","EventField":"Delivery_ServicePicklist__c"},{"ObjectName":"Account","ObjectField":"Payment_Method__c","EventField":"Payment_Method__c"},{"ObjectName":"Account","ObjectField":"Tax_Number__c","EventField":"Tax_Number__c"},{"ObjectName":"Account","ObjectField":"Legal_form__c","EventField":"Legal_Form__c"},{"ObjectName":"Account","ObjectField":"Business_office__c","EventField":"Business_office__c"},{"ObjectName":"Account","ObjectField":"Registration_office__c","EventField":"Registration_office__c"},{"ObjectName":"Account","ObjectField":"Trade_Register_Number__c","EventField":"Trade_Register_Number__c"},{"ObjectName":"Account","ObjectField":"OwnerId","EventField":"Owner_Email__c"},{"ObjectName":"AddressDetail__c","ObjectField":"FormattedAddress__c","EventField":"Address__c"},{"ObjectName":"AddressDetail__c","ObjectField":"LatLng__Latitude__s","EventField":"Latitude__c"},{"ObjectName":"AddressDetail__c","ObjectField":"LatLng__Longitude__s","EventField":"Longitude__c"},{"ObjectName":"Contact","ObjectField":"Salutation","EventField":"Contact_Saludation__c"},{"ObjectName":"Contact","ObjectField":"FirstName","EventField":"Contact_First_Name__c"},{"ObjectName":"Contact","ObjectField":"LastName","EventField":"Contact_Last_Name__c"},{"ObjectName":"Contact","ObjectField":"MiddleName","EventField":"Contact_MiddleName__c"},{"ObjectName":"Contact","ObjectField":"Suffix","EventField":"Contact_Suffix__c"},{"ObjectName":"Contact","ObjectField":"Contact_Role__c","EventField":"Contact_Role__c"},{"ObjectName":"Contact","ObjectField":"MobilePhone","EventField":"Contact_MobilePhone__c"},{"ObjectName":"Contact","ObjectField":"Phone","EventField":"Contact_Phone__c"}]',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='AddressType',Business_Rule_Value__c='Restaurant Address',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='ContactType',Business_Rule_Value__c='Owner',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='PlatformPerfomanceFields',Business_Rule_Value__c='[{"ObjectName":"Platform_Performance__c","ObjectField":"Account__c","EventField":"Account"},{"ObjectName":"Platform_Performance__c","ObjectField":"Platform__c","EventField":"Platform"},{"ObjectName":"Platform_Performance__c","ObjectField":"id","EventField":"id"}]',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
        
        insert new List<sObject>{b,b1,b2,b3,b4};
		
		accounts = UnitTestDataFactory.createAccounts(2, testCountry, 'Yogiyo_Account');
		insert accounts;
		
		
		Platform_Performance__c plaPer = new Platform_Performance__c();
		plaPer.Account__c = accounts[0].Id;
		plaPer.Backend_ID__c = '1234';
		plaPer.Name = '1234';
		insert plaPer;

        AddressDetail__c addr = createAddressDetail(accounts[0].Id, 'Shipping Address', 'Ecuador');
        AddressDetail__c addr2 = createAddressDetail(accounts[0].Id, 'Restaurant Address', 'Ecuador');
        AddressDetail__c addr3 = createAddressDetail(accounts[1].Id, 'Billing Address', 'Ecuador');
        insert addr;
        insert addr2;
		insert addr3;
		
		List<Contact> contactList = UnitTestDataFactory.createContacts(accounts, 'testContact', 'firstname', null, 'owner', 1, 'testCt', 'Yogiyo_Contact');
		insert contactList;
	
		Test.startTest();
	 	
		accounts[0].Name = 'test 2';
		update accounts;
		
		addr.GPA_formatted_address__c = 'whatever';
		update addr;
		
		addr2.GPA_formatted_address__c = 'whatever';
		update addr2;
		
		addr3.GPA_formatted_address__c = 'whatever';
		update addr3;
		
		contactList[0].firstName = 'firstname 2';
		
		update contactList;
		
		plaPer = new Platform_Performance__c();
		plaPer.Account__c = accounts[0].Id;
		plaPer.Backend_ID__c = '1234';
		plaPer.Name = '1234';
		insert plaPer;
		
		Test.stopTest();
		
		List<Log_Error_Message__c> lstErrMs = new List<Log_Error_Message__c>();
		lstErrMs = [SELECT Id FROM Log_Error_Message__c];
		
		System.assert(lstErrMs.size()==0);
    }

	@IsTest
	public static void test_SendingAddressWithEventOnAddressUpdate() {

		UnitTestDataFactory.getRecordtypeValues();
		testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
		insert testCountry;
		testCompany = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', testCountry);
		insert testCompany;
		Integration_Config__c cs1 = new Integration_Config__c(
				Name = 'GoogleMapsSignature', Password__c = 'Abvcd-asdfdgfhjklhnO0=');
		insert cs1;

		Business_Config__c b = new Business_Config__c(Business_Rule_Name__c='TypesException',Business_Rule_Value__c='Brand,Group,Holding,Regional / Global HQ',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
		Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='FieldsMap',Business_Rule_Value__c='[{"ObjectName":"Account","ObjectField":"Name","EventField":"Account_Name__c"},{"ObjectName":"Account","ObjectField":"ParentId","EventField":"Account_Parent__c"},{"ObjectName":"Account","ObjectField":"Restaurant_Name__c","EventField":"Restaurant_Name__c"},{"ObjectName":"Account","ObjectField":"Phone","EventField":"Account_Phone__c"},{"ObjectName":"Account","ObjectField":"Record_Country__c","EventField":"Account_Country__c"},{"ObjectName":"Account","ObjectField":"Delivery_Service__c","EventField":"Delivery_ServicePicklist__c"},{"ObjectName":"Account","ObjectField":"Payment_Method__c","EventField":"Payment_Method__c"},{"ObjectName":"Account","ObjectField":"Tax_Number__c","EventField":"Tax_Number__c"},{"ObjectName":"Account","ObjectField":"Legal_form__c","EventField":"Legal_Form__c"},{"ObjectName":"Account","ObjectField":"Business_office__c","EventField":"Business_office__c"},{"ObjectName":"Account","ObjectField":"Registration_office__c","EventField":"Registration_office__c"},{"ObjectName":"Account","ObjectField":"Trade_Register_Number__c","EventField":"Trade_Register_Number__c"},{"ObjectName":"Account","ObjectField":"OwnerId","EventField":"Owner_Email__c"},{"ObjectName":"AddressDetail__c","ObjectField":"FormattedAddress__c","EventField":"Address__c"},{"ObjectName":"AddressDetail__c","ObjectField":"LatLng__Latitude__s","EventField":"Latitude__c"},{"ObjectName":"AddressDetail__c","ObjectField":"LatLng__Longitude__s","EventField":"Longitude__c"},{"ObjectName":"Contact","ObjectField":"Salutation","EventField":"Contact_Saludation__c"},{"ObjectName":"Contact","ObjectField":"FirstName","EventField":"Contact_First_Name__c"},{"ObjectName":"Contact","ObjectField":"LastName","EventField":"Contact_Last_Name__c"},{"ObjectName":"Contact","ObjectField":"MiddleName","EventField":"Contact_MiddleName__c"},{"ObjectName":"Contact","ObjectField":"Suffix","EventField":"Contact_Suffix__c"},{"ObjectName":"Contact","ObjectField":"Contact_Role__c","EventField":"Contact_Role__c"},{"ObjectName":"Contact","ObjectField":"MobilePhone","EventField":"Contact_MobilePhone__c"},{"ObjectName":"Contact","ObjectField":"Phone","EventField":"Contact_Phone__c"}]',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
		Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='AddressType',Business_Rule_Value__c='Shipping Address',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
		Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='ContactType',Business_Rule_Value__c='Owner',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
		Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='PlatformPerfomanceFields',Business_Rule_Value__c='[{"ObjectName":"Platform_Performance__c","ObjectField":"Account__c","EventField":"Account"},{"ObjectName":"Platform_Performance__c","ObjectField":"Platform__c","EventField":"Platform"},{"ObjectName":"Platform_Performance__c","ObjectField":"id","EventField":"id"}]',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');

		insert new List<sObject>{b,b1,b2,b3,b4};

		accounts = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
		insert accounts;

		Platform_Performance__c plaPer = new Platform_Performance__c();
		plaPer.Account__c = accounts[0].Id;
		plaPer.Backend_ID__c = '1234';
		plaPer.Name = '1234';
		insert plaPer;

		AddressDetail__c addr = createAddressDetail(accounts[0].Id, 'Shipping Address', 'Cuba');
		AddressDetail__c addr2 = createAddressDetail(accounts[0].Id, 'Restaurant Address', 'Ecuador');
		AddressDetail__c addr3 = createAddressDetail(accounts[0].Id, 'Billing Address', 'Ecuador');

        insert new List<AddressDetail__c>{addr, addr2, addr3};
		//Reset static variable from previous execution, since test runs in the same context
		EventBusHelper.stAlreadyProcessed = new Set<Id>();
		Test.startTest();
			Map<Id, AddressDetail__c> addressDetails = new Map<Id, AddressDetail__c>{addr3.Id => addr3};
			List<Backend_Integration__e> eventList = EventBusHelper.ValidateRecords('AddressDetail__c', addressDetails, addressDetails, false);
		Test.stopTest();
		Backend_Integration__e event = eventList.get(0);
		List<AddressDetail__c> parsedAddressDetails = (List<AddressDetail__c>) JSON.deserialize(eventList[0].Addresses__c, List<AddressDetail__c>.class);
		System.assertEquals(3, parsedAddressDetails.size());
		List<EventBusHelper.FieldEventMapping> eventMappings = (List<EventBusHelper.FieldEventMapping>) JSON.deserialize(b4.Business_Rule_Value__c, List<EventBusHelper.FieldEventMapping>.class);
		for (EventBusHelper.FieldEventMapping mapping : eventMappings) {
			if (mapping.ObjectName.equals(String.valueOf(AddressDetail__c.getSObjectType()))) {
				System.assertEquals(addr.get(mapping.ObjectField), event.get(mapping.EventField));
			}
		}
	}

	@IsTest
	public static void test_SendingAddressWithEventOnPlatformInsert() {

		UnitTestDataFactory.getRecordtypeValues();
		testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
		insert testCountry;
		testCompany = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', testCountry);
		insert testCompany;
		Integration_Config__c cs1 = new Integration_Config__c(
				Name = 'GoogleMapsSignature', Password__c = 'Abvcd-asdfdgfhjklhnO0=');
		insert cs1;

		Business_Config__c b = new Business_Config__c(Business_Rule_Name__c='TypesException',Business_Rule_Value__c='Brand,Group,Holding,Regional / Global HQ',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
		Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='FieldsMap',Business_Rule_Value__c='[{"ObjectName":"Platform_Performance__c","ObjectField":"Id","EventField":"Account_Platform__c"},{"ObjectName":"Account","ObjectField":"Name","EventField":"Account_Name__c"},{"ObjectName":"Account","ObjectField":"ParentId","EventField":"Account_Parent__c"},{"ObjectName":"Account","ObjectField":"Restaurant_Name__c","EventField":"Restaurant_Name__c"},{"ObjectName":"Account","ObjectField":"Phone","EventField":"Account_Phone__c"},{"ObjectName":"Account","ObjectField":"Record_Country__c","EventField":"Account_Country__c"},{"ObjectName":"Account","ObjectField":"Delivery_Service__c","EventField":"Delivery_ServicePicklist__c"},{"ObjectName":"Account","ObjectField":"Payment_Method__c","EventField":"Payment_Method__c"},{"ObjectName":"Account","ObjectField":"Tax_Number__c","EventField":"Tax_Number__c"},{"ObjectName":"Account","ObjectField":"Legal_form__c","EventField":"Legal_Form__c"},{"ObjectName":"Account","ObjectField":"Business_office__c","EventField":"Business_office__c"},{"ObjectName":"Account","ObjectField":"Registration_office__c","EventField":"Registration_office__c"},{"ObjectName":"Account","ObjectField":"Trade_Register_Number__c","EventField":"Trade_Register_Number__c"},{"ObjectName":"Account","ObjectField":"OwnerId","EventField":"Owner_Email__c"},{"ObjectName":"AddressDetail__c","ObjectField":"FormattedAddress__c","EventField":"Address__c"},{"ObjectName":"AddressDetail__c","ObjectField":"LatLng__Latitude__s","EventField":"Latitude__c"},{"ObjectName":"AddressDetail__c","ObjectField":"LatLng__Longitude__s","EventField":"Longitude__c"},{"ObjectName":"Contact","ObjectField":"Salutation","EventField":"Contact_Saludation__c"},{"ObjectName":"Contact","ObjectField":"FirstName","EventField":"Contact_First_Name__c"},{"ObjectName":"Contact","ObjectField":"LastName","EventField":"Contact_Last_Name__c"},{"ObjectName":"Contact","ObjectField":"MiddleName","EventField":"Contact_MiddleName__c"},{"ObjectName":"Contact","ObjectField":"Suffix","EventField":"Contact_Suffix__c"},{"ObjectName":"Contact","ObjectField":"Contact_Role__c","EventField":"Contact_Role__c"},{"ObjectName":"Contact","ObjectField":"MobilePhone","EventField":"Contact_MobilePhone__c"},{"ObjectName":"Contact","ObjectField":"Phone","EventField":"Contact_Phone__c"}]',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
		Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='AddressType',Business_Rule_Value__c='Shipping Address',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
		Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='ContactType',Business_Rule_Value__c='Owner',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
		Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='PlatformPerfomanceFields',Business_Rule_Value__c='[{"ObjectName":"Platform_Performance__c","ObjectField":"Account__c","EventField":"Account"},{"ObjectName":"Platform_Performance__c","ObjectField":"Platform__c","EventField":"Platform"},{"ObjectName":"Platform_Performance__c","ObjectField":"id","EventField":"id"}]',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');

		insert new List<sObject>{b,b1,b2,b3,b4};

		accounts = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
		insert accounts;

		Platform_Performance__c plaPer = new Platform_Performance__c();
		plaPer.Account__c = accounts[0].Id;
		plaPer.Backend_ID__c = '1234';
		plaPer.Name = '1234';
		insert plaPer;

		AddressDetail__c addr = createAddressDetail(accounts[0].Id, 'Shipping Address', 'Ecuador');
		AddressDetail__c addr2 = createAddressDetail(accounts[0].Id, 'Restaurant Address', 'Ecuador');
		AddressDetail__c addr3 = createAddressDetail(accounts[0].Id, 'Billing Address', 'Ecuador');

		insert new List<AddressDetail__c>{addr, addr2, addr3};
		//Reset static variable from previous execution, since test runs in the same context
		EventBusHelper.stAlreadyProcessed = new Set<Id>();
		Test.startTest();
		Map<Id, Platform_Performance__c> platformPerformances = new Map<Id, Platform_Performance__c>{plaPer.Id => plaPer};
		List<Backend_Integration__e> eventList = EventBusHelper.ValidateRecordsPlatform('Platform', platformPerformances);
		Test.stopTest();
		Backend_Integration__e event = eventList.get(0);
		List<AddressDetail__c> parsedAddressDetails = (List<AddressDetail__c>) JSON.deserialize(eventList[0].Addresses__c, List<AddressDetail__c>.class);
		System.assertEquals(3, parsedAddressDetails.size());
		List<EventBusHelper.FieldEventMapping> eventMappings = (List<EventBusHelper.FieldEventMapping>) JSON.deserialize(b4.Business_Rule_Value__c, List<EventBusHelper.FieldEventMapping>.class);
		for (EventBusHelper.FieldEventMapping mapping : eventMappings) {
			if (mapping.ObjectName.equals(String.valueOf(AddressDetail__c.getSObjectType()))) {
				System.assertEquals(addr.get(mapping.ObjectField), event.get(mapping.EventField));
			}
		}
	}

	/**
     * Description: The method checks that a contact with contact role added in EventBus business config are published as platform event.
     */
	@IsTest
	public static void test_SendingContactsPositive() {

		UnitTestDataFactory.getRecordtypeValues();
		testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
		insert testCountry;
		testCompany = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', testCountry);
		insert testCompany;

		Business_Config__c b = new Business_Config__c(Business_Rule_Name__c='TypesException',Business_Rule_Value__c='Brand,Group,Holding,Regional / Global HQ',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
		Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='FieldsMap',Business_Rule_Value__c='[{"ObjectName":"Account","ObjectField":"Name","EventField":"Account_Name__c"},{"ObjectName":"Account","ObjectField":"ParentId","EventField":"Account_Parent__c"},{"ObjectName":"Account","ObjectField":"Restaurant_Name__c","EventField":"Restaurant_Name__c"},{"ObjectName":"Account","ObjectField":"Phone","EventField":"Account_Phone__c"},{"ObjectName":"Account","ObjectField":"Record_Country__c","EventField":"Account_Country__c"},{"ObjectName":"Account","ObjectField":"Delivery_Service__c","EventField":"Delivery_ServicePicklist__c"},{"ObjectName":"Account","ObjectField":"Payment_Method__c","EventField":"Payment_Method__c"},{"ObjectName":"Account","ObjectField":"Tax_Number__c","EventField":"Tax_Number__c"},{"ObjectName":"Account","ObjectField":"Legal_form__c","EventField":"Legal_Form__c"},{"ObjectName":"Account","ObjectField":"Business_office__c","EventField":"Business_office__c"},{"ObjectName":"Account","ObjectField":"Registration_office__c","EventField":"Registration_office__c"},{"ObjectName":"Account","ObjectField":"Trade_Register_Number__c","EventField":"Trade_Register_Number__c"},{"ObjectName":"Account","ObjectField":"OwnerId","EventField":"Owner_Email__c"},{"ObjectName":"AddressDetail__c","ObjectField":"FormattedAddress__c","EventField":"Address__c"},{"ObjectName":"AddressDetail__c","ObjectField":"LatLng__Latitude__s","EventField":"Latitude__c"},{"ObjectName":"AddressDetail__c","ObjectField":"LatLng__Longitude__s","EventField":"Longitude__c"},{"ObjectName":"Contact","ObjectField":"Salutation","EventField":"Contact_Saludation__c"},{"ObjectName":"Contact","ObjectField":"FirstName","EventField":"Contact_First_Name__c"},{"ObjectName":"Contact","ObjectField":"LastName","EventField":"Contact_Last_Name__c"},{"ObjectName":"Contact","ObjectField":"MiddleName","EventField":"Contact_MiddleName__c"},{"ObjectName":"Contact","ObjectField":"Suffix","EventField":"Contact_Suffix__c"},{"ObjectName":"Contact","ObjectField":"Contact_Role__c","EventField":"Contact_Role__c"},{"ObjectName":"Contact","ObjectField":"MobilePhone","EventField":"Contact_MobilePhone__c"},{"ObjectName":"Contact","ObjectField":"Phone","EventField":"Contact_Phone__c"}]',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
		Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='AddressType',Business_Rule_Value__c='Shipping Address',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
		Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='ContactType',Business_Rule_Value__c='Owner,Manager',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
		Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='PlatformPerfomanceFields',Business_Rule_Value__c='[{"ObjectName":"Platform_Performance__c","ObjectField":"Account__c","EventField":"Account"},{"ObjectName":"Platform_Performance__c","ObjectField":"Platform__c","EventField":"Platform"},{"ObjectName":"Platform_Performance__c","ObjectField":"id","EventField":"id"}]',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');

		insert new List<sObject>{b,b1,b2,b3,b4};

		accounts = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
		insert accounts;

		Platform_Performance__c plaPer = new Platform_Performance__c();
		plaPer.Account__c = accounts[0].Id;
		plaPer.Backend_ID__c = '1234';
		plaPer.Name = '1234';
		insert plaPer;

		Contact testManager = new Contact(FirstName='TestContact', LastName='Manager', Contact_Role__c='Owner', AccountId = accounts.get(0).Id, RecordTypeId = UnitTestDataFactory.mapRecordtypes.get('Yogiyo_Contact').Id);

		insert testManager;
		Map<Id, Contact> testContactMap = new Map<Id, Contact>{testManager.Id => testManager};
		//Reset static variable from previous execution, since test runs in the same context
		EventBusHelper.stAlreadyProcessed = new Set<Id>();

		Test.startTest();
		List<Backend_Integration__e> eventList = EventBusHelper.ValidateRecords('Contact', testContactMap, testContactMap, false);
		Test.stopTest();
		Backend_Integration__e event = eventList.get(0);
		System.assertEquals(event.Contact_First_Name__c, testManager.FirstName);
		System.assertEquals(event.Contact_Last_Name__c, testManager.LastName);
		System.assertEquals(event.Contact_Role__c, testManager.Contact_Role__c);
		System.assertNotEquals(event.Contacts__c, null);
	}

	/**
     * Description: The method checks that a contact with contact role NOT added in EventBus business config is NOT published as platform event.
     */
	@IsTest
	public static void test_SendingContactsNegetive() {

		UnitTestDataFactory.getRecordtypeValues();
		testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
		insert testCountry;
		testCompany = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', testCountry);
		insert testCompany;

		Business_Config__c b = new Business_Config__c(Business_Rule_Name__c='TypesException',Business_Rule_Value__c='Brand,Group,Holding,Regional / Global HQ',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
		Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='FieldsMap',Business_Rule_Value__c='[{"ObjectName":"Account","ObjectField":"Name","EventField":"Account_Name__c"},{"ObjectName":"Account","ObjectField":"ParentId","EventField":"Account_Parent__c"},{"ObjectName":"Account","ObjectField":"Restaurant_Name__c","EventField":"Restaurant_Name__c"},{"ObjectName":"Account","ObjectField":"Phone","EventField":"Account_Phone__c"},{"ObjectName":"Account","ObjectField":"Record_Country__c","EventField":"Account_Country__c"},{"ObjectName":"Account","ObjectField":"Delivery_Service__c","EventField":"Delivery_ServicePicklist__c"},{"ObjectName":"Account","ObjectField":"Payment_Method__c","EventField":"Payment_Method__c"},{"ObjectName":"Account","ObjectField":"Tax_Number__c","EventField":"Tax_Number__c"},{"ObjectName":"Account","ObjectField":"Legal_form__c","EventField":"Legal_Form__c"},{"ObjectName":"Account","ObjectField":"Business_office__c","EventField":"Business_office__c"},{"ObjectName":"Account","ObjectField":"Registration_office__c","EventField":"Registration_office__c"},{"ObjectName":"Account","ObjectField":"Trade_Register_Number__c","EventField":"Trade_Register_Number__c"},{"ObjectName":"Account","ObjectField":"OwnerId","EventField":"Owner_Email__c"},{"ObjectName":"AddressDetail__c","ObjectField":"FormattedAddress__c","EventField":"Address__c"},{"ObjectName":"AddressDetail__c","ObjectField":"LatLng__Latitude__s","EventField":"Latitude__c"},{"ObjectName":"AddressDetail__c","ObjectField":"LatLng__Longitude__s","EventField":"Longitude__c"},{"ObjectName":"Contact","ObjectField":"Salutation","EventField":"Contact_Saludation__c"},{"ObjectName":"Contact","ObjectField":"FirstName","EventField":"Contact_First_Name__c"},{"ObjectName":"Contact","ObjectField":"LastName","EventField":"Contact_Last_Name__c"},{"ObjectName":"Contact","ObjectField":"MiddleName","EventField":"Contact_MiddleName__c"},{"ObjectName":"Contact","ObjectField":"Suffix","EventField":"Contact_Suffix__c"},{"ObjectName":"Contact","ObjectField":"Contact_Role__c","EventField":"Contact_Role__c"},{"ObjectName":"Contact","ObjectField":"MobilePhone","EventField":"Contact_MobilePhone__c"},{"ObjectName":"Contact","ObjectField":"Phone","EventField":"Contact_Phone__c"}]',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
		Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='AddressType',Business_Rule_Value__c='Shipping Address',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
		Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='ContactType',Business_Rule_Value__c='Owner',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
		Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='PlatformPerfomanceFields',Business_Rule_Value__c='[{"ObjectName":"Platform_Performance__c","ObjectField":"Account__c","EventField":"Account"},{"ObjectName":"Platform_Performance__c","ObjectField":"Platform__c","EventField":"Platform"},{"ObjectName":"Platform_Performance__c","ObjectField":"id","EventField":"id"}]',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');

		insert new List<sObject>{b,b1,b2,b3,b4};

		accounts = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
		insert accounts;

		Platform_Performance__c plaPer = new Platform_Performance__c();
		plaPer.Account__c = accounts[0].Id;
		plaPer.Backend_ID__c = '1234';
		plaPer.Name = '1234';
		insert plaPer;

		Contact testManager = new Contact(FirstName='TestContact', LastName='Manager', Contact_Role__c='Manager', AccountId = accounts.get(0).Id, RecordTypeId = UnitTestDataFactory.mapRecordtypes.get('Yogiyo_Contact').Id);

		insert testManager;
		Map<Id, Contact> testContactMap = new Map<Id, Contact>{testManager.Id => testManager};
		//Reset static variable from previous execution, since test runs in the same context
		EventBusHelper.stAlreadyProcessed = new Set<Id>();

		Test.startTest();
		List<Backend_Integration__e> eventList = EventBusHelper.ValidateRecords('Contact', testContactMap, testContactMap, false);
		Test.stopTest();

		System.assertEquals(0, eventList.size());
	}

    private static AddressDetail__c createAddressDetail(Id accountId, String type, String countryName) {
        return new AddressDetail__c(
                Type__c = type,
                LatLng__Longitude__s = 10.0,
                LatLng__Latitude__s = 5.0,
                Account__c = accountId,

                GPA_Country_long_name__c = 'Ecuador',
                GPA_Country_short_name__c = 'EC',

                GPA_Admin_area_level_1_long_name__c = adminAreaLabel,
                GPA_Admin_area_level_1_short_name__c = adminArea,

                GPA_Locality_long_name__c = localityLabel,
                GPA_Locality_short_name__c = locality,

                GPA_Route_long_name__c = streetLabel,
                GPA_Route_short_name__c = street,

                GPA_Street_number_long_name__c = numLabel,
                GPA_Street_number_short_name__c = num,

                GPA_Postal_code_long_name__c = zipCOdeLabel,
                GPA_Postal_code_short_name__c = zipCOde,

                GPA_Place_id__c = '12344',
                GPA_formatted_address__c = 'whatever bla bla',
                GPA_Was_modified_manually__c = false
        );
    }
}