/**
 * Created by c.kumari on 09.05.2019.
 */

@isTest
private class BookingService_Test {

    @isTest static void testRestBookingServiceSuccess() {
        //setup wrapper data
        List<BookingService.OppLineItem> listBookLI = new List<BookingService.OppLineItem>();

        BookingService.OppLineItem bookLI = new BookingService.OppLineItem();
        bookLI.productName = 'Premium Placement';
        bookLI.promoAreaName = 'test';
        bookLI.promoAreaId = '5183';
        bookLI.startDate = '2019-5-1';
        bookLI.endDate = '2019-5-30';
        bookLI.restaurantPosition = '1st';
        bookLI.listPrice = 1000;
        bookLI.discount = '10';
        bookLI.totalAmount = 1000;
        bookLI.bookingId = '74847';
        listBookLI.add(bookLI);

        BookingService.bookingDetails book = new BookingService.bookingDetails();
        book.restaurantGridId = '4O2N63';
        book.Platform = 'Talabat';
        book.Country = 'Bahrain';
        book.Owner = 'test@deliveryhero.com';
        book.paymentMethod = 'Cash';
        book.type = 'Create';
        book.oppLineItem = listBookLI;
        book.sourceSystem = 'MIDAS';
        String JsonMsg =JSON.serialize(book);

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/BookingService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        BookingService.processRequestWrapper();
        System.assertEquals(500,res.statusCode);
        Test.stopTest();
    }
    
    @isTest static void testRestBookingServiceSuccessCancel() {
        //setup wrapper data
        List<BookingService.OppLineItem> listBookLI = new List<BookingService.OppLineItem>();

        BookingService.OppLineItem bookLI = new BookingService.OppLineItem();
        bookLI.productName = 'Premium Placement';
        bookLI.promoAreaName = 'test';
        bookLI.promoAreaId = '5183';
        bookLI.startDate = '2019-5-1';
        bookLI.endDate = '2019-5-30';
        bookLI.restaurantPosition = '1st';
        bookLI.listPrice = 1000;
        bookLI.discount = '10';
        bookLI.totalAmount = 1000;
        bookLI.bookingId = '74847';
        listBookLI.add(bookLI);

        BookingService.bookingDetails book = new BookingService.bookingDetails();
        book.restaurantGridId = '4O2N63';
        book.Platform = 'Talabat';
        book.Country = 'Bahrain';
        book.Owner = 'test@deliveryhero.com';
        book.paymentMethod = 'Cash';
        book.type = 'Cancel';
        book.oppLineItem = listBookLI;
        book.sourceSystem = 'MIDAS';
        String JsonMsg =JSON.serialize(book);

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/BookingService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        BookingService.processRequestWrapper();
        System.assertEquals(500,res.statusCode);
        Test.stopTest();
    }

