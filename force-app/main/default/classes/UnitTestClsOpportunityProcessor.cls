@isTest
public class UnitTestClsOpportunityProcessor {
    private static Map<String,RecordType> mapRecordTypes = LibRecordTypeHelper.getRecordTypeForObjects(
    														new Set<String>{'Case','Opportunity_Quote__c',
    																	'Opportunity_Quote_Line_Item__c','Asset__C',
    																	'Branding_Content__C','Additional_Charges__c'});
    @TestSetup
    public static void testSetup(){
    	// fetch the business config data from the static resource
    	List<sObject> ls = Test.loadData(Business_Config__c.sObjectType, 'BusinessConfigData');
    	
    	List<Platform_Country__c> platformCountry =new List<Platform_Country__c>(); 
        platformCountry.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name='FOCPlatform', country__c='Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
         
        List<Integration_Config__c> integrationSettings =new List<Integration_Config__c>(); 
        integrationSettings.add(new Integration_Config__c(name='United Kingdom',endpoint__c='http://staging-hungryhouse.com/api/salesforce/restaurant/', username__c='uksfuser', password__c='SFs3cr3tPw'));
        insert integrationSettings;
        
        List<MidasIntegration__c> midasIntg = new List<MidasIntegration__c>();
        midasIntg.add(new MidasIntegration__c(name = 'PP', EndPoint__c = 'http://midas.medusa-hero.com/backend/', AuthenticationToken__c = 'WyI0IiwiYzUwNjRkMmQ2MWUwNTE3YjVhNjRmMTk4Yjc2NmFiODgiXQ.CgtJbA.kFY4BLsKd3XXiXg7QtVxmLqZ7i0', countrybrand__c='{"United Kingdom":"UKHH", "Kuwait":"KWTB"}'));
        insert midasIntg;
        
        List<CountryCompanyBrand__c> countryBrandSettings = new List<CountryCompanyBrand__c>();
        CountryCompanyBrand__c config = new CountryCompanyBrand__c();
        config.name = 'hungryhouse';
        config.code__c = 'UKHH';
        countryBrandSettings.add(config);
        
        CountryCompanyBrand__c config2 = new CountryCompanyBrand__c();
        config2.name = 'United Kingdom';
        config2.code__c = 'UKHH';
        countryBrandSettings.add(config2);
        
        CountryCompanyBrand__c config3 = new CountryCompanyBrand__c();
        config3.name = 'Kuwait';
        config3.code__c = 'KWTB';
        countryBrandSettings.add(config3);
        
        insert countryBrandSettings;
        
        List<InterestedOppClosedLost__c> intOppClosedSetting =new List<InterestedOppClosedLost__c>(); 
        intOppClosedSetting.add(new InterestedOppClosedLost__c(name='Interested',Values__c='Not enough capacity'));
        insert intOppClosedSetting;
        
        UnitTestDataFactory.getRecordtypeValues();
        // create business configs implemented for SSC-1982 : Tlife Commission
        List<Business_Config__c> configs = new List<Business_Config__c>();
        configs.add(UnitTestDataFactory.createBusinessConfig('TlifeRevenueModel','process', 'ContractServiceType','Deal Subscription Fee,Commission Fee,Logistics Fee', null,'DE_Contract',True,True));
        configs.add(UnitTestDataFactory.createBusinessConfig('TlifeRevenueModel','process', 'Commission Fee','Ordering Platform', null,'DE_Contract',True,false));
        insert configs;

        //SSC-1982 : Tlife Commission ends here
    }
  	
    @isTest static void test_contractProcess_positive() {
        // Implement test code
        UnitTestDataFactory.testDataForYogiyoContractProcessWithoutConfigs();
        Opportunity opp = [select id,StageName,CloseDate from Opportunity where name='TestOpp123'];
        ClsCaseProcessor.donotValidateOppStage = true;
        List<Case> cases = [Select Id from Case where type = 'Quality Check'];
        for(Case cs :cases){
        	cs.status = 'Closed';
        	cs.Closed_reason__c = 'Successful';
        }
	Test.startTest();
		update cases;
        Test.stopTest();
        string opptyStage = [select id,StageName,CloseDate from Opportunity where name='TestOpp123'].StageName;
        System.assertEquals('Closed Won',opptyStage);
        List<Contract> listContract = [Select id,name from Contract where Id_Opportunity__c=:opp.id];
        List<Additional_Charges__c> listAddCharges = [SELECT Id, Id_Opportunity__c,Start_Date__c FROM Additional_Charges__c WHERE Id_Opportunity__c =: opp.Id ];
        System.debug('listContract list: '+listContract);
        System.assertEquals(1,listContract.size());
        System.assertEquals(2,listAddCharges.size());
    }
    
    @isTest static void test_contractProcess_negative() {
        // Implement test code
        UnitTestDataFactory.testDataForYogiyoContractProcessWithoutConfigs();
        Opportunity opp = [select id,StageName from Opportunity where name='AddChargeStartDateTest'];
        
        Test.startTest();
            opp.StageName = 'Closed Won';
            update opp;
        Test.stopTest();
        
        List<Contract> listContract = [Select id,name from Contract where Id_Opportunity__c=:opp.id];
        System.debug('listContract list: '+listContract);
        System.assert(listContract.isEmpty());
    }
    
