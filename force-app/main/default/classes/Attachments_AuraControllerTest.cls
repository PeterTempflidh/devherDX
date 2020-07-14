@isTest
private class Attachments_AuraControllerTest {
    
    private static Opportunity opp;
    private static Account acc;
    private static Case testCase;
    private static Country__c c;
    private static Company__c com;
    private static String attType;
    private static String docId;
    private static ContentDocumentLink cdl;
    private static List<String> lstAttTypes = new List<String>();
   
    static {
        UnitTestDataFactory.getRecordtypeValues();
        c = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        insert c;
        com = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', c);
        insert com;
        acc = UnitTestDataFactory.createAccount('TestAccount', c, 'Yogiyo_Account');
        insert acc;
        opp = UnitTestDataFactory.createOpportunity('TestOpp123', acc, 'Yogiyo_Opportunity', Date.today());
        insert opp;

        Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Case'});
        testCase = new Case(Opportunity__c = opp.id, type = 'Quality Check', AccountId = opp.AccountId, RecordTypeId = mapRecordtypes.get('Yogiyo_Internal_Case').id);
        insert testCase;

        
        Schema.DescribeFieldResult fieldResult = ContentVersion.Attachment_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry plVal : ple){
            lstAttTypes.add(plVal.getLabel());
        }
        attType = lstAttTypes[0];
        ContentVersion cv = new ContentVersion(Title = 'TestTitle',
                                                Attachment_Type__c = attType,
                                                VersionData = Blob.valueOf('Content Test'),
                                                PathOnClient = 'testpath',
                                                IsMajorVersion = true
        );
        insert cv;

        List<ContentVersion> contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        docId = contentVersion[0].ContentDocumentId;
        cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = testCase.Id;
        cdl.ContentDocumentId = docId;
        cdl.ShareType = 'V';
        insert cdl;
    }

    @isTest
    static void testGetAttachments(){
        List<Case> c = [SELECT Id FROM Case Limit 1];

        Test.startTest();
            List<Attachments_AuraController.attWrapper> lstWrapper = Attachments_AuraController.getAttachments(c[0].Id);
        Test.stopTest();
        System.assertEquals('TestTitle', lstWrapper[0].title);
        System.assertEquals(attType, lstWrapper[0].attachmenttype);
        System.assertEquals(docId, lstWrapper[0].contentdocumentid);
    }

    @isTest
    static void testGetAttTypePicklistValues(){
        Test.startTest();
            List<String> lstAttTypesFromMethod = Attachments_AuraController.getAttTypePicklistValues();
        Test.stopTest();
        System.assertEquals(lstAttTypes.size(), lstAttTypesFromMethod.size());
    }

     @isTest
    static void testDeleteFile(){

        Test.startTest();
            Attachments_AuraController.deleteFile(new List<String>{docId});
        Test.stopTest();
        Integer contentVersion = [SELECT count() FROM ContentVersion];
        System.assertEquals(0, contentVersion);
    }

    @isTest
    static void testSaveFileSaveOtherThanAccount(){
        String mapString = '[{"docId": "' + docId + '","lstAtt":["' + lstAttTypes[1] + '"],"halalDate":null,"halalBolean":false,"name":"testname"}]';
        Test.startTest();
            Attachments_AuraController.saveFile(testCase.Id, new List<String>{docId}, mapString);
        Test.stopTest();
            List<ContentVersion> lstcv = [SELECT Id, Attachment_Type__c FROM ContentVersion];
        System.assertEquals(lstAttTypes[1], lstcv[0].Attachment_Type__c);
    }

    @isTest
    static void testSaveFileSaveOnAccount(){
        ContentDocumentLink cdlAcc = new ContentDocumentLink();
        cdlAcc.LinkedEntityId = acc.Id;
        cdlAcc.ContentDocumentId = docId;
        cdlAcc.ShareType = 'V';
        insert cdlAcc;

        String mapString = '[{"docId": "' + docId + '","lstAtt":["' + lstAttTypes[1] + '"],"halalDate":null,"halalBolean":false,"name":"testname"}]';
        Test.startTest();
            Attachments_AuraController.saveFile(acc.Id, new List<String>{docId}, mapString);
        Test.stopTest();
        List<ContentVersion> lstcv = [SELECT Id, Attachment_Type__c FROM ContentVersion];
        System.assertEquals(lstAttTypes[1], lstcv[0].Attachment_Type__c);
    }

    @isTest
    static void testGetAttachmentNotFile(){
        List<Case> c = [SELECT Id FROM Case Limit 1];
        List<ContentDocument> lstDoc = [SELECT Id FROM ContentDocument WHERE Id = :docId];
        delete lstDoc;
        Attachment att = new Attachment(Name = 'testAtt',
                                        body = Blob.valueOf('unit test att body'),
                                        parentId = c[0].Id);
        insert att;
        Test.startTest();
            List<Attachments_AuraController.attWrapper> lstWrapper = Attachments_AuraController.getAttachments(c[0].Id);
        Test.stopTest();
        System.assertEquals('testAtt', lstWrapper[0].title);
        System.assertEquals('Attachment', lstWrapper[0].fielextension);
        System.assertEquals(att.Id, lstWrapper[0].contentdocumentid);
    }
}