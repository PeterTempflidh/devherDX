@isTest
private class UnitTBatchOpportunityLineItemsMigration {
    
    //static Map<String,RecordType> mapRecordTypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Opportunity'});
    static User testRunningUser = [SELECT Id,Username,Email FROM User WHERE Profile.PermissionsModifyAllData = true AND IsActive = true LIMIT 1];

    static{
        UnitTestDataFactory.getRecordtypeValues();
        Country__c c = UnitTestDataFactory.createCountry('KR','Korea', 'KRW');
        insert c;
        Company__c com = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', c);
        insert com;
        Account acc1 = UnitTestDataFactory.createAccount('BatchTestClassAccount1',c,'Yogiyo_Account');
        Account acc2 = UnitTestDataFactory.createAccount('BatchTestClassAccount2',c,'Yogiyo_Account');
        Account acc3 = UnitTestDataFactory.createAccount('BatchTestClassAccount2',c,'Yogiyo_Account');
        

        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,c,'Apple','Yogiyo_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,c,'Setup Fee','Yogiyo_List_Product_Group');
        List_Product_Group__c lpg2 = UnitTestDataFactory.createProductGroup(com,c,'Terminal','Yogiyo_List_Product_Group');

        insert new List<SObject>{lpg,lpg1,lpg2,acc1,acc2,acc3};
        
        Opportunity opp = new Opportunity(CurrencyIsoCode='KRW',Setup_Fee_AU__c=155,Start_Date_uk__c=Date.newInstance(2014, 12, 21),name='BatchTestopp', recordtypeid=LibRecordTypeHelper.getRecordTypeValue('Yogiyo_Opportunity'),AccountId=acc1.id,CloseDate=Date.newInstance(2014, 12, 21), StageName='Prospecting', TarrifName_AU__c='testTarif1',Is_DataLoaded__c=true,Migration_Notes_AU__c='Migration');
        Opportunity opp2 = new Opportunity(CurrencyIsoCode='KRW',Setup_Fee_AU__c=105,Start_Date_uk__c=Date.newInstance(2014, 12, 21),name='BatchTestOpp2', recordtypeid=LibRecordTypeHelper.getRecordTypeValue('Yogiyo_Opportunity'),AccountId=acc2.id,CloseDate=Date.newInstance(2014, 12, 21), StageName='Prospecting', TarrifName_AU__c='testTarif1',Is_DataLoaded__c=true,Migration_Notes_AU__c='Migration');
        Opportunity opp3 = new Opportunity(CurrencyIsoCode='KRW',Setup_Fee_AU__c=155,Start_Date_uk__c=Date.newInstance(2014, 12, 21),name='BatchTestOpp3', recordtypeid=LibRecordTypeHelper.getRecordTypeValue('Yogiyo_Opportunity'),AccountId=acc2.id,CloseDate=Date.newInstance(2014, 12, 21), StageName='Prospecting', TarrifName_AU__c='testTarif1',Is_DataLoaded__c=true,Migration_Notes_AU__c='Migration');
        
        

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,c,'Ipad 4 Gen. 16GB',lpg.id,'Yogiyo_List_Product_Price',1,true,100,1,false,20);
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,c,'Super Hero Setup 1',lpg1.id,'Yogiyo_List_Product_Price',1,true,100,1,false,20); 
        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com,c,'Super Hero Setup 2',lpg1.id,'Yogiyo_List_Product_Price',1,true,50,1,false,20);  
        List_Product_Price__c lpp3 = UnitTestDataFactory.createProduct(com,c,'Terminal A (One-time Payment)',lpg2.id,'Yogiyo_List_Product_Price',1,true,100,1,false,null);

        List_Service_Price__c lsp = UnitTestDataFactory.createService(com,c,'testService1','Yogiyo_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType');
        List_Service_Price__c lsp1 = UnitTestDataFactory.createService(com,c,'testService2','Yogiyo_List_Service_Price',12,12,13,5,null,true,null,'Commission','ServiceType');
        List_Service_Price__c lsp2 = UnitTestDataFactory.createService(com,c,'testService3','Yogiyo_List_Service_Price',12,12,13,5,null,true,null,'Commission','ServiceType');

        Tarif__c t = UnitTestDataFactory.createTarif(com,c,'testTarif1','Yogiyo_Tarif',false);
        Tarif__c t1 = UnitTestDataFactory.createTarif(com,c,'testTarif2','Yogiyo_Tarif',false);

        insert new List<sObject>{lpp,lpp1,lpp2,lpp3,lsp,lsp1,lsp2,t,t1,opp2,opp,opp3};


        Tarif_Member__c tm = UnitTestDataFactory.createTarifMember(lpp.id,'Yogiyo_Tarif_Member',t.id,'Product');
        Tarif_Member__c tm1 = UnitTestDataFactory.createTarifMember(lpp3.id,'Yogiyo_Tarif_Member',t.id,'Product');
        Tarif_Member__c tm2 = UnitTestDataFactory.createTarifMember(lsp.id,'Yogiyo_Tarif_Member',t.id,'Service');
        Tarif_Member__c tm3 = UnitTestDataFactory.createTarifMember(lsp2.id,'Yogiyo_Tarif_Member',t1.id,'Service');
        Tarif_Member__c tm4 = UnitTestDataFactory.createTarifMember(lpp2.id,'Yogiyo_Tarif_Member',t1.id,'Product');
        Tarif_Member__c tm5 = UnitTestDataFactory.createTarifMember(lpp1.id,'Yogiyo_Tarif_Member',t1.id,'Product');

       
        insert new List<sObject>{tm,tm1,tm2,tm3,tm4,tm5};
        t.Is_Active__c = true;
        t1.Is_Active__c = true;
        update new List<Tarif__c>{t,t1};
        Opportunity_Tarif_Item__c oppTarif= UnitTestDataFactory.createOpportunityTarif('testTarif1',t1.id,opp.id,'Yogiyo_Opportunity_Tarif_Item');
        Opportunity_Product_Item__c oppProduct = UnitTestDataFactory.createOpportunityProductItem('Super Hero Setup 2',opp,lpg1.id,lpp2.id,true,'Yogiyo_Opportunity_Product_Item',1,'',50,1,50);
        Opportunity_Product_Item__c oppProduct2 = UnitTestDataFactory.createOpportunityProductItem('Super Hero Setup 1',opp,lpg1.id,lpp1.id,true,'Yogiyo_Opportunity_Product_Item',1,'',50,1,50);
        Opportunity_Service_Item__c oppService = UnitTestDataFactory.createOpportunityServiceItem('testService3',opp,lsp2.id,true,'Yogiyo_Opportunity_Service_Item',12,null,Date.today(),'Commission',null);
        
        insert new List<sObject>{oppTarif,oppProduct,oppProduct2,oppService};

        Opportunity_Quote__c oppQuote = new Opportunity_Quote__c(CurrencyIsoCode=opp.currencyIsoCode,Id_Account__c=opp.accountid,Id_Opportunity__c=opp.id,Description__c='test data',RecordTypeId=LibRecordTypeHelper.getRecordTypeValue('Yogiyo_Opportunity_Quote'),Status__c='Accepted',Subtotal__c=19900,Total__c=19900);
        insert oppQuote;

            Opportunity_Quote_Product_Item__c oppQuoteProduct = new Opportunity_Quote_Product_Item__c(CurrencyIsoCode=opp.currencyIsoCode,Has_Related_Tarif__c=true,Id_List_Product_Price__c=oppProduct.Id_List_Price_Product__c,Id_Opportunity_Quote__c=oppQuote.id,Installments__c=oppProduct.Installments__c,Listed_Price__c=oppProduct.Listed_Price__c,Name=oppProduct.name,Product_Group__c=oppProduct.Product_Group__c,Quantity__c=oppProduct.Quantity__c,Rabbat__c=oppProduct.Rabbat__c,RecordTypeId=LibRecordTypeHelper.getRecordTypeValue('Yogiyo_Opportunity_Quote_Product_Item'),Total_Amount__c=oppProduct.Total_Amount__c);
            Opportunity_Quote_Product_Item__c oppQuoteProduct2 = new Opportunity_Quote_Product_Item__c(CurrencyIsoCode=opp.currencyIsoCode,Has_Related_Tarif__c=true,Id_List_Product_Price__c=oppProduct2.Id_List_Price_Product__c,Id_Opportunity_Quote__c=oppQuote.id,Installments__c=oppProduct2.Installments__c,Listed_Price__c=oppProduct2.Listed_Price__c,Name=oppProduct2.name,Product_Group__c=oppProduct2.Product_Group__c,Quantity__c=oppProduct2.Quantity__c,Rabbat__c=oppProduct2.Rabbat__c,RecordTypeId=LibRecordTypeHelper.getRecordTypeValue('Yogiyo_Opportunity_Quote_Product_Item'),Total_Amount__c=oppProduct2.Total_Amount__c);
            Opportunity_Quote_Service_Item__c oppServiceER = new Opportunity_Quote_Service_Item__c(Commission_In_Percentage__c=oppService.Commission_In_Percentage__c,Commission_Per_Order__c=oppService.Commission_Per_Order__c,CurrencyIsoCode=opp.currencyIsoCode,End_Date__c=oppService.End_Date__c,Has_Related_Tarif__c=oppService.Has_Related_Tarif__c,Id_Opportunity_Quote__c=oppQuote.id,Name=oppService.Name,RecordTypeId=LibRecordTypeHelper.getRecordTypeValue('Yogiyo_Opportunity_Quote_Service_Item'),Recurring_Fee__c=oppService.Recurring_Fee__c,Start_Date__c=oppService.Start_Date__c,Type__c=oppService.Type__c);
        insert new List<sObject>{oppQuoteProduct,oppQuoteProduct2,oppServiceER};
        Asset__c ast = new Asset__c(Id_Opportunity_Quote_Product_Item__c=oppQuoteProduct.Id);
        insert ast;
       }
    @isTest static void test_method_one() {
                
        Test.startTest();
        System.runAs(testRunningUser){
            BatchOpportunityLineItemsMigration batch = new BatchOpportunityLineItemsMigration();
            Database.executeBatch(batch,500);
        }
        Test.stopTest();
        //System.assertEquals(([select id from Additional_Charges__c]).size(),4);       

    }
    
}