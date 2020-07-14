@isTest
private class UnitTestCtrAccountClone {

    static User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'yogiyounittestuser@deliveryhero.com', 'Yogiyo', 'KR');
    static User testUser2 = UnitTestDataFactory.createUser('CD Sales Team', 'yogiyounittestuser@deliveryhero.com', 'ClickDelivery', 'PE');
    static Country__c testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KWR');
    static Country__c testCountryCD = UnitTestDataFactory.createCountry('PE', 'Peru', 'PEN');
    static Country__c testCountryTal = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'USD');
    static Country__c testCountryDE = UnitTestDataFactory.createCountry('DE', 'Germany', 'EUR');
    static Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Account', 'Contact'});
    static {
        UnitTestDataFactory.getRecordtypeValues();
    }
    static void testData() {
        List<Platform_Country__c> platformCountry = new List<Platform_Country__c>();
        platformCountry.add(new Platform_Country__c(name = 'TalabatPlatform', country__c = 'Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name = 'FOCPlatform', country__c = 'Lebanon,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name = 'Peru', country__c = 'limadelivery.com'));
        insert platformCountry;
        //business config for select options
        Business_Config__c bc12 = new Business_Config__c(
            Business_Rule_Name__c = 'Select options',
            Business_Rule_Value__c = 'Account Clone Flyer,Account Clone Owner Change',
            Id_country__c = testCountry.Id,
            Is_Active__c = true,
            Parent__c = true,
            Process_Name__c = 'Account Clone Select Options',
            Record_Type_Id__c = 'Yogiyo_Account',
            Type__c = 'Process'
        );


        // business configs for "Account Clone Flyer"
        Business_Config__c bc = new Business_Config__c(
            Business_Rule_Name__c = 'Copy fields',
            Business_Rule_Value__c = 'RecordTypeId,CurrencyIsoCode,Name,Restaurant_Name__c,BillingStreet,Menu_Typing_By_User__c,BillingPostalCode,Menu_Typing_Date_Start__c,BillingCity,Menu_Typing_Progress_Status__c,BillingState,Final_Check_Date__c,BillingCountry,Billing_Dong__c,Billing_GunGu__c,Billing_Subdistrict__c,Record_Country__c,Franchise_Type__c',
            Id_country__c = testCountry.Id,
            Is_Active__c = true,
            Parent__c = true,
            Process_Name__c = 'Account Clone Flyer',
            Record_Type_Id__c = 'Yogiyo_Account',
            Type__c = 'Process'
        );

        Business_Config__c bc1 = new Business_Config__c(
            Business_Rule_Name__c = 'Opportunity name',
            Business_Rule_Value__c = 'Korean Opportunity',
            Id_country__c = testCountry.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Flyer',
            Record_Type_Id__c = 'Yogiyo_Account',
            Type__c = 'Process'
        );

        Business_Config__c bc2 = new Business_Config__c(
            Business_Rule_Name__c = 'deeperLevel',
            Business_Rule_Value__c = 'True',
            Id_country__c = testCountry.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Flyer',
            Record_Type_Id__c = 'Yogiyo_Account',
            Type__c = 'Process'
        );

        Business_Config__c bc3 = new Business_Config__c(
            Business_Rule_Name__c = 'Opportunity Stagename',
            Business_Rule_Value__c = 'Needs Analysis',
            Id_country__c = testCountry.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Flyer',
            Record_Type_Id__c = 'Yogiyo_Account',
            Type__c = 'Process'
        );

        Business_Config__c bc4 = new Business_Config__c(
            Business_Rule_Name__c = 'Opportunity Percentage',
            Business_Rule_Value__c = '20',
            Id_country__c = testCountry.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Flyer',
            Record_Type_Id__c = 'Yogiyo_Account',
            Type__c = 'Process'
        );
        Business_Config__c bc10 = new Business_Config__c(
            Business_Rule_Name__c = 'Opportunity CloseDate days in future',
            Business_Rule_Value__c = '20',
            Id_country__c = testCountry.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Flyer',
            Record_Type_Id__c = 'Yogiyo_Account',
            Type__c = 'Process'
        );
        Business_Config__c bc13 = new Business_Config__c(
            Business_Rule_Name__c = 'OpportunityRecordtype',
            Business_Rule_Value__c = 'Yogiyo_Opportunity',
            Id_country__c = testCountry.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Flyer',
            Record_Type_Id__c = 'Yogiyo_Account',
            Type__c = 'Process'
        );
        //business configs for "Account Clone Owner Change"

        Business_Config__c bc5 = new Business_Config__c(
            Business_Rule_Name__c = 'Copy fields',
            Business_Rule_Value__c = 'RecordTypeId,CurrencyIsoCode,Name,Restaurant_Name__c,BillingStreet,BillingPostalCode,BillingCity,BillingState,BillingCountry,Record_Country__c,Franchise_Type__c',
            Id_country__c = testCountry.Id,
            Is_Active__c = true,
            Parent__c = true,
            Process_Name__c = 'Account Clone Owner Change',
            Record_Type_Id__c = 'Yogiyo_Account',
            Type__c = 'Process'
        );

        Business_Config__c bc6 = new Business_Config__c(
            Business_Rule_Name__c = 'Opportunity name',
            Business_Rule_Value__c = 'Korean Opportunity',
            Id_country__c = testCountry.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Owner Change',
            Record_Type_Id__c = 'Yogiyo_Account',
            Type__c = 'Process'
        );

        Business_Config__c bc7 = new Business_Config__c(
            Business_Rule_Name__c = 'deeperLevel',
            Business_Rule_Value__c = 'False',
            Id_country__c = testCountry.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Owner Change',
            Record_Type_Id__c = 'Yogiyo_Account',
            Type__c = 'Process'
        );

        Business_Config__c bc8 = new Business_Config__c(
            Business_Rule_Name__c = 'Opportunity Stagename',
            Business_Rule_Value__c = 'Needs Analysis',
            Id_country__c = testCountry.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Owner Change',
            Record_Type_Id__c = 'Yogiyo_Account',
            Type__c = 'Process'
        );

        Business_Config__c bc9 = new Business_Config__c(
            Business_Rule_Name__c = 'Opportunity Percentage',
            Business_Rule_Value__c = '20',
            Id_country__c = testCountry.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Owner Change',
            Record_Type_Id__c = 'Yogiyo_Account',
            Type__c = 'Process'
        );
        Business_Config__c bc11 = new Business_Config__c(
            Business_Rule_Name__c = 'Opportunity CloseDate days in future',
            Business_Rule_Value__c = '20',
            Id_country__c = testCountry.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Owner Change',
            Record_Type_Id__c = 'Yogiyo_Account',
            Type__c = 'Process'
        );
        Business_Config__c bc14 = new Business_Config__c(
            Business_Rule_Name__c = 'OpportunityRecordtype',
            Business_Rule_Value__c = 'Yogiyo_Opportunity',
            Id_country__c = testCountry.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Owner Change',
            Record_Type_Id__c = 'Yogiyo_Account',
            Type__c = 'Process'
        );

        Business_Config__c bc15 = new Business_Config__c(
            Business_Rule_Name__c = 'selectOptionValues',
            Business_Rule_Value__c = 'Account Clone Flyer:Account Clone Flyer,Account Clone Owner Change:Account Clone Owner Change',
            Id_country__c = testCountry.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Select Options',
            Record_Type_Id__c = 'Yogiyo_Account',
            Type__c = 'Process'
        );

        Business_Config__c bc16 = new Business_Config__c(
            Business_Rule_Name__c = 'selectOptionValues',
            Business_Rule_Value__c = 'dynamically rendering',
            Id_country__c = testCountryCD.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Select Options',
            Record_Type_Id__c = 'CD_Account',
            Type__c = 'Process'
        );
        Business_Config__c bc17 = new Business_Config__c(
            Business_Rule_Name__c = 'Copy fields',
            Business_Rule_Value__c = 'Name,Restaurant_Name__c,Record_Country__c,BillingStreet,BillingPostalCode,BillingCity,BillingState,BillingCountry,ShippingStreet,ShippingPostalCode,ShippingCity,ShippingState,ShippingCountry,Platform__c,ParentId,Franchise_Type__c',
            Id_country__c = testCountryCD.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Brand',
            Record_Type_Id__c = 'CD_Account',
            Type__c = 'Process'
        );
        Business_Config__c bc20 = new Business_Config__c(
            Business_Rule_Name__c = 'Copy Related Contact',
            Business_Rule_Value__c = 'true',
            Id_country__c = testCountryCD.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Brand',
            Record_Type_Id__c = 'CD_Account',
            Type__c = 'Process'
        );
        Business_Config__c bc21 = new Business_Config__c(
            Business_Rule_Name__c = 'deeperLevel',
            Business_Rule_Value__c = 'false',
            Id_country__c = testCountryCD.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Brand',
            Record_Type_Id__c = 'CD_Account',
            Type__c = 'Process'
        );
        Business_Config__c bc18 = new Business_Config__c(
            Business_Rule_Name__c = 'include',
            Business_Rule_Value__c = 'rule0',
            Id_country__c = testCountryCD.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Select Options',
            Record_Type_Id__c = 'CD_Account',
            Type__c = 'Process'
        );
        Business_Config__c bc19 = new Business_Config__c(
            Business_Rule_Name__c = 'rule0',
            Business_Rule_Value__c = 'Type:Branch:AND:RecordType:CD_Account:Account_Clone_Brand',
            Id_country__c = testCountryCD.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Select Options',
            Record_Type_Id__c = 'CD_Account',
            Type__c = 'Process'
        );
        Business_Config__c bc22 = new Business_Config__c(
            Business_Rule_Name__c = 'Account_Clone_Brand',
            Business_Rule_Value__c = 'Account Clone Brand:Clone Franchise',
            Id_country__c = testCountryCD.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Select Options',
            Record_Type_Id__c = 'CD_Account',
            Type__c = 'Process'
        );
        Business_Config__c bc23 = new Business_Config__c(
            Business_Rule_Name__c = 'Opportunity name',
            Business_Rule_Value__c = 'CD Opportunity',
            Id_country__c = testCountryCD.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Brand',
            Record_Type_Id__c = 'CD_Account',
            Type__c = 'Process'
        );
        Business_Config__c bc24 = new Business_Config__c(
            Business_Rule_Name__c = 'OpportunityRecordtype',
            Business_Rule_Value__c = 'CD_Opportunity',
            Id_country__c = testCountryCD.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Brand',
            Record_Type_Id__c = 'CD_Account',
            Type__c = 'Process'
        );
        Business_Config__c bc25 = new Business_Config__c(
            Business_Rule_Name__c = 'Opportunity BusinessType',
            Business_Rule_Value__c = 'Owner Change',
            Id_country__c = testCountryCD.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Brand',
            Record_Type_Id__c = 'CD_Account',
            Type__c = 'Process'
        );
        Business_Config__c bc26 = new Business_Config__c(
            Business_Rule_Name__c = 'Opportunity CloseDate days in future',
            Business_Rule_Value__c = '12',
            Id_country__c = testCountryCD.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Brand',
            Record_Type_Id__c = 'CD_Account',
            Type__c = 'Process'
        );
        Business_Config__c bc27 = new Business_Config__c(
            Business_Rule_Name__c = 'Opportunity CloseDate days in future',
            Business_Rule_Value__c = '12',
            Id_country__c = testCountryCD.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Brand',
            Record_Type_Id__c = 'CD_Account',
            Type__c = 'Process'
        );
        Business_Config__c bc28 = new Business_Config__c(
            Business_Rule_Name__c = 'Opportunity CloseDate days',
            Business_Rule_Value__c = '14',
            Id_country__c = testCountryCD.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Brand',
            Record_Type_Id__c = 'CD_Account',
            Type__c = 'Process'
        );
        Business_Config__c bc29 = new Business_Config__c(
            Business_Rule_Name__c = 'Opportunity Percentage',
            Business_Rule_Value__c = '20',
            Id_country__c = testCountryCD.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Brand',
            Record_Type_Id__c = 'CD_Account',
            Type__c = 'Process'
        );
        Business_Config__c bc30 = new Business_Config__c(
            Business_Rule_Name__c = 'Opportunity Stagename',
            Business_Rule_Value__c = 'Prospecting',
            Id_country__c = testCountryCD.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Brand',
            Record_Type_Id__c = 'CD_Account',
            Type__c = 'Process'
        );

        //talabat

        Business_Config__c tal1 = new Business_Config__c(
            Business_Rule_Name__c = 'selectOptionValues',
            Business_Rule_Value__c = 'json_format',
            Id_country__c = testCountryTal.Id,
            Is_Active__c = true,
            Parent__c = true,
            Process_Name__c = 'Account Clone Select Options',
            Record_Type_Id__c = 'Talabat_Account',
            Type__c = 'Process'
        );

        Business_Config__c tal2 = new Business_Config__c(
            Business_Rule_Name__c = 'allowedAccountTypeForCloning',
            Business_Rule_Value__c = 'Brand,Branch,Group',
            Id_country__c = testCountryTal.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Select Options',
            Record_Type_Id__c = 'Talabat_Account',
            Type__c = 'Process'
        );

        Business_Config__c tal3 = new Business_Config__c(
            Business_Rule_Name__c = 'checkAccountTypeNotBlank',
            Business_Rule_Value__c = 'true',
            Id_country__c = testCountryTal.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Select Options',
            Record_Type_Id__c = 'Talabat_Account',
            Type__c = 'Process'
        );

        Business_Config__c tal4 = new Business_Config__c(
            Business_Rule_Name__c = 'selectOptionValuesJsonFormat',
            Business_Rule_Value__c = '[{"value": "Account Clone Brand", "label": "Account Clone Group"}, {"fieldsRequirements": {"Type": "Brand", "ParentId": "not_null"}, "value": "Account Clone Flyer", "label": "Account Clone Branch"}, {"fieldsRequirements": {"Type": "Brand"}, "value": "Account Clone Owner Change", "label": "Account Clone Owner Change"}, {"fieldsRequirements": {"Type": "Branch"}, "value": "Clone Sibling", "label": "Account Clone Branch"}, {"fieldsRequirements": {"Type": "Group"}, "value": "Account Clone Owner Change", "label": "Account Clone Owner Change"} ]',
            Id_country__c = testCountryTal.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Select Options',
            Record_Type_Id__c = 'Talabat_Account',
            Type__c = 'Process'
        );

        Business_Config__c branchCloneOptionsDE = new Business_Config__c(
            Business_Rule_Name__c = 'Account Clone Select Options',
            Business_Rule_Value__c = '[{"fieldsRequirements":{"Type":"Branch - Express"},"value":"Account Clone Owner Change","label":"Account Clone Owner Change"},{"fieldsRequirements":{"Type":"Branch - Virtual Restaurant"},"value":"Account Clone Owner Change","label":"Account Clone Owner Change"},{"fieldsRequirements":{"Type":"Branch - Main"},"value":"Account Clone Branch to Branch Express","label":"Account Clone Branch Main to Branch Express"},{"fieldsRequirements":{"Type":"Branch - Main"},"value":"Account Clone Branch to Branch Virtual","label":"Account Clone Branch Main to Branch Virtual Restaurant"},{"fieldsRequirements":{"Type":"Branch - Main"},"value":"Account Clone Branch to Group","label":"Account Clone Branch to Group"},{"fieldsRequirements":{"Type":"Branch - Main"},"value":"Account Clone Owner Change","label":"Account Clone Owner Change"},{"fieldsRequirements":{"Type":"Group"},"value":"Account Clone Group to Branch Main","label":"Account Clone Group to Branch Main"},{"fieldsRequirements":{"Type":"Group"},"value":"Account Clone Group to Brand","label":"Account Clone Group to Brand"},{"fieldsRequirements":{"Type":"Group"},"value":"Account Clone Group to Holding","label":"Account Clone Group to Holding"},{"fieldsRequirements":{"Type":"Brand"},"value":"Account Clone Brand to Group","label":"Account Clone Brand to Group"},{"fieldsRequirements":{"Type":"Brand"},"value":"Account Clone Brand to Holding","label":"Account Clone Brand to Holding"},{"fieldsRequirements":{"Type":"Holding"},"value":"Account Clone Holding to Group","label":"Account Clone Holding to Group"},{"fieldsRequirements":{"Type":"Holding"},"value":"Account Clone Holding to Regional/Global HQ","label":"Account Clone Holding to Regional/Global HQ"},{"fieldsRequirements":{"Type":"Holding"},"value":"Account Clone Holding to Brand","label":"Account Clone Holding to Brand"},{"fieldsRequirements":{"Type":"Branch - Main"},"value":"Account Clone Legal Form Change","label":"Account Clone Legal Form Change"},{"fieldsRequirements":{"Type":"Branch - Express"},"value":"Account Clone Legal Form Change","label":"Account Clone Legal Form Change"},{"fieldsRequirements":{"Type":"Branch - Virtual Restaurant"},"value":"Account Clone Legal Form Change","label":"Account Clone Legal Form Change"}]',
            Id_country__c = testCountryDE.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Branch to Branch Virtual',
            Record_Type_Id__c = 'DE_Account',
            Type__c = 'Process'
        );
        
        Business_Config__c branchCloneBc2 = new Business_Config__c(
            Business_Rule_Name__c = 'Account Clone Branch to Branch Virtual',
            Business_Rule_Value__c = 'Name,Restaurant_Name__c,Record_Country__c,Platform__c,ownerid,Cuisine__c,Legal_form__c,Franchise_Type__c',
            Id_country__c = testCountryDE.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Branch to Branch Virtual',
            Record_Type_Id__c = 'DE_Account',
            Type__c = 'Process'
        );
        
        
        Business_Config__c branchCloneBc = new Business_Config__c(
            Business_Rule_Name__c = 'Parent or grandparent must be group',
            Business_Rule_Value__c = 'TRUE',
            Id_country__c = testCountryDE.Id,
            Is_Active__c = true,
            Parent__c = false,
            Process_Name__c = 'Account Clone Branch to Branch Virtual',
            Record_Type_Id__c = 'DE_Account',
            Type__c = 'Process'
        );
       
        insert new List<sObject> {branchCloneOptionsDE, branchCloneBc, branchCloneBc2, tal1, tal2, tal3, tal4, bc, bc1, bc2, bc3, bc4, bc5, bc6, bc7, bc8, bc9, bc10, bc11, bc12, bc13, bc14, bc15, bc16, bc17, bc18, bc22, bc19, bc20, bc21, bc23, bc24, bc25, bc26, bc27, bc28, bc29, bc30};

    }

    @isTest static void getCloneOptionsReturnsNoOptionIfAccountTypeIsBlank() {
        testData();

        Account myTestAccount = new Account(
            Name = 'My pretty Testaccount',
            Restaurant_Name__c = 'Tasty food',
            Record_Country__c = 'Bahrain',
            CurrencyIsoCode = 'USD',
            RecordTypeId = mapRecordtypes.get('Talabat_Account').Id
        );

        insert myTestAccount;
        myTestAccount.Type = '';
        update myTestAccount;

        List<SelectOption> res;

        Test.startTest();

        Test.setCurrentPage(Page.AccountClone);
        ApexPages.StandardController std = new ApexPages.StandardController(myTestAccount);
        CtrAccountClone ctr = new CtrAccountClone(std);
        res = ctr.getCloneOptions();
        Test.stopTest();

        System.assert(res.isEmpty());
    }

    @isTest static void getCloneOptionsReturnsNoOptionIfAccountTypeIsNotAllowed() {
        testData();

        Account myTestAccount = new Account(
            Name = 'My pretty Testaccount',
            Restaurant_Name__c = 'Tasty food',
            Record_Country__c = 'Bahrain',
            CurrencyIsoCode = 'USD',
            Type = 'Client',
            RecordTypeId = mapRecordtypes.get('Talabat_Account').Id
        );

        insert myTestAccount;

        List<SelectOption> res;

        Test.startTest();

        Test.setCurrentPage(Page.AccountClone);
        ApexPages.StandardController std = new ApexPages.StandardController(myTestAccount);
        CtrAccountClone ctr = new CtrAccountClone(std);
        res = ctr.getCloneOptions();
        Test.stopTest();

        System.assert(res.isEmpty());
    }

    @isTest static void getCloneOptionsWithJsonWorksCorrectly() {
        testData();

        Account myTestAccount = new Account(
            Name = 'My pretty Testaccount',
            Restaurant_Name__c = 'Tasty food',
            Type = 'Brand',
            Record_Country__c = 'Bahrain',
            CurrencyIsoCode = 'USD',
            RecordTypeId = mapRecordtypes.get('Talabat_Account').Id
        );

        insert myTestAccount;

        Test.startTest();

        Test.setCurrentPage(Page.AccountClone);
        ApexPages.StandardController std = new ApexPages.StandardController(myTestAccount);
        CtrAccountClone ctr = new CtrAccountClone(std);
        ctr.getCloneOptions();
        Test.stopTest();
    }

    @isTest static void test_cloneAccountFlyer() {

        testdata();

        Country__c c = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        insert c;


        System.runAs(testUser) {


            Account myTestAccount = new Account(
                Name = 'My pretty Testaccount',
                Restaurant_Name__c = 'Tasty food',
                BillingStreet = 'BillingStreet',
                BillingPostalCode = 'BillingPostalCode',
                BillingCity = 'BillingCity',
                BillingState = 'BillingState',
                BillingCountry = 'Korea',
                Menu_Typing_By_User__c = testUser.Id,
                Menu_Typing_Date_Start__c = Datetime.now(),
                Menu_Typing_Progress_Status__c = 'Taking Restaurant Online',
                Final_Check_Date__c = Datetime.now() + 14,
                Billing_Dong__c = 'Billing Dong',
                Billing_GunGu__c = 'Billing GunGu',
                Billing_Subdistrict__c = 'Billing subdistrict',
                Record_Country__c = 'Korea',
                CurrencyIsoCode = 'KRW',
                RecordTypeId = mapRecordtypes.get('Yogiyo_Account').Id
            );

            insert myTestAccount;

            Test.startTest();

            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(myTestAccount);
            CtrAccountClone ctrl = new CtrAccountClone(stdCtrl);

            ctrl.createOpportunityFlag = true;

            List<SelectOption> listOptions = ctrl.getCloneOptions();

            ctrl.selectedCloneOption = listOptions[1].getValue();

            ctrl.drawPanel();

            ctrl.doClone();

            Test.stopTest();

            Account clonedAccount  = [SELECT Name,
                                      Restaurant_Name__c,
                                      BillingStreet,
                                      BillingPostalCode,
                                      BillingCity,
                                      BillingState,
                                      BillingCountry,
                                      Menu_Typing_By_User__c,
                                      Menu_Typing_Date_Start__c,
                                      Menu_Typing_Progress_Status__c,
                                      Final_Check_Date__c,
                                      Billing_Dong__c,
                                      Billing_GunGu__c,
                                      Billing_Subdistrict__c,
                                      Record_Country__c,
                                      CurrencyIsoCode,
                                      RecordTypeId
                                      FROM    Account
                                      WHERE ParentId = :myTestAccount.Id];

            System.assertEquals(myTestAccount.Name, clonedAccount.Name);
            System.assertEquals(myTestAccount.Restaurant_Name__c, clonedAccount.Restaurant_Name__c);
            System.assertEquals(myTestAccount.BillingStreet, clonedAccount.BillingStreet);
            System.assertEquals(myTestAccount.BillingPostalCode, clonedAccount.BillingPostalCode);
            System.assertEquals(myTestAccount.BillingCity, clonedAccount.BillingCity);
            System.assertEquals(myTestAccount.BillingState, clonedAccount.BillingState);
            System.assertEquals(myTestAccount.BillingCountry, clonedAccount.BillingCountry);
            System.assertEquals(myTestAccount.Menu_Typing_By_User__c, clonedAccount.Menu_Typing_By_User__c);
            System.assertEquals(myTestAccount.Menu_Typing_Progress_Status__c, clonedAccount.Menu_Typing_Progress_Status__c);
            System.assertEquals(myTestAccount.Billing_Dong__c, clonedAccount.Billing_Dong__c);
            System.assertEquals(myTestAccount.Billing_GunGu__c, clonedAccount.Billing_GunGu__c);
            System.assertEquals(myTestAccount.Billing_Subdistrict__c, clonedAccount.Billing_Subdistrict__c);
            System.assertEquals(myTestAccount.Record_Country__c, clonedAccount.Record_Country__c);
            /*System.assertEquals(myTestAccount.CurrencyIsoCode, clonedAccount.CurrencyIsoCode);*/
            System.assertEquals(myTestAccount.RecordTypeId, clonedAccount.RecordTypeId);

            Opportunity createdOpportunity = [SELECT Id,
                                              Name,
                                              StageName
                                              FROM
                                              Opportunity
                                              WHERE
                                              AccountId = : clonedAccount.Id];

            System.assertEquals('Korean Opportunity', createdOpportunity.Name);
            System.assertEquals('Needs Analysis', createdOpportunity.StageName);





        }
    }

    @isTest static void test_CloneOwnerChange() {
        testdata();


        System.runAs(testUser) {

            Account myTestAccount = new Account(
                Name = 'My pretty Testaccount',
                Restaurant_Name__c = 'Tasty food',
                BillingStreet = 'BillingStreet',
                BillingPostalCode = 'BillingPostalCode',
                BillingCity = 'BillingCity',
                BillingState = 'BillingState',
                BillingCountry = 'BillingCountry',
                Menu_Typing_By_User__c = testUser.Id,
                Menu_Typing_Date_Start__c = Datetime.now(),
                Menu_Typing_Progress_Status__c = 'Taking Restaurant Online',
                Final_Check_Date__c = Datetime.now() + 14,
                Billing_Dong__c = 'Billing Dong',
                Billing_GunGu__c = 'Billing GunGu',
                Billing_Subdistrict__c = 'Billing subdistrict',
                Record_Country__c = 'Korea',
                CurrencyIsoCode = 'KRW',
                RecordTypeId = mapRecordtypes.get('Yogiyo_Account').Id
            );

            insert myTestAccount;

            Contact myTestConact = new Contact(
                LastName = 'Test',
                AccountId = myTestAccount.Id,
                CurrencyIsoCode = myTestAccount.CurrencyIsoCode,
                RecordTypeId = mapRecordtypes.get('Yogiyo_Contact').Id
            );
            insert myTestConact;

            Test.startTest();

            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(myTestAccount);
            CtrAccountClone ctrl = new CtrAccountClone(stdCtrl);
            ctrl.createOpportunityFlag = true;

            List<SelectOption> listOptions = ctrl.getCloneOptions();

            ctrl.selectedCloneOption = listOptions[2].getValue();

            ctrl.drawPanel();

            ctrl.doClone();

            Test.stopTest();


            List<Account> listAccount = [SELECT Id FROM Account WHERE Name = : myTestAccount.Name];

            System.assertEquals(2, listAccount.size());
        }
    }

    @isTest static void test_cancel() {
        testdata();
        PageReference returnRef;

        System.runAs(testUser) {

            Account myTestAccount = new Account(
                Name = 'My pretty Testaccount',
                Restaurant_Name__c = 'Tasty food',
                BillingStreet = 'BillingStreet',
                BillingPostalCode = 'BillingPostalCode',
                BillingCity = 'BillingCity',
                BillingState = 'BillingState',
                BillingCountry = 'BillingCountry',
                Menu_Typing_By_User__c = testUser.Id,
                Menu_Typing_Date_Start__c = Datetime.now(),
                Menu_Typing_Progress_Status__c = 'Taking Restaurant Online',
                Final_Check_Date__c = Datetime.now() + 14,
                Billing_Dong__c = 'Billing Dong',
                Billing_GunGu__c = 'Billing GunGu',
                Billing_Subdistrict__c = 'Billing subdistrict',
                Record_Country__c = 'Korea',
                CurrencyIsoCode = 'KRW',
                RecordTypeId = mapRecordtypes.get('Yogiyo_Account').Id
            );

            insert myTestAccount;

            Contact myTestConact = new Contact(
                LastName = 'Test',
                AccountId = myTestAccount.Id,
                CurrencyIsoCode = myTestAccount.CurrencyIsoCode,
                RecordTypeId = mapRecordtypes.get('Yogiyo_Contact').Id
            );
            insert myTestConact;

            Test.startTest();

            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(myTestAccount);
            CtrAccountClone ctrl = new CtrAccountClone(stdCtrl);

            returnRef = ctrl.cancel();

            Test.stopTest();

            System.assert(String.valueOf('/' + myTestAccount.Id).contains(returnRef.getUrl()));

        }
    }

    @isTest static void testErrorNoCloneOptionSelected() {
        testData();

        System.runAs(testUser) {
            Account myTestAccount = new Account(
                Name = 'My pretty Testaccount',
                Restaurant_Name__c = 'Tasty food',
                BillingStreet = 'BillingStreet',
                BillingPostalCode = 'BillingPostalCode',
                BillingCity = 'BillingCity',
                BillingState = 'BillingState',
                BillingCountry = 'BillingCountry',
                Menu_Typing_By_User__c = testUser.Id,
                Menu_Typing_Date_Start__c = Datetime.now(),
                Menu_Typing_Progress_Status__c = 'Taking Restaurant Online',
                Final_Check_Date__c = Datetime.now() + 14,
                Billing_Dong__c = 'Billing Dong',
                Billing_GunGu__c = 'Billing GunGu',
                Billing_Subdistrict__c = 'Billing subdistrict',
                Record_Country__c = 'Korea',
                CurrencyIsoCode = 'KRW',
                RecordTypeId = mapRecordtypes.get('Yogiyo_Account').Id
            );

            insert myTestAccount;

            Contact myTestConact = new Contact(
                LastName = 'Test',
                AccountId = myTestAccount.Id,
                CurrencyIsoCode = myTestAccount.CurrencyIsoCode,
                RecordTypeId = mapRecordtypes.get('Yogiyo_Contact').Id
            );
            insert myTestConact;

            Test.startTest();

            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(myTestAccount);
            CtrAccountClone ctrl = new CtrAccountClone(stdCtrl);

            ctrl.drawPanel();
            ctrl.doClone();

            Test.stopTest();
        }

    }

    @isTest static void citiesPerCountryReturnsCorrectly() {

        testdata();

        Country__c c = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
        insert c;

        List<SelectOption> res;

        BEIntegration_CountriesToCities__c conf = new BEIntegration_CountriesToCities__c(Name = 'Quito', Country_Code__c = 'EC');
        insert conf;

        Account myTestAccount = new Account(
            Name = 'My pretty Testaccount',
            Restaurant_Name__c = 'Tasty food',
            BillingStreet = 'BillingStreet',
            BillingPostalCode = 'BillingPostalCode',
            BillingCity = 'BillingCity',
            BillingState = 'BillingState',
            BillingCountry = 'Ecuador',
            Record_Country__c = 'Ecuador',
            CurrencyIsoCode = 'USD',
            RecordTypeId = mapRecordtypes.get('CD_Account').Id
        );

        insert myTestAccount;

        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(myTestAccount);
        CtrAccountClone ctrl = new CtrAccountClone(stdCtrl);

        res = ctrl.citiesPerCountry;

        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assertEquals(1, res.size());
        System.assertEquals('Quito', res[0].getValue());

    }


    @isTest
    static void testCloneAccountBranchMainToVirtual_Positive() {
        testdata();
        
        Account myTestGroup = new Account(
            Name = 'Test group',
            Restaurant_Name__c = 'Tasty food group',
            RecordTypeId = mapRecordtypes.get('DE_Account').Id,
            Type = 'Group'
        );
        insert myTestGroup;
       
        
        Account myTestBranch = new Account(
            Name = 'My pretty Testaccount',
            Restaurant_Name__c = 'Tasty food',
            RecordTypeId = mapRecordtypes.get('DE_Account').Id,
            ParentId = myTestGroup.Id,
            Type = 'Branch - Main'
        );
        insert myTestBranch;
        Contact c1 = new Contact (
            FirstName = 'asgasg',
            LastName = 'asgas',
            AccountId = myTestBranch.Id
        );
        insert c1;

        AccountContactRole acr = new AccountContactRole(
            AccountId = myTestBranch.Id,
            ContactId = c1.Id,
            Role = 'Influencer'
        );
        insert acr;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(myTestBranch);
        PageReference pageRef = Page.AccountClone;
        pageRef.getParameters().put('id', myTestBranch.Id);
        
        CtrAccountClone cloneMachine = new CtrAccountClone(sc);
        cloneMachine.theAccount.Franchise_Type__c = 'Directly managed';
        cloneMachine.selectedCloneOption = 'Account Clone Branch to Branch Virtual';
        cloneMachine.theClonedAccount = new Account(recordtypeid = myTestBranch.recordtypeid, Name = myTestBranch.Name);
        cloneMachine.createOpportunityFlag = false;
        
        test.startTest();
            cloneMachine.doClone();
        test.stopTest();
        
        System.assertNotEquals(null,  cloneMachine.theClonedAccount.Id, 'Account should have been cloned and inserted');
    }
    
    @isTest
    static void testCloneAccountBranchMainToVirtual_Negative() {
        testdata();
        
        Account myTestGroup = new Account(
            Name = 'Test group',
            Restaurant_Name__c = 'Tasty food group',
            RecordTypeId = mapRecordtypes.get('DE_Account').Id,
            Type = 'Brand'
        );
        insert myTestGroup;
       
        
        Account myTestBranch = new Account(
            Name = 'My pretty Testaccount',
            Restaurant_Name__c = 'Tasty food',
            RecordTypeId = mapRecordtypes.get('DE_Account').Id,
            ParentId = myTestGroup.Id,
            Type = 'Branch - Main'
        );
        insert myTestBranch;
        Contact c1 = new Contact (
            FirstName = 'asgasg',
            LastName = 'asgas',
            AccountId = myTestBranch.Id
        );
        insert c1;

        AccountContactRole acr = new AccountContactRole(
            AccountId = myTestBranch.Id,
            ContactId = c1.Id,
            Role = 'Influencer'
        );
        insert acr;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(myTestBranch);
        
        CtrAccountClone cloneMachine = new CtrAccountClone(sc);
        cloneMachine.selectedCloneOption = 'Account Clone Branch to Branch Virtual';
        cloneMachine.theClonedAccount = new Account(recordtypeid = myTestBranch.recordtypeid, Name = myTestBranch.Name);
        cloneMachine.createOpportunityFlag = false;
        
        test.startTest();
            cloneMachine.doClone();
        test.stopTest();
        
        System.assertEquals(null,  cloneMachine.theClonedAccount.Id, 'Account should NOT have been cloned and inserted');
    }

}