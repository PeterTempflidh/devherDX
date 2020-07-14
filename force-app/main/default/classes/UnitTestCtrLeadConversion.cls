/*
@author : Alexander Faust
@reviewer : Terence Viban
@creation : 01.12.2015

@notes: code coverage is 95%. Missing lines are page messages which cannot be tested (cant reproduce the
error of a empty company string on lead and cannot force the opportunity update to fail)
*/
@isTest
private class UnitTestCtrLeadConversion {
    private static User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'yogiyounittestuser@deliveryhero.com', 'Yogiyo', 'KR');
    private static Country__c testCountry;
    private static Company__c testCompany;
    private static RecordType yogiyoRecordType;
    private static List<Lead> leads;

    @testSetup static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
        testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        insert testCountry;
        List<Business_Config__c> listConfigs = new List<Business_Config__c>();
        Business_Config__c config1 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'FieldsToQuery', 'Dong__c,GunGu__c,Subdistrict__c,Id,OwnerId,MobilePhone,Email,ConvertedAccountId,ConvertedContactId,ConvertedDate,CurrencyIsoCode,ConvertedOpportunityId,RecordTypeId,RecordType.DeveloperName,Street,City,PostalCode,Country,Fax,Phone,LeadSource,Status,State,Name,Company,Salutation,FirstName,LastName,Country__c,Record_Country__c', testCountry.Id, 'Yogiyo_Lead', true, true);
        Business_Config__c config2 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'ContactInformationFieldsToDisplay', 'Salutation,FirstName,LastName,MobilePhone,Phone,Fax,Email', testCountry.Id, 'Yogiyo_Lead', true, false);
        Business_Config__c config3 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'AccountInformationFieldsToDisplay', 'Street,Subdistrict__c,GunGu__c,Dong__c,City,PostalCode,State,Country', testCountry.Id, 'Yogiyo_Lead', true, false);
        Business_Config__c config4 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'LeadInformationFieldsToDisplay', 'OwnerId,LeadSource,Status,Country__c', testCountry.Id, 'Yogiyo_Lead', true, false);
        Business_Config__c config5 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'MandatoryFields', 'OwnerId,Country__c', testCountry.Id, 'Yogiyo_Lead', true, false);
        Business_Config__c config6 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'SkipConversionPage', 'false', testCountry.Id, 'Yogiyo_Lead', true, false);
        Business_Config__c config7 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'LeadToAccountMap', 'Record_Country__c=Record_Country__c,Account_Email__c=Email,Non_Contracted__c=Non_Contracted__c=ShippingStreet=Street,ShippingCity=City,ShippingPostalCode=PostalCode,ShippingCountry=Country,ShippingState=State,Shipping_Subdistrict__c=Subdistrict__c,CurrencyIsoCode=CurrencyIsoCode', testCountry.Id, 'Yogiyo_Lead', true, false);
        //Business_Config__c config8 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'LeadFieldsToQueryAfterConversion', 'Record_Country__c,Email,Non_Contracted__c,Street,City,PostalCode,Country,State,Subdistrict__c,CurrencyIsoCode', testCountry.Id, 'Yogiyo_Lead', true, false);
        //Business_Config__c config9 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'TerritoryFieldToCompare', 'Record_Country__c,Email,Non_Contracted__c,Street,City,PostalCode,Country,State,Subdistrict__c,CurrencyIsoCode', testCountry.Id, 'Yogiyo_Lead', true, false);
        Business_Config__c config10 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'DefaultStageProbability', 'StageName=Appointment Set,Probability=5', testCountry.Id, 'Yogiyo_Lead', true, false);

        insert new List<sObject> {config1, config2, config3, config4, config5, config6, config7, config10};

    }

    static void userSetup() {

        List<Platform_Country__c> platformCountry = new List<Platform_Country__c>();
        platformCountry.add(new Platform_Country__c(name = 'TalabatPlatform', country__c = 'Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name = 'FOCPlatform', country__c = 'Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
        insert testUser;

        System.runAs(testUser) {
            testCountry = [Select Iso__c,
                           Name,
                           CurrencyIsoCode
                           From Country__c
                           Where Iso__c = 'KR' ];

            testCompany = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', testCountry);
            insert testCompany;

            leads = UnitTestDataFactory.createLeads (1, testCountry, 'Mustermann', 'Yogiyo', 'KRW', 'Mustermann Food', 'Yogiyo_Lead');
            insert leads;

            yogiyoRecordType = UnitTestDataFactory.getRecordType('Yogiyo_Lead');
        }
    }


    @isTest static void testVariablesAndConstructor() {
        userSetup();
        Test.startTest();
        ApexPages.StandardController sdtController;
        CtrLeadConversion ctrl;
        Lead leadToConvert = [SELECT Id, RecordType.DeveloperName, CurrencyIsoCode, Company_Code__c, Company, Record_Country__c FROM Lead WHERE Id = : leads[0].Id];
        System.runAs(testUser) {
            sdtController = new ApexPages.StandardController(leadToConvert);
            system.debug('@@@@ calling testSuccessfullConvertWithOpportunity : ' + sdtController);
            ctrl = new CtrLeadConversion(sdtController);

            //Below code is for code coverage
            ctrl.mobileActionConvert();
            List<SelectOption> contactRoleOptions = ctrl.contactRoleOptions;
            Schema.DisplayType d = CtrLeadConversion.getFieldType('Name','Lead');
            //End-coverage code

        }
        Test.stopTest();

        System.assertEquals(leadToConvert.Id, ctrl.leadToConvert.Id);
        System.assertEquals(leadToConvert.Company, ctrl.leadToConvert.Company);
        System.assertEquals('Yogiyo', ctrl.companyCode);
    }

    @isTest static void testSuccessfullConvertWithOpportunity() {
        userSetup();
        Test.startTest();
        ApexPages.StandardController sdtController;
        CtrLeadConversion ctrl;
        Lead leadToConvert = [SELECT Id, RecordType.DeveloperName, CurrencyIsoCode, Company_Code__c, Company, Record_Country__c FROM Lead WHERE Id = : leads[0].Id];
        System.runAs(testUser) {
            sdtController = new ApexPages.StandardController(leadToConvert);
            ctrl = new CtrLeadConversion(sdtController);
            ctrl.convertLead();
            ctrl.opportunityName = 'MyTestOpportunity';
        }
        Test.stopTest();

        Lead convertedLead = [SELECT Id, isConverted, Company, LastName FROM Lead WHERE Id = : leadToConvert.Id];
        System.assert(convertedLead.isConverted);

        Account createdAccount = [SELECT Id FROM Account WHERE Name = :convertedLead.Company];
        System.assertNotEquals(null, createdAccount);

        Opportunity createdOpp = [SELECT Id, Name FROM Opportunity WHERE AccountId = : createdAccount.Id];
        System.assertNotEquals(null, createdOpp);
        System.assertNotEquals('MyTestOpportunity', createdOpp.Name);

        Contact createdContact = [SELECT Id, Contact_Role__c, LastName FROM Contact Where AccountId = : createdAccount.Id];
        System.assertEquals(convertedLead.LastName, createdContact.LastName);
        System.assertEquals('Owner', createdContact.Contact_Role__c);

        System.assertNotEquals(null, ctrl.getDynamicPanelPage());

        // Implement test code
    }

    @isTest static void testSuccessFullConvertWithoutOpportunity() {
        userSetup();
        Test.startTest();
        ApexPages.StandardController sdtController;
        CtrLeadConversion ctrl;
        Lead leadToConvert = [SELECT Id, RecordType.DeveloperName, CurrencyIsoCode, Company_Code__c, Company, Record_Country__c FROM Lead WHERE Id = : leads[0].Id];
        System.runAs(testUser) {
            sdtController = new ApexPages.StandardController(leadToConvert);
            ctrl = new CtrLeadConversion(sdtController);
            ctrl.opportunityName = 'MyTestOpportunity';
            ctrl.newOpportunityMustBeNotCreated = true;
            ctrl.convertLead();
        }
        Test.stopTest();

        Lead convertedLead = [SELECT Id, isConverted, Company, LastName FROM Lead WHERE Id = : leadToConvert.Id];
        System.assert(convertedLead.isConverted);

        Account createdAccount = [SELECT Id FROM Account WHERE Name = :convertedLead.Company];
        System.assertNotEquals(null, createdAccount);

        List<Opportunity> listCreatedOpp = [SELECT Id, Name FROM Opportunity WHERE AccountId = : createdAccount.Id];
        System.assert(listCreatedOpp.isEmpty());
    }

    @isTest static void testSuccessfullConvertWithAdditionalContacts() {
        userSetup();
        Test.startTest();
        ApexPages.StandardController sdtController;
        CtrLeadConversion ctrl;
        Lead leadToConvert = [SELECT Id, RecordType.DeveloperName, CurrencyIsoCode, Company_Code__c, Company, Record_Country__c FROM Lead WHERE Id = : leads[0].Id];
        System.runAs(testUser) {
            sdtController = new ApexPages.StandardController(leadToConvert);
            ctrl = new CtrLeadConversion(sdtController);

            ctrl.addNewContact();

            if (!ctrl.mapNewContactMap.isEmpty()) {

                for (String key : ctrl.mapNewContactMap.keySet()) {
                    if (ctrl.mapNewContactMap.get(key).LastName == null) {
                        ctrl.mapNewContactMap.get(key).salutation = 'Mr';
                        ctrl.mapNewContactMap.get(key).FirstName = 'John';
                        ctrl.mapNewContactMap.get(key).LastName = 'Doe';
                        ctrl.mapNewContactMap.get(key).mobile = '01245635';
                        ctrl.mapNewContactMap.get(key).email = 'jd@email.com';
                    }
                }


            }
            ctrl.convertLead();
        }

        Test.stopTest();
        Lead convertedLead = [SELECT Id, isConverted, Company, LastName FROM Lead WHERE Id = : leadToConvert.Id];
        System.assert(convertedLead.isConverted);

        Account createdAccount = [SELECT Id FROM Account WHERE Name = : convertedLead.Company];
        System.assertNotEquals(null, createdAccount);

        List<Opportunity> listCreatedOpp = [SELECT Id FROM Opportunity WHERE AccountId = : createdAccount.Id];
        System.assertEquals(1, listCreatedOpp.size());

        List<Contact> listCreatedContacts = [SELECT Id, LastName FROM Contact WHERE AccountId = : createdAccount.Id ORDER BY LastName ASC];
        System.assertEquals(2, listCreatedContacts.size());

        System.assertEquals('Doe', listCreatedContacts[0].LastName);
        System.assertEquals('Mustermann', listCreatedContacts[1].LastName);

    }

    @isTest static void testUnSuccessfullConvertWithAdditionalContactsNoLastName() {
        userSetup();
        Test.startTest();
        ApexPages.StandardController sdtController;
        CtrLeadConversion ctrl;
        Lead leadToConvert = [SELECT Id, RecordType.DeveloperName, CurrencyIsoCode, Company_Code__c, Company, Record_Country__c FROM Lead WHERE Id = : leads[0].Id];
        System.runAs(testUser) {
            sdtController = new ApexPages.StandardController(leadToConvert);
            ctrl = new CtrLeadConversion(sdtController);

            ctrl.addNewContact();

            if (!ctrl.mapNewContactMap.isEmpty()) {

                for (String key : ctrl.mapNewContactMap.keySet()) {
                    if (ctrl.mapNewContactMap.get(key).LastName == null) {
                        ctrl.mapNewContactMap.get(key).salutation = 'Mr';
                        ctrl.mapNewContactMap.get(key).FirstName = 'John';
                        ctrl.mapNewContactMap.get(key).mobile = '01245635';
                        ctrl.mapNewContactMap.get(key).email = 'jd@email.com';
                    }
                }


            }
            ctrl.convertLead();
        }

        Test.stopTest();

        Lead convertedLead = [SELECT Id, isConverted, Company, LastName FROM Lead WHERE Id = : leadToConvert.Id];
        System.assert(!convertedLead.isConverted);

        Account[] createdAccounts = [SELECT Id FROM Account WHERE Name = : convertedLead.Company];
        System.assert(createdAccounts.isEmpty());
    }

    @isTest static void testRemoveAdditionalContactFromList() {
        userSetup();
        Test.startTest();
        ApexPages.StandardController sdtController;
        CtrLeadConversion ctrl;
        Lead leadToConvert = [SELECT Id, RecordType.DeveloperName, CurrencyIsoCode, Company_Code__c, Company, Record_Country__c FROM Lead WHERE Id = : leads[0].Id];
        System.runAs(testUser) {
            sdtController = new ApexPages.StandardController(leadToConvert);
            ctrl = new CtrLeadConversion(sdtController);

            ctrl.addNewContact();


            if (!ctrl.mapNewContactMap.isEmpty()) {

                for (String key : ctrl.mapNewContactMap.keySet()) {
                    if (ctrl.mapNewContactMap.get(key).LastName == null) {
                        ctrl.mapNewContactMap.get(key).salutation = 'Mr';
                        ctrl.mapNewContactMap.get(key).FirstName = 'John';
                        ctrl.mapNewContactMap.get(key).LastName = 'Doe';
                        ctrl.mapNewContactMap.get(key).mobile = '01245635';
                        ctrl.mapNewContactMap.get(key).email = 'jd@email.com';

                        ctrl.contactToRemove = key;
                    }
                }


            }
            ctrl.removeContactFromList();
        }

        Test.stopTest();
        System.assert(ctrl.mapNewContactMap.isEmpty());
    }

    @isTest static void testCancel() {
        userSetup();
        PageReference returnRef;

        Test.startTest();
        ApexPages.StandardController sdtController;
        CtrLeadConversion ctrl;
        Lead leadToConvert = [SELECT Id, RecordType.DeveloperName, CurrencyIsoCode, Company_Code__c, Company, Record_Country__c FROM Lead WHERE Id = : leads[0].Id];
        System.runAs(testUser) {
            sdtController = new ApexPages.StandardController(leadToConvert);
            ctrl = new CtrLeadConversion(sdtController);
            returnRef = ctrl.cancel();
        }
        Test.stopTest();

        System.assertEquals('/' + leadToConvert.Id, returnRef.getURL());
    }


}