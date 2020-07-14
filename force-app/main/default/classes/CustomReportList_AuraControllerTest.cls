/**
* @author Mantas Jurkunas
* @date 19.08.2019
*
* @description Test class for CustomReportList_AuraController
* @see CustomReportList_AuraController
*/
@IsTest
public with sharing class CustomReportList_AuraControllerTest {

    @TestSetup
    public static void setup() {
        Business_Config__c config1 = UnitTestDataFactory.createBusinessConfig('CustomReports', 'Process', 'Opportunities', '{"queryCondition":null,"parentLookupField":null,"objectName":"Account","fieldSetName":"OptTriggerQuery","fieldSetMembers":null,"dataMap":null,"children":[{"queryCondition":null,"parentLookupField":"AccountId","objectName":"Opportunity","fieldSetName":"Test_FieldSet","fieldSetMembers":null,"dataMap":null,"children":[{"queryCondition":null,"parentLookupField":"Id_Opportunity__c", "stackValues": true,"objectName":"Opportunity_Line_Item__c","fieldSetName":"Test_FieldSet","fieldSetMembers":null,"dataMap":null,"children":null}]}]}', null, 'Yogiyo', true, true);
        insert config1;
    }

    @IsTest
    public static void test_getReportDescription() {
        List<CustomReportList_AuraController.ReportDescription> description = CustomReportList_AuraController.getReportDefinitionList();
        System.assertEquals(1, description.size());
    }
}