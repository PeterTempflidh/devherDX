/**
 * @description Test class for CreateFpOpportunityRecords_Batch class
 * @date 29.10.2019
 * @author Mantas Jurkunas
 * @see CreateFpOpportunityRecords_Batch
 */
@IsTest
public with sharing class CreateFpOpportunityRecords_Test {

    @TestSetup
    public static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
        Country__c country = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'USD');
        insert country;
        Company__c company = UnitTestDataFactory.createCompany('FP', 'FP', country);
        insert company;
        Account acc = UnitTestDataFactory.createAccount('Food Panda Customer', country, 'FP_Account');
        acc.Phone = '+85227367722';
        insert acc;

        insertBusinessConfig(country);

        Opportunity nbqcOpp = UnitTestDataFactory.createOpportunity('NB Quality Check', acc, 'FP_Opportunity', Date.today());
        nbqcOpp.StageName = 'Quality Check';
        nbqcOpp.Business_Type__c = 'New Business';
        Opportunity nbeqOpp = UnitTestDataFactory.createOpportunity('NB Editorial Queue', acc, 'FP_Opportunity', Date.today());
        nbeqOpp.StageName = 'Editorial Queue';
        nbeqOpp.Business_Type__c = 'New Business';
        Opportunity nbobOpp = UnitTestDataFactory.createOpportunity('NB Onboarding', acc, 'FP_Opportunity', Date.today());
        nbobOpp.StageName = 'Onboarding';
        nbobOpp.Business_Type__c = 'New Business';

        Opportunity ocqcOpp = UnitTestDataFactory.createOpportunity('OC Quality Check', acc, 'FP_Opportunity', Date.today());
        ocqcOpp.StageName = 'Quality Check';
        ocqcOpp.Business_Type__c = 'Owner Change';
        Opportunity oceqOpp = UnitTestDataFactory.createOpportunity('OC Editorial Queue', acc, 'FP_Opportunity', Date.today());
        oceqOpp.StageName = 'Editorial Queue';
        oceqOpp.Business_Type__c = 'Owner Change';
        Opportunity ocobOpp = UnitTestDataFactory.createOpportunity('OC Onboarding', acc, 'FP_Opportunity', Date.today());
        ocobOpp.StageName = 'Onboarding';
        ocobOpp.Business_Type__c = 'Owner Change';

        Opportunity wbqcOpp = UnitTestDataFactory.createOpportunity('WB Quality Check', acc, 'FP_Opportunity', Date.today());
        wbqcOpp.StageName = 'Quality Check';
        wbqcOpp.Business_Type__c = 'Win Back';
        Opportunity wbeqOpp = UnitTestDataFactory.createOpportunity('WB Editorial Queue', acc, 'FP_Opportunity', Date.today());
        wbeqOpp.StageName = 'Editorial Queue';
        wbeqOpp.Business_Type__c = 'Win Back';
        Opportunity wbobOpp = UnitTestDataFactory.createOpportunity('WB Onboarding', acc, 'FP_Opportunity', Date.today());
        wbobOpp.StageName = 'Onboarding';
        wbobOpp.Business_Type__c = 'Win Back';

        Opportunity lfcqcOpp = UnitTestDataFactory.createOpportunity('LFC Quality Check', acc, 'FP_Opportunity', Date.today());
        lfcqcOpp.StageName = 'Quality Check';
        lfcqcOpp.Business_Type__c = 'Legal Form Change';
        Opportunity lfceqOpp = UnitTestDataFactory.createOpportunity('LFC Editorial Queue', acc, 'FP_Opportunity', Date.today());
        lfceqOpp.StageName = 'Editorial Queue';
        lfceqOpp.Business_Type__c = 'Legal Form Change';
        Opportunity lfcobOpp = UnitTestDataFactory.createOpportunity('LFC Onboarding', acc, 'FP_Opportunity', Date.today());
        lfcobOpp.StageName = 'Onboarding';
        lfcobOpp.Business_Type__c = 'Legal Form Change';

        Opportunity uuqcOpp = UnitTestDataFactory.createOpportunity('UU Quality Check', acc, 'FP_Opportunity', Date.today());
        uuqcOpp.StageName = 'Quality Check';
        uuqcOpp.Business_Type__c = 'Upgrade/Upsell';

        Opportunity dgqcOpp = UnitTestDataFactory.createOpportunity('DG Quality Check', acc, 'FP_Opportunity', Date.today());
        dgqcOpp.StageName = 'Quality Check';
        dgqcOpp.Business_Type__c = 'Downgrade';

        Opportunity uupnlOpp = UnitTestDataFactory.createOpportunity('UU Promo And Logistics', acc, 'FP_Opportunity', Date.today());
        uupnlOpp.StageName = 'Promo and Logistics Queue';
        uupnlOpp.Business_Type__c = 'Upgrade/Upsell';

        Opportunity dgpnlOpp = UnitTestDataFactory.createOpportunity('DG Promo And Logistics', acc, 'FP_Opportunity', Date.today());
        dgpnlOpp.StageName = 'Promo and Logistics Queue';
        dgpnlOpp.Business_Type__c = 'Downgrade';

        List<Opportunity> opportunitiesForTest = new List<Opportunity>{
                nbqcOpp, nbeqOpp, nbobOpp, ocqcOpp,
                oceqOpp, ocobOpp, wbqcOpp, wbeqOpp,
                wbobOpp, lfcqcOpp, lfceqOpp, lfcobOpp,
                uuqcOpp, dgqcOpp, uupnlOpp, dgpnlOpp
        };
        insert opportunitiesForTest;
        List<Opportunity_Line_Item__c> opportunityLineItems = generateLineItemsForOpportunities(opportunitiesForTest, company, country);
        insert opportunityLineItems;
    }

    private static List<Opportunity_Line_Item__c> generateLineItemsForOpportunities(List<Opportunity> opportunities, Company__c company, Country__c country) {

        List<Opportunity_Line_Item__c> opportunityLineItems = new List<Opportunity_Line_Item__c>();
        List_Product_Group__c addChargesGroup = UnitTestDataFactory.createProductGroup(company, country, 'Add. Charges', 'FP_List_Product_Group');
        List_Product_Group__c marketingMerchandiseGroup = UnitTestDataFactory.createProductGroup(company, country, 'Marketing and Merchandise', 'FP_List_Product_Group');
        insert new List<List_Product_Group__c> {addChargesGroup, marketingMerchandiseGroup};

        List_Service_Price__c exclusiveCommission = new List_Service_Price__c(
                Name = 'Exclusive Commission MP',
                Commission_In_Percentage__c = 40,
                Minimum_Commission_in_Percentage__c = 31,
                Maximum_Commission_In_Percentage__c = 40,
                Id_Country__c = country.Id,
                Company__c = company.Id,
                Commission_Type__c = 'Percentage',
                Displayed_Name__c = 'Commission',
                RecordTypeId = LibRecordTypeHelper.getRecordTypeValue('FP_List_Service_Price'),
                Service_Type__c = 'Commission Fee'
        );

        List_Product_Price__c dataFee = new List_Product_Price__c(
                Is_Active__c = true,
                Id_List_Product_Group__c = addChargesGroup.Id,
                Product_Name__c = 'Data Fee',
                Product_Type__c = 'Recurring Fee',
                Displayed_Name__c = 'Data Fee',
                List_Price__c = 100,
                Installments__c = 1,
                Default_Quantity__c = 1,
                Id_Country__c = country.Id,
                Company__c = company.Id
        );
        List_Product_Price__c acrylicDisplay = new List_Product_Price__c(
                Is_Active__c = true,
                Id_List_Product_Group__c = marketingMerchandiseGroup.Id,
                Product_Name__c = 'Acrylic Display',
                Product_Type__c = 'Merchandise',
                Displayed_Name__c = 'Acrylic Display',
                List_Price__c = 0,
                Installments__c = 1,
                Default_Quantity__c = 1,
                Id_Country__c = country.Id,
                Company__c = company.Id
        );

        List_Add_On__c exclusivityAddon = new List_Add_On__c(
                Name = 'Exclusivity',
                Id_Country__c = country.Id,
                Contract_Addition__c = 'You are and stay exclusive!',
                Type__c = 'Exclusivity',
                RecordTypeId = LibRecordTypeHelper.getRecordTypeValue('FP_List_Add_On')

        );

        insert new List<SObject> {exclusiveCommission, dataFee, acrylicDisplay, exclusivityAddon};

        for (Opportunity opp: opportunities) {
            opportunityLineItems.add(
                    new Opportunity_Line_Item__c (
                            Name = 'Exclusive Commission MP',
                            Line_Item_Type__c = 'Service',
                            Sub_type__c = 'Commission Fee',
                            Id_Opportunity__c = opp.Id,
                            Commission_In_Percentage__c = 40,
                            Start_Date__c = Date.today(),
                            Id_List_Service_Price__c = exclusiveCommission.Id
                    )
            );
            opportunityLineItems.add(
                    new Opportunity_Line_Item__c (
                            Name = 'Data Fee',
                            Line_Item_Type__c = 'Product',
                            Sub_type__c = 'Recurring Fee',
                            Id_Opportunity__c = opp.Id,
                            Quantity__c = 1,
                            Listed_Price__c = 100,
                            Total_Amount__c = 100,
                            Id_List_Price_Product__c = dataFee.Id,
                            Product_Group__c = 'Add. Charges'
                    )
            );
            opportunityLineItems.add(
                    new Opportunity_Line_Item__c (
                            Name = 'Exclusivity',
                            Line_Item_Type__c = 'AddOn',
                            Sub_type__c = 'Exclusivity',
                            Id_Opportunity__c = opp.Id,
                            Id_List_Add_On__c = exclusivityAddon.Id
                    )
            );
            opportunityLineItems.add(
                    new Opportunity_Line_Item__c (
                            Name = 'Acrylic Display',
                            Line_Item_Type__c = 'Product',
                            Sub_type__c = 'Merchandise',
                            Id_Opportunity__c = opp.Id,
                            Quantity__c = 1,
                            Listed_Price__c = 0,
                            Total_Amount__c = 0,
                            Id_List_Price_Product__c = acrylicDisplay.Id,
                            Product_Group__c = 'Marketing and Merchandise'
                    )
            );
        }
        return opportunityLineItems;
    }

    private static void insertBusinessConfig(Country__c country) {
        Business_Config__c quoteConfig = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='QuoteReplyStage', Business_Rule_Value__c='Feedback Received', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig1 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='TemplateForQuoterefresh', Business_Rule_Value__c='Foodpanda_Quotes', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig2 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='DefaultContent', Business_Rule_Value__c='', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig3 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='DefaultSalutationFirstNameFirst', Business_Rule_Value__c='Dear {Salutation{FirstName {LastName', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig4 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='DefaultSalutationLastNameFirst', Business_Rule_Value__c='Dear {Salutation);', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig22 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='DefaultSalutation', Business_Rule_Value__c='Dear Customer', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig21 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='Greeting', Business_Rule_Value__c='Salutation,LastName', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig20 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='UseDefaultQuoteComment', Business_Rule_Value__c='TRUE', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig19 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='UseDefaultQuoteCommentMenuPrinting', Business_Rule_Value__c='TRUE', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig18 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='quoteEmailSubject', Business_Rule_Value__c='Quote', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig17 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='OrgWideEmailAddId', Business_Rule_Value__c='123456', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig16 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='OppQuoteProductRecordTypeid', Business_Rule_Value__c='FP_Opportunity_Quote_Line_Item', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig15 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='OppQuoteServiceRecordTypeid', Business_Rule_Value__c='FP_Opportunity_Quote_Line_Item', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig14 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='IncludeService', Business_Rule_Value__c='TRUE', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig13 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='IncludeProduct', Business_Rule_Value__c='TRUE', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig12 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='OppQuoteRecordTypeid', Business_Rule_Value__c='FP_Opportunity_Quote', Is_Active__c=true, Parent__c=true, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig11 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='OppQuoteEmailTemplate', Business_Rule_Value__c='Foodpanda_Quotes', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig10 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='minProbability', Business_Rule_Value__c='60', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig9 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='stagesToIgnore', Business_Rule_Value__c='Please Check', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig8 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='probability', Business_Rule_Value__c='65', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig7 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='entityNameMap', Business_Rule_Value__c='{"United Arab Emirates":"Talabat Middle East Internet Services Co. L.L.C","Kuwait":"Talabat General Trading and Contractig Company W.L.L","Qatar":"Talabat QFC L.L.C;QFC License No. 00387","Bahrain":"Talabat Services Company S.P.C","Oman":"Talabat Electronic Services L.L.C","Kingdom of Saudi Arabia":"Talabat for Restaurants Company W.L.L","Jordan":"Food on clicK.com W.L.L";', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig6 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='letterHeadAddressMap', Business_Rule_Value__c='', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);
        Business_Config__c quoteConfig5 = new Business_Config__c(Type__c = 'Process', Process_Name__c='OppQuoteProcess', Business_Rule_Name__c='BankDetailsMap', Business_Rule_Value__c='', Is_Active__c=true, Parent__c=false, Record_Type_Id__c='FP_Account', Id_Country__c = country.Id);

        Business_Config__c qualityCheckConf = new Business_Config__c(Process_Name__c='QualityCheckInternalCase', Business_Rule_Name__c='refundBusinessTypes', Business_Rule_Value__c='Refund', Is_Active__c=true, Parent__c=false, Type__c='Process', Record_Type_Id__c='FP_Opportunity', Id_Country__c = country.Id);
        Business_Config__c qualityCheckConf1 = new Business_Config__c(Process_Name__c='QualityCheckInternalCase', Business_Rule_Name__c='QualityCheckCaseForFinanceTeam', Business_Rule_Value__c='RecordTypeId='+LibRecordTypeHelper.getRecordTypeValue('FP_Internal_Case')+',type=Quality Check,subject=Quality Check,status=New,ownerid='+UserInfo.getUserId()+',Origin=Automatic', Is_Active__c=true, Parent__c=false, Type__c='Process', Record_Type_Id__c='FP_Opportunity', Id_Country__c = country.Id);
        Business_Config__c qualityCheckConf2 = new Business_Config__c(Process_Name__c='QualityCheckInternalCase', Business_Rule_Name__c='QualityCheckCaseFirstStage', Business_Rule_Value__c='RecordTypeId='+LibRecordTypeHelper.getRecordTypeValue('FP_Internal_Case')+',type=Quality Check,subject=Quality Check,status=New,ownerid='+UserInfo.getUserId()+',Origin=Automatic', Is_Active__c=true, Parent__c=false, Type__c='Process', Record_Type_Id__c='FP_Opportunity', Id_Country__c = country.Id);
        Business_Config__c qualityCheckConf3 = new Business_Config__c(Process_Name__c='QualityCheckInternalCase', Business_Rule_Name__c='QualityCheckCaseSecondStage', Business_Rule_Value__c='RecordTypeId='+LibRecordTypeHelper.getRecordTypeValue('FP_Internal_Case')+',Type=Quality Check,subject=Quality Check,status=Operation Check,ownerid='+UserInfo.getUserId()+',Origin=Automatic', Is_Active__c=true, Parent__c=false, Type__c='Process', Record_Type_Id__c='FP_Opportunity', Id_Country__c = country.Id);
        Business_Config__c qualityCheckConf4 = new Business_Config__c(Process_Name__c='QualityCheckInternalCase', Business_Rule_Name__c='UseBusinessTypeForCaseSubject', Business_Rule_Value__c='TRUE', Is_Active__c=true, Parent__c=false, Type__c='Process', Record_Type_Id__c='FP_Opportunity', Id_Country__c = country.Id);
        Business_Config__c qualityCheckConf5 = new Business_Config__c(Process_Name__c='QualityCheckInternalCase', Business_Rule_Name__c='QualityCheckCase', Business_Rule_Value__c='RecordTypeId='+LibRecordTypeHelper.getRecordTypeValue('FP_Internal_Case')+',type=Quality Check,subject=Quality Check,status=New,ownerid='+UserInfo.getUserId()+',Origin=Automatic', Is_Active__c=true, Parent__c=false, Type__c='Process', Record_Type_Id__c='FP_Opportunity', Id_Country__c = country.Id);
        Business_Config__c qualityCheckConf6 = new Business_Config__c(Process_Name__c='QualityCheckInternalCase', Business_Rule_Name__c='CheckOpenCaseType', Business_Rule_Value__c='Quality Check,Menu Processing', Is_Active__c=true, Parent__c=false, Type__c='Process', Record_Type_Id__c='FP_Opportunity', Id_Country__c = country.Id);
        Business_Config__c qualityCheckConf7 = new Business_Config__c(Process_Name__c='QualityCheckInternalCase', Business_Rule_Name__c='StageName', Business_Rule_Value__c='Quality Check Request', Is_Active__c=true, Parent__c=true, Type__c='Process', Record_Type_Id__c='FP_Opportunity', Id_Country__c = country.Id);

        Business_Config__c mpConfig = new Business_Config__c(Process_Name__c='GenericMenuProcessing', Business_Rule_Name__c='keyAccountOwnerId', Business_Rule_Value__c=UserInfo.getUserId(), Is_Active__c=true, Parent__c=false, Id_Country__c=country.Id, Type__c='Process', Record_Type_Id__c='FP_Opportunity');
        Business_Config__c mpConfig1 = new Business_Config__c(Process_Name__c='GenericMenuProcessing', Business_Rule_Name__c='BusinessType-Upgrade', Business_Rule_Value__c='Case_Reason__c=Contract Update,subject=Upgrade', Is_Active__c=true, Parent__c=false, Id_Country__c=country.Id, Type__c='Process', Record_Type_Id__c='FP_Opportunity');
        Business_Config__c mpConfig2 = new Business_Config__c(Process_Name__c='GenericMenuProcessing', Business_Rule_Name__c='BusinessType-Downgrade', Business_Rule_Value__c='Case_Reason__c=Contract Update,subject=Downgrade', Is_Active__c=true, Parent__c=false, Id_Country__c=country.Id, Type__c='Process', Record_Type_Id__c='FP_Opportunity');
        Business_Config__c mpConfig3 = new Business_Config__c(Process_Name__c='GenericMenuProcessing', Business_Rule_Name__c='keyAccountCategory', Business_Rule_Value__c='Key Account', Is_Active__c=true, Parent__c=false, Id_Country__c=country.Id, Type__c='Process', Record_Type_Id__c='FP_Opportunity');
        Business_Config__c mpConfig4 = new Business_Config__c(Process_Name__c='GenericMenuProcessing', Business_Rule_Name__c='ClosedReason', Business_Rule_Value__c='Take Online is not possible,Invalid,Duplicate', Is_Active__c=true, Parent__c=false, Id_Country__c=country.Id, Type__c='Process', Record_Type_Id__c='FP_Opportunity');
        Business_Config__c mpConfig5 = new Business_Config__c(Process_Name__c='GenericMenuProcessing', Business_Rule_Name__c='OpportunityType', Business_Rule_Value__c='Existing Business,New Business,Contract Only,Contract & Product,Additional Contract,Administration', Is_Active__c=true, Parent__c=false, Id_Country__c=country.Id, Type__c='Process', Record_Type_Id__c='FP_Opportunity');
        Business_Config__c mpConfig6 = new Business_Config__c(Process_Name__c='GenericMenuProcessing', Business_Rule_Name__c='StageName', Business_Rule_Value__c='Editorial Queue', Is_Active__c=true, Parent__c=true, Id_Country__c=country.Id, Type__c='Process', Record_Type_Id__c='FP_Opportunity');
        Business_Config__c mpConfig7 = new Business_Config__c(Process_Name__c='GenericMenuProcessing', Business_Rule_Name__c='Menu Processing Case', Business_Rule_Value__c='RecordTypeId='+LibRecordTypeHelper.getRecordTypeValue('FP_Entry_Case')+',ownerId= '+UserInfo.getUserId()+',type=Menu Processing,subject=Menu Processing,status=New,Origin=Automatic', Is_Active__c=true, Parent__c=false, Id_Country__c=country.Id, Type__c='Process', Record_Type_Id__c='FP_Opportunity');

        Business_Config__c plConfig = new Business_Config__c(Process_Name__c='PhotoListingProcess', Business_Rule_Name__c='stageName', Business_Rule_Value__c='Editorial Queue', Is_Active__c=true, Parent__c=true, Type__c='Process', Id_Country__c=country.Id, Record_Type_Id__c='FP_Opportunity');
        Business_Config__c plConfig1 = new Business_Config__c(Process_Name__c='PhotoListingProcess', Business_Rule_Name__c='PhotoListingCaseFields', Id_Country__c=country.Id, Business_Rule_Value__c='RecordTypeId='+LibRecordTypeHelper.getRecordTypeValue('FP_Entry_Case')+',ownerId= '+UserInfo.getUserId()+',type=Photo Listing,subject=Photo Listing Process,status=New', Is_Active__c=true, Parent__c=false, Type__c='Process', Record_Type_Id__c='FP_Opportunity');

        Business_Config__c addonConfig = new Business_Config__c(Process_Name__c='AddonCreation', Business_Rule_Name__c='Deal / Promotion', Business_Rule_Value__c='New', Is_Active__c=true, Parent__c=true, Type__c='Process', Record_Type_Id__c='FP_Opportunity_Quote_Line_Item', Id_Country__c=country.Id);
        Business_Config__c addonConfig1 = new Business_Config__c(Process_Name__c='AddonCreation', Business_Rule_Name__c='Extra Terms and Conditions', Business_Rule_Value__c='Active', Is_Active__c=true, Parent__c=false, Type__c='Process', Record_Type_Id__c='FP_Opportunity_Quote_Line_Item', Id_Country__c=country.Id);
        Business_Config__c addonConfig2 = new Business_Config__c(Process_Name__c='AddonCreation', Business_Rule_Name__c='Exclusivity', Business_Rule_Value__c='Active', Is_Active__c=true, Parent__c=false, Type__c='Process', Record_Type_Id__c='FP_Opportunity_Quote_Line_Item', Id_Country__c=country.Id);
        Business_Config__c addonConfig3 = new Business_Config__c(Process_Name__c='AddonCreation', Business_Rule_Name__c='AddonRecType', Business_Rule_Value__c='FP_Add_On', Is_Active__c=true, Parent__c=false, Type__c='Process', Record_Type_Id__c='FP_Opportunity_Quote_Line_Item', Id_Country__c=country.Id);

        insert new List<Business_Config__c> {
                quoteConfig, quoteConfig1, quoteConfig2, quoteConfig3,
                quoteConfig4, quoteConfig5, quoteConfig6, quoteConfig7,
                quoteConfig8, quoteConfig9, quoteConfig10, quoteConfig11,
                quoteConfig12, quoteConfig13, quoteConfig14, quoteConfig15,
                quoteConfig16, quoteConfig17, quoteConfig18, quoteConfig19,
                quoteConfig20, quoteConfig21, quoteConfig22, qualityCheckConf,
                qualityCheckConf1, qualityCheckConf2, qualityCheckConf3, qualityCheckConf4,
                qualityCheckConf5, qualityCheckConf6, qualityCheckConf7, mpConfig,
                mpConfig1, mpConfig2, mpConfig3, mpConfig4,
                mpConfig5, mpConfig6, mpConfig7, plConfig, plConfig1,
                addonConfig, addonConfig1, addonConfig2, addonConfig3
        };
    }

    /**
     * @description Test batch to create items related to the opportunity based on opportunity stage and type
     */
    @IsTest
    public static void test_createFpOpportunityRecords() {
        final Set<String> scenario1BusinessTypes= new Set<String>{'New Business', 'Owner Change', 'Win Back', 'Legal Form Change'};
        final Set<String> scenario2BusinessTypes= new Set<String>{'Upgrade/Upsell', 'Downgrade'};

        Test.startTest();
            CreateFpOpportunityRecords_Batch.run();
        Test.stopTest();

        List<Opportunity> opportunities = Opportunity_Selector.getAllWithChildren();
        for (Opportunity opp: opportunities) {
            System.assertEquals(opp.Opportunity_Line_Items__r.size(), opp.Opportunity_Quote_Line_Items__r.size(), 'Incorrect amount of Quote line items');
            if (scenario1BusinessTypes.contains(opp.Business_Type__c)) {
                validateScenario1Opportunity(opp);
            } else if (scenario2BusinessTypes.contains(opp.Business_Type__c)) {
                validateScenario2Opportunity(opp);
            } else {
                System.assert(false, 'Invalid opportunity business type for test scenario: ' + opp.Business_Type__c);
            }
        }
        System.assertEquals(10, [SELECT Id FROM Add_on_Service__c].size(), 'Incorrect amount of addons created.');
    }

    private static void validateScenario1Opportunity (final Opportunity opp) {
        if (opp.StageName.equals('New') || opp.StageName.equals('Verbal Agreement')) {
            System.assert(opp.Cases__r == null || opp.Cases__r.isEmpty(), 'Inserted cases for invalid opportunity stage');
        } else if (opp.StageName.equals('Quality Check')) {
            System.assertEquals(1, opp.Opportunity_Quotes__r.size(), 'Failed to create quote for quality check');
            for (Opportunity_Quote__c oppQuote: opp.Opportunity_Quotes__r) {
                System.assertEquals('Accepted', oppQuote.Status__c);
            }
            System.assertEquals(1, opp.Cases__r.size(), 'Failed to create Case for quality check');
            for (Case cs: opp.Cases__r) {
                System.assertEquals('New', cs.Status);
                System.assertEquals('Quality Check', cs.Type);
            }
        } else if (opp.StageName.equals('Editorial Queue')) {
            System.assertEquals(1, opp.Opportunity_Quotes__r.size(), 'Failed to create quote for Editorial Queue');
            for (Opportunity_Quote__c oppQuote: opp.Opportunity_Quotes__r) {
                System.assertEquals('Accepted', oppQuote.Status__c);
            }
            System.assertEquals(1, opp.Cases__r.size(), 'Failed to create Case for Editorial Queue');
            for (Case cs: opp.Cases__r) {
                Boolean qualityCheckCase = cs.Status.equals('Closed') && cs.Closed_Reason__c.equals('Successful') && cs.Type.equals('Quality Check');
                System.assert(qualityCheckCase, 'Incorrect case created for Editorial Queue: ' + cs.Type);
            }
        } else if (opp.StageName.equals('Onboarding')) {
            System.assertEquals(1, opp.Opportunity_Quotes__r.size(), 'Failed to create quote for Onboarding');
            for (Opportunity_Quote__c oppQuote: opp.Opportunity_Quotes__r) {
                System.assertEquals('Accepted', oppQuote.Status__c);
            }
            System.assertEquals(1, opp.Cases__r.size(), 'Failed to create Case for Onboarding');
            for (Case cs: opp.Cases__r) {
                Boolean qualityCheckCase = cs.Status.equals('Closed') && cs.Closed_Reason__c.equals('Successful') && cs.Type.equals('Quality Check');
                System.assert(qualityCheckCase, 'Incorrect case created for Onboarding: ' + cs.Type);
            }
        } else {
            System.assert(false, 'Invalid Stage for scenario1 opportunity: ' + opp.StageName);
        }
    }

    private static void validateScenario2Opportunity (final Opportunity opp) {
        if (opp.StageName.equals('New') || opp.StageName.equals('Verbal Agreement')) {
            System.assert(opp.Cases__r == null || opp.Cases__r.isEmpty(), 'Inserted cases for invalid opportunity stage');
        } else if (opp.StageName.equals('Quality Check')) {
            System.assertEquals(1, opp.Opportunity_Quotes__r.size(), 'Failed to create quote for quality check');
            for (Opportunity_Quote__c oppQuote: opp.Opportunity_Quotes__r) {
                System.assertEquals('Accepted', oppQuote.Status__c);
            }
            System.assertEquals(1, opp.Cases__r.size(), 'Failed to create Case for quality check');
            for (Case cs: opp.Cases__r) {
                System.assertEquals('New', cs.Status);
                System.assertEquals('Quality Check', cs.Type);
            }
        } else if (opp.StageName.equals('Promo and Logistics Queue')) {
            System.assertEquals(1, opp.Opportunity_Quotes__r.size(), 'Failed to create quote for Promo and Logistics Queue');
            for (Opportunity_Quote__c oppQuote: opp.Opportunity_Quotes__r) {
                System.assertEquals('Accepted', oppQuote.Status__c);
            }
            System.assertEquals(1, opp.Cases__r.size(), 'Failed to create Case for Promo and Logistics Queue');
            for (Case cs: opp.Cases__r) {
                System.assertEquals('Closed', cs.Status);
                System.assertEquals('Quality Check', cs.Type);
            }
        } else {
            System.assert(false, 'Invalid Stage for scenario2 opportunity: ' + opp.StageName);
        }
    }

}