    @isTest static void testRestBookingServiceJoker() {
        Logging__c logConfig =new Logging__c(SetupOwnerId=Userinfo.getUserId());
        logConfig.DISABLE_MIDAS__C = false;
        logConfig.NUMBER_OF_DAYS__c = 30;
        insert logConfig;
        //setup wrapper data
        Account account = AccountSelector.getAccountByName('TEST');
        List<BookingService.OppLineItem> listBookLI = new List<BookingService.OppLineItem>();

        BookingService.OppLineItem bookLI = new BookingService.OppLineItem();
        bookLI.productName = 'Joker';
        bookLI.promoAreaName = '';
        bookLI.promoAreaId = '';
        bookLI.startDate = '2019-5-1';
        bookLI.endDate = '2019-5-30';
        bookLI.restaurantPosition = '';
        bookLI.listPrice = null;
        bookLI.discount = '';
        bookLI.totalAmount = null;
        bookLI.bookingId = '748499';
        bookLI.budget = null;
        bookLI.subProductName = '';
        bookLI.interval = 'day';
        bookLI.quantity = 3;
        bookLI.costPerUnit = 2.5;
        listBookLI.add(bookLI);

        BookingService.bookingDetails book = new BookingService.bookingDetails();
        book.restaurantGridId = account.GRID__c;
        book.Platform = 'Talabat';
        book.Country = 'Bahrain';
        book.Owner = 'test@deliveryhero.com';
        book.paymentMethod = 'Cash';
        book.type = 'Create';
        book.oppLineItem = listBookLI;
        book.sourceSystem = 'MIDAS';
        String JsonMsg =JSON.serialize(book);

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/BookingService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        BookingService.processRequestWrapper();
        System.assertNotEquals(500,res.statusCode);
        List<Opportunity_Line_Item__c> olis = OpportunityLineItem_Selector.getOLIByBookingId(new List<String>{'748499'});
        System.assertEquals(1, olis.size());
        for (Opportunity_Line_Item__c lineItem: olis) {
            System.assertEquals(bookLI.interval, lineItem.Interval__c);
            System.assertEquals(bookLI.quantity, lineItem.Quantity__c);
            System.assertEquals(bookLI.costPerUnit, lineItem.Unit_Cost__c);
            System.assertEquals(bookLI.productName, lineItem.Name);
        }
        Opportunity_Quote__c quote;
        List<Opportunity_Quote_Line_Item__c> qlineItems = OpportunityQuoteLineItem_Selector.getAll();
        for (Opportunity_Quote_Line_Item__c qlineItem: qlineItems) {
            if (qlineItem.Booking_Api_Id__c == '748499') {
                System.assertEquals(bookLI.interval, qlineItem.Interval__c);
                System.assertEquals(bookLI.quantity, qlineItem.Quantity__c);
                System.assertEquals(bookLI.costPerUnit, qlineItem.Unit_Cost__c);
                System.assertEquals(bookLI.budget, qlineItem.Budget__c);
                quote = OpportunityQuoteSelector.findQuotesbyIds(new Set<Id>{qlineItem.Id_Opportunity_Quote__c})[0];
            }
        }
        System.assert(quote != null);
        quote.Status__c = 'Accepted';
        update quote;
        Opportunity opp = Opportunity_Selector.getOpportunityById(olis[0].Id_Opportunity__c);
        System.assertEquals(bookLI.productName, opp.Name);
        opp.StageName = 'Closed Won';
        update opp;

        List<Additional_Charges__c> additionalCharges = AdditionalChargesSelector.getAdditionalChargesByBookingID(new Set<String>{'748499'});
        System.assertEquals(1, additionalCharges.size());
        System.assertEquals(bookLI.interval, additionalCharges[0].Interval__c);
        System.assertEquals(bookLI.quantity, additionalCharges[0].Quantity__c);
        System.assertEquals(bookLI.costPerUnit, additionalCharges[0].Unit_Cost__c);
        System.assertEquals(bookLI.budget, additionalCharges[0].Budget__c);
        System.assertEquals('Active', additionalCharges[0].Status__c);
        Test.stopTest();
    }

    @isTest static void testRestBookingServiceCuisinePlacements() {
        Logging__c logConfig =new Logging__c(SetupOwnerId=Userinfo.getUserId());
        logConfig.DISABLE_MIDAS__C = false;
        logConfig.NUMBER_OF_DAYS__c = 30;
        insert logConfig;
        //setup wrapper data
        Account account = AccountSelector.getAccountByName('TEST');
        List<BookingService.OppLineItem> listBookLI = new List<BookingService.OppLineItem>();

        BookingService.OppLineItem bookLI = new BookingService.OppLineItem();
        bookLI.productName = 'Premium Placement Cuisine';
        bookLI.promoAreaName = 'Promo Area';
        bookLI.promoAreaId = '11234';
        bookLI.startDate = '2019-5-1';
        bookLI.endDate = '2019-5-30';
        bookLI.restaurantPosition = '2nd';
        bookLI.listPrice = 15;
        bookLI.discount = '';
        bookLI.totalAmount = 24;
        bookLI.bookingId = '748499';
        bookLI.budget = null;
        bookLI.subProductName = 'Center';
        bookLI.interval = '';
        bookLI.quantity = 3;
        bookLI.costPerUnit = null;
        listBookLI.add(bookLI);

        BookingService.bookingDetails book = new BookingService.bookingDetails();
        book.restaurantGridId = account.GRID__c;
        book.Platform = 'Talabat';
        book.Country = 'Bahrain';
        book.Owner = 'test@deliveryhero.com';
        book.paymentMethod = 'Cash';
        book.type = 'Create';
        book.oppLineItem = listBookLI;
        book.sourceSystem = 'MIDAS';
        String JsonMsg =JSON.serialize(book);

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/BookingService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        BookingService.processRequestWrapper();
        System.assertNotEquals(500,res.statusCode);
        List<Opportunity_Line_Item__c> olis = OpportunityLineItem_Selector.getOLIByBookingId(new List<String>{'748499'});
        System.assertEquals(1, olis.size());
        for (Opportunity_Line_Item__c lineItem: olis) {
            System.assertEquals(bookLI.subProductName, lineItem.Sub_Product_Name__c);
        }
        Opportunity_Quote__c quote;
        List<Opportunity_Quote_Line_Item__c> qlineItems = OpportunityQuoteLineItem_Selector.getAll();
        for (Opportunity_Quote_Line_Item__c qlineItem: qlineItems) {
            if (qlineItem.Booking_Api_Id__c == '748499') {
                System.assertEquals(bookLI.subProductName, qlineItem.Sub_Product_Name__c);
                quote = OpportunityQuoteSelector.findQuotesbyIds(new Set<Id>{qlineItem.Id_Opportunity_Quote__c})[0];
            }
        }
        System.assert(quote != null);
        quote.Status__c = 'Accepted';
        update quote;
        Opportunity opp = Opportunity_Selector.getOpportunityById(olis[0].Id_Opportunity__c);
        System.assertEquals(bookLI.productName, opp.Name);
        opp.StageName = 'Closed Won';
        update opp;

        List<Additional_Charges__c> additionalCharges = AdditionalChargesSelector.getAdditionalChargesByBookingID(new Set<String>{'748499'});
        System.assertEquals(1, additionalCharges.size());
        System.assertEquals(bookLI.subProductName, additionalCharges[0].Sub_Product_Name__c);
        System.assertEquals('Active', additionalCharges[0].Status__c);
        Test.stopTest();
    }

