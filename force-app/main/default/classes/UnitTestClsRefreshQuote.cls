@isTest
private class UnitTestClsRefreshQuote {
    static List<Opportunity_Quote__c> oppQuoteList;

    static Country__c testCountry;
    static List<Account> accList;
    static Account acc;
    static EmailTemplate templateAsset;
    static List<Opportunity_Quote_Line_Item__c> oqp;

    @testSetup static void setup() {

        UnitTestDataFactory.getRecordtypeValues();

        List<Platform_Country__c> platformCountry = new List<Platform_Country__c>();
        platformCountry.add(new Platform_Country__c(name = 'TalabatPlatform', country__c = 'Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name = 'FOCPlatform', country__c = 'Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
    }

    static void setupUserData(User u) {
        testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        Company__c com = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', testCountry);

        insert new List<sObject> {testCountry, com};
        System.runAs(u) {
            List<Opportunity> listOpp = [select id from Opportunity where name = 'TestOpp123'];
            Business_Config__c b16 = new Business_Config__c(Business_Rule_Name__c = 'OppQuoteRecordTypeid', Business_Rule_Value__c = 'Yogiyo_Opportunity_Quote', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'OppQuoteProcess', Record_Type_Id__c = 'Yogiyo_Account', Type__c = 'Process');
            Business_Config__c b17 = new Business_Config__c(Business_Rule_Name__c = 'TemplateForQuoterefresh', Business_Rule_Value__c = 'Yogiyo_QuoteVFTemplate_Asset,Yogiyo_QuoteVFTemplate_Both,Yogiyo_QuoteVFTemplate_Service,Yogiyo_QuoteVFTemplate_MenuPrinting', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'OppQuoteProcess', Record_Type_Id__c = 'Yogiyo_Account', Type__c = 'Process');

            insert new List<sObject> {b16, b17};

            accList = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
            accList[0].CurrencyIsoCode = 'KRW';
            insert accList;
            List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList, 1, 'Yogiyo_Opportunity', Date.today());
            insert oppList;
            oppQuoteList = UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1, 'Yogiyo_Opportunity_Quote', 'Draft', 'test data', 100.45, 100.45, '', '', 0);
            insert oppQuoteList;
            List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com, testCountry, 'Apple', 'Yogiyo_List_Product_Group');
            insert lpg;
            List<List_Product_Price__c> lpp = UnitTestDataFactory.createProducts(com , testCountry, lpg.Id, 10, 'Yogiyo_List_Product_Price', 1, true, 299, 1, true, 10);
            insert lpp;
            lpp[0].Product_Type__c = 'Menu Printing';
            update lpp;
            oqp = UnitTestDataFactory.createOpportunityQuoteLineItems(oppQuoteList[0], lpp[0].id, lpg.id, 1, true, 'Yogiyo_Opportunity_Quote_Line_Item', 1, '20', 200.0, 2, 300.0, 'Product');

            insert oqp;
            templateAsset = UnitTestDataFactory.createEmailTemplate('Yogiyo_QuoteVFTemplate_Service', 'Yogiyo Asset', 'Yogiyo_QuoteVFTemplate_Service', true, 'Quote', 'Text', u.Id);
            insert templateAsset ;

        }
    }


    @isTest static void test_refreshQuote() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'testUser@deliveryhero.com', 'Yogiyo', 'KR');


        Test.startTest();
        System.runAs(testUser) {
            setupUserData(testUser);

            List<Opportunity_Quote_Line_Item__c> opqs = UnitTestDataFactory.createOpportunityQuoteLineItems(oppQuoteList[0], 1, true, 'Yogiyo_Opportunity_Quote_Line_Item', 11, null, true, null, Date.today(), 'Commission Fee', 'Service');
            insert opqs;

            Boolean refreshQuote = ClsRefreshQuote.refreshQuote(oppQuoteList[0].id);

        }
        Test.stopTest();
    }

    @isTest static void test_refreshQuote2() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'testUser@deliveryhero.com', 'Yogiyo', 'KR');

        Test.startTest();
        System.runAs(testUser) {
            setupUserData(testUser);

            oqp[0].Sub_type__c = 'Ad Sales';
            update oqp;

            Boolean refreshQuote = ClsRefreshQuote.refreshQuote(oppQuoteList[0].id);

        }
        Test.stopTest();
    }

    @isTest static void test_refreshQuote3() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'testUser@deliveryhero.com', 'Yogiyo', 'KR');

        Test.startTest();
        System.runAs(testUser) {
            setupUserData(testUser);
            oqp[0].Sub_type__c = 'Flat Commission';
            update oqp;

            Boolean refreshQuote = ClsRefreshQuote.refreshQuote(oppQuoteList[0].id);

        }
        Test.stopTest();
    }

    @isTest static void test_refreshQuote4() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'testUser@deliveryhero.com', 'Yogiyo', 'KR');

        Test.startTest();
        System.runAs(testUser) {
            setupUserData(testUser);
            List<Opportunity_Quote_Line_Item__c> opqs = UnitTestDataFactory.createOpportunityQuoteLineItems(oppQuoteList[0], 1, true, 'Yogiyo_Opportunity_Quote_Line_Item', 11, null, true, null, Date.today(), 'Commission Fee', 'Service');
            insert opqs;
            delete oqp;

            Boolean refreshQuote = ClsRefreshQuote.refreshQuote(oppQuoteList[0].id);
            //String htmlValue=ClsRefreshQuote.getEmailHtmlValue(true,false,false);
            //ClsRefreshQuote.getEmailHtmlValue(false,true,false);

        }
        Test.stopTest();
    }


}