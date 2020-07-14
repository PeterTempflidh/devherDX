@isTest
private class CaseControllerLightningTest {
    public static string TYPE = '';
	private static AuraComponentVisibilityControl__c  compVisCustSetting;
	
    @testsetup
    static void testSetup(){
        UnitTestDataFactory.getRecordtypeValues();

        User usr = [Select id,name from User where Id = :UserInfo.getUserId()];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE  Name ='Exclude_from_Validation'];
        Group q = new Group( Name = 'DE Special Cases', Type = 'Queue' );
        insert q;
        PermissionSetAssignment psa = new PermissionSetAssignment();
        System.RunAs(usr)
        {
            Test.startTest();
            GroupMember qMember = new GroupMember(GroupId=q.id,UserOrGroupId=userinfo.getUserId());
            insert qMember;
            insert new queuesobject (queueid=q.id, sobjecttype='Case');
            psa.PermissionSetId=ps.Id;
            psa.AssigneeId=usr.id;
            insert psa;
            Test.stopTest();
        }
        Country__c c = UnitTestDataFactory.createCountry('UY','Uruguay', 'UYU');
        Company__c com = UnitTestDataFactory.createCompany('testcompany', 'UY', c);
        User ccTestUser = UnitTestDataFactory.createUser('PY Customer Care', 'escalationtestuser@deliveryhero.com', 'PY_UY','PY');
        insert new List<sObject> { c,com,ccTestUser };

        List<Account> accList = UnitTestDataFactory.createAccounts(1,c,'PY_Account');
        accList[0].Backend_ID__c = '12345';
        insert accList;
        Account acc = accList[0];

        // create Integration config
        Integration_Config__c config = new Integration_Config__c();
        config.AuthenticationToken__c 	= '123455';
        config.AuthTokenExtension__c	= '1234677';
        config.Endpoint__c				= 'https://dummy.api.stg.testdatafridge.com/v1/global-entity-ids/@ENTITY_ID/order-status-aggregates';
        config.Timeout__c				= 10000;
        config.name						= 'DataFridgeOrderDetails';

        insert config;

        String jsonResultCase = AccountControllerLightning.newCallCase(acc.Id);
        ResultWrapper res1 = ResultWrapper.parse(jsonResultCase);
        System.assertNotEquals(null, res1.Id, 'Case is not created');

        Case chatCase = new Case();
        chatCase = UnitTestDataFactory.createCase(acc,'New','Customer','','Chat',c,'PY_Inbound_Case','My Problem');
        chatCase.Case_Reason_Level_1__c = 'Across Journey';
        chatCase.Case_Reason_Level_2__c = 'Feedback';
        chatCase.Case_Reason_Level_3__c = 'Negative';		
        chatCase.OwnerId=q.Id;
        insert chatCase;

        Case chatCase2 = new Case();
        chatCase2 = UnitTestDataFactory.createCase(acc,'New','Customer','','Chat',c,'PY_Inbound_Case','My Problem');
        chatCase2.Case_Reason_Level_1__c = 'Across Journey';
        chatCase2.Case_Reason_Level_2__c = 'Feedback';
        chatCase2.Case_Reason_Level_3__c = 'Negative';
        chatCase2.OwnerId=ccTestUser.Id;
        insert chatCase2;

        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='platformEntityMapping ',Business_Rule_Value__c='{"PedidosYa_Uruguay":"PY_UY","PizzaDE":"PD_DE"}',Id_Country__c=c.id,Is_Active__c=true,Parent__c=true,Process_Name__c='ChatBotConfigs',Record_Type_Id__c='Global_Config',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='hurrierDetails',Business_Rule_Value__c='[{"Platform":"PedidosYa","Uruguay":"https://uy.usehurrier.com//dispatcher/order_details/"}]',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='ChatBotConfigs',Record_Type_Id__c='Global_Config',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='orderDetailsLink',Business_Rule_Value__c='[{"Uruguay":"https://uy.usehurrier.com//dispatcher/order_details/"}]',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='ChatBotConfigs',Record_Type_Id__c='Global_Config',Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='customerDetailsLink',Business_Rule_Value__c='[{"Uruguay":"https://uy.usehurrier.com//dispatcher/order_details/"}]',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='ChatBotConfigs',Record_Type_Id__c='Global_Config',Type__c='Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='startDateMonths',Business_Rule_Value__c='12',Id_Country__c=c.id,Is_Active__c=true,Parent__c=true,Process_Name__c='ChatBotConfigs',Record_Type_Id__c='Global_Config',Type__c='Process');
        insert new List<Business_Config__c>{b1,b2,b3,b4,b5};
        system.runAs(usr){
            delete psa;
        }
		compVisCustSetting = UnitTestDataFactory.createAuraComponentVisibilityControlCustSetTestData();
    }

    @isTest
    static void testGetCurrentCaseReason() {
        Case newCase = [SELECT Id, RecordTypeId,Type,Case_Reason_Level_1__c,Case_Reason_Level_2__c,Case_Reason_Level_3__c FROM Case WHERE RecordType.DeveloperName='PY_Inbound_Case' LIMIT 1];
        Test.startTest();
        Case jsonResult = CaseControllerLightning.getCurrentCaseReason(newCase.Id);
        Test.stopTest();

        System.assertEquals(jsonResult.id,newCase.Id);
    }

    @isTest
    static void testGetCurrentCaseReasonNegative() {
        Test.startTest();
        Case jsonResult = CaseControllerLightning.getCurrentCaseReason('5001r00002qnLbj');
        Test.stopTest();

        System.assertEquals(null, jsonResult);
    }

    @isTest
    static void testGetCurrentCaseReasonNegative2() {
        Test.startTest();
        Case jsonResult = CaseControllerLightning.getCurrentCaseReason('Fake ID');
        Test.stopTest();

        System.assertEquals(null, jsonResult);
    }

    @IsTest
    private static void testGetUrlString() {
        String result = CaseControllerLightning.getUrlString('hurrierDetails',
                '[{"Platform":"PedidosYa","Uruguay":"https://uy.usehurrier.com//dispatcher/order_details/"}]', 'Pedidosya', 'Uruguay');
        System.assertEquals('https://uy.usehurrier.com//dispatcher/order_details/', result);
    }

    @IsTest
    private static void testGetUrlStringFail() {
        String result = CaseControllerLightning.getUrlString('hurrierDetails',
                '[]', 'Pedidosya', 'Uruguay');
        System.assertEquals('Not Found', result);
    }

    @isTest
    static void testGetAllPicklistValuesReason3_Positive() {
        Test.setMock(HttpCalloutMock.class, new MockCaseReason3ValueResponseGenerator(true,'Case Reason Level 3'));

        Case newCase = [SELECT Id, RecordTypeId,Type,Case_Reason_Level_1__c,Case_Reason_Level_2__c,Case_Reason_Level_3__c FROM Case WHERE RecordType.DeveloperName='PY_Inbound_Case' LIMIT 1];
        test.startTest();
        Boolean disabledButton=CaseControllerLightning.isCloseCaseButtonDisabled(newCase.Id);
        String res = CaseControllerLightning.getAllPicklistValuesReason3(newCase.Id);
        test.stopTest();
        system.assert(!disabledButton);
        System.assert(res != '[]');
    }

    @isTest
    static void testGetAllPicklistValuesReason3_Negative() {
        Test.setMock(HttpCalloutMock.class, new MockCaseReason3ValueResponseGenerator(false,'Case Reason Level 3'));

        Case newCase = [SELECT Id, RecordTypeId,Type,Case_Reason_Level_1__c,Case_Reason_Level_2__c,Case_Reason_Level_3__c FROM Case WHERE RecordType.DeveloperName='PY_Inbound_Case' LIMIT 1];
        test.startTest();
        String res = CaseControllerLightning.getAllPicklistValuesReason3(newCase.Id);
        test.stopTest();
        System.assert(res == '[]');
    }

    @isTest
    static void testCloseCase() {
        Case newCase = [SELECT Id, RecordTypeId,Type,Case_Reason_Level_1__c,Case_Reason_Level_2__c,Case_Reason_Level_3__c FROM Case WHERE RecordType.DeveloperName='PY_Inbound_Case' LIMIT 1];

        Test.startTest();
        CaseControllerLightning.closeCase(newCase.Id);
        Test.stopTest();

        newCase = [SELECT Id, Status, OwnerId FROM Case WHERE Id = :newCase.Id LIMIT 1];

        System.assertEquals(CaseConstants.statusClosed, newCase.Status, 'Status should be closed');
    }

    @IsTest
    static void testCloseNullCase() {
        Test.startTest();
        String result = CaseControllerLightning.closeCase('5001r00002qnLbj');
        Test.stopTest();
        System.assert(result.contains(Label.Case_not_found_for_id));
    }

    @isTest
    static void testCloseCaseFail() {
        Case newCase = CaseSelector.getCaseWithDynamicCondition(' Id != null ', 'AccountId').values()[0];
        Case qcCase = new Case( AccountId = newCase.AccountId,
                Status = 'New',
                RecordTypeId = LibRecordTypeHelper.getRecordTypeIdByDeveloperName('Case', 'PY_Entry_Case'),
                Type = 'Quality Check',
                Closed_Reason__c = 'Take Online is not possible'
        );
        insert qcCase;
        Test.startTest();
        CaseControllerLightning.closeCase(qcCase.Id);
        Test.stopTest();

        qcCase = CaseSelector.getCaseDetailsById(qcCase.Id);

        System.assertNotEquals(CaseConstants.statusClosed, qcCase.Status, 'Status should not be closed');
    }

    @isTest
    static void testGetCaseFromChat() {
        LiveChatVisitor visitor=new LiveChatVisitor();
        insert visitor;

        LiveChatTranscript chat = new LiveChatTranscript(
                Platform__c = 'LieferheldDE',
                Order_Number__c = '1234567890001',
                Email__c = 'test@deliveryhero.com',
                User_Name__c = 'test name',
                My_Problem__c = 'Kunde - Anderes Problem',
                Body='Hello',
                LiveChatVisitorId=visitor.id,
                ownerId=userinfo.getUserId()
        );

        insert chat;

        Test.startTest();
        String testCase = CaseControllerLightning.getCaseFromChat(chat.Id);
        Test.stopTest();

        System.assertNotEquals(null, testCase, 'Case json should be returned for this chat');
    }
	
	@isTest
    static void testGetCaseFromChatThroughCase() {
        Case newCase = [SELECT Id, RecordTypeId,Type,Case_Reason_Level_1__c,Case_Reason_Level_2__c,Case_Reason_Level_3__c FROM Case WHERE RecordType.DeveloperName='PY_Inbound_Case' LIMIT 1];
        system.assertEquals(newCase!=null, true);        
        Test.startTest();
        String testCase = CaseControllerLightning.getCaseFromChat(newCase.Id);
        Test.stopTest();
        System.assertNotEquals(null, testCase, 'Case json should be returned for this chat');
    }

    @isTest
    static void testTakeOwnership_1() {
        Case newCase = [SELECT Id FROM Case WHERE RecordType.DeveloperName='PY_Inbound_Case' LIMIT 1];
        User u=[SELECT Id FROM User Where id=:UserInfo.getUserId()];
        Test.startTest();
        system.runAs(u) {
            GroupMember gm = [SELECT Id FROM GroupMember LIMIT 1];
            delete gm;
        }
        String testCase = CaseControllerLightning.takeOwnership(newCase.Id);
        Test.stopTest();

        System.assertNotEquals(null, testCase, 'Case json should be returned for this chat');
    }

    @isTest
    static void testTakeOwnership_2() {
        List<Case> allCases = CaseSelector.getAll();
        Test.startTest();
        for (Case cs: allCases) {
            String testCase = CaseControllerLightning.takeOwnership(cs.Id);
            System.assertNotEquals(null, testCase, 'Case json should be returned for this chat');
        }
        Test.stopTest();
    }

    @isTest
    static void testTakeOwnership_3(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Case newCase = new Case();
        newCase.AccountId = acc.Id;
        newCase.OwnerId = UserInfo.getUserId();
        newCase.Origin = 'Phone';
        insert newCase;

        Test.startTest();
        String testCase = CaseControllerLightning.takeOwnership(newCase.Id);
        Test.stopTest();

        System.assertNotEquals(null, testCase, 'Case json should be returned for this chat');
    }
    
    @isTest
    static void testTakeOwnership_4(){

        Group q = new Group( Name = 'FP Editorial Team', Type = 'Queue' );
        insert q;

        Group q1 = new Group( Name = 'SE Photo Team', Type = 'Queue' );
        insert q1;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue1 = new QueueSObject(QueueID = q.id, SObjectType = 'Case');
            insert testQueue1;
            
            QueuesObject testQueue2 = new QueueSObject(QueueID = q1.id, SObjectType = 'Case');
            insert testQueue2;            
        }
        
        UnitTestDataFactory.getRecordtypeValues();
        Country__c cd = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'EUR');
        insert cd;

        Account acc = [SELECT Id FROM Account LIMIT 1];

        acc.Mark_up__c = 'In percentage';
        acc.Mark_up_Value__c = 11;
        acc.Vendor_Grade__c = 'A';
        update acc;

        Case acase2 = UnitTestDataFactory.createCase(acc, 'New', 'Menu Change', 'Full Menu', '', cd, 'SE_Entry_Case', '');
        acase2.OwnerId = q1.Id;
        insert acase2;
        
        Case newCase = new Case();
        newCase.AccountId = acc.Id;
        newCase.OwnerId = q.Id;
        newCase.Origin = 'Phone';
        insert newCase;

        Case newCaseTemp;

        Test.startTest();
        String testCase = CaseControllerLightning.takeOwnership(newCase.Id);
        String testCase2 = CaseControllerLightning.takeOwnership(acase2.Id);
        Test.stopTest();

        System.assertNotEquals(null, testCase, 'Case json should be returned for this chat');
    }

    @isTest
    static void testTakeOwnership_5(){
        Group q1 = new Group( Name = 'CZ Photography', Type = 'Queue' );
        insert q1;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue1 = new QueueSObject(QueueID = q1.id, SObjectType = 'Case');
            insert testQueue1;        
        }

        Country__c cz = UnitTestDataFactory.createCountry('CZ', 'Czech Republic', 'CZK');
        insert cz;

        Account acc = [SELECT Id FROM Account LIMIT 1];

        acc.Mark_up__c = 'In percentage';
        acc.Mark_up_Value__c = 11;
        acc.Vendor_Grade__c = 'A';
        update acc;

        Case case1 = UnitTestDataFactory.createCase(acc, 'New', 'Dish Level Photo', 'Full Menu', '', cz, 'CZ_Entry_Case', '');
        case1.OwnerId = q1.Id;
        insert case1;

        Test.startTest();
        String testCase1 = CaseControllerLightning.takeOwnership(case1.Id);
        Test.stopTest();

        System.assert(testCase1.contains(Label.BackToQueue_successful));

    }

    @isTest
    static void testGetAllPicklistValues(){
        Test.setMock(HttpCalloutMock.class, new MockCaseReason3ValueResponseGenerator(true,'Type'));
        Case newCase = [SELECT Id, RecordTypeId,Type,Case_Reason_Level_1__c,Case_Reason_Level_2__c,Case_Reason_Level_3__c FROM Case LIMIT 1];
        map<String,map<String,String>> crLabelValueMap=new map<String,map<String,String>>();
        Test.startTest();
        crLabelValueMap=CaseControllerLightning.getAllPicklistValues(newCase.id);
        Test.stopTest();
        System.assertEquals(crLabelValueMap.keySet().size(),4);
        System.assertNotEquals(crLabelValueMap.get('type').size(),0);
        System.assertNotEquals(crLabelValueMap.get('level1').size(),0);
        System.assertNotEquals(crLabelValueMap.get('level2').size(),0);
        System.assertNotEquals(crLabelValueMap.get('level3').size(),0);
    }

    /**
    * @author Hugh Crinion
    * @date 20-Oct-19
    * @description Tests
    * SP-3791 : Global - Pandora Menu Change Process
    */
    @IsTest
    public static void test_menuChangeProcesses() {    

        UnitTestDataFactory.getRecordtypeValues();
        Country__c cd = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'EUR');
        insert cd;
        
        Account acco = UnitTestDataFactory.createAccount('TEST', cd, 'FP_Account');
        acco.Vertical__c = 'Restaurant'; 
        acco.phone = '+85212345678';
        insert acco;

        Business_Config__c b1x = new Business_Config__c(Business_Rule_Name__c='ownerId',Business_Rule_Value__c= '{"Menu Update Minor MenuChange Restaurant":"FP Editorial Team","Menu Update Major with Images MenuChange Restaurant":"FP Editorial Team"}' ,Id_Country__c=cd.id,Is_Active__c=true,Parent__c=true,Process_Name__c='MarkCompleteBtn',Record_Type_Id__c='FP_Entry_Case',Type__c='Process');     
        Business_Config__c b2x = new Business_Config__c(Business_Rule_Name__c='Menu Update Major with Images Restaurant',Business_Rule_Value__c= '{"Menu Typing" : "Final Check","Please Correct Errors":"Final Check","Final Check":"Closed"}' ,Id_Country__c=cd.id,Is_Active__c=true,Parent__c=false,Process_Name__c='MarkCompleteBtn',Record_Type_Id__c='FP_Entry_Case',Type__c='Process');
        Business_Config__c b3x = new Business_Config__c(Business_Rule_Name__c='Menu Update Minor Restaurant',Business_Rule_Value__c= '{"Approved":"Menu Typing","Menu Typing":"Closed","Pending Activation":"Closed"}' ,Id_Country__c=cd.id,Is_Active__c=true,Parent__c=false,Process_Name__c='MarkCompleteBtn',Record_Type_Id__c='FP_Entry_Case',Type__c='Process');
        Business_Config__c b4x = new Business_Config__c(Business_Rule_Name__c='Imagery only update Restaurant',Business_Rule_Value__c= '{"New":"Editing","Editing":"Final Check","Final Check":"Upload","Upload":"Closed","Please Correct Errors":"Final Check","Pending Activation":"Closed"}' ,Id_Country__c=cd.id,Is_Active__c=true,Parent__c=false,Process_Name__c='MarkCompleteBtn',Record_Type_Id__c='FP_Entry_Case',Type__c='Process');
        Business_Config__c b5x = new Business_Config__c(Business_Rule_Name__c='Menu Update Major Restaurant',Business_Rule_Value__c= '{"Menu Typing" : "Final Check","Please Correct Errors":"Final Check","Final Check":"Closed"}' ,Id_Country__c=cd.id,Is_Active__c=true,Parent__c=false,Process_Name__c='MarkCompleteBtn',Record_Type_Id__c='FP_Entry_Case',Type__c='Process');
        Business_Config__c b6x = new Business_Config__c(Business_Rule_Name__c='Menu Change', Business_Rule_Value__c= '{"Menu Typing":"Final Check","FinalStatus":"Final Check","New":"Menu Typing","Final Check":"Approval Pending","Please Correct Errors":"Final Check"}',Id_Country__c=cd.id,Is_Active__c=true,Parent__c=false,Process_Name__c='MarkCompleteBtn',Record_Type_Id__c='FP_Entry_Case',Type__c='Process');
        Business_Config__c b7x = new Business_Config__c(Business_Rule_Name__c='Type',Business_Rule_Value__c= 'Setup Backend,Menu Processing,Menu Change',Id_Country__c=cd.id,Is_Active__c=true,Parent__c=false,Process_Name__c='MarkCompleteBtn',Record_Type_Id__c='FP_Entry_Case',Type__c='Process');
        List<Business_Config__c> busConList = new List<Business_Config__c>{b1x,b2x,b3x,b4x,b5x,b6x,b7x};
        insert busConList;

        Map<String, Business_Config__c> bconfMap_1 = new Map<String, Business_Config__c>{b1x.Business_Rule_Name__c => b1x, b2x.Business_Rule_Name__c => b2x, b3x.Business_Rule_Name__c => b3x, b4x.Business_Rule_Name__c => b4x, b5x.Business_Rule_Name__c => b5x, b6x.Business_Rule_Name__c => b6x, b7x.Business_Rule_Name__c => b7x};
        Map<String, Map<String, Business_Config__c>> bconfMap_1f = new Map<String, Map<String, Business_Config__c>>{'FP_Entry_Case' => bconfMap_1, 'FP_Internal_Case' => bconfMap_1};
        LibBusinessConfig.setMotherOfAllBusinessMaps(new Map<String, Map<String, Map<String, Business_Config__c>>>{b1x.Process_Name__c => bconfMap_1f});
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User usr = new User(Alias = 'standt', Email='standarduser@deliveryhero.com', 
                            EmailEncodingKey='UTF-8', LastName='FP Photography', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, FederationIdentifier = '01p1w0000000YMp',
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser211@deliveryhero.com');
        insert usr ;
           
        Case acase1 = UnitTestDataFactory.createCase(acco, 'New', 'Menu Change', 'Menu Update Minor', '', cd, 'FP_Entry_Case', '');
        acase1.ownerId = usr.id;
        Case acase2 = new Case( 
                Type = 'Menu Change',
                Status = 'Menu Typing',
                Case_Reason__c = 'Menu Update Major with Images',
                Menu_Upd_Mjr_Check__c = true,
                AccountId = acco.Id,
                ownerId = usr.id
        );
        Case acase3 = UnitTestDataFactory.createCase(acco, 'Menu Typing', 'Menu Change', 'Imagery only update', '', cd, 'FP_Entry_Case', '');
        acase3.ownerId = usr.id;

        Case acase4 = UnitTestDataFactory.createCase(acco, 'Menu Typing', 'Menu Change', 'Menu Update Major', '', cd, 'FP_Entry_Case', '');
        acase4.ownerId = usr.id;

        List<Case> caseList = new List<Case>{acase2, acase1, acase3, acase4};
        insert caseList;
        
        //test1: mark complete 
        String mrkCompStr1 = CaseControllerLightning.markComplete(String.valueOf(acase1.id));
        mrkCompStr1 = CaseControllerLightning.markComplete(String.valueOf(acase1.id));
        String mrkCompStr2 = CaseControllerLightning.markComplete(String.valueOf(acase2.id));

        ClsRemoteController_Utils.menuChangeProcessCase(bconfMap_1, acase4);

        acase1.Parentid = acase2.Id;
        update acase1;
        
        //test3: (Menu Update Minor) menuChangeProcessCase
        ClsRemoteController_Utils.menuChangeProcessCase(bconfMap_1, acase1);

        //test3.2: (Menu Update Minor) menuChangeProcessCase
        acase1.Status = 'Menu Typing';
        acase1.Due_Date__c = system.today() + 5;

        test.startTest();
        //test4: (Imagery only update) menuChangeProcessCase
        ClsRemoteController_Utils.menuChangeProcessCase(bconfMap_1, acase3);
        System.assertEquals(acase3.ownerId, usr.id);

        //test4.2: (Imagery only update) menuChangeProcessCase
        acase3.Status = 'Please Correct Errors';
        acase3.Menu_Typing_Errors__c = 'Format issue';
        ClsRemoteController_Utils.menuChangeProcessCase(bconfMap_1, acase3);
        System.assertEquals(acase3.Status, 'Final Check');

        //test4.3: (Imagery only update) menuChangeProcessCase
        acase3.Status = 'Pending Activation';
        acase3.Due_Date__c = system.today() + 5;
        acase3.Closed_Reason__c = 'Not Successful';
        CaseControllerLightning.takeOwnership(String.valueOf(acase3.Id));
        ClsRemoteController_Utils.menuChangeProcessCase(bconfMap_1, acase3);
        System.assertEquals(acase3.Status, 'Closed');

        //test5: (Menu Update Major) menuChangeProcessCase
        acase3.Status = 'Menu Typing';
        acase3.Closed_Reason__c = 'Menu Update Major';        
        ClsRemoteController_Utils.menuChangeProcessCase(bconfMap_1, acase3);  
        System.assertNotEquals(acase3.ownerId, usr.id);

        //test4: (Menu Update Major with Images) menuChangeProcessCase
        ClsRemoteController_Utils.menuChangeProcessCase(bconfMap_1, acase2);
     
        //test4.2: (Menu Update Major with Images) menuChangeProcessCase
        CaseControllerLightning.takeOwnership(String.valueOf(acase2.Id));
        ClsRemoteController_Utils.menuChangeProcessCase(bconfMap_1, acase2);
        test.stopTest();  
        
        acase3.ownerId = usr.id;
        update acase3;  
        
        Boolean b1 = ClsRemoteController_Utils.menuChangeValidate(String.valueOf(acase2.Id));            
    }

    @isTest static void test_getOrderCompsVisibilitySetting(){
         
        Test.startTest();           
        System.assertEquals(true, CaseControllerLightning.getOrderCompsVisibilitySetting(System.Label.OrderHistoryComponents).Name == System.Label.OrderHistoryComponents );
        Test.stopTest();
    }
    
    @isTest
    static void testUndoComplete(){
        Case newCase = [SELECT Id, RecordTypeId,Type,Case_Reason_Level_1__c,Case_Reason_Level_2__c,Case_Reason_Level_3__c FROM Case WHERE RecordType.DeveloperName='PY_Inbound_Case' LIMIT 1];
        test.startTest();
            String returnJsonString = CaseControllerLightning.undoComplete(newCase.Id);        
        test.stopTest();

        system.assert(returnJsonString.contains(newCase.Id));  
    }
}
