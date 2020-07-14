/**
* @author Sudhakar Ch
* @date 09/01/2020
* @description Class is the test class for 'GetAccountDataForNintex.cls'
* This class is build as for recomendations of Nintex documentation can be find here : https://help.nintex.com/en-us/docgen/docservices/#docgen-sfdc/Services/manageDDP/RelationshipApexData.htm%3FTocPath%3DUse%2520advanced%2520techniques%7CRelationships%7C_____5
*/
@istest
public with sharing class GetAccountDataForNintexTest {
    
    private static testMethod void testApexData() {
        User testUser = UnitTestDataFactory.createUser('FP Sales Team', 'unittestUser@deliveryhero.com', 'Foodpanda', 'HK');
        // Create apex data class instance
        GetAccountDataForNintex apexData = new GetAccountDataForNintex();
        
        Test.startTest();
        System.runAs(testUser) {
            setupUserData(testUser);
            
            Set<string> gd = apexData.getGlobalDescribe();
            system.assertEquals(1, gd.size());
            
            system.assert(apexData.getChildRelationships('Account').isEmpty());
            
            List<Loop.ExternalData.DataObject> dataObjects = apexData.describeObjects(new List<string>(gd));
            system.assertEquals(1, dataObjects.size());
            for (Loop.ExternalData.DataObject dataObject : dataObjects) {
                system.assert(!dataObject.fields.isEmpty());
            }
            
            Loop.ExternalData.QueryRequestInfo requestInfo = new Loop.ExternalData.QueryRequestInfo();
            requestInfo.RecordId = [Select Id FROM Opportunity_Quote__c LIMIT 1].Id;
            
            Loop.ExternalData.Relationship opps = new Loop.ExternalData.Relationship();
            opps.Name = 'Account';            
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
            
            
            //Inserting Opp quote
            Opportunity_Quote__c  oq = new Opportunity_Quote__c();
            oq.Id_Opportunity__c = opp.Id;
            oq.Id_Account__c = fpAcc.Id;
            insert oq;   
        }
    }
}