@isTest
public class pdfViewerCtrlTest {
    private static Country__c HKCoutry;
    private static List<Account> accounts;
    private static List<Opportunity> opportunities;
    private static List<Opportunity_Quote__c> quotes;
    private static User testUser;

    private static testMethod void testApexData() {
        testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'yogiyouser@deliveryhero.com', 'Yogiyo', 'KR');
        insert testUser;
        Test.startTest();
        setupUserData(testUser);

        System.runAs(testUser) {

            List<Opportunity_Quote__c> pyQuote = new List<Opportunity_Quote__c>();
            List<Opportunity_Quote__c> fpQuote = new List<Opportunity_Quote__c>();

            for(Opportunity_Quote__c oq : OpportunityQuoteSelector.findAll()) {
                if(oq.RecordType.DeveloperName == 'PY_Opportunity_Quote'){
                    pyQuote.add(oq);
                }
                else{
                    fpQuote.add(oq);
                }
            }

            if(!fpQuote.isEmpty()) {
                String title = ContentVersion_Selector.QUOTE_FILENAME_PREFIX + fpQuote[0].Name + ContentVersion_Selector.FILE_TYPE_PDF;	
                    ContentVersion cv = new ContentVersion(Title = title,	
                                                VersionData = Blob.valueOf('Content Test'),	
                                                PathOnClient = 'testpath',	
                                                IsMajorVersion = true                    );	
                    insert CV;	
                    List<ContentVersion> contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = :title AND IsLatest = true LIMIT 1];	
                    Id docIdopp = contentVersion[0].ContentDocumentId;	
                    ContentDocumentLink cdl = new ContentDocumentLink();	
                    cdl.LinkedEntityId = fpQuote[0].Id;	
                    cdl.ContentDocumentId = docIdopp;	
                    cdl.ShareType = 'V';	
                    insert cdl;	
                pdfViewerCtrl.generateQuoteUrl(fpQuote[0], false);	
                pdfViewerCtrl.getAccessLevelCtrl(fpQuote[0].Id);	
              pdfViewerCtrl.updateOpportunityType(fpQuote[0]);
                //pdfViewerCtrl.updateOpportunityType(fpQuote[0]);	
                System.assert(!pdfViewerCtrl.getInitData(fpQuote[0]).disableAcceptButton);
            }

