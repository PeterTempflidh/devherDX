@isTest
public class UnitTestCtrOpportunityLineItemsctr {
    private static Map<String, RecordType> mapRecordtypesKR = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Opportunity', 'Account', 'List_Product_Group__c', 'List_Product_Price__c', 'List_Service_Price__c', 'List_Add_On__c','Tarif__c', 'Tarif_Member__c', 'Tarif_Item__c', 'Opportunity_Line_Item__c'});
    
    @TestSetup
    public static void setUpData(){
        // create RecordType__c custom setting
        UnitTestDataFactory.getRecordtypeValues();	
        
        // create Country
        Country__c c = UnitTestDataFactory.createCountry('UK', 'United Kingdom', 'GBP');
	Country__c HKCoutry = UnitTestDataFactory.createCountry('HK','Hong Kong', 'HKD');
	insert new List<Country__c>{c,HKCoutry};
        
        // create company
        Company__c com = UnitTestDataFactory.createCompany('Hungryhouse', 'uk', c);
        insert com;

		//Inserting business config    
        
        Business_Config__c bc1 = UnitTestDataFactory.createBusinessConfig('nintexDocumentGeneration', 'Process','deliveryOptionName','Attachment', HKCoutry.id, 'FP_Opportunity', true, false);
        Business_Config__c bc2 = UnitTestDataFactory.createBusinessConfig('nintexDocumentGeneration', 'Process','docGenPackageName','Quotes', HKCoutry.id, 'FP_Opportunity', true, false);
        Business_Config__c bc3 = UnitTestDataFactory.createBusinessConfig('validationRules', 'Process','addressFieldsAdditionalCheck','<Type__c>Restaurant Address<Type__c>', HKCoutry.id, 'FP_Opportunity', true, false);
        Business_Config__c bc4 = UnitTestDataFactory.createBusinessConfig('validationRules', 'Process','accountFields','Name,Legal_Name__c,Vertical__c,Delivery_Service__c,Phone,Account_Email__c,Bank_Name__c,Bank_Account_Owner__c,Invoice_Frequency__c,Mark_up__c,Company_Number__c,Food_License_Number__c', HKCoutry.id, 'FP_Opportunity', true, false);
        Business_Config__c bc5 = UnitTestDataFactory.createBusinessConfig('validationRules', 'Process','contactFields','Contact_Role__c,FirstName,LastName,Phone,Email', HKCoutry.id, 'FP_Opportunity', true, false);
        Business_Config__c bc6 = UnitTestDataFactory.createBusinessConfig('validationRules', 'Process','addressFields','LatLng__c,Type__c,Translated_Street_Name__c,Translated_City_Name__c', HKCoutry.id, 'FP_Opportunity', true, false);
        Business_Config__c bc7 = UnitTestDataFactory.createBusinessConfig('validationRules', 'Process','accountFieldsAdditionalCheck','<Delivery_Service__c>Unknown<Delivery_Service__c>,<Vertical__c>Restaurant<Vertical__c>', HKCoutry.id, 'FP_Opportunity', true, false);
        Business_Config__c bc8 = UnitTestDataFactory.createBusinessConfig('validationRules', 'Process','contactFieldsAdditionalCheck','<Contact_Role__c>Owner<Contact_Role__c>', HKCoutry.id, 'FP_Opportunity', true, false);
        Business_Config__c bc9 = UnitTestDataFactory.createBusinessConfig('validationRules', 'Process','opportunityFields','List_Photo_Comments__c', HKCoutry.id, 'FP_Opportunity', true, false);
        Business_Config__c bc10 = UnitTestDataFactory.createBusinessConfig('validationRules', 'Process','opportunityFieldsAdditionalCheck','<Business_Type__c>Upgrade/Upsell,Downgrade<Business_Type__c>', HKCoutry.id, 'FP_Opportunity', true, false);
        Business_Config__c bc11 = UnitTestDataFactory.createBusinessConfig('validationRules', 'Process','bankFields','{"Payment_Method__c" : { "Bank Account" :["Bank_Account_Name__c", "Bank_Account_Number__c","Bank_Account_Owner__c"], "Mobile Wallet" : ["Bank_Account_Name__c"]}}', HKCoutry.id, 'FP_Opportunity', true, false);
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='OppQuoteEmailTemplate',Business_Rule_Value__c='UK_QuoteVFTemplate',Id_Country__c=c.id,Is_Active__c=true,Parent__c=true,Process_Name__c='OppQuoteProcess',Record_Type_Id__c='UK_Account',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='DeliverableEnable',Business_Rule_Value__c='TRUE',Id_Country__c=c.id,Is_Active__c=true,Parent__c=true,Process_Name__c='ShipmentOrders',Record_Type_Id__c='UK_Account',Type__c='Process');
        Business_Config__c b3 = UnitTestDataFactory.createBusinessConfig('nintexForChainOpp', 'Process','FP_Account','FP_Opportunity', HKCoutry.id, 'Chain_Opportunity', true, false);

