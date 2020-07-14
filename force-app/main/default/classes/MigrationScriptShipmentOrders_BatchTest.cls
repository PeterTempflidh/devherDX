/***
 * @description test class for MigrationScriptShipmentOrders_Batch class
 * @date 07.05.2020
 * @author Konrad Czykin
 */
@isTest
public class MigrationScriptShipmentOrders_BatchTest {

    @TestSetup
    public static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c country = UnitTestDataFactory.createCountry('TH', 'Thailand', 'THB');
        insert country;
        
        Company__c company = UnitTestDataFactory.createCompany('FP', 'FP', country);
        insert company;

        Account acc = UnitTestDataFactory.createAccount('Thailand Test Account', country, 'FP_Account');
        acc.phone = '+66123456789';
        acc.CurrencyIsoCode = 'THB';
        insert acc;

        Opportunity opp = UnitTestDataFactory.createOpportunity('Test Opportunity', acc, 'FP_Opportunity', Date.today());
        opp.StageName = 'Onboarding';
        opp.Business_Type__c = 'New Business';
        insert opp;

        List_Product_Group__c addChargesGroup = UnitTestDataFactory.createProductGroup(company, country, 'Add. Charges', 'FP_List_Product_Group');
        insert addChargesGroup;

        List_Product_Price__c simCard = new List_Product_Price__c(
            Is_Active__c = true,
            Id_List_Product_Group__c = addChargesGroup.Id,
            Product_Name__c = 'SIM Card',
            Product_Type__c = 'Hardware',
            Displayed_Name__c = 'SIM Card',
            List_Price__c = 0,
            Installments__c = 1,
            Default_Quantity__c = 1,
            Id_Country__c = country.Id,
            Company__c = company.Id);

        List_Product_Price__c tablet = new List_Product_Price__c(
            Is_Active__c = true,
            Id_List_Product_Group__c = addChargesGroup.Id,
            Product_Name__c = 'Tablet',
            Product_Type__c = 'Hardware',
            Displayed_Name__c = 'Tablet',
            List_Price__c = 0,
            Installments__c = 1,
            Default_Quantity__c = 1,
            Id_Country__c = country.Id,
            Company__c = company.Id);
        
        insert new List<List_Product_Price__c>{simCard, tablet};

        List<Opportunity_Quote__c> oppQ = UnitTestDataFactory.createOpportunityQuotes(opp, 1, 'FP_Opportunity_Quote', 'Accepted', 'Description', 0, 0, 'url', 'key', 0);
        insert oppQ;
    }

        @isTest
        public static void testCreateAllrecords(){
         
            Test.startTest();
                Database.executeBatch(new MigrationScriptShipmentOrders_Batch('FP','Thailand'));
            Test.stopTest();

            Opportunity opp = [SELECT Id FROM Opportunity limit 1];
            Account acc = [SELECT Id FROM Account limit 1];
            Opportunity_Quote__c oppQuote = [SELECT Id FROM Opportunity_Quote__c limit 1];
            List_Product_Price__c lppTablet = [SELECT Id FROM List_Product_Price__c WHERE Product_Name__c = 'Tablet'];
            List_Product_Price__c lppSIMCard = [SELECT Id FROM List_Product_Price__c WHERE Product_Name__c = 'SIM Card'];

            //check Shipment Order record
            List<Shipment_Order__c> lstSO = [SELECT Id, Status__c, Opportunity__c, Account__c FROM Shipment_Order__c];
            System.assertEquals(1, lstSO.size());
            System.assertEquals('Ready to be shipped', lstSO[0].Status__c);
            System.assertEquals(acc.Id, lstSO[0].Account__c);
            System.assertEquals(opp.Id, lstSO[0].Opportunity__c);

            //check tablet Shipment Order Line Item
            List<Shipment_Order_Line_Item__c> lstSOLI = [SELECT Id, List_Product_Price__c, Shipment_Order__c FROM Shipment_Order_Line_Item__c WHERE Name = 'Tablet'];
            System.assertEquals(1, lstSOLI.size());
            System.assertEquals(lppTablet.Id, lstSOLI[0].List_Product_Price__c);
            System.assertEquals(lstSO[0].Id, lstSOLI[0].Shipment_Order__c);

            //check SIM Card Shipment Order Line Item
            List<Shipment_Order_Line_Item__c> lstSOLIsim = [SELECT Id, List_Product_Price__c, Shipment_Order__c FROM Shipment_Order_Line_Item__c WHERE Name = 'SIM Card'];
            System.assertEquals(1, lstSOLIsim.size());
            System.assertEquals(lppSIMCard.Id, lstSOLIsim[0].List_Product_Price__c);
            System.assertEquals(lstSO[0].Id, lstSOLIsim[0].Shipment_Order__c);
            
            //check Tablet Quote Line Item
            List<Opportunity_Quote_Line_Item__c> lstOQLItablet = [SELECT Id, Id_Opportunity_Quote__c, Id_Opportunity__c FROM Opportunity_Quote_Line_Item__c WHERE Name = 'Tablet'];
            System.assertEquals(1, lstOQLItablet.size());
            System.assertEquals(oppQuote.Id, lstOQLItablet[0].Id_Opportunity_Quote__c);
            System.assertEquals(opp.Id, lstOQLItablet[0].Id_Opportunity__c);

            //check SIM Card Quote Line Item
            List<Opportunity_Quote_Line_Item__c> lstOQLIsim = [SELECT Id, Id_Opportunity_Quote__c, Id_Opportunity__c FROM Opportunity_Quote_Line_Item__c WHERE Name = 'SIM Card'];
            System.assertEquals(1, lstOQLIsim.size());
            System.assertEquals(oppQuote.Id, lstOQLIsim[0].Id_Opportunity_Quote__c);
            System.assertEquals(opp.Id, lstOQLIsim[0].Id_Opportunity__c);

            //check tablet Opportunity Line Item
            List<Opportunity_Line_Item__c> lstOLI = [SELECT Id, Delivery__c, Id_Opportunity__c, Id_List_Price_Product__c FROM Opportunity_Line_Item__c WHERE Name = 'Tablet'];
            System.assertEquals(1, lstOLI.size());
            System.assertEquals('Shipment', lstOLI[0].Delivery__c);
            System.assertEquals(lppTablet.Id, lstOLI[0].Id_List_Price_Product__c);

            //check SIM Card Opportunity Line Item
            List<Opportunity_Line_Item__c> lstOLIsim = [SELECT Id, Delivery__c, Id_Opportunity__c, Id_List_Price_Product__c FROM Opportunity_Line_Item__c WHERE Name = 'SIM Card'];
            System.assertEquals(1, lstOLIsim.size());
            System.assertEquals('Shipment', lstOLIsim[0].Delivery__c);
            System.assertEquals(lppSIMCard.Id, lstOLIsim[0].Id_List_Price_Product__c);
        }
}