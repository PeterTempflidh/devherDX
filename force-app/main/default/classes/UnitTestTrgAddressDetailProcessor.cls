/**
 * Created by marco.zeuli on 25/8/2017.
 */

@IsTest
private class UnitTestTrgAddressDetailProcessor {
	static final String testPostCode = 'Test_Scenario_PostCode';
	static final String testAdminArea = 'Test_Scenario_AdminArea';
	static final String testAdminAreaLabel = 'Test Scenario AdminArea';
	static final String testLocality = 'Test_Scenario_Locality';
	static final String testSubArea = 'Test_Scenario_SubArea';
	static final String testCountry = 'Test_Scenario_Country';
	static final String testCountryLabel = 'Test Scenario Country';
	static final String testDependentLocality = 'Test_Scenario_DependentLocality';

	static final xAL_Country__mdt country = [
	        SELECT DeveloperName, MasterLabel, Code__c
	        FROM xAL_Country__mdt
	        WHERE DeveloperName = :testCountry
	                                        ];

	static final xAL_AdministrativeArea__mdt area = [
	            SELECT DeveloperName, MasterLabel, Type__c, Code__c
	            FROM xAL_AdministrativeArea__mdt
	            WHERE DeveloperName = :testAdminArea
	        ];

	static final xAL_SubAdministrativeAreas__mdt subArea = [
	            SELECT DeveloperName, MasterLabel, Type__c, Code__c
	            FROM xAL_SubAdministrativeAreas__mdt
	            WHERE DeveloperName = :testSubArea
	        ];

	static final xAL_Locality__mdt locality = [
	            SELECT DeveloperName, MasterLabel, Type__c, Code__c
	            FROM xAL_Locality__mdt
	            WHERE DeveloperName = :testLocality
	        ];

	static final xAL_Locality__mdt dependentLocality = [
	            SELECT DeveloperName, MasterLabel, Type__c, Code__c
	            FROM xAL_Locality__mdt
	            WHERE DeveloperName = :testDependentLocality
	        ];

	static final xAL_PostalCode__mdt zipcode = [
	            SELECT DeveloperName, MasterLabel, Number__c
	            FROM xAL_PostalCode__mdt
	            WHERE DeveloperName = :testPostCode
	        ];

	@TestSetup static void setup() {
		UnitTestDataFactory.getRecordtypeValues();


		Integration_Config__c cs1 = new Integration_Config__c(
		    Name = 'GoogleMapsSignature', Password__c = 'Abvcd-asdfdgfhjklhnO0=');
		insert cs1;

		Country__c c = UnitTestDataFactory.createCountry('EC', testCountryLabel, 'USD');
		insert c;

		Account a = UnitTestDataFactory.createAccount('test', c, 'CD_Account');
		insert a;

		AddressDetail__c addr = new AddressDetail__c(

		    Type__c = 'Restaurant Address;Billing Address',
		    Account__c = a.Id,

		    LatLng__Latitude__s = 10.0,
		    LatLng__Longitude__s = 5.0,

		    AddressLine__c = 'amazing add line....',

		    CountryDevName__c = country.DeveloperName,
		    CountryName__c = country.MasterLabel,
		    CountryCode__c = country.Code__c,

		    AdministrativeAreaDevName__c = area.DeveloperName,
		    AdministrativeAreaName__c = area.MasterLabel,
		    AdministrativeAreaCode__c = area.Code__c,
		    AdministrativeAreaType__c = area.Type__c,

		    SubAdministratriveAreaDevName__c = subArea.DeveloperName,
		    SubAdministrativeAreaName__c = subArea.MasterLabel,
		    SubAdministrativeAreaCode__c = subArea.Code__c,
		    SubAdministrativeAreaType__c = subArea.Type__c,

		    LocalityDevName__c = locality.DeveloperName,
		    LocalityName__c = locality.MasterLabel,
		    LocalityType__c = locality.Type__c,
		    LocalityCode__c = locality.Code__c,

		    DependentLocalityDevName_1__c = dependentLocality.DeveloperName,
		    DependentLocalityName_1__c = dependentLocality.MasterLabel,
		    DependentLocalityType_1__c = dependentLocality.Type__c,
		    DependentlocalityCode_1__c = dependentLocality.Code__c,

		    PostalCodeDevName__c = zipcode.DeveloperName,
		    PostalCodeName__c = zipcode.Number__c
		);

		insert addr;
	}

