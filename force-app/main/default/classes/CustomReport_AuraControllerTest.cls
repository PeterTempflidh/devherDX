/**
* @author Mantas Jurkunas
* @date 31.07.2019
*
* @description Test class for CustomReport_AuraController
*/
@IsTest
private class CustomReport_AuraControllerTest {

    @TestSetup
    public static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c testCountry = UnitTestDataFactory.createCountry('SE','Sweden', 'SEK');
        insert testCountry;

        Company__c com = UnitTestDataFactory.createCompany('Lieferheld', 'SE', testCountry);
        insert com;

        List<Account> accList= UnitTestDataFactory.createAccounts(5,testCountry,'SE_Account');
        for (Account acc: accList) { acc.Phone = '+461234567'; }
        insert accList;

        List<AddressDetail__c> allAddressDetails = new List<AddressDetail__c>();
        for (Account acc: accList) {
            allAddressDetails.addAll(UnitTestDataFactory.createAddressDetails(new List<String>{'Shipping Address', 'Billing Address', 'Restaurant Address'}, acc.Id));
        }
        Trigger_Manager__c tm = Trigger_Manager__c.getInstance();
        tm.Deactivate_AddressDetail_Trigger__c = true;
        upsert tm;
        insert allAddressDetails;

        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,5,'SE_Opportunity',Date.today());
        insert oppList;

        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,testCountry,'Setup Fee','SE_List_Product_Group');
        insert lpg1;

        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 1',lpg1.Id,'SE_List_Product_Price',1,true,100,1,false,null);
        lpp1.Product_Type__c = 'Dish Level Photoshoot';
        insert lpp1;

        List<Opportunity_Line_Item__c> opi = new List<Opportunity_Line_Item__c>();
        for (Opportunity opp: oppList) {
            opi.addAll(UnitTestDataFactory.createOpportunityLineItems(opp, lpg1.Id, lpp1.Id, 5, false, 'SE_Opportunity_Line_Item', 1, '10', 299.0, 1, 1, 'Product'));
        }
        insert opi;
    }

    /**
     * @description  Testing if the correct number of report lines is being generated, it is dependent on the Field sets in the org
     */
    @IsTest
    public static void test_generateReportWIthMultipleChildren() {
        CustomReport_AuraController.ReportRelationDefinition definitionAccount = new CustomReport_AuraController.ReportRelationDefinition();
        CustomReport_AuraController.ReportRelationDefinition definitionAddress= new CustomReport_AuraController.ReportRelationDefinition();
        CustomReport_AuraController.ReportRelationDefinition definitionOpportunity = new CustomReport_AuraController.ReportRelationDefinition();
        CustomReport_AuraController.ReportRelationDefinition definitionOpportunityLineItem = new CustomReport_AuraController.ReportRelationDefinition();
        definitionOpportunityLineItem.objectName = Opportunity_Line_Item__c.getSObjectType().getDescribe().getLocalName();
        definitionOpportunityLineItem.parentLookupField = Opportunity_Line_Item__c.Id_Opportunity__c.getDescribe().getLocalName();
        definitionOpportunityLineItem.fieldSetName = 'KR_CustomReport';

        definitionOpportunity.objectName = Opportunity.getSObjectType().getDescribe().getLocalName();
        definitionOpportunity.parentLookupField = Opportunity.AccountId.getDescribe().getLocalName();
        definitionOpportunity.fieldSetName = 'KR_CustomReport';
        definitionOpportunity.children = new List<CustomReport_AuraController.ReportRelationDefinition>{definitionOpportunityLineItem};

        definitionAddress.objectName = AddressDetail__c.getSObjectType().getDescribe().getLocalName();
        definitionAddress.parentLookupField = AddressDetail__c.Account__c.getDescribe().getLocalName();
        definitionAddress.fieldSetName = 'OptTriggerQuery';

        definitionAccount.objectName = Account.getSObjectType().getDescribe().getLocalName();
        definitionAccount.fieldSetName = 'OptTriggerQuery';
        definitionAccount.children = new List<CustomReport_AuraController.ReportRelationDefinition>{definitionOpportunity, definitionAddress};
        CustomReport_AuraController.ReportData reportData = CustomReport_AuraController.loadReportData(JSON.serialize(definitionAccount));
        System.assertEquals(375, reportData.data.size());
    }

    /**
     * @description  Testing if the correct number of report lines is being generated with one row stacked, it is dependent on the Field sets in the org
     */
    @IsTest
    public static void test_generateReportWithStackedRow() {
        CustomReport_AuraController.ReportRelationDefinition definitionAccount = new CustomReport_AuraController.ReportRelationDefinition();
        CustomReport_AuraController.ReportRelationDefinition definitionAddress= new CustomReport_AuraController.ReportRelationDefinition();
        CustomReport_AuraController.ReportRelationDefinition definitionOpportunity = new CustomReport_AuraController.ReportRelationDefinition();
        CustomReport_AuraController.ReportRelationDefinition definitionOpportunityLineItem = new CustomReport_AuraController.ReportRelationDefinition();
        definitionOpportunityLineItem.objectName = Opportunity_Line_Item__c.getSObjectType().getDescribe().getLocalName();
        definitionOpportunityLineItem.parentLookupField = Opportunity_Line_Item__c.Id_Opportunity__c.getDescribe().getLocalName();
        definitionOpportunityLineItem.fieldSetName = 'KR_CustomReport';

        definitionOpportunity.objectName = Opportunity.getSObjectType().getDescribe().getLocalName();
        definitionOpportunity.parentLookupField = Opportunity.AccountId.getDescribe().getLocalName();
        definitionOpportunity.fieldSetName = 'KR_CustomReport';
        definitionOpportunity.children = new List<CustomReport_AuraController.ReportRelationDefinition>{definitionOpportunityLineItem};

        definitionAddress.objectName = AddressDetail__c.getSObjectType().getDescribe().getLocalName();
        definitionAddress.parentLookupField = AddressDetail__c.Account__c.getDescribe().getLocalName();
        definitionAddress.fieldSetName = 'OptTriggerQuery';
        definitionAddress.stackValues = true;

        definitionAccount.objectName = Account.getSObjectType().getDescribe().getLocalName();
        definitionAccount.fieldSetName = 'OptTriggerQuery';
        definitionAccount.children = new List<CustomReport_AuraController.ReportRelationDefinition>{definitionOpportunity, definitionAddress};
        CustomReport_AuraController.ReportData reportData = CustomReport_AuraController.loadReportData(JSON.serialize(definitionAccount));
        System.assertEquals(125, reportData.data.size());
    }

    /**
    * @description  Testing if the correct number of report lines is being generated with all rows stacked, it is dependent on the Field sets in the org
    */
    @IsTest
    public static void test_generateReportWIthAllStackedRows() {
        CustomReport_AuraController.ReportRelationDefinition definitionAccount = new CustomReport_AuraController.ReportRelationDefinition();
        CustomReport_AuraController.ReportRelationDefinition definitionAddress= new CustomReport_AuraController.ReportRelationDefinition();
        CustomReport_AuraController.ReportRelationDefinition definitionOpportunity = new CustomReport_AuraController.ReportRelationDefinition();
        CustomReport_AuraController.ReportRelationDefinition definitionOpportunityLineItem = new CustomReport_AuraController.ReportRelationDefinition();
        definitionOpportunityLineItem.objectName = Opportunity_Line_Item__c.getSObjectType().getDescribe().getLocalName();
        definitionOpportunityLineItem.parentLookupField = Opportunity_Line_Item__c.Id_Opportunity__c.getDescribe().getLocalName();
        definitionOpportunityLineItem.fieldSetName = 'KR_CustomReport';
        definitionOpportunityLineItem.stackValues = true;

        definitionOpportunity.objectName = Opportunity.getSObjectType().getDescribe().getLocalName();
        definitionOpportunity.parentLookupField = Opportunity.AccountId.getDescribe().getLocalName();
        definitionOpportunity.fieldSetName = 'KR_CustomReport';
        definitionOpportunity.children = new List<CustomReport_AuraController.ReportRelationDefinition>{definitionOpportunityLineItem};
        definitionOpportunity.stackValues = true;

        definitionAddress.objectName = AddressDetail__c.getSObjectType().getDescribe().getLocalName();
        definitionAddress.parentLookupField = AddressDetail__c.Account__c.getDescribe().getLocalName();
        definitionAddress.fieldSetName = 'OptTriggerQuery';
        definitionAddress.stackValues = true;

        definitionAccount.objectName = Account.getSObjectType().getDescribe().getLocalName();
        definitionAccount.fieldSetName = 'OptTriggerQuery';
        definitionAccount.children = new List<CustomReport_AuraController.ReportRelationDefinition>{definitionOpportunity, definitionAddress};
        definitionAccount.stackValues = true;
        CustomReport_AuraController.ReportData reportData = CustomReport_AuraController.loadReportData(JSON.serialize(definitionAccount));
        System.assertEquals(1, reportData.data.size());
    }

    /**
     * @description  Testing if the correct number of report lines is being generated
     */
    @IsTest
    public static void test_generateReport() {
        CustomReport_AuraController.ReportRelationDefinition definitionAccount = new CustomReport_AuraController.ReportRelationDefinition();
        CustomReport_AuraController.ReportRelationDefinition definitionAddress= new CustomReport_AuraController.ReportRelationDefinition();
        CustomReport_AuraController.ReportRelationDefinition definitionOpportunity = new CustomReport_AuraController.ReportRelationDefinition();

        definitionOpportunity.objectName = Opportunity.getSObjectType().getDescribe().getLocalName();
        definitionOpportunity.parentLookupField = Opportunity.AccountId.getDescribe().getLocalName();
        definitionOpportunity.fieldSetName = 'KR_CustomReport';

        definitionAddress.objectName = AddressDetail__c.getSObjectType().getDescribe().getLocalName();
        definitionAddress.parentLookupField = AddressDetail__c.Account__c.getDescribe().getLocalName();
        definitionAddress.fieldSetName = 'OptTriggerQuery';

        definitionAccount.objectName = Account.getSObjectType().getDescribe().getLocalName();
        definitionAccount.fieldSetName = 'OptTriggerQuery';
        definitionAccount.children = new List<CustomReport_AuraController.ReportRelationDefinition>{definitionOpportunity, definitionAddress};
        CustomReport_AuraController.ReportData reportData = CustomReport_AuraController.loadReportData(JSON.serialize(definitionAccount));
        System.assertEquals(75, reportData.data.size());
    }

    /**
     * @description  Testing if the correct number of report lines is being generated
     */
    @IsTest
    public static void test_generateReportWithLinearInheritance() {
        CustomReport_AuraController.ReportRelationDefinition definitionAccount = new CustomReport_AuraController.ReportRelationDefinition();
        CustomReport_AuraController.ReportRelationDefinition definitionAddress = new CustomReport_AuraController.ReportRelationDefinition();
        CustomReport_AuraController.ReportRelationDefinition definitionOpportunity = new CustomReport_AuraController.ReportRelationDefinition();

        definitionOpportunity.objectName = Opportunity.getSObjectType().getDescribe().getLocalName();
        definitionOpportunity.parentLookupField = Opportunity.AccountId.getDescribe().getLocalName();
        definitionOpportunity.fieldSetName = 'KR_CustomReport';

        definitionAddress.objectName = AddressDetail__c.getSObjectType().getDescribe().getLocalName();
        definitionAddress.parentLookupField = AddressDetail__c.Account__c.getDescribe().getLocalName();
        definitionAddress.fieldSetName = 'OptTriggerQuery';

        definitionAccount.objectName = Account.getSObjectType().getDescribe().getLocalName();
        definitionAccount.fieldSetName = 'OptTriggerQuery';
        definitionAccount.children = new List<CustomReport_AuraController.ReportRelationDefinition>{definitionAddress, definitionOpportunity, definitionAddress};
        CustomReport_AuraController.ReportData reportData = CustomReport_AuraController.loadReportData(JSON.serialize(definitionAccount));
        System.assertEquals(225, reportData.data.size());
    }
}