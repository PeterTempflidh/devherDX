/**
 * Created by w.novoa on 19.03.2018.
 */

@IsTest
private class UnitTestCtrTerminateRestaurantVue {

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
    private static List<List_Add_On__c> addOns;


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
        Business_Config__c b8 = new Business_Config__c(Business_Rule_Name__c = 'EnableCancelBookingInMidas', Business_Rule_Value__c = 'false', Id_Country__c = country.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'Yogiyo_Account', Type__c = 'Process');
        Business_Config__c b9 = new Business_Config__c(Business_Rule_Name__c = 'addonTerminationReasonMandatory', Business_Rule_Value__c = 'false', Id_Country__c = country.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'Yogiyo_Account', Type__c = 'Process');
        Business_Config__c b10 = new Business_Config__c(Business_Rule_Name__c = 'contractTerminationDateMandatory', Business_Rule_Value__c = 'false', Id_Country__c = country.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'Yogiyo_Account', Type__c = 'Process');
        Business_Config__c b11 = new Business_Config__c(Business_Rule_Name__c = 'addChargesTerminationDateMandatory', Business_Rule_Value__c = 'false', Id_Country__c = country.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'Yogiyo_Account', Type__c = 'Process');
        Business_Config__c b12 = new Business_Config__c(Business_Rule_Name__c = 'brandingTerminationDateMandatory', Business_Rule_Value__c = 'false', Id_Country__c = country.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'Yogiyo_Account', Type__c = 'Process');
        Business_Config__c b13 = new Business_Config__c(Business_Rule_Name__c = 'addonTerminationDateMandatory', Business_Rule_Value__c = 'false', Id_Country__c = country.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'Yogiyo_Account', Type__c = 'Process');

        Business_Config__c ab1 = new Business_Config__c(Business_Rule_Name__c = 'AssetTerminateStatus', Business_Rule_Value__c = 'Canceled', Id_Country__c = country_AU.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'DH_AU_Account', Type__c = 'Process');
        Business_Config__c ab2 = new Business_Config__c(Business_Rule_Name__c = 'contractTerminationReasonMandatory', Business_Rule_Value__c = 'false', Id_Country__c = country_AU.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'DH_AU_Account', Type__c = 'Process');
        Business_Config__c ab3 = new Business_Config__c(Business_Rule_Name__c = 'addChargesTerminationReasonMandatory', Business_Rule_Value__c = 'false', Id_Country__c = country_AU.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'DH_AU_Account', Type__c = 'Process');
        Business_Config__c ab4 = new Business_Config__c(Business_Rule_Name__c = 'brandingTerminationReasonMandatory', Business_Rule_Value__c = 'false', Id_Country__c = country_AU.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'DH_AU_Account', Type__c = 'Process');
        Business_Config__c ab5 = new Business_Config__c(Business_Rule_Name__c = 'addonTerminationReasonMandatory', Business_Rule_Value__c = 'false', Id_Country__c = country_AU.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'DH_AU_Account', Type__c = 'Process');
        Business_Config__c ab6 = new Business_Config__c(Business_Rule_Name__c = 'RecodTypesRelatedList', Business_Rule_Value__c = '{"Contract": "DE_Contract","Additional_Charges__c": "DE_Additional_Charges","Branding_Content__c": "DE_Branding_Content","Add_on_Service__c": "DE_Add_On"}', Id_Country__c = country_AU.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'TerminateRestaurant', Record_Type_Id__c = 'DH_AU_Account', Type__c = 'Process');
        Business_Config__c ab7 = new Business_Config__c(Business_Rule_Name__c = 'status', Business_Rule_Value__c = 'false', Id_Country__c = country_AU.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'RestrictPPTerminationByStatus', Record_Type_Id__c = 'DH_AU_Additional_Charges', Type__c = 'Process');

        insert new List<sObject> {b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,ab1,ab2,ab3,ab4,ab5,ab6,ab7};

