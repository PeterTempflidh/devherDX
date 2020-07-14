@isTest
private class UnitTestLibBusinessConfig {
    private static User testUser;
    private static Country__c country;
    private static Company__c company;
    private static List<Account> accts;
    private static List<Lead> leads;
    private static Business_Config__c configTrigger;
    private static Business_Config__c configProcess;

    static {
        testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'yogiyounittestuser@deliveryhero.com', 'Yogiyo', 'KR');
        insert testUser;
        List<Platform_Country__c> platformCountry =new List<Platform_Country__c>();
        platformCountry.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name='FOCPlatform', country__c='Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
        UnitTestDataFactory.getRecordtypeValues();
        System.runAs(testUser){
            country = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            insert country;

            company = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', country);
            company.CurrencyIsoCode = country.CurrencyIsoCode;
            insert company;

            leads = UnitTestDataFactory.createLeads(201, country, 'Test Lead','Test Company', 'KRW', 'Test Burgers - Not for eating', 'Yogiyo_Lead');
            //insert leads;
            /*accts = UnitTestDataFactory.createAccounts(201, country, 'Yogiyo_Account');
            insert accts;*/
            configTrigger = UnitTestDataFactory.createBusinessConfig('Test Trigger', 'Trigger', 'Test Rule', 'Test Value', country.Id, 'Yogiyo_Account', true, true);
            configProcess = UnitTestDataFactory.createBusinessConfig('Test Process', 'Process', 'Test Rule', 'Test Value', country.Id, 'Yogiyo_Account', true, true);

            TLB_Approval_Matrix__c approvalSetting_level1 = new TLB_Approval_Matrix__c(
                    Name = 'Level1',
                    CountryName__c = 'Arab Emirates',

                    Notification__c = true,
                    Role__c = 'HOS'

            );

            TLB_Approval_Matrix__c approvalSetting_level2 = new TLB_Approval_Matrix__c(
                    Name = 'Level2',
                    CountryName__c = 'Arab Emirates',

                    Notification__c = true,
                    Role__c = 'Legal'

            );

            insert new List<sObject>{approvalSetting_level2,approvalSetting_level1};

            //RecortType rt = new RecortType(DeveloperName = 'Yogiyo_Lead');
        }
    }

    @isTest static void test_determineApprover(){
        TLB_Approval_Matrix__c approvalEntry;
        Test.startTest();

        System.runas(testUser){
            // approvalEntry = LibBusinessConfig.determineApprover('Arab Emirates', 1);
        }

        Test.stopTest();

        // System.assertNotEquals(null,approvalEntry);
    }


    @isTest static void test_setCountryLookUp() {

        Test.startTest();

        System.assertEquals(null, leads[0].Country__c);

        System.runAs(testUser){
            insert leads;
        }

        Test.stopTest();

        Lead testLead = [SELECT Id, Name, Country__c FROM Lead WHERE id = :leads[0].Id];
        System.assertEquals(country.Id, testLead.Country__c);
    }

    @isTest static void test_isTriggerActive() {
        Test.startTest();

        System.assertEquals(null, LibBusinessConfig.isTriggerActive('Test Trigger'));

        System.runAs(testUser){
            insert configTrigger;
        }

        Test.stopTest();
        System.assertEquals(true, LibBusinessConfig.isTriggerActive('Test Trigger'));
    }

    @isTest static void test_getRecordTypeToRecordTypeAssignment(){
        Test.startTest();

        System.runAs(testUser){
            insert configProcess;
            System.assertEquals('Test Value', LibBusinessConfig.getRecordTypeToRecordTypeAssignment('Test Process').get('Test Rule'));
        }

        Test.stopTest();
    }

    @isTest static void test_getGerenericProcessDataWithCountry(){
        Test.startTest();

        System.runAs(testUser){
            insert configProcess;
            System.assertEquals('Test Value', LibBusinessConfig.getGerenericProcessDataWithCountry('Test Process').get('KR').get('Test Rule').Business_Rule_Value__c);
        }

        Test.stopTest();
    }

    @isTest static void test_getUserCompanies(){
        Test.startTest();

        System.runAs(testUser){
            System.debug('@@@@ calling test_getUserCompanies : ' + LibBusinessConfig.getUserCompanies());
            System.assertEquals(1, LibBusinessConfig.getUserCompanies().size());
            System.assertEquals('Yogiyo', LibBusinessConfig.getUserCompanies()[0].Name);
        }

        Test.stopTest();
    }

    @isTest static void test_getUserCountries(){
        Test.startTest();

        System.runAs(testUser){
            System.assertEquals(1, LibBusinessConfig.getUserCountries().size());
            System.assertEquals('Korea', LibBusinessConfig.getUserCountries()[0].Name);
        }

        Test.stopTest();
    }

    @isTest static void test_getRecordTypeDevName(){
        Test.startTest();

        System.runAs(testUser){
            insert leads;
            System.assertEquals('Yogiyo_Lead', LibBusinessConfig.getRecordTypeDevName(leads[0], 'Lead'));
        }

        Test.stopTest();
    }

    @isTest static void test_determineCompany(){
        Test.startTest();

        System.runAs(testUser){
            System.assertEquals('Yogiyo', LibBusinessConfig.determineCompany('Yogiyo_Account'));
            System.assertEquals('DH_AU', LibBusinessConfig.determineCompany('DH_AU_Account'));
        }

        Test.stopTest();
    }

    @isTest static void test_recordCurrencyMap(){
        Test.startTest();

        System.runAs(testUser){
            System.assertEquals('KRW', LibBusinessConfig.recordCurrencyMap().get('Korea'));
        }

        Test.stopTest();
    }
    /**
     * @description test that the partion of the bussiness configs work properly
     *
     * @param None
     */
    @isTest static void readMultipartionBussinessRules(){
        String partitionCache = 'local.BusinessConfigCache';

        UnitTestDataFactory.getRecordtypeValues();
        Country__c testCountry = UnitTestDataFactory.createCountry('PY', 'Paraguay', 'COP');
        insert testCountry;
        Company__c testCompany = UnitTestDataFactory.createCompany('PedidosYA', 'PedidosYA', testCountry);
        insert testCompany;
        Business_Config__c process1 = new Business_Config__c(Business_Rule_Name__c='TypesException',Business_Rule_Value__c='Brand,Group,Holding,Regional / Global HQ',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
        Business_Config__c process2 = new Business_Config__c(Business_Rule_Name__c='TypesException',Business_Rule_Value__c='Brand,Group,Holding,Regional / Global HQ',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='EventBus 2',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
        insert new List<sObject>{process1,process2};

        test.startTest();
        Cache.OrgPartition orgCache = Cache.Org.getPartition(partitionCache);
        system.assertEquals(0,orgCache.getKeys().size());
        Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
        system.assertEquals(1,orgCache.getKeys().size());
        moam = LibBusinessConfig.motherOfAllBusinessMaps;
        System.assertNotEquals(null,moam.get('EventBus'));
        LibBusinessConfig.cleanOrgCache();
        system.assertEquals(0,orgCache.getKeys().size());


        test.stopTest();

    }

    /**
     * @description test that the partion of the bussiness configs work properly
     *
     * @param None
     */
    @isTest static void readMultipartionBussinessRulesHitTime(){
        String partitionCache = 'local.BusinessConfigCache';

        UnitTestDataFactory.getRecordtypeValues();
        Country__c testCountry = UnitTestDataFactory.createCountry('PY', 'Paraguay', 'COP');
        insert testCountry;
        Company__c testCompany = UnitTestDataFactory.createCompany('PedidosYA', 'PedidosYA', testCountry);
        insert testCompany;
        Business_Config__c process1 = new Business_Config__c(Business_Rule_Name__c='TypesException',Business_Rule_Value__c='Brand,Group,Holding,Regional / Global HQ',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
        Business_Config__c process2 = new Business_Config__c(Business_Rule_Name__c='TypesException',Business_Rule_Value__c='Brand,Group,Holding,Regional / Global HQ',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='EventBus 2',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
        insert new List<sObject>{process1,process2};

        Test.startTest();

        Cache.OrgPartition orgCachePartition = Cache.Org.getPartition(partitionCache);
        System.assertEquals(0,orgCachePartition.getKeys().size(), 'The org cache must start empty in the test');

        Long startTime = 0;
        Long endTime = 0;
        Long totalTimeCacheMiss = 0;
        Long totalTimeCacheHit = 0;

        startTime = System.currentTimeMillis();
        Map<String, Map<String, Map<String, Business_Config__c>> > moam1 = LibBusinessConfig.motherOfAllBusinessMaps;
        endTime = System.currentTimeMillis();
        totalTimeCacheMiss = endTime - startTime;
        System.assertEquals(1,orgCachePartition.getKeys().size(),'The org cache must have one key after the first miss');

        startTime = System.currentTimeMillis();
        Map<String, Map<String, Map<String, Business_Config__c>> > moam2 = LibBusinessConfig.motherOfAllBusinessMaps;
        endTime = System.currentTimeMillis();
        totalTimeCacheHit = endTime - startTime;

        System.assert( totalTimeCacheMiss > totalTimeCacheHit ,'The second time must we call the method we should obtain a hit and the execution time must be less');

        Test.stopTest();
    }

    /**
     * @description test that the partion of the bussiness configs work properly
     *
     * @param None
     */
    @isTest static void readMultipartionBussinessRulesMissReload(){
        String partitionCache = 'local.BusinessConfigCache';

        UnitTestDataFactory.getRecordtypeValues();
        Country__c testCountry = UnitTestDataFactory.createCountry('PY', 'Paraguay', 'COP');
        insert testCountry;
        Company__c testCompany = UnitTestDataFactory.createCompany('PedidosYA', 'PedidosYA', testCountry);
        insert testCompany;
        Business_Config__c process1 = new Business_Config__c(Business_Rule_Name__c='TypesException',Business_Rule_Value__c='Brand,Group,Holding,Regional / Global HQ',Id_Country__c=testCountry.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
        Business_Config__c process2 = new Business_Config__c(Business_Rule_Name__c='TypesException',Business_Rule_Value__c='Brand,Group,Holding,Regional / Global HQ',Id_Country__c=testCountry.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='EventBus 2',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
        insert new List<SObject>{process1,process2};

        Test.startTest();

        Cache.OrgPartition orgCachePartition = Cache.Org.getPartition(partitionCache);
        System.assertEquals(0,orgCachePartition.getKeys().size(), 'The org cache must start empty in the test');

        Map<String, Map<String, Map<String, Business_Config__c>> > moam1 = LibBusinessConfig.motherOfAllBusinessMaps;
        System.assertEquals(1,orgCachePartition.getKeys().size(),'The org cache must have one key after the first miss');

        // Simulate a cache miss
        orgCachePartition.put( String.valueOf('0'), '' );

        // Call the method directly to force the retrieval of the cache
        Map<String, Map<String, Map<String, Business_Config__c>> > moam2 = LibBusinessConfig.retrieveBusinessConfigFromCache();
        System.assertEquals(1,orgCachePartition.getKeys().size(),'The org cache must have one key after the second miss');
        System.assert( orgCachePartition.get('0') instanceof Map<String, Map<String, Map<String, Business_Config__c>>>,'The org cache contents must be a valid structure');

        Test.stopTest();
    }

    @isTest
    static void testClearOrgCache() {
        PlatformCache__c setting = new PlatformCache__c();
        setting.Name = 'BusinessConfig';
        setting.CachePartitionSize__c = 3;
        insert setting;
        
        String partitionCache = 'local.BusinessConfigCache';

        UnitTestDataFactory.getRecordtypeValues();
        Country__c testCountry = UnitTestDataFactory.createCountry('PY', 'Paraguay', 'COP');
        insert testCountry;
        Company__c testCompany = UnitTestDataFactory.createCompany('PedidosYA', 'PedidosYA', testCountry);
        insert testCompany;
        Business_Config__c process1 = new Business_Config__c(Business_Rule_Name__c='TypesException',Business_Rule_Value__c='Brand,Group,Holding,Regional / Global HQ',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='EventBus',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
        Business_Config__c process2 = new Business_Config__c(Business_Rule_Name__c='TypesException',Business_Rule_Value__c='Brand,Group,Holding,Regional / Global HQ',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='EventBus 2',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
        Business_Config__c process3 = new Business_Config__c(Business_Rule_Name__c='TypesException',Business_Rule_Value__c='Brand,Group,Holding,Regional / Global HQ',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='EventBus 3',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
        Business_Config__c process4 = new Business_Config__c(Business_Rule_Name__c='TypesException',Business_Rule_Value__c='Brand,Group,Holding,Regional / Global HQ',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='EventBus 4',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
        Business_Config__c process5 = new Business_Config__c(Business_Rule_Name__c='TypesException',Business_Rule_Value__c='Brand,Group,Holding,Regional / Global HQ',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='EventBus 5',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
        insert new List<sObject>{process1,process2,process3,process4,process5};

        Cache.OrgPartition orgCache = Cache.Org.getPartition(partitionCache);
        Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
        
        System.assertNotEquals(0,orgCache.getKeys().size(), 'Cache should not be empty');
        
        test.startTest();
            LibBusinessConfig.cleanOrgCache();
        test.stopTest();
        
        System.assertEquals(0,orgCache.getKeys().size(), 'Cache should be empty');
    }
    
    @isTest
    static void testSetMotherOfAllBusinessMaps() {
        LibBusinessConfig.motherOfAllBusinessMaps = null;
            
        test.startTest();
            LibBusinessConfig.setMotherOfAllBusinessMaps(new Map<String, Map<String, Map<String, Business_Config__c>>>());
        test.stopTest();
        
        System.assertNotEquals(null, LibBusinessConfig.motherOfAllBusinessMaps, 'motherOfAllBusinessMaps should not be null');
    }
    
    @isTest
    static void testGetBusinessConfigFromRuleMap() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c beh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        insert beh;
        Country__c my = UnitTestDataFactory.createCountry('MY', 'Malaysia', 'MYR');
        insert my;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='OppQuoteEmailTemplate',
                                                       Business_Rule_Value__c='TestTemplate',Id_Country__c=beh.id,Is_Active__c=true,
                                                       Parent__c=true,Process_Name__c='OppQuoteProcess',
                                                       Record_Type_Id__c='Talabat_Account',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c = 'Status__c', 
                                                       Business_Rule_Value__c = 'Accepted', Id_Country__c = beh.id, Is_Active__c = true, 
                                                       Parent__c = true, Process_Name__c = 'OppTypeAndStageProcess', 
                                                       Record_Type_Id__c = 'Talabat_Opportunity_Quote', Type__c = 'Process');
        insert new List<Business_Config__c> { b1, b2 };
        LibBusinessConfig.createMotherOfAllBusinessMapsOptimized();
        List<RecordType> recTypeIds = [SELECT Id FROM RecordType WHERE DeveloperName = 'Talabat_Account'];
        
        test.startTest();
            Business_Config__c businessConfig = LibBusinessConfig.getBusinessConfigFromRuleMap('OppQuoteProcess', recTypeIds[0].Id, 'OppQuoteEmailTemplate');
        test.stopTest();
        
        System.assertEquals('OppQuoteProcess', businessConfig.Process_Name__c, 'Returned process name should be OppQuoteProcess');
    }
    
    @isTest
    static void testGetRecordTypesForProcess() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c beh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        insert beh;
        Country__c my = UnitTestDataFactory.createCountry('MY', 'Malaysia', 'MYR');
        insert my;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='OppQuoteEmailTemplate',
                                                       Business_Rule_Value__c='TestTemplate',Id_Country__c=beh.id,Is_Active__c=true,
                                                       Parent__c=true,Process_Name__c='OppQuoteProcess',
                                                       Record_Type_Id__c='Talabat_Account',Type__c='Process');
        insert b1;
        
        test.startTest();
            Set<String> recTypes = LibBusinessConfig.getRecordTypesForProcess('OppQuoteProcess');
        test.stopTest();
        
        System.assertEquals(true, recTypes.contains('Talabat_Account'), 'Returned set should contain Talabat_Account rec type');
    }
    
    @isTest
    static void testGetGenericProcessData() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c beh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        insert beh;
        Country__c my = UnitTestDataFactory.createCountry('MY', 'Malaysia', 'MYR');
        insert my;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='OppQuoteEmailTemplate',
                                                       Business_Rule_Value__c='TestTemplate',Id_Country__c=beh.id,Is_Active__c=true,
                                                       Parent__c=true,Process_Name__c='OppQuoteProcess',
                                                       Record_Type_Id__c='Talabat_Account',Type__c='Process');
        insert b1;
        
        test.startTest();
            Map<String, Map<String, Business_Config__c>> processData = LibBusinessConfig.getGenericProcessData('OppQuoteProcess');
        test.stopTest();
        
        System.assertEquals(true, processData.containsKey('Talabat_Account'), 'Business configs should contain Talabat_Account rec type');
        System.assertEquals(true, processData.get('Talabat_Account').containsKey('OppQuoteEmailTemplate'), 'Business configs should contain key OppQuoteEmailTemplate');
    }
    
    @isTest
    static void testGetBCDataWithProAndCountryAndRecType() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c beh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        insert beh;
        Country__c my = UnitTestDataFactory.createCountry('MY', 'Malaysia', 'MYR');
        insert my;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='OppQuoteEmailTemplate',
                                                       Business_Rule_Value__c='TestTemplate',Id_Country__c=beh.id,Is_Active__c=true,
                                                       Parent__c=true,Process_Name__c='OppQuoteProcess',
                                                       Record_Type_Id__c='Talabat_Account',Type__c='Process');
        insert b1;
        
        test.startTest();
             Map<String,Map<String,Map<String, Business_Config__c>>> bcData = LibBusinessConfig.getBCDataWithProAndCountryAndRecType('OppQuoteProcess', new List<String> { 'Bahrain' }, new List<String> {'Talabat_Account'});
        test.stopTest();
        
        System.assertEquals(true, bcData.keySet() != null);
        System.assertEquals(true, bcData.containsKey('Talabat_Account'), 'Business configs should contain Talabat_Account rec type');
        System.assertEquals(true, bcData.get('Talabat_Account').containsKey('Bahrain'), 'Business configs should contain key Bahrain');
    }
    
    @isTest
    static void testGetBCDataWithProAndCountryAndRecType_WithoutCountry() {
        UnitTestDataFactory.getRecordtypeValues();
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='OppQuoteEmailTemplate',
                                                       Business_Rule_Value__c='TestTemplate',Id_Country__c=null, Is_Active__c=true,
                                                       Parent__c=true,Process_Name__c='OppQuoteProcess',
                                                       Record_Type_Id__c='Talabat_Account',Type__c='Process');
        insert b1;
        
        test.startTest();
             Map<String,Map<String,Map<String, Business_Config__c>>> bcData = LibBusinessConfig.getBCDataWithProAndCountryAndRecType('OppQuoteProcess', new List<String> { 'Bahrain' }, new List<String> {'Talabat_Account'});
        test.stopTest();
        
        System.assertEquals(true, bcData.keySet() != null);
        System.assertEquals(true, bcData.containsKey('Talabat_Account'), 'Business configs should contain Talabat_Account rec type');
        System.assertEquals(true, bcData.get('Talabat_Account').containsKey('ALL'), 'Business configs should contain key ALL');
    }
    
    @isTest
    static void testCreateMotherOfAllBusinessMapsOptimized() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c beh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        insert beh;
        Country__c my = UnitTestDataFactory.createCountry('MY', 'Malaysia', 'MYR');
        insert my;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='OppQuoteEmailTemplate',
                                                       Business_Rule_Value__c='TestTemplate',Id_Country__c=beh.id,Is_Active__c=true,
                                                       Parent__c=true,Process_Name__c='OppQuoteProcess',
                                                       Record_Type_Id__c='Talabat_Account',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c = 'Status__c', 
                                                       Business_Rule_Value__c = 'Accepted', Id_Country__c = beh.id, Is_Active__c = true, 
                                                       Parent__c = true, Process_Name__c = 'OppTypeAndStageProcess', 
                                                       Record_Type_Id__c = 'Talabat_Opportunity_Quote', Type__c = 'Process');
        insert new List<Business_Config__c> { b1, b2 };
        
        test.startTest();
            Map<String,Map<String,Map<String, Business_Config__c>>> moam = LibBusinessConfig.createMotherOfAllBusinessMapsOptimized();
        test.stopTest();
        
        System.assertEquals(true, moam.keySet() != null, 'moam should not be empty');
    }



    @isTest
    static void testDetermineApproverMap() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c cd = UnitTestDataFactory.createCountry('CD', 'Colombia', 'COP');
        insert cd;
        Account acco = UnitTestDataFactory.createAccount('TEST', cd, 'CD_Account');
        acco.Type = 'Branch - main';
        insert acco;
        Opportunity oppt = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'CD_Opportunity', Date.today());
        oppt.Business_Type__c = 'New Business';
        Opportunity oppt2 = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'CD_Opportunity', Date.today());
        oppt2.Business_Type__c = 'New Business';
        insert new List<Opportunity>{oppt, oppt2};
        Case acase = UnitTestDataFactory.createCase(acco, 'New', 'Quality Check', '', '', cd, 'CD_Entry_Case', '');
        acase.Stage_1_Completed__c = true;
        acase.Opportunity__c = oppt.Id;
        acase.Closed_Reason__c = 'Take Online';

        Case acase1 = UnitTestDataFactory.createCase(acco, 'Please Check', 'Quality Check', '', '', cd, 'CD_Entry_Case', '');
        acase1.Opportunity__c = oppt2.Id;
        acase1.Closed_Reason__c = 'Take Online';

        List<Case> caseList = new List<Case>{acase, acase1};
        insert caseList;

        Business_Config__c businessConfig0_1 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process','validAccountForSecondStage', acco.Type, cd.Id, 'CD_Opportunity', true, true );
        Business_Config__c businessConfig0_2 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process','validOppBusinessTypeForSecondStage', oppt.Business_Type__c, cd.Id, 'CD_Opportunity', true, false );
        Business_Config__c businessConfig0_3 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process', 'assignmentMap', '{"Germany":"00G1r000003JwK5","Bahrain":"00Gw00000034PPe","Colombia":"00Gw00000034PPe","Kuwait":"00Gw00000034PPe","Lebanon":"00Gw00000034PPe","Oman":"00Gw00000034PPe","Qatar":"00Gw00000034PPe","Kingdom of Saudi Arabia":"00Gw00000034PPe","United Arab Emirates":"00Gw00000034PPe","Jordan":"00Gw00000034PPe"}', cd.Id, 'CD_Opportunity', true, false );
        Business_Config__c businessConfig0_4 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process', 'recordTypeMap', '{"Germany":"0121r000000V9wh","Bahrain":"012w0000000MPceAAG","Colombia":"012w0000000MPceAAG","Lebanon":"012w0000000MPceAAG","Oman":"012w0000000MPceAAG","Qatar":"012w0000000MPceAAG","Kingdom of Saudi Arabia":"012w0000000MPceAAG","United Arab Emirates":"012w0000000MPceAAG","Jordan":"012w0000000MPceAAG"}', cd.Id, 'CD_Opportunity', true, false );
        Business_Config__c businessConfig0_5 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process','QualityCheckCaseSecondStage', 'RecordTypeId=012w0000000MPce,Type=Quality Check,subject=Quality Check,status=Operation Check,ownerid=00Gw00000034QshEAE', cd.Id, 'CD_Opportunity', true, true );
        Map<String, Business_Config__c> bconfMap_1 = new Map<String, Business_Config__c>{businessConfig0_1.Business_Rule_Name__c => businessConfig0_1, businessConfig0_2.Business_Rule_Name__c => businessConfig0_2, businessConfig0_3.Business_Rule_Name__c => businessConfig0_3, businessConfig0_4.Business_Rule_Name__c => businessConfig0_4, businessConfig0_5.Business_Rule_Name__c => businessConfig0_5};
        Map<String, Map<String, Business_Config__c>> bconfMap_1f = new Map<String, Map<String, Business_Config__c>>{'CD_Opportunity' => bconfMap_1};
        ClsOpportunityProcessor.moam = new Map<String, Map<String, Map<String, Business_Config__c>>>{businessConfig0_1.Process_Name__c => bconfMap_1f};
        
        Test.startTest();
            Map<String,Map<string,OpportunityTeamMember>> oppTeamMembers = LibBusinessConfig.determineApproverMap(oppt.Id);
        Test.stopTest();

        System.assertNotEquals(null, oppTeamMembers, 'Returned map should not be null');
    }

}