    @isTest static void testRestBookingMarketingPackage() {
        Logging__c logConfig =new Logging__c(SetupOwnerId=Userinfo.getUserId());
        logConfig.DISABLE_MIDAS__C = false;
        logConfig.NUMBER_OF_DAYS__c = 30;
        insert logConfig;
        //setup wrapper data
        Account account = AccountSelector.getAccountByName('TEST');
        List<BookingService.OppLineItem> listBookLI = new List<BookingService.OppLineItem>();

        BookingService.OppLineItem bookLI = new BookingService.OppLineItem();
        bookLI.productName = 'Marketing Packages';
        bookLI.promoAreaName = '';
        bookLI.promoAreaId = '';
        bookLI.startDate = '2019-5-1';
        bookLI.endDate = '2019-5-30';
        bookLI.restaurantPosition = '';
        bookLI.listPrice = null;
        bookLI.discount = '';
        bookLI.totalAmount = 1000;
        bookLI.bookingId = '748499';
        bookLI.budget = 600;
        bookLI.subProductName = 'acquisition';
        bookLI.interval = 'month';
        bookLI.quantity = null;
        bookLI.costPerUnit = 10;
        listBookLI.add(bookLI);

        BookingService.bookingDetails book = new BookingService.bookingDetails();
        book.restaurantGridId = account.GRID__c;
        book.Platform = 'Talabat';
        book.Country = 'Bahrain';
        book.Owner = 'test@deliveryhero.com';
        book.paymentMethod = 'Cash';
        book.type = 'Create';
        book.oppLineItem = listBookLI;
        book.sourceSystem = 'MIDAS';
        String JsonMsg =JSON.serialize(book);

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/BookingService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        BookingService.processRequestWrapper();
        System.assertNotEquals(500,res.statusCode);
        List<Opportunity_Line_Item__c> olis = OpportunityLineItem_Selector.getOLIByBookingId(new List<String>{'748499'});
        System.assertEquals(1, olis.size());
        for (Opportunity_Line_Item__c lineItem: olis) {
            System.assertEquals(bookLI.interval, lineItem.Interval__c);
            System.assertEquals(bookLI.quantity, lineItem.Quantity__c);
            System.assertEquals(bookLI.costPerUnit, lineItem.Unit_Cost__c);
            System.assertEquals(bookLI.budget, lineItem.Budget__c);
        }
        Opportunity_Quote__c quote;
        List<Opportunity_Quote_Line_Item__c> qlineItems = OpportunityQuoteLineItem_Selector.getAll();
        for (Opportunity_Quote_Line_Item__c qlineItem: qlineItems) {
            if (qlineItem.Booking_Api_Id__c == '748499') {
                System.assertEquals(bookLI.interval, qlineItem.Interval__c);
                System.assertEquals(bookLI.quantity, qlineItem.Quantity__c);
                System.assertEquals(bookLI.costPerUnit, qlineItem.Unit_Cost__c);
                System.assertEquals(bookLI.budget, qlineItem.Budget__c);
                quote = OpportunityQuoteSelector.findQuotesbyIds(new Set<Id>{qlineItem.Id_Opportunity_Quote__c})[0];
            }
        }
        System.assert(quote != null);
        quote.Status__c = 'Accepted';
        update quote;
        Opportunity opp = Opportunity_Selector.getOpportunityById(olis[0].Id_Opportunity__c);
        opp.StageName = 'Closed Won';
        update opp;

        List<Additional_Charges__c> additionalCharges = AdditionalChargesSelector.getAdditionalChargesForOpportunity(new Set<Id>{olis[0].Id_Opportunity__c});
        System.assertEquals(1, additionalCharges.size());
        System.assertEquals(bookLI.interval, additionalCharges[0].Interval__c);
        System.assertEquals(bookLI.quantity, additionalCharges[0].Quantity__c);
        System.assertEquals(bookLI.costPerUnit, additionalCharges[0].Unit_Cost__c);
        System.assertEquals(bookLI.subProductName, additionalCharges[0].Sub_Product_Name__c);
        System.assertEquals(bookLI.budget, additionalCharges[0].Budget__c);
        System.assertEquals('Draft', additionalCharges[0].Status__c);
        Test.stopTest();
    }

