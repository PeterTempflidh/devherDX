@isTest
private class UnitTestBatchContractRenewal {

    @testSetup static void setup() {
        Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Opportunity', 'Contract'});
        UnitTestDataFactory.getRecordtypeValues();

        Country__c bh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        Country__c ec = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
        insert new List<Country__c> {ec, bh};
        
        company__c com = UnitTestDataFactory.createCompany('Talabat', 'Talabat', bh);
            insert com;

        Business_Config__c b1 = UnitTestDataFactory.createBusinessConfig('BatchContractRenewal', 'Process', 'CountriesEnabledForAutoRenewal', 'Bahrain', bh.id, 'Talabat_Contract', true, true);
        Business_Config__c b2 = UnitTestDataFactory.createBusinessConfig('BatchContractRenewal', 'Process', 'RenewForNumberOfMonths', '12', bh.id, 'Talabat_Contract', true, false);
        Business_Config__c b3 = UnitTestDataFactory.createBusinessConfig('BatchContractRenewal', 'Process', 'expiredContractStatus', 'Expired', bh.id, 'Talabat_Contract', true, false);
        Business_Config__c b4 = UnitTestDataFactory.createBusinessConfig('BatchContractRenewal', 'Process', 'renewalContractStatus', 'Activated', bh.id, 'Talabat_Contract', true, false);
        Business_Config__c b5 = UnitTestDataFactory.createBusinessConfig('BatchContractRenewal', 'Process', 'updateExpiredContracts', 'true', bh.id, 'Talabat_Contract', true, false);

        Business_Config__c b6 = UnitTestDataFactory.createBusinessConfig('BatchContractRenewal', 'Process', 'expiredContractStatus', 'Expired', ec.id, 'CD_Contract', true, true);
        Business_Config__c b7 = UnitTestDataFactory.createBusinessConfig('BatchContractRenewal', 'Process', 'updateExpiredContracts', 'true', ec.id, 'CD_Contract', true, false);
        insert new List<sObject> {b1, b2, b3, b4, b5, b6, b7};

        Account acc1 = UnitTestDataFactory.createAccount('BatchTestClassAccount1', bh, 'Talabat_Account');
        Account acc2 = UnitTestDataFactory.createAccount('cd account', ec, 'CD_Account');
        insert new List<Account> {acc1, acc2};
        
        List_Service_Price__c lsp = UnitTestDataFactory.createService(com,bh,'testService1','Talabat_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType');
        insert lsp;
        Tarif__c t = UnitTestDataFactory.createTarif(com, bh , 'Free Tarif', 'Talabat_Tarif', false);
        insert t;

        // create business configs implemented for SSC-1982 : Tlife Commission
        List<Business_Config__c> configs = new List<Business_Config__c>();
        configs.add(UnitTestDataFactory.createBusinessConfig('TlifeRevenueModel','process', 'ContractServiceType','Deal Subscription Fee,Commission Fee,Logistics Fee', null,'Talabat_Contract',True,True));
        configs.add(UnitTestDataFactory.createBusinessConfig('TlifeRevenueModel','process', 'Commission Fee','Ordering Platform', null,'Talabat_Contract',True,false));
        configs.add(UnitTestDataFactory.createBusinessConfig('TlifeRevenueModel','process', 'Deal Subscription Fee','Deal Subscription Service', null,'Talabat_Contract',True,false));
        configs.add(UnitTestDataFactory.createBusinessConfig('BatchContractRenewal','process', 'terminatedContractStatus','Terminated', null,'Talabat_Contract',True,false));
        insert configs;

        Country__c talabatCountry = UnitTestDataFactory.createCountry('AE', 'United Arab Emirates', 'AED');
        insert talabatCountry;

        Account talabatInstanceAccount = UnitTestDataFactory.createAccount('Talabat Account',talabatCountry,Constants.ACCOUNT_RT_TALABAT_ACCOUNT);
        talabatInstanceAccount.Revenue_Model__c = Constants.ACCOUNT_REVENUE_MODEL_ORDERING;
        insert talabatInstanceAccount;
        //SSC-1982 : Tlife Commission ends here


        Opportunity opp1 = new Opportunity(
            Setup_Fee_AU__c = 155,
            Start_Date_uk__c = Date.newInstance(2014, 12, 21),
            name = 'BatchTestOpp1',
            recordtypeid = mapRecordTypes.get('Talabat_Opportunity').id,
            AccountId = acc1.id,
            CloseDate = Date.newInstance(2014, 12, 21),
            StageName = 'Prospecting',
            TarrifName_AU__c = 'testTarif1',
            id_tarif__c=t.id,
            Is_DataLoaded__c = true,
            Migration_Notes_AU__c = 'Migration');

        Opportunity opp2 = new Opportunity(
            Setup_Fee_AU__c = 155,
            Start_Date_uk__c = Date.newInstance(2014, 12, 21),
            name = 'BatchTestOpp2',
            recordtypeid = mapRecordTypes.get('CD_Opportunity').id,
            AccountId = acc2.id,
            CloseDate = Date.newInstance(2014, 12, 21),
            StageName = 'Prospecting',
            TarrifName_AU__c = 'testTarif1',
                id_tarif__c=t.id,
        Is_DataLoaded__c = true,
            Migration_Notes_AU__c = 'Migration');
        insert new List<Opportunity> {opp1, opp2};
        
        
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=opp1.id,status__c='Approved',ID_Account__c=acc1.id);
        insert newQuote;
       
