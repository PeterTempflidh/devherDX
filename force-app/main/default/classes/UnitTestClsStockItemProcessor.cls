@isTest
private class UnitTestClsStockItemProcessor {
    private static User testUser_KR;
    private static Country__c country;
    private static Country__c country_KR;
    private static Company__c company;
    private static Company__c company_KR;


    static {
        UnitTestDataFactory.getRecordtypeValues();
        Platform_Country__c pt1 = new Platform_Country__c(name='FOCPlatform',Country__c='Lebanon,Qatar,United Arab Emirates');
        Platform_Country__c pt2 = new Platform_Country__c(name='TalabatPlatform',Country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates');
        insert new List<sObject>{pt1,pt2};
        country = UnitTestDataFactory.createCountry('AU', 'Australia', 'AUD');
        insert country;

        company = UnitTestDataFactory.createCompany('DH_AU', 'Australia', country);
        insert company;

        List<Account> accts = UnitTestDataFactory.createAccounts(2, country, 'DH_AU_Account');
        insert accts;

        accts[0].Restaurant_Name__c = 'Test AU Account_0';
        accts[1].Restaurant_Name__c = 'Test AU Account_1';
        update accts;
        //Test Account_' + i,

        Opportunity opp = UnitTestDataFactory.createOpportunity('TestOpp123',accts[0],'DH_AU_Opportunity',Date.today());
        insert opp;


        Stock_Item__c stockItem = new Stock_Item__c(RecordTypeId= UnitTestDataFactory.getRecordType('DH_AU_Stock_Item').Id,Name = '123456_AU');
        insert stockItem;

        Stock_Item__c stockItem2 = new Stock_Item__c(RecordTypeId= UnitTestDataFactory.getRecordType('DH_AU_Stock_Item').Id,Name = '654321_AU');
        insert stockItem2;

        Stock_Item__c stockItem3 = new Stock_Item__c(RecordTypeId= UnitTestDataFactory.getRecordType('DH_AU_Stock_Item').Id,Name = '08154711_AU');
        insert stockItem3;



        Asset__c asset = new Asset__c(Name='TestAsset_AU', Account__c = accts[0].Id, Stock_Item__c = stockItem.Id, RecordTypeId = UnitTestDataFactory.getRecordType('DH_AU_Asset').Id);
        insert asset;

        Asset__c asset2 = new Asset__c(Name='TestAsset_AU_2', Account__c = accts[1].Id, Replaced_Stock_Item__c= stockItem3.Id, RecordTypeId = UnitTestDataFactory.getRecordType('DH_AU_Asset').Id);
        insert asset2;
    }
    
    static {
        testUser_KR = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'yogiyounittestuser@deliveryhero.com', 'Yogiyo', 'KR');
        insert testUser_KR;

        System.runAs(testUser_KR){
            country_KR = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            insert country_KR;

            company_KR = UnitTestDataFactory.createCompany('Yogiyo', 'Korea', country_KR);
            insert company_KR;
            
            Business_Config__c b1_kr = new Business_Config__c(Business_Rule_Name__c='fieldsToCopy',Business_Rule_Value__c='Return_Due_Date__c,Returning_Stock_Item_Serial_No__c,Number_of_Retours__c,Retour_Date__c,Retour_Shipping_Company__c,Retour_Tracking_Number__c,Return_Status__c,Returned_Reason__c',Id_Country__c=country_KR.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='ReturningStockItemProcess',Record_Type_Id__c='Yogiyo_Asset',Type__c='Process');
            insert b1_kr;
            
            List<Account> accts = UnitTestDataFactory.createAccounts(2, country_KR, 'Yogiyo_Account');
            insert accts;

            accts[0].Restaurant_Name__c = 'Test KR Account_0';
            accts[1].Restaurant_Name__c = 'Test KR Account_1';
            update accts;
            //Test Account_' + i,

            Opportunity opp = UnitTestDataFactory.createOpportunity('TestOpp123',accts[0],'Yogiyo_Opportunity',Date.today());
            insert opp;


            Stock_Item__c stockItem = new Stock_Item__c(RecordTypeId= UnitTestDataFactory.getRecordType('Yogiyo_Stock_Item').Id,Name = '123456_KR');
            insert stockItem;

            Stock_Item__c stockItem2 = new Stock_Item__c(RecordTypeId= UnitTestDataFactory.getRecordType('Yogiyo_Stock_Item').Id,Name = '654321_KR');
            insert stockItem2;
            
            Stock_Item__c stockItem3 = new Stock_Item__c(RecordTypeId= UnitTestDataFactory.getRecordType('Yogiyo_Stock_Item').Id,Name = '08154711_KR');
            insert stockItem3;



            Asset__c asset = new Asset__c(Name='TestAsset_KR', Account__c = accts[0].Id, Stock_Item__c = stockItem.Id, RecordTypeId = UnitTestDataFactory.getRecordType('Yogiyo_Asset').Id);
            insert asset;
            
            Asset__c asset2 = new Asset__c(Name='TestAsset_KR_2', Account__c = accts[1].Id, Replaced_Stock_Item__c= stockItem3.Id, RecordTypeId = UnitTestDataFactory.getRecordType('Yogiyo_Asset').Id);
            insert asset2;

        }
    }

