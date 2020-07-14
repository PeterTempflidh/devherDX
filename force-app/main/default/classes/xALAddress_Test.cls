/**
* @author Mantas Jurkunas
* @date 09.09.2019
*
* @description Test class for xAL_Address related methods
*/

@IsTest
public with sharing class xALAddress_Test {

    @TestSetup
    private static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c country = UnitTestDataFactory.createCountry('CL', 'Chile', 'USD');
        insert country;
        CountryCompanyMapping__c countryCompanyMapping = new CountryCompanyMapping__c(Name = 'Chile', Company_Code__c='PY');
        insert countryCompanyMapping;
        Business_Config__c addressConfig = UnitTestDataFactory.createBusinessConfig('xALAddressObject', 'Process', 'TextFieldVisibility',
                '{"Chile":{"postCode":false, "translatedStreetName":true}}', country.Id, 'PY_Account', true, true);
        insert addressConfig;
    }

    @IsTest
    private static void testGetNextAddressLineText() {
        Map<String, Boolean> textVisibilityMap = xALAddress_Utils.getNextAddresslineText('Chile');
        System.assert(textVisibilityMap.containsKey('postCode'));
        System.assert(!textVisibilityMap.get('postCode'));
        System.assert(textVisibilityMap.containsKey('translatedStreetName'));
        System.assert(textVisibilityMap.get('translatedStreetName'));
    }

    @IsTest
    public static void test_getCountry() {
        Country__c country = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'USD');
        insert country;
        Account account = UnitTestDataFactory.createAccount('FP account', country, 'FP_Account');
        account.Phone = '+85227367722';
        insert account;

        AddressDetail__c addressDetail = new AddressDetail__c(
                AddressLine__c = 'Oranienburger Str. 70, Berlin, Germany',
                CountryCode__c = 'DE',
                CountryName__c = 'Germany',
                CountryDevName__c = 'Germany',
                AdministrativeAreaName__c ='admArea',
                AdministrativeAreaDevName__c = 'admArea',
                SubAdministrativeAreaName__c = 'subAdminArea',
                SubAdministratriveAreaDevName__c = 'subAdminArea',
                LocalityName__c = 'locality',
                LocalityDevName__c = 'locality',
                Account__c = account.Id,
                Type__c = 'Billing Address;Shipping Address'
        );
        Trigger_Manager__c tm = Trigger_Manager__c.getInstance();
        tm.Deactivate_AddressDetail_Trigger__c = true;
        upsert tm;
        insert addressDetail;

        xALCountry xcountry = CtrCreateNewAddress.getCountryByCountryName('Hong Kong');
        System.assertEquals('Hong Kong', xcountry.label);
        System.assertEquals('HK', xcountry.code);

        xALCountry xcountry2 = CtrCreateNewAddress.getAccountCountry(account.Id);
        System.assertEquals('Hong Kong', xcountry2.label);
        System.assertEquals('HK', xcountry2.code);

        List<xALAddressDetails> alAddressDetails = CtrCreateNewAddress.getXALAddressDetailsPerAccount(account.Id);
        System.assertEquals(1, alAddressDetails.size());

        alAddressDetails = CtrCreateNewAddress.saveXALAddresses(alAddressDetails);
        System.assertEquals(1, alAddressDetails.size());

        xALAddressDetails alAddressDetail = CtrCreateNewAddress.saveXALAddress(alAddressDetails.get(0));
        System.assertEquals('admArea', alAddressDetail.country.adminArea.label);
        System.assertEquals('subAdminArea', alAddressDetail.country.adminArea.subAdministrativeArea.label);
        System.assertEquals('locality', alAddressDetail.country.adminArea.subAdministrativeArea.locality.label);
    }

    @IsTest
    public static void test_insertAddress() {
        xAL_Address__c address1 = new xAL_Address__c(
                xAL_Country__c = 'Hong Kong',
                xAL_AdministrativeAreaName__c='area1',
                xAL_SubAdministrativeAreaName__c='area2',
                Type__c = 'City'
        );

        xAL_Address__c address2 = new xAL_Address__c(
                xAL_Country__c = 'Hong Kong',
                xAL_AdministrativeAreaName__c='area1',
                xAL_SubAdministrativeAreaName__c='area2',
                Type__c = 'State'
        );

        Country__c country = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'HKD');
        insert country;
        List<Lead> lstLeads = UnitTestDataFactory.createLeads(1, country, 'FP Test Lead', 'HK', 'HKD', 'FP Restaurant Test Lead', 'FP_Lead');
        lstLeads[0].Area__c = 'test area';
        insert lstLeads;

        Account account = UnitTestDataFactory.createAccount('FP account', country, 'FP_Account');
        account.Phone = '+85227367722';
        insert account;

        Business_Config__c b1x = new Business_Config__c(Business_Rule_Name__c='Hong KongAddressMappingJSON',
                Business_Rule_Value__c='{"Country":"City","City":"District","District": "Area"}',
                Id_Country__c=country.id,Is_Active__c=true,Parent__c=true,Process_Name__c='xALAddressObject',
                Record_Type_Id__c='FP_Account',Type__c='Process');
        insert b1x;

        Map<String, Business_Config__c> bconfMap_1 = new Map<String, Business_Config__c>{b1x.Business_Rule_Name__c => b1x};
        Map<String, Map<String, Business_Config__c>> bconfMap_1f = new Map<String, Map<String, Business_Config__c>>{'FP_Account' => bconfMap_1};
        Map<String, Map<String, Map<String, Business_Config__c>>> testMap = new Map<String, Map<String, Map<String, Business_Config__c>>>{b1x.Process_Name__c => bconfMap_1f};
        LibBusinessConfig.setMotherOfAllBusinessMaps(testMap);

        try {
            insert address1;
            insert address2;
        } catch (DmlException e) {
            System.debug(e.getMessage());
        }
        xAL_Address__c addresses = xALAddress_Selector.getById(address1.Id);
        System.assertEquals('City', addresses.Type__c);
        System.assert(address2.Id == null);
    }

    /**
     * @description Test if next address lines are retrieved properly with similar city names
     */
    @IsTest
    public static void testAddressRetrieval() {
        CountryCompanyMapping__c countryCompanyMapping = new CountryCompanyMapping__c(Name = 'Hong Kong', Company_Code__c='FP');
        insert countryCompanyMapping;
        Country__c country = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'USD');
        insert country;
        Business_Config__c addressConfig = new Business_Config__c(Id_Country__c=country.Id, Process_Name__c='xALAddressObject', Business_Rule_Name__c='AddressMappingJSON', Business_Rule_Value__c='{"Country":"City","City":"Area"}', Record_Type_Id__c='FP_Account', Is_Active__c=true, Type__c='Process');
        insert addressConfig;
        Account account = UnitTestDataFactory.createAccount('FP account', country, 'FP_Account');
        account.Phone = '+85227367722';
        insert account;

        xAL_Address__c address0 = new xAL_Address__c(
                xAL_Country__c = 'Hong Kong',
                Type__c = 'Country'
        );
        xAL_Address__c address0_1 = new xAL_Address__c(
                xAL_Country__c = 'Hong Kong',
                xAL_AdministrativeAreaName__c='area1',
                Type__c = 'City'
        );
        xAL_Address__c address0_2 = new xAL_Address__c(
                xAL_Country__c = 'Hong Kong',
                xAL_AdministrativeAreaName__c='area 1',
                Type__c = 'City'
        );
        xAL_Address__c address0_3 = new xAL_Address__c(
                xAL_Country__c = 'Hong Kong',
                xAL_AdministrativeAreaName__c='area  1',
                Type__c = 'City'
        );
        xAL_Address__c address0_4 = new xAL_Address__c(
                xAL_Country__c = 'Hong Kong',
                xAL_AdministrativeAreaName__c='area   1',
                Type__c = 'City'
        );

        xAL_Address__c address1 = new xAL_Address__c(
                xAL_Country__c = 'Hong Kong',
                xAL_AdministrativeAreaName__c='area1',
                xAL_SubAdministrativeAreaName__c='area2',
                Type__c = 'Area'
        );

        xAL_Address__c address2 = new xAL_Address__c(
                xAL_Country__c = 'Hong Kong',
                xAL_AdministrativeAreaName__c='area 1',
                xAL_SubAdministrativeAreaName__c='area2',
                Type__c = 'Area'
        );

        xAL_Address__c address3 = new xAL_Address__c(
                xAL_Country__c = 'Hong Kong',
                xAL_AdministrativeAreaName__c='area  1',
                xAL_SubAdministrativeAreaName__c='area2',
                Type__c = 'Area'
        );

        xAL_Address__c address4 = new xAL_Address__c(
                xAL_Country__c = 'Hong Kong',
                xAL_AdministrativeAreaName__c='area   1',
                xAL_SubAdministrativeAreaName__c='area2',
                Type__c = 'Area'
        );

        try {
            insert new List<xAL_Address__c> { address0, address0_1, address0_2, address0_3, address0_4, address1, address2, address3, address4 };
        } catch (DmlException e) {
            System.debug(e.getMessage());
        }
        Test.startTest();
        List<xAL_Address__c> addresses = xALAddress_Utils.getNextAddressLineValues(xALAddress_Selector.getById(address0_1.Id));
        System.assertEquals(1, addresses.size());
        addresses = xALAddress_Utils.getNextAddressLineValues(xALAddress_Selector.getById(address0_2.Id));
        System.assertEquals(1, addresses.size());
        addresses = xALAddress_Utils.getNextAddressLineValues(xALAddress_Selector.getById(address0_3.Id));
        System.assertEquals(1, addresses.size());
        addresses = xALAddress_Utils.getNextAddressLineValues(xALAddress_Selector.getById(address0_4.Id));
        System.assertEquals(1, addresses.size());
        Test.stopTest();
    }

}
