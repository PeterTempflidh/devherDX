/***
* @description test class for MultiSelectLookUp_AuraController class
* @date 24.06.2020
* @author Danish Farooq
   */

@IsTest
private class MultiSelectLookUp_AuraControllerTest {
    @testSetup
    static void setup(){

        UnitTestDataFactory.getRecordtypeValues();
        Country__c country = UnitTestDataFactory.createCountry('MY', 'Malaysia', 'MYR');
        insert country;

        Company__c company = UnitTestDataFactory.createCompany('FP', 'FP', country);
        insert company;

        List<Account> lstAccounts = UnitTestDataFactory.createAccounts(1, country, 'FP_Account');

        for(Account iAccount : lstAccounts){
            iAccount.phone = '+6023456789';
            iAccount.CurrencyIsoCode = 'MYR';
            iAccount.Account_status__c = 'Active';
            iAccount.Vertical__c = 'Restaurant';
            iAccount.Vertical_Segment__c = 'Regular Restaurant';
            iAccount.Category__c = 'Asian';
            iAccount.Name = 'testAccount_Test';
        }
        insert lstAccounts;

        List<Contact> lstContact = UnitTestDataFactory.createContacts(lstAccounts,'FirstName','Last Name','MR','owner',1,'test',Constants.FP_CONTACT_DEVELOPERNAME);
        insert lstContact;

    }

    @IsTest
    static void testSearchLookUp() {

        MultiSelectLookUp_AuraController.ParametersWrapper paramObj = new MultiSelectLookUp_AuraController.ParametersWrapper();
        MultiSelectLookUp_AuraController multiSelectCtrlObj = new MultiSelectLookUp_AuraController();
        multiSelectCtrlObj.searchKeyWord = 'last Name';
        multiSelectCtrlObj.objectName = 'Contact';
        multiSelectCtrlObj.fieldToQuery = 'Email';
        multiSelectCtrlObj.excludedItemLst = new List<sObject>();

        paramObj.searchKeyWord = multiSelectCtrlObj.searchKeyWord;
        paramObj.objectName =  multiSelectCtrlObj.objectName;
        paramObj.fieldToQuery =multiSelectCtrlObj.fieldToQuery ;

        MultiSelectLookUp_AuraController.ExcludedItemWrapper excludedItemWrapperObj = new MultiSelectLookUp_AuraController.ExcludedItemWrapper();
        excludedItemWrapperObj.id = '000';
        excludedItemWrapperObj.name = 'test Name';
        excludedItemWrapperObj.email = 'test Email';
        paramObj.excludedItemLst = new List<MultiSelectLookUp_AuraController.ExcludedItemWrapper> { excludedItemWrapperObj };

        string jsonString = JSON.serialize(paramObj);

        test.startTest();
        List<sObject> lstReturnedObjects = MultiSelectLookUp_AuraController.fetchLookUpValues(jsonString);
        test.stopTest();

        system.assertNotEquals(lstReturnedObjects.size(),0);
    }
}