    @isTest static void trackAccountOnStockItem_Insert() {
        Test.startTest();

        Stock_Item__c item = [SELECT Id,Restaurant_Name__c FROM Stock_Item__c WHERE Name = '123456_AU'];

        Test.stopTest();

        System.assertEquals('Test AU Account_0',item.Restaurant_Name__c);


    }
    
    @isTest static void trackAccountOnStockItem_Update() {
        Stock_Item__c item = [SELECT Id,Restaurant_Name__c FROM Stock_Item__c WHERE Name = '654321_AU'];
        Asset__c asset = [SELECT Stock_Item__c FROM Asset__c WHERE Name = 'TestAsset_AU'];
        Test.startTest();
        asset.Stock_Item__c = item.Id;
        update asset;
        Test.stopTest();

        item = [SELECT Restaurant_Name__c FROM Stock_Item__c WHERE Id=: item.id];

        System.assertEquals('Test AU Account_0',item.Restaurant_Name__c);
    }
    
    @isTest static void setStockItemSerialNumberOnAsset_Insert(){
        Test.startTest();
        Stock_Item__c item = [SELECT Id, Name FROM Stock_Item__c WHERE Name = '123456_AU'];
        Asset__c asset = [SELECT Stock_Item__c, Stock_Item_Serial_No__c FROM Asset__c WHERE Name = 'TestAsset_AU'];
        Test.stopTest();
        
        System.assertEquals(item.Name, asset.Stock_Item_Serial_No__c);
        
    }
    
    @isTest static void setStockItemSerialNumberOnAsset_Update(){
        Test.startTest();
        Stock_Item__c item = [SELECT Id, Name FROM Stock_Item__c WHERE Name = '654321_AU'];
        Asset__c asset = [SELECT Stock_Item__c, Stock_Item_Serial_No__c FROM Asset__c WHERE Name = 'TestAsset_AU'];
        asset.Stock_Item__c = item.Id;
        update asset;
        Test.stopTest();
        
        asset = [SELECT Stock_Item__c, Stock_Item_Serial_No__c FROM Asset__c WHERE Name = 'TestAsset_AU'];        
        System.assertEquals(item.Name, asset.Stock_Item_Serial_No__c);
        
    }
    
    
    
    @isTest static void setStockItemSerialNumberOnAsset_Update_Remove(){
        Test.startTest();
        Stock_Item__c item = [SELECT Id, Name FROM Stock_Item__c WHERE Name = '654321_AU'];
        Asset__c asset = [SELECT Stock_Item__c, Stock_Item_Serial_No__c FROM Asset__c WHERE Name = 'TestAsset_AU'];
        asset.Stock_Item__c = item.Id;
        update asset;
        
        asset = [SELECT Stock_Item__c, Stock_Item_Serial_No__c FROM Asset__c WHERE Name = 'TestAsset_AU'];
        System.assertEquals(item.Name, asset.Stock_Item_Serial_No__c);
        
        asset.Stock_Item__c = null;
        update asset;
        Test.stopTest();
        
        asset = [SELECT Stock_Item__c, Stock_Item_Serial_No__c FROM Asset__c WHERE Name = 'TestAsset_AU'];
        System.assertNotEquals(null, asset.Stock_Item_Serial_No__c);
        
    }

    @isTest static void resetRestaurantsNameOnStockItem_Update() {
        Stock_Item__c item = [SELECT Id,Restaurant_Name__c FROM Stock_Item__c WHERE Name = '654321_AU'];
        Asset__c asset = [SELECT Stock_Item__c FROM Asset__c WHERE Name = 'TestAsset_AU'];
        Test.startTest();
        asset.Stock_Item__c = item.Id;
        update asset;
        
        item = [SELECT Restaurant_Name__c, Status__c FROM Stock_Item__c WHERE Id=: item.id];
        item.Status__c = 'In Stock';
        update item;
        
        Test.stopTest();
        
        item = [SELECT Restaurant_Name__c, Status__c FROM Stock_Item__c WHERE Id=: item.id];
        System.assertEquals(null,item.Restaurant_Name__c);
    }
}