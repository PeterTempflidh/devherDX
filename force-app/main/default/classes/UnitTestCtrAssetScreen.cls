@isTest
private class UnitTestCtrAssetScreen {
    private static User testUser;
    private static Country__c country;
    private static List<Account> accounts;
    private static List<Opportunity> opportunities;
    private static List<Asset__c> assets;
    private static List<Stock_Item__c> stockItems;
    private static List<Consignment__c> consignments;
    private static Asset__c assetUK;
    private static List_Product_Price__c lpp;
    private static List_Product_Price__c lpp1;

    
    
    static {
        UnitTestDataFactory.getRecordtypeValues();
        testUser = UnitTestDataFactory.createUser('Yogiyo Customer Care Management', 'yogiyouser@deliveryhero.com', 'Yogiyo', 'KR');

        insert new List<sObject>{testUser};
        List<Platform_Country__c> platformCountry =new List<Platform_Country__c>(); 
        platformCountry.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name='FOCPlatform', country__c='Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
        country = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        Country__c countryUK = UnitTestDataFactory.createCountry('UK', 'United Kingdom', 'GBP');
            insert new List<sObject>{country,countryUK};

            Company__c com = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', country);
            Company__c comUK = UnitTestDataFactory.createCompany('Hungryhouse', 'UK', countryUK);

        Business_Config__c q1 = UnitTestDataFactory.createBusinessConfig('AssetScreenProcess', 'Process','AssetCancellationFieldSet','Yogiyo_fields', country.id, 'Yogiyo_Asset', true, true);
        Business_Config__c qq1 = UnitTestDataFactory.createBusinessConfig('AssetScreenProcess', 'Process','AssetCancellationFieldSet','UK_fields', countryUK.id, 'UK_Asset', true, true);
        Business_Config__c qq2 = UnitTestDataFactory.createBusinessConfig('AssetScreenProcess', 'Process','UpdateAssetStatusForRP','Waiting For Replacement', countryUK.id, 'UK_Asset', true, false);
        insert new List<sObject>{q1,qq1,qq2,com,comUK};
        System.runAs(testUser){
            

            consignments = UnitTestDataFactory.createConsignments(1, false, 'Ordered', 'Other', 'trackingUrl');
            accounts = UnitTestDataFactory.createAccounts(1, country, 'Yogiyo_Account');

            List<sObject> objectsToInsert1 = new List<sObject>();
            objectsToInsert1.addAll((List<sObject>)accounts);
            insert objectsToInsert1;

            stockItems = UnitTestDataFactory.createStockItems(2,'Yogiyo_Stock_Item', accounts[0], consignments[0], 'A1 - New used', Date.today(), Date.today().addDays(10), Date.today().addDays(-30), '1234567890', '1234567890', 'Korea Telekom', 'Ordered', 'Other');
            opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'Yogiyo_Opportunity', Date.today().addMonths(2));
            
            List<sObject> objectsToInsert2 = new List<sObject>();
            objectsToInsert2.addAll((List<sObject>)stockItems);
            objectsToInsert2.addAll((List<sObject>)opportunities);
            insert objectsToInsert2;

            assets = UnitTestDataFactory.createAssets(10, accounts[0], opportunities[0], Date.today().addDays(-10), true, stockItems[0], stockItems[1], 'Yogiyo_Asset',
                    '12345674', '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'Exchange Requested',
                    Date.today().addDays(20), 'Yazi Logistics', '1234', 'Delivered to Warehouse');
            
            insert assets;

            
        }
        List<Account> accountsUK = UnitTestDataFactory.createAccounts(1, countryUK, 'UK_Account');
        insert accountsUK;
        List<Opportunity> opportunitiesUK = UnitTestDataFactory.createOpportunities(accountsUK, 1, 'UK_Opportunity', Date.today().addMonths(2));
        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,countryUK,'Replacement','UK_List_Product_Group');
        insert opportunitiesUK;
        assetUK = new Asset__c(
                Name = 'Test_Asset_UK',
                Account__c = accounts[0].Id,
                Opportunity__c = opportunitiesUK[0].Id,
                Is_Active__c = true,
                Status__c = 'New - Awaiting Shipping',
                RecordtypeId = UnitTestDataFactory.mapRecordtypes.get('UK_Asset').Id
                );
        insert new List<sObject>{assetUK,lpg};

        lpp = UnitTestDataFactory.createProduct(comUK,countryUK,'Replace3G',lpg.id,'UK_List_Product_Price',1,true,100,1,false,20);
        lpp.Requires_Replacement__c = true;
        lpp.Requires_Additional_Charge__c = true;        
        lpp1 = UnitTestDataFactory.createProduct(comUK,countryUK,'ReplaceLiveLink',lpg.id,'UK_List_Product_Price',1,true,100,1,false,null);
        lpp1.Requires_Replacement__c = true;
        lpp1.Requires_Additional_Charge__c = true;  
        insert new List<sObject>{lpp,lpp1};

    }
    static testmethod void UnitTest1(){
        Asset__c ast = [select id,name,Account__c,Opportunity__c,Is_Active__c,Status__c,RecordtypeId,RecordType.developername,Number_of_Returns__c,Retour_Date__c,
        Opportunity__r.Company_Code__c,Opportunity__r.StageName,Opportunity__r.CurrencyIsoCode,Date_Shipped__c,Tracking_Number__c,Number_of_Retours__c,Retour_Status__c,
        Returned_Date__c,Returned_Reason__c,Shared_Information__c,Takeover_Information__c,Return_Due_Date__c,Retour_Tracking_Number__c,Return_Status__c   
        from Asset__c where id=:assets[0].Id];
        Test.startTest();
        System.runAs(testUser){
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(ast);
            CtrAssetScreen ctrl = new CtrAssetScreen(stdCtrl);
            List<Schema.FieldSetMember> dd = ctrl.fields_Asset_Can_AU;
            ctrl.switchToEditMode();
            ctrl.switchToViewMode();
            ctrl.switchToLockMode();
            ctrl.saveDetails();
            ctrl.refreshPage();
        }
        Test.stopTest();
    }


    static testmethod void UnitTest2(){
        Asset__c ast = [select id,name,Account__c,Opportunity__c,Is_Active__c,Status__c,RecordtypeId,RecordType.developername,Opportunity__r.Company_Code__c,Opportunity__r.StageName,Opportunity__r.CurrencyIsoCode from Asset__c where id=:assetUK.Id];
        System.debug('ast: '+ast);
        Test.startTest();
        System.currentPageReference().getParameters().put('products',lpp.id+','+lpp1.id+'#::#Defective');
        //System.currentPageReference().getParameters().put('Id',ast.id);
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(ast);
        CtrAssetScreen ctrl = new CtrAssetScreen(stdCtrl);
        String pp = ctrl.products;
        Boolean dd = ctrl.showRelatedSection;
        String productItems = ctrl.productItems;
        ctrl.switchToEditMode();
        ctrl.switchToViewMode();
        ctrl.switchToLockMode();
        ctrl.assetReplacement();
        Test.stopTest();
    }

    static testmethod void UnitTest3(){
        Asset__c ast = [select id,name,Account__c,Opportunity__c,Is_Active__c,Status__c,RecordtypeId,RecordType.developername,Opportunity__r.Company_Code__c,Opportunity__r.StageName,Opportunity__r.CurrencyIsoCode from Asset__c where id=:assetUK.Id];
        System.debug('ast: '+ast);
        Test.startTest();
        System.currentPageReference().getParameters().put('products',lpp.id+'#::#Defective#::#sdfsdf sdfsd fdsfsdfsdfsdfdsfsfsd');
        //System.currentPageReference().getParameters().put('Id',ast.id);
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(ast);
        CtrAssetScreen ctrl = new CtrAssetScreen(stdCtrl);
        String pp = ctrl.products;
        Boolean dd = ctrl.showRelatedSection;
        String productItems = ctrl.productItems;
        ctrl.assetReplacement();
        Test.stopTest();
    }
}