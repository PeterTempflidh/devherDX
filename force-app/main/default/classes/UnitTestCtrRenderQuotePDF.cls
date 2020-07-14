@isTest
private class UnitTestCtrRenderQuotePDF {
  private static User testUser;
  private static Country__c country;
  private static Company__c company;
  private static List<Account> accounts;
  private static List<Contact> contacts;
  private static List<Opportunity_Quote__c> quotes;
  static {
    testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'yogiyouser@deliveryhero.com', 'Yogiyo', 'KR');
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
        insert company;

        Business_Config__c config = UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'Greeting', 'Salutation,LastName', country.Id, 'Yogiyo_Opportunity_Quote', true, true);
        Business_Config__c config1 = UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'Use_Default_Content', 'true', country.Id, 'Yogiyo_Opportunity_Quote', true, false);
        Business_Config__c config2 = UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'EmailSubject', 'Partnership Confirmation', country.Id, 'Yogiyo_Opportunity_Quote', true, false);
        Business_Config__c config3 = UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'OnlinePaymentPdf', 'TalabatPaymentPdf', country.Id, 'Yogiyo_Opportunity_Quote', true, false);
        EmailTemplate templateAsset = UnitTestDataFactory.createEmailTemplate('OnlinePaymentPdf', 'Yogiyo Asset', 'OnlinePaymentPdf', true, 'Quote', 'Text', testUser.Id);
        List<sObject> objectsToInsert2 = new List<sObject>();
        objectsToInsert2.add(config);
        objectsToInsert2.add(config1);
        objectsToInsert2.add(config2);
        objectsToInsert2.add(config3);
        objectsToInsert2.add(templateAsset);
        insert objectsToInsert2;
        accounts = UnitTestDataFactory.createAccounts(1, country, 'Yogiyo_Account');
        insert accounts;
        contacts = UnitTestDataFactory.CreateContacts(accounts, 'Best', 'Burger', 'Mr', 'Employee', 5, 'test', 'Yogiyo_Contact');
        List<Opportunity> opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'Yogiyo_Opportunity', Date.today().addMonths(2));
        List<sObject> objectsToInsert3 = new List<sObject>();
        objectsToInsert3.addAll((List<sObject>)contacts);
        objectsToInsert3.addAll((List<sObject>)opportunities);
        insert objectsToInsert3;

        List<Opportunity_Quote__c> quotes_1 = UnitTestDataFactory.createOpportunityQuotes(opportunities[0], 1, 'Yogiyo_Opportunity_Quote', 'Draft', 'TEST', 100, 100, 'Test', 'Test', 10);
        quotes_1[0].Non_Standard_Contract_Components__c = 'Online Payment Doc'; 
        insert quotes_1;

        quotes = [SELECT Id, Name, status__c,Non_Standard_Contract_Components__c, RecordtypeId, RecordType.DeveloperName, Id_opportunity__c,Attachment__c, Id_opportunity__r.recordtypeId, Id_opportunity__r.Accountid, Id_Account__c, description__c, Url_Key__c, Quote_Comment__c FROM Opportunity_Quote__c WHERE Id =: quotes_1[0].Id];

        contacts[0].Contact_Role__c = 'Owner';
        update contacts[0];
    }

  }

//updated
    @isTest static void test_method_one() {

      ApexPages.StandardController sdtController;
      CtrRenderQuotePDF sq;
      System.runAs(testUser){
        Test.startTest();
        sdtController = new ApexPages.StandardController(quotes[0]);
        sq = new CtrRenderQuotePDF(sdtController);
        sq.getOnlinePaymentPDF();
        //sq.getQuoteAdditions();
        Test.stopTest();
      }
    }
    
}