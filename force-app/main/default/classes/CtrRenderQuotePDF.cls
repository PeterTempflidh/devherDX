public with sharing class CtrRenderQuotePDF {
    
    /*******************************************************************************************************
    * @description SSC-349 - using this variable on VF page to display quote name
    */    
    public String oppQuoteName {get;set;} 
    public Opportunity_Quote__c oppQuote {get;set;}
    public transient Boolean showOnlinePdf {get;set;}
    //SP-761
    public transient Boolean showQuoteAdditions {get;set;}
    public transient List<String> listAdditions {get;set;} 
    //List<String> listAdditions = new List<String>();
    public transient String onlinePdfContent {get;set;}
    //private transient Messaging.SingleEmailMessage mail {get;set;}
    private static Map<String, Map<String,Map<String,Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    //changes for email limit hotfix
    private String templateName {get;set;}
    //SP-716
    private String quoteAddtionsFileNamePrefix {get;set;}

    public CtrRenderQuotePDF(ApexPages.StandardController ctr) {
        if(!Test.isRunningTest()){
            ctr.addFields(new List<String>{'Non_Standard_Contract_Components__c','RecordType.DeveloperName','Id_Opportunity__c','Template_Name__c','Name'});
        }
        this.showOnlinePdf = false;
        //SP-761
        this.showQuoteAdditions = false;
        this.listAdditions = new List<String>();

        //mail = new Messaging.SingleEmailMessage();
        this.oppQuote = (Opportunity_Quote__c) ctr.getRecord();
        Map<String,Map<String,Business_Config__c>> mapProcessData = moam.get('EmailConfiguration');
        if(mapProcessData!=null && !mapProcessData.isEmpty()){
            Map<String,Business_Config__c> mapBusinessData = mapProcessData.get(this.oppQuote.Recordtype.Developername);
            if(mapBusinessData!=null && !mapBusinessData.isEmpty()){
                if(mapBusinessData.get('OnlinePaymentPdf')!=null && this.oppQuote.Non_Standard_Contract_Components__c!=null){
                    if(this.oppQuote.Non_Standard_Contract_Components__c.contains('Online Payment Doc')){
                        templateName = mapBusinessData.get('OnlinePaymentPdf').Business_Rule_Value__c;
                    }else if(this.oppQuote.Non_Standard_Contract_Components__c.contains('BladeT&C')){
                        templateName = mapBusinessData.get('OnlinePaymentPdf').Business_Rule_Value__c;
                    }

                }
                //SP-761
                if(mapBusinessData.get('additionalMenueFlyers') != null && Boolean.valueOf(mapBusinessData.get('additionalMenueFlyers').Business_Rule_Value__c)){
                    this.showQuoteAdditions = true;
                    this.quoteAddtionsFileNamePrefix = mapBusinessData.get('additionalMenueFlyersFileNamePrefix').Business_Rule_Value__c;
                }
            }
        }
        //SSC-349 Adding quote name to pdf only for Talabat Quotes
        oppQuoteName = this.oppQuote.RecordType.developername == 'Talabat_Opportunity_Quote' ? this.oppQuote.Name : '';
    }

   


    //SP-761
    /*public void getQuoteAdditions(){
        if(templateName != null){
            System.debug('templateName : ' + templateName);
            PageReference pf = new PageReference('/apex/'+templateName+'?id='+this.oppQuote.Id_Opportunity__c);
            if(Test.IsRunningTest()){
                this.onlinePdfContent='UNIT.TEST';
            }
            else{
                this.onlinePdfContent = pf.getContent().toString();
            }
            this.showOnlinePdf = true;
            //return pf.getContent().toString();    
        }
        if(this.showQuoteAdditions){
            Set<String> setFileNames = new Set<String>();
            String fileName;

            for(String cuisineType : this.oppQuote.Non_Standard_Contract_Components__c.split(';')){
                fileName = this.quoteAddtionsFileNamePrefix + cuisineType;
                setFileNames.add(fileName);
            }

            for(StaticResource sr : [SELECT Name, Id, Body FROM StaticResource WHERE Name IN: setFileNames]){
                String utf8 = EncodingUtil.urlEncode(sr.Body.toString(),'UTF-8');
                System.debug('$$$ utf8: ' + utf8);

                listAdditions.add(utf8);
                //listAdditions.add(sr.Body.toString());
                //EncodingUtil.base64Encode(csvBlob);
                //listAdditions.add(EncodingUtil.base64Encode(sr.Body));

            }

            System.debug('$$$ listAddionts ' + listAdditions);
        }
    }*/




    public void getOnlinePaymentPDF(){
        if(templateName != null){
            System.debug('templateName : ' + templateName);
            PageReference pf = new PageReference('/apex/'+templateName+'?id='+this.oppQuote.Id);
            if(Test.IsRunningTest()){
                this.onlinePdfContent='UNIT.TEST';
            }
            else{
                this.onlinePdfContent = pf.getContent().toString();
            }
            this.showOnlinePdf = true;
            //return pf.getContent().toString();    
        }
        
    }
}