        insert new List<Business_Config__c>{b1,b2,b3,bc1,bc2,bc3,bc4,bc5,bc6,bc7,bc8,bc9,bc10,bc11};
            
        // Create Accounts
        List<Account> lstAcc = new List<Account>();
        List<Account> lstFranchiseAcc = new List<Account>();
        
        Account acc = UnitTestDataFactory.createAccount('test',c,'UK_Account');
        lstAcc.add(acc);
        
        Account fpAcc = UnitTestDataFactory.createAccount('test',c,'FP_Account');
        fpAcc.Record_Country__c = 'Hong Kong';
        lstAcc.add(fpAcc);
        
        for(Integer i = 0; i < 6; i++){
            Account accX = UnitTestDataFactory.createAccount('test' + i,c,'UK_Account');
            lstAcc.add(accX);
        }

        for(Integer i = 0; i < 6; i++){
            Account accF = UnitTestDataFactory.createAccount('franchiseTest' + i,c,'UK_Account');
            lstFranchiseAcc.add(accF);
        }

        insert lstAcc;
        insert lstFranchiseAcc;

        for(Integer i = 0; i < lstAcc.size()-1; i++){
            lstAcc[i].ParentId = lstAcc[i+1].Id;
        }
        lstAcc[0].Franchise_connection__c = lstFranchiseAcc[0].Id;
        lstAcc[0].Franchise_Type__c = 'Indirectly managed';

        for(Integer i = 0; i < lstFranchiseAcc.size()-1; i++){
            lstFranchiseAcc[i].ParentId = lstFranchiseAcc[i+1].Id;
        }


        update lstAcc;
        update lstFranchiseAcc;
        
        //Inserting contacts
        List<Contact> contacts = UnitTestDataFactory.createContacts(lstAcc, 'test Lastname', 'test FirstName', 'Mr', 'Owner', 1, 'testme', 'FP_Contact');
        insert contacts;
        
        //INserting Address rec
        Integration_Config__c cs1 = new Integration_Config__c(
            Name = 'GoogleMapsSignature', Password__c = 'Abvcd-asdfdgfhjklhnO0=');
        insert cs1;
        
        AddressDetail__c addr = new AddressDetail__c(
            Type__c = 'Billing Address;Restaurant Address',
            LatLng__Longitude__s = 10.0,
            LatLng__Latitude__s = 5.0,
            Account__c = fpAcc.Id,
            
            GPA_Country_long_name__c = 'Ecuador',
            GPA_Country_short_name__c = 'EC',
            
            GPA_Admin_area_level_1_long_name__c = 'admin area 1 test',
            GPA_Admin_area_level_1_short_name__c = 'aat1',
            
            GPA_Locality_long_name__c = 'locality',
            GPA_Locality_short_name__c = 'lco',
            
            GPA_Route_long_name__c = 'street name',
            GPA_Route_short_name__c = 'str',
            
            GPA_Street_number_long_name__c = '10',
            GPA_Street_number_short_name__c = '10',
            
            GPA_Postal_code_long_name__c = '1010',
            GPA_Postal_code_short_name__c = '1010',
            
            GPA_Place_id__c = '12344',
            GPA_formatted_address__c = 'whatever bla bla',
            GPA_Was_modified_manually__c = false
        );
        
        insert addr;
        
        // Create Platform Perforance 
        Platform_Performance__c per = new Platform_performance__c();
        per.Account__c = acc.Id;
        per.Platform__c = 'hungryhouse';
        per.backend_id__c = '123';
        insert per;
        
