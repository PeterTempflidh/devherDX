/**
* Created by marco.zeuli on 25/8/2017.
*/

@IsTest
private class UnitTestxALAddressDetails {
	static final String testPostCode = 'Test_Scenario_PostCode';
	static final String testAdminArea = 'Test_Scenario_AdminArea';
	static final String testLocality = 'Test_Scenario_Locality';
	static final String testSubArea = 'Test_Scenario_SubArea';
	static final String testCountry = 'Test_Scenario_Country';
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

		Country__c c = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
		insert c;

		Account a = UnitTestDataFactory.createAccount('test', c, 'CD_Account');
		insert a;

		AddressDetail__c addr = new AddressDetail__c(
		    Type__c = 'Restaurant Address;Billing Address',
		    Account__c = a.Id,

		    LatLng__Latitude__s = 10.0,
		    LatLng__Longitude__s = 5.0,

		    AddressLine__c = 'amazing address',

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

	@IsTest static void xALAddressDetailsInstantiateCorrectly() {
		AddressDetail__c addrRecord = [
		                                  SELECT Id, AddressLine__c, LatLng__Longitude__s, LatLng__Latitude__s, Account__c, Type__c
		                                  FROM AddressDetail__c
		                                  LIMIT 1
		                              ];

		xALAddressDetails addr;

		Test.startTest();

		addr = new xALAddressDetails(addrRecord.Id);

		Test.stopTest();

		System.assertNotEquals(null, addr);

		System.assertEquals(addrRecord.AddressLine__c, addr.addressLine);
		System.assertEquals(addrRecord.LatLng__Latitude__s, addr.latitude);
		System.assertEquals(addrRecord.LatLng__Longitude__s, addr.longitude);
		System.assertEquals(addrRecord.Account__c, addr.account);

		Set<String> types = new Set<String>(addr.type);

		for (String type : addrRecord.Type__c.split(';')) {
			System.assert(types.contains(type), 'Type missing: ' + type);
		}

		// checks country
		System.assertEquals(country.DeveloperName, addr.country.developerName);
		System.assertEquals(country.MasterLabel, addr.country.label);
		System.assertEquals(country.Code__c, addr.country.code);

		// checks admin area
		System.assertEquals(area.DeveloperName, addr.country.adminArea.developerName);
		System.assertEquals(area.MasterLabel, addr.country.adminArea.label);
		System.assertEquals(area.Code__c, addr.country.adminArea.code);
		System.assertEquals(area.Type__c, addr.country.adminArea.type);

		// checks sub area
		System.assertEquals(subArea.DeveloperName, addr.country.adminArea.subAdministrativeArea.developerName);
		System.assertEquals(subArea.MasterLabel, addr.country.adminArea.subAdministrativeArea.label);
		System.assertEquals(subArea.Code__c, addr.country.adminArea.subAdministrativeArea.code);
		System.assertEquals(subArea.Type__c, addr.country.adminArea.subAdministrativeArea.type);

		// checks locality
		System.assertEquals(locality.DeveloperName, addr.country.adminArea.subAdministrativeArea.locality.developerName);
		System.assertEquals(locality.MasterLabel, addr.country.adminArea.subAdministrativeArea.locality.label);
		System.assertEquals(locality.Type__c, addr.country.adminArea.subAdministrativeArea.locality.type);
		System.assertEquals(locality.Code__c, addr.country.adminArea.subAdministrativeArea.locality.code);

		// checks dep locality
		System.assertEquals(dependentLocality.DeveloperName, addr.country.adminArea.subAdministrativeArea.locality.dependentLocality.developerName);
		System.assertEquals(dependentLocality.MasterLabel, addr.country.adminArea.subAdministrativeArea.locality.dependentLocality.label);
		System.assertEquals(dependentLocality.Type__c, addr.country.adminArea.subAdministrativeArea.locality.dependentLocality.type);
		System.assertEquals(dependentLocality.Code__c, addr.country.adminArea.subAdministrativeArea.locality.dependentLocality.code);
	}

	@IsTest static void saveInsertNewAddressCorrectly_1() {
		Account a = [SELECT Id FROM Account LIMIT 1];
		xALAddressDetails newAddr = new xALAddressDetails();
		Id res;

		newAddr.type = new List<String> {
			'Shipping Address'
		};
		newAddr.addressLine = 'Go to hell!! :D';
		newAddr.account = a.Id;
		newAddr.latitude = 15.0;
		newAddr.longitude = 10.0;

		newAddr.country = xALCountry.byName(testCountry);
		newAddr.country.adminArea = xALAdministrativeArea.byName(testAdminArea);
		newAddr.country.adminArea.subAdministrativeArea = xALSubAdministrativeArea.byName(testSubArea);
		newAddr.country.adminArea.subAdministrativeArea.locality = xALLocality.byName(testLocality);
		newAddr.country.adminArea.subAdministrativeArea.locality.dependentLocality = xALLocality.byName(testDependentLocality);
		newAddr.country.adminArea.subAdministrativeArea.locality.dependentLocality.postalCode = xALPostalCode.byName(testPostCode);

		Test.startTest();

		res = newAddr.save();

		Test.stopTest();

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
		                            LocalityCode__c,
		                            LocalityName__c,
		                            LocalityType__c,
		                            LocalityDevName__c,
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
		                            WHERE Id = :res
		                                       LIMIT 1
		                        ];

		// inserted correctly?
		System.assertNotEquals(null, addr);

		System.assertEquals(newAddr.account, addr.Account__c);
		System.assertEquals(newAddr.addressLine, addr.AddressLine__c);
		System.assertEquals(newAddr.longitude, addr.LatLng__longitude__s);
		System.assertEquals(newAddr.latitude, addr.LatLng__latitude__s);

		Set<String> types = new Set<String>(addr.Type__c.split(';'));
		for (String type : newAddr.type) {
			System.assert(types.contains(type), 'Type is missing: ' + type);
		}

		System.assertEquals(newAddr.country.label, addr.CountryName__c);
		System.assertEquals(newAddr.country.developerName, addr.CountryDevName__c);
		System.assertEquals(newAddr.country.code, addr.CountryCode__c);

		System.assertEquals(newAddr.country.adminArea.code, addr.AdministrativeAreaCode__c);
		System.assertEquals(newAddr.country.adminArea.type, addr.AdministrativeAreaType__c);
		System.assertEquals(newAddr.country.adminArea.label, addr.AdministrativeAreaName__c);
		System.assertEquals(newAddr.country.adminArea.developerName, addr.AdministrativeAreaDevName__c);

		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.code, addr.SubAdministrativeAreaCode__c);
		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.label, addr.SubAdministrativeAreaName__c);
		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.type, addr.SubAdministrativeAreaType__c);
		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.developerName, addr.SubAdministratriveAreaDevName__c);

		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.locality.code, addr.LocalityCode__c);
		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.locality.label, addr.LocalityName__c);
		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.locality.type, addr.LocalityType__c);
		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.locality.developerName, addr.LocalityDevName__c);

		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.locality.dependentLocality.code, addr.DependentlocalityCode_1__c);
		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.locality.dependentLocality.developerName, addr.DependentLocalityDevName_1__c);
		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.locality.dependentLocality.label, addr.DependentLocalityName_1__c);
		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.locality.dependentLocality.type, addr.DependentLocalityType_1__c);

		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.locality.dependentLocality.postalCode.value, addr.PostalCodeName__c);
		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.locality.dependentLocality.postalCode.developerName, addr.PostalCodeDevName__c);
	}

	// without dep locality
	@IsTest static void saveInsertNewAddressCorrectly_2() {
		Account a = [SELECT Id FROM Account LIMIT 1];
		xALAddressDetails newAddr = new xALAddressDetails();
		Id res;

		newAddr.type = new List<String> {
			'Shipping Address'
		};
		newAddr.addressLine = 'Go to hell!! :D';
		newAddr.account = a.Id;
		newAddr.latitude = 15.0;
		newAddr.longitude = 10.0;

		newAddr.country = xALCountry.byName(testCountry);
		newAddr.country.adminArea = xALAdministrativeArea.byName(testAdminArea);
		newAddr.country.adminArea.subAdministrativeArea = xALSubAdministrativeArea.byName(testSubArea);
		newAddr.country.adminArea.subAdministrativeArea.locality = xALLocality.byName(testLocality);
		newAddr.country.adminArea.subAdministrativeArea.locality.postalCode = xALPostalCode.byName(testPostCode);

		Test.startTest();

		res = newAddr.save();

		Test.stopTest();

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
		                            WHERE Id = :res
		                                       LIMIT 1
		                        ];

		// inserted correctly?
		System.assertNotEquals(null, addr);

		System.assertEquals(newAddr.account, addr.Account__c);
		System.assertEquals(newAddr.addressLine, addr.AddressLine__c);
		System.assertEquals(newAddr.longitude, addr.LatLng__longitude__s);
		System.assertEquals(newAddr.latitude, addr.LatLng__latitude__s);

		Set<String> types = new Set<String>(addr.Type__c.split(';'));
		for (String type : newAddr.type) {
			System.assert(types.contains(type), 'Type is missing: ' + type);
		}

		System.assertEquals(newAddr.country.label, addr.CountryName__c);
		System.assertEquals(newAddr.country.developerName, addr.CountryDevName__c);
		System.assertEquals(newAddr.country.code, addr.CountryCode__c);

		System.assertEquals(newAddr.country.adminArea.code, addr.AdministrativeAreaCode__c);
		System.assertEquals(newAddr.country.adminArea.type, addr.AdministrativeAreaType__c);
		System.assertEquals(newAddr.country.adminArea.label, addr.AdministrativeAreaName__c);
		System.assertEquals(newAddr.country.adminArea.developerName, addr.AdministrativeAreaDevName__c);

		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.code, addr.SubAdministrativeAreaCode__c);
		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.label, addr.SubAdministrativeAreaName__c);
		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.type, addr.SubAdministrativeAreaType__c);
		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.developerName, addr.SubAdministratriveAreaDevName__c);

		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.locality.code, addr.LocalityCode__c);
		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.locality.label, addr.LocalityName__c);
		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.locality.type, addr.LocalityType__c);
		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.locality.developerName, addr.LocalityDevName__c);

		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.locality.postalCode.value, addr.PostalCodeName__c);
		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.locality.postalCode.developerName, addr.PostalCodeDevName__c);

		System.assert(String.isBlank(addr.DependentLocalityDevName_1__c));
	}

	// without locality
	@IsTest static void saveInsertNewAddressCorrectly_3() {
		Account a = [SELECT Id FROM Account LIMIT 1];
		xALAddressDetails newAddr = new xALAddressDetails();
		Id res;

		newAddr.type = new List<String> {
			'Shipping Address'
		};
		newAddr.addressLine = 'Go to hell!! :D';
		newAddr.account = a.Id;
		newAddr.latitude = 15.0;
		newAddr.longitude = 10.0;

		newAddr.country = xALCountry.byName(testCountry);
		newAddr.country.adminArea = xALAdministrativeArea.byName(testAdminArea);
		newAddr.country.adminArea.subAdministrativeArea = xALSubAdministrativeArea.byName(testSubArea);
		newAddr.country.adminArea.subAdministrativeArea.postalCode = xALPostalCode.byName(testPostCode);

		Test.startTest();

		res = newAddr.save();

		Test.stopTest();

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
		                            WHERE Id = :res
		                                       LIMIT 1
		                        ];

		// inserted correctly?
		System.assertNotEquals(null, addr);

		System.assertEquals(newAddr.account, addr.Account__c);
		System.assertEquals(newAddr.addressLine, addr.AddressLine__c);
		System.assertEquals(newAddr.longitude, addr.LatLng__longitude__s);
		System.assertEquals(newAddr.latitude, addr.LatLng__latitude__s);

		Set<String> types = new Set<String>(addr.Type__c.split(';'));
		for (String type : newAddr.type) {
			System.assert(types.contains(type), 'Type is missing: ' + type);
		}

		System.assertEquals(newAddr.country.label, addr.CountryName__c);
		System.assertEquals(newAddr.country.developerName, addr.CountryDevName__c);
		System.assertEquals(newAddr.country.code, addr.CountryCode__c);

		System.assertEquals(newAddr.country.adminArea.code, addr.AdministrativeAreaCode__c);
		System.assertEquals(newAddr.country.adminArea.type, addr.AdministrativeAreaType__c);
		System.assertEquals(newAddr.country.adminArea.label, addr.AdministrativeAreaName__c);
		System.assertEquals(newAddr.country.adminArea.developerName, addr.AdministrativeAreaDevName__c);

		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.code, addr.SubAdministrativeAreaCode__c);
		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.label, addr.SubAdministrativeAreaName__c);
		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.type, addr.SubAdministrativeAreaType__c);
		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.developerName, addr.SubAdministratriveAreaDevName__c);

		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.postalCode.value, addr.PostalCodeName__c);
		System.assertEquals(newAddr.country.adminArea.subAdministrativeArea.postalCode.developerName, addr.PostalCodeDevName__c);

		System.assert(String.isBlank(addr.LocalityDevName__c));
	}

	// with locality related to admin area
	@IsTest static void saveInsertNewAddressCorrectly_4() {
		Account a = [SELECT Id FROM Account LIMIT 1];
		xALAddressDetails newAddr = new xALAddressDetails();
		Id res;

		newAddr.type = new List<String> {
			'Shipping Address'
		};
		newAddr.addressLine = 'Go to hell!! :D';
		newAddr.account = a.Id;
		newAddr.latitude = 15.0;
		newAddr.longitude = 10.0;

		newAddr.country = xALCountry.byName(testCountry);
		newAddr.country.adminArea = xALAdministrativeArea.byName(testAdminArea);
		newAddr.country.adminArea.locality = xALLocality.byName(testLocality);
		newAddr.country.adminArea.locality.postalCode = xALPostalCode.byName(testPostCode);

		Test.startTest();

		res = newAddr.save();

		Test.stopTest();

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
		                            WHERE Id = :res
		                                       LIMIT 1
		                        ];

		// inserted correctly?
		System.assertNotEquals(null, addr);

		System.assertEquals(newAddr.account, addr.Account__c);
		System.assertEquals(newAddr.addressLine, addr.AddressLine__c);
		System.assertEquals(newAddr.longitude, addr.LatLng__longitude__s);
		System.assertEquals(newAddr.latitude, addr.LatLng__latitude__s);

		Set<String> types = new Set<String>(addr.Type__c.split(';'));
		for (String type : newAddr.type) {
			System.assert(types.contains(type), 'Type is missing: ' + type);
		}

		System.assertEquals(newAddr.country.label, addr.CountryName__c);
		System.assertEquals(newAddr.country.developerName, addr.CountryDevName__c);
		System.assertEquals(newAddr.country.code, addr.CountryCode__c);

		System.assertEquals(newAddr.country.adminArea.code, addr.AdministrativeAreaCode__c);
		System.assertEquals(newAddr.country.adminArea.type, addr.AdministrativeAreaType__c);
		System.assertEquals(newAddr.country.adminArea.label, addr.AdministrativeAreaName__c);
		System.assertEquals(newAddr.country.adminArea.developerName, addr.AdministrativeAreaDevName__c);

		System.assertEquals(newAddr.country.adminArea.locality.code, addr.LocalityCode__c);
		System.assertEquals(newAddr.country.adminArea.locality.label, addr.LocalityName__c);
		System.assertEquals(newAddr.country.adminArea.locality.type, addr.LocalityType__c);
		System.assertEquals(newAddr.country.adminArea.locality.developerName, addr.LocalityDevName__c);

		System.assertEquals(newAddr.country.adminArea.locality.postalCode.value, addr.PostalCodeName__c);
		System.assertEquals(newAddr.country.adminArea.locality.postalCode.developerName, addr.PostalCodeDevName__c);

		System.assert(String.isBlank(addr.SubAdministratriveAreaDevName__c));
	}

	// without locality and sub area
	@IsTest static void saveInsertNewAddressCorrectly_5() {
		Account a = [SELECT Id FROM Account LIMIT 1];
		xALAddressDetails newAddr = new xALAddressDetails();
		Id res;

		newAddr.type = new List<String> {
			'Shipping Address'
		};
		newAddr.addressLine = 'Go to hell!! :D';
		newAddr.account = a.Id;
		newAddr.latitude = 15.0;
		newAddr.longitude = 10.0;

		newAddr.country = xALCountry.byName(testCountry);
		newAddr.country.adminArea = xALAdministrativeArea.byName(testAdminArea);
		newAddr.country.adminArea.postalCode = xALPostalCode.byName(testPostCode);

		Test.startTest();

		res = newAddr.save();

		Test.stopTest();

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
		                            WHERE Id = :res
		                                       LIMIT 1
		                        ];

		// inserted correctly?
		System.assertNotEquals(null, addr);

		System.assertEquals(newAddr.account, addr.Account__c);
		System.assertEquals(newAddr.addressLine, addr.AddressLine__c);
		System.assertEquals(newAddr.longitude, addr.LatLng__longitude__s);
		System.assertEquals(newAddr.latitude, addr.LatLng__latitude__s);

		Set<String> types = new Set<String>(addr.Type__c.split(';'));
		for (String type : newAddr.type) {
			System.assert(types.contains(type), 'Type is missing: ' + type);
		}

		System.assertEquals(newAddr.country.label, addr.CountryName__c);
		System.assertEquals(newAddr.country.developerName, addr.CountryDevName__c);
		System.assertEquals(newAddr.country.code, addr.CountryCode__c);

		System.assertEquals(newAddr.country.adminArea.code, addr.AdministrativeAreaCode__c);
		System.assertEquals(newAddr.country.adminArea.type, addr.AdministrativeAreaType__c);
		System.assertEquals(newAddr.country.adminArea.label, addr.AdministrativeAreaName__c);
		System.assertEquals(newAddr.country.adminArea.developerName, addr.AdministrativeAreaDevName__c);

		System.assertEquals(newAddr.country.adminArea.postalCode.value, addr.PostalCodeName__c);
		System.assertEquals(newAddr.country.adminArea.postalCode.developerName, addr.PostalCodeDevName__c);

		System.assert(String.isBlank(addr.LocalityDevName__c));
		System.assert(String.isBlank(addr.SubAdministratriveAreaDevName__c));
	}

	// without admin area
	@IsTest static void saveInsertNewAddressCorrectly_6() {
		Account a = [SELECT Id FROM Account LIMIT 1];
		xALAddressDetails newAddr = new xALAddressDetails();
		Id res;

		newAddr.type = new List<String> {
			'Shipping Address'
		};
		newAddr.addressLine = 'Go to hell!! :D';
		newAddr.account = a.Id;
		newAddr.latitude = 15.0;
		newAddr.longitude = 10.0;

		newAddr.country = xALCountry.byName(testCountry);

		Test.startTest();

		res = newAddr.save();

		Test.stopTest();

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
		                            WHERE Id = :res
		                                       LIMIT 1
		                        ];

		// inserted correctly?
		System.assertNotEquals(null, addr);

		System.assertEquals(newAddr.account, addr.Account__c);
		System.assertEquals(newAddr.addressLine, addr.AddressLine__c);
		System.assertEquals(newAddr.longitude, addr.LatLng__longitude__s);
		System.assertEquals(newAddr.latitude, addr.LatLng__latitude__s);

		Set<String> types = new Set<String>(addr.Type__c.split(';'));
		for (String type : newAddr.type) {
			System.assert(types.contains(type), 'Type is missing: ' + type);
		}

		System.assertEquals(newAddr.country.label, addr.CountryName__c);
		System.assertEquals(newAddr.country.developerName, addr.CountryDevName__c);
		System.assertEquals(newAddr.country.code, addr.CountryCode__c);

		System.assert(String.isBlank(addr.AdministrativeAreaDevName__c));
	}

	// without country
	@IsTest static void saveInsertNewAddressCorrectly_7() {
		Account a = [SELECT Id FROM Account LIMIT 1];
		xALAddressDetails newAddr = new xALAddressDetails();
		Id res;

		newAddr.type = new List<String> {
			'Shipping Address'
		};
		newAddr.addressLine = 'Go to hell!! :D';
		newAddr.account = a.Id;
		newAddr.latitude = 15.0;
		newAddr.longitude = 10.0;

		Test.startTest();

		res = newAddr.save();

		Test.stopTest();

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
		                            WHERE Id = :res
		                                       LIMIT 1
		                        ];

		// inserted correctly?
		System.assertNotEquals(null, addr);

		System.assertEquals(newAddr.account, addr.Account__c);
		System.assertEquals(newAddr.addressLine, addr.AddressLine__c);
		System.assertEquals(newAddr.longitude, addr.LatLng__longitude__s);
		System.assertEquals(newAddr.latitude, addr.LatLng__latitude__s);

		Set<String> types = new Set<String>(addr.Type__c.split(';'));
		for (String type : newAddr.type) {
			System.assert(types.contains(type), 'Type is missing: ' + type);
		}

		System.assert(String.isBlank(addr.CountryDevName__c));
	}

	@IsTest static void saveUpdateAddressCorrectly() {
		AddressDetail__c addr = [
		                            SELECT Account__c, AddressLine__c, LatLng__Longitude__s, LatLng__Latitude__s, Type__c
		                            FROM AddressDetail__c
		                            LIMIT 1
		                        ];
		Id res;

		xALCountry ctry = xALCountry.byName(testCountry);
		ctry.adminArea = xALAdministrativeArea.byName(testAdminArea);
		ctry.adminArea.locality = xALLocality.byName(testLocality);
		ctry.adminArea.locality.postalCode = xALPostalCode.byName(testPostCode);

		Test.startTest();

		xALAddressDetails newaddr = new xALAddressDetails(addr.Id);
		newaddr.country = ctry;

		res = newaddr.save();

		Test.stopTest();

		// updated correctly?
		System.assertEquals(addr.Id, res);

		AddressDetail__c addrUpdated = [
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
		                                   WHERE Id = :res
		                                           LIMIT 1
		                               ];

		System.assertEquals(addr.Account__c, addrUpdated.Account__c);
		System.assertEquals(addr.AddressLine__c, addrUpdated.AddressLine__c);
		System.assertEquals(addr.LatLng__Longitude__s, addrUpdated.LatLng__longitude__s);
		System.assertEquals(addr.LatLng__Latitude__s, addrUpdated.LatLng__latitude__s);

		Set<String> types = new Set<String>(addrUpdated.Type__c.split(';'));
		for (String type : addr.Type__c.split(';')) {
			System.assert(types.contains(type), 'Type is missing: ' + type);
		}

		System.assertEquals(ctry.label, addrUpdated.CountryName__c);
		System.assertEquals(ctry.developerName, addrUpdated.CountryDevName__c);
		System.assertEquals(ctry.code, addrUpdated.CountryCode__c);

		System.assertEquals(ctry.adminArea.code, addrUpdated.AdministrativeAreaCode__c);
		System.assertEquals(ctry.adminArea.type, addrUpdated.AdministrativeAreaType__c);
		System.assertEquals(ctry.adminArea.label, addrUpdated.AdministrativeAreaName__c);
		System.assertEquals(ctry.adminArea.developerName, addrUpdated.AdministrativeAreaDevName__c);

		System.assertEquals(ctry.adminArea.locality.code, addrUpdated.LocalityCode__c);
		System.assertEquals(ctry.adminArea.locality.label, addrUpdated.LocalityName__c);
		System.assertEquals(ctry.adminArea.locality.type, addrUpdated.LocalityType__c);
		System.assertEquals(ctry.adminArea.locality.developerName, addrUpdated.LocalityDevName__c);

		System.assertEquals(ctry.adminArea.locality.postalCode.value, addrUpdated.PostalCodeName__c);
		System.assertEquals(ctry.adminArea.locality.postalCode.developerName, addrUpdated.PostalCodeDevName__c);

		System.assert(String.isBlank(addrUpdated.SubAdministratriveAreaDevName__c));
		System.assert(String.isBlank(addrUpdated.DependentLocalityDevName_1__c));
	}
}
