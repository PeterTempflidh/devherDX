global with sharing class ClsRefreshQuote {
    webService static Boolean refreshQuote(Id quoteId){
        Opportunity_Quote__c oppQuote;
        String quoteBody = '';
        List<Opportunity_Quote__c> quotes = [
       SELECT Id, Description__c,Non_Standard_Contract_Terms__c,Template_Name__c,Non_Standard_Contract_Components__c, Id_Account__c, Id_Account__r.Company_Code__c, Id_Opportunity__c,RecordType.DeveloperName, Subtotal__c, Total__c, VAT__c, Url_Key__c, Status__c, Quote_Comment__c, RecordTypeId, 
       (Select Id, Name,Line_Item_Type__c,Sub_type__c,Id_List_Service_Price__c, CurrencyIsoCode, Commission_In_Percentage__c,Commission_Per_Order__c, Start_Date__c, End_Date__c, 
        Id_Opportunity_Quote__c, Recurring_Fee__c,Id_List_Product_Price__r.Requires_Asset__c,Id_List_Product_Price__r.Requires_Additional_Charge__c,
        Id_List_Product_Price__r.Requires_Add_On__c,Id_List_Product_Price__r.Requires_Branding__c,Id_List_Product_Price__r.Product_Type__c,Id_List_Product_Price__r.Product_Name__c,
        Has_Related_Tarif__c,Id_List_Product_Price__c,Installments__c,Listed_Price__c,Product_Group__c,Quantity__c,Discount__c,Total_Amount__c,Category__c,Category_Id__c,District__c,District_Id__c,City_ZipCode__c FROM Opportunity_Quote_Line_Items__r) 
       FROM Opportunity_Quote__c WHERE Id =: quoteId LIMIT 1];
       
        if(!quotes.isEmpty()){
            oppQuote = quotes[0];
            Opportunity opp = new Opportunity(Id=quotes[0].Id_Opportunity__c);
            if(oppQuote.Template_Name__c==null){
                ClsQuoteProcessor cqp = new ClsQuoteProcessor(opp, quotes[0],quotes[0].RecordType.DeveloperName,(List<Opportunity_Quote_Line_Item__c>) quotes[0].Opportunity_Quote_Line_Items__r);
                quoteBody = cqp.renderVFTemplate();
            }else{

                quoteBody = ClsQuoteProcessor.renderVFTemplate(oppQuote.Id,oppQuote.Template_Name__c);
            }
            
            if(OppQuote.Non_Standard_Contract_Terms__c!=null && OppQuote.Non_Standard_Contract_Terms__c.length()>3 && OppQuote.recordtypeid==LibRecordTypeHelper.getRecordTypeValue('Talabat_Opportunity_Quote')){
                String finalStr = OppQuote.Non_Standard_Contract_Terms__c.replaceAll('\n','<br/>');
                String str = quoteBody.replace('<div id="talabatnonstandardcontract"></div>',finalStr);
                quoteBody = str;
            }
            else if(OppQuote.Non_Standard_Contract_Terms__c!=null && OppQuote.Non_Standard_Contract_Terms__c.length()>3 && OppQuote.recordtypeid==LibRecordTypeHelper.getRecordTypeValue('AT_Opportunity_Quote')){ 
                String finalStr = OppQuote.Non_Standard_Contract_Terms__c.replaceAll('\n','<br/>');  
                String str = quoteBody.replace('<div id="austriaNonContract"></div>',finalStr);          
                quoteBody = str;
        }
            if(String.isNotBlank(quoteBody) && !quoteBody.equals('error')){
                oppQuote.Description__c = quoteBody;
                try{
                    update oppQuote;
                    return true;
                }catch(Exception e){
                    return false;
                }
            } else {
                return false;
            }
        } else {
            return false;
        }
    }
}