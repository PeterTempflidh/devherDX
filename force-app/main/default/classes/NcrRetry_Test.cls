/**
* @author Mantas Jurkunas
* @date 15.11.2019
*
* @description Test class for NcrRetry functionality
*
*/
@IsTest
private class NcrRetry_Test {

    @isTest static void testRestBookingServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new MidasCalloutMock(false));

        Test.startTest();
            Database.executeBatch(new NcrRetry_Batch());
        Test.stopTest();
        for (Opportunity_Line_Item__c lineItem: OpportunityLineItem_Selector.getAll()) {
            System.assertEquals(false, lineItem.Midas_Exception__c);
        }
    }

    @isTest static void testRestBookingServiceError() {
        Test.setMock(HttpCalloutMock.class, new MidasCalloutMock(true));

        Test.startTest();
        Database.executeBatch(new NcrRetry_Batch());
        Test.stopTest();
        for (Opportunity_Line_Item__c lineItem: OpportunityLineItem_Selector.getAll()) {
            System.assertEquals(true, lineItem.Midas_Exception__c);
        }
    }

    @TestSetup
    public static void setup() {

        Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Case','Additional_Charges__c'});
        UnitTestDataFactory.getRecordtypeValues();

        Country__c beh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        insert beh;

        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='OppQuoteEmailTemplate',Business_Rule_Value__c='TestTemplate',Id_Country__c=beh.id,Is_Active__c=true,Parent__c=true,Process_Name__c='OppQuoteProcess',Record_Type_Id__c='Talabat_Account',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c = 'Status__c', Business_Rule_Value__c = 'Accepted', Id_Country__c = beh.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'OppTypeAndStageProcess', Record_Type_Id__c = 'Talabat_Opportunity_Quote', Type__c = 'Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c = 'Product Only', Business_Rule_Value__c = 'stageName=Quality Check Request,Probability=95', Id_Country__c = beh.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'OppTypeAndStageProcess', Record_Type_Id__c = 'Talabat_Opportunity_Quote', Type__c = 'Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c = 'opportunity stage', Business_Rule_Value__c = 'Closed Won', Id_Country__c = beh.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'Talabat_Opportunity', Type__c = 'Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c = 'AdditionalCharges RecordType', Business_Rule_Value__c = 'Talabat_Additional_Charges', Id_Country__c = beh.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'Talabat_Opportunity', Type__c = 'Process');
        Business_Config__c b6 = UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'EmailTemplateMap', '{"New Business":"Talabat_NB_EmailTemplate","UpgradeUpsell":"Talabat_ProductOnly_EmailTemplate","Premium Placement":"Talabat_PP_EmailTemplate"}', beh.Id, 'Talabat_Opportunity_Quote', true, true);
        Business_Config__c b7 = UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'EmailSubject', 'Partnership Confirmation', beh.Id, 'Talabat_Opportunity_Quote', true, false);
        Business_Config__c b8 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','Enable','True',beh.Id,'Talabat_Opportunity',true,false);
        Business_Config__c b9 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','opportunityName','Premium Placement',beh.Id,'Talabat_Opportunity',true,false);
        Business_Config__c b10 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','opportunityType','Product Only',beh.Id,'Talabat_Opportunity',true,false);
        Business_Config__c b11 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','businessType','Upgrade/Upsell',beh.Id,'Talabat_Opportunity',true,false);
        Business_Config__c b12 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','stageName','Verbal Agreement',beh.Id,'Talabat_Opportunity',true,false);
        Business_Config__c b13 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','oppLineItemType','Product',beh.Id,'Talabat_Opportunity',true,false);
        Business_Config__c b14 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','discountType','%',beh.Id,'Talabat_Opportunity',true,false);
        Business_Config__c b15 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','tarifName','Premium Placement',beh.Id,'Talabat_Opportunity',true,false);

        insert new List<sObject> { b1, b2, b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15};

        Account acco = UnitTestDataFactory.createAccount('TEST', beh, 'Talabat_Account');
        acco.Type = 'Branch - main';
        acco.Backend_ID__c = '83G63';
        acco.GRID__c = '4O2N63';
        insert acco;
        List<account> accountlist = new List<account>();
        accountlist.add(acco);

        list<Contact> contacts = UnitTestDataFactory.CreateContacts(accountlist, 'Best', 'Burger', 'Mr', 'Employee', 1, 'test', 'Talabat_Contact');
        contacts[0].Contact_Role__c = 'Owner';
        insert contacts;

        Company__c com_bh = UnitTestDataFactory.createCompany('Talabat Bahrain', 'Talabat', beh);
        insert com_bh;

        Tarif__c t = UnitTestDataFactory.createTarif(com_bh, beh, 'Premium Placement SE', 'Talabat_Tarif', false);
        insert t;
        t.Is_Active__c = true;
        update t;

        Opportunity oppt = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'Talabat_Opportunity', Date.today());
        oppt.Business_Type__c = 'Upgrade/Upsell';
        oppt.Id_Tarif__r = t;
        oppt.StageName = 'Verbal Agreement';
        oppt.CurrencyIsoCode = 'BHD';
        oppt.Source_System__c = 'MIDAS';
        oppt.Type = 'Product Only';
        oppt.Country__c = beh.Id;

        Opportunity oppt2 = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'Talabat_Opportunity', Date.today());
        oppt2.Business_Type__c = 'Upgrade/Upsell';
        oppt2.Country__c = beh.Id;
        oppt2.Id_Tarif__r = t;
        oppt2.StageName = 'Verbal Agreement';
        oppt2.CurrencyIsoCode = 'BHD';
        oppt2.Source_System__c = 'MIDAS';
        oppt2.Type = 'Product Only';

        Opportunity oppt3 = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'Talabat_Opportunity', Date.today());
        oppt3.Business_Type__c = 'Upgrade/Upsell';
        oppt3.Id_Tarif__r = t;
        oppt3.StageName = 'Verbal Agreement';
        oppt3.CurrencyIsoCode = 'BHD';
        oppt3.Source_System__c = 'MIDAS';
        oppt3.Type = 'Product Only';
        oppt3.Country__c = beh.Id;

        insert new List<Opportunity>{oppt, oppt2, oppt3};

        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com_bh, beh, 'Premium Placement API', 'Talabat_List_Product_Group');
        insert lpg;

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com_bh, beh, 'Premium Placement', lpg.id, 'Talabat_List_Product_Price', 1, true, 100, 1, false, 20);
        lpp.Displayed_Name__c = 'Premium Placement';
        lpp.Requires_Additional_Charge__c = true;
        insert lpp;

        List<Opportunity_Line_Item__c> lineItems = UnitTestDataFactory.createOpportunityLineItems(oppt, lpg.id, lpp.id, 2, true, 'Talabat_Opportunity_Line_Item', 1, '10', 299.0, 1, 1, 'Product');
        lineItems.addAll(UnitTestDataFactory.createOpportunityLineItems(oppt2, lpg.id, lpp.id, 2, true, 'Talabat_Opportunity_Line_Item', 1, '10', 299.0, 1, 1, 'Product'));
        lineItems.addAll(UnitTestDataFactory.createOpportunityLineItems(oppt3, lpg.id, lpp.id, 2, true, 'Talabat_Opportunity_Line_Item', 1, '10', 299.0, 1, 1, 'Product'));
        integer n = 0;
        for (Opportunity_Line_Item__c lineItem : lineItems) {
            n++;
            lineItem.Booking_Api_Id__c = '1234'+n;
            lineItem.Midas_Exception__c = true;
        }
        insert lineItems;

        List<Opportunity_Quote__c> quotes_1 = UnitTestDataFactory.createOpportunityQuotes(oppt, 1, 'Talabat_Opportunity_Quote', 'Accepted', 'TEST', 100, 100, 'Test', 'Test', 10);
        insert quotes_1;

        List<Opportunity_Quote_Line_Item__c> oqp=UnitTestDataFactory.createOpportunityQuoteLineItems(quotes_1[0],lpp.id,lpg.Name,2,true,'Talabat_Opportunity_Quote_Line_Item',1,'1',200.0,1,300.0,'Product');
        insert oqp;

        oppt.StageName = 'Closed Won';
        oppt2.StageName = 'Closed Lost';
        oppt3.StageName = 'Closed Won';
        update new List<Opportunity>{oppt, oppt2, oppt3};

        insert new Additional_Charges__c(
                Id_Opportunity__c = oppt.Id,
                Id_Account__c = oppt.AccountId,
                RecordTypeId = mapRecordtypes.get('Talabat_Additional_Charges').Id,
                Status__c = 'Terminated',
                Booking_Api_Id__c = lineItems[0].Booking_Api_Id__c,
                Termination_Date__c = Date.today()
        );


    }


    public class MidasCalloutMock implements HttpCalloutMock {

        private final Boolean fail;

        public MidasCalloutMock(Boolean fail) {
            this.fail = fail;
        }

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            if (request.getEndpoint().contains('callout:Midas_Heimdall?grant_type=client_credentials&scope=sales_force')) {
                String responseBody = '{"access_token" : "tokenMock"}';
                response.setBody(responseBody);
                response.setStatusCode(200);
            } else if (this.fail) {
                response.setStatusCode(500);
                response.setStatus('Internal server error');
            } else if (request.getEndpoint().contains('callout:Midas_Hannibal/sites/TB_BH/bookings/')) {
                Integer statusCode = checkRequestBody(request.getBody());
                response.setStatusCode(statusCode);
            } else {
                response.setStatusCode(404);
            }
            return response;
        }

    }

    /**
     * @description Check if the request is done for one opportunity at the time.
     * @param requestBody the request body
     * @return request status code
    */
    private static Integer checkRequestBody(String requestBody) {
        List<LibWebserviceHelper.oppLineItemBookingData> bookingData = (List<LibWebserviceHelper.oppLineItemBookingData>) JSON.deserialize(requestBody, List<LibWebserviceHelper.oppLineItemBookingData>.class);
        List<Opportunity_Line_Item__c> lineItems = OpportunityLineItem_Selector.getAll();
        Map<String, Opportunity_Line_Item__c> bookingLineItemMap = (Map<String, Opportunity_Line_Item__c>) ClsSObjectUtils.convertToSingleStringMap(lineItems, Opportunity_Line_Item__c.Booking_Api_Id__c.getDescribe().getLocalName());
        Set<Id> opportunityIds = new Set<Id>();
        for (LibWebserviceHelper.oppLineItemBookingData bookingItem: bookingData) {
            Id opportunityId = bookingLineItemMap.get(String.valueOf(bookingItem.id)).Id_Opportunity__c;
            if (opportunityIds.contains(opportunityId)) {
                continue;
            }
            opportunityIds.add(opportunityId);
        }
        return opportunityIds.size() > 1 ? 500: 204;
    }

}