        // create business configs implemented for SSC-1982 : Tlife Commission
        List<Business_Config__c> configs = new List<Business_Config__c>();
        configs.add(UnitTestDataFactory.createBusinessConfig('TlifeRevenueModel','process', 'ContractServiceType','Deal Subscription Fee,Commission Fee,Logistics Fee', null,'Talabat_Contract',True,True));
        configs.add(UnitTestDataFactory.createBusinessConfig('TlifeRevenueModel','process', 'Commission Fee','Ordering Platform', null,'Talabat_Contract',True,false));
        configs.add(UnitTestDataFactory.createBusinessConfig('TlifeRevenueModel','process', 'Deal Subscription Fee','Deal Subscription Service', null,'Talabat_Contract',True,false));
        insert configs;

        Country__c talabatCountry = UnitTestDataFactory.createCountry('AE', 'United Arab Emirates', 'AED');
        insert talabatCountry;

        Account talabatAccount = UnitTestDataFactory.createAccount('Talabat Account',talabatCountry,Constants.ACCOUNT_RT_TALABAT_ACCOUNT);
        talabatAccount.Revenue_Model__c = Constants.ACCOUNT_REVENUE_MODEL_ORDERING;
        insert talabatAccount;

        List<Contract> talabatContractList = UnitTestDataFactory.createContracts(talabatAccount, Date.today(), Date.today(),
                Constants.CONTRACT_STATUS_DRAFT, Constants.CONTRACT_RT_TALABAT_CONTRACT,2, Constants.CONTRACT_SERVICE_COMMISSION_FEE);
        talabatContractList[1].End_Date__c = Date.today().addDays(2);
        talabatContractList[1].Service_Type__c = Constants.CONTRACT_SERVICE_DEAL_SUBSCRIPTION;
        talabatContractList[0].Termination_Reason__c = Constants.CONTRACT_TERMINATION_REASON;
        talabatContractList[1].Termination_Reason__c = Constants.CONTRACT_TERMINATION_REASON;
        insert talabatContractList;

        talabatContractList[1].Status = Constants.CONTRACT_STATUS_ACTIVATED;
        update talabatContractList;
        //SSC-1982 : Tlife Commission ends here
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
            opportunities[0].Source_System__c = 'MIDAS';
            List<sObject> objectsToInsert1 = new List<sObject>();
            objectsToInsert1.addAll((List<sObject>)products);
            objectsToInsert1.addAll((List<sObject>)opportunities);
            objectsToInsert1.addAll((List<sObject>)contracts);
            insert objectsToInsert1;

            Opportunity_Line_Item__c oppProduct = UnitTestDataFactory.createOpportunityLineItemProduct('Menu Printing',opportunities[0],productGroups[0].id,products[0].id,true,'Yogiyo_Opportunity_Line_Item',1,'',50,1,50,'Menu Printing');
            oppProduct.Booking_Api_Id__c = '123456';
            insert oppProduct;