    @isTest static void testRestBookingServiceCuisinePlacements_Cancel() {

        Logging__c logConfig =new Logging__c(SetupOwnerId=Userinfo.getUserId());
        logConfig.DISABLE_MIDAS__C = false;
        logConfig.NUMBER_OF_DAYS__c = 30;
        insert logConfig;
        //setup wrapper data
        Account account = AccountSelector.getAccountByName('TEST');
        List<BookingService.OppLineItem> listBookLI = new List<BookingService.OppLineItem>();

        BookingService.OppLineItem bookLI = new BookingService.OppLineItem();
        bookLI.productName = 'Premium Placement Cuisine';
        bookLI.promoAreaName = 'Promo Area';
        bookLI.promoAreaId = '11234';
        bookLI.startDate = '2019-5-1';
        bookLI.endDate = '2019-5-30';
        bookLI.restaurantPosition = '2nd';
        bookLI.listPrice = 15;
        bookLI.discount = '';
        bookLI.totalAmount = 24;
        bookLI.bookingId = '748499';
        bookLI.budget = null;
        bookLI.subProductName = 'Center';
        bookLI.interval = '';
        bookLI.quantity = 3;
        bookLI.costPerUnit = null;
        listBookLI.add(bookLI);

        BookingService.bookingDetails book = new BookingService.bookingDetails();
        book.restaurantGridId = account.GRID__c;
        book.Platform = 'Talabat';
        book.Country = 'Bahrain';
        book.Owner = 'test@deliveryhero.com';
        book.paymentMethod = 'Cash';
        book.type = 'Cancel';
        book.oppLineItem = listBookLI;
        book.sourceSystem = 'MIDAS';
        String JsonMsg =JSON.serialize(book);

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/BookingService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        BookingService.processRequestWrapper();
        Test.stopTest();
    }

    @IsTest static void testRestBookingServiceSelfBookingOwner() {
        Logging__c logConfig =new Logging__c(SetupOwnerId=UserInfo.getUserId());
        logConfig.DISABLE_MIDAS__c = false;
        logConfig.DISABLE_MIDAS_SELFBOOKING__c = false;
        logConfig.NUMBER_OF_DAYS__c = 30;
        insert logConfig;
        //setup wrapper data
        Account account = AccountSelector.getAccountByName('TEST_FP');
        List<BookingService.OppLineItem> listBookLI = new List<BookingService.OppLineItem>();

        BookingService.OppLineItem bookLI = new BookingService.OppLineItem();
        bookLI.productName = 'Joker';
        bookLI.promoAreaName = '';
        bookLI.promoAreaId = '';
        bookLI.startDate = '2019-5-1';
        bookLI.endDate = '2019-5-30';
        bookLI.restaurantPosition = '';
        bookLI.listPrice = null;
        bookLI.discount = '';
        bookLI.totalAmount = null;
        bookLI.bookingId = '748499';
        bookLI.budget = null;
        bookLI.subProductName = '';
        bookLI.interval = 'day';
        bookLI.quantity = 3;
        bookLI.costPerUnit = 2.5;
        listBookLI.add(bookLI);

        BookingService.bookingDetails book = new BookingService.bookingDetails();
        book.restaurantGridId = account.GRID__c;
        book.Platform = 'FP';
        book.Country = 'Malaysia';
        book.Owner = 'test_contact_0_@deliveryhero.com';
        book.paymentMethod = 'Cash';
        book.type = 'Create';
        book.oppLineItem = listBookLI;
        book.sourceSystem = 'Restaurant Portal Service';
        String JsonMsg =JSON.serialize(book);

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/BookingService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        BookingService.processRequestWrapper();
        System.assertNotEquals(500,res.statusCode);
        List<Opportunity_Line_Item__c> olis = OpportunityLineItem_Selector.getOLIByBookingId(new List<String>{'748499'});
        System.assertEquals(1, olis.size());
        for (Opportunity_Line_Item__c lineItem: olis) {
            System.assertEquals(bookLI.interval, lineItem.Interval__c);
            System.assertEquals(bookLI.quantity, lineItem.Quantity__c);
            System.assertEquals(bookLI.costPerUnit, lineItem.Unit_Cost__c);
            System.assertEquals(bookLI.productName, lineItem.Name);
        }
        List<Opportunity_Quote_Line_Item__c> qlineItems = OpportunityQuoteLineItem_Selector.getAll();
        for (Opportunity_Quote_Line_Item__c qlineItem: qlineItems) {
            if (qlineItem.Booking_Api_Id__c == '748499') {
                System.assertEquals(bookLI.interval, qlineItem.Interval__c);
                System.assertEquals(bookLI.quantity, qlineItem.Quantity__c);
                System.assertEquals(bookLI.costPerUnit, qlineItem.Unit_Cost__c);
                System.assertEquals(bookLI.budget, qlineItem.Budget__c);
            }
        }
        Opportunity opp = Opportunity_Selector.getOpportunityById(olis[0].Id_Opportunity__c);
        System.assert(opp.Selfbooking_Owner__c != null);
        Contact cont = ContactSelector.getNonPrimaryContactListForAccount(account.Id, '').get(0);
        System.assertEquals(cont.Id, opp.Selfbooking_Owner__c);
        Test.stopTest();
    }

