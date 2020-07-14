/**
 * Controller per BrandingContentScreen
 * Handles the logic to submit/approve/reject the branding content record.
 *
 * Right now used only by CD
 */
public with sharing class CtrBrandingContentScreen {

    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    private  Map<String, Business_Config__c> Rules;
    private static Map<String, Map<String, Business_Config__c>> mapProcessData = moam.get('BrandingApprovalProcess');

    public Boolean displayApprove {
        get {
            return (
                isButtonVisible('Approve')
                && (isFirstLevelApprover() || isSecondLevelApprover())
            );
        }
    }

    public Boolean displayReject {
        get {
            return (
                isButtonVisible('Reject')
                && (isFirstLevelApprover() || isSecondLevelApprover())
            );
        }
    }

    public Boolean displayTakeOwnership {
        get {
            return isButtonVisible('TakeOwnership') && canTakeOwnership();
        }
    }

    public Boolean displaySubmit {
        get {
            return isButtonVisible('Submit') && canSubmit();
        }
    }

    public String ownerName {
        get {
            return String.isNotBlank(brandingcontent.OwnerId) &&  String.valueOf(brandingContent.OwnerId).startsWith('005')
                ? [Select Name From User Where id=: brandingcontent.OwnerId].name 
                : [select Name From Group Where Id=: brandingcontent.OwnerId].Name;
        }
    }

    // branding content record
    public Branding_Content__c     brandingContent {get; set;}

    public CtrBrandingContentScreen(ApexPages.StandardController stdCtr) {
        if (!Test.isRunningTest()) {
            stdCtr.addFields(new List<String> {'Recordtype.Developername', 'Opportunity__r.Record_Country__c', 'Opportunity__r.company_code__c'});
        }
        brandingContent = (Branding_Content__c) stdCtr.getRecord();

        // initialize rules to an empty map
        rules = new Map<String, Business_Config__c>();

        if (mapProcessData != null && !mapProcessData.isEmpty()) {
            rules = mapProcessData.get(brandingContent.Recordtype.Developername);
        }
    }

    /**
    * Called when user press on Approve button. Based on brandingContent's status
    * updates record's owner and status itself
    * @return [description]
    */
    public PageReference approve() {
        system.debug('**approve');
        List<String> result = new List<String>();
        System.Savepoint sp = Database.setSavepoint();

        Boolean updateOpp = false;
        //rules= mapProcessData.get(brandingContent.Recordtype.Developername);
        try {

            system.debug('&&rules' + rules);

            if (isFirstLevelApprover()) {

                brandingcontent.status__c = Rules.get('level1ApprovedStatus').Business_Rule_Value__c;
                //brandingcontent.ownerid = Rules.get('countryManagerId' + brandingcontent.Opportunity__r.Record_Country__c).Business_Rule_Value__c;
                updateOpp = false;

            } else if (isSecondLevelApprover()) {

                brandingcontent.status__c = Rules.get('finalApprovalStatus').Business_Rule_Value__c;
                updateOpp = true;

            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.Branding_Accept_No_Access));
            }

            try {

                update brandingcontent;
                Opportunity opp = [SELECT Id, StageName, probability FROM Opportunity WHERE Id = :brandingcontent.opportunity__c  LIMIT 1];
                system.debug(opp);
                system.debug(Integer.valueof(Rules.get('oppProbability').Business_Rule_Value__c));
                if (updateOpp &&  opp.StageName != Rules.get('pushStageNameAfterFinalApproval').Business_Rule_Value__c && opp.probability < Integer.valueof(Rules.get('oppProbability').Business_Rule_Value__c)) {
                    opp.StageName = Rules.get('pushStageNameAfterFinalApproval').Business_Rule_Value__c;
                    update opp;
                }

            } catch (DmlException e) {
                System.debug('Error: ' + e.getMessage());
                System.debug('e.getDmlType(0): ' + e.getDmlType(0));

                if (e.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
                    result.add(Label.Error + ' ' + e.getDmlMessage(0));
                    Database.rollback(sp);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, e.getDmlMessage(0)));
                }
                result.add(Label.Error + ' ' + e.getMessage());
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, e.getMessage()));
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString());
            result.add(Label.Error + ' ' + e.getMessage());
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, e.getMessage()));
        }
        return null;
    }

    /**
     * Called when user press on Reject button. Based on brandingContent's status
     * updates record's owner and status itself
     * @return [description]
     */
    public PageReference reject() {
        system.debug('**reject');
        List<String> result = new List<String>();
        System.Savepoint sp = Database.setSavepoint();

        rules = mapProcessData.get(brandingContent.Recordtype.Developername);
        system.debug('&&rules' + rules);

        try {
            system.debug('&&rules' + rules);

            if (isFirstLevelApprover()) {

                brandingcontent.status__c = Rules.get('rejectionStatusLevel1').Business_Rule_Value__c;
                //brandingcontent.ownerid = rules.get('DesignQueue').business_rule_value__C;

            } else if (isSecondLevelApprover()) {

                brandingcontent.status__c = Rules.get('rejectionStatusFinal').Business_Rule_Value__c;
                //brandingcontent.ownerid = rules.get('DesignQueue').business_rule_value__C;

            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.Branding_Accept_No_Access));

            }

            try {

                update brandingcontent;

            } catch (DmlException e) {
                System.debug('Error: ' + e.getMessage());
                System.debug('e.getDmlType(0): ' + e.getDmlType(0));

                if (e.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
                    result.add(Label.Error + ' ' + e.getDmlMessage(0));
                    Database.rollback(sp);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, e.getDmlMessage(0)));
                }
                result.add(Label.Error + ' ' + e.getMessage());
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, e.getMessage()));
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString());
            result.add(Label.Error + ' ' + e.getMessage());
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, e.getMessage()));
        }

        return null;
    }

    /**
     * Called when user press on Take Ownership button changes record's owner
     * @return [description]
     */
    public PageReference takeOwnership() {
        if (canTakeOwnership()) {

            brandingcontent.ownerid = Userinfo.getUserId();

            try {
                update brandingContent;
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, e.getMessage()));
            }
        }

        return null;
    }

    /**
     * Called when user press on Submit button, changes brandingContent's owner and
     * status
     * @return [description]
     */
    public PageReference submit() {
        if (canSubmit()) {

            //brandingcontent.ownerid = rules.get('designManagerId' + brandingcontent.Opportunity__r.Record_Country__c).business_rule_value__C;
            brandingContent.Status__c = Rules.get('initialStatusLevel').Business_Rule_Value__c;

            try {
                update brandingContent;
            } Catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, e.getMessage()));
            }
        }
        return null;
    }


    /** UTILITY METHODS  **/


    private Boolean isButtonVisible(String buttonName) {
        // checks business matrix
        if (!moam.containsKey('BrandingApprovalProcess')) {
            return false;
        }


        // filter by recordtype
        if (!mapProcessData.containsKey(brandingContent.Recordtype.Developername)) {
            return false;
        }


        // checks if rule exist


        if (!Rules .containsKey('buttonToStatuses')) {
            return false;
        }

        Map<String, Set<String>> buttonToStatuses = (Map<String, Set<String>>)
                JSON.deserialize(Rules.get('buttonToStatuses').Business_Rule_Value__c,
                                 Map<String, Set<String>>.class);

        return buttonToStatuses.containsKey(buttonName) ? buttonToStatuses.get(buttonName).contains(brandingContent.Status__c) : false;
    }

    /**
     * Checks if current user is a first level approver for brandingContent record
     * @return true if current user is a first level approver, false otherwise
     */
    private Boolean isFirstLevelApprover() {
        if (rules.isEmpty()) {
            return false;
        }

        // get approval matrix
        Map<String,Map<String,OpportunityTeamMember>>mapOppTeam = LibBusinessConfig.determineApproverMap(brandingContent.opportunity__c);

        Map<String, OpportunityTeamMember> mapApprovalEntriesLevel1 = mapOppTeam.get('Design Manager');

        return (
                   Rules.containsKey('initialStatusLevel')
                   && brandingContent.status__c == Rules.get('initialStatusLevel').Business_Rule_Value__c
                   && mapApprovalEntriesLevel1!=null && mapApprovalEntriesLevel1.keySet().contains(Userinfo.getUserId())
               );
    }

    /**
     * Checks if current user is a second level approver for brandingContent record
     * @return true if current user is a second level approver, false otherwise
     */
    private Boolean isSecondLevelApprover() {
        if (rules.isEmpty()) {
            return false;
        }

        // get approver matrix
        Map<String,Map<String,OpportunityTeamMember>>mapOppTeam = LibBusinessConfig.determineApproverMap(brandingContent.opportunity__c);

        Map<String, OpportunityTeamMember> mapApprovalEntriesLevel2 = mapOppTeam.get('HOS');

        return (
                   Rules.containsKey('level1ApprovedStatus')
                   && brandingContent.status__c == Rules.get('level1ApprovedStatus').Business_Rule_Value__c
                   && mapApprovalEntriesLevel2!= null && mapApprovalEntriesLevel2.keySet().contains(Userinfo.getUserId())
               );
    }

    /**
     * Checks if current user can take ownership of the brandingContent record
     * @return true if user can take ownership, false otherwise
     */
    private Boolean canTakeOwnership() {
        return (
                   rules.containsKey('DesignQueue')
                   && brandingcontent.ownerid == rules.get('DesignQueue').business_rule_value__c
                   && ! new Map<Id, SObject>([select id from GroupMember where Userorgroupid =: UserInfo.getUserId() and GroupId = : brandingcontent.ownerid]).isEmpty()
               );
    }

    /**
     * Checks if current user can submit the brandingContent record for approval
     * @return true if user can submit, false otherwise
     */
    private Boolean canSubmit() {
        return  brandingcontent.ownerid == Userinfo.getUserId() &&
                (
                    (rules.containsKey('brandingStatusOnCreate') && brandingcontent.status__c == rules.get('brandingStatusOnCreate').business_rule_value__C)
                    || (rules.containsKey('rejectionStatusLevel1') && brandingcontent.status__c == rules.get('rejectionStatusLevel1').business_rule_value__C)
                    || (rules.containsKey('rejectionStatusFinal') && brandingcontent.status__c == rules.get('rejectionStatusFinal').business_rule_value__C)
                );
    }
}