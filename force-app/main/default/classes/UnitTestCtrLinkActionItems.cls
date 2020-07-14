/**
 * @description [ Test class for CtrLinkActionItems Class ]
 * Created by keerthan.tantry on 12/05/2020.
 */

@IsTest
private class UnitTestCtrLinkActionItems {

    @TestSetup static  void setup(){
        User testUser;
        Country__c country;
        List<Account> accounts;
        List<ActionItem__c  > actionItems;
        List<Platform_Country__c> platformCountries;
        Task objTask;
        UnitTestDataFactory.getRecordtypeValues();

        testUser = UnitTestDataFactory.createUser('Talabat Sales Team', 'talabattestuser@talabat.com', 'Talabat', 'AE');
        insert testUser;
        System.runAs(testUser) {
            platformCountries = createPlatformCountries();
            insert platformCountries;

            country = UnitTestDataFactory.createCountry('AE', 'United Arab Emirates', 'AED');
            insert country;

            accounts = UnitTestDataFactory.createAccounts(1, country, 'Talabat_Account');
            insert accounts;

            actionItems  = createActionItems(5,accounts[0]);
            insert actionItems;

            objTask = createTaskForActionItem(actionItems[0]);
            insert objTask;

        }
    }
    /**
    *
    * @description  [Create Action Item data]
    * @param noOfRecords [No of records to create]
    * @param objAccount [Account under which action items are created]
    *
    * @return [List of action items]
    */
    public static List<ActionItem__c> createActionItems(Integer noOfRecords, Account objAccount){
        List<ActionItem__c> actionItems = new List<ActionItem__c>();
        ActionItem__c obj;
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
    * @param objActionItem [Action Item record ]
    * @return [Task record]
    */
    public static Task  createTaskForActionItem(ActionItem__c objActionItem){
        Task objTask = new Task();
        objTask.OwnerId = UserInfo.getUserId();
        objTask.WhatId = objActionItem.Id;
        objTask.RecordTypeId = LibRecordTypeHelper.getRecordTypeIdByDeveloperName(Constants.SOBJECT_TASK,Constants.TASK_RT_TALABAT_TASK);
        objTask.Subject = Constants.TASK_SUBJECT_CALL;
        objTask.Status = Constants.TASK_STATUS_NOT_STARTED;
        objTask.Priority = Constants.TASK_PRIORITY_NORMAL;
        return objTask;
    }
    /**
    *
    * @description  [Create Platform_Country__c test records ]
    * @return [List of Platform_Country__c records]
    */
    public static List<Platform_Country__c> createPlatformCountries(){
        List<Platform_Country__c> pcList =new List<Platform_Country__c>();
        pcList.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        return  pcList;
    }


    @IsTest
    static void testGetActionItems() {
        List<ActionItem__c> actionItems = [SELECT ID,Account__c FROM ActionItem__c];
        List<Task> tasks = [SELECT  Id,WhatId FROM Task];

        Test.startTest();
           List<CtrLinkActionItems.ActionItemsWrapper> resList =   CtrLinkActionItems.getActionItems(tasks[0].Id);
           System.assert(!resList.isEmpty());
        Test.stopTest();
    }

    @IsTest
    static void testLinkActionItems() {
        List<ActionItem__c> actionItems = [SELECT ID,Account__c FROM ActionItem__c];
        List<Task> tasks = [SELECT  Id,Code__c,WhatId FROM Task];

        Test.startTest();
        CtrLinkActionItems.linkActionItems(tasks[0].Id,actionItems[1].Id);
        List<Task> tasks1  = [ SELECT Id,WhatId,Code__c FROM Task WHERE Code__c =:tasks[0].Code__c AND WhatId =:actionItems[1].Id    ];
        System.assert(!tasks1.isEmpty());
        //Cover isTaskAlreadyLinked upsert
        CtrLinkActionItems.linkActionItems(tasks[0].Id,actionItems[1].Id);
        Test.stopTest();
    }

    @IsTest
    static void testDelinkActionItems() {
        List<ActionItem__c> actionItems = [SELECT ID,Account__c FROM ActionItem__c];
        List<Task> tasks = [SELECT  Id,Code__c,WhatId FROM Task];

        Test.startTest();
        CtrLinkActionItems.delinkActionItems(tasks[0].Id,actionItems[0].Id);
        List<Task> tasks1  = [ SELECT Id,WhatId,Code__c FROM Task WHERE Code__c =:tasks[0].Code__c AND WhatId =:actionItems[1].Id    ];
        System.assert(tasks1.isEmpty());
        Test.stopTest();
    }
}