    @IsTest static void testRestBookingServiceSelfBookingOwnerMissing() {
        Logging__c logConfig =new Logging__c(SetupOwnerId=UserInfo.getUserId());
        logConfig.DISABLE_MIDAS__c = false;
        logConfig.DISABLE_MIDAS_SELFBOOKING__c = false;
        logConfig.NUMBER_OF_DAYS__c = 30;
        insert logConfig;
        //setup wrapper data
        Account account = AccountSelector.getAccountByName('TEST_FP');
        List<BookingService.OppLineItem> listBookLI = new List<BookingService.OppLineItem>();

        BookingService.OppLineItem bookLI = new BookingService.OppLineItem();
        bookLI.productName = 'Joker';
        bookLI.promoAreaName = '';
        bookLI.promoAreaId = '';
        bookLI.startDate = '2019-5-1';
        bookLI.endDate = '2019-5-30';
        bookLI.restaurantPosition = '';
        bookLI.listPrice = null;
        bookLI.discount = '';
        bookLI.totalAmount = null;
        bookLI.bookingId = '748499';
        bookLI.budget = null;
        bookLI.subProductName = '';
        bookLI.interval = 'day';
        bookLI.quantity = 3;
        bookLI.costPerUnit = 2.5;
        listBookLI.add(bookLI);

        BookingService.bookingDetails book = new BookingService.bookingDetails();
        book.restaurantGridId = account.GRID__c;
        book.Platform = 'FP';
        book.Country = 'Malaysia';
        book.Owner = 'test_contact_0_@deliveryhero.com';
        book.paymentMethod = 'Cash';
        book.type = 'Create';
        book.oppLineItem = listBookLI;
        book.sourceSystem = 'Midas';
        String JsonMsg =JSON.serialize(book);

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/BookingService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        BookingService.processRequestWrapper();
        System.assertNotEquals(500,res.statusCode);
        List<Opportunity_Line_Item__c> olis = OpportunityLineItem_Selector.getOLIByBookingId(new List<String>{'748499'});
        System.assertEquals(1, olis.size());
        for (Opportunity_Line_Item__c lineItem: olis) {
            System.assertEquals(bookLI.interval, lineItem.Interval__c);
            System.assertEquals(bookLI.quantity, lineItem.Quantity__c);
            System.assertEquals(bookLI.costPerUnit, lineItem.Unit_Cost__c);
            System.assertEquals(bookLI.productName, lineItem.Name);
        }
        List<Opportunity_Quote_Line_Item__c> qlineItems = OpportunityQuoteLineItem_Selector.getAll();
        for (Opportunity_Quote_Line_Item__c qlineItem: qlineItems) {
            if (qlineItem.Booking_Api_Id__c == '748499') {
                System.assertEquals(bookLI.interval, qlineItem.Interval__c);
                System.assertEquals(bookLI.quantity, qlineItem.Quantity__c);
                System.assertEquals(bookLI.costPerUnit, qlineItem.Unit_Cost__c);
                System.assertEquals(bookLI.budget, qlineItem.Budget__c);
            }
        }
        Opportunity opp = Opportunity_Selector.getOpportunityById(olis[0].Id_Opportunity__c);
        System.assertEquals(null, opp.Selfbooking_Owner__c);
        Test.stopTest();
    }

    @isTest static void testRestBookingServiceFailure() {

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/BookingService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('Test Data');
        RestContext.request = req;
        RestContext.response = res;
        BookingService.processRequestWrapper();
        Test.stopTest();
       System.assertEquals(500,res.statusCode);

    }

