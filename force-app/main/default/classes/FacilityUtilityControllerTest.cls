/**
* @author Shivani
* @date 15.05.2020
*
* @description Test class for FacilityUtilityController
*/
@IsTest
public class FacilityUtilityControllerTest {
    static final String TESTCOUNTRY = 'Test_Scenario_Country';
	static final xAL_Country__mdt COUNTRY = [
	        SELECT DeveloperName, MasterLabel, Code__c
	        FROM xAL_Country__mdt
	        WHERE DeveloperName = :TESTCOUNTRY];

     /*******************************************************************************************************
    * @description SSC-2796 - dummy Record creation before actual test method to test various conditions
    */
    @testSetup static void setup() {
        UnitTestDataFactory.getRecordtypeValues();

        Integration_Config__c cs1 = new Integration_Config__c(
		Name = 'GoogleMapsSignature', Password__c = 'Abvcd-asdfdgfhjklhnO0=');
		insert cs1;
        //Inserting record for PY
        Country__c pYCoutry = UnitTestDataFactory.createCountry('CL','Chile', 'EUR');
        insert pYCoutry;
        insertBusinessConfig(pYCoutry);

        List<Lead> leadList = UnitTestDataFactory.createLeads(1, pYCoutry,'Test_Lead', 'Test Company', 'EUR', 'BCCORP', 'PY_Lead');
        insert leadList;
        Account pYaccount = UnitTestDataFactory.createAccount('TestPY',pYCoutry,'PY_Account');
        insert pYaccount;

        //Inserting record for FP
        Country__c cdFP = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'EUR');
        insert cdFP;

        Account fpAccount = UnitTestDataFactory.createAccount('TESTFP', cdFP, 'FP_Account');
        fpAccount.Vertical__c = 'Restaurant';
        fpAccount.phone = '+85212345678';
        fpAccount.Record_Country__c = 'Hong Kong';
        insert fpAccount;

        AddressDetail__c addr = new AddressDetail__c(
		    Type__c = 'Restaurant Address;Billing Address',
		    Account__c = pYaccount.Id,
		    LatLng__Latitude__s = 10.0,
		    LatLng__Longitude__s = 5.0,
		    AddressLine__c = 'amazing address',
		    CountryDevName__c = COUNTRY.DeveloperName,
		    CountryName__c = COUNTRY.MasterLabel,
		    CountryCode__c = COUNTRY.Code__c
		);

