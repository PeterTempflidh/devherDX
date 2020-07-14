/**
 * Used only when rendering the quote template
 */
public with sharing class ClsAccountWrapper {

	public String ownerName { get; set; }
	public String ownerMobilePhone { get; set; }
	public String ownerPhone { get; set; }
	public String ownerEmail { get; set; }
	public String ownerSalutation { get; set; }
	public String fax { get; set; }
	public String billingContactEmail {get;set;}
	public String billingMobilePhone {get;set;}
	public String billingSalutation {get;set;}
	public String billingFirstname {get;set;}
	public String billingLastname {get;set;}

	public String companyName { get; set; }
	public String companyId { get; set; }
	public String legalForm {get; set;}
	public String registrationOffice {get; set;}
	public String businessOffice {get; set;}
	public String GRID {get;set;}
	public String cuisine{get;set;}
	// restaurant address, according to new address model or legacy one if account's country does not support new model
	public String restaurantName { get; set; }
	public String LegalName {get;set;}
	public String restaurantPhoneNumber { get; set; }
	public String IBAN	{get;set;}
	public String swiftCode	{get;set;}
	public List<String> entityName {get;set;}
	public List<String> letterheadAddress {get;set;}
	public List<String> bankDetails	{get;set;}

	// in case of new address model this is populated from Restaurant address record (formatted address)
	public String restaurantAddress { get; set; }
	public String restaurantWebsite { get; set; }
	public String restaurantEmail { get; set; }
	public String restaurantClosingSchedule { get; set; }
	public String siteURL {get;set;}
	public String generalConditionsURLMarketing {get;set;}
	public String generalConditionsURLLogistics {get;set;}
	public String pedidosyaTranslation {get;set;}
	public String applicableLaw {get;set;}
	public String termination {get;set;}
	public String fixedTerm {get;set;}
	public String indeterminateTerm {get;set;}
	public String contactRoleValue {get;set;}
	public String prodPremPlacement {get;set;}
	public String prodPremPlacGold {get;set;}
	public String prodPremPlacGoldCat {get;set;}

	// billing address, according to new address model (AddressDeatil__c object)
	public String billingAddress {get; set; }

	// shipping address, according to new address model (AddressDeatil__c object)
	public String shippingAddress {get; set; }

	public Boolean hasNewAddressModel {get; set;}


	public Decimal deliveryFee { get; set; }
	public String deliveryTime { get; set; }
	public String deliveryZone { get; set; }
	public Boolean paymentMethodCash { get; set; }
	public Boolean paymentMethodCreditCard { get; set; }
	public Decimal minimumOrderValue { get; set; }
	public String closingSchedule { get; set; }
	public String availableDeliveryTimeWeekdayOpen { get; set; }
	public String availableDeliveryTimeWeekdayClose { get; set; }
	public String availableDeliveryTimeWeekendOpen { get; set; }
	public String availableDeliveryTimeWeekendClose { get; set; }
	public String availableDeliveryTimeComment { get; set; }
	public String availableDeliveryArea { get; set; }
	public String holiday { get; set; }
	public Date firstPaymentDate { get; set; }
	public Date paidPeriodOfApplictaion { get; set; }

	public Decimal creditCardNumber { get; set; }
	public Date creditCardValidityPeriod { get; set; }
	public Date collectionAccountBirthDate { get; set; }
	public String collectionAccountOwner { get; set; }
	public String collectionBankName { get; set; }
	public String collectionAccoutSortCode { get; set; }
	public Decimal collectionAccountNumber { get; set; }
	public String refundAccountOwner { get; set; }
	public String refundBankName { get; set; }
	public String refundAccountNumber { get; set; }

	public String bankAccountNumber { get; set; }
	public String bankAccountOwner { get; set; }
	public String bankSortCode { get; set; }
	public String invoiceTransmissionMethod { get; set; }

	// in case of new address model these field are populated from Restaurant Address record
	public String addressStreet { get; set; }
	public String addressPostal { get; set; }
	public String addressCity { get; set; }

	public String owner2Name { get; set; }
	public String owner2MobilePhone { get; set; }
	public String owner2Phone { get; set; }
	public String owner2Email { get; set; }

	public String backendId { get; set; }
	public String ownerFirstname { get; set; }
	public String ownerLastname { get; set; }
	public String owner2Firstname { get; set; }
	public String owner2Lastname { get; set; }
	public String ownerMailingStreet { get; set; }
	public String ownerMailingCity { get; set; }
	public String ownerMailingPostalCode { get; set; }
	public Boolean keyAccount { get; set; }
	public Boolean deliveryService { get; set; }

	public String taxNumber { get; set; }
	public String tradeRegNumber { get; set; }
	public String bankName { get; set; }

	public Date ownerBirthdate { get; set; }
	public Date owner2Birthdate { get; set; }
	public String accountCountry { get; set; }
	public String bankAccountType { get; set; }
	public String thirdPartyDeliveryService { get; set; }
	public String deliveryServiceValue	{get;set;}
	public String accPlatform { get; set; }
	public Map<String, String> mapFieldTranslation { get; set; }
	public String recordTypeDevName {get; set;}
	public String countryName {get; set;}

	// address variables for Austria quotes
	public String mjamQuoteLogoAddress {get; set;}
	public String mjamMainQuoteAddress {get; set;}
	public String mjamQuoteAddress {get; set;}

	public map<string,string> mpNamesMonth {
		get;
		set;
	}

	/**
	 * Create a new wrapper class for specified account id.
	 * quoteCreationDate is used to render the correct address on the quote screen,
	 * due to the introduction of the new address model.
	 *
	 * If you want to ignore the quoteCreationDate and consider the account creation
	 * date, set quoteCreationDate to null
	 * @param  acctId            account id
	 * @param  quoteCreationDate quote creation date, optional, can be null
	 * @return                   [description]
	 */
	public ClsAccountWrapper(Id acctId, Datetime quoteCreationDate) {
		Account acct = [
				SELECT Name, Backend_Id__c, CreatedDate, Phone, X3rd_Party_Delivery_Service__c, Fax, Holiday__c, Main_Contact__r.Name,
						Account_Email__c, Company_Number__c, Restaurant_Name__c, Legal_Name__c,Website, Payment_Method__c, Person_In_Charge__c,IBAN__c,
						Available_Delivery_Time_Weekday_Begin__c, Available_Delivery_Time_Weekday_End__c, Available_Delivery_Time_Weekend_Begin__c,
						Available_Delivery_Time_Weekend_End__c, Minimum_order_value_Cash__c,GRID__c, Company_Code__c,Swift_Code_BIC__c,
						Minimum_order_value_Credit_card__c, Owner.Phone, BillingPostalCode, BillingStreet, BillingState, BillingCity, BillingCountry, Billing_Dong__c, Billing_GunGu__c, Billing_Subdistrict__c,
						Available_Delivery_Time_Comment__c, Closing_Schedule__c, Delivery_Fee__c, Delivery_Zone__c, Delivery_Time__c, First_Payment_Date__c, Paid_Period_Of_Application__c, Credit_Card_Number__c, Credit_Card_Validity_Period__c,
						Refund_Account_Number__c, Refund_Account_Owner__c, Refund_Bank_Name__c, Collection_Account_Birthdate__c, bank_name__c, Collection_Account_Number__c, Collection_Account_Owner__c, Collection_Bank_Name__c,
						Invoice_Transmission_method__c, Bank_Account_Owner__c, Bank_Account_Number__c, Bank_Sort_Code__c, Bank_Account_Type__c, toLabel(Legal_form__c), Business_office__c, Registration_office__c,
						Collection_Account_Sort_Code__c, recordType.DeveloperName, Delivery_Service__c, Key_VIP_Account__c, Platform__c, Record_country__c, Tax_Number__c, Trade_Register_Number__c,Cuisine__c,
				(SELECT Id, FirstName, LastName, Salutation, Name, Phone, MobilePhone, Email, Contact_Role__c, Birthdate, MailingStreet, MailingCity, MailingPostalCode FROM Contacts WHERE AccountId = : acctId /*AND Contact_Role__c = 'Owner'*/)
				FROM Account
				WHERE Id = : acctId
		];
		this.paymentMethodCash = false;
		this.paymentMethodCreditCard = false;
		this.keyAccount = acct.Key_VIP_Account__c;
		if (acct.Delivery_Service__c != null && acct.Delivery_Service__c.contains('No')) {
			this.deliveryService = true;
		}
		this.deliveryServiceValue	= acct.Delivery_Service__c;
		this.minimumOrderValue = acct.Minimum_order_value_Credit_card__c;
		this.restaurantAddress = '';
		this.availableDeliveryArea = '';
		this.accPlatform = '';
		this.ownerName = '';
		this.ownerMobilePhone = '';
		this.ownerEmail = '';
		this.ownerMailingStreet = '';
		this.ownerMailingCity = '';
		this.ownerMailingPostalCode = '';
		this.ownerSalutation = '';
		this.fax = acct.Fax;
		this.companyName = acct.Name;
		this.companyId = acct.Company_Number__c;
		this.businessOffice = acct.Business_office__c;
		this.registrationOffice = acct.Registration_office__c;
		this.legalForm = acct.Legal_form__c;
		this.IBAN	= acct.IBAN__c;
		this.swiftCode	= acct.Swift_Code_BIC__c;
		this.GRID	= acct.GRID__c;
		this.cuisine = acct.Cuisine__c;
		this.restaurantName = acct.Restaurant_Name__c;
		this.legalName	= acct.Legal_Name__c;
		this.restaurantPhoneNumber = acct.Phone;
		this.restaurantWebsite = acct.Website;
		this.restaurantEmail = acct.Account_Email__c;
		this.restaurantClosingSchedule = acct.Closing_Schedule__c;
		this.deliveryFee = acct.Delivery_Fee__c;
		this.deliveryTime = acct.Delivery_Time__c;
		this.deliveryZone = acct.Delivery_Zone__c;
		this.thirdPartyDeliveryService = '';
		this.firstPaymentDate = acct.First_Payment_Date__c;
		this.paidPeriodOfApplictaion = acct.Paid_Period_Of_Application__c;
		this.availableDeliveryTimeWeekdayOpen = acct.Available_Delivery_Time_Weekday_Begin__c;
		this.availableDeliveryTimeWeekdayClose = acct.Available_Delivery_Time_Weekday_End__c;
		this.availableDeliveryTimeWeekendOpen = acct.Available_Delivery_Time_Weekend_Begin__c;
		this.availableDeliveryTimeWeekendClose = acct.Available_Delivery_Time_Weekend_End__c;
		this.availableDeliveryTimeComment = acct.Available_Delivery_Time_Comment__c;
		this.holiday = acct.Holiday__c;

		this.creditCardNumber = acct.Credit_Card_Number__c;
		this.creditCardValidityPeriod = acct.Credit_Card_Validity_Period__c;
		this.collectionAccountNumber = acct.Collection_Account_Number__c;
		this.collectionAccountOwner = acct.Collection_Account_Owner__c;
		this.collectionAccountBirthDate = acct.Collection_Account_Birthdate__c;
		this.collectionBankName = acct.Collection_Bank_Name__c;
		this.collectionAccoutSortCode = acct.Collection_Account_Sort_Code__c;
		this.refundAccountOwner = acct.Refund_Account_Owner__c;
		this.refundAccountNumber = acct.Refund_Account_Number__c;
		this.refundBankName = acct.Refund_Bank_Name__c;
		this.bankAccountType = acct.Bank_Account_Type__c;

		this.bankAccountNumber = acct.Bank_Account_Number__c;
		this.bankAccountOwner = acct.Bank_Account_Owner__c;
		this.bankSortCode = acct.Bank_Sort_Code__c;
		this.bankName = acct.Bank_Name__c;
		this.invoiceTransmissionMethod = acct.Invoice_Transmission_method__c;
		this.accountCountry = acct.billingcountry;
		this.recordTypeDevName = acct.RecordType.DeveloperName;
		this.countryName = acct.Record_country__c;


		this.backendId = acct.Backend_ID__c;

		this.taxNumber = acct.Tax_Number__c;
		this.tradeRegNumber = acct.Trade_Register_Number__c;
		if (acct.X3rd_Party_Delivery_Service__c != null)
			this.thirdPartyDeliveryService = acct.X3rd_Party_Delivery_Service__c;
		if (acct.Platform__c != null) {
			this.accPlatform = acct.platform__c;
			if (acct.platform__c.contains(';'))
				this.accPlatform = acct.platform__c.replace(';', ' & ');
		}
		Schema.DescribeFieldResult FRes = Account.Bank_Account_Type__c.getDescribe();
		List<Schema.PicklistEntry> PickVal = FRes.getPicklistValues();
		Map<String, String> mapFieldTranslation = new Map<String, String>();

		for (Schema.PicklistEntry e : PickVal) {
			mapFieldTranslation.put(e.value, e.label);
		}
		this.bankaccounttype = mapFieldTranslation.get(acct.Bank_Account_Type__c);
		Boolean noContact = true;
		Boolean billingContactFound = false;
		if (acct.Contacts != null && !acct.Contacts.isEmpty()) {
			for (Contact con : acct.Contacts) {
				if (con.Contact_Role__c != null) {
					this.contactRoleValue = con.Contact_Role__c;
					if (con.Contact_Role__c.equals('Owner')) {
						this.ownerName = con.Name != null ? con.Name : '';
						this.ownerFirstname = con.FirstName != null ? con.FirstName : '';
						this.ownerLastname = con.LastName != null ? con.LastName : '';
						this.ownerMobilePhone = con.MobilePhone != null ? con.MobilePhone : '';
						this.ownerEmail = con.Email != null ? con.Email : '';
						this.ownerPhone = con.Phone != null ? con.Phone : '';
						this.ownerBirthdate = con.Birthdate;
						this.ownerMailingStreet = con.MailingStreet != null ? con.MailingStreet : '';
						this.ownerMailingCity = con.MailingCity != null ? con.MailingCity : '';
						this.ownerMailingPostalCode = con.MailingPostalCode != null ? con.MailingPostalCode : '';
						this.ownerSalutation = con.Salutation != null ? con.Salutation : '' ;
						noContact = false;
						continue;
					} else if (con.Contact_Role__c == 'Billing Manager') {
						this.billingContactEmail = con.Email;
						this.billingMobilePhone = con.MobilePhone;
						this.billingSalutation = con.Salutation;
						this.billingFirstname = con.FirstName;
						this.billingLastname = con.LastName;
						billingContactFound = true;
					}
				}
			}
			if (!billingContactFound) {
				this.billingContactEmail = this.ownerEmail;
				this.billingMobilePhone = this.ownerMobilePhone;
				this.billingSalutation = this.ownerSalutation;
				this.billingFirstname = this.ownerFirstname;
				this.billingLastname = this.ownerLastname;
			}

		}

		if (noContact) {
			List<AccountContactRelation > accCon = [select contactid, contact.email, contact.name, contact.FirstName, contact.LastName, contact.Phone, contact.Birthdate, contact.MailingStreet, contact.MailingCity, contact.MailingPostalCode, contact.Salutation, contact.MobilePhone from AccountContactRelation where accountid = :acct.id and contact.contact_role__c = 'owner' and isactive = true order by CreatedDate desc];
			if (accCon != null && !accCon.isEmpty()) {
				this.ownerName = accCon[0].contact.Name != null ? accCon[0].contact.Name : '';
				this.ownerFirstname = accCon[0].contact.FirstName != null ? accCon[0].contact.FirstName : '';
				this.ownerLastname = accCon[0].contact.LastName != null ? accCon[0].contact.LastName : '';
				this.ownerMobilePhone = accCon[0].contact.MobilePhone != null ? accCon[0].contact.MobilePhone : '';
				this.ownerEmail = accCon[0].contact.Email != null ? accCon[0].contact.Email : '';
				this.ownerPhone = accCon[0].contact.Phone != null ? accCon[0].contact.Phone : '';
				this.ownerBirthdate = accCon[0].contact.Birthdate;
				this.ownerMailingStreet = accCon[0].contact.MailingStreet != null ? accCon[0].contact.MailingStreet : '';
				this.ownerMailingCity = accCon[0].contact.MailingCity != null ? accCon[0].contact.MailingCity : '';
				this.ownerMailingPostalCode = accCon[0].contact.MailingPostalCode != null ? accCon[0].contact.MailingPostalCode : '';
				this.ownerSalutation = accCon[0].contact.Salutation != null ? accCon[0].contact.Salutation : '' ;
			}
		}

		// set the billing contact email address to the owner contact email address if the billing contact is not present
		if(String.isBlank(this.billingContactEmail)){
			this.billingContactEmail = this.ownerEmail;
		}

		// fetch the entity names and the letter head addresses from the business config
		getEnitityNameAndAddress(acct.company_code__c);

		if (acct.Payment_Method__c != null && acct.Payment_Method__c.equals('Cash')) {
			this.paymentMethodCash = true;
			this.minimumOrderValue = acct.Minimum_order_value_Cash__c;
		} else {
			this.paymentMethodCreditCard = true;
			this.minimumOrderValue = acct.Minimum_order_value_Credit_card__c;
		}

		/* ADDRESS SETUP */

		// rollout date of the new address model based on Google Place Api for Austria
		Datetime newAddressModelLiveDate = Datetime.valueOf(Label.GPA_Address_Model_Activation_Date);
		Set<String> accountWithNewModel = new Set<String> {'Talabat_Account', 'AT_Account', 'DE_Account','FI_Account','PY_Account', 'HU_Account'};
		Datetime creationDateToCompare = quoteCreationDate != null ? quoteCreationDate : acct.CreatedDate;

		hasNewAddressModel = (accountWithNewModel.contains(acct.RecordType.DeveloperName) && creationDateToCompare >= newAddressModelLiveDate);


		// try to retrieve new model
		for (AddressDetail__c address : [
				SELECT
						FormattedAddress__c,
						Type__c,
						Model__c,

						GPA_Route_long_name__c,
						GPA_Street_number_long_name__c,
						GPA_Postal_code_long_name__c,
						GPA_Locality_long_name__c,
						Global_City_Label__c,
						Global_City_Area_Label__c

				FROM AddressDetail__c
				WHERE Account__c = :acct.Id
		]) {

			String addressLine = String.isNotBlank(address.FormattedAddress__c) ? address.FormattedAddress__c : '';
			if (address.Type__c.contains('Billing Address')) {
				this.billingAddress = addressLine;
			}

			if (address.Type__c.contains('Restaurant Address')) {
				this.restaurantAddress 	= addressLine;

				if(this.restaurantAddress != null) {
					this.restaurantAddress	= this.restaurantAddress.replaceAll('<br>',', ');
				}
				if (address.Model__c == 'GPA') {
					this.addressStreet = address.GPA_Route_long_name__c + ' ' + address.GPA_Street_number_long_name__c + ', ';
					this.addressCity = address.GPA_Locality_long_name__c;
					this.addressPostal = address.GPA_Postal_code_long_name__c;
				} else if (address.Model__c == 'XAL') {
					this.addressCity = address.Global_City_Label__c;
					this.addressStreet = address.Global_City_Area_Label__c;
				}
			}

			if (address.Type__c.contains('Shipping Address')) {
				this.shippingAddress = addressLine;
			}
		}

		// legacy support
		if (!hasNewAddressModel) {
			if (String.isNotBlank(acct.BillingState)) {
				this.restaurantAddress += acct.BillingState + ', ';
			}

			if (String.isNotBlank(acct.BillingCity)) {
				this.restaurantAddress += acct.BillingCity + ', ';
				this.addressCity = acct.BillingCity;
			}

			if (String.isNotBlank(acct.Billing_GunGu__c)) {
				this.restaurantAddress += acct.Billing_GunGu__c + ', ';
			}

			if (String.isNotBlank(acct.Billing_Dong__c)) {
				this.restaurantAddress += acct.Billing_Dong__c + ', ';
			}

			if (String.isNotBlank(acct.BillingStreet)) {
				this.restaurantAddress += acct.BillingStreet + ', ';
				this.addressStreet = acct.BillingStreet;
			}
			if (String.isNotBlank(acct.BillingPostalCode)) {
				this.addressPostal = acct.BillingPostalCode;
			}
			if (this.restaurantAddress.length() > 2) {
				this.restaurantAddress = this.restaurantAddress.subString(0, this.restaurantAddress.length() - 2);
			}
		}
	}

	public void getEnitityNameAndAddress(String companyCode){
		Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
		Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('OppQuoteProcess');

		if(mapBusinessLogic == null)
			return;

		Map<String, Business_Config__c> mapBusinessRules 				= mapBusinessLogic.get(companyCode+'_Account');

		if(mapBusinessRules == null)
			return;

		if(mapBusinessRules.containsKey('entityNameMap')){
			Map<String,String> entityMap =	(Map<String, String>)JSON.deserialize(mapBusinessRules.get('entityNameMap').business_rule_value__c,Map<String, String>.class);
			if(entityMap.containsKey(this.countryName)){
				this.entityName = entityMap.get(this.countryName).split(';');
			}
		}

		if(mapBusinessRules.containsKey('letterHeadAddressMap')){
			Map<String,String> addressMap =	(Map<String, String>)JSON.deserialize(mapBusinessRules.get('letterHeadAddressMap').business_rule_value__c,Map<String, String>.class);
			if(addressMap.containsKey(this.countryName)){
				this.letterheadAddress = addressMap.get(this.countryName).split(';');
			}
		}

		if(mapBusinessRules.containsKey('BankDetailsMap')){
			Map<String,String> bankMap =	(Map<String, String>)JSON.deserialize(mapBusinessRules.get('BankDetailsMap').business_rule_value__c,Map<String, String>.class);
			if(bankMap.containsKey(this.countryName)){
				this.bankDetails = bankMap.get(this.countryName).split(';');
			}
		}

		if(mapBusinessRules.containsKey('siteURLMap')){
			Map<String,String> siteURLMap =	(Map<String, String>)JSON.deserialize(mapBusinessRules.get('siteURLMap').business_rule_value__c,Map<String, String>.class);
			if(siteURLMap.containsKey(this.countryName)){
				this.siteURL = siteURLMap.get(this.countryName);
			}
		}

		if(mapBusinessRules.containsKey('generalConditionsURLMap')){

			Map<String,Map<String,String>> generalConditionsURLMap =	(Map<String, Map<String,String>>)JSON.deserialize(mapBusinessRules.get('generalConditionsURLMap').business_rule_value__c,Map<String, Map<String,String>>.class);
			if(generalConditionsURLMap.containsKey(this.countryName)){
				if(generalConditionsURLMap.get(this.countryName).ContainsKey('Logistics')){
					this.generalConditionsURLLogistics = generalConditionsURLMap.get(this.countryName).get('Logistics');
				}
				if(generalConditionsURLMap.get(this.countryName).ContainsKey('Marketing')){
					this.generalConditionsURLMarketing = generalConditionsURLMap.get(this.countryName).get('Marketing');
				}
			}
		}

		if(mapBusinessRules.containsKey('pedidosyaTranslation')){
			Map<String,String> pedidosyaTranslationMap =	(Map<String, String>)JSON.deserialize(mapBusinessRules.get('pedidosyaTranslation').business_rule_value__c,Map<String, String>.class);
			if(pedidosyaTranslationMap.containsKey(this.countryName)){
				this.pedidosyaTranslation = pedidosyaTranslationMap.get(this.countryName);
			}
		}

		if(mapBusinessRules.containsKey('applicableLaw')){
			Map<String,String> applicableLawMap =	(Map<String, String>)JSON.deserialize(mapBusinessRules.get('applicableLaw').business_rule_value__c,Map<String, String>.class);
			if(applicableLawMap.containsKey(this.countryName)){
				this.applicableLaw = applicableLawMap.get(this.countryName);
			}
		}

		if(mapBusinessRules.containsKey('Termination')){
			Map<String,String> terminationLawMap =	(Map<String, String>)JSON.deserialize(mapBusinessRules.get('Termination').business_rule_value__c,Map<String, String>.class);
			if(terminationLawMap.containsKey(this.countryName)){
				this.termination = terminationLawMap.get(this.countryName);
			}
		}

		if(mapBusinessRules.containsKey('fixedTerm')){
			Map<String,String> fixedTermMap =	(Map<String, String>)JSON.deserialize(mapBusinessRules.get('fixedTerm').business_rule_value__c,Map<String, String>.class);
			if(fixedTermMap.containsKey(this.countryName)){
				this.fixedTerm = fixedTermMap.get(this.countryName);
			}
		}

		if(mapBusinessRules.containsKey('indeterminateTerm')){
			Map<String,String> indeterminateTermMap =	(Map<String, String>)JSON.deserialize(mapBusinessRules.get('indeterminateTerm').business_rule_value__c,Map<String, String>.class);
			if(indeterminateTermMap.containsKey(this.countryName)){
				this.indeterminateTerm = indeterminateTermMap.get(this.countryName);
			}
		}

		if(mapBusinessRules.containsKey('premPlacementProdName')){
			Map<String,String> premPlacementNameMap =	(Map<String, String>)JSON.deserialize(mapBusinessRules.get('premPlacementProdName').business_rule_value__c,Map<String, String>.class);
			if(premPlacementNameMap.containsKey('Premium Placement')){
				this.prodPremPlacement = premPlacementNameMap.get('Premium Placement');
			}
			if(premPlacementNameMap.containsKey('Premium Placement Gold')){
				this.prodPremPlacGold = premPlacementNameMap.get('Premium Placement Gold');
			}
			if(premPlacementNameMap.containsKey('Premium Placement Gold Category')){
				this.prodPremPlacGoldCat = premPlacementNameMap.get('Premium Placement Gold Category');
			}
		}

		if(mapBusinessRules.containsKey('MjamQuoteLogoAddress')){
			this.mjamQuoteLogoAddress = mapBusinessRules.get('MjamQuoteLogoAddress').business_rule_value__c;
		}

		if(mapBusinessRules.containsKey('MjamMainQuoteAddress')){
			this.mjamMainQuoteAddress = mapBusinessRules.get('MjamMainQuoteAddress').business_rule_value__c;
		}

		if(mapBusinessRules.containsKey('MjamQuoteAddress')){
			this.mjamQuoteAddress = mapBusinessRules.get('MjamQuoteAddress').business_rule_value__c;
		}
		if(mapBusinessRules.containsKey('MonthsMap')){
			Map<String,String> mpNamesMonth =	(Map<String, String>)JSON.deserialize(mapBusinessRules.get('MonthsMap').business_rule_value__c,Map<String, String>.class);
		}else{
			{
				mpNamesMonth = new map<string,string>{'1' => 'Enero', '2' => 'Febrero' , '3' => 'Marzo', '4' => 'Abril', '5' => 'Mayo', '6' => 'Junio' , '7' => 'Julio','8' => 'Agosto','9' => 'Septiembre','10' => 'Octubre','11' => 'Noviembre','12' => 'Diciembre'};
			}
		}

	}
}