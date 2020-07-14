/**
* @author Mantas Jurkunas
* @date 28.04.20
*
* @description Unit Test class for DocuSignSystemActions_Batch.
*/
@IsTest
private class DocusignSystemActions_Test {

    @TestSetup
    private static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c country = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        insert country;

        Business_Config__c systemConfig0 = UnitTestDataFactory.createBusinessConfig('DocuSignSystemActions', 'Process', 'SentTask',
                '{' +
                        '"Subject":"Call: Follow-up on contract signature",' +
                        '"Status":"Not Started",' +
                        '"Comments__c":"The customer has not opened the contract couple of days. Please follow up about any concerns.",'+
                        '"Type":"Call",' +
                        '"Priority":"Normal"' +
                        '}', country.Id, 'Yogiyo_Opportunity_Quote', true, true);
        Business_Config__c systemConfig1 = UnitTestDataFactory.createBusinessConfig('DocuSignSystemActions', 'Process', 'DeliveredTask',
                '{' +
                        '"Subject":"Call: Follow-up on contract signature",' +
                        '"Status":"Not Started",' +
                        '"Comments__c":"The customer has viewed the contract without taking action. Please follow up about any concerns.",'+
                        '"Type":"Call",' +
                        '"Priority":"Normal"' +
                        '}', country.Id, 'Yogiyo_Opportunity_Quote', true, false);
        Business_Config__c systemConfig2 = UnitTestDataFactory.createBusinessConfig('DocuSignSystemActions', 'Process', 'ViewedAge', '1', country.Id, 'Yogiyo_Opportunity_Quote', true, false);
        Business_Config__c systemConfig4 = UnitTestDataFactory.createBusinessConfig('DocuSignSystemActions', 'Process', 'ViewedAge', '1', country.Id, 'Talabat_Opportunity_Quote', true, true);
        Business_Config__c systemConfig5 = UnitTestDataFactory.createBusinessConfig('DocuSignSystemActions', 'Process', 'SentAge', '3', country.Id, 'Talabat_Opportunity_Quote', true, false);
        Business_Config__c systemConfig6 = UnitTestDataFactory.createBusinessConfig('DocuSignSystemActions', 'Process', 'ViewedAge', '1', country.Id, 'FP_Opportunity_Quote', true, true);
        Business_Config__c systemConfig7 = UnitTestDataFactory.createBusinessConfig('DocuSignSystemActions', 'Process', 'SentAge', '3', country.Id, 'FP_Opportunity_Quote', true, false);

        insert new List<Business_Config__c> {systemConfig0, systemConfig1, systemConfig2,
                                            systemConfig4, systemConfig5, systemConfig6, systemConfig7};

        Company__c company = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', country);
        insert company;

        List<List_Product_Group__c> productGroups = UnitTestDataFactory.createProductGroups(company, country, 10, 'Yogiyo_List_Product_Group');
        List<Account> accounts = UnitTestDataFactory.createAccounts(1, country, 'Yogiyo_Account');

        List<SObject> objectsToInsert = new List<SObject>();
        objectsToInsert.addAll((List<SObject>)productGroups);
        objectsToInsert.addAll((List<SObject>)accounts);
        insert objectsToInsert;

