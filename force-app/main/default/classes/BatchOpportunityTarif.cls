/*
@author : Magesh Mani Yadav
@reviewer : 
@creation : 19.11.2014
*/
global class BatchOpportunityTarif implements Database.Batchable<sObject>,Database.Stateful {
    
    
    Map<String,Map<String,Business_Config__c>> mapBusinessLogic = new Map<String,Map<String,Business_Config__c>>();
    Map<String,RecordType> mapRecordTypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Opportunity_Line_Item__c','Opportunity_Quote__c','Opportunity_Quote_Line_Item__c','Contract','Asset__c','Additional_Charges__c','Add_On_Service__c'});
    String migrationText;
	

    global BatchOpportunityTarif() {
        mapBusinessLogic = LibBusinessConfig.getGenericProcessData('BatchSchedulerForOpportunity');
        migrationText = BatchOpportunityTarif_MigrationText__c.getValues('FilterText').Value__c;
    }
    //Fetches all the opportunity which doesnot have Opportunity_Tarif_Item__c 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('migrationText: '+migrationText);
        return Database.getQueryLocator([select id,name,closeDate,Id_Tarif__c,Lost_Date__c,stageName,AccountId,RecordType.DeveloperName,CurrencyIsoCode,FreeTrial_End_AU__c,FreeTrial_Start_AU__c,Commi__c,Online_Payment_Fee_AU__c,
            Order_Transmission_Fee_AU__c,Setup_Fee_AU__c,TarrifName_AU__c,tariff_range_CD__C,addon_Specification__c,addon_startdate__c,Online_Payment_Fee_perOrder_CD__c,tariff_Online_CD__C,Start_Date_uk__c,Renewal_Fee_TB__c,ownerId,FixedPerOrder_AU__c,Installment_migration__c,AssetPrice_migration__c,Asset_Installment_migration__c
            from Opportunity
            where Is_DataLoaded__c=true and Migration_Notes_AU__c=:migrationText and Id_Tarif__c=null  ]);
    }

    //creates Opportunity_Tarif_Item__c,Opportunity_Service_Item__c and Opportunity_Product_Item__c for every opportunity
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<String> oppTarifNames = new List<String>();
        Map<String,String> mapServiceList = new Map<String,String>();
        Map<String,String> mapProductList = new Map<String,String>();
        Map<String,String> mapAddon = new Map<String,String>();
        Map<String,List<String>> mapServiceTarifmember1 = new Map<String,List<String>>();
        Map<String,List<String>> mapProductTarifmember1 = new Map<String,List<String>>();
         Map<String,List<String>> mapAddOnmember1 = new Map<String,List<String>>();
        List<Opportunity_Quote__c> listOppQuote = new List<Opportunity_Quote__c>();
        List<Opportunity_Line_Item__c> listOpplines = new List<Opportunity_Line_Item__c>();
        List<Opportunity_Quote_Line_Item__c> listOppQuoteLines = new List<Opportunity_Quote_Line_Item__c>();
        Map<Id,List_Service_Price__c> mapListServicePrice = new Map<Id,List_Service_Price__c>();
        Map<Id,List_Product_Price__c> mapListProductPrice = new Map<Id,List_Product_Price__c>();
        Map<Id,List_Add_On__c> mapListAddOn = new Map<Id,List_Add_On__c>();
        Map<String,List<List_Service_Price__c>> mapServicePrices = new Map<String,List<List_Service_Price__c>>();
        Map<String,List<List_Product_Price__c>> mapProductPrices = new Map<String,List<List_Product_Price__c>>();

        Map<String,String> mapQuoteOppIds = new Map<String,String>();
        Map<String,Id> mapTarif = new Map<String,Id>();
        Map<id,Opportunity> mapOpp = new Map<id,Opportunity>();
        Map<id,String> mapOppRecordtype = new Map<id,String>();
        List<Contract> listNewContracts = new List<Contract>();
        if(!mapBusinessLogic.isEmpty()){
            for(SObject s: scope){
                Opportunity opp = (Opportunity) s;
                mapOppRecordtype.put(opp.id,opp.RecordType.DeveloperName);
                if(opp.TarrifName_AU__c!=null){
                    if(!mapBusinessLogic.isEmpty() && mapBusinessLogic.size()==1){
                        if(mapBusinessLogic.get(opp.RecordType.DeveloperName)!=null){
                            oppTarifNames.add(opp.TarrifName_AU__c);
                            mapOpp.put(opp.id,opp);
                        }else{
                            System.debug('Business config for BatchSchedulerForOpportunity is not active for recordtype '+opp.RecordType.DeveloperName);
                        }
                    }else{
                        System.debug('Only one business process can be active!');
                    }
                }
            }
            if(!mapOpp.isEmpty()){
                for(Tarif_Member__c trMem :  [SELECT Id, Tarif_Name__c,Tarif_Name__r.Id,Tarif_Name__r.name,Id_Tarif_Item__c, Type__c
                                                FROM Tarif_Member__c
                                                WHERE Tarif_Name__r.name in: oppTarifNames]){
                                                system.debug(trMem );
                    if(trMem.Id_Tarif_Item__c!=null){
                        if(mapTarif.get(trMem.Tarif_Name__r.name)==null)
                        mapTarif.put(trMem.Tarif_Name__r.name,trMem.Tarif_Name__r.Id);
                        if(trMem.Type__c=='Service'){

                                if(mapServiceTarifmember1.get(trMem.Tarif_Name__r.name)==null){
                                    mapServiceTarifmember1.put(trMem.Tarif_Name__r.name, new List<String>{trMem.Id_Tarif_Item__c});

                                }else{
                                    List<String> tarifItems = mapServiceTarifmember1.get(trMem.Tarif_Name__r.name);
                                    tarifItems.add(trMem.Id_Tarif_Item__c);
                                    mapServiceTarifmember1.remove(trMem.Tarif_Name__r.name);
                                    mapServiceTarifmember1.put(trMem.Tarif_Name__r.name, tarifItems);

                                }
                                if(mapServiceList.get(trMem.Id_Tarif_Item__c)==null)
                                    mapServiceList.put(trMem.Id_Tarif_Item__c,trMem.Tarif_Name__r.name);
                        }else if(trMem.Type__c=='AddOn'){

                            if(mapAddOnmember1.get(trMem.Tarif_Name__r.name)==null){
                                    mapAddOnmember1.put(trMem.Tarif_Name__r.name, new List<String>{trMem.Id_Tarif_Item__c});

                                }else{
                                    List<String> tarifItems = mapAddOnmember1.get(trMem.Tarif_Name__r.name);
                                    tarifItems.add(trMem.Id_Tarif_Item__c);
                                    mapAddOnmember1.remove(trMem.Tarif_Name__r.name);
                                    mapAddOnmember1.put(trMem.Tarif_Name__r.name, tarifItems);

                                }
                                if(mapAddOn.get(trMem.Id_Tarif_Item__c)==null)
                                    mapAddOn.put(trMem.Id_Tarif_Item__c,trMem.Tarif_Name__r.name);


                        }else{

                            if(mapProductTarifmember1.get(trMem.Tarif_Name__r.name)==null){
                                mapProductTarifmember1.put(trMem.Tarif_Name__r.name, new List<String>{trMem.Id_Tarif_Item__c});
                            }else{
                                List<String> tarifItems = mapProductTarifmember1.get(trMem.Tarif_Name__r.name);
                                tarifItems.add(trMem.Id_Tarif_Item__c);
                                mapProductTarifmember1.remove(trMem.Tarif_Name__r.name);
                                mapProductTarifmember1.put(trMem.Tarif_Name__r.name, tarifItems);
                            }
                            if(mapProductList.get(trMem.Id_Tarif_Item__c)==null){
                                mapProductList.put(trMem.Id_Tarif_Item__c,trMem.Tarif_Name__r.name);
                            }
                        }
                    }
                }


                if(!mapServiceList.isEmpty()){
                        mapListServicePrice = new Map<Id,List_Service_Price__c>([SELECT Id, Name,Requires_Approval__c,Service_Type__c,Commission_Type__c,Commission_Per_Order__c, Commission_In_Percentage__c,Is_Active__c,
                                                                Maximum_Commission_In_Percentage__c, Minimum_Commission_in_Percentage__c, Type__c, Recurring_Fee__c
                                                                FROM List_Service_Price__c
                                                                WHERE Id IN :mapServiceList.keySet() AND Is_Active__c = true]);
                }
                if(!mapProductList.isEmpty()){
                    mapListProductPrice = new Map<Id,List_Product_Price__c>([SELECT Id, Name, Id_List_Product_Group__r.Name,maximum_discount__c, Default_Quantity__c, Installments__c, Is_Active__c,
                                                            Product_Name__c, List_Price__c,Product_Type__c,Requires_Additional_Charge__c,Requires_Add_On__c,Requires_Asset__c,Requires_Branding__c,Unapproved_Discount_Limit__c
                                                            FROM List_Product_Price__c
                                                            WHERE Id IN :mapProductList.keySet() AND Is_Active__c = true]);
                }if(!mapAddOn.isEmpty()){
                    mapListAddOn = new Map<Id,List_Add_On__c>([SELECT Id, Name, Contract_Addition__c,  Is_Active__c,
                                                            type__c
                                                            FROM List_Add_On__c
                                                            WHERE Id IN :mapAddOn.keySet() AND Is_Active__c = true]);
                }
                System.debug('mapServiceList: '+mapServiceList);
                System.debug('mapProductList: '+mapProductList);
                for(Opportunity opp:  mapOpp.values()){
                    Map<String,Business_Config__c> mapBusinessData = mapBusinessLogic.get(opp.RecordType.DeveloperName);
                    if(!mapBusinessData.isEmpty()){
                        if(mapTarif.get(opp.TarrifName_AU__c)!=null){
                            opp.Id_Tarif__c = mapTarif.get(opp.TarrifName_AU__c);
                            listOppQuote.add(new Opportunity_Quote__c(Id_Opportunity__c=opp.id,CurrencyIsoCode=opp.CurrencyIsoCode,status__c='Accepted',Id_Account__c=opp.AccountId,recordtypeId=mapRecordTypes.get(mapBusinessData.get('opportunity_quote_recordType').Business_Rule_Value__c).id));
                            if(mapServiceTarifmember1.get(opp.TarrifName_AU__c)!=null){
                                for(String listServiceId : mapServiceTarifmember1.get(opp.TarrifName_AU__c)){
                                    Decimal commPercent;
                                    Decimal commPerOrder;
                                    Date startDate;
                                    Date endDate;
                                    List_Service_Price__c listService = mapListServicePrice.get(listServiceId);
                                    commPercent = opp.Commi__c!=null ? opp.Commi__c : listService.Commission_In_Percentage__c;
                                    if(opp.StageName == 'Terminal Returned' || opp.StageName == 'Closed Lost'){
                                       if(opp.Lost_Date__c!=null){
                                            endDate = opp.Lost_Date__c;
                                        }else{
                                            endDate = opp.CloseDate;
                                            if(mapBusinessData.get('enableAnnualEndDate')!=null && Boolean.valueOf(mapBusinessData.get('enableAnnualEndDate').Business_Rule_Value__c)){
                                                endDate = opp.CloseDate.addYears(1).addDays(-1);
                                            }
                                        }
                                    }else{
                                        if(mapBusinessData.get('enableAnnualEndDate')!=null && Boolean.valueOf(mapBusinessData.get('enableAnnualEndDate').Business_Rule_Value__c)){
                                            endDate = opp.CloseDate.addYears(1).addDays(-1);
                                        }
                                    }
                                    startDate = opp.CloseDate;
                                    if(listService.Commission_Type__c=='Per Order'){
                                        commPerOrder = opp.FixedPerOrder_AU__c!=null ? opp.FixedPerOrder_AU__c : listService.Commission_Per_Order__c;
                                    }

                                    if(listService.name.contains('Free Trial')){
                                        commPercent = listService.Commission_In_Percentage__c;
                                        startDate = opp.FreeTrial_Start_AU__c;
                                        endDate = opp.FreeTrial_End_AU__c;
                                    }else{
                                        if(listService.Service_Type__c.contains('Commission Fee')){
                                            commPercent = opp.Commi__c!=null ? opp.Commi__c : listService.Commission_In_Percentage__c;
                                        }else if(listService.Service_Type__c.contains('Transmission Fee')){
                                            commPercent = opp.Order_Transmission_Fee_AU__c!=null ? opp.Order_Transmission_Fee_AU__c : listService.Commission_In_Percentage__c;
                                        }else if(listService.Service_Type__c.contains('Online Payment Fee')){
                                            if(listService.Commission_Type__c!='Per Order' )
                                                commPercent = opp.Online_Payment_Fee_AU__c!=null ? opp.Online_Payment_Fee_AU__c : listService.Commission_In_Percentage__c;
                                            else
                                                commPerOrder = opp.Online_Payment_Fee_perOrder_CD__c!=null ? opp.Online_Payment_Fee_perOrder_CD__c : listService.Commission_Per_Order__c;
                                        }
                                        startDate = opp.Start_Date_uk__c;
                                        endDate = null;
                                    }if(mapBusinessData.get('tieredKeyword')!=null && opp.TarrifName_AU__c.containsignorecase(mapBusinessData.get('tieredKeyword').Business_Rule_Value__c)){


                                            JSONParser parser = JSON.createParser(opp.tariff_range_CD__C );
                                            do{
                                                parser.nextToken();
                                            }while(parser.hasCurrentToken() && !'data'.equals(parser.getCurrentName()));
                                            parser.nextToken();
                                            List<RangeWrapper> rangeLst= (List<RangeWrapper>)parser.readValueAs(List<RangeWrapper>.class);
                                            Map<string,String> minValueOPMap = new Map<String,String>();
                                            if(opp.tariff_Online_CD__C!=null){
                                            JSONParser parser2 = JSON.createParser(opp.tariff_Online_CD__C );
                                            do{
                                                parser2.nextToken();
                                            }while(parser2.hasCurrentToken() && !'data'.equals(parser2.getCurrentName()));
                                            parser2.nextToken();
                                            List<RangeWrapper> onlinePaymentLst = (List<RangeWrapper>)parser2.readValueAs(List<RangeWrapper>.class);
                                            system.debug(onlinePaymentLst);

                                             for(RangeWrapper rw:onlinePaymentLst){
                                                 minValueOPMap.put(rw.desde,rw.valor);

                                             }
                                            }
                                            system.debug(rangeLst);
                                            integer i=1;
                                            Decimal commPercentDec;
                                            Decimal commPerOrderDec;
                                            for(RangeWrapper rw:rangeLst){
                                                Integer Max;

                                                if((rw.hasta!='n')){
                                                    Max=Integer.valueof(rw.hasta);
                                                }
                                                if(rw.tipo=='%'){
                                                    commPercentDec=Decimal.Valueof(rw.valor);
                                                }else
                                                    commPerOrderDec=Decimal.valueof(rw.valor);

                                                Decimal onlinepayment = 0.0;
                                                system.debug('@@#'+minValueOPMap);
                                                if(minValueOPMap!=null && !minValueOPMap.isEmpty() &&  minValueOPMap.get(rw.desde)!=null)
                                                onlinepayment=  Decimal.valueof(minValueOPMap.get(rw.desde));

                                            listOpplines.add(new Opportunity_Line_Item__c(Id_List_Service_Price__c = listService.id,
                                                                         name = listService.name, Commission_In_Percentage__c = commPercentDec,
                                                                         Commission_Per_Order__c =commPerOrderDec,Id_Opportunity__c = opp.id,start_date__c=startDate,End_Date__c=endDate, Max__c=Integer.Valueof(Max),min__c=Integer.valueof(rw.desde),IsTiered__c=true,online_payment_fee__c=onlinepayment,
                                                                         /*Type__c=listService.Type__c,*/Has_Related_Tarif__c = true,Line_Item_Type__c='Service',
                                                                         recordtypeid = mapRecordTypes.get(mapBusinessData.get('opportunity_service_recordType').Business_Rule_Value__c).id, index__c=i,
                                                                         CurrencyIsoCode = opp.CurrencyIsoCode, Recurring_Fee__c = listService.Recurring_Fee__c,Sub_Type__c = listService.Service_Type__c));
                                    listOppQuoteLines.add(new Opportunity_Quote_Line_Item__c(name=listService.name,Commission_In_Percentage__c=commPercentDec,Commission_Per_Order__c =commPerOrderDec,
                                         /*Type__c=listService.Type__c,*/Has_Related_Tarif__c=true,Max__c=Integer.Valueof(Max),IsTiered__c=true,min__c=Integer.valueof(rw.desde),End_Date__c=endDate, Start_Date__c=startDate,Line_Item_Type__c='Service',index__c=i,online_payment_fee__c=onlinepayment,
                                           recordtypeId = mapRecordTypes.get(mapBusinessData.get('opportunity_quote_service_recordType').Business_Rule_Value__c).id,  Id_Opportunity__c =opp.id,
                                           CurrencyIsoCode = opp.CurrencyIsoCode,Recurring_Fee__c = listService.Recurring_Fee__c,Sub_Type__c = listService.Service_Type__c,Migration_OppId__c=opp.Id));
                                        i++;

                                            }
                                    }
                                    else{
                                    listOpplines.add(new Opportunity_Line_Item__c(Id_List_Service_Price__c = listService.id,
                                                                         name = listService.name, Commission_In_Percentage__c = commPercent,
                                                                         Commission_Per_Order__c =commPerOrder,Id_Opportunity__c = opp.id,start_date__c=startDate,End_Date__c=endDate,
                                                                         /*Type__c=listService.Type__c,*/Has_Related_Tarif__c = true,Line_Item_Type__c='Service',
                                                                         recordtypeid = mapRecordTypes.get(mapBusinessData.get('opportunity_service_recordType').Business_Rule_Value__c).id,
                                                                         CurrencyIsoCode = opp.CurrencyIsoCode, Recurring_Fee__c = listService.Recurring_Fee__c,Sub_Type__c = listService.Service_Type__c));
                                    listOppQuoteLines.add(new Opportunity_Quote_Line_Item__c(Id_List_Service_Price__c = listService.id,name=listService.name,Commission_In_Percentage__c=commPercent,Commission_Per_Order__c =commPerOrder,
                                         /*Type__c=listService.Type__c,*/Has_Related_Tarif__c=true,End_Date__c=endDate, Start_Date__c=startDate,Line_Item_Type__c='Service',
                                           recordtypeId = mapRecordTypes.get(mapBusinessData.get('opportunity_quote_service_recordType').Business_Rule_Value__c).id,  Id_Opportunity__c =opp.id,
                                           CurrencyIsoCode = opp.CurrencyIsoCode,Recurring_Fee__c = listService.Recurring_Fee__c,Sub_Type__c = listService.Service_Type__c,Migration_OppId__c=opp.Id));
                                }
                            }
                            }
                            if(mapProductTarifmember1.get(opp.TarrifName_AU__c)!=null){
                                for(String listProductId : mapProductTarifmember1.get(opp.TarrifName_AU__c)){
                                    List_Product_Price__c listProduct = mapListProductPrice.get(listProductId);
                                    //if(opp.Setup_Fee_AU__c!=null){
                                        Decimal prodPrice;
                                        Integer install = 1;
                                        if(listProduct.Requires_Asset__c){
                                            prodPrice = opp.AssetPrice_migration__c!=null ? opp.AssetPrice_migration__c : listProduct.List_Price__c;
                                            if(opp.Asset_Installment_migration__c!=null){
                                                install = Integer.valueOf(opp.Asset_Installment_migration__c);
                                            }
                                        }else{
                                            if(opp.Installment_migration__c!=null){
                                                install = Integer.valueOf(opp.Installment_migration__c);
                                            }
                                            if(listProduct.product_type__c=='Setup Fee'){
                                                prodPrice = opp.Setup_Fee_AU__c!=null ? opp.Setup_Fee_AU__c : listProduct.List_Price__c;
                                            }else if(listProduct.product_type__c=='Renewal Fee'){
                                                system.debug('@@recurringfee'+opp.Renewal_Fee_TB__c);
                                                 prodPrice = opp.Renewal_Fee_TB__c!=null ? opp.Renewal_Fee_TB__c : listProduct.List_Price__c;
                                            }

                                        }
                                        listOpplines.add(new Opportunity_Line_Item__c(Id_List_Price_Product__c = listProduct.id, name = listProduct.Product_Name__c, Listed_Price__c = prodPrice, Quantity__c = 1,
                                                                         Total_Amount__c = prodPrice, Product_Group__c = listProduct.Id_List_Product_Group__r.Name,Line_Item_Type__c='Product',
                                                                         Installments__c = install, Id_Opportunity__c = opp.id,Has_Related_Tarif__c = true,sub_type__c=listProduct.Product_Type__c,
                                                                         recordtypeid = mapRecordTypes.get(mapBusinessData.get('opportunity_product_recordType').Business_Rule_Value__c).id, CurrencyIsoCode = opp.CurrencyIsoCode));
                                        listOppQuoteLines.add(new Opportunity_Quote_Line_Item__c(name = listProduct.Product_Name__c,Id_List_Product_Price__c = listProduct.id,
                                         Listed_Price__c = prodPrice, Quantity__c = 1, Total_Amount__c = prodPrice,Id_Opportunity__c= opp.id,
                                          Product_Group__c = listProduct.Id_List_Product_Group__r.Name, Installments__c = install,
                                           Has_Related_Tarif__c = true, recordtypeId = mapRecordTypes.get(mapBusinessData.get('opportunity_quote_product_recordType').Business_Rule_Value__c).id,
                                            CurrencyIsoCode = opp.CurrencyIsoCode,Migration_OppId__c=opp.Id,Line_Item_Type__c='Product',sub_type__c=listProduct.Product_Type__c));

                                    //}
                                }
                            }//ifaddon
                            if(mapAddOnmember1.get(opp.TarrifName_AU__c)!=null){
                                for(String listAddonId : mapAddOnmember1.get(opp.TarrifName_AU__c)){
                                    List_Add_On__c listaddon = mapListAddOn.get(listAddonId);
                                    //if(opp.Setup_Fee_AU__c!=null){
                                        Decimal prodPrice;
                                        Integer install = 1;
                                        String specifications ='';
                                        Date startDate;
                                        startDate = opp.CloseDate;
                                        if(opp.addon_Specification__c!=null){
                                            specifications=opp.addon_Specification__c;
                                        }else{
                                            specifications=listaddon.Contract_Addition__c;
                                        }if(opp.addon_startdate__c!=null){
                                            startDate=opp.addon_startdate__c;
                                        }
                                        system.debug(mapBusinessData);
                                        listOpplines.add(new Opportunity_Line_Item__c(Id_List_Add_On__c = listAddon.id, name = listaddon.name,Quantity__c = 1,
                                                                         Line_Item_Type__c='AddOn',Specifications__c=specifications,start_date__c=opp.addon_startdate__c,
                                                                          Id_Opportunity__c = opp.id,Has_Related_Tarif__c = true,sub_type__c=listAddon.type__c,
                                                                         recordtypeid = mapRecordTypes.get(mapBusinessData.get('opportunity_product_recordType').Business_Rule_Value__c).id, CurrencyIsoCode = opp.CurrencyIsoCode));
                                        listOppQuoteLines.add(new Opportunity_Quote_Line_Item__c(name = listaddon.Name,
                                         Id_Opportunity__c= opp.id,Specifications__c=specifications,start_date__c=opp.addon_startdate__c,

                                           Has_Related_Tarif__c = true, recordtypeId = mapRecordTypes.get(mapBusinessData.get('opportunity_quote_product_recordType').Business_Rule_Value__c).id,
                                            CurrencyIsoCode = opp.CurrencyIsoCode,Migration_OppId__c=opp.Id,Line_Item_Type__c='AddOn',sub_type__c=listAddOn.Type__c));

                                    //}
                                }
                            }
                        }
                    }

                }
                System.debug('list opp listOpplines: '+listOpplines);
                insert listOpplines;
                insert listOppQuote;
                Map<Id,Opportunity_Quote_Line_Item__c> mapOppQuoteProd = new Map<Id,Opportunity_Quote_Line_Item__c>();
                List<Additional_Charges__c> listAdditional = new List<Additional_Charges__c>();
                List<Asset__c> listProcessAssetForAddCharge = new List<Asset__c>();
                List<Asset__c> listAssets = new List<Asset__c>();
                List<Add_on_Service__c> listNewAddons = new List<Add_on_Service__c>();
                List<Branding_Content__c>listBranding=new List<Branding_Content__c>();
                Map<Id,Opportunity_Quote__c> mapOppQuote = new Map<id,Opportunity_Quote__c>();
                for(Opportunity_Quote__c oppQ : listOppQuote){
                    mapQuoteOppIds.put(oppQ.Id_Opportunity__c,oppQ.Id);
                    mapOppQuote.put(oppQ.id,oppQ);
                }
                for(Opportunity_Quote_Line_Item__c oppQS :listOppQuoteLines){
                    oppQS.Id_Opportunity_Quote__c = mapQuoteOppIds.get(oppQS.Migration_OppId__c);
                }
                insert listOppQuoteLines;
                Map<Id,Account> updateNonContractAccount = new Map<Id,Account>();
                for(Opportunity_Quote_Line_Item__c oppQlineItem : [ Select Id, Name,Line_Item_Type__c,Sub_type__c,Id_List_Service_Price__c, CurrencyIsoCode, Commission_In_Percentage__c,Commission_Per_Order__c, Start_Date__c, End_Date__c,
                        Id_Opportunity_Quote__c, Recurring_Fee__c,Id_Opportunity__r.ownerId,Id_Opportunity__r.RecordType.DeveloperName,Id_Opportunity__r.AccountId, Id_Opportunity__r.Account.Non_Contracted__c,
                        recordtype.DeveloperName,
                        (select name,Account__c,CurrencyIsoCode,RecordTypeId,Id_Opportunity_Quote_Line_Item__c,Opportunity__c,Status__c/*,Id_Additional_Charges__c*/ from Assets__r),
                        Id_Opportunity__c,Specifications__c,Id_Opportunity__r.CloseDate,Id_List_Product_Price__r.Requires_Asset__c,Id_List_Product_Price__r.Requires_Additional_Charge__c,
                        Id_List_Product_Price__r.Requires_Add_On__c,Id_List_Product_Price__r.Requires_Branding__c,Id_List_Product_Price__r.Product_Type__c,Id_List_Product_Price__r.Product_Name__c,min__c,max__c,isTiered__c,index__c,
                        Has_Related_Tarif__c,Id_List_Product_Price__c,Installments__c,Listed_Price__c,Online_Payment_Fee__c,
                        Product_Group__c,Quantity__c,Discount__c,Total_Amount__c,Category__c,Category_Id__c,District__c,District_Id__c,City_ZipCode__c
                        FROM Opportunity_Quote_Line_Item__c
                        WHERE Id_Opportunity_Quote__c IN :mapOppQuote.keySet()
                    ])
                {
                    System.debug('oppQlineItem.Id_Opportunity__r.RecordType.DeveloperName: '+oppQlineItem.Id_Opportunity__r.RecordType.DeveloperName);
                    Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(oppQlineItem.Id_Opportunity__r.RecordType.DeveloperName);
                    if(mapBusinessRules!=null && !mapBusinessRules.isEmpty()){
                        Id oppId = oppQlineItem.Id_Opportunity__c;
                        Id accId = oppQlineItem.Id_Opportunity__r.AccountId;
                        if(oppQlineItem.Line_Item_Type__c=='Service'){
                            Contract contr = new Contract();
                            contr.AccountId  = accId;
                            contr.Id_Opportunity_Quote_Line_Item__c = oppQlineItem.id;
                            contr.Id_Opportunity__c = oppId;
                            contr.Id_Opportunity_Quote__c = oppQlineItem.Id_Opportunity_Quote__c;
                            contr.RecordTypeId = mapRecordTypes.get(mapBusinessRules.get('Contract_recordType').Business_Rule_Value__c).id;
                            contr.Service_Type__c = oppQlineItem.Sub_type__c;
                            contr.min__c=oppQlineItem.min__c;
                            contr.max__c=oppQlineItem.max__c;
                            contr.istiered__c=oppQlineItem.isTiered__c;
                            contr.index__c=oppQlineItem.index__c;

                            if(String.isNotblank(string.valueof(oppQlineItem.Commission_In_Percentage__c))){
                                contr.Commission__c = oppQlineItem.Commission_In_Percentage__c;
                            }
                            if(String.isNotblank(string.valueof(oppQlineItem.Commission_Per_Order__c))){
                                contr.Commission_Per_Order__c = oppQlineItem.Commission_Per_Order__c;
                            }
                            if(String.isNotblank(string.valueof(oppQlineItem.Recurring_Fee__c))){
                                contr.Recurring_Fee__c = oppQlineItem.Recurring_Fee__c;
                            }
                            if(String.isNotblank(string.valueof(oppQlineItem.online_payment_fee__c))){
                                contr.online_payment_fee__c=oppQlineItem.online_payment_fee__c;
                            }
                            if(oppQlineItem.Id_Opportunity__r.ownerId!=null){
                                contr.ownerId = oppQlineItem.Id_Opportunity__r.ownerId;
                                /*contr.CreatedBy.id = oppQlineItem.Id_Opportunity_Quote__r.Id_Opportunity__r.ownerId;
                                contr.LastModifiedBy.id = oppQlineItem.Id_Opportunity_Quote__r.Id_Opportunity__r.ownerId;*/
                            }
                            contr.CurrencyIsoCode = oppQlineItem.CurrencyIsoCode;
                            contr.Name__c = oppQlineItem.Name;
                            contr.Status = 'Draft'; //Activated
                            //contr.ActivatedDate = oppQlineItem.Start_Date__c;
                            contr.StartDate = oppQlineItem.Start_Date__c;
                            if(mapBusinessRules.get('enableContractEndDate')!=null && Boolean.valueOf(mapBusinessRules.get('enableContractEndDate').Business_Rule_Value__c)){
                                if(oppQlineItem.End_Date__c!=null){
                                    contr.End_Date__c = oppQlineItem.End_Date__c;
                                }
                            }
                            listNewContracts.add(contr);
                        }else if(oppQlineItem.Line_Item_Type__c=='AddOn'){
                            Add_On_Service__c addonSvc = new Add_On_Service__c();
                            addonSvc.Account_Name__c  = accId;
                            addonSvc.Id_Opportunity_Quote_Line_Item__c = oppQlineItem.id;
                            addonSvc.Opportunity__c = oppId;

                            addonSvc.RecordTypeId = mapRecordTypes.get(mapBusinessRules.get('Add_On_Service_recordType').Business_Rule_Value__c).id;
                            addonSvc.Type__c = oppQlineItem.Sub_type__c;
                            addonSvc.Specifications__c=oppQlineItem.Specifications__c;
                            addonSvc.Status__c='Active';



                            addonSvc.CurrencyIsoCode = oppQlineItem.CurrencyIsoCode;


                            addonSvc.Start_Date__c = oppQlineItem.Start_Date__c;
                            if(mapOpp.get(oppId)!=null && mapOpp.get(oppId).StageName == 'Closed Lost'){
                                    if(mapOpp.get(oppId).Lost_Date__c!=null){
                                        addonSvc.End_Date__c = mapOpp.get(oppId).Lost_Date__c;
                                    }else{
                                        addonSvc.End_Date__c = mapOpp.get(oppId).CloseDate;
                                    }
                                    addonSvc.status__c = 'Terminated';
                                }
                            listNewAddons.add(addonSvc);

                        }

                        else if(oppQlineItem.Line_Item_Type__c=='Product'){

                            mapOppQuoteProd.put(oppQlineItem.Id,oppQlineItem);
                            //Asset creation merged
                            system.debug('**opp quote oppQlineItem:'+ oppQlineItem);

                            if(oppQlineItem.Id_List_Product_Price__r.Requires_Asset__c){
                                if(oppQlineItem.Assets__r==null || oppQlineItem.Assets__r.isEmpty()){
                                    for(integer i=1; i<=oppQlineItem.Quantity__c; i++  ){
                                        Asset__c newAsset = new Asset__c();
                                        newAsset.name = oppQlineItem.name;
                                        newAsset.Account__c = accId;
                                        newAsset.CurrencyIsoCode = oppQlineItem.CurrencyIsoCode;
                                        newAsset.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('Asset_recordType').Business_Rule_Value__c);
                                        newAsset.Id_Opportunity_Quote_Line_Item__c = oppQlineItem.Id;
                                        newAsset.Opportunity__c = oppId;
                                        newAsset.Status__c = 'New - Awaiting Shipping';
                                        listAssets.add(newAsset);
                                    }
                                }else{
                                    listProcessAssetForAddCharge.addAll(oppQlineItem.Assets__r);
                                }
                            }
                            if(oppQlineItem.Id_List_Product_Price__r.Requires_Additional_Charge__c && !oppQlineItem.Id_List_Product_Price__r.Requires_Asset__c){
                                //create all other Additional Charge except for Asset
                                Additional_Charges__c add1 = new Additional_Charges__c();
                                add1.Has_Related_Tarif__c = oppQlineItem.Has_Related_Tarif__c;
                                add1.Id_List_Product_Price__c = oppQlineItem.Id_List_Product_Price__c;
                                add1.Installments__c = oppQlineItem.Installments__c;
                                add1.Listed_Price__c = oppQlineItem.Listed_Price__c;
                                add1.Id_Opportunity_Quote__c = oppQlineItem.Id_Opportunity_Quote__c;
                                add1.Product_Group__c = oppQlineItem.Product_Group__c;
                                add1.product__c = oppQlineItem.name;
                                add1.Quantity__c = oppQlineItem.Quantity__c;
                                add1.CurrencyIsoCode = oppQlineItem.CurrencyIsoCode;
                                add1.Rabbat__c = oppQlineItem.Discount__c;
                                add1.Total_Amount__c = oppQlineItem.Total_Amount__c;
                                add1.recordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('AdditionalCharges_recordType').Business_Rule_Value__c);
                                add1.Id_Account__c = accId;
                                add1.Id_Opportunity__c = oppId;
                                add1.ID_Opportunity_Quote_Line_Item__c=oppQlineItem.Id;
                                //add1.Ad_Sales_Type__c=oppQlineItem.Ad_Sales_Type__c;
                                add1.Category__c=oppQlineItem.Category__c;
                                add1.Category_Id__c=oppQlineItem.Category_Id__c;
                                add1.District__c=oppQlineItem.District__c;
                                add1.District_Id__c=oppQlineItem.District_Id__c;
                                add1.status__c = 'Active';
                                add1.Type__c = oppQlineItem.Sub_type__c;
                                if(mapOpp.get(oppId)!=null && (mapOpp.get(oppId).StageName=='Terminal Returned' || mapOpp.get(oppId).StageName == 'Closed Lost')){
                                    if(mapOpp.get(oppId).Lost_Date__c!=null){
                                        add1.Termination_Date__c = mapOpp.get(oppId).Lost_Date__c;
                                    }else{
                                        add1.Termination_Date__c = mapOpp.get(oppId).CloseDate;
                                    }
                                    add1.status__c = 'Terminated';
                                }
                                if(mapBusinessRules.get('startDateIsOppCloseDate') != null && Boolean.valueOf(mapBusinessRules.get('startDateIsOppCloseDate').Business_Rule_Value__c)){
                                    add1.Start_Date__c = oppQlineItem.Id_Opportunity__r.CloseDate;
                                }else if(oppQlineItem.Start_Date__c!=null){
                                    add1.Start_Date__c = oppQlineItem.Start_Date__c;
                                }else{
                                    add1.Start_Date__c = Date.today();
                                }
                                listAdditional.add(add1);
                            }

                            /*if(oppQlineItem.Id_List_Product_Price__r.Requires_Add_On__c){
                                for(integer i=1; i<=oppQlineItem.Quantity__c; i++  ){
                                    Add_on_Service__c newAddOn = new Add_on_Service__c();
                                    newAddOn.Account_Name__c = accId;
                                    newAddOn.CurrencyIsoCode = oppQlineItem.CurrencyIsoCode;
                                    newAddOn.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('AddOnRecordType').Business_Rule_Value__c);
                                    newAddOn.Opportunity__c = oppId;
                                    if(oppQlineItem.Start_Date__c!=null){
                                        newAddOn.Start_Date__c = oppQlineItem.Start_Date__c;
                                    }else{
                                        newAddOn.Start_Date__c = Date.today();
                                    }
                                    listAddOn.add(newAddOn);
                                }
                            }*/

                            if(oppQlineItem.Id_List_Product_Price__r.Requires_Branding__c){
                                for(integer i=1; i<=oppQlineItem.Quantity__c; i++  ){
                                    Branding_Content__c newBranding = new Branding_Content__c();
                                    newBranding.Restaurant_Name__c = accId;
                                    newBranding.CurrencyIsoCode = oppQlineItem.CurrencyIsoCode;
                                    newBranding.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('BrandingContentRecordType').Business_Rule_Value__c);
                                    newBranding.Opportunity__c = oppId;
                                    newBranding.type__c=oppQlineItem.Id_List_Product_Price__r.Product_Type__c;
                                    listBranding.add(newBranding);
                                }
                            }

                        }
                    }
                }
                insert listNewContracts;
                insert listAssets;
                insert listNewAddons;
                insert listBranding;
                if(!listAssets.isEmpty()){
                    listProcessAssetForAddCharge.addAll(listAssets);
                }
                
                
                
                //create Additional charge for Assets
                for(Asset__c asst :listProcessAssetForAddCharge){
                    Id oppId = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Id_Opportunity__c;
                    Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Id_Opportunity__r.RecordType.DeveloperName);
                    if(mapBusinessRules!=null && !mapBusinessRules.isEmpty()){
                        Additional_Charges__c add1 = new Additional_Charges__c();
                        add1.Has_Related_Tarif__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Has_Related_Tarif__c;
                        add1.Id_List_Product_Price__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Id_List_Product_Price__c;
                        add1.Installments__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Installments__c;
                        add1.Listed_Price__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Listed_Price__c;
                        add1.Id_Opportunity_Quote__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Id_Opportunity_Quote__c;
                        add1.Product_Group__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Product_Group__c;
                        add1.product__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).name;
                        add1.Quantity__c = 1;
                        add1.CurrencyIsoCode = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).CurrencyIsoCode;
                        add1.Rabbat__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Discount__c;
                        add1.Total_Amount__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Total_Amount__c;
                        add1.recordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('AdditionalCharges_recordType').Business_Rule_Value__c);
                        add1.Id_Account__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Id_Opportunity__r.AccountId;
                        add1.Id_Opportunity__c = oppId;
                        add1.Id_Asset__c = asst.id;
                        add1.ID_Opportunity_Quote_Line_Item__c=asst.Id_Opportunity_Quote_Line_Item__c;
                        add1.Type__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Sub_type__c;
                        add1.Start_Date__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Id_Opportunity__r.CloseDate;
                        add1.status__c = 'Active';

                        listAdditional.add(add1);
                    }
                }
                
                insert listAdditional;



                for(Contract c:listNewContracts){
                    if(mapOpp.get(c.Id_Opportunity__c)!=null && (mapOpp.get(c.Id_Opportunity__c).StageName=='Terminal Returned' || mapOpp.get(c.Id_Opportunity__c).StageName == 'Closed Lost')){
                         c.Status='Terminated';
                    }else{
                        c.Status='Activated';
                    }
                }
                update listNewContracts;
            

            update mapOpp.values();

        }else{
            System.debug('Business config for BatchSchedulerForOpportunity is not active ');
        }  


                      
    }
    
    
    }
     Class RangeWrapper{
        public String desde{get;set;}
        public String hasta {get; set;}
        public String valor{get;set;}
        public String tipo{get;set;}
       
        
}
   
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}