    @TestSetup
    public static void setup() {

        Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Case','Additional_Charges__c'});
        UnitTestDataFactory.getRecordtypeValues();

        Country__c beh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        insert beh;
        Country__c my = UnitTestDataFactory.createCountry('MY', 'Malaysia', 'MYR');
        insert my;

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
        Business_Config__c b19 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','nonPremiumPlacementProducts','{"Joker": {"Opportunity": "Joker","Tarif":"Joker"},"Marketing Package": {"Opportunity":"Marketing Package","Tarif": "Marketing Package"},"Premium Placement Cuisine": {"Opportunity":"Premium Placement Cuisine"}}',beh.Id,'Talabat_Opportunity',true,false);
        Business_Config__c b12 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','stageName','Verbal Agreement',beh.Id,'Talabat_Opportunity',true,false);
        Business_Config__c b13 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','oppLineItemType','Product',beh.Id,'Talabat_Opportunity',true,false);
        Business_Config__c b14 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','discountType','%',beh.Id,'Talabat_Opportunity',true,false);
        Business_Config__c b15 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','tarifName','Premium Placement',beh.Id,'Talabat_Opportunity',true,false);
        Business_Config__c b16 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','invokeAutomaticQuoteGeneration','TRUE',beh.Id,'Talabat_Opportunity',true,false);
        Business_Config__c b20 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','cancellationAllowed','TRUE',beh.Id,'Talabat_Opportunity',true,false);
		Business_Config__c b17 = UnitTestDataFactory.createBusinessConfig('nintexDocumentGeneration', 'Process','deliveryOptionName','Attachment', beh.id, 'Talabat_Opportunity', true, false);
        Business_Config__c b18 = UnitTestDataFactory.createBusinessConfig('nintexDocumentGeneration', 'Process','docGenPackageName','Quotes', beh.id, 'Talabat_Opportunity', true, false);
        Business_Config__c b21 = UnitTestDataFactory.createBusinessConfig('PermiumPlacementOpp','Process','EnabledForCountry','Bahrain',beh.Id,'Talabat_Opportunity',true,false);
        Business_Config__c bb1 = new Business_Config__c(Business_Rule_Name__c='OppQuoteEmailTemplate',Business_Rule_Value__c='TestTemplate',Id_Country__c=my.id,Is_Active__c=true,Parent__c=true,Process_Name__c='OppQuoteProcess',Record_Type_Id__c='FP_Account',Type__c='Process');
        Business_Config__c bb2 = new Business_Config__c(Business_Rule_Name__c = 'Status__c', Business_Rule_Value__c = 'Accepted', Id_Country__c = my.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'OppTypeAndStageProcess', Record_Type_Id__c = 'FP_Opportunity_Quote', Type__c = 'Process');
        Business_Config__c bb3 = new Business_Config__c(Business_Rule_Name__c = 'Product Only', Business_Rule_Value__c = 'stageName=Quality Check Request,Probability=95', Id_Country__c = my.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'OppTypeAndStageProcess', Record_Type_Id__c = 'FP_Opportunity_Quote', Type__c = 'Process');
        Business_Config__c bb4 = new Business_Config__c(Business_Rule_Name__c = 'opportunity stage', Business_Rule_Value__c = 'Closed Won', Id_Country__c = my.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'FP_Opportunity', Type__c = 'Process');
        Business_Config__c bb5 = new Business_Config__c(Business_Rule_Name__c = 'AdditionalCharges RecordType', Business_Rule_Value__c = 'FP_Additional_Charges', Id_Country__c = my.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'FP_Opportunity', Type__c = 'Process');
        Business_Config__c bb6 = UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'EmailTemplateMap', '{"New Business":"FP_NB_EmailTemplate","UpgradeUpsell":"FP_ProductOnly_EmailTemplate","Premium Placement":"FP_PP_EmailTemplate"}', my.Id, 'FP_Opportunity_Quote', true, true);
        Business_Config__c bb7 = UnitTestDataFactory.createBusinessConfig('EmailConfiguration', 'Process', 'EmailSubject', 'Partnership Confirmation', my.Id, 'FP_Opportunity_Quote', true, false);
        Business_Config__c bb8 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','Enable','True',my.Id,'FP_Opportunity',true,false);
        Business_Config__c bb9 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','opportunityName','Premium Placement',my.Id,'FP_Opportunity',true,false);
        Business_Config__c bb10 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','opportunityType','Product Only',my.Id,'FP_Opportunity',true,false);
        Business_Config__c bb11 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','businessType','Upgrade/Upsell',my.Id,'FP_Opportunity',true,false);
        Business_Config__c bb19 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','nonPremiumPlacementProducts','{"Joker": {"Opportunity": "Joker","Tarif":"Joker"},"Marketing Package": {"Opportunity":"Marketing Package","Tarif": "Marketing Package"},"Premium Placement Cuisine": {"Opportunity":"Premium Placement Cuisine"}}',my.Id,'FP_Opportunity',true,false);
        Business_Config__c bb12 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','stageName','Verbal Agreement',my.Id,'FP_Opportunity',true,false);
        Business_Config__c bb13 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','oppLineItemType','Product',my.Id,'FP_Opportunity',true,false);
        Business_Config__c bb14 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','discountType','%',my.Id,'FP_Opportunity',true,false);
        Business_Config__c bb15 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','tarifName','Premium Placement',my.Id,'FP_Opportunity',true,false);
        Business_Config__c bb16 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','invokeAutomaticQuoteGeneration','TRUE',my.Id,'FP_Opportunity',true,false);
        Business_Config__c bb20 = UnitTestDataFactory.createBusinessConfig('Booking_Service','Process','cancellationAllowed','TRUE',my.Id,'FP_Opportunity',true,false);
        Business_Config__c bb17 = UnitTestDataFactory.createBusinessConfig('nintexDocumentGeneration', 'Process','deliveryOptionName','Attachment', my.id, 'FP_Opportunity', true, false);
        Business_Config__c bb18 = UnitTestDataFactory.createBusinessConfig('nintexDocumentGeneration', 'Process','docGenPackageName','Quotes', my.id, 'FP_Opportunity', true, false);
        Business_Config__c bb21 = UnitTestDataFactory.createBusinessConfig('PermiumPlacementOpp','Process','EnabledForCountry','Malaysia',my.Id,'FP_Opportunity',true,false);


