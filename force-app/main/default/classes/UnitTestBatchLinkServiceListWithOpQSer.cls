@isTest
private class UnitTestBatchLinkServiceListWithOpQSer{
static User testRunningUser = [SELECT Id,Username,Email FROM User WHERE Profile.PermissionsModifyAllData = true AND IsActive = true LIMIT 1];

	@isTest static void test_method_one() {
		UnitTestDataFactory.getRecordtypeValues();
		UnitTestDataFactory.testDataForYogiyoContractProcess();
		Company__c com = [select id,Country__c from Company__c where name='Yogiyo' limit 1];
		Country__c c = new Country__c(Id=com.Country__c);
		Opportunity_Quote__c oppQuote = [select id,CurrencyIsoCode from Opportunity_Quote__c where Subtotal__c=19900 limit 1];
		Opportunity_Quote_Service_Item__c oppQSER = new Opportunity_Quote_Service_Item__c(Commission_In_Percentage__c=15,CurrencyIsoCode=oppQuote.currencyIsoCode,End_Date__c=Date.today().addDays(2),Id_Opportunity_Quote__c=oppQuote.id,Name='xxxxxxxxxx',RecordTypeId=LibRecordTypeHelper.getRecordTypeValue('Yogiyo_Opportunity_Quote_Service_Item'),Start_Date__c=Date.today(),Type__c='Commission');
        insert oppQSER;
        List<List_Service_Price__c> listService = new List<List_Service_Price__c>();
        listService.add(UnitTestDataFactory.createService(com,c,'요기팩기본 (주)푸디아 / 미스터보쌈5379','Yogiyo_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType'));
        listService.add(UnitTestDataFactory.createService(com,c,'Total Commission','Yogiyo_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType'));
        listService.add(UnitTestDataFactory.createService(com,c,'White Label Discount','Yogiyo_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType'));
        listService.add(UnitTestDataFactory.createService(com,c,'Order Now Discount','Yogiyo_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType'));
        listService.add(UnitTestDataFactory.createService(com,c,'요기팩기본 (주)멕시카나 / 멕시카나치킨','Yogiyo_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType'));
        listService.add(UnitTestDataFactory.createService(com,c,'요기팩기본 (주)한국일오삼농산 / 처갓집양념치킨','Yogiyo_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType'));
        listService.add(UnitTestDataFactory.createService(com,c,'요기팩기본 (주)에땅 / 피자에땅','Yogiyo_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType'));
        listService.add(UnitTestDataFactory.createService(com,c,'요기팩기본 (주)농협목우촌 / 또래오래','Yogiyo_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType'));
        listService.add(UnitTestDataFactory.createService(com,c,'요기팩기본 (주)원앤원 / 원할머니보쌈','Yogiyo_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType'));
        listService.add(UnitTestDataFactory.createService(com,c,'요기팩기본 (유)비에이치씨 / BHC치킨','Yogiyo_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType'));
        listService.add(UnitTestDataFactory.createService(com,c,'요기팩기본 (주)맥시칸 / 맥시칸치킨','Yogiyo_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType'));
        listService.add(UnitTestDataFactory.createService(com,c,'요기팩기본 [프로모션 8%] 한국맥도날드(유) / 맥도날드','Yogiyo_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType'));
        listService.add(UnitTestDataFactory.createService(com,c,'요기팩기본 주식회사김가네 / 김가네','Yogiyo_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType'));
        listService.add(UnitTestDataFactory.createService(com,c,'요기팩기본 한국파파존스(주) / 파파존스','Yogiyo_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType'));
        listService.add(UnitTestDataFactory.createService(com,c,'요기팩기본 (주)롯데리아 / 롯데리아','Yogiyo_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType'));
        listService.add(UnitTestDataFactory.createService(com,c,'Yogiyo Basic 12%','Yogiyo_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType'));
        listService.add(UnitTestDataFactory.createService(com,c,'Yogiyo Basic (사업자변경) 6%~12.5%','Yogiyo_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType'));
		listService.add(UnitTestDataFactory.createService(com,c,'testService1','Yogiyo_List_Service_Price',13,13,26,5,null,true,null,'Commission','ServiceType'));
		listService.add(UnitTestDataFactory.createService(com,c,'testService2','Yogiyo_List_Service_Price',13,13,14,5,null,true,null,'Commission','ServiceType'));
		listService.add(UnitTestDataFactory.createService(com,c,'testService3','Yogiyo_List_Service_Price',13,13,14,5,null,true,null,'Commission','ServiceType'));
		insert listService;
		Test.startTest();
		System.runAs(testRunningUser){
			BatchLinkServiceListWithOppQuoteService bt = new BatchLinkServiceListWithOppQuoteService();
			Database.executeBatch(bt,2000);
		}
		Test.stopTest();

	}

}