global class BatchOpportunityLineItemsMigration implements Database.Batchable<sObject> {
    
    //String query='select id, Id_Tarif__c,LineItemsCopied__c,Company_Code__c,(select Id_Tarif__c from Opportunity_Tarif_Items__r),(SELECT Id, Name, RecordTypeId, Has_Related_Tarif__c, Id_List_Price_Product__c, Installments__c, Listed_Price__c, Product_Group__c, Quantity__c, Rabbat__c, Total_Amount__c, End_Date__c, Start_Date__c, Ad_Sales_Type__c, Category_Id__c, Category__c, District_Id__c, District__c, API_Type__c, City_ZipCode__c FROM Opportunity_Product_Items__r),(SELECT Id, Name, RecordTypeId, Commission_In_Percentage__c, Commission_Per_Order__c, End_Date__c, Has_Related_Tarif__c, Id_List_Service_Price__c, Recurring_Fee__c, Start_Date__c, Type__c, Service_Type__c, Commission_Type__c FROM Opportunity_Service_Items__r) from Opportunity where LineItemsCopied__c=false';
   String query='select id,CurrencyIsoCode, Id_Tarif__c,LineItemsCopied__c,Company_Code__c,(select Id_Tarif__c from Opportunity_Tarif_Items__r),(SELECT Id, Name, RecordTypeId, Has_Related_Tarif__c, Id_List_Price_Product__c, Installments__c, Listed_Price__c, Product_Group__c, Quantity__c, Rabbat__c, Total_Amount__c, End_Date__c, Start_Date__c, Ad_Sales_Type__c, Category_Id__c, Category__c, District_Id__c, District__c, API_Type__c, City_ZipCode__c FROM Opportunity_Product_Items__r),(SELECT Id, Name, RecordTypeId, Commission_In_Percentage__c, Commission_Per_Order__c, End_Date__c, Has_Related_Tarif__c, Id_List_Service_Price__c, Recurring_Fee__c, Start_Date__c, Type__c, Service_Type__c, Commission_Type__c FROM Opportunity_Service_Items__r),(select id, API_Type__c, Type__c from Additional_Charges__r ) from Opportunity where LineItemsCopied__c=false limit 60000';
    
    global BatchOpportunityLineItemsMigration() {

        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Opportunity> listOpps = (List<Opportunity>) scope;
         Map<Id,Opportunity_Quote_Line_Item__c> mapOppQlineItems = new Map<Id,Opportunity_Quote_Line_Item__c>();
        List<Opportunity_Line_Item__c> listOppLines = new List<Opportunity_Line_Item__c>();
        List<Opportunity> updateOpps = new List<Opportunity>();
         List<Additional_Charges__c> listAddChrg = new List<Additional_Charges__c>();
        for(Opportunity opp : listOpps){
            String CurrencyIso = opp.CurrencyIsoCode;
            Id tarifId;
            Id OppId = opp.Id;
            String companyCode = opp.Company_Code__c;
            if(opp.Opportunity_Tarif_Items__r!=null && !opp.Opportunity_Tarif_Items__r.isEmpty()){
                tarifId = opp.Opportunity_Tarif_Items__r[0].Id_Tarif__c;
            }
            if(opp.Additional_Charges__r!=null && !opp.Additional_Charges__r.isEmpty()){
               for(Additional_Charges__c ad : opp.Additional_Charges__r){
                  if(ad.API_Type__c!=null){
                     listAddChrg.add(new Additional_Charges__c(Id=ad.Id,Type__c=ad.API_Type__c));
                  }
               }
            }


            if(opp.Opportunity_Product_Items__r!=null && !opp.Opportunity_Product_Items__r.isEmpty()){
               for(Opportunity_Product_Item__c oppP : opp.Opportunity_Product_Items__r){
                  String subType;
                  if(oppP.API_Type__c!=null){
                     subType = oppP.API_Type__c;
                  }

                  listOppLines.add(new Opportunity_Line_Item__c(CurrencyIsoCode=CurrencyIso,Name=oppP.Name, RecordTypeId=LibRecordTypeHelper.getRecordTypeValue(companyCode+'_Opportunity_Line_Item'), Id_Opportunity__c=OppId, Has_Related_Tarif__c=oppP.Has_Related_Tarif__c, Id_List_Price_Product__c=oppP.Id_List_Price_Product__c, Installments__c=oppP.Installments__c, Listed_Price__c=oppP.Listed_Price__c, Product_Group__c=oppP.Product_Group__c, Quantity__c=oppP.Quantity__c, Discount__c=oppP.Rabbat__c, Total_Amount__c=oppP.Total_Amount__c, End_Date__c=oppP.End_Date__c, Start_Date__c=oppP.Start_Date__c, Sub_Type__c=subType, Category_Id__c=oppP.Category_Id__c, Category__c=oppP.Category__c, District_Id__c=oppP.District_Id__c, District__c=oppP.District__c, City_ZipCode__c=oppP.City_ZipCode__c,Line_Item_Type__c='Product'));
               }
            }

            if(opp.Opportunity_Service_Items__r!=null && !opp.Opportunity_Service_Items__r.isEmpty()){
               for(Opportunity_Service_Item__c oppS : opp.Opportunity_Service_Items__r){

                  listOppLines.add(new Opportunity_Line_Item__c(CurrencyIsoCode=CurrencyIso,Name=oppS.Name, RecordTypeId=LibRecordTypeHelper.getRecordTypeValue(companyCode+'_Opportunity_Line_Item'), Id_Opportunity__c=OppId, Commission_In_Percentage__c=oppS.Commission_In_Percentage__c, Commission_Per_Order__c=oppS.Commission_Per_Order__c, End_Date__c=oppS.End_Date__c, Has_Related_Tarif__c=oppS.Has_Related_Tarif__c, Id_List_Service_Price__c=oppS.Id_List_Service_Price__c, Start_Date__c=oppS.Start_Date__c, Line_Item_Type__c='Service', Sub_Type__c=oppS.Service_Type__c));
               }
            }    

            updateOpps.add(new Opportunity(Id=opp.Id,Id_Tarif__c=tarifId,LineItemsCopied__c=true));
        }



        for(Opportunity_Quote_Product_Item__c oppQp : [SELECT Id,CurrencyIsoCode, Name, RecordTypeId, Id_Opportunity_Quote__c,Id_Opportunity_Quote__r.Id_Opportunity__c,Id_Opportunity_Quote__r.Id_Opportunity__r.Company_Code__c,Has_Related_Tarif__c, Id_List_Product_Price__c, Installments__c, Listed_Price__c, Product_Group__c, Quantity__c, Rabbat__c, Total_Amount__c, Migration_OppId__c, Product_Type__c, Ad_Sales_Type__c, Category_Id__c, Category__c, District_Id__c, District__c, End_Date__c, Start_Date__c, API_Type__c, City_ZipCode__c FROM Opportunity_Quote_Product_Item__c where Id_Opportunity_Quote__r.Id_Opportunity__c in : updateOpps]){
            String subType;
            if(oppQp.API_Type__c!=null){
                subType = oppQp.API_Type__c;
            }else{
                subType = oppQp.Product_Type__c;
            }
            
            mapOppQlineItems.put(oppQp.Id,new Opportunity_Quote_Line_Item__c(CurrencyIsoCode=oppQp.CurrencyIsoCode,RecordTypeId=LibRecordTypeHelper.getRecordTypeValue(oppQp.Id_Opportunity_Quote__r.Id_Opportunity__r.Company_Code__c+'_Opportunity_Quote_Line_Item'),Id_Opportunity__c=oppQp.Id_Opportunity_Quote__r.Id_Opportunity__c, Name=oppQp.Name,Id_Opportunity_Quote__c=oppQp.Id_Opportunity_Quote__c, Has_Related_Tarif__c=oppQp.Has_Related_Tarif__c, Id_List_Product_Price__c=oppQp.Id_List_Product_Price__c, Installments__c=oppQp.Installments__c, Listed_Price__c=oppQp.Listed_Price__c, Product_Group__c=oppQp.Product_Group__c, Quantity__c=oppQp.Quantity__c, Discount__c=oppQp.Rabbat__c, Total_Amount__c=oppQp.Total_Amount__c, Migration_OppId__c=oppQp.Migration_OppId__c, Sub_Type__c=subType, Category_Id__c=oppQp.Category_Id__c, Category__c=oppQp.Category__c, District_Id__c=oppQp.District_Id__c, District__c=oppQp.District__c, End_Date__c=oppQp.End_Date__c, Start_Date__c=oppQp.Start_Date__c, City_ZipCode__c=oppQp.City_ZipCode__c,Line_Item_Type__c='Product'));
        }

        for(Opportunity_Quote_Service_Item__c  oppQs : [SELECT Id,CurrencyIsoCode, Name, Id_Opportunity_Quote__c, Commission_In_Percentage__c, Commission_Per_Order__c, End_Date__c, Has_Related_Tarif__c, Recurring_Fee__c, Start_Date__c, Type__c, Service_Type__c,Id_Opportunity_Quote__r.Id,Id_Opportunity_Quote__r.Id_Opportunity__c,Id_Opportunity_Quote__r.Id_Opportunity__r.Company_Code__c FROM Opportunity_Quote_Service_Item__c where Id_Opportunity_Quote__r.Id_Opportunity__c in : updateOpps]){
            mapOppQlineItems.put(oppQs.Id,new Opportunity_Quote_Line_Item__c(CurrencyIsoCode=oppQs.CurrencyIsoCode,RecordTypeId=LibRecordTypeHelper.getRecordTypeValue(oppQs.Id_Opportunity_Quote__r.Id_Opportunity__r.Company_Code__c+'_Opportunity_Quote_Line_Item'),Id_Opportunity__c=oppQs.Id_Opportunity_Quote__r.Id_Opportunity__c, Name=oppQs.Name,Id_Opportunity_Quote__c=oppQs.Id_Opportunity_Quote__c, Has_Related_Tarif__c=oppQs.Has_Related_Tarif__c, Commission_In_Percentage__c=oppQs.Commission_In_Percentage__c, Commission_Per_Order__c=oppQs.Commission_Per_Order__c, End_Date__c=oppQs.End_Date__c, Start_Date__c=oppQs.Start_Date__c, Sub_Type__c=oppQs.Service_Type__c,Line_Item_Type__c='Service'));
        }


         insert listOppLines;
         insert mapOppQlineItems.values();

         //System.debug('listOppLines: '+listOppLines);
         //System.debug('mapOppQlineItems.values(): '+mapOppQlineItems.values());



         List<Asset__c> updateAssets = [Select id,Id_Opportunity_Quote_Product_Item__c,Id_Opportunity_Quote_Line_Item__c from Asset__c where Id_Opportunity_Quote_Product_Item__c in :mapOppQlineItems.keySet()];
         for(Asset__c ast: updateAssets){
            ast.Id_Opportunity_Quote_Line_Item__c = mapOppQlineItems.get(ast.Id_Opportunity_Quote_Product_Item__c).Id;
         }

         update updateAssets;
         update  updateOpps;
         update listAddChrg;
         //System.debug('updateAssets: '+updateAssets);
         System.debug('updateOpps: '+updateOpps);
         //System.debug('listAddChrg: '+listAddChrg);


    
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}