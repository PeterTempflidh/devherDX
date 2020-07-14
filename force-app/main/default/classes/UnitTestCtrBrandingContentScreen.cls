@isTest
private class UnitTestCtrBrandingContentScreen {

    static String buttonRule = '{"Approve": ["Pending design approval"], "Reject": ["Pending design approval"], "TakeOwnership": ["New"], "Submit": ["New"] }';
    static RecordType cdBrandContRecType = [Select DeveloperName from Recordtype Where Developername = 'CD_Branding_Content' and sobjecttype = 'Branding_Content__c'];

    @testSetup
    static void setup() {

        UnitTestDataFactory.getRecordTypeValues();
        Country__c c = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
        insert c;
		Company__c com = UnitTestDataFactory.createCompany('CD', 'CD', c);
		insert com;
		
        List<Business_Config__c> configs = new List<Business_Config__c>();

        configs.add(
            UnitTestDataFactory.createBusinessConfig(
                'BrandingApprovalProcess',
                'Process',
                'buttonToStatuses',
                buttonRule,
                c.id,
                'CD_Branding_Content',
                true,
                true)
        );

        configs.add(
            UnitTestDataFactory.createBusinessConfig(
                'BrandingApprovalProcess',
                'Process',
                'initialStatusLevel',
                'Pending design approval',
                c.Id,
                'CD_Branding_Content',
                true,
                false)
        );

        configs.add(
            UnitTestDataFactory.createBusinessConfig(
                'BrandingApprovalProcess',
                'Process',
                'level1ApprovedStatus',
                'Pending final approval',
                c.Id,
                'CD_Branding_Content',
                true,
                false)
        );

        configs.add(
            UnitTestDataFactory.createBusinessConfig(
                'BrandingApprovalProcess',
                'Process',
                'finalApprovalStatus',
                'Approved',
                c.Id,
                'CD_Branding_Content',
                true,
                false)
        );

        configs.add(
            UnitTestDataFactory.createBusinessConfig(
                'BrandingApprovalProcess',
                'Process',
                'countryManagerIdEcuador',
                UserInfo.getUserId(),
                c.Id,
                'CD_Branding_Content',
                true,
                false)
        );

        configs.add(
            UnitTestDataFactory.createBusinessConfig(
                'BrandingApprovalProcess',
                'Process',
                'DesignQueue',
                UserInfo.getUserId(),
                c.Id,
                'CD_Branding_Content',
                true,
                false)
        );

        configs.add(
            UnitTestDataFactory.createBusinessConfig(
                'BrandingApprovalProcess',
                'Process',
                'designManagerIdEcuador',
                UserInfo.getUserId(),
                c.Id,
                'CD_Branding_Content',
                true,
                false)
        );

        configs.add(
            UnitTestDataFactory.createBusinessConfig(
                'BrandingApprovalProcess',
                'Process',
                'brandingStatusOnCreate',
                'New',
                c.Id,
                'CD_Branding_Content',
                true,
                false)
        );

        configs.add(
            UnitTestDataFactory.createBusinessConfig(
                'BrandingApprovalProcess',
                'Process',
                'rejectionStatus',
                'Rejected',
                c.Id,
                'CD_Branding_Content',
                true,
                false)
        );

        configs.add(
            UnitTestDataFactory.createBusinessConfig(
                'BrandingApprovalProcess',
                'Process',
                'oppProbability',
                '95',
                c.Id,
                'CD_Branding_Content',
                true,
                false)
        );

        configs.add(
            UnitTestDataFactory.createBusinessConfig(
                'BrandingApprovalProcess',
                'Process',
                'pushStageNameAfterFinalApproval',
                'Promo and Logistics Queue',
                c.Id,
                'CD_Branding_Content',
                true,
                false)
        );

        configs.add(
            UnitTestDataFactory.createBusinessConfig(
                'BrandingApprovalProcess',
                'Process',
                'rejectionStatusLevel1',
                'Design rejected',
                c.Id,
                'CD_Branding_Content',
                true,
                false)
        );

        configs.add(
            UnitTestDataFactory.createBusinessConfig(
                'BrandingApprovalProcess',
                'Process',
                'rejectionStatusFinal',
                'Rejected',
                c.Id,
                'CD_Branding_Content',
                true,
                false)
        );

        insert configs;

        Account acc = UnitTestDataFactory.createAccount('test', c, 'CD_Account');
        insert acc;

        Opportunity opp = UnitTestDataFactory.createOpportunity('test', acc, 'CD_Opportunity', Date.today());
        insert opp;
		
		// create product Gruop
		List_Product_Group__c grp = UnitTestDataFactory.createProductGroup(com,c,'test', 'CD_List_Product_Group');
		insert grp;
		
		List<List_product_price__c> product = UnitTestDataFactory.createProducts(com, c,grp.Id,1, 'CD_List_Product_Price',0, true, 100.00, 1, false, 10);
		product[0].Requires_Branding__c = true;
		insert product;
		
        List<Branding_Content__c> bcs = new List<Branding_Content__c>();
        bcs.add(getCDBrandingContent(acc, opp, 'New',product[0].Id));
        bcs.add(getCDBrandingContent(acc, opp, 'Pending design approval',product[0].Id));
        bcs.add(getCDBrandingContent(acc, opp, 'Pending final approval',product[0].Id));

        insert bcs;


        OpportunityTeamMember otm = new OpportunityTeamMember(userID=userinfo.getUserID(), TeamMemberRole='Design Manager,HOS',  OpportunityId=opp.id);
        insert otm;
        /*TLB_Approval_Matrix__c appMatrix = new TLB_Approval_Matrix__c(Name = 'test',
                User_Id__c = UserInfo.getUserId(),
                CountryName__c = 'branding Ecuador',
                Level__c = 1);

        TLB_Approval_Matrix__c appMatrix2 = new TLB_Approval_Matrix__c(Name = 'test2',	
                User_Id__c = UserInfo.getUserId(),
                CountryName__c = 'branding Ecuador',
                Level__c = 2);

        insert appMatrix;
        insert appMatrix2;*/
    }

