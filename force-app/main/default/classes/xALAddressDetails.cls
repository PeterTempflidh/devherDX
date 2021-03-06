public with sharing class xALAddressDetails {

	private class xALAddressDetailsException extends Exception {}

	private static final Integer MAX_DEPENDENT_LOCALITIES = 3;

	public xALCountry country 				{get; set;}
	public List<String> type 				{get; set;}
	public String addressLine				{get; set;}
	public String id 						{get; set;}
	public String account 					{get; set;}
	public Decimal latitude					{get; set;}
	public Decimal longitude				{get; set;}
	public String translatedStreetName		{get; set;}
	/*Adding parent address city name to the cloned account address*/
	public String translatedCityName		{get; set;}
	public String postCode					{get; set;}

	public String translatedAreaName        {get; set;}

	public xALAddressDetails() {}

	public xALAddressDetails(AddressDetail__c address) {
		this();

		if (address == null) {
			return;
		}

		type = String.isNotBlank(address.Type__c) ? address.Type__c.split(';') : new List<String>();
		addressLine = address.AddressLine__c;
		id = address.Id;
		account = address.Account__c;
		latitude = address.LatLng__latitude__s;
		longitude = address.LatLng__longitude__s;
		postCode = address.PostalCodeName__c;

		// checks country
		if (String.isBlank(address.CountryDevName__c)) {
			return;
		}

		country = xALCountry.byName(address.CountryDevName__c);

		// checks administrative area
		if (String.isBlank(address.AdministrativeAreaDevName__c)) {
			return;
		}

		country.adminArea = xALAdministrativeArea.byName(address.AdministrativeAreaDevName__c);

		if (String.isNotBlank(address.SubAdministratriveAreaDevName__c)) {
			// load sub administrative area
			country.adminArea.subAdministrativeArea = xALSubAdministrativeArea.byName(address.SubAdministratriveAreaDevName__c);

			if (String.isNotBlank(address.LocalityDevName__c)) {
				// load locality related to sub admin area
				country.adminArea.subAdministrativeArea.locality = loadLocalityTree(address);
			}
		} else if (String.isNotBlank(address.LocalityDevName__c)) {
			// load locality related to admin area
			country.adminArea.locality = loadLocalityTree(address);
		}
	}

	private static xALAddressDetails  getXALAddressDetails(AddressDetail__c address) {
		xALAddressDetails addressDetails = new xALAddressDetails();
		if (address == null) {
			return addressDetails;
		}
		
		addressDetails.translatedStreetName = address.Translated_Street_Name__c;
		addressDetails.translatedCityName = address.Translated_City_Name__c;
		addressDetails.translatedAreaName = address.Translated_Area_Name__c;
		addressDetails.type = String.isNotBlank(address.Type__c) ? address.Type__c.split(';') : new List<String>();
		addressDetails.addressLine = address.AddressLine__c;
		addressDetails.id = address.Id;
		addressDetails.account = address.Account__c;
		addressDetails.latitude = address.LatLng__Latitude__s;
		addressDetails.longitude = address.LatLng__Longitude__s;
		addressDetails.postCode = address.PostalCodeName__c;

		// checks country
		if (String.isBlank(address.CountryDevName__c)) {
			return addressDetails;
		}
		xALCountry country = new xALCountry();
		country.developerName = address.CountryDevName__c;
		country.label = address.CountryName__c;
		country.code = address.CountryCode__c;
		addressDetails.country = country;

		// checks administrative area
		if (String.isBlank(address.AdministrativeAreaDevName__c)) {
			return addressDetails;
		}
		xALAdministrativeArea administrativeArea = new xALAdministrativeArea();
		administrativeArea.developerName = address.AdministrativeAreaDevName__c;
		administrativeArea.label = address.AdministrativeAreaName__c;
		administrativeArea.code = address.AdministrativeAreaCode__c;
		administrativeArea.type = address.AdministrativeAreaType__c;
		addressDetails.country.adminArea = administrativeArea;

		if (String.isNotBlank(address.SubAdministratriveAreaDevName__c)) {
			// load sub administrative area
			xALSubAdministrativeArea subAdministrativeArea = new xALSubAdministrativeArea();
			subAdministrativeArea.developerName = address.SubAdministratriveAreaDevName__c;
			subAdministrativeArea.label = address.SubAdministrativeAreaName__c;
			subAdministrativeArea.code = address.SubAdministrativeAreaCode__c;
			subAdministrativeArea.type = address.SubAdministrativeAreaType__c;
			addressDetails.country.adminArea.subAdministrativeArea = subAdministrativeArea;
			addressDetails.country.adminArea.translatedCityName = address.Translated_City_Name__c;

			if (String.isNotBlank(address.LocalityDevName__c)) {
				xALLocality locality =  new xALLocality();
				locality.developerName = address.LocalityDevName__c;
				locality.label = address.LocalityName__c;
				locality.code = address.LocalityCode__c;
				locality.type = address.LocalityType__c;
				addressDetails.country.adminArea.subAdministrativeArea.locality = locality;
			}
			if (String.isNotBlank(address.DependentLocalityDevName_1__c)) {
				xALLocality dependentLocality =  new xALLocality();
				dependentLocality.developerName = address.DependentLocalityDevName_1__c;
				dependentLocality.label = address.DependentLocalityName_1__c;
				dependentLocality.code = address.DependentlocalityCode_1__c;
				dependentLocality.type = address.DependentLocalityType_1__c;
				addressDetails.country.adminArea.subAdministrativeArea.locality.dependentLocality = dependentLocality;
			}
		}
		return addressDetails;
	}

	public static xALAddressDetails getXALAddressDetailsById(Id addressId) {
		AddressDetail__c addressDetail = AddressDetail_Selector.getXalById(addressId);
		return getXALAddressDetails(addressDetail);
	}

	public xALAddressDetails(Id addressId) {
		this(AddressDetail_Selector.getXalById(addressId));
	}

	/**
	 * Persist this instance to an AddressDetail__c record and return its id
	 * @return [description]
	 */
	public Id save() {
		AddressDetail__c address = new AddressDetail__c();
		address = getAddressDetailRecord(this);

		try {
			upsert address;
		} catch (DmlException exc) {
			throw new xALAddressDetailsException(exc.getDmlMessage(0));
		}

		return address.Id;
	}

	/**
	 * Create a record of AddressDetail__c from an instance of xALAddressDetails
	 * @param  addressDetails Address detail instance
	 * @return                [description]
	 */
	private static AddressDetail__c getAddressDetailRecord(xALAddressDetails addressDetails) {
		AddressDetail__c address = new AddressDetail__c();

		if (String.isNotBlank(addressDetails.id)) {
			address.Id = addressDetails.id;
			// we have to clear this address
			address = clearAddressFields(address);
		} else {
			// new address, set also the account reference
			address.Account__c = addressDetails.account;
		}

		address.Type__c = '';
		for (String val : addressDetails.type) {
			address.Type__c += val + ';';
		}

		address.AddressLine__c = addressDetails.addressLine;
		address.PostalCodeName__c = addressDetails.postCode;
		address.Translated_Street_Name__c = null != addressDetails && null != addressDetails.translatedStreetName 
                     ? addressDetails.translatedStreetName : '';
		address.Translated_City_Name__c = null != addressDetails && null != addressDetails.country 
                     && null != addressDetails.country.adminArea && null != addressDetails.country.adminArea.translatedCityName  
                     ? addressDetails.country.adminArea.translatedCityName : addressDetails.translatedCityName;

		address.Translated_Area_Name__c = null != addressDetails && null != addressDetails.country
				&& null != addressDetails.country.adminArea && null != addressDetails.country.adminArea.subAdministrativeArea
				&& null != addressDetails.country.adminArea.subAdministrativeArea.translatedAreaName
				? addressDetails.country.adminArea.subAdministrativeArea.translatedAreaName : addressDetails.translatedAreaName;

		// fill latitude and longitude
		address.LatLng__longitude__s = addressDetails.longitude;
		address.LatLng__latitude__s = addressDetails.latitude;

		if (addressDetails.country == null) {
			return address;
		}

		// fill country data
		xALCountry country = addressDetails.country;
		address.CountryDevName__c = country.developerName;
		address.CountryName__c = country.label;
		address.CountryCode__c = country.code;

		if (country.adminArea == null) {
			return address;
		}

		// fill admin area data
		xALAdministrativeArea adminArea = country.adminArea;
		address.AdministrativeAreaDevName__c = adminArea.developerName;
		address.AdministrativeAreaType__c = adminArea.type;
		address.AdministrativeAreaCode__c = adminArea.code;
		address.AdministrativeAreaName__c = adminArea.label;

		if (adminArea.subAdministrativeArea != null) {
			// fill sub admin data
			xALSubAdministrativeArea subArea = adminArea.subAdministrativeArea;
			address.SubAdministrativeAreaCode__c = subArea.code;
			address.SubAdministrativeAreaName__c = subArea.label;
			address.SubAdministrativeAreaType__c = subArea.type;
			address.SubAdministratriveAreaDevName__c = subArea.developerName;

			if (subArea.locality != null) {
				address = storeLocalityTree(address, subArea.locality);
			} else if (subArea.postalCode != null) {
				address = storePostalCode(address, subArea.postalCode);
			}
		} else if (adminArea.locality != null) {
			address = storeLocalityTree(address, adminArea.locality);
		} else if (adminArea.postalCode != null) {
			address = storePostalCode(address, adminArea.postalCode);
		}

		return address;
	}

	/**
	 * Stores postal code data to and AddressDetail__c record
	 * @param  address    AddressDetail__c record
	 * @param  postalCode Postal code
	 * @return            [description]
	 */
	private static AddressDetail__c storePostalCode(AddressDetail__c address, xALPostalCode postalCode) {
		address.PostalCodeDevName__c = postalCode.developerName;
		address.PostalCodeName__c = postalCode.value;
		return address;
	}

	/**
	 * Stores locality hierarchy information to AddressDetail__c record
	 * @param  address AddressDetail__c record
	 * @param  root    Root locality
	 * @return         [description]
	 */
	private static AddressDetail__c storeLocalityTree(AddressDetail__c address, xALLocality root) {
		// store root info
		address.LocalityDevName__c = root.developerName;
		address.LocalityName__c = root.label;
		address.LocalityCode__c = root.code;
		address.LocalityType__c = root.type;

		xALLocality curr = root;
		for (Integer i = 1; i <= MAX_DEPENDENT_LOCALITIES; i++) {

			if (curr.dependentLocality == null) {
				break;
			}

			curr = curr.dependentLocality;

			address.put('DependentlocalityCode_' + i + '__c', curr.code);
			address.put('DependentLocalityType_' + i + '__c', curr.type);
			address.put('DependentLocalityName_' + i + '__c', curr.label);
			address.put('DependentLocalityDevName_' + i + '__c', curr.developerName);
		}

		if (curr.postalCode != null) {
			address = storePostalCode(address, curr.postalCode);
		}

		return address;
	}

	/**
	 * Load all the hierarchy structure of a given root locality. If present load also
	 * the postal code related to the deepest locality level
	 * @param  address AddressDetail__c record
	 * @return         Root node
	 */
	private static xALLocality loadLocalityTree(AddressDetail__c address) {
		xALLocality root = xALLocality.byName(address.LocalityDevName__c);

		xALLocality curr = root;
		for (Integer i = 1; i <= MAX_DEPENDENT_LOCALITIES; i++) {
			String dependentLocality = String.valueOf(address.get('DependentLocalityDevName_' + i + '__c'));
			if (String.isNotBlank(dependentLocality)) {
				curr.dependentLocality = xALLocality.byName(dependentLocality);
				curr = curr.dependentLocality;
			}
		}

		return root;
	}

	/**
	 * Clear all address fields on specified addressDetails record. Used when updating
	 * an existing record
	 * @param  record Record to be cleared
	 * @return        cleared record
	 */
	private static AddressDetail__c clearAddressFields(AddressDetail__c record) {
		Map<String, Schema.SObjectField> fields = Schema.SObjectType.AddressDetail__c.fields.getMap();
		for (String fld : fields.keySet()) {
			Schema.DescribeFieldResult dfl = fields.get(fld).getDescribe();
			if (fld.endsWith('__c') && fld != 'Account__c' && !fld.startsWithIgnoreCase('ON_') && dfl.isUpdateable()) { // ON_ is because of Just.On
				if (dfl.isDefaultedOnCreate()) {
					record.put(fld, dfl.getDefaultValue());
				} else {
					record.put(fld, '');
				}
			}
		}
		return record;
	}
}
