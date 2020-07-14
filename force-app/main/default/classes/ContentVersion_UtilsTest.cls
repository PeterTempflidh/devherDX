@isTest
private class ContentVersion_UtilsTest {

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
        acc.Halal_Certificate_Expiry_Date__c = Date.today();
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
    static void testcheckDuplicateFilesOnQuote(){
        Boolean insertFailed;
        ContentVersion cv = new ContentVersion(Title = 'Contract - OQ-12345.pdf',
                                                VersionData = Blob.valueOf('Content Test'),
                                                PathOnClient = 'testpath',
                                                IsMajorVersion = true
        );
        ContentVersion cv2 = new ContentVersion(Title = 'Contract - OQ-12345.pdf',
                                                VersionData = Blob.valueOf('Content Test'),
                                                PathOnClient = 'testpath',
                                                IsMajorVersion = true
        );
        
        Test.startTest();
            insert cv;
        try{
            insertFailed = false;
            insert cv2;
        }
        catch(Exception e){
            insertFailed = true;
            System.debug(e);
            System.assertEquals(e.getMessage().contains(System.Label.duplicateFileNameError+' Contract - OQ-12345.pdf'),true);
        }
        System.assertEquals(insertFailed, true);
        	
        Test.stopTest();

    }

    @isTest 
    static void testUpdateAttachmentTypeNewContentVersionInserted(){
        ContentVersion cv = new ContentVersion(Title = 'TestTitleNewVersion',
                                                VersionData = Blob.valueOf('Content Test'),
                                                PathOnClient = 'testpath',
                                                ContentDocumentId = docId
        );
        Test.startTest();
            insert cv;
        Test.stopTest();
        List<ContentVersion> cvAfterTrigger = [SELECT Id, Attachment_Type__c FROM ContentVersion WHERE IsLatest = true LIMIT 1];
        System.assertEquals(attType, cvAfterTrigger[0].Attachment_Type__c);
    }

    @isTest 
    static void testUpdateContentVersionWithNewHalalDate(){
        Date halalDate = Date.today().addDays(-10);
        ContentVersion cv = new ContentVersion(Title = 'TestTitleNewVersion',
                                                VersionData = Blob.valueOf('Content Test'),
                                                PathOnClient = 'testpath',
                                                ContentDocumentId = docId,
                                                Halal_Certificate_Expiry_Date__c = halalDate
        );
        insert cv;
        Test.startTest();
            List<ContentVersion> cvAfterTrigger = [SELECT Id, Attachment_Type__c, Halal_Certificate_Expiry_Date__c FROM ContentVersion WHERE Title = 'TestTitleNewVersion' AND IsLatest = true LIMIT 1];
            Date testDate = Date.today().addDays(10);
            cvAfterTrigger[0].Halal_Certificate_Expiry_Date__c = testDate;
            update cvAfterTrigger[0];
        Test.stopTest();
    }

   @isTest 
    static void testUpdateContentVersionWithNewHalalDateOnOpportunity(){
        Date halalDate = Date.today().addDays(-10);
        ContentVersion cv = new ContentVersion(Title = 'TestOnOpp',
                                                Attachment_Type__c = attType,
                                                VersionData = Blob.valueOf('Content Test'),
                                                PathOnClient = 'testpath',
                                                IsMajorVersion = true,
                                                Halal_Certificate_Expiry_Date__c = halalDate
        );
        insert cv;
        List<ContentVersion> contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'TestOnOpp' AND IsLatest = true LIMIT 1];
        Id docIdopp = contentVersion[0].ContentDocumentId;
        cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = opp.Id;
        cdl.ContentDocumentId = docIdopp;
        cdl.ShareType = 'V';
        insert cdl;

        Test.startTest();
            Date testDate = Date.today().addDays(20);
            contentVersion[0].Halal_Certificate_Expiry_Date__c = testDate;
            update contentVersion[0];
        Test.stopTest();
    }

   @isTest 
    static void testUpdateContentVersionWithNewHalalDateOnContact(){

        List<Contact> lstCont = UnitTestDataFactory.createContacts(new List<Account>{acc}, 'testLastName', 'testfirstName', 'Mr.', 'Owner', 1, 'testemail', 'Yogiyo_Contact');
        insert lstCont;

        Date halalDate = Date.today().addDays(-10);
        ContentVersion cv = new ContentVersion(Title = 'TestOnContact',
                                                Attachment_Type__c = attType,
                                                VersionData = Blob.valueOf('Content Test'),
                                                PathOnClient = 'testpath',
                                                IsMajorVersion = true,
                                                Halal_Certificate_Expiry_Date__c = halalDate
        );
        insert cv;
        List<ContentVersion> contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'TestOnContact' AND IsLatest = true LIMIT 1];
        Id docIdcontact = contentVersion[0].ContentDocumentId;
        cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = lstCont[0].Id;
        cdl.ContentDocumentId = docIdcontact;
        cdl.ShareType = 'V';
        insert cdl;

        Test.startTest();
            Date testDate = Date.today().addDays(30);
            contentVersion[0].Halal_Certificate_Expiry_Date__c = testDate;
            update contentVersion[0];
        Test.stopTest();
    }

}
