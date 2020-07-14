@isTest
private class UnitTestBatchAdditionalChargeStartDate {

    @TestSetup
    static void setup() {
        UnitTestDataFactory.getRecordtypeValues();

        Country__c ec = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
        insert ec;

        Account acc = UnitTestDataFactory.createAccount('test', ec, 'CD_Account');
        insert acc;

        Opportunity opp = UnitTestDataFactory.createOpportunity('with close date', acc, 'CD_Opportunity', Date.today());

        insert new List<Opportunity>{
                opp
        };

        List<Additional_Charges__c> toCreate = new List<Additional_Charges__c>();

        toCreate.add(new Additional_Charges__c(
                Id_Account__c = acc.Id,
                Id_Opportunity__c = opp.Id
        ));

        insert toCreate;
    }

    @isTest static void batgchExecuteCorrectly() {
        Opportunity oppWithCloseDate = [SELECT CloseDate FROM Opportunity Where Name = 'with close date' limit 1];

        Test.startTest();

        Database.executeBatch(new BatchAdditionalChargeStartDate());

        Test.stopTest();

        Additional_Charges__c withCloseDate = [SELECT Start_Date__c FROM Additional_Charges__c WHERE Id_Opportunity__r.Name = 'with close date' LIMIT 1];

        System.assertEquals(oppWithCloseDate.CloseDate, withCloseDate.Start_Date__c);
    }
}