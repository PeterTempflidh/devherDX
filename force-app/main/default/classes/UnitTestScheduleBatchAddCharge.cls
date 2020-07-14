@isTest
private class UnitTestScheduleBatchAddCharge {
	static Map<String,RecordType> mapRecordTypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Opportunity','Additional_Charges__c'});
    static User testRunningUser = [SELECT Id,Username,Email FROM User WHERE Profile.PermissionsModifyAllData = true AND IsActive = true LIMIT 1];
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    private static String failedBody;
    static{
        UnitTestDataFactory.getRecordtypeValues();
        Integration_Config__c intconfig = new Integration_Config__c(name='United Kingdom',Endpoint__c='http://staging-hungryhouse.com/api/salesforce/restaurant/',Password__c='SFs3cr3tPw',RecordTypeDName__c='UK_Additional_Charges',UserName__c='uksfuser');
        insert intconfig;
        Country__c c = UnitTestDataFactory.createCountry('UK','United Kingdom', 'GBP');
        insert c;
        Company__c com = UnitTestDataFactory.createCompany('hungryhouse', 'UK', c);
        insert com;
        Account acc1 = UnitTestDataFactory.createAccount('BatchTestClassAccount1',c,'UK_Account');
        acc1.CurrencyIsoCode = 'GBP';
        Account acc2 = UnitTestDataFactory.createAccount('BatchTestClassAccount2',c,'UK_Account');
        Account acc3 = UnitTestDataFactory.createAccount('BatchTestClassAccount2',c,'UK_Account');
        BatchOpportunityTarif_MigrationText__c cs = new BatchOpportunityTarif_MigrationText__c(name='FilterText',Value__c='Migration');
        
        insert new List<SObject>{acc1,acc2,acc3,cs};


        Opportunity opp1 = new Opportunity(CurrencyIsoCode = acc1.CurrencyIsoCode,Setup_Fee_AU__c=155,Start_Date_uk__c=Date.newInstance(2014, 12, 21),name='BatchTestOpp1', recordtypeid=mapRecordTypes.get('UK_Opportunity').id,AccountId=acc1.id,CloseDate=Date.newInstance(2014, 12, 21), StageName='Prospecting', TarrifName_AU__c='testTarif1',Migration_Notes_AU__c='Migration');
        
        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,c,'Apple','UK_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,c,'Setup Fee','UK_List_Product_Group');
        insert new List<SObject>{opp1,lpg,lpg1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,c,'Ipad 4 Gen. 16GB',lpg.id,'UK_List_Product_Price',1,true,100,1,false,20);
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,c,'Super Hero Setup 1',lpg1.id,'UK_List_Product_Price',1,true,100,1,false,20); 
        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com,c,'Super Hero Setup 2',lpg1.id,'UK_List_Product_Price',1,true,50,1,false,20);  
        insert new List<sObject>{lpp,lpp1,lpp2};
        List<Opportunity_Quote__c> oppQuoteList = UnitTestDataFactory.createOpportunityQuotes(opp1, 1,'UK_Opportunity_Quote','Draft','test data',100.45,100.45,'','',0);
        insert oppQuoteList;
        List<Opportunity_Quote_Line_Item__c> oqp=UnitTestDataFactory.createOpportunityQuoteLineItems(oppQuoteList[0],lpp.id,lpg.id,4,true,'UK_Opportunity_Quote_Line_Item',1,'20',200.0,2,300.0, 'Product');
        insert oqp;
        List<Additional_Charges__c> additionalCharges = new List<Additional_Charges__c>();
        additionalCharges.add(new Additional_Charges__c(
	                    Id_Account__c = acc1.Id,
	                    Status__c = 'To be sent',
	                    Booking_Api_Id__c = '12332',
                    	City_ZipCode__c = 'PW23',
	                    Type__c = 'Premium Placement',
	                    Id_List_Product_Price__c = lpp.Id,
	                    Id_Opportunity__c = opp1.Id,
	                    Id_Opportunity_Quote__c = oppQuoteList[0].Id,
	                    Installments__c = 1,
	                    Listed_Price__c = 300,
	                    Product__c = 'Premium Placement',
	                    Product_Group__c = lpg.Name,
	                    Quantity__c = 1,
	                    Total_Amount__c = 300,
	                    Start_date__c = Date.today(),
	                    Termination_Date__c = Date.today().addDays(30),
                    	RecordTypeId = mapRecordTypes.get('UK_Additional_Charges').id

	                )
            );
        for(Integer i = 0; i < 5; i++){
            additionalCharges.add(
                new Additional_Charges__c(
                    Id_Account__c = acc1.Id,
                    Status__c = 'To be sent',
                    Type__c = 'SetUp Fee',
                    Id_List_Product_Price__c = lpp.Id,
                    Id_Opportunity__c = opp1.Id,
                    Id_Opportunity_Quote__c = oppQuoteList[0].Id,
                    Installments__c = 1,
                    Listed_Price__c = 300,
                    Product__c = lpp.Name,
                    Product_Group__c = lpg.Name,
                    Quantity__c = 1,
                    Total_Amount__c = 300 + i,
                    Start_date__c = Date.today(),
                    RecordTypeId = mapRecordTypes.get('UK_Additional_Charges').id
                )
            );
        }
        insert additionalCharges;
        failedBody = '[';
        String respBody = '[';
        for(Additional_Charges__c ad : additionalCharges){
            respBody += '{"success":true,"salesforce_id":"'+ad.id+'"},';
            failedBody += '{"success":false,"code":2006,"message":"Charges cannot be added for the specified charge name via API.","salesforce_id":"'+ad.id+'"},';
        }
        respBody  = respBody.removeEnd(',')+']';
        failedBody  = failedBody.removeEnd(',')+']';
        HttpResponse customResponse = new HttpResponse();
        customResponse.setStatusCode(207);
        customResponse.setBody(respBody);
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice(customResponse));

       }
    @isTest static void test_method_one() {
        Test.startTest();
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new ScheduleBatchAddCharge());
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
    }


    @isTest static void test_method_two() {
        HttpResponse customResponse = new HttpResponse();
        customResponse.setStatusCode(207);
        customResponse.setBody(failedBody);
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice(customResponse));
        Test.startTest();
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new ScheduleBatchAddCharge());
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
    }

    @isTest static void test_method_three() {
        HttpResponse customResponse = new HttpResponse();
        customResponse.setStatusCode(400);
        customResponse.setBody('{"success":false,"code":2001,"message":"Invalid parameter."}');
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice(customResponse));
        Test.startTest();
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new ScheduleBatchAddCharge());
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
    }
	
}