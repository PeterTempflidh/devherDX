public with sharing class ClsQuoteProcessor {

    private Map<String,Map<String,Business_Config__c>> businessConfigData;
    private EmailTemplate theEmailTemplate;
    private EmailObject emailObj;
    private Opportunity opp;
    private String businessConfigName;
    private Boolean isError;
    private Boolean hasAsset;
    private Boolean hasService;
    private Boolean isMenuPrinting;
    private String whatId;
    private Boolean isAdsales;
    private Boolean isFlatProduct;
    private Boolean isCarLease;
    private Boolean isOwnerChange;
    private Boolean isPPProduct;
    private Boolean isPPProductDiscount;
    private Opportunity_Quote__c oppQuote;
    private static Map<String, Map<String,Map<String,Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    public String vfTemplateName {get;set;}

    public ClsQuoteProcessor(){

    }

    public ClsQuoteProcessor(Opportunity opp, String businessConfigName, Boolean hasAsset, Boolean hasService, Boolean isMenuPrinting, Boolean isAdsales, Boolean isFlatProduct, Boolean isCarLease, Boolean isOwnerChange, Boolean isPPProduct, Boolean isPPProductDiscount) {
        this.opp = opp;
        this.businessConfigName = businessConfigName;
        //this.businessConfigData = LibBusinessConfig.getGenericProcessData('OppQuoteProcess');
        this.businessConfigData = moam.get('OppQuoteProcess');
        this.isError = false;
        this.hasAsset = hasAsset;
        this.hasService = hasService;
        this.isMenuPrinting = isMenuPrinting;
        this.isAdsales = isAdsales;
        this.isFlatProduct = isFlatProduct;
        this.isCarLease=isCarLease;
        this.isOwnerChange=isOwnerChange;
        this.isPPProduct = isPPProduct;
        this.isPPProductDiscount = isPPProductDiscount;
    }

    public ClsQuoteProcessor(Opportunity opp,Opportunity_Quote__c oppQuote, String businessConfigName,List<Opportunity_Quote_Line_Item__c> listOfQLineItems) {
        this.isMenuPrinting=false;
        this.isAdsales=false;
        this.isOwnerChange=false;
        this.isPPProduct=false;
        this.isPPProductDiscount=false;
        this.isCarLease=false;
        this.hasAsset=false;
        this.hasService=false;
        this.isFlatProduct=false;
        this.opp = opp;
        this.oppQuote = oppQuote;
        this.businessConfigName = businessConfigName;
        //this.businessConfigData = LibBusinessConfig.getGenericProcessData('OppQuoteProcess');
        List<Opportunity_Quote_Line_Item__c> listOfProductLine = new List<Opportunity_Quote_Line_Item__c>();
        List<Opportunity_Quote_Line_Item__c> listOfServiceLine = new List<Opportunity_Quote_Line_Item__c>();

        if(listOfQLineItems!=null && !listOfQLineItems.isEmpty()){
            for(Opportunity_Quote_Line_Item__c oppQLineItem : listOfQLineItems){
                if(oppQLineItem.Sub_type__c=='Menu Printing'){
                    this.isMenuPrinting = true;
                }else if(oppQLineItem.Sub_type__c=='Ad Sales'){
                    this.isAdsales = true;
                }else if(oppQLineItem.Sub_type__c=='Flat Commission'){
                    this.isFlatProduct = true;
                }else if(oppQLineItem.Sub_type__c=='Automatic' || oppQLineItem.Sub_type__c=='Manual'){
                    this.isCarLease = true;
                }else if(oppQLineItem.Sub_type__c=='Premium Placement'){
                    this.isPPProduct = true;
                }else if(oppQLineItem.Sub_type__c=='Ad Sales'){
                    this.isAdsales = true;
                }
                if(oppQLineItem.Line_Item_Type__c=='Product'){
                    listOfProductLine.add(oppQLineItem);

                }else if(oppQLineItem.Line_Item_Type__c=='Service'){
                    listOfServiceLine.add(oppQLineItem);
                }
            }
        }
        if(this.oppQuote.Non_Standard_Contract_Components__c!=null && this.oppQuote.Non_Standard_Contract_Components__c.contains('Ownership Change')){
            this.isOwnerChange= true;        
        }else if(this.oppQuote.Non_Standard_Contract_Components__c!=null && this.oppQuote.Non_Standard_Contract_Components__c.containsIgnoreCase('Premium Show Discount')) {
            this.isPPProductDiscount = true;
        }
        this.businessConfigData = moam.get('OppQuoteProcess');
        this.isError = false;
        system.debug('@@this.isMenuPrinting'+this.isMenuPrinting);
        if(!this.isMenuPrinting){
            if(!listOfProductLine.isEmpty()){
                this.hasAsset = true;
            }
            if(!listOfServiceLine.isEmpty()){
                this.hasService = true;
            }
        }
        System.debug('this.hasService: '+this.hasService+'...'+this.hasAsset );
        //if(this.businessConfigData.get(businessConfigName) != null && this.businessConfigData.get(businessConfigName).get('OppQuoteEmailTemplate') != null && businessConfigData.get(this.businessConfigName).get('OppQuoteEmailTemplate').Business_Rule_Value__c != null){
        //    vfTemplateName = getTemplateName(businessConfigData.get(businessConfigName).get('OppQuoteEmailTemplate').Business_Rule_Value__c);
        //}else{
        //    vfTemplateName = 'Error';
        //}

        if(this.businessConfigData.get(this.businessConfigName) != null && this.businessConfigData.get(this.businessConfigName).get('OppQuoteEmailTemplate') != null && this.businessConfigData.get(this.businessConfigName).get('OppQuoteEmailTemplate').Business_Rule_Value__c != null){
            this.vfTemplateName = getTemplateName(this.businessConfigData.get(this.businessConfigName).get('OppQuoteEmailTemplate').Business_Rule_Value__c);
        }

    }

    public String getEmailHtmlValue(){
        this.getQuoteEmailTemplate();
        if(!isError){
            if(this.emailObj != null){
            return this.emailObj.mailHtmlBody;
            } else {
                return 'error';
            }
        } else {
            return 'error';
        }
    }   

    private void getQuoteEmailTemplate(){
        if(this.businessConfigData.get(this.businessConfigName) != null && this.businessConfigData.get(this.businessConfigName).get('OppQuoteEmailTemplate') != null && this.businessConfigData.get(this.businessConfigName).get('OppQuoteEmailTemplate').Business_Rule_Value__c != null){
            String templateName = getTemplateName(this.businessConfigData.get(this.businessConfigName).get('OppQuoteEmailTemplate').Business_Rule_Value__c);
            system.debug('GGGGGGGG calling getQuoteEmailTemplate - templateName: ' + templateName);
            try{
                theEmailTemplate = [SELECT id, HtmlValue FROM EmailTemplate WHERE DeveloperName =: templateName limit 1]; 
                this.renderHtmlEmail();
                this.isError = false;
            } catch(Exception e) {
                this.isError = true;
                System.debug('@@@@ calling getQuoteEmailTemplate in ClsQuoteProcessor. The following error occurred while reading the Business Config for OppQuoteProcess - OppQuoteEmailTemplate : ' +  e.getMessage());
            }
            
        } else {
            this.isError = true;
        }
    }

    private String getTemplateName(String businessValue){
        String templateName = '';
        List<String> templateTypes = businessValue.split(',');
        System.debug('templateTypes: '+templateTypes);
        System.debug('Flags: '+this.isCarLease+this.isOwnerChange+this.isPPProduct+this.isAdsales+this.isFlatProduct+this.hasService);
        if(templateTypes.size() > 1){    
        
            if(this.isCarLease){
                for(String str : templateTypes){
                    if(str.indexOf('CarLease') != - 1){
                        return str;
                    }
                }    
            
            }
            if(this.isOwnerChange){
                for(String str : templateTypes){
                    if(str.indexOf('Owner') != - 1){
                        return str;
                    }
                }  
            
            }else if(this.isPPProduct){
                if(this.isPPProductDiscount) {
                    for(String str : templateTypes){
                        if(str.indexOf('Quote_PP_Discount') != - 1){
                            return str;
                        }
                    }
                }
                else {
                    for(String str : templateTypes){
                        if(str.indexOf('Quote_PP_Discount') != - 1){
                        }
                        else {
                            if(str.indexOf('Quote_PP') != - 1){
                                return str;
                            }
                        }
                    }
                }

            }else if(this.isAdsales){
                for(String str : templateTypes){
                    if(str.indexOf('AdSales') != - 1){
                        return str;
                    }
                }
            }else if(this.isFlatProduct){
                for(String str : templateTypes){
                    if(str.indexOf('FixedCommission') != - 1){
                        return str;
                    }
                }
            }else if(this.hasAsset && this.hasService){
                for(String str : templateTypes){
                    if(str.indexOf('Both') != - 1){
                        return str;
                    }
                }
            } else if(this.hasAsset){
                for(String str : templateTypes){
                    if(str.indexOf('Asset') != - 1){
                        return str;
                    }
                }
            } else if(this.hasService){
                for(String str : templateTypes){
                    if(str.indexOf('Service') != - 1){
                        return str;
                    }
                }
            } else if(this.isMenuPrinting){
                for(String str : templateTypes){
                    if(str.indexOf('MenuPrinting') != - 1){
                        return str;
                    }
                }
            } 
                for(String str : templateTypes){
                    if(str.indexOf('Unique') != - 1){
                        return str;
                    }
         
            }
        } 
        return businessValue;
    }

    private void renderHtmlEmail(){
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'test@fake.de'};
        mail.setToAddresses(toAddresses);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false);
        mail.setSenderDisplayName('MMPT');
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setWhatId(this.opp.Id);
        mail.setTargetObjectId(UserInfo.getUserId());
        if(this.theEmailTemplate!=null){
            mail.setTemplateId(this.theEmailTemplate.Id);
        }
        Savepoint sp = Database.setSavepoint();
        System.debug('mail: '+mail);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        Database.rollback(sp);
        this.emailObj = new EmailObject(mail);
    }

    public String renderVFTemplate(){
        if(this.businessConfigData.get(this.businessConfigName) != null && this.businessConfigData.get(this.businessConfigName).get('OppQuoteEmailTemplate') != null && this.businessConfigData.get(this.businessConfigName).get('OppQuoteEmailTemplate').Business_Rule_Value__c != null){
            String vfcontent;
            this.vfTemplateName = getTemplateName(this.businessConfigData.get(this.businessConfigName).get('OppQuoteEmailTemplate').Business_Rule_Value__c);
            system.debug('GGGGGGGG calling getQuoteEmailTemplate - templateName: ' + this.vfTemplateName+'oppqouteid'+this.oppQuote.Id);
            String pageName = '/apex/'+this.vfTemplateName+'?id='+this.oppQuote.Id;
            System.debug('pageName: '+pageName);
            PageReference pf = new PageReference(pageName);
            if(!Test.isRunningTest()){
                vfcontent = pf.getContent().toString();
            }else{
               vfcontent = 'Some Text content'; 
            }
            
              
            System.debug('vfcontent: '+vfcontent);
            return vfcontent;

        }
        return 'error';
    }

    
    public static String renderVFTemplate(Id quoteId,String templateName){
        String vfcontent;
        if(templateName != null){            
            system.debug('GGGGGGGG calling getQuoteEmailTemplate - templateName: ' + templateName+'oppqouteid'+quoteId);
            String pageName = '/apex/'+templateName+'?id='+quoteId;
            System.debug('pageName: '+pageName);
            PageReference pf = new PageReference(pageName);
            if(!Test.isRunningTest()){
                vfcontent = pf.getContent().toString();
            }else{
               vfcontent = 'Some Text content'; 
            }
            System.debug('vfcontent: '+vfcontent);
        }else{
            return 'error';
        }
        return vfcontent;
    }


    public List<Opportunity> setDefaultValueForOpportunityQuoteComment(List<Opportunity> opportunities, Boolean isMenuPrinting){
        //Map<Id,RecordType> mapRecordTypesForIds = LibRecordTypeHelper.getRecordTypeForIds(new Set<String>{'Opportunity'});
        Set<String> accountIds = new Set<String>();
        //Map<String,Map<String,Business_Config__c>> mapProcessData = LibBusinessConfig.getGenericProcessData('OppQuoteProcess');
        Map<String,Map<String,Business_Config__c>> mapProcessData = moam.get('OppQuoteProcess');
        Map<String, List<Opportunity>> acctIdOppMap = new Map<String, List<Opportunity>>();
        Map<String, Contact> acctContactMap = new Map<String, Contact>();
        Map<String,Business_Config__c> mapBusinessData;
        List<String> greetingParts;
        String defaultContent = '';
        

        //if(mapProcessData!=null && !mapProcessData.isEmpty() && mapProcessData.get(mapRecordTypesForIds.get(opportunities[0].RecordTypeId).DeveloperName) != null){
        //    mapBusinessData = mapProcessData.get(mapRecordTypesForIds.get(opportunities[0].RecordTypeId).DeveloperName);
        if(mapProcessData!=null && !mapProcessData.isEmpty() && mapProcessData.get(LibRecordTypeHelper.getRecordTypeValue(opportunities[0].RecordTypeId)) != null){
            mapBusinessData = mapProcessData.get(LibRecordTypeHelper.getRecordTypeValue(opportunities[0].RecordTypeId));
            if(mapBusinessData != null){
                if(isMenuPrinting && mapBusinessData.get('DefaultContentMenuPrinting') != null){
                    defaultContent = mapBusinessData.get('DefaultContentMenuPrinting').Business_Rule_Value__c;
                } else {
                    if(mapBusinessData.get('DefaultContent') != null){
                        defaultContent = mapBusinessData.get('DefaultContent').Business_Rule_Value__c;
                    }
                }
                if(mapBusinessData.get('Greeting') != null){
                    greetingParts =  mapBusinessData.get('Greeting').Business_Rule_Value__c.split(',');
                }
                //if(mapBusinessData != null && mapBusinessData.get('UseDefaultQuoteComment') != null && String.isNotBlank(mapBusinessData.get('UseDefaultQuoteComment').Business_Rule_Value__c) && !mapBusinessData.get('UseDefaultQuoteComment').Business_Rule_Value__c.equals('false')){
                if((!isMenuPrinting && mapBusinessData.get('UseDefaultQuoteComment') != null && String.isNotBlank(mapBusinessData.get('UseDefaultQuoteComment').Business_Rule_Value__c) && !mapBusinessData.get('UseDefaultQuoteComment').Business_Rule_Value__c.equals('false'))
                    || (isMenuPrinting && mapBusinessData.get('UseDefaultQuoteCommentMenuPrinting') != null && String.isNotBlank(mapBusinessData.get('UseDefaultQuoteCommentMenuPrinting').Business_Rule_Value__c) && !mapBusinessData.get('UseDefaultQuoteCommentMenuPrinting').Business_Rule_Value__c.equals('false'))){

                    for(Opportunity opp : opportunities){
                        if(acctIdOppMap.get(opp.AccountId) != null){
                            acctIdOppMap.get(opp.AccountId).add(opp);
                        } else {
                            acctIdOppMap.put(opp.AccountId, new List<Opportunity>{opp});
                        }
                        accountIds.add(opp.AccountId);
                    }
                    
                    List<Contact> primaryContacs = [SELECT Id, Email, Salutation, LastName, FirstName, AccountId FROM Contact WHERE AccountId IN : accountIds AND Contact_Role__c = 'Owner'];
                
                    if(!primaryContacs.isEmpty()){
                        for(Contact con : primaryContacs){
                            acctContactMap.put(con.AccountId, con);
                        }
                    }

                    for(String str : acctIdOppMap.keySet()){
                        String salutation = '';
                        String firstName = '';
                        String lastName = '';
                        String contentHead = '';
                        String completeContent = '';
                        if(acctContactMap.get(str) != null && greetingParts != null){
                            Contact con = acctContactMap.get(str);
                            if(greetingParts.size() >= 2){
                                if(greetingParts[1].equals('FirstName')){
                                    if(mapBusinessData.get('DefaultSalutationFirstNameFirst') != null){
                                        contentHead = mapBusinessData.get('DefaultSalutationFirstNameFirst').Business_Rule_Value__c;
                                    }
                                } else if(greetingParts[1].equals('LastName')){
                                    if(mapBusinessData.get('DefaultSalutationLastNameFirst') != null){
                                        contentHead = mapBusinessData.get('DefaultSalutationLastNameFirst').Business_Rule_Value__c;
                                    }
                                    //contentHead = Label.Quote_Email_Default_Content_LastName_First;
                                } else {
                                    if(mapBusinessData.get('DefaultSalutation') != null){
                                        contentHead = mapBusinessData.get('DefaultSalutation').Business_Rule_Value__c;
                                    }
                                    //contentHead = Label.Quote_Email_Dear_Customer;
                                }
                            } else {
                                if(greetingParts[0].equals('FirstName')){
                                    if(mapBusinessData.get('DefaultSalutationFirstNameFirst') != null){
                                        contentHead = mapBusinessData.get('DefaultSalutationFirstNameFirst').Business_Rule_Value__c;
                                    }
                                    //contentHead = Label.Quote_Email_Default_Content_FirstName_First;
                                } else if(greetingParts[0].equals('LastName')){
                                    if(mapBusinessData.get('DefaultSalutationLastNameFirst') != null){
                                        contentHead = mapBusinessData.get('DefaultSalutationLastNameFirst').Business_Rule_Value__c;
                                    }
                                    //contentHead = Label.Quote_Email_Default_Content_LastName_First;
                                } else {
                                    if(mapBusinessData.get('DefaultSalutation') != null){
                                        contentHead = mapBusinessData.get('DefaultSalutation').Business_Rule_Value__c;
                                    }
                                    //contentHead = Label.Quote_Email_Dear_Customer;
                                }
                            }
                            for(String part : greetingParts){
                                if(part.equals('Salutation') && con.Salutation != null){
                                    salutation = con.Salutation;
                                } else if(part.equals('FirstName') && con.FirstName != null){
                                    firstName = con.FirstName;
                                } else if(part.equals('LastName') && con.LastName != null){
                                    lastName = con.LastName;
                                }
                            }
                            contentHead = contentHead.replace('{Salutation}', salutation);
                            contentHead = contentHead.replace('{FirstName}', firstName);
                            contentHead = contentHead.replace('{LastName}', lastName);

                            //completeContent = contentHead.trim() + ',' + Label.Quote_Email_Default_Content;
                            completeContent = contentHead.trim() + ',' + defaultContent;
                            for(Opportunity opp : acctIdOppMap.get(str)){
                                if(isMenuPrinting){
                                    opp.Quote_Comment_Menu_Printing__c = completeContent;
                                } else {
                                    opp.Quote_Comment__c = completeContent;
                                }
                            }
                        } else{
                            if(mapBusinessData.get('DefaultSalutationFirstNameFirst') != null){
                                contentHead = mapBusinessData.get('DefaultSalutationFirstNameFirst').Business_Rule_Value__c;
                            }
                            //contentHead = Label.Quote_Email_Default_Content_FirstName_First;
                            if(mapBusinessData.get('DefaultSalutation') != null){
                                contentHead = contentHead.replace('Dear',mapBusinessData.get('DefaultSalutation').Business_Rule_Value__c);
                            }
                            //contentHead = contentHead.replace('Dear', Label.Quote_Email_Dear_Customer);
                            contentHead = contentHead.replace('{Salutation}', salutation);
                            contentHead = contentHead.replace('{FirstName}', firstName);
                            contentHead = contentHead.replace('{LastName}', lastName);
                            completeContent = contentHead.trim() + ',' + defaultContent;

                            for(Opportunity opp : acctIdOppMap.get(str)){
                                if(isMenuPrinting){
                                    opp.Quote_Comment_Menu_Printing__c = completeContent;
                                } else {
                                    opp.Quote_Comment__c = completeContent;
                                }
                            }
                        }
                    }
                }
            }   
        }
        return opportunities;
    }

    public Boolean submitQuoteForApproval(Id quoteId){
        //System.debug('@@@@ submitQuoteForApproval - quoteId : ' + quoteId);
        Approval.ProcessSubmitRequest ar = new Approval.ProcessSubmitRequest();
        ar.setComments('Submitting request for approval');
        ar.setObjectId(quoteId);
        Approval.ProcessResult result = Approval.Process(ar);
        if(result.isSuccess()){
            return true;
        }
        return false;
    }

    //wrapper
    public class EmailObject{
        public String mailTextBody;
        public String mailHtmlBody;
        public String mailSubject;

        public emailObject(Messaging.SingleEmailMessage mail){
            this.mailTextBody = mail.getPlainTextBody();
            this.mailHtmlBody = mail.getHTMLBody();
            this.mailSubject = mail.getSubject();
        }

    }
}