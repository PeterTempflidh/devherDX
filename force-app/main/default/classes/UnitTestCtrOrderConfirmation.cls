@isTest
private class UnitTestCtrOrderConfirmation {
    private static Country__c testCountry;
    private static Company__c testCompany;
    private static List<Lead> leads;
    
    static {
        UnitTestDataFactory.getRecordtypeValues();
        List<Platform_Country__c> platformCountry =new List<Platform_Country__c>();
        platformCountry.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name='FOCPlatform', country__c='Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
        testCountry = UnitTestDataFactory.createCountry('UK','United Kingdom','GBP');
        insert testCountry;

        testCompany = UnitTestDataFactory.createCompany('Hungryhouse', 'HH', testCountry);
        insert testCompany;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='FieldsToQuery',Business_Rule_Value__c='Subdistrict__c,Id,OwnerId,MobilePhone,Email,ConvertedAccountId,ConvertedContactId,ConvertedDate,ConvertedOpportunityId,RecordTypeId,RecordType.DeveloperName,Street,City,PostalCode,Country,Fax,Phone,LeadSource,Status,State,Name,Company,Salutation,FirstName,LastName,Country__c,Record_Country__c,CurrencyIsoCode,Platform__c,Target_Partner__c,Number_of_Restaurants__c',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='Lead Conversion',Record_Type_Id__c='UK_Lead',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='OppBusinessType',Business_Rule_Value__c='New Business',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Lead Conversion',Record_Type_Id__c='UK_Lead',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='DefaultStageProbability',Business_Rule_Value__c='StageName=Prospecting,Probability=20',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Lead Conversion',Record_Type_Id__c='UK_Lead',Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='LeadToAccountMap',Business_Rule_Value__c='Record_Country__c=Record_Country__c,Account_Email__c=Email,Non_Contracted__c=Non_Contracted__c,ShippingStreet=Street,ShippingCity=City,ShippingPostalCode=PostalCode,ShippingCountry=Country,ShippingState=State,Shipping_Subdistrict__c=Subdistrict__c,CurrencyIsoCode=CurrencyIsoCode,Platform__c=Platform__c,Target_Partner__c=Target_Partner__c,Number_of_Restaurants__c=Number_of_Restaurants__c',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Lead Conversion',Record_Type_Id__c='UK_Lead',Type__c='Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='LeadFieldsToQueryAfterConversion',Business_Rule_Value__c='Record_Country__c,Email,Street,City,PostalCode,Country,State,Subdistrict__c,CurrencyIsoCode',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Lead Conversion',Record_Type_Id__c='UK_Lead',Type__c='Process');
        Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c='LeadInformationFieldsToDisplay',Business_Rule_Value__c='OwnerId,Country__c',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Lead Conversion',Record_Type_Id__c='UK_Lead',Type__c='Process');
        Business_Config__c b7 = new Business_Config__c(Business_Rule_Name__c='ContactInformationFieldsToDisplay',Business_Rule_Value__c='Salutation,FirstName,LastName,MobilePhone,Phone,Email',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Lead Conversion',Record_Type_Id__c='UK_Lead',Type__c='Process');
        Business_Config__c b8 = new Business_Config__c(Business_Rule_Name__c='TerritoryFieldToCompare',Business_Rule_Value__c='BillingPostalCode',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Lead Conversion',Record_Type_Id__c='UK_Lead',Type__c='Process');
        Business_Config__c b9 = new Business_Config__c(Business_Rule_Name__c='AccountInformationFieldsToDisplay',Business_Rule_Value__c='Street,City,PostalCode,State,Country,Review_Source__c,Feature_Competitor__c,Target_Partner__c,Number_of_Reviews__c,Number_of_Restaurants__c,External_Rating__c',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Lead Conversion',Record_Type_Id__c='UK_Lead',Type__c='Process');
        Business_Config__c b10 = new Business_Config__c(Business_Rule_Name__c='SkipConversionPage',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Lead Conversion',Record_Type_Id__c='UK_Lead',Type__c='Process');
        Business_Config__c b11 = new Business_Config__c(Business_Rule_Name__c='MandatoryFields',Business_Rule_Value__c='city',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Lead Conversion',Record_Type_Id__c='UK_Lead',Type__c='Process');
        Business_Config__c b12 = new Business_Config__c(Business_Rule_Name__c='LeadToQuoteOppStage',Business_Rule_Value__c='StageName=Verbal Agreement,Probability=50',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Lead Conversion',Record_Type_Id__c='UK_Lead',Type__c='Process');

        insert new List<sObject>{b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11};
        leads = UnitTestDataFactory.createLeads (1, testCountry, 'Mustermann', 'Hungryhouse', 'GBP', 'Mustermann Food', 'UK_Lead');
        leads[0].phone= '0044123456789';
        leads[0].MobilePhone='0044712345678';
        leads[0].PostalCode ='DE24 3JG';
        leads[0].delivery_Service__c = 'Unknown';
        leads[0].Cuisine__c = 'American';
        insert leads;
    }
    
     @isTest static void orderConfirmation(){
        //System.runAs(testUser){
         Lead ld =CtrOrderConfirmation.getLead(leads[0].Id);
         List<Schema.PicklistEntry> pickVal= CtrOrderConfirmation.getCuisineTypes(leads[0].id);
         String ldDatat=CtrOrderConfirmation.updateLead(leads[0].Id, 'test','test', 'test', 'blah',
                                    'DE24 3JG', 'London', 'test@deliveryhero.com', '0044123456789',
                                    '0044712345678', '4/10/2006', 20, 300, 'test tarif','test desc',
                                    3,'test', '9:30', 'test', 'Mr.');
         String convertedLd= CtrOrderConfirmation.convertLead(leads[0].Id,'New Sign up');                   
        
       // }
     }
   
    
    
}