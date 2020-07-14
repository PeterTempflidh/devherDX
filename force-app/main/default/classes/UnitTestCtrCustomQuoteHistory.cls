@isTest
private class UnitTestCtrCustomQuoteHistory{
    private static User testUser;
    private static Country__c country;
    private static List<Account> accounts;
    private static List<Opportunity> opportunities;
    
    private static List<Opportunity_Quote__c> quotes;
   
    static{
        UnitTestDataFactory.getRecordtypeValues();
        testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'yogiyotestuser@deliveryhero.com', 'Yogiyo', 'KR');
        insert testUser;
        System.runAs(testUser){
            country = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            insert country;

            
            //config_OppQuoteProcess = UnitTestDataFactory.createBusinessConfig('OppQuoteProcess', 'Process', 'OppQuoteEmailTemplate', 'Yogiyo_QuoteVFTemplate_Asset,Yogiyo_QuoteVFTemplate_Service,Yogiyo_QuoteVFTemplate_Both,Yogiyo_QuoteVFTemplate_MenuPrinting,Yogiyo_QuoteVFTemplate_AdSales', country.Id, 'Yogiyo_Account', true, false);
            //greeting_OppQuoteProcess = UnitTestDataFactory.createBusinessConfig('OppQuoteProcess', 'Process','Greeting','Salutation,Lastname', country.Id, 'Yogiyo_Account', true, false);
            //useDefaultContent_OppQuoteProcess = UnitTestDataFactory.createBusinessConfig('OppQuoteProcess', 'Process','UseDefaultQuoteComment','true', country.Id, 'Yogiyo_Account', true, false);
            Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='OppQuoteEmailTemplate',Business_Rule_Value__c='Yogiyo_QuoteVFTemplate_Asset,Yogiyo_QuoteVFTemplate_Service,Yogiyo_QuoteVFTemplate_Both,Yogiyo_QuoteVFTemplate_MenuPrinting,Yogiyo_QuoteVFTemplate_AdSales',Id_Country__c=country.id,Is_Active__c=true,Parent__c=true,Process_Name__c='OppQuoteProcess',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
            Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='Greeting',Business_Rule_Value__c='Salutation,Lastname',Id_Country__c=country.id,Is_Active__c=true,Parent__c=false,Process_Name__c='OppQuoteProcess',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
            Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='UseDefaultQuoteComment',Business_Rule_Value__c='true',Id_Country__c=country.id,Is_Active__c=true,Parent__c=false,Process_Name__c='OppQuoteProcess',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
            insert new List<sObject>{b1,b2,b3};
            accounts = UnitTestDataFactory.createAccounts(1, country, 'Yogiyo_Account');
            
            insert accounts;

            List<Contact> contacts = UnitTestDataFactory.createContacts(accounts, 'test Lastname', 'test FirstName', 'Mr', 'Owner', 1, 'testme', 'Yogiyo_Contact');

            opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'Yogiyo_Opportunity', Date.today().addMonths(2));
            insert opportunities;

            EmailTemplate templateAsset = UnitTestDataFactory.createEmailTemplate('Yogiyo_QuoteVFTemplate_Asset', 'Yogiyo Asset', 'Yogiyo_QuoteVFTemplate_Asset', true, 'Quote', 'Text', testUser.Id);
            EmailTemplate templateService = UnitTestDataFactory.createEmailTemplate('Yogiyo_QuoteVFTemplate_Service', 'Yogiyo Service', 'Yogiyo_QuoteVFTemplate_Service', true, 'Quote', 'Text', testUser.Id);
            EmailTemplate templateBoth = UnitTestDataFactory.createEmailTemplate('Yogiyo_QuoteVFTemplate_Both', 'Yogiyo Both', 'Yogiyo_QuoteVFTemplate_Both', true, 'Quote', 'Text', testUser.Id);
            EmailTemplate templateMenuPrinting = UnitTestDataFactory.createEmailTemplate('Yogiyo_QuoteVFTemplate_MenuPrinting', 'Yogiyo Menu Printing', 'Yogiyo_QuoteVFTemplate_MenuPrinting', true, 'Quote', 'Text', testUser.Id);
            EmailTemplate templateAdsales = UnitTestDataFactory.createEmailTemplate('Yogiyo_QuoteVFTemplate_AdSales', 'Yogiyo Adsales', 'Yogiyo_QuoteVFTemplate_AdSales', true, 'Quote', 'Text', testUser.Id);
            insert new List<sObject>{templateAsset, templateService, templateBoth, templateMenuPrinting,templateAdsales,contacts[0]};

            quotes = UnitTestDataFactory.createOpportunityQuotes(opportunities[0], 1, 'Yogiyo_Opportunity_Quote', 'draft', 'TEST', 100, 100, 'Test', 'Test', 10);
            insert quotes;
            opportunities = [select id,AccountId,name,recordtypeId,recordtype.developerName from Opportunity where id in :opportunities];
        }
    
    }
    static testmethod void UnitTest1(){
        Test.startTest();
        System.runAs(testUser){
            
            CtrCustomQuoteHistory ctrl = new CtrCustomQuoteHistory();
            ctrl.SomeObjectId=quotes[0].id;
             ctrl.showMore();
           
            CtrCustomQuoteHistory.SomeObjectHistory sh=new CtrCustomQuoteHistory.SomeObjectHistory();
            string actFormat=sh.ActionFormat;
            List<CtrCustomQuoteHistory.SomeObjectHistory> test=ctrl.SomeObjectHistories;
            
        }
           
            
        
        Test.stopTest();
    }
}