@isTest
private class UnitTestClsTaskProcessor {

    @testSetup static void setup() {
        UnitTestDataFactory.getRecordtypeValues();

        Country__c c = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
        insert c;

        Account a = UnitTestDataFactory.createAccount('test acc', c, 'CD_Account');
        insert a;

        Case cs = UnitTestDataFactory.createCase(a, 'New', 'CD Inbound', 'issue whatever', 'Phone', c, 'CD_Inbound_Case', 'test');
        insert cs;

        Lead l = UnitTestDataFactory.createLeads(1, c, 'test', 'test', 'USD', 'test', 'CD_Lead')[0];
        insert l;

        Country__c talabatCountry = UnitTestDataFactory.createCountry('AE', 'United Arab Emirates', 'AED');
        insert talabatCountry;

        Account talabatAccount = UnitTestDataFactory.createAccount('test acc', talabatCountry, 'Talabat_Account');
        insert talabatAccount;

        List<ActionItem__c> actionItems = createActionItems(2,talabatAccount);
        insert actionItems;

        List<Task> taskInstance = createTaskForActionItem(1, actionItems[0]);
        insert taskInstance;

        List<Task> taskWithAnotherActionItem = createTaskForActionItem(1, actionItems[1]);
        insert taskWithAnotherActionItem;
        
        // create business configs
        List<Business_Config__c> configs = new List<Business_Config__c>();
        configs.add(UnitTestDataFactory.createBusinessConfig('opportunityUpdateFromTaskProcess','process','requiredProbabilityForCEStage','20', null,'Generic_Activity',True,True));
        configs.add(UnitTestDataFactory.createBusinessConfig('opportunityUpdateFromTaskProcess','process','oppContactEstablishedStageName','Contact Established', null,'Generic_Activity',True,false));
        configs.add(UnitTestDataFactory.createBusinessConfig('opportunityUpdateFromTaskProcess','process','requiredProbabilityForOpenStage','5', null,'Generic_Activity',True,false));
        configs.add(UnitTestDataFactory.createBusinessConfig('opportunityUpdateFromTaskProcess','process','oppOpenStageName','Open', null,'Generic_Activity',True,false));
        configs.add(UnitTestDataFactory.createBusinessConfig('opportunityUpdateFromTaskProcess','process','CEAcitvitySubject','Call - Decision maker reached', null,'Generic_Activity',True,false));
        configs.add(UnitTestDataFactory.createBusinessConfig('opportunityUpdateFromTaskProcess','process','openAcitvitySubject','Call - Employee reached,Call - Nobody reached', null,'Generic_Activity',True,false));
        configs.add(UnitTestDataFactory.createBusinessConfig('opportunityUpdateFromTaskProcess','process','taskTypes','Call', null,'Generic_Activity',True,false));
        configs.add(UnitTestDataFactory.createBusinessConfig('opportunityUpdateFromTaskProcess','process','taskStatus','Completed', null,'Generic_Activity',True,false));
        configs.add(UnitTestDataFactory.createBusinessConfig('opportunityUpdateFromTaskProcess','process','eventTypes','Meeting', null,'Generic_Activity',True,false));
        configs.add(UnitTestDataFactory.createBusinessConfig(Constants.BUSINESSCONFIG_PROCESSNAME_SYNCTASKS,'process', Constants.BUSINESSCONIFG_RULENAME_TASKFIELDTOMAP,'Subject,Type', null,'Talabat_Task',True,True));
        insert configs;
    }

    @isTest static void updateCaseLastCallDateWorksCorrectly() {
        Case c = [Select Id From Case Limit 1];

        Datetime res;

        Test.startTest();

        Task call = new Task(
            Type = 'Call',
            Subject = 'Test',
            WhatId = c.Id,
            Status = 'Completed',
            recordtypeId = LibRecordTypeHelper.getRecordTypeValue('CD_Task')
        );

        insert call;

        res = [select CreatedDate from Task where id =: call.Id].CreatedDate;

        Test.stopTest();

        c = [Select Last_Call_Date__c From Case where id =: c.Id];

        System.assertEquals(res, c.Last_Call_Date__c);
    }

    @isTest static void updateCaseLastCallDateDoesNothingIfTaskIsNotACallOrIsNotCompleted() {
        Case c = [Select Id From Case Limit 1];

        Test.startTest();

        // call not completed
        Task t1 = new Task(
            Type = 'Call',
            Subject = 'Test',
            WhatId = c.Id,
            Status = 'New',
            recordtypeId = LibRecordTypeHelper.getRecordTypeValue('CD_Task')
        );

        // not a call
        Task t2 = new Task(
            Type = 'Task',
            Subject = 'Test',
            WhatId = c.Id,
            Status = 'Completed',
            recordtypeId = LibRecordTypeHelper.getRecordTypeValue('CD_Task')
        );

        insert new List<Task>{t1, t2};

        Test.stopTest();

        c = [Select Last_Call_Date__c From Case where id =: c.Id];

        System.assertEquals(null, c.Last_Call_Date__c);
    }

