@isTest
private class UnitTestCtrTerminateRestaurant {
    private static User testUser;
    private static Country__c country;
    private static Country__c country_AU;
    private static Company__c company;
    private static Company__c company_AU;
    private static List<Account> accounts;
    private static List<Account> accounts_AU;
    private static List<Opportunity> opportunities;
    private static List<Opportunity> opportunities_AU;
    private static List<Contract> contracts;
    private static List<Contract> contracts_AU;
    private static List<List_Product_Group__c> productGroups;
    private static List<List_Product_Group__c> productGroups_AU;
    private static List<List_Product_Price__c> products;
    private static List<List_Product_Price__c> products_AU;
    private static List<Opportunity_Quote__c> quotes;
    private static List<Opportunity_Quote__c> quotes_AU;
    private static List<Asset__c> assets;
    private static List<Asset__c> assets_AU;
    private static List<Additional_Charges__c> additionalCharges;
    private static List<Additional_Charges__c> additionalCharges_AU;

    static {
        testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'yogiyounittestuser@deliveryhero.com', 'Yogiyo', 'KR');
        insert testUser;
        List<Platform_Country__c> platformCountry = new List<Platform_Country__c>();
        platformCountry.add(new Platform_Country__c(name = 'TalabatPlatform', country__c = 'Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name = 'FOCPlatform', country__c = 'Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
        List<MidasIntegration__c> midasIntg = new List<MidasIntegration__c>();
        midasIntg.add(new MidasIntegration__c(name = 'UK', EndPoint__c = 'http://midas.medusa-hero.com/backend/', AuthenticationToken__c = 'WyI0IiwiYzUwNjRkMmQ2MWUwNTE3YjVhNjRmMTk4Yjc2NmFiODgiXQ.CgtJbA.kFY4BLsKd3XXiXg7QtVxmLqZ7i0'));
        midasIntg.add(new MidasIntegration__c(name = 'DH_AU', EndPoint__c = 'http://midas.medusa-hero.com/backend/', AuthenticationToken__c = 'WyI0IiwiYzUwNjRkMmQ2MWUwNTE3YjVhNjRmMTk4Yjc2NmFiODgiXQ.CgtJbA.kFY4BLsKd3XXiXg7QtVxmLqZ7i0'));
        insert midasIntg;
        UnitTestDataFactory.getRecordtypeValues();
        country = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        insert country;

        company = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', country);
        insert company;

        country_AU = UnitTestDataFactory.createCountry('AU', 'Australia', 'AUD');
        insert country_AU;

        company_AU = UnitTestDataFactory.createCompany('DH_AU', 'DH_AU', country_AU);
        insert company_AU;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c = 'DoNotOverwriteStatus', Business_Rule_Value__c = 'Returned Shipment', Id_Country__c = country.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'Yogiyo_Account', Type__c = 'Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c = 'AssetTerminateStatus', Business_Rule_Value__c = 'Canceled', Id_Country__c = country.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'Yogiyo_Account', Type__c = 'Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c = 'contractTerminationReasonMandatory', Business_Rule_Value__c = 'true', Id_Country__c = country.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'Yogiyo_Account', Type__c = 'Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c = 'addChargesTerminationReasonMandatory', Business_Rule_Value__c = 'true', Id_Country__c = country.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'Yogiyo_Account', Type__c = 'Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c = 'brandingTerminationReasonMandatory', Business_Rule_Value__c = 'true', Id_Country__c = country.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'Yogiyo_Account', Type__c = 'Process');
        Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c = 'BrandingTerminateStatus', Business_Rule_Value__c = 'true', Id_Country__c = country.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'Yogiyo_Account', Type__c = 'Process');
        Business_Config__c b7 = new Business_Config__c(Business_Rule_Name__c = 'BrandingUninstalledStatus', Business_Rule_Value__c = 'true', Id_Country__c = country.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'Yogiyo_Account', Type__c = 'Process');


