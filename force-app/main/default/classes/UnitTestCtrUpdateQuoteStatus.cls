/*
@author : Magesh Mani Yadav
@reviewer : 
@creation : 23.09.2014
*/
@isTest
private class UnitTestCtrUpdateQuoteStatus {
    static User runningUser = UnitTestDataFactory.createUser('Yogiyo Sales Team','testUser@deliveryherotest.com','Yogiyo','KR');
    static void testData(){
         List<Platform_Country__c> platformCountry =new List<Platform_Country__c>(); 
        platformCountry.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name='FOCPlatform', country__c='Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
        UnitTestDataFactory.getRecordtypeValues();
        UnitTestDataFactory.testDataForYogiyoContractProcess();
        Country__c c = [select id,iso__c,name from Country__c where name='Korea'];
        Opportunity opp = [select id,StageName from Opportunity where name='TestOpp123'];
        Opportunity_Quote__c oppQuote = [select id,Url_Key__c,key__c,status__c from Opportunity_Quote__c where Id_Opportunity__c=:opp.id];

        Blob cryptoKey = Crypto.generateAesKey(256);
        Business_Config__c b1 =  UnitTestDataFactory.createBusinessConfig('Quote is won process', 'Trigger',null,null, c.id, null, true, true);
        Business_Config__c b2 = UnitTestDataFactory.createBusinessConfig('Quote Accept Process', 'Process','set opportunity stage','100% Closed', c.id, 'Yogiyo_Opportunity', true, true);
        insert new List<sObject>{b1,b2};
        String urlKey = LibScarfaceCryptor.encrypt(oppQuote.id,cryptoKey);
        oppQuote.Url_Key__c = urlKey;
        oppQuote.status__c ='Waiting for Answer';
        oppQuote.key__c = EncodingUtil.base64Encode(cryptoKey);
        update oppQuote;
        
    }
    
    @isTest static void test_method_one() {
        // Implement test code
        testData();
        list<Opportunity_Quote__c> listOppQuote = [select id,key__c,url_key__c from Opportunity_Quote__c where status__c='Waiting for Answer'];
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.QuoteStatus')); 
        System.currentPageReference().getParameters().put('key',listOppQuote[0].url_key__c);
        CtrUpdateQuoteStatus testObj = new CtrUpdateQuoteStatus(); 
        testObj.acceptQuote();
        testObj = new CtrUpdateQuoteStatus();
        //testObj.declineQuote();
        Test.stopTest();
        System.assertEquals(testObj.oppQuote.status__c,'Accepted');
    }
    
    @isTest static void test_method_two() {
        testData();
        list<Opportunity_Quote__c> listOppQuote = [select id,key__c,url_key__c from Opportunity_Quote__c where status__c='Waiting for Answer'];
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.QuoteStatus')); 
        System.currentPageReference().getParameters().put('key',listOppQuote[0].url_key__c);
        CtrUpdateQuoteStatus testObj = new CtrUpdateQuoteStatus(); 
        testObj.declineQuote();
        Test.stopTest();
        System.assertEquals(testObj.oppQuote.status__c,'Declined');
    }

    @isTest static void test_method_Negative() {
        testData();
        list<Opportunity_Quote__c> listOppQuote = [select id,key__c,url_key__c from Opportunity_Quote__c where status__c='Waiting for Answer'];
        Test.startTest();
        listOppQuote[0].url_key__c = 'hhhh';
        Test.setCurrentPageReference(new PageReference('Page.QuoteStatus')); 
        System.currentPageReference().getParameters().put('key',listOppQuote[0].url_key__c);
        CtrUpdateQuoteStatus testObj = new CtrUpdateQuoteStatus();
        Test.stopTest(); 
        System.assertEquals(testObj.oppQuote,null);
    }

    @isTest static void test_method_Negative_two() {
        testData();
        list<Opportunity_Quote__c> listOppQuote = [select id,key__c,url_key__c from Opportunity_Quote__c where status__c='Waiting for Answer'];
        Test.startTest();
        listOppQuote[0].url_key__c = '';
        Test.setCurrentPageReference(new PageReference('Page.QuoteStatus')); 
        System.currentPageReference().getParameters().put('key',listOppQuote[0].url_key__c);
        CtrUpdateQuoteStatus testObj = new CtrUpdateQuoteStatus();
        Test.stopTest(); 
        System.assertEquals(testObj.oppQuote,null);
    }
}