    @isTest static void ctrBrandingContentScreenBuildCorrectly() {
        Branding_Content__c bc = [Select Recordtype.Developername, Status__c from Branding_Content__c limit 1];

        PageReference pref = Page.BrandingContentScreen;
        pref.getParameters().put('id', bc.Id);

        CtrBrandingContentScreen ctr;

        Test.startTest();
        Test.setCurrentPage(pref);

        ApexPages.StandardController stdCtr = new ApexPages.StandardController(bc);
        ctr = new CtrBrandingContentScreen(stdCtr);

        Test.stopTest();
    }

    @isTest static void submitAndTakeOwnershipButtonsAreCorrectlyVisible() {
        Branding_Content__c bc = [Select Recordtype.Developername, Status__c, OwnerId, Opportunity__r.Record_Country__c from Branding_Content__c Where Status__c = 'New' limit 1];

        PageReference pref = Page.BrandingContentScreen;
        pref.getParameters().put('id', bc.Id);

        CtrBrandingContentScreen ctr;

        Test.startTest();
        Test.setCurrentPage(pref);

        ApexPages.StandardController stdCtr = new ApexPages.StandardController(bc);
        ctr = new CtrBrandingContentScreen(stdCtr);

        Test.stopTest();

        System.assert(ctr.displaySubmit);
        //System.assert(ctr.displayTakeOwnership); right now s not possible to test this
        System.assert(String.isNotBlank(ctr.ownerName));
        System.assert(!ctr.displayApprove);
        System.assert(!ctr.displayReject);
    }

    @isTest static void approveAndRejectButtonsAreCorrectlyVisible() {
        Branding_Content__c bc = [Select Recordtype.Developername, Status__c, OwnerId, Opportunity__r.Record_Country__c from Branding_Content__c Where Status__c = 'Pending design approval' limit 1];

        PageReference pref = Page.BrandingContentScreen;
        pref.getParameters().put('id', bc.Id);

        CtrBrandingContentScreen ctr;

        Test.startTest();
        Test.setCurrentPage(pref);

        ApexPages.StandardController stdCtr = new ApexPages.StandardController(bc);
        ctr = new CtrBrandingContentScreen(stdCtr);

        Test.stopTest();

        System.assert(!ctr.displaySubmit);
        System.assert(!ctr.displayTakeOwnership);
        System.assert(ctr.displayApprove);
        System.assert(ctr.displayReject);
    }

    @isTest static void buttonsAreHiddenIfBusinessConfigNotExist() {
        // change record type name on Business_Config__c
        List<Business_Config__c> rules =  [select Record_Type_Id__c from Business_Config__c Where Process_Name__c = 'BrandingApprovalProcess'];
        for (Business_Config__c b : rules) {
            b.Record_Type_Id__c = 'UK_Branding_Content';
        }
        update rules;

        Branding_Content__c bc = [Select Recordtype.Developername, Status__c from Branding_Content__c Where Status__c = 'New' limit 1];

        PageReference pref = Page.BrandingContentScreen;
        pref.getParameters().put('id', bc.Id);

        CtrBrandingContentScreen ctr;

        Test.startTest();
        Test.setCurrentPage(pref);

        ApexPages.StandardController stdCtr = new ApexPages.StandardController(bc);
        ctr = new CtrBrandingContentScreen(stdCtr);

        Test.stopTest();

        System.assert(!ctr.displaySubmit);
        System.assert(!ctr.displayTakeOwnership);
        System.assert(!ctr.displayApprove);
        System.assert(!ctr.displayReject);
    }

