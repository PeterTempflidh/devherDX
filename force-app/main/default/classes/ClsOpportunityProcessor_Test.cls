/**
* @author Mantas Jurkunas
* @date 15.03.2019
*
* @description Test class for ClsCaseProcessor
*/
@IsTest
private class ClsOpportunityProcessor_Test {
    
    @testSetup 
    static void setup() {
        Country__c hk = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'HKD');
        Database.insert(hk);
        Company__c com = UnitTestDataFactory.createCompany('Foodpanda Hong Kong', 'FP', hk);
        insert com;
         // CREATE BUSINESS CONFIGS
        List<Business_Config__c> businessConfigList = new List<Business_Config__c>();
        //SSC-1744
        businessConfigList.add(UnitTestDataFactory.createBusinessConfig(
                'nintexForChainOpp', 'Process','Business_Type__c', 'Legal Form Change,New Business,Win Back,Owner Change', hk.Id, 'Chain_Opportunity,FP_Opportunity', true, true));
        businessConfigList.add(UnitTestDataFactory.createBusinessConfig(
                'nintexForChainOpp', 'Process','StageName', 'Editorial Queue', hk.Id, 'Chain_Opportunity,FP_Opportunity', true, false));
        businessConfigList.add(UnitTestDataFactory.createBusinessConfig(
                'nintexForChainOpp', 'Process','FP_Account', 'FP_Opportunity', hk.Id, 'Chain_Opportunity,FP_Opportunity', true, false));
        businessConfigList.add(UnitTestDataFactory.createBusinessConfig(
                'nintexForChainOpp', 'Process','FP_Account', 'FP_Opportunity', hk.Id, 'Chain_Opportunity,FP_Opportunity', true, false));
        insert businessConfigList;
    }
    //validateOpportunityOnClosedWon

    /**
     * @description Test if the quality check case is created successfully
     * //@Ticket #           : SSC-1214
     */
    @IsTest
    public static void test_createQualityCheckCase() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c cd = UnitTestDataFactory.createCountry('CD', 'Colombia', 'COP');
        insert cd;
        Account acco = UnitTestDataFactory.createAccount('TEST', cd, 'CD_Account');
        acco.Type = 'Branch - main';
        insert acco;
        Opportunity oppt = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'CD_Opportunity', Date.today());
        oppt.Business_Type__c = 'New Business';
        Opportunity oppt2 = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'CD_Opportunity', Date.today());
        oppt2.Business_Type__c = 'New Business';
        insert new List<Opportunity>{oppt, oppt2};
        Case acase = UnitTestDataFactory.createCase(acco, 'New', 'Quality Check', '', '', cd, 'CD_Entry_Case', '');
        acase.Stage_1_Completed__c = true;
        acase.Opportunity__c = oppt.Id;
        acase.Closed_Reason__c = 'Take Online';

        Case acase1 = UnitTestDataFactory.createCase(acco, 'Please Check', 'Quality Check', '', '', cd, 'CD_Entry_Case', '');
        acase1.Opportunity__c = oppt2.Id;
        acase1.Closed_Reason__c = 'Take Online';

        List<Case> caseList = new List<Case>{acase, acase1};
        insert caseList;

        Business_Config__c businessConfig0_1 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process','validAccountForSecondStage', acco.Type, cd.Id, 'CD_Opportunity', true, true );
        Business_Config__c businessConfig0_2 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process','validOppBusinessTypeForSecondStage', oppt.Business_Type__c, cd.Id, 'CD_Opportunity', true, false );
        Business_Config__c businessConfig0_3 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process', 'assignmentMap', '{"Germany":"00G1r000003JwK5","Bahrain":"00Gw00000034PPe","Colombia":"00Gw00000034PPe","Kuwait":"00Gw00000034PPe","Lebanon":"00Gw00000034PPe","Oman":"00Gw00000034PPe","Qatar":"00Gw00000034PPe","Kingdom of Saudi Arabia":"00Gw00000034PPe","United Arab Emirates":"00Gw00000034PPe","Jordan":"00Gw00000034PPe"}', cd.Id, 'CD_Opportunity', true, false );
        Business_Config__c businessConfig0_4 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process', 'recordTypeMap', '{"Germany":"0121r000000V9wh","Bahrain":"012w0000000MPceAAG","Colombia":"012w0000000MPceAAG","Lebanon":"012w0000000MPceAAG","Oman":"012w0000000MPceAAG","Qatar":"012w0000000MPceAAG","Kingdom of Saudi Arabia":"012w0000000MPceAAG","United Arab Emirates":"012w0000000MPceAAG","Jordan":"012w0000000MPceAAG"}', cd.Id, 'CD_Opportunity', true, false );
        Business_Config__c businessConfig0_5 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process','QualityCheckCaseSecondStage', 'RecordTypeId=012w0000000MPce,Type=Quality Check,subject=Quality Check,status=Operation Check,ownerid=00Gw00000034QshEAE', cd.Id, 'CD_Opportunity', true, true );
        Map<String, Business_Config__c> bconfMap_1 = new Map<String, Business_Config__c>{businessConfig0_1.Business_Rule_Name__c => businessConfig0_1, businessConfig0_2.Business_Rule_Name__c => businessConfig0_2, businessConfig0_3.Business_Rule_Name__c => businessConfig0_3, businessConfig0_4.Business_Rule_Name__c => businessConfig0_4, businessConfig0_5.Business_Rule_Name__c => businessConfig0_5};
        Map<String, Map<String, Business_Config__c>> bconfMap_1f = new Map<String, Map<String, Business_Config__c>>{'CD_Opportunity' => bconfMap_1};
        ClsOpportunityProcessor.moam = new Map<String, Map<String, Map<String, Business_Config__c>>>{businessConfig0_1.Process_Name__c => bconfMap_1f};

        Case case0 = (Case) ClsOpportunityProcessor.createQualityCheckCase(oppt,caseList, acco);
        Case case1 = (Case) ClsOpportunityProcessor.createQualityCheckCase(oppt2,caseList, acco);

        System.assert(case0 != null);
        System.assert(case1 != null);

        System.assertEquals('Operation Check', case0.Status);
        System.assertEquals('Quality Check', case1.Type);
        System.assertEquals('00Gw00000034PPe', case0.OwnerId);
        System.assertEquals('00Gw00000034PPe', case1.OwnerId);
        System.assertEquals('012w0000000MPceAAG', case0.RecordTypeId);
        System.assertEquals('012w0000000MPceAAG', case1.RecordTypeId);
    }

    /**
     * @description Test if callout to MiDAS can be made successfully
     */
    @IsTest
    public static void test_updateBookingsStatusInMidas() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c cd = UnitTestDataFactory.createCountry('CD', 'Colombia', 'COP');
        insert cd;

        Account acco = UnitTestDataFactory.createAccount('TEST', cd, 'CD_Account');
        acco.Type = 'Branch - main';
        insert acco;

        Company__c com_cd = UnitTestDataFactory.createCompany('ClickDelivery', 'CD', cd);
        insert com_cd;

        Tarif__c t = UnitTestDataFactory.createTarif(com_cd, cd, 'Premium Placement', 'CD_Tarif', false);
        insert t;

        Opportunity oppt = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'CD_Opportunity', Date.today());
        oppt.Business_Type__c = 'New Business';
        oppt.Id_Tarif__c = t.ID;
        Opportunity oppt2 = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'CD_Opportunity', Date.today());
        oppt2.Business_Type__c = 'New Business';
        oppt2.Id_Tarif__c = t.ID;
        List<Opportunity> oppList = new List<Opportunity>{oppt, oppt2};
        insert oppList;

        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com_cd,cd,'Apple','Yogiyo_List_Product_Group');
        insert lpg;

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com_cd,cd,'Ipad 4 Gen. 16GB',lpg.id,'Yogiyo_List_Product_Price',1,true,100,1,false,20);
        insert lpp;

        List<Opportunity_Line_Item__c> lineItems = UnitTestDataFactory.createOpportunityLineItems(oppt,lpg.id, lpp.id, 3, true, 'Yogiyo_Opportunity_Line_Item',1, '10', 299.0, 1, 1, 'Product');
        integer bID = 1;
        for(Opportunity_Line_Item__c lineItem: lineItems) {
            bID = bID + 1;
            lineItem.Booking_Api_Id__c = '123' + bID;
        }
        insert lineItems;

        CountryCompanyBrand__c config = new CountryCompanyBrand__c();
        config.Name = 'ClickDelivery';
        config.Code__c = 'UKHH';
        insert config;

        List<MidasIntegration__c> midasIntg = new List<MidasIntegration__c>();
        midasIntg.add(new MidasIntegration__c(name = 'PP', EndPoint__c = 'http://midas.medusa-hero.com/backend/', AuthenticationToken__c = 'WyI0IiwiYzUwNjRkMmQ2MWUwNTE3YjVhNjRmMTk4Yjc2NmFiODgiXQ.CgtJbA.kFY4BLsKd3XXiXg7QtVxmLqZ7i0', countrybrand__c='{"United Kingdom":"UKHH", "Kuwait":"KWTB"}'));
        insert midasIntg;

        Test.setMock(HttpCalloutMock.class, new UnitTestDataFactory.MockHttpResponseGenerator());
        Test.startTest();
            ClsOpportunityProcessor.updateBookingsStatusInMidas(new Map<Id, Opportunity>(oppList), new Map<Id, Opportunity>(oppList));
        Test.stopTest();
    }

    @IsTest
    public static void test_checkForAssets() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c cd = UnitTestDataFactory.createCountry('CD', 'Colombia', 'COP');
        insert cd;
        Account acco = UnitTestDataFactory.createAccount('TEST', cd, 'CD_Account');
        acco.Type = 'Branch - main';
        insert acco;
        Opportunity oppt = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'CD_Opportunity', Date.today());
        oppt.Business_Type__c = 'New Business';
        Opportunity oppt2 = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'CD_Opportunity', Date.today());
        oppt2.Business_Type__c = 'New Business';
        insert new List<Opportunity>{oppt, oppt2};
        Case acase = UnitTestDataFactory.createCase(acco, 'New', 'Quality Check', '', '', cd, 'CD_Entry_Case', '');
        acase.Stage_1_Completed__c = true;
        acase.Opportunity__c = oppt.Id;
        acase.Closed_Reason__c = 'Take Online';

        Case acase1 = UnitTestDataFactory.createCase(acco, 'Please Check', 'Quality Check', '', '', cd, 'CD_Entry_Case', '');
        acase1.Opportunity__c = oppt2.Id;
        acase1.Closed_Reason__c = 'Take Online';

        List<Case> caseList = new List<Case>{acase, acase1};
        insert caseList;

        Business_Config__c businessConfig0_1 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process','exceptionStatuses', 'Error', cd.Id, 'CD_Opportunity', true, true );
        Business_Config__c businessConfig0_2 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process','activeStatuses', 'New', cd.Id, 'CD_Opportunity', true, false );
        Map<String, Business_Config__c> bconfMap_1 = new Map<String, Business_Config__c>{businessConfig0_1.Business_Rule_Name__c => businessConfig0_1, businessConfig0_2.Business_Rule_Name__c => businessConfig0_2};
        Asset__c asset = new Asset__c( Status__c = 'New');
        Asset__c asset2 = new Asset__c( Status__c = 'Old');
        System.assertEquals(true, ClsOpportunityProcessor.checkForAssets(new List<Asset__c>(), bconfMap_1));
        System.assertEquals(true, ClsOpportunityProcessor.checkForAssets(new List<Asset__c>{asset}, bconfMap_1));
        System.assertEquals(false, ClsOpportunityProcessor.checkForAssets(new List<Asset__c>{asset2}, bconfMap_1));
    }

    @IsTest
    public static void test_updateBookingStatusesInMidas() {

        UnitTestDataFactory.getRecordtypeValues();
        Country__c beh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        insert beh;

        Account acco = UnitTestDataFactory.createAccount('TEST', beh, 'Talabat_Account');
        acco.Type = 'Branch - main';
        acco.Backend_ID__c = '83G63';
        insert acco;
        List<account> accountlist = new List<account>();
        accountlist.add(acco);

        list<Contact> contacts = UnitTestDataFactory.CreateContacts(accountlist, 'Best', 'Burger', 'Mr', 'Employee', 1, 'test', 'Talabat_Contact');
        contacts[0].Contact_Role__c = 'Owner';
        insert contacts;

        Company__c com_bh = UnitTestDataFactory.createCompany('Talabat Bahrain', 'Talabat', beh);
        insert com_bh;

        Tarif__c t = UnitTestDataFactory.createTarif(com_bh, beh, 'Premium Placement SE', 'Talabat_Tarif', false);
        insert t;
        t.Is_Active__c = true;
        update t;

        Opportunity oppt = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'Talabat_Opportunity', Date.today());
        oppt.Business_Type__c = 'Upgrade/Upsell';
        oppt.Id_Tarif__r = t;
        oppt.StageName = 'Verbal Agreement';
        oppt.CurrencyIsoCode = 'BHD';
        oppt.Source_System__c = 'MIDAS';
        oppt.type = 'Product Only';
        insert oppt;

        Test.setMock(HttpCalloutMock.class, new UnitTestDataFactory.MockHttpResponseGenerator());

        test.startTest();
        ClsOpportunityProcessor.approvePremiumPlacementInMidas(oppt.id);
        ClsOpportunityProcessor.cancelPremiumPlacementInMidas(oppt.id);
        test.stopTest();

    }
    
     //SSC-1533
     @isTest
    public static void test_UpdateAccountCountry() {
        UnitTestDataFactory.getRecordtypeValues();

        Country__c hk = [SELECT Id, Name, CurrencyIsoCode FROM Country__c WHERE Name = 'Hong Kong'];
        Company__c com = [SELECT Id, Name FROM Company__c WHERE Country__c =: hk.Id];
        // CREATE ACCOUNT
        Account accTemp;
        List<Account> accountList = new List<Account>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        for(Integer counter = 0; counter < 2; counter++){
            accTemp = UnitTestDataFactory.createAccount('Test FP ' + (counter + 1), hk, 'FP_Account');
            accTemp.Type = 'Branch';
            accountList.add(accTemp);
        }
        insert accountList;
        
        Opportunity oppt = UnitTestDataFactory.createOpportunity(accountList[0].Name, accountList[0], 'FP_Opportunity', Date.today());
        oppt.Business_Type__c = 'New Business';
        insert oppt;
        
        for(Account iAcc : accountList){
            iAcc.Record_Country__c = 'MALAYSIA';
            iAcc.Phone = '+6012345678';
        }
        
        update accountList;
        
        oppt.AccountId = accountList[1].Id;
        update oppt;
        Opportunity updatedOpportunity = [SELECT Opportunity_Country__c
                                            FROM Opportunity
                                            WHERE ID =: oppt.ID]; 
        
       System.assertEquals(updatedOpportunity.Opportunity_Country__c, 'Malaysia');
    }
    /**
    * @description Test if the quality check case is created successfully & assigned to Finance team
    * //@Ticket #           : SSC-1332
    */
    @IsTest
    public static void test_MarketingPackageCaseRoutingForTB() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c beh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        insert beh;

        Account acco = UnitTestDataFactory.createAccount('TEST', beh, 'Talabat_Account');
        acco.Type = 'Branch - main';
        acco.Backend_ID__c = '1234521';
        insert acco;
        List<account> accountlist = new List<account>();
        accountlist.add(acco);

        list<Contact> contacts = UnitTestDataFactory.CreateContacts(accountlist, 'Best', 'Burger', 'Mr', 'Employee', 1, 'test', 'Talabat_Contact');
        contacts[0].Contact_Role__c = 'Owner';
        insert contacts;

        Company__c com_bh = UnitTestDataFactory.createCompany('Talabat Bahrain', 'Talabat', beh);
        insert com_bh;

        Tarif__c t = UnitTestDataFactory.createTarif(com_bh, beh, 'Marketing Package', 'Talabat_Tarif', false);
        insert t;
        t.Is_Active__c = true;
        update t;
        Opportunity oppt = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'Talabat_Opportunity', Date.today());
        oppt.Business_Type__c = 'Upgrade/Upsell';
        oppt.Id_Tarif__r = t;
        oppt.StageName = 'Verbal Agreement';
        oppt.CurrencyIsoCode = 'BHD';
        oppt.Source_System__c = 'MIDAS';
        oppt.type = 'Product Only';
        insert oppt;

        Case acase = UnitTestDataFactory.createCase(acco, 'New', 'Quality Check', '', '', beh, 'Talabat_Internal_Case', '');
        acase.Stage_1_Completed__c = true;
        acase.Opportunity__c = oppt.Id;
        acase.Closed_Reason__c = '';

        List<Case> caseList = new List<Case>{acase};
        insert caseList;

        Business_Config__c businessConfig0_1 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process','validAccountForSecondStage', acco.Type, beh.Id, 'Talabat_Opportunity', true, true );
        Business_Config__c businessConfig0_2 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process','validOppBusinessTypeForSecondStage', oppt.Business_Type__c, beh.Id, 'Talabat_Opportunity', true, false );
        Business_Config__c businessConfig0_3 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process', 'assignmentMap', '{"Germany":"00G1r000003JwK5","Bahrain":"00Gw00000034PPe","Colombia":"00Gw00000034PPe","Kuwait":"00Gw00000034PPe","Lebanon":"00Gw00000034PPe","Oman":"00Gw00000034PPe","Qatar":"00Gw00000034PPe","Kingdom of Saudi Arabia":"00Gw00000034PPe","United Arab Emirates":"00Gw00000034PPe","Jordan":"00Gw00000034PPe"}', beh.Id, 'Talabat_Opportunity', true, false );
        Business_Config__c businessConfig0_4 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process', 'recordTypeMap', '{"Germany":"0121r000000V9wh","Bahrain":"012w0000000MPceAAG","Colombia":"012w0000000MPceAAG","Lebanon":"012w0000000MPceAAG","Oman":"012w0000000MPceAAG","Qatar":"012w0000000MPceAAG","Kingdom of Saudi Arabia":"012w0000000MPceAAG","United Arab Emirates":"012w0000000MPceAAG","Jordan":"012w0000000MPceAAG"}', beh.Id, 'Talabat_Opportunity', true, false );
        Business_Config__c businessConfig0_5 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process','QualityCheckCaseSecondStage', 'RecordTypeId=012w0000000MPce,Type=Quality Check,subject=Quality Check,status=Operation Check,ownerid=00Gw00000034QshEAE', beh.Id, 'Talabat_Opportunity', true, true );
        Business_Config__c businessConfig0_6 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process','MIDASPackagesCaseQueueAssignment', '{"Marketing Package":"Talabat_Finance_Team"}', beh.Id, 'Talabat_Opportunity', true, true );
        Map<String, Business_Config__c> bconfMap_1 = new Map<String, Business_Config__c>{businessConfig0_1.Business_Rule_Name__c => businessConfig0_1, businessConfig0_2.Business_Rule_Name__c => businessConfig0_2, businessConfig0_3.Business_Rule_Name__c => businessConfig0_3, businessConfig0_4.Business_Rule_Name__c => businessConfig0_4, businessConfig0_5.Business_Rule_Name__c => businessConfig0_5, businessConfig0_6.Business_Rule_Name__c => businessConfig0_6};
        Map<String, Map<String, Business_Config__c>> bconfMap_1f = new Map<String, Map<String, Business_Config__c>>{'Talabat_Opportunity' => bconfMap_1};
        ClsOpportunityProcessor.moam = new Map<String, Map<String, Map<String, Business_Config__c>>>{businessConfig0_1.Process_Name__c => bconfMap_1f};

        Test.startTest();
        Case case0 = (Case) ClsOpportunityProcessor.createQualityCheckCase(oppt,caseList, acco);
        Test.stopTest();
        System.assert(case0 != null);
        System.assertEquals('00Gw00000034PPe', case0.OwnerId);
    }
    /**
     * @description #SSC-1220
     */
    @IsTest
    public static void testMarketingPackageAddtnlChargesStatus() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c beh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        insert beh;

        Account acco = UnitTestDataFactory.createAccount('TEST', beh, 'Talabat_Account');
        acco.Type = 'Branch - main';
        acco.Backend_ID__c = '1234521';
        insert acco;
        insert new Platform_Performance__c(Account__c = acco.Id, Backend_ID__c = '1111');
        List<account> accountlist = new List<account>();
        accountlist.add(acco);

        list<Contact> contacts = UnitTestDataFactory.CreateContacts(accountlist, 'Best', 'Burger', 'Mr', 'Employee', 1, 'test', 'Talabat_Contact');
        contacts[0].Contact_Role__c = 'Owner';
        insert contacts;

        Company__c com_bh = UnitTestDataFactory.createCompany('Talabat Bahrain', 'Talabat', beh);
        insert com_bh;

        Tarif__c t = UnitTestDataFactory.createTarif(com_bh, beh, 'Marketing Package', 'Talabat_Tarif', false);
        insert t;
        t.Is_Active__c = true;
        update t;
        Opportunity oppt = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'Talabat_Opportunity', Date.today());
        oppt.Name = 'TestOppty1';
        oppt.Business_Type__c = 'Upgrade/Upsell';
        oppt.Id_Tarif__r = t;
        oppt.StageName = 'Verbal Agreement';
        oppt.CurrencyIsoCode = 'BHD';
        oppt.Source_System__c = 'MIDAS';
        oppt.type = 'Product Only';
        insert oppt;



        Business_Config__c businessConfig1 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process','validAccountForSecondStage', acco.Type, beh.Id, 'Talabat_Opportunity', true, true );
        Business_Config__c businessConfig2 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process','validOppBusinessTypeForSecondStage', oppt.Business_Type__c, beh.Id, 'Talabat_Opportunity', true, false );
        Business_Config__c businessConfig3 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process', 'assignmentMap', '{"Germany":"00G1r000003JwK5","Bahrain":"00Gw00000034PPe","Colombia":"00Gw00000034PPe","Kuwait":"00Gw00000034PPe","Lebanon":"00Gw00000034PPe","Oman":"00Gw00000034PPe","Qatar":"00Gw00000034PPe","Kingdom of Saudi Arabia":"00Gw00000034PPe","United Arab Emirates":"00Gw00000034PPe","Jordan":"00Gw00000034PPe"}', beh.Id, 'Talabat_Opportunity', true, false );
        Business_Config__c businessConfig4 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process', 'recordTypeMap', '{"Germany":"0121r000000V9wh","Bahrain":"012w0000000MPceAAG","Colombia":"012w0000000MPceAAG","Lebanon":"012w0000000MPceAAG","Oman":"012w0000000MPceAAG","Qatar":"012w0000000MPceAAG","Kingdom of Saudi Arabia":"012w0000000MPceAAG","United Arab Emirates":"012w0000000MPceAAG","Jordan":"012w0000000MPceAAG"}', beh.Id, 'Talabat_Opportunity', true, false );
        Business_Config__c businessConfig5 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process','QualityCheckCaseSecondStage', 'RecordTypeId=012w0000000MPce,Type=Quality Check,subject=Quality Check,status=Operation Check,ownerid=00Gw00000034QshEAE', beh.Id, 'Talabat_Opportunity', true, true );
        Business_Config__c businessConfig6 = UnitTestDataFactory.createBusinessConfig('QualityCheckInternalCase', 'Process','MIDASPackagesCaseQueueAssignment', '{"Marketing Package":"Talabat_Finance_Team"}', beh.Id, 'Talabat_Opportunity', true, true );
        Business_Config__c businessConfig7 = UnitTestDataFactory.createBusinessConfig('Opportunity Contract Process', 'Process','setAdditionalChargesStatus', 'Marketing Package', beh.Id, 'Talabat_Opportunity', true, true );
        Business_Config__c businessConfig8 = UnitTestDataFactory.createBusinessConfig('Opportunity Contract Process', 'Process','AdditionalCharges RecordType', 'Talabat_Additional_Charges', beh.Id, 'Talabat_Opportunity', true, true );
        Map<String, Business_Config__c> bconfMap1 = new Map<String, Business_Config__c>{businessConfig1.Business_Rule_Name__c => businessConfig1, businessConfig2.Business_Rule_Name__c => businessConfig2, businessConfig3.Business_Rule_Name__c => businessConfig3, businessConfig4.Business_Rule_Name__c => businessConfig4, businessConfig5.Business_Rule_Name__c => businessConfig5,businessConfig7.Business_Rule_Name__c => businessConfig7,businessConfig8.Business_Rule_Name__c => businessConfig8};
        Map<String, Map<String, Business_Config__c>> bconfMap1f = new Map<String, Map<String, Business_Config__c>>{'Talabat_Opportunity' => bconfMap1};
        ClsOpportunityProcessor.moam = new Map<String, Map<String, Map<String, Business_Config__c>>>{businessConfig1.Process_Name__c => bconfMap1f};




        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com_bh,beh,'Apple','Talabat_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com_bh,beh,'Setup Fee','Talabat_List_Product_Group');
        insert new List<SObject>{lpg,lpg1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com_bh,beh,'Test Product',lpg.id,'Talabat_List_Product_Price',1,true,100,1,false,20);
        lpp.Requires_Asset__c=false;
        lpp.Requires_Branding__c=false;
        lpp.Requires_Add_On__c=true;
        insert new List<sObject>{lpp};

        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppt.id,status__c='Approved',ID_Account__c=acco.id);
        insert newQuote;

        List<Opportunity_Quote_Line_Item__c> oppQuoteLine2 =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'Talabat_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Packaging','Product');
        oppQuoteLine2[0].Id_List_Product_Price__c = lpp.Id;
        oppQuoteLine2[0].id_opportunity__c=oppt.id;
        oppQuoteLine2[0].Quantity__c = 1;
        oppQuoteLine2[0].Budget__c = 100;
        oppQuoteLine2[0].Unit_Cost__c = 2;
        oppQuoteLine2[0].Name = 'Marketing Package';
        insert oppQuoteLine2;

        newQuote.status__c = 'Accepted';

        Case acase = UnitTestDataFactory.createCase(acco, 'New', 'Quality Check', '', '', beh, 'Talabat_Internal_Case', '');
        acase.Stage_1_Completed__c = true;
        acase.Opportunity__c = oppt.Id;
        acase.Closed_Reason__c = '';

        List<Case> caseList = new List<Case>{acase};
        insert caseList;

        Case caseObj = [select id,Status,Closed_Reason__c from Case where Opportunity__c=:oppt.Id];
        caseObj.Status='Closed';
        caseObj.Closed_Reason__c='Successful';
        update caseObj;
        Opportunity opp =[select id,StageName from Opportunity where AccountId=:acco.id limit 1];
        opp.StageName='Closed Won';
        update opp;
        List<Additional_Charges__c> listAdditional = new List<Additional_Charges__c>();
        Test.startTest();
        ClsOpportunityProcessor.createAdditionalCharge(oppQuoteLine2[0],listAdditional,bconfMap1);
        Test.stopTest();

        System.assertEquals(1,caseList.size());
        System.assertEquals('Closed Won',opp.StageName);
    }
    /**
    * @description #SSC-1220
    */
    @IsTest
    public static void testProdCoverage() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c beh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        insert beh;

        Account acco = UnitTestDataFactory.createAccount('TEST', beh, 'Talabat_Account');
        acco.Type = 'Branch - main';
        acco.Backend_ID__c = '1234521';
        insert acco;
        insert new Platform_Performance__c(Account__c = acco.Id, Backend_ID__c = '1111');
        List<account> accountlist = new List<account>();
        accountlist.add(acco);

        list<Contact> contacts = UnitTestDataFactory.CreateContacts(accountlist, 'Best', 'Burger', 'Mr', 'Employee', 1, 'test', 'Talabat_Contact');
        contacts[0].Contact_Role__c = 'Owner';
        insert contacts;

        Company__c com_bh = UnitTestDataFactory.createCompany('Talabat Bahrain', 'Talabat', beh);
        insert com_bh;

        Tarif__c t = UnitTestDataFactory.createTarif(com_bh, beh, 'Marketing Package', 'Talabat_Tarif', false);
        insert t;
        t.Is_Active__c = true;
        update t;
        Opportunity oppt = UnitTestDataFactory.createOpportunity(acco.Name, acco, 'Talabat_Opportunity', Date.today());
        oppt.Name = 'TestOppty1';
        oppt.Business_Type__c = 'Upgrade/Upsell';
        oppt.Id_Tarif__r = t;
        oppt.StageName = 'Verbal Agreement';
        oppt.CurrencyIsoCode = 'BHD';
        oppt.Source_System__c = 'MIDAS';
        oppt.type = 'Product Only';
        insert oppt;


        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com_bh,beh,'Apple','Talabat_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com_bh,beh,'Setup Fee','Talabat_List_Product_Group');
        insert new List<SObject>{lpg,lpg1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com_bh,beh,'Test Product',lpg.id,'Talabat_List_Product_Price',1,true,100,1,false,20);
        lpp.Requires_Asset__c=false;
        lpp.Requires_Branding__c=false;
        lpp.Requires_Add_On__c=true;
        insert new List<sObject>{lpp};

        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppt.id,status__c='Approved',ID_Account__c=acco.id);
        insert newQuote;

        List<Opportunity_Line_Item__c> lineItems = UnitTestDataFactory.createOpportunityLineItems(oppt,lpg.id, lpp.id, 3, true, 'Talabat_Opportunity_Line_Item',1, '10', 299.0, 1, 1, 'Product');
        integer bID = 1;
        for(Opportunity_Line_Item__c lineItem: lineItems) {
            bID = bID + 1;
            lineItem.Booking_Api_Id__c = '123' + bID;
        }
        insert lineItems;

        List<Opportunity_Quote_Line_Item__c> oppQuoteLine2 =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'Talabat_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Packaging','Product');
        oppQuoteLine2[0].Id_List_Product_Price__c = lpp.Id;
        oppQuoteLine2[0].id_opportunity__c=oppt.id;
        oppQuoteLine2[0].Quantity__c = 1;
        oppQuoteLine2[0].Budget__c = 100;
        oppQuoteLine2[0].Unit_Cost__c = 2;
        oppQuoteLine2[0].Name = 'Marketing Package';
        insert oppQuoteLine2;

        newQuote.status__c = 'Accepted';

        Case acase = UnitTestDataFactory.createCase(acco, 'New', 'Quality Check', '', '', beh, 'Talabat_Internal_Case', '');
        acase.Stage_1_Completed__c = true;
        acase.Opportunity__c = oppt.Id;
        acase.Closed_Reason__c = '';

        List<Case> caseList = new List<Case>{acase};
        insert caseList;

        Case caseObj = [select id,Status,Closed_Reason__c from Case where Opportunity__c=:oppt.Id];
        caseObj.Status='Closed';
        caseObj.Closed_Reason__c='Successful';
        update caseObj;
        List<InterestedOppClosedLost__c> intOppClosedSetting = new List<InterestedOppClosedLost__c>();
        intOppClosedSetting.add(new InterestedOppClosedLost__c(name = 'Interested', Values__c = 'Not enough capacity', CaseClosingReason__c = 'Successful'));
        insert intOppClosedSetting;
        CountryCompanyBrand__c config = new CountryCompanyBrand__c();
        config.Name = 'Talabat Bahrain';
        config.Code__c = 'Talabat Bahrain';
        insert config;
        Opportunity opp =[select id,StageName,AccountId,Lost_Reason__c,Source_System__c from Opportunity where AccountId=:acco.id limit 1];
        opp.StageName='Closed Lost';
        opp.Lost_Reason__c='Invalid';
        opp.Source_System__c ='';
        update opp;
        List_Product_Price__c listProductPriceObj = [select id,company__r.Name from List_Product_Price__c limit 1];

        List<Opportunity_Line_Item__c> oppLineItemObj = [select id,Id_Opportunity__c,Id_Opportunity__r.Source_System__c,Booking_Api_Id__c from Opportunity_Line_Item__c where Id_Opportunity__c=:opp.id];
        
        Test.startTest();
        ClsOpportunityProcessor.cancelMidasPP(opp);
        ClsOpportunityProcessor.sentBookingsStatusToMidas(opp.id);
        Test.stopTest();
        System.assertEquals('Closed Lost',opp.StageName);

    }
}
