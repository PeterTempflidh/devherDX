@isTest
private class UnitTestCtrQuoteScreen {

  private static User testUser;
  private static Country__c country;
  private static Company__c company;
  private static List<Account> accounts;
  private static List<Opportunity> opportunities;
  private static List<Opportunity_Quote__c> quotes;
  private static Opportunity_quote__c oppQuote;

  static {
    testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'yogiyouser@deliveryhero.com', 'Yogiyo', 'KR');
    insert testUser;
    UnitTestDataFactory.getRecordtypeValues();
    System.runAs(testUser){
      country = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
      insert country;

      
      //config_OppQuoteProcess = UnitTestDataFactory.createBusinessConfig('OppQuoteProcess', 'Process', 'OppQuoteEmailTemplate', 'Yogiyo_QuoteVFTemplate_Asset,Yogiyo_QuoteVFTemplate_Service,Yogiyo_QuoteVFTemplate_Both,Yogiyo_QuoteVFTemplate_MenuPrinting,Yogiyo_QuoteVFTemplate_AdSales', country.Id, 'Yogiyo_Account', true, false);
      //greeting_OppQuoteProcess = UnitTestDataFactory.createBusinessConfig('OppQuoteProcess', 'Process','Greeting','Salutation,Lastname', country.Id, 'Yogiyo_Account', true, false);
          //useDefaultContent_OppQuoteProcess = UnitTestDataFactory.createBusinessConfig('OppQuoteProcess', 'Process','UseDefaultQuoteComment','true', country.Id, 'Yogiyo_Account', true, false);
          Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='OppQuoteEmailTemplate',Business_Rule_Value__c='Yogiyo_QuoteVFTemplate_Asset,Yogiyo_QuoteVFTemplate_Service,Yogiyo_QuoteVFTemplate_Both,Yogiyo_QuoteVFTemplate_MenuPrinting,Yogiyo_QuoteVFTemplate_AdSales',Id_Country__c=country.id,Is_Active__c=true,Parent__c=true,Process_Name__c='OppQuoteProcess',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
      Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='Greeting',Business_Rule_Value__c='Salutation,Lastname',Id_Country__c=country.id,Is_Active__c=true,Parent__c=false,Process_Name__c='OppQuoteProcess',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
      Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='UseDefaultQuoteComment',Business_Rule_Value__c='true',Id_Country__c=country.id,Is_Active__c=true,Parent__c=false,Process_Name__c='OppQuoteProcess',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
      Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='FieldSet',Business_Rule_Value__c='Yogiyo_fields',Id_Country__c=country.id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteScreenProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
      Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='DisableButton_Draft',Business_Rule_Value__c='acceptQuote,createPDF,sendEmail,refresh',Id_Country__c=country.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteScreenProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
      Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c='DisableButton_Rejected',Business_Rule_Value__c='acceptQuote,createPDF,sendEmail,refresh',Id_Country__c=country.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteScreenProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
      Business_Config__c b7 = new Business_Config__c(Business_Rule_Name__c='DisableButton_Pending',Business_Rule_Value__c='acceptQuote,createPDF,sendEmail,refresh,approval,sendEmail,readOnly',Id_Country__c=country.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteScreenProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
      Business_Config__c b8 = new Business_Config__c(Business_Rule_Name__c='DisableButton_Declined',Business_Rule_Value__c='acceptQuote,createPDF,sendEmail,refresh',Id_Country__c=country.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteScreenProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
      Business_Config__c b9 = new Business_Config__c(Business_Rule_Name__c='DisableButton_Waiting for answer',Business_Rule_Value__c='acceptQuote,refresh',Id_Country__c=country.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteScreenProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
      Business_Config__c b10 = new Business_Config__c(Business_Rule_Name__c='DisableButton_Accepted',Business_Rule_Value__c='acceptQuote,refresh',Id_Country__c=country.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteScreenProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
      Business_Config__c b11 = new Business_Config__c(Business_Rule_Name__c='OppQuoteRecordTypeid',Business_Rule_Value__c='Yogiyo_Opportunity_Quote',Id_Country__c=country.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteScreenProcess',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
     Business_Config__c b12 = new Business_Config__c(Business_Rule_Name__c='level1ApprovedStatus',Business_Rule_Value__c='Pending - legal',Id_Country__c=country.id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
     Business_Config__c b13 = new Business_Config__c(Business_Rule_Name__c='initialStatusLevel3',Business_Rule_Value__c='Approval pending - Regional HOS',Id_Country__c=country.id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
     Business_Config__c b14 = new Business_Config__c(Business_Rule_Name__c='InformHOSEmailTemplate',Business_Rule_Value__c='Talabt_Inform_HOS',Id_Country__c=country.id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
     Business_Config__c b15 = new Business_Config__c(Business_Rule_Name__c='InformHOSEmailSubject',Business_Rule_Value__c='{AccountName}: There is a new Quote for Regional HOS approval!',Id_Country__c=country.id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
     Business_Config__c b16 = new Business_Config__c(Business_Rule_Name__c='InformHOSAboutRegionalHOSApproval',Business_Rule_Value__c='true',Id_Country__c=country.id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
     Business_Config__c b17 = new Business_Config__c(Business_Rule_Name__c='CheckForRequiredFields',Business_Rule_Value__c='true',Id_Country__c=country.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteScreenProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
     Business_Config__c b18 = new Business_Config__c(Business_Rule_Name__c='AllowAcceptQuoteButton',Business_Rule_Value__c='60',Id_Country__c=country.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteScreenProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
     Business_Config__c b19 = new Business_Config__c(Business_Rule_Name__c='SkipEmailForTypes',Business_Rule_Value__c='Refund',Id_Country__c=country.id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteScreenProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
        Business_Config__c b20 = new Business_Config__c(Business_Rule_Name__c='MonthsMap',Business_Rule_Value__c='{"1":"January","2":"February","3":"March","4":"April","5":"May","6":"June","7":"July","8":"Augost","9":"September","10":"October","11":"November","12":"December",}',Id_Country__c=country.id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteScreenProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');


        //Business_Config__c b10 = new Business_Config__c(Business_Rule_Name__c='OppQuoteRecordTypeid',Business_Rule_Value__c='Yogiyo_Opportunity_Quote',Id_Country__c=country.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteScreenProcess',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');

      insert new List<sObject>{b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16,b17,b18,b19,b20};
          system.debug('*b4'+b4);
          accounts = UnitTestDataFactory.createAccounts(1, country, 'Yogiyo_Account');
        accounts[0].CurrencyIsoCode = 'KRW';
      insert accounts;

      List<Contact> contacts = UnitTestDataFactory.createContacts(accounts, 'test Lastname', 'test FirstName', 'Mr', 'Owner', 1, 'testme', 'Yogiyo_Contact');

      opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'Yogiyo_Opportunity', Date.today().addMonths(2));
      insert opportunities;

      /*EmailTemplate templateAsset = UnitTestDataFactory.createEmailTemplate('Yogiyo_QuoteVFTemplate_Asset', 'Yogiyo Asset', 'Yogiyo_QuoteVFTemplate_Asset', true, 'Quote', 'Text', testUser.Id);
      EmailTemplate templateService = UnitTestDataFactory.createEmailTemplate('Yogiyo_QuoteVFTemplate_Service', 'Yogiyo Service', 'Yogiyo_QuoteVFTemplate_Service', true, 'Quote', 'Text', testUser.Id);
      EmailTemplate templateBoth = UnitTestDataFactory.createEmailTemplate('Yogiyo_QuoteVFTemplate_Both', 'Yogiyo Both', 'Yogiyo_QuoteVFTemplate_Both', true, 'Quote', 'Text', testUser.Id);
      EmailTemplate templateMenuPrinting = UnitTestDataFactory.createEmailTemplate('Yogiyo_QuoteVFTemplate_MenuPrinting', 'Yogiyo Menu Printing', 'Yogiyo_QuoteVFTemplate_MenuPrinting', true, 'Quote', 'Text', testUser.Id);
      EmailTemplate templateAdsales = UnitTestDataFactory.createEmailTemplate('Yogiyo_QuoteVFTemplate_AdSales', 'Yogiyo Adsales', 'Yogiyo_QuoteVFTemplate_AdSales', true, 'Quote', 'Text', testUser.Id);
      insert new List<sObject>{templateAsset, templateService, templateBoth, templateMenuPrinting,templateAdsales,contacts[0]};*/

      quotes = UnitTestDataFactory.createOpportunityQuotes(opportunities[0], 1, 'Yogiyo_Opportunity_Quote', 'draft', 'TEST', 100, 100, 'Test', 'Test', 10);
          insert quotes;
          oppQuote = [select id, status__c,recordtypeId,Id_Opportunity__r.Business_Type__c, Recordtype.Developername,Id_Opportunity__r.Record_Country__c from opportunity_quote__c where id =:quotes[0].id];
          opportunities = [select id,AccountId,name,recordtypeId,recordtype.developerName from Opportunity where id in :opportunities];
    }
  }
  
  static testmethod void UnitTest1(){
        Test.startTest();
        
        System.runAs(testUser){
            ApexPages.StandardController std= new ApexPages.StandardController(oppQuote );
            CtrQuoteScreen ctrl= new CtrQuoteScreen(std);
            ctrl.generateTemplateName();
            String templateName = ctrl.templateName;
            ctrl.switchToEditMode();
            ctrl.switchToViewMode();
            ctrl.switchToLockMode();
            pageReference pg=ctrl.saveDetails();
            
        }
        Test.stopTest();
    }

    /**
     * @description Test the functionality to skip sending email for certain opportunity business types
     */
    static testMethod void test_AcceptQuote() {
        ApexPages.StandardController std= new ApexPages.StandardController(oppQuote );
        CtrQuoteScreen ctrl= new CtrQuoteScreen(std);
        System.assertEquals('60', ctrl.allowAcceptQuote);
        opportunities[0].Business_Type__c = 'Refund';
        update opportunities;
        oppQuote = OpportunityQuoteSelector.findAll()[0];
        std= new ApexPages.StandardController(oppQuote );
        ctrl = new CtrQuoteScreen(std);
        System.assertEquals(null, ctrl.allowAcceptQuote);
    }
  
  
}