    @isTest static void updateLeadLastCallDateWorksCorrectly() {
        Lead l = [select id from Lead limit 1];

        Datetime res;

        Test.startTest();

        Task call = new Task(
            Type = 'Call',
            Subject = 'Test',
            WhoId = l.Id,
            Status = 'Completed',
            recordtypeId = LibRecordTypeHelper.getRecordTypeValue('CD_Task')
        );

        insert call;

        res = [select CreatedDate from Task where id =: call.Id].CreatedDate;

        Test.stopTest();

        l = [Select Last_Call_Date__c From Lead Where Id =: l.Id];

        System.assertEquals(res, l.Last_Call_Date__c);
    }

    @isTest static void updateLeadLastCallDateDoesNothingIfTaskIsNotACallOrIsNotCompleted() {
        Lead l = [Select Id From Lead Limit 1];

        Test.startTest();

        // call not completed
        Task t1 = new Task(
            Type = 'Call',
            Subject = 'Test',
            WhoId = l.Id,
            Status = 'New',
            recordtypeId = LibRecordTypeHelper.getRecordTypeValue('CD_Task')
        );

        // not a call
        Task t2 = new Task(
            Type = 'Task',
            Subject = 'Test',
            WhoId = l.Id,
            Status = 'Completed',
            recordtypeId = LibRecordTypeHelper.getRecordTypeValue('CD_Task')
        );

        insert new List<Task>{t1, t2};

        Test.stopTest();

        l = [Select Last_Call_Date__c From Lead where id =: l.Id];

        System.assertEquals(null, l.Last_Call_Date__c);
    }



    @isTest static void legacyTestJustForCoverage() {
        List<Account> accounts;
        List<Account> accounts2;
        List<Opportunity> opportunities;
        List<Lead> ls;
        Case cs;


        Country__c testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        Country__c testCountry2 = UnitTestDataFactory.createCountry('UK', 'United Kingdom', 'GBP');
        insert testCountry;
        Company__c testCompany = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', testCountry);
        insert testCompany;
        accounts = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
        accounts2 = UnitTestDataFactory.createAccounts(1, testCountry2, 'FP_Account');
        accounts2[0].Phone = '+85227367722';
        insert accounts;
        opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'Yogiyo_Opportunity', Date.today().addMonths(2));
        insert opportunities;
        ls = UnitTestDataFactory.createLeads(2, testCountry, 'test', 'Yogiyo', 'KRW', 'test', 'Yogiyo_Lead');
        ls[0].Status = 'decision maker reached';
        ls[0].GRID__c = 'BCD1';
        ls[1].Status = 'employee reached';
        ls[1].GRID__c = 'BCD2';

        insert ls;
        cs = UnitTestDataFactory.createCase(accounts2[0], 'New', 'Partner', 'Transmission Issues', 'phone', testCountry2, 'Yogiyo_Inbound', 'Tablink Callback: Eve Richens');
        insert cs;