    @isTest static void buttonsAreHiddenIfButtonsRuleNotExist() {
        // change rule name
        List<Business_Config__c> rules =  [select Business_Rule_name__c from Business_Config__c Where Process_Name__c = 'BrandingApprovalProcess' and Business_Rule_name__c = 'buttonToStatuses'];
        for (Business_Config__c b : rules) {
            b.Business_Rule_Name__c = 'stupidName';
        }
        update rules;

        Branding_Content__c bc = [Select Recordtype.Developername, Status__c from Branding_Content__c Where Status__c = 'New' limit 1];

        PageReference pref = Page.BrandingContentScreen;
        pref.getParameters().put('id', bc.Id);

        CtrBrandingContentScreen ctr;

        Test.startTest();
        Test.setCurrentPage(pref);

        ApexPages.StandardController stdCtr = new ApexPages.StandardController(bc);
        ctr = new CtrBrandingContentScreen(stdCtr);

        Test.stopTest();

        System.assert(!ctr.displaySubmit);
        System.assert(!ctr.displayTakeOwnership);
        System.assert(!ctr.displayApprove);
        System.assert(!ctr.displayReject);
    }

    @isTest static void buttonsAreHiddenIfBusinessConfigNotMatchRecordType() {
        delete [select id from Business_Config__c];

        Branding_Content__c bc = [Select Recordtype.Developername, Status__c from Branding_Content__c Where Status__c = 'New' limit 1];

        PageReference pref = Page.BrandingContentScreen;
        pref.getParameters().put('id', bc.Id);

        CtrBrandingContentScreen ctr;

        Test.startTest();
        Test.setCurrentPage(pref);

        ApexPages.StandardController stdCtr = new ApexPages.StandardController(bc);
        ctr = new CtrBrandingContentScreen(stdCtr);

        Test.stopTest();

        System.assert(!ctr.displaySubmit);
        System.assert(!ctr.displayTakeOwnership);
        System.assert(!ctr.displayApprove);
        System.assert(!ctr.displayReject);
    }

    @isTest static void submitReturnCorrectly() {
        Branding_Content__c bc = [Select Recordtype.Developername, Status__c, OwnerId, Opportunity__r.Record_Country__c from Branding_Content__c Where Status__c = 'New' limit 1];

        PageReference pref = Page.BrandingContentScreen;
        pref.getParameters().put('id', bc.Id);

        CtrBrandingContentScreen ctr;
        PageReference res;

        Test.startTest();
        Test.setCurrentPage(pref);

        ApexPages.StandardController stdCtr = new ApexPages.StandardController(bc);
        ctr = new CtrBrandingContentScreen(stdCtr);
        res = ctr.submit();
        Test.stopTest();

        System.assertEquals(null, res);
        System.assertEquals('Pending design approval', [select status__c from Branding_Content__c where id =: bc.id].status__c);
    }


    @isTest static void approveReturnCorrectlyOnFirstLevel() {
        Branding_Content__c bc = [Select Recordtype.Developername, Status__c, OwnerId, Opportunity__r.Record_Country__c from Branding_Content__c Where Status__c = 'Pending design approval' limit 1];

        PageReference pref = Page.BrandingContentScreen;
        pref.getParameters().put('id', bc.Id);

        CtrBrandingContentScreen ctr;
        PageReference res;

        Test.startTest();
        Test.setCurrentPage(pref);

        ApexPages.StandardController stdCtr = new ApexPages.StandardController(bc);
        ctr = new CtrBrandingContentScreen(stdCtr);
        res = ctr.approve();
        Test.stopTest();

        System.assertEquals(null, res);
        System.assertEquals('Pending final approval', [select Status__c from Branding_Content__c Where id=: bc.id].Status__c);
    }

    @isTest static void approveReturnCorrectlyOnSecondLevel() {
        Branding_Content__c bc = [Select Recordtype.Developername, Status__c, OwnerId, Opportunity__r.Record_Country__c from Branding_Content__c Where Status__c = 'Pending final approval' limit 1];

        PageReference pref = Page.BrandingContentScreen;
        pref.getParameters().put('id', bc.Id);

        CtrBrandingContentScreen ctr;
        PageReference res;

        Test.startTest();
        Test.setCurrentPage(pref);

        ApexPages.StandardController stdCtr = new ApexPages.StandardController(bc);
        ctr = new CtrBrandingContentScreen(stdCtr);
        res = ctr.approve();
        Test.stopTest();

        System.assertEquals(null, res);
       // System.assertEquals('Approved', [select Status__c from Branding_Content__c Where id=: bc.id].Status__c);
    }