        Opportunity_Line_Item__c oppService = UnitTestDataFactory.createOpportunityLineItemService('testService3',opp1,lsp.id,true,'Talabat_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        insert oppService;
        
        List<Opportunity_Quote_Line_Item__c> oppQuoteLine =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'Talabat_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Commission Fee','Service');
        oppQuoteLine[0].id_opportunity__c=opp1.id;
        oppQuoteLine[0].id_list_service_price__c=lsp.id;
        insert oppQuoteLine ;
        newQuote.status__c='Accepted';
        update newQuote;

        Contract con1 = new Contract(name = 'test1',
                                     AccountId = acc1.id,
                                     Id_Opportunity__c = opp1.id,
                                     status = 'Draft',
                                     StartDate = Date.Today().addYears(-1),
                                     end_date__c = Date.Today().addDays(-1),
                                     id_opportunity_quote_line_item__c=oppQuoteLine[0].id,
                                     recordtypeid = mapRecordTypes.get('Talabat_Contract').id);
        Contract con2 = new Contract(name = 'test2',
                                     AccountId = acc2.id,
                                     Id_Opportunity__c = opp2.id,
                                     status = 'Draft',
                                     StartDate = Date.Today().addYears(-1),
                                     end_date__c = Date.Today().addDays(-1),
                                     recordtypeid = mapRecordTypes.get('CD_Contract').id);
        Contract con3 = new Contract(name = 'test2',
                                    AccountId = acc2.id,
                                    Id_Opportunity__c = opp2.id,
                                    status = 'Draft',
                                    StartDate = Date.Today(),
                                    end_date__c = Date.Today().addDays(20),
                                    recordtypeid = mapRecordTypes.get('PY_Contract').id);
        insert new List<Contract> {con1, con2, con3};