	@IsTest static void generateSignedUrlForMapImageSkipsAddressWithInvalidCoordintaes() {
		AddressDetail__c addr = new AddressDetail__c(
		    Type__c = 'Shipping Address',
		    Account__c = [SELECT Id FROM Account LIMIT 1].Id,

		    AddressLine__c = 'amazing add line....',

		    CountryDevName__c = country.DeveloperName,
		    CountryName__c = country.MasterLabel,
		    CountryCode__c = country.Code__c,

		    AdministrativeAreaDevName__c = area.DeveloperName,
		    AdministrativeAreaName__c = area.MasterLabel,
		    AdministrativeAreaCode__c = area.Code__c,
		    AdministrativeAreaType__c = area.Type__c,

		    SubAdministratriveAreaDevName__c = subArea.DeveloperName,
		    SubAdministrativeAreaName__c = subArea.MasterLabel,
		    SubAdministrativeAreaCode__c = subArea.Code__c,
		    SubAdministrativeAreaType__c = subArea.Type__c,

		    LocalityDevName__c = locality.DeveloperName,
		    LocalityName__c = locality.MasterLabel,
		    LocalityType__c = locality.Type__c,
		    LocalityCode__c = locality.Code__c,

		    DependentLocalityDevName_1__c = dependentLocality.DeveloperName,
		    DependentLocalityName_1__c = dependentLocality.MasterLabel,
		    DependentLocalityType_1__c = dependentLocality.Type__c,
		    DependentlocalityCode_1__c = dependentLocality.Code__c,

		    PostalCodeDevName__c = zipcode.DeveloperName,
		    PostalCodeName__c = zipcode.Number__c
		);

		Test.startTest();

		insert addr;

		Test.stopTest();

		AddressDetail__c res = [SELECT SignedGoogleMapsPathRequest__c FROM AddressDetail__c WHERE Id = :addr.Id];

		System.assert(String.isBlank(res.SignedGoogleMapsPathRequest__c));
	}

	@IsTest static void generateSignedUrlForMapImageResetSignedUrlIfCoordinatesAreBlank() {
		AddressDetail__c addr = [SELECT LatLng__latitude__s, LatLng__longitude__s FROM AddressDetail__c LIMIT 1];

		addr.LatLng__longitude__s = null;
		addr.LatLng__latitude__s = null;

		Test.startTest();

		update addr;

		Test.stopTest();

		AddressDetail__c res = [SELECT SignedGoogleMapsPathRequest__c FROM AddressDetail__c WHERE Id = :addr.Id];

		System.assert(String.isBlank(res.SignedGoogleMapsPathRequest__c));
	}

	@IsTest static void generateSignedUrlForMapImageSkipsRecordWithNoChangesInCoordinates() {
		AddressDetail__c addr = [SELECT PostalCodeName__c, SignedGoogleMapsPathRequest__c FROM AddressDetail__c LIMIT 1];

		addr.PostalCodeName__c = 'whatever';

		Test.startTest();

		update addr;

		Test.stopTest();

		AddressDetail__c res = [SELECT SignedGoogleMapsPathRequest__c FROM AddressDetail__c WHERE Id = :addr.Id];

		System.assertEquals(addr.SignedGoogleMapsPathRequest__c, res.SignedGoogleMapsPathRequest__c);
	}

	@IsTest static void generateSignedUrlForMapImageSetSignedUrlForNewRecords() {
		AddressDetail__c addr = new AddressDetail__c(
		    Type__c = 'Shipping Address',
		    Account__c = [SELECT Id FROM Account LIMIT 1].Id,

		    AddressLine__c = 'amazing add line....',

		    LatLng__longitude__s = 10.5,
		    LatLng__latitude__s = 10.5,

		    CountryDevName__c = country.DeveloperName,
		    CountryName__c = country.MasterLabel,
		    CountryCode__c = country.Code__c,

		    AdministrativeAreaDevName__c = area.DeveloperName,
		    AdministrativeAreaName__c = area.MasterLabel,
		    AdministrativeAreaCode__c = area.Code__c,
		    AdministrativeAreaType__c = area.Type__c,

		    SubAdministratriveAreaDevName__c = subArea.DeveloperName,
		    SubAdministrativeAreaName__c = subArea.MasterLabel,
		    SubAdministrativeAreaCode__c = subArea.Code__c,
		    SubAdministrativeAreaType__c = subArea.Type__c,

		    LocalityDevName__c = locality.DeveloperName,
		    LocalityName__c = locality.MasterLabel,
		    LocalityType__c = locality.Type__c,
		    LocalityCode__c = locality.Code__c,

		    DependentLocalityDevName_1__c = dependentLocality.DeveloperName,
		    DependentLocalityName_1__c = dependentLocality.MasterLabel,
		    DependentLocalityType_1__c = dependentLocality.Type__c,
		    DependentlocalityCode_1__c = dependentLocality.Code__c,

		    PostalCodeDevName__c = zipcode.DeveloperName,
		    PostalCodeName__c = zipcode.Number__c
		);

		Test.startTest();

		insert addr;

		Test.stopTest();

		AddressDetail__c res = [SELECT SignedGoogleMapsPathRequest__c FROM AddressDetail__c WHERE Id = :addr.Id];

		System.assert(String.isNotBlank(res.SignedGoogleMapsPathRequest__c));
	}

