/*
@author : Alexander Faust
@reviewer : 
@creation : 01.12.2015
*/
@isTest
private class UnitTestCtrLeadCreate {
    private static User testUser;
    static {
        UnitTestDataFactory.getRecordtypeValues();
        testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'yogiyotestuser@deliveryhero.com', 'Yogiyo','KR');
        insert testUser;
    }
    
     static testmethod void testInit() {
        Lead testLead = new Lead();
        CtrLeadCreate cstCtrl;
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testLead);

        Test.startTest();
        System.runAs(testUser){
            cstCtrl = new CtrLeadCreate(stdCtrl);   
        }
        Test.stopTest();

        System.assertEquals(cstCtrl.leadObj.OwnerId,testUser.Id);
        //NO "isDouble" method?
        System.assert(cstCtrl.leadObj.Generated_Menu_Number__c != null);
        



    }
    
    static testmethod void testSave() {
        Lead testLead = new Lead();
        CtrLeadCreate cstCtrl;
        PageReference returnRef;
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testLead);

        Test.startTest();
        System.runAs(testUser){
            cstCtrl = new CtrLeadCreate(stdCtrl);

            //filling the mandatory fields
            cstCtrl.leadObj.Company = 'MyTestCompany';
            cstCtrl.leadObj.Restaurant_Name__c = 'My Test Restaurant';
            cstCtrl.leadObj.LastName = 'Test';
            cstCtrl.leadObj.CurrencyIsoCode = 'KRW';
            returnRef = cstCtrl.save();

        }
        Test.stopTest();

        List<Lead> listResult = [SELECT Id FROM Lead WHERE Company = 'MyTestCompany'];

        System.assertEquals(listResult.size(),1);
        System.assertEquals(returnRef.getUrl(),'/'+listResult[0].Id);
    }

    static testmethod void testSaveAndNew() {
        Lead testLead = new Lead();
        CtrLeadCreate cstCtrl;
        PageReference returnRef;
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testLead);

        Test.startTest();
        System.runAs(testUser){
            cstCtrl = new CtrLeadCreate(stdCtrl);

            //filling the mandatory fields
            cstCtrl.leadObj.Company = 'MyTestCompany';
            cstCtrl.leadObj.Restaurant_Name__c = 'My Test Restaurant';
            cstCtrl.leadObj.LastName = 'Test';
            cstCtrl.leadObj.CurrencyIsoCode = 'KRW';
            returnRef = cstCtrl.saveAndNew();

        }
        Test.stopTest();

        List<Lead> listResult = [SELECT Id FROM Lead WHERE Company = 'MyTestCompany'];

        System.assertEquals(listResult.size(),1);
        System.assertEquals(returnRef.getUrl(),'/apex/LeadCreate');
    }

    static testmethod void testCancel(){
        Lead testLead = new Lead();
        CtrLeadCreate cstCtrl;
        PageReference returnRef;
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testLead);

        Test.startTest();
        System.runAs(testUser){
            cstCtrl = new CtrLeadCreate(stdCtrl);
            returnRef = cstCtrl.cancel();

        }
        Test.stopTest();

        List<Lead> listResult = [SELECT Id FROM Lead WHERE Company = 'MyTestCompany'];

        System.assertEquals(listResult.size(),0);
        System.assertEquals(returnRef.getUrl(),'/00Q/o');

    }
    
}