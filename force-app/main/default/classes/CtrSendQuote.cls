public class CtrSendQuote {
    public Opportunity_Quote__c oppQuote { get; set; }

    public List<Contact> allContacts { get; set; }

    /***/
    public List<Contact> primaryContact { get; set; }

    /** primary contact to be set on the To: field of the email. This is an primary opportunity contact role if it exist, or the primary account contact role if it exist and the primary opportunity contact role doesn't exist */
    public String primaryContactEmail { get; set; }

    /** A list of wrapped contacts, account and opportiunity contact roles */
    public Map<String, ContactWrapper> recipients { get; set; }

    /** */
    public List<String> emailAddresses { get; set; }

    public Boolean isSingleAdd { get; set; }
    /** The subject of the email */
    public String subject { get; set; }

    /** The body of the email */
    public String content { get; set; }

    /*+ List of additionalAttachments */
    public List<Attachment> additionalAttachments { get; set; }

    /* Holds a list of attachments to be attached to the created task */
    public transient List<Attachment> attachmentsToUpload { get; set; }

    /* List of additionalAttachments */
    public List<String> attachmentNames { get; set; }

    /** Possible number of recipients that can be added */
    //private static final Integer NUM_ADDITIONAL_RECIPIENTS_TO_ADD = 10;

    /* Number of default attachments */
    private static final Integer NUM_ATTACHMENTS_TO_ADD = 3;

    /** Show the entire send quiote email form or hide it if this value is true */
    public Boolean showSendQuote { get; set; }

    /** List of From  Addresses */
    public String fromAddress { get; set; }

    /** List of Additional Email Addresses */
    public String additionalTo { get; set; }

    /** List of CC Addresses */
    public String cc { get; set; }

    /** List of BBC  Addresses */
    public String bcc { get; set; }

    /** Business Process Data */
    public Map<String, Map<String, Business_Config__c>> mapProcessData { get; set; }

    public Map<String, Business_Config__c> mapBusinessdata {get; set;}

    /** Email drop down to choose the email address for the from field */
    public List<SelectOption> fromEmailAddresses { get; set; }

    /** */
    public String emailToAdd { get; set; }

    /** */
    //public String idOfContactToAdd { get; set; }

    /** this could be To, CC or BCC */
    public String whereToAddOrRemoveEmail { get; set; }

    /* */
    public transient List<Messaging.Emailfileattachment> emailAttachmentsToSend { get; set; }

    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;

    public Boolean attachQuotePdf {get; set;}
    public Boolean attachTCPdf {get; set;}
    public Boolean attachMenueFlyer {get; set;} //SP-761
    public Boolean useQuoteTemplateNameAsPdf {get; set;}

    public String onlinePaymentPDf {get; set;}
    private String emailContent;
    private String EmailTemplateURL{get; set;}
    public Boolean setOppToCollectingDocs {get; set;}
    //public Boolean MenuContract {get; set;}

    public Boolean newRestaurant { get; set; }

    public CtrSendQuote(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) {
            controller.addFields(new List<String> {'Id',
                    'Template_Name__c',
                    'Id_opportunity__r.type',
                    'Id_opportunity__r.Business_Type__c',
                    'Id_opportunity__r.Owner.FirstName',
                    'Id_opportunity__r.Owner.LastName',
                    'Id_opportunity__r.Id_tarif__r.name',
                    'Name',
                    'status__c',
                    'RecordtypeId',
                    'RecordType.DeveloperName',
                    'Id_opportunity__c',
                    'Id_opportunity__r.recordtypeId',
                    'Id_opportunity__r.Accountid',
                    'Id_Account__c',
                    'Id_Account__r.Main_Contact__c',
                    'description__c',
                    'Url_Key__c',
                    'Quote_Comment__c',
                    'Attachment__c',
                    'Non_Standard_Contract_Components__c',
                    'Id_Account__r.OwnerId',
                    'Id_Account__r.Name',
                    'Id_Account__r.Record_Country__c'
            });
        }
        oppQuote = (Opportunity_Quote__c)controller.getRecord();
        this.init();
    }

    private void init() {

        User currentUser = [select Name, UserRole.Name from User where id = :Userinfo.getUserId()];
        this.mapProcessData = moam.get('EmailConfiguration');

        if (this.mapProcessData != null) {
            this.mapBusinessdata = this.mapProcessData.get(this.oppQuote.RecordType.DeveloperName);
        }

        this.fromEmailAddresses = new List<SelectOption>();
        this.recipients = new Map<String, ContactWrapper>();
        this.content = '';

        this.retrieveMainContactOnAccount();
        this.retrieveAllContacts();
        this.addOrgWideEmailAddressesToFromAddresses();
        this.buildAttachmentList();

        this.isSingleAdd = true;
        this.attachmentNames = new List<String>();
        this.showSendQuote = true;
        this.attachQuotePdf = true;
        this.attachTCPdf = false;
        this.attachMenueFlyer = false;
        this.setOppToCollectingDocs = false;
        this.useQuoteTemplateNameAsPdf = false;
        this.newRestaurant = this.oppQuote.Non_Standard_Contract_Components__c == 'New Restaurant Info' ? true : false;

        // yogiyo specific logic
        if (oppQuote.RecordType.DeveloperName == 'Yogiyo_Opportunity_Quote' && oppQuote.Attachment__c != null) {
            if (oppQuote.Attachment__c == 'Quote') {
                this.attachQuotePdf = true;
                this.attachTCPdf = false;
            } else if (oppQuote.Attachment__c == 'T&C') {
                this.attachQuotePdf = false;
                this.attachTCPdf = true;
            }
        }

        // sweden logic
        if (oppQuote.RecordType.DeveloperName == 'SE_Opportunity_Quote' && oppQuote.Non_Standard_Contract_Components__c != null) {
            this.attachMenueFlyer = true;
        }

        if (this.mapBusinessdata == null || this.mapBusinessdata.isEmpty()) {
            return;
        }

        if (this.mapBusinessdata.containsKey('useQuoteTemplateNameAsPdf')) {
            useQuoteTemplateNameAsPdf = Boolean.valueOf(mapBusinessdata.get('useQuoteTemplateNameAsPdf').Business_Rule_Value__c);
        }

        if (this.mapBusinessdata.get('EmailSubject') != null) {
            this.Subject = this.mapBusinessdata.get('EmailSubject').Business_Rule_Value__c;
        }

        if (this.mapBusinessdata.get('sendEmailOppStage') != null) {
            this.setOppToCollectingDocs = Boolean.valueof(this.mapBusinessdata.get('sendEmailOppStage').Business_Rule_Value__c);
        }

        if (this.mapBusinessdata.get('OnlinePaymentPdf') != null && oppQuote.Non_Standard_Contract_Components__c != null) {
            if (oppQuote.Non_Standard_Contract_Components__c.contains('Online Payment Doc')) {
                onlinePaymentPDf = this.mapBusinessdata.get('OnlinePaymentPdf').Business_Rule_Value__c;
            }
        }

        if (!this.mapBusinessdata.containsKey('productTypeWithEmailContent')
                && !this.mapBusinessdata.containsKey('EmailTemplateMap')
                && !this.mapBusinessdata.containsKey('EmailTemplateMapPerType')) {
            return;
        }

        emailContent = null;
        if(this.mapBusinessdata.containsKey('productTypeWithEmailContent')){
            emailContent = fetchEmailContentFromVFPages();
        }
        else if(this.mapBusinessdata.containsKey('EmailTemplateMapPerType')){
            emailContent = fetchEmailContentFromEmailTemplatesPerType();
        }
        else{
            emailContent = fetchEmailContentFromEmailTemplates();
        }

        this.content = processEmailContent(emailContent,currentUser);
    }

    /**
    * @Description: this method fetches the email content from the VF page
    */
    public String fetchEmailContentFromVFPages(){
        Map<String, String> typeAndTemplateName = new Map<String, String>();
        Boolean isService 						= false;
        Boolean isProduct 						= false;
        Boolean isBladeSign 					= false;
        Boolean isPP 							= false;
        Boolean isDefault 						= false;
        Boolean isMenuP 						= false;

        for (String str : this.mapBusinessdata.get('productTypeWithEmailContent').Business_Rule_Value__c.split(',')) {
            List<String> finalStr = str.split('=');
            typeAndTemplateName.put(finalStr[0], finalStr[1]);
        }

        if ([select Opp_Origin__c from Opportunity where Id = : oppQuote.Id_opportunity__c].Opp_Origin__c == 'Fieldsales') {
            return renderVFTemplate(typeAndTemplateName.get('Fieldsales'));
        }

        for (Opportunity_Quote_Line_Item__c oppqline : [SELECT id, Line_Item_Type__c, Sub_type__c,
                Id_Opportunity_Quote__r.Id_opportunity__r.Business_Type__c
        FROM Opportunity_Quote_Line_Item__c
        WHERE Id_Opportunity_Quote__c = :oppQuote.Id]) {
            System.debug('product type: ' + oppqline.Sub_type__c);
            if (oppqline.Line_Item_Type__c == 'Service') {
                isService = true;
            } else if (oppqline.Sub_type__c == 'Blade Sign') {
                isBladeSign = true;
            } else if (oppqline.Sub_type__c == 'Premium Placement') {
                isPP = true;
                break;
            } else if (oppqline.Sub_type__c == 'Menu Printing') {
                isMenuP = true;
                break;
            } if (oppqline.Line_Item_Type__c == 'Product' && oppqline.Id_Opportunity_Quote__r.Id_opportunity__r.Business_Type__c == 'Upgrade/Upsell') {
                isProduct = true;
            } else {
                isDefault = true;
            }
        }

        if (oppquote.id_opportunity__r.type == 'Additional Contract') {
            emailContent = renderVFTemplate(typeAndTemplateName.get('Upgrade'));
        } else if (oppQuote.Id_Opportunity__r.type == 'Product Only' && typeAndTemplateName.containsKey('Product Only')) {
            emailContent = renderVFTemplate(typeAndTemplateName.get('Product Only'));
        } else if (isPP && typeAndTemplateName.get('Premium Placement') != null) {
            emailContent = renderVFTemplate(typeAndTemplateName.get('Premium Placement'));
        } else if (isMenuP && typeAndTemplateName.get('Menu Printing') != null) {
            emailContent = renderVFTemplate(typeAndTemplateName.get('Menu Printing'));
        } else if (isService && typeAndTemplateName.get('Default') != null) {
            emailContent = renderVFTemplate(typeAndTemplateName.get('Default'));
        } else if (isBladeSign && typeAndTemplateName.get('Blade Sign') != null) {
            emailContent = renderVFTemplate(typeAndTemplateName.get('Blade Sign'));
        } else if (isProduct && typeAndTemplateName.get('Upgrade') != null ) {
            emailContent = renderVFTemplate(typeAndTemplateName.get('Upgrade'));
        } else if (typeAndTemplateName.get('Upgrade') != null) {
            emailContent = renderVFTemplate(typeAndTemplateName.get('Upgrade'));
        } else if (typeAndTemplateName.get('Generic') != null) {
            // yogiyo and new logic for de
            emailContent = renderVFTemplate(typeAndTemplateName.get('Generic'));
        }

        return emailContent;
    }

    /**
    * @PKALINA: Created through Hungary Implementation
    * @Description: This method fetches the email tempalte content from the email template object dependent on Opportunity Type
    */
    public String fetchEmailContentFromEmailTemplatesPerType(){
        Map<String,String> templateMap
                = (Map<String, String>)JSON.deserialize(this.mapBusinessdata.get('EmailTemplateMapPerType').business_rule_value__c,Map<String, String>.class);

        String tempTemplate;
        tempTemplate = this.oppQuote.Id_opportunity__r.Type;

        String templateName;
        if(templateMap.containsKey(tempTemplate)){
            templateName = templateMap.get(tempTemplate);
        }

        if(templateName == null)
            return null;

        List<EmailTemplate> template = EmailTemplateSelector.getListTemplateByDeveloperName(templateName);

        if(template.size() == 0)
            return null;

        // set the subject
        this.subject = template[0].subject;

        return template[0].htmlValue != null ? template[0].htmlValue : template[0].Body;
    }

    /**
    * @Description: This method fetches the email tempalte content from the email template object
    */
    public String fetchEmailContentFromEmailTemplates(){
        Map<String,String> templateMap
                = (Map<String, String>)JSON.deserialize(this.mapBusinessdata.get('EmailTemplateMap').business_rule_value__c,Map<String, String>.class);

        String tempTemplate;
        if(this.oppQuote.Id_opportunity__r.Business_Type__c == 'New Business'
                || this.oppQuote.Id_opportunity__r.Business_Type__c == 'Win Back'
                || this.oppQuote.Id_opportunity__r.Business_Type__c == 'Owner Change'){
            tempTemplate = 'New Business';
        }else{
            if(this.oppQuote.Id_opportunity__r.Id_tarif__r.name == 'Premium Placement'){
                tempTemplate = 'Premium Placement';
            }else{
                tempTemplate = 'UpgradeUpsell';
            }
        }

        if(this.mapBusinessdata.ContainsKey('EmailTemplateMapwithCountry')&& Boolean.valueOf(this.mapBusinessdata.get('EmailTemplateMapwithCountry').Business_Rule_Value__c)){
            tempTemplate = tempTemplate+ '-'+ this.oppQuote.Id_Account__r.Record_Country__c;
            system.debug('templateName-->'+tempTemplate);
        }

        if(mapBusinessdata.containsKey('EmailTemplatePeyaURL')){
            Map<String,String> templateCountryMap =	(Map<String, String>)JSON.deserialize(mapBusinessdata.get('EmailTemplatePeyaURL').business_rule_value__c,Map<String, String>.class);
            if(templateCountryMap.containsKey(this.oppQuote.Id_Account__r.Record_Country__c)){
                this.EmailTemplateURL = templateCountryMap.get(this.oppQuote.Id_Account__r.Record_Country__c);
            }
        }

        String templateName;
        if(templateMap.containsKey(tempTemplate)){
            templateName = templateMap.get(tempTemplate);
        }



        if(templateName == null)
            return null;

        List<EmailTemplate> template = EmailTemplateSelector.getListTemplateByDeveloperName(templateName);

        if(template.size() == 0)
            return null;

        // set the subject
        this.subject = template[0].subject;

        return template[0].htmlValue;
    }

    public String processEmailContent(String emailContent,User currentUser){
        if (emailContent != null) {
            String manStr;
            if (!primaryContact.isEmpty() && primaryContact[0].Salutation != null) {
                manStr = emailContent.replace('{Salutation}', primaryContact[0].Salutation);
            } else {
                manStr = emailContent.replace('{Salutation}', '');
            }
            String replacedStr;
            if (!primaryContact.isEmpty() && primaryContact[0].LastName != null) {
                replacedStr = manStr.replace('{LastName}', primaryContact[0].LastName).replace('{SalesName}', currentUser.Name);
            } else {
                replacedStr = manStr.replace('{LastName}', '').replace('{SalesName}', currentUser.Name);
            }
            if (!primaryContact.isEmpty()  && primaryContact[0].FirstName != null) {
                replacedStr = replacedStr.replace('{FirstName}', primaryContact[0].FirstName);

                replacedStr = replacedStr.replace('{OpportunityOwnerContactFirstName}',
                        primaryContact[0].FirstName);
            } else {
                replacedStr = replacedStr.replace('{FirstName}', '');

                replacedStr = replacedStr.replace('{OpportunityOwnerContactFirstName}',
                        this.oppQuote.Id_Account__r.Name);
            }

            if (!primaryContact.isEmpty()  && primaryContact[0].Translated_Name__c != null) {
                replacedStr = replacedStr.replace('{translatedName}', primaryContact[0].Translated_Name__c);
            } else {
                replacedStr = replacedStr.replace('{translatedName}', '');
            }

            if (this.oppQuote.Id_Account__c != null  && this.oppQuote.Id_Account__r.Name != null) {
                replacedStr = replacedStr.replace('{AccountName}', this.oppQuote.Id_Account__r.Name );
            } else {
                replacedStr = replacedStr.replace('{AccountName}', '');
            }

            replacedStr = replacedStr.replace('{OpportunityOwnerName}',
                    this.oppQuote.Id_Opportunity__r.Owner.FirstName + ' ' + this.oppQuote.Id_Opportunity__r.Owner.LastName);

            replacedStr = replacedStr.replace('{OpportunityOwnerName2}',
                    this.oppQuote.Id_Opportunity__r.Owner.LastName + ' ' + this.oppQuote.Id_Opportunity__r.Owner.FirstName);

            if (currentUser.UserRole != null && currentUser.UserRole.Name != null) {
                replacedStr = replacedStr.replace('{SalesRole}', currentUser.UserRole.Name);
            } else {
                replacedStr = replacedStr.replace('{SalesRole}', '');
            }

            if (this.EmailTemplateURL != null) {
                replacedStr = replacedStr.replace('{PeyaURL}', this.EmailTemplateURL);
            } else {
                replacedStr = replacedStr.replace('{PeyaURL}', '');
            }

            replacedStr = replacedStr.replace('{OpportunityOwnerLastName}',
                    this.oppQuote.Id_Opportunity__r.Owner.LastName);

            return replacedStr;
        }

        return null;
    }

    public String renderVFTemplate(String vfTemplateName) {
        String vfcontent;
        String pageName = '/apex/' + vfTemplateName + '?id=' + this.oppQuote.Id;
        System.debug('pageName: ' + pageName);
        PageReference pf = new PageReference(pageName);
        if (!Test.isRunningTest()) {
            //pf.setRedirect(true);
            vfcontent = pf.getContent().toString();
        } else {
            vfcontent = 'Some Text content';
        }
        return vfcontent;
    }

    public void retrieveAllContacts() {
        allContacts = [SELECT Id, Email, Name, Translated_Name__c FROM Contact WHERE Account.Id = : oppQuote.Id_Account__c];
        if (!allContacts.isEmpty()) {
            for (Contact ct : allContacts) {
                if (ct.Email != null && ct.Email.length() != 0 && (primaryContactEmail == null || (primaryContactEmail != null && !primaryContactEmail.equals(ct.Email)))) {
                    this.recipients.put(ct.Email, new ContactWrapper(ct, 'contact', ct.Name, ct.Email));
                }
            }
        }
        List<AccountContactRelation> accCon = [select contactid, contact.email, contact.name from AccountContactRelation where accountid = :oppQuote.Id_Account__c and isactive = true order by createddate desc Limit 1];
        if (!accCon.isEmpty()) {
            for (AccountContactRelation ct : accCon) {
                if (ct.contact.Email != null && ct.contact.Email.length() != 0 && (primaryContactEmail == null || (primaryContactEmail != null && !primaryContactEmail.equals(ct.contact.Email)))) {
                    this.recipients.put(ct.contact.Email, new ContactWrapper(ct, 'contact', ct.contact.Name, ct.contact.Email));
                }
            }
        }
    }

    public void retrieveMainContactOnAccount() {
        if (this.mapBusinessdata != null && !this.mapBusinessdata.isEmpty()
                && this.mapBusinessdata.get('Use_Default_Content') != null
                && Boolean.valueOf(this.mapBusinessdata.get('Use_Default_Content').Business_Rule_Value__c)
                && this.oppQuote.Quote_Comment__c != null) {
            this.content = this.oppQuote.Quote_Comment__c;
        }

        primaryContact = [SELECT Id, Email, Salutation, LastName, FirstName, Translated_Name__c FROM Contact WHERE AccountId = :oppQuote.Id_Account__c AND Contact_Role__c = 'Owner' LIMIT 1];
        if (primaryContact.isEmpty()) {
            Set<id> conIds = new Set<Id>();
            for (AccountContactRelation  accCon : [select contactid, contact.email, contact.name from AccountContactRelation where accountid = :oppQuote.Id_Account__c and contact.contact_role__c='Owner' and isactive = true order by createddate desc Limit 1]) {
                conIds.add(accCon.contactid);
            }
            system.debug('**conIds' + conIds);
            primaryContact = [SELECT Id, Email, Salutation, LastName, FirstName, Translated_Name__c FROM Contact WHERE Contact_Role__c = 'Owner' and id in:conIds LIMIT 1];
        } if (!primaryContact.isEmpty()) {
            primaryContactEmail = primaryContact[0].Email;
        }
    }

    public void addOrgWideEmailAddressesToFromAddresses() {
        fromEmailAddresses.add(new SelectOption(Userinfo.getUserEmail(), ' "' + UserInfo.getName() + '" <' +  UserInfo.getUserEmail() + '>'));
        for (OrgWideEmailAddress owa : [select id, Address from OrgWideEmailAddress]) {
            fromEmailAddresses.add(new SelectOption(owa.Id, ' "' + UserInfo.getOrganizationName() + '" <' +  owa.Address + '>'));
        }
    }


    /**
    * collects all recipients (email addresses) that will receive this email inro a single list that will be passed into the setToAddresses method of Messaging.SingleEmailMessage
    *
    * @param
    * @return List<String> : list of email addresses
    */
    public void determineRecipients() {
        emailAddresses = new List<String>();
        Map<String, String> emailMap = new Map<String, String>();
        for (String mail : this.recipients.keySet()) {
            if (this.recipients.get(mail).isRecipient) {
                emailMap.put(this.recipients.get(mail).email, this.recipients.get(mail).email);
            }
        }

        if (this.primaryContactEmail != null) {
            emailMap.put(this.primaryContactEmail, this.primaryContactEmail);
        }

        for (String email : emailMap.keySet()) {
            emailAddresses.add(email);
        }

        if (this.additionalTo != null && this.additionalTo.length() != 0) {
            List<String> additionalTo = this.additionalTo.split(',');
            if (!additionalTo.isEmpty()) {
                emailAddresses.addAll(additionalTo);
            }
        }
        if (this.cc != null && this.cc.length() != 0) {
            List<String> cc = this.cc.split(',');
            if (!cc.isEmpty()) {
                emailAddresses.addAll(cc);
            }
        }
        if (this.bcc != null && this.bcc.length() != 0) {
            List<String> bcc = this.bcc.split(',');
            if (!bcc.isEmpty()) {
                emailAddresses.addAll(bcc);
            }
        }
    }

    /**
    * list of attachments to add
    *
    * @param
    * @return void
    */
    public void buildAttachmentList() {
        this.additionalAttachments = new List<Attachment>();
        //this.attachmentsToUpload = new List<Attachment>();

        for (Integer i = 0; i < NUM_ATTACHMENTS_TO_ADD; i++) {
            this.additionalAttachments.add(new Attachment());
        }
    }

    /**
    * extracts the attachments from the additional attachments list if any have been added (body != null). Also hold the attachments in a list. This list will be passed
    * and the attachments added to a completed task when creating the activity history.
    *
    * @param
    * @return void
    */
    @TestVisible
    private void extractAdditionalAttachments() {
        if (this.attachmentsToUpload == null) {
            this.attachmentsToUpload = new List<Attachment>();
        }
        // TODO: refactor below if conditions to use common method with a parameter to avoid code redundancy.
        if (this.mapBusinessdata.containsKey('defaultAttachmentPerOppBusinessType')) {
            // based on the opportunity business type we have a default attachment to add

            Map<String, String> oppTypeToDocumentDevName = new Map<String, String>();

            for (String typeToDevName : mapBusinessdata.get('defaultAttachmentPerOppBusinessType').Business_Rule_Value__c.split(',')) {
                oppTypeToDocumentDevName.put(typeToDevName.split('=')[0], typeToDevName.split('=')[1]);
            }

            String docDevName = oppTypeToDocumentDevName.get(this.oppQuote.Id_opportunity__r.Business_Type__c);
            if (String.isNotBlank(docDevName)) {
                // add attachment to list
                Document doc = AttachmentSelector.getDocumentByName(docDevName);
                this.additionalAttachments.add(new Attachment(
                        ContentType = doc.ContentType,
                        Name = doc.Name + '.pdf',
                        Body = doc.Body)
                );
            }
        }
        /* PKALINA: Created through Hungary Implementation
         * Based on the opportunity business type we have a default attachment to add additional attachment
         */
        if (this.mapBusinessdata.containsKey('additionalAttachmentPerOppBusinessType')) {
            Map<String, String> oppTypeToDocumentDevName = new Map<String, String>();
            for (String typeToDevName : mapBusinessdata.get('additionalAttachmentPerOppBusinessType').Business_Rule_Value__c.split(',')) {
                oppTypeToDocumentDevName.put(typeToDevName.split('=')[0], typeToDevName.split('=')[1]);
            }

            String docDevName = oppTypeToDocumentDevName.get(this.oppQuote.Id_opportunity__r.Business_Type__c);
            if (String.isNotBlank(docDevName)) {
                // add attachment to list
                Document doc = AttachmentSelector.getDocumentByName(docDevName);
                this.additionalAttachments.add(new Attachment(
                        ContentType = doc.ContentType,
                        Name = doc.Name + '.pdf',
                        Body = doc.Body)
                );
            }
        }

        /* PKALINA: Created through Hungary Implementation
         * Based on the opportunity type we have a default attachment
         */
        if (this.mapBusinessdata.containsKey('defaultAttachmentPerType')) {
            Map<String, String> oppTypeToDocumentDevName = new Map<String, String>();
            for (String typeToDevName : mapBusinessdata.get('defaultAttachmentPerType').Business_Rule_Value__c.split(',')) {
                oppTypeToDocumentDevName.put(typeToDevName.split('=')[0], typeToDevName.split('=')[1]);
            }

            String docDevName = oppTypeToDocumentDevName.get(this.oppQuote.Id_opportunity__r.Type);
            if (String.isNotBlank(docDevName)) {
                // add attachment to list
                Document doc = AttachmentSelector.getDocumentByName(docDevName);
                this.additionalAttachments.add(new Attachment(
                        ContentType = doc.ContentType,
                        Name = doc.Name + '.pdf',
                        Body = doc.Body)
                );
            }
        }

        /* PKALINA: Created through Hungary Implementation
         * Based on the opportunity type we have a additional attachment
         */
        if (this.mapBusinessdata.containsKey('additionalAttachmentPerType')) {
            Map<String, String> oppTypeToDocumentDevName = new Map<String, String>();
            for (String typeToDevName : mapBusinessdata.get('additionalAttachmentPerType').Business_Rule_Value__c.split(',')) {
                oppTypeToDocumentDevName.put(typeToDevName.split('=')[0], typeToDevName.split('=')[1]);
            }

            String docDevName = oppTypeToDocumentDevName.get(this.oppQuote.Id_opportunity__r.Type);
            if (String.isNotBlank(docDevName)) {
                // add attachment to list
                Document doc = AttachmentSelector.getDocumentByName(docDevName);
                this.additionalAttachments.add(new Attachment(
                        ContentType = doc.ContentType,
                        Name = doc.Name + '.pdf',
                        Body = doc.Body)
                );
            }
        }
        this.emailAttachmentsToSend = new List<Messaging.Emailfileattachment>();
        for (Attachment att : this.additionalAttachments) {
            if (att.Body != null) {
                this.attachmentNames.add(att.Name);
                attachmentsToUpload.add(att);
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setBody(att.Body);
                efa.setFileName(att.Name);
                efa.setContentType(att.ContentType);
                this.emailAttachmentsToSend.add(efa);
            }
        }
        this.buildAttachmentList();
    }

    public void buildEmailAttachments() {

        this.extractAdditionalAttachments();
        String companyName = LibBusinessConfig.determineCompany(this.oppQuote.RecordType.DeveloperName);

        Blob body;
        try {
            if (!Test.isRunningTest()) {
                if (attachTCPdf) {
                    StaticResource sr = [Select  s.Name, s.Id, s.Body From StaticResource s where s.Name = 'Yogiyo_T_C' limit 1]; // 'static_resource' is the name of the static resource PDF.
                    body =  sr.Body;
                } else if (useQuoteTemplateNameAsPdf) {
                    PageReference pdfQuote = new PageReference('/apex/' + this.oppQuote.Template_Name__c + '?id=' + this.oppQuote.Id + '&pdf=1');
                    body = pdfQuote.getContent();
                } else {
                    PageReference pdfQuote = new PageReference('/apex/RenderQuoteAsPDF?id=' + this.oppQuote.Id);
                    body = pdfQuote.getContent();
                }
            } else {
                body = Blob.valueOf('Running Test');
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Quote_Generate_Pdf_Error));
            System.debug('@@@@ The following error occured while generating the Quote pdf to attach to the quote email : ' + e.getMessage());
        }

        Messaging.Emailfileattachment attachment = new Messaging.Emailfileattachment();
        attachment.setContentType('application/pdf');
        attachment.setFileName(Label.Your_Quote);
        if (body != null) {
            attachment.setBody(body);
        } else {
            Blob bb = Blob.valueOf('');
            attachment.setBody(bb);
        }
        this.emailAttachmentsToSend.add(attachment);
        if (onlinePaymentPDf != null) {
            PageReference onlinePaymentPDf = new PageReference('/apex/TalabatPaymentPdf?id=' + this.oppQuote.Id);
            Blob b = onlinePaymentPDf.getContent();
            if (b != null) {
                Messaging.Emailfileattachment attachment2 = new Messaging.Emailfileattachment();
                attachment2.setContentType('application/pdf');
                attachment2.setFileName('Online Payment Method');
                attachment2.setInline(false);
                attachment2.setBody(b);
                this.emailAttachmentsToSend.add(attachment2);
            }
        }

        if (this.attachMenueFlyer) {
            List<String> fileNamesForQuery = new List<String>();

            for (String fileName : oppQuote.Non_Standard_Contract_Components__c.split(';')) {
                filename = 'SE_Quote_Addition_' + filename;

                fileNamesForQuery.add(fileName);
            }


            List<StaticResource> listFilesFromStaticRessource = new List<StaticResource>([SELECT Name, Id, Body FROM StaticResource WHERE Name IN: fileNamesForQuery]);

            for (StaticResource file : listFilesFromStaticRessource) {
                Messaging.EmailFileAttachment att = new Messaging.Emailfileattachment();
                att.setContentType('application/pdf');
                att.setFileName(file.Name);
                att.setInline(false);
                att.setBody(file.Body);

                this.emailAttachmentsToSend.add(att);
            }

        }

        if (this.newRestaurant) {
            List<String> fileNamesForQuery = new List<String>();

            for (String fileName : oppQuote.Non_Standard_Contract_Components__c.split(';')) {
                filename = 'FI_Quote_Addition_' + filename.replace(' ', '_');

                fileNamesForQuery.add(fileName);
            }


            List<StaticResource> listFilesFromStaticRessource = new List<StaticResource>([SELECT Name, Id, Body FROM StaticResource WHERE Name IN: fileNamesForQuery]);

            for (StaticResource file : listFilesFromStaticRessource) {
                Messaging.EmailFileAttachment att = new Messaging.Emailfileattachment();
                att.setContentType('application/pdf');
                att.setFileName(file.Name);
                att.setInline(false);
                att.setBody(file.Body);

                this.emailAttachmentsToSend.add(att);
            }
        }
    }

    /**
     * On 30/7/2018 I had to fix this method because of course it was completely wrong. @author marco.zeuli
     *
     * NOTE:
     * If you might ever think you are able to validate an email address I really advise you to go and take a look at this
     * video: https://www.youtube.com/watch?v=xxX81WmXjPg&ab_channel=FOSDEM
     *
     * After that, if you are still thinking of validating an email address, either you are a genius or more likely insane :P
     *
     * @param emailAddresses
     *
     * @return
     */
    public List<String> validateEmailAddress(List<String> emailAddresses) {
        List<String> wrongEmailAddresses = new List<String>();
        for (String email : emailAddresses) {
            if(String.isBlank(email) || !email.contains('@')) {
                wrongEmailAddresses.add(email);
            }
        }
        return wrongEmailAddresses;
    }

    /**
    * extracts the attachments from the additional attachments list if any have been added
    *
    * @param
    * @return void
    */
    public PageReference SendQuote() {
        System.debug('@@@@ calling SendQuote gggg - this.emailAddresses : ' + this.emailAddresses);
        try {
            buildEmailAttachments();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Quote_Email_Error_Retrieving_Attachments));
            System.debug('@@@@ calling SendQuote - The following error occurred while retrieving attachments : ' + e.getMessage());
            return null;
        }
        // Build list of email recipients
        this.determineRecipients();

        if (this.emailAddresses.isEmpty()) {
            ApexPages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, Label.Quote_Email_Error_No_Emails));
            return null;
        }

        System.debug('@@@@ calling SendQuote - this.emailAddresses : ' + this.emailAddresses);
        List<String> wrongEmailAddresses = this.validateEmailAddress(this.emailAddresses);
        if (!wrongEmailAddresses.isEmpty()) {
            String errorMsg;
            if (wrongEmailAddresses.size() > 1) {
                errorMsg = Label.Quote_Email_Wrong_Email_Address + ': <br /><ul>';
                for (String wem : wrongEmailAddresses) {
                    errorMsg += '<li> ' + wem + '</li>';
                }
                errorMsg += '</ul>';
            } else {
                errorMsg = Label.Quote_Email_Wrong_Email_Addresses + ': ' + wrongEmailAddresses[0];
            }

            Apexpages.Message msg = new Apexpages.Message(Apexpages.Severity.Error, errorMsg);
            Apexpages.addMessage(msg);
            return null;
        }

        if (this.subject == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Quote_Email_Error_Subject_Missing));
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSaveAsActivity(true);

        List<String> toEmails = new List<String>();
        //toEmails.add(Label.Email_to_Salesforce);
        if (this.primaryContactEmail != null) {
            toEmails.add(primaryContactEmail);
        }
        if (this.additionalTo != null && this.additionalTo.length() != 0) {
            List<String> additionalTo = this.additionalTo.split(',');
            toEmails.addAll(additionalTo);
        }

        mail.setToAddresses(toEmails);

        if (this.cc != null && this.cc.length() != 0) {
            List<String> cc = this.cc.split(',');
            mail.setCcAddresses(cc);
        }

        if (this.bcc != null && this.bcc.length() != 0) {
            List<String> bcc = this.bcc.split(',');
            mail.setBccAddresses(bcc);
        }

        List<String> checkFromAddress = this.validateEmailAddress(new List<String> {this.fromAddress});
        If(!checkFromAddress.isEmpty()) {
            mail.setOrgWideEmailAddressId(this.fromAddress);
        }

        mail.setSubject(this.subject);
        mail.setReplyTo(Label.Email_to_Salesforce);
        mail.setWhatId(this.oppQuote.Id_Opportunity__c);
        // JIRA Binding refrence ids to the email's body
        mail.setHtmlBody(this.content +
                '<br/><span class="show" style="overflow:hidden; float:left; display:none !important;line-height:0px !important;padding:0 !important; max-height:0 !important;font-size:0 !important"><br />' +
                '(REFQ: #' + this.oppQuote.Id_Opportunity__c + '.' + UserInfo.getUserId() + '#)</span><br/>');
        mail.setFileAttachments(this.emailAttachmentsToSend);
        mail.setCharset('UTF-8'); // for KR language, otherwise subject may not display correctly
        sendEmail(mail);
        return null;
    }

    public void sendEmail(Messaging.SingleEmailMessage mail) {
        try {
            // Send Email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

            String msg = Label.Email_Quote_Email_Sent_Successfully + ': <br /><ul>';
            for (String em : emailAddresses) {
                msg += '<li> ' + em + '</li>';
            }
            msg += '</ul>';


            if (this.attachmentNames != null) {
                if (!this.attachmentNames.isEmpty()) {
                    msg += Label.Quote_Email_Sent_Attachments + ': <ul>';
                    for (String attName : this.attachmentNames) {
                        msg += '<li>' + attName + '</li>';
                    }
                    msg += '</ul>';
                }
            }
            String msg_link = '';
            if (UserInfo.getUiThemeDisplayed() == 'Theme4t'  || UserInfo.getUiThemeDisplayed() == 'Theme4u' ) {
                msg_link = Label.Quote_Email_Click_To_Go_Back + ' <b><a href="" onclick="closeCurrentTab(); return false;"> ' + Label.Quote_Email_Opportunity + ' </a></b>';
            } else {
                msg_link = Label.Quote_Email_Click_To_Go_Back + ' <b><a href="" onclick="closeCurrentTab(); return false;"> ' + Label.Quote_Email_Quote + ' </a></b>';
            }

            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.INFO, msg + msg_link));
            this.showSendQuote = false;
            if (setOppToCollectingDocs)
                setOpportunityToQuoteSent();

        } catch (Exception e) {
            ApexPages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, Label.Quote_Email_Error_Sending_Quote));
            system.debug('@@@@ calling sendQuote - The following error occurred while sending the quote by email : ' + e.getMessage());
            System.debug('$$$ calling sendQuote - stack trace: ' + e.getStackTraceString());
        }
    }

    public void setOpportunityToQuoteSent() {
        if (oppQuote.Id_opportunity__c != null) {
            List<Opportunity> opp = [SELECT StageName, probability FROM Opportunity WHERE Id = :oppQuote.Id_opportunity__c LIMIT 1];
            if (opp.size() > 0) {
                if (opp[0].probability < 60) {
                    opp[0].StageName = 'Quote Sent';
                    opp[0].probability = 60;
                    update opp;
                }
            }
        }
    }

    public void addTo() {
        ContactWrapper cw = this.recipients.get(this.emailToAdd);
        if (this.whereToAddOrRemoveEmail.equals('to')) {
            if (this.additionalTo.length() != 0) {
                List<String> additionalToList = this.additionalTo.split(',');
                additionalToList.add(this.emailToAdd);
                this.additionalTo = String.join(additionalToList, ',');
            } else {
                this.additionalTo = this.emailToAdd;
            }
            cw.removeFromTo = false;
        } else if (this.whereToAddOrRemoveEmail.equals('cc')) {
            if (this.cc.length() != 0) {
                List<String> ccList =  this.cc.split(',');
                ccList.add(this.emailToAdd);
                this.cc = String.join(ccList, ',');
            } else {
                this.cc = this.emailToAdd;
            }
            cw.removeFromCc = false;
        } else if (this.whereToAddOrRemoveEmail.equals('bcc')) {
            if (this.bcc.length() != 0) {
                List<String> bccList =  this.bcc.split(',');
                bccList.add(this.emailToAdd);
                this.bcc = String.join(bccList, ',');
            } else {
                this.bcc = this.emailToAdd;
            }
            cw.removeFromBcc = false;
        }
        cw.addToTo = true;
        cw.addToCc = true;
        cw.addToBcc = true;
    }

    public void removeFrom() {
        ContactWrapper cw = this.recipients.get(this.emailToAdd);
        if (this.whereToAddOrRemoveEmail.equals('to')) {
            List<String> additionalToList = this.additionalTo.split(',');
            for (Integer i = 0; i < additionalToList.size(); i++) {
                if (additionalToList[i].equals(this.emailToAdd)) {
                    additionalToList.remove(i);
                }
            }
            this.additionalTo = String.join(additionalToList, ',');
            cw.removeFromTo = true;
        } else if (this.whereToAddOrRemoveEmail.equals('cc')) {
            List<String> ccList = this.cc.split(',');
            for (Integer i = 0; i < ccList.size(); i++) {
                if (ccList[i].equals(this.emailToAdd)) {
                    ccList.remove(i);
                }
            }
            this.cc = String.join(ccList, ',');
            cw.removeFromCc = true;
        } else if (this.whereToAddOrRemoveEmail.equals('bcc')) {
            List<String> bccList = this.bcc.split(',');
            for (Integer i = 0; i < bccList.size(); i++) {
                if (bccList[i].equals(this.emailToAdd)) {
                    bccList.remove(i);
                }
            }
            this.bcc = String.join(bccList, ',');
            cw.removeFromBcc = true;
        }
        cw.addToTo = false;
        cw.addToCc = false;
        cw.addToBcc = false;
    }

    public pagereference backMethod() {
        Pagereference pg =  new Pagereference('/apex/QuoteScreen?id=' + oppQuote.Id); // Include name of page where user should be navigated after clicking on Back button
        pg.setRedirect(true);
        return pg;
    }

    public class ContactWrapper {
        public String name { get; set; }
        public String role { get; set; }
        public String email { get; set; }
        public Boolean isRecipient { get; set; }
        public Boolean addToTo { get; set; }
        public Boolean addToCc { get; set; }
        public Boolean addToBcc { get; set; }
        public Boolean removeFromTo { get; set; }
        public Boolean removeFromCc { get; set; }
        public Boolean removeFromBcc { get; set; }


        public ContactWrapper(sObject contact, String objType, String contactName, String mail) {
            name = contactName;
            role = !objType.equals('contact') ? (contact.get('Role') != null ? (String)contact.get('Role') : '') : '';
            email = mail != null ? mail : '';
            isRecipient = false;
            addToTo = false;
            addToCc = false;
            addToBcc = false;
            removeFromTo = true;
            removeFromCc = true;
            removeFromBcc = true;
        }
    }
}