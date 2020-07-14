public with sharing class CtrCreateNewAddress {

	public CtrCreateNewAddress() {
	}

	public CtrCreateNewAddress(ApexPages.StandardController ctr) {
	}
	public static String DaumApiKey {
		get {
			return Integration_Config__c.getValues('DaumMapsAPI').Password__c;
		}
	}
	/* ********** UTILS ACTIONS ********* */

	@RemoteAction
	public static Map<String, String> getAddressTypes() {
		Map<String, String> res = new Map<String, String>();
		for (Schema.PicklistEntry pe : AddressDetail__c.Type__c.getDescribe().getPicklistValues()) {
			res.put(pe.getValue(), pe.getLabel());
		}
		return  res;
	}

	@RemoteAction
	public static Account getAccountRecordType(String accountId) {
        Account accountCountryRecType = [SELECT RecordType.DeveloperName,Record_Country__c FROM Account WHERE Id = :accountId];
        return accountCountryRecType;
	}

	/* ********** GPA MODEL ACTIONS ********* */

	@RemoteAction
	public static GPAAddressDetails gpa_getNewAddressDetailsPerAccount(String accountId) {
		// get country iso code
		String countryName = [
				SELECT Record_Country__c
				FROM Account
				WHERE Id = :accountId
		].Record_Country__c;

		// creates empty address
		GPAAddressDetails res = new GPAAddressDetails([
				SELECT Iso__c
				FROM Country__c
				WHERE Name = :countryName
				LIMIT 1
		].Iso__c);

		// set account id
		res.account = accountId;
		return res;
	}

	@RemoteAction
	public static GPAAddressDetails gpa_getNewAddressPerCountry(String countryName) {
		return new GPAAddressDetails([
				SELECT Iso__c
				FROM Country__c
				WHERE Name = :countryName
		].Iso__c);
	}

	@RemoteAction
	public static GPAAddressDetails gpa_getAddressDetails(String addressId) {
		return new GPAAddressDetails(Id.valueOf(addressId));
	}

	@RemoteAction
	public static GPAAddressDetails daum_getAddressDetails(String addressId, String accountId) {
		return new GPAAddressDetails(Id.valueOf(addressId), Id.valueOf(accountId));
	}

	@RemoteAction
	public static List<GPAAddressDetails> daum_getAddressDetailsPerAccount(String accountId) {
		List<GPAAddressDetails> res = new List<GPAAddressDetails>();
		for (AddressDetail__c address : AddressDetail_Selector.getByAccountIdsAndDaumModel(new Set<Id> {accountId}, Label.KR_Old_Address)) {
			res.add(new GPAAddressDetails(address.Id, accountId));
		}
		return res;
	}

	@RemoteAction
	public static List<GPAAddressDetails> gpa_getAddressDetailsPerAccount(String accountId) {
		List<GPAAddressDetails> res = new List<GPAAddressDetails>();
		for (AddressDetail__c address : AddressDetail_Selector.getByAccountIds(new Set<Id> {accountId})) {
			res.add(new GPAAddressDetails(address.Id));
		}
		return res;
	}

	@RemoteAction
	public static GPAAddressDetails gpa_saveAddress(GPAAddressDetails address) {
		return new GPAAddressDetails(address.save());
	}

	@RemoteAction
	public static List<GPAAddressDetails> gpa_saveAddresses(List<GPAAddressDetails> addresses) {
		List<GPAAddressDetails> res = new List<GPAAddressDetails>();
		for (GPAAddressDetails address : addresses) {
			res.add(new GPAAddressDetails(address.save()));
		}
		return res;
	}

	/* ********** XAL MODEL ACTIONS ********* */

	@RemoteAction
	public static xALAdministrativeArea getAdminAreaByName(String name) {
		return xALAdministrativeArea.byName(name);
	}

	@RemoteAction
	public static xALAdministrativeArea getAdminAreaByLabel(String label) {
		return xALAdministrativeArea.byLabel(label);
	}

	@RemoteAction
	public static xALSubAdministrativeArea getSubAdminAreaByName(String name) {
		return xALSubAdministrativeArea.byName(name);
	}

	@RemoteAction
	public static xALLocality getLocalityByName(String name) {
		return xALLocality.byName(name);
	}

	@RemoteAction
	public static xALCountry getCountryByName(String name) {
		return xALCountry.byName(name);
	}

	@RemoteAction
	public static xALCountry getCountryByLabel(String label) {
		xALCountry res = null;
		try {
			res = xALCountry.byLabel(label);
		} catch (Exception e) {
			System.debug('CtrCreateNewAddress.getCountryByLabel: exception occurred. Message is: ' + e.getMessage());
		}
		return res;
	}

	@RemoteAction
	public static xALCountry getCountryByAccountCountryLabel(String accountId) {
		return getCountryByLabel([SELECT Record_Country__c FROM Account WHERE Id = :accountId].Record_Country__c);
	}

	@RemoteAction
	public static xALAddressDetails getAddressDetails(String id) {
		return new xALAddressDetails(id);
	}

	@RemoteAction
	public static List<xALAddressDetails> getAddressDetailsPerAccount(String accountId) {
		List<xALAddressDetails> res = new List<xALAddressDetails>();
		for (AddressDetail__c addr : [SELECT Id FROM AddressDetail__c WHERE Account__c = :accountId]) {
			res.add(new xALAddressDetails(addr.Id));
		}
		return res;
	}

	@RemoteAction
	public static xALAddressDetails saveAddress(xALAddressDetails address) {
		return new xALAddressDetails(address.save());
	}

	@RemoteAction
	public static List<xALAddressDetails> saveAddresses(List<xALAddressDetails> addresses) {
		List<xALAddressDetails> res = new List<xALAddressDetails>();
		for (xALAddressDetails addr : addresses) {
			res.add(new xALAddressDetails(addr.save()));
		}
		return res;
	}

	/*---------------------New xAL Methods--------------------*/

	@RemoteAction
	public static xALCountry getCountryByCountryName(String countryName) {
		Country__c country = Country_Selector.getByName(countryName);
		return new xALCountry(country);
	}

	@RemoteAction
	public static xALCountry getAccountCountry(String accountId) {
		String countryName =  AccountSelector.getAccountDetailsforId(accountId).Record_Country__c;
		return getCountryByCountryName(countryName);
	}

	@RemoteAction
	public static xALAddressDetails getXALAddressDetails(String id) {
		return xALAddressDetails.getXALAddressDetailsById(id);
	}

	@RemoteAction
	public static List<xALAddressDetails> getXALAddressDetailsPerAccount(String accountId) {
		List<xALAddressDetails> res = new List<xALAddressDetails>();
		for (AddressDetail__c addr : AddressDetail_Selector.getByAccountId(accountId)) {
			res.add(xALAddressDetails.getXALAddressDetailsById(addr.Id));
		}
		return res;
	}

	@RemoteAction
	public static xALAddressDetails saveXALAddress(xALAddressDetails address) {
		return xALAddressDetails.getXALAddressDetailsById(address.save());
	}

	@RemoteAction
	public static List<xALAddressDetails> saveXALAddresses(List<xALAddressDetails> addresses) {
		List<xALAddressDetails> res = new List<xALAddressDetails>();
		for (xALAddressDetails address : addresses) {
			res.add(xALAddressDetails.getXALAddressDetailsById(address.save()));
		}
		return res;
	}

	/* ********** Mixed (GPA/XAL) MODEL ACTIONS - Used by Argentina,Chile,Uruguay **********/

	@RemoteAction
	public static List<xALLocality> getLocalityBySubAdminArea(String name) {
		return xALLocality.bySubAdministrativeAreaLabel(name);
	}
}