        con1.Status = 'Activated';
        con2.Status = 'Activated';
        update new List<Contract> {con1, con2};
    }

    @isTest static void batchContractRenewalDoesNothingIfNoBusinessConfig() {
        delete [select id from Business_Config__c];

        Contract c = [Select Status From Contract limit 1];

        Test.startTest();

        Database.executeBatch(new BatchContractRenewal());

        Test.stopTest();

        c = [Select Status, End_Date__c From Contract where id = : c.Id];

        System.assertEquals('Activated', c.Status);
        System.assert(c.End_Date__c <= Date.today());
    }

    @isTest static void batchContractRenewalDoesNothingIfNoBusinessLogic() {
        delete [Select Id from Business_Config__c Where Record_Type_Id__c like 'Tal%'];

        Contract talabatC = [Select Id from Contract Where RecordType.DeveloperName = 'Talabat_Contract' limit 1];

        Test.startTest();

        Database.executeBatch(new BatchContractRenewal());

        Test.stopTest();

        talabatC = [Select End_Date__c, Status From Contract Where Id = : talabatC.Id];
        System.assertEquals('Activated', talabatC.Status);
        System.assert(talabatC.End_Date__c <= Date.today());
    }

    @isTest static void testContractActivationThatStartToday() {
        Test.startTest();

        Database.executeBatch(new BatchContractRenewal());

        Test.stopTest();

        Boolean contractActivated = false;
        List<Contract> contracts = ContractSelector.getAll();
        for (Contract cont: contracts) {
            if (cont.StartDate == Date.today()) {
                contractActivated = 'Activated' == cont.Status;
                break;
            }
        }
        System.assert(contractActivated);
    }

    @isTest static void batchContractRenewalRenewContractCorrectly() {
        Contract talabatC = [Select Id from Contract Where RecordType.DeveloperName = 'Talabat_Contract' limit 1];

        Test.startTest();

        Database.executeBatch(new BatchContractRenewal());

        Test.stopTest();

        talabatC = [Select End_Date__c, Status, Last_renewal_date__c, Renewal_version__c From Contract WHere id = : talabatC.Id];

        System.assertEquals('Activated', talabatC.Status);
        System.assert(talabatC.End_Date__c > Date.today());
        System.assertEquals(1, talabatC.Renewal_version__c);
        System.assert(talabatC.Last_renewal_date__c >= Date.today());
    }

    @isTest static void batchContractRenewalDoesNotRenewContractIfAutoRenewIsDisabled() {
        Contract talabatC = [Select Do_not_auto_renew__c from Contract Where RecordType.DeveloperName = 'Talabat_Contract' limit 1];
        talabatC.Do_not_auto_renew__c = true;
        update talabatC;

        Test.startTest();

        Database.executeBatch(new BatchContractRenewal());

        Test.stopTest();

        talabatC = [Select End_Date__c, Status From Contract WHere id = : talabatC.Id];

        System.assertEquals('Expired', talabatC.Status);
        System.assert(talabatC.End_Date__c < Date.today());
    }

    @isTest static void batchContractRenewalDoesNotRenewContractIfCountryIsNotEnabledForAutoRenewal() {
        Contract cdC = [Select Id From Contract Where RecordType.DeveloperName like 'CD%' limit 1];

        Test.startTest();

        Database.executeBatch(new BatchContractRenewal());

        Test.stopTest();

        cdC = [Select Status, End_Date__c From Contract WHere Id =: cdC.Id];

        System.assertEquals('Expired', cdC.Status);
        System.assert(cdC.End_Date__c <= Date.today());
    }


    @isTest static void batchContractRenewalRenewContractCorrectlywithdiferentbatchsize() {

        Business_Config__c b7 = UnitTestDataFactory.createBusinessConfig('BatchContractRenewal', 'Process', 'BatchSize', '10', null, 'Global_Config', true, false);
        insert b7;
        Contract talabatC = [Select Id from Contract Where RecordType.DeveloperName = 'Talabat_Contract' limit 1];

        Test.startTest();

        SchedulableContext sc = null;
        ScheduleBatchContractRenewal tsc = new ScheduleBatchContractRenewal();
        tsc.execute(sc);

        Test.stopTest();

        talabatC = [Select End_Date__c, Status, Last_renewal_date__c, Renewal_version__c From Contract WHere id = : talabatC.Id];

        System.assertEquals('Activated', talabatC.Status);
        System.assert(talabatC.End_Date__c > Date.today());
        System.assertEquals(1, talabatC.Renewal_version__c);
        System.assert(talabatC.Last_renewal_date__c >= Date.today());
    }

    /**
    * @date     : [03/06/2020]
    * @method name  : testUpdateRevenueModel
    * @description  : Test method of the updateRevenueModel implemented for SSC-1982 : Tlife Commission
    */
    @IsTest
    public static void testUpdateRevenueModel() {
        Account talabatAccount = [Select id,Revenue_Model__c,RecordType.DeveloperName from Account where
        Revenue_Model__c =:  Constants.ACCOUNT_REVENUE_MODEL_ORDERING and  RecordType.DeveloperName =: Constants.ACCOUNT_RT_TALABAT_ACCOUNT limit 1];

        Test.startTest();
        List<Contract> talabatContractList = UnitTestDataFactory.createContracts(talabatAccount, Date.today().addDays(-2), Date.today(),
                Constants.CONTRACT_STATUS_DRAFT, Constants.CONTRACT_RT_TALABAT_CONTRACT,2, Constants.CONTRACT_SERVICE_COMMISSION_FEE);
        talabatContractList[0].End_Date__c = Date.today().addDays(-1);
        talabatContractList[1].Service_Type__c = Constants.CONTRACT_SERVICE_DEAL_SUBSCRIPTION;
        talabatContractList[0].Termination_Reason__c = Constants.CONTRACT_TERMINATION_REASON;
        talabatContractList[1].Termination_Reason__c = Constants.CONTRACT_TERMINATION_REASON;
        insert talabatContractList;
        System.assert(!talabatContractList.isEmpty());

        talabatContractList[1].Status = Constants.CONTRACT_STATUS_ACTIVATED;
        update talabatContractList;
        System.assert(!talabatContractList.isEmpty());

        Database.executeBatch(new BatchContractRenewal());
        Test.stopTest();
    }
}