            if(!pyQuote.isEmpty()) {
                System.assert(!pdfViewerCtrl.getInitData(pyQuote[0]).disableAcceptButton);
            }

        }
        Test.stopTest();
    }

    private static testMethod void testVipCountries() {
        testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'yogiyouser@deliveryhero.com', 'Yogiyo', 'KR');
        insert testUser;
        Test.startTest();
        setupUserData(testUser);

        System.runAs(testUser) {
            List<Opportunity_Quote__c> quotes = OpportunityQuoteSelector.findAll();
            for (Opportunity_Quote__c quote: quotes) {
                if (quote.Id_Account__r.Record_Country__c == 'Hong Kong') {
                    System.assert(!pdfViewerCtrl.findAcceptButton(quote));
                }
                if (quote.Id_Account__r.Record_Country__c == 'Argentina'){
                    System.assert(!pdfViewerCtrl.findAcceptButton(quote));
                }
            }

        }
        Test.stopTest();
    }

    @testSetup static void setup() {
        List<Platform_Country__c> platformCountry = new List<Platform_Country__c>();
        platformCountry.add(new Platform_Country__c(name = 'TalabatPlatform', country__c = 'Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name = 'FOCPlatform', country__c = 'Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
        UnitTestDataFactory.getRecordtypeValues();


    }

    static void setupUserData(User u) {
        System.runAs(u) {

            //Inserting country
            HKCoutry = UnitTestDataFactory.createCountry('HK','Hong Kong', 'HKD');
            insert HKCoutry;

            Country__c pyCountry = UnitTestDataFactory.createCountry('AR', 'Argentina', 'ARS');
            insert pyCountry;

            //Inserting Business configs
            Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='AllowVIPAcceptQuote',Business_Rule_Value__c='true',Id_Country__c=HKCoutry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteScreenProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c b2= new Business_Config__c(Business_Rule_Name__c='AllowAcceptQuoteButton',Business_Rule_Value__c='60',Id_Country__c=HKCoutry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteScreenProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c b3= new Business_Config__c(Business_Rule_Name__c='AllowVipAcceptCountries',Business_Rule_Value__c='Hong Kong',Id_Country__c=HKCoutry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QuoteScreenProcess',Record_Type_Id__c='FP_Opportunity_Quote',Type__c='Process');
            Business_Config__c b4= new Business_Config__c(Business_Rule_Name__c='acceptButtonLogic',Business_Rule_Value__c='{"Argentina":{"ApplyLogic":"TRUE","EnableOnDSCount":"2"}}',Id_Country__c=pyCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='docuSignFilters',Record_Type_Id__c='PY_Opportunity_Quote',Type__c='Process');
            Business_Config__c b5= new Business_Config__c(Business_Rule_Name__c='acceptButtonLogic',Business_Rule_Value__c='{"Hong Kong":{"ApplyLogic":"TRUE","EnableOnDSCount":"2"}}',Id_Country__c=HKCoutry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='docuSignFilters',Record_Type_Id__c='FP_Opportunity_Quote',Type__c='Process');
            Business_Config__c b6= new Business_Config__c(Business_Rule_Name__c='enableButton',Business_Rule_Value__c='TRUE',Id_Country__c=pyCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='docuSignFilters',Record_Type_Id__c='PY_Opportunity_Quote',Type__c='Process');
            Business_Config__c b7= new Business_Config__c(Business_Rule_Name__c='enableButton',Business_Rule_Value__c='TRU',Id_Country__c=HKCoutry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='docuSignFilters',Record_Type_Id__c='FP_Opportunity_Quote',Type__c='Process');

            insert new List<sObject>{b1,b2,b3,b4,b5,b6,b7};

            //INserting account
            Account fpAcc = UnitTestDataFactory.createAccount('test',HKCoutry,'FP_Account');
            fpAcc.Key_VIP_Account__c = true;
            fpAcc.phone = '+85278273613';

            insert fpAcc;

            //Inserting Opp
            Opportunity opp = UnitTestDataFactory.createOpportunity('test',fpAcc,'FP_Opportunity', Date.today());
            opp.Company_Code__c = 'HK';
            opp.Business_Type__c = 'Upgrade/Upsell';
            opp.Type = 'Product Only';
            insert opp;

            //Inserting address
            Integration_Config__c cs1 = new Integration_Config__c(
                    Name = 'GoogleMapsSignature', Password__c = 'Abvcd-asdfdgfhjklhnO0=');
            insert cs1;

            AddressDetail__c addr = new AddressDetail__c(
                    Type__c = 'Billing Address;Restaurant Address',
                    LatLng__Longitude__s = 10.0,
                    LatLng__Latitude__s = 5.0,
                    Account__c = fpAcc.Id,

                    GPA_Country_long_name__c = 'Ecuador',
                    GPA_Country_short_name__c = 'EC',

                    GPA_Admin_area_level_1_long_name__c = 'admin area 1 test',
                    GPA_Admin_area_level_1_short_name__c = 'aat1',

                    GPA_Locality_long_name__c = 'locality',
                    GPA_Locality_short_name__c = 'lco',

                    GPA_Route_long_name__c = 'street name',
                    GPA_Route_short_name__c = 'str',

                    GPA_Street_number_long_name__c = '10',
                    GPA_Street_number_short_name__c = '10',

                    GPA_Postal_code_long_name__c = '1010',
                    GPA_Postal_code_short_name__c = '1010',

                    GPA_Place_id__c = '12344',
                    GPA_formatted_address__c = 'whatever bla bla',
                    GPA_Was_modified_manually__c = false
            );

            insert addr;

            //Inserting Opp quote
            Opportunity_Quote__c  oq = new Opportunity_Quote__c();
            oq.Id_Opportunity__c = opp.Id;
            insert oq;

            Opportunity_Quote__c  oq2 = new Opportunity_Quote__c();
            oq2.Id_Opportunity__c = opp.Id;
            oq2.Id_Account__c = fpAcc.Id;
            oq2.Status__c='Approved';
            oq2.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue('FP_Opportunity_Quote');
            insert oq2;

            Company__c pyCompany = UnitTestDataFactory.createCompany('Pedidosya', 'PY', pyCountry);
            insert pyCompany;

            Account pyAcc = UnitTestDataFactory.createAccount('test',pyCountry,'PY_Account');
            insert pyAcc;

            Opportunity pyOpp = UnitTestDataFactory.createOpportunity('test',pyAcc,'PY_Opportunity', Date.today());
            insert pyOpp;

            Opportunity_Quote__c  pyQuote = new Opportunity_Quote__c();
            pyQuote.Id_Account__c = pyAcc.Id;
            pyQuote.Id_Opportunity__c = pyOpp.Id;
            pyQuote.Status__c='Approved';
            pyQuote.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue('PY_Opportunity_Quote');
            insert pyQuote;

            List_Service_Price__c lsp = UnitTestDataFactory.createService(pyCompany,pyCountry,'testService1','PY_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType');
            lsp.Based_On__c = 'Orders';
            lsp.Commission_Type__c = 'Percentage';
            lsp.Requires_Esignature__c='Mandatory';
            lsp.Scaled__c = true;
            insert lsp;

            List_Add_On__c lao = new List_Add_On__c(Is_Active__c = true, Type__c = 'Deal / Promotion', Company__c = pyCompany.Id, Id_Country__c = pyCountry.Id, Name = 'Test add on');
            lao.Requires_Esignature__c='Mandatory';
            insert lao;

            List<Opportunity_Quote_Line_Item__c> oppQuoteLine =  UnitTestDataFactory.createOpportunityQuoteLineItems(pyQuote,1,false,'PY_Opportunity_Quote_Line_Item',12,1,true, 0, Date.today(),'Commission Fee','Service');
            oppQuoteLine[0].Id_Opportunity__c=pyOpp.Id;
            oppQuoteLine[0].Id_Opportunity_Quote__c=pyQuote.Id;
            oppQuoteLine[0].Id_List_Service_Price__c=lsp.Id;
            insert oppQuoteLine ;

            List<Opportunity_Quote_Line_Item__c> oppQuoteLine1 =  UnitTestDataFactory.createOpportunityQuoteLineItems(pyQuote,1,false,'PY_Opportunity_Quote_Line_Item',12,1,true, 0, Date.today(),'Commission Fee','Service');
            oppQuoteLine1[0].Id_Opportunity__c=pyOpp.Id;
            oppQuoteLine1[0].Id_Opportunity_Quote__c=pyQuote.Id;
            oppQuoteLine1[0].Id_List_Add_On__c=lao.Id;
            insert oppQuoteLine1 ;

            //Inserting DocuSign Status
            dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c();
            ds.Opportunity_Quote__c = oq.Id;
            ds.dsfs__Envelope_Status__c = 'Sent';
            insert ds;

            dsfs__DocuSign_Status__c ds1 = new dsfs__DocuSign_Status__c();
            ds1.Opportunity_Quote__c = oq.Id;
            ds1.dsfs__Envelope_Status__c = 'Sent';
            insert ds1;

        }
    }
    
}
