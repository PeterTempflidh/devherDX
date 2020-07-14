/*
@author : Magesh Mani Yadav
@reviewer : 
@creation : 10.09.2014 
*/
@isTest
private class UnitTestCtrCreateProductLineItems{
    static User runningUser;
    static User runningUser_TLB = UnitTestDataFactory.createUser('Talabat Sales Team','testUserTLB@deliveryherotest.com','Talabat','UAE');
     public static Map<String,RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Lead','Case','Contact','Opportunity','Account', 'Contact', 'Contract', 'List_Product_Group__c','List_Product_Price__c','List_Service_Price__c','Tarif__c','Tarif_Member__c','Opportunity_Tarif_Item__c','Opportunity_Product_Item__c','Opportunity_Service_Item__c','Opportunity_Quote__c',/* 'Opportunity_Quote_Product_Item__c', 'Opportunity_Quote_Service_Item__c',*/ 'Asset__c','Stock_Item__c', 'Additional_Charges__c', 'Opportunity_Line_Item__c', 'Opportunity_Quote_Line_Item__c'});
    
  /*  @future
    private static void insertUser(){
    runningUser = UnitTestDataFactory.createUser('Yogiyo Sales Team','testUser@deliveryherotest.com','Yogiyo','KR');
    insert runningUser;
     insert runningUser_TLB;
    }
*/
    static {
        UnitTestDataFactory.getRecordtypeValues();
        //insert runningUser;
       
        List<Platform_Country__c> platformCountry =new List<Platform_Country__c>(); 
        List<AdSales__c> addS = new List<AdSales__c>();
        platformCountry.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name='FOCPlatform', country__c='Lebanon,Qatar,United Arab Emirates'));
        addS.add(new AdSales__c(name='Category',Values__c='치킨,분식,한식,중식,피자양식,족발보쌈,돈까스,야식,프랜차이즈,테이크아웃'));
        insert platformCountry;
        insert addS;
        MidasIntegration__c midas = new MidasIntegration__c(name='UK',AuthenticationToken__c='SFSTG001P3B1KNxEqNz50KFFO55EUQmi',EndPoint__c='http://midas-staging.medusa-hero.com/backend/');
      
        insert midas;
        Integration_Config__c iconfig = new Integration_Config__c(Name = 'KR_YogiyoBackend',
                Endpoint__c='https://www.yogiyo.co.kr/salesforce/restaurant/',
                ClientId__c='salesforce', ClientSecret__c='salesforceSecret');
        Integration_Config__c iconfig1 = new Integration_Config__c(Name = 'KR_YogiyoBackend_STG',
                Endpoint__c='https://www.yogiyo.co.kr/salesforce/restaurant/',
                ClientId__c='salesforce', ClientSecret__c='salesforceSecret');

        insert new List<SObject> {iconfig, iconfig1};
        //System.runAs(runningUser){
            UnitTestDataFactory.testDataForYogiyoOpportunityProcesses();
            
       // }
       // System.runAs(runningUser_TLB){
            UnitTestDataFactory.testDataForTalabatApproval();
            TLB_Approval_Matrix__c approvalSetting_level1 = new TLB_Approval_Matrix__c(
                                                                                        Name = 'ArabEmirates_Level1',
                                                                                        CountryName__c = 'Arab Emirates',
                                                                                       
                                                                                        Notification__c = true,
                                                                                        Role__c = 'HOS'
                                                                                        
                                                                                        );

            TLB_Approval_Matrix__c approvalSetting_level2 = new TLB_Approval_Matrix__c(
                                                                                    Name = 'ArabEmirates_Level2',
                                                                                    CountryName__c = 'Arab Emirates',
                                                                                   
                                                                                    Notification__c = true,
                                                                                    Role__c = 'Legal'
                                                                                    
                                                                                    );

            insert new List<sObject>{approvalSetting_level2,approvalSetting_level1};

           // UnitTestDataFactory.testDataForTalabatApproval();
        //}

        /*System.runAs(runningUser_TLB){

            TLB_Approval_Matrix__c approvalSetting_level1 = new TLB_Approval_Matrix__c(
                                                                                        Name = 'ArabEmirates_Level1',
                                                                                        CountryName__c = 'Arab Emirates',
                                                                                        Level__c = 1,
                                                                                        Notification__c = true,
                                                                                        Role__c = 'Country HOS',
                                                                                        User_Email__c = 'tlbtestuser@test.com',
                                                                                        User_Id__c = runningUser_TLB.Id
                                                                                        );

            TLB_Approval_Matrix__c approvalSetting_level2 = new TLB_Approval_Matrix__c(
                                                                                    Name = 'ArabEmirates_Level2',
                                                                                    CountryName__c = 'Arab Emirates',
                                                                                    Level__c = 2,
                                                                                    Notification__c = true,
                                                                                    Role__c = 'Country CEO',
                                                                                    User_Email__c = 'tlbtestuser@test.com',
                                                                                    User_Id__c = runningUser_TLB.Id
                                                                                    );

            insert new List<sObject>{approvalSetting_level2,approvalSetting_level1};

            UnitTestDataFactory.testDataForTalabatApproval();


        }*/

    }

    /*static {
        insert runningUser_TLB;

        List<Platform_Country__c> platformCountry =new List<Platform_Country__c>(); 
        List<AdSales__c> addS = new List<AdSales__c>();
        platformCountry.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name='FOCPlatform', country__c='Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;

        System.runAs(runningUser_TLB){

            TLB_Approval_Matrix__c approvalSetting_level1 = new TLB_Approval_Matrix__c(
                                                                                        Name = 'ArabEmirates_Level1',
                                                                                        CountryName__c = 'Arab Emirates',
                                                                                        Level__c = 1,
                                                                                        Notification__c = true,
                                                                                        Role__c = 'Country HOS',
                                                                                        User_Email__c = 'tlbtestuser@test.com',
                                                                                        User_Id__c = runningUser_TLB.Id
                                                                                        );

            TLB_Approval_Matrix__c approvalSetting_level2 = new TLB_Approval_Matrix__c(
                                                                                    Name = 'ArabEmirates_Level2',
                                                                                    CountryName__c = 'Arab Emirates',
                                                                                    Level__c = 2,
                                                                                    Notification__c = true,
                                                                                    Role__c = 'Country CEO',
                                                                                    User_Email__c = 'tlbtestuser@test.com',
                                                                                    User_Id__c = runningUser_TLB.Id
                                                                                    );

            insert new List<sObject>{approvalSetting_level2,approvalSetting_level1};

            UnitTestDataFactory.testDataForTalabatApproval();


        }


    }*/

    static testmethod void talabatApproval_non_standard_approval_exception(){
        Opportunity theOpp = [select id,RecordType.DeveloperName,Country__c,Record_Country__c,StageName,AccountId,
        						Account.Name,Quote_Comment__c,recordtypeid,subtotal__c,vat__c,total__c,
        						Quote_Comment_Menu_Printing__c,currencyIsoCode, Id_Tarif__c, 
        						account.recordTypeId,account.recordType.developerName
        						from Opportunity where name='TestOppTalabat' LIMIT 1];
        Test.startTest();
        Integer emailsSendBeforeTest = Limits.getEmailInvocations();
        //System.runas(runningUser_TLB){
            ApexPages.StandardController stctr = new ApexPages.StandardController(theOpp);
            CtrCreateProductLineItems testObject = new CtrCreateProductLineItems(stctr);

            //testObject.checkExistingOpportunityTarif();

            testObject.saveLineItems();
            testObject.selectedTarifItem = testObject.tarifItems[0].getValue();
            testObject.getRelatedTarifMember();
            testObject.selectedServiceItem = testObject.serviceItems[1].getValue();
            testObject.getServiceDetails();
            testObject.selectedService.Start_Date__c = Date.today();
            testObject.selectedService.End_Date__c = Date.today() + 3;
            testObject.addService();

            testObject.saveLineItems();
            testObject.showQuotePage();
            testObject.createQuote();
            testObject.oppQuote.Non_Standard_Contract_Components__c = 'Registration fee;Renewal fee';
            //testObject.saveQuote();
       // }
        Test.stopTest();
        Integer emailsSendAfterTest = Limits.getEmailInvocations();
        System.assertEquals(emailsSendBeforeTest,emailsSendAfterTest);               
    }





    static testmethod void talabatApproval(){
        Opportunity theOpp = [select id,RecordType.DeveloperName,Country__c,Record_Country__c,StageName,AccountId,
        						Account.Name,Quote_Comment__c,recordtypeid,subtotal__c,vat__c,total__c,
        						Quote_Comment_Menu_Printing__c,currencyIsoCode, Id_Tarif__c, 
        						account.recordTypeId,account.recordType.developerName
        						from Opportunity where name='TestOppTalabat' LIMIT 1];

        Opportunity_Line_Item__c oppLinItem = [select id,Min__c,Max__c,Commission_In_Percentage__c,Commission_per_order__c,
                                                      online_payment_fee__c,Listed_Price__c, Start_Date__c, End_Date__c,Total_Amount__c
                                                from Opportunity_Line_Item__c
                                                where Id_Opportunity__c =: theOpp.id limit 1];

        oppLinItem.District__c = 'testDistrict';
        oppLinItem.Start_Date__c = Date.today();
        oppLinItem.End_Date__c = Date.today().addDays(2);
        oppLinItem.Listed_Price__c = 10;
        oppLinItem.Total_Amount__c = 10;

        //System.runas(runningUser_TLB){
            ApexPages.StandardController stctr = new ApexPages.StandardController(theOpp);
            CtrCreateProductLineItems testObject = new CtrCreateProductLineItems(stctr);
        Test.setCurrentPageReference(new PageReference('Page.CreateProductLineItems'));
        System.currentPageReference().getParameters().put('indexOfAdsales', '1');


        //testObject.checkExistingOpportunityTarif();
            
            testObject.selectedTarifItem = testObject.tarifItems[1].getValue();
            testObject.getRelatedTarifMember();
            testObject.selectedServiceItem = testObject.serviceItems[1].getValue();
            testObject.getServiceDetails();
            testObject.selectedService.Start_Date__c = Date.today();
            testObject.selectedService.End_Date__c = Date.today() + 3;
            testObject.addService();
            Test.startTest();
            testObject.saveLineItems();
            testObject.showQuotePage();
            testObject.createQuote();
            //testObject.saveQuote();
            testObject.getRecurringProduct();
            testObject.addRecurringCharge();
            testObject.removeRecurringCharge();
            testObject.addAdSalesProduct();
            testObject.selectedAdSalesTypes = 'TestType';
            testObject.selectedCategories = 'TestCategory';
            testObject.adSalesProductDates.District__c = 'testDistrict';
            testObject.adSalesProductDates.Start_Date__c = Date.today();
            testObject.adSalesProductDates.End_Date__c = Date.today().addDays(2);
            testObject.adSalesProductDates.Listed_Price__c = 10;
            testObject.adSalesProductDates.Total_Amount__c = 10;

            testObject.adSalesProductLineItems = new List<CtrCreateProductLineItems.LineItemWrapper>();
            CtrCreateProductLineItems.LineItemWrapper lineWrp =   new CtrCreateProductLineItems.LineItemWrapper(oppLinItem,false,1,'type');
            lineWrp.product = oppLinItem;
            testObject.adSalesProductLineItems.add(lineWrp);
             lineWrp =   new CtrCreateProductLineItems.LineItemWrapper(oppLinItem,false,2,'type');
            lineWrp.product = oppLinItem;
            testObject.adSalesProductLineItems.add(lineWrp);
            testObject.addAdSalesProduct();
            testObject.calculateAdSalesAmountWithDate();
            testObject.addFlatProduct();
            testObject.adSalesProductToRemove = 1;
            testObject.removeAdSalesProduct();
            //testObject.removeFlatProduct();
            testObject.addProduct();
            testObject.removeProduct();
            testObject.clearproductData();
            testObject.removeService();
            testObject.saveLineItemsAndShowQuotePage();
            testObject.addNonstandardcontract();
            //testObject.doesQuoteRequiredApproval();
            testObject.cancelShowQuote();
            Test.stopTest();
            //decimal quoteServiceItem =testObject.retrieveQuoteServiceItem();
       // }        
    }

  static testmethod void unitTest1(){
        List<Opportunity> listOpp = [select id,RecordType.DeveloperName,Country__c,Record_Country__c,AccountId,StageName,
        								Account.Name,Quote_Comment__c,recordtypeid,subtotal__c,vat__c,total__c,
        								Quote_Comment_Menu_Printing__c,currencyIsoCode, Id_Tarif__c, 
        								account.recordTypeId,account.recordType.developerName
        								from Opportunity where name='TestOpp456'];
     // insertUser(); 
      Test.startTest();
       // System.runAs(runningUser){
            ApexPages.StandardController stctr = new ApexPages.StandardController(listOpp[0]);
            CtrCreateProductLineItems testObject = new CtrCreateProductLineItems(stctr);
            System.debug('dd: '+testObject.tarifItems[1].getValue()+' kk: '+testObject.tarifItems[0].getValue()+' mm: '+testObject.tarifItems[2].getValue());
            //testObject.checkExistingOpportunityTarif();
            
            testObject.selectedTarifItem = testObject.tarifItems[0].getValue();
            testObject.adSalesTarif=null;
            testObject.getRelatedTarifMember();
            testObject.selectedServiceItem = testObject.serviceItems[1].getValue();
            testObject.getServiceDetails();
            testObject.selectedService.Start_Date__c = Date.today();
            testObject.selectedService.End_Date__c = Date.today() + 3;
            testObject.addService();


            testObject.selectedServiceItem = testObject.serviceItems[2].getValue();
            testObject.getServiceDetails();
            testObject.selectedService.Start_Date__c = Date.today();
            testObject.selectedService.End_Date__c = Date.today() - 2;
            testObject.addService();

            testObject.serviceToRemove = testObject.serviceLineItems.size() - 1;
            testObject.removeService();

            testObject.selectedProductGroup = testObject.groupItems[2].getValue();
            testObject.getRelatedGroupProducts();
            testObject.selectedProductLineItem = testObject.productItems[2].getValue();
            testObject.getRelatedProduct();
            testObject.addProduct();


            testObject.selectedProductGroup = testObject.groupItems[1].getValue();
            testObject.getRelatedGroupProducts();
            testObject.selectedProductLineItem = testObject.productItems[1].getValue();
            testObject.getRelatedProduct();
            testObject.addProduct();

            testObject.productToRemove = testObject.productLineItems.size() - 1;
            testObject.removeProduct();

            testObject.saveLineItems();
            testObject.showQuotePage();
            testObject.cancelShowQuote();
            testObject.showQuotePage();
            testObject.createQuote();

        //}
        Test.stopTest();
        Opportunity_Quote__c q = [select id, name from Opportunity_Quote__c where Id_Opportunity__c=:listOpp[0].id limit 1];
        System.assertNotEquals(q.id,null);

    }


    static testmethod void unitTest2(){
        List<Opportunity> listOpp = [select id,RecordType.DeveloperName,Country__c,Account.Name,Record_Country__c,
        								StageName,AccountId,Quote_Comment__c,recordtypeid,subtotal__c,vat__c,total__c,
        								Quote_Comment_Menu_Printing__c,currencyIsoCode, Id_Tarif__c, 
        								account.recordTypeId,account.recordType.developerName
        								from Opportunity where name='TestOpp123'];
        Test.startTest();
        //System.runAs(runningUser){
            ApexPages.StandardController stctr = new ApexPages.StandardController(listOpp[0]);
            CtrCreateProductLineItems testObject = new CtrCreateProductLineItems(stctr);
            testObject.selectedTarifItem = testObject.tarifItems[3].getValue();
            //testObject.getRelatedTarifMember();
            //testObject.selectedTarifItem = testObject.tarifItems[0].getValue();
           // testObject.getRelatedTarifMember();
           // testObject.selectedTarifItem = testObject.tarifItems[2].getValue();
           // testObject.getRelatedTarifMember();
            testObject.addService();
            testObject.selectedServiceItem = testObject.serviceItems[1].getValue();
           // testObject.getServiceDetails();
            testObject.addService();
            testObject.selectedService.Commission_In_Percentage__c = 0;
            testObject.addService();
            testObject.selectedService.Commission_In_Percentage__c = 100;
            testObject.addService();
            testObject.selectedService.Start_Date__c = Date.today();
            testObject.selectedService.End_Date__c = Date.today() + 3;
            testObject.addService();
            testObject.addProduct();
            testObject.selectedProductGroup = testObject.groupItems[2].getValue();
            testObject.getRelatedGroupProducts();
            testObject.selectedProductLineItem = testObject.productItems[1].getValue();
            testObject.getRelatedProduct();
            testObject.addProduct();
            testObject.selectedProductLineItem = testObject.productItems[0].getValue();
            testObject.getRelatedProduct();
            testObject.addProduct();
            testObject.selectedProductLineItem = testObject.productItems[2].getValue();
            testObject.getRelatedProduct();
            testObject.addProduct();
           
            testObject.saveLineItems();
            testObject.showQuotePage();
            testObject.createQuote();
  
        //}    
        Test.stopTest();
        Opportunity_Quote__c q = [select id, name from Opportunity_Quote__c where Id_Opportunity__c=:listOpp[0].id];
        System.assertNotEquals(q.id,null);

    }


   
    static testmethod void unitTest4(){


        List<Opportunity> listOpp = [select id,RecordType.DeveloperName,Account.Backend_ID__c,Country__c,Record_Country__c,
        								AccountId,Quote_Comment__c,recordtypeid,subtotal__c,vat__c,total__c,currencyIsoCode, 
        								Id_Tarif__c,account.recordTypeId,account.recordType.developerName 
        								from Opportunity where name='Ad Sales'];
        Account acc = new Account(id=listOpp[0].AccountId,Backend_ID__c='0816');
        update acc;
        listOpp = [select id,RecordType.DeveloperName,Account.Backend_ID__c,Account.Name,Country__c,StageName,
        				Record_Country__c,AccountId,recordtypeid,subtotal__c,vat__c,total__c,
        				Quote_Comment_Menu_Printing__c,currencyIsoCode, Id_Tarif__c,
        				account.recordTypeId,account.recordType.developerName
        			from Opportunity where name='Ad Sales'];
        //List<list_product_price__c> lpp =  
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebserviceKR());
        //System.runAs(runningUser){
            
   
       
        Test.startTest();
            ApexPages.StandardController stctr = new ApexPages.StandardController(listOpp[0]);
            CtrCreateProductLineItems testObject = new CtrCreateProductLineItems(stctr);
            testobject.startdate=system.today();
            testobject.enddate=system.today()+5;
            
            testObject.selectedTarifItem = testObject.tarifItems[1].getValue();     
            testObject.selectedRecurringCharge = testObject.recuringChargesMap.values()[0].Id;
            testObject.recurringChargeLineItems[0].product.Start_Date__c = Date.today();
            testObject.getRecurringProduct();
            testObject.addRecurringCharge();
            testObject.removeRecurringCharge();
            
            testObject.flatCommissionAPICallout();
            
            if(testObject.flatProductLineItems.size()==0){
                testObject.flatProductLineItems.add(new CtrCreateProductLineItems.LineItemWrapper(0, testObject.flatProductLineItems.size()));
            }
            testObject.flatProductDates.Start_Date__c = Date.today();

            testobject.selectedFlatCategories.add('18');
            testObject.selectedflatdistricts.add('153');
            testObject.selectedflatdistricts.add('400');
            testObject.addflatproduct();
            testObject.flatProductLineItems[0].product.Total_Amount__c = 0;
            testObject.flatProductLineItems[0].product.Listed_Price__c = 10;
            testObject.flatProductLineItems[1].product.Total_Amount__c = 0;
            testObject.flatProductLineItems[0].product.End_Date__c = Date.today().addDays(30);
            Apexpages.currentPage().getParameters().put('indexOfFlatProd','0');
            testObject.calculateFlatCommissionAmountWithDate();
            Apexpages.currentPage().getParameters().put('indexOfFlatProd','1');
            testObject.calculateFlatCommissionAmountWithDate();
            try{
                testObject.flatProductLineItems[0].product.End_Date__c = Date.today().addDays(-3);
                Apexpages.currentPage().getParameters().put('indexOfFlatProd','0');
                testObject.calculateFlatCommissionAmountWithDate();
            }catch(Exception e){
                System.debug('Exception: '+e.getMessage());
            }

            testObject.flatProductLineItems[0].product.End_Date__c = Date.today().addDays(3);
            Apexpages.currentPage().getParameters().put('indexOfFlatProd','0');
            testObject.calculateFlatCommissionAmountWithDate();
            try{
                testObject.flatProductLineItems[0].product.Start_Date__c = null;
                testObject.validateFlatProductItems();
                }catch(Exception e){
                    
                }
            try{
                testObject.flatProductLineItems[0].product.Start_Date__c = Date.Today();
                testObject.flatProductLineItems[0].product.Total_Amount__c = null;
                testObject.validateFlatProductItems();
                }catch(Exception e){
                    
                }
            System.debug('testObject.flatProductLineItems: '+testObject.flatProductLineItems);
            testObject.flatProductToRemove =  0;

            testobject.removeFlatProduct();

            testObject.flatProductToRemove =  0;
            testobject.removeFlatProduct();




            testObject.showadsalesblock=false;
            testobject.adsalestarif=null;
            testobject.showFlatProductBlock=true;
            testobject.determineOpportunityTarifItems();
            testobject.adsalestarif=null;
            testObject.getRelatedTarifMember();
            testObject.adsalestarif='test1';
            testObject.flatProductTarif='test';
            testObject.selectedTarifItemName='test';
            testObject.getRelatedTarifMember();
            testObject.selectedRecurringCharge='test';
            testObject.addRecurringcharge();
            //testObject.selectedflatdistricts.add('test');
            //testobject.addflatproduct();
            //testObject.selectedflatdistricts.add('test');
            //testObject.selectedflatcategories.add('test');
            //testobject.addflatproduct();
            //testobject.flatproductdates.start_date__C=system.today();
            //testobject.showFlatProductBlock=true;
            testobject.selectedTarifItem='Yogiyo_Tarif_Member';
            testobject.determineOpportunityTarifItems();
            //testObject.selectedflatdistricts=null;
            //testObject.selectedflatcategories.add('test');
            //testobject.addflatproduct();
            //testObject.selectedflatcategories=null;
            //testobject.addflatproduct();
            //testobject.removeFlatProduct();
            testobject.selectedadsalestypes='test';
            testObject.selectedCategories=null;
            testObject.addAdSalesProduct();
            testObject.selectedCategories='test';
            testObject.adSalesProductDates.District__c=null;
            testObject.selectedCategories=null;
            testObject.addAdSalesProduct();
            testObject.selectedCategories='test';
            testObject.adSalesProductDates.Start_Date__c=null;
            testObject.addAdSalesProduct();
            testObject.showQuotePage();
            testobject.createquote();
            testObject.oppquote.Non_Standard_Contract_Terms__c='test 1234';
            testObject.recurringChargeToRemove=10;
             testObject.selectedTarifItem = testObject.tarifItems[2].getValue();
            testObject.getRelatedTarifMember();
            testobject.recurringCharges=null;
            testobject.flatProductToRemove=1;
            
            testobject.useCombinedSaveAndCreateQuote=false;
            testobject.flatProductLineItems=null;
            Boolean f = testObject.isSoftLimitDiscountViolated(100.0, 3.0, 5.0, '150');
            Boolean f2 =testObject.isSoftLimitDiscountViolated(100.0, 3.0, null, '15%');
            
            testObject = new CtrCreateProductLineItems(stctr);
        Test.stopTest();

       // }
        //Opportunity_Quote__c q = [select id, name from Opportunity_Quote__c where Id_Opportunity__c=:listOpp[0].id];
        //System.assertNotEquals(q.id,null);

    }


    static testmethod void unitTest5(){
        List<Opportunity> listOpp = [select id,RecordType.DeveloperName,Country__c,Account.Name,Record_Country__c,
        								StageName,AccountId,Quote_Comment__c,recordtypeid,subtotal__c,vat__c,total__c,
        								Quote_Comment_Menu_Printing__c,currencyIsoCode, Id_Tarif__c,Account.recordTypeId,
        								account.recordType.developerName 
        							from Opportunity where name='TestOpp123'];
        Test.startTest();
        //System.runAs(runningUser){
            ApexPages.StandardController stctr = new ApexPages.StandardController(listOpp[0]);
            CtrCreateProductLineItems testObject = new CtrCreateProductLineItems(stctr);
            testObject.saveLineItems();
            testObject.showQuotePage();
            testObject.createQuote();
           
            testObject.getRelatedPPProducts();
            Boolean asset=testObject.hasAsset();
  
        //}    
        Test.stopTest();
        Opportunity_Quote__c q = [select id, name from Opportunity_Quote__c where Id_Opportunity__c=:listOpp[0].id];
        System.assertNotEquals(q.id,null);

    }
    static testmethod void unitTest6(){
        List<Opportunity> listOpp = [select id,RecordType.DeveloperName,Country__c,Account.Name,Record_Country__c,StageName,AccountId,Quote_Comment__c,recordtypeid,subtotal__c,vat__c,total__c,Quote_Comment_Menu_Printing__c,currencyIsoCode, Id_Tarif__c from Opportunity where name='Menu Printing'];
        Test.startTest();
        //System.runAs(runningUser){
            ApexPages.StandardController stctr = new ApexPages.StandardController(listOpp[0]);
            CtrCreateProductLineItems testObject = new CtrCreateProductLineItems(stctr);
            Opportunity_Line_Item__c oportLineItem = [Select id,Quantity__c,Id_List_Price_Product__c,Listed_Price__c, Discount__c,Total_Amount__c, Number_of_Copies__c, Size__c from Opportunity_Line_Item__c where Id_Opportunity__c =: listOpp[0].id limit 1];
            oportLineItem.Number_of_Copies__c = '';
            oportLineItem.Size__c = '';
            testObject.getRelatedMPProducts();


            testObject.selectedProductItem = oportLineItem;
            testObject.selectedProductLineItem = '1';
            CtrCreateProductLineItems.LineItemWrapper lineItemWrp = new  CtrCreateProductLineItems.LineItemWrapper(10,1);
            lineItemWrp.product = testObject.selectedProductItem;
            testObject.mapProductType.put(oportLineItem.Id_List_Price_Product__c, 'Menu Printing');
            testObject.ppProductLineItems.add(lineItemWrp);

            integer size = testObject.mpProductLineItems.size();
            testObject.addMPProduct();
            System.assertEquals(size+1,testObject.mpProductLineItems.size());

            testObject.selectedProductItem = oportLineItem;
            testObject.selectedProductLineItem = '1';
            testObject.mapProductType.put(oportLineItem.id, 'Menu Printing');
            testObject.productToRemove = 1;
            size = testObject.mpProductLineItems.size();
            testObject.removeMPProduct();
            System.assertEquals(size-1,testObject.mpProductLineItems.size());

            testObject.selectedProductItem = oportLineItem;
            testObject.selectedProductLineItem = '1';
            lineItemWrp = new  CtrCreateProductLineItems.LineItemWrapper(10,1);
            lineItemWrp.product = testObject.selectedProductItem;
            testObject.ppProductLineItems.add(lineItemWrp);

            size = testObject.ppProductLineItems.size();
            testObject.addPPProduct();
            System.assertEquals(size+1,testObject.ppProductLineItems.size());

            testObject.selectedProductItem = oportLineItem;
            testObject.selectedProductLineItem = '1';
            testObject.mapProductType.put(oportLineItem.id, 'Premium placement -');
            testObject.productToRemove = 1;

            size = testObject.ppProductLineItems.size();
            testObject.removePPProduct();
            System.assertEquals(size-1,testObject.ppProductLineItems.size());

       // }    
        Test.stopTest();
    }


    static testmethod void unitTest7(){
        List<Opportunity> listOpp = [select id,RecordType.DeveloperName,Country__c,Account.Name,Record_Country__c,StageName,AccountId,Quote_Comment__c,recordtypeid,subtotal__c,vat__c,total__c,Quote_Comment_Menu_Printing__c,currencyIsoCode, Id_Tarif__c from Opportunity where name='Premium Placement'];
        List<List_Product_Price__c> lippProd = [select id from List_Product_Price__c where Product_Name__c in ('Premium Placement API','Menu Printing') order by Product_Name__c];
        Test.startTest();
        //System.runAs(runningUser){
            ApexPages.StandardController stctr = new ApexPages.StandardController(listOpp[0]);
            CtrCreateProductLineItems testObject = new CtrCreateProductLineItems(stctr);          
            testobject.determineOpportunityTarifItems();
            testobject.selectedProductLineItem = lippProd[1].id;

            //menu
            testobject.mpProductLineItems.add(new CtrCreateProductLineItems.LineItemWrapper(new Opportunity_Line_Item__c(), false, 0,'Product'));
            testobject.mpTarif = 'menu printing tarif';
            testobject.selectedProductLineItem = lippProd[0].id;
            testObject.getRelatedProduct();

        //}    
        Test.stopTest();
    }

    static testmethod void unitTest8(){
        Country__c c = UnitTestDataFactory.createCountry('UK','United Kingdom', 'GBP');
        Company__c com = UnitTestDataFactory.createCompany('Hungryhouse', 'UK', c);
        insert new List<sObject>{c,com};
        List<Opportunity> listOpp = [select id,RecordType.DeveloperName,Country__c,Account.Name,Record_Country__c,StageName,AccountId,Quote_Comment__c,recordtypeid,subtotal__c,vat__c,total__c,Quote_Comment_Menu_Printing__c,currencyIsoCode, Id_Tarif__c from Opportunity where name='Premium Placement'];
        listOpp[0].Country__c = c.Id;
        update listOpp[0];
        
        Test.startTest();
        //System.runAs(runningUser){
            ApexPages.StandardController stctr = new ApexPages.StandardController(listOpp[0]);
            CtrCreateProductLineItems testObject = new CtrCreateProductLineItems(stctr);
            testobject.determineOpportunityTarifItems();

            //testObject.getRelatedMPProducts();
            //testObject.addMPProduct();
            //testObject.removeMPProduct();
            //testObject.addPPProduct();
            //testObject.removePPProduct();
  
        //}    
        Test.stopTest();
    }


    static testmethod void unitTest9(){
        List<Opportunity> listOpp = [select id,RecordType.DeveloperName,Country__c,Account.Name,Record_Country__c,StageName,AccountId,Quote_Comment__c,recordtypeid,subtotal__c,vat__c,total__c,Quote_Comment_Menu_Printing__c,currencyIsoCode, Id_Tarif__c from Opportunity where name='TestOpp123'];
        Test.startTest();
        //System.runAs(runningUser){
            ApexPages.StandardController stctr = new ApexPages.StandardController(listOpp[0]);
            CtrCreateProductLineItems testObject = new CtrCreateProductLineItems(stctr);
            for(Tarif__c t : [select id from Tarif__c where Id_Country__r.iso__c='KR']){
                testObject.selectedTarifItem = t.id;
                testObject.getRelatedTarifMember();

            }
        //}    
        Test.stopTest();
    }

    static testmethod void unitTest10(){
        List<Opportunity> listOpp = [select id,RecordType.DeveloperName,Country__c,Account.Name,Account.Backend_ID__c,Record_Country__c,StageName,AccountId,Quote_Comment__c,recordtypeid,subtotal__c,vat__c,total__c,Quote_Comment_Menu_Printing__c,currencyIsoCode, Id_Tarif__c from Opportunity where name='TestOpp123'];
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebserviceKR());
        //System.runAs(runningUser){
            ApexPages.StandardController stctr = new ApexPages.StandardController(listOpp[0]);
            CtrCreateProductLineItems testObject = new CtrCreateProductLineItems(stctr);
            testObject.getOppLines();
            CtrCreateProductLineItems.createQuotePP(listOpp[0].id);
            CtrCreateProductLineItems.getRestaurantInfo(listOpp[0].AccountId,'01-2017','UK Sales Manager');
           // Test.startTest();
               // String str1 = CtrCreateProductLineItems.getRestaurantInfo('001w000001TvEe0','8-2016','UK Sales Manager');
            
               // String str2 = CtrCreateProductLineItems.getRestaurantInfo('001w000001TvEXU',null,'UK Sales Manager');
            
                //String str3 = CtrCreateProductLineItems.getRestaurantInfo('001w000001TvEXH','8-2016','UK Sales Manager');
                //try{
                  //  String str4 = CtrCreateProductLineItems.getRestaurantInfo('0067E0000058UDx','82016','UK Sales Manager');
                //}catch(Exception e){

               // }

               // String str5 = CtrCreateProductLineItems.savePPLines('0018E00000Jws43QAB', listOpp[0].Id,new List<CtrCreateProductLineItems.SelectedPostcodes>{new CtrCreateProductLineItems.SelectedPostcodes('12345','test','ER',234,34,'p1',50),new CtrCreateProductLineItems.SelectedPostcodes('12456','ERW',546,12,'p2',50)},'8-2016',null);
                //String str6 = CtrCreateProductLineItems.savePPLines('0018E00000Jws43QAC', listOpp[0].Id,new List<CtrCreateProductLineItems.SelectedPostcodes>{new CtrCreateProductLineItems.SelectedPostcodes('12345','test','ER',234,34,'p1',50),new CtrCreateProductLineItems.SelectedPostcodes('12456','ERW',546,12,'p2',50)},null,null);
               //String str7 =  CtrCreateProductLineItems.createQuotePP(listOpp[0].Id);
            //Test.stopTest();
       // }
    }

    static testmethod void unitTest11(){
        List<Opportunity> listOpp = [select id,RecordType.DeveloperName,Country__c,Account.Name,Account.Backend_ID__c,Record_Country__c,StageName,AccountId,Quote_Comment__c,recordtypeid,subtotal__c,vat__c,total__c,Quote_Comment_Menu_Printing__c,currencyIsoCode, Id_Tarif__c from Opportunity where name='TestOpp123'];
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebserviceKR());
        //System.runAs(runningUser){
            ApexPages.StandardController stctr = new ApexPages.StandardController(listOpp[0]);
            CtrCreateProductLineItems testObject = new CtrCreateProductLineItems(stctr);
            Test.startTest();
                String str6 = CtrCreateProductLineItems.savePPLines('0018E00000Jws43QAC', listOpp[0].Id,new List<CtrCreateProductLineItems.SelectedPostcodes>{new CtrCreateProductLineItems.SelectedPostcodes('12345','test','ER',234,34,'p1',50),new CtrCreateProductLineItems.SelectedPostcodes('12456','test','ERW',546,12,'p2',50)},'8-2016',null);
            Test.stopTest();
        //}
    }
    
     static testmethod void unitTest12(){
         Country__c testCountry = UnitTestDataFactory.createCountry('CD','Colombia', 'COP');
        insert testCountry;
        Company__c com = UnitTestDataFactory.createCompany('Clickdelivery', 'CD', testCountry);
        insert com;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='approvalProcesse',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='DesignProductTypes',Business_Rule_Value__c='Exclusive Special Offer',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
         Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='DesignTarif',Business_Rule_Value__c='Design Tarif',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='tieredKeyword',Business_Rule_Value__c='scaled',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='MenuPrintingTarif',Business_Rule_Value__c='Menu Printing',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c='initialApprovalStatus',Business_Rule_Value__c='Approval Pending',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b7 = new Business_Config__c(Business_Rule_Name__c='ApprovalProcessService',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b8 = new Business_Config__c(Business_Rule_Name__c='usesServiceTypes',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b9 = new Business_Config__c(Business_Rule_Name__c='nonStandardContractValue',Business_Rule_Value__c='Platform exclusivity',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b10 = new Business_Config__c(Business_Rule_Name__c='showNonStandardContractComponentsSection',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
       Business_Config__c b11 = new Business_Config__c(Business_Rule_Name__c='noViolationQuoteStatus',Business_Rule_Value__c='Approved',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
       Business_Config__c b12 = new Business_Config__c(Business_Rule_Name__c='showNonStandardContractTerms',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
       Business_Config__c b13 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterInitialApprovalEntry',Business_Rule_Value__c='Verbal agreement',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
       Business_Config__c b14 = new Business_Config__c(Business_Rule_Name__c='MarketingShippingTariff',Business_Rule_Value__c='Marketing & Packaging',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
       Business_Config__c b15 = new Business_Config__c(Business_Rule_Name__c='showApprovalCommentsSection',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
       Business_Config__c b16 = new Business_Config__c(Business_Rule_Name__c='skipAutoApprovalQuote',Business_Rule_Value__c='false',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b17 = new Business_Config__c(Business_Rule_Name__c='MarketingShippingProdTypes',Business_Rule_Value__c='Online Marketing,Packaging',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='addOpportunityLineItems',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
       
         
         insert new List<sObject>{b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16,b17};
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'CD_Account');
        insert accList;
        accList[0].Restaurant_Name__c ='test';
        accList[0].record_country__c='Colombia';
        accList[0].BillingPostalCode='W1H 1DP';
        update accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'CD_Opportunity',Date.today());
        insert oppList;
        //Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppList[0].id,status__c='Approved',ID_Account__c=acclist[0].id);
        //insert newQuote;

        List_Service_Price__c lsp = UnitTestDataFactory.createService(com,testCountry,'testService1','CD_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType');
        insert lsp;
        //Opportunity_Line_Item__c oppService = //UnitTestDataFactory.createOpportunityLineItemService('testService3',oppList[0],lsp.id,true,'CD_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        //insert oppService;
        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,testCountry,'Apple','CD_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,testCountry,'Setup Fee','CD_List_Product_Group');
        insert new List<SObject>{lpg,lpg1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,testCountry,'Ipad 4 Gen. 16GB',lpg.id,'CD_List_Product_Price',1,true,100,1,false,20);
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 1',lpg1.id,'CD_List_Product_Price',1,true,100,1,false,20); 
        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 2',lpg1.id,'CD_List_Product_Price',1,true,50,1,false,20);
        lpp.product_type__c='Online Marketing';
        lpp.Requires_Asset__c=false;  
        lpp.Requires_Branding__c=true;
        lpp.Requires_Add_On__c=false;
        insert new List<sObject>{lpp,lpp1,lpp2};
        //List<Opportunity_Quote_Line_Item__c> oppQuoteLine =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'CD_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Commission Fee','Service');
       // List<Opportunity_Quote_Line_Item__c> oppQuoteLine2 =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'CD_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Packaging','Product');
       // insert oppQuoteLine ;
        //oppQuoteLine[0].id_opportunity__c=opplist[0].id;
        //oppQuoteLine2[0].id_opportunity__c=opplist[0].id;
        //oppQuoteLine2[0].Id_List_Product_Price__c=lpp.id;
        //insert oppQuoteLine2;
       // newQuote.status__c='Accepted';
       // update newQuote;
       // update oppQuoteLine;
        //List<Contact> contacts = UnitTestDataFactory.createContacts(accList, 'test Lastname', 'test FirstName', 'Mr', 'Owner', 1, 'testme', 'UK_Contact');
        //insert oppQuoteLine;
        //insert contacts;
        //contacts[0].email='test@test.com';
        //update contacts; 
         Tarif__c tarifs= (new Tarif__c( Name = 'Marketing & Packaging' , Company__c = com.Id, 
                    Id_Country__c = testcountry.Id,
                    Is_Active__c = false,
                    RecordtypeId = mapRecordtypes.get('CD_Tarif').Id));

         Tarif__c tarifs2= (new Tarif__c( Name = 'scaled Commission' , Company__c = com.Id, 
                    Id_Country__c = testcountry.Id,
                    Is_Active__c = false,
                    RecordtypeId = mapRecordtypes.get('CD_Tarif').Id));

           
        
        insert new List<sObject>{tarifs,tarifs2};
        Tarif_Member__c trm = (new Tarif_Member__c(Id_Tarif_Item__c=lsp.id,Tarif_Name__c=tarifs2.id,Type__c ='Service'));
            insert trm;
        tarifs.is_Active__c=true;
        tarifs2.is_Active__c=true;

        update new List<sObject>{tarifs,tarifs2};
    
        Test.startTest();
            opportunity opp= [select id,RecordType.DeveloperName,Country__c,Account.Name,Account.Backend_ID__c,Record_Country__c,StageName,AccountId,Quote_Comment__c,recordtypeid,subtotal__c,vat__c,total__c,Quote_Comment_Menu_Printing__c,currencyIsoCode, Id_Tarif__c from Opportunity where id=:oppList[0].id];
        
            
            ApexPages.StandardController stctr = new ApexPages.StandardController(opp);
            CtrCreateProductLineItems testObject = new CtrCreateProductLineItems(stctr);
            testobject.mpProductLineItems.add(new CtrCreateProductLineItems.LineItemWrapper(new Opportunity_Line_Item__c(), false, 0,'Product'));
            testObject.selectedTarifItemName='Marketing & Packaging';
            testObject.selectedproductlineitem=lpp.id;

            testObject.getRelatedMarketingShippingProducts();
            testObject.addMSProduct();
            testObject.addDPProduct();
            testObject.showTieredBlock=true;
            testObject.selectedTarifItem=tarifs2.id;
             testObject.selectedTarifItemName='Scaled Commission';
             testObject.getRelatedTarifMember();
            testObject.selectedServiceItem = testObject.serviceItems[1].getValue();
            testObject.getServiceDetails();


           // testObject.removeMSTarif();
            
        Test.stopTest();
        
    
    }
}