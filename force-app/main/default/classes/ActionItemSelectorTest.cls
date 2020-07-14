/**
 * @description [Test class for ActionItemSelector]
 * Created by keerthan.tantry on 12/05/2020.
 */

@IsTest
private class ActionItemSelectorTest {

    @TestSetup static  void setup(){
        User testUser;
        Country__c country;
        List<Account> accounts;
        List<Platform_Country__c> platformCountries;
        List<ActionItem__c  > actionItems;
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

        }
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
    *
    * @description  [Create Platform_Country__c data ]
    * @return [ List of Platform_Country__c ]
    */
    public static List<Platform_Country__c> createPlatformCountries(){
        List<Platform_Country__c> pcList =new List<Platform_Country__c>();
        pcList.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        return  pcList;
    }

    @IsTest
    static void testGetActionItemsById() {
        List<ActionItem__c> actionItems = [SELECT ID,Account__c FROM ActionItem__c];
        Test.startTest();
        List<ActionItem__c> result = ActionItemSelector.getActionItemsById(new Set<String>{actionItems[0].Id});
        System.assert(!result.isEmpty());
        Test.stopTest();
    }

    @IsTest
    static void testGetActionItemsByAccountId() {
        List<ActionItem__c> actionItems = [SELECT ID,Account__c FROM ActionItem__c];
        Test.startTest();
        List<ActionItem__c> result = ActionItemSelector.getActionItemsByAccountId(new Set<String>{actionItems[0].Account__c});
        System.assert(!result.isEmpty());
        Test.stopTest();
    }
}