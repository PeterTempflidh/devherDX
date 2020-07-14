/**
 * @description [Test class for ContactSelector]
 * Created by Sarfaraz.Ahmed on 06/07/2020.
 */
@isTest
public class ContactSelectorTest {

    @testSetup static void setup() {

        UnitTestDataFactory.getRecordtypeValues();

        Country__c uaeCountry = UnitTestDataFactory.createCountry('AE','United Arab Emirates', 'AED');
        insert uaeCountry;
        Company__c comUAE = UnitTestDataFactory.createCompany('Talabat UAE', 'Talabat', uaeCountry);
        insert comUAE;

        Account uaeAccount = UnitTestDataFactory.createAccount('test',uaeCountry,Constants.ACCOUNT_RT_TALABAT_ACCOUNT);
        uaeAccount.phone = '+85278273613';
        insert uaeAccount;

        Account uaeAccount1 = UnitTestDataFactory.createAccount('test1',uaeCountry,Constants.ACCOUNT_RT_TALABAT_ACCOUNT);
        uaeAccount1.phone = '+85278273613';
        insert uaeAccount1;

        List<Contact> listContact;
        listContact = UnitTestDataFactory.CreateContacts(new List<Account>{uaeAccount}, 'Best', 'Burger', 'Mr', 'Employee', 2, 'test', Constants.CONTACT_RT_TALABAT_DEVELOPERNAME);
        listContact[0].Contact_Role__c='Owner';
        listContact[0].Passport_ID_Number__c='111';
        listContact[0].Email='test@test.com';
        listContact[1].Contact_Role__c='Manager';
        listContact[1].AccountId=uaeAccount1.id;
        insert listContact;

    }
    /**
    * @method name  : testOwnerQueries
    * @description  : Test method of the getAccountOwnerInformation, getNonPrimaryContactListForAccount,getByEmailAndAccountGrid and fetchContactsWithOwnerRole
    */
    private static testMethod void testOwnerQueries() {

        Contact contactObj =[select id,AccountId,Email,Account.GRID__c,Contact_Role__c from Contact where Contact_Role__c=:Constants.CONTACT_CONTACTROLE_OWNER limit 1];
        if(contactObj!=null){
            Test.startTest();
            List<Contact> contList = new List<Contact>();
            ContactSelector.getAccountOwnerInformation(contactObj.AccountId);
            ContactSelector.getNonPrimaryContactListForAccount(contactObj.AccountId,contactObj.Email);
            contList = ContactSelector.fetchContactsWithOwnerRole(new Set<Id>{contactObj.AccountId});
            ContactSelector.getByEmailAndAccountGrid(contactObj.Email,contactObj.Account.GRID__c);
            Test.stopTest();
            System.assert(!contList.isEmpty());
        }
    }
    /**
    * @method name  : testNonOwnerQueries
    * @description  : Test method of the getAccountOwnerInformation
    */
    private static testMethod void testNonOwnerQueries() {
        Contact contactObj =[select id,AccountId,Email,Account.GRID__c,Contact_Role__c from Contact where Contact_Role__c!=:Constants.CONTACT_CONTACTROLE_OWNER limit 1];
        if(contactObj!=null){
            Test.startTest();
            ContactSelector.getAccountOwnerInformation(contactObj.AccountId);
            Test.stopTest();
            System.assert(contactObj.Contact_Role__c!=null);
        }

    }
}
