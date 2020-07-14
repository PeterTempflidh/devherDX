@isTest
private class UnitTestBatchOpportunityTarif {

    static Map<String,RecordType> mapRecordTypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Opportunity'});
    static User testRunningUser;
    static{
    UnitTestDataFactory.getRecordtypeValues();
    }
    static void testData(){
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Exclude_from_Validation'];
        PermissionSetAssignment psa = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE Assignee.Profile.PermissionsModifyAllData = TRUE AND Assignee.IsActive = TRUE AND PermissionSetId = :ps.Id LIMIT 1];
        testRunningUser = [SELECT Id, Username, Email FROM User WHERE Id = :psa.AssigneeId];
        Country__c c = UnitTestDataFactory.createCountry('KR','Korea', 'KRW');
        insert c;
        Company__c com = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', c);
        insert com;

        Business_Config__c b1 = UnitTestDataFactory.createBusinessConfig('BatchSchedulerForOpportunity', 'Process','opportunity_tarif_recordType','Yogiyo_Opportunity_Tarif_Item', c.id, 'Yogiyo_Opportunity', true, true);
        Business_Config__c b2 = UnitTestDataFactory.createBusinessConfig('BatchSchedulerForOpportunity', 'Process','opportunity_product_recordType','Yogiyo_Opportunity_Line_Item', c.id, 'Yogiyo_Opportunity', true, false);
        Business_Config__c b3 = UnitTestDataFactory.createBusinessConfig('BatchSchedulerForOpportunity', 'Process','opportunity_service_recordType','Yogiyo_Opportunity_Line_Item', c.id, 'Yogiyo_Opportunity', true, false);
        Business_Config__c b4 = UnitTestDataFactory.createBusinessConfig('BatchSchedulerForOpportunity', 'Process','opportunity_quote_service_recordType','Yogiyo_Opportunity_Quote_Line_Item', c.id, 'Yogiyo_Opportunity', true, false);
        Business_Config__c b5 = UnitTestDataFactory.createBusinessConfig('BatchSchedulerForOpportunity', 'Process','opportunity_quote_product_recordType','Yogiyo_Opportunity_Quote_Line_Item', c.id, 'Yogiyo_Opportunity', true, false);
        Business_Config__c b6 = UnitTestDataFactory.createBusinessConfig('BatchSchedulerForOpportunity', 'Process','opportunity_quote_recordType','Yogiyo_Opportunity_Quote', c.id, 'Yogiyo_Opportunity', true, false);
        Business_Config__c b7 = UnitTestDataFactory.createBusinessConfig('BatchSchedulerForOpportunity', 'Process','Contract_recordType','Yogiyo_Contract', c.id, 'Yogiyo_Opportunity', true, false);
        Business_Config__c b8 = UnitTestDataFactory.createBusinessConfig('BatchSchedulerForOpportunity', 'Process','Asset_recordType','Yogiyo_Asset', c.id, 'Yogiyo_Opportunity', true, false);
        Business_Config__c b9 = UnitTestDataFactory.createBusinessConfig('BatchSchedulerForOpportunity', 'Process','AdditionalCharges_recordType','Yogiyo_Additional_Charges', c.id, 'Yogiyo_Opportunity', true, false);
        Business_Config__c b10 = UnitTestDataFactory.createBusinessConfig('BatchSchedulerForOpportunity', 'Process','enableAnnualEndDate','true', c.id, 'Yogiyo_Opportunity', true, false);
        Business_Config__c b11 = UnitTestDataFactory.createBusinessConfig('BatchSchedulerForOpportunity', 'Process','enableContractEndDate','false', c.id, 'Yogiyo_Opportunity', true, false);
        Business_Config__c b12 = UnitTestDataFactory.createBusinessConfig('BatchSchedulerForOpportunity', 'Process','AddOnRecordType','Yogiyo_Add_On', c.id, 'Yogiyo_Opportunity', true, false);
        Business_Config__c b13 = UnitTestDataFactory.createBusinessConfig('BatchSchedulerForOpportunity', 'Process','BrandingContentRecordType','Yogiyo_Branding_Content', c.id, 'Yogiyo_Opportunity', true, false);
        Business_Config__c b14 = UnitTestDataFactory.createBusinessConfig('BatchSchedulerForOpportunity', 'Process','Add_On_Service_recordType','SE_Add_on', c.id, 'Yogiyo_Opportunity', true, false);
        Business_Config__c b15 = UnitTestDataFactory.createBusinessConfig('BatchSchedulerForOpportunity', 'Process','startDateIsOppCloseDate','TRUE', c.id, 'Yogiyo_Opportunity', true, false);
        Business_Config__c b16 = UnitTestDataFactory.createBusinessConfig('BatchSchedulerForOpportunity', 'Process','tieredKeyword','testTarif', c.id, 'Yogiyo_Opportunity', true, false);

