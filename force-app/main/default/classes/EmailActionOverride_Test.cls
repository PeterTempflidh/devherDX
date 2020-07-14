/**
 * Created by t.jain on 2019-04-05.
 */

@IsTest
private class EmailActionOverride_Test {
    @testSetup
    public static void setupData(){
        UnitTestDataFactory.getRecordtypeValues();
        Country__c c = UnitTestDataFactory.createCountry('DE','Germany', 'EUR');
        insert c;
        Account acc = UnitTestDataFactory.createAccount('PrepopulateEmailFields',c,'DE_Account');
        insert acc;
        Case cs1 = UnitTestDataFactory.createCase(acc,'Resolved','Customer',null,'Chat',c,'DE_Inbound_Case','test');
        cs1.resolvedDate__c = Date.today().addDays(-20);
        cs1.order_number__c = '90123456789012';
        cs1.Case_Reason_Level_1__c = 'Across Journey';
        cs1.Case_Reason_Level_2__c = 'Customer Account';
        cs1.Case_Reason_Level_3__c = 'Account deletion';
        cs1.customer_email__c = 'test1@test.com';
        cs1.Platform__c = 'LieferheldDE';
        cs1.Description = 'test';
        cs1.Status = 'Closed';
        cs1.Closed_Reason__c = 'Successful';
        insert cs1;
        Business_Config__c config1 = UnitTestDataFactory.createBusinessConfig('CaseEmailPrepoulateConfigs', 'Process', 'Parameters', 'Template,To,CC,From', null, 'LieferheldDE', true, true);
        Business_Config__c config2 = UnitTestDataFactory.createBusinessConfig('CaseEmailPrepoulateConfigs', 'Process', 'Template', '{"1":{"Criteria":"Type", "Type":"Customer", "Template":"DE Blanko - LH Customer", "TargetField":"Template"}, "2":{"Criteria":"Type&&Case_Reason_Level_3__c", "Type":"Customer Request","Case_Reason_Level_3__c":"Other food complaint","Template":"DE Blanko - Restaurant", "TargetField":"Template"}}', null, 'LieferheldDE', true, true);
        Business_Config__c config3 = UnitTestDataFactory.createBusinessConfig('CaseEmailPrepoulateConfigs', 'Process', 'From', '{"1":{"Criteria":"Type&&Case_Reason_Level_3__c", "Type":"Customer", "Case_Reason_Level_3__c":"Account deletion", "From":"tarunjain90@gmail.com", "TargetField":"fromAddress"}, "2":{"Criteria":"Type&&Case_Reason_Level_3__c", "Type":"Customer Request","Case_Reason_Level_3__c":"Other food complaint","From":"tarun.jain@deliveryhero.com", "TargetField":"fromAddress"}}', null, 'LieferheldDE', true, true);
        Business_Config__c config4 = UnitTestDataFactory.createBusinessConfig('CaseEmailPrepoulateConfigs', 'Process', 'To', '{"1":{"Criteria":"Type&&Case_Reason_Level_3__c", "Type":"Customer", "Case_Reason_Level_3__c":"Account deletion", "To":"tarunjain90@gmail.com,abcdef@absdff.asd", "TargetField":"ToAddress"},"2":{"Criteria":"Type&&Case_Reason_Level_3__c", "Type":"Customer Request", "Case_Reason_Level_3__c":"Other food complaint", "To":"tarun.jain@deliveryhero.com,abcdef@absdff.asd", "TargetField":"ToAddress"}}', null, 'LieferheldDE', true, true);
        Business_Config__c config5 = UnitTestDataFactory.createBusinessConfig('CaseEmailPrepoulateConfigs', 'Process', 'CC', '{"1":{"Criteria":"Type&&Case_Reason_Level_3__c", "Type":"Customer", "Case_Reason_Level_3__c":"Account deletion", "CC":"tarunjain90@gmail.com,abcdef@absdff.asd", "TargetField":"CcAddress"}, "2":{"Criteria":"Type&&Case_Reason_Level_3__c", "Type":"Customer Request", "Case_Reason_Level_3__c":"Other food complaint", "CC":"tarun.jain@deliveryhero.com,tarunjain90@gmail.com", "TargetField":"CcAddress"}}', null, 'LieferheldDE', true, true);
        insert new List<sObject>{config1,config2,config3,config4,config5};
    }

    @IsTest
    static void testNewEmailActionPrepopulateData() {
        Case c = [SELECT Id FROM Case Limit 1];
        List<Map<String, Object>> defaultSettingAsUntypedObject = new List<Map<String, Object>>{
                new Map<String, Object>{
                        'targetSObject' => new EmailMessage(),
                        'contextId' => c.Id,
                        'actionType' => 'Email',
                        'actionName' => 'Case.Email'
                }
        };
        QuickAction.SendEmailQuickActionDefaults[] defaultsSettings = (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsUntypedObject), List<QuickAction.SendEmailQuickActionDefaults>.class);
        Test.startTest();
            try{
                EmailActionOverride emailOverride=new EmailActionOverride();
                emailOverride.onInitDefaults(defaultsSettings);
            }
        catch(Exception failure) { }
        Test.stopTest();
    }
}