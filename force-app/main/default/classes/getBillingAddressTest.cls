@isTest
private class getBillingAddressTest {
    private static Country__c country;
    private static List<Account> accounts;
    private static List<Opportunity> opportunities;
    private static List<Opportunity_Quote__c> quotes;
    private static User testUser;
    
    private static testMethod void testApexData() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'unittestUser@deliveryhero.com', 'Yogiyo', 'KR');
        // Create apex data class instance
        getBillingAddress apexData = new getBillingAddress();
        
        Test.startTest();
        System.runAs(testUser) {
            setupUserData(testUser);
            
            Set<string> gd = apexData.getGlobalDescribe();
            system.assertEquals(1, gd.size());
            
            system.assert(apexData.getChildRelationships('AddressDetail__c').isEmpty());
            
            List<Loop.ExternalData.DataObject> dataObjects = apexData.describeObjects(new List<string>(gd));
            system.assertEquals(1, dataObjects.size());
            for (Loop.ExternalData.DataObject dataObject : dataObjects) {
                system.assert(!dataObject.fields.isEmpty());
            }
            
            Loop.ExternalData.QueryRequestInfo requestInfo = new Loop.ExternalData.QueryRequestInfo();
            requestInfo.RecordId = [Select Id FROM Opportunity_Quote__c LIMIT 1].Id;
            
            Loop.ExternalData.Relationship opps = new Loop.ExternalData.Relationship();
            opps.Name = 'AddressDetail__c';            
            requestInfo.Relationships = new List<Loop.ExternalData.Relationship>{opps};
            Loop.ExternalData.QueryResultSet qrs = apexData.query(requestInfo);            
            system.assertEquals(1, qrs.results.size());
            
            for (Loop.ExternalData.QueryResult queryResult : qrs.results) {
                system.assertEquals(1, queryResult.rows.size());
            }
        }
        Test.stopTest();
    }
    
    @testSetup static void setup() {
        List<Platform_Country__c> platformCountry = new List<Platform_Country__c>();
        platformCountry.add(new Platform_Country__c(name = 'TalabatPlatform', country__c = 'Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name = 'FOCPlatform', country__c = 'Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
        UnitTestDataFactory.getRecordtypeValues();
    }
    
    static void setupUserData(User u) {
        System.runAs(u) {
            //Inserting country
            Country__c HKCoutry = UnitTestDataFactory.createCountry('HK','Hong Kong', 'HKD');
            insert HKCoutry;
            
            //INserting account
            Account fpAcc = UnitTestDataFactory.createAccount('test',HKCoutry,'FP_Account');
            fpAcc.phone = '+85278273613';
            insert fpAcc;
            
            //Inserting Opp
            Opportunity opp = UnitTestDataFactory.createOpportunity('test',fpAcc,'FP_Opportunity', Date.today());
            opp.Company_Code__c = 'HK';
            opp.Business_Type__c = 'Upgrade/Upsell';
            opp.Type = 'Product Only';
            insert opp;
            
            //Inserting address
            Integration_Config__c cs1 = new Integration_Config__c(
                Name = 'GoogleMapsSignature', Password__c = 'Abvcd-asdfdgfhjklhnO0=');
            insert cs1;
            
            AddressDetail__c addr = new AddressDetail__c(
                Type__c = 'Billing Address;Restaurant Address',
                LatLng__Longitude__s = 10.0,
                LatLng__Latitude__s = 5.0,
                Account__c = fpAcc.Id,
                
                GPA_Country_long_name__c = 'Ecuador',
                GPA_Country_short_name__c = 'EC',
                
                GPA_Admin_area_level_1_long_name__c = 'admin area 1 test',
                GPA_Admin_area_level_1_short_name__c = 'aat1',
                
                GPA_Locality_long_name__c = 'locality',
                GPA_Locality_short_name__c = 'lco',
                
                GPA_Route_long_name__c = 'street name',
                GPA_Route_short_name__c = 'str',
                
                GPA_Street_number_long_name__c = '10',
                GPA_Street_number_short_name__c = '10',
                
                GPA_Postal_code_long_name__c = '1010',
                GPA_Postal_code_short_name__c = '1010',
                
                GPA_Place_id__c = '12344',
                GPA_formatted_address__c = 'whatever bla bla',
                GPA_Was_modified_manually__c = false
            );
            
            insert addr;
            
            //Inserting Opp quote
            Opportunity_Quote__c  oq = new Opportunity_Quote__c();
            oq.Id_Opportunity__c = opp.Id;
            insert oq;   
        }
    }
}