        List<List_Product_Price__c> products = UnitTestDataFactory.createProducts(company, country, productGroups[0].Id, 10, 'Yogiyo_List_Product_Price', 1, true, 299, 1, true, 10);
        List<Opportunity> opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'Yogiyo_Opportunity', Date.today().addMonths(2));
        opportunities.get(0).LeadSource = 'Inbound';
        List<SObject> objectsToInsert1 = new List<SObject>();
        objectsToInsert1.addAll((List<SObject>)products);
        objectsToInsert1.addAll((List<SObject>)opportunities);
        insert objectsToInsert1;

        List<Opportunity_Quote__c> quotes = UnitTestDataFactory.createOpportunityQuotes(opportunities[0], 2, 'Yogiyo_Opportunity_Quote', 'draft', 'TEST', 100, 100, 'Test', 'Test', 10);
        insert quotes;

        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c();
        ds.Opportunity_Quote__c = quotes[0].Id;
        ds.dsfs__Envelope_Status__c = DocusignSystemActions_Utils.ENVELOPE_SENT;
        ds.dsfs__Sent_Date_Time__c = Date.today().addDays(-3);

        dsfs__DocuSign_Status__c ds1 = new dsfs__DocuSign_Status__c();
        ds1.Opportunity_Quote__c = quotes[0].Id;
        ds1.dsfs__Envelope_Status__c = DocusignSystemActions_Utils.ENVELOPE_DELIVERED;
        ds1.dsfs__Sent_Date_Time__c = Date.today().addDays(-3);

        dsfs__DocuSign_Status__c ds2 = new dsfs__DocuSign_Status__c();
        ds2.Opportunity_Quote__c = quotes[0].Id;
        ds2.dsfs__Envelope_Status__c = DocusignSystemActions_Utils.ENVELOPE_DELIVERED;
        ds2.dsfs__Sent_Date_Time__c = Date.today().addDays(-3);
        // workaround for duplication error
        insert ds;
        insert ds1;
        insert ds2;

        //Dynamic insert of age to BC because the value varies based on time of day
        ds = DocuSignStatus_Selector.getDocuSignStatusbyIds(new List<dsfs__DocuSign_Status__c> {ds})[0];
        Business_Config__c systemConfig3 = UnitTestDataFactory.createBusinessConfig('DocuSignSystemActions', 'Process', 'SentAge', String.valueOf(ds.dsfs__Sent_Age__c), country.Id, 'Yogiyo_Opportunity_Quote', true, false);
        insert systemConfig3;

        dsfs__DocuSign_Recipient_Status__c docuSignRecipientStatus = new dsfs__DocuSign_Recipient_Status__c();
        docuSignRecipientStatus.dsfs__Parent_Status_Record__c = ds2.Id;
        docuSignRecipientStatus.dsfs__Date_Delivered__c = Date.today().addDays(-1);
        docuSignRecipientStatus.dsfs__DocuSign_Recipient_Id__c = '123';
        docuSignRecipientStatus.dsfs__DocuSign_Recipient_Email__c = 'eugene.h.krabs@bikinibottom.com';

        dsfs__DocuSign_Recipient_Status__c docuSignRecipientStatus2 = new dsfs__DocuSign_Recipient_Status__c();
        docuSignRecipientStatus2.dsfs__Parent_Status_Record__c = ds1.Id;
        docuSignRecipientStatus2.dsfs__Date_Delivered__c = Date.today().addDays(-1);
        docuSignRecipientStatus2.dsfs__DocuSign_Recipient_Id__c = '123';
        docuSignRecipientStatus2.dsfs__DocuSign_Recipient_Email__c = UserInfo.getUserEmail();
        insert new List<dsfs__DocuSign_Recipient_Status__c>{docuSignRecipientStatus, docuSignRecipientStatus2};

    }

    @IsTest
    static void testDocusignSytemActions() {
        Test.startTest();
         Database.executeBatch(new DocusignSystemActions_Batch());
        Test.stopTest();

        List<Task> tasks = ActivitySelector.getAll();
        System.assertEquals(2, tasks.size());
        //Coverage only execution, functionality is tested above
        DocusignSystemActions_Batch.schedule('0 0 22 * * ? *');
    }

    @IsTest
    static void testDocusignSytemActionsNoBc() {
        delete [SELECT Id FROM Business_Config__c];
        Test.startTest();
        Database.executeBatch(new DocusignSystemActions_Batch());
        Test.stopTest();

        List<Task> tasks = ActivitySelector.getAll();
        System.assertEquals(0, tasks.size());
    }
}