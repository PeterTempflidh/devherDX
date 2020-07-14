public class TrgAddressDetailProcessor {


	private static final String GOOGLE_MAPS_BASE_URL = 'https://maps.googleapis.com';
	private static final String GOOGLE_MAPS_PATH_AND_REQUEST = '/maps/api/staticmap?&zoom=18&size=600x300&maptype=roadmap&client=gme-deliveryheroholding&markers=';

	/**
	 * Generate signed google maps link for new and updated address where lat/lng have changed.
	 * If lat/lng is blank do nothing.
	 * More info on how to sign the url https://developers.google.com/maps/documentation/static-maps/get-api-key#generating_valid_signatures
	 * @param addresses Address records inserted or updated
	 * @param oldMap    Address record before update, could be null
	 */
	public static void generateSignedUrlForMapImage(List<AddressDetail__c> addresses) {
		System.debug('TrgAddressDetailProcessor.generateSignedUrlForMapImage: start');

		String b64Secret = Integration_Config__c.getValues('GoogleMapsSignature').Password__c;
		b64Secret = b64Secret.replace('_', '/').replace('-', '+');

		Blob secret = EncodingUtil.base64Decode(b64Secret);

		for (AddressDetail__c addr : addresses) {

			if (addr.LatLng__Longitude__s == null
			        || addr.LatLng__Latitude__s == null) {
				// clear url if any
				addr.SignedGoogleMapsPathRequest__c = '';
				System.debug('TrgAddressDetailProcessor.generateSignedUrlForMapImage: null coordinates');
				continue; // invalid or empty coordinates
			}

			System.debug('TrgAddressDetailProcessor.generateSignedUrlForMapImage: setting maps url for: ' + addr.Id);

			String requestUrl = GOOGLE_MAPS_PATH_AND_REQUEST + addr.LatLng__Latitude__s + ',' + addr.LatLng__Longitude__s;
			Blob binarySgnature = Crypto.generateMac('hmacSHA1', Blob.valueOf(requestUrl), secret);

			String signature = EncodingUtil.base64Encode(binarySgnature);
			signature = signature.replace('+', '-').replace('/', '_');

			addr.SignedGoogleMapsPathRequest__c = GOOGLE_MAPS_BASE_URL + requestUrl + '&signature=' + signature;

			System.debug('TrgAddressDetailProcessor.generateSignedUrlForMapImage: final url: ' + addr.SignedGoogleMapsPathRequest__c);
		}
	}

	/**
	 * Called on before insert or update checks that there aren't two addresses of same
	 * type related to same account. In case of duplicates add an error message to the record
	 * @param newAddresses
	 */
	public static void checksDuplicateAddressTypesPerAccount(List<AddressDetail__c> newAddresses) {
		Set<Id> accountIds = ClsSObjectUtils.extractSetIds(newAddresses, AddressDetail__c.Account__c.getDescribe().getLocalName());
		Map<Id, Map<String, Map<String, Integer>>> accountIdToTypesOccurrence = new Map<Id, Map <String, Map<String, Integer>>>();

		List<AddressDetail__c> existingAddressDetails = AddressDetail_Selector.getByAccountIdsFilterIds(accountIds, Trigger.isInsert ? new Set<Id>() : new Map<Id, AddressDetail__c>(newAddresses).keySet());
		existingAddressDetails.addAll(newAddresses);

		for (AddressDetail__c addr : existingAddressDetails) {
			addTypesOccurrencesToMap(accountIdToTypesOccurrence, addr);
		}

		for (AddressDetail__c addr : newAddresses) {
			for (String type : accountIdToTypesOccurrence.get(addr.Account__c).get(addr.DAUM_Address_Model__c).keySet()) {
				if (accountIdToTypesOccurrence.get(addr.Account__c).get(addr.DAUM_Address_Model__c).get(type) <= 1) {
					continue;
				}
				String errorMessage = Label.AddressDetail_DuplicateAddressType + ' ' + type +
							(addr.DAUM_Address_Model__c != null ? (' (' + addr.DAUM_Address_Model__c + ') ' ) : '');
				addr.addError(errorMessage);
			}
		}
	}

	private static void addTypesOccurrencesToMap(Map<Id, Map <String, Map<String, Integer>>> typesOccurrences, AddressDetail__c addr) {
		if (!typesOccurrences.containsKey(addr.Account__c)) {
			typesOccurrences.put(addr.Account__c, new Map <String, Map<String, Integer>>());
		}

		Map <String, Map<String, Integer>> typeOccurrenceModel = typesOccurrences.get(addr.Account__c);

		if (!typeOccurrenceModel.containsKey(addr.DAUM_Address_Model__c)) {
			typeOccurrenceModel.put(addr.DAUM_Address_Model__c, new Map<String, Integer>());
		}

		Map<String, Integer> typeOccurrence = typeOccurrenceModel.get(addr.DAUM_Address_Model__c);

		for (String type : addr.Type__c.split(';')) {
			Integer occ = typeOccurrence.containsKey(type) ? typeOccurrence.get(type) + 1 : 1;
			typeOccurrence.put(type, occ);
		}
	}
	/*
    * @description - Copy Address details of parent account(Facility) when ever facility is associated
    *                to Branch - Kitchen Restaurant  removed extra method and applied try catch and clone clone(SSC-2794)
    * @param listOfAdd  - List of Addresses
    * @param oldMapOfAddress - Old map of Address
    * @jira - SSC-335
    */
	public static void updateKitchenAddressWhenFacltyAddessIsUpdated(List<AddressDetail__c> listOfAdd,Map<Id,AddressDetail__c> oldMapOfAddress) {

		Map<Id,AddressDetail__c> mapOfFacilityIdWithAddress = new Map<Id,AddressDetail__c>();
		for (AddressDetail__c addObj : listOfAdd) {
			if (String.isNotBlank(addObj.Account__c) &&
					((oldMapOfAddress == null && addObj.Type__c.contains(Constants.ADDRESS_TYPE_RESTAURANT_ADDRESS))
							||  (checkOldMapAddressValues(addObj, oldMapOfAddress)))) {

				mapOfFacilityIdWithAddress.put(addObj.Account__c, addObj);
			}
		}
		if(!mapOfFacilityIdWithAddress.keySet().isEmpty()) {
			updatingAddressOfBranchKitchen(mapOfFacilityIdWithAddress);
		}

	}

	/*
    * @date     : [05/04/2020]
    * @method name  : updatingAddressOfBranchKitchen
    * @description  : Logic to update branch kitchen restaurant address
    *
    ********************************************************************
    * @return      : none
    * @param        : Map<Id,Id> mapOfFacilityIdWithAccountId, Set<Id> setOfAccountIds
    *
    */
	private static void updatingAddressOfBranchKitchen(Map<Id,AddressDetail__c> mapOfFacilityIdWithAddress) {

		Map<Id,Id> mapOfChildIdwithAddressId = new Map<Id,Id>();
		Set<Id> setOfChildIds = new Set<Id>();
		List<Account> listOfChildAccounts = new List<Account>();

		for(Account accObj:[SELECT Id,Facility__c FROM Account WHERE Facility__c IN: mapOfFacilityIdWithAddress.keySet()]){
			setOfChildIds.add(accObj.Id);
			listOfChildAccounts.add(accObj);
		}
		if(!setOfChildIds.isEmpty()){
			for(AddressDetail__c addressObj : AddressDetail_Selector.getByAccountIds(setOfChildIds)){
				if(addressObj !=null && addressObj.Type__c.contains(Constants.ADDRESS_TYPE_RESTAURANT_ADDRESS)) {
						mapOfChildIdwithAddressId.put(addressObj.Account__c, addressObj.Id);
				}
			}
			updateKitchenAddress(listOfChildAccounts,mapOfChildIdwithAddressId,mapOfFacilityIdWithAddress);
		}
	}
	/**
    * @description Logic to update facility address to kitchen address. Updated (SSC-2794)
    * @param listOfChildAccounts list of child record with facility field to get address
    * @param mapOfChildIdwithAddressId  map of child id and associated address Id
    * @param mapOfFacilityIdWithAddress  map of Facility and its associated address
    */
	private static void updateKitchenAddress(List<Account> listOfChildAccounts,
										    Map<Id,Id> mapOfChildIdwithAddressId,
											Map<Id,AddressDetail__c> mapOfFacilityIdWithAddress) {

		List<AddressDetail__c> listOfAddressToUpsert = new List<AddressDetail__c>();
		try{
			for(Account childAccount :listOfChildAccounts){
				AddressDetail__c addressDetail = new AddressDetail__c();
				addressDetail = mapOfFacilityIdWithAddress.get(childAccount.Facility__c).clone(false, false, false, false);
				addressDetail.Account__c = childAccount.Id;
				addressDetail.Id = mapOfChildIdwithAddressId.get(childAccount.Id);
				addressDetail.Type__c = Constants.ADDRESS_TYPE_RESTAURANT_ADDRESS;
				listOfAddressToUpsert.add(addressDetail);
			}
			if (!listOfAddressToUpsert.isEmpty()) {
				Database.upsert(listOfAddressToUpsert,false);
			}
		}
		catch (Exception ex) { ClsLogErrorMessage.logMessages('Facility Address update on Child Account',
		    'Could not update address on Facility child accounts records' + ex.getMessage() + ex.getStackTraceString());
		}

	}

	/**
	* @description - Logic to map all the address object fields
	* @param addObj  - AddressDetail__c
	* @param oldMapOfAddress  - Map<Id,AddressDetail__c>
	* @return - Boolean
	*/
	private static Boolean checkOldMapAddressValues(AddressDetail__c addObj,Map<Id,AddressDetail__c> oldMapOfAddress) {
		if (oldMapOfAddress != null && ((addObj.Type__c.Contains(Constants.ADDRESS_TYPE_RESTAURANT_ADDRESS) ||
				oldMapOfAddress.get(addObj.Id).Type__c.Contains(Constants.ADDRESS_TYPE_RESTAURANT_ADDRESS) !=
						addObj.Type__c.Contains(Constants.ADDRESS_TYPE_RESTAURANT_ADDRESS)) ||
				(oldMapOfAddress.get(addObj.Id).FormattedAddress__c != addObj.FormattedAddress__c))) {

			return true;
		}
		else{
			return false;
		}
	}
}