        Account acc1 = UnitTestDataFactory.createAccount('BatchTestClassAccount1',c,'Yogiyo_Account');
        Account acc2 = UnitTestDataFactory.createAccount('BatchTestClassAccount2',c,'Yogiyo_Account');
        Account acc3 = UnitTestDataFactory.createAccount('BatchTestClassAccount2',c,'Yogiyo_Account');
        BatchOpportunityTarif_MigrationText__c cs = new BatchOpportunityTarif_MigrationText__c(name='FilterText',Value__c='Migration');

        insert new List<SObject>{b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,acc1,acc2,acc3,cs,b12,b13,b14,b15,b16};


        Opportunity opp1 = new Opportunity(Setup_Fee_AU__c=155,Start_Date_uk__c=Date.newInstance(2014, 12, 21),name='BatchTestOpp1', recordtypeid=mapRecordTypes.get('Yogiyo_Opportunity').id,AccountId=acc1.id,CloseDate=Date.newInstance(2014, 12, 21), StageName='Prospecting', TarrifName_AU__c='testTarif1',Is_DataLoaded__c=true,Migration_Notes_AU__c='Migration', tariff_range_CD__c='{"formula": {"data": [{"hasta": "80", "desde": "0", "tipo": "%", "valor": "8.00"}, {"hasta": "160", "desde": "81", "tipo": "%", "valor": "10.00"}, {"hasta": "300", "desde": "161", "tipo": "%", "valor": "12.00"}, {"hasta": "500", "desde": "301", "tipo": "%", "valor": "14.00"}, {"hasta": "0", "desde": "501", "tipo": "%", "valor": "15.00"}], "tipo": "rango"}}', tariff_online_CD__c='{"formula": {"data": [{"hasta": "80", "desde": "0", "tipo": "%", "valor": "3.50"}, {"hasta": "160", "desde": "81", "tipo": "%", "valor": "3.50"}, {"hasta": "300", "desde": "161", "tipo": "%", "valor": "3.50"}, {"hasta": "500", "desde": "301", "tipo": "%", "valor": "3.50"}, {"hasta": "0", "desde": "501", "tipo": "%", "valor": "3.50"}], "tipo": "rango"}}');
        Opportunity opp2 = new Opportunity(Setup_Fee_AU__c=200,Start_Date_uk__c=Date.newInstance(2014, 12, 22),name='BatchTestOpp2', recordtypeid=mapRecordTypes.get('Yogiyo_Opportunity').id,AccountId=acc1.id,CloseDate=Date.today(), StageName='Prospecting', TarrifName_AU__c='testTarif2',Is_DataLoaded__c=true,Migration_Notes_AU__c='Migration', tariff_range_CD__c='{"formula": {"data": [{"hasta": "80", "desde": "0", "tipo": "%", "valor": "8.00"}, {"hasta": "160", "desde": "81", "tipo": "%", "valor": "10.00"}, {"hasta": "300", "desde": "161", "tipo": "%", "valor": "12.00"}, {"hasta": "500", "desde": "301", "tipo": "%", "valor": "14.00"}, {"hasta": "0", "desde": "501", "tipo": "%", "valor": "15.00"}], "tipo": "rango"}}', tariff_online_CD__c='{"formula": {"data": [{"hasta": "80", "desde": "0", "tipo": "%", "valor": "3.50"}, {"hasta": "160", "desde": "81", "tipo": "%", "valor": "3.50"}, {"hasta": "300", "desde": "161", "tipo": "%", "valor": "3.50"}, {"hasta": "500", "desde": "301", "tipo": "%", "valor": "3.50"}, {"hasta": "0", "desde": "501", "tipo": "%", "valor": "3.50"}], "tipo": "rango"}}');
        Opportunity opp3 = new Opportunity(Setup_Fee_AU__c=115,Start_Date_uk__c=Date.newInstance(2014, 12, 20),name='BatchTestOpp3', recordtypeid=mapRecordTypes.get('Yogiyo_Opportunity').id,AccountId=acc2.id,CloseDate=Date.today(), StageName='Prospecting', TarrifName_AU__c='testTarif2',Is_DataLoaded__c=true,Migration_Notes_AU__c='Migration', tariff_range_CD__c='{"formula": {"data": [{"hasta": "80", "desde": "0", "tipo": "%", "valor": "8.00"}, {"hasta": "160", "desde": "81", "tipo": "%", "valor": "10.00"}, {"hasta": "300", "desde": "161", "tipo": "%", "valor": "12.00"}, {"hasta": "500", "desde": "301", "tipo": "%", "valor": "14.00"}, {"hasta": "0", "desde": "501", "tipo": "%", "valor": "15.00"}], "tipo": "rango"}}', tariff_online_CD__c='{"formula": {"data": [{"hasta": "80", "desde": "0", "tipo": "%", "valor": "3.50"}, {"hasta": "160", "desde": "81", "tipo": "%", "valor": "3.50"}, {"hasta": "300", "desde": "161", "tipo": "%", "valor": "3.50"}, {"hasta": "500", "desde": "301", "tipo": "%", "valor": "3.50"}, {"hasta": "0", "desde": "501", "tipo": "%", "valor": "3.50"}], "tipo": "rango"}}');
        Opportunity opp4 = new Opportunity(Setup_Fee_AU__c=110,Start_Date_uk__c=Date.newInstance(2014, 12, 19),name='BatchTestOpp4', recordtypeid=mapRecordTypes.get('Yogiyo_Opportunity').id,AccountId=acc2.id,CloseDate=Date.today(), StageName='Prospecting', TarrifName_AU__c='testTarif1',Is_DataLoaded__c=true,Migration_Notes_AU__c='Migration', tariff_range_CD__c='{"formula": {"data": [{"hasta": "80", "desde": "0", "tipo": "%", "valor": "8.00"}, {"hasta": "160", "desde": "81", "tipo": "%", "valor": "10.00"}, {"hasta": "300", "desde": "161", "tipo": "%", "valor": "12.00"}, {"hasta": "500", "desde": "301", "tipo": "%", "valor": "14.00"}, {"hasta": "0", "desde": "501", "tipo": "%", "valor": "15.00"}], "tipo": "rango"}}', tariff_online_CD__c='{"formula": {"data": [{"hasta": "80", "desde": "0", "tipo": "%", "valor": "3.50"}, {"hasta": "160", "desde": "81", "tipo": "%", "valor": "3.50"}, {"hasta": "300", "desde": "161", "tipo": "%", "valor": "3.50"}, {"hasta": "500", "desde": "301", "tipo": "%", "valor": "3.50"}, {"hasta": "0", "desde": "501", "tipo": "%", "valor": "3.50"}], "tipo": "rango"}}');
        Opportunity opp5 = new Opportunity(Setup_Fee_AU__c=120,Start_Date_uk__c=Date.newInstance(2014, 12, 18),name='BatchTestOpp5', recordtypeid=mapRecordTypes.get('Yogiyo_Opportunity').id,AccountId=acc3.id,CloseDate=Date.today(), StageName='Prospecting', TarrifName_AU__c='testTarif1',Is_DataLoaded__c=true,Migration_Notes_AU__c='Migration', tariff_range_CD__c='{"formula": {"data": [{"hasta": "80", "desde": "0", "tipo": "%", "valor": "8.00"}, {"hasta": "160", "desde": "81", "tipo": "%", "valor": "10.00"}, {"hasta": "300", "desde": "161", "tipo": "%", "valor": "12.00"}, {"hasta": "500", "desde": "301", "tipo": "%", "valor": "14.00"}, {"hasta": "0", "desde": "501", "tipo": "%", "valor": "15.00"}], "tipo": "rango"}}', tariff_online_CD__c='{"formula": {"data": [{"hasta": "80", "desde": "0", "tipo": "%", "valor": "3.50"}, {"hasta": "160", "desde": "81", "tipo": "%", "valor": "3.50"}, {"hasta": "300", "desde": "161", "tipo": "%", "valor": "3.50"}, {"hasta": "500", "desde": "301", "tipo": "%", "valor": "3.50"}, {"hasta": "0", "desde": "501", "tipo": "%", "valor": "3.50"}], "tipo": "rango"}}');
        Opportunity opp6 = new Opportunity(Setup_Fee_AU__c=150,Start_Date_uk__c=Date.newInstance(2014, 12, 05),name='BatchTestOpp6', recordtypeid=mapRecordTypes.get('Yogiyo_Opportunity').id,AccountId=acc3.id,CloseDate=Date.today(), StageName='Prospecting', TarrifName_AU__c='testTarif2',Is_DataLoaded__c=true,Migration_Notes_AU__c='Migration', tariff_range_CD__c='{"formula": {"data": [{"hasta": "80", "desde": "0", "tipo": "%", "valor": "8.00"}, {"hasta": "160", "desde": "81", "tipo": "%", "valor": "10.00"}, {"hasta": "300", "desde": "161", "tipo": "%", "valor": "12.00"}, {"hasta": "500", "desde": "301", "tipo": "%", "valor": "14.00"}, {"hasta": "0", "desde": "501", "tipo": "%", "valor": "15.00"}], "tipo": "rango"}}', tariff_online_CD__c='{"formula": {"data": [{"hasta": "80", "desde": "0", "tipo": "%", "valor": "3.50"}, {"hasta": "160", "desde": "81", "tipo": "%", "valor": "3.50"}, {"hasta": "300", "desde": "161", "tipo": "%", "valor": "3.50"}, {"hasta": "500", "desde": "301", "tipo": "%", "valor": "3.50"}, {"hasta": "0", "desde": "501", "tipo": "%", "valor": "3.50"}], "tipo": "rango"}}');
        Opportunity opp7 = new Opportunity(Setup_Fee_AU__c=150,Start_Date_uk__c=Date.newInstance(2014, 12, 05),name='BatchTestOpp7', recordtypeid=mapRecordTypes.get('Yogiyo_Opportunity').id,AccountId=acc3.id,CloseDate=Date.today(), StageName='Prospecting', TarrifName_AU__c='',Is_DataLoaded__c=true,Migration_Notes_AU__c='Migration');
        Opportunity opp8 = new Opportunity(Setup_Fee_AU__c=150,Start_Date_uk__c=Date.newInstance(2014, 12, 05),name='BatchTestOpp8', recordtypeid=mapRecordTypes.get('Yogiyo_Opportunity').id,AccountId=acc3.id,CloseDate=Date.today(), StageName='Closed Lost', TarrifName_AU__c='testTarif2',Is_DataLoaded__c=true,Migration_Notes_AU__c='Migration', Lost_Date__c=Date.today(), Asset_Installment_migration__c = 1, FreeTrial_End_AU__c=Date.today(), tariff_range_CD__c='{"formula": {"data": [{"hasta": "80", "desde": "0", "tipo": "%", "valor": "8.00"}, {"hasta": "160", "desde": "81", "tipo": "%", "valor": "10.00"}, {"hasta": "300", "desde": "161", "tipo": "%", "valor": "12.00"}, {"hasta": "500", "desde": "301", "tipo": "%", "valor": "14.00"}, {"hasta": "0", "desde": "501", "tipo": "%", "valor": "15.00"}], "tipo": "rango"}}', tariff_online_CD__c='{"formula": {"data": [{"hasta": "80", "desde": "0", "tipo": "%", "valor": "3.50"}, {"hasta": "160", "desde": "81", "tipo": "%", "valor": "3.50"}, {"hasta": "300", "desde": "161", "tipo": "%", "valor": "3.50"}, {"hasta": "500", "desde": "301", "tipo": "%", "valor": "3.50"}, {"hasta": "0", "desde": "501", "tipo": "%", "valor": "3.50"}], "tipo": "rango"}}');
        Opportunity opp9 = new Opportunity(Setup_Fee_AU__c=150,Start_Date_uk__c=Date.newInstance(2014, 12, 05),name='BatchTestOpp9', recordtypeid=mapRecordTypes.get('Yogiyo_Opportunity').id,AccountId=acc3.id,CloseDate=Date.today(), StageName='Closed Lost', TarrifName_AU__c='testTarif2',Is_DataLoaded__c=true,Migration_Notes_AU__c='Migration', FreeTrial_End_AU__c=Date.today(), Lost_Date__c = Date.today(), tariff_range_CD__c='{"formula": {"data": [{"hasta": "80", "desde": "0", "tipo": "%", "valor": "8.00"}, {"hasta": "160", "desde": "81", "tipo": "%", "valor": "10.00"}, {"hasta": "300", "desde": "161", "tipo": "%", "valor": "12.00"}, {"hasta": "500", "desde": "301", "tipo": "%", "valor": "14.00"}, {"hasta": "0", "desde": "501", "tipo": "%", "valor": "15.00"}], "tipo": "rango"}}', tariff_online_CD__c='{"formula": {"data": [{"hasta": "80", "desde": "0", "tipo": "%", "valor": "3.50"}, {"hasta": "160", "desde": "81", "tipo": "%", "valor": "3.50"}, {"hasta": "300", "desde": "161", "tipo": "%", "valor": "3.50"}, {"hasta": "500", "desde": "301", "tipo": "%", "valor": "3.50"}, {"hasta": "0", "desde": "501", "tipo": "%", "valor": "3.50"}], "tipo": "rango"}}');
        Opportunity opp10 = new Opportunity(Setup_Fee_AU__c=150,Start_Date_uk__c=Date.newInstance(2014, 12, 05),name='BatchTestOpp9', recordtypeid=mapRecordTypes.get('Yogiyo_Opportunity').id,AccountId=acc3.id,CloseDate=Date.today(), StageName='Closed Lost', TarrifName_AU__c='testTarif2',Is_DataLoaded__c=true,Migration_Notes_AU__c='Migration', Installment_migration__c = 1, addon_Specification__c='Test Spec', addon_startdate__c=Date.today(), FreeTrial_End_AU__c=Date.today(), tariff_range_CD__c='{"formula": {"data": [{"hasta": "80", "desde": "0", "tipo": "%", "valor": "8.00"}, {"hasta": "160", "desde": "81", "tipo": "%", "valor": "10.00"}, {"hasta": "300", "desde": "161", "tipo": "%", "valor": "12.00"}, {"hasta": "500", "desde": "301", "tipo": "%", "valor": "14.00"}, {"hasta": "0", "desde": "501", "tipo": "%", "valor": "15.00"}], "tipo": "rango"}}', tariff_online_CD__c='{"formula": {"data": [{"hasta": "80", "desde": "0", "tipo": "%", "valor": "3.50"}, {"hasta": "160", "desde": "81", "tipo": "%", "valor": "3.50"}, {"hasta": "300", "desde": "161", "tipo": "%", "valor": "3.50"}, {"hasta": "500", "desde": "301", "tipo": "%", "valor": "3.50"}, {"hasta": "0", "desde": "501", "tipo": "%", "valor": "3.50"}], "tipo": "rango"}}');
        Opportunity opp11 = new Opportunity(Setup_Fee_AU__c=150,Start_Date_uk__c=Date.newInstance(2014, 12, 05),name='BatchTestOpp9', recordtypeid=mapRecordTypes.get('Yogiyo_Opportunity').id,AccountId=acc3.id,CloseDate=Date.today(), StageName='Closed Lost', TarrifName_AU__c='testTarif3',Is_DataLoaded__c=true,Migration_Notes_AU__c='Migration', Installment_migration__c = 1, addon_Specification__c='Test Spec', addon_startdate__c=Date.today(), FreeTrial_End_AU__c=Date.today(), tariff_range_CD__c='{"formula": {"data": [{"hasta": "80", "desde": "0", "tipo": "%", "valor": "8.00"}, {"hasta": "160", "desde": "81", "tipo": "%", "valor": "10.00"}, {"hasta": "300", "desde": "161", "tipo": "%", "valor": "12.00"}, {"hasta": "500", "desde": "301", "tipo": "%", "valor": "14.00"}, {"hasta": "0", "desde": "501", "tipo": "%", "valor": "15.00"}], "tipo": "rango"}}', tariff_online_CD__c='{"formula": {"data": [{"hasta": "80", "desde": "0", "tipo": "%", "valor": "3.50"}, {"hasta": "160", "desde": "81", "tipo": "%", "valor": "3.50"}, {"hasta": "300", "desde": "161", "tipo": "%", "valor": "3.50"}, {"hasta": "500", "desde": "301", "tipo": "%", "valor": "3.50"}, {"hasta": "0", "desde": "501", "tipo": "%", "valor": "3.50"}], "tipo": "rango"}}');

        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,c,'Apple','Yogiyo_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,c,'Setup Fee','Yogiyo_List_Product_Group');


