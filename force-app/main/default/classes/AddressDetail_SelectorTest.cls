/**
 * @description [Test class for AddressDetail_Selector]
 * Created by Abhinav.Bhatia on 17/06/2020.
 */

@IsTest
private class AddressDetail_SelectorTest {
    static final String ADDRESS_TYPE_BILLING_ADDRESS = 'Billing Address';
    @TestSetup static  void setup(){

        UnitTestDataFactory.getRecordtypeValues();
        User testUser = UnitTestDataFactory.createUser('Talabat Sales Team', 'talabattestuser@talabat.com', 'Talabat', 'AE');
        insert testUser;

        //CREATE ADDRESS DETAILS
        Integration_Config__c integrationConfig = new Integration_Config__c(
                Name = 'GoogleMapsSignature', Password__c = 'Abcd='
        );
        insert integrationConfig;

        System.runAs(testUser) {
            Country__c country = UnitTestDataFactory.createCountry('AE', 'United Arab Emirates', 'AED');
            insert country;
            List<Account> accounts = UnitTestDataFactory.createAccounts(1, country, Constants.ACCOUNT_RT_TALABAT_ACCOUNT);
            insert accounts;
            List<AddressDetail__c> addressDetails = UnitTestDataFactory.createAddressDetails(new List<String>{Constants.ADDRESS_TYPE_RESTAURANT_ADDRESS,ADDRESS_TYPE_BILLING_ADDRESS}, accounts[0].Id);
            insert addressDetails;
        }
    }

    /**
    * @date     : [17/06/2020]
    * @method name  : testGetAddressById
    * @description  : Test method of the getById and getByIdAndAccountId
    */
    @IsTest
    static void testGetAddressById() {
        List<AddressDetail__c> addressDetail  = AddressDetail_Selector.getAddressByType(ADDRESS_TYPE_BILLING_ADDRESS);
        AddressDetail__c resultAddress = new AddressDetail__c();
        List<AddressDetail__c> resultAddressList = new List<AddressDetail__c>();
        AddressDetail__c getXALById = new AddressDetail__c();

        if(!addressDetail.isEmpty()) {
            Test.startTest();
            resultAddress = AddressDetail_Selector.getById(addressDetail[0].Id);
            resultAddressList = AddressDetail_Selector.getByIdAndAccountId(addressDetail[0].Id, addressDetail[0].Account__c);
            getXALById = AddressDetail_Selector.getXalById(addressDetail[0].Id);
            Test.stopTest();
        }
        System.assert(null != resultAddress);
        System.assert(!resultAddressList.isEmpty());
        System.assert(null != getXALById);
    }

    /**
    * @date     : [17/06/2020]
    * @method name  : testGetAddressesByAccountId
    * @description  : Test method of the getByAccountId,getAccountIdBillingAddressMap and getAccountIdREstaurantAddressMap
    */
    @IsTest
    static void testGetAddressesByAccountId() {
        List<AddressDetail__c> billingAddressDetail  = AddressDetail_Selector.getAddressByType(ADDRESS_TYPE_BILLING_ADDRESS);
        List<AddressDetail__c> restaurantAddressDetail  = AddressDetail_Selector.getAddressByType(Constants.ADDRESS_TYPE_RESTAURANT_ADDRESS);
        List<AddressDetail__c> resultAddressList = new List<AddressDetail__c>();
        Map<Id,AddressDetail__c> mapOfIdAndAddress = new Map<Id,AddressDetail__c>();
        Map<Id,AddressDetail__c> mapOfAccountAndRestaurantAddress = new Map<Id,AddressDetail__c>();

        if(!billingAddressDetail.isEmpty() && !restaurantAddressDetail.isEmpty()) {
            Test.startTest();
            resultAddressList = AddressDetail_Selector.getByAccountId(billingAddressDetail[0].Account__c);
            mapOfIdAndAddress = AddressDetail_Selector.getAccountIdBillingAddressMap(new Set<Id>{billingAddressDetail[0].Account__c});
            mapOfAccountAndRestaurantAddress = AddressDetail_Selector.getAccountIdREstaurantAddressMap(new Set<Id>{restaurantAddressDetail[0].Account__c});
            Test.stopTest();
        }
        System.assert(!resultAddressList.isEmpty());
        System.assert(mapOfIdAndAddress.size() > 0);
        System.assert(mapOfAccountAndRestaurantAddress.size() > 0);

    }

    /**
    * @date     : [17/06/2020]
    * @method name  : testGetAccountById
    * @description  : Test method of the getByAccountIds and getAddressByAccountIds
    */
    @IsTest
    static void testGetAccountById() {
        List<AddressDetail__c> addressDetail  = AddressDetail_Selector.getAddressByType(ADDRESS_TYPE_BILLING_ADDRESS);
        List<AddressDetail__c> resultByAccountIds = new List<AddressDetail__c>();
        List<AddressDetail__c> resultAddressByAccountIds = new List<AddressDetail__c>();
        List<AddressDetail__c> accountIdByDaumModel = new List<AddressDetail__c>();

        if(!addressDetail.isEmpty()) {
            Test.startTest();
            resultByAccountIds = AddressDetail_Selector.getByAccountIds(new Set<Id>{addressDetail[0].Account__c});
            resultAddressByAccountIds = AddressDetail_Selector.getAddressByAccountIds(new Set<Id>{addressDetail[0].Account__c});
            accountIdByDaumModel = AddressDetail_Selector.getByAccountIdsAndDaumModel(new Set<Id>{addressDetail[0].Account__c}, 'Old Address');
            Test.stopTest();
        }
        System.assert(!resultByAccountIds.isEmpty());
        System.assert(!resultAddressByAccountIds.isEmpty());
    }
}