        // Create commissions
        List<List_Service_price__c> commissions = UnitTestDataFactory.createServices(com, c, 3,'UK_List_Service_Price',12,12,16, 8, 1,'Commission Fee', 
                                                                                     true, 0,'','Percentage', 'Commission Fee');
        
        insert commissions;
        
        // Create Product Group
        List<List_Product_group__c> groups = UnitTestDataFactory.createProductGroups(Com, c, 1, 'UK_List_Product_Group');
        insert groups;
        
        // Create Products
        List<List_Product_price__c> products = UnitTestDataFactory.createProducts(com, c,groups[0].id, 2,'UK_List_Product_Price',
                                                                                  0, true, 100, 1, false,20);
        insert products;
        
        // Create Add Ons
        List<List_Add_On__c> addOns = UnitTestDataFactory.createAddOns(com,c,2,'UK_List_Add_On','test','Deal / Promotion',true);
        insert addOns;
        
        // Create Tarif
        Tarif__c t = new Tarif__c(Company__c = com.id, Id_Country__c = c.id, Is_Active__c = false, Name = 'testTarif1', RecordTypeId = mapRecordtypesKR.get('UK_Tarif').id);
        t.is_Locked__c 		= false;
        t.Product_only__c 	= false;
        t.categories__c 	= groups[0].name;
        insert t;
        t.Is_Active__c = true;
        update t;
        
        // create tarif Member
        List<Tarif_Member__c> members = new List<Tarif_Member__c>();
        for(List_Service_price__c comm :  commissions){
            Tarif_Member__c tm = new Tarif_Member__c(Id_Tarif_Item__c = comm.id, RecordTypeId = mapRecordtypesKR.get('UK_Tarif_Member').id, Tarif_Name__c = t.id, Type__c = 'Service');
            members.add(tm);
        }
        for(List_Product_price__c prod : products){
            Tarif_Member__c tm = new Tarif_Member__c(Id_Tarif_Item__c = prod.id, RecordTypeId = mapRecordtypesKR.get('UK_Tarif_Member').id, Tarif_Name__c = t.id, Type__c = 'Product');
            members.add(tm);
        }
        for(List_Add_On__c addOn : addOns){
            Tarif_Member__c tm = new Tarif_Member__c(Id_Tarif_Item__c = addOn.id, RecordTypeId = mapRecordtypesKR.get('UK_Tarif_Member').id, Tarif_Name__c = t.id, Type__c = 'AddOn');
            members.add(tm);
        }
        insert members;
        
        // Create Opportunity
        Opportunity opp = UnitTestDataFactory.createOpportunity('test',acc,'UK_Opportunity', Date.today());
        opp.Company_Code__c = 'UK';
        opp.Id_tarif__c = t.id;
        insert opp;
        
        Opportunity opp2 = UnitTestDataFactory.createOpportunity('test',fpAcc,'FP_Opportunity', Date.today());
        opp2.Company_Code__c = 'HK';
        opp2.Id_tarif__c = t.id;
        insert opp2;

        List<Account> accList= UnitTestDataFactory.createAccounts(1,HKCoutry,'FP_Account');
        accList[0].Type = 'Group';
        insert accList;
        
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(new List<Account>{accList[0]},1,'Chain_Opportunity',Date.today());
        insert oppList;
        
        
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
        
        // CREATE MIDAS CONF
        MidasIntegration__c conf = new MidasIntegration__c();
        conf.name = 'PP';
        conf.AuthenticationToken__c = '123';
        conf.EndPoint__c = 'https://www.eaxmple.com';
        conf.CountryBrand__c = '{"hungryhouse":"UKHH"}';
        insert conf;
        
        
        // Create premium placement product
        List_Product_Price__c premiumPlaceApiProd = new List_Product_price__c();
        premiumPlaceApiProd.Id_List_Product_Group__c = groups[0].Id;  
        premiumPlaceApiProd.Product_Name__c = 'Premium Placement API'; 
        premiumPlaceApiProd.RecordTypeId =  LibRecordTypeHelper.getRecordTypeValue('UK_List_Product_Price');
        premiumPlaceApiProd.List_price__c = 0;
        premiumPlaceApiProd.Default_Quantity__c	= 1;
        insert premiumPlaceApiProd;
        