        insert new List<sObject> { b1, b2, b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16,b17,b18,b19,b20,b21};
        insert new List<sObject> { bb1, bb2, bb3,bb4,bb5,bb6,bb7,bb8,bb9,bb10,bb11,bb12,bb13,bb14,bb15,bb16,bb17,bb18,bb19,bb20,bb21};
            
        //CREATE DDP TEST DATA
        Loop__DDP__c ddp	= new Loop__DDP__c(Name='Quotes');
        insert ddp;

        Loop__DDP_Integration_Option__c	delivOpt = new Loop__DDP_Integration_Option__c(Name='Attachment',Loop__DDP__c=ddp.Id);
        insert delivOpt;

        Account acco = UnitTestDataFactory.createAccount('TEST', beh, 'Talabat_Account');
        acco.Type = 'Branch - main';
        acco.Backend_ID__c = '83G63';
        acco.GRID__c = '4O2N63';
        insert acco;
        List<account> accountlist = new List<account>();
        accountlist.add(acco);

        Account acc1 = UnitTestDataFactory.createAccount('TEST_FP', my, 'FP_Account');
        acc1.Type = 'Branch - main';
        acc1.Backend_ID__c = '83G64';
        acc1.GRID__c = '4O2N64';
        acc1.phone = '+6012345678';
        insert acc1;

        list<Contact> contacts = UnitTestDataFactory.CreateContacts(accountlist, 'Best', 'Burger', 'Mr', 'Employee', 1, 'test', 'Talabat_Contact');
        contacts[0].Contact_Role__c = 'Owner';
        contacts.addAll(UnitTestDataFactory.CreateContacts(new List<Account> {acc1}, 'Best', 'Burger', 'Mr', 'Employee', 1, 'test', 'FP_Contact'));
        contacts[1].Contact_Role__c = 'Owner';
        insert contacts;

        Company__c com_bh = UnitTestDataFactory.createCompany('Talabat Bahrain', 'Talabat', beh);
        insert com_bh;
        Company__c com_MY = UnitTestDataFactory.createCompany('Foodpanda', 'FP', my);
        insert com_MY;

        Tarif__c t = UnitTestDataFactory.createTarif(com_bh, beh, 'Premium Placement SE', 'Talabat_Tarif', false);
        Tarif__c t2 = UnitTestDataFactory.createTarif(com_bh, beh, 'Joker', 'Talabat_Tarif', false);
        Tarif__c t3 = UnitTestDataFactory.createTarif(com_bh, beh, 'Marketing Packages', 'Talabat_Tarif', false);
        Tarif__c tt = UnitTestDataFactory.createTarif(com_MY, my, 'Premium Placement SE', 'FP_Tarif', false);
        Tarif__c tt2 = UnitTestDataFactory.createTarif(com_MY, my, 'Joker', 'FP_Tarif', false);
        Tarif__c tt3 = UnitTestDataFactory.createTarif(com_MY, my, 'Marketing Packages', 'FP_Tarif', false);

        insert new List<Tarif__c>{t, t2, t3,tt,tt2,tt3};
        t.Is_Active__c = true;
        t2.Is_Active__c = true;
        t3.Is_Active__c = true;
        tt.Is_Active__c = true;
        tt2.Is_Active__c = true;
        tt3.Is_Active__c = true;
        update new List<Tarif__c>{t, t2, t3,tt,tt2,tt3};

