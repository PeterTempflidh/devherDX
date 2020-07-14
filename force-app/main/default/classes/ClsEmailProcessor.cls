public with sharing class ClsEmailProcessor {
    private static Map<String, Map<String,Map<String,Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;

    /*
    * SP -581
    * send out notification template to all approvers that have set the notfication checkbox and are available for the required level
    *
    * 
    *
    *    sending email needed some hacks. If you use a template and link it to the desired object (to access merge fields)
    *    you cannot send emails to users (only contacts).
    *
    *    So we query a dummy contact to initiate the email object correctly but before sending we roll back the transaction
    *    and swap the dummy contact address with the wanted user email id
    *
    *
    * @param 
    *       list of custom setting entries
    *       recordtype developername
    *       whatId
    * @return void
    */

    public static void notifyApprovers(List<OpportunityTeamMember> listApprovalEntries, String recordTypeDeveloperName, String whatId){
        List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
        //List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
        //Messaging.SingleEmailMessage theEmail = new Messaging.SingleEmailMessage();



        Set<String> setUserEmailIds = new Set<String>();

        for(OpportunityTeamMember approvalEntry : listApprovalEntries){

            if( !setUserEmailIds.contains(approvalEntry.User.Email)){
                setUserEmailIds.add(approvalEntry.User.Email);
            }
        }



        List<String> listApprovalUserEmailIds = new List<String>();
        listApprovalUserEmailIds.addAll(setUserEmailIds);

        System.debug('$$$ listApprovalUserEmailIds: ' + listApprovalUserEmailIds);
               
        //Contact dummy = [SELECT Id, Email FROM Contact WHERE Email != null LIMIT 1];

        //System.debug('$$$ dummy contact: ' + dummy);
        Opportunity_Quote__c oppQuote = [select Id_account__r.name,Id_Opportunity__r.Name from Opportunity_Quote__c where id=:whatId];

        String notificationTemplate;
        String subject;

        Map<String,Business_Config__c> mapBusinessData;
        Map<String,Map<String,Business_Config__c>> mapProcessData= moam.get('QuoteApprovalProcess');

        if(mapProcessData != null && !mapProcessData.isEmpty()){
            mapBusinessData = mapProcessData.get(recordTypeDeveloperName);
        }



        if(mapBusinessData.get('notificationTemplate')!=null &&  String.isNotBlank(mapBusinessData.get('notificationTemplate').Business_Rule_Value__c)){
            notificationTemplate = mapBusinessData.get('notificationTemplate').Business_Rule_Value__c;
        }
        if(mapBusinessData.get('notificationSubject')!=null &&  String.isNotBlank(mapBusinessData.get('notificationSubject').Business_Rule_Value__c)){
            if(mapBusinessData.get('notificationSubject').Business_Rule_Value__c.indexOf('{AccountName}')>-1){
                subject = mapBusinessData.get('notificationSubject').Business_Rule_Value__c.replace('{AccountName}',oppQuote.Id_account__r.Name);
            }else{
                subject = mapBusinessData.get('notificationSubject').Business_Rule_Value__c;
            }
        }

        if(notificationTemplate != null && !listApprovalUserEmailIds.isEmpty()){
            sendEmailWithVfTemplate(notificationTemplate,whatId,listApprovalUserEmailIds,subject);
            /*String teplateContent = renderVFTemplate(notificationTemplate,whatId);
                theEmail.setToAddresses(listApprovalUserEmailIds);
                theEmail.setHTMLBody(teplateContent);
                theEmail.setSubject(subject);
                lstMsgs.add(theEmail);

                if(!Test.isRunningTest()){
                    Messaging.sendEmail(lstMsgs);    
                }*/
            /*theEmail.setTargetObjectId(dummy.Id);
            theEmail.setToAddresses(listApprovalUserEmailIds);
            theEmail.setTemplateId(notificationTemplate);
            theEmail.setWhatId(whatId);
            theEmail.setSaveAsActivity(false);
            lstMsgs.add(theEmail);

            // Send the emails in a transaction, then roll it back
            Savepoint sp = Database.setSavepoint();
            if(!Test.isRunningTest()){
                Messaging.sendEmail(lstMsgs);    
            }
            

            Database.rollback(sp);

            
             for (Messaging.SingleEmailMessage email : lstMsgs) {
                System.debug('$$$ email: ' + email);
                 Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                 emailToSend.setToAddresses(email.getToAddresses());
                 emailToSend.setPlainTextBody(email.getPlainTextBody());
                 emailToSend.setHTMLBody(email.getHTMLBody());
                 emailToSend.setSubject(email.getSubject());
                 lstMsgsToSend.add(emailToSend);
             }
            if(!Test.isRunningTest()){
                Messaging.sendEmail(lstMsgsToSend);   
            }*/
             
        }
    }

//This method is created due to the empty soql for Opp quote as the quote is not yet committed in database hence have to go for future method
@future(callout=true)
public static void sendEmailWithVfTemplate(String notificationTemplate,String whatId,List<String> listApprovalUserEmailIds,String subject){
    List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
    Messaging.SingleEmailMessage theEmail = new Messaging.SingleEmailMessage();
    String teplateContent = renderVFTemplate(notificationTemplate,whatId);
    theEmail.setToAddresses(listApprovalUserEmailIds);
    theEmail.setHTMLBody(teplateContent);
    theEmail.setSubject(subject);
    lstMsgs.add(theEmail);

    if(!Test.isRunningTest()){
        Messaging.sendEmail(lstMsgs);    
    }
}



    /*
    * SP -581
    * send out notification template to approver
    *
    * 
    *
    *    sending email needed some hacks. If you use a template and link it to the desired object (to access merge fields)
    *    you cannot send emails to users (only contacts).
    *
    *    So we query a dummy contact to initiate the email object correctly but before sending we roll back the transaction
    *    and swap the dummy contact address with the wanted user email id
    *
    *
    * @param 
    *       userId of approver
    *       whatId
    * @return void
    */    

   /* public static void notifyApprover(String userId, String recordTypeDeveloperName, String whatId){
        List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage theEmail = new Messaging.SingleEmailMessage();
        Boolean sendMail = true;

        Map<String, TLB_Approval_Matrix__c> mapApprovalMatrix = TLB_Approval_Matrix__c.getall();

        for(TLB_Approval_Matrix__c entry : mapApprovalMatrix.values()){
            if(entry.User_Id__c == userId && entry.notification__c == false){
                sendMail = false;
            }
        }

        if(sendMail){



            Contact dummy = [SELECT Id, Email FROM Contact WHERE Email != null LIMIT 1];

            String emailId = [SELECT Email FROM User WHERE Id =: userId].Email;

            String notificationTemplate;

            Map<String,Business_Config__c> mapBusinessData;
            Map<String,Map<String,Business_Config__c>> mapProcessData= moam.get('QuoteApprovalProcess');

            if(mapProcessData != null && !mapProcessData.isEmpty()){
                mapBusinessData = mapProcessData.get(recordTypeDeveloperName);
            }



            if(mapBusinessData.get('notificationTemplate')!=null &&  String.isNotBlank(mapBusinessData.get('notificationTemplate').Business_Rule_Value__c)){
                notificationTemplate = mapBusinessData.get('notificationTemplate').Business_Rule_Value__c;
            }
            

            if(notificationTemplate != null ){


                theEmail.setTargetObjectId(dummy.Id);
                theEmail.setToAddresses(new List<String>{emailId});
                theEmail.setTemplateId(notificationTemplate);
                theEmail.setWhatId(whatId);
                theEmail.setSaveAsActivity(false);
                lstMsgs.add(theEmail);

                // Send the emails in a transaction, then roll it back
                Savepoint sp = Database.setSavepoint();
                Messaging.sendEmail(lstMsgs);

                Database.rollback(sp);

                
                 for (Messaging.SingleEmailMessage email : lstMsgs) {
                     Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                     emailToSend.setToAddresses(email.getToAddresses());
                     emailToSend.setPlainTextBody(email.getPlainTextBody());
                     emailToSend.setHTMLBody(email.getHTMLBody());
                     emailToSend.setSubject(email.getSubject());
                     lstMsgsToSend.add(emailToSend);
                 }

                 Messaging.sendEmail(lstMsgsToSend);
            }
        }
    }*/

    public static void sendRejectionNotification(String userId, String recordTypeDeveloperName, String whatId){
        List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage theEmail = new Messaging.SingleEmailMessage();

        //Contact dummy = [SELECT Id, Email FROM Contact WHERE Email != null LIMIT 1];

        String emailId = [SELECT Email FROM User WHERE Id =: userId].Email;
        Opportunity_Quote__c oppQuote = [select Id_account__r.name,Id_Opportunity__r.Name from Opportunity_Quote__c where id=:whatId];
        String notificationTemplate;
        String subject;

        Map<String,Business_Config__c> mapBusinessData;
        Map<String,Map<String,Business_Config__c>> mapProcessData= moam.get('QuoteApprovalProcess');

        if(mapProcessData != null && !mapProcessData.isEmpty()){
            mapBusinessData = mapProcessData.get(recordTypeDeveloperName);
        }



        if(mapBusinessData.get('rejectionTemplate')!=null &&  String.isNotBlank(mapBusinessData.get('rejectionTemplate').Business_Rule_Value__c)){
            notificationTemplate = mapBusinessData.get('rejectionTemplate').Business_Rule_Value__c;
        }
        if(mapBusinessData.get('rejectionSubject')!=null &&  String.isNotBlank(mapBusinessData.get('rejectionSubject').Business_Rule_Value__c)){
            if(mapBusinessData.get('rejectionSubject').Business_Rule_Value__c.indexOf('{OppName}')>-1){
                subject = mapBusinessData.get('rejectionSubject').Business_Rule_Value__c.replace('{OppName}',oppQuote.Id_Opportunity__r.Name);
            }else{
                subject = mapBusinessData.get('rejectionSubject').Business_Rule_Value__c;
            }
        }
        if(notificationTemplate != null ){

            sendEmailWithVfTemplate(notificationTemplate,whatId,new List<String>{emailId},subject);
            
            /*String teplateContent = renderVFTemplate(notificationTemplate,whatId);
                theEmail.setToAddresses(new List<String>{emailId});
                theEmail.setHTMLBody(teplateContent);
                theEmail.setSubject(subject);
                lstMsgs.add(theEmail);

                if(!Test.isRunningTest()){
                    Messaging.sendEmail(lstMsgs);    
                }*/

                
               /* theEmail.setTargetObjectId(dummy.Id);
                theEmail.setToAddresses(new List<String>{emailId});
                theEmail.setTemplateId(notificationTemplate);
                theEmail.setWhatId(whatId);
                theEmail.setSaveAsActivity(false);
                lstMsgs.add(theEmail);

                // Send the emails in a transaction, then roll it back
                Savepoint sp = Database.setSavepoint();
                if(!Test.isRunningTest()){
                    Messaging.sendEmail(lstMsgs);    
                }
                

                Database.rollback(sp);

                
                 for (Messaging.SingleEmailMessage email : lstMsgs) {
                     Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                     emailToSend.setToAddresses(email.getToAddresses());
                     emailToSend.setPlainTextBody(email.getPlainTextBody());
                     emailToSend.setHTMLBody(email.getHTMLBody());
                     emailToSend.setSubject(email.getSubject());
                     lstMsgsToSend.add(emailToSend);
                 }

            if(!Test.isRunningTest()){
                Messaging.sendEmail(lstMsgsToSend);
            }*/
             
        }
    }

    public static String renderVFTemplate(String templateName,String oppQuoteId){
            String vfcontent;
            system.debug('GGGGGGGG calling getQuoteEmailTemplate - templateName: ' + templateName);
            String pageName = '/apex/'+templateName+'?id='+oppQuoteId;
            PageReference pf = new PageReference(pageName);
            if(!Test.isRunningTest()){
                //pf.setRedirect(true);
                vfcontent = pf.getContent().toString();
            }else{
               vfcontent = 'Some Text content'; 
            }
            System.debug('vfcontent: '+vfcontent);
            return vfcontent;
    }
    



    
    /**
    * checks if a case for this email was already created. The unique identifier
    * of doublete is set in the business config rule 
    *
    * @param 
    *       map of new emails (Trigger.new)
    * @return void
    */    

    /*public static void preventDoubleCaseCreation(Map<String,List<EmailMessage>> mapEmails){

        Map<String,Business_Config__c> mapBusinessRule = new Map<String,Business_Config__c>();


        for(String toAddress : mapEmails.keySet()){
            //get business config for the incoming toAddress
            mapBusinessRule = LibBusinessConfig.getGenericProcessData('Email2Case_' + toAddress).values[0];

            String uniqueIdentifierFieldName = mapBusinessRule.get('uniqueIdentifier').Business_Rule_Value__c;



        }
    }*/



    /**
    * links the Email2Case to the account with the same emailaddress 
    *
    * @param 
    *       map of new emails (Trigger.new)
    * @return void
    */
    /*public static void linkCaseToAccountBasedOnEmailaddress(Map<Id,EmailMessage> mapEmails){
        Set<Id> setCaseIds = new Set<Id>();
        Set<String> setEmailAddresses = new Set<String>();
        List<Case> listCases2Update = new List<Case>();

        //gather case ids and from-addresses
        for(EmailMessage email : mapEmails.values()){
            if(email.ParentId != null && !setCaseIds.contains(email.ParentId)){
                setCaseIds.add(email.ParentId);

                if(!setEmailAddresses.contains(email.FromAddress) && email.FromAddress != null){
                    setEmailAddresses.add(email.FromAddress);
                }
            }
        }
        //get the ids of the accounts based on email addresses 
        Map<String,Id> mapAddressesAccounts = new Map<String,Id>();
        for(Account acc : [SELECT Id, Account_Email__c FROM Account WHERE Account_Email__c IN: setEmailAddresses]){
            mapAddressesAccounts.put(acc.Account_Email__c,acc.Id);
        }

        //get the ids of the accounts based on the contacts email addresses
        Map<String,Id> mapAddressesContacts = new Map<String,Id>();
        for(Contact c : [SELECT Id, Email, AccountId FROM Contact WHERE Email IN: setEmailAddresses]){
            mapAddressesContacts.put(c.Email, c.AccountId);
        }

        for(Case c : [SELECT Id,AccountId,SuppliedEmail,RecordTypeId FROM Case WHERE Id IN: setCaseIds]){
            Id theAccountId;

            if(mapAddressesAccounts.get(c.SuppliedEmail) != null){
                theAccountId = mapAddressesAccounts.get(c.SuppliedEmail);
            }else if(mapAddressesContacts.get(c.SuppliedEmail) != null){
                theAccountId = mapAddressesContacts.get(c.SuppliedEmail);
            }

            c.AccountId = theAccountId;
            
            listCases2Update.add(c);
        }

        //listCases2Update = ClsEmailProcessor.setDefaultValuesFromBusinessConfig(listCases2Update);

        if(!listCases2Update.isEmpty()){
            update listCases2Update;
        }
    }
*/
    

    /**
    * iterates through every Email2Case, extracts the necessary information by using regular expressions
    * and updates the case fields depending on a business config
    *
    * @param map of email messages to process; key is toAddress
    *      
    * @return void
    */
    public static void processEmail2Case(Map<String,List<EmailMessage>> mapEmails){
        Set<Id> setCaseIds = new Set<Id>();
        Map<Id,List<Email2CaseTokenWrapper>> mapCaseIdTokenWrapper = new Map<Id,List<Email2CaseTokenWrapper>>();
        Map<String,Map<String,Business_Config__c>> mapBusinessLogic = new Map<String,Map<String,Business_Config__c>>();
        Map<String,Business_Config__c> mapBusinessRule = new Map<String,Business_Config__c>();
        Set<String> setUniqueIdentifierFieldValues = new Set<String>();
        List<Case> listCases2Delete = new List<Case>();
        Set<String> setSpecialIncomingAddresses = new Set<String>();
        Boolean specialInboundProcess = false;
        //List<Email2CaseTokenWrapper> listWrapper = new List<Email2CaseTokenWrapper>();
        String regExp;
        Pattern thePattern;
        Matcher theMatcher;



        for(String toAddress : mapEmails.keySet()){
            //get business config for the incoming toAddress
            //mapBusinessLogic = LibBusinessConfig.getGenericProcessData('Email2Case_' + toAddress);
            mapBusinessLogic = moam.get('Email2Case_' + toAddress);
            
            if(mapBusinessLogic != null && !mapBusinessLogic.isEmpty()){
                mapBusinessRule = mapBusinessLogic.values()[0];

                if(mapBusinessRule != null && !mapBusinessRule.isEmpty()){

                    if(mapBusinessRule.get('RegExp') != null){
                        regExp = mapBusinessRule.get('RegExp').Business_Rule_Value__c;
                        thePattern = Pattern.compile(regExp);    
                    }
                    
                    if(mapBusinessRule.get('incomingAddresses') != null){
                       setSpecialIncomingAddresses.addAll(mapBusinessRule.get('incomingAddresses').Business_Rule_Value__c.split(','));
                    }
                    

                    String uniqueIdentifierFieldName = null;
                    if(mapBusinessRule.get('uniqueIdentifier') != null){
                        uniqueIdentifierFieldName = mapBusinessRule.get('uniqueIdentifier').Business_Rule_Value__c;
                    }
                    //regExp = '((?m)^[a-zA-Z ]*:)([a-zöäüßA-Z0-9@\\/+&:\\- [:punct:]]*)([\n])';
                    

                    List<EmailMessage> listEmails = mapEmails.get(toAddress);
                    for(EmailMessage e : listEmails){
                        if(!setCaseIds.contains(e.ParentId)){
                            setCaseIds.add(e.ParentId);
                        }
                        System.debug('$$$ FromAddress' + e.FromAddress);
                        
                        if(setSpecialIncomingAddresses.contains(e.FromAddress)){
                            specialInboundProcess = true;
                            Email2CaseTokenWrapper theWrapper = new Email2CaseTokenWrapper();

                            theWrapper.token = 'SuppliedEmail';
                            theWrapper.value = e.FromAddress;
                            List<Email2CaseTokenWrapper> listWrapper = new List<Email2CaseTokenWrapper>{theWrapper};

                            mapCaseIdTokenWrapper.put(e.ParentId, listWrapper);
                        }

                        //regular expression parsing of emailbody/emailsubject starts here...
                        if(mapBusinessRule.get('WhatToParse').Business_Rule_Value__c == 'Body'){
                            if(e.TextBody != null){
                                theMatcher = thePattern.matcher(e.TextBody);    
                            }
                        }else if(mapBusinessRule.get('WhatToParse').Business_Rule_Value__c == 'Subject'){
                            if(e.Subject != null){
                                theMatcher = thePattern.matcher(e.Subject);    
                            }
                        }else if(mapBusinessRule.get('WhatToParse').Business_Rule_Value__c == 'Header'){
                            Email2CaseTokenWrapper theWrapper = new Email2CaseTokenWrapper();

                            theWrapper.token = 'SuppliedEmail';
                            theWrapper.value = e.FromAddress;
                            List<Email2CaseTokenWrapper> listWrapper = new List<Email2CaseTokenWrapper>{theWrapper};

                            mapCaseIdTokenWrapper.put(e.ParentId, listWrapper);

                        }

                        System.debug('$$$ theMatcher: ' + theMatcher);

                        if(theMatcher != null && theMatcher.find()){
                            List<Email2CaseTokenWrapper> listWrapper = new List<Email2CaseTokenWrapper>();
                            do{
                                Email2CaseTokenWrapper theWrapper = new Email2CaseTokenWrapper();

                                if(uniqueIdentifierFieldName != null){
                                    if(theMatcher.group(1) == uniqueIdentifierFieldName){
                                        if(!setUniqueIdentifierFieldValues.contains(theMatcher.group(2))){
                                            setUniqueIdentifierFieldValues.add(theMatcher.group(2));
                                        }
                                    }    
                                }
                                

                                theWrapper.token = theMatcher.group(1);
                                theWrapper.value = theMatcher.group(2);

                                System.debug('$$$ RegExp: token: ' + theWrapper.token + ' value: ' + theWrapper.value);

                                listWrapper.add(theWrapper);


                            }while(theMatcher.find());

                            mapCaseIdTokenWrapper.put(e.ParentId, listWrapper);
                        }else{
                            System.debug('$$$ no match found');
                        }
                        
                        /*if(skipParsing){
                            if(mapBusinessRule.get('mappingIncomingAddresses').Business_Rule_Value__c != null){
                                    String defaultValues = mapBusinessRule.get('mappingIncomingAddresses').Business_Rule_Value__c;
                                    Map<String,String> mapDefaultValues = (Map<String,String>) JSON.deserialize(defaultValues, Map<String,String>.class);

                                    for(String fieldName : mapDefaultValues.keySet()){
                                        c.put(fieldName, (String) mapDefaultValues.get(fieldName));
                                    }   
                            }
                        }*/
                    }   
                    
                    
                    
                    if(!mapCaseIdTokenWrapper.isEmpty()){
                        String jsonMapping = mapBusinessRule.get('jsonMapping').Business_Rule_Value__c;
                        //jsonMapping is : key=token / value=name of case field
                        Map<String,String> mapMapping = (Map<String,String>) JSON.deserialize(jsonMapping, Map<String,String>.class);

                        List<String> listFieldNames4Query = mapMapping.values();
                        String queryString = 'SELECT Id,RecordTypeId, ' + String.join(listFieldNames4Query, ',') + ' FROM Case WHERE Id IN: setCaseIds';

                        List<Case> listCases2Update = Database.query(queryString);

                        if(!listCases2Update.isEmpty()){
                            for(Case c : listCases2Update){
                                //setting values from parsing
                                for(Email2CaseTokenWrapper theWrapper : mapCaseIdTokenWrapper.get(c.Id)){
                                    if(mapMapping.get(theWrapper.token) != null){

                                        if(setUniqueIdentifierFieldValues != null && setUniqueIdentifierFieldValues.contains(theWrapper.value)){
                                            listCases2Delete.add(c);
                                        }
                                        System.debug('$$$updating case fieldName:'+mapMapping.get(theWrapper.token));
                                        System.debug('$$$updating case fieldValue:'+theWrapper.value);
                                        c.put(
                                            //fieldname:
                                            mapMapping.get(theWrapper.token),
                                            //value:
                                            theWrapper.value
                                        );  
                                    }
                                    
                                }
                                if(specialInboundProcess){
                                    if(mapBusinessRule.get('mappingIncomingAddresses').Business_Rule_Value__c != null){
                                            String defaultValues = mapBusinessRule.get('mappingIncomingAddresses').Business_Rule_Value__c;
                                            Map<String,String> mapDefaultValues = (Map<String,String>) JSON.deserialize(defaultValues, Map<String,String>.class);
        
                                            for(String fieldName : mapDefaultValues.keySet()){
                                                c.put(fieldName, (String) mapDefaultValues.get(fieldName));
                                            }   
                                    }
                                }   
                                //setting default values
                                if(mapBusinessRule.get('defaultMapping').Business_Rule_Value__c != null){
                                    String defaultValues = mapBusinessRule.get('defaultMapping').Business_Rule_Value__c;
                                    Map<String,String> mapDefaultValues = (Map<String,String>) JSON.deserialize(defaultValues, Map<String,String>.class);

                                    for(String fieldName : mapDefaultValues.keySet()){
                                        c.put(fieldName, (String) mapDefaultValues.get(fieldName));
                                    }   
                                }
                            }
                        }
                        if(!listCases2Update.isEmpty()){
                            System.debug('updating caselist : '+ listCases2Update);
                            update listCases2Update; 

                            Map<Id,Case> mapCases = new Map<Id,Case>();
                            mapCases.putAll(listCases2Update);
                            LibHelper.linkCasesToAccountBasedOnFieldValue(mapCases);
                        }

                        if(!listCases2Delete.isEmpty()){
                            delete listCases2Delete;
                        }  
                    }                           
                }
            }   
        }
        
    }
    /**
    * private class used in processPhoneTransmissionEmails method to build needed data structure
    */
    private class Email2CaseTokenWrapper{
        String token {get;set;}
        String value {get;set;}

        public Email2CaseTokenWrapper(){

        }
    }

    /**
    * sorts incoming emails by toAddress. used to save queries in processEmail2Case method.
    * calls processEmail2Case method
    *
    * @param map of email messages to process
    *      
    * @return void
    */
    public static void sortIncomingEmailsByToAddress(Map<Id,EmailMessage> mapEmails){
        Map<String,List<EmailMessage>> mapResult = new Map<String,List<EmailMessage>>();

        for(EmailMessage e : mapEmails.values()){
            if(!mapResult.containsKey(e.ToAddress)){
                mapResult.put(e.ToAddress, new List<EmailMessage>{e});
            }else{
                mapResult.get(e.ToAddress).add(e);
            }
        }




        processEmail2Case(mapResult);

    }


    /*public static void informHosEmail(List<TLB_Approval_Matrix__c> listApprovalEntries, String recordTypeDeveloperName, String whatId){
        List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
        Set<String> setUserEmailIds = new Set<String>();
        String notificationTemplate;
        String subject;
        Boolean informHOS = false;
        List<String> listUserEmailIds = new List<String>();

        Map<String,Business_Config__c> mapBusinessData;
        Map<String,Map<String,Business_Config__c>> mapProcessData= moam.get('QuoteApprovalProcess');

        if(mapProcessData != null && !mapProcessData.isEmpty()){
            mapBusinessData = mapProcessData.get(recordTypeDeveloperName);
        }
        if(mapBusinessData.get('InformHOSAboutRegionalHOSApproval')!=null &&  String.isNotBlank(mapBusinessData.get('InformHOSAboutRegionalHOSApproval').Business_Rule_Value__c)){
            informHOS = Boolean.valueOf(mapBusinessData.get('InformHOSAboutRegionalHOSApproval').Business_Rule_Value__c);
        }

        if(informHOS){
            for(TLB_Approval_Matrix__c approvalEntry : listApprovalEntries){
                if(approvalEntry.Notification__c == true && !setUserEmailIds.contains(approvalEntry.User_Email__c)){
                    setUserEmailIds.add(approvalEntry.User_Email__c);
                }
            }
            
            listUserEmailIds.addAll(setUserEmailIds);
            System.debug('$$$ listUserEmailIds: ' + listUserEmailIds);
            Opportunity_Quote__c oppQuote = [select Id_account__r.name,Id_Opportunity__r.Name from Opportunity_Quote__c where id=:whatId];
           if(mapBusinessData.get('InformHOSEmailTemplate')!=null &&  String.isNotBlank(mapBusinessData.get('InformHOSEmailTemplate').Business_Rule_Value__c)){
            notificationTemplate = mapBusinessData.get('InformHOSEmailTemplate').Business_Rule_Value__c;
            }
            if(mapBusinessData.get('InformHOSEmailSubject')!=null &&  String.isNotBlank(mapBusinessData.get('InformHOSEmailSubject').Business_Rule_Value__c)){
                if(mapBusinessData.get('InformHOSEmailSubject').Business_Rule_Value__c.indexOf('{AccountName}')>-1){
                    subject = mapBusinessData.get('InformHOSEmailSubject').Business_Rule_Value__c.replace('{AccountName}',oppQuote.Id_account__r.Name);
                }else{
                    subject = mapBusinessData.get('InformHOSEmailSubject').Business_Rule_Value__c;
                }
            }
            if(notificationTemplate != null){
                sendEmailWithVfTemplate(notificationTemplate,whatId,listUserEmailIds,subject);
                 
            } 
        }
    }*/
}