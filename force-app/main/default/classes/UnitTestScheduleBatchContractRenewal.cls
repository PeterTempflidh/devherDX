@isTest
private class UnitTestScheduleBatchContractRenewal {

    @testSetup static void setup() {
        Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Opportunity', 'Contract'});
        UnitTestDataFactory.getRecordtypeValues();

        Country__c bh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        insert new List<Country__c> {bh};
        company__c com = UnitTestDataFactory.createCompany('Talabat', 'Talabat', bh);
        insert com;

        Business_Config__c b1 = UnitTestDataFactory.createBusinessConfig('BatchContractRenewal', 'Process', 'CountriesEnabledForAutoRenewal', 'Bahrain', bh.id, 'Talabat_Contract', true, true);
        Business_Config__c b2 = UnitTestDataFactory.createBusinessConfig('BatchContractRenewal', 'Process', 'RenewForNumberOfMonths', '12', bh.id, 'Talabat_Contract', true, false);
        Business_Config__c b3 = UnitTestDataFactory.createBusinessConfig('BatchContractRenewal', 'Process', 'expiredContractStatus', 'Expired', bh.id, 'Talabat_Contract', true, false);
        Business_Config__c b4 = UnitTestDataFactory.createBusinessConfig('BatchContractRenewal', 'Process', 'renewalContractStatus', 'Activated', bh.id, 'Talabat_Contract', true, false);
        Business_Config__c b5 = UnitTestDataFactory.createBusinessConfig('BatchContractRenewal', 'Process', 'updateExpiredContracts', 'true', bh.id, 'Talabat_Contract', true, false);

        insert new List<sObject> {b1, b2, b3, b4, b5};

        Account acc1 = UnitTestDataFactory.createAccount('BatchTestClassAccount1', bh, 'Talabat_Account');
        acc1.Backend_Id__c = '12345';
        insert new List<Account> {acc1};
        
        Tarif__c tarif = UnitTestDataFactory.createTarif(com,bh,'test','Talabat_Tarif', false);
        insert tarif;
        tarif.is_active__c = true;
        update tarif;

        Opportunity opp1 = new Opportunity(
            Setup_Fee_AU__c = 155,
            Start_Date_uk__c = Date.newInstance(2014, 12, 21),
            name = 'BatchTestOpp1',
            recordtypeid = mapRecordTypes.get('Talabat_Opportunity').id,
            AccountId = acc1.id,
            CloseDate = Date.newInstance(2014, 12, 21),
            StageName = 'Prospecting',
            TarrifName_AU__c = 'testTarif1',
            Is_DataLoaded__c = true,
            Migration_Notes_AU__c = 'Migration',
            Id_tarif__c = tarif.Id);

        insert new List<Opportunity> {opp1};

        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=opp1.id,status__c='Approved',ID_Account__c=acc1.id);
        insert newQuote;

        List_Service_Price__c lsp = UnitTestDataFactory.createService(com,bh,'testService1','Talabat_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType');
        insert lsp;

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
                                     end_date__c = Date.Today(),
                                     id_opportunity_quote_line_item__c=oppQuoteLine[0].id,
                                     recordtypeid = mapRecordTypes.get('Talabat_Contract').id);
        insert new List<Contract> {con1};

        con1.Status = 'Activated';
        update new List<Contract> {con1};
    }

    @isTest static void scheduleBatchContractRenewalWorksCorrectly() {
        Id jobId;
        
        Test.startTest();
        jobId = System.schedule('test job', '0 0 0 * * ?', new ScheduleBatchContractRenewal());
        Test.stopTest();

        CronTrigger[] jobs = [Select Id from CronTrigger Where Id = : jobId];

        System.assert(!jobs.isEmpty());

    }
}