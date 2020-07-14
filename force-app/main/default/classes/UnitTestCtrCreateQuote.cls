@isTest
private class UnitTestCtrCreateQuote {

    private static User testUser;
    private static Country__c testCountry;
    private static Company__c testCompany;
    private static List<Account> accounts;
    private static List<Opportunity> opportunities;
    private static List<Opportunity_Quote__c> oppqsYG;
    private static List<Opportunity_Quote__c> oppqsTb;
    private static List<List_Service_Price__c> services;
    private static List<Account> talabatAcc;
    private static User TalabatUser;
    private static country__c talabatCountry;
    private static company__c talabatCompany;
    private static List<Opportunity> Tbtopportunities;
    private static List<List_Service_Price__c> Tbtservices;
    private static List<Opportunity_Line_Item__c> TbtoppServiceItem;
    

    static {
        UnitTestDataFactory.getRecordtypeValues();
        List<Platform_Country__c> platformCountry =new List<Platform_Country__c>(); 
        platformCountry.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name='FOCPlatform', country__c='Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
        testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'yogiyouser@deliveryhero.com', 'Yogiyo', 'KR');
        insert testUser;
        talabatUser = UnitTestDataFactory.createUser('Talabat Sales Management', 'talabatuser@deliveryhero.com', 'Talabat', 'KW');
        insert talabatUser;
        System.runAs(testUser){
            testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            insert testCountry;
            testCompany = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', testCountry);
            insert testCompany;
            accounts = UnitTestDataFactory.createAccounts(2, testCountry, 'Yogiyo_Account'); 
            accounts[0].Payment_method__c = 'Cash';
            accounts[1].Payment_Method__c = 'Cash';
            accounts[0].BillingState = 'CA';
            accounts[0].BillingCity = 'San Francisco';
            accounts[0].Billing_GunGu__c = 'gaga';
            accounts[0].Billing_Dong__c = 'tetee';
            accounts[0].BillingPostalCode = '12345';
            accounts[0].BillingStreet = 'test str. 22';
            accounts[0].Delivery_Service__c = 'Unknown';
            services= UnitTestDataFactory.createServices(testCompany, testCountry, 10, 'Yogiyo_List_Service_Price', 13, 13, 15, 10, 1, '% per Order', true, 299, 'Monthly', 'Commission', 'ServiceType');           
            List<sObject> objectsToInsert1 = new List<sObject>();
            objectsToInsert1.addAll((List<sObject>)accounts);
            objectsToInsert1.addAll((List<sObject>)services);           
            insert objectsToInsert1;
            Contact owner = new Contact();
            owner.FirstName = 'test';
            owner.Salutation = 'Mr.';
            owner.LastName = 'lastn';
            owner.Phone = '123456';
            owner.Contact_Role__c = 'Owner';
            owner.AccountId = accounts[0].Id;
            insert owner;
            
            Contact manager = new Contact();
            manager.FirstName = 'test';
            manager.Salutation = 'Mr.';
            manager.LastName = 'lastn';
            manager.Phone = '123456';
            manager.Contact_Role__c = 'Manager';
            manager.AccountId = accounts[0].Id;
            insert manager;
            opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'Yogiyo_Opportunity', Date.today().addMonths(2));
            insert opportunities;
            Opportunity_Line_Item__c oppServiceItem = UnitTestDataFactory.createOpportunityLineItemService('commission Fee',opportunities[0], services[0].Id, false, 'Yogiyo_Opportunity_Line_Item', 13, null, Date.today(), 'Commission Fee', null);
            insert oppServiceItem;
            oppqsYG = UnitTestDataFactory.createOpportunityQuotes(opportunities[0], 1, 'Yogiyo_Opportunity_Quote', 'Accepted','testdata',10, 10, null,null,0);
            insert oppqsYG;
            insert UnitTestDataFactory.createOpportunityQuoteLineItem(oppqsYG[0],oppServiceItem,'Yogiyo_Opportunity_Quote_Line_Item');
        }
        
        System.runAs(talabatUser){
            talabatCountry = UnitTestDataFactory.createCountry('KW', 'Kuwait', 'KWD ');
            insert talabatCountry ;
            talabatCompany= UnitTestDataFactory.createCompany('Talabat', 'talabat', talabatCountry );
            insert talabatCompany;
            talabatAcc= UnitTestDataFactory.createAccounts(1, talabatCountry, 'Talabat_Account');           
            Tbtservices = UnitTestDataFactory.createServices(talabatCompany, talabatCountry, 10, 'Talabat_List_Service_Price', 13, 13, 15, 10, 1, '% per Order', true, 299, 'Monthly', 'Commission', 'ServiceType');           
            List<sObject> objectsToInsert1 = new List<sObject>();
            objectsToInsert1.addAll((List<sObject>)talabatAcc);
            objectsToInsert1.addAll((List<sObject>)Tbtservices );           
            insert objectsToInsert1;
            Tbtopportunities= UnitTestDataFactory.createOpportunities(talabatAcc, 1, 'Talabat_Opportunity', Date.today().addMonths(2));
            insert Tbtopportunities;
            Opportunity_Line_Item__c oppServiceItem = UnitTestDataFactory.createOpportunityLineItemService('commission Fee 2',Tbtopportunities[0], Tbtservices [0].Id, false, 'Talabat_Opportunity_Line_Item', 13, null, Date.today(), 'Commission Fee', null);
            insert oppServiceItem;
            oppqsTb = UnitTestDataFactory.createOpportunityQuotes(Tbtopportunities[0], 1, 'Yogiyo_Opportunity_Quote', 'Accepted','testdata',10, 10, null,null,0);
            insert oppqsTb;
            insert UnitTestDataFactory.createOpportunityQuoteLineItem(oppqsTb[0],oppServiceItem,'Yogiyo_Opportunity_Quote_Line_Item');


        }

        List<Business_Config__c> listConfigs = new List<Business_Config__c>();
        Business_Config__c config1 = UnitTestDataFactory.createBusinessConfig('OppQuoteProcess', 'Process', 'generalConditionsURLMap', '{     "Chile":{        "Logistics":"https://www.pedidosya.cl/condiciones-generales-logistica",      "Marketing":"https://www.pedidosya.cl/condiciones-generales-marketplace"   },   "Bolivia":{        "Logistics":"https://www.pedidosya.com.bo/condiciones-generales-logistica",      "Marketing":"https://www.pedidosya.com.bo/condiciones-generales-marketplace"   },   "Panamá":{        "Logistics":"https://www.appetito24.com.pa/condiciones-generales-logistica",      "Marketing":"https://www.appetito24.com.pa/condiciones-generales-marketplace"   },   "Paraguay":{        "Logistics":"https://www.pedidosya.com.py/condiciones-generales-marketplace",      "Marketing":"https://www.pedidosya.com.py/condiciones-generales-marketplace"   },   "Uruguay":{        "Logistics":"https://www.pedidosya.com.uy/condiciones-generales-logistica",      "Marketing":"https://www.pedidosya.com.uy/condiciones-generales-marketplace"   },   "Argentina":{        "Logistics":"https://www.pedidosya.com.ar/condiciones-generales-logistica",      "Marketing":"https://www.pedidosya.com.ar/condiciones-generales-marketplace"   }}', testCountry.Id, 'Yogiyo_Account', true, true);
        Business_Config__c config2 = UnitTestDataFactory.createBusinessConfig('OppQuoteProcess', 'Process', 'generalConditionsURLMap', '{     "Chile":{        "Logistics":"https://www.pedidosya.cl/condiciones-generales-logistica",      "Marketing":"https://www.pedidosya.cl/condiciones-generales-marketplace"   },   "Bolivia":{        "Logistics":"https://www.pedidosya.com.bo/condiciones-generales-logistica",      "Marketing":"https://www.pedidosya.com.bo/condiciones-generales-marketplace"   },   "Panamá":{        "Logistics":"https://www.appetito24.com.pa/condiciones-generales-logistica",      "Marketing":"https://www.appetito24.com.pa/condiciones-generales-marketplace"   },   "Paraguay":{        "Logistics":"https://www.pedidosya.com.py/condiciones-generales-marketplace",      "Marketing":"https://www.pedidosya.com.py/condiciones-generales-marketplace"   },   "Uruguay":{        "Logistics":"https://www.pedidosya.com.uy/condiciones-generales-logistica",      "Marketing":"https://www.pedidosya.com.uy/condiciones-generales-marketplace"   },   "Argentina":{        "Logistics":"https://www.pedidosya.com.ar/condiciones-generales-logistica",      "Marketing":"https://www.pedidosya.com.ar/condiciones-generales-marketplace"   }}', testCountry.Id, 'Talabat_Account', true, true);

        insert new List<sObject> {config1, config2};
    }

    @isTest static void test_getAccountWrapper() {
        Test.startTest();
        CtrCreateQuote ccq;
        System.runAs(testUser){
            ccq = new CtrCreateQuote();
            ccq.oppQId = oppqsYG[0].Id;
            ccq.acctId = accounts[0].Id;
            opportunity op1 =ccq.opportunity;
            opportunity_quote__c opq=ccq.oppQuote;
            //ccq.oppId = opportunities[0].Id;
            list<Opportunity_Quote_Line_Item__c>op=ccq.listLineItems;
            //list<Opportunity_Quote_Line_Item__c>oq=ccq.listQuoteLineItems;
            Double lineItem=ccq.lineItemsTotalAmount;
            string quoteText= ccq.quoteNonstandardText;
            string dis=ccq.displayAuto;
            List<Opportunity_Quote_Line_Item__c> listCommision=ccq.listCommisionItems;
            
            System.assertNotEquals(null, ccq.getAccountWrapper());
            System.assertEquals(13, ccq.getCommissionFee());
        }
        Test.stopTest();
    }
    
    @isTest static void test_getAccountWrapper2() {
        Test.startTest();
        CtrCreateQuote ccq;
        System.runAs(talabatUser){

            ccq = new CtrCreateQuote();
            ccq.oppQId = oppqsTb[0].Id;
            ccq.acctId = talabatAcc[0].Id;
            String mjamtxt=ccq.quoteNonstandardTextMjam;
            //ccq.oppId = tbtopportunities[0].Id;
            list<Opportunity_Quote_Line_Item__c>op=ccq.listLineItems;
            //list<Opportunity_Quote_Line_Item__c>oq=ccq.listQuoteLineItems;
            Double lineItem=ccq.lineItemsTotalAmount;
            string quoteText= ccq.quoteNonstandardText;
            System.assertNotEquals(null, ccq.getAccountWrapper());
            System.assertEquals(13, ccq.getCommissionFee());
        }
        Test.stopTest();
    }
    
     
}