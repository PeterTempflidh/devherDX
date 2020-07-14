/**
 * Created by marco.zeuli on 13/9/2017.
 */

@IsTest
private class UnitTestGpaAddressDetails {

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
				Type__c = 'Billing Address',
				LatLng__Longitude__s = 10.0,
				LatLng__Latitude__s = 5.0,
				Account__c = a.Id,

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

		insert addr;

		List<GooglePlaceApiFieldMapping__c> confs = new List<GooglePlaceApiFieldMapping__c>();

		confs.add(new GooglePlaceApiFieldMapping__c(
				Name = 'a1',
				AddressFieldPrefix__c = 'GPA_Country',
				CountryIso__c = 'EC',
				FormLabel__c = 'country',
				FormPosition__c = '1-1',
				Required__c = true,
				TypeToLikelihood__c = '{"country":99}'
		));

		confs.add(new GooglePlaceApiFieldMapping__c(
				Name = 'a2',
				AddressFieldPrefix__c = 'GPA_Admin_area_level_1',
				CountryIso__c = 'EC',
				FormLabel__c = 'admin area',
				FormPosition__c = '1-2',
				Required__c = true,
				TypeToLikelihood__c = '{"admin_Area":99}'
		));

		confs.add(new GooglePlaceApiFieldMapping__c(
				Name = 'a3',
				AddressFieldPrefix__c = 'GPA_locality',
				CountryIso__c = 'EC',
				FormLabel__c = 'locality',
				FormPosition__c = '1-1',
				Required__c = true,
				TypeToLikelihood__c = '{"locality":99}'
		));

		confs.add(new GooglePlaceApiFieldMapping__c(
				Name = 'a4',
				AddressFieldPrefix__c = 'GPA_route',
				CountryIso__c = 'EC',
				FormLabel__c = 'route',
				FormPosition__c = '1-1',
				Required__c = true,
				TypeToLikelihood__c = '{"route":99}'
		));

		confs.add(new GooglePlaceApiFieldMapping__c(
				Name = 'a5',
				AddressFieldPrefix__c = 'GPA_Street_number',
				CountryIso__c = 'EC',
				FormLabel__c = 'street num',
				FormPosition__c = '1-1',
				Required__c = true,
				TypeToLikelihood__c = '{"street num":99}'
		));

		confs.add(new GooglePlaceApiFieldMapping__c(
				Name = 'a6',
				AddressFieldPrefix__c = 'GPA_Postal_code',
				CountryIso__c = 'EC',
				FormLabel__c = 'zipcode',
				FormPosition__c = '1-1',
				Required__c = true,
				TypeToLikelihood__c = '{"zipcode":99}'
		));

		// two fake conf related to wrong country
		confs.add(new GooglePlaceApiFieldMapping__c(
				Name = 'a7',
				AddressFieldPrefix__c = 'GPA_Street_number',
				CountryIso__c = 'AT',
				FormLabel__c = 'street num',
				FormPosition__c = '1-1',
				Required__c = true,
				TypeToLikelihood__c = '{"street num":99}'
		));

		confs.add(new GooglePlaceApiFieldMapping__c(
				Name = 'a8',
				AddressFieldPrefix__c = 'GPA_Postal_code',
				CountryIso__c = 'AT',
				FormLabel__c = 'zipcode',
				FormPosition__c = '1-1',
				Required__c = true,
				TypeToLikelihood__c = '{"zipcode":99}'
		));

