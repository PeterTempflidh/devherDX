/**
 * Created by a.onatra on 29.03.20.
 */

@isTest
public class dh_CustomPicklist_WebControllerTest {

    @TestSetup
    public static void testSetup(){

    }

    @IsTest
    public static void test(){
        
		UnitTestDataFactory.getRecordtypeValues();
        Country__c c = UnitTestDataFactory.createCountry('DE','Germany', 'EUR');
        Company__c com = UnitTestDataFactory.createCompany('testcompany', 'DE', c);
        User ccTestUser = UnitTestDataFactory.createUser('DE Customer Care', 'escalationtestuser@deliveryhero.com', 'DH_AU','AU');
        insert new List<sObject> { c,com,ccTestUser };

        List<Account> accList = UnitTestDataFactory.createAccounts(1,c,'DE_Account');
        insert accList;

		String jsonInput ='{"pickListConfiguration":{"pickListApiName":"Vertical__c","fieldsToQueryAPIName":"Vertical__c,Vertical_Segment__c,Category__c,Record_Country__c","rules":[{"conditions":[{"attribute":"Record_Country__c","operator":"IN","value":"Hong Kong,Taiwan,Singapore,Malaysia"}],"actions":[{"operator":"show","value":"Shop,Restaurant"}]},{"conditions":[{"attribute":"Record_Country__c","operator":"IN","value":"Laos,Cambodia,Myanmar,Taiwan"}],"actions":[{"operator":"show","value":"Restaurant"}]},{"conditions":[{"attribute":"Record_Country__c","operator":"NOT IN","value":"Laos,Cambodia,Myanmar,Taiwan"}],"actions":[{"operator":"show","value":"Restaurant"}]},{"conditions":[{"attribute":"Record_Country__c","operator":"=","value":"Laos,Cambodia,Myanmar,Taiwan"}],"actions":[{"operator":"show","value":"Restaurant"}]},{"conditions":[{"attribute":"Record_Country__c","operator":"!=","value":"Laos,Cambodia,Myanmar,Taiwan"}],"actions":[{"operator":"show","value":"Restaurant"}]},{"conditions":[{"attribute":"Record_Country__c","operator":"<","value":"Laos,Cambodia,Myanmar,Taiwan"}],"actions":[{"operator":"show","value":"Restaurant"}]}]},"selectedPicklistValues":[],"currentRecordId":"'+accList[0].Id+'","picklistFieldAPIName":"Vertical__c","sObjectName":"Account"}';

        Test.startTest();
		System.assertEquals('{"Vertical__c":[{"validFor":"Restaurant","defaultValue":"Restaurant","active":"Restaurant","label":"Restaurant","value":"Restaurant"}]}', dh_CustomPicklist_WebController.getPicklistValues( jsonInput ),'Rule engine is not returning expected values');
        Test.stopTest();
    }

}