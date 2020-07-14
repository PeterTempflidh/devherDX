@IsTest
public class DH_InboudCaseProcessor_Test {

    @testSetup
    static void testSetup() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c bh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        Country__c hk = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'EUR');
        Country__c ar = UnitTestDataFactory.createCountry('AR', 'Argentina', 'ARS');
        Country__c my = UnitTestDataFactory.createCountry('MY', 'Malaysia', 'MYR');
        Country__c tw = UnitTestDataFactory.createCountry('TW', 'Taiwan', 'TWD');
        Country__c de = UnitTestDataFactory.createCountry('DE', 'Germany', 'EUR');
        List<Country__c> countrylst = new List<Country__c>{bh,my,tw,hk,ar,de};
        Database.insert(countrylst);

        Company__c com = UnitTestDataFactory.createCompany('Talabat', 'Talabat', bh);
        insert com;

        Account acco = UnitTestDataFactory.createAccount('TEST', bh, 'Talabat_Account');
        Account bcco = UnitTestDataFactory.createAccount('TEST', hk, 'FP_Account');
        Account dcco = UnitTestDataFactory.createAccount('TEST', ar, 'PY_Account');
        insert new List<Account>{acco,bcco,dcco};

        Group q = new Group();
        q.Name = 'Talabat_BH_Sales_Admin';
        q.Type = 'Queue';
        
        Group q2 = new Group();
        q2.Name = 'FP_CS_HK_Email';
        q2.Type = 'Queue';

        Group q3 = new Group();
        q3.Name = 'FP_CS_Team_Lead';
        q3.Type = 'Queue';

        Group q4 = new Group();
        q4.Name = 'PY_Customer_Request';
        q4.Type = 'Queue';
              
        Group q5 = new Group(Name='FP_CS_Recovery_en_XX', Type='Queue');
        Group q6 = new Group(Name='FP_CS_Recovery_zh_TW', Type='Queue');
        List<Group> grpList =  new List<Group>{q, q2,q3,q4,q5,q6};
        insert grpList ;
        User u = [SELECT Id FROM User WHERE Id=:userinfo.getUserId()];
        PermissionSet elastixPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'API_Elastix'];
        system.runAs(u) {
            QueueSObject qSObj = new QueueSObject(SobjectType = 'Case', QueueId = q.Id);
            QueueSObject qSObj2 = new QueueSObject(SobjectType = 'Case', QueueId = q2.Id);
            QueueSObject qSObj3 = new QueueSObject(SobjectType = 'Case', QueueId = q3.Id);
            QueueSObject qSObj4 = new QueueSObject(SobjectType = 'Case', QueueId = q4.Id);
            insert new List<QueueSObject>{qSObj,qSObj2,qSObj3,qSObj4};
          
            UserRole rom = new UserRole(DeveloperName = 'RO_Test_Role', Name = 'RO Test Role');
            insert rom;
            insert new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Global Customer Service'].Id,
                    LastName = 'last',
                    Email = 'testclassuser12345@deliveryhero.com',
                    Username = 'testclassuser12345@deliveryhero.com',
                    CompanyName = 'TEST',
                    Title = 'title',
                    Alias = 'alias',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    UserRoleId = rom.Id,
                    FederationIdentifier='testclassuser12345@deliveryhero.com'
            );
			
			Profile talabatProfile = [SELECT Id FROM Profile WHERE Name = 'Talabat Customer Care'];
            Profile apiProfile = [SELECT Id FROM Profile WHERE Name = 'API Only'];
            List<User> usersToInsert = new List<User>();
            User apiElastixUser = new User();
            apiElastixUser.alias = 'elastUsr';
            apiElastixUser.email='testclassuser@talabat.com';
            apiElastixUser.emailencodingkey='UTF-8';
            apiElastixUser.lastname='Test Class User';
            apiElastixUser.languagelocalekey='en_US';
            apiElastixUser.localesidkey='en_US';
            apiElastixUser.profileid = apiProfile.Id;
            apiElastixUser.timezonesidkey='America/Los_Angeles';
            apiElastixUser.username='api.elastix2@talabat.com.test';
            usersToInsert.add(apiElastixUser);

            User elastixUser = new User();
            elastixUser.Elastix_Agent_Id__c = '9876';
            elastixUser.Elastix_Password__c = 'test1234';
            elastixUser.alias = 'elastUsr';
            elastixUser.email='testclassuser@talabat.com';
            elastixUser.emailencodingkey='UTF-8';
            elastixUser.lastname='Test Class User';
            elastixUser.languagelocalekey='en_US';
            elastixUser.localesidkey='en_US';
            elastixUser.profileid = talabatProfile.Id;
            elastixUser.timezonesidkey='America/Los_Angeles';
            elastixUser.username='testclassuser@talabat.com.test';
            elastixUser.FederationIdentifier='testclassuser@talabat.com.test';
            usersToInsert.add(elastixUser);

            insert usersToInsert;

            PermissionSetAssignment elastixPSA = new PermissionSetAssignment();
            elastixPSA.PermissionSetId = elastixPermissionSet.Id;
            elastixPSA.AssigneeId = apiElastixUser.Id;
            insert elastixPSA;
        }
        List<Business_Config__c> configs = new List<Business_Config__c>();

        configs.add(
                new Business_Config__c(
                        Process_Name__c = 'CaseEscalationLogic',
                        Business_Rule_Name__c = 'Escalation',
                        Business_Rule_Value__c = '{"Parameters":"Case_Reason_Level_3__c","Case_Reason_Level_3__c":"Check order status","Order status":"Check order status", "Queue":"Talabat_Cases_Escalation", "New Case":"FALSE"}',
                        Id_Country__c = bh.id,
                        Is_Active__c = true,
                        Record_Type_Id__c = 'Talabat',
                        Type__c = 'Process',
                        Parent__c = true
                ));
        configs.add(
                new Business_Config__c(
                        Process_Name__c = 'CaseEscalationLogic',
                        Business_Rule_Name__c = 'Sales Admin',
                        Business_Rule_Value__c = '{"Parameters":"Case_Reason_Level_3__c","Case_Reason_Level_3__c":"Printer damaged","Printer":"Printer damaged","Status":"Closed","Queue":"Talabat_<Country_Code>_Sales_Admin","New Case":"TRUE","New Case RecordType":"Talabat_Internal_Case","Fields":"Type","New.Type":"Sales Task"}',
                        Id_Country__c = bh.id,
                        Is_Active__c = true,
                        Record_Type_Id__c = 'Talabat',
                        Type__c = 'Process',
                        Parent__c = true
                )
        );
       configs.add(
                new Business_Config__c(
                        Process_Name__c = 'backToQueueLogic',
                        Business_Rule_Name__c = 'Foodpanda',
                        Business_Rule_Value__c = '{"Customer": {"<CountryCode>": "FP_CS_<CountryCode>_Email","Other": "FP_CS_Team_Lead"}, "Partner": {"<CountryCode>": "FP_PS_<CountryCode>_Email","Other": "FP_CS_Team_Lead"}}',
                        Id_Country__c = hk.id,
                        Is_Active__c = true,
                        Record_Type_Id__c = 'Global_Config',
                        Type__c = 'Process',
                        Parent__c = true
                )
        );
              configs.add(
                new Business_Config__c(
                        Process_Name__c = 'backToQueueLogic',
                        Business_Rule_Name__c = 'PedidosYa',
                        Business_Rule_Value__c = '{ "Customer": { "All": "PY_Customer_Request" }, "Partner":{"All":"PY_Restaurant_Request"}}',
                        Id_Country__c = hk.id,
                        Is_Active__c = true,
                        Record_Type_Id__c = 'Global_Config',
                        Type__c = 'Process',
                        Parent__c = false
                )
        );
        configs.add(
                new Business_Config__c(
                        Process_Name__c = 'backToQueueLogic',
                        Business_Rule_Name__c = 'Status',
                        Business_Rule_Value__c = 'New Answer,Re-Open',
                        Id_Country__c = hk.id,
                        Is_Active__c = true,
                        Record_Type_Id__c = 'Global_Config',
                        Type__c = 'Process',
                        Parent__c = false
                )
        );
        configs.add(
                new Business_Config__c(
                        Process_Name__c = 'backToQueueLogic',
                        Business_Rule_Name__c = 'TeamLeadQueues',
                        Business_Rule_Value__c = 'FP_CS_Team_Lead',
                        Id_Country__c = hk.id,
                        Is_Active__c = true,
                        Record_Type_Id__c = 'Global_Config',
                        Type__c = 'Process',
                        Parent__c = false
                )
        );

		String businesRuleValue= '{"Parameters":"Case_Reason_Level_3__c,CLRThroughCustomSetting",';
        businesRuleValue+= '"Case_Reason_Level_3__c":"Service_Recovery_Escalation__c.CLR3__c",';
        businesRuleValue+='"CLRThroughCustomSetting":"TRUE", "Type":"APAC-Recovery",'; 
        businesRuleValue+='"CLRThroughCustomSettingName":"Service_Recovery_Escalation__c",';
        businesRuleValue+='"Language_Code__c":"en-MY,en-SG,en-PH,en-HK,zh-HK,en-TW,zh-TW,en-TH,';
        businesRuleValue+='th-TH,en-PK,en-BD,en-MM,my-MM,en-LA,lo-LA,en-KH,km-KH",';
        businesRuleValue+='"Country_Queue":"MY:en_XX,PH:en_XX,TW:zh_TW,HK:zh_HK,SG:en_XX,KH:km_KH",';
        businesRuleValue+='"Language_Queue":"en-MY:en_XX,en-SG:en_XX,en-PH:en_XX,en-HK:en_XX,';
        businesRuleValue+='en-TW:en_XX,en-TH:en_XX,en-PK:en_XX,en-BD:en_XX,en-MM:en_XX,en-LA:en_XX,';
        businesRuleValue+='en-KH:en_XX,my-MM:my_MM,th-TH:th_TH,zh-TW:zh_TW,zh-HK:zh_HK,lo-LA:lo_LA,';
        businesRuleValue+='km-KH:km_KH", "Status":"Resolved","Queue":"FP_CS_Recovery_<Language_Code>",';
        businesRuleValue+='"Exclude This Rule":"true","Exclude Rule Criteria":"isalreadyresolved__c","IsAlreadyResolved__c":"true",';
        businesRuleValue+='"Additional Cases": "Refund",';
        businesRuleValue+='"New Case":"TRUE", "New Case RecordType":"FP_Inbound_Case",';
        businesRuleValue+='"Fields":"Type,Origin,Case_Reason_Level_1__c,Case_Reason_Level_2__c,';
        businesRuleValue+='Case_Reason_Level_3__c,Language_Code__c,Order_Number__c",';
        businesRuleValue+='"New.Type":"Customer","New.Origin":"Internal","New.Case_Reason_Level_1__c":"Parent.Case_Reason_Level_1__c",';
        businesRuleValue+='"New.Case_Reason_Level_2__c":"Parent.Case_Reason_Level_2__c",';
        businesRuleValue+='"New.Case_Reason_Level_3__c":"Parent.Case_Reason_Level_3__c",';
        businesRuleValue+='"New.Country__c":"Parent.Country__c", "New.Language_Code__c":"Parent.Language_Code__c",';
        businesRuleValue+='"New.Order_Number__c":"Parent.Order_Number__c"}';
        configs.add(
                new Business_Config__c(
                        Process_Name__c = 'CaseEscalationLogic',
                        Business_Rule_Name__c = 'APAC-Recovery',
                        Business_Rule_Value__c = businesRuleValue,
                        Id_Country__c = de.id,
                        Is_Active__c = true,
                        Record_Type_Id__c = 'Foodpanda',
			Type__c = 'Process',
                        Parent__c = true
                )
        );
        businesRuleValue ='{"Parameters":"Partial_Refund_Amount__c","Partial_Refund_Amount__c":"NOTNULL",';
        businesRuleValue += '"Queue":"Pakistan-FP_PK_Customer_Refunds,Bangladesh-FP_BD_Customer_Refunds,Laos-FP_LA_Customer_Refunds,';
        businesRuleValue += 'Cambodia-FP_KH_Customer_Refunds,Myanmar-FP_MM_Customer_Refunds,Others-FP_APAC_Customer_Refunds",';
        businesRuleValue +='"Exclude This Rule":"true","Exclude Rule Criteria":"status","Status":"NOTIN::Resolved",';
        businesRuleValue += '"New Case":"TRUE","New Case RecordType":"Global_CS_Refunds_Case",';
        businesRuleValue += '"Fields":"Type,Case_Reason__c,Partial_Refund_Amount__c,Order_Number__c,';
        businesRuleValue += 'Partial_Refund_Type__c,Voucher_Severity__c,Customer_ID__c",';
        businesRuleValue += '"New.Type":"Refund","New.Case_Reason__c":"Customer Refund","New.Partial_Refund_Amount__c":"Parent.Partial_Refund_Amount__c",';
        businesRuleValue += '"New.Partial_Refund_Type__c":"Parent.Partial_Refund_Type__c","New.Order_Number__c":"Parent.Order_Number__c",';
        businesRuleValue += '"New.Voucher_Severity__c":"Parent.Voucher_Severity__c","New.Customer_ID__c":"Parent.Customer_ID__c"}';
        configs.add(
                new Business_Config__c(
                        Process_Name__c = 'CaseEscalationLogic',
                        Business_Rule_Name__c = 'Refund',
                        Business_Rule_Value__c = businesRuleValue,
                        Id_Country__c = de.id,
                        Is_Active__c = true,
                        Record_Type_Id__c = 'Foodpanda',
                        Type__c = 'Process',
                        Parent__c = true
                )
        );
        
        insert configs;
       
        Case aCase = UnitTestDataFactory.createCase(acco, 'New', 'Customer', '', '', bh, 'Talabat_Inbound_Case', 'Testing Escalation');
        aCase.Platform__c='Talabat';
        
        Case a2Case = UnitTestDataFactory.createCase(acco, 'New', 'Customer', '', '', bh, 'Talabat_Inbound_Case', 'Testing Escalation');
        a2Case.Platform__c='Talabat';
        
        Case aCase2 = UnitTestDataFactory.createCase(acco, 'New', 'Customer', '', '', bh, 'FP_Inbound_Case', 'Testing Country Validation');
        aCase2.AccountId=null;
        aCase2.Platform__c='Foodpanda';
        aCase2.Country__c=null;
        
        Case caserec1 = UnitTestDataFactory.createCase(acco, 'New', 'Customer', '', '', tw, 'FP_Inbound_Case', 'SCC-303-0');
        caserec1.Platform__c='Foodpanda';
        Case caserec2 = UnitTestDataFactory.createCase(acco, 'New', 'Customer', '', '', tw, 'FP_Inbound_Case', 'SCC-303-1');
        caserec2.Platform__c='Foodpanda';           
        Case caserec3 = UnitTestDataFactory.createCase(acco, 'New', 'Customer', '', '', tw, 'FP_Inbound_Case', 'SCC-303-2');
        caserec3.Platform__c='Foodpanda';  
       
        Case b2QCase = UnitTestDataFactory.createCase(bcco, 'New', '', '', '', hk, 'FP_Inbound_Case', 'Testing BackToQueue');
        b2QCase.Platform__c='Foodpanda';
        b2QCase.Type = 'Customer';
        b2QCase.Status = 'New';
        b2QCase.Country__c = 'Hong Kong';

        Case b2QCase2 = UnitTestDataFactory.createCase(bcco, 'New', '', '', '', hk, 'FP_Inbound_Case', 'Testing BackToQueue');
        b2QCase2.Platform__c='Foodpanda';
        b2QCase2.Type = 'Customer';
        b2QCase2.Country__c = '';

        Case b2QCase3 = UnitTestDataFactory.createCase(dcco, 'New', '', '', '', ar, 'PY_Inbound_Case', 'Testing BackToQueue');
        b2QCase3.Platform__c='PedidosYa';
        b2QCase3.Type = 'Customer';
        b2QCase2.Country__c = '';


        insert new List<Case>{b2QCase,b2QCase2,b2QCase3,aCase,aCase2,a2Case,caserec1,caserec2,caserec3};        
        
        List<String> escalationReasonsApacRec = new List<String>();
        escalationReasonsApacRec.add('Order status:Check order status');
        escalationReasonsApacRec.add('Order status:Order not assigned to a rider');
        escalationReasonsApacRec.add('Order status:Complain about late order');
      
        List<Service_Recovery_Escalation__c> servEscRecs = UnitTestDataFactory.createServiceEscCustomSetting('APAC-Recovery','Foodpanda',escalationReasonsApacRec);
        insert servEscRecs;

    }

    /**
     * @description Testing logic for case escalation to a queue not for sales
     */
    @IsTest
    public static void test_caseEscalationNotToSales() {

        Case aCase = [SELECT Id FROM Case WHERE Platform__c='Talabat' LIMIT 1];

        test.startTest();
        aCase.Case_Reason_Level_1__c='Live Order Process';
        aCase.Case_Reason_Level_2__c='Order Status';
        aCase.Case_Reason_Level_3__c='Check Order Status';
        aCase.Description='Testing Escalation';
        Group q=[SELECT Id FROM Group WHERE DeveloperName='Talabat_Cases_Escalation' AND Type='Queue'];
        try {
            aCase.Escalate__c=true;
            update aCase;
        } catch (Exception e) {}
        test.stopTest();
        aCase = CaseSelector.getCaseDetailsById(aCase.Id);
        system.assertEquals(q.Id,aCase.OwnerId);
    }

    /**
     * @description Testing logic for case escalation to a queue for sales
     */
    @IsTest
    public static void test_caseEscalationToSales() {
        Case aCase = [SELECT Id FROM Case WHERE Platform__c='Talabat' LIMIT 1];
        test.startTest();
        aCase.Account=null;
        aCase.Country__c='Bahrain';
        aCase.Platform__c='Talabat';
        aCase.Type='Partner';
        acase.Case_Reason_Level_1__c='Technical Inquiry';
        aCase.Case_Reason_Level_2__c='Printer';
        aCase.Case_Reason_Level_3__c='Printer Damaged';
        aCase.Description='Testing Escalation';
        try {
            aCase.Escalate__c=true;
            update aCase;
        } catch (Exception e) {system.debug(e);}
        test.stopTest();
        aCase = CaseSelector.getCaseDetailsById(aCase.Id);
        system.assertEquals('Closed',aCase.Status);
        List<Case> cases= [SELECT Id FROM Case WHERE ParentId=:acase.id LIMIT 1];
        system.assertEquals(1,cases.size());
    }

    @IsTest
    public static void test_CountryValidationPositive() {
        Case aCase = [SELECT Id,Country__c,Platform__c FROM Case WHERE Subject='Testing Country Validation' AND Platform__c='Foodpanda'];
        User romUser = [SELECT Id FROM User WHERE UserRoleId IN (SELECT Id FROM UserRole WHERE DeveloperName='RO_Test_Role')];
        aCase.OwnerId = romUser.Id;
        update aCase;
        test.startTest();
        system.runAs(romUser) {
            aCase.AccountId = null;
            aCase.Country__c = 'Romania';
            update aCase;
        }
        test.stopTest();
        system.assertEquals('Romania',aCase.Country__c);
    }

    @IsTest
    public static void test_CountryValidationNegative() {
        Case aCase = [SELECT Id,Country__c,Platform__c FROM Case WHERE Subject='Testing Country Validation' AND Platform__c='Foodpanda'];
        User romUser = [SELECT Id FROM User WHERE UserRoleId IN (SELECT Id FROM UserRole WHERE DeveloperName='RO_Test_Role')];
        aCase.OwnerId = romUser.Id;
        update aCase;
        test.startTest();
        system.runAs(romUser) {
            aCase.AccountId = null;
            aCase.Country__c = 'Bahrain';
            try {
                update aCase;
            } catch (Exception e) {
                Boolean isErrorCountryValidation = e.getMessage().contains(Label.Case_Platform_Country_Error);
                system.assertEquals(true, isErrorCountryValidation);
            }
        }
        test.stopTest();
    }
    /**
    * @description Test method1 for  CaseSetups
    */
    @istest
    public static void  test_CaseSetups_Talabat() {

        UnitTestDataFactory.getRecordtypeValues();

        test.startTest();
        // Country__c bh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        // insert bh;

        Country__c bh = CountrySelector.getCountryByName('Bahrain');


        Company__c com = UnitTestDataFactory.createCompany('Talabat2', 'Talabat', bh);
        insert com;

        Account acco3 = UnitTestDataFactory.createAccount('TEST3', bh, 'Talabat_Account');
        insert acco3;

        Business_Config__c businessConfig0_2 = UnitTestDataFactory.createBusinessConfig('CaseSetups_New', 'Process', 'Talabat_Inbound_Case','{"1":{"Criteria":"Id","Id":"ISNEW","Entity":"Talabat Inbound"},"2":{"Criteria":"Origin&&Type&&EmailToAddress__c","Origin":"Email","Type":"ISBLANK","EmailToAddress__c":"ISNOTBLANK","Entity":"Talabat Inbound"},"3":{"Criteria":"Origin&&Country__c","Origin":"Email","Country__c":"ISCHANGED","Entity":"Talabat Inbound" },"4":{"Criteria":"Origin&&Country__c","Origin":"ISNOTEQUALS(Email,Chat)","Country__c":"ISCHANGED","Entity":"Talabat Inbound" }}', bh.Id, 'Global_Config', true, false);
        insert businessConfig0_2;


        Map<String, Business_Config__c> bconfMap_3 = new Map<String, Business_Config__c>{businessConfig0_2.Business_Rule_Name__c => businessConfig0_2};
        Map<String, Map<String, Business_Config__c>> bconfMap_3f = new Map<String, Map<String, Business_Config__c>>{businessConfig0_2.Record_Type_Id__c => bconfMap_3};
        LibBusinessConfig.setMotherOfAllBusinessMaps(new Map<String, Map<String, Map<String, Business_Config__c>>>{businessConfig0_2.Process_Name__c => bconfMap_3f});

        List<Case> caseList = new List<Case>();

        Case bcase = UnitTestDataFactory.createCase(acco3, 'New', null, '', 'Email', bh, 'Talabat_Inbound_Case', 'Test Talabat');
        bcase.EmailToAddress__c ='customercare@otlob.com';
        caseList.add(bcase);

        Case dcase = UnitTestDataFactory.createCase(acco3, 'New', null, '', 'Email', bh, 'Talabat_Inbound_Case', 'Test Talabat');
        dcase.Platform__c ='Otlob';
        caseList.add(dcase);

        Database.insert(caseList, True);

        Case case1 = CaseSelector.getCaseDetailsById(bcase.Id);
        Case case2 = CaseSelector.getCaseDetailsById(dcase.Id);

        system.assertEquals('Otlob',case1.Platform__c);
        system.assertEquals('Talabat',case2.Platform__c);

        test.stopTest();

    }

    /**
     * @description Test method2 for  CaseSetups
     */
    @istest
    public static void  test_CaseSetups_Peya() {

        UnitTestDataFactory.getRecordtypeValues();

        Country__c ar = CountrySelector.getCountryByName('Argentina');

        Company__c com3 = UnitTestDataFactory.createCompany('PedidosYa', 'PedidosYa', ar);
        insert com3;

        Account acco2 = UnitTestDataFactory.createAccount('TEST2', ar, 'PY_Account');
        insert acco2;

        Business_Config__c businessConfig0_1 = UnitTestDataFactory.createBusinessConfig('CaseSetups_New', 'Process', 'PY_Inbound_Case','{"1":{"Criteria":"Id","Id":"ISNEW","Entity":"PY Inbound"},"2":{"Criteria":"Origin&&EmailToAddress__c","Origin":"Email","EmailToAddress__c":"ISNOTBLANK","Entity":"PY Inbound"},"3":{"Criteria":"Country__c","Country__c":"ISCHANGED","Entity":"PY Inbound"}}', ar.Id, 'Global_Config', true, true);
        insert businessConfig0_1;

        Map<String, Business_Config__c> bconfMap_1 = new Map<String, Business_Config__c>{businessConfig0_1.Business_Rule_Name__c => businessConfig0_1};
        Map<String, Map<String, Business_Config__c>> bconfMap_1f = new Map<String, Map<String, Business_Config__c>>{businessConfig0_1.Record_Type_Id__c=> bconfMap_1};
        LibBusinessConfig.setMotherOfAllBusinessMaps(new Map<String, Map<String, Map<String, Business_Config__c>>>{businessConfig0_1.Process_Name__c => bconfMap_1f});

        test.startTest();

        Group q2 = new Group();
        q2.Name = 'PY_Restaurant_Request';
        q2.Type = 'Queue';

        Group q3 = new Group();
        q3.Name = 'PY_Dispatch_Escalation_Customers';
        q3.Type = 'Queue';

        Group q4 = new Group();
        q4.Name = 'PY_Dispatch_Escalations';
        q4.Type = 'Queue';


        insert new List<Group>{q2,q3,q4};

        User u = [SELECT Id FROM User WHERE Id=:userinfo.getUserId()];
        system.runAs(u) {
            QueueSObject qSObj2 = new QueueSObject(SobjectType = 'Case', QueueId = q2.Id);
            QueueSObject qSObj3 = new QueueSObject(SobjectType = 'Case', QueueId = q3.Id);
            QueueSObject qSObj4 = new QueueSObject(SobjectType = 'Case', QueueId = q4.Id);

            insert new List<QueueSObject>{qSObj2,qSObj3,qSObj4};
        }

        List<Case> caseList = new List<Case>();

        Case acase = UnitTestDataFactory.createCase(acco2, 'New', '', '', 'Email', ar, 'PY_Inbound_Case', 'DP_CUSTOMER_CANCEL');
        acase.Type = null;
        acase.OwnerId=q2.Id;
        acase.Subject = 'DP_Test';
        acase.EmailToAddress__c = 'contactos@appetito24.com';
        caseList.add(acase);

        Case bcase = UnitTestDataFactory.createCase(acco2, 'New', '', '', 'Email', ar, 'PY_Inbound_Case', 'DP_CUSTOMER_CANCEL');
        caseList.add(bcase);


        Database.insert(caseList, True);

        bcase.Type = null;
        bcase.Country__c = '';
        bcase.Subject = 'DP_REDELIVERY_FAILED';
        bcase.EmailToAddress__c = 'soporte@pedidosya.com;  test@test.com';
        update bcase;

        Case pyCase = CaseSelector.getCaseDetailsById(acase.Id);
        Case pyCase2 = CaseSelector.getCaseDetailsById(bcase.Id);
        Group g2= GroupSelector.getQueueByDeveloperName('PY_Dispatch_Escalations');

        system.assertEquals('Appetito24',pyCase.Platform__c);
        system.assertEquals('Panamá',pyCase.Country__c);
        system.assertEquals('Customer',pyCase.Type);
        system.assertEquals(g2.Id,pyCase.OwnerId);
        system.assertEquals(u.Id,pyCase2.OwnerId);
        system.assertEquals('Partner',pyCase2.Type);

        test.stopTest();
    }

    /**
    * @description Test method1 for  CaseSetups
    */
    @istest
    public static void  test_CaseSetups_FP() {

        UnitTestDataFactory.getRecordtypeValues();

        test.startTest();
        // Country__c hk = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'HKD');
        // Database.insert(hk);

        Country__c hk = CountrySelector.getCountryByName('Hong Kong');

        Company__c com = UnitTestDataFactory.createCompany('Foodpanda', 'Foodpanda', hk);
        insert com;

        Account acco3 = UnitTestDataFactory.createAccount('TEST3', hk, 'FP_Account');
        insert acco3;

        Business_Config__c businessConfig0_2 = UnitTestDataFactory.createBusinessConfig('CaseSetups_New', 'Process', 'FP_Inbound_Case','{"1":{ "Criteria":"Origin&&Type&&EmailToAddress__c","Origin":"Email","Type":"ISBLANK","EmailToAddress__c":"ISNOTBLANK","Entity":"FP Inbound" }}', hk.Id, 'Global_Config', true, false);
        insert businessConfig0_2;

        Group q2 = new Group();
        q2.Name = 'FP_CS_HK_Email';
        q2.Type = 'Queue';

        Group q3 = new Group();
        q3.Name = 'FP_CS_PK_Email';
        q3.Type = 'Queue';

        insert new List<Group>{q2,q3};

        User u = [SELECT Id FROM User WHERE Id=:userinfo.getUserId()];
        system.runAs(u) {
            QueueSObject qSObj2 = new QueueSObject(SobjectType = 'Case', QueueId = q2.Id);
            QueueSObject qSObj3 = new QueueSObject(SobjectType = 'Case', QueueId = q3.Id);
            insert new List<QueueSObject>{qSObj2,qSObj3};
        }

        Map<String, Business_Config__c> bconfMap_2 = new Map<String, Business_Config__c>{businessConfig0_2.Business_Rule_Name__c => businessConfig0_2};
        Map<String, Map<String, Business_Config__c>> bconfMap_2f = new Map<String, Map<String, Business_Config__c>>{businessConfig0_2.Record_Type_Id__c => bconfMap_2};
        LibBusinessConfig.setMotherOfAllBusinessMaps(new Map<String, Map<String, Map<String, Business_Config__c>>>{businessConfig0_2.Process_Name__c => bconfMap_2f});

        List<Case> caseList = new List<Case>();

        Case ecase = UnitTestDataFactory.createCase(acco3, 'New', null, '', 'Email', hk, 'FP_Inbound_Case', 'Test FP');
        ecase.EmailToAddress__c = 'support@foodpanda.pk; test@test.com';
        caseList.add(ecase);
        Database.insert(caseList, True);

        ecase.Country__c = '';
        ecase.Type ='';
        update ecase;

        Case fpCase = CaseSelector.getCaseDetailsById(ecase.Id);
        Group g1= GroupSelector.getQueueByDeveloperName('FP_CS_PK_Email');

        system.assertEquals('Pakistan',fpcase.Country__c);
        system.assertEquals(g1.Id,fpCase.OwnerId);

        Case deleteCase = UnitTestDataFactory.createCase(acco3, 'New', null, '', 'Email', hk, 'FP_Inbound_Case', 'Test FP');
        insert deleteCase;

        delete deleteCase;

        test.stopTest();
    }
    @isTest
    public static void test_backToQueue(){
        List<Case> CaseList = [SELECT Id,Queue_ID__c,OwnerId FROM Case WHERE Platform__c='Foodpanda' Limit 2];
        Case  peyaCase = [SELECT Id,Queue_ID__c,OwnerId FROM Case WHERE Platform__c='PedidosYa' Limit 1];


        test.startTest();

        Group q2=[SELECT Id FROM Group WHERE DeveloperName='FP_CS_HK_Email' AND Type='Queue'];
        Group q3=[SELECT Id FROM Group WHERE DeveloperName='FP_CS_Team_Lead' AND Type='Queue'];
        Group q4=[SELECT Id FROM Group WHERE DeveloperName='PY_Customer_Request' AND Type='Queue'];

            CaseList[1].Country__c = '';
            CaseList[1].Status = 'New Answer';
            CaseList[1].Queue_ID__c = q3.Id;
            peyaCase.Status =  'New Answer';
            CaseList.add(peyaCase);

            update CaseList;

        Case aCase = CaseSelector.getCaseDetailsById(CaseList[0].Id);
        Case bCase = CaseSelector.getCaseDetailsById(CaseList[1].Id);
        Case pCase = CaseSelector.getCaseDetailsById(peyaCase.Id);

        test.stopTest();

        system.assertEquals(q2.Id,aCase.Queue_ID__c);
        system.assertEquals(q3.Id,bCase.Queue_ID__c);
        system.assertEquals(bCase.Queue_ID__c,bCase.OwnerId);
        system.assertEquals(q4.Id,pCase.Queue_ID__c);

    }
    /**
     * @description Testing logic for case assignment to agent based on elastix extension
     */	
	@IsTest
    public static void test_elastixCaseAssignment() {
        test.startTest();
        User apiUser = [SELECT Id FROM User WHERE username='api.elastix2@talabat.com.test' LIMIT 1];
        User elastixUser = [SELECT Id FROM User WHERE username='testclassuser@talabat.com.test' LIMIT 1];
        Case elastixCase = new Case();
        system.runAs(apiUser){

            elastixCase.Vendor_Phone_Number__c = '123456789';
            elastixCase.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Talabat Inbound Case').getRecordTypeId();
            elastixCase.Elastix_Agent_Extension__c = '9876';
            elastixCase.Subject='Test Class Case';
            elastixCase.Description='Test Class Case';
            insert elastixCase;
        }
        test.stopTest();

        Case insertedElastixCase = [SELECT Id,OwnerId,Status FROM Case WHERE Elastix_Agent_Extension__c='9876'];

        system.assertEquals(insertedElastixCase.OwnerId,elastixUser.id);
        system.assertEquals('In Progress',insertedElastixCase.Status);
    }
	
	 /**
     * @description Testing logic for case escalation to a queue for apac service recovery
     */
    @IsTest
    public static void test_caseEscalationForApacServiceRecovery() {
        
        List<Case> aCase = [SELECT Id,subject,type,Country__c FROM Case WHERE Platform__c='Foodpanda' AND Subject LIKE 'SCC-303%'];
        system.assertEquals(3,aCase.size());
       
        List<Case> updatedCase = new List<Case>();
        test.startTest(); 
        //Only Service Recovery Case and should create 1 service recovery case       
		aCase[0].Account=null;
		acase[0].Case_Reason_Level_1__c='Live Order Process';
		aCase[0].Case_Reason_Level_2__c='Order status';
		aCase[0].Case_Reason_Level_3__c='Check order status';
		aCase[0].Country__c='Taiwan';
		aCase[0].Description='SCC-303 0';
		aCase[0].Customer_Email__c = 'Test@test.com';
		aCase[0].Customer_Name__c = 'SCC-300 test';
		aCase[0].Escalate__c=true;
		aCase[0].Order_Number__c = '0000-0000';
		updatedCase.add(aCase[0]);           
      
      
        //Service Recovery plus Refunds Case and should create 1 refund and 1 service recovery case
		aCase[1].Account=null;
		acase[1].Case_Reason_Level_1__c='Live Order Process';
		aCase[1].Case_Reason_Level_2__c='Order status';
		aCase[1].Case_Reason_Level_3__c='Order not assigned to a rider';
		aCase[1].Country__c='Taiwan';
		aCase[1].Description='SCC-303 2';
		aCase[1].Partial_Refund_Type__c = 'Online payment' ;
		aCase[1].Partial_Refund_Amount__c =12;
		aCase[1].Customer_Email__c = 'Test@test.com';
		aCase[1].Customer_Name__c = 'SCC-302 test';
		aCase[1].Escalate__c=true;
		aCase[1].Order_Number__c = '0000-0000';
		updatedCase.add(aCase[1]);               
        
        try {           
            update  updatedCase;
        } catch (Exception e) {system.debug(e);}
        test.stopTest();        
        Integer checkChildCaseCount = [Select count() from Case where recordtype.DeveloperName in('Global_CS_Refunds_Case','FP_Inbound_Case') and status='New' and ParentId!=null];
        system.assertEquals(3,checkChildCaseCount); 
            
    }
	
	@IsTest
    public static void test_onlyRefundEscalationWithApacServiceRecovery() {
        
        List<Case> aCase = [SELECT Id,subject,type,Country__c FROM Case WHERE Platform__c='Foodpanda' AND Subject LIKE 'SCC-303%' LIMIT 1];
        system.assertEquals(1,aCase.size());

        List<Case> updatedCase = new List<Case>();
        test.startTest(); 
        //Only Refunds Case and should create 1 refund case        
        aCase[0].Account=null;
        acase[0].Case_Reason_Level_1__c='Live Order Process';
        aCase[0].Case_Reason_Level_2__c='Order status';
        aCase[0].Case_Reason_Level_3__c='Complain about late order';
        aCase[0].Country__c='Taiwan';
        aCase[0].Description='SCC-303 2';
        aCase[0].Partial_Refund_Type__c = 'Online payment' ;
        aCase[0].Partial_Refund_Amount__c =12;
        aCase[0].Status='Resolved';
        aCase[0].Customer_Email__c = 'Test@test.com';
        aCase[0].Customer_Name__c = 'SCC-303 2 test';
        aCase[0].Order_Number__c = '0000-0000';
        updatedCase.add(aCase[0]);           
        
        try {           
            update  updatedCase;
        } catch (Exception e) {system.debug(e);}
        test.stopTest();        
        Integer checkChildCaseCount = [Select count() from Case where recordtype.DeveloperName in('Global_CS_Refunds_Case') and status='New' and ParentId!=null];
         
        system.assertEquals(1,checkChildCaseCount); 
            
    }
}
