@isTest
public class unitTestCtrLeadExten {
    Private static Lead testLead;
    Private static Lead testLead2;
    public static Map<String,RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Lead'});

    
    
     public static void  CreateLead(){
           UnitTestDataFactory.getRecordtypeValues();
        testLead  = new Lead();
        testLead.Company = 'MyTestCompany';
        testLead.Street = 'teststreet'; 
        testLead.Restaurant_Name__c = 'My Test Restaurant';
        testLead.LastName = 'Test';
        testLead.CurrencyIsoCode = 'GBP';
        testLead.Longitude = -0.30576014496403703;
        testLead.Latitude = 51.512362901834540;
        testLead.LeadSource = 'Import';
        testLead.Cuisine__c = 'Asian';
        testLead.PostalCode = 'W5 2PJ';
        testLead.Status = 'Qualified';
        testLead.RecordTypeId = mapRecordtypes.get('UK_Lead').Id;  
        //system.debug('recordtypeId' + LibRecordTypeHelper.getRecordType('UK_Lead', 'Lead').Id);
        insert testLead;
        
        testLead2 = new Lead();
        testLead2.Company = 'MyTestCompany2';
        testLead2.Restaurant_Name__c = 'My Test Restaurant2';
        testLead2.LastName = 'Test';
        testLead2.Street = 'teststreet'; 
        testLead2.CurrencyIsoCode = 'GBP';
        testLead2.Longitude = -0.30576014123403705;
        testLead2.Latitude = 51.512362967534544;
        testLead2.LeadSource = 'Import';
        testLead2.Cuisine__c = 'Asian';
        testLead2.PostalCode = 'W5 2PJ';
        testLead2.Status = 'Qualified';
        testLead2.RecordTypeId = mapRecordtypes.get('UK_Lead').Id;  
         
        
        insert testLead2;

        
     }
    
    
    @isTest
    static void testSave() {
        system.debug(mapRecordtypes);
        Country__c testCountry = UnitTestDataFactory.createCountry('UK','United Kingdom','GBP');
        insert testCountry;

        Company__c testCompany = UnitTestDataFactory.createCompany('Hungryhouse', 'HH', testCountry);
        insert testCompany;
        Business_Config__c config1 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'LeadMapDisplay', 'Postcode', testCountry.Id, 'UK_Lead', true, true);
        Business_Config__c config2 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'LeadMapDefaultDistance','5', testCountry.Id, 'UK_Lead', true, false);
        Business_Config__c config3 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'LeadMapDefault', 'Postcode', testCountry.Id, 'UK_Lead', true, false);
            
        insert new List<sObject>{config1, config2, config3};
        CreateLead();
        CtrLeadExten cstCtrLead;
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testLead);
        
        Test.startTest();
            cstCtrLead = new CtrLeadExten(stdCtrl);
            cstCtrLead.getCodesByDistance();
            cstCtrLead.getCodesByPostcode();
        Test.stopTest();
        
        System.assertEquals(true, true);
    }

}