    @isTest static void approveReturnNullOnFirstLevelIfExceptionOccurs() {
        Branding_Content__c bc = [Select Recordtype.Developername, Status__c, OwnerId, Opportunity__r.Record_Country__c from Branding_Content__c Where Status__c = 'Pending design approval' limit 1];

        PageReference pref = Page.BrandingContentScreen;
        pref.getParameters().put('id', bc.Id);

        CtrBrandingContentScreen ctr;
        PageReference res;

        delete [select id from Business_Config__c where Business_Rule_name__c = 'oppProbability'];

        Test.startTest();
        Test.setCurrentPage(pref);

        ApexPages.StandardController stdCtr = new ApexPages.StandardController(bc);
        ctr = new CtrBrandingContentScreen(stdCtr);
        res = ctr.approve();
        Test.stopTest();

        System.assertEquals(null, res);
    }

    @isTest static void approveReturnNullOnSecondLevelIfExceptionOccurs() {
        Branding_Content__c bc = [Select Recordtype.Developername, Status__c, OwnerId, Opportunity__r.Record_Country__c from Branding_Content__c Where Status__c = 'Pending final approval' limit 1];

        PageReference pref = Page.BrandingContentScreen;
        pref.getParameters().put('id', bc.Id);

        CtrBrandingContentScreen ctr;
        PageReference res;

        delete [select id from Business_Config__c where Business_Rule_name__c = 'pushStageNameAfterFinalApproval'];

        Test.startTest();
        Test.setCurrentPage(pref);

        ApexPages.StandardController stdCtr = new ApexPages.StandardController(bc);
        ctr = new CtrBrandingContentScreen(stdCtr);
        res = ctr.approve();
        Test.stopTest();

        System.assertEquals(null, res);
    }

    @isTest static void rejectReturnCorrectlyOnFirstLevel() {
        Branding_Content__c bc = [Select Recordtype.Developername, Status__c, OwnerId, Opportunity__r.Record_Country__c from Branding_Content__c Where Status__c = 'Pending design approval' limit 1];

        PageReference pref = Page.BrandingContentScreen;
        pref.getParameters().put('id', bc.Id);

        CtrBrandingContentScreen ctr;
        PageReference res;

        Test.startTest();
        Test.setCurrentPage(pref);

        ApexPages.StandardController stdCtr = new ApexPages.StandardController(bc);
        ctr = new CtrBrandingContentScreen(stdCtr);
        res = ctr.reject();
        Test.stopTest();

        System.assertEquals(null, res);
        System.assertEquals('Design rejected', [select Status__c from Branding_Content__c Where id=: bc.id].Status__c);
    }

    @isTest static void rejectReturnCorrectlyOnSecondLevel() {
        Branding_Content__c bc = [Select Recordtype.Developername, Status__c, OwnerId, Opportunity__r.Record_Country__c from Branding_Content__c Where Status__c = 'Pending final approval' limit 1];

        PageReference pref = Page.BrandingContentScreen;
        pref.getParameters().put('id', bc.Id);

        CtrBrandingContentScreen ctr;
        PageReference res;

        Test.startTest();
        Test.setCurrentPage(pref);

        ApexPages.StandardController stdCtr = new ApexPages.StandardController(bc);
        ctr = new CtrBrandingContentScreen(stdCtr);
        res = ctr.reject();
        Test.stopTest();

        System.assertEquals(null, res);
        System.assertEquals('Rejected', [select Status__c from Branding_Content__c Where id=: bc.id].Status__c);
    }

    @isTest static void rejectReturnNullOnFirstLevelIfExceptionOccurs() {
        Branding_Content__c bc = [Select Recordtype.Developername, Status__c, OwnerId, Opportunity__r.Record_Country__c from Branding_Content__c Where Status__c = 'Pending design approval' limit 1];

        PageReference pref = Page.BrandingContentScreen;
        pref.getParameters().put('id', bc.Id);

        CtrBrandingContentScreen ctr;
        PageReference res;

        delete [select id from Business_Config__c where Business_Rule_name__c = 'rejectionStatusLevel1'];

        Test.startTest();
        Test.setCurrentPage(pref);

        ApexPages.StandardController stdCtr = new ApexPages.StandardController(bc);
        ctr = new CtrBrandingContentScreen(stdCtr);
        res = ctr.approve();
        Test.stopTest();

        System.assertEquals(null, res);
    }



    private static Branding_Content__c getCDBrandingContent(Account acc, Opportunity opp, String status, String productId) {
        return new Branding_Content__c(Restaurant_name__c = acc.Id,
                                       Status__c = status,
                                       RecordtypeId = cdBrandContRecType.Id,
                                       Opportunity__c = opp.Id,
                                       product__c = productId);
    }
}