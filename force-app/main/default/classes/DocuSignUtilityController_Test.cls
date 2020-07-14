@isTest
public class DocuSignUtilityController_Test {

    private static User testUser;
    private static Country__c PYCoutry;
    private static List<Account> accounts;
    private static List<Opportunity> opportunities;
    private static List<Opportunity_Quote__c> quotes;

    private static testMethod void testMethod1(){

        testUser = UnitTestDataFactory.createUser('PY Sales Management', 'pyuser@deliveryhero.com', 'PedidosYa', 'UY');
        insert testUser;
        Test.startTest();
        setupUserData(testUser);
        System.runAs(testUser) {

            Opportunity_Quote__c oq = [Select Id,Name,Id_Account__r.Key_VIP_Account__c,Id_Opportunity__r.Probability,RecordTypeId,Id_opportunity__c,Status__c FROM Opportunity_Quote__c LIMIT 1];
            ApexPages.currentPage().getParameters().put('Id',String.valueOf(oq.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(oq);
            DocuSignUtilityController dsController = new DocuSignUtilityController(sc);
            dsController.createEnvelope();
            DocuSignUtilityController.checkDocuSignEnvelopeCount(oq.Id);
            DocuSignUtilityController.getUIThemeDescription();

        }
        Test.stopTest();

    }

    @testSetup static void setup() {
        List<Platform_Country__c> platformCountry = new List<Platform_Country__c>();
        platformCountry.add(new Platform_Country__c(name = 'PYPlatform', country__c = 'Argentina,Bolivia,Uruguay,Paraguay,Panama,Chile,Dominican Republic'));
        insert platformCountry;
        UnitTestDataFactory.getRecordtypeValues();
    }

    static void setupUserData(User u) {
        System.runAs(u) {

            //Inserting country
            PYCoutry = UnitTestDataFactory.createCountry('UY','Uruguay', 'UYU');
            insert PYCoutry;

            //Inserting Business configs
            Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='Uruguay',Business_Rule_Value__c='PY_DocuSign_Email_Body_Non_Argentina,ABC',Id_Country__c=PYCoutry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='docuSignEmailTemplate',Record_Type_Id__c='PY_Opportunity_Quote',Type__c='Process');
            Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='enableButton',Business_Rule_Value__c='2',Id_Country__c=PYCoutry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='docuSignFilters',Record_Type_Id__c='PY_Opportunity_Quote',Type__c='Process');
            Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='maxEnvelopeCount',Business_Rule_Value__c='2',Id_Country__c=PYCoutry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='docuSignFilters',Record_Type_Id__c='PY_Opportunity_Quote',Type__c='Process');
            //Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='Uruguay',Business_Rule_Value__c='2',Id_Country__c=PYCoutry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='docuSignFilters',Record_Type_Id__c='PY_Opportunity_Quote',Type__c='Process');
            insert new List<sObject>{b1,b2,b3};

            //INserting account
            Account fpAcc = UnitTestDataFactory.createAccount('test',PYCoutry,'PY_Account');
            fpAcc.phone = '+85278273613';
            insert fpAcc;

            Contact con = new Contact();
            con.FirstName = 'Test';
            con.LastName = 'Test';
            con.Contact_Role__c = 'Owner';
            con.AccountId = fpAcc.Id;
            insert con;

            //Inserting Opp
            Opportunity opp = UnitTestDataFactory.createOpportunity('test',fpAcc,'PY_Opportunity', Date.today());
            opp.Company_Code__c = 'UY';
            opp.Business_Type__c = 'Upgrade/Upsell';
            opp.Email_Path__c = 'DocuSign';
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

            EmailTemplate etemp = new EmailTemplate();
            etemp.Name = 'PY_DocuSign_Email_Body_Non_Argentina';
            etemp.Subject = 'Test';
            etemp.Body = 'Test';
            etemp.FolderId = UserInfo.getUserId();
            etemp.TemplateType = 'text';
            etemp.DeveloperName = 'PY_DocuSign_Email_Body_Non_Argentina';
            insert etemp;

            //Inserting Opp quote
            Opportunity_Quote__c  oq = new Opportunity_Quote__c();
            oq.Id_Opportunity__c = opp.Id;
            oq.Id_Account__c = fpAcc.Id;
            oq.Status__c = 'Approved';
            insert oq;

            //Inserting DocuSign Status
            dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c();
            ds.Opportunity_Quote__c = oq.Id;
            ds.dsfs__Envelope_Status__c = 'Sent';
            insert ds;

            dsfs__DocuSign_Status__c ds1 = new dsfs__DocuSign_Status__c();
            ds1.Opportunity_Quote__c = oq.Id;
            ds1.dsfs__Envelope_Status__c = 'Sent';
            insert ds1;

            oq.Status__c = 'Declined';
            update oq;

            ds.dsfs__Envelope_Status__c = 'Declined';
            ds.dsfs__Declined_Reason__c = 'Declined';
            update ds;

            ds.dsfs__Envelope_Status__c = 'Voided';
            ds.dsfs__Voided_Reason__c = 'Voided';
            update ds;

        }
    }

}