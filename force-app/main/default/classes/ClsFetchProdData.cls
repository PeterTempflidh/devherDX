public class ClsFetchProdData {

    //Login Domain May be test, prerellogin.pre
    String LOGIN_DOMAIN = 'www';
    public String pwd;
    public String userName;
    public List<Country__c> countryLst{get;set;}
    public List<company__c> companyLst{get;set;}
    public List<Business_Config__c > businessConfigLst{get;set;}
    
    String SERVER_URL;
    String SESSION_ID ;
     HttpRequest request;
    public List<JSONParser> jsonParserLst;
    

    public ClsFetchPRodData(String username, String pwd)
    {
        this.username= username;
        this.pwd=pwd;
    }
    
    public void fetchData(){
    try{
    //-----------------------------------
        // Login via SOAP/XML web service api
        //-----------------------------------
        request = new HttpRequest();
        request.setEndpoint('https://cs87.salesforce.com/services/Soap/u/22.0');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', '""');
        //not escaping username and password because we're setting those variables above
        //in other words, this line "trusts" the lines above
        //if username and password were sourced elsewhere, they'd need to be escaped below
        if(!test.isrunningtest()){
        request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + userName+ '</username><password>' + pwd+ '</password></login></Body></Envelope>');
       system.debug('**'+(new Http()).send(request).getBodyDocument().getRootElement());
       
        Dom.XmlNode resultElmt = (new Http()).send(request).getBodyDocument().getRootElement()
          .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
          .getChildElement('loginResponse', 'urn:partner.soap.sforce.com')
          .getChildElement('result', 'urn:partner.soap.sforce.com');
          //system.debug
          

        //-------------------------------
        // Grab session id and server url
        //--------------------------------
         SERVER_URL = resultElmt.getChildElement('serverUrl', 'urn:partner.soap.sforce.com') .getText().split('/services')[0];
         SESSION_ID = resultElmt.getChildElement('sessionId', 'urn:partner.soap.sforce.com') .getText();
         }
        /*callouts to get data from prod */
        //get country
        /*String countryStr = 'Select  c.Name, c.Iso__c, c.CurrencyIsoCode From Country__c c where name=\'Austria\' ';
        List<JSONParser> countryParser=fetch(countryStr );
        countryLst= (List<Country__c>)countryParser[0].readValueAs(List<Country__c>.class);
        
        //get company
        String companyStr = 'Select cm.Name, cm.Company_Code__c From Company__c cm where name=\'Mjam\' ';
        List<JSONParser> companyParser=fetch(companyStr );
        companyLst= (List<Company__c>)companyParser[0].readValueAs(List<Company__c>.class);*/
        
        //get business config
        String businessConfigStr = 'select b.Business_Rule_Name__c,b.name, b.Business_Rule_Value__c,b.Id_Country__c,b.Id_Country__r.name,b.Description__c,b.Is_Active__c,b.Is_Json__c,b.Parent__c,b.Process_Name__c,b.Record_Type_Id__c,b.Type__c from Business_Config__c b where Id_Country__r.name=\'Peru\'';
        List<JSONParser> businessConfigParser=fetch(businessConfigStr);      
        system.debug('@@businessConfigParser'+businessConfigParser);
        List<Business_Config__c> businessConfigToInsertLst = new List<Business_Config__c>();
        
        //get tarif
       /* string tarifStr ='select t.Name, t.RecordTypeID, t.Is_Active__c, t.Company__c,t.Id_Country__r.name,t.CurrencyIsoCode, t.Company__r.name from Tarif__c t';
        List<JSONParser> tariffParser = fetch(tarifStr);
        List<Tarif__c>tarifLst = new List<Tarif__c>();
        List<Tarif__c> tarifToInsert = new List<Tarif__c>();
        
        //get tarifMember
        string tarifMemStr ='select t.Name, t.RecordTypeID,t.Id_Tarif_Item__c,t.Tarif_Name__c,t.Tarif_Name__r.name,t.CurrencyIsoCode,t.Type__c from Tarif_Member__c t';
        List<JSONParser> tariffMemParser = fetch(tarifMemStr);
        List<Tarif_Member__c>tarifMemLst = new List<Tarif_Member__c>();
        List<Tarif_Member__c> tarifMemToInsert = new List<Tarif_Member__c>();
        
        //get list product group
        string lpgStr ='select l.Name, l.RecordTypeID, l.In_Use__c, l.Company__c,l.Id_Country__r.name,l.CurrencyIsoCode, l.Company__r.name from List_Product_Group__c l';
        List<JSONParser> lpgParserLst= fetch(lpgStr);
        List<List_Product_Group__c>lpgLst = new List<List_Product_Group__c>();
        List<List_Product_Group__c> lpgToInsert = new List<List_Product_Group__c>();
        
        //get list product price
        string lppStr ='select l.Product_Name__c, l.Installments__c, l.List_Price__c,l.Allow_Installments__c,l.Requires_Add_On__c,l.Maximum_Discount__c,l.Product_Type__c,Id_List_Product_Group__c,Id_List_Product_Group__r.name,l.Requires_Additional_Charge__c, l.RecordTypeID,l.Requires_Branding__c,l.Requires_Asset__c,l.Default_Quantity__c, l.Is_Active__c,l.Unapproved_Discount_Limit__c, l.Company__c,l.Id_Country__r.name,l.CurrencyIsoCode, l.Company__r.name from List_Product_Price__c l';
        List<JSONParser> lppParserLst= fetch(lppStr);
        List<List_Product_Price__c>lppLst = new List<List_Product_Price__c>();
        List<List_Product_price__c> lppToInsert = new List<List_Product_Price__c>();
        
        //get list service price
        string lspStr ='select l.Type__c,l.Service_Type__c,l.Requires_Approval__c,l.Recurring_Interval__c,l.Recurring_Fee__c, l.Minimum_Commission_in_Percentage__c, l.Name,Maximum_Commission_In_Percentage__c,l.Commission_Type__c,l.Default_Commission_In_Percentage__c, l.RecordTypeID,l.Commission_Per_Order__c, l.Is_Active__c, l.Company__c,l.Id_Country__r.name,l.CurrencyIsoCode,l.Commission_In_Percentage__c, l.Company__r.name from List_Service_Price__c l';
        List<JSONParser> lspParserLst= fetch(lspStr);
        List<List_Service_Price__c>lspLst = new List<List_Service_Price__c>();
        List<List_Service_Price__c> lspToInsert = new List<List_Service_Price__c>();
           
       
        /* Insert data fetched from production */
       //insert countryLst;
        Map<String,id> countryIDMap = new Map<string,id>();
        countryLst=[select id, name from country__c];
        for(Country__c c:countryLst){
            countryIDMap.put(c.name,c.id);
        }
        system.debug('@@@@country'+countryLst);
       
       
        //insert companyLst;
        List<company__c>companyLst=[select id, name from company__c];
        Map<String,id> companyIDMap = new Map<string,id>();
        for(company__c  c:companyLst){
            companyIDMap.put(c.name,c.id);
        }
        
        system.debug('@@@@company'+companyLst);
       
       
       
        for(JSONParser jsonP:businessConfigParser){
            businessConfigLst= (List<Business_Config__c>)jsonP.readValueAs(List<Business_Config__c >.class);
            for(Business_Config__c bConfig :businessConfigLst){          
               system.debug('bConfig countryname'+bConfig.Id_Country__r.name);          
               businessConfigToInsertLst.add(new Business_Config__c(Id_Country__c=countryIDMap.get(bConfig.Id_Country__r.name),Business_Rule_Name__c=bConfig.Business_Rule_Name__c,name=bConfig.name,Business_Rule_Value__c=bConfig.Business_Rule_Value__c,Description__c=bConfig.Description__c,Is_Active__c=bConfig.Is_Active__c,Is_Json__c=bConfig.Is_Json__c,Parent__c=bConfig.Parent__c,Process_Name__c=bConfig.Process_Name__c,Record_Type_Id__c=bConfig.Record_Type_Id__c,Type__c =bConfig.Type__c ));
            }
        }
        insert businessConfigToInsertLst;
        system.debug('@@@@businessConfigLst'+businessConfigLst+businessConfigParser.size()+businessConfigToInsertLst.size());
       
       
      /*  for(JSONParser jsonP:tariffParser){
           tarifLst = (List<Tarif__c>)jsonP.readValueAs(List<Tarif__c>.class);
            for(Tarif__c tarifValue :tarifLst){          
               system.debug('tarifValue countryname'+tarifValue.Id_Country__r.name);          
               tarifToInsert.add(new Tarif__c(Id_Country__c=countryIDMap.get(tarifValue.Id_Country__r.name),Company__c=companyIDMap.get(tarifValue.company__r.name),Is_Active__c=tarifValue.Is_Active__c,RecordTypeID=tarifValue.RecordTypeID,Name=tarifValue.Name,CurrencyIsoCode=tarifValue.CurrencyIsoCode));
            }
        }
        //insert tarifToInsert;
        tarifToInsert =[select id, Name from Tarif__c];
        Map<String,id> tarifIDMap = new Map<string,id>();
        for (Tarif__c t:tarifToInsert){
           tarifIDMap.put(t.name,t.id);
       
        }
        //system.debug('@@@@tarifToInsert'+tarifToInsert+tarifToInsert.size()+tariffParser.size());
       
       
        for(JSONParser jsonP:tariffMemParser){
            tarifMemLst = (List<Tarif_Member__c>)jsonP.readValueAs(List<Tarif_Member__c>.class);
            for(Tarif_Member__c t :tarifMemLst){          
                         
                tarifMemToInsert.add(new Tarif_Member__c(Id_Tarif_Item__c=t.Id_Tarif_Item__c,Tarif_Name__c=tarifIDMap.get(t.Tarif_Name__r.name),Type__c=t.Type__c,RecordTypeID=t.RecordTypeID,CurrencyIsoCode=t.CurrencyIsoCode));
            }
        }
        insert tarifMemToInsert;
        system.debug('@@@@tarifMemToInsert'+tarifMemToInsert+tarifMemToInsert.size()+tariffMemParser.size());
       
       
       
        for(JSONParser jsonP:lpgParserLst){
            lpgLst = (List<List_Product_Group__c>)jsonP.readValueAs(List<List_Product_Group__c>.class);
            for(List_Product_Group__c lpg :lpgLst){          
               system.debug('lpg countryname'+lpg.Id_Country__r.name);          
               lpgToInsert.add(new List_Product_Group__c(Id_Country__c=countryIDMap.get(lpg.Id_Country__r.name),Company__c=companyIDMap.get(lpg.company__r.name),In_Use__c=lpg.In_Use__c,RecordTypeID=lpg.RecordTypeID,Name=lpg.Name,CurrencyIsoCode=lpg.CurrencyIsoCode ));
            }
        }
        //insert lpgToInsert;
        lpgToInsert=[select id, name from List_Product_Group__c];
        Map<String,id> lpgIDMap = new Map<string,id>();
        for(List_Product_Group__c  c:lpgToInsert){
            lpgIDMap.put(c.name,c.id);
        }
       system.debug('@@@@lpgToInsert'+lpgToInsert+lpgToInsert.size()+lpgParserLst.size());
       
       
        for(JSONParser jsonP:lppParserLst){
            lppLst = (List<List_Product_Price__c>)jsonP.readValueAs(List<List_Product_Price__c>.class);
            for(List_Product_Price__c lpp :lppLst){          
               system.debug('lpp countryname'+lpp.Id_Country__r.name);          
               lppToInsert.add(new List_Product_price__c(Product_Name__c=lpp.Product_Name__c,Installments__c =lpp.Installments__c,List_Price__c=lpp.List_Price__c,Allow_Installments__c=lpp.Allow_Installments__c,Id_List_Product_Group__c=lpgIDMap.get(lpp.Id_List_Product_Group__r.name),Maximum_Discount__c=lpp.Maximum_Discount__c,Product_Type__c=lpp.Product_Type__c,Requires_Additional_Charge__c=lpp.Requires_Additional_Charge__c,Requires_Add_On__c =lpp.Requires_Add_On__c ,Requires_Asset__c=lpp.Requires_Asset__c,Requires_Branding__c=lpp.Requires_Branding__c,Default_Quantity__c=lpp.Default_Quantity__c,Unapproved_Discount_Limit__c=lpp.Unapproved_Discount_Limit__c,Id_Country__c=countryIDMap.get(lpp.Id_Country__r.name),Company__c=companyIDMap.get(lpp.company__r.name),Is_Active__c=lpp.Is_Active__c,RecordTypeID=lpp.RecordTypeID,CurrencyIsoCode=lpp.CurrencyIsoCode ));
               system.debug('@@lppToInsert'+lppToInsert);
            }
        }
        //insert lppToInsert;
        system.debug('@@@@lppToInsert'+lppToInsert+lppToInsert.size()+lppParserLst.size());
       
       
        for(JSONParser jsonP:lspParserLst){
            lspLst = (List<List_Service_Price__c>)jsonP.readValueAs(List<List_Service_Price__c>.class);
            for(List_Service_Price__c lsp :lspLst){          
               system.debug('lsp countryname'+lsp.Id_Country__r.name);          
               lspToInsert.add(new List_Service_Price__c(Type__c=lsp.Type__c,Service_Type__c=lsp.Service_Type__c,Requires_Approval__c=lsp.Requires_Approval__c,Recurring_Fee__c=lsp.Recurring_Fee__c,Recurring_Interval__c=lsp.Recurring_Interval__c,Minimum_Commission_in_Percentage__c=lsp.Minimum_Commission_in_Percentage__c,Maximum_Commission_In_Percentage__c=lsp.Maximum_Commission_In_Percentage__c,Default_Commission_In_Percentage__c=lsp.Default_Commission_In_Percentage__c,Commission_Type__c=lsp.Commission_Type__c,Commission_Per_Order__c=lsp.Commission_Per_Order__c,Commission_In_Percentage__c=lsp.Commission_In_Percentage__c,Id_Country__c=countryIDMap.get(lsp.Id_Country__r.name),Company__c=companyIDMap.get(lsp.company__r.name),Is_Active__c=lsp.Is_Active__c,RecordTypeID=lsp.RecordTypeID,Name=lsp.Name,CurrencyIsoCode=lsp.CurrencyIsoCode ));
            }
        }
        //insert lspToInsert;
        system.debug('@@@@lspToInsert'+lspToInsert+lspToInsert.size()+lspParserLst.size());  */        
        }
        catch(Exception e){
           system.debug('Exception :'+e);
        }
    
    }
   
    public List<JSONParser> fetch(String sObjName)
    {
        
        try
        {
        jsonParserLst= new List<JSONParser>();
        
        final PageReference theUrl = new PageReference(SERVER_URL + '/services/data/v35.0/query/');
        theUrl.getParameters().put('q',sObjName);
        
        //limit=2000
        request = new HttpRequest();
        request.setEndpoint(theUrl.getUrl());
        request.setMethod('GET');
        request.setHeader('Authorization', 'OAuth ' + SESSION_ID);
        string body='';
        if(!test.isrunningtest()){
         body = (new Http()).send(request).getBody();
        }
        else
         body='{"totalSize":234,"done":false,"nextRecordsUrl":"/services/data/v35.0/query/01gg000000bUV4uAAG-200","records":[{"attributes":{"type":"Business_Config__c","url":"/services/data/v35.0/sobjects/Business_Config__c/a02g000000DS7jxAAD"},"Business_Rule_Name__c":"skipApprovalForTheseNonStandardComponents","Name":"a02g000000DS7jx","Business_Rule_Value__c":"Partial prepayment,Settlement,Cash before delivery,Premium Show Discount","Id_Country__c":"a05g000000BEIHpAAP","Id_Country__r"}]}';       
        
        system.debug('@@body'+body);
        JSONParser parser = JSON.createParser(body);

        do{
            parser.nextToken();
        }while(parser.hasCurrentToken() && !'records'.equals(parser.getCurrentName()));
        parser.nextToken();
        
        system.debug('@@parser'+parser);
        JSONParserLst.add(parser);
        
        //if there are more than 200 records
        if(body.contains('nextRecordsUrl')){
            moreRecords(body);        
        }
         
        system.debug('@@JSONParserLst'+JSONParserLst);
        return JSONParserLst;
        }
        catch(Exception e)
        {
            system.debug('@@@@Exception'+e);
            
        }
        return null;
         
    }
    
    
    private void moreRecords(string next){
        try{
            string nextUrl = next.substringafter('nextRecordsUrl":"');
            nextUrl=nextUrl.substringbefore('","records":');
            system.debug('@@nextUrl'+nextUrl);
            final PageReference theUrl2 = new PageReference(SERVER_URL + nextUrl);
            request = new HttpRequest();
            request.setEndpoint(theUrl2.getUrl());
            request.setMethod('GET');
            
            request.setHeader('Authorization', 'OAuth ' + SESSION_ID);
            String body='';
            if(!test.isrunningtest()){
                 body = (new Http()).send(request).getBody();
            }
            else
                body='{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Country__c","url":"/services/data/v35.0/sobjects/Country__c/a05g000000BEIHpAAP"},"Name":"Austria","Iso__c":"AT","CurrencyIsoCode":"EUR"}]}';
            system.debug('@@@@body2'+body);
            //system.debug('@@nextRecords'+nextRecords);
            system.debug('@@body'+body);
            JSONParser parser2 = JSON.createParser(body);
            do{
                parser2.nextToken();
            }while(parser2.hasCurrentToken() && !'records'.equals(parser2.getCurrentName()));
    
            parser2.nextToken();
            system.debug('@@parser2'+parser2);
            JSONParserLst.add(parser2);
            if(body.contains('nextRecordsUrl')){
                moreRecords(body);                            
            
            }
        
        }
        catch(Exception e)
        {
            system.debug('@@@@Exception'+e);
            
        }
              
    }
   
}