            List<Tier__c> lstTier = new List<Tier__c>();
            Tier__c tierTemp = new Tier__c();
            for(Contract conTemp: contracts){
                tierTemp = new Tier__c();
                tierTemp.Id_Contract__c = conTemp.id;
                lstTier.add(tierTemp);

                tierTemp = new Tier__c();
                tierTemp.Id_Contract__c = conTemp.id;
                lstTier.add(tierTemp);
            }
            insert lstTier;

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
                    '100', 1, 100, 1, 100, 11, 'Yogiyo_Additional_Charges__c', null);
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
            additionalCharges[9].Id_Asset__c = null;
            additionalCharges[10].Type__c = 'Premium Placement';
            additionalCharges[10].start_Date__c = Date.Today();
            additionalCharges[10].Booking_Api_Id__c = '123457';
            additionalCharges[10].RecordTypeId = Schema.SObjectType.Additional_Charges__c.getRecordTypeInfosByName().get('DH AU Additional Charges').getRecordTypeId();

            insert additionalCharges;
            system.debug('test Additional-->'+ [Select id, RecordTypeId from Additional_Charges__c where id =: additionalCharges[10].id]);

            addOns   = UnitTestDataFactory.createAddOns(country.id,Company.id,'Test Add On','Deals','test','Yogiyo_List_Add_On',10);

            Add_on_Service__c addTest1 = new Add_on_Service__c();

            addTest1.Account_Name__c = accounts[0].Id;
            //addTest1.Opportunity__c  = opportunities[0].id;
            addTest1.Status__c  = 'Active';
            addTest1.Id_List_Add_On__c = addOns[0].id;

            insert addTest1;


            Branding_Content__c bran = new Branding_Content__c();
            bran.Restaurant_Name__c = Accounts[0].id;
            insert bran;
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
                '100', 1, 100, 1, 100, 11, 'DH_AU_Additional_Charges__c', null);
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
        additionalCharges[10].Type__c = 'Premium Placement';
        additionalCharges[10].start_Date__c = Date.Today();
        additionalCharges[10].Booking_Api_Id__c = '123457';
        additionalCharges[10].RecordTypeId = Schema.SObjectType.Additional_Charges__c.getRecordTypeInfosByName().get('DH AU Additional Charges').getRecordTypeId();

        insert additionalCharges_AU;
    }

    @IsTest
    static void testBehavior() {

        CtrTerminationRestaurantVue ctr = new CtrTerminationRestaurantVue();
        System.runAs(testUser) {
            Test.startTest();
            CtrTerminationRestaurantVue.getRecordTypesRelatedList(accounts[0].RecordTypeId);
            List<CtrTerminationRestaurantVue.ContractWrapper> lstContract = CtrTerminationRestaurantVue.getActiveContracts(accounts[0].id);
            List<CtrTerminationRestaurantVue.AddOnWrapper> lstAddon = CtrTerminationRestaurantVue.getActiveAddOns(accounts[0].id);
            List<CtrTerminationRestaurantVue.AdditionalWrapper> lstAddChar = CtrTerminationRestaurantVue.getActiveAddionalCharges(accounts[0].id);
            List<CtrTerminationRestaurantVue.AdditionalWrapper> lstAddCharPP = CtrTerminationRestaurantVue.getActiveAddionalChargesPP(accounts[0].id);
            List<CtrTerminationRestaurantVue.BrandingWrapper> lstBrand = CtrTerminationRestaurantVue.getBranding(accounts[0].id);
            id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Yogiyo Account').getRecordTypeId();
            system.debug('RecordtypeID-->'+accounts[0].RecordTypeId);

            CtrTerminationRestaurantVue.terminateContracts('NO selected',accounts[0].RecordTypeId,null,null,null,null,null);
            CtrTerminationRestaurantVue.terminateContracts('NO selected',accounts[0].RecordTypeId,lstContract,lstAddChar,lstAddCharPP,lstBrand,lstAddon);

            for(CtrTerminationRestaurantVue.ContractWrapper conwrp : lstContract){
                conwrp.con.Termination_Reason__c = 'Test reason';
            }
            for(CtrTerminationRestaurantVue.AddOnWrapper addwrp : lstAddon){
                addwrp.addon.Termination_Reason__c = 'Test reason';
            }
            for(CtrTerminationRestaurantVue.AdditionalWrapper addchawrp : lstAddChar){
                addchawrp.add.Termination_Reason__c = 'Test reason';
            }
            for(CtrTerminationRestaurantVue.AdditionalWrapper addchaPPwrp : lstAddCharPP){
                addchaPPwrp.add.Termination_Reason__c = 'Test reason';
            }
            for(CtrTerminationRestaurantVue.BrandingWrapper brawrp : lstBrand){
                brawrp.branding.Termination_Reason__c = 'Test reason';
            }


            CtrTerminationRestaurantVue.terminateContracts('selected',accounts[0].RecordTypeId,lstContract,lstAddChar,lstAddCharPP,lstBrand,lstAddon);
            CtrTerminationRestaurantVue.terminateContracts('NO selected',accounts[0].RecordTypeId,lstContract,lstAddChar,lstAddCharPP,lstBrand,lstAddon);

            for(CtrTerminationRestaurantVue.ContractWrapper conwrp : lstContract){
                conwrp.con.Termination_Reason__c = 'Test reason';
                conwrp.con.End_Date__c = Date.today().addDays(10);
            }
            for(CtrTerminationRestaurantVue.AddOnWrapper addwrp : lstAddon){
                addwrp.addon.Termination_Reason__c = 'Test reason';
                addwrp.addon.End_Date__c = Date.today().addDays(10);
            }
            for(CtrTerminationRestaurantVue.AdditionalWrapper addchawrp : lstAddChar){
                addchawrp.add.Termination_Reason__c = 'Test reason';
                addchawrp.add.Termination_Date__c = Date.today().addDays(10);
            }
            for(CtrTerminationRestaurantVue.AdditionalWrapper addchaPPwrp : lstAddCharPP){
                addchaPPwrp.add.Termination_Reason__c = 'Test reason';
                addchaPPwrp.add.Termination_Date__c = Date.today().addDays(10);
            }
            for(CtrTerminationRestaurantVue.BrandingWrapper brawrp : lstBrand){
                brawrp.branding.Termination_Reason__c = 'Test reason';
                brawrp.branding.End_Date__c = Date.today().addDays(10);
            }
            CtrTerminationRestaurantVue.terminateContracts('NO selected',accounts[0].RecordTypeId,lstContract,lstAddChar,lstAddCharPP,lstBrand,lstAddon);

            System.assertEquals(0,[select id from contract where status = 'Terminated'].size());

            for(CtrTerminationRestaurantVue.ContractWrapper conwrp : lstContract){
                conwrp.con.Termination_Reason__c = 'Test reason';
                conwrp.con.End_Date__c = Date.today().addDays(-10);
            }
            for(CtrTerminationRestaurantVue.AddOnWrapper addwrp : lstAddon){
                addwrp.addon.Termination_Reason__c = 'Test reason';
                addwrp.addon.End_Date__c = Date.today().addDays(-10);
            }
            for(CtrTerminationRestaurantVue.AdditionalWrapper addchawrp : lstAddChar){
                addchawrp.add.Termination_Reason__c = 'Test reason';
                addchawrp.add.Termination_Date__c = Date.today().addDays(-10);
            }
            for(CtrTerminationRestaurantVue.AdditionalWrapper addchaPPwrp : lstAddCharPP){
                addchaPPwrp.add.Termination_Reason__c = 'Test reason';
                addchaPPwrp.add.Termination_Date__c = Date.today().addDays(-10);
            }
            for(CtrTerminationRestaurantVue.BrandingWrapper brawrp : lstBrand){
                brawrp.branding.Termination_Reason__c = 'Test reason';
                brawrp.branding.End_Date__c = Date.today().addDays(-10);
            }
            CtrTerminationRestaurantVue.terminateContracts('NO selected',accounts[0].RecordTypeId,lstContract,lstAddChar,lstAddCharPP,lstBrand,lstAddon);
            test.stopTest();

        }
    }

    /**
    * @date     : [03/06/2020]
    * @method name  : testUpdateRevenueModel
    * @description  : Test method of the updateRevenueModel implemented for SSC-1982 : Tlife Commission
    */
    @IsTest
    public static void testUpdateRevenueModel() {

        List<Account> accountInstance = [SELECT ID,Name,Recordtype.DeveloperName,RecordTypeId,Revenue_Model__c FROM Account
        where RecordType.DeveloperName =: Constants.ACCOUNT_RT_TALABAT_ACCOUNT limit 1];
        Test.startTest();
        List<CtrTerminationRestaurantVue.ContractWrapper> listOfTalabatContract = CtrTerminationRestaurantVue.getActiveContracts(accountInstance[0].id);
        System.assert(!listOfTalabatContract.isEmpty());

        String successMessage = CtrTerminationRestaurantVue.terminateContracts('NO selected',accountInstance[0].RecordTypeId,listOfTalabatContract,
                new List<CtrTerminationRestaurantVue.AdditionalWrapper>(),new List<CtrTerminationRestaurantVue.AdditionalWrapper>(),
                new List<CtrTerminationRestaurantVue.BrandingWrapper>(),new List<CtrTerminationRestaurantVue.AddOnWrapper>());
        System.assert(String.isNotBlank(successMessage));
        Test.stopTest();
    }
}