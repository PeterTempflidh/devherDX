@isTest
private class UnitTestClsEmailProcessor {
    private static User testUser_kr = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'yogiyounittestuser@deliveryhero.com', 'Yogiyo','KR');
    private static User testUser_au = UnitTestDataFactory.createUser('DH AU Sales Team', 'dhauunittestuser@deliveryhero.com', 'DH_AU','AU');
    //private static User testUser_tlb = UnitTestDataFactory.createUser('Talabat Sales Team', 'tlbtestuser@deliveryhero.com','Talabat', 'AE');

    private static Country__c testCountry_kr;
    private static Country__c testCountry_au;
    private static Country__c testCountry_tlb;

    private static Company__c testCompany_kr;
    private static Company__c testCompany_au;
    private static Company__c testCompany_tlb;

    private static Account testAccount_kr;
    private static Account testAccount_au;
    private static account testAccount_tlb;

    private static Contact testContact_kr;
    private static Contact testContact_au;

    static Map<String,RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Case','Contact','Account'});
    
    //TLB testdata 
    /*static{
        Platform_Country__c pt1 = new Platform_Country__c(name='FOCPlatform',Country__c='Lebanon,Qatar,United Arab Emirates');
        Platform_Country__c pt2 = new Platform_Country__c(name='TalabatPlatform',Country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates');
        insert new List<sObject>{pt1,pt2};

        insert testUser_tlb;
        System.runAs(testUser_tlb){
            testCountry_tlb = UnitTestDataFactory.createCountry('AE','Arab Emirates','AED');
            insert testCountry_tlb;

            testCompany_tlb = UnitTestDataFactory.createCompany('Talabat','Talabat',testCountry_tlb);
            insert testCompany_tlb;

            testUser_tlb.CountryCode__c = 'AE';
            testUser_tlb.Company_Name__c = 'Talabat';
            
            testAccount_tlb = UnitTestDataFactory.createAccount('TLB Testaccount', testCountry_tlb, 'Talabat_Account');
            insert testAccount_tlb;

            TLB_Approval_Matrix__c approvalSetting_level1 = new TLB_Approval_Matrix__c(
                                                                                    Name = 'ArabEmirates_Level1',
                                                                                    CountryName__c = 'Arab Emirates',
                                                                                    Level__c = 1,
                                                                                    Notification__c = true,
                                                                                    Role__c = 'Country HOS',
                                                                                    User_Email__c = 'tlbtestuser@deliveryhero.com',
                                                                                    User_Id__c = testUser_tlb.Id
                                                                                    );

            TLB_Approval_Matrix__c approvalSetting_level2 = new TLB_Approval_Matrix__c(
                                                                                    Name = 'ArabEmirates_Level2',
                                                                                    CountryName__c = 'Arab Emirates',
                                                                                    Level__c = 2,
                                                                                    Notification__c = true,
                                                                                    Role__c = 'Country CEO',
                                                                                    User_Email__c = 'tlbtestuser@deliveryhero.com',
                                                                                    User_Id__c = testUser_tlb.Id
                                                                                    );

            insert new List<sObject>{approvalSetting_level2,approvalSetting_level1};
                
            Business_Config__c bc_tlb1 = new Business_Config__c(Business_Rule_Name__c='level1ApprovedStatus',Business_Rule_Value__c='Pending - legal',Id_Country__c=testCountry_tlb.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb2 = new Business_Config__c(Business_Rule_Name__c='finalApprovalStatus',Business_Rule_Value__c='Accepted',Id_Country__c=testCountry_tlb.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb3 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterFinalApproval',Business_Rule_Value__c='Menu received',Id_Country__c=testCountry_tlb.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb4 = new Business_Config__c(Business_Rule_Name__c='rejectionTemplate',Business_Rule_Value__c='00Xg0000000IyFrEAK',Id_Country__c=testCountry_tlb.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb5 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel1Approval',Business_Rule_Value__c='Positive Feedback - HOS',Id_Country__c=testCountry_tlb.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb6 = new Business_Config__c(Business_Rule_Name__c='notificationTemplate',Business_Rule_Value__c='00Xg0000000IxWmEAK',Id_Country__c=testCountry_tlb.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb7 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel2Approval',Business_Rule_Value__c='Menu received',Id_Country__c=testCountry_tlb.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb8 = new Business_Config__c(Business_Rule_Name__c='level2ApprovedStatus',Business_Rule_Value__c='Accepted',Id_Country__c=testCountry_tlb.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb9 = new Business_Config__c(Business_Rule_Name__c='initialStatusLevel1',Business_Rule_Value__c='Approval pending',Id_Country__c=testCountry_tlb.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb10 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel1Rejection',Business_Rule_Value__c='Negotiating',Id_Country__c=testCountry_tlb.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb11 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel2Rejection',Business_Rule_Value__c='Please correct errors',Id_Country__c=testCountry_tlb.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Talabat_Opportunity_Quote',Type__c='Process');
            
            insert new List<sObject>{bc_tlb1,bc_tlb2,bc_tlb3,bc_tlb4,bc_tlb5,bc_tlb6,bc_tlb7,bc_tlb8,bc_tlb9,bc_tlb10,bc_tlb11};

        }
    }*/
    //KR testdata
    static {
        UnitTestDataFactory.getRecordtypeValues();
        Platform_Country__c pt1 = new Platform_Country__c(name='FOCPlatform',Country__c='Lebanon,Qatar,United Arab Emirates');
        Platform_Country__c pt2 = new Platform_Country__c(name='TalabatPlatform',Country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates');
        insert new List<sObject>{pt1,pt2};
        insert testUser_kr;
        System.runAs(testUser_kr){
            testCountry_kr = UnitTestDataFactory.createCountry('KR','Korea','KRW');
            insert testCountry_kr;

            testCompany_kr = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', testCountry_kr);
            insert testCompany_kr;

            testUser_kr.CountryCode__c = 'KR';
            testUser_kr.Company_Name__c = 'Yogiyo';
            update testUser_kr;
            
            TLB_Approval_Matrix__c approvalSetting_level1 = new TLB_Approval_Matrix__c(
                                                                                    Name = 'ArabEmirates_Level1',
                                                                                    CountryName__c = 'Arab Emirates',
                                                                                    
                                                                                    Notification__c = true,
                                                                                    Role__c = 'HOS'
                                                                                    
                                                                                    );

            TLB_Approval_Matrix__c approvalSetting_level2 = new TLB_Approval_Matrix__c(
                                                                                    Name = 'ArabEmirates_Level2',
                                                                                    CountryName__c = 'Arab Emirates',
                                                                                    
                                                                                    Notification__c = true,
                                                                                    Role__c = 'Legal'
                                                                                    );

            TLB_Approval_Matrix__c approvalSetting_level3 = new TLB_Approval_Matrix__c(
                                                                                    Name = 'ArabEmirates_Level3',
                                                                                    CountryName__c = 'Arab Emirates',
                                                                                    
                                                                                    Notification__c = true,
                                                                                    Role__c = 'Regional HOS'
                                                                                   
                                                                                    );

            insert new List<sObject>{approvalSetting_level2,approvalSetting_level1,approvalSetting_level3};
                
            Business_Config__c bc_tlb1 = new Business_Config__c(Business_Rule_Name__c='level1ApprovedStatus',Business_Rule_Value__c='Pending - legal',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb2 = new Business_Config__c(Business_Rule_Name__c='finalApprovalStatus',Business_Rule_Value__c='Accepted',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb3 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterFinalApproval',Business_Rule_Value__c='Quality Check Request',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb4 = new Business_Config__c(Business_Rule_Name__c='rejectionTemplate',Business_Rule_Value__c='00Xg0000000IyFrEAK',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb5 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel1Approval',Business_Rule_Value__c='Positive Feedback - HOS',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb6 = new Business_Config__c(Business_Rule_Name__c='notificationTemplate',Business_Rule_Value__c='00Xg0000000IxWmEAK',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb7 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel2Approval',Business_Rule_Value__c='Quality Check Request',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb8 = new Business_Config__c(Business_Rule_Name__c='level2ApprovedStatus',Business_Rule_Value__c='Accepted',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb9 = new Business_Config__c(Business_Rule_Name__c='initialStatusLevel1',Business_Rule_Value__c='Approval pending',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb10 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel1Rejection',Business_Rule_Value__c='Negotiating',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb11 = new Business_Config__c(Business_Rule_Name__c='pushStageNameAfterLevel2Rejection',Business_Rule_Value__c='Please correct errors',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb12 = new Business_Config__c(Business_Rule_Name__c='InformHOSEmailTemplate',Business_Rule_Value__c='Talabt_Inform_HOS',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb13 = new Business_Config__c(Business_Rule_Name__c='InformHOSEmailSubject',Business_Rule_Value__c='{AccountName}: There is a new Quote for Regional HOS approval!',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb14 = new Business_Config__c(Business_Rule_Name__c='InformHOSAboutRegionalHOSApproval',Business_Rule_Value__c='true',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb15 = new Business_Config__c(Business_Rule_Name__c='initialStatusLevel3',Business_Rule_Value__c='Approval pending - Regional HOS',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb16 = new Business_Config__c(Business_Rule_Name__c='notificationSubject',Business_Rule_Value__c='{AccountName} has a quote to be appoved!',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            Business_Config__c bc_tlb17 = new Business_Config__c(Business_Rule_Name__c='rejectionSubject',Business_Rule_Value__c='{OppName} has been rejected!',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='QuoteApprovalProcess',Record_Type_Id__c='Yogiyo_Opportunity_Quote',Type__c='Process');
            
            insert new List<sObject>{bc_tlb1,bc_tlb2,bc_tlb3,bc_tlb4,bc_tlb5,bc_tlb6,bc_tlb7,bc_tlb8,bc_tlb9,bc_tlb10,bc_tlb11,bc_tlb12,bc_tlb13,bc_tlb14,bc_tlb15,bc_tlb16,bc_tlb17};
            String recordTypeIdValue = mapRecordtypes.get('Yogiyo_Inbound').Id;
            String recordTypeIdBusinessConfigValue = '{"RecordTypeId":"' + recordTypeIdValue + '"}';

            String recordTypeIdAccount = mapRecordtypes.get('Yogiyo_Account').Id;
            String recordTypeIdContact = mapRecordtypes.get('Yogiyo_Contact').Id;

            Business_Config__c b1_kr = new Business_Config__c(Business_Rule_Name__c='jsonMapping',Business_Rule_Value__c='{"SuppliedEmail":"SuppliedEmail"}',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='Email2Case_devtest_kr@deliveryhero.com',Record_Type_Id__c='Yogiyo_Inbound',Type__c='Process');
            Business_Config__c b2_kr = new Business_Config__c(Business_Rule_Name__c='WhatToParse',Business_Rule_Value__c='Header',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='Email2Case_devtest_kr@deliveryhero.com',Record_Type_Id__c='Yogiyo_Inbound',Type__c='Process');      
            Business_Config__c b3_kr = new Business_Config__c(Business_Rule_Name__c='defaultMapping',Business_Rule_Value__c=recordTypeIdBusinessConfigValue,Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='Email2Case_devtest_kr@deliveryhero.com',Record_Type_Id__c='Yogiyo_Inbound',Type__c='Process');

            Business_Config__c b4_kr = new Business_Config__c(Business_Rule_Name__c='caseField',Business_Rule_Value__c='SuppliedEmail',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='EmailConfiguration',Record_Type_Id__c='Yogiyo_Inbound',Type__c='Process');
            Business_Config__c b5_kr = new Business_Config__c(Business_Rule_Name__c='accountRecordTypeId',Business_Rule_Value__c=recordTypeIdAccount,Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='EmailConfiguration',Record_Type_Id__c='Yogiyo_Inbound',Type__c='Process');
            Business_Config__c b6_kr = new Business_Config__c(Business_Rule_Name__c='contactRecordTypeId',Business_Rule_Value__c=recordTypeIdContact,Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='EmailConfiguration',Record_Type_Id__c='Yogiyo_Inbound',Type__c='Process');
            Business_Config__c b7_kr = new Business_Config__c(Business_Rule_Name__c='accountField',Business_Rule_Value__c='Account_Email__c',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='EmailConfiguration',Record_Type_Id__c='Yogiyo_Inbound',Type__c='Process');
            Business_Config__c b8_kr = new Business_Config__c(Business_Rule_Name__c='contactField',Business_Rule_Value__c='Email',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='EmailConfiguration',Record_Type_Id__c='Yogiyo_Inbound',Type__c='Process');


            insert new List<sObject>{b1_kr,b2_kr,b3_kr,b4_kr,b5_kr,b6_kr,b7_kr,b8_kr};
                
            testAccount_kr = UnitTestDataFactory.createAccount('TestAccount KR',testCountry_kr,'Yogiyo_Account');
            testAccount_kr.Account_Email__c = 'test_kr@deliveryhero.com';
            insert testAccount_kr;

            List<Contact> listContact = UnitTestDataFactory.createContacts(new List<Account>{testAccount_kr}, 'Mustermann', 'Max', 'Mr', 'Owner', 1, 'Test', 'Yogiyo_Contact');
            testContact_kr = listContact[0];
            testContact_kr.Email = 'test_kr@deliveryhero.com';
            insert testContact_kr;

            



        }

    }
    //AU testdata
    static {
        insert testUser_au;
        System.runAs(testUser_au){
            testCountry_au = UnitTestDataFactory.createCountry('AU','Australia','AUD');
            insert testCountry_au;

            testCompany_au = UnitTestDataFactory.createCompany('DH_AU', 'DH_AU', testCountry_au);
            insert testCompany_au;

            testUser_au.CountryCode__c = 'AU';
            testUser_au.Company_Name__c = 'DH_AU';
            update testUser_au;
            
            String recordTypeIdValue = mapRecordtypes.get('DH_AU_Inbound').Id;
            String recordTypeIdBusinessConfigValue = '{"RecordTypeId":"' + recordTypeIdValue + '"}';

            String recordTypeIdAccount = mapRecordtypes.get('DH_AU_Account').Id;
            String recordTypeIdContact = mapRecordtypes.get('DH_AU_Contact').Id;
            
             Business_Config__c b1_au = new Business_Config__c(Business_Rule_Name__c='jsonMapping',Business_Rule_Value__c='{"Fwd: New SMS from ":"SuppliedPhone"}',Id_Country__c=testCountry_au.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='Email2Case_devtest_au@deliveryhero.com',Record_Type_Id__c='DH_AU_Inbound',Type__c='Process');
            Business_Config__c b2_au = new Business_Config__c(Business_Rule_Name__c='defaultMapping',Business_Rule_Value__c=recordTypeIdBusinessConfigValue,Id_Country__c=testCountry_au.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='Email2Case_devtest_au@deliveryhero.com',Record_Type_Id__c='DH_AU_Inbound',Type__c='Process');
            Business_Config__c b3_au = new Business_Config__c(Business_Rule_Name__c='WhatToParse',Business_Rule_Value__c='Subject',Id_Country__c=testCountry_au.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='Email2Case_devtest_au@deliveryhero.com',Record_Type_Id__c='DH_AU_Inbound',Type__c='Process');
            Business_Config__c b4_au = new Business_Config__c(Business_Rule_Name__c='RegExp',Business_Rule_Value__c='[A-Za-z: ]*(Fwd: New SMS from )(\\d+)',Id_Country__c=testCountry_au.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='Email2Case_devtest_au@deliveryhero.com',Record_Type_Id__c='DH_AU_Inbound',Type__c='Process');
            
            /*Business_Config__c b5_au = new Business_Config__c(Business_Rule_Name__c='lookUpField',Business_Rule_Value__c='MobilePhone',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='EmailConfiguration',Record_Type_Id__c='DH_AU_Inbound',Type__c='Process');
            Business_Config__c b6_au = new Business_Config__c(Business_Rule_Name__c='connectionField',Business_Rule_Value__c='AccountId',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='EmailConfiguration',Record_Type_Id__c='DH_AU_Inbound',Type__c='Process');
            Business_Config__c b7_au = new Business_Config__c(Business_Rule_Name__c='lookUpObject',Business_Rule_Value__c='Contact',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='EmailConfiguration',Record_Type_Id__c='DH_AU_Inbound',Type__c='Process');*/
            Business_Config__c b5_au = new Business_Config__c(Business_Rule_Name__c='caseField',Business_Rule_Value__c='SuppliedPhone',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='EmailConfiguration',Record_Type_Id__c='DH_AU_Inbound',Type__c='Process');
            Business_Config__c b6_au = new Business_Config__c(Business_Rule_Name__c='accountRecordTypeId',Business_Rule_Value__c=recordTypeIdAccount,Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='EmailConfiguration',Record_Type_Id__c='DH_AU_Inbound',Type__c='Process');            
            Business_Config__c b7_au = new Business_Config__c(Business_Rule_Name__c='contactRecordTypeId',Business_Rule_Value__c=recordTypeIdContact,Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='EmailConfiguration',Record_Type_Id__c='DH_AU_Inbound',Type__c='Process');            
            Business_Config__c b8_au = new Business_Config__c(Business_Rule_Name__c='accountField',Business_Rule_Value__c='Phone',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='EmailConfiguration',Record_Type_Id__c='DH_AU_Inbound',Type__c='Process');           
            Business_Config__c b9_au = new Business_Config__c(Business_Rule_Name__c='contactField',Business_Rule_Value__c='MobilePhone',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='EmailConfiguration',Record_Type_Id__c='DH_AU_Inbound',Type__c='Process');         

            insert new List<sObject>{b1_au,b2_au,b3_au,b4_au,b5_au,b6_au,b7_au,b8_au,b9_au};

            testAccount_au = UnitTestDataFactory.createAccount('TestAccount AU',testCountry_au,'DH_AU_Account');
            testAccount_au.Account_Email__c = 'test_au@deliveryhero.com';
            insert testAccount_au;



            List<Contact> listContact = UnitTestDataFactory.createContacts(new List<Account>{testAccount_au}, 'Mustermann', 'Max', 'Mr', 'Owner', 1, 'Test', 'DH_AU_Contact');
            testContact_au = listContact[0];
            testContact_au.MobilePhone = '61412345678';
            insert testContact_au;




           
        }

    }
    
    @isTest static void notifyApprovers(){
       // Map<String,TLB_Approval_Matrix__c> mapApprovalSettings = TLB_Approval_Matrix__c.getAll();
        
        Integer emailLimitBeforeSending = Limits.getEmailInvocations();
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(new List<Account>{testAccount_kr},1,'Yogiyo_Opportunity',Date.today());
        insert oppList;
        List<Opportunity_Quote__c>  oppq = UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1,'Yogiyo_Opportunity_Quote','Pending-Approval','test description',0,0,'','',0);
        insert oppq;

       // ClsEmailProcessor.notifyApprovers(mapApprovalSettings.values(), 'Yogiyo_Opportunity_Quote', oppq[0].Id);
        
        Integer emailLimitAfterSending = Limits.getEmailInvocations();
        
        System.debug('emailLimitBeforeSending ' + emailLimitBeforeSending);
        System.debug('emailLimitAfterSending ' + emailLimitAfterSending);
        
        //System.assert(emailLimitBeforeSending < emailLimitAfterSending);
        
    }
    
    @isTest static void sendRejection(){
       // Map<String,TLB_Approval_Matrix__c> mapApprovalSettings = TLB_Approval_Matrix__c.getAll();
        
        Integer emailLimitBeforeSending = Limits.getEmailInvocations();
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(new List<Account>{testAccount_kr},1,'Yogiyo_Opportunity',Date.today());
        insert oppList;
        OpportunityTeamMember otm= new OpportunityTeamMember(userid=Userinfo.getuserid(), opportunityID= oppList[0].id,TeamMemberRole='HOS');
        insert otm;
        List<OpportunityTeamMember> otmLst = new List<OpportunityTeamMember>();
        otmLst.add(otm);
        List<Opportunity_Quote__c>  oppq = UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1,'Yogiyo_Opportunity_Quote','Pending-Approval','test description',0,0,'','',0);
        insert oppq;
        
        ClsEmailProcessor.sendRejectionNotification(testUser_au.Id, 'Yogiyo_Opportunity_Quote', oppq[0].Id);           
        clsEmailProcessor.notifyApprovers(otmLst,'Yogiyo_Opportunity_Quote',oppq[0].Id);
        
        Integer emailLimitAfterSending = Limits.getEmailInvocations();
        
        System.debug('emailLimitBeforeSending ' + emailLimitBeforeSending);
        System.debug('emailLimitAfterSending ' + emailLimitAfterSending);
        
        //System.assert(emailLimitBeforeSending < emailLimitAfterSending);
        
    }

    @isTest static void processEmail2Case_KR(){
        Test.startTest();

        //manually creation of case mandatory, since EmailMessage object needs a ParentId on insert...
        Case testCase = new Case(RecordTypeId = mapRecordtypes.get('Yogiyo_Inbound').id, 
                                  Status='New',
                                  Origin='Email',
                                  AccountId = testAccount_kr.id
                                );
        insert testCase;

        EmailMessage email = new EmailMessage(
                                    ToAddress = 'devtest_kr@deliveryhero.com',
                                    FromAddress = 'test_kr@deliveryhero.com',
                                    TextBody = 'Bestellnummer: 0815\nCustomer email: test_kr@deliveryhero.com\nToken:Something else\n',
                                    ParentId = testCase.Id
                                             );
        insert email;
        Test.stopTest();

        testCase = [SELECT Id, AccountId FROM Case WHERE Id =: testCase.Id];
        //System.assertEquals(testAccount_kr.Id, testCase.AccountId);

    }

    @isTest static void processEmail2Case_AU(){
        Test.startTest();

        //manually creation of case mandatory, since EmailMessage object needs a ParentId on insert...
        Case testCase = new Case(RecordTypeId = mapRecordtypes.get('DH_AU_Inbound').id, 
                                  Status='New',
                                  Origin='Email'
                                );
        insert testCase;

        EmailMessage email = new EmailMessage(
                                    ToAddress = 'devtest_au@deliveryhero.com',
                                    FromAddress = 'test_au@deliveryhero.com',
                                    Subject = 'Lets try with some weired values before Fwd: New SMS from 61412345678',
                                    ParentId = testCase.Id
                                             );
        insert email;
        Test.stopTest();

        testCase = [SELECT Id, AccountId FROM Case WHERE Id =: testCase.Id];
        //System.assertEquals(testAccount_au.Id, testCase.AccountId);

    }
    
    @isTest static void processEmail2Case_AU_nonProcessEmail(){
        Test.startTest();

        //manually creation of case mandatory, since EmailMessage object needs a ParentId on insert...
        Case testCase = new Case(RecordTypeId = mapRecordtypes.get('DH_AU_Inbound').id, 
                                  Status='New',
                                  Origin='Email'
                                );
        insert testCase;

        EmailMessage email = new EmailMessage(
                                    ToAddress = 'devtest_au@deliveryhero.com',
                                    FromAddress = 'test_au@deliveryhero.com',
                                    Subject = '1/96 Jonson St, Byron Bay NSW 2481 - Legend Pizza',
                                    ParentId = testCase.Id
                                             );
        insert email;
        Test.stopTest();

        testCase = [SELECT Id, AccountId FROM Case WHERE Id =: testCase.Id];
        System.assertEquals(null, testCase.AccountId);

    }

    @isTest static void processEmail2Case_AU_subjectNull(){
        Test.startTest();

        //manually creation of case mandatory, since EmailMessage object needs a ParentId on insert...
        Case testCase = new Case(RecordTypeId = mapRecordtypes.get('DH_AU_Inbound').id, 
                                  Status='New',
                                  Origin='Email'
                                );
        insert testCase;

        EmailMessage email = new EmailMessage(
                                    ToAddress = 'devtest_au@deliveryhero.com',
                                    FromAddress = 'test_au@deliveryhero.com',
                                    Subject = null,
                                    ParentId = testCase.Id
                                             );
        insert email;
        Test.stopTest();

        testCase = [SELECT Id, AccountId FROM Case WHERE Id =: testCase.Id];
        System.assertEquals(null, testCase.AccountId);

    }


    @isTest static void informHosEmail(){
        Map<String,TLB_Approval_Matrix__c> mapApprovalSettings = TLB_Approval_Matrix__c.getAll();
        
        Integer emailLimitBeforeSending = Limits.getEmailInvocations();
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(new List<Account>{testAccount_kr},1,'Yogiyo_Opportunity',Date.today());
        insert oppList;

        List<Opportunity_Quote__c>  oppq = UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1,'Yogiyo_Opportunity_Quote','Pending-Approval','test description',0,0,'','',0);
        insert oppq;

        
        //ClsEmailProcessor.informHosEmail(mapApprovalSettings.values(), 'Yogiyo_Opportunity_Quote', oppq[0].Id);
        
        Integer emailLimitAfterSending = Limits.getEmailInvocations();
        
        System.debug('emailLimitBeforeSending ' + emailLimitBeforeSending);
        System.debug('emailLimitAfterSending ' + emailLimitAfterSending);
        
        //System.assert(emailLimitBeforeSending < emailLimitAfterSending);
        
    }


    
    
}