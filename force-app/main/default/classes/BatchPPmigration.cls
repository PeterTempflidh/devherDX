global class BatchPPmigration implements Database.Batchable<sObject>,Database.Stateful {
    
    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    Map<String,Map<String,Business_Config__c>> mapBusinessLogic = new Map<String,Map<String,Business_Config__c>>();
    Map<String,RecordType> mapRecordTypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Opportunity_Line_Item__c','Opportunity_Quote__c','Opportunity_Quote_Line_Item__c','Contract','Asset__c','Additional_Charges__c'});
    String migrationText;
    
    
    global BatchPPmigration() {
        mapBusinessLogic = moam.get('BatchSchedulerForOpportunity');
        migrationText = BatchOpportunityTarif_MigrationText__c.getValues('FilterText').Value__c;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('migrationText: '+migrationText);

        return Database.getQueryLocator([select id,(Select Id, Name,Line_Item_Type__c,Sub_type__c, CurrencyIsoCode,  Start_Date__c,End_Date__c, 
                        Recurring_Fee__c,Id_Opportunity__r.ownerId,Id_Opportunity__r.RecordType.DeveloperName,
                        Id_Opportunity__r.AccountId, Id_Opportunity__r.Account.Non_Contracted__c,Booking_Api_Id__c,
                        recordtype.DeveloperName,City_ZipCode__c,Position__c,
                        Id_Opportunity__c,Id_Opportunity__r.CloseDate,Id_List_Price_Product__r.Requires_Additional_Charge__c,
                        Id_List_Price_Product__r.Requires_Add_On__c,Id_List_Price_Product__r.Product_Type__c,
                        Id_List_Price_Product__r.Product_Name__c,min__c,max__c,isTiered__c,index__c,
                        Has_Related_Tarif__c,Id_List_Price_Product__c,Installments__c,Listed_Price__c,
                        Online_Payment_Fee__c,
                        Product_Group__c,Quantity__c,Discount__c,Total_Amount__c,Category__c,Category_Id__c,District__c,District_Id__c
                        FROM Opportunity_Line_Items__r), name,closeDate,Lost_Date__c,stageName,AccountId,
                        RecordType.DeveloperName,CurrencyIsoCode,
                        Start_Date_uk__c,Renewal_Fee_TB__c,ownerId
            from opportunity
            where  Migration_Notes_AU__c=:migrationText   ]);
    }

    //creates Opportunity_Tarif_Item__c,Opportunity_Service_Item__c and Opportunity_Product_Item__c for every opportunity
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Opportunity_Quote_Line_Item__c> listOppQuoteLines = new List<Opportunity_Quote_Line_Item__c>();
        List<Opportunity_Quote__c> listOppQuote = new List<Opportunity_Quote__c>();
        Map<String,String> mapQuoteOppIds = new Map<String,String>();
        if(!mapBusinessLogic.isEmpty()){
            for(SObject s: scope){
                Opportunity opp = (Opportunity) s;


                    if(!mapBusinessLogic.isEmpty() && mapBusinessLogic.size()==1){
                        if(mapBusinessLogic.get(opp.RecordType.DeveloperName)!=null){
                             Map<String,Business_Config__c> mapBusinessData = mapBusinessLogic.get(opp.RecordType.DeveloperName);


                            listOppQuote.add(new Opportunity_Quote__c(Id_Opportunity__c=opp.id,
                                                      CurrencyIsoCode=opp.CurrencyIsoCode,
                                                      status__c='Accepted',
                                                      Id_Account__c=opp.AccountId,
                                                      recordtypeId=mapRecordTypes.get(mapBusinessData.get('opportunity_quote_recordType').Business_Rule_Value__c).id));

                            for(Opportunity_Line_Item__c opplineitem: opp.Opportunity_Line_Items__r){
                                listOppQuoteLines.add(new Opportunity_Quote_Line_Item__c(name = opplineitem.name,
                                                                        Id_List_Product_Price__c = opplineitem.Id_List_Price_Product__c,
                                                                        Listed_Price__c = opplineitem.Listed_Price__c,
                                                                        Quantity__c = opplineitem.Quantity__c,
                                                                        Total_Amount__c = opplineitem.Total_Amount__c,
                                                                        Id_Opportunity__c= opplineitem.Id_Opportunity__c,
                                                                        Product_Group__c = opplineitem.Product_Group__c,
                                                                        Installments__c = opplineitem.Installments__c,
                                                                        Has_Related_Tarif__c = opplineitem.Has_Related_Tarif__c,
                                                                        recordtypeId = mapRecordTypes.get(mapBusinessData.get('opportunity_quote_product_recordType').Business_Rule_Value__c).id,
                                                                        CurrencyIsoCode = opp.CurrencyIsoCode,
                                                                        Migration_OppId__c=opp.Id,
                                                                        City_ZipCode__c=opplineitem.City_ZipCode__c,
                                                                        Position__c=opplineitem.Position__c,
                                                                        Start_Date__c=opplineitem.Start_Date__c,
                                                                        End_Date__c=opplineitem.End_Date__c,
                                                                        Booking_Api_Id__c=opplineitem.Booking_Api_Id__c,
                                                                        Discount__c=opplineitem.discount__c,
                                                                        Category__c=opplineitem.Category__c,
                                                                        Line_Item_Type__c='Product',
                                                                        sub_type__c=opplineitem.sub_type__c));




                            }


                        }else{
                            System.debug('Business config for BatchSchedulerForOpportunity is not active for recordtype '+opp.RecordType.DeveloperName);
                        }
                    }else{
                        System.debug('Only one business process can be active!');
                    }

            }


            insert listOppQuote;
            Map<Id,Opportunity_Quote_Line_Item__c> mapOppQuoteProd = new Map<Id,Opportunity_Quote_Line_Item__c>();
            List<Additional_Charges__c> listAdditional = new List<Additional_Charges__c>();

            Map<Id,Opportunity_Quote__c> mapOppQuote = new Map<id,Opportunity_Quote__c>();
            for(Opportunity_Quote__c oppQ : listOppQuote){
                mapQuoteOppIds.put(oppQ.Id_Opportunity__c,oppQ.Id);
                mapOppQuote.put(oppQ.id,oppQ);
            }
            for(Opportunity_Quote_Line_Item__c oppQS :listOppQuoteLines){
                oppQS.Id_Opportunity_Quote__c = mapQuoteOppIds.get(oppQS.Migration_OppId__c);
            }
            insert listOppQuoteLines;

            for(Opportunity_Quote_Line_Item__c oppQlineItem : [ Select Id, Name,Line_Item_Type__c,Sub_type__c, CurrencyIsoCode,Start_Date__c, End_Date__c,
                        Id_Opportunity_Quote__c, Recurring_Fee__c,Id_Opportunity__r.ownerId,Id_Opportunity__r.RecordType.DeveloperName,
                        Id_Opportunity__r.Account.Non_Contracted__c,Booking_Api_Id__c,
                        recordtype.DeveloperName,City_ZipCode__c,Position__c,Id_Opportunity__r.AccountId,
                        Id_Opportunity__c,Id_Opportunity__r.CloseDate,Id_List_Product_Price__r.Requires_Additional_Charge__c,
                        Id_List_Product_Price__r.Requires_Add_On__c,Id_Opportunity__r.Lost_Date__c,Id_List_Product_Price__r.Product_Type__c,Id_List_Product_Price__r.Product_Name__c,min__c,max__c,isTiered__c,index__c,
                        Has_Related_Tarif__c,Id_List_Product_Price__c,Installments__c,Listed_Price__c,Online_Payment_Fee__c,
                        Product_Group__c,Quantity__c,Id_Opportunity__r.StageName,Discount__c,Total_Amount__c,Category__c,Category_Id__c,
                        District__c,District_Id__c
                        FROM Opportunity_Quote_Line_Item__c
                        WHERE Id_Opportunity_Quote__c IN :mapOppQuote.keySet()
                    ])
            {   Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(oppQlineItem.Id_Opportunity__r.RecordType.DeveloperName);

                if(oppQlineItem.Id_List_Product_Price__r.Requires_Additional_Charge__c){
                                //create all other Additional Charge except for Asset
                    Additional_Charges__c add1 = new Additional_Charges__c();
                    add1.Has_Related_Tarif__c = oppQlineItem.Has_Related_Tarif__c;
                    add1.Id_List_Product_Price__c = oppQlineItem.Id_List_Product_Price__c;
                    add1.Installments__c = oppQlineItem.Installments__c;
                    add1.Listed_Price__c = oppQlineItem.Listed_Price__c;
                    add1.Id_Opportunity_Quote__c = oppQlineItem.Id_Opportunity_Quote__c;
                    add1.Product_Group__c = oppQlineItem.Product_Group__c;
                    add1.product__c = oppQlineItem.name;
                    add1.Position__c=oppQlineItem.Position__c;
                    add1.City_ZipCode__c=add1.City_ZipCode__c;
                    add1.Quantity__c = oppQlineItem.Quantity__c;
                    add1.CurrencyIsoCode = oppQlineItem.CurrencyIsoCode;
                    add1.Rabbat__c = oppQlineItem.Discount__c;
                    add1.Total_Amount__c = oppQlineItem.Total_Amount__c;
                    add1.recordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('AdditionalCharges_recordType').Business_Rule_Value__c);
                    add1.Id_Account__c = oppQlineItem.Id_Opportunity__r.AccountId;
                    add1.Id_Opportunity__c = oppQlineItem.Id_Opportunity__c;
                    //add1.Ad_Sales_Type__c=oppQlineItem.Ad_Sales_Type__c;
                    add1.Category__c=oppQlineItem.Category__c;
                    add1.Category_Id__c=oppQlineItem.Category_Id__c;
                    add1.District__c=oppQlineItem.District__c;
                    add1.District_Id__c=oppQlineItem.District_Id__c;
                    add1.status__c = 'Active';
                    add1.Termination_Date__c=oppQlineItem.End_Date__c;
                    add1.Booking_Api_Id__c=oppQlineItem.Booking_Api_Id__c;
                    add1.Type__c = oppQlineItem.Sub_type__c;
                    if(oppQlineItem.Id_Opportunity__r.StageName == 'Closed Lost'){
                        if(oppQlineItem.Id_Opportunity__r.Lost_Date__c!=null){
                            add1.Termination_Date__c = oppQlineItem.Id_Opportunity__r.Lost_Date__c;
                        }else{
                            add1.Termination_Date__c = oppQlineItem.Id_Opportunity__r.CloseDate;
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
            }

            insert listAdditional;
        }
            
    }
    
     global void finish(Database.BatchableContext BC) {
        
    }
    
}