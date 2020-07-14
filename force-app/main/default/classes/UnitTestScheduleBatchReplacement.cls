@isTest
private class UnitTestScheduleBatchReplacement {
private static List_Product_Price__c lpp3;
private static List_Product_Price__c lpp4;
private static Opportunity opp;
private static Opportunity opp1;
	

    static {
        UnitTestDataFactory.getRecordtypeValues();
        ReplacementOrderSettings__c rp = new ReplacementOrderSettings__c(name='UK',StageName__c='Replacement Charge',probability__c=50,Opportunity__c='name=Asset Replacement,RecordTypeId='+LibRecordTypeHelper.getRecordTypeValue('UK_Opportunity')+',CurrencyIsoCode=GBP,Business_Type__c=Upgrade/Upsell,stageName=Verbal Agreement',QualityCheckCaseSP__c='RecordTypeId='+LibRecordTypeHelper.getRecordTypeValue('UK_Internal_Case')+',type=Quality Check Replacement,subject=Quality Check Replacement,status=New,CurrencyIsoCode=GBP');
        insert rp;
        Country__c c = UnitTestDataFactory.createCountry('UK','United Kingdom', 'GBP');
        Company__c com = UnitTestDataFactory.createCompany('Hungryhouse', 'UK', c);
        User currentUser = [Select Id from user where id =: UserInfo.getUserId()];
        // Running in current user context to avoid Mixed dal opration with User
        System.runAs(currentUser){
	        // Making username unique so that it doesnt clashes with the username in any other org.
	        String orgId = UserInfo.getOrganizationId();
		    String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
		    Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
		    String uniqueName = orgId + dateString + randomInt;
        }
        insert new List<sObject>{c,com};
        
        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,c,'Apple','UK_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,c,'Setup Fee','UK_List_Product_Group');
        List_Product_Group__c lpg2 = UnitTestDataFactory.createProductGroup(com,c,'Replacement','UK_List_Product_Group');

        Account acc = UnitTestDataFactory.createAccount('TestAccount',c,'UK_Account');
        Account acc1 = UnitTestDataFactory.createAccount('TestAccount1',c,'UK_Account');

        insert new List<sObject>{lpg,lpg1,lpg2,acc,acc1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,c,'Ipad 4 Gen. 16GB',lpg.id,'UK_List_Product_Price',1,true,100,1,false,20);        
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,c,'Super Hero Setup 1',lpg1.id,'UK_List_Product_Price',1,true,100,1,false,null);
        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com,c,'Super Hero Setup 2',lpg1.id,'UK_List_Product_Price',1,true,50,1,true,20);
        lpp3 = UnitTestDataFactory.createProduct(com,c,'Replacement 3G',lpg2.id,'UK_List_Product_Price',1,true,150,1,false,null);
        lpp4 = UnitTestDataFactory.createProduct(com,c,'Replacement Livelink',lpg2.id,'UK_List_Product_Price',1,true,200,1,false,null);

        List_Service_Price__c lsp = UnitTestDataFactory.createService(com,c,'testService1','UK_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType');
        List_Service_Price__c lsp1 = UnitTestDataFactory.createService(com,c,'testService2','UK_List_Service_Price',12,12,13,5,null,true,null,'Commission','ServiceType');
        List_Service_Price__c lsp2 = UnitTestDataFactory.createService(com,c,'testService3','UK_List_Service_Price',12,12,13,5,null,true,null,'Commission','ServiceType');

        Tarif__c t = UnitTestDataFactory.createTarif(com,c,'testTarif1','UK_Tarif',false);
        Tarif__c t1 = UnitTestDataFactory.createTarif(com,c,'testTarif2','UK_Tarif',false);
        insert new List<sObject>{lpp,lpp1,lpp2,lpp3,lpp4,lsp,lsp1,lsp2,t,t1};

        opp = UnitTestDataFactory.createOpportunity('TestOpp123',acc,'UK_Opportunity',Date.today());
        opp1 = UnitTestDataFactory.createOpportunity('TestOpp456',acc1,'UK_Opportunity',Date.today());
        opp.type = 'Contract & Product';
        opp.Id_Tarif__c = t1.id;

        insert new List<sObject>{opp,opp1};
        
        Tarif_Member__c tm = UnitTestDataFactory.createTarifMember(lpp.id,'UK_Tarif_Member',t.id,'Product');
        Tarif_Member__c tm2 = UnitTestDataFactory.createTarifMember(lsp.id,'UK_Tarif_Member',t.id,'Service');
        Tarif_Member__c tm3 = UnitTestDataFactory.createTarifMember(lsp2.id,'UK_Tarif_Member',t1.id,'Service');
        Tarif_Member__c tm4 = UnitTestDataFactory.createTarifMember(lpp2.id,'UK_Tarif_Member',t1.id,'Product');
        Tarif_Member__c tm5 = UnitTestDataFactory.createTarifMember(lpp1.id,'UK_Tarif_Member',t1.id,'Product');

        //Opportunity_Tarif_Item__c oppTarif= UnitTestDataFactory.createOpportunityTarif('testTarif1',t1.id,opp.id,'UK_Opportunity_Tarif_Item');
       
        Opportunity_Line_Item__c oppProduct = UnitTestDataFactory.createOpportunityLineItemProduct('Super Hero Setup 2',opp,lpg1.id,lpp2.id,true,'UK_Opportunity_Line_Item',1,'',50,1,50,'Setup Fee');
        Opportunity_Line_Item__c oppProduct2 = UnitTestDataFactory.createOpportunityLineItemProduct('Super Hero Setup 1',opp,lpg1.id,lpp1.id,true,'UK_Opportunity_Line_Item',1,'',50,1,50,'Setup Fee');

        Opportunity_Line_Item__c oppService = UnitTestDataFactory.createOpportunityLineItemService('testService3',opp,lsp2.id,true,'UK_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        
        insert new List<sObject>{tm,tm2,tm3,tm4,tm5};
        t.Is_Active__c = true;
        t1.Is_Active__c = true;
        update new List<Tarif__c>{t,t1};

        insert new List<sObject>{oppProduct,oppProduct2,oppService};



        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c = 'OppStage', Business_Rule_Value__c = 'Closed Won,Closed Lost Shipment', Id_Country__c = c.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'BatchReplacementOrder', Record_Type_Id__c = 'UK_Asset', Type__c = 'Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c = 'RPbackOfficePending', Business_Rule_Value__c = 'Backoffice-Pending', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'BatchReplacementOrder', Record_Type_Id__c = 'UK_Asset', Type__c = 'Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c = 'RPbackOfficeApproved', Business_Rule_Value__c = 'Backoffice-Approved', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'BatchReplacementOrder', Record_Type_Id__c = 'UK_Asset', Type__c = 'Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c = 'oldQuoteStatus', Business_Rule_Value__c = 'Expired', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'BatchReplacementOrder', Record_Type_Id__c = 'UK_Asset', Type__c = 'Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c = 'OppQuoteAcceptStatus', Business_Rule_Value__c = 'Accepted', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'BatchReplacementOrder', Record_Type_Id__c = 'UK_Asset', Type__c = 'Process');
        insert new List<sObject>{b1,b2,b3,b4,b5};
        
    }
	
	@isTest static void test_method_one() {
        List<Asset__c> listAssets = new List<Asset__c>();
        Map<Id,Opportunity_Line_Item__c> mapOppline = new Map<Id,Opportunity_Line_Item__c>();
        List<Opportunity> listOpp = [select id,RecordType.DeveloperName,Country__c,Record_Country__c,AccountId,recordtypeid,subtotal__c,vat__c,total__c,currencyIsoCode from Opportunity where Id=:opp.Id];
        Opportunity_Quote__c oppQuote = new Opportunity_Quote__c(CurrencyIsoCode=listOpp[0].currencyIsoCode,Id_Account__c=listOpp[0].accountid,Id_Opportunity__c=listOpp[0].id,Description__c='test data',RecordTypeId=UnitTestDataFactory.mapRecordtypes.get('UK_Opportunity_Quote').id,Status__c='Accepted',Subtotal__c=19900,Total__c=19900);
        insert oppQuote;
        List<Opportunity_Line_Item__c> oppProductItem = [SELECT Commission_In_Percentage__c,Commission_Per_Order__c,Id_List_Service_Price__c,CurrencyIsoCode,Has_Related_Tarif__c,Id,Id_List_Price_Product__c,Id_List_Price_Product__r.Requires_Asset__c,Id_Opportunity__c,Id_Opportunity__r.OwnerId,Installments__c,Listed_Price__c,Name,Product_Group__c,Quantity__c,Discount__c,RecordTypeId,Total_Amount__c,Sub_Type__c,Line_Item_Type__c,Recurring_Fee__c,Start_Date__c,End_Date__c FROM Opportunity_Line_Item__c where  Id_Opportunity__c =:listOpp[0].id ];
        List<Opportunity_Quote_Line_Item__c> listOppQuotelines = new List<Opportunity_Quote_Line_Item__c>();
        for(Opportunity_Line_Item__c oppQP : oppProductItem){
            if(oppQp.Id_List_Price_Product__r.Requires_Asset__c){
                mapOppline.put(oppQp.Id_List_Price_Product__c,oppQp);
            }
            Opportunity_Quote_Line_Item__c oppQuoteLine = new Opportunity_Quote_Line_Item__c(Id_List_Service_Price__c=oppQP.Id_List_Service_Price__c,Commission_In_Percentage__c=oppQP.Commission_In_Percentage__c,Commission_Per_Order__c=oppQP.Commission_Per_Order__c,End_Date__c=oppQP.End_Date__c,Recurring_Fee__c=oppQP.Recurring_Fee__c,Start_Date__c=oppQP.Start_Date__c,CurrencyIsoCode=listOpp[0].currencyIsoCode,Has_Related_Tarif__c=true,Id_List_Product_Price__c=oppQP.Id_List_Price_Product__c,Id_Opportunity_Quote__c=oppQuote.id,Installments__c=oppQP.Installments__c,Listed_Price__c=oppQP.Listed_Price__c,Name=oppQP.name,Product_Group__c=oppQP.Product_Group__c,Quantity__c=oppQP.Quantity__c,Discount__c=oppQP.Discount__c,RecordTypeId=UnitTestDataFactory.mapRecordtypes.get('UK_Opportunity_Quote_Line_Item').id,Total_Amount__c=oppQp.Total_Amount__c,Sub_Type__c=oppQp.Sub_Type__c,Line_Item_Type__c=oppQp.Line_Item_Type__c,Id_Opportunity__c=oppQp.Id_Opportunity__c);
            listOppQuotelines.add(oppQuoteLine);

        }
        insert listOppQuotelines;
        for(Opportunity_Quote_Line_Item__c oppQlineItem : listOppQuotelines){
            if(mapOppline.get(oppQlineItem.Id_List_Product_Price__c)!=null){
                Asset__c newAsset = new Asset__c();
                newAsset.OwnerId = mapOppline.get(oppQlineItem.Id_List_Product_Price__c).Id_Opportunity__r.ownerId;
                newAsset.name = oppQlineItem.name;
                newAsset.Account__c = listOpp[0].AccountId;
                newAsset.CurrencyIsoCode = oppQlineItem.CurrencyIsoCode;
                newAsset.RecordTypeId = UnitTestDataFactory.mapRecordtypes.get('UK_Asset').Id;
                newAsset.Id_Opportunity_Quote_Line_Item__c = oppQlineItem.Id;
                newAsset.Opportunity__c = oppQlineItem.Id_Opportunity__c;
                newAsset.Status__c = 'New - Awaiting Shipping';
                listAssets.add(newAsset);
            }
        }
        List<Replacement_Order__c> replacements = new List<Replacement_Order__c>();
        insert listAssets;
        replacements.add(new Replacement_Order__c(Status__c='Transmission-Approved',Amount__c=10,CurrencyIsoCode=listAssets[0].CurrencyIsoCode,Id_List_Product_Price__c=lpp3.id,Id_Asset__c=listAssets[0].id,Id_Opportunity__c=listAssets[0].Opportunity__c,Id_Account__c=listAssets[0].Account__c,RecordTypeId=LibRecordTypeHelper.getRecordTypeValue('UK_Replacement_Order')));
        replacements.add(new Replacement_Order__c(Status__c='Transmission-Approved',Amount__c=0.01,CurrencyIsoCode=listAssets[0].CurrencyIsoCode,Id_List_Product_Price__c=lpp4.id,Id_Asset__c=listAssets[0].id,Id_Opportunity__c=listAssets[0].Opportunity__c,Id_Account__c=listAssets[0].Account__c,RecordTypeId=LibRecordTypeHelper.getRecordTypeValue('UK_Replacement_Order')));
        insert replacements;
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        Test.startTest();
        String jobId = System.schedule('ScheduleBatchReplacementTest', CRON_EXP, new ScheduleBatchReplacement());
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));

	}
	
	@isTest static void test_method_two() {
        List<Asset__c> listAssets = new List<Asset__c>();
        Map<Id,Opportunity_Line_Item__c> mapOppline = new Map<Id,Opportunity_Line_Item__c>();
        List<Opportunity> listOpp = [select id,RecordType.DeveloperName,StageName,Probability,Country__c,Record_Country__c,AccountId,recordtypeid,subtotal__c,vat__c,total__c,currencyIsoCode from Opportunity where Id=:opp.Id];
        Opportunity_Quote__c oppQuote = new Opportunity_Quote__c(CurrencyIsoCode=listOpp[0].currencyIsoCode,Id_Account__c=listOpp[0].accountid,Id_Opportunity__c=listOpp[0].id,Description__c='test data',RecordTypeId=UnitTestDataFactory.mapRecordtypes.get('UK_Opportunity_Quote').id,Status__c='Accepted',Subtotal__c=19900,Total__c=19900);
        insert oppQuote;
        List<Opportunity_Line_Item__c> oppProductItem = [SELECT Commission_In_Percentage__c,Commission_Per_Order__c,Id_List_Service_Price__c,CurrencyIsoCode,Has_Related_Tarif__c,Id,Id_List_Price_Product__c,Id_List_Price_Product__r.Requires_Asset__c,Id_Opportunity__c,Id_Opportunity__r.OwnerId,Installments__c,Listed_Price__c,Name,Product_Group__c,Quantity__c,Discount__c,RecordTypeId,Total_Amount__c,Sub_Type__c,Line_Item_Type__c,Recurring_Fee__c,Start_Date__c,End_Date__c FROM Opportunity_Line_Item__c where  Id_Opportunity__c =:listOpp[0].id ];
        List<Opportunity_Quote_Line_Item__c> listOppQuotelines = new List<Opportunity_Quote_Line_Item__c>();
        for(Opportunity_Line_Item__c oppQP : oppProductItem){
            if(oppQp.Id_List_Price_Product__r.Requires_Asset__c){
                mapOppline.put(oppQp.Id_List_Price_Product__c,oppQp);
            }
            Opportunity_Quote_Line_Item__c oppQuoteLine = new Opportunity_Quote_Line_Item__c(Id_List_Service_Price__c=oppQP.Id_List_Service_Price__c,Commission_In_Percentage__c=oppQP.Commission_In_Percentage__c,Commission_Per_Order__c=oppQP.Commission_Per_Order__c,End_Date__c=oppQP.End_Date__c,Recurring_Fee__c=oppQP.Recurring_Fee__c,Start_Date__c=oppQP.Start_Date__c,CurrencyIsoCode=listOpp[0].currencyIsoCode,Has_Related_Tarif__c=true,Id_List_Product_Price__c=oppQP.Id_List_Price_Product__c,Id_Opportunity_Quote__c=oppQuote.id,Installments__c=oppQP.Installments__c,Listed_Price__c=oppQP.Listed_Price__c,Name=oppQP.name,Product_Group__c=oppQP.Product_Group__c,Quantity__c=oppQP.Quantity__c,Discount__c=oppQP.Discount__c,RecordTypeId=UnitTestDataFactory.mapRecordtypes.get('UK_Opportunity_Quote_Line_Item').id,Total_Amount__c=oppQp.Total_Amount__c,Sub_Type__c=oppQp.Sub_Type__c,Line_Item_Type__c=oppQp.Line_Item_Type__c,Id_Opportunity__c=oppQp.Id_Opportunity__c);
            listOppQuotelines.add(oppQuoteLine);

        }
        insert listOppQuotelines;
        for(Opportunity_Quote_Line_Item__c oppQlineItem : listOppQuotelines){
            if(mapOppline.get(oppQlineItem.Id_List_Product_Price__c)!=null){
                Asset__c newAsset = new Asset__c();
                newAsset.OwnerId = mapOppline.get(oppQlineItem.Id_List_Product_Price__c).Id_Opportunity__r.ownerId;
                newAsset.name = oppQlineItem.name;
                newAsset.Account__c = listOpp[0].AccountId;
                newAsset.CurrencyIsoCode = oppQlineItem.CurrencyIsoCode;
                newAsset.RecordTypeId = UnitTestDataFactory.mapRecordtypes.get('UK_Asset').Id;
                newAsset.Id_Opportunity_Quote_Line_Item__c = oppQlineItem.Id;
                newAsset.Opportunity__c = oppQlineItem.Id_Opportunity__c;
                newAsset.Status__c = 'New - Awaiting Shipping';
                listAssets.add(newAsset);
            }
        }

        insert listAssets;
        listOpp[0].StageName = 'Closed Won';
        listOpp[0].Probability = 100;
        update listOpp[0];

        List<Replacement_Order__c> replacements = new List<Replacement_Order__c>();
        replacements.add(new Replacement_Order__c(Status__c='Transmission-Approved',Amount__c=10,CurrencyIsoCode=listAssets[0].CurrencyIsoCode,Id_List_Product_Price__c=lpp3.id,Id_Asset__c=listAssets[0].id,Id_Opportunity__c=listAssets[0].Opportunity__c,Id_Account__c=listAssets[0].Account__c,RecordTypeId=LibRecordTypeHelper.getRecordTypeValue('UK_Replacement_Order')));
        replacements.add(new Replacement_Order__c(Status__c='Transmission-Approved',Amount__c=0.01,CurrencyIsoCode=listAssets[0].CurrencyIsoCode,Id_List_Product_Price__c=lpp4.id,Id_Asset__c=listAssets[0].id,Id_Opportunity__c=listAssets[0].Opportunity__c,Id_Account__c=listAssets[0].Account__c,RecordTypeId=LibRecordTypeHelper.getRecordTypeValue('UK_Replacement_Order')));
        insert replacements;

        String CRON_EXP = '0 0 0 15 3 ? 2022';
        Test.startTest();
        String jobId = System.schedule('ScheduleBatchReplacementTest', CRON_EXP, new ScheduleBatchReplacement());
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
	}
	
}