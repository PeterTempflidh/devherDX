/*
@author : Magesh Mani Yadav
@reviewer :
@creation : 24.09.2014
*/
@isTest
private class UnitTestCtrOpportunityQuote {

    @testSetup static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
        List<Platform_Country__c> platformCountry = new List<Platform_Country__c>();
        platformCountry.add(new Platform_Country__c(name = 'TalabatPlatform', country__c = 'Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name = 'FOCPlatform', country__c = 'Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
    }

    static testmethod void unitTest_positive() {
        User runningUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'testUser@deliveryhero.com', 'Yogiyo', 'KR');
        Test.startTest();
        System.runAs(runningUser) {
            UnitTestDataFactory.testDataForYogiyoOpportunityProcesses();
            List<Opportunity> listOpp = [select id, RecordType.DeveloperName, Country__c, Record_Country__c, AccountId, recordtypeid, subtotal__c, vat__c, total__c, currencyIsoCode from Opportunity where name like '%TestOpp123%'];

            ApexPages.currentPage().getParameters().put('opportunityId', listOpp[0].Id);
            CtrOpportunityQuote testObject = new CtrOpportunityQuote();

            System.assertEquals(testObject.oppQuote.status__c, 'Draft');
        }
        Test.stopTest();
    }


    static testmethod void unitTest_negative() {
        User runningUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'testUser@deliveryhero.com', 'Yogiyo', 'KR');
        Test.startTest();
        System.runAs(runningUser) {
            UnitTestDataFactory.testDataForYogiyoOpportunityProcesses();
            List<Opportunity> listOpp = [select id, RecordType.DeveloperName, Country__c, Record_Country__c, AccountId, recordtypeid, subtotal__c, vat__c, total__c, currencyIsoCode from Opportunity where name like '%TestOpp123%'];

            ApexPages.currentPage().getParameters().put('opportunityId', listOpp[0].Id);
            CtrOpportunityQuote testObject = new CtrOpportunityQuote();

            //System.assert(testObject.mapExistingServices.isEmpty());
        }
        Test.stopTest();
    }

    /*private static final String currentUserId = UserInfo.getUserId();
    private static final Map<String,RecordType> mapRecordtypesKR = LibRecordTypeHelper.getRecordTypeOnlyForNames(new Set<String>{'KR_Opportunity','KR_Account','KR_Product_Group','KR_Service_Price','KR_List_Product_Price','KR_Opportunity_Quote','KR_Opp_Quote_Product_Item','KR_Opp_Quote_Service_Item','KR_Opportunity_Service_Item','KR_Opportunity_Product_Item'});

    static void testData(){
        EmailTemplate etemp_kr = new  EmailTemplate(Name='KR_template',folderid=currentUserId, developername='KR_template', isActive=true, templateType='Text',
            subject='test KR subject', body='Please find the quote below: showQuoteInformationHere Please click the below link for Accepting or Declining the Quote: linkToBeEmbedded');

            System.runAs ( new User(Id = currentUserId) ) {
                insert etemp_kr;
            }

        Country__c c = new Country__c(Iso__c='KR',Name='Korea');
        insert c;

        Business_Config__c b = new Business_Config__c(Business_Rule_Name__c='OppQuoteRecordTypeid',Business_Rule_Value__c=mapRecordtypesKR.get('KR_Opportunity_Quote').id,Id_Country__c=c.id,Is_Active__c=true,Parent__c=true,Process_Name__c='OppQuoteProcess',Record_Type_Id__c=mapRecordtypesKR.get('KR_Opportunity').id,Type__c='Process');
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='IncludeService',Business_Rule_Value__c='true',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='OppQuoteProcess',Record_Type_Id__c=mapRecordtypesKR.get('KR_Opportunity').id,Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='IncludeProduct',Business_Rule_Value__c='true',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='OppQuoteProcess',Record_Type_Id__c=mapRecordtypesKR.get('KR_Opportunity').id,Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='OppQuoteEmailTemplate',Business_Rule_Value__c=etemp_kr.id,Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='OppQuoteProcess',Record_Type_Id__c=mapRecordtypesKR.get('KR_Opportunity').id,Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='quoteEmailSubject',Business_Rule_Value__c='Quote',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='OppQuoteProcess',Record_Type_Id__c=mapRecordtypesKR.get('KR_Opportunity').id,Type__c='Process');
        //uncomment once orgwide email is set for korea
        //Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='OrgWideEmailAddId',Business_Rule_Value__c=EmailFromAddIdKR.id,Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='OppQuoteProcess',Record_Type_Id__c=mapRecordtypesKR.get('KR_Opportunity').id,Type__c='Process');
        Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c='OppQuoteProductRecordTypeid',Business_Rule_Value__c=mapRecordtypesKR.get('KR_Opp_Quote_Product_Item').id,Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='OppQuoteProcess',Record_Type_Id__c=mapRecordtypesKR.get('KR_Opportunity').id,Type__c='Process');
        Business_Config__c b7 = new Business_Config__c(Business_Rule_Name__c='OppQuoteServiceRecordTypeid',Business_Rule_Value__c=mapRecordtypesKR.get('KR_Opp_Quote_Service_Item').id,Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='OppQuoteProcess',Record_Type_Id__c=mapRecordtypesKR.get('KR_Opportunity').id,Type__c='Process');

        Account acc = new Account(name='TestAccount',recordtypeid=mapRecordtypesKR.get('KR_Account').id);
        Account acc1 = new Account(name='TestAccount1',recordtypeid=mapRecordtypesKR.get('KR_Account').id);

        List_Product_Group__c lpg1 = new List_Product_Group__c(Id_Country__c=c.id,Name='Setup Fee',recordtypeid=mapRecordtypesKR.get('KR_Product_Group').id);

        insert new List<sObject>{b,b1,b2,b3,b4,b6,b7,acc,acc1,lpg1};

        //Contact cont = new Contact(FirstName='test1',LastName='contact1', AccountId=acc.id,email='test1@testing.com');

        Opportunity opp = new Opportunity(name='TestOpp123', recordtypeid=mapRecordtypesKR.get('KR_Opportunity').id,AccountId=acc.id,CloseDate=Date.today(), StageName='Prospecting');
        Opportunity opp1 = new Opportunity(name='TestOpp456', recordtypeid=mapRecordtypesKR.get('KR_Opportunity').id,AccountId=acc1.id,CloseDate=Date.today(), StageName='Prospecting');
        List_Service_Price__c lsp2 = new List_Service_Price__c(Commission_In_Percentage__c=12,Default_Commission_In_Percentage__c=12,Id_Country__c=c.id,Is_Active__c=true,Maximum_Commission_In_Percentage__c=13,Minimum_Commission_in_Percentage__c=5,Name='testService3',RecordTypeId=mapRecordtypesKR.get('KR_Service_Price').id,Type__c='Commission');
        List_Product_Price__c lpp2 = new List_Product_Price__c(Id_List_Product_Group__c=lpg1.id,Installments__c=1,Is_Active__c=true,List_Price__c=50,Product_Name__c='Super Hero Setup 2',RecordTypeId=mapRecordtypesKR.get('KR_List_Product_Price').id,Default_Quantity__c=1);

        insert new List<sObject>{opp,opp1,lsp2,lpp2};

        Opportunity_Product_Item__c oppProduct = new Opportunity_Product_Item__c(Has_Related_Tarif__c=true,Id_List_Price_Product__c=lpp2.id,Id_Opportunity__c=opp.id,Installments__c=1,Listed_Price__c=50,Name='Super Hero Setup 2',Product_Group__c=lpg1.id,Quantity__c=1,RecordTypeId=mapRecordtypesKR.get('KR_Opportunity_Product_Item').id,Total_Amount__c=50);

        Opportunity_Service_Item__c oppService = new Opportunity_Service_Item__c(Commission_In_Percentage__c=12,Has_Related_Tarif__c=true,Id_List_Service_Price__c=lsp2.id,Id_Opportunity__c=opp.id,Name='testService3',RecordTypeId=mapRecordtypesKR.get('KR_Opportunity_Service_Item').id,Start_Date__c=Date.today(),Type__c='Commission');

        insert new List<sObject>{oppProduct,oppService};
    }

    @isTest static void test_method_one() {
        testData();
        List<Opportunity> listOpp = [select id,accountid,recordtypeid,subtotal__c,vat__c,total__c from Opportunity where name='TestOpp123'];
        Test.startTest();
        ApexPages.StandardController stctr = new ApexPages.StandardController(listOpp[0]);
        CtrOpportunityQuote testObject = new CtrOpportunityQuote(stctr);
        testObject.renderHtmlEmail();
        testObject.createQuote();
        Test.stopTest();
        System.assert(true);

    }*/

    /*@isTest static void test_method_two() {
        testData();
        List<Opportunity> listOpp = [select id,accountid,recordtypeid,subtotal__c,vat__c,total__c from Opportunity where name='TestOpp123'];
        Contact cc = [select id from Contact where FirstName='test1' limit 1];
        OpportunityContactRole oppcontactrole = new OpportunityContactRole(contactid=cc.id,Opportunityid=listOpp[0].id);
        insert oppcontactrole;
        Test.startTest();
        ApexPages.StandardController stctr = new ApexPages.StandardController(listOpp[0]);
        CtrOpportunityQuote testObject = new CtrOpportunityQuote(stctr);
        testObject.renderHtmlEmail();
        testObject.createQuote();
        Test.stopTest();
        System.assert(true);
    }*/

}