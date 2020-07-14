public with sharing class CtrLeadConversion {

    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    public Lead leadTobeConverted {Get; Set;}
    public Lead leadToConvert { get; set; }
    public Account tempAccount {Get; Set;}
    public Opportunity tempOpportunity {Get; Set;}
    public String convertedStatus {Get; Set;}
    public String opportunityName { get; set;}
    public String companyCode { get; set; }

    public Boolean newOpportunityMustBeNotCreated {Get; Set;}
    public Boolean newAccount {Get; Set;}
    public String addUserID {Get; Set;}
    public WrapperContact additionalContact {Get; Set;}
    public Map<String, WrapperContact> mapNewContactMap {Get; Set;}
    public Id convertedAccountId {get; set;}
    public String baseUrl {get; set;}
    public Id convertedQuoteId { get; set; }

    private Map<String, String> configMap {Get; Set;}
    public MAP<String, MAP<String, Business_Config__c>> mapBusinessLogic {Get; Set;}
    private Map<String, Business_Config__c> mapBusinessData { get; set; }

    public String leadCurrency { get; set; }

    private List<String> listFieldsToDisplay { get; set;}
    private List<String> listFieldsToQuery { get; set;}
    private List<String> listFieldsLeadInformation { get; set;}
    private List<String> listFieldsAccountInformation { get; set;}
    private List<String> listFieldsContactInformation { get; set;}
    private List<String> mandatoryFields { get; set;}
    public Boolean showConversionPage { get; set; }
    private List<String> listFieldsNonContracted;
    private  Boolean nonContracted;

    public String contactToRemove { get; set; }
    public String createdAcctId { get; set; }
    public Boolean showOnlyErrorMessage { get; set; }
    public String redirectURL {get; set;}
    private set<String> setMandatoryFields {get; set;}
    private List<String> defaultStageProbability;
    public String mobileReturnUrl {get; set;}
    private String countryCode;

    //transient Component.Apex.Outputpanel dynamicPanel;
    public Lead leadForTest {get; set;}
    private Boolean enabledTerritory;
    private String territoryOppOwner;
    private String territoryAccOwner;
    private String oppBusinessType;
    private Boolean restrictCityValues;
    private List<String> leadToQuoteStage;

    public List<SelectOption> contactRoleOptions {
        get {
            List<SelectOption> res = new List<SelectOption>{
                new SelectOption('', '-- None --')
            };

            for (Schema.PicklistEntry val : Contact.Contact_Role__c.getDescribe().getPicklistValues()) {
                if (val.getValue() != 'Owner' && val.isActive()) {
                    res.add(new SelectOption(val.getValue(), val.getLabel()));
                }
            }
            return res;
        }
    }

    // this contact is used only to display some readonly fields on the page, it's not updated or created
    public Contact dummyContact {get; set;}

    public CtrLeadConversion(Apexpages.StandardController sdtController) {
        if (!Test.isRunningTest()) {
            sdtController.addFields(new List<String> {'Id', 'RecordType.DeveloperName', 'CurrencyIsoCode', 'Company_Code__c', 'Record_Country__c', 'Vertical__c', 'Vertical_Segment__c'});
        }
        redirectURL = URL.getSalesforceBaseUrl().toExternalForm();
        this.leadToConvert = (Lead)sdtController.getRecord();
        this.tempAccount = new Account();
        this.tempAccount.OwnerId = UserInfo.getUserId();
        this.newOpportunityMustBeNotCreated = false;
        this.mapNewContactMap = new Map<String, WrapperContact>();
        this.showOnlyErrorMessage = false;
        this.companyCode = this.leadToConvert.Company_Code__c;
        this.enabledTerritory = false;

        for (Country__c c : [select Iso__c From Country__c Where Name = : leadToConvert.Record_Country__c]) {
            this.countryCode = c.Iso__c;
        }

        //mapBusinessData = LibBusinessConfig.getGenericProcessData('Lead Conversion').get(this.companyCode + '_Lead');
        mapBusinessData = moam.get('Lead Conversion').get(this.companyCode + '_Lead');

        boolean existVertical = mapBusinessData.containsKey('ValidateVertical') ? Boolean.valueOf(mapBusinessData.get('ValidateVertical').Business_Rule_Value__c) : false;

        if(existVertical && (this.leadToConvert.Vertical__c == null || this.leadToConvert.Vertical_Segment__c == null)){
            this.showOnlyErrorMessage = true;
        }

        Boolean isBusinessConfigDataCorrect = checkIfBusinessConfigsAreAvailable();
        if (!isBusinessConfigDataCorrect) {
            Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.Warning, 'Fieldstoquery is empty'));
        } else {
            try {
                this.leadTobeConverted = this.queryLead(listFieldsToQuery);
                if(this.leadTobeConverted.Street != null) {
                    this.leadTobeConverted.Street = this.leadTobeConverted.Street.replace('\r\n', ' ');
                    this.leadTobeConverted.Street = this.leadTobeConverted.Street.replace('\n', ' ');
                    this.leadTobeConverted.Street = this.leadTobeConverted.Street.replace('\r', ' ');
                }
                if (this.leadToConvert.RecordType.DeveloperName.equals('Yogiyo_Lead')) {
                    leadTobeConverted.OwnerId = UserInfo.getUserId();
                }
                this.tempAccount.Name = this.leadTobeConverted.Company;
            } catch (Exception e) {
                ApexPages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, Label.Lead_Conversion_Error_While_Retrieving_Lead));
                system.debug('@@@@ The following error occurred while retrieving the lead to be converted : ' + e.getMessage());
            }

        }

    }

    public Pagereference mobileActionConvert() {
        Pagereference p;
        // Prevents opp update from activity when activities are transfered to opp from leads
        ClsOpportunityProcessor.disableOppUpdateFromActivity = true;
        List<String> result = ClsLeadProcessor.processLeadConversion(leadToConvert.id, leadToConvert.Company_Code__c, false);
        String oppQuoteId = ClsLeadProcessor.createOppQuote();
        if (!result.isEmpty()) {
            System.debug('result: ' + result);
            if (result[0] == 'success') {
                if (result[1] == 'showConversionPage') {
                    p = new Pagereference('/apex/LeadConversion?id=' + leadToConvert.id);
                    return p;
                } else if (oppQuoteId != null) {
                    mobileReturnUrl = oppQuoteId;
                    p = new Pagereference('/' + oppQuoteId);
                    return p;
                } else {
                    mobileReturnUrl = result[1];
                    p = new Pagereference('/' + result[1]);
                    return p;
                }

            } else {
                ApexPages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, result[1]));
                return null;
            }
        }
        return null;
    }

    private Boolean checkIfBusinessConfigsAreAvailable() {
        if (this.mapBusinessData != null && !this.mapBusinessData.isEmpty()) {
            List<String> listOfFields = new List<String>();
            listOfFields = mapBusinessData.get('FieldsToQuery') != null ? mapBusinessData.get('FieldsToQuery').Business_Rule_Value__c.split(',') : new List<String>();
            listFieldsLeadInformation = mapBusinessData.get('LeadInformationFieldsToDisplay') != null ? mapBusinessData.get('LeadInformationFieldsToDisplay').Business_Rule_Value__c.split(',') : new List<String>();
            listFieldsAccountInformation = mapBusinessData.get('AccountInformationFieldsToDisplay') != null ? mapBusinessData.get('AccountInformationFieldsToDisplay').Business_Rule_Value__c.split(',') : new List<String>();
            listFieldsContactInformation = mapBusinessData.get('ContactInformationFieldsToDisplay') != null ? mapBusinessData.get('ContactInformationFieldsToDisplay').Business_Rule_Value__c.split(',') : new List<String>();
            mandatoryFields = mapBusinessData.get('MandatoryFields') != null ? mapBusinessData.get('MandatoryFields').Business_Rule_Value__c.split(',') : new List<String>();
            nonContracted = mapBusinessData.get('nonContractedFlag') != null ? Boolean.valueOf(mapBusinessData.get('nonContractedFlag').Business_Rule_Value__c) : null;
            listFieldsNonContracted = mapBusinessData.get('MandatoryFieldsNonContracted') != null ? mapBusinessData.get('MandatoryFieldsNonContracted').Business_Rule_Value__c.split(',') : new List<String>();
            defaultStageProbability = mapBusinessData.get('DefaultStageProbability') != null ? mapBusinessData.get('DefaultStageProbability').Business_Rule_Value__c.split(',') : new List<String>();
            this.enabledTerritory = mapBusinessData.get('EnableTerritory') != null ? Boolean.valueOf(mapBusinessData.get('EnableTerritory').Business_Rule_Value__c) : false;
            this.oppBusinessType = mapBusinessData.get('OppBusinessType') != null ? mapBusinessData.get('OppBusinessType').Business_Rule_Value__c : null;
            leadToQuoteStage = mapBusinessData.get('LeadToQuoteOppStage') != null ? mapBusinessData.get('LeadToQuoteOppStage').Business_Rule_Value__c.split(',') : new List<String>();
            restrictCityValues = mapBusinessData.containsKey('RestrictCityValues') ? Boolean.valueOf(mapBusinessData.get('RestrictCityValues').Business_Rule_Value__c) : false;

            setMandatoryFields = new Set<String>();
            setMandatoryFields.addAll(mandatoryFields);
            Set<String> allFieldsToQuerySet = new Set<String>();
            allFieldsToQuerySet.addAll(convertToLowerCase(listOfFields));
            allFieldsToQuerySet.addAll(convertToLowerCase(listFieldsLeadInformation));
            allFieldsToQuerySet.addAll(convertToLowerCase(listFieldsAccountInformation));
            allFieldsToQuerySet.addAll(convertToLowerCase(listFieldsContactInformation));
            allFieldsToQuerySet.addAll(convertToLowerCase(mandatoryFields));
            allFieldsToQuerySet.addAll(convertToLowerCase(listFieldsNonContracted));
            listFieldsToQuery = new List<String>();
            listFieldsToQuery.addAll(allFieldsToQuerySet);

            return true;
        }
        return false;
    }

    private List<String> convertToLowerCase(List<String> fields) {
        List<String> lowerCaseFields = new List<String>();
        for (String str : fields) {
            lowerCaseFields.add(str.toLowerCase());
        }
        return lowerCaseFields;
    }

    private Lead queryLead(List<String> listOfFields) {
        String theId = this.leadToConvert.Id;
        String query = 'SELECT Non_Contracted__c,Commission__c,Order_date__c,Tariff_Name__c,' + String.join(listOfFields, ',') + ' FROM Lead WHERE Id =:theId';
        Sobject obj = Database.query(query);
        return (Lead)obj;

    }

    public Component.apex.Outputpanel getDynamicPanelPage(){
        Component.Apex.Outputpanel dynamicPanel = new Component.Apex.Outputpanel();
        Component.Apex.PageBlock thePageBlock = new Component.Apex.PageBlock();

        Component.Apex.PageBlockSection thePageBlockSectionLeadInformation = new Component.Apex.PageBlockSection();
        thePageBlockSectionLeadInformation.title = '1 Lead information';
        if (leadTobeConverted.Non_Contracted__c && nonContracted != null && nonContracted && !listFieldsNonContracted.isEmpty()) {
            thePageBlockSectionLeadInformation.Columns = 2;
        } else {
            thePageBlockSectionLeadInformation.Columns = 1;
        }

        for (String field : this.listFieldsLeadInformation) {

            Component.Apex.InputField theInputField = new Component.Apex.InputField();
            theInputField.expressions.value = '{!leadTobeConverted.' + field + '}';
            if (field == 'OwnerId') {
                theInputField.Styleclass = 'testcc';
            }
            theInputField.Id = 'leadField' + field;

            thePageBlockSectionLeadInformation.childComponents.add(theInputField);
        }
        if (leadTobeConverted.Non_Contracted__c && nonContracted != null && nonContracted && !listFieldsNonContracted.isEmpty()) {
            for (String field : this.listFieldsNonContracted) {
                Component.Apex.InputField theInputField = new Component.Apex.InputField();
                theInputField.expressions.value = '{!leadTobeConverted.' + field + '}';
                theInputField.Id = 'leadField' + field;
                theInputField.required = true;
                thePageBlockSectionLeadInformation.childComponents.add(theInputField);

            }
        }

        thePageBlock.childComponents.add(thePageBlockSectionLeadInformation);

        Component.Apex.PageBlockSection thePageBlockSectionAccountInformation = new Component.Apex.PageBlockSection();
        thePageBlockSectionAccountInformation.title = '2 Account Information';
        thePageBlockSectionAccountInformation.columns = 2;

        Component.Apex.InputField theOwnerIdInputField = new Component.Apex.InputField();
        theOwnerIdInputField.expressions.value = '{!tempAccount.OwnerId}';
        thePageBlockSectionAccountInformation.childComponents.add(theOwnerIdInputField);

        Component.Apex.InputField theAccountNameInputfield = new Component.Apex.InputField();
        theAccountNameInputfield.expressions.value = '{!tempAccount.Name}';
        thePageBlockSectionAccountInformation.childComponents.add(theAccountNameInputfield);

        for (String field : this.listFieldsAccountInformation) {

            // checks if has to restrict city field values
            if (restrictCityValues && field == 'City') {
                Component.Apex.PageBlockSectionItem item = new Component.Apex.PageBlockSectionItem();

                Component.Apex.OutputLabel label = new Component.Apex.OutputLabel();
                label.expressions.value = '{!$ObjectType.Lead.fields.City.Label}';
                label.expressions.for = '{!$Component.cityCmp}';

                Component.CDSelectCityComponent cmp = new Component.CDSelectCityComponent(
                    id = 'cityCmp',
                    countryCode = this.countryCode,
                    initialValue = String.isNotBlank(leadTobeConverted.City) ? leadTobeConverted.City : '',
                    includeVue = true,
                    displayCityLabel = false,
                    visualforceStyle = true
                );
                cmp.expressions.assignTo = '{!leadTobeConverted.City}';

                item.childComponents.add(label);
                item.childComponents.add(cmp);

                thePageBlockSectionAccountInformation.childComponents.add(item);
            } else {
                Component.Apex.InputField theInputField = new Component.Apex.InputField();
                theInputField.expressions.value = '{!leadTobeConverted.' + field + '}';
                system.debug(setMandatoryFields );
                system.debug(field);
                if (setMandatoryFields != null && setMandatoryFields.contains(field)) {
                    theInputField.required = true;
                }
                if (field == 'type__c') {
                    theInputField.onchange = 'doNotCreateOpps(this)';
                }
                thePageBlockSectionAccountInformation.childComponents.add(theInputField);
            }
        }
        thePageBlock.childComponents.add(thePageBlockSectionAccountInformation);

        Component.Apex.PageBlockSection thePageBlockSectionContactInformation = new Component.Apex.PageBlockSection();
        thePageBlockSectionContactInformation.title = '3 Contact Information';
        thePageBlockSectionContactInformation.columns = 1;

        for (String field : this.listFieldsContactInformation) {
            Component.Apex.InputField theInputField = new Component.Apex.InputField();
            theInputField.expressions.value = '{!leadTobeConverted.' + field + '}';
            if (setMandatoryFields != null && setMandatoryFields.contains(field)) {
                theInputField.required = true;
            }
            thePageBlockSectionContactInformation.childComponents.add(theInputField);
        }

        dummyContact = new Contact(Contact_Role__c = 'Owner');
        Component.Apex.OutputField roleField = new Component.Apex.OutputField();
        roleField.expressions.value = '{!dummyContact.Contact_Role__c}';
        thePageBlockSectionContactInformation.childComponents.add(roleField);

        thePageBlock.childComponents.add(thePageBlockSectionContactInformation);

        Component.Apex.Outputpanel theOutputPanelAddContact = new Component.Apex.Outputpanel();

        Component.Apex.CommandButton addContactButton = new Component.Apex.CommandButton();
        addContactButton.value = 'Additional Contact';
        addContactButton.onclick = 'addAdditionalContact(); return false;';
        addContactButton.styleClass = 'removeButton';
        addContactButton.style = 'margin-top:20px; margin-bottom:10px;';

        theOutputPanelAddContact.childComponents.add(addContactButton);
        thePageBlockSectionContactInformation.childComponents.add(theOutputPanelAddContact);

        thePageBlock.childComponents.add(thePageBlockSectionContactInformation);


        Component.Apex.Outputpanel theOutputPanelAdditionalContactsTable = new Component.Apex.Outputpanel();
        theOutputPanelAdditionalContactsTable.Id = 'theAdditionalContacts';

        Component.Apex.PageBlockTable thePageBlockTable = new Component.Apex.PageBlockTable();
        thePageBlockTable.expressions.value = '{!mapNewContactMap}';
        thePageBlockTable.var = 'newContact';
        thePageBlockTable.id = 'additionalContacts';

        Component.Apex.Column colRemoveContract = new Component.Apex.Column();
        Component.Apex.CommandButton removeContactButton = new Component.Apex.CommandButton();
        removeContactButton.value = ' - ';
        removeContactButton.expressions.onclick = 'removeAdditionalContact({!mapNewContactMap[newContact].tempKey});return false;';

        colRemoveContract.childComponents.add(removeContactButton);
        thePageBlockTable.childComponents.add(colRemoveContract);

        Component.Apex.Column colSalutation = new Component.Apex.Column();
        colSalutation.headerValue = 'Salutation';
        Component.Apex.InputText inputSalutation = new Component.Apex.InputText();
        inputSalutation.expressions.value = '{!mapNewContactMap[newContact].salutation}';

        colSalutation.childComponents.add(inputSalutation);
        thePageBlockTable.childComponents.add(colSalutation);

        Component.Apex.Column colFirstname = new Component.Apex.Column();
        colFirstname.headerValue = 'Firstname';
        Component.Apex.InputText inputFirstname = new Component.Apex.InputText();
        inputFirstname.expressions.value = '{!mapNewContactMap[newContact].firstname}';

        colFirstname.childComponents.add(inputFirstname);
        thePageBlockTable.childComponents.add(colFirstname);

        Component.Apex.Column colLastname = new Component.Apex.Column();
        colLastname.headerValue = 'Lastname';
        Component.Apex.InputText inputLastname = new Component.Apex.InputText();
        inputLastname.expressions.value = '{!mapNewContactMap[newContact].lastname}';

        colLastname.childComponents.add(inputLastname);
        thePageBlockTable.childComponents.add(colLastname);

        Component.Apex.Column colMobile = new Component.Apex.Column();
        colMobile.headerValue = 'Mobile';
        Component.Apex.InputText inputMobile = new Component.Apex.InputText();
        inputMobile.expressions.value = '{!mapNewContactMap[newContact].mobile}';

        colMobile.childComponents.add(inputMobile);
        thePageBlockTable.childComponents.add(colMobile);

        Component.Apex.Column colEmail = new Component.Apex.Column();
        colEmail.headerValue = 'Email';
        Component.Apex.InputText inputEmail = new Component.Apex.InputText();
        inputEmail.expressions.value = '{!mapNewContactMap[newContact].email}';

        colEmail.childComponents.add(inputEmail);
        thePageBlockTable.childComponents.add(colEmail);

        Component.Apex.Column colRole = new Component.Apex.Column();
        colRole.headerValue = 'Role';
        Component.Apex.SelectList inputRole = new Component.Apex.SelectList();
        inputRole.multiselect = false;
        inputRole.size = 1;
        inputRole.expressions.value = '{!mapNewContactMap[newContact].contactRole}';

        // add option to list
        for (Schema.PicklistEntry val : Contact.Contact_Role__c.getDescribe().getPicklistValues()) {
            if (val.getValue() != 'Owner' && val.isActive()) {
                Component.Apex.SelectOption opt = new Component.Apex.SelectOption();
                opt.itemlabel = val.getLabel();
                opt.itemvalue = val.getValue();
                inputRole.childComponents.add(opt);
            }
        }
        Component.Apex.SelectOption emptyOpt = new Component.Apex.SelectOption();
        emptyOpt.itemlabel = '--- None ---';
        emptyOpt.itemvalue = '';
        inputRole.childComponents.add(0, emptyOpt);

        colRole.childComponents.add(inputRole);
        thePageBlockTable.childComponents.add(colRole);

        theOutputPanelAdditionalContactsTable.childComponents.add(thePageBlockTable);

        thePageBlock.childComponents.add(theOutputPanelAdditionalContactsTable);

        Component.Apex.PageBlockSection thePageBlockSectionOpportunity = new Component.Apex.PageBlockSection();
        thePageBlockSectionOpportunity.title = '4 Opportunity';
        thePageBlockSectionOpportunity.columns = 2;

        Component.Apex.OutputLabel createOppLabel = new Component.Apex.OutputLabel();
        createOppLabel.value = Label.Lead_Conversion_No_Opportunity + ' :';
        //createOppLabel.style='width:20%;';
        thePageBlockSectionOpportunity.childComponents.add(createOppLabel);

        if(mapBusinessData.containsKey('invertDefaultOportunityCreation') && Boolean.valueOf(mapBusinessData.get('invertDefaultOportunityCreation').Business_Rule_Value__c)){
            newOpportunityMustBeNotCreated = !newOpportunityMustBeNotCreated;
        }

        Component.Apex.InputCheckbox creatOppCheckbox = new Component.Apex.InputCheckbox();
        creatOppCheckbox.expressions.value = '{!newOpportunityMustBeNotCreated}';
        creatOppCheckbox.id = 'creatOppCheckbox';
        thePageBlockSectionOpportunity.childComponents.add(creatOppCheckbox);

        Component.Apex.OutputLabel oppNameLabel = new Component.Apex.OutputLabel();
        oppNameLabel.value = Label.Lead_Conversion_Opportunity_Name + ' : ';
        //oppNameLabel.style='width:20%;';
        thePageBlockSectionOpportunity.childComponents.add(oppNameLabel);

        Component.Apex.InputText inputOppname = new Component.Apex.InputText();
        inputOppname.expressions.value = '{!opportunityName}';
        thePageBlockSectionOpportunity.childComponents.add(inputOppname);

        thePageBlock.childComponents.add(thePageBlockSectionOpportunity);

        dynamicPanel.childComponents.add(thePageBlock);
        return dynamicPanel;
    }

    public void addNewContact() {
        system.debug('@@@@ calling addNewContact ');
        WrapperContact wc = new WrapperContact(new Contact(CurrencyIsoCode = this.leadCurrency));
        wc.tempKey = String.valueof(Math.random());
        this.mapNewContactMap.put(wc.tempKey, wc);
    }
    public void removeContactFromList() {
        if (contactToRemove != null && this.mapNewContactMap.get(contactToRemove) != null) {
            this.mapNewContactMap.remove(contactToRemove);
        }
    }

    public Pagereference cancel() {
        return new Pagereference('/' + this.leadToConvert.Id);
    }

    public Pagereference convertLead() {
        System.debug('CtrLeadConversion.convertLead: start');
        // Prevents opp update from activity when activities are transfered to opp from leads
        ClsOpportunityProcessor.disableOppUpdateFromActivity = true;
        Lead leadTobeConvertedBackup = leadTobeConverted.clone(true, true, false, true);
        System.Savepoint sp = Database.setSavepoint();

        if (string.IsBlank(this.tempAccount.Name)) {
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Warning, 'Company name is always mandatory'));
            System.debug('CtrLeadConversion.convertLead: new account name is blank');
            return null;
        }

        try {

            System.debug('CtrLeadConversion.convertLead: updating the lead');

            update this.leadTobeConverted;

            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(this.leadTobeConverted.id);

            if(mapBusinessData.containsKey('invertDefaultOportunityCreation') && Boolean.valueOf(mapBusinessData.get('invertDefaultOportunityCreation').Business_Rule_Value__c)){
                newOpportunityMustBeNotCreated = !newOpportunityMustBeNotCreated;
            }
            
            lc.setDoNotCreateOpportunity(newOpportunityMustBeNotCreated);

            if (!newOpportunityMustBeNotCreated && String.isNotBlank(opportunityName)) {
                lc.setOpportunityName(opportunityName);
            }

            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);

            System.debug('CtrLeadConversion.convertLead: converting...');


            Database.LeadConvertResult lcr = Database.convertLead(lc);


            System.debug('CtrLeadConversion.convertLead: converted');

            Id newContactId = lcr.getContactId();
            Id newAccountId = lcr.getAccountId();
            Id newOpportunityId = lcr.getOpportunityId();

            this.createdAcctId = newAccountId;

            System.debug('CtrLeadConversion.convertLead: updating newly created account');


            this.updateNewAccount(newAccountId, this.leadTobeConverted.id);

            System.debug('CtrLeadConversion.convertLead: new account updated, updating new contact and additional contacts');

            if (newContactId != null) {
                this.updateNewContacts(newContactId, newAccountId);
            }

            System.debug('CtrLeadConversion.convertLead: new contact updated');

            if (newOpportunityId != null) {

                System.debug('CtrLeadConversion.convertLead: updating the opportunity');

                Opportunity updateOpp = new Opportunity(Id = newOpportunityId);
                updateOpp.Recordtypeid = LibRecordTypeHelper.getRecordTypeValue(this.companyCode + '_Opportunity');
                Map<String, String> oppStageAndProbability = new Map<String, String>();

                if (!defaultStageProbability.isEmpty()) {
                    for (String str : defaultStageProbability) {
                        List<String> fields = str.split('=');
                        oppStageAndProbability.put(fields[0], fields[1]);
                    }

                    if (oppStageAndProbability.get('StageName') != null) {
                        updateOpp.StageName = oppStageAndProbability.get('StageName');
                        if (oppStageAndProbability.get('Probability') != null) {
                            updateOpp.Probability = Decimal.valueOf(oppStageAndProbability.get('Probability'));
                        }
                    }
                }

                if (this.territoryOppOwner != null) {
                    updateOpp.ownerId = territoryOppOwner;
                }

                if (this.oppBusinessType != null) {
                    updateOpp.Business_Type__c = this.oppBusinessType;
                }

                oppStageAndProbability.clear();

                if (leadTobeConverted.Commission__c != null && leadTobeConverted.Order_date__c != null && leadTobeConverted.Tariff_Name__c != null) {
                    if (!leadToQuoteStage.isEmpty()) {
                        for (String str : leadToQuoteStage) {
                            List<String> fields = str.split('=');
                            oppStageAndProbability.put(fields[0], fields[1]);
                        }

                        if (oppStageAndProbability.get('StageName') != null) {
                            updateOpp.StageName = oppStageAndProbability.get('StageName');
                            if (oppStageAndProbability.get('Probability') != null) {
                                updateOpp.Probability = Decimal.valueOf(oppStageAndProbability.get('Probability'));
                            }
                        }
                    }
                }

                System.debug('CtrLeadConversion.convertLead: updating opportunity');

                update updateOpp;

                System.debug('CtrLeadConversion.convertLead: opportunity updated');

                if (leadTobeConverted.Commission__c != null && leadTobeConverted.Order_date__c != null && leadTobeConverted.Tariff_Name__c != null) {
                    ClsLeadProcessor.futureLeadToQuoteProcess(updateOpp.Id);
                }
            }

            this.convertedAccountId = newAccountId;
        }catch(DMLException ex){ 
        	ClsUtilsApexPages.addErrorMessage(ex.getDMLMessage(0));
        }catch (LeadConversionException customEx) {
            System.debug('CtrLeadConversion.convertLead: custom exception occurred');



            ClsUtilsApexPages.addMessage(customEx.severity, customEx.getMessage());

            Database.rollback(sp);
            leadTobeConverted = leadTobeConvertedBackup;
        } catch (Exception e) {
            System.debug('CtrLeadConversion.convertLead: exception occurred. Message is: ' + e.getMessage());





            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, Label.Lead_Conversion_Error));

            Database.rollback(sp);
            leadTobeConverted = leadTobeConvertedBackup;
        }

        return null;
    }
    /*
        changes for SP-530 "ContactOwner is the same as AccountOwner"
    */
    private void updateNewContacts(String convertedContactId, String accountId) {
        System.debug('CtrLeadConversion.updateNewContacts: start');

        Id contactRecordTypeId = LibRecordTypeHelper.getRecordTypeValue(this.companyCode + '_Contact');
        List<Contact> additionalContactList = new List<Contact>();
        String LeadToContactMap = mapBusinessData.get('LeadToContactMap') != null ? mapBusinessData.get('LeadToContactMap').Business_Rule_Value__c : '';
        Contact newContact1 = new Contact(id = convertedContactId, Contact_Role__c = 'Owner', RecordTypeId = contactRecordTypeId);

        System.debug('CtrLeadConversion.updateNewContacts: main contact is: ' + newContact1);

        if (String.isNotBlank(LeadToContactMap)) {
            List<String> keyPair = LeadToContactMap.split('=');
            newContact1 .put(keyPair[0], this.leadTobeConverted.get(keyPair[1]));
        }

        additionalContactList.add(newContact1);

        if (!this.mapNewContactMap.isEmpty()) {
            for (WrapperContact newC : this.mapNewContactMap.values()) {
                System.debug('CtrLeadConversion.updateNewContacts: adding additional contact with lastname: ' + newC.lastName);
                Contact addtionalContact = new Contact();
                addtionalContact.AccountId = accountId;
                addtionalContact.LastName = newC.lastName;
                addtionalContact.FirstName =  newC.firstName;
                addtionalContact.Salutation = newC.salutation;
                addtionalContact.MobilePhone = newC.mobile;
                addtionalContact.Email = newC.email;
                addtionalContact.Contact_Role__c = newC.contactRole;
                addtionalContact.RecordTypeId = contactRecordTypeId;
                addtionalContact.OwnerId = leadTobeConverted.OwnerId;
                additionalContactList.add(addtionalContact);
            }
        }

        if (territoryAccOwner != null) {
            for (Contact theContact : additionalContactList) {
                theContact.put('OwnerId', territoryAccOwner);
            }
        }

        try {
            System.debug('CtrLeadConversion.updateNewContacts: inserting additional contacts');

            upsert additionalContactList;

            System.debug('CtrLeadConversion.updateNewContacts: additional contacts inserted');
        } catch (Exception e) {
            System.debug('CtrLeadConversion.updateNewContacts: exception occurred. Message is: ' + e.getMessage());


            throw new LeadConversionException(Label.Lead_Conversion_Additional_Contacts_Error, ApexPages.Severity.ERROR);
        }
    }


    private void updateNewAccount(String accountId, String leadId) {
        List<String> leadToAccountMap = mapBusinessData.get('LeadToAccountMap') != null ? mapBusinessData.get('LeadToAccountMap').Business_Rule_Value__c.split(',') : new List<String>();
        List<String> leadToAccountNonContractedMap = mapBusinessData.get('LeadToAccountNonContractedMap') != null ? mapBusinessData.get('LeadToAccountNonContractedMap').Business_Rule_Value__c.split(',') : new List<String>();

        String queryAcc = 'SELECT Id, Type, Non_Contracted__c, RecordTypeId,ownerId, RecordType.DeveloperName,Record_Country__c';
        if (mapBusinessData.get('TerritoryFieldToCompare') != null && mapBusinessData.get('TerritoryFieldToCompare').Business_Rule_Value__c != null) {
            queryAcc = queryAcc + ',' + mapBusinessData.get('TerritoryFieldToCompare').Business_Rule_Value__c;
        }
        queryAcc = queryAcc + ' FROM Account WHERE Id =: accountId LIMIT 1';


        Account newlyCreatedAccount = (Account) Database.query(queryAcc);

        this.leadTobeConverted = this.queryLead(listFieldsToQuery);
        System.debug('this.leadTobeConverted: ' + this.leadTobeConverted);

        try {
            if (newlyCreatedAccount != null) {
                newlyCreatedAccount.Name = this.tempAccount.Name;

                // set default account type if specified in business config
                if (mapBusinessData.containsKey('accountType')) {
                    newlyCreatedAccount.Type = mapBusinessData.get('accountType').Business_Rule_Value__c;
                }

                newlyCreatedAccount.Recordtypeid = LibRecordTypeHelper.getRecordTypeValue(this.companyCode + '_Account');
                for (String str : leadToAccountMap) {
                    List<String> keyPair = str.split('=');
                    newlyCreatedAccount.put(keyPair[0], this.leadTobeConverted.get(keyPair[1]));
                }
                if (newlyCreatedAccount.Non_Contracted__c && nonContracted != null && nonContracted && !leadToAccountNonContractedMap.isEmpty()) {
                    for (String str : leadToAccountNonContractedMap) {
                        List<String> keyPair = str.split('=');
                        System.debug('keyPair[0]: ' + keyPair[0]);
                        newlyCreatedAccount.put(keyPair[0], this.leadTobeConverted.get(keyPair[1]));
                    }
                }

                String recordtypeName = this.companyCode + '_Account';
                if (this.enabledTerritory) {
                    String typeOfterritory = mapBusinessData.get('TerritoryType') != null ? mapBusinessData.get('TerritoryType').Business_Rule_Value__c : null;
                    String fieldToCompare = mapBusinessData.get('TerritoryFieldToCompare').Business_Rule_Value__c;

                    if (newlyCreatedAccount.get(fieldToCompare) != null) {
                        for (Territory__c tr : [select id, Account_owner__c, Account_Record_Type__c, Company__c, Country__c, Field_to_compare__c, Opportunity_owner__c, Type__c, Values__c, Territory__c from Territory__c where Account_Record_Type__c = :recordtypeName and Type__c = : typeOfterritory]) {
                            if (tr.type__c == 'Range') {
                                Integer filedValue = Integer.valueOf(newlyCreatedAccount.get(fieldToCompare));
                                List<String> postCodes = tr.Values__c.split('-');
                                System.debug('filedValue: ' + filedValue);
                                System.debug('postCodes[0]: ' + postCodes[0]);
                                System.debug('postCodes[1]: ' + postCodes[1]);
                                Integer startValue = Integer.valueOf(postCodes[0]);
                                Integer endValue = Integer.valueOf(postCodes[1]);
                                if (filedValue >= startValue &&  filedValue <= endValue) {
                                    newlyCreatedAccount.put('ownerId', tr.Account_owner__c);
                                    newlyCreatedAccount.put('Territory__c', tr.Territory__c);
                                    territoryAccOwner = tr.Account_owner__c;
                                    territoryOppOwner = tr.Opportunity_owner__c;
                                    break;
                                }
                            } else if (tr.type__c == 'Comma separated') {
                                Set<String> PostCodeValues = new Set<String>(tr.Values__c.split(','));
                                if (PostCodeValues.contains(String.valueOf(newlyCreatedAccount.get(fieldToCompare)))) {
                                    newlyCreatedAccount.put('ownerId', tr.Account_owner__c);
                                    newlyCreatedAccount.put('Territory__c', tr.Territory__c);
                                    territoryAccOwner = tr.Account_owner__c;
                                    territoryOppOwner = tr.Opportunity_owner__c;
                                    break;
                                }
                            }
                        }
                    }
                }

                System.debug('newlyCreatedAccount: ' + newlyCreatedAccount);
                newlyCreatedAccount.Record_Country__c = this.leadToConvert.Record_Country__c;
                update newlyCreatedAccount;

            }
        } catch (Exception e) {
            System.debug('CtrLeadConversion.updateNewAccount: exception occurred. Message is: ' + e.getMessage());

            System.debug(LoggingLevel.ERROR, 'm-zeuli: upnewacc msg: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'm-zeuli stk: ' + e.getStackTraceString());

            throw new LeadConversionException(Label.Lead_Conversion_New_Account_Update_Error, ApexPages.Severity.ERROR);
        }
    }

    public class LeadConversionException extends Exception {
        public ApexPages.Severity severity {get; set;}
        public LeadConversionException(String message, ApexPages.Severity severity) {
            this(message);
            this.severity = severity;
        }
    }

    //wrapper
    public class WrapperContact {
        public String salutation {Get; Set;}
        public String firstName {Get; Set;}
        public String lastName {Get; Set;}
        public String mobile {Get; Set;}
        public String email {Get; Set;}
        public String contactRole {get; set;}
        public String tempKey {Get; Set;}

        public wrapperContact(Contact cont) {

            this.salutation = cont.Salutation;
            this.firstName = cont.FirstName;
            this.lastName = cont.LastName;
            this.mobile = cont.MobilePhone;
            this.email = cont.Email;
            this.contactRole = cont.Contact_Role__c;
        }
    }
    @TestVisible
    private static Schema.DisplayType getFieldType(String fieldName, String sObjectName) {

        Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);
        Schema.DescribeSObjectResult r = t.getDescribe();
        Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();
        return f.getType();
    }
}
