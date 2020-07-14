/**
* @author DeliveryHero
* @date  2019
*
* @description Test class for ClsCaseProcessor
*/

@isTest
private class UnitTestClsCaseProcessor {
    private static User runningUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'testUser@deliveryhero.com', 'Yogiyo', 'KR');
    static Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Case'});
    private static Account acc;
    private static Account acc_uk;
    private static Account acc_cd;
    private static Country__c c;
    private static Country__c c_au;
    private static Country__c c_se;
    private static Country__c c_uk;
    private static country__c c_cd;
    private static country__c c_de;
    private static Opportunity opp;
    private static Opportunity opp_au;
    private static Opportunity opp_uk;
    private static Opportunity opp_cd;
    private static Account acc_au;
    private static Account acc_se;
    private static Account acc_de;
    private static List<Asset__c> assetsUK;
    private static List<Stock_Item__c> stockListUK;
    private static Company__c com_uk;
    private static company__c com_cd;
    private static Company__c com;

    private static User runningAdminUser = UnitTestDataFactory.createUser('System Administrator', 'testAdmin@deliveryhero.com', 'Yogiyo;UK', 'KR,UK');

    static {

        runningUser.CountryCode__c = 'KR;AU;UK';
        runningUser.Company_Name__c = 'Yogiyo;DH_AU;HH';

        insert new List<sObject> {runningAdminUser,runningUser};
        
        PermissionSet ps = [SELECT Id From PermissionSet WHERE Name = 'Exclude_from_Validation'];
        insert new PermissionSetAssignment(AssigneeId = runningUser.Id, PermissionSetId = ps.Id );    
        insert new PermissionSetAssignment(AssigneeId = runningAdminUser.Id, PermissionSetId = ps.Id ); 

        System.runAs(runningAdminUser) {

            UnitTestDataFactory.getRecordtypeValues();
            Platform_Country__c pt1 = new Platform_Country__c(name = 'FOCPlatform', Country__c = 'Lebanon,Qatar,United Arab Emirates');
            Platform_Country__c pt2 = new Platform_Country__c(name = 'TalabatPlatform', Country__c = 'Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates');
            List<MidasIntegration__c> midasIntg = new List<MidasIntegration__c>();
            midasIntg.add(new MidasIntegration__c(name = 'UK', EndPoint__c = 'http://midas.medusa-hero.com/backend/', AuthenticationToken__c = 'WyI0IiwiYzUwNjRkMmQ2MWUwNTE3YjVhNjRmMTk4Yjc2NmFiODgiXQ.CgtJbA.kFY4BLsKd3XXiXg7QtVxmLqZ7i0'));
            insert midasIntg;
            List<InterestedOppClosedLost__c> intOppClosedSetting = new List<InterestedOppClosedLost__c>();
            intOppClosedSetting.add(new InterestedOppClosedLost__c(name = 'Interested', Values__c = 'Not enough capacity', CaseClosingReason__c = 'Successful'));
            insert intOppClosedSetting;
            c = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            c_au = UnitTestDataFactory.createCountry('AU', 'Australia', 'AUD');
            c_se = UnitTestDataFactory.createCountry('SE', 'Sweden', 'SEK');
            c_uk = UnitTestDataFactory.createCountry('UK', 'United Kingdom', 'GBP');
            c_cd = UnitTestDataFactory.createCountry('CD', 'Colombia', 'COP');

            c_cd = UnitTestDataFactory.createCountry('CD', 'Colombia', 'COP');
            c_de = UnitTestDataFactory.createCountry('DE', 'Germany', 'EUR');

            com = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', c);
            Company__c com_au = UnitTestDataFactory.createCompany('Delivery Hero Australia', 'DH_AU', c_au);
            com_cd = UnitTestDataFactory.createCompany('ClickDelivery', 'CD', c_cd);
            com_uk = UnitTestDataFactory.createCompany('Hungryhouse', 'HH', c_uk);
            insert new List<sObject> {c, c_au, c_uk, com, com_au, com_uk, pt1, pt2, c_cd, com_cd,c_se};
            List<sObject> ls = Test.loadData(Business_Config__c.sObjectType, 'BusinessConfigData');

            System.runAs(runningUser) {
                acc = UnitTestDataFactory.createAccount('TestAccount', c, 'Yogiyo_Account');
                acc_au = UnitTestDataFactory.createAccount('TestAccount', c_au, 'DH_AU_Account');
                acc_se = UnitTestDataFactory.createAccount('TestAccount', c_se, 'SE_Account');
                acc_uk = UnitTestDataFactory.createAccount('TestAccount', c_uk, 'UK_Account');
                acc_cd = UnitTestDataFactory.createAccount('TestAccount', c_cd, 'CD_Account');
                acc_de = UnitTestDataFactory.createAccount('TestAccount', c_de, 'DE_Account');
                acc_au.Relay_Method__c = 'Email';
                insert new List<sObject> {acc, acc_au, acc_uk, acc_cd, acc_se, acc_de};

                List<Contact> contactList = UnitTestDataFactory.createContacts(new List<Account> {acc}, 'testContact', 'firstname', null, 'owner', 1, 'testCt', 'Yogiyo_Contact');
                insert contactList;
                
                opp = UnitTestDataFactory.createOpportunity('TestOpp123', acc, 'Yogiyo_Opportunity', Date.today());
                opp.Type = 'Contract Only';
                opp_au = UnitTestDataFactory.createOpportunity('TestOpp123', acc_au, 'DH_AU_Opportunity', Date.today());
                opp_au.type = 'Contract Only';
                insert  new List<sObject> {opp, opp_au};
                    
                opp_uk = UnitTestDataFactory.createOpportunity('TestOpp123', acc_uk, 'UK_Opportunity', Date.today());
                opp_cd = UnitTestDataFactory.createOpportunity('TestOpp123', acc_cd, 'CD_Opportunity', Date.today());
                opp_cd.business_type__C = 'New Business';
                opp_cd.StageName = 'Collecting Documents';
                opp_cd.CurrencyIsoCode = 'EUR';
                opp_uk.type = 'Product Only';
                opp_cd.type = 'Product Only';

                insert new List<sObject> {opp_cd,opp_uk};
                    
                Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c = opp_uk.id, status__c = 'Draft');
                newQuote.recordtypeid = LibRecordTypeHelper.getRecordTypeValue('UK_Opportunity_Quote');
                
                Tarif__c t = UnitTestDataFactory.createTarif(com_uk, c_uk , 'Menu Printing', 'UK_Tarif', false);
                
                insert new List<sObject> {t,newQuote};

                List_Add_on__c lao = new List_Add_on__c(Is_Active__c=true,Type__c='Deal / Promotion',Company__c=com_uk.id,id_country__c=c_uk.id,name='Test add on');
                lao.recordtypeid=LibRecordTypeHelper.getRecordTypeValue('UK_List_Add_On');
                List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com_uk, c_uk , 'Apple', 'UK_List_Product_Group');
                List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com_uk, c_uk , 'Menu Printing', 'UK_List_Product_Group');
                insert new List<SObject> {lao,lpg, lpg1};

                List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com_uk, c_uk , 'Menu Printing with website', lpg.id, 'UK_List_Product_Price', 1, true, 100, 1, false, 20);
                List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com_uk, c_uk , 'Menu Printing without website', lpg1.id, 'UK_List_Product_Price', 1, true, 100, 1, false, 20);
                lpp1.product_type__c = 'Menu Printing';
                lpp.product_type__c = 'Menu Printing';
                lpp.Requires_Branding__c = true;
                lpp.Requires_Asset__c = true;

                insert new List<sobject> {lpp1, lpp};

                ClsCaseProcessor.donotValidateOppStage  = true;

                List<Opportunity_Quote_Line_Item__c> oqp = UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote, lpp.id, lpg.id, 4, true, 'UK_Opportunity_Quote_Line_Item', 1, '20', 200.0, 2, 300.0, 'Product');
                oqp[0].Id_Opportunity__c = opp_uk.id;

                oqp.add(new Opportunity_Quote_Line_Item__c(Id_Opportunity__c=opp_uk.id,line_item_type__c='AddOn',sub_type__c='Deal / Promotion', id_opportunity_quote__c=newQuote.id,id_list_add_on__c=lao.id));
                oqp[1].Recordtypeid=LibRecordTypeHelper.getRecordTypeValue('UK_Opportunity_Quote_Line_Item');
                insert oqp;
                
                newQuote.status__c = 'Accepted';
                update newQuote;
            }


        }

    }



    @isTest static void nonContractedMenuChange_positive() {
        System.runAs(runningAdminUser) {
			Test.startTest();
            acc.Non_Contracted__c = true;
            update acc;
            List<Opportunity_Quote__c> quotes;
            quotes = UnitTestDataFactory.createOpportunityQuotes(opp,1,'Yogiyo_Opportunity_Quote','Accepted','test',100,100,'Test','Test',10);
			insert quotes;
            
            Case qualityCase = new Case(Opportunity__c = opp.id, type = 'Quality Check', AccountId = opp.AccountId, RecordTypeId = mapRecordtypes.get('Yogiyo_Internal_Case').id);
            qualityCase.Status = 'Closed';
            qualityCase.Closed_Reason__c = 'Successful';

            Case menuProcessingCase = new Case(Type = 'Menu Processing', Subject = '    ', RecordTypeId = mapRecordtypes.get('Yogiyo_Entry_Case').id , Status = 'New');
            menuProcessingCase.Opportunity__c = opp.id;
            menuProcessingCase.AccountId = opp.AccountId;
            menuProcessingCase.Person_In_Charge__c = 'testUser';
            menuProcessingCase.Menu_Typed_Date__c = Datetime.now();
            menuProcessingCase.Person_in_Charge_Final_Check__c = 'testUser';
            menuProcessingCase.Final_Check_Date__c = Datetime.now();
            menuProcessingCase.Person_In_Charge_Take_Online__c = 'testUser';
            menuProcessingCase.Take_Online_Date__c = Datetime.now();
            
            insert new List<sObject>{qualityCase,menuProcessingCase };
                
            opp.Non_Contracted__c = true;            
            menuProcessingCase.status = 'Closed';
            
            update new List<sObject>{opp,menuProcessingCase};
            
            opp.stageName = 'Closed Won';
            update opp;
            Test.stopTest();
        }
        List<Case> listCase = [select id from case where type = 'Convert to Contract'];
        System.assertEquals(listCase.size(), 1);
    }

    @isTest static void terminationCaseFlow_retention_successful() {
        System.runAs(runningAdminUser) {

            Case terminationCase = new Case(


                    AccountId = acc_cd.id,
                    Type = 'Restaurant Operations',
                    RecordTypeId = mapRecordtypes.get('CD_Restaurant_Operations').id,

                    Status = 'New',
                    Order_Number__c = '0'

            );
            insert terminationCase;

            //terminationCase.Status = 'In retention';
            terminationCase.Status = 'Closed';
            terminationCase.Closed_Reason__c = 'Successful';

            system.debug('terminationCase-->'+terminationCase);
            Test.startTest();
            update terminationCase;
            Case retentionCase = [SELECT Id, ParentId, Type, Status, Closed_Reason__c FROM Case WHERE ParentId = : terminationCase.Id];
            System.assertEquals('Take Online', retentionCase.Type);
            retentionCase.Status = 'Closed';
            retentionCase.Closed_Reason__c = 'Successful';
            update retentionCase;
            Test.stopTest();
            terminationCase = [SELECT Id, IsClosed FROM Case WHERE Id = : terminationCase.Id];
            System.assertEquals(true, terminationCase.IsClosed);

        }
    }

    //also tests takeoffline flow
    @isTest static void terminationCaseFlow_retention_unsuccessful() {
        System.runAs(runningAdminUser) {
            Case terminationCase = new Case(


                    AccountId = acc_cd.id,

                    Type = 'Restaurant Operations',
                    RecordTypeId = mapRecordtypes.get('CD_Restaurant_Operations').id,

                    Status = 'New',
                    Order_Number__c = '0'


            );
            insert terminationCase;

            //terminationCase.Status = 'In retention';
            terminationCase.Status = 'Closed';
            terminationCase.Closed_Reason__c = 'Successful';

            Test.startTest();
            update terminationCase;
            Case retentionCase = [SELECT Id, ParentId, Type, Status, Closed_Reason__c FROM Case WHERE ParentId = : terminationCase.Id];
            System.assertEquals('Take Online', retentionCase.Type);
            retentionCase.Status = 'Closed';
            retentionCase.Closed_Reason__c = 'Not Successful';
            retentionCase.Comments_del__c = 'test coments';
            retentionCase.Root_Cause__c = 'test';
            update retentionCase;

            Test.stopTest();

            terminationCase = [SELECT Id, IsClosed FROM Case WHERE Id = : terminationCase.Id];
            System.assertEquals(true, terminationCase.IsClosed);


        }
    }

    @isTest static void terminationCaseFlow_takeOffline_successful() {
        System.runAs(runningAdminUser) {
            Case terminationCase = new Case(

                    AccountId = acc_cd.id,
                    Type = 'Restaurant Operations',
                    RecordTypeId = mapRecordtypes.get('CD_Restaurant_Operations').id,

                    Status = 'New',
                    Order_Number__c = '0'


            );
            system.debug('cases-->0'+ [SELECT Id, ParentId, Type, Status, Closed_Reason__c FROM Case]);

            insert terminationCase;

            terminationCase.Status = 'Closed';
            terminationCase.Closed_Reason__c = 'Not Successful';
            terminationCase.Root_Cause__c = 'test';
            terminationCase.Comments_del__c = 'test';

            Test.startTest();
            update terminationCase;
            system.debug('cases-->'+ [SELECT Id, ParentId, Type, Status, Closed_Reason__c FROM Case]);
            Case takeOfflineCase = [SELECT Id, ParentId, Type, Status, Closed_Reason__c FROM Case WHERE ParentId = : terminationCase.Id];
            System.assertEquals('Take Offline', takeOfflineCase.Type);
            takeOfflineCase.Status = 'Closed';
            takeOfflineCase.Closed_Reason__c = 'Successful';
            update takeOfflineCase;
            Test.stopTest();
        }
    }
	/*******************************************************************************************************
    * @description Test Class for checking Menu Processing with Positive output
    * @updated 18-May-2019 PKALINA: SP-3544 Regarding exceeding SOQL Governor Limits
    * @update 17-Jun-2019 PKALINA: Updated
    * @param 
    * @return
    */
    @isTest
    public static void MenuProcessingClosingAction_Positive() {
        System.runAs(runningUser) {
            Test.startTest();
            Opportunity opp_au1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc_de, 'DE_Opportunity', Date.today());
            opp_au1.StageName = 'Collecting Documents';
            opp_au1.type = 'Contract Only';
            opp_au1.Business_Type__c = 'New Business';
            opp_au1.CurrencyIsoCode = 'EUR';
            insert opp_au1;

            List<Opportunity_Quote__c> quotes = UnitTestDataFactory.createOpportunityQuotes(opp_au1,1,'DE_Opportunity_Quote','Accepted','test',100,100,'Test','Test',10);
			
           	Tarif__c t = UnitTestDataFactory.createTarif(com_uk, c_de , 'Menu Printing', 'DE_Tarif', false);

            List_Add_on__c lao = new List_Add_on__c(Is_Active__c=true,Type__c='Deal / Promotion',Company__c=com_uk.id,id_country__c=c_uk.id,name='Test add on');
            lao.recordtypeid=LibRecordTypeHelper.getRecordTypeValue('UK_List_Add_On');
            
            List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com_uk, c_de , 'Apple', 'DE_List_Product_Group'); 
            
            Opportunity opp_au2 = new Opportunity();
            opp_au2.StageName = 'Editorial Queue';
            opp_au2.probability = 95;
            opp_au2.ID = opp_au1.ID;
            
            Case qualityCheckCase = new Case(Type = 'Quality Check', Subject = 'Quality Check', RecordTypeId = mapRecordtypes.get('DE_Internal_Case').id , Status = 'New');
            qualityCheckCase.Opportunity__c = opp_au1.id;
            qualityCheckCase.AccountId = opp_au1.AccountId;
            
            Case qualityCheckCaseCLOSE = new Case();
            qualityCheckCaseCLOSE.Status = 'Closed';
            qualityCheckCaseCLOSE.Closed_Reason__c = 'Successful';

            Case menuProcessingCase = new Case(Type = 'Menu Processing', Subject = 'Menu Processing', RecordTypeId = mapRecordtypes.get('DE_Entry_Case').id , Status = 'New');
            menuProcessingCase.Opportunity__c = opp_au1.id;
            menuProcessingCase.AccountId = opp_au1.AccountId;
            
            Account updateAccount = new Account(Id = opp_au1.AccountId, Is_Tested__c = true);

            Case menuProcessingCaseCLOSE = new Case();
            menuProcessingCaseCLOSE.Status = 'Closed';
            menuProcessingCaseCLOSE.Closed_Reason__c = 'Take Online';
            
            
            insert quotes;
            
            insert new List<sObject>{t,lao,lpg};
            List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com_uk, c_de , 'Menu Printing with website', lpg.id, 'DE_List_Product_Price', 1, true, 100, 1, false, 20);
            insert lpp; 
            
            List<Opportunity_Quote_Line_Item__c> quotesLI = UnitTestDataFactory.createOpportunityQuoteLineItems(quotes[0], lpp.id, lpg.id, 1, true, 'DE_Opportunity_Quote_Line_Item', 1, '20', 200.0, 2, 300.0, 'Product');
            quotesLI[0].Id_Opportunity__c = opp_au1.id;
            insert quotesLI;

            Trigger_Manager__c manager = Trigger_Manager__c.getInstance();
            manager.Deactivate_Case_Trigger__c = true;
            manager.Deactivate_Opportunity_Trigger__c = true;
            insert new List<sObject>{manager,qualityCheckCase};
            
            qualityCheckCaseCLOSE.ID = qualityCheckCase.ID;
            manager.Deactivate_Opportunity_Trigger__c = false;
            manager.Deactivate_Case_Trigger__c = false;
            
            update new List<sObject>{qualityCheckCaseCLOSE,opp_au2,manager};
            
            insert menuProcessingCase;
            menuProcessingCaseCLOSE.ID = menuProcessingCase.ID;
            update new List<sObject>{updateAccount,menuProcessingCase};
            Test.stopTest();
            
            Opportunity result = [select id, stageName from Opportunity where id = :opp_au1.id];
        }
    }

	/*******************************************************************************************************
    * @description Test Class for checking Menu Processing with Positive output
    * @updated 18-May-2019 PKALINA: SP-3544 Regarding exceeding SOQL Governor Limits
    * @update 17-Jun-2019 PKALINA: Updated
    * @param 
    * @return
    */
    @isTest 
    public static void MenuProcessingClosingAction_Positive2() {
        System.runAs(runningUser) {
            Opportunity opp_au1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc_de, 'DE_Opportunity', Date.today());
            opp_au1.StageName = 'Collecting Documents';
            opp_au1.type = 'Contract Only';
            opp_au1.Business_Type__c = 'New Business';
            opp_au1.CurrencyIsoCode = 'EUR';
            insert opp_au1;

            List<Opportunity_Quote__c> quotes = UnitTestDataFactory.createOpportunityQuotes(opp_au1,1,'DE_Opportunity_Quote','Accepted','test',100,100,'Test','Test',10);
			
            Tarif__c t = UnitTestDataFactory.createTarif(com_uk, c_de , 'Menu Printing', 'DE_Tarif', false);

            List_Add_on__c lao = new List_Add_on__c(Is_Active__c=true,Type__c='Deal / Promotion',Company__c=com_uk.id,id_country__c=c_uk.id,name='Test add on');
            lao.recordtypeid=LibRecordTypeHelper.getRecordTypeValue('UK_List_Add_On');
            
            List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com_uk, c_de , 'Apple', 'DE_List_Product_Group');  
                        
            Opportunity opp_au2 = new Opportunity();
            opp_au2.StageName = 'Editorial Queue';
            opp_au2.probability = 95;
            opp_au2.ID = opp_au1.ID;
            
			Case qualityCheckCase = new Case(Type = 'Quality Check', Subject = 'Quality Check', RecordTypeId = mapRecordtypes.get('DE_Internal_Case').id , Status = 'New');
            qualityCheckCase.Opportunity__c = opp_au1.id;
            qualityCheckCase.AccountId = opp_au1.AccountId;
            
            Case qualityCheckCaseCLOSE = new Case();
            qualityCheckCaseCLOSE.Status = 'Closed';
            qualityCheckCaseCLOSE.Closed_Reason__c = 'Successful';
            
            Case menuProcessingCase = new Case(Type = 'Menu Processing', Subject = 'Menu Processing', RecordTypeId = mapRecordtypes.get('DE_Entry_Case').id , Status = 'New');
            menuProcessingCase.Opportunity__c = opp_au1.id;
            menuProcessingCase.AccountId = opp_au1.AccountId;
            
            Account updateAccount = new Account(Id = opp_au1.AccountId, Is_Tested__c = true);
			
            Case menuProcessingCaseCLOSE = new Case();
            menuProcessingCaseCLOSE.Status = 'Closed';
            menuProcessingCaseCLOSE.Root_Cause__c = 'Why yes';
			menuProcessingCaseCLOSE.Closed_Reason__c = 'Take Online is not possible';
            
            Test.startTest();
            insert quotes;

            insert t;
            insert lao;
            insert lpg;
            List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com_uk, c_de , 'Menu Printing with website', lpg.id, 'DE_List_Product_Price', 1, true, 100, 1, false, 20);
            insert lpp; 
            
            List<Opportunity_Quote_Line_Item__c> quotesLI = UnitTestDataFactory.createOpportunityQuoteLineItems(quotes[0], lpp.id, lpg.id, 1, true, 'DE_Opportunity_Quote_Line_Item', 1, '20', 200.0, 2, 300.0, 'Product');
            quotesLI[0].Id_Opportunity__c = opp_au1.id;
            insert quotesLI;

            insert qualityCheckCase;
            
            qualityCheckCaseCLOSE.ID = qualityCheckCase.ID;
            update qualityCheckCaseCLOSE;
            
            update opp_au2;
            
            update updateAccount;
            
            insert menuProcessingCase;
            
            menuProcessingCaseCLOSE.ID = menuProcessingCase.ID;
            update menuProcessingCaseCLOSE;
            
            Test.stopTest();
            
            Opportunity result = [select id, stageName from Opportunity where id = :opp_au1.id];
            System.assertEquals(result.stageName, 'Please Check');
        }
    }
    
	/*******************************************************************************************************
    * @description Test Class for checking Menu Processing with Negative output
    * @updated 17-May-2019 PKALINA: SP-3544 Regarding exceeding SOQL Governor Limits
    * @update 17-Jun-2019 PKALINA: Updated
    * @param 
    * @return
    */
    @isTest 
    public static void MenuProcessingClosingAction_Negative() {
        System.runAs(runningUser) {            
            Opportunity opp_au1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc_de, 'DE_Opportunity', Date.today());
            opp_au1.StageName = 'Collecting Documents';
            opp_au1.type = 'Contract Only';
            opp_au1.Business_Type__c = 'New Business';
            opp_au1.CurrencyIsoCode = 'EUR';
            insert opp_au1;

            List<Opportunity_Quote__c> quotes = UnitTestDataFactory.createOpportunityQuotes(opp_au1,1,'DE_Opportunity_Quote','Accepted','test',100,100,'Test','Test',10);
			
            Tarif__c t = UnitTestDataFactory.createTarif(com_uk, c_de , 'Menu Printing', 'DE_Tarif', false);

            List_Add_on__c lao = new List_Add_on__c(Is_Active__c=true,Type__c='Deal / Promotion',Company__c=com_uk.id,id_country__c=c_uk.id,name='Test add on');
            lao.recordtypeid=LibRecordTypeHelper.getRecordTypeValue('UK_List_Add_On');
            
            List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com_uk, c_de , 'Apple', 'DE_List_Product_Group');
            
            Opportunity opp_au2 = new Opportunity();
            opp_au2.StageName = 'Editorial Queue';
            opp_au2.probability = 95;

            Case qualityCheckCase = new Case(Type = 'Quality Check', Subject = 'Quality Check', RecordTypeId = mapRecordtypes.get('DE_Internal_Case').id , Status = 'New');
            qualityCheckCase.Opportunity__c = opp_au1.id;
            qualityCheckCase.AccountId = opp_au1.AccountId;
            
            Case qualityCheckCaseCLOSE = new Case();
            qualityCheckCaseCLOSE.Status = 'Closed';
            qualityCheckCaseCLOSE.Closed_Reason__c = 'Successful';
            
            Case menuProcessingCase = new Case(Type = 'Menu Processing', Subject = 'Menu Processing', RecordTypeId = mapRecordtypes.get('DE_Entry_Case').id , Status = 'New');
            menuProcessingCase.Opportunity__c = opp_au1.id;
            menuProcessingCase.AccountId = opp_au1.AccountId;
            
            Case menuProcessingCaseCLOSE = new Case();
            menuProcessingCaseCLOSE.Status = 'Closed';
            menuProcessingCaseCLOSE.Closed_Reason__c = 'Take Online is not possible';
            menuProcessingCaseCLOSE.Root_Cause__c = 'test';

            Test.startTest();
            insert quotes;
            
            insert t;
            insert lao;
            insert lpg;
            List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com_uk, c_de , 'Menu Printing with website', lpg.id, 'DE_List_Product_Price', 1, true, 100, 1, false, 20);
            insert lpp; 
            
            List<Opportunity_Quote_Line_Item__c> quotesLI = UnitTestDataFactory.createOpportunityQuoteLineItems(quotes[0], lpp.id, lpg.id, 1, true, 'DE_Opportunity_Quote_Line_Item', 1, '20', 200.0, 2, 300.0, 'Product');
            quotesLI[0].Id_Opportunity__c = opp_au1.id;
            insert quotesLI;

            insert qualityCheckCase;
            
            qualityCheckCaseCLOSE.ID = qualityCheckCase.ID;
            update qualityCheckCaseCLOSE;
            
            opp_au2.ID = opp_au1.ID;
            update opp_au2;
            
            insert menuProcessingCase;
            
            menuProcessingCaseCLOSE.ID = menuProcessingCase.ID;
            update menuProcessingCaseCLOSE;
            Test.stopTest();
            
            Opportunity result = [select id, stageName from Opportunity where id = :opp_au1.id];
            System.assertNotEquals(result.stageName, 'Closed Won');
        }
    }
	
    /*******************************************************************************************************
    * @description 
    * @update 17-Jun-2019 PKALINA: Updated 
    * @param 
    * @return
    */
    @isTest static void NonContractedMPClosingAction_Positive() {
        System.runAs(runningUser) {
            Opportunity opp1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc, 'Yogiyo_Opportunity', Date.today());
            opp1.type = 'Contract Only';
            opp1.Non_Contracted__c = true;
            opp1.stageName= 'Non Contracted';

            Test.startTest();
            insert opp1;
            
            Case menuProcessingCase = new Case(Opportunity__c = opp1.id, type = 'Menu Processing', AccountId = acc.id, RecordTypeId = mapRecordtypes.get('Yogiyo_Entry_Case').id);
            insert menuProcessingCase ;
            menuProcessingCase.Status = 'Closed';
            menuProcessingCase.Closed_Reason__c = 'Take Online';
            menuProcessingCase.Person_In_Charge__c = 'A';
            menuProcessingCase.Menu_Typed_Date__c = Date.today();
            menuProcessingCase.Person_in_Charge_Final_Check__c = 'B';
            menuProcessingCase.Final_Check_Date__c = Date.today();
            menuProcessingCase.Person_In_Charge_Take_Online__c = 'C';
            menuProcessingCase.Take_Online_Date__c = Date.today();

            update menuProcessingCase;
            Test.stopTest();
            
            Opportunity result = [select id, stageName from Opportunity where id = :opp1.id];
            System.assertEquals(result.stageName, 'Call - Reached');
        }
    }

    /*******************************************************************************************************
    * @description 
    * @update 17-Jun-2019 PKALINA: Updated 
    * @param 
    * @return
    */
    @isTest static void NonContractedMPClosingAction_Negative() {
        System.runAs(runningUser) {
            Test.startTest();
            
            Opportunity opp1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc, 'Yogiyo_Opportunity', Date.today());
            opp1.type = 'Contract Only';
            opp1.Non_Contracted__c = true;
            opp1.StageName = 'Non Contracted';
            opp1.probability = 30;
            insert opp1;
            
            Case menuProcessingCase = new Case(Opportunity__c = opp1.id, type = 'Menu Processing', AccountId = acc.id, RecordTypeId = mapRecordtypes.get('Yogiyo_Entry_Case').id);
            insert menuProcessingCase ;
            menuProcessingCase.Status = 'Closed';
            menuProcessingCase.Closed_Reason__c = 'Take Online is not possible';
            menuProcessingCase.root_cause__c = 'other';
            update menuProcessingCase;
            Test.stopTest();
            
            Opportunity result = [select id, stageName from Opportunity where id = :opp1.id];
            System.assertEquals(result.stageName, 'Closed Lost');
        }
    }

    @isTest static void QualityCheckClosingAction_Positive() {
        System.runAs(runningUser) {
            Opportunity opp1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc, 'Yogiyo_Opportunity', Date.today());
            opp1.type = 'Contract Only';
            opp1.stagename='Prospecting';
            Test.startTest();
            insert opp1;
            Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c = opp1.id, status__c = 'Draft');
            newQuote.recordtypeid = LibRecordTypeHelper.getRecordTypeValue('Yogiyo_Opportunity_Quote');

            insert newQuote;
            Tarif__c t = UnitTestDataFactory.createTarif(com, c , 'Menu Printing', 'Yogiyo_Tarif', false);
            insert t;
            List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,c , 'Apple', 'Yogiyo_List_Product_Group');
            insert lpg;
            List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com, c , 'Menu Printing with website', lpg.id, 'Yogiyo_List_Product_Price', 1, true, 100, 1, false, 20);
            insert lpp;

            List<Opportunity_Quote_Line_Item__c> oqp = UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote, lpp.id, lpg.id, 1, true, 'Yogiyo_Opportunity_Quote_Line_Item', 1, '20', 200.0, 2, 300.0, 'Product');
            oqp[0].Id_Opportunity__c = opp1.id;

            insert oqp;
            newQuote.status__C='Accepted';
            update newQuote;
            Case cs = new Case(Opportunity__c = opp1.id, type = 'Quality Check', AccountId = acc.id, RecordTypeId = mapRecordtypes.get('Yogiyo_Internal_Case').id);
            insert cs;
            cs.Status = 'Closed';
            cs.Closed_Reason__c = 'Successful';
            update cs;
            Test.stopTest();
            Opportunity result = [select id, stageName from Opportunity where id = :opp1.id];
            System.assertEquals(result.stageName, 'Closed Won');
        }
    }
    
    @isTest static void QualityCheckClosingAction_Negative() {
        System.runAs(runningUser) {
            Opportunity opp1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc, 'Yogiyo_Opportunity', Date.today());
            opp1.type = 'Contract Only';
            Test.startTest();
            insert opp1;
            Case cs = new Case(Opportunity__c = opp1.id, type = 'Quality Check', AccountId = acc.id, RecordTypeId = mapRecordtypes.get('Yogiyo_Internal_Case').id);
            insert cs;
            cs.Status = 'Closed';
            cs.Root_Cause__c = 'Activity Not Registered';
            cs.Closed_Reason__c = 'Not Successful';
            update cs;
            Test.stopTest();
            Opportunity result = [select id, stageName from Opportunity where id = :opp1.id];
            System.assertEquals(result.stageName, 'Please correct errors');
        }
    }

	/*******************************************************************************************************
    * @description Test Class for checking Restaurant Care Closing with Positive output
    * @updated 18-May-2019 PKALINA: SP-3544 Regarding exceeding SOQL Governor Limits
    * @param 
    * @return
    */
    @isTest 
    public static void restaurantCareClosingAction_Positive() {
        System.runAs(runningAdminUser ) {

            Opportunity opp_de = UnitTestDataFactory.createOpportunity('TestOpp123', acc_de, 'DE_Opportunity', Date.today());
            opp_de.StageName = 'Collecting Documents';
            opp_de.type = 'Product Only';
            opp_de.Business_Type__c = 'New Business';
            insert opp_de;

            Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c = opp_de.id, status__c = 'Draft');
            newQuote.recordtypeid = LibRecordTypeHelper.getRecordTypeValue('DE_Opportunity_Quote');
            insert newQuote;
            
            Tarif__c t = UnitTestDataFactory.createTarif(com_uk, c_de , 'Menu Printing', 'DE_Tarif', false);
            insert t;

            List_Add_on__c lao = new List_Add_on__c(Is_Active__c=true,Type__c='Deal / Promotion',Company__c=com_uk.id,id_country__c=c_uk.id,name='Test add on');
            lao.recordtypeid=LibRecordTypeHelper.getRecordTypeValue('UK_List_Add_On');


            List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com_uk, c_de , 'Apple', 'DE_List_Product_Group');
            List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com_uk, c_de , 'Menu Printing', 'DE_List_Product_Group');
            insert new List<SObject> {lao,lpg, lpg1};

            List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com_uk, c_de , 'Menu Printing with website', lpg.id, 'DE_List_Product_Price', 1, true, 100, 1, false, 20);
            List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com_uk, c_de , 'Menu Printing without website', lpg1.id, 'DE_List_Product_Price', 1, true, 100, 1, false, 20);
            lpp1.product_type__c = 'Menu Printing';
            lpp.product_type__c = 'Menu Printing';
            lpp.Requires_Branding__c = true;
            lpp.Requires_Asset__c = true;
            insert new List<sobject> {lpp1, lpp};
                
            List<Opportunity_Quote_Line_Item__c> oqp = UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote, lpp.id, lpg.id, 4, true, 'DE_Opportunity_Quote_Line_Item', 1, '20', 200.0, 2, 300.0, 'Product');
            oqp[0].Id_Opportunity__c = opp_uk.id;
			oqp.add(new Opportunity_Quote_Line_Item__c(Id_Opportunity__c=opp_de.id,line_item_type__c='AddOn',sub_type__c='Deal / Promotion', id_opportunity_quote__c=newQuote.id,id_list_add_on__c=lao.id));
            oqp[1].Recordtypeid=LibRecordTypeHelper.getRecordTypeValue('UK_Opportunity_Quote_Line_Item');
            
            Opportunity_Quote__c newQuote2 = new Opportunity_Quote__c();
            newQuote2.status__c = 'Accepted';

            Case cs = new Case(Opportunity__c = opp_de.id, type = 'Quality Check', AccountId = opp_de.AccountId, RecordTypeId = mapRecordtypes.get('DE_Internal_Case').id);

            Case cs2 = new Case();
            cs2.Status = 'Closed';
            cs2.Closed_Reason__c = 'Successful';


            Case resCare = new Case(Type = 'Onboarding',Case_Reason__c='Onboarding', Subject = 'Onboarding', RecordTypeId = mapRecordtypes.get('DE_Restaurant_Operations').id , Status = 'New');
            resCare.Opportunity__c = opp_de.id;
            resCare.AccountId = opp_de.AccountId;

            Opportunity opp_de2 = new Opportunity();
            opp_de2.stagename = 'Onboarding';
  			
            Case resCare2 = new Case();
            resCare2.status = 'Closed';
            resCare2.Closed_Reason__c = 'Successful';
            
            Test.startTest();
            insert oqp;
            
            newQuote2.ID = newQuote.ID;
            update newQuote2;
            
            insert cs;
            
            cs2.ID = cs.ID;
            update cs2;
            
            insert resCare;
            
            opp_de2.ID = opp_de.ID;
            update opp_de2;
            
            resCare2.ID = resCare.ID;
            update resCare2;
            Test.stopTest();

            List<Opportunity> result = [select id, stageName from Opportunity where id =: resCare.Opportunity__c];
            System.assertEquals(result[0].stageName,'Closed Won');

        }
    }

    @isTest static void menutypeage() {
        System.runAs(runningAdminUser ) {


            Case cs = new Case(Type = 'Menu Processing', Subject = 'test', RecordTypeId = mapRecordtypes.get('UK_Entry_Case').id , Status = 'Menu Typing');
            cs.Opportunity__c = opp_uk.id;
            cs.AccountId = opp_uk.AccountId;
            insert cs;

            // assetsUK[0].status__c='Activated Successfully';
            //assetsUK[0].opportunity__C=opp_uk.id;
            cs.status = 'Final Check';
            cs.menu_typed_date__C = system.now();
            cs.First_Check_Date__c = system.now();

            update cs;
            Test.startTest();

            //List<Opportunity> result = [select id, stageName from Opportunity where id =: resCare.Opportunity__c];
            //System.assertEquals(result[0].stageName,'Closed Won');

        }
    }

    @isTest static void menutypeageMenuChange() {
        System.runAs(runningAdminUser ) {


            Case cs = new Case(Type = 'Menu Change', Subject = 'test', RecordTypeId = mapRecordtypes.get('UK_Entry_Case').id , Status = 'Menu Typing');
            cs.Opportunity__c = opp_uk.id;
            cs.AccountId = opp_uk.AccountId;
            insert cs;
            cs.menu_change_date__C = system.now();
            update cs;
            // assetsUK[0].status__c='Activated Successfully';
            //assetsUK[0].opportunity__C=opp_uk.id;
            cs.status = 'Final Check';
            cs.menu_typed_date__C = system.now();

            update cs;
            Test.startTest();

            //List<Opportunity> result = [select id, stageName from Opportunity where id =: resCare.Opportunity__c];
            //System.assertEquals(result[0].stageName,'Closed Won');

        }
    }
    
    @isTest static void premiumPlacementCaseUK() {
        System.runAs(runningAdminUser ) {

            Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
            Case cs = new Case(Type = 'Sales Task', Subject = 'test', RecordTypeId = mapRecordtypes.get('UK_Internal_Case').id , Status = 'New' , case_reason__c = 'Premium Placement');
            cs.Opportunity__c = opp_uk.id;
            cs.AccountId = opp_uk.AccountId;
            Test.startTest();
            insert cs;

            // assetsUK[0].status__c='Activated Successfully';
            //assetsUK[0].opportunity__C=opp_uk.id;
            cs.status = 'Closed';
            cs.closed_reason__c = 'Successful';
            cs.menu_typed_date__C = system.now();
            cs.Root_Cause__c = 'test';

            update cs;
            Test.stopTest();
            //

            //List<Opportunity> result = [select id, stageName from Opportunity where id =: resCare.Opportunity__c];
            //System.assertEquals(result[0].stageName,'Closed Won');

        }
    }
    
    @isTest static void qualityCheckReplacementClosingAction_positive() {
        System.runAs(runningAdminUser ) {
            Opportunity opp1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc_uk, 'UK_Opportunity', Date.today());
            opp1.type = 'Contract Only';
            Test.startTest();
            insert opp1;
            Case cs = new Case(Opportunity__c = opp1.id, type = 'Quality Check Replacement', AccountId = acc_uk.id, RecordTypeId = mapRecordtypes.get('UK_Internal_Case').id);

            insert cs;
            cs.Status = 'Closed';
            cs.Closed_Reason__c = 'Successful';

            update cs;
            Test.stopTest();

        }
    }
    
    @isTest static void qualityCheckReplacementClosingAction_negative() {
        System.runAs(runningAdminUser ) {
            Opportunity opp1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc_uk, 'UK_Opportunity', Date.today());
            opp1.type = 'Contract Only';
            Test.startTest();
            insert opp1;
            Case cs = new Case(Opportunity__c = opp1.id, type = 'Quality Check Replacement', AccountId = acc_uk.id, RecordTypeId = mapRecordtypes.get('UK_Internal_Case').id);

            insert cs;
            cs.Status = 'Closed';
            cs.Root_Cause__c = 'Fraud';
            cs.Closed_Reason__c = 'Not Successful';
            update cs;
            Test.stopTest();

        }
    }
    
    @isTest static void qualityCheckCreateBranding_positive() {
        System.runAs(runningAdminUser ) {
            // Opportunity opp1 = UnitTestDataFactory.createOpportunity('TestOpp123',acc,'UK_Opportunity',Date.today());
            // opp1.type='Contract Only';

            Test.startTest();
            //insert opp1;
            opp_uk.Business_Type__c = 'New Business';
            opp_uk.StageName = 'Collecting Documents';
            update opp_uk;


            Case cs = new Case(type = 'Quality Check', RecordTypeId = mapRecordtypes.get('UK_Internal_Case').id);
            cs.Opportunity__c = opp_uk.id;
            cs.AccountId = opp_uk.AccountId;
            insert cs;
            cs.Status = 'Closed';
            cs.Closed_Reason__c = 'Successful';
            update cs;
            Test.stopTest();

        }
    }
    
    @isTest static void marketingShipping_positive() {
        System.runAs(runningAdminUser ) {
		Test.startTest();
            // Opportunity opp1 = UnitTestDataFactory.createOpportunity('TestOpp123',acc,'UK_Opportunity',Date.today());
            // opp1.type='Contract Only';

            List<Opportunity_Quote__c> quotes;
            quotes = UnitTestDataFactory.createOpportunityQuotes(opp_cd,1,'CD_Opportunity_Quote','Accepted','test',100,100,'Test','Test',10);
            insert quotes;
            List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com_cd,c_cd , 'Apple', 'CD_List_Product_Group');
            insert lpg;
            List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com_cd, c_cd , 'Menu Printing with website', lpg.id, 'CD_List_Product_Price', 1, true, 100, 1, false, 20);
            insert lpp;
            List<Opportunity_Quote_Line_Item__c> oqp = UnitTestDataFactory.createOpportunityQuoteLineItems(quotes[0], lpp.id, lpg.id, 1, true, 'CD_Opportunity_Quote_Line_Item', 1, '20', 200.0, 2, 300.0, 'Product');
            oqp[0].Id_Opportunity__c = opp_cd.id;
            System.debug('oqp-->'+oqp);
            insert oqp;
            Case cs2 = new Case(Opportunity__c = opp_cd.id, type = 'Quality Check', AccountId = acc_cd.id, RecordTypeId = mapRecordtypes.get('CD_Internal_Case').id);
            insert cs2;
            cs2.Status = 'Closed';
            cs2.Closed_Reason__c = 'Successful';
            update cs2;

            Test.stopTest();
        }
    }

    @isTest static void brandingCase_positive() {
        System.runAs(runningAdminUser ) {

	    Test.startTest();	
            
            List<Opportunity_Quote__c> quotes;
            quotes = UnitTestDataFactory.createOpportunityQuotes(opp_cd,1,'CD_Opportunity_Quote','Accepted','test',100,100,'Test','Test',10);
            insert quotes;
            
            List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com_cd,c_cd , 'Apple', 'CD_List_Product_Group');
            insert lpg;
            
            List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com_cd, c_cd , 'Menu Printing with website', lpg.id, 'CD_List_Product_Price', 1, true, 100, 1, false, 20);
            insert lpp;
            
            List<Opportunity_Quote_Line_Item__c> oqp = UnitTestDataFactory.createOpportunityQuoteLineItems(quotes[0], lpp.id, lpg.id, 1, true, 'CD_Opportunity_Quote_Line_Item', 1, '20', 200.0, 2, 300.0, 'Product');
            oqp[0].Id_Opportunity__c = opp_cd.id;
            System.debug('oqp-->'+oqp);
            insert oqp;

            List<Case> lstCase = new List<case>();

            for(case csTemp: [select id from case where Opportunity__c = :opp_cd.id AND status != 'Closed']){
                csTemp.status = 'Closed';
                csTemp.Closed_Reason__c = 'Successful';
                lstCase.add(csTemp);
            }
            
            update lstCase;


            //insert opp1;
            Case cs = new Case(type = 'BE Data Entry', RecordTypeId = mapRecordtypes.get('CD_Entry_Case').id);
            cs.Opportunity__c = opp_cd.id;
            cs.AccountId = opp_cd.AccountId;
            insert cs;
            
            cs.Status = 'Closed';
            cs.Closed_Reason__c = 'Take Online';
            update cs;
            
            Test.stopTest();

        }
    }

    @isTest static void PhotoListingClosingAction() {
        System.runAs(runningUser) {
            ClsCaseProcessor.donotValidateOppStage = true;
            Opportunity opp_au1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc_se, 'SE_Opportunity', Date.today());
            opp_au1.type = 'Contract Only';
            opp_au1.StageName = 'Editorial Queue';
            opp_au1.probability = 95;
            insert opp_au1;


            Case menuProcessingCase = new Case(Type = 'Menu Processing', Subject = 'Menu Processing', RecordTypeId = mapRecordtypes.get('SE_Entry_Case').id , Status = 'New');
            menuProcessingCase.Opportunity__c = opp_au1.id;
            menuProcessingCase.AccountId = opp_au1.AccountId;
            
            Case photoListingProcessCase = new Case(Type = 'Photo Listing Process', Subject = 'Photo Listing Process', RecordTypeId = mapRecordtypes.get('SE_Entry_Case').id , Status = 'New');
			photoListingProcessCase.Opportunity__c = opp_au1.id;
            photoListingProcessCase.AccountId = opp_au1.AccountId;
            
            insert new List<Case>{menuProcessingCase, photoListingProcessCase};
            
            Test.startTest();
            
			photoListingProcessCase.Closed_reason__c = 'Successful';
            photoListingProcessCase.Status = 'Closed';
            
            menuProcessingCase.Closed_reason__c = 'Take Online';
            menuProcessingCase.Status = 'Closed';
            
            update new List<Case>{menuProcessingCase, photoListingProcessCase};    
                
            Test.stopTest();
            
            Opportunity result = [select id, stageName from Opportunity where id = :opp_au1.id];
            System.assertEquals(result.stageName,'Onboarding');
        }

    }
    
    @isTest static void PhotoListingClosingActionWithOpenMP() {
        System.runAs(runningUser) {

			Test.startTest();
            ClsCaseProcessor.donotValidateOppStage = true;
            Opportunity opp_au1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc_se, 'SE_Opportunity', Date.today());
            opp_au1.type = 'Contract Only';
            opp_au1.StageName = 'Editorial Queue';
            opp_au1.probability = 95;
            insert opp_au1;
            Case menuProcessingCase = new Case(Type = 'Menu Processing', Subject = 'Menu Processing', RecordTypeId = mapRecordtypes.get('SE_Entry_Case').id , Status = 'New');
            menuProcessingCase.Opportunity__c = opp_au1.id;
            menuProcessingCase.AccountId = opp_au1.AccountId;
            insert menuProcessingCase;

            Case photoListingProcessCase = new Case(Type = 'Photo Listing Process', Subject = 'Photo Listing Process', RecordTypeId = mapRecordtypes.get('SE_Entry_Case').id , Status = 'New');

            photoListingProcessCase.Opportunity__c = opp_au1.id;
            photoListingProcessCase.AccountId = opp_au1.AccountId;
            insert photoListingProcessCase;

            
            photoListingProcessCase.Closed_reason__c = 'Successful';
            photoListingProcessCase.Status = 'Closed';
            update photoListingProcessCase;

            Test.stopTest();
            Opportunity result = [select id, stageName from Opportunity where id = :opp_au1.id];
            System.assertEquals(result.stageName,'Editorial Queue');
        }
    }

}