        Opportunity oppt = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'Talabat_Opportunity', Date.today());
        oppt.Business_Type__c = 'Upgrade/Upsell';
        oppt.Id_Tarif__r = t;
        oppt.StageName = 'Verbal Agreement';
        oppt.CurrencyIsoCode = 'BHD';
        oppt.Source_System__c = 'MIDAS';
        oppt.type = 'Product Only';
        insert oppt;

        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com_bh, beh, 'Premium Placement API', 'Talabat_List_Product_Group');
        insert lpg;

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com_bh, beh, 'Premium Placement', lpg.id, 'Talabat_List_Product_Price', 1, true, 100, 1, false, 20);
        lpp.Displayed_Name__c = 'Premium Placement';
        lpp.Requires_Additional_Charge__c = true;

        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com_bh, beh, 'Joker', lpg.id, 'Talabat_List_Product_Price', 1, true, 100, 1, false, 20);
        lpp2.Displayed_Name__c = 'Joker';
        lpp2.Requires_Additional_Charge__c = true;

        List_Product_Price__c lpp3 = UnitTestDataFactory.createProduct(com_bh, beh, 'Marketing Packages', lpg.id, 'Talabat_List_Product_Price', 1, true, 100, 1, false, 20);
        lpp3.Displayed_Name__c = 'Marketing Packages';
        lpp3.Requires_Additional_Charge__c = true;

        List_Product_Price__c lpp4 = UnitTestDataFactory.createProduct(com_bh, beh, 'Premium Placement Cuisine', lpg.id, 'Talabat_List_Product_Price', 1, true, 100, 1, false, 20);
        lpp4.Displayed_Name__c = 'Premium Placement Cuisine';
        lpp4.Requires_Additional_Charge__c = true;
        insert new List<List_Product_Price__c> {lpp, lpp2, lpp3, lpp4};

        List_Product_Group__c lpgfp = UnitTestDataFactory.createProductGroup(com_MY, my, 'Premium Placement API', 'FP_List_Product_Group');
        insert lpgfp;

        List_Product_Price__c llpp = UnitTestDataFactory.createProduct(com_MY, my, 'Premium Placement', lpgfp.id, 'FP_List_Product_Price', 1, true, 100, 1, false, 20);
        llpp.Displayed_Name__c = 'Premium Placement';
        llpp.Requires_Additional_Charge__c = true;

        List_Product_Price__c llpp2 = UnitTestDataFactory.createProduct(com_MY, my, 'Joker', lpgfp.id, 'FP_List_Product_Price', 1, true, 100, 1, false, 20);
        llpp2.Displayed_Name__c = 'Joker';
        llpp2.Requires_Additional_Charge__c = true;

        List_Product_Price__c llpp3 = UnitTestDataFactory.createProduct(com_MY, my, 'Premium Placement Cuisine', lpgfp.id, 'FP_List_Product_Price', 1, true, 100, 1, false, 20);
        llpp3.Displayed_Name__c = 'Premium Placement Cuisine';
        llpp3.Requires_Additional_Charge__c = true;

        List_Product_Price__c llpp4 = UnitTestDataFactory.createProduct(com_MY, my, 'Marketing Packages', lpgfp.id, 'FP_List_Product_Price', 1, true, 100, 1, false, 20);
        llpp4.Displayed_Name__c = 'Marketing Packages';
        llpp4.Requires_Additional_Charge__c = true;
        insert new List<List_Product_Price__c>{llpp, llpp2, llpp3, llpp4};

        List<Opportunity_Line_Item__c> lineItems = UnitTestDataFactory.createOpportunityLineItems(oppt, lpg.id, lpp.id, 2, true, 'Talabat_Opportunity_Line_Item', 1, '10', 299.0, 1, 1, 'Product');
        integer n = 0;
        for (Opportunity_Line_Item__c lineItem : lineItems) {
            n++;
           lineItem.Booking_Api_Id__c = '1234'+n;
        }
        insert lineItems;

        List<Opportunity_Quote__c> quotes_1 = UnitTestDataFactory.createOpportunityQuotes(oppt, 1, 'Talabat_Opportunity_Quote', 'Accepted', 'TEST', 100, 100, 'Test', 'Test', 10);
        insert quotes_1;

        List<Opportunity_Quote_Line_Item__c> oqp=UnitTestDataFactory.createOpportunityQuoteLineItems(quotes_1[0],lpp.id,lpg.Name,2,true,'Talabat_Opportunity_Quote_Line_Item',1,'1',200.0,1,300.0,'Product');
        insert oqp;

        Test.startTest();

        Opportunity recOpp = [select id,StageName from Opportunity where id=:oppt.id];
        recOpp.StageName = 'Closed Won';
        update recOpp;

        Test.stopTest();

        insert new Additional_Charges__c(
                Id_Opportunity__c = oppt.Id,
                Id_Account__c = oppt.AccountId,
                RecordTypeId = mapRecordtypes.get('Talabat_Additional_Charges').Id
        );
        List<Additional_Charges__c> listAdd = [select id from Additional_Charges__c];
        System.assertEquals(1,listAdd.size());

        Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = oppt.id;
        attachment.Name = 'Test Attachment';
        attachment.Body = b;
        insert attachment;

        System.runAs([select Id from User where Id = :Userinfo.getUserId() limit 1][0]) {
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'Premium_Placement';
            validEmailTemplate.DeveloperName = 'Premium_Placement';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            insert validEmailTemplate;
        }
    }
}