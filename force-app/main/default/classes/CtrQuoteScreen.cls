public without sharing class CtrQuoteScreen {
    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;

    public Opportunity_Quote__c theQuote {get; set;}
    public List<Schema.FieldSetMember> fields_Quote {get; set;}
    public boolean viewMode {get; set;}
    public boolean editMode {get; set;}
    public boolean showAcceptQuote {get; set;}
    public boolean showCreatePDF {get; set;}
    public boolean showSendEmail {get; set;}
    public boolean showEditButton {get; set;}
    public boolean readOnly {get; set;}
    public boolean showRefresh {get; set;}
    public Boolean displayQuoteInIframe {get; set;}
    public Boolean checkForRequiredFields { get; set; }
    public String allowAcceptQuote { get; set; }
    public Boolean allowVIPAcceptQuote {get;set; }
    public Boolean isNintexQuote {get; set;}
    private Boolean templateNameIsSet {get; set;}
    private static final Set<String> nintexClassicCountries = Constants.NINTEX_CONFIG_CLASSICUI_COUNTRIES;

    /*
    * SP-581 Approval for ME
    */
    public boolean showApprovalButtons {get; set;} //show Approve and Reject button

    public CtrQuoteScreen(ApexPages.StandardController controller) {
        this.viewMode = true;
        this.editMode = false;
        this.showAcceptQuote = true;
        this.showCreatePDF = true;
        this.showSendEmail = true;
        this.showEditButton = true;
        this.showApprovalButtons = false;
        this.readOnly = false;
        this.showRefresh = true;
        this.templateNameIsSet = false;
        this.displayQuoteInIframe = false;

        Map<String, Map<String, Business_Config__c>> mapProcessData = moam.get('QuoteScreenProcess');
        Map<String, Business_Config__c> mapBusinessData;

        if (!Test.isRunningTest()) {
            controller.addFields(new List<String> {
                'Template_Name__c',
                'Id_opportunity__r.RecordTypeId',
                'Id_opportunity__r.Business_Type__c',
                'Id_Account__r.recordType.developerName',
                'Non_Standard_Contract_Components__c',
                'Recordtype.Developername',
                'Id_Opportunity__r.Record_Country__c',
                'Id_Account__r',
                'Id_Account__r.Trade_Register_Number__c',
                'Id_Account__r.Tax_Number__c',
                'Id_Account__c',
                'CreatedDate'
            });
        }

        this.theQuote = (Opportunity_Quote__c) controller.getRecord();
        this.isNintexQuote = nintexClassicCountries.contains(theQuote.Id_Opportunity__r.Record_Country__c);
        // checks for null values
        if (mapProcessData == null) {
            ClsUtilsApexPages.addInfoMessage(Label.BusinessProcessNotActive);
            return;
        }

        mapBusinessData = mapProcessData.get(this.theQuote.Recordtype.Developername);

        Map<String, Map<String, Business_Config__c>> mapProcessDataApproval = moam.get('QuoteApprovalProcess');

        // checks if quote can be approved by current user
        if (mapProcessDataApproval != null) {
            Map<String, Map<String, OpportunityTeamMember>>mapOppTeam = LibBusinessConfig.determineApproverMap(this.theQuote.id_opportunity__c);
            Map<String, OpportunityTeamMember> mapApprovalLevel1 = mapOppTeam.get('HOS');
            Map<String, OpportunityTeamMember> mapApprovalLevel2 = mapOppTeam.get('Legal');
            Map<String, OpportunityTeamMember> mapApprovalLevel3 = mapOppTeam.get('Regional HOS');
            Map<String, Business_Config__c> mapBusinessDataApproval = mapProcessDataApproval.get(this.theQuote.Recordtype.Developername);


            // checks if to show or not approval buttons
            if (mapBusinessDataApproval != null && mapOppTeam != null) {

                this.showApprovalButtons = (
                                               // level 3 approvers
                                               (
                                                   mapApprovalLevel3 != null &&
                                                   mapApprovalLevel3.keySet().contains(UserInfo.getUserId()) && mapBusinessDataApproval.get('initialStatusLevel3') != null &&
                                                   this.theQuote.Status__c == mapBusinessDataApproval.get('initialStatusLevel3').Business_Rule_Value__c
                                               )
                                               ||
                                               // level 1 approvers
                                               (
                                                   mapApprovalLevel1 != null &&
                                                   mapApprovalLevel1.keySet().contains(UserInfo.getUserId()) && mapBusinessDataApproval.get('initialStatusLevel1') != null &&
                                                   this.theQuote.Status__c == mapBusinessDataApproval.get('initialStatusLevel1').Business_Rule_Value__c
                                               )
                                               ||
                                               // level 2 approvers
                                               (
                                                   mapApprovalLevel2 != null &&
                                                   mapApprovalLevel2.keySet().contains(Userinfo.getUserId()) && mapBusinessDataApproval.get('level1ApprovedStatus') != null &&
                                                   this.theQuote.Status__c == mapBusinessDataApproval.get('level1ApprovedStatus').Business_Rule_Value__c
                                               )
                                           );
            }
        }

        if (mapBusinessData != null) {

            // checks if has to display the quote pdf in an iframe instead of injecting it into the page
            if (mapBusinessData.containsKey('displayQuoteInIframe')) {
                this.displayQuoteInIframe = Boolean.valueOf(mapBusinessData.get('displayQuoteInIframe').Business_Rule_Value__c);
            }

            // add fields
            if (mapBusinessData.containsKey('FieldSet')) {
                this.fields_Quote = readFieldSet(mapBusinessData.get('FieldSet').Business_Rule_Value__c, 'Opportunity_Quote__c');
                this.checkForRequiredFields = Boolean.valueOf(mapBusinessData.get('CheckForRequiredFields').Business_Rule_Value__c);
                if (mapBusinessData.containsKey('AllowAcceptQuoteButton') && (!mapBusinessData.containsKey('SkipEmailForTypes')
                        || this.theQuote.Id_Opportunity__r.Business_Type__c == null
                        || !mapBusinessData.get('SkipEmailForTypes').Business_Rule_Value__c.contains(this.theQuote.Id_Opportunity__r.Business_Type__c))) {
                    this.allowAcceptQuote = mapBusinessData.get('AllowAcceptQuoteButton').Business_Rule_Value__c;

                }
            }

            if (mapBusinessData.containsKey('AllowVIPAcceptQuote')){
            	allowVIPAcceptQuote = boolean.valueOf(mapBusinessData.get('AllowVIPAcceptQuote').Business_Rule_Value__c);
            }else{
            	allowVIPAcceptQuote = false;
            }
            

            // gets the quote
            retriveQuoteDetails();

            // enable/disable buttons according to quote status
            String statusRuleName = 'DisableButton_' + this.theQuote.status__c;
            if (mapBusinessData.containsKey(statusRuleName)) {
                for (String str : (mapBusinessData.get(statusRuleName).Business_Rule_Value__c.split(','))) {
                    if (str.equalsIgnoreCase('acceptQuote')) {
                        this.showAcceptQuote = false;
                    } else if (str.equalsIgnoreCase('createPDF')) {
                        this.showCreatePDF = false;
                    } else if (str.equalsIgnoreCase('sendEmail')) {
                        this.showSendEmail = false;
                    } else if (str.equalsIgnoreCase('approval')) {
                        this.showApprovalButtons = false;
                    } else if (str.equalsIgnoreCase('edit')) {
                        this.showEditButton = false;
                    } else if (str.equalsIgnoreCase('readOnly')) {
                        this.readOnly = true;
                    } else if (str.equalsIgnoreCase('refresh')) {
                        this.showRefresh = false;
                    }
                }
            }
        }

        if (this.theQuote.Template_Name__c != null && !this.isNintexQuote) { // Defect Fix: #SSC:1319) {
            this.templateName = this.theQuote.Template_Name__c;
        }
    }

    private void retriveQuoteDetails() {
        String queryString = 'select id,Name, CreatedDate, Template_Name__c,Id_opportunity__r.RecordTypeId, Id_Opportunity__r.Account.ParentId, Non_Standard_Contract_Components__c,Id_Account__r.recordType.developerName';
        if (this.fields_Quote != null) {
            for (Schema.FieldSetMember fsm : this.fields_Quote) {
                String filedName = fsm.getFieldPath();
                if (!queryString.containsIgnoreCase(filedName)) {
                    queryString += ', ' + filedName;
                }
            }
        }
        queryString += ' from Opportunity_Quote__c where id=\'' + this.theQuote.id + '\'';
        this.theQuote = Database.query(queryString);
    }

    public String templateName {
        get{
            System.debug('templateName1: ' + templateName);
            this.templateNameIsSet = false;
            if (templateName == null) {
                List<Opportunity_Quote_Line_Item__c> existingLineItems = [select id, Line_Item_Type__c, sub_type__c from Opportunity_Quote_Line_Item__c where Id_Opportunity_Quote__c = :this.theQuote.Id];
                ClsQuoteProcessor cqp1 = new ClsQuoteProcessor(null, this.theQuote,this.theQuote.Id_Account__r.recordType.developerName, existingLineItems);
                this.templateName = cqp1.vfTemplateName;
                System.debug('templateName2: ' + templateName);
                this.theQuote.Template_Name__c = this.templateName;
                this.templateNameIsSet = true;
                //update this.theQuote;
                System.debug('this.theQuote.Template_Name__c: ' + this.theQuote.Template_Name__c);
            }
            return templateName;
        }
        private set;
    }

    public void generateTemplateName() {
        if (this.templateNameIsSet) {
            System.debug('templateNameIsSet: ' + templateNameIsSet);
            update this.theQuote;
        }
    }

    public PageReference saveDetails() {
        try {
            update this.theQuote;
            retriveQuoteDetails();
        } catch (Exception e) {
            System.debug('Error at Save Detail: ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error occured contact Admins.'));
        }
        return new PageReference('/' + this.theQuote.Id);
    }

    private List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName) {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields();
    }

    public void switchToEditMode() {
        this.viewMode = false;
        this.showEditButton = false;
        this.editMode = true;
    }

    public void switchToLockMode() {
        //this.lockMode = true;
        this.viewMode = true;
        this.showEditButton = true;
        this.editMode = false;
    }

    public void switchToViewMode() {
        this.viewMode = true;
        this.showEditButton = true;
        this.editMode = false;
        retriveQuoteDetails();
    }
}
