@isTest
private class UnitTestCtrSendQuote {

  private static User testUser;
  private static Country__c country;
  private static Company__c company;
  private static List<Account> accounts;
  private static List<Contact> contacts;
  private static List<Opportunity_Quote__c> quotes;

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
        insert company;

        Business_Config__c config = UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'Greeting', 'Salutation,LastName', country.Id, 'Yogiyo_Opportunity_Quote', true, true);
        Business_Config__c config1 = UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'Use_Default_Content', 'true', country.Id, 'Yogiyo_Opportunity_Quote', true, false);
        Business_Config__c config2 = UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'EmailSubject', 'Partnership Confirmation', country.Id, 'Yogiyo_Opportunity_Quote', true, false);
        Business_Config__c config3 = UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'sendEmailOppStage', 'true', country.Id, 'Yogiyo_Opportunity_Quote', true, false);
        Business_Config__c config4 = UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'productTypeWithEmailContent', 'Blade Sign=UK_EC_Blade_Sign,Premium Placement=UK_EC_Premium_Placement,Menu Printing=UK_EC_Menu_Printing,Default=UK_EC_Sign_up_Telesales,Fieldsales=UK_EC_Sign_up_Field_Agent,Upgrade=UK_EC_Upgrade', country.Id, 'Yogiyo_Opportunity_Quote', true, false);
        Business_Config__c config5 = UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'useQuoteTemplateNameAsPdf', 'TRUE', country.Id, 'PY_Opportunity_Quote', true, false);
        Business_Config__c config6 = UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'OnlinePaymentPdf', 'SE_online_payment_v2', country.Id, 'SE_Opportunity_Quote', true, false);
        Business_Config__c config7 = UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'EmailTemplateMap', '{"New Business":"Talabat_NB_EmailTemplate","UpgradeUpsell":"Talabat_ProductOnly_EmailTemplate","Premium Placement":"Talabat_PP_EmailTemplate"}', country.Id, 'Talabat_Opportunity_Quote', true, false);
        Business_Config__c config8 = UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'defaultAttachmentPerOppBusinessType', 'New Business=Talabat_Account_Setup_Form2,Owner Change=Talabat_Account_Setup_Form2,Win Back=Talabat_Account_Setup_Form2', country.Id, 'Talabat_Opportunity_Quote', true, false);

        List<sObject> objectsToInsert2 = new List<sObject>();
        objectsToInsert2.add(config);
        objectsToInsert2.add(config1);
        objectsToInsert2.add(config2);
        objectsToInsert2.add(config3);
        objectsToInsert2.add(config4);
        objectsToInsert2.add(config5);
        objectsToInsert2.add(config6);
        objectsToInsert2.add(config7);
        objectsToInsert2.add(config8);
        insert objectsToInsert2;
        accounts = UnitTestDataFactory.createAccounts(1, country, 'Yogiyo_Account');
        insert accounts;
        contacts = UnitTestDataFactory.CreateContacts(accounts, 'Best', 'Burger', 'Mr', 'Employee', 5, 'test', 'Yogiyo_Contact');
        List<Opportunity> opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'Yogiyo_Opportunity', Date.today().addMonths(2));
        List<sObject> objectsToInsert3 = new List<sObject>();
        objectsToInsert3.addAll((List<sObject>)contacts);
        objectsToInsert3.addAll((List<sObject>)opportunities);
        insert objectsToInsert3;

        List<Opportunity_Quote__c> quotes_1 = UnitTestDataFactory.createOpportunityQuotes(opportunities[0], 2, 'Yogiyo_Opportunity_Quote', 'Draft', 'TEST', 100, 100, 'Test', 'Test', 10);
        quotes_1[0].Non_Standard_Contract_Components__c ='Online Payment Doc';
        quotes_1[0].Attachment__c = 'Quote';
        insert quotes_1;

        quotes = [SELECT Id, Name, status__c, RecordtypeId,id_opportunity__r.type, RecordType.DeveloperName,
        			Non_Standard_Contract_Components__c, Id_opportunity__c,Attachment__c, Id_opportunity__r.recordtypeId, 
        			Id_opportunity__r.Accountid, Id_Account__c, description__c, Url_Key__c, Quote_Comment__c,
        			Id_opportunity__r.Owner.FirstName,Id_opportunity__r.Owner.LastName,Id_opportunity__r.Id_tarif__r.name ,Id_Account__r.Name
        		FROM Opportunity_Quote__c 
        		WHERE Id =: quotes_1[0].Id];

        contacts[0].Contact_Role__c = 'Owner';
        update contacts[0];
    }

  }

  @isTest static void test_Variables() {
    Test.startTest();
      ApexPages.StandardController sdtController;
      CtrSendQuote sq;
      System.runAs(testUser){
        sdtController = new ApexPages.StandardController(quotes[0]);
        sq = new CtrSendQuote(sdtController);
      }
      //system.assertEquals(1, sq.fromEmailAddresses.size());
      system.assertEquals(contacts[0].Id, sq.primaryContact[0].Id);
      system.assertEquals(contacts[0].Email, sq.primaryContactEmail);
      system.assertEquals(5, sq.allContacts.size());
      system.assertEquals(4, sq.recipients.size());
      system.assertNotEquals(null, sq.content);
      system.assertNotEquals(null, sq.subject);
      system.assertEquals(true, sq.isSingleAdd);
      system.assertEquals(true, sq.showSendQuote);
      system.assertEquals(0, sq.attachmentNames.size());
      system.assertEquals(3, sq.additionalAttachments.size());
      system.assertEquals(null, sq.additionalTo);
      system.assertEquals(null, sq.cc);
      system.assertEquals(null, sq.bcc);
      system.assertEquals(null, sq.emailToAdd);
      system.assertEquals(null, sq.whereToAddOrRemoveEmail);
      system.assertEquals(null, sq.onlinePaymentPDf);
      system.assertEquals(null, sq.fromAddress);
      system.assertEquals(null, sq.emailAttachmentsToSend);
      system.assertEquals('Salutation,LastName', sq.mapProcessData.get('Yogiyo_Opportunity_Quote').get('Greeting').Business_Rule_Value__c);


    Test.stopTest();
  }

  @isTest static void test_ValidateEmailAddresses() {
    Test.startTest();
      ApexPages.StandardController sdtController;
      CtrSendQuote sq;
      System.runAs(testUser){
        sdtController = new ApexPages.StandardController(quotes[0]);
        sq = new CtrSendQuote(sdtController);

        List<String> testEmailAddresses = new List<String>();
        for(Contact con : contacts){
          testEmailAddresses.add(con.Email);
        }

        List<String> wrongEmailAddress = sq.validateEmailAddress(testEmailAddresses);
      
        System.assertEquals(0, wrongEmailAddress.size());
      }
      Test.stopTest();
  }    

  @isTest static void test_EmailRecipients() {
    Test.startTest();
      ApexPages.StandardController sdtController;
      CtrSendQuote sq;
      System.runAs(testUser){
        sdtController = new ApexPages.StandardController(quotes[0]);
        sq = new CtrSendQuote(sdtController);

        sq.determineRecipients();
        sq.backmethod();
        system.assertEquals(null, sq.additionalTo);
        system.assertEquals(null, sq.cc);
        system.assertEquals(null, sq.bcc);

        // Test Remove from various recipient list (additionalTo, cc and bcc)

        sq.additionalTo = '';
        sq.whereToAddOrRemoveEmail = 'to';
        sq.emailToAdd = contacts[1].Email;
        sq.addTo();

        sq.cc = '';
        sq.whereToAddOrRemoveEmail = 'cc';
        sq.emailToAdd = contacts[2].Email;
        sq.addTo();

        sq.bcc = '';
        sq.whereToAddOrRemoveEmail = 'bcc';
        sq.emailToAdd = contacts[3].Email;
        sq.addTo();

        sq.determineRecipients();

        system.assertEquals(contacts[1].Email, sq.additionalTo);
        system.assertEquals(contacts[2].Email, sq.cc);
        system.assertEquals(contacts[3].Email, sq.bcc);

        sq.whereToAddOrRemoveEmail = 'to';
        sq.emailToAdd = contacts[2].Email;
        sq.addTo();

        sq.whereToAddOrRemoveEmail = 'cc';
        sq.emailToAdd = contacts[3].Email;
        sq.addTo();

        sq.whereToAddOrRemoveEmail = 'bcc';
        sq.emailToAdd = contacts[1].Email;
        sq.addTo();

        sq.determineRecipients();

        List<String> additionalTo = sq.additionalTo.split(',');
        List<String> cc = sq.cc.split(',');
        List<String> bcc = sq.bcc.split(',');
        system.assertEquals(2, additionalTo.size());
        system.assertEquals(2, cc.size());
        system.assertEquals(2, bcc.size());

        // Test Remove from various recipient list (additionalTo, cc and bcc)
        sq.whereToAddOrRemoveEmail = 'to';
        sq.emailToAdd = contacts[2].Email;
        sq.removeFrom();

        sq.whereToAddOrRemoveEmail = 'cc';
        sq.emailToAdd = contacts[3].Email;
        sq.removeFrom();

        sq.whereToAddOrRemoveEmail = 'bcc';
        sq.emailToAdd = contacts[1].Email;
        sq.removeFrom();

        sq.determineRecipients();

        List<String> additionalTo1 = sq.additionalTo.split(',');
        List<String> cc1 = sq.cc.split(',');
        List<String> bcc1 = sq.bcc.split(',');
        system.assertEquals(contacts[1].Email, sq.additionalTo);
        system.assertEquals(contacts[2].Email, sq.cc);
        system.assertEquals(contacts[3].Email, sq.bcc);
        system.assertEquals(1, additionalTo1.size());
        system.assertEquals(1, cc1.size());
        system.assertEquals(1, bcc1.size());
      } 
      Test.stopTest();
  }

  @isTest static void test_Attachments() {
    Test.startTest();
      ApexPages.StandardController sdtController;
      CtrSendQuote sq;
      System.runAs(testUser){
        sdtController = new ApexPages.StandardController(quotes[0]);
        sq = new CtrSendQuote(sdtController);

        sq.buildEmailAttachments();
        system.assertEquals(0, sq.attachmentsToUpload.size());
        system.assertEquals(1, sq.emailAttachmentsToSend.size());

        Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();  
        attachment.ParentId = quotes[0].Id;  
        attachment.Name = 'Test Attachment';  
        attachment.Body = b;

        sq.additionalAttachments.add(attachment);
        sq.buildEmailAttachments();
        system.assertEquals(1, sq.attachmentsToUpload.size());
        system.assertEquals(2, sq.emailAttachmentsToSend.size());

        sq.extractAdditionalAttachments();
      }
      Test.stopTest();
  }

  @isTest static void test_SendQuoteAndEmail() {
    Test.startTest();
      ApexPages.StandardController sdtController;
      CtrSendQuote sq;
      System.runAs(testUser){
        sdtController = new ApexPages.StandardController(quotes[0]);
        sq = new CtrSendQuote(sdtController);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        sq.buildEmailAttachments();
        sq.attachmentsToUpload.add(new Attachment(Name = 'Test Attachment', Body = Blob.valueOf('Test Data'), ParentId = quotes[0].Id));
        sq.attachmentNames = new List<String>{'Test Attachment'};

        contacts[0].Email = 'WrongEmailFormat';
        sq.recipients.put('WrongEmailFormat', new CtrSendQuote.ContactWrapper(contacts[0], 'contact', contacts[0].Name, 'WrongEmailFormat'));

        sq.additionalTo = '';
        sq.whereToAddOrRemoveEmail = 'to';
        sq.emailToAdd = 'WrongEmailFormat';
        sq.addTo();

        system.assertEquals(null, sq.SendQuote());

        sq.additionalTo = '';
        sq.whereToAddOrRemoveEmail = 'to';
        sq.emailToAdd = contacts[1].Email;
        sq.addTo();

        sq.cc = '';
        sq.whereToAddOrRemoveEmail = 'cc';
        sq.emailToAdd = contacts[2].Email;
        sq.addTo();

        sq.bcc = '';
        sq.whereToAddOrRemoveEmail = 'bcc';
        sq.emailToAdd = contacts[3].Email;
        sq.addTo();

        sq.SendQuote();
        sq.setOpportunityToQuoteSent();
       } 
    Test.stopTest();
  }
}