        // create opportunity line items
        List<Opportunity_Line_item__c> lineItems = new List<Opportunity_line_Item__c>();
        lineItems.add(UnitTestDataFactory.createOpportunityLineItemProduct('test', opp,groups[0].id, products[0].id, true,'UK_Opportunity_Line_Item',0,'0', 100, 1, 100,'test'));
        LineItems.add(UnitTestDataFactory.createOpportunityLineItemService('test', opp, commissions[0].id,true,'UK_Opportunity_Line_Item', 12, 12, Date.today(), 'test', 0));
        insert lineItems;
        
        
        
        
            
        //CREATE DDP TEST DATA
        Loop__DDP__c ddp	= new Loop__DDP__c(Name='Quotes');
        insert ddp;
        
        Loop__DDP_Integration_Option__c	delivOpt = new Loop__DDP_Integration_Option__c(Name='Attachment',Loop__DDP__c=ddp.Id);    
        insert delivOpt;
        
    }
    
    @isTest
    public static void testWrapperPopulation(){
    	Opportunity opp		= [SELECT id, account.Backend_ID__c, CurrencyIsoCode, Company_Code__c, Record_Country__c,Id_Tarif__c,
		            				Country__c,accountId, RecordTypeId
		                        FROM Opportunity Limit 1];
		ApexPages.StandardController oppStd = new ApexPages.StandardController(opp);
    	Test.startTest();
    		CtrOpportunityLineItems controller = new CtrOpportunityLineItems(oppStd);
    		CtrOpportunityLineItems.TarifWrapper wrapper = CtrOpportunityLineItems.populateData(opp.id);
    		
    		System.assertEquals(1,wrapper.tarif.commissions.size());
    		System.assertEquals(1,wrapper.tarif.products.size());
    		System.assertEquals(0,wrapper.tarif.addOns.size());
    	Test.stopTest();
    }
    
    @isTest
    public static void testTarifChange(){
    	Opportunity opp		= [SELECT id, account.Backend_ID__c, CurrencyIsoCode, Company_Code__c, Record_Country__c,Id_Tarif__c,
		            				Country__c,accountId, Opportunity.RecordTypeId
		                        FROM Opportunity Limit 1];
		ApexPages.StandardController oppStd = new ApexPages.StandardController(opp);
		CtrOpportunityLineItems controller = new CtrOpportunityLineItems(oppStd);
		CtrOpportunityLineItems.TarifWrapper wrapper = CtrOpportunityLineItems.populateData(opp.id);
		wrapper.tarif.id = opp.Id_tarif__c;
		wrapper.tarifId  = opp.Id_tarif__c;
    	Test.startTest();
    		CtrOpportunityLineItems.TarifWrapper wrapper2 =  CtrOpportunityLineItems.popuateTarifDetails(JSON.serialize(wrapper));
    		CtrOpportunityLineItems.save(JSON.serialize(wrapper));
    		CtrOpportunityLineItems.createQuote(JSON.serialize(wrapper));
    		
    		System.assertEquals(3,wrapper2.tarif.commissions.size());
    		System.assertEquals(2,wrapper2.tarif.products.size());
    		System.assertEquals(2,wrapper2.tarif.addOns.size());
    	Test.stopTest();
    }

    @isTest
    public static void testAccountHierarchy(){
        Opportunity opp     = [SELECT id, account.Backend_ID__c, CurrencyIsoCode, Company_Code__c, Record_Country__c,Id_Tarif__c,
                                    Country__c,accountId, Opportunity.RecordTypeId
                                FROM Opportunity Limit 1];
        ApexPages.StandardController oppStd = new ApexPages.StandardController(opp);
        Test.startTest();
            CtrOpportunityLineItems controller = new CtrOpportunityLineItems(oppStd);
            CtrOpportunityLineItems.TarifWrapper wrapper = CtrOpportunityLineItems.populateData(opp.id);

            Integer y = 0;
            for(Integer i = 0; i < wrapper.billableAccountOptions.size(); i++){
                if(wrapper.billableAccountOptions[i].Label.startsWith(Label.FranchisePreIndex)){
                    y += 1;
                }  
            }

           // System.assertEquals(12, wrapper.billableAccountOptions.size());
            System.assertEquals(6, y);

        Test.stopTest();
    }
    
    @isTest
    public static void testGetPackageDetails(){
        Opportunity opp	= [SELECT id,RecordTypeId,Record_Country__c FROM Opportunity WHERE RecordType.developername = 'FP_Opportunity' Limit 1];
        
        //Inserting Opp quote
        Opportunity_Quote__c  oq = new Opportunity_Quote__c();
        oq.Id_Opportunity__c = opp.Id;
        insert oq;
        
        String retValue = CtrOpportunityLineItems.getPackageDetails(oq.Id, opp.RecordTypeId, opp.Record_Country__c);
        System.assert(retValue.startsWith('/apex/loop__looplus'), true);

        Opportunity oppChain	= [SELECT id,RecordTypeId,Record_Country__c FROM Opportunity WHERE RecordType.developername = 'Chain_Opportunity' Limit 1];
        
        //Inserting Opp quote
        Opportunity_Quote__c  oqChain = new Opportunity_Quote__c();
        oqChain.Id_Opportunity__c = oppChain.Id;
        insert oqChain;
        
        String retValueChain = CtrOpportunityLineItems.getPackageDetails(oqChain.Id, oppChain.RecordTypeId, oppChain.Record_Country__c);
        System.assert(retValueChain.startsWith('/apex/loop__looplus'), true);
    }
    
    @isTest
    public static void testValidate(){
        Opportunity opp	= [SELECT id,RecordTypeId,AccountId, Record_Country__c, Account.RecordTypeId FROM Opportunity WHERE RecordType.developername = 'FP_Opportunity' Limit 1];
        Opportunity chainOpp	= [SELECT id,RecordTypeId,AccountId, Record_Country__c, Account.RecordTypeId FROM Opportunity WHERE RecordType.developername = 'Chain_Opportunity' Limit 1];
        List<Bank_Detail__c> bankDetail1 = new List<Bank_Detail__c>();

        bankDetail1.add(new Bank_Detail__c(Account__c = opp.AccountId,
                Bank_Account_Number__c = '7674787367326736',
                Bank_Name__c = 'testBank',
                Bank_Account_Owner__c = 'Test User',
                Status__c = 'Active',  Activation_Date__c = System.today()));

        //SSC-1330
        insert bankDetail1;
        String retValue = CtrOpportunityLineItems.validate(opp);
        String retValueChain = CtrOpportunityLineItems.validate(chainOpp);
        
        System.assertNotEquals(retValue, 'No Error');
        System.assertEquals(retValueChain, 'No Error');
        
    }
    /*****
   * @description     : Test Class for AT Premium Placement
   * @param           : none
   */
    @isTest
    public static void testATPremiumPlacement(){
        User testUser = UnitTestDataFactory.createUser('AT Sales Team', 'unittestUser@deliveryhero.com', 'Mjam', 'AT');
        List<Opportunity_Quote__c> oppQuoteList;
        Country__c atCountry = UnitTestDataFactory.createCountry('AT','Austria', 'EUR');
        insert new List<Country__c>{atCountry};
        Company__c austriaCom = UnitTestDataFactory.createCompany('Mjam', 'AT', atCountry);
        insert austriaCom;

        Business_Config__c businessConfig1 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','Business_Type__c:Upgrade/Upsell;Type:Contract Only','AT Quote Myam', atCountry.id, 'AT_Opportunity', true, false);
        Business_Config__c businessConfig2 = UnitTestDataFactory.createBusinessConfig('nintexQuoteFilters', 'Process','checkCommissionTypes','Logistics Fee', atCountry.id, 'AT_Opportunity', true, false);
        Business_Config__c businessConfig3 = UnitTestDataFactory.createBusinessConfig('addOpportunityLineItems', 'Process','showATPremiumPlacementUI','false', atCountry.id, 'AT_Opportunity', true, false);
        Business_Config__c businessConfig4 = UnitTestDataFactory.createBusinessConfig('nintexQuoteAdditionalFilters', 'Process','Account.Name','Logistics Fee', atCountry.id, 'AT_Opportunity', true, false);

        insert new List<Business_Config__c>{businessConfig1,businessConfig2,businessConfig3,businessConfig4};
        UnitTestDataFactory.getRecordtypeValues();



        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(austriaCom, atCountry, 'test commsi', 'AT_List_Product_Group');
        insert lpg;

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(austriaCom, atCountry, 'test product price', lpg.id, 'AT_List_Product_Price', 1, true, 100, 1, false, 20);
        lpp.Displayed_Name__c = 'test comm';
        lpp.Requires_Additional_Charge__c = false;

        insert new List<List_Product_Price__c> {lpp};

        List<List_Service_Price__c> commissions = new List<List_Service_Price__c>();
        List_Service_Price__c lsp = UnitTestDataFactory.createService(austriaCom,atCountry,'testService1','AT_List_Service_Price',12,12,25,5,null,true,null,'Commission','Logistics Fee');
        commissions.add(lsp);
        insert commissions;
        // Create Tarif
        Tarif__c tarifObj = new Tarif__c(Company__c = austriaCom.id, Id_Country__c = atCountry.id, Is_Active__c = false, Name = 'Premium Placement', RecordTypeId = mapRecordtypesKR.get('AT_Tarif').id);
        tarifObj.is_Locked__c      = false;
        tarifObj.Product_only__c   = false;
        tarifObj.categories__c     = lpg.name;
        insert tarifObj;
        tarifObj.Is_Active__c = true;
        update tarifObj;

        // create tarif Member
        List<Tarif_Member__c> members = new List<Tarif_Member__c>();
        for(List_Service_price__c comm :  commissions){
            Tarif_Member__c tm = new Tarif_Member__c(Id_Tarif_Item__c = comm.id, RecordTypeId = mapRecordtypesKR.get('AT_Tarif_Member').id, Tarif_Name__c = tarifObj.id, Type__c = 'Service');
            members.add(tm);
        }
        insert members;

        Account austAcc = UnitTestDataFactory.createAccount('TEST', atCountry, 'AT_Account');
        austAcc.Type = 'Branch - main';
        insert austAcc;

        Opportunity opp2 = UnitTestDataFactory.createOpportunity('test',austAcc,'AT_Opportunity', Date.today());
        opp2.Company_Code__c = 'AT';
        opp2.Business_Type__c = 'Upgrade/Upsell';
        opp2.Type = 'Contract Only';
        opp2.Id_tarif__c = tarifObj.id;
        insert opp2;

        // create opportunity line items
        List<Opportunity_Line_item__c> lineItems = new List<Opportunity_line_Item__c>();
        lineItems.add(UnitTestDataFactory.createOpportunityLineItemProduct('test', opp2,lpg.id, lpp.id, true,'AT_Opportunity_Line_Item',0,'0', 100, 1, 100,'test'));
        LineItems.add(UnitTestDataFactory.createOpportunityLineItemService('test', opp2, commissions[0].id,true,'AT_Opportunity_Line_Item', 12, 12, Date.today(), 'test', 0));
        insert lineItems;

        ApexPages.StandardController oppStd = new ApexPages.StandardController(opp2);
        Test.startTest();
        Opportunity oppObj = [SELECT id, account.Backend_ID__c, CurrencyIsoCode, Company_Code__c, Record_Country__c,Id_Tarif__c,
                Country__c,accountId, Opportunity.RecordTypeId
        FROM Opportunity where Id=:opp2.id Limit 1];
            CtrOpportunityLineItems controller = new CtrOpportunityLineItems(oppStd);
            CtrOpportunityLineItems.TarifWrapper wrapper = CtrOpportunityLineItems.populateData(oppObj.id);
            wrapper.tarif.id = oppObj.Id_tarif__c;
            wrapper.tarifId  = oppObj.Id_tarif__c;
            CtrOpportunityLineItems.TarifWrapper wrapper2 =  CtrOpportunityLineItems.popuateTarifDetails(JSON.serialize(wrapper));
            CtrOpportunityLineItems.save(JSON.serialize(wrapper));
            //System.assertEquals(1,wrapper2.tarif.commissions.size());
            System.assertEquals('Austria',oppObj.Record_Country__c);
        Test.stopTest();

    }
}