	@IsTest static void generateSignedUrlForMapImageUpdateSignedUrlForUpdatedRecords() {
		AddressDetail__c addr = [SELECT LatLng__latitude__s, LatLng__longitude__s, SignedGoogleMapsPathRequest__c FROM AddressDetail__c LIMIT 1];

		addr.LatLng__Longitude__s = addr.LatLng__longitude__s + 1.0;
		addr.LatLng__Latitude__s = addr.LatLng__Latitude__s + 1.0; 

		Test.startTest();

		update addr;

		Test.stopTest();

		AddressDetail__c res = [SELECT SignedGoogleMapsPathRequest__c FROM AddressDetail__c WHERE Id = :addr.Id];

		System.assert(String.isNotBlank(res.SignedGoogleMapsPathRequest__c));	
		System.assertNotEquals(addr.SignedGoogleMapsPathRequest__c, res.SignedGoogleMapsPathRequest__c);
	}

	// without admin area
	@IsTest static void checksDuplicateAddressTypesPerAccountThrowExceptionIfNewAddressIsDuplicate() {
		AddressDetail__c addr = [
		                            SELECT
		                            Account__c,
		                            AddressLine__c,
		                            AdministrativeAreaCode__c,
		                            AdministrativeAreaType__c,
		                            AdministrativeAreaName__c,
		                            AdministrativeAreaDevName__c,
		                            CountryName__c,
		                            CountryDevName__c,
		                            CountryCode__c,
		                            LocalityCode__c,
		                            LocalityName__c,
		                            LocalityType__c,
		                            LocalityDevName__c,
		                            DependentlocalityCode_1__c,
		                            DependentLocalityDevName_1__c,
		                            DependentLocalityName_1__c,
		                            DependentLocalityType_1__c,
		                            DependentlocalityCode_2__c,
		                            DependentLocalityDevName_2__c,
		                            DependentLocalityName_2__c,
		                            DependentLocalityType_2__c,
		                            DependentlocalityCode_3__c,
		                            DependentLocalityDevName_3__c,
		                            DependentLocalityName_3__c,
		                            DependentLocalityType_3__c,
		                            PostalCodeName__c,
		                            PostalCodeDevName__c,
		                            SubAdministrativeAreaCode__c,
		                            SubAdministrativeAreaName__c,
		                            SubAdministrativeAreaType__c,
		                            SubAdministratriveAreaDevName__c,
		                            Type__c,
		                            LatLng__longitude__s,
		                            LatLng__latitude__s
		                            FROM AddressDetail__c
		                            LIMIT 1
		                        ];

		AddressDetail__c newAddr = addr.clone();

		Boolean throwed = false;

		Test.startTest();

		try {
			insert newAddr;
		} catch (DmlException exc) {
			throwed = true;
		}

		Test.stopTest();

		System.assert(throwed);
	}

