@isTest
public with sharing class ContentVersion_Selector_Test {
    private static Opportunity opp;
    private static Account acc;
    private static Case testCase;
    private static List<Lead> lstLd;
    private static List<Opportunity_Quote__c> lstOppQ;
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
        lstLd = UnitTestDataFactory.createLeads(1, c, 'Test Last Name', 'Yogiyo', 'KRW', 'Test Res Name', 'Yogiyo_Lead');
        insert lstLd;
        lstOppQ = UnitTestDataFactory.createOpportunityQuotes(opp, 1, 'Yogiyo_Opportunity_Quote', 'Accepted', 'Test description', 10.00, 10.00, 'urlKey', 'key', 23.00);
        insert lstOppQ;

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
    static void testAllMethods(){
        Set<Id> recIdSet = new Set<Id>();
        List<Case> allCasesList = CaseSelector.getAll();
        List<Account> allAccsList = AccountSelector.getAll();
        List<Opportunity> allOppList = Opportunity_Selector.getAll();
        
        for(Case cs : allCasesList){
            recIdSet.add(cs.Id);
        }
        
        List<ContentDocumentLink> cdLinkList = COntentVersion_Selector.getContentDocumnetLink(allCasesList[0].Id, 'TestTitle');
        List<String> cdIdList = new List<String>();
        List<String> titlesList = new List<String>();
        Set<Id> cdIdSet = new Set<Id>();
        for(ContentDocumentLink cdl : cdLinkList){
            cdIdList.add(cdl.ContentDocumentId);
            cdIdSet.add(cdl.ContentDocumentId);
            titlesList.add(cdl.ContentDocument.Title);
        }        
        
        COntentVersion_Selector.getContentDocumnetLink(allCasesList[0].Id);
        COntentVersion_Selector.getContentVersion(cdIdList);
        COntentVersion_Selector.getContentDocumnetLinksWithLatestVersionBody(recIdSet);
        COntentVersion_Selector.getObjects(allCasesList[0].Id);
        COntentVersion_Selector.getObjects(allAccsList[0].Id);
        COntentVersion_Selector.getObjects(allOppList[0].Id);
        COntentVersion_Selector.getObjects(lstLd[0].Id);
        COntentVersion_Selector.getObjects(lstOppQ[0].Id);
        COntentVersion_Selector.getAccounts(allAccsList[0].Id);
        COntentVersion_Selector.getContentDocumentLinks(cdIdSet);
        COntentVersion_Selector.getContentDocumentsFromTitles(titlesList);
        System.assertEquals(false, cdLinkList.isEmpty());
    }
}
