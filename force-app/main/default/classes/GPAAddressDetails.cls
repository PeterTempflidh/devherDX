/**
 * Created by marco.zeuli on 5/9/2017.
 */

public with sharing class GPAAddressDetails {

	public class GPAAddressDetailsException extends Exception {}

	@TestVisible
	private static final String SHORT_FIELD_SUFFIX = '_short_name__c';

	@TestVisible
	private static final String LONG_FIELD_SUFFIX = '_long_name__c';

	@TestVisible
	private static final String CUSTOM_FIELD_SUFFIX = '__c';

	@TestVisible
	private static final Set<String> fieldsWithoutSuffix = new Set<String> { 'GPA_formatted_address' };

	public String id { get; set; }
    public String related_id { get; set; }
	public String account { get; set; }
	public List<String> type { get; set; }

	public Decimal latitude { get; set; }
	public Decimal longitude { get; set; }

	// GPA related fields
	public String placeId { get; set; }
	public String formattedAddress { get; set; }
	public Boolean modifiedManually {get; set;}
	public List<AddressComponent> components { get; set; }

	// DAUM related fields

	public String addressModel {get; set;}

	//recipient name
	public String recipientName { get; set; }

	//used for AR,CL,UY Neighbourhood values
	public String localityName { get; set; }
	public String localityDevName { get; set; }
	public String localityCode { get; set; }
	public String localityType { get; set; }
	public String gpaLocalityValue { get; set; }

	public GPAAddressDetails() {
		modifiedManually = false;
		placeId = '';
		formattedAddress = '';
		type = new List<String>();
		components = new List<AddressComponent>();
	}

	public GPAAddressDetails(String countryIso) {
		this();
		for (GooglePlaceApiFieldMapping__c setting : getComponentsSettingPerCountry(countryIso)) {
			components.add(new AddressComponent(setting));
		}
	}

	public GPAAddressDetails(AddressDetail__c address) {
		this();
		id = address.Id;
		account = address.Account__c;

		type = String.isNotBlank(address.Type__c) ? address.Type__c.split(';') : new List<String>();
		recipientName = String.isNotBlank(address.GPA_formatted_address__c)?(address.GPA_formatted_address__c.containsignorecase('|')
                ?address.GPA_formatted_address__c.split(' \\| ')[0]:''):'';

		latitude = address.LatLng__Latitude__s;
		longitude = address.LatLng__Longitude__s;

		placeId = address.GPA_Place_id__c;

		formattedAddress = String.isNotBlank(address.GPA_formatted_address__c)?(address.GPA_formatted_address__c.containsignorecase('|')
                ?address.GPA_formatted_address__c.split('\\| ')[1]:address.GPA_formatted_address__c):'';
		modifiedManually = address.GPA_Was_modified_manually__c;

		String countryIso = [
		                        SELECT Iso__c
		                        FROM Country__c
		                        WHERE Name = : address.Account__r.Record_Country__c
		                    ].Iso__c;

		//Neighbourhood fields
		localityName =  address.LocalityName__c;
		localityDevName = address.LocalityDevName__c ;
		localityCode = address.LocalityCode__c;
		localityType = address.LocalityType__c;
		gpaLocalityValue = address.GPA_Locality_long_name__c;

		// initialize address components
		for (GooglePlaceApiFieldMapping__c setting : getComponentsSettingPerCountry(countryIso)) {
			String shortField = setting.AddressFieldPrefix__c + (fieldsWithoutSuffix.contains(setting.AddressFieldPrefix__c) ? CUSTOM_FIELD_SUFFIX : SHORT_FIELD_SUFFIX);
			String longField = setting.AddressFieldPrefix__c + (fieldsWithoutSuffix.contains(setting.AddressFieldPrefix__c) ? CUSTOM_FIELD_SUFFIX : LONG_FIELD_SUFFIX);
			components.add(new AddressComponent(
			                   setting,
			                   String.valueOf(address.get(longField)),
			                   String.valueOf(address.get(shortField))
			               ));
		}
	}

    /**
     * @description initialises two address records into one GPAAddressdetails apex object, used for DAUM maps data model.
     *
     * @param oldAddress
     * @param newAddress
     * @param primary_id
     *
     * @return
     */
    private GPAAddressDetails initialiseDaumDetails(AddressDetail__c oldAddress, AddressDetail__c newAddress, Id primary_id) {
        AddressDetail__c address = oldAddress != null && oldAddress.Id == primary_id ? oldAddress : newAddress;

        id = address.Id;
        account = address.Account__c;
        related_id = oldAddress != null && oldAddress.Id != primary_id ? oldAddress.Id : (newAddress != null && newAddress.Id != primary_id ? newAddress.Id : null);

        type = String.isNotBlank(address.Type__c) ? address.Type__c.split(';') : new List<String>();
        recipientName = String.isNotBlank(address.GPA_formatted_address__c)?(address.GPA_formatted_address__c.containsIgnoreCase('|')
                ?address.GPA_formatted_address__c.split(' \\| ')[0]:''):'';
		if (newAddress != null) {
			newAddress.GPA_formatted_address__c = String.isNotBlank(newAddress.GPA_formatted_address__c)?(newAddress.GPA_formatted_address__c.containsIgnoreCase('|')
					? newAddress.GPA_formatted_address__c.split('\\| ')[1]:newAddress.GPA_formatted_address__c) :'';
		}
		if (oldAddress != null) {
			oldAddress.GPA_formatted_address__c = String.isNotBlank(oldAddress.GPA_formatted_address__c)?(oldAddress.GPA_formatted_address__c.containsIgnoreCase('|')
					? oldAddress.GPA_formatted_address__c.split('\\| ')[1]:oldAddress.GPA_formatted_address__c) :'';
		}

        latitude = address.LatLng__Latitude__s;
        longitude = address.LatLng__Longitude__s;

        addressModel = address.DAUM_Address_Model__c;

        placeId = '';

        formattedAddress = (newAddress != null && String.isNotBlank(newAddress.GPA_formatted_address__c)? newAddress.GPA_formatted_address__c :'') + (newAddress != null && oldAddress !=null ? '; ' : '') +
				(oldAddress != null && String.isNotBlank(oldAddress.GPA_formatted_address__c)? oldAddress.GPA_formatted_address__c :'');
        modifiedManually = address.GPA_Was_modified_manually__c;

        String countryIso = [
                SELECT Iso__c
                FROM Country__c
                WHERE Name = : address.Account__r.Record_Country__c
        ].Iso__c;

        // initialize address components
        for (GooglePlaceApiFieldMapping__c setting : getComponentsSettingPerCountry(countryIso)) {
            String shortField = setting.AddressFieldPrefix__c + (fieldsWithoutSuffix.contains(setting.AddressFieldPrefix__c) ? CUSTOM_FIELD_SUFFIX : SHORT_FIELD_SUFFIX);
            String longField = setting.AddressFieldPrefix__c + (fieldsWithoutSuffix.contains(setting.AddressFieldPrefix__c) ? CUSTOM_FIELD_SUFFIX : LONG_FIELD_SUFFIX);
            components.add(new AddressComponent(
                    setting,
                    String.valueOf( setting.Name.endsWith(Label.KR_NEW_SUFFIX) ? ( newAddress != null ? newAddress.get(longField) : '' ) : ( oldAddress != null ? oldAddress.get(longField) : '' ) ),
                    String.valueOf( setting.Name.endsWith(Label.KR_NEW_SUFFIX) ? ( newAddress != null ? newAddress.get(shortField) : '' ) : ( oldAddress != null ? oldAddress.get(shortField) : '' ) )
            ));
        }
        return this;
    }

    public GPAAddressDetails(Id addressId, Id accountId) {
        this();
        List<AddressDetail__c> addressDetails = AddressDetail_Selector.getByIdAndAccountId(addressId, accountId);
        AddressDetail__c primaryDetail = new Map<Id, AddressDetail__c>(addressDetails).get(addressId);
        AddressDetail__c secondaryDetail;
        for (AddressDetail__c addressDetail: addressDetails) {
            if (addressDetail.Id != primaryDetail.Id && addressDetail.Type__c == primaryDetail.Type__c && addressDetail.DAUM_Address_Model__c != primaryDetail.DAUM_Address_Model__c) {
                secondaryDetail = addressDetail;
                break;
            }
        }
        initialiseDaumDetails(primaryDetail.DAUM_Address_Model__c.equals(Label.KR_Old_Address) ? primaryDetail : secondaryDetail,
                primaryDetail.DAUM_Address_Model__c.equals(Label.KR_New_Address) ? primaryDetail : secondaryDetail, addressId);
    }

	public GPAAddressDetails(Id addressId) {
		this(AddressDetail_Selector.getById(addressId));
	}

	/**
	Save current record
	 */
	public Id save() {
		AddressDetail__c address = getAddressDetailRecord(this);

		try {
			upsert address;
		} catch (DmlException exc) {
			throw new GPAAddressDetailsException(exc.getDmlMessage(0));
		}

		return address.Id;
	}

	private static AddressDetail__c getAddressDetailRecord(GPAAddressDetails addressDetails) {
		AddressDetail__c address = new AddressDetail__c();

		if (String.isNotBlank(addressDetails.id)) {
			// this is an update
			address.Id = addressDetails.Id;
			// clear all fields
			address = clearAddressFields(address); // this way we enfore blank values on deleted field
		} else {
			// this is a new address
			address.Account__c = addressDetails.account;
		}

		address.Type__c = '';
		for (String val : addressDetails.type) {
			address.Type__c += val + ';';
		}

		if(String.isNotBlank(addressDetails.addressModel)) {
			address.DAUM_Address_Model__c = addressDetails.addressModel;
		}

		// fill latitude and longitude
		address.LatLng__longitude__s = addressDetails.longitude;
		address.LatLng__latitude__s = addressDetails.latitude;

		// gpa related fields
		address.GPA_Place_id__c = addressDetails.placeId;
		address.GPA_formatted_address__c = String.isNotBlank(addressDetails.recipientName)
				?addressDetails.recipientName +' | ' + addressDetails.formattedAddress
				:addressDetails.formattedAddress;

		address.GPA_Was_modified_manually__c = addressDetails.modifiedManually;

		//Neighbourhood fields
		address.LocalityName__c = addressDetails.localityName;
		address.LocalityDevName__c = addressDetails.localityDevName;
		address.LocalityCode__c = addressDetails.localityCode;
		address.LocalityType__c = addressDetails.localityType;

		for (AddressComponent cmp : addressDetails.components) {
			String shortField = cmp.settings.AddressFieldPrefix__c + SHORT_FIELD_SUFFIX;
			String longField = cmp.settings.AddressFieldPrefix__c + LONG_FIELD_SUFFIX;
			address.put(shortField, cmp.shortValue);
			address.put(longField, cmp.longValue);
		}

		return address;
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
			if (fld.endsWith('__c') && fld != 'Account__c' && !fld.startsWithIgnoreCase('ON_') && dfl.isUpdateable()) { // ON_ it's because of Just.On integration
				if (dfl.isDefaultedOnCreate()) {
					record.put(fld, dfl.getDefaultValue());
				} else {
					record.put(fld, '');
				}
			}
		}
		return record;
	}

	/**
	Retrieves all GooglePlaceApiFieldMapping__c records related to specified country iso code
	@param countryIso Two digit country ISO code
	 */
	private static List<GooglePlaceApiFieldMapping__c> getComponentsSettingPerCountry(String countryIso) {
		List<GooglePlaceApiFieldMapping__c> res = new List<GooglePlaceApiFieldMapping__c>();
		for (GooglePlaceApiFieldMapping__c rec : GooglePlaceApiFieldMapping__c.getAll().values()) {
			if (countryIso == rec.CountryIso__c) {
				res.add(rec);
			}
		}
		return res;
	}

	// when loading an address
	// get all custom settings record related to the country
	// iterate over them and extract the field values
	// instantiate the new address component with the setting and the field values

	// when initialize a new address, instantiate only with the custom setting record

	// when updating clear all fields as always


	/**
	Represents an address component item. Contains information about the form position of the item, where to store the value
	and the actual values (short-name, long-name) coming from Google place api
	 */
	public class AddressComponent {
		public GooglePlaceApiFieldMapping__c settings { get; set; }
		public Integer lastTypeLikelihood { get; set; }
		public String shortValue { get; set; }
		public String longValue { get; set; }

		public AddressComponent() {
			// likeihood is a value between 0 and 99, this way first component mathching setting will set the value
			lastTypeLikelihood = -1;
			shortValue = '';
			longValue = '';
		}

		public AddressComponent(GooglePlaceApiFieldMapping__c settings) {
			this();
			this.settings = settings;
		}

		public AddressComponent(GooglePlaceApiFieldMapping__c settings, String longValue, String shortValue) {
			this(settings);
			this.longValue = longValue;
			this.shortValue = shortValue;
		}
	}

}
