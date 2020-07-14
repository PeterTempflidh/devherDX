@isTest
private class UnitTestClsAdditionalChargeProcessor {

    private static User testUser;
    private static Country__c country;
    private static Company__c company;
    private static List<Account> accounts;
    private static List<Opportunity> opportunities;
    private static List<Opportunity_Quote__c> quotes;
    private static List<List_Product_Group__c> productGroups;
    private static List<List_Product_Price__c> products;
    private static List<Asset__c> assets;
    private static List<Stock_Item__c>  stockItems;
    private static List<Additional_Charges__c> additionalCharges;
    private static List<Consignment__c> consignments;
    private static Business_Config__c businessConfig;
    private static RecordType testAdditionalChargesRecordType;

    static {
        UnitTestDataFactory.getRecordtypeValues();
        testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'yogiyouser@deliveryhero.com', 'Yogiyo', 'KR');
        insert testUser;
        List<Platform_Country__c> platformCountry =new List<Platform_Country__c>(); 
        platformCountry.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name='FOCPlatform', country__c='Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
        System.runAs(testUser){
      		
            PermissionSet ps = new PermissionSet();
            ps.Name = 'Test_Perm_Set';
            ps.Label = 'Test Perm Set';
            insert ps;
            SetupEntityAccess sea = new SetupEntityAccess();
            sea.ParentId = ps.Id;
            sea.SetupEntityId = [select Id from CustomPermission where DeveloperName = 'FP_Finance_Permissions' LIMIT 1].Id;
            insert sea;
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = UserInfo.getUserId();
            psa.PermissionSetId = ps.Id;
            insert psa;
            country = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            insert country;

            company = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', country);
            insert company;
 			testAdditionalChargesRecordType =  UnitTestDataFactory.getRecordType('FP_Additional_Charges');
            List<RecordType__c> customSettings = new List<RecordType__c>();
            customSettings.add(new RecordType__c(Name = testAdditionalChargesRecordType.Id,
                                                     Value__c = 'FP_Additional_Charges'));
			insert customSettings;
            productGroups = UnitTestDataFactory.createProductGroups(company, country, 10, 'Yogiyo_List_Product_Group');
            accounts = UnitTestDataFactory.createAccounts(1, country, 'Yogiyo_Account');
            businessConfig = UnitTestDataFactory.createBusinessConfig('Custom Report Settings', 'Process','createAdditionalChargeShadow','true', country.Id, 'Yogiyo_Additional_Charges', true, true);
            insert businessConfig;
            Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='API_Type',Business_Rule_Value__c='Flat Commission',Id_Country__c=country.id,Is_Active__c=true,Parent__c=true,Process_Name__c='FlatCommissionAddChargeTerminate',Record_Type_Id__c='Yogiyo_Additional_Charges',Type__c='Process');
            Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='EntryCase',Business_Rule_Value__c='RecordTypeId=012w00000006n25,OwnerId=00Gw0000001DBnk,type=0% Commission Entry,subject=Cancel the 0% Commission,status=New',Id_Country__c=country.id,Is_Active__c=true,Parent__c=false,Process_Name__c='FlatCommissionAddChargeTerminate',Record_Type_Id__c='Yogiyo_Additional_Charges',Type__c='Process');
            insert new List<sObject>{b1,b2}; 
            List<sObject> objectsToInsert = new List<sObject>();
            objectsToInsert.addAll((List<sObject>)productGroups);
            objectsToInsert.addAll((List<sObject>)accounts);
            //objectsToInsert.add((sObject)businessConfig);
            insert objectsToInsert;

            products = UnitTestDataFactory.createProducts(company, country, productGroups[0].Id, 10, 'Yogiyo_List_Product_Price', 1, true, 299, 1, true, 10);   
            opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'Yogiyo_Opportunity', Date.today().addMonths(2));
            List<sObject> objectsToInsert1 = new List<sObject>();
            objectsToInsert1.addAll((List<sObject>)products);
            objectsToInsert1.addAll((List<sObject>)opportunities);
            insert objectsToInsert1;

            quotes = UnitTestDataFactory.createOpportunityQuotes(opportunities[0], 1, 'Yogiyo_Opportunity_Quote', 'draft', 'TEST', 100, 100, 'Test', 'Test', 10);
            insert quotes;

            consignments = UnitTestDataFactory.createConsignments(1, false, 'Ordered', 'Other', 'trackingUrl');
            insert consignments;

            stockItems = UnitTestDataFactory.createStockItems(2,'Yogiyo_Stock_Item', accounts[0], consignments[0], 'A1 - New used', Date.today(), Date.today().addDays(10), Date.today().addDays(-30), '1234567890', '1234567890', 'Korea Telekom', 'Ordered', 'Other');
            insert stockItems;

            //assets = UnitTestDataFactory.createAssets(3,accList[0],oppList[0],Date.today().addDays(-10),true,null,null,'Yogiyo_Asset',18,'12345674', '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'Exchange Requested');
            assets = UnitTestDataFactory.createAssets(10, accounts[0], opportunities[0], Date.today().addDays(-10), true, stockItems[0], stockItems[1], 'Yogiyo_Asset', 
                '12345674', '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'Exchange Requested',
                Date.today().addDays(20), 'Yazi Logistics', '1234', 'Delivered to Warehouse');

            insert assets;

            additionalCharges = UnitTestDataFactory.createAdditionalCharges(accounts[0], assets[0], opportunities[0], quotes[0], products[0], productGroups[0], '100', 1, 100, 1, 100, 10, 'Yogiyo_Additional_Charges__c', null); 

        }
    }
    
    @isTest static void test_Insert() {
        Test.startTest();
            System.runAs(testUser){
                insert additionalCharges;
            }
        Test.stopTest();

        // Test the the additional charge shadow objects were created and the asset updated accordindly
        List<Additional_Charge_Shadow__c> acs = [SELECT Id, Additional_Charge__c, Ac_Name__c, AC_Total_Amount__c, AC_Termination_Date__c, AC_Termination_Reason__c, Account_Id__c, Account_Name__c, Account_Company_Number__c,Opportunity_Amount__c, Asset_Id__c, Asset_Name__c, StockItem_Id__c, StockItem_Name__c, StockItem_Simcard_Number__c FROM Additional_Charge_Shadow__c];
        List<Asset__c> updatedAsset = [SELECT Id, Additional_Charge_Shadow__c FROM Asset__c WHERE Id =: assets[0].Id];
        

        System.assertEquals(10, acs.size());
        System.assertEquals(acs[0].Additional_Charge__c, additionalCharges[0].Id);
        System.assertEquals(acs[0].Asset_Id__c, assets[0].Id);
        System.assertEquals(acs[0].Asset_Name__c, assets[0].Name);
        System.assertEquals(acs[0].StockItem_Id__c, stockItems[0].Id);
        System.assertEquals(acs[0].StockItem_Name__c, stockItems[0].Name);

        // Test that the asset got updated with the additional charge shadow Id
        System.assertNotEquals(updatedAsset[0].Additional_Charge_Shadow__c, acs[0].Id);
    }
    
    @isTest static void test_Update() {
        Test.startTest();
        List<SObject> objectsToUpdate = new List<SObject>();
            System.runAs(testUser){
                insert additionalCharges;
                assets[0].Name = 'Yogiyo Asset Updated';
                stockItems[0].Name = 'Yogiyo Stock Item Updated';
            }

            objectsToUpdate.add((sObject)assets[0]);
            objectsToUpdate.add((sObject)stockItems[0]);
            update objectsToUpdate;

            List<Additional_Charges__c> ac = [SELECT Id FROM Additional_Charges__c];
            update ac;
        Test.stopTest();

        List<Additional_Charge_Shadow__c> acs1 = [SELECT Id, Additional_Charge__c, Ac_Name__c, AC_Total_Amount__c, AC_Termination_Date__c, AC_Termination_Reason__c, Account_Id__c, Account_Name__c, Account_Company_Number__c,Opportunity_Amount__c, Asset_Id__c, Asset_Name__c, StockItem_Id__c, StockItem_Name__c, StockItem_Simcard_Number__c FROM Additional_Charge_Shadow__c];
            
        System.assertEquals(acs1[0].Asset_Name__c, 'Yogiyo Asset Updated');
        System.assertEquals(acs1[0].StockItem_Name__c, 'Yogiyo Stock Item Updated');

    }
    
    @isTest static void testPreventSelfApprovalMethod() {
        User usr = UnitTestDataFactory.createUser('System Administrator','test34335@deliveryhero.com','FP','HK');
        insert usr;

        System.runAs(new User(Id = Userinfo.getUserId())) {	
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'FP_HK_Finance_Permissions'];	
            PermissionSetAssignment psa = new PermissionSetAssignment();	
            psa.AssigneeId = usr.Id;	
            psa.PermissionSetId = ps.Id;	
            insert psa;	
        }
        
        System.runAs(usr){
        Test.startTest();          
        Additional_Charges__c addChargeToTestApprovalFlow = additionalCharges[0];
        insert addChargeToTestApprovalFlow;
        addChargeToTestApprovalFlow.Product__c = 'test product';
        addChargeToTestApprovalFlow.Product_Group__c = 'test group';
        addChargeToTestApprovalFlow.Type__c = 'Adjustment';
        addChargeToTestApprovalFlow.Status__c  = 'Draft';
        addChargeToTestApprovalFlow.RecordTypeId = testAdditionalChargesRecordType.Id;
        addChargeToTestApprovalFlow.Specifications__c = 'testSpecification';
        addChargeToTestApprovalFlow.Total_Amount__c = 100.00;
        addChargeToTestApprovalFlow.Start_Date__c = date.today().addDays(3);
        update addChargeToTestApprovalFlow;
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(addChargeToTestApprovalFlow.Id);
        app.setSubmitterId(UserInfo.getUserId());
        app.setProcessDefinitionNameOrId(ClsProcessDefinitionSelector.getApprovalProcessDefinitionLIKE('APAC_Standard_Approval_For_Add_Charges').DeveloperName);
        Approval.ProcessResult result = Approval.process(app);
        system.assert(result.isSuccess());       
        Approval.ProcessWorkitemRequest app2 = new Approval.ProcessWorkitemRequest();
		app2.setComments('Approving request.');
		app2.setAction('Approve');
		app2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        List<ProcessInstanceWorkitem> piw = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =:  additionalCharges[0].Id];
        if(!piw.isEMpty()){
	app2.setWorkitemId(piw[0].Id);
        Approval.ProcessResult result2;
        try {
            
        	result2 = Approval.process(app2);
        } catch (DmlException ex) {
            
           system.assert(ex.getMessage().contains(Label.Approval_Process_Self_Approval_Error));       
        }  
	}	
        Test.stopTest();        
    }
    }
    
}