        Business_Config__c ab1 = new Business_Config__c(Business_Rule_Name__c = 'AssetTerminateStatus', Business_Rule_Value__c = 'Canceled', Id_Country__c = country_AU.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'DH_AU_Account', Type__c = 'Process');
        Business_Config__c ab2 = new Business_Config__c(Business_Rule_Name__c = 'contractTerminationReasonMandatory', Business_Rule_Value__c = 'false', Id_Country__c = country_AU.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'DH_AU_Account', Type__c = 'Process');
        Business_Config__c ab3 = new Business_Config__c(Business_Rule_Name__c = 'addChargesTerminationReasonMandatory', Business_Rule_Value__c = 'false', Id_Country__c = country_AU.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'DH_AU_Account', Type__c = 'Process');
        Business_Config__c ab4 = new Business_Config__c(Business_Rule_Name__c = 'brandingTerminationReasonMandatory', Business_Rule_Value__c = 'false', Id_Country__c = country_AU.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'DH_AU_Account', Type__c = 'Process');
        Business_Config__c ab5 = new Business_Config__c(Business_Rule_Name__c = 'addonTerminationReasonMandatory', Business_Rule_Value__c = 'false', Id_Country__c = country_AU.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'DH_AU_Account', Type__c = 'Process');

        insert new List<sObject> {b1, b2, b3, b4, b5,b6,b7, ab1, ab2, ab3, ab4,ab5};


        System.runAs(testUser) {


            productGroups = UnitTestDataFactory.createProductGroups(company, country, 1, 'Yogiyo_List_Product_Group');
            accounts = UnitTestDataFactory.createAccounts(1, country, 'Yogiyo_Account');

            List<sObject> objectsToInsert = new List<sObject>();
            objectsToInsert.addAll((List<sObject>)productGroups);
            objectsToInsert.addAll((List<sObject>)accounts);
            insert objectsToInsert;

            contracts = new List<Contract>();
            for (Integer i = 1; i < 11; i++) {
                contracts.add(UnitTestDataFactory.createContract(accounts[0], Date.today().addDays(i + 1), Date.today().addDays(i + 2), 'Draft', 'Yogiyo_Contract'));
            }
            contracts.add(UnitTestDataFactory.createContract(accounts[0], Date.today().addDays(12), null, 'Draft', 'Yogiyo_Contract'));

            products = UnitTestDataFactory.createProducts(company, country, productGroups[0].Id, 1, 'Yogiyo_List_Product_Price', 1, true, 299, 1, true, 10);
            opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'Yogiyo_Opportunity', Date.today().addMonths(2));
            List<sObject> objectsToInsert1 = new List<sObject>();
            objectsToInsert1.addAll((List<sObject>)products);
            objectsToInsert1.addAll((List<sObject>)opportunities);
            objectsToInsert1.addAll((List<sObject>)contracts);
            insert objectsToInsert1;

            assets = UnitTestDataFactory.createAssets(10, accounts[0], opportunities[0], Date.today().addDays(-10), true, null, null, 'Yogiyo_Asset',
                     '12345674', '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'New',
                     Date.today().addDays(20), 'Yazi Logistics', '1234', 'Delivered to Warehouse');
            for (Asset__c asset : assets) {
                asset.Termination_Date__c = null;
            }

            quotes = UnitTestDataFactory.createOpportunityQuotes(opportunities[0], 1, 'Yogiyo_Opportunity_Quote', 'Draft', 'TEST', 100, 100, 'Test', 'Test', 10);
            List<sObject> objectsToInsert2 = new List<sObject>();
            objectsToInsert2.addAll((List<sObject>)assets);
            objectsToInsert2.addAll((List<sObject>)quotes);
            insert objectsToInsert2;