        insert new List<SObject>{opp1,opp2,opp3,opp4,opp5,opp6,opp7,opp8,opp9,opp10,opp11,lpg,lpg1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,c,'Ipad 4 Gen. 16GB',lpg.id,'Yogiyo_List_Product_Price',1,true,100,1,false,20);
        lpp.Requires_Asset__c = true;
        List_Product_Price__c lpp3 = UnitTestDataFactory.createProduct(com,c,'Ipad 4 Gen. 16GB',lpg.id,'Yogiyo_List_Product_Price',1,true,100,1,false,20);
        lpp3.Product_Type__c = 'Recurring Fee';
        lpp3.Product_Name__c = Label.MigrationSubscriptionFee;
        lpp3.Requires_Branding__c = true;
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,c,'Super Hero Setup 1',lpg1.id,'Yogiyo_List_Product_Price',1,true,100,1,false,20);
        lpp1.Requires_Branding__c = true;
        lpp1.Requires_Add_On__c = true;
        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com,c,'Super Hero Setup 2',lpg1.id,'Yogiyo_List_Product_Price',1,true,50,1,true,20);
        List_Product_Price__c lpp4 = UnitTestDataFactory.createProduct(com,c,'Ipad 4 Gen. 16GB',lpg.id,'Yogiyo_List_Product_Price',1,true,100,1,false,20);
        lpp4.Product_Type__c = 'Setup Fee';

        List_Service_Price__c lsp = UnitTestDataFactory.createService(com,c,'testService1','Yogiyo_List_Service_Price',12,12,25,5,null,true,200,'Commission Fee','Commission Fee');
        List_Service_Price__c lsp1 = UnitTestDataFactory.createService(com,c,'testService2','Yogiyo_List_Service_Price',12,12,13,5,null,true,null,'Commission Fee','Commission Fee');

        List_Add_On__c lsa = UnitTestDataFactory.createAddOn(c.Id, com.Id, 'test','Deal / Promotion','test');
        List_Add_On__c lsa1 = UnitTestDataFactory.createAddOn(c.Id, com.Id, 'test','Deal / Promotion','test');

        Tarif__c t = UnitTestDataFactory.createTarif(com,c,'testTarif1','Yogiyo_Tarif',false);
        Tarif__c t1 = UnitTestDataFactory.createTarif(com,c,'testTarif2','Yogiyo_Tarif',false);
        Tarif__c t2 = UnitTestDataFactory.createTarif(com,c,'testTarif3','Yogiyo_Tarif',false);

        insert new List<sObject>{lpp,lpp1,lpp2,lpp3,lpp4,lsp,lsp1,t,t1,t2,lsa,lsa1};

        Tarif_Member__c tm = UnitTestDataFactory.createTarifMember(lpp.id,'Yogiyo_Tarif_Member',t.id,'Product');
        Tarif_Member__c tm1 = UnitTestDataFactory.createTarifMember(lpp1.id,'Yogiyo_Tarif_Member',t.id,'Product');
        Tarif_Member__c tm2 = UnitTestDataFactory.createTarifMember(lsp.id,'Yogiyo_Tarif_Member',t.id,'Service');
        Tarif_Member__c tm3 = UnitTestDataFactory.createTarifMember(lsp1.id,'Yogiyo_Tarif_Member',t1.id,'Service');
        Tarif_Member__c tm4 = UnitTestDataFactory.createTarifMember(lpp2.id,'Yogiyo_Tarif_Member',t1.id,'Product');
        Tarif_Member__c tm5 = UnitTestDataFactory.createTarifMember(lpp3.id,'Yogiyo_Tarif_Member',t1.id,'Product');
        Tarif_Member__c tm6 = UnitTestDataFactory.createTarifMember(lpp4.id,'Yogiyo_Tarif_Member',t1.id,'Product');
        Tarif_Member__c tm7 = UnitTestDataFactory.createTarifMember(lsa.id,'Yogiyo_Tarif_Member',t2.id,'AddOn');
        Tarif_Member__c tm8 = UnitTestDataFactory.createTarifMember(lsa1.id,'Yogiyo_Tarif_Member',t2.id,'AddOn');

        insert new List<sObject>{tm,tm1,tm2,tm3,tm4,tm5,tm6,tm7,tm8};

        t.Is_Active__c = true;
        t1.Is_Active__c = true;
        opp7.Migration_List_Addon_ID__c = lsa1.id;
        opp7.Migration_List_Product_ID__c=lpp.id;
        opp7.Migration_List_Service_ID__c=lsp.id;
        opp8.Migration_List_Product_ID__c=lpp.id;
        opp8.Migration_List_Service_ID__c=lsp.id;
        opp9.Migration_List_Product_ID__c=lpp3.id;
        opp9.Migration_List_Service_ID__c=lsp.id;
        opp10.Migration_List_Product_ID__c=lpp4.id;
        opp10.Migration_List_Service_ID__c=lsp.id;
        opp11.Migration_List_Addon_ID__c = lsa.id;
        update new List<sObject>{t,t1,opp7, opp8, opp9, opp10};
    }

    @isTest static void test_method_one() {
        testData();

        System.runAs(testRunningUser){
            Test.startTest();
                BatchOpportunityTarif batch = new BatchOpportunityTarif();
                Database.executeBatch(batch,500);
            Test.stopTest();
        }

        List<Opportunity_Quote_Line_Item__c> oppQuoteService = [select id,end_date__c from Opportunity_Quote_Line_Item__c];
        List<Contract> contracts = [select id,end_date__c from Contract];
        System.assertEquals(([select id from Opportunity_Line_Item__c]).size(),71);
        System.assertEquals(([select id from Opportunity_Quote__c]).size(),10);
        System.assertEquals(([select id from Opportunity_Quote_Line_Item__c]).size(),71);
        System.assertEquals(contracts.size(),45);
        System.assertEquals(([select id from Asset__c]).size(),9);
        System.assertEquals(contracts[0].end_date__c,null);

    }
     @isTest static void test_method_two() {
        testData();

        System.runAs(testRunningUser){
            Test.startTest();
                BatchOpportunityTarifDE batch = new BatchOpportunityTarifDE();
                Database.executeBatch(batch,500);
            Test.stopTest();
        }

        System.assertEquals(([select id from Opportunity_Line_Item__c]).size(),9);
    }

}