    @isTest static void test_assetProcess_positive() {
        UnitTestDataFactory.testDataForYogiyoContractProcessWithoutConfigs();
        Opportunity opp = [select id,StageName from Opportunity where name='TestOpp123'];
        
        // close quality check cases
        ClsCaseProcessor.donotValidateOppStage = true;
        List<Case> cases = [Select Id from Case where type = 'Quality Check'];
        for(Case cs :cases){
        	cs.status = 'Closed';
        	cs.Closed_reason__c = 'Successful';
        }
        
        Test.startTest();
	    update cases;
        Test.stopTest();
        string opptyStage = [select id,StageName,CloseDate from Opportunity where name='TestOpp123'].StageName;
        System.assertEquals('Closed Won',opptyStage);
        List<Asset__c> listAsset = [select id from Asset__c where Opportunity__c=:opp.id];
        System.debug('listAsset list: '+listAsset);
        System.assertEquals(listAsset.size(),1);
    }
    
    @isTest static void test_assetCreationProcess(){
    	Country__c testCountry = UnitTestDataFactory.createCountry('CD','Colombia', 'COP');
        insert testCountry;
        Company__c com = UnitTestDataFactory.createCompany('Clickdelivery', 'CD', testCountry);
        insert com;
        
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'CD_Account');
        insert accList;
        
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'CD_Opportunity',Date.today());
        oppList[0].type = 'Product Only';
        insert oppList;
        
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppList[0].id,status__c='Approved',ID_Account__c=acclist[0].id);
        insert newQuote;

        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,testCountry,'Apple','CD_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,testCountry,'Setup Fee','CD_List_Product_Group');
        insert new List<SObject>{lpg,lpg1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,testCountry,'Ipad 4 Gen. 16GB',lpg.id,'CD_List_Product_Price',1,true,100,1,false,20);
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 1',lpg1.id,'CD_List_Product_Price',1,true,100,1,false,20); 
        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 2',lpg1.id,'CD_List_Product_Price',1,true,50,1,false,20);
        lpp.Requires_Asset__c=true;  
        lpp.Requires_Branding__c=false;
        lpp.Requires_Add_On__c=false;
        insert new List<sObject>{lpp,lpp1,lpp2};

        List<Opportunity_Quote_Line_Item__c> oppQuoteLine2 =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'CD_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Packaging','Product');
        oppQuoteLine2[0].Id_List_Product_Price__c = lpp.Id;
        oppQuoteLine2[0].id_opportunity__c=opplist[0].id;
        oppQuoteLine2[0].Quantity__c = 1;
        insert oppQuoteLine2;
        ClsCaseProcessor.donotValidateOppStage = true;
        newQuote.status__c='Accepted';
        update newQuote;
        
        Test.startTest();
        	ClsCaseProcessor.donotValidateOppStage = true;
        	oppList[0].business_type__c = 'New Business';
            oppList[0].stageName='Quality Check Request';
            update oppList[0];
        Test.stopTest();   
        
        List<Asset__c> assets = [Select Id from Asset__c];
        System.assertEquals(assets.size(),1);
        
    }
    
    
    @isTest static void test_NonContractedMenuProcessing(){
        Country__c testCountry = UnitTestDataFactory.createCountry('KR','Korea', 'KRW');
        insert testCountry;

        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'Yogiyo_Account');
        accList[0].Non_Contracted__c = true;
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'Yogiyo_Opportunity',Date.today());
        oppList[0].Non_Contracted__c = true;
        
        Test.startTest();
            insert oppList;
        Test.stopTest();
        
        List<Case> listCase = [select id from Case where Opportunity__c =:oppList[0].id and type='Menu Processing'];
        Opportunity result = [select id,stageName from Opportunity where id =:oppList[0].id];
        System.assertEquals(listCase.size(),1);
        System.assertEquals(result.stageName,'Non Contracted');
    }
    
    
    @isTest static void test_flatCommissionEntryProcess(){
    	Country__c testCountry = UnitTestDataFactory.createCountry('KR','Korea', 'KRW');
        insert testCountry;
		Company__c com = UnitTestDataFactory.createCompany('Yogiyo', 'KR', testCountry);
        insert com;
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'Yogiyo_Account');
        accList[0].Non_Contracted__c = true;
        insert accList;
        
        
        Tarif__c t = UnitTestDataFactory.createTarif(com,testCountry,'0% Commission','UK_Tarif',false);
        insert t;
        
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'Yogiyo_Opportunity',Date.today());
        oppList[0].Non_Contracted__c = true;
        oppList[0].type = 'Product Only';
        oppList[0].id_tarif__c = t.id;
        insert oppList;       
        
        Test.startTest();
            ClsCaseProcessor.donotValidateOppStage = true;
            oppList[0].stageName = 'Closed Won';
            update oppList;
        Test.stopTest();
        
        List<Case> listCase = [select id from Case where Opportunity__c =:oppList[0].id and type='0% Commission Entry'];
        System.assertEquals(listCase.size(),1);
    } 
    
    
    @isTest static void test_NonContractedMenuProcessing_Negative(){
        Country__c testCountry = UnitTestDataFactory.createCountry('KR','Korea', 'KRW');
        insert testCountry;
                
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'Yogiyo_Account');
        accList[0].Non_Contracted__c = false;
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'Yogiyo_Opportunity',Date.today());
        insert oppList;
        oppList[0].Non_Contracted__c = false;
        
        Test.startTest();
            update oppList[0];
        Test.stopTest();
        
        List<Case> caseList = [select id from Case where Opportunity__c =:oppList[0].id and type='Menu Processing'];
        Opportunity result = [select id,stageName from Opportunity where id =:oppList[0].id];
        System.assertEquals(caseList.size(),0);
        System.assertNotEquals(result.stageName,'Non Contracted');
    }
   
    @isTest static void test_NonContractedMenuChange(){
        Country__c testCountry = UnitTestDataFactory.createCountry('KR','Korea', 'KRW');
        insert testCountry;
        
        Case menuProcessingCase = new Case(Type='Menu Processing',Subject='Menu Processing',RecordTypeId=mapRecordTypes.get('Yogiyo_Entry_Case').id ,status='closed');
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'Yogiyo_Account');
        accList[0].Non_Contracted__c = true;
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'Yogiyo_Opportunity',Date.today());
        oppList[0].non_contracted__c = true;
        insert oppList;
        oppList[0].non_contracted__c = true;
        oppList[0].StageName = 'Closed Won';
        // closed the mp case created
        List<Case> mpCases = [Select status from Case where type = 'Menu Processing'];
        if(mpCases.size() > 0){
        	mpCases[0].status = 'Closed';
        	update mpCases;
        }
        Test.startTest();
            menuProcessingCase.Opportunity__c = oppList[0].id;
            menuProcessingCase.AccountId = accList[0].id;
            insert menuProcessingCase;
            update oppList[0]; 
        Test.stopTest();
        
        List<Case> caseList = [select id from Case where Opportunity__c =:oppList[0].id and type='Convert to Contract'];
        System.assertEquals(caseList.size(),1);
    }
    
    @isTest static void test_NonContractedMenuChange_Negative(){
        Country__c testCountry = UnitTestDataFactory.createCountry('KR','Korea', 'KRW');
        insert testCountry;
                
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'Yogiyo_Account');
        accList[0].Non_Contracted__c = false;
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'Yogiyo_Opportunity',Date.today());
        insert oppList;
        oppList[0].Non_Contracted__c = false;
        oppList[0].StageName = 'Closed Won';
        Test.startTest();
            update oppList[0];
        Test.stopTest();

        List<Case> caseList = [select id from Case where Opportunity__c =:oppList[0].id and type='Convert to Contract'];
        System.assertEquals(caseList.size(),0);
    }
    
    @isTest static void test_ContractedMenuProcessing(){
        Country__c testCountry = UnitTestDataFactory.createCountry('KR','Korea', 'KRW');
        insert testCountry;
        
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'Yogiyo_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'Yogiyo_Opportunity',Date.today());
        oppList[0].non_contracted__c = false;
        insert oppList;
        oppList[0].StageName = 'Closed Won';
        oppList[0].type = 'Contract Only';
        Test.startTest();
        update oppList[0];
        Test.stopTest();
        system.debug('cases-->'+[select id,type from Case ]);
        List<Case> caseList = [select id from Case where Opportunity__c =:oppList[0].id and type='Menu Processing'];
        System.assertEquals(caseList.size(),1);
    }
    
    @isTest static void test_genericMenuProcessing_Positive(){
        Country__c testCountry = UnitTestDataFactory.createCountry('DE','Germany', 'EUR');
        insert testCountry;

        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'DE_Account');
        insert accList;
        ClsCaseProcessor.donotValidateOppStage = true;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DE_Opportunity',Date.today());
		oppList[0].stageName = 'Quote Sent';
        insert oppList;
        oppList[0].StageName = 'Editorial Queue';
        oppList[0].type = 'Contract Only';
        Test.startTest();
        	ClsCaseProcessor.donotValidateOppStage = true;
            update oppList[0];
        Test.stopTest();
        
        List<Case> caseList = [select id from Case where Opportunity__c =:oppList[0].id and type='Menu Processing'];
        System.assertEquals(caseList.size(),1);

    }
    
    @isTest static void test_qualityCheckInternalCase_Positive(){
        Country__c testCountry = UnitTestDataFactory.createCountry('DE','Germany', 'EUR');
        insert testCountry;

        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'DE_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DE_Opportunity',Date.today());
        insert oppList;
        oppList[0].type = 'Contract Only';
        oppList[0].Business_Type__c = 'New';
        oppList[0].StageName = 'Quality Check Request';
        
        Test.startTest();
        	ClsCaseProcessor.donotValidateOppStage = true; 
            update oppList[0];
        Test.stopTest();
        
        List<Case> caseList = [select id, Subject from Case where Opportunity__c =:oppList[0].id and type='Quality Check'];
        System.assertEquals(caseList.size(),1);
        System.assert(caseList[0].Subject.contains(oppList[0].Business_Type__c));
    }
        
    @isTest static void test_qualityCheckInternalCase_Negative(){
        Country__c testCountry = UnitTestDataFactory.createCountry('DE','Germany', 'EUR');
        insert testCountry;

        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'DE_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DE_Opportunity',Date.today());
        insert oppList;
        oppList[0].type = 'Contract Only';
        oppList[0].StageName = 'Editorial Queue';
        
        Test.startTest();
        	ClsCaseProcessor.donotValidateOppStage = true; 
            update oppList[0];
        Test.stopTest();
        
        List<Case> caseList = [select id from Case where Opportunity__c =:oppList[0].id and type='Quality Check'];
        System.assertEquals(caseList.size(),0);
    }
    
    @isTest static void test_validateOpportunityQuote_Positive(){
        Country__c testCountry = UnitTestDataFactory.createCountry('DE','Germany', 'EUR');
        insert testCountry;

        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'DE_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DE_Opportunity',Date.today());
        insert oppList;
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppList[0].id,status__c='Draft');
        insert newQuote;
        oppList[0].type = 'Contract Only';
        oppList[0].StageName = 'Closed Won';
        Case cs = new Case(Opportunity__c=oppList[0].id, accountid=accList[0].id,type='Quality Check', status='New');
        insert cs;
        Test.startTest();
        	try{
            update oppList[0];
            System.assertEquals(true,false,'Validation is not working');
        	}catch(Exception e){
        		System.assertEquals(true,true);
        	}
        Test.stopTest();
    }
    
     @isTest static void test_validateOpportunityQuote_Negative(){
        Country__c testCountry = UnitTestDataFactory.createCountry('DE','Germany', 'EUR');
        insert testCountry;

        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'DE_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DE_Opportunity',Date.today());
        oppList[0].type = 'Contract Only';
        insert oppList;
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppList[0].id,status__c='Accepted');
        insert newQuote;
        
        oppList[0].type = 'Contract Only';
        oppList[0].StageName = 'Closed Won';
        
        Test.startTest();
        	ClsCaseProcessor.donotValidateOppStage = true;
        	try{
            update oppList[0];
            System.AssertEquals(true,false);
        	}catch(Exception e){}            
        Test.stopTest();
        
        List<Opportunity> listOpp = [select id,StageName from Opportunity where id=:oppList[0].id];
        System.assertNotEquals('Closed Won',listOpp[0].StageName);
    }
    
    @isTest static void test_adSalesEntryCaseCreation(){
        Country__c testCountry = UnitTestDataFactory.createCountry('KR','Korea', 'KRW');
        insert testCountry;
                
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'Yogiyo_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'Yogiyo_Opportunity',Date.today());
        insert oppList;
        oppList[0].StageName = 'Closed Won';
        oppList[0].type = 'AdSales';
        Test.startTest();
            update oppList[0];
        Test.stopTest();
        
        List<Case> caseList = [select id from Case where Opportunity__c =:oppList[0].id and type='Ad Sales Entry'];
        System.assertEquals(1,caseList.size());
     }
     
     @isTest static void test_genericMenuProcessingWithBusinessType_Positive(){
        Country__c testCountry = UnitTestDataFactory.createCountry('DE','Germany', 'EUR');
        insert testCountry;

        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'DE_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DE_Opportunity',Date.today());

        insert oppList;
        oppList[0].StageName = 'Editorial Queue';
        oppList[0].type = 'Contract Only';
        oppList[0].Business_Type__c = 'Upgrade';
        
        Test.startTest();
        	ClsCaseProcessor.donotValidateOppStage = true; 
            update oppList[0];
        Test.stopTest();
        
        List<Case> caseList = [select id from Case where Opportunity__c =:oppList[0].id and type='Menu Processing' and subject='Upgrade'];
        System.assertEquals(caseList.size(),1);
    }
    
    @isTest static void test_validateOpportunityQuote(){
        Country__c testCountry = UnitTestDataFactory.createCountry('DE','Germany', 'EUR');
        insert testCountry;

        company__c com = UnitTestDataFactory.createCompany('Delivery Hero', 'DE', testCountry);
        insert com;
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'DE_Account');
        insert accList;
        Platform_Performance__c platformPerformance = new Platform_Performance__c(Account__c = accList[0].Id, Backend_ID__c = '1111');
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DE_Opportunity',Date.today());
        oppList[0].type = 'Contract Only';
        insert oppList;
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppList[0].id,status__c='Draft');
        newQuote.recordtypeid=LibRecordTypeHelper.getRecordTypeValue('DE_Opportunity_Quote');
        insert newQuote;
        
        
        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,testCountry,'Apple','DE_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,testCountry,'Setup Fee','DE_List_Product_Group');
        insert new List<SObject>{lpg,lpg1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,testCountry,'Ipad 4 Gen. 16GB',lpg.id,'DE_List_Product_Price',1,true,100,1,false,20);
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 1',lpg1.id,'DE_List_Product_Price',1,true,100,1,false,20); 
        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com,testCountry,'Premium placement - 1 Month',lpg1.id,'DE_List_Product_Price',1,true,50,1,false,20);
        lpp.Requires_Asset__c=false;  
        lpp.Requires_Branding__c=false;
        lpp.Requires_Add_On__c=false;
        lpp1.Requires_Additional_Charge__c=true;
        lpp1.Requires_Asset__c=false;
        lpp2.product_type__c='Premium placement - 1 Month';
        insert new List<sObject>{lpp,lpp1,lpp2, platformPerformance};
        
        List<Opportunity_Quote_Line_Item__c> oqp=UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,lpp.id,lpg.id,4,true,'DE_Opportunity_Quote_Line_Item',1,'20',200.0,2,300.0, 'Product');
        List<Opportunity_Quote_Line_Item__c> quoteLines=UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,True,'DE_Opportunity_Quote_Line_Item',20.0,0,true,1,system.today(),'Commission Fee','Service');
        List<Opportunity_Quote_Line_Item__c> oqp2=UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,lpp1.id,lpg.id,4,true,'DE_Opportunity_Quote_Line_Item',1,'20',200.0,2,300.0, 'Product');
        List<Opportunity_Quote_Line_Item__c> oqp3=UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,lpp2.id,lpg.id,4,true,'DE_Opportunity_Quote_Line_Item',1,'20',200.0,2,300.0, 'Product');
        
        quoteLines[0].id_opportunity__c=oppList[0].id;
        oqp[0].id_opportunity__c=oppList[0].id;
        oqp2[0].id_opportunity__c=oppList[0].id;
        oqp3[0].id_opportunity__c=oppList[0].id;
        insert new List<sObject>{quoteLines[0],oqp[0],oqp2[0],oqp3[0]};
        
        oppList[0].type = 'Contract Only';
        oppList[0].StageName = 'Closed Won';
        
        Test.startTest();
            newQuote.Status__C='Accepted';
            update newQuote;
            // close quality check cases
	        ClsCaseProcessor.donotValidateOppStage = true;
            List<Case> cases = [Select Id from Case where type = 'Quality Check' AND Opportunity__c = :oppList.get(0).Id];
	        for(Case cs :cases){
	        	cs.status = 'Closed';
	        	cs.Closed_reason__c = 'Successful';
	        }
	        update cases;
        Test.stopTest();
        
        List<Opportunity> listOpp = [select id,StageName from Opportunity where id=:oppList[0].id];
        System.assertEquals('Closed Won',listOpp[0].stageName);
    }
    
    @isTest static void test_createBackendUK(){
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());    
        Country__c testCountry = UnitTestDataFactory.createCountry('UK','United Kingdom', 'GBP');
        insert testCountry;
        Company__c com = UnitTestDataFactory.createCompany('hungryhouse', 'UK', testCountry);
        insert com;
        
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'UK_Account');
        insert accList;
        accList[0].Restaurant_Name__c ='test';
        accList[0].record_country__c='United Kingdom';
        accList[0].BillingPostalCode='W1H 1DP';
        update accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'UK_Opportunity',Date.today());
        oppList[0].type = 'Contract Only';
        oppList[0].Business_type__c = 'New Business';
        insert oppList;
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppList[0].id,status__c='Approved',ID_Account__c=acclist[0].id);
        insert newQuote;

        List_Service_Price__c lsp = UnitTestDataFactory.createService(com,testCountry,'testService1','UK_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType');
        insert lsp;
        Opportunity_Line_Item__c oppService = UnitTestDataFactory.createOpportunityLineItemService('testService3',oppList[0],lsp.id,true,'UK_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        insert oppService;
        ClsCaseProcessor.donotValidateOppStage = true;
        List<Opportunity_Quote_Line_Item__c> oppQuoteLine =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'UK_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Commission Fee','Service');
        insert oppQuoteLine ;
        oppQuoteLine[0].id_opportunity__c=opplist[0].id;
        newQuote.status__c='Accepted';
        update newQuote;
        update oppQuoteLine;
        List<Contact> contacts = UnitTestDataFactory.createContacts(accList, 'test Lastname', 'test FirstName', 'Mr', 'Owner', 1, 'testme', 'UK_Contact');
        insert contacts;
        contacts[0].email='test@test.com';
        update contacts;
        List<Case> casesList = new List<Case>();
        ClsCaseProcessor.donotValidateOppStage = true;
        List<Case> cases = [Select Id from Case where type = 'Quality Check'];
        for(Case cs :cases){
        	cs.status = 'Closed';
        	cs.Closed_reason__c = 'Successful';
            casesList.add(cs);
        }

        Test.startTest();
            update casesList;
            oppList[0].Business_Type__c = 'New Business';
            oppList[0].stageName='Editorial Queue';
            //try{
            update oppList[0];
            //}catch(Exception e){}
        Test.stopTest();
        
        List<Account> accounts = [Select Id from Account where backend_iD__c != null];
        System.assertEquals(1,accounts.size());
        
    } 
    
    @isTest static void test_CloseOppLostWithMidasAPI(){
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        Country__c testCountry = UnitTestDataFactory.createCountry('UK','United Kingdom', 'GBP');
        insert testCountry;
        Company__c com = UnitTestDataFactory.createCompany('hungryhouse', 'UK', testCountry);
        insert com;
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'UK_Account');
        accList[0].Record_Country__c='United Kingdom';
        insert accList;
        Tarif__c t = UnitTestDataFactory.createTarif(com,testCountry,'Premium Placement','UK_Tarif',false);
        insert t;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'UK_Opportunity',Date.today());
        oppList[0].Id_Tarif__c = t.Id;
        insert oppList;
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,testCountry,'Setup Fee','UK_List_Product_Group');
        insert lpg1;
        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com,testCountry,'Premium placement',lpg1.id,'UK_List_Product_Price',1,true,50,1,false,20);
        lpp2.Product_type__c 	= 'Premium Placement';
        insert lpp2;
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppList[0].id,status__c='Approved',ID_Account__c=acclist[0].id);
        insert newQuote;
        List<Opportunity_Quote_Line_Item__c> oqp2=UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,lpp2.id,lpg1.id,4,true,'UK_Opportunity_Quote_Line_Item',1,'20',200.0,2,300.0, 'Product');
        oqp2[0].Id_opportunity__c = oppList[0].id;
        oqp2[0].Booking_Api_Id__c = '58983';
        insert oqp2;
        Opportunity_Line_Item__c oppProduct = UnitTestDataFactory.createOpportunityLineItemProduct('Super Hero Setup 2',oppList[0],lpg1.id,lpp2.id,true,'UK_Opportunity_Line_Item',1,'',50,1,50,'Setup Fee');
        oppProduct.Booking_Api_Id__c = '58983';
        insert oppProduct;
        
        Test.startTest();
            oppList[0].StageName='Closed Lost';
            oppList[0].Lost_Reason__c = 'Not enough capacity';
            update oppList[0];
        Test.stopTest();
        
        List<Opportunity_Line_Item__c> li = [Select Booking_Api_Id__c,Id_opportunity__r.stageName from Opportunity_Line_Item__c where booking_Api_Id__c != null];
        System.assertEquals(li[0].Booking_Api_Id__c,'58983');
        System.assertEquals(li[0].Id_opportunity__r.StageName,'Closed Lost');
    }
    
    
    @isTest static void test_shippingbackendCase(){
        Country__c testCountry = UnitTestDataFactory.createCountry('CD','Colombia', 'COP');
        insert testCountry;
        Company__c com = UnitTestDataFactory.createCompany('Clickdelivery', 'CD', testCountry);
        insert com;
 
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'CD_Account');
        insert accList;
        accList[0].Restaurant_Name__c ='test';
        accList[0].record_country__c='Colombia';
        accList[0].BillingPostalCode='W1H 1DP';
        update accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'CD_Opportunity',Date.today());
        oppList[0].type = 'Product Only';
        insert oppList;
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppList[0].id,status__c='Approved',ID_Account__c=acclist[0].id);
        insert newQuote;

        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,testCountry,'Apple','CD_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,testCountry,'Setup Fee','CD_List_Product_Group');
        insert new List<SObject>{lpg,lpg1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,testCountry,'Ipad 4 Gen. 16GB',lpg.id,'CD_List_Product_Price',1,true,100,1,false,20);
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 1',lpg1.id,'CD_List_Product_Price',1,true,100,1,false,20); 
        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 2',lpg1.id,'CD_List_Product_Price',1,true,50,1,false,20);
        lpp.Requires_Asset__c=false;  
        lpp.Requires_Branding__c=false;
        lpp.Requires_Add_On__c=false;
        insert new List<sObject>{lpp,lpp1,lpp2};
		
		ClsCaseProcessor.donotValidateOppStage = true;
        List<Opportunity_Quote_Line_Item__c> oppQuoteLine2 =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'CD_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Packaging','Product');
        oppQuoteLine2[0].id_opportunity__c=opplist[0].id;
        insert oppQuoteLine2;
        newQuote.status__c='Accepted';
        update newQuote; 
        
        Test.startTest();
            oppList[0].Business_Type__c = 'New Business';
            oppList[0].stageName='Promo and Logistics Queue';
            update oppList[0];
        Test.stopTest();
        
        List<Case> cases = [Select Id from Case where type = 'Shipment'];
        System.assertEquals(cases.size(),1);
        
    }
    
    @isTest static void test_brandingOnQuoteAccept(){
        Country__c testCountry = UnitTestDataFactory.createCountry('CD','Colombia', 'COP');
        insert testCountry;
        Company__c com = UnitTestDataFactory.createCompany('Clickdelivery', 'CD', testCountry);
        insert com;
        
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'CD_Account');
        insert accList;
        accList[0].Restaurant_Name__c ='test';
        accList[0].record_country__c='Colombia';
        accList[0].BillingPostalCode='W1H 1DP';
        update accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'CD_Opportunity',Date.today());
        oppList[0].type = 'Product Only';
        insert oppList;
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppList[0].id,status__c='Approved',ID_Account__c=acclist[0].id);
        insert newQuote;

        
        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,testCountry,'Apple','CD_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,testCountry,'Setup Fee','CD_List_Product_Group');
        insert new List<SObject>{lpg,lpg1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,testCountry,'Ipad 4 Gen. 16GB',lpg.id,'CD_List_Product_Price',1,true,100,1,false,20);
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 1',lpg1.id,'CD_List_Product_Price',1,true,100,1,false,20); 
        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 2',lpg1.id,'CD_List_Product_Price',1,true,50,1,false,20);
        lpp.Requires_Asset__c=false;  
        lpp.Requires_Branding__c=true;
        lpp.Requires_Add_On__c=false;
        insert new List<sObject>{lpp,lpp1,lpp2};
        
        ClsCaseProcessor.donotValidateOppStage = true;
        List<Opportunity_Quote_Line_Item__c> oppQuoteLine2 =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'CD_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Packaging','Product');
        oppQuoteLine2[0].id_opportunity__c=opplist[0].id;
        oppQuoteLine2[0].Id_List_Product_Price__c=lpp.id;
        insert oppQuoteLine2;
        newQuote.status__c='Accepted';
        update newQuote;
        
        Test.startTest();
        	ClsCaseProcessor.donotValidateOppStage = true;
            oppList[0].Business_Type__c = 'Upgrade/Upsell';
            oppList[0].stageName='Design Approval';
            update oppList[0];
        Test.stopTest();
        
        List<Branding_Content__c> bcs = [Select Id from Branding_Content__c];
        System.assertEquals(bcs.size(),1);	
    }

  @isTest static void test_RestaurantCare(){
        Country__c testCountry = UnitTestDataFactory.createCountry('DE','Germany', 'EUR');
        insert testCountry;
        Company__c com = UnitTestDataFactory.createCompany('Delivery Hero', 'DE', testCountry);
        insert com;
        
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'DE_Account');
        insert accList;
        accList[0].Restaurant_Name__c ='test';
        accList[0].record_country__c='Germany';
        accList[0].BillingPostalCode='W1H 1DP';
        update accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DE_Opportunity',Date.today());
        oppList[0].type = 'Contract & Product';
        insert oppList;
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppList[0].id,status__c='Approved',ID_Account__c=acclist[0].id);
        insert newQuote;

        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,testCountry,'Apple','DE_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,testCountry,'Setup Fee','DE_List_Product_Group');
        insert new List<SObject>{lpg,lpg1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,testCountry,'Ipad 4 Gen. 16GB',lpg.id,'DE_List_Product_Price',1,true,100,1,false,20);
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 1',lpg1.id,'DE_List_Product_Price',1,true,100,1,false,20); 
        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 2',lpg1.id,'DE_List_Product_Price',1,true,50,1,false,20);
        lpp.Requires_Asset__c=false;  
        lpp.Requires_Branding__c=true;
        lpp.Requires_Add_On__c=false;
        insert new List<sObject>{lpp,lpp1,lpp2};
        List<Opportunity_Quote_Line_Item__c> oppQuoteLine2 =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'DE_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Packaging','Product');
        oppQuoteLine2[0].id_opportunity__c=opplist[0].id;
        oppQuoteLine2[0].Id_List_Product_Price__c=lpp.id;
        insert oppQuoteLine2;
        newQuote.status__c='Accepted';
        update newQuote;   
        Case cs =new Case(type='Onboarding', status='New', recordtypeid=mapRecordTypes.get('DE_Entry_Case').id,accountid=acclist[0].id);
        insert cs;
         
        Test.startTest();
        	ClsCaseProcessor.donotValidateOppStage = true;
            cs.opportunity__c=opplist[0].id;
            cs.Status='Closed';
            cs.closed_reason__c='Invalid';
            update cs;
            oppList[0].Business_Type__c = 'New Business';
            oppList[0].stageName='Onboarding';
            update oppList[0];
        Test.stopTest();
        
        List<Case> cases = [Select Id from Case where type = 'Onboarding'];
        System.assertEquals(cases.size(),2);
        
    }
    
	 @isTest static void test_oppClosedLost(){
        Country__c testCountry = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'HKD');
        insert testCountry;
        
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'FP_Account');
	accList[0].Phone = '+85227367722';
        insert accList;
        accList[0].Restaurant_Name__c ='test';
        accList[0].record_country__c='Hong Kong';
        accList[0].BillingPostalCode='W1H 1DP';
        accList[0].Delivery_Service__c = 'DH Delivery';
        update accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'FP_Opportunity',Date.today());
        insert oppList;
        
         
        Test.startTest();
            Case cs =new Case(type='Onboarding', status='New', recordtypeid=mapRecordTypes.get('FP_Entry_Case').id,accountid=acclist[0].id,Opportunity__c=oppList[0].id);
            insert cs;
            Asset__C asset_new =new Asset__C( status__c='New', recordtypeid=mapRecordTypes.get('FP_Asset').id,account__c=acclist[0].id,Opportunity__c=oppList[0].id);
            insert asset_new;
            branding_content__c brand =new branding_content__c( status__c='New', recordtypeid=mapRecordTypes.get('FP_Branding_Content').id,Restaurant_Name__c=acclist[0].id,Opportunity__c=oppList[0].id);
            insert brand;
            oppList[0].Business_Type__c = 'New Business';
            oppList[0].stageName='Closed Lost';
            update oppList[0];
            
        Test.stopTest();
        
        List<Case> cases = [Select Id from Case where status != 'Closed'];
        System.assertEquals(cases.size(),0);
        
    }
    
    @isTest static void test_platformCreation(){
    	Country__c testCountry = UnitTestDataFactory.createCountry('DE','Germany', 'EUR');
        insert testCountry;
        Company__c com = UnitTestDataFactory.createCompany('Lieferheld', 'DE', testCountry);
        insert com;
        
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'DE_Account');
        insert accList;
        accList[0].Restaurant_Name__c ='test';
        accList[0].record_country__c='Germany';
        accList[0].BillingPostalCode='W1H 1DP';
        update accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DE_Opportunity',Date.today());
        oppList[0].type = 'Contract & Product';
        insert oppList;
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppList[0].id,status__c='Approved',ID_Account__c=acclist[0].id);
        insert newQuote;

        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,testCountry,'Apple','DE_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,testCountry,'Setup Fee','DE_List_Product_Group');
        insert new List<SObject>{lpg,lpg1};
		
		List_Service_Price__c lsp = UnitTestDataFactory.createService(com,testCountry,'testService1','DE_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType');
        insert lsp;
		Opportunity_Line_Item__c oppService = UnitTestDataFactory.createOpportunityLineItemService('testService3',oppList[0],lsp.id,true,'DE_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        insert oppService;
        List<Opportunity_Quote_Line_Item__c> oppQuoteLine =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'DE_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Commission Fee','Service');
        oppQuoteLine[0].Id_Opportunity__c = oppList[0].Id;
        oppQuoteLine[0].Id_list_Service_price__c = lsp.Id;
        insert oppQuoteLine ;
        newQuote.status__c='Accepted';
        update newQuote;   

        Test.startTest();
        	ClsCaseProcessor.donotValidateOppStage = true;
        	oppList[0].business_type__c = 'New Business';
            oppList[0].stageName='Editorial Queue';
            try{
            update oppList[0];
            }catch(Exception e){} 
        Test.stopTest();
    }
   
    @isTest static void test_photoListingProcess(){
        Country__c testCountry = UnitTestDataFactory.createCountry('SE','Sweden', 'SEK');
        insert testCountry;
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'SE_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'SE_Opportunity',Date.today());

        insert oppList;
        oppList[0].StageName = 'Quality check';
        oppList[0].type = 'Contract Only';
        update oppList[0];

        oppList[0].StageName = 'Editorial Queue';
        Test.startTest();
            update oppList[0];
        Test.stopTest();
        
        List<Case> caseList = [select id from Case where Opportunity__c =:oppList[0].id and type='Photo Listing'];
        System.assertEquals(caseList.size(),1);

    } 
    
    @isTest static void test_DishLevelPhotoProcess(){

        Country__c testCountry = UnitTestDataFactory.createCountry('SE','Sweden', 'SEK');
        insert testCountry;

        Company__c com = UnitTestDataFactory.createCompany('Lieferheld', 'SE', testCountry);
        insert com;

        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'SE_Account');
        insert accList;

        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'SE_Opportunity',Date.today());
        insert oppList;

        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,testCountry,'Setup Fee','SE_List_Product_Group');
        insert lpg1;

        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 1',lpg1.id,'SE_List_Product_Price',1,true,100,1,false,null);
        lpp1.Product_Type__c = 'Dish Level Photoshoot';
        insert lpp1;

        List<Opportunity_Line_Item__c> opi;
        opi = UnitTestDataFactory.createOpportunityLineItems(oppList[0], lpg1.Id, lpp1.Id, 1, false, 'SE_Opportunity_Line_Item',1, '10', 299.0, 1, 1, 'Product');

        insert opi;

        oppList[0].StageName = 'Promo and Logistics Queue';
        oppList[0].type = 'Contract Only';
        Test.startTest();
            update oppList[0];
        Test.stopTest();
        
        List<Case> caseList = [select id from Case where Opportunity__c =:oppList[0].id and type='Dish Level Photo'];
        System.assertEquals(caseList.size(),1);

    }
    
    @isTest static void test_photoListingProcessExisting(){
        Country__c testCountry = UnitTestDataFactory.createCountry('SE','Sweden', 'SEK');
        insert testCountry;
       
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'SE_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'SE_Opportunity',Date.today());

        insert oppList;
        oppList[0].StageName = 'Quality check';
        oppList[0].type = 'Contract Only';
        
        Case cs = new Case(Opportunity__c = oppList[0].id, AccountId = accList[0].id, CurrencyIsoCode = oppList[0].CurrencyIsoCode);
        cs.RecordTypeId= mapRecordTypes.get('SE_Entry_Case').id;
        cs.type='Photo Listing Process';
        cs.subject='Photo Listing Process';
        cs.status='New';
        insert cs;
        
        Test.startTest();
            update oppList[0];
        Test.stopTest();
        
        List<Case> caseList = [select id from Case where Opportunity__c =:oppList[0].id and type='Photo Listing'];
        System.assertNotEquals(caseList.size(),2);

    }

}