	@IsTest static void checksDuplicateAddressTypesPerAccountThrowExceptionIfAddressIsDuplicateDuringBulkLoad() {
		AddressDetail__c addr = [
		                            SELECT
		                            Account__c,
		                            AddressLine__c,
		                            AdministrativeAreaCode__c,
		                            AdministrativeAreaType__c,
		                            AdministrativeAreaName__c,
		                            AdministrativeAreaDevName__c,
		                            CountryName__c,
		                            CountryDevName__c,
		                            CountryCode__c,
		                            LocalityCode__c,
		                            LocalityName__c,
		                            LocalityType__c,
		                            LocalityDevName__c,
		                            DependentlocalityCode_1__c,
		                            DependentLocalityDevName_1__c,
		                            DependentLocalityName_1__c,
		                            DependentLocalityType_1__c,
		                            DependentlocalityCode_2__c,
		                            DependentLocalityDevName_2__c,
		                            DependentLocalityName_2__c,
		                            DependentLocalityType_2__c,
		                            DependentlocalityCode_3__c,
		                            DependentLocalityDevName_3__c,
		                            DependentLocalityName_3__c,
		                            DependentLocalityType_3__c,
		                            PostalCodeName__c,
		                            PostalCodeDevName__c,
		                            SubAdministrativeAreaCode__c,
		                            SubAdministrativeAreaName__c,
		                            SubAdministrativeAreaType__c,
		                            SubAdministratriveAreaDevName__c,
		                            Type__c,
		                            LatLng__longitude__s,
		                            LatLng__latitude__s
		                            FROM AddressDetail__c
		                            LIMIT 1
		                        ];

		AddressDetail__c newAddr = addr.clone();
		AddressDetail__c newAddr2 = addr.clone();

		delete addr;

		Test.startTest();

		System.debug(LoggingLevel.ERROR, 'add1 acc:' + newAddr.Account__c);
		System.debug(LoggingLevel.ERROR, 'add2 acc:' + newAddr2.Account__c);

		try {
			insert new List<AddressDetail__c> {
				newAddr, newAddr2

			};
			System.assert(false);
		} catch (DmlException exc) {
			System.assert(true);
		}
		newAddr.Type__c = 'Shipping Address';
		newAddr.DAUM_Address_Model__c = 'Old Address';

		newAddr2.Type__c = 'Billing Address';
		newAddr2.DAUM_Address_Model__c = 'Old Address';

		try {
			insert new List<AddressDetail__c> {
					newAddr, newAddr2

			};
			System.assert(true);
		} catch (DmlException exc) {
			System.assert(false);
		}

		newAddr.Type__c = 'Shipping Address;Billing Address';

		try {
			update newAddr;
			System.assert(false, 'Update address validation failed');
		} catch (DmlException exc) {
			System.assert(true);
		}

		Test.stopTest();

	}

	/*******************************************************************************************************
    * @description Test class to update the kitchen address when facility address is getting updated
    */
	@isTest
	static void methodToCheckUpdateKitchenAddress(){
		UnitTestDataFactory.getRecordtypeValues();

		Country__c hk = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'HKD');
		Database.insert(hk);
		Company__c com = UnitTestDataFactory.createCompany('Foodpanda Hong Kong', 'FP', hk);
		insert com;

		// CREATE ACCOUNT
		Account accTemp;
		List<Account> accountList = new List<Account>();
		for(Integer counter = 0; counter < 2; counter++){
			accTemp = UnitTestDataFactory.createAccount('Test FP ' + (counter + 1), hk, 'Facility_Account');
			accTemp.Type = 'Facility';
			accountList.add(accTemp);
		}
		insert accountList;

		//CREATE CONTACT
		List<Contact> conList = UnitTestDataFactory.createContacts(accountList, 'FP Contact', 'Test', '', 'Owner', 1, 'testFPContact', 'FP_Contact');
		conList[0].Contact_Role__c = 'Manager';
		conList[1].FirstName = null;
		conList[1].Phone = null;
		conList[1].Email = null;
		insert conList;


		//CREATE ADDRESS DETAILS
		Integration_Config__c cs1 = new Integration_Config__c(
				Name = 'GoogleMapsSignature', Password__c = 'Abvcd-asdfdgfhjklhnO0='
		);
		insert cs1;
		AddressDetail__c addDetail = new AddressDetail__c(

				Type__c = 'Billing Address',
				Account__c = accountList[0].Id,

				LatLng__Latitude__s = 10.0,
				LatLng__Longitude__s = 5.0,

				AddressLine__c = 'amazing add line....'
		);
		insert addDetail;
		Account acc     = UnitTestDataFactory.createAccount('TestAccount1', hk, 'FP_Account');
		acc.Phone = '+85227367722';
		acc.Type ='Branch - Main';
		acc.Facility__c = accountList[0].id;
		insert acc;

		Test.startTest();
		addDetail.AddressLine__c='test update';
		update addDetail;
		Test.stopTest();
		System.assertEquals(accountList[0].id,acc.Facility__c);
	}
}