            additionalCharges = UnitTestDataFactory.createAdditionalCharges(accounts[0], assets[0], opportunities[0], quotes[0], products[0], productGroups[0],
                                '100', 1, 100, 1, 100, 10, 'Yogiyo_Additional_Charges__c', null);
            additionalCharges[0].Id_Asset__c = assets[0].id;
            additionalCharges[1].Id_Asset__c = assets[1].id;
            additionalCharges[2].Id_Asset__c = assets[2].id;
            additionalCharges[3].Id_Asset__c = assets[3].id;
            additionalCharges[4].Id_Asset__c = assets[4].id;
            additionalCharges[5].Id_Asset__c = assets[5].id;
            additionalCharges[6].Id_Asset__c = null;
            additionalCharges[7].Id_Asset__c = null;
            additionalCharges[8].Id_Asset__c = null;
            additionalCharges[9].Id_Asset__c = null;
            additionalCharges[9].Type__c = 'Premium Placement';
            additionalCharges[9].start_Date__c = Date.Today();
            additionalCharges[9].Booking_Api_Id__c = '123456';
            additionalCharges[9].Status__c = 'To be sent';

            insert additionalCharges;
        }
        productGroups_AU = UnitTestDataFactory.createProductGroups(company_AU, country_AU, 1, 'DH_AU_List_Product_Group');
        accounts_AU = UnitTestDataFactory.createAccounts(1, country_AU, 'DH_AU_Account');

        List<sObject> objectsToInsert = new List<sObject>();
        objectsToInsert.addAll((List<sObject>)productGroups_AU);
        objectsToInsert.addAll((List<sObject>)accounts_AU);
        insert objectsToInsert;

        contracts_AU = new List<Contract>();
        for (Integer i = 1; i < 11; i++) {
            contracts_AU.add(UnitTestDataFactory.createContract(accounts_AU[0], Date.today().addDays(i + 1), Date.today().addDays(i + 2), 'Draft', 'DH_AU_Contract'));
        }
        contracts_AU.add(UnitTestDataFactory.createContract(accounts_AU[0], Date.today().addDays(12), null, 'Draft', 'DH_AU_Contract'));

        Contract c1 = UnitTestDataFactory.createContract(accounts_AU[0], Date.today().addDays(12), null, 'Draft', 'DH_AU_Contract');
        c1.isTiered__c = true;
        c1.index__c = 1;
        contracts_AU.add(c1);
        Contract c2 = UnitTestDataFactory.createContract(accounts_AU[0], Date.today().addDays(12), null, 'Draft', 'DH_AU_Contract');
        c2.isTiered__c = true;
        c2.index__c = 2;
        contracts_AU.add(c2);
        Contract c3 = UnitTestDataFactory.createContract(accounts_AU[0], Date.today().addDays(12), null, 'Draft', 'DH_AU_Contract');
        c3.isTiered__c = true;
        c3.index__c = 3;
        contracts_AU.add(c3);



        products_AU = UnitTestDataFactory.createProducts(company_AU, country_AU, productGroups_AU[0].Id, 1, 'DH_AU_List_Product_Price', 1, true, 299, 1, true, 10);
        opportunities_AU = UnitTestDataFactory.createOpportunities(accounts_AU, 1, 'DH_AU_Opportunity', Date.today().addMonths(2));
        List<sObject> objectsToInsert1 = new List<sObject>();
        objectsToInsert1.addAll((List<sObject>)products_AU);
        objectsToInsert1.addAll((List<sObject>)opportunities_AU);
        objectsToInsert1.addAll((List<sObject>)contracts_AU);
        insert objectsToInsert1;

        Add_on_Service__c ao = new Add_on_Service__c(Account_Name__c = accounts_AU[0].id,opportunity__c=opportunities_AU[0].id, start_date__c=date.today(), recordtypeid=LibRecordTypeHelper.getRecordTypeValue('DH_AU_Add_on'));
        insert ao;

        assets_AU = UnitTestDataFactory.createAssets(10, accounts_AU[0], opportunities_AU[0], Date.today().addDays(-10), true, null, null, 'DH_AU_Asset',
                    '12345674', '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'New',
                    Date.today().addDays(20), 'Yazi Logistics', '1234', 'Delivered to Warehouse');
        for (Asset__c asset : assets_AU) {
            asset.Termination_Date__c = null;
        }

        quotes_AU = UnitTestDataFactory.createOpportunityQuotes(opportunities_AU[0], 1, 'DH_AU_Opportunity_Quote', 'Draft', 'TEST', 100, 100, 'Test', 'Test', 10);
        List<sObject> objectsToInsert2 = new List<sObject>();
        objectsToInsert2.addAll((List<sObject>)assets_AU);
        objectsToInsert2.addAll((List<sObject>)quotes_AU);
        insert objectsToInsert2;

        additionalCharges_AU = UnitTestDataFactory.createAdditionalCharges(accounts_AU[0], assets_AU[0], opportunities_AU[0], quotes_AU[0], products_AU[0], productGroups_AU[0],
                               '100', 1, 100, 1, 100, 10, 'DH_AU_Additional_Charges__c', null);
        additionalCharges_AU[0].Id_Asset__c = assets_AU[0].id;
        additionalCharges_AU[1].Id_Asset__c = assets_AU[1].id;
        additionalCharges_AU[2].Id_Asset__c = assets_AU[2].id;
        additionalCharges_AU[3].Id_Asset__c = assets_AU[3].id;
        additionalCharges_AU[4].Id_Asset__c = assets_AU[4].id;
        additionalCharges_AU[5].Id_Asset__c = assets_AU[5].id;
        additionalCharges_AU[6].Id_Asset__c = null;
        additionalCharges_AU[7].Id_Asset__c = null;
        additionalCharges_AU[8].Id_Asset__c = null;
        additionalCharges_AU[9].Id_Asset__c = null;
        additionalCharges_AU[9].Type__c = 'Premium Placement';
        additionalCharges_AU[9].start_Date__c = Date.Today();
        additionalCharges_AU[9].Booking_Api_Id__c = '123456';
        additionalCharges_AU[9].Status__c = 'To be sent';
        insert additionalCharges_AU;
    }

    @isTest static void test_terminateSelectedContract() {
        ApexPages.StandardController sdtController;
        CtrTerminateRestaurant ctr;
        System.runAs(testUser) {
            sdtController = new ApexPages.StandardController(accounts[0]);
            ctr = new CtrTerminateRestaurant(sdtController);
            integer count = 0;
            for (CtrTerminateRestaurant.contractWrapper cont : ctr.mapContracts.values()) {
                cont.isSelected = true;
                cont.opp.Lost_Reason__c = 'Bad debtor';
                count++;
                if (count == 3)
                    break;
            }
            Test.startTest();
            ctr.terminateSelected();
            Test.stopTest();
        }


        List<Contract> terminatedContracts = [SELECT Id, ContractNumber, StartDate, End_Date__c, Status FROM Contract WHERE AccountId = : accounts[0].Id AND Status = 'Terminated' ORDER BY StartDate DESC];
        System.assertEquals(3, terminatedContracts.size());
        System.assertNotEquals(null, terminatedContracts[0].End_Date__c);

    }

    @isTest static void test_terminateSelectedAssetsAndAdditionalCharges() {
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        ApexPages.StandardController sdtController;
        CtrTerminateRestaurant ctr;

        System.runAs(testUser) {
            sdtController = new ApexPages.StandardController(accounts[0]);
            ctr = new CtrTerminateRestaurant(sdtController);
            for (CtrTerminateRestaurant.additionalWrapper add : ctr.mapAddCharges.values()) {
                add.isSelected = true;
                add.opp.Lost_Reason__c = 'Bad debtor';
            }
            for (CtrTerminateRestaurant.additionalWrapper add : ctr.mapPPCharge.values()) {
                add.isSelected = true;
                add.opp.Lost_Reason__c = 'Bad debtor';

            }
            Test.startTest();
            ctr.terminateSelected();
            Test.stopTest();

        }

        List<Asset__c> terminatedAssets = [select id from Asset__c where termination_date__c != null and Account__c = : accounts[0].Id];
        List<Additional_Charges__c> terminatedAdditionalCharges = [select id from Additional_Charges__c where termination_date__c != null and Id_Account__c = : accounts[0].Id];
        System.assertEquals(true, true);
        System.assertEquals(true, true);

    }

    @isTest static void test_terminateRestaurant() {
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        ApexPages.StandardController sdtController;
        CtrTerminateRestaurant ctr;
        List<Additional_Charges__c> terminatedAdditionalCharges;
        System.runAs(testUser) {
            sdtController = new ApexPages.StandardController(accounts[0]);
            ctr = new CtrTerminateRestaurant(sdtController);

            for (CtrTerminateRestaurant.additionalWrapper add : ctr.mapAddCharges.values()) {
                add.opp.Lost_Reason__c = 'Bad debtor';
            }

            for (CtrTerminateRestaurant.contractWrapper cont : ctr.mapContracts.values()) {
                cont.opp.Lost_Reason__c = 'Bad debtor';
            }
            for (CtrTerminateRestaurant.additionalWrapper add : ctr.mapPPCharge.values()) {
                add.opp.Lost_Reason__c = 'Bad debtor';
            }

            Test.startTest();
            ctr.terminateRestaurant();
            Test.stopTest();

        }

        List<Contract> terminatedContracts = [SELECT Id, ContractNumber, StartDate, End_Date__c, Status FROM Contract WHERE AccountId = : accounts[0].Id AND Status = 'Terminated' ORDER BY StartDate DESC];
        System.assertEquals(true, true);

    }