		insert addr;


    }

    /*******************************************************************************************************
    * @description SSC-2796 - testing FacilityUtilityController for value assignment to Facility Business config wrapper
    */
    @IsTest
    public static void testFacilityUtilityControllerConstructorPositiveCase() {
        Lead leadRecord = [SELECT Id,RecordTypeId FROM Lead where LastName ='Test_Lead'];
        FacilityUtilityController facilityCont;
        ApexPages.StandardController sc = new ApexPages.StandardController(leadRecord);
        Test.startTest();
        facilityCont = new FacilityUtilityController(sc);
        Test.stopTest();

        System.assert(facilityCont.wrpForFacilityValidation != null,'Facility Config Wrapper value does not exist in Business cofig FOr PY');
        System.assert(facilityCont.wrpForFacilityValidation.CondLabels != null,'Conditional Label does not exist in Facility Config Wrapper  FOr PY');
        System.assert(facilityCont.wrpForFacilityValidation.RecTypes != null,'RecTypes does not exist in Facility Config Wrapper  FOr PY');
        System.assert(facilityCont.wrpForFacilityValidation.ErrMessages != null,'errMessages does not exist in Facility Config Wrapper  FOr PY');
        System.assertEquals('Restaurant Address',facilityCont.wrpForFacilityValidation.CondLabels.restaurantAddressType);
        System.assertEquals('Branch - Kitchen Restaurant',facilityCont.wrpForFacilityValidation.CondLabels.branchKitchenRestaurantAccountType);
        System.assertEquals('PY_Account',facilityCont.wrpForFacilityValidation.RecTypes.accRecordType);
        System.assertEquals('Facility_Account',facilityCont.wrpForFacilityValidation.RecTypes.facilityRecordType);
        System.assertNotEquals(null,facilityCont.wrpForFacilityValidation.ErrMessages.kitchenRestaurantFacilityValidationMessage);
        System.assertNotEquals(null,facilityCont.wrpForFacilityValidation.ErrMessages.errorValidationOnAddressForm);
        System.assertNotEquals(null,facilityCont.wrpForFacilityValidation.ErrMessages.errorAddressMessageForRestaurant);

    }
     /*******************************************************************************************************
    * @description SSC-2796 - testing FacilityUtilityController for Account Clone extension for different region
    */
    @IsTest
    public static void testFacilityUtilityControllerConstDifferentRegion() {
        Account fpAccount = [SELECT Id,RecordTypeId FROM Account where name ='TESTFP'];
        FacilityUtilityController facilityCont;
        ApexPages.StandardController sc = new ApexPages.StandardController(fpAccount);
        Test.startTest();
        facilityCont = new FacilityUtilityController(sc);
        Test.stopTest();
        System.assert(facilityCont.wrpForFacilityValidation != null,'Facility Config Wrapper value does not exist in Business cofig For FP' );
        System.assert(facilityCont.wrpForFacilityValidation.CondLabels == null,'CondLabels Wrapper value exists in Business cofig For FP');
    }

     /*******************************************************************************************************
    * @description SSC-2796 - testing FacilityUtilityController for Empty Extension
    */
    @IsTest
    public static void testFacilityUtilityControllerConstNegativeCase() {
        Account accRecrod = new Account();
        FacilityUtilityController facilityCont;
        ApexPages.StandardController sc = new ApexPages.StandardController(accRecrod);
        Test.StartTest();
        facilityCont = new FacilityUtilityController(sc);
        Test.stopTest();
        System.assert(facilityCont.wrpForFacilityValidation.CondLabels == null,'Facility Config Wrapper value exists in Business cofig empty record instance');
        System.assert(facilityCont.wrpForFacilityValidation.RecTypes == null,'Facility Config Wrapper value exists in Business cofig empty record instance');
        System.assert(facilityCont.wrpForFacilityValidation.ErrMessages == null,'Facility Config Wrapper value exists in Business cofig empty record instance');
        System.assert(facilityCont.wrpForFacilityValidation.AddModels == null,'Facility Config Wrapper value exists in Business cofig empty record instance');

    }

     /*******************************************************************************************************
    * @description SSC-2796 - testing FacilityUtilityController for adddress Details page
    */
    @IsTest
    public static void testFacilityUtilityControllerConstAddressDetails() {
        Account fpAccount = [SELECT Id,RecordTypeId FROM Account where name ='TestPY'];
        AddressDetail__c addDetail = [SELECT SignedGoogleMapsPathRequest__c,Account__c
                                      FROM AddressDetail__c
                                      WHERE Account__c =:fpAccount.Id];
        FacilityUtilityController facilityCont;
        ApexPages.StandardController sc = new ApexPages.StandardController(addDetail);
        Test.StartTest();
        facilityCont = new FacilityUtilityController(sc);
        Test.stopTest();
        System.assert(facilityCont.wrpForFacilityValidation.CondLabels != null,'Facility Config Wrapper cond lable values does not exist');
        System.assert(facilityCont.wrpForFacilityValidation.AddModels != null,'Facility Config Wrapper Address values does not exist');
        System.assertEquals('Egypt,Argentina,Chile,Bolivia',facilityCont.wrpForFacilityValidation.AddModels.xalNewCountries);
        System.assertEquals('Panamá,Paraguay',facilityCont.wrpForFacilityValidation.AddModels.xalCountries);
        System.assertEquals('Uruguay,Dominican Republic',facilityCont.wrpForFacilityValidation.AddModels.gpaCountries);
        System.assertEquals('',facilityCont.wrpForFacilityValidation.AddModels.daumCountries);
        System.assertNotEquals(null,facilityCont.wrpForFacilityValidation.ErrMessages.errorAddressMessageForKitchen);
        System.assertNotEquals(null,facilityCont.wrpForFacilityValidation.ErrMessages.typeFieldRequired);

    }

    /*******************************************************************************************************
    * @description SSC-2796- inserting business config for Facility
    * @param pYCoutry the country for which business config record will be inserted
    */
    public static void insertBusinessConfig(Country__c pYCoutry){
        String json = '{'+
		' \"CondLabels\" : {'+
		' \"restaurantAddressType\" : \"Restaurant Address\", '+
		' \"branchKitchenRestaurantAccountType\" : \"Branch - Kitchen Restaurant\" '+
		' },'+
		'\"RecTypes\" : { '+
		'	\"accRecordType\" : \"PY_Account\",'+
		'	\"facilityRecordType\" : \"Facility_Account\" '+
		'	},'+
		' \"ErrMessages\": { '+
		'	\"errorAddressMessageForKitchen\" : \"You cannot select Restaurant Address as Address type for Branch Kitchen. Please remove Restaurant Address.\", '+
		'	\"typeFieldRequired\" : \"Please select a value in Type field\" ,'+
		'	\"kitchenRestaurantFacilityValidationMessage\" : \"Please connect this Kitchen Restaurant to the Facility that it is located in before you proceed.\", '+
		'	\"errorValidationOnAddressForm\" : \"Please review errors in the form\" ,'+
		'	\"errorAddressMessageForRestaurant\" : \"You cannot change the Restaurant Address as Address type for Branch Kitchen.\"'+
		'	},'+
        ' \"AddModels\": { '+
		'	\"xalNewCountries\" : \"Egypt,Argentina,Chile,Bolivia\", '+
		'	\"xalCountries\" : \"Panamá,Paraguay\" ,'+
		'	\"gpaCountries\" : \"Uruguay,Dominican Republic\", '+
		'	\"daumCountries\" : \"\"'+
		'	}'+
		'}';

        //inserting business config record to
        Business_Config__c busConf = new Business_Config__c(Business_Rule_Name__c='checkParameters',Business_Rule_Value__c=json,Id_Country__c=pYCoutry.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='LeadConversionAndAccountCloneFacilityCheck',Record_Type_Id__c='PY_Lead,PY_Account',Type__c='Process');
        insert busConf;
    }
}