		insert confs;
	}

	@IsTest static void GPAAddressDetailsInstantiateCorrectlyWithoutParams() {
		GPAAddressDetails res;

		Test.startTest();

		res = new GPAAddressDetails();

		Test.stopTest();

		System.assert(!res.modifiedManually);
		System.assert(String.isBlank(res.placeId));
		System.assert(String.isBlank(res.formattedAddress));
		System.assert(res.type.isEmpty());
		System.assert(res.components.isEmpty());
	}

	@IsTest static void GPAAddressDeatlsInstantiateCorrectlyWithCountryIsoCOde() {
		GPAAddressDetails res;

		Test.startTest();

		res = new GPAAddressDetails('EC');

		Test.stopTest();

		System.assert(!res.components.isEmpty());

		for (GPAAddressDetails.AddressComponent cmp : res.components) {
			System.assertEquals('EC', cmp.settings.CountryIso__c);
		}
	}

	@IsTest static void GPAAddressDetailsInstantiateCorrectlyWithAddressId() {
		Account a = [SELECT Id FROM Account LIMIT 1];
		AddressDetail__c addr = [
				SELECT
						Account__c,
						Type__c,
						LatLng__Latitude__s,
						LatLng__Longitude__s,
						GPA_Country_long_name__c,
						GPA_Country_short_name__c,
						GPA_Admin_area_level_1_short_name__c,
						GPA_Admin_area_level_1_long_name__c,
						GPA_Locality_long_name__c,
						GPA_Locality_short_name__c,
						GPA_Sublocality_level_1_long_name__c,
						GPA_Sublocality_level_1_short_name__c,
						GPA_Route_long_name__c,
						GPA_Route_short_name__c,
						GPA_Street_number_long_name__c,
						GPA_Street_number_short_name__c,
						GPA_Postal_code_long_name__c,
						GPA_Postal_code_short_name__c,
						GPA_formatted_address__c,
						GPA_Place_id__c,
						GPA_Was_modified_manually__c
				FROM AddressDetail__c
				LIMIT 1
		];

		GPAAddressDetails res;

		Test.startTest();

		res = new GPAAddressDetails(addr.Id);

		Test.stopTest();

		System.assertEquals(addr.Id, res.id);
		System.assertEquals(a.Id, res.account);
		System.assertEquals(1, res.type.size());

		System.assertNotEquals(null, res.latitude);
		System.assertNotEquals(null, res.longitude);

		System.assertEquals(addr.GPA_Place_id__c, res.placeId);

		for (GPAAddressDetails.AddressComponent cmp : res.components) {
			// country is correct
			System.assertEquals('EC', cmp.settings.CountryIso__c);

			// long/short value is correct
			String shortField = cmp.settings.AddressFieldPrefix__c + GPAAddressDetails.SHORT_FIELD_SUFFIX;
			String longField = cmp.settings.AddressFieldPrefix__c + GPAAddressDetails.LONG_FIELD_SUFFIX;

			System.assertEquals(String.valueOf(addr.get(shortField)), cmp.shortValue);
			System.assertEquals(String.valueOf(addr.get(longField)), cmp.longValue);
		}
	}

	@IsTest static void saveCreateNewAddressRecordCorrectly() {
		final String placeId = '4321';
		final String formattedAddr = 'aaaaa bbbbbb ccccc';

		final String ctyLabel = 'Ecuador';
		final String ctyCode = 'EC';
		final String areaLabel = 'amazing admin area';
		final String areaCode = 'aaa';
		final String cityLabel = 'another amazing city';
		final String cityCode = 'aac';
		final String strLabel = 'whatever strret name';
		final String strCode = 'wsn';
		final String strNumLabel = '10';
		final String strNumCode = '10';
		final String zipLabel = '123';
		final String zipCode = '123';

		Account a = [SELECT Id FROM Account LIMIT 1];

		GPAAddressDetails newAddr = new GPAAddressDetails('EC');
		newAddr.account = a.Id;
		newAddr.type = new List<String>{
				'Restaurant Address'
		};
		newAddr.latitude = 10.0;
		newAddr.longitude = 5.0;
		newAddr.placeId = placeId;
		newAddr.formattedAddress = formattedAddr;
		newAddr.modifiedManually = true;

		for (GPAAddressDetails.AddressComponent cmp : newAddr.components) {
			if (cmp.settings.AddressFieldPrefix__c == 'GPA_Country') {
				cmp.longValue = ctyLabel;
				cmp.shortValue = ctyCode;
			}

			if (cmp.settings.AddressFieldPrefix__c == 'GPA_Admin_area_level_1') {
				cmp.longValue = areaLabel;
				cmp.shortValue = areaCode;
			}

			if (cmp.settings.AddressFieldPrefix__c == 'GPA_Locality') {
				cmp.longValue = cityLabel;
				cmp.shortValue = cityCode;
			}

			if (cmp.settings.AddressFieldPrefix__c == 'GPA_Route') {
				cmp.longValue = strLabel;
				cmp.shortValue = strCode ;
			}

			if (cmp.settings.AddressFieldPrefix__c == 'GPA_Street_number') {
				cmp.longValue = strNumLabel;
				cmp.shortValue = strNumCode;
			}

			if (cmp.settings.AddressFieldPrefix__c == 'GPA_Postal_code') {
				cmp.longValue = zipLabel;
				cmp.shortValue = zipCode;
			}
		}

		Id res;

		Test.startTest();

		res = newAddr.save();

		Test.stopTest();

		AddressDetail__c newAddRecord = [
				SELECT
						Account__c,
						Type__c,
						LatLng__Latitude__s,
						LatLng__Longitude__s,
						GPA_Country_long_name__c,
						GPA_Country_short_name__c,
						GPA_Admin_area_level_1_short_name__c,
						GPA_Admin_area_level_1_long_name__c,
						GPA_Locality_long_name__c,
						GPA_Locality_short_name__c,
						GPA_Sublocality_level_1_long_name__c,
						GPA_Sublocality_level_1_short_name__c,
						GPA_Route_long_name__c,
						GPA_Route_short_name__c,
						GPA_Street_number_long_name__c,
						GPA_Street_number_short_name__c,
						GPA_Postal_code_long_name__c,
						GPA_Postal_code_short_name__c,
						GPA_formatted_address__c,
						GPA_Place_id__c,
						GPA_Was_modified_manually__c
				FROM AddressDetail__c
				WHERE Id = :res
		];

		System.assertEquals(a.Id, newAddRecord.Account__c);
		System.assertEquals(1, newAddRecord.Type__c.split(';').size());
		System.assertNotEquals(null, newAddRecord.LatLng__Latitude__s);
		System.assertNotEquals(null, newAddRecord.LatLng__Longitude__s);
		System.assertEquals(placeId, newAddRecord.GPA_Place_id__c);
		System.assertEquals(formattedAddr, newAddRecord.GPA_formatted_address__c);
		System.assert(newAddRecord.GPA_Was_modified_manually__c);

		System.assertEquals(ctyLabel, newAddRecord.GPA_Country_long_name__c);
		System.assertEquals(ctyCode, newAddRecord.GPA_Country_short_name__c);
		System.assertEquals(areaLabel, newAddRecord.GPA_Admin_area_level_1_long_name__c);
		System.assertEquals(areaCode, newAddRecord.GPA_Admin_area_level_1_short_name__c);
		System.assertEquals(cityLabel, newAddRecord.GPA_Locality_long_name__c);
		System.assertEquals(cityCode, newAddRecord.GPA_Locality_short_name__c);
		System.assertEquals(strLabel, newAddRecord.GPA_Route_long_name__c);
		System.assertEquals(strCode, newAddRecord.GPA_Route_short_name__c);
		System.assertEquals(strNumLabel, newAddRecord.GPA_Street_number_long_name__c);
		System.assertEquals(strNumCode, newAddRecord.GPA_Street_number_short_name__c);
		System.assertEquals(zipLabel, newAddRecord.GPA_Postal_code_long_name__c);
		System.assertEquals(zipCode, newAddRecord.GPA_Postal_code_short_name__c);

		List<AddressDetail__c> addrs = [SELECT Id FROM AddressDetail__c WHERE Account__c = :a.Id];
		System.assertEquals(2, addrs.size());
	}

	@IsTest static void saveUpdateExistingAddressRecordCoorectly() {
		final String newAdminArea = adminAreaLabel + ' amazing again!!';
		final String newAdminAreaCode = adminArea + ' cocoooooos';

		final String newRouteLabel = streetLabel + ' whatever';
		final String newRouteCode = street + ' 123';

		Account a = [SELECT Id FROM Account LIMIT 1];
		AddressDetail__c addr = [
				SELECT Account__c,
						Type__c,
						LatLng__Latitude__s,
						LatLng__Longitude__s,
						GPA_Country_long_name__c,
						GPA_Country_short_name__c,
						GPA_Admin_area_level_1_short_name__c,
						GPA_Admin_area_level_1_long_name__c,
						GPA_Locality_long_name__c,
						GPA_Locality_short_name__c,
						GPA_Sublocality_level_1_long_name__c,
						GPA_Sublocality_level_1_short_name__c,
						GPA_Route_long_name__c,
						GPA_Route_short_name__c,
						GPA_Street_number_long_name__c,
						GPA_Street_number_short_name__c,
						GPA_Postal_code_long_name__c,
						GPA_Postal_code_short_name__c,
						GPA_formatted_address__c,
						GPA_Place_id__c,
						GPA_Was_modified_manually__c
				FROM AddressDetail__c
				WHERE Account__c = :a.Id
				LIMIT 1
		];

		GPAAddressDetails newAddr = new GPAAddressDetails(addr.Id);

		for (GPAAddressDetails.AddressComponent cmp : newAddr.components) {
			if (cmp.settings.AddressFieldPrefix__c == 'GPA_Admin_area_level_1') {
				cmp.longValue = newAdminArea;
				cmp.shortValue = newAdminAreaCode;
			}

			if (cmp.settings.AddressFieldPrefix__c == 'GPA_Route') {
				cmp.longValue = newRouteLabel;
				cmp.shortValue = newRouteCode;
			}
		}

		Test.startTest();

		newAddr.save();

		Test.stopTest();

		List<AddressDetail__c> addrs = [
				SELECT Account__c,
						Type__c,
						LatLng__Latitude__s,
						LatLng__Longitude__s,
						GPA_Country_long_name__c,
						GPA_Country_short_name__c,
						GPA_Admin_area_level_1_short_name__c,
						GPA_Admin_area_level_1_long_name__c,
						GPA_Locality_long_name__c,
						GPA_Locality_short_name__c,
						GPA_Sublocality_level_1_long_name__c,
						GPA_Sublocality_level_1_short_name__c,
						GPA_Route_long_name__c,
						GPA_Route_short_name__c,
						GPA_Street_number_long_name__c,
						GPA_Street_number_short_name__c,
						GPA_Postal_code_long_name__c,
						GPA_Postal_code_short_name__c,
						GPA_formatted_address__c,
						GPA_Place_id__c,
						GPA_Was_modified_manually__c
				FROM AddressDetail__c
				WHERE Account__c = :a.Id
		];

		System.assertEquals(1, addrs.size());

		// modified
		System.assertEquals(newAdminArea, addrs[0].GPA_Admin_area_level_1_long_name__c);
		System.assertEquals(newAdminAreaCode, addrs[0].GPA_Admin_area_level_1_short_name__c);
		System.assertEquals(newRouteLabel, addrs[0].GPA_Route_long_name__c);
		System.assertEquals(newRouteCode, addrs[0].GPA_Route_short_name__c);

		// same
		System.assertEquals(addr.Type__c, addrs[0].Type__c);
		System.assertEquals(addr.LatLng__Latitude__s, addrs[0].LatLng__Latitude__s);
		System.assertEquals(addr.LatLng__Longitude__s, addrs[0].LatLng__Longitude__s);
		System.assertEquals(addr.GPA_Country_long_name__c, addrs[0].GPA_Country_long_name__c);
		System.assertEquals(addr.GPA_Country_short_name__c, addrs[0].GPA_Country_short_name__c);
		System.assertEquals(addr.GPA_Locality_long_name__c, addrs[0].GPA_Locality_long_name__c);
		System.assertEquals(addr.GPA_Locality_short_name__c, addrs[0].GPA_Locality_short_name__c);
		System.assertEquals(addr.GPA_Sublocality_level_1_long_name__c, addrs[0].GPA_Sublocality_level_1_long_name__c);
		System.assertEquals(addr.GPA_Sublocality_level_1_short_name__c, addrs[0].GPA_Sublocality_level_1_short_name__c);
		System.assertEquals(addr.GPA_Street_number_long_name__c, addrs[0].GPA_Street_number_long_name__c);
		System.assertEquals(addr.GPA_Street_number_short_name__c, addrs[0].GPA_Street_number_short_name__c);
		System.assertEquals(addr.GPA_Postal_code_long_name__c, addrs[0].GPA_Postal_code_long_name__c);
		System.assertEquals(addr.GPA_Postal_code_short_name__c, addrs[0].GPA_Postal_code_short_name__c);
		System.assertEquals(addr.GPA_formatted_address__c, addrs[0].GPA_formatted_address__c);
		System.assertEquals(addr.GPA_Place_id__c, addrs[0].GPA_Place_id__c);
		System.assertEquals(addr.GPA_Was_modified_manually__c, addrs[0].GPA_Was_modified_manually__c);
	}

	@IsTest static void saveThrowsExceptionIfErrorOccurs() {
		AddressDetail__c addr = [SELECT Id FROM AddressDetail__c LIMIT 1];
		GPAAddressDetails newAddr = new GPAAddressDetails(addr.Id);
		newAddr.id = ''; // clear id

		Boolean throwed = false;

		Test.startTest();

		// duplicate type
		try {
			newAddr.save();
		} catch (GPAAddressDetails.GPAAddressDetailsException ex) {
			throwed = true;
		}

		Test.stopTest();

		System.assert(throwed);
	}

	/**
	 * @description  test the creating address detail from two addresses and test the validation if address type already exists
	 */
	@IsTest static void test_daumAddressDetail() {
		Country__c c = UnitTestDataFactory.createCountry('KR', 'Korea', 'USD');
		insert c;
		Account acc = UnitTestDataFactory.createAccount('test', c, 'Yogiyo_Account');
		insert acc;
		AddressDetail__c addr2 = new AddressDetail__c(
				Type__c = 'Billing Address;Shipping Address;Restaurant Address',
				LatLng__Longitude__s = 10.0,
				LatLng__Latitude__s = 5.0,
				Account__c = acc.Id,

				GPA_Country_long_name__c = 'Korea',
				GPA_Country_short_name__c = 'KR',

				DAUM_Address_Model__c = Label.KR_New_Address,

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
		AddressDetail__c addr = new AddressDetail__c(
				Type__c = 'Billing Address;Shipping Address;Restaurant Address',
				LatLng__Longitude__s = 10.0,
				LatLng__Latitude__s = 5.0,
				Account__c = acc.Id,

				GPA_Country_long_name__c = 'Korea',
				GPA_Country_short_name__c = 'KR',

				DAUM_Address_Model__c = Label.KR_Old_Address,

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
		AddressDetail__c addr3 = new AddressDetail__c(
				Type__c = 'Billing Address;Shipping Address;Restaurant Address',
				LatLng__Longitude__s = 10.0,
				LatLng__Latitude__s = 5.0,
				Account__c = acc.Id,

				GPA_Country_long_name__c = 'Korea',
				GPA_Country_short_name__c = 'KR',

				DAUM_Address_Model__c = Label.KR_Old_Address,

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
		Test.startTest();
		try {
			insert new List<AddressDetail__c> {addr, addr3};
		} catch (DmlException e) {}

		System.assert(addr.Id == null && addr3.Id == null);

		insert new List<AddressDetail__c> {addr, addr2};

		try {
			insert addr3;
		} catch (DmlException e) {}

		GPAAddressDetails addressDetails = new GPAAddressDetails(addr.Id, acc.Id);
		Test.stopTest();

		System.assert(addr3.Id == null);
		System.assertEquals(addr.Id, addressDetails.id);
		System.assertEquals(addr2.Id, addressDetails.related_id);

 	}
}