@isTest
public class UnitTestChainOpportunityController {
    
    @TestSetup
    public static void setupData(){
    	UnitTestDataFactory.getRecordtypeValues();
    	
    	Country__c testCountry = UnitTestDataFactory.createCountry('DE','Germany', 'EUR');
        insert testCountry;
        Company__c com = UnitTestDataFactory.createCompany('Lieferheld', 'DE', testCountry);
        insert com;
        
        List<Account> accList= UnitTestDataFactory.createAccounts(2,testCountry,'DE_Account');
        accList[0].Type = 'Group';
        accList[1].Type = 'Branch';
        insert accList;
        accList[1].ParentId = accList[0].Id;
        update accList;
        
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(new List<Account>{accList[0]},1,'Chain_Opportunity',Date.today());
        oppList[0].type = 'Product Only';
        insert oppList;
        
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppList[0].id,status__c='Approved',ID_Account__c=acclist[0].id);
        insert newQuote;

        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,testCountry,'Apple','DE_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,testCountry,'Setup Fee','DE_List_Product_Group');
        insert new List<SObject>{lpg,lpg1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,testCountry,'Ipad 4 Gen. 16GB',lpg.id,'DE_List_Product_Price',1,true,100,1,false,20);
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 1',lpg1.id,'DE_List_Product_Price',1,true,100,1,false,20); 
        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 2',lpg1.id,'DE_List_Product_Price',1,true,50,1,false,20);
        lpp.Requires_Asset__c=true;  
        lpp.Requires_Branding__c=false;
        lpp.Requires_Add_On__c=false;
        insert new List<sObject>{lpp,lpp1,lpp2};

        List<Opportunity_Quote_Line_Item__c> oppQuoteLine2 =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'DE_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Packaging','Product');
        oppQuoteLine2[0].Id_List_Product_Price__c = lpp.Id;
        oppQuoteLine2[0].id_opportunity__c=opplist[0].id;
        oppQuoteLine2[0].Quantity__c = 1;
        insert oppQuoteLine2;
        ClsCaseProcessor.donotValidateOppStage = true;
        newQuote.status__c='Accepted';
        update newQuote;
    	
    	// Create Business Configs
    	Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='childOppStageName',Business_Rule_Value__c='Quality Check Request',
    							Id_Country__c= testCountry.Id,Is_Active__c=true,Parent__c=false,
    							Process_Name__c='HeadquarterDealProcess',
								Record_Type_Id__c='Global_Config',Type__c='Process');
		Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='AsynchronousThreshold',Business_Rule_Value__c='2',
    							Id_Country__c= testCountry.Id,Is_Active__c=true,Parent__c=false,
    							Process_Name__c='HeadquarterDealProcess',
								Record_Type_Id__c='Global_Config',Type__c='Process');
		Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='SynchronousThreshold',Business_Rule_Value__c='1',
    							Id_Country__c= testCountry.Id,Is_Active__c=true,Parent__c=false,
    							Process_Name__c='HeadquarterDealProcess',
								Record_Type_Id__c='Global_Config',Type__c='Process');		
								
		insert new List<Business_Config__c>{b1,b2,b3};
    }
    
    @isTest
    public static void testFetchBranches(){
    	Opportunity opp = [Select Id,StageName from Opportunity where recordtype.developerName = 'Chain_Opportunity'];
    	ChainOpportunityController.ResultWrapper wrapper;
    	
    	opp.stageName = 'Closed Won';
    	update opp;
    	
    	wrapper = ChainOpportunityController.fetchBranches(opp.Id);
    	System.assertEquals(wrapper.accounts.size(),1);
    }
    
    @isTest
    public static void testApplyDeal(){
    	Opportunity opp = [Select Id,StageName from Opportunity where recordtype.developerName = 'Chain_Opportunity'];
    	opp.stageName = 'Closed Won';
    	update opp;
    	
    	ChainOpportunityController.ResultWrapper wrapper = ChainOpportunityController.fetchBranches(opp.Id);
    	
    	Test.startTest();
    		try{
    			wrapper	= ChainOpportunityController.applyDeals(JSON.Serialize(wrapper.accounts),opp.Id);
    			System.assertEquals(0,1,'Exception was not thrown as expected');
    		}catch(Exception e){
    			System.assertEquals(1,1);
    		}
    		
    		wrapper.accounts[0].isSelected = true;
    		wrapper	= ChainOpportunityController.applyDeals(JSON.Serialize(wrapper.accounts),opp.Id);	
    		System.assertEquals(wrapper.accounts[0].dealAlreadyApplied,true);
    		
    		// Try again by marking deal creation as false
    		wrapper.accounts[0].dealAlreadyApplied = false;
    		try{
    			wrapper	= ChainOpportunityController.applyDeals(JSON.Serialize(wrapper.accounts),opp.Id);
    			System.assertEquals(0,1,'Exception was not thrown as expected on recreation');
    		}catch(Exception e){
    			
    		}
    		
    	Test.stopTest();
    	
    	List<Opportunity> opps = [Select Id from Opportunity Where recordType.developerName = 'DE_Opportunity'];
    	List<Opportunity_Quote__c> quote = [Select Id from Opportunity_Quote__c where recordType.developerName = 'DE_Opportunity_Quote'];
    	
    	System.assertEquals(opps.size(),1);
    	System.assertEquals(quote.size(),1);
    }
    
    @isTest
    public static void testApplyDealAsynchronous(){
    	List<Account> accParent = [Select Id from Account where type = 'Group'];
    	Country__c ger			= [Select Id,Name,CurrencyISOCode from Country__c where name = 'Germany'];
    	List<Account> accList= UnitTestDataFactory.createAccounts(2,ger,'DE_Account');
    	accList[0].parentId = accParent[0].Id;
    	accList[0].type		= 'Branch';
    	insert accList;
    	
    	Opportunity opp = [Select Id,StageName from Opportunity where recordtype.developerName = 'Chain_Opportunity'];
    	opp.stageName = 'Closed Won';
    	update opp;
    	
    	ChainOpportunityController.ResultWrapper wrapper = ChainOpportunityController.fetchBranches(opp.Id);
    	
    	Test.startTest(); 		
    		wrapper.accounts[0].isSelected 	= true;
    		wrapper.accounts[1].isSelected	= true;
    		wrapper	= ChainOpportunityController.applyDeals(JSON.Serialize(wrapper.accounts),opp.Id);	
    		System.assertEquals(wrapper.accounts[0].dealAlreadyApplied,true);
    	Test.stopTest();
    	
    	List<Opportunity> opps = [Select Id from Opportunity Where recordType.developerName = 'DE_Opportunity'];
    	List<Opportunity_Quote__c> quote = [Select Id from Opportunity_Quote__c where recordType.developerName = 'DE_Opportunity_Quote'];
    	
    	System.assertEquals(opps.size(),2);
    	System.assertEquals(quote.size(),2);
    }
}