@IsTest
private class UnitTestClsContractProcessor {

    private static List<Contract> newContracts = new List<Contract>();
    private static List<Contract> oldContracts = new List<Contract>();
    private static List<Account> accounts;
    private static Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Contract'});


    @TestSetup static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
        List<Platform_Country__c> platformCountry = new List<Platform_Country__c>();
        platformCountry.add(new Platform_Country__c(Name = 'TalabatPlatform', Country__c = 'Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(Name = 'FOCPlatform', Country__c = 'Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;

        Country__c testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        insert testCountry;

        Business_Config__c config1 = UnitTestDataFactory.createBusinessConfig('ContractCreation', 'Process', 'GroupBeforeSorting', 'false', testCountry.Id, 'Yogiyo_Contract', true, true);
        Business_Config__c config2 = UnitTestDataFactory.createBusinessConfig('ContractCreation', 'Process', 'validServiceTypesForPlatformStatusChange', 'Commission Fee, Logistics Fee', testCountry.Id, 'Yogiyo_Contract', true, false);
        Business_Config__c config3 = UnitTestDataFactory.createBusinessConfig('ContractCreation', 'Process', 'additionalSwitchBusinessTypes', 'Upgrade/Upsell,Winback,Downgrade', testCountry.Id, 'Yogiyo_Contract', true, false);
        Business_Config__c config4 = UnitTestDataFactory.createBusinessConfig('ContractCreation', 'Process', 'deliveryServiceTypes', 'Commission Fee, Logistics Fee', testCountry.Id, 'Yogiyo_Contract', true, false);
        Business_Config__c config5 = UnitTestDataFactory.createBusinessConfig('ContractCreation', 'Process', 'deliveryServiceTypesMap', '{"Logistics Fee" : "DH Delivery", "Commission Fee" : "Partner Delivery", "Logistics Fee, Commission Fee" : "Hybrid"}', testCountry.Id, 'Yogiyo_Contract', true, false);
        List<Business_Config__c> bConfigs = new List<Business_Config__c> {config1, config2, config3, config4, config5};
        insert bConfigs;
    }

    static void setupUserData(User u) {
        System.runAs(u) {
            //Country__c testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            //insert testCountry;
            Country__c testCountry = [SELECT Iso__c,
                                      Name,
                                      CurrencyIsoCode
                                      FROM Country__c
                                      WHERE Iso__c = 'KR' ];

            accounts = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
            insert accounts;

            Platform_Performance__c platPerformance = new Platform_Performance__c (Account__c = accounts.get(0).Id,
                                                                                    Platform__c = 'Yogiyo',
                                                                                    Vendor_Status__c = '');
            insert platPerformance;
            
			List<Opportunity> testOpportunities = UnitTestDataFactory.createOpportunities(accounts, 2, 'Yogiyo_Opportunity', System.today());
            testOpportunities.get(0).Business_Type__c = 'Switch';
            insert testOpportunities;
            
            for (Integer i = 1; i < 11; i++) {
                oldContracts.add(new Contract(
                                    AccountId = accounts[0].Id,
                                    Id_Opportunity__c = testOpportunities.get(0).Id,
                                    StartDate = Date.today().addDays(i + 1),
                                    End_Date__c = Date.today().addDays(i + 2),
                                    Status = 'Draft',
                                    Service_Type__c = 'Commission Fee',
                                    RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id,
                                    Company_Name__c = 'Yogiyo'
                                    )
                                );
            }
            oldContracts.add(new Contract(AccountId = accounts[0].Id, StartDate = Date.today(), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id));

            for (Integer i = 12; i < 212; i++) {
                newContracts.add(new Contract(
                                    AccountId = accounts[0].Id,
                                    Id_Opportunity__c = testOpportunities.get(0).Id,
                                    StartDate = Date.today().addDays(i + 1),
                                    End_Date__c = Date.today().addDays(i + 2),
                                    Status = 'Draft',
                                    Service_Type__c = 'Logistics Fee',
                                    RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id,
                                    Company_Name__c = 'Yogiyo'
                                    )
                                );
            }
            newContracts.add(new Contract(AccountId = accounts[0].Id, StartDate = Date.today().addDays(1), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id));

            //Business_Config__c config = UnitTestDataFactory.createBusinessConfig('ContractCreation', 'Process', 'GroupBeforeSorting', 'false', testCountry.Id, 'Yogiyo_Contract', true, true);

            //insert config;
        }
    }


    @isTest static void test_noContractsAvailableOnAccountYet() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'testUser@deliveryhero.com', 'Yogiyo', 'KR');
        insert testUser;
        PermissionSet ps = [SELECT Id From PermissionSet WHERE Name = 'Exclude_from_Validation'];
        insert new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = ps.Id );


        Test.startTest();
        System.runAs(testUser) {
            setupUserData(testUser);
            insert newContracts;
            ClsContractProcessor.preventDuplicateContracts(newContracts);
        }
        Test.stopTest();

        // Nothing happens
        System.assertEquals(null, newContracts[newContracts.size() - 1].End_Date__c);

        Platform_Performance__c pp = [SELECT Id, Account__c, Platform__c, Platform_Online_Status__c, Vendor_Status__c
                FROM Platform_Performance__c WHERE Platform__c = 'Yogiyo' LIMIT 1];

        System.assertEquals(ContractSelector.ONLINE_STATUS_PENDINGACTIVATION, pp.Vendor_Status__c);
    }


    @isTest static void test_contractsOnAccountPreventDuplicates() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'testUser@deliveryhero.com', 'Yogiyo', 'KR');
        insert testUser;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Exclude_from_Validation'];
        insert new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = ps.Id );
        Test.startTest();
        System.runAs(testUser) {
            setupUserData(testUser);
            insert oldContracts;
            insert newContracts;
            ClsContractProcessor.preventDuplicateContracts(newContracts);
        }
        Test.stopTest();

        Set<Id> conIds = new Set<Id>();
        for (Contract cont : oldContracts) {
            conIds.add(cont.Id);
        }

        Boolean allTerminated = true;
        List<Contract> contracts = [SELECT Id, Status, StartDate, End_Date__c FROM Contract WHERE Id IN :conIds];
        Contract con = [SELECT Id, Status, End_Date__c FROM Contract WHERE Id = : oldContracts[oldContracts.size() - 1].Id];

        // Check to make sure that all previous contacts with a start date greated than the start date of the earliest new contract are terminated.
        /*for(Contract cont : contracts){
            if((cont.Id != con.Id) && (cont.Status != 'Terminated')){
                allTerminated = false;
            }
        }*/

        // System.assertEquals(Date.today(), con.End_Date__c);
        System.assertEquals('Draft', con.Status);
        //System.assertEquals(true, allTerminated);
    }


    @IsTest static void test_PlatformStatusForActiveContract() {

        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'testUser@deliveryhero.com', 'Yogiyo', 'KR');
        insert testUser;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Exclude_from_Validation'];
        insert new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = ps.Id );


        Test.startTest();
        System.runAs(testUser) {
            setupUserData(testUser);
            newContracts[0].StartDate = Date.today().addDays(-1);
            insert newContracts;
            ClsContractProcessor.preventDuplicateContracts(newContracts);
        }
        Test.stopTest();

        Platform_Performance__c pp = [SELECT Id, Account__c, Platform__c, Platform_Online_Status__c, Vendor_Status__c
        FROM Platform_Performance__c WHERE Platform__c = 'Yogiyo' LIMIT 1];

        System.assertEquals(ContractSelector.ONLINE_STATUS_ACTIVE, pp.Vendor_Status__c);
    }

    /**
     * @description Test scenario when one contract is ending today and another one is starting the next day. Contract should remain active in this case.
    */
    @IsTest
    public static void test_PlatformStatusForActiveContractToday() {

        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'testUser@deliveryhero.com', 'Yogiyo', 'KR');
        insert testUser;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Exclude_from_Validation'];
        insert new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = ps.Id );

        Test.startTest();
        Contract currentContract;
        System.runAs(testUser) {
            setupUserData(testUser);
            currentContract = newContracts[0];
            Contract futureContract = newContracts[1];
            currentContract.StartDate = Date.today().addDays(-1);
            currentContract.End_Date__c = Date.today();
            insert currentContract;
            Platform_Performance__c pp = PlatformPerformanceSelector.getPlatformPerformancesForAccounts(new Set<Id>{currentContract.AccountId})[0];
            System.assertEquals(ContractSelector.ONLINE_STATUS_ACTIVE, pp.Vendor_Status__c);
            futureContract.StartDate = Date.today().addDays(1);
            insert futureContract;
        }
        Test.stopTest();
        Platform_Performance__c pp = PlatformPerformanceSelector.getPlatformPerformancesForAccounts(new Set<Id>{currentContract.AccountId})[0];
        System.assertEquals(ContractSelector.ONLINE_STATUS_ACTIVE, pp.Vendor_Status__c);
    }

    @IsTest static void test_PlatformStatusForTerminatedContract() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'testUser@deliveryhero.com', 'Yogiyo', 'KR');
        insert testUser;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Exclude_from_Validation'];
        insert new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = ps.Id );


        Test.startTest();
        System.runAs(testUser) {
            setupUserData(testUser);
            newContracts[0].StartDate = Date.today().addDays(-10);
            newContracts[0].End_Date__c = Date.today().addDays(-1);
            insert newContracts[0];
            ClsContractProcessor.preventDuplicateContracts(newContracts);
        }
        Test.stopTest();

        Platform_Performance__c pp = [SELECT Id, Account__c, Platform__c, Platform_Online_Status__c, Vendor_Status__c
        FROM Platform_Performance__c WHERE Platform__c = 'Yogiyo' LIMIT 1];

        System.assertEquals(ContractSelector.ONLINE_STATUS_TERMINATED, pp.Vendor_Status__c);
    }

    /**
     * @description Test switch process with  one switch contract
     */
    @IsTest
    public static void test_switchFunctionality() {
        List<Contract> allContracts = new List<Contract>();
        List<Contract> oldContracts = new List<Contract>();
        Country__c testCountry = [SELECT Iso__c,
                Name,
                CurrencyIsoCode
        FROM Country__c
        WHERE Iso__c = 'KR' ];

        accounts = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
        insert accounts;

        Platform_Performance__c platPerformance = new Platform_Performance__c (Account__c = accounts.get(0).Id,
                Platform__c = 'Yogiyo',
                Vendor_Status__c = '');
        insert platPerformance;

        List<Opportunity> testOpportunities = UnitTestDataFactory.createOpportunities(accounts, 2, 'Yogiyo_Opportunity', System.today());
        testOpportunities.get(0).Business_Type__c = 'Switch';
        testOpportunities.get(1).Business_Type__c = 'New Business';
        insert testOpportunities;

        for (Integer i = 1; i < 11; i++) {
            oldContracts.add(new Contract(
                    AccountId = accounts[0].Id,
                    Id_Opportunity__c = testOpportunities.get(1).Id,
                    StartDate = Date.today().addDays(i + 1),
                    End_Date__c = Date.today().addDays(i + 2),
                    Status = 'Draft',
                    Service_Type__c = 'Commission Fee',
                    RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id,
                    Company_Name__c = 'Yogiyo'
            )
            );
        }
        oldContracts.add(new Contract(Service_Type__c = 'Commission Fee', Id_Opportunity__c = testOpportunities.get(1).Id, AccountId = accounts[0].Id, StartDate = Date.today().addDays(12), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id));

        insert oldContracts;

        Contract switchContract = new Contract(Service_Type__c = 'Commission Fee', Id_Opportunity__c = testOpportunities.get(0).Id, AccountId = accounts[0].Id, StartDate = Date.today().addDays(10), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id);

        insert switchContract;

        allContracts = ContractSelector.getAll();
        for (Contract cont: allContracts) {
            System.assert(cont.End_Date__c <= switchContract.StartDate || cont.StartDate > switchContract.StartDate || cont.Id == switchContract.Id);
            if (cont.Id == switchContract.Id) {
                System.assertEquals('Draft', cont.Status);
                System.assertEquals(null, cont.End_Date__c);
            } else if (cont.StartDate < switchContract.StartDate) {
                System.assertEquals('Draft', cont.Status);
            } else {
                System.assertEquals('Terminated', cont.Status);
            }
        }

    }

    /**
     * @description Test switch process with Business Config
     */
    @IsTest
    public static void test_switchFunctionalityBC() {
        List<Contract> allContracts = new List<Contract>();
        List<Contract> oldContracts = new List<Contract>();
        Country__c testCountry = [SELECT Iso__c,
                Name,
                CurrencyIsoCode
        FROM Country__c
        WHERE Iso__c = 'KR' ];
        Business_Config__c config3 = UnitTestDataFactory.createBusinessConfig('ContractCreation', 'Process', 'validServiceTypesForSwitch', 'Commission Fee,Logistics Fee', testCountry.Id, 'Yogiyo_Contract', true, false);
        insert config3;
        accounts = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
        insert accounts;

        Platform_Performance__c platPerformance = new Platform_Performance__c (Account__c = accounts.get(0).Id,
                Platform__c = 'Yogiyo',
                Vendor_Status__c = '');
        insert platPerformance;

        List<Opportunity> testOpportunities = UnitTestDataFactory.createOpportunities(accounts, 2, 'Yogiyo_Opportunity', System.today());
        testOpportunities.get(0).Business_Type__c = 'Switch';
        testOpportunities.get(1).Business_Type__c = 'New Business';
        insert testOpportunities;

        for (Integer i = 1; i < 11; i++) {
            oldContracts.add(new Contract(
                    AccountId = accounts[0].Id,
                    Id_Opportunity__c = testOpportunities.get(1).Id,
                    StartDate = Date.today().addDays(i + 1),
                    End_Date__c = Date.today().addDays(i + 2),
                    Status = 'Draft',
                    Service_Type__c = 'Commission Fee',
                    RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id,
                    Company_Name__c = 'Yogiyo'
            )
            );
        }
        oldContracts.add(new Contract(Service_Type__c = 'Commission Fee', Id_Opportunity__c = testOpportunities.get(1).Id, AccountId = accounts[0].Id, StartDate = Date.today().addDays(12), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id));

        insert oldContracts;

        Contract switchContract = new Contract(Service_Type__c = 'Commission Fee', Id_Opportunity__c = testOpportunities.get(0).Id, AccountId = accounts[0].Id, StartDate = Date.today().addDays(10), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id);

        insert switchContract;

        allContracts = ContractSelector.getAll();
        for (Contract cont: allContracts) {
            System.assert(cont.End_Date__c <= switchContract.StartDate || cont.StartDate > switchContract.StartDate || cont.Id == switchContract.Id);
            if (cont.Id == switchContract.Id) {
                System.assertEquals('Draft', cont.Status);
                System.assertEquals(null, cont.End_Date__c);
            } else if (cont.StartDate < switchContract.StartDate) {
                System.assertEquals('Draft', cont.Status);
            } else {
                System.assertEquals('Terminated', cont.Status);
            }
        }

    }

    /**
     * @description Test switch functionality with tiered switch commissions
     */
    @IsTest
    public static void test_switchFunctionalityTieredSwitch() {
        List<Contract> allContracts = new List<Contract>();
        List<Contract> oldContracts = new List<Contract>();
        Country__c testCountry = [SELECT Iso__c,
                Name,
                CurrencyIsoCode
        FROM Country__c
        WHERE Iso__c = 'KR' ];

        accounts = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
        insert accounts;

        Platform_Performance__c platPerformance = new Platform_Performance__c (Account__c = accounts.get(0).Id,
                Platform__c = 'Yogiyo',
                Vendor_Status__c = '');
        insert platPerformance;

        List<Opportunity> testOpportunities = UnitTestDataFactory.createOpportunities(accounts, 2, 'Yogiyo_Opportunity', System.today());
        testOpportunities.get(0).Business_Type__c = 'Switch';
        testOpportunities.get(1).Business_Type__c = 'New Business';
        insert testOpportunities;

        for (Integer i = 1; i < 11; i++) {
            oldContracts.add(new Contract(
                    AccountId = accounts[0].Id,
                    Id_Opportunity__c = testOpportunities.get(1).Id,
                    StartDate = Date.today().addDays(i + 1),
                    End_Date__c = Date.today().addDays(i + 2),
                    Status = 'Draft',
                    Service_Type__c = 'Commission Fee',
                    RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id,
                    Company_Name__c = 'Yogiyo'
            )
            );
        }
        oldContracts.add(new Contract(Service_Type__c = 'Commission Fee', Id_Opportunity__c = testOpportunities.get(1).Id, AccountId = accounts[0].Id, StartDate = Date.today().addDays(12), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id));

        insert oldContracts;

        Contract switchContract = new Contract(Service_Type__c = 'Commission Fee', Id_Opportunity__c = testOpportunities.get(0).Id, AccountId = accounts[0].Id, StartDate = Date.today().addDays(5), End_Date__c = Date.today().addDays(7), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id);
        Contract switchContract2 = new Contract(Service_Type__c = 'Commission Fee', Id_Opportunity__c = testOpportunities.get(0).Id, AccountId = accounts[0].Id, StartDate = Date.today().addDays(8), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id);

        insert new List<Contract> {switchContract, switchContract2};

        allContracts = ContractSelector.getAll();
        for (Contract cont: allContracts) {
            System.assert(cont.End_Date__c <= switchContract2.StartDate || cont.StartDate > switchContract2.StartDate || cont.Id == switchContract2.Id);
            if (cont.Id == switchContract2.Id) {
                System.assertEquals('Draft', cont.Status);
                System.assertEquals(null, cont.End_Date__c);
            } else if (cont.Id == switchContract.Id) {
                System.assertEquals('Draft', cont.Status);
                System.assertNotEquals(null, cont.End_Date__c);
            } else if (cont.StartDate < switchContract.StartDate) {
                System.assertEquals('Draft', cont.Status);
            } else {
                System.assertEquals('Terminated', cont.Status);
            }
        }

    }

    /**
    * @description Test switch functionality with tiered switch commissions of different service type
    */
    @IsTest
    public static void test_switchFunctionalityServiceType() {
        List<Contract> allContracts = new List<Contract>();
        List<Contract> oldContracts = new List<Contract>();
        Country__c testCountry = [SELECT Iso__c,
                Name,
                CurrencyIsoCode
        FROM Country__c
        WHERE Iso__c = 'KR' ];

        accounts = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
        insert accounts;

        Platform_Performance__c platPerformance = new Platform_Performance__c (Account__c = accounts.get(0).Id,
                Platform__c = 'Yogiyo',
                Vendor_Status__c = '');
        insert platPerformance;

        List<Opportunity> testOpportunities = UnitTestDataFactory.createOpportunities(accounts, 2, 'Yogiyo_Opportunity', System.today());
        testOpportunities.get(0).Business_Type__c = 'Switch';
        testOpportunities.get(1).Business_Type__c = 'New Business';
        insert testOpportunities;

        for (Integer i = 1; i < 11; i++) {
            oldContracts.add(new Contract(
                    AccountId = accounts[0].Id,
                    Id_Opportunity__c = testOpportunities.get(1).Id,
                    StartDate = Date.today().addDays(i + 1),
                    End_Date__c = Date.today().addDays(i + 2),
                    Status = 'Draft',
                    Service_Type__c = 'Commission Fee',
                    RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id,
                    Company_Name__c = 'Yogiyo'
            )
            );
        }
        oldContracts.add(new Contract(Service_Type__c = 'Commission Fee', Id_Opportunity__c = testOpportunities.get(1).Id, AccountId = accounts[0].Id, StartDate = Date.today().addDays(12), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id));

        insert oldContracts;

        Contract switchContract = new Contract(Service_Type__c = 'Logistics Fee', Id_Opportunity__c = testOpportunities.get(0).Id, AccountId = accounts[0].Id, StartDate = Date.today().addDays(5), End_Date__c = Date.today().addDays(7), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id);
        Contract switchContract2 = new Contract(Service_Type__c = 'Logistics Fee', Id_Opportunity__c = testOpportunities.get(0).Id, AccountId = accounts[0].Id, StartDate = Date.today().addDays(8), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id);

        insert new List<Contract> {switchContract, switchContract2};

        allContracts = ContractSelector.getAll();
        for (Contract cont: allContracts) {
            System.assert(cont.End_Date__c <= switchContract2.StartDate || cont.StartDate > switchContract2.StartDate || cont.Id == switchContract2.Id);
            if (cont.Id == switchContract2.Id) {
                System.assertEquals('Draft', cont.Status);
                System.assertEquals(null, cont.End_Date__c);
            } else if (cont.Id == switchContract.Id) {
                System.assertEquals('Draft', cont.Status);
                System.assertNotEquals(null, cont.End_Date__c);
            } else if (cont.StartDate < switchContract.StartDate) {
                System.assertEquals('Draft', cont.Status);
            } else {
                System.assertEquals('Terminated', cont.Status);
            }
        }

    }

    /**
    * @description Test switch functionality with tiered switch commissions of different service type
    */
    @IsTest
    public static void test_switchFunctionalityInvalidServiceType() {
        List<Contract> allContracts = new List<Contract>();
        List<Contract> oldContracts = new List<Contract>();
        Country__c testCountry = [SELECT Iso__c,
                Name,
                CurrencyIsoCode
        FROM Country__c
        WHERE Iso__c = 'KR' ];

        accounts = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
        insert accounts;

        Platform_Performance__c platPerformance = new Platform_Performance__c (Account__c = accounts.get(0).Id,
                Platform__c = 'Yogiyo',
                Vendor_Status__c = '');
        insert platPerformance;

        List<Opportunity> testOpportunities = UnitTestDataFactory.createOpportunities(accounts, 2, 'Yogiyo_Opportunity', System.today());
        testOpportunities.get(0).Business_Type__c = 'Switch';
        testOpportunities.get(1).Business_Type__c = 'New Business';
        insert testOpportunities;

        for (Integer i = 1; i < 11; i++) {
            oldContracts.add(new Contract(
                    AccountId = accounts[0].Id,
                    Id_Opportunity__c = testOpportunities.get(1).Id,
                    StartDate = Date.today().addDays(i + 1),
                    End_Date__c = Date.today().addDays(i + 2),
                    Status = 'Draft',
                    Service_Type__c = 'Commission Fee',
                    RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id,
                    Company_Name__c = 'Yogiyo'
            )
            );
        }
        oldContracts.add(new Contract(Service_Type__c = 'Commission Fee', Id_Opportunity__c = testOpportunities.get(1).Id, AccountId = accounts[0].Id, StartDate = Date.today().addDays(12), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id));

        insert oldContracts;

        Contract switchContract = new Contract(Service_Type__c = 'Service Fee', Id_Opportunity__c = testOpportunities.get(0).Id, AccountId = accounts[0].Id, StartDate = Date.today().addDays(5), End_Date__c = Date.today().addDays(7), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id);
        Contract switchContract2 = new Contract(Service_Type__c = 'Service Fee', Id_Opportunity__c = testOpportunities.get(0).Id, AccountId = accounts[0].Id, StartDate = Date.today().addDays(8), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id);

        insert new List<Contract> {switchContract, switchContract2};

        allContracts = ContractSelector.getAll();
        for (Contract cont: allContracts) {
            System.assertEquals('Draft', cont.Status);
        }

    }

    /**
    * @description Test additional switch types functionality with tiered switch commissions
    */
    @IsTest
    public static void testAdditionalSwitchFunctionalityTieredSwitch() {
        List<Contract> allContracts = new List<Contract>();
        List<Contract> oldContracts = new List<Contract>();
        Country__c testCountry = [SELECT Iso__c,
                Name,
                CurrencyIsoCode
        FROM Country__c
        WHERE Iso__c = 'KR' ];

        accounts = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
        insert accounts;

        Platform_Performance__c platPerformance = new Platform_Performance__c (Account__c = accounts.get(0).Id,
                Platform__c = 'Yogiyo',
                Vendor_Status__c = '');
        insert platPerformance;

        List<Opportunity> testOpportunities = UnitTestDataFactory.createOpportunities(accounts, 2, 'Yogiyo_Opportunity', System.today());
        testOpportunities.get(0).Business_Type__c = 'Upgrade/Upsell';
        testOpportunities.get(1).Business_Type__c = 'New Business';
        insert testOpportunities;

        for (Integer i = 1; i < 11; i++) {
            oldContracts.add(new Contract(
                    AccountId = accounts[0].Id,
                    Id_Opportunity__c = testOpportunities.get(1).Id,
                    StartDate = Date.today().addDays(i + 1),
                    End_Date__c = Date.today().addDays(i + 2),
                    Status = 'Draft',
                    Service_Type__c = 'Commission Fee',
                    RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id,
                    Company_Name__c = 'Yogiyo'
            )
            );
        }
        oldContracts.add(new Contract(Service_Type__c = 'Commission Fee', Id_Opportunity__c = testOpportunities.get(1).Id, AccountId = accounts[0].Id, StartDate = Date.today().addDays(12), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id));

        insert oldContracts;

        Contract switchContract = new Contract(Service_Type__c = 'Commission Fee', Id_Opportunity__c = testOpportunities.get(0).Id, AccountId = accounts[0].Id, StartDate = Date.today().addDays(5), End_Date__c = Date.today().addDays(7), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id);
        Contract switchContract2 = new Contract(Service_Type__c = 'Commission Fee', Id_Opportunity__c = testOpportunities.get(0).Id, AccountId = accounts[0].Id, StartDate = Date.today().addDays(8), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id);

        insert new List<Contract> {switchContract, switchContract2};

        allContracts = ContractSelector.getAll();
        for (Contract cont: allContracts) {
            System.assert(cont.End_Date__c <= switchContract2.StartDate || cont.StartDate > switchContract2.StartDate || cont.Id == switchContract2.Id);
            if (cont.Id == switchContract2.Id) {
                System.assertEquals('Draft', cont.Status);
                System.assertEquals(null, cont.End_Date__c);
            } else if (cont.Id == switchContract.Id) {
                System.assertEquals('Draft', cont.Status);
                System.assertNotEquals(null, cont.End_Date__c);
            } else if (cont.StartDate < switchContract.StartDate) {
                System.assertEquals('Draft', cont.Status);
            } else {
                System.assertEquals('Terminated', cont.Status);
            }
        }
    }

    /**
    * @description Test switch functionality with tiered switch commissions of invalit opportunity business type
    */
    @IsTest
    public static void testSwitchFunctionalityInvalidBusinessType() {
        List<Contract> allContracts = new List<Contract>();
        List<Contract> oldContracts = new List<Contract>();
        Country__c testCountry = [SELECT Iso__c,
                Name,
                CurrencyIsoCode
        FROM Country__c
        WHERE Iso__c = 'KR' ];

        accounts = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
        insert accounts;

        Platform_Performance__c platPerformance = new Platform_Performance__c (Account__c = accounts.get(0).Id,
                Platform__c = 'Yogiyo',
                Vendor_Status__c = '');
        insert platPerformance;

        List<Opportunity> testOpportunities = UnitTestDataFactory.createOpportunities(accounts, 2, 'Yogiyo_Opportunity', System.today());
        testOpportunities.get(0).Business_Type__c = 'New Business';
        testOpportunities.get(1).Business_Type__c = 'New Business';
        insert testOpportunities;

        for (Integer i = 1; i < 11; i++) {
            oldContracts.add(new Contract(
                    AccountId = accounts[0].Id,
                    Id_Opportunity__c = testOpportunities.get(1).Id,
                    StartDate = Date.today().addDays(i + 1),
                    End_Date__c = Date.today().addDays(i + 2),
                    Status = 'Draft',
                    Service_Type__c = 'Commission Fee',
                    RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id,
                    Company_Name__c = 'Yogiyo'
            )
            );
        }
        oldContracts.add(new Contract(Service_Type__c = 'Commission Fee', Id_Opportunity__c = testOpportunities.get(1).Id, AccountId = accounts[0].Id, StartDate = Date.today().addDays(12), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id));

        insert oldContracts;

        Contract switchContract = new Contract(Service_Type__c = 'Commission Fee', Id_Opportunity__c = testOpportunities.get(0).Id, AccountId = accounts[0].Id, StartDate = Date.today().addDays(5), End_Date__c = Date.today().addDays(7), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id);
        Contract switchContract2 = new Contract(Service_Type__c = 'Commission Fee', Id_Opportunity__c = testOpportunities.get(0).Id, AccountId = accounts[0].Id, StartDate = Date.today().addDays(8), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id);

        insert new List<Contract> {switchContract, switchContract2};

        allContracts = ContractSelector.getAll();
        for (Contract cont: allContracts) {
            System.assertEquals('Draft', cont.Status);
        }

    }

   /**
    * @description Test if account is updated based on active/expired commissions
    */
    @IsTest
    public static void testAccountDeliveryTypeUpdate() {
        Country__c testCountry = [SELECT Iso__c,
                Name,
                CurrencyIsoCode
        FROM Country__c
        WHERE Iso__c = 'KR' ];

        accounts = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
        insert accounts;
  
        Opportunity testOpportunity = UnitTestDataFactory.createOpportunities(accounts, 1, 'Yogiyo_Opportunity', System.today()).get(0);
        testOpportunity.Business_Type__c = 'New Business';
        insert testOpportunity;

        Contract commissionContract = new Contract(Service_Type__c = 'Commission Fee', Id_Opportunity__c = testOpportunity.Id, AccountId = accounts[0].Id, StartDate = Date.today(), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id);
        Contract serviceContract = new Contract(Service_Type__c = 'Logistics Fee', Id_Opportunity__c = testOpportunity.Id, AccountId = accounts[0].Id, StartDate = Date.today(), End_Date__c = Date.today().addDays(7), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id);

        insert new List<Contract> {commissionContract, serviceContract};
        commissionContract.Status = 'Activated';
        serviceContract.Status = 'Activated';
        update new List<Contract> {commissionContract, serviceContract};

        Test.startTest();
            Account deliveryAccount = ClsAccountSelector.findAccountById(accounts[0].Id);
            System.assertEquals('Hybrid', deliveryAccount.Delivery_Service__c);

            commissionContract.Status = 'Terminated';
            update commissionContract;

            deliveryAccount = ClsAccountSelector.findAccountById(accounts[0].Id);
            System.assertEquals('DH Delivery', deliveryAccount.Delivery_Service__c);

            serviceContract.Status = 'Terminated';
            update serviceContract;

            deliveryAccount = ClsAccountSelector.findAccountById(accounts[0].Id);
            System.assertEquals(null, deliveryAccount.Delivery_Service__c);

            commissionContract.Status = 'Activated';
            update commissionContract;

            deliveryAccount = ClsAccountSelector.findAccountById(accounts[0].Id);
            System.assertEquals('Partner Delivery', deliveryAccount.Delivery_Service__c);
        Test.stopTest();
    }
}