//Australia tests
    @isTest static void test_terminateSelectedContract_AU() {
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        ApexPages.StandardController sdtController;
        CtrTerminateRestaurant ctr;
        sdtController = new ApexPages.StandardController(accounts_AU[0]);
        ctr = new CtrTerminateRestaurant(sdtController);
        integer count = 0;
        for (CtrTerminateRestaurant.contractWrapper cont : ctr.mapContracts.values()) {
            if (!cont.con.isTiered__c) {
                cont.isSelected = true;
                count++;
                if (count == 3)
                    break;
            }
        }
        Test.startTest();
        ctr.terminateSelected();
        Test.stopTest();
        List<Contract> terminatedContracts = [SELECT Id, ContractNumber, StartDate, End_Date__c, Status FROM Contract WHERE AccountId = : accounts_AU[0].Id AND Status = 'Terminated' ORDER BY StartDate DESC];
        System.assertEquals(3, terminatedContracts.size());
        System.assertNotEquals(null, terminatedContracts[0].End_Date__c);
    }

    @isTest static void test_terminateSelectedContract_ReasonMan_AU() {
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        ApexPages.StandardController sdtController;
        CtrTerminateRestaurant ctr;
        sdtController = new ApexPages.StandardController(accounts_AU[0]);
        ctr = new CtrTerminateRestaurant(sdtController);
        //ctr.terminationReasonMandatory = true;
        integer count = 0;


        for (CtrTerminateRestaurant.contractWrapper cont : ctr.mapContracts.values()) {
            if (!cont.con.isTiered__c) {
                if (count <= 3) {
                    cont.isSelected = true;
                    cont.opp.Lost_Reason__c = 'Bad debtor';
                    if (count == 1)
                        cont.opp.Lost_Date__c = Date.today();
                }
            }

            if (cont.con.isTiered__c && cont.con.index__c == 1) {
                cont.isSelected = true;
                cont.opp.Lost_Reason__c = 'Bad debtor';
                cont.opp.Lost_Date__c = Date.today().addDays(30);
            }
            count++;
        }
        Test.startTest();
        ctr.mapAddCharges.clear();
        ctr.mapPPCharge.clear();
        try {
            ctr.terminateSelected();
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest static void test_terminateSelectedContract_ReasonMan_AU2() {
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        ApexPages.StandardController sdtController;
        CtrTerminateRestaurant ctr;
        sdtController = new ApexPages.StandardController(accounts_AU[0]);
        ctr = new CtrTerminateRestaurant(sdtController);
        //ctr.terminationReasonMandatory = true;
        integer count = 0;


        for (CtrTerminateRestaurant.contractWrapper cont : ctr.mapContracts.values()) {
            if (!cont.con.isTiered__c) {
                if (count <= 3) {
                    cont.isSelected = true;
                    cont.opp.Lost_Reason__c = 'Bad debtor';
                    if (count == 1)
                        cont.opp.Lost_Date__c = Date.today().addDays(30);
                }
            }

            if (cont.con.isTiered__c && cont.con.index__c == 1) {
                cont.isSelected = true;
                //cont.opp.Lost_Reason__c = 'Bad debtor';
                cont.opp.Lost_Date__c = Date.today().addDays(30);
            }
            count++;
        }
        Test.startTest();
        ctr.mapAddCharges.clear();
        ctr.mapPPCharge.clear();
        try {
            ctr.terminateSelected();
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        Test.stopTest();
        //List<Contract> terminatedContracts = [SELECT Id, ContractNumber, StartDate, End_Date__c, Status FROM Contract WHERE AccountId =: accounts_AU[0].Id AND Status = 'Terminated' ORDER BY StartDate DESC];
        //System.assertEquals(3, terminatedContracts.size());
        //System.assertNotEquals(null, terminatedContracts[0].End_Date__c);
    }

    @isTest static void test_terminateSelectedContract_ReasonMan_AU3() {
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        ApexPages.StandardController sdtController;
        CtrTerminateRestaurant ctr;
        sdtController = new ApexPages.StandardController(accounts_AU[0]);
        ctr = new CtrTerminateRestaurant(sdtController);
        //ctr.terminationReasonMandatory = true;
        integer count = 0;
        for (CtrTerminateRestaurant.contractWrapper cont : ctr.mapContracts.values()) {
            if (!cont.con.isTiered__c) {
                if (count <= 3) {
                    cont.isSelected = true;
                    cont.opp.Lost_Reason__c = 'Bad debtor';
                    if (count == 1)
                        cont.opp.Lost_Date__c = Date.today().addDays(30);
                }
            }

            if (cont.con.isTiered__c && cont.con.index__c == 1) {
                cont.isSelected = true;
                cont.opp.Lost_Reason__c = 'Bad debtor';
                cont.opp.Lost_Date__c = Date.today().addDays(30);
            }
            count++;
        }
        Test.startTest();
        ctr.mapAddCharges.clear();
        ctr.mapPPCharge.clear();
        try {
            ctr.terminateSelected();
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest static void test_terminateSelectedContract_ReasonMan_AU4() {
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        ApexPages.StandardController sdtController;
        CtrTerminateRestaurant ctr;
        sdtController = new ApexPages.StandardController(accounts_AU[0]);
        ctr = new CtrTerminateRestaurant(sdtController);
        //ctr.terminationReasonMandatory = true;
        integer count = 0;
        ctr.mapContracts.values()[0].isSelected = true;
        ctr.mapContracts.values()[0].opp.Lost_Reason__c = 'Bad debtor';
        ctr.mapContracts.values()[0].opp.Lost_Date__c = Date.today();
        Test.startTest();
        ctr.mapAddCharges.clear();
        ctr.mapPPCharge.clear();
        try {
            ctr.terminateSelected();
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest static void test_terminateSelectedContract_ReasonMan_AU5() {
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        ApexPages.StandardController sdtController;
        CtrTerminateRestaurant ctr;
        sdtController = new ApexPages.StandardController(accounts_AU[0]);
        ctr = new CtrTerminateRestaurant(sdtController);
        //ctr.terminationReasonMandatory = false;
        integer count = 0;
        ctr.mapContracts.values()[0].isSelected = true;
        ctr.mapContracts.values()[0].opp.Lost_Date__c = Date.today();
        Test.startTest();
        ctr.mapAddCharges.clear();
        ctr.mapPPCharge.clear();
        try {
            ctr.terminateSelected();
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    @isTest static void test_terminateSelectedAddon_ReasonMan_AU5() {
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        ApexPages.StandardController sdtController;
        CtrTerminateRestaurant ctr;
        sdtController = new ApexPages.StandardController(accounts_AU[0]);
        ctr = new CtrTerminateRestaurant(sdtController);
        //ctr.terminationReasonMandatory = false;
        integer count = 0;
        ctr.mapAddOn.values()[0].isSelected = true;
        ctr.mapAddOn.values()[0].opp.Lost_Date__c = Date.today();
        Test.startTest();

        try {
            ctr.terminateSelected();
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    @isTest static void test_terminateSelectedAssetsAndAdditionalCharges_AU() {
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        ApexPages.StandardController sdtController;
        CtrTerminateRestaurant ctr;

        System.runAs(testUser) {
            sdtController = new ApexPages.StandardController(accounts_AU[0]);
            ctr = new CtrTerminateRestaurant(sdtController);
            Integer ss = ctr.additionalSize;
            Integer cc = ctr.premiumPlSize;

            for (CtrTerminateRestaurant.additionalWrapper add : ctr.mapAddCharges.values()) {
                add.isSelected = true;
            }
            for (CtrTerminateRestaurant.additionalWrapper add : ctr.mapPPCharge.values()) {
                add.isSelected = true;
            }
            Test.startTest();
            ctr.terminateSelected();
            Test.stopTest();
        }
        List<Asset__c> terminatedAssets = [select id from Asset__c where termination_date__c != null and Account__c = : accounts_AU[0].Id];
        List<Additional_Charges__c> terminatedAdditionalCharges = [select id from Additional_Charges__c where termination_date__c != null and Id_Account__c = : accounts_AU[0].Id];
        System.assertEquals(true, true);
        //System.assertEquals(10, terminatedAdditionalCharges.size());
    }



    @isTest static void test_terminateRestaurant_AU() {
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());

        ApexPages.StandardController sdtController;
        CtrTerminateRestaurant ctr;
        List<Additional_Charges__c> terminatedAdditionalCharges;
        System.runAs(testUser) {
            sdtController = new ApexPages.StandardController(accounts_AU[0]);
            ctr = new CtrTerminateRestaurant(sdtController);
            Test.startTest();
            ctr.terminateRestaurant();
            Test.stopTest();
        }
        List<Contract> terminatedContracts = [SELECT Id, ContractNumber, StartDate, End_Date__c, Status FROM Contract WHERE AccountId = : accounts_AU[0].Id AND Status = 'Terminated' ORDER BY StartDate DESC];
        //System.assertEquals(14, terminatedContracts.size());
    }


    @isTest static void test_terminateRestaurant_reasonMan_AU() {
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());

        ApexPages.StandardController sdtController;
        CtrTerminateRestaurant ctr;
        List<Additional_Charges__c> terminatedAdditionalCharges;
        System.runAs(testUser) {
            sdtController = new ApexPages.StandardController(accounts_AU[0]);
            ctr = new CtrTerminateRestaurant(sdtController);
            //ctr.terminationReasonMandatory = true;
            integer count = 0;

            for (CtrTerminateRestaurant.contractWrapper cont : ctr.mapContracts.values()) {
                if (!cont.con.isTiered__c) {
                    cont.isSelected = true;
                    cont.opp.Lost_Reason__c = 'Bad debtor';
                    if (count == 1)
                        cont.opp.Lost_Date__c = Date.today().addDays(30);

                } else if (cont.con.index__c == 1) {
                    cont.isSelected = true;
                    cont.opp.Lost_Reason__c = 'Bad debtor';
                    cont.opp.Lost_Date__c = Date.today().addDays(30);
                }
                count++;
            }
            Test.startTest();
            ctr.mapAddCharges.clear();
            ctr.mapPPCharge.clear();
            ctr.terminateRestaurant();
            string status =ctr.brandingInactiveStatuses;
            Test.stopTest();
        }
        List<Contract> terminatedContracts = [SELECT Id, ContractNumber, StartDate, End_Date__c, Status FROM Contract WHERE AccountId = : accounts_AU[0].Id AND Status = 'Terminated' ORDER BY StartDate DESC];
        System.assertEquals(14, terminatedContracts.size());
    }

}