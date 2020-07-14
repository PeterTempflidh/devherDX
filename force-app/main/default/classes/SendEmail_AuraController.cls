public class SendEmail_AuraController {

    public class ConfigWrapper {

        public List<String> listOfEmails;
        public List<String> validFromEmails;
        public String emailTemplate;
        public String primaryContactEmail;
        public String emailSubject;
        public String objectAPIName;
        public String recordName;
        public Map<String, String> mandatoryAttachments; 
    }

    public class EmailDatapackWrapper {

        public List<String> email, emailsTo, emailsAdd, emailsCC, emailsBCC, attachmentIds;
        public String subject, message, recordId;
    }

    @AuraEnabled
    public static String processEmail(String emailDatapack){

        Map<String, Map<String, Map<String, Business_Config__c>>> moam = LibBusinessConfig.motherOfAllBusinessMaps;
        String sMessage='';
        EmailDatapackWrapper emailData = (EmailDatapackWrapper) JSON.deserialize(emailDatapack,EmailDatapackWrapper.class);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSaveAsActivity(true);
        List<String> toEmails = new List<String>();
        emailData.emailsTo = trimArrayMembers(emailData.emailsTo);
        emailData.emailsTo.addAll(trimArrayMembers(emailData.emailsAdd));
        mail.setToAddresses(emailData.emailsTo);
        mail.setCcAddresses(trimArrayMembers(emailData.emailsCC));
        mail.setBccAddresses(trimArrayMembers(emailData.emailsBCC));
        Opportunity_Quote__c opportunityQquote = OpportunityQuoteSelector.findQuotesbyIds(new Set<Id> {emailData.recordId})[0];
        Opportunity oppty = Opportunity_Selector.getSelected(new List<Id> {opportunityQquote.Id_Opportunity__c})[0];
        if (oppty!=null) {

             if (oppty.Probability <= 60) {
                 
                oppty.StageName = 'Quote Sent';
                oppty.Probability = 60;
                oppty.Email_Path__c = 'Classic';
                try {

                    update oppty;
                } catch (DMLException ex) {

                    return sMessage=ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getMessage()+'\n'+ex.getStackTraceString();
                }
            }
        }
        mail.setSubject(emailData.subject);
        mail.setReplyTo(Label.Email_to_Salesforce);
        mail.setWhatId(opportunityQquote.Id_Opportunity__c);
        // JIRA Binding refrence ids to the email's body
        mail.setHtmlBody(emailData.message + 
                         '<br/><span class="show" style="overflow:hidden; float:left; display:none !important;line-height:0px !important;padding:0 !important; max-height:0 !important;font-size:0 !important"><br />' +
                         '(REFQ: #' + opportunityQquote.Id_Opportunity__c + '.' + UserInfo.getUserId() + '#)</span><br/>');
        List<String> attachmentIds = new List<String>();
        for (String attId :emailData.attachmentIds) {

            if(attId.startsWith('068')) {

                attachmentIds.add(attId.split('-')[1]);
            } else {

                attachmentIds.add(attId);
            }
        }              
        List<Messaging.Emailfileattachment> attachments = getAttachmentsFromIds(attachmentIds);
        attachments.addAll(getAdditionalAttachments(opportunityQquote));
        mail.setFileAttachments(attachments);
        mail.setCharset('UTF-8'); 
        try {
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            sMessage = 'Success';
        } catch (Exception ex) {

            return sMessage=ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getMessage()+'\n'+ex.getStackTraceString();
        }
    
        return sMessage; 
    }

     @AuraEnabled
    public static String getConfigParams(String recordId) {

       ConfigWrapper configWrapper = new ConfigWrapper();
       List<String> listOfEmails = new List<String>();
       try {
            Opportunity_Quote__c opportunityQquote = OpportunityQuoteSelector.findQuotesbyIds(new Set<Id> {Id.valueOf(recordId)})[0];
            Map<String, Map<String, Map<String, Business_Config__c>>> moam = LibBusinessConfig.motherOfAllBusinessMaps;
            Map<String, Map<String, Business_Config__c>> emailDataMap = moam.get('EmailConfiguration');
            if (emailDataMap==null || !emailDataMap.containsKey(opportunityQquote.RecordType.DeveloperName)) {
            
                return 'missingBusinessConfig'; 
            }
            Map<String, Business_Config__c> emailRecordTypeDataMap = emailDataMap.get(opportunityQquote.RecordType.DeveloperName);
            Set<Id> conIds = new Set<Id>();

            // detection of primary contact
            List<Contact> primaryContact =  new List<Contact> {ContactSelector.getAccountOwnerInformation(opportunityQquote.Id_Account__c)};
            if (!primaryContact.isEmpty()) {

                configWrapper.primaryContactEmail = primaryContact[0].Email;
            } else {

                configWrapper.primaryContactEmail = '';
            }
            
            // creation of list with additional emails from contact records
            List<Contact> contactList = ContactSelector.getNonPrimaryContactListForAccount(opportunityQquote.Id_Account__c, configWrapper.primaryContactEmail); 
            for (Contact c : contactList) {

                if (c.Email != null) {

                    listOfEmails.add(c.Email);   
                }
            }
            configWrapper.listOfEmails = listOfEmails;

            // upload of email template using data from  Business_Config__c record 
            List<EmailTemplate> template;
            String templateName = '';
            if (opportunityQquote.Quote_Type__c == null) {

                configWrapper.emailTemplate = '';
            } else {
        
                Business_Config__c templateRule = emailRecordTypeDataMap.get(opportunityQquote.Quote_Type__c);
                if (templateRule!=null) {

                    templateName = String.valueOf(templateRule.get('Business_Rule_Value__c'));
                    if (templateName != null) {
                                    
                        EmailTemplate extractedTemplate = EmailTemplateSelector.getTemplateByDeveloperName(templateName);
                        if (extractedTemplate !=null) {

                            template = new List<EmailTemplate> {extractedTemplate};
                        }
                    }
                }                    
            }

            if(template == null) {
                configWrapper.emailTemplate = '';
            } else {
               
                configWrapper.emailTemplate = processEmailContent(template[0].HtmlValue, primaryContact[0], opportunityQquote);
            }
            String subject;                  
            Business_Config__c subjectRule = emailRecordTypeDataMap.get(templateName);
            if (subjectRule!=null) {
                        
                subject =  String.valueOf(subjectRule.get('Business_Rule_Value__c'));
            }            
            if (subject != null) {
                
                configWrapper.emailSubject = subject;
            } else {

                configWrapper.emailSubject = '';
            }
            //defines object API name, used for dynamic navigation, increases component's re-usability
            Id recordIdFormatted = Id.valueOf(recordId);
            configWrapper.objectAPIName = recordIdFormatted.getSObjectType().getDescribe().getName();

            //defines current record name
            configWrapper.recordName = opportunityQquote.Name;

            //defines mandatory attachments
            Map<String,String> mandatoryAttachments = new Map<String,String>(); 
            String pdfQuoteDocumentTitle = 'Contract - '+opportunityQquote.Name+'.pdf';
            List<ContentDocumentLink> cdLinkList = ContentVersion_Selector.getContentDocumnetLink(opportunityQquote.Id, pdfQuoteDocumentTitle);
            if (cdLinkList.size()>0) {
               	
                mandatoryAttachments.put(cdLinkList[0].ContentDocument.LatestPublishedVersionId+'-'+cdLinkList[0].ContentDocumentId, pdfQuoteDocumentTitle);
            }
            Map<String, String> oppTypeToDocumentDevName = new Map<String, String>();
                        
            Business_Config__c mapBusinessdata =  emailRecordTypeDataMap.get('defaultAttachmentPerOppBusinessType'+'-'+opportunityQquote.Id_Account__r.Record_Country__c);
            if (mapBusinessdata!=null) {
                for (String typeToDevName : mapBusinessdata.Business_Rule_Value__c.split(',')) {
                        oppTypeToDocumentDevName.put(typeToDevName.split('=')[0], typeToDevName.split('=')[1]);
                }

                String docDevName = oppTypeToDocumentDevName.get(opportunityQquote.Id_opportunity__r.Business_Type__c);
                if (String.isNotBlank(docDevName)) {
                            
                    Document doc = DocumentSelector.getDocumentByDeveloperName(docDevName);
                    mandatoryAttachments.put(doc.Id, doc.Name+'.pdf');
                }
            }
             
            configWrapper.mandatoryAttachments = mandatoryAttachments;

            // defines list of From emails
            List<String> validFromEmails = new List<String>();
            validFromEmails.add('"' + UserInfo.getName() + '" <' +  UserInfo.getUserEmail() + '>');
            for (OrgWideEmailAddress owa : OrgWideEmailAddressSelector.getOrgWideEmailAddresses()) {
                validFromEmails.add('"'+UserInfo.getOrganizationName() + '" <' +  owa.Address + '>');
            }
            configWrapper.validFromEmails = validFromEmails;
       } catch (Exception ex) {

           system.debug('Exception data: '+ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getMessage()+'\n'+ex.getStackTraceString());
           return JSON.serialize(configWrapper);
       }
       String resultJSON;
       try {
           resultJSON = JSON.serialize(configWrapper);
       } catch (JSONException ex) {

           system.debug('Exception data: '+ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getMessage()+'\n'+ex.getStackTraceString());
           configWrapper.mandatoryAttachments = new Map<String,String>();
           return JSON.serialize(configWrapper);
       }
        return resultJSON;

    }


    public static String processEmailContent(String emailContent, Contact primaryContact, Opportunity_Quote__c oppQuote)  {

        /*Adding functionality to retrieve country specific urls from business configs map*/
        Business_Config__c urlBC = LibBusinessConfig.getBusinessConfigFromRuleMap('EmailConfiguration',oppQuote.RecordTypeId,'EmailTemplateURL');
        /*Creating maps of the json structure received from the business rule value*/
        Map<String,String> urlMap = urlBC != null ? (Map<String, String>)JSON.deserialize(urlBC.business_rule_value__c,Map<String, String>.class) : null ;

        if (primaryContact != null) {
            /* Salutation can be null and thereby avoiding the 'null' string on UI*/
            String sal = primaryContact.Salutation == null ? '' : primaryContact.Salutation + ' ';
            emailContent = emailContent.replace('[Full Name]', sal +primaryContact.FirstName + ' ' +primaryContact.LastName);

            if(emailContent.contains('[Contact Owner First Name]')){
                emailContent = emailContent.replace('[Contact Owner First Name]', primaryContact.FirstName);
            }
        } else {
            emailContent = emailContent.replace('[Full Name]', '');
        }

        if (oppQuote.Id_Opportunity__r.Owner.FirstName != null) {
            emailContent = emailContent.replace('[Opportunity Owner First Name]', oppQuote.Id_Opportunity__r.Owner.FirstName);
        }
        if (oppQuote.Id_Opportunity__r.Owner.LastName != null) {
            emailContent = emailContent.replace('[Opportunity Owner Last Name]', oppQuote.Id_Opportunity__r.Owner.LastName);
        }
        if (oppQuote.Id_Opportunity__r.Owner.Email != null) {
            emailContent = emailContent.replace('[Opportunity Owner email]', oppQuote.Id_Opportunity__r.Owner.Email);
        } else {
            emailContent = emailContent.replace('[Opportunity Owner email]', '');
        }
        if (oppQuote.Id_Opportunity__r.Owner.Phone != null) {
            emailContent = emailContent.replace('[Opportunity Owner mobile]', oppQuote.Id_Opportunity__r.Owner.Phone);
        } else {
            emailContent = emailContent.replace('[Opportunity Owner mobile]', '');
        }
        //Updating url
        if(oppQuote.Id_Account__r.Record_Country__c != null && urlMap != null && urlMap.containsKey(oppQuote.Id_Account__r.Record_Country__c)){
            emailContent = emailContent.replace('[Opportunity URL]', urlMap.get(oppQuote.Id_Account__r.Record_Country__c));
        } else {
            emailContent = emailContent.replace('[Opportunity URL]', '');
        }
        if (oppQuote.Id_Account__r.Name != null) {
            emailContent = emailContent.replace('[Account Name]', oppQuote.Id_Account__r.Name);
        } else {
            emailContent = emailContent.replace('[Account Name]', '');
        }
        return emailContent;
    }

    public static List<String> trimArrayMembers(List<String> stringList) {

            List<String> resultList = new List<String>();
            for (String s : stringList) {

                s = s.trim();
                if (s!='') {

                   resultList.add(s); 
                }
            }
        return resultList;
    }

    public static List<Messaging.Emailfileattachment> getAttachmentsFromIds(List<String> idList) {

        List<Messaging.Emailfileattachment> attachments = new List<Messaging.Emailfileattachment>();
        Set<Id> docIdSet = new Set<Id>();
        Set<Id> contentDocumentIdSet = new Set<Id>(); 
        Map<Id, ContentDocument> contentDocMap = new Map<Id, ContentDocument>();
        List<ContentDocument> contentDocList = new List<ContentDocument>();
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        List<Document> docList = new List<Document>();
        try {

            for (String stringId : idList) {

                if (stringId.startsWith('069')) {

                contentDocumentIdSet.add(stringId); 
                } else {

                    docIdSet.add(stringId);
                }
            }
            // content versions
            if (contentDocumentIdSet.size()>0) {

                List<ContentDocumentLink> documentLinkList = ContentVersion_Selector.getContentDocumnetLinksWithLatestVersionBody(contentDocumentIdSet);
                for (ContentDocumentLink cd : documentLinkList) {

                    Messaging.Emailfileattachment newAttachment = new Messaging.Emailfileattachment();
                    newAttachment.setFileName(cd.ContentDocument.Title);
                    newAttachment.setContentType('application/pdf');
                    newAttachment.setBody(cd.ContentDocument.LatestPublishedVersion.VersionData);
                    attachments.add(newAttachment);
                }               
            }

            // Docs
            if (docIdSet.size()>0) {

                docList = DocumentSelector.getDocumentsByIds(docIdSet);
                for (Document doc : docList) {

                    Messaging.Emailfileattachment newAttachment = new Messaging.Emailfileattachment();
                    newAttachment.setFileName(doc.Name+'.pdf');
                    newAttachment.setContentType(doc.ContentType);
                    newAttachment.setBody(doc.Body);
                    attachments.add(newAttachment);
                }
            }
        } catch (Exception e) {

            return attachments;
        }
        return attachments;
    }

    @TestVisible
    private static List<Messaging.EmailFileAttachment> getAdditionalAttachments(Opportunity_Quote__c oppQuote) {
        Messaging.EmailFileAttachment attachmentTemp;
        List<Messaging.EmailFileAttachment> attachmentList = new List<Messaging.EmailFileAttachment>();
        Map<Id, Document> documentMap;
        Map<String, Set<String>> docDevNamePerOppTypeMap;
        Map<String, Business_Config__c> businessConfigMap;
        Map<String, Map<String, Map<String, Business_Config__c>>> moam = LibBusinessConfig.motherOfAllBusinessMaps;
        Map<String, Map<String, Business_Config__c>> emailConfigurationDataMap = moam.get('EmailConfiguration');

        if(emailConfigurationDataMap.containsKey(oppQuote.RecordType.DeveloperName)){
            businessConfigMap = emailConfigurationDataMap.get(oppQuote.RecordType.DeveloperName);

            if(businessConfigMap.containsKey('additionalAttachmentPerQuoteType')){
                docDevNamePerOppTypeMap = (Map<String, Set<String>>) JSON.deserialize(businessConfigMap.get('additionalAttachmentPerQuoteType').Business_Rule_Value__c, Map<String, Set<String>>.class);
            }

            if(docDevNamePerOppTypeMap != null && docDevNamePerOppTypeMap.containsKey(oppQuote.Quote_Type__c)){
                documentMap = DocumentSelector.getDocumentByDeveloperName(docDevNamePerOppTypeMap.get(oppQuote.Quote_Type__c));
            }

            if(documentMap != null){
                for(Document doc : documentMap.values()){
                    attachmentTemp = new Messaging.Emailfileattachment();
                    attachmentTemp.setFileName(doc.Name+'.pdf');
                    attachmentTemp.setContentType(doc.ContentType);
                    attachmentTemp.setBody(doc.Body);
    
                    attachmentList.add(attachmentTemp);
                }
            }
        }

        return attachmentList;
    }
}