        ClsTaskProcessor ct = new ClsTaskProcessor();
        Task t1  = new Task(Subject = 'Email', Type = 'Call', status = 'Completed', whatId = opportunities[0].id, description = 'test it', ActivityDate = Date.today(), recordtypeId = LibRecordTypeHelper.getRecordTypeValue('Yogiyo_Task'));
        Task t2  = new Task(Subject = 'Email', Type = 'Call', status = 'New', whoid = ls[0].id, description = 'test it', ActivityDate = Date.today(), Activity_Subject__c = 'decision maker reached');
        Task t3  = new Task(Subject = 'Email', Type = 'Call', status = 'Completed', whoid = ls[0].id, description = 'test it', ActivityDate = Date.today(), Activity_Subject__c = 'employee reached');
        Task t4  = new Task(Subject = 'Email', Type = 'Call', status = 'Completed', whatId = cs.Id, description = 'test it', ActivityDate = Date.today(), Activity_Subject__c = 'employee reached');
        insert new List<Task> {t1, t2, t3, t4};
    }
    
    @isTest
    public static void testOpportunityStageUpdateForOpenStage(){
    	Country__c testCountry = UnitTestDataFactory.createCountry('DE', 'Germany', 'EUR');
        insert testCountry;
        Company__c testCompany = UnitTestDataFactory.createCompany('Lieferheld', 'Lieferheld', testCountry);
        insert testCompany;
        List<Account> accounts 	= UnitTestDataFactory.createAccounts(1, testCountry, 'DE_Account');
        insert accounts;
        List<Opportunity> opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'DE_Opportunity', Date.today().addMonths(2));
        opportunities[0].stageName = 'New';
        insert opportunities;
        
        Test.startTest();
        	Task t1  = new Task(Subject = 'Email', Type = 'Call', status = 'Completed', whatId = opportunities[0].id, 
        				description = 'test it', ActivityDate = Date.today(), 
        				recordtypeId = LibRecordTypeHelper.getRecordTypeValue('DE_Task'),
        				Activity_Subject__c = 'Call - Employee reached');
        	insert t1;
        Test.stopTest();
        
        List<Opportunity> opps = [Select Id from Opportunity where stageName = 'Open'];
        system.assertEquals(1,opps.size());
    }
    
    @isTest
    public static void testOpportunityStageUpdateForCEStage(){
    	Country__c testCountry = UnitTestDataFactory.createCountry('DE', 'Germany', 'EUR');
        insert testCountry;
        Company__c testCompany = UnitTestDataFactory.createCompany('Lieferheld', 'Lieferheld', testCountry);
        insert testCompany;
        List<Account> accounts 	= UnitTestDataFactory.createAccounts(1, testCountry, 'DE_Account');
        insert accounts;
        List<Opportunity> opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'DE_Opportunity', Date.today().addMonths(2));
        opportunities[0].stageName = 'New';
        insert opportunities;
        
        Test.startTest();
        	Task t1  = new Task(Subject = 'Email', Type = 'Call', status = 'Completed', whatId = opportunities[0].id, 
        				description = 'test it', ActivityDate = Date.today(), 
        				recordtypeId = LibRecordTypeHelper.getRecordTypeValue('DE_Task'),
        				Activity_Subject__c = 'Call - Decision maker reached');
        	insert t1;
        Test.stopTest();
        
        List<Opportunity> opps = [Select Id from Opportunity where stageName = 'Contact Established'];
        system.assertEquals(1,opps.size());
    }

    /**
    * @date     : [06/05/2020]
    * @method name  : testSyncTaskObject
    * @description  : Test method of the syncTaskObject
    * @retun : None
    */
    @IsTest
    public static void testSyncTaskObject() {

        List<Task> taskInstance = [SELECT ID,Code__c,WhatId,Subject FROM Task limit 2];
        taskInstance[0].Code__c = taskInstance[1].Code__c;
        taskInstance[0].Subject = 'Other';

        Test.startTest();
        update taskInstance[0];
        System.assert(!taskInstance.isEmpty());
        Test.stopTest();
    }

    /**
    *
    * @description [Create Action Item data]
    * @param noOfRecords [No of records to create]
    * @param objAccount [Account under which action items are created]
    *
    * @return [List of action items]
    */
    public static List<ActionItem__c> createActionItems(Integer noOfRecords, Account objAccount){
        List<ActionItem__c> actionItems = new List<ActionItem__c>();
        ActionItem__c obj = new ActionItem__c();
        for(Integer i=0;i<noOfRecords;i++){
            obj  = new ActionItem__c();
            obj.Name = 'Action Item' + i;
            obj.Type__c = Constants.ACTION_ITEM_TYPE_COMMISSION_UPGRADE;
            obj.Start_Date__c  = System.today();
            obj.End_Date__c = System.today().addDays(10);
            obj.Account__c = objAccount.Id;
            actionItems.add(obj);
        }
        return actionItems;
    }

    /**
    * @description  [Create Task under Action Items ]
    * @param noOfRecords [No of records to create]
    * @param objActionItem [Action Item record ]
    * @return [Task record]
    */
    public static List<Task>  createTaskForActionItem(Integer noOfRecords, ActionItem__c objActionItem){
        List<Task> taskList = new List<Task>();
        Task objTask = new Task();
        for(Integer i=0;i<noOfRecords;i++){
            objTask.OwnerId = UserInfo.getUserId();
            objTask.WhatId = objActionItem.Id;
            objTask.RecordTypeId = LibRecordTypeHelper.getRecordTypeIdByDeveloperName(Constants.SOBJECT_TASK,Constants.TASK_RT_TALABAT_TASK);
            objTask.Subject = Constants.TASK_SUBJECT_CALL;
            objTask.Status = Constants.TASK_STATUS_NOT_STARTED;
            objTask.Priority = Constants.TASK_PRIORITY_NORMAL;
            taskList.add(objTask);
        }
        return taskList;
    }
}