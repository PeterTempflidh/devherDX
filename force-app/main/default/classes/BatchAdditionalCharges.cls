global class BatchAdditionalCharges implements Database.Batchable<sObject>,Database.Stateful {
    private static Map<String,RecordType> mapRecordTypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Additional_Charges__c', 'Contract', 'Opportunity','Asset__c'});
    String migrationText;
    
    global BatchAdditionalCharges() {
        migrationText = BatchOpportunityTarif_MigrationText__c.getValues('FilterText').Value__c;    
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        /*return Database.getQueryLocator([select id,name,closeDate,AccountId,RecordType.DeveloperName,subTotal__c,
            Total__c,CurrencyIsoCode,FreeTrial_End_AU__c,FreeTrial_Start_AU__c,Commi__c,Online_Payment_Fee_AU__c,
            Order_Transmission_Fee_AU__c,Setup_Fee_AU__c,TarrifName_AU__c,Start_Date_uk__c 
            from Opportunity 
            where Is_DataLoaded__c=true and Migration_Notes_AU__c=:migrationText ]);*/

        return Database.getQueryLocator([select id, name,CurrencyIsoCode,Id_List_Product_Price__r.Requires_Asset__c,Has_Related_Tarif__c,Id_List_Product_Price__c,Installments__c,Listed_Price__c,
                                                        Id_Opportunity_Quote__c,Id_Opportunity_Quote__r.Id_Account__c,Id_Opportunity_Quote__r.Id_Opportunity__c,Id_Opportunity_Quote__r.Id_Opportunity__r.Lost_Date__c,Id_Opportunity_Quote__r.Id_Opportunity__r.StageName,Product_Group__c,Quantity__c,Discount__c,Total_Amount__c
                                                            from Opportunity_Quote_Line_Item__c where Id_Opportunity_Quote__r.Id_Opportunity__r.Is_DataLoaded__c = true and Id_Opportunity_Quote__r.Id_Opportunity__r.Migration_Notes_AU__c=:migrationText]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        //List<Opportunity> listOpp = new List<Opportunity>();
        //listOpp.addAll((List<Opportunity>)scope);
        List<Id> listOppIds = new List<Id>();
        Set<Id> setOppIds = new Set<Id>();
        Map<Id,Opportunity_Quote_Line_Item__c> mapOppQuoteProd = new Map<Id,Opportunity_Quote_Line_Item__c>();
        for(Opportunity_Quote_Line_Item__c oppQuoteProditem : (List<Opportunity_Quote_Line_Item__c>)scope){
                if(mapOppQuoteProd.get(oppQuoteProditem.id)==null){
                    mapOppQuoteProd.put(oppQuoteProditem.id,oppQuoteProditem);
                    listOppIds.add(oppQuoteProditem.Id_Opportunity_Quote__r.Id_Opportunity__c);
                }
        }
        for(AggregateResult arr : [select count(id),Opportunity__c from Asset__c where Opportunity__c in :listOppIds group by Opportunity__c having count(id)>1]){
            setOppIds.add((ID)arr.get('Opportunity__c'));
        }
        List<Additional_Charges__c> listAdditional = new List<Additional_Charges__c>();
            List<Asset__c> listProcessAssetForAddCharge = new List<Asset__c>();
            //if(!listOpp.isEmpty()){
            if(!mapOppQuoteProd.isEmpty()){
                Map<Id,Asset__c> mapOppAsset = new Map<Id,Asset__c>();
                for(Asset__c ass : [select name,Account__c,CurrencyIsoCode,RecordTypeId,Id_Opportunity_Quote_Line_Item__c,Opportunity__c,Status__c from Asset__c where Opportunity__c in: listOppIds]){
                    if(mapOppAsset.get(ass.Opportunity__c)==null){
                        mapOppAsset.put(ass.Opportunity__c, ass);
                    }
                }
                /*Map<Id,Opportunity_Quote_Line_Item__c> mapOppQuoteProd = new Map<Id,Opportunity_Quote_Line_Item__c>([select id, name,CurrencyIsoCode,Id_List_Product_Price__r.Requires_Asset__c,Has_Related_Tarif__c,Id_List_Product_Price__c,Installments__c,Listed_Price__c,
                                                        Id_Opportunity_Quote__c,Id_Opportunity_Quote__r.Id_Account__c,Id_Opportunity_Quote__r.Id_Opportunity__c,Id_Opportunity_Quote__r.Id_Opportunity__r.Lost_Date__c,Id_Opportunity_Quote__r.Id_Opportunity__r.StageName,Product_Group__c,Quantity__c,Rabbat__c,Total_Amount__c
                                                            from Opportunity_Quote_Line_Item__c where Id_Opportunity_Quote__r.Id_Opportunity__c in :listOpp]);*/
                for(Opportunity_Quote_Line_Item__c qq1 : mapOppQuoteProd.values()){

                    Id oppId = qq1.Id_Opportunity_Quote__r.Id_Opportunity__c;
                    if(!setOppIds.contains(oppId)){
                            Additional_Charges__c add1 = new Additional_Charges__c();
                            add1.Has_Related_Tarif__c = qq1.Has_Related_Tarif__c;
                            add1.Id_List_Product_Price__c = qq1.Id_List_Product_Price__c;
                            add1.Installments__c = qq1.Installments__c;
                            add1.Listed_Price__c = qq1.Listed_Price__c;
                            add1.Id_Opportunity_Quote__c = qq1.Id_Opportunity_Quote__c;
                            add1.Product_Group__c = qq1.Product_Group__c;
                            add1.product__c = qq1.name;
                            add1.Quantity__c = qq1.Quantity__c;
                            add1.CurrencyIsoCode = qq1.CurrencyIsoCode;
                            add1.Rabbat__c = qq1.Discount__c;
                            add1.Total_Amount__c = qq1.Total_Amount__c;
                            add1.recordTypeId = mapRecordTypes.get('Yogiyo_Additional_Charges').id;
                            add1.Id_Account__c = qq1.Id_Opportunity_Quote__r.Id_Account__c;
                            add1.Id_Opportunity__c = oppId;
                        if(mapOppAsset.get(oppId)!=null){
                            Asset__c asst = mapOppAsset.get(oppId);
                            asst.Id_Opportunity_Quote_Line_Item__c = qq1.Id;
                            listProcessAssetForAddCharge.add(asst);
                            add1.Id_Asset__c = asst.id;
                            if(qq1.Id_Opportunity_Quote__r.Id_Opportunity__r.stageName == 'Terminal Returned' || qq1.Id_Opportunity_Quote__r.Id_Opportunity__r.stageName == 'Closed Lost'){
                            add1.Termination_Date__c = qq1.Id_Opportunity_Quote__r.Id_Opportunity__r.Lost_Date__c;
                            }
                        }                       
                            listAdditional.add(add1);
                    }

                }
                update listProcessAssetForAddCharge;
                insert listAdditional;

            }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}