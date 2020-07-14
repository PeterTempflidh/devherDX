@isTest
private class UnitTestTrgQuoteProcessor {

    static List<Opportunity> oppList;
    static Country__c testCountry;

    @testSetup static void setup() {
        List<Platform_Country__c> platformCountry = new List<Platform_Country__c>();
        platformCountry.add(new Platform_Country__c(name = 'TalabatPlatform', country__c = 'Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name = 'FOCPlatform', country__c = 'Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
        UnitTestDataFactory.getRecordtypeValues();

        ReplacementOrderSettings__c replacementOrderObj = new ReplacementOrderSettings__c(name='UK',StageName__c='Replacement Charge',probability__c=50,Opportunity__c='name=Asset Replacement,RecordTypeId='+LibRecordTypeHelper.getRecordTypeValue('UK_Opportunity')+',CurrencyIsoCode=GBP,Business_Type__c=Upgrade/Upsell,stageName=Verbal Agreement',QualityCheckCaseSP__c='RecordTypeId='+LibRecordTypeHelper.getRecordTypeValue('UK_Internal_Case')+',type=Quality Check Replacement,subject=Quality Check Replacement,status=New,CurrencyIsoCode=GBP');
        insert replacementOrderObj;

        Country__c uaeCountry = UnitTestDataFactory.createCountry('AE','United Arab Emirates', 'AED');
        insert uaeCountry;
        Company__c comUAE = UnitTestDataFactory.createCompany('Talabat UAE', 'Talabat', uaeCountry);
        insert comUAE;

        Tarif__c tarifObj = UnitTestDataFactory.createTarif(comUAE, uaeCountry, 'Premium Placement', Constants.TARIF_RT_TALABAT_DEVELOPERNAME, false);
        insert tarifObj;
        tarifObj.Is_Active__c = true;
        update tarifObj;

        Account uaeAccount = UnitTestDataFactory.createAccount('test',uaeCountry,Constants.ACCOUNT_RT_TALABAT_ACCOUNT);
        uaeAccount.phone = '+85278273613';
        insert uaeAccount;

        List<Contact> listContact;
        listContact = UnitTestDataFactory.CreateContacts(new List<Account>{uaeAccount}, 'Best', 'Burger', 'Mr', 'Employee', 1, 'test', Constants.CONTACT_RT_TALABAT_DEVELOPERNAME);
        listContact[0].Contact_Role__c='Owner';
        listContact[0].Passport_ID_Number__c='111';
        insert listContact;

        Opportunity uaeOpportunity = UnitTestDataFactory.createOpportunity('testtlb',uaeAccount,Constants.OPPORTUNITY_RT_TALABAT_OPPORTUNITY, Date.today());
        uaeOpportunity.Business_Type__c = Constants.OPPORTUNITY_BUSINESSTYPE_UPGRADE_UPSELL;
        uaeOpportunity.Id_Tarif__r = tarifObj;
        uaeOpportunity.Type = Constants.OPPORTUNITY_TYPE_PRODUCT_ONLY;
        insert uaeOpportunity;

        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(comUAE,uaeCountry,'Apple',Constants.LPG_RT_TALABAT_DEVELOPERNAME);
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(comUAE,uaeCountry,'Setup Fee',Constants.LPG_RT_TALABAT_DEVELOPERNAME);
        insert new List<SObject>{lpg,lpg1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(comUAE,uaeCountry,'Test Product',lpg.id,Constants.LPP_RT_TALABAT_DEVELOPERNAME,1,true,100,1,false,20);
        lpp.Requires_Asset__c=false;
        lpp.Requires_Branding__c=false;
        lpp.Requires_Add_On__c=true;
        insert new List<sObject>{lpp};

        List<Opportunity_Quote__c> objOpprtyQuote;
        objOpprtyQuote = UnitTestDataFactory.createOpportunityQuotes(uaeOpportunity, 2, Constants.OPPORTUNITY_QUOTE_RT_TALABAT_QUOTE, 'Draft', 'test data', 100.45, 100.45, '', '', 0);
        objOpprtyQuote[0].Id_Account__c =uaeAccount.id;
        objOpprtyQuote[0].CreatedDate = System.today()-1;
        objOpprtyQuote[1].Status__c = Constants.OPPORTUNITY_QUOTE_STATUS_APPROVED;
        insert objOpprtyQuote;

        List<Opportunity_Quote_Line_Item__c> oppQuoteLine1 =  UnitTestDataFactory.createOpportunityQuoteLineItems(objOpprtyQuote[0],2,False,Constants.TALABAT_OPPORTUNITY_QUOTE_LINE_ITEM_DEVELOPERNAME,12,1,True, 0, date.today(),'Packaging','Product');
        oppQuoteLine1[0].Id_List_Product_Price__c = lpp.Id;
        oppQuoteLine1[0].id_opportunity__c=uaeOpportunity.id;
        oppQuoteLine1[0].Quantity__c = 1;
        oppQuoteLine1[0].Budget__c = 10;
        oppQuoteLine1[0].Unit_Cost__c = 2;
        oppQuoteLine1[0].Name = 'Premium Placement';
        oppQuoteLine1[1].id_opportunity__c=uaeOpportunity.id;
        oppQuoteLine1[1].Name = 'test Placement';
        oppQuoteLine1[1].Sub_type__c = 'Logistics Fee';
        insert oppQuoteLine1;

        List<Stock_Item__c> stockItemsList = UnitTestDataFactory.createStockItems(2, 'Talabat_Stock_Item', uaeAccount, null, 'A1 - New used', Date.today(), Date.today().addDays(10), Date.today().addDays(-30), '1234567890', '1234567890', 'Korea Telekom', 'In Stock', 'Other');
        insert stockItemsList;
        Branding_Content__c brandContentObj = new Branding_Content__c(Restaurant_Name__c = uaeAccount.Id, Opportunity__c = uaeOpportunity.Id);
        brandContentObj.Id_Opportunity_Quote_Line_Item__c=oppQuoteLine1[0].id;
        insert brandContentObj;
        List<Asset__c> assetsList = UnitTestDataFactory.createAssets(1, uaeAccount, uaeOpportunity, Date.today().addDays(-10), true, stockItemsList[0], stockItemsList[1], 'Talabat_Asset', '12345674',
                '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'Exchange Requested',
                Date.today().addDays(20), 'Yazi Logistics', '1234', 'none');
        assetsList[0].Id_Opportunity_Quote_Line_Item__c=oppQuoteLine1[0].id;
        insert assetsList;

        Business_Config__c busConfigObj1 = UnitTestDataFactory.createBusinessConfig('OppTypeAndStageProcess', 'Process','Status__c','Accepted', uaeCountry.id, 'Talabat_Opportunity_Quote', true, true);
        Business_Config__c busConfigObj2 = UnitTestDataFactory.createBusinessConfig('OppTypeAndStageProcess', 'Process','Product Only','stageName=Quality Check Request,Probability=95', uaeCountry.id, 'Talabat_Opportunity_Quote', true, false);
        Business_Config__c busConfigObj3 = UnitTestDataFactory.createBusinessConfig('OppTypeAndStageProcess', 'Process','Contract & Product','stageName=Quality Check Request,Probability=90', uaeCountry.id, 'Talabat_Opportunity_Quote', true, false);
        Business_Config__c busConfigObj4 = UnitTestDataFactory.createBusinessConfig('OppTypeAndStageProcess', 'Process','UpdateStageToIfReplacementQuote','stageName=Replacement Accepted,Probability=70', uaeCountry.id, 'Talabat_Opportunity_Quote', true, false);
        Business_Config__c busConfigObj5 = UnitTestDataFactory.createBusinessConfig('OppTypeAndStageProcess', 'Process','SetToClosedWonForTariff','Premium Placement', uaeCountry.id, 'Talabat_Opportunity_Quote', true, false);
        Business_Config__c busConfigObj6 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:Upgrade/Upsell;Type:Product Only','AT Quote Myam', uaeCountry.id, 'Talabat_Opportunity', true, false);
        Business_Config__c busConfigObj7 = UnitTestDataFactory.createBusinessConfig('OppTypeAndStageProcess', 'Process','Status__c','Accepted', uaeCountry.id, 'Talabat_Opportunity', true, false);
        Business_Config__c busConfigObj8 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','checkCommissionTypes','Logistics Fee', uaeCountry.id, 'Talabat_Opportunity', true, false);
        Business_Config__c busConfigObj9 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:Upgrade/Upsell;Type:Product Only','AT Quote Myam', uaeCountry.id, 'Talabat_Opportunity', true, false);
        Business_Config__c busConfigObj10 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','checkCommissionTypes','Logistics Fee', uaeCountry.id, 'Talabat_Opportunity', true, false);
        Business_Config__c busConfigObj11 = UnitTestDataFactory.createBusinessConfig('nintexQuoteAdditionalFilters', 'Process','Account.Name','Logistics Fee', uaeCountry.id, 'Talabat_Opportunity', true, false);

        insert new List<Business_Config__c>{busConfigObj1,busConfigObj2,busConfigObj3,busConfigObj4,busConfigObj5,busConfigObj6,busConfigObj7,busConfigObj8,busConfigObj9,busConfigObj10,busConfigObj11};
    }

    static void setupUserData(User u) {
        System.runAs(u) {

            testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            Country__c HKCoutry = UnitTestDataFactory.createCountry('HK','Hong Kong', 'HKD');
			insert new List<Country__c>{testCountry,HKCoutry};
            
            Business_Config__c c =  UnitTestDataFactory.createBusinessConfig('Quote is won process', 'Trigger', null, null, testCountry.id, null, true, true);
            Business_Config__c b = UnitTestDataFactory.createBusinessConfig('Quote Accept Process', 'Process', 'set opportunity stage', '100% Closed', testCountry.id, 'Yogiyo_Opportunity', true, true);
            Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c = 'Status__c', Business_Rule_Value__c = 'Accepted', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'OppTypeAndStageProcess', Record_Type_Id__c = 'Yogiyo_Opportunity_Quote', Type__c = 'Process');
            Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c = 'Product Only', Business_Rule_Value__c = 'stageName=Quality Check Request,Probability=95', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'OppTypeAndStageProcess', Record_Type_Id__c = 'Yogiyo_Opportunity_Quote', Type__c = 'Process');
            Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c = 'Contract & Product', Business_Rule_Value__c = 'stageName=Quality Check Request,Probability=90', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'OppTypeAndStageProcess', Record_Type_Id__c = 'Yogiyo_Opportunity_Quote', Type__c = 'Process');
			
            Business_Config__c bc1 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:New Business;Type:Contract & Product','Vendor Registration Form', HKCoutry.id, 'FP_Opportunity', true, false);
            Business_Config__c bc2 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:New Business;Type:Contract Only','Vendor Registration Form', HKCoutry.id, 'FP_Opportunity', true, false);        
            Business_Config__c bc3 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:New Business;Type:Product Only','Vendor Registration Form', HKCoutry.id, 'FP_Opportunity', true, false);
            Business_Config__c bc4 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:Win back;Type:Contract & Product','Vendor Registration Form', HKCoutry.id, 'FP_Opportunity', true, false);
            Business_Config__c bc5 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:Win back;Type:Contract Only','Vendor Registration Form', HKCoutry.id, 'FP_Opportunity', true, false);
            Business_Config__c bc6 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:Win back;Type:Product Only','Vendor Registration Form', HKCoutry.id, 'FP_Opportunity', true, false);
            Business_Config__c bc7 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:Owner Change;Type:Contract & Product','Vendor Registration Form', HKCoutry.id, 'FP_Opportunity', true, false);
            Business_Config__c bc8 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:Owner Change;Type:Contract Only','Vendor Registration Form', HKCoutry.id, 'FP_Opportunity', true, false);
            Business_Config__c bc9 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:Owner Change;Type:Product Only','Vendor Registration Form', HKCoutry.id, 'FP_Opportunity', true, false);
            Business_Config__c bc10 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:Legal Form Change;Type:Contract & Product','Vendor Registration Form', HKCoutry.id, 'FP_Opportunity', true, false);
            Business_Config__c bc11 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:Legal Form Change;Type:Contract Only','Vendor Registration Form', HKCoutry.id, 'FP_Opportunity', true, false);
            Business_Config__c bc12 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:Legal Form Change;Type:Product Only','Vendor Registration Form', HKCoutry.id, 'FP_Opportunity', true, false);
            Business_Config__c bc13 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:Upgrade/Upsell;Type:Contract & Product','Contract Amendment', HKCoutry.id, 'FP_Opportunity', true, false);
            Business_Config__c bc14 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:Upgrade/Upsell;Type:Contract Only','Contract Amendment', HKCoutry.id, 'FP_Opportunity', true, false);
            Business_Config__c bc15 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:Upgrade/Upsell;Type:Product Only','Order Confirmation checkArea', HKCoutry.id, 'FP_Opportunity', true, false);
            Business_Config__c bc16 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:Downgrade;Type:Contract & Product','Contract Amendment', HKCoutry.id, 'FP_Opportunity', true, false);
            Business_Config__c bc17 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:Downgrade;Type:Contract Only','Contract Amendment', HKCoutry.id, 'FP_Opportunity', true, false);
            Business_Config__c bc18 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:Downgrade;Type:Product Only','Order Confirmation checkArea', HKCoutry.id, 'FP_Opportunity', true, false);
            
            insert new List<Business_Config__c>{c,b,b1,b2,b3,bc1,bc2,bc3,bc4,bc5,bc6,bc7,bc8,bc9,bc10,bc11,bc12,bc13,bc14,bc15,bc16,bc17,bc18};


            List<Account> accList = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
            insert accList;
            
            Account fpAcc = UnitTestDataFactory.createAccount('test',HKCoutry,'FP_Account');
            fpAcc.phone = '+85278273613';
            insert fpAcc;
            
            oppList = UnitTestDataFactory.createOpportunities(accList, 1, 'Yogiyo_Opportunity', Date.today());
            oppList[0].Type = 'Contract Only';
            insert oppList;
            
            Opportunity opp2 = UnitTestDataFactory.createOpportunity('test',fpAcc,'FP_Opportunity', Date.today());
            opp2.Company_Code__c = 'HK';
            opp2.Business_Type__c = 'Upgrade/Upsell';
            opp2.Type = 'Product Only';
            insert opp2;

        }
    }

    @isTest static void test_QuoteProcess_positive() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'unittestUser@deliveryhero.com', 'Yogiyo', 'KR');
        List<Opportunity_Quote__c> oppQuoteList;

        Test.startTest();
        System.runAs(testUser) {
            setupUserData(testUser);
            //Inserting Opp quote
        	Opportunity opp	= [SELECT id,RecordTypeId FROM Opportunity WHERE RecordType.developername = 'FP_Opportunity' Limit 1];
            Opportunity_Quote__c  oq = new Opportunity_Quote__c();
            oq.Id_Opportunity__c = opp.Id;
            insert oq;
            
            oppQuoteList = UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1, 'Yogiyo_Opportunity_Quote', 'Draft', 'test data', 100.45, 100.45, '', '', 0);
            oppQuoteList.addAll(UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1, 'Yogiyo_Opportunity_Quote', 'Draft', 'test data1', 101.45, 101.45, '', '', 0));
            System.debug('oppQuoteList: ' + oppQuoteList);
            insert oppQuoteList;
            oppQuoteList[0].Status__c = 'Accepted';
            update oppQuoteList[0];
        }
        Test.stopTest();
        Opportunity_Quote__c result = [Select id, status__c from Opportunity_Quote__c where id = :oppQuoteList[1].id];
        System.assertEquals(result.status__c, 'Declined');

    }

    @isTest static void test_QuoteProcess_negative() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'unittestUser@deliveryhero.com', 'Yogiyo', 'KR');
        List<Opportunity_Quote__c> oppQuoteList ;
        Test.startTest();
        System.runAs(testUser) {
            setupUserData(testUser);
            oppQuoteList = UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1, 'Yogiyo_Opportunity_Quote', 'Draft', 'test data', 100.45, 100.45, '', '', 0);
            oppQuoteList.addAll(UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1, 'Yogiyo_Opportunity_Quote', 'Draft', 'test data1', 101.45, 101.45, '', '', 0));

            System.debug('oppQuoteList: ' + oppQuoteList);
            insert oppQuoteList;
            oppQuoteList[0].Status__c = 'Declined';
            update oppQuoteList[0];
        }
        Test.stopTest();
        Opportunity_Quote__c result = [Select id, status__c from Opportunity_Quote__c where id = :oppQuoteList[1].id];
        System.assertEquals(result.status__c, 'Draft');
    }
    /*****
     * @description     : Test Class for AT Nintex Rollout to populate quote type
     * @param           : none
     */
    @isTest static void testQuoteProcessForAT() {
        User testUser = UnitTestDataFactory.createUser('AT Sales Team', 'unittestUser@deliveryhero.com', 'Mjam', 'AT');
        List<Opportunity_Quote__c> oppQuoteList;
        Country__c atCountry = UnitTestDataFactory.createCountry('AT','Austria', 'EUR');
        insert new List<Country__c>{atCountry};
        Company__c austriaCom = UnitTestDataFactory.createCompany('Mjam', 'AT', atCountry);
        insert austriaCom;

        Business_Config__c businessConfig1 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:Upgrade/Upsell;Type:Contract Only','AT Quote Myam', atCountry.id, 'AT_Opportunity', true, false);
        Business_Config__c businessConfig2 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','checkCommissionTypes','Logistics Fee', atCountry.id, 'AT_Opportunity', true, false);
        Business_Config__c businessConfig3 = UnitTestDataFactory.createBusinessConfig('nintexQuoteAdditionalFilters', 'Process','Account.Name','Logistics Fee', atCountry.id, 'AT_Opportunity', true, false);

        insert new List<Business_Config__c>{businessConfig1,businessConfig2,businessConfig3};
        UnitTestDataFactory.getRecordtypeValues();

        Account austAcc = UnitTestDataFactory.createAccount('TEST', atCountry, 'AT_Account');
        austAcc.Type = 'Branch - main';
        insert austAcc;

        Opportunity opp2 = UnitTestDataFactory.createOpportunity('test',austAcc,'AT_Opportunity', Date.today());
        opp2.Company_Code__c = 'AT';
        opp2.Business_Type__c = 'Upgrade/Upsell';
        opp2.Type = 'Contract Only';
        insert opp2;

        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(austriaCom, atCountry, 'test commsi', 'AT_List_Product_Group');
        insert lpg;

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(austriaCom, atCountry, 'test product price', lpg.id, 'AT_List_Product_Price', 1, true, 100, 1, false, 20);
        lpp.Displayed_Name__c = 'test comm';
        lpp.Requires_Additional_Charge__c = false;

        insert new List<List_Product_Price__c> {lpp};

        List_Service_Price__c lsp = UnitTestDataFactory.createService(austriaCom,atCountry,'testService1','AT_List_Service_Price',12,12,25,5,null,true,null,'Commission','Logistics Fee');
        insert lsp;

        List<Opportunity_Line_Item__c> lineItems = UnitTestDataFactory.createOpportunityLineItems(opp2, lpg.id, lpp.id, 2, true, 'AT_Opportunity_Line_Item', 1, '10', 299.0, 1, 1, 'Product');
        lineItems[0].Sub_type__c = 'Logistics Fee';
        insert lineItems;


        Test.startTest();
        oppQuoteList = UnitTestDataFactory.createOpportunityQuotes(opp2, 1, 'AT_Opportunity_Quote', 'Draft', 'test data', 100.45, 100.45, '', '', 0);
        insert oppQuoteList;
        Test.stopTest();

        Opportunity_Quote__c result = [Select id, status__c,Quote_type__c from Opportunity_Quote__c where id = :oppQuoteList[0].id];
        System.assertEquals('Draft',result.status__c);
        System.assertEquals('AT Quote Myam',result.Quote_type__c);
    }
    /**
       * @description #SSC-2815
       */
    @IsTest
    public static void testUpdateNationalIdOnContactPositive(){
        Account objAccount = [select id from Account where Recordtype.DeveloperName=:Constants.ACCOUNT_RT_TALABAT_ACCOUNT limit 1];
        Opportunity_Quote__c objOpprtyQuote = [select id,National_Id_Number__c,Id_Account__c,Id_Opportunity__c from Opportunity_Quote__c where Id_Account__c=:objAccount.id limit 1];

        Test.startTest();
        objOpprtyQuote.National_Id_Number__c ='123456';
        update objOpprtyQuote;
        Test.stopTest();
        Contact contactObj =ContactSelector.fetchContactsWithOwnerRole(new Set<Id>{objAccount.id})[0];
        System.assertEquals(objOpprtyQuote.National_Id_Number__c,contactObj.Passport_ID_Number__c);


    }
    /**
     * @description #SSC-2815
     */
    @IsTest
    public static void testUpdateNationalIdOnContactNegative(){
        Account objAccount = [select id from Account where Recordtype.DeveloperName=:Constants.ACCOUNT_RT_TALABAT_ACCOUNT limit 1];
        Opportunity_Quote__c objOpprtyQuote = [select id,National_Id_Number__c,Id_Account__c,Id_Opportunity__c from Opportunity_Quote__c where Id_Account__c=:objAccount.id limit 1];

        Test.startTest();
        Contact contactObj =ContactSelector.fetchContactsWithOwnerRole(new Set<Id>{objAccount.id})[0];
        System.assertNotEquals(objOpprtyQuote.National_Id_Number__c,contactObj.Passport_ID_Number__c);
        Test.stopTest();
    }
    /**
     * @description: Prod Coverage
     */
    @IsTest
    public static void testQuoteAcceptAndDecline(){
        Account objAccount = [select id from Account where Recordtype.DeveloperName=:Constants.ACCOUNT_RT_TALABAT_ACCOUNT limit 1];
        Opportunity objOpportuity = [select id,StageName from opportunity where RecordType.DeveloperName=:Constants.OPPORTUNITY_RT_TALABAT_OPPORTUNITY limit 1];
        objOpportuity.StageName =Constants.OPPORTUNITY_STAGE_QUALITY_CHECK_REQUEST;
        update objOpportuity;
        List<Opportunity_Quote__c> objOpprtyQuote = [select id,Id_Account__c,Id_Opportunity__c,Status__c from Opportunity_Quote__c where Status__c=:Constants.OPPORTUNITY_QUOTE_STATUS_DRAFT and  Id_Account__c=:objAccount.id limit 1];
        objOpprtyQuote[0].Status__c =Constants.OPPORTUNITY_QUOTE_STATUS_ACCEPTED;
        Opportunity_Quote_Line_Item__c oppLineItemObj = [select id,Id_List_Product_Price__c,id_opportunity__c,id_opportunity_quote__c,Sub_type__c from Opportunity_Quote_Line_Item__c limit 1];
        Test.startTest();
        update objOpprtyQuote;
        Test.stopTest();
        List<Tier__c> tierObj =[select id from Tier__c limit 1];
        System.assert(tierObj.isEmpty());
    }
    /**
     * @description: Prod Coverage
     */
    @IsTest
    public static void testOppTypeAndStageProcess(){
        Account objAccount = [select id from Account where Recordtype.DeveloperName=:Constants.ACCOUNT_RT_TALABAT_ACCOUNT limit 1];
        List<Opportunity_Quote__c> objOpprtyQuote = [select id,Id_Account__c,Id_Opportunity__c,Status__c,isReplacementQuote__c,Non_Standard_Contract_Components__c from Opportunity_Quote__c where Status__c=:Constants.OPPORTUNITY_QUOTE_STATUS_DRAFT and  Id_Account__c=:objAccount.id limit 1];

        Opportunity_Quote_Line_Item__c oppLineItemObj = [select id,Id_List_Product_Price__c,id_opportunity__c,id_opportunity_quote__c,Sub_type__c,OldOppQuoteLineId__c from Opportunity_Quote_Line_Item__c limit 1];
        oppLineItemObj.OldOppQuoteLineId__c =oppLineItemObj.id;
        update oppLineItemObj;
        Test.startTest();
        objOpprtyQuote[0].Status__c =Constants.OPPORTUNITY_QUOTE_STATUS_ACCEPTED;
        objOpprtyQuote[0].Non_Standard_Contract_Components__c =Constants.OPPORTUNITY_QUOTE_NON_STD_CONTRCT_COMP;
        objOpprtyQuote[0].isReplacementQuote__c=true;
        update objOpprtyQuote;
        Test.stopTest();
        Opportunity opptyObj =[select id,Non_Standard_Contract_Components__c from opportunity where AccountId=:objAccount.id limit 1];
        System.assertEquals(opptyObj.Non_Standard_Contract_Components__c,objOpprtyQuote[0].Non_Standard_Contract_Components__c );
    }
}
