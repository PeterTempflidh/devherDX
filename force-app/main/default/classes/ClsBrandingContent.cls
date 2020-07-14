public with sharing class ClsBrandingContent {
    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;

    public static void updateOppOnBrandingActivation(List<Branding_Content__C> branding, Map<id, branding_content__c> brandingOldMap) {

        System.debug('ClsBrandingContent.updateOppOnBrandingActivation: start');

        Map<String, Map<String, Business_Config__c>> mapProcessData = moam.get('BrandingActivation');
        Set<string> oppIds = new set<string>();

        // checks for null values
        if (mapProcessData == null || mapProcessData.isEmpty()) {
            System.debug('ClsBrandingContent.updateOppOnBrandingActivation: no process data');
            return;
        }

        for (Branding_Content__C b : branding) {
            String rtId = LibRecordTypeHelper.getRecordTypeValue(b.RecordTypeId);

            if (String.isBlank(rtId)) {
                continue;
            }

            Map<String, Business_Config__c> mapBusinessData = mapProcessData.get(rtId);

            if (mapBusinessData == null || mapBusinessData.isEmpty()) {
                continue;
            }

            if (mapBusinessData.get('checkForBrandingActivation') != null && Boolean.valueOf(mapBusinessData.get('checkForBrandingActivation').Business_Rule_Value__C) ) {
                if (b.status__c != brandingOldMap.get(b.id).status__c && b.status__c == mapBusinessData.get('brandingActivationStatus').Business_Rule_Value__C && b.type__c != null && b.type__c.containsignorecase('White Label')) {
                    oppIds.add(b.Opportunity__c);
                }
            }
        }

        if (oppIds.isEmpty()) {
            System.debug('ClsBrandingContent.updateOppOnBrandingActivation: no opps to process');
            return;
        }

        Set<String> onbSuccess = new Set<String>();
        Set<String> onbNotSuccessful = new Set<String>();
        Set<String> MPSuccessful = new Set<String>();
        Set<String> MPNotSuccessful = new Set<String>();
        Set<String> QCSuccessful = new set<String>();
        Set<String> QCNotSuccessful = new Set<String>();
        Set<String> assetActivated = new Set<String>();
        Set<String> assetNotActivated = new Set<String>();
        Map<String, String> oppBrandingStatusMapNeg = new Map<String, String>();

        for (Case c : [select id, status, type, opportunity__c, closed_reason__c from Case where opportunity__c in :oppIds]) {

            if (c.Status == 'Closed') {
                if (c.Type == 'Onboarding') {
                    if (c.Closed_Reason__c == 'Successful') {
                        onbSuccess.add(c.Opportunity__c);
                    } else {
                        onbNotSuccessful.add(c.Opportunity__c);
                    }
                } else if (c.type == 'Menu Processing') {
                    if (c.Closed_Reason__c == 'Take Online' ) {
                        MPSuccessful.add(c.Opportunity__C);
                    } else {
                        MPNotSuccessful.add(c.Opportunity__C);
                    }
                } else if (c.type == 'Quality Check') {
                    if (c.Closed_Reason__c == 'Successful' ) {
                        QCSuccessful.add(c.Opportunity__C);
                    } else {
                        QCNotSuccessful.add(c.Opportunity__C);
                    }
                }
            }
        }

        for (Asset__c a : [select id, status__c, opportunity__c from asset__c where opportunity__c in : oppIds ]) {
            if (a.status__c == 'Activated Successfully') {
                assetActivated.add(a.opportunity__c);
            } else {
                assetNotActivated.add(a.Opportunity__c);
            }
        }


        for (Branding_Content__c b : [select id, status__c, opportunity__c from branding_Content__c where  type__c like '%White Label%' and id not in :branding and opportunity__c in :oppIds]) {
            if (b.Status__c != 'Installed Successfully') {
                oppBrandingStatusMapNeg.put(b.Opportunity__c, b.status__c);
            }
        }

        // clear sets
        onbSuccess.removeAll(onbNotSuccessful);
        QCSuccessful.removeAll(QCNotSuccessful);
        MPSuccessful.removeAll(MPNotSuccessful);
        assetActivated.removeAll(assetNotActivated);

        Set<String> oppsToUpdate = new Set<String>();

        oppsToUpdate.addAll(onbSuccess);
        oppsToUpdate.addAll(QCSuccessful);
        oppsToUpdate.addAll(MPSuccessful);
        oppsToUpdate.addAll(assetActivated);
        oppsToUpdate.removeAll(oppBrandingStatusMapNeg.keySet());

        if (oppsToUpdate.isEmpty()) {
            System.debug('ClsBrandingContent.updateOppOnBrandingActivation: no opp to update');
            return;
        }

        List<Opportunity> oppToUpd = new List<Opportunity>();
        for (Opportunity o : [select id, stagename from opportunity where id in : oppsToUpdate and stageName != 'Closed Won']) {
            o.stageName = 'Closed Won';
            oppToUpd.add(o);
        }

        if (!oppToUpd.isEmpty()) {
            System.debug('ClsBrandingContent.updateOppOnBrandingActivation: updating opportunities');
            update oppToUpd;
        }
    }

    /**
     * Update account branding status when a Branding record is inserted or deleted
     * or gets canceled/uninstalled
     * @param brandings Inserted branding records
     */
    public static void updateAccountBrandingStatus(List<Branding_Content__c> brandings) {
        updateAccountBrandingStatus(brandings, new Map<Id, Branding_Content__c>());
    }

    /**
     * Update account branding status when a Branding record gets updated
     * @param brandings       Updated branding records
     * @param brandingOldMap  Old branding records before update
     */
    public static void updateAccountBrandingStatus(List<Branding_Content__c> brandings, Map<Id, Branding_Content__c> brandingOldMap) {
        Set<Id> accountIds = new Set<Id>();
        for (Branding_Content__c branding : brandings) {
            if (brandingOldMap.containsKey(branding.Id)) {
                if (branding.Status__c == brandingOldMap.get(branding.Id).Status__c) {
                    continue;
                }
            }
            accountIds.add(branding.Restaurant_Name__c);
        }

        if (!System.isBatch() && !System.isFuture()) {
            normalizeAccountBrandingStatusFuture(accountIds);
        } else {
            normalizeAccountBrandingStatus(accountIds);
        }
    }

    private static void normalizeAccountBrandingStatus(Set<Id> accountIds) {

        if (accountIds.isEmpty()) {
            System.debug('ClsBrandingContent.normalizeAccountBrandingStatusFuture: nothing to do');
            return;
        }

        Map<String, Map<String, Business_Config__c>> mapProcessData = moam.get('BrandingActivation');

        // checks matrix configuration
        if (mapProcessData == null || mapProcessData.isEmpty()) {
            System.debug('ClsBrandingContent.updateAccountBrandingStatus: mapProcessData is empty');
            return;
        }

        Map<Id, Account> idToAccount = new Map<Id, Account>([
                    SELECT
                    Id,
                    Branding_Status__c
                    FROM Account
                    WHERE Id in :accountIds
                ]);

        accountIds.clear();

        Map<Id, List<Branding_Content__C>> accountIdToBrandings = new Map<Id, List<Branding_Content__c>>();

        for (Branding_Content__c branding : [
                    SELECT
                    Restaurant_Name__c,
                    RecordType.DeveloperName,
                    Status__c,
                    Type__c
                    FROM Branding_Content__c
                    WHERE Restaurant_Name__c in :idToAccount.keySet()
                ]) {

            // checks if has to process branding
            Map<String, Business_Config__c> config = mapProcessData.get(branding.RecordType.DeveloperName);

            CheckForAccountUpdateWrapper rule = getCheckForAccountUpdateRule(config, branding.RecordType.DeveloperName);

            if (!rule.appliesTo(branding)) {
                continue;
            }

            if (!accountIdToBrandings.containsKey(branding.Restaurant_Name__c)) {
                accountIdToBrandings.put(branding.Restaurant_Name__c, new List<Branding_Content__c>());
            }

            accountIdToBrandings.get(branding.Restaurant_Name__c).add(branding);
        }

        for (Id accountId : idToAccount.keySet()) {

            if (!accountIdToBrandings.containsKey(accountId)) {
                continue;
            }

            Account acc = idToAccount.get(accountId);

            String activeStatus;
            String waitingStatus;
            String inactiveStatus;

            if (!accountIdToBrandings.containsKey(accountId)) {
                // accounts has no more branding records
                acc.Branding_Status__c = '';
                continue;
            }

            for (Branding_Content__c branding : accountIdToBrandings.get(accountId)) {
                // checks if has to process branding
                Map<String, Business_Config__c> config = mapProcessData.get(branding.RecordType.DeveloperName);

                CheckForAccountUpdateWrapper rule = getCheckForAccountUpdateRule(config, branding.RecordType.DeveloperName);

                if (rule.isActiveStatus(branding)) {
                    activeStatus = rule.getAccountStatus(branding);
                } else if (rule.isWaitingStatus(branding)) {
                    waitingStatus = rule.getAccountStatus(branding);
                } else if (rule.isInactiveStatus(branding)) {
                    inactiveStatus = rule.getAccountStatus(branding);
                }
            }

            acc.Branding_Status__c = activeStatus != null
                                     ? activeStatus
                                     : waitingStatus != null
                                     ? waitingStatus
                                     : inactiveStatus;
        }

        update idToAccount.values();
    }

    /**
     * Normalize the account branding status value
     * @param accountIds Account to process
     */
    @future
    private static void normalizeAccountBrandingStatusFuture(Set<Id> accountIds) {
        normalizeAccountBrandingStatus(accountIds);
    }

    // maintains a cache of instantiated rules
    static Map<String, CheckForAccountUpdateWrapper> rtDevNameToRule = new Map<String, CheckForAccountUpdateWrapper>();
    static CheckForAccountUpdateWrapper getCheckForAccountUpdateRule(Map<String, Business_Config__c> config, String rtDevName) {
        if (config == null || !config.containsKey('checkForAccountUpdate')) {
            return new CheckForAccountUpdateWrapper(); // inactive rule, wont apply to any record
        }

        // parse rule and caches it
        if (!rtDevNameToRule.containsKey(rtDevName)) {
            rtDevNameToRule.put(
                rtDevName,
                (CheckForAccountUpdateWrapper) JSON.deserialize(
                    config.get('checkForAccountUpdate').Business_Rule_Value__C,
                    CheckForAccountUpdateWrapper.class)
            );
        }

        return rtDevNameToRule.get(rtDevName);
    }

    /**
     * Wrapper for 'checkForAccountUpdate' Business Config rule.
     * DO NOT instantiate directly this class, use the static method getCheckForAccountUpdateRule
     */
    class CheckForAccountUpdateWrapper {

        Boolean isActive                                                {get; set;}
        Set<String> validBrandingTypes                                  {get; set;}
        Map<String, String> inactiveStatusToAccountStatus               {get; set;}
        Map<String, String> activeStatusToAccountStatus                 {get; set;}
        Map<String, String> waitingStatusToAccountStatus                {get; set;}
        String accountStatusOnDelete                                    {get; set;}

        public CheckForAccountUpdateWrapper() {
            isActive = false;
            validBrandingTypes = new Set<String>();
            activeStatusToAccountStatus = new Map<String, String>();
            inactiveStatusToAccountStatus = new Map<String, String>();
            waitingStatusToAccountStatus = new Map<String, String>();
            accountStatusOnDelete = null;
        }

        /**
         * Checks if the rule applies to a specific Branding_Content__c record
         * @param  branding Branding_Content__c record to check
         * @return          true if rule applies to branding record, false otherwise
         */
        public Boolean appliesTo(Branding_Content__c branding) {
            return (
                       isActive
                       && validBrandingTypes.contains(branding.Type__c)
                       && (
                           isActiveStatus(branding)
                           || isInactiveStatus(branding)
                           || isWaitingStatus(branding)
                       )
                   );
        }

        public Boolean isActiveStatus(Branding_Content__c branding) {
            return activeStatusToAccountStatus.containsKey(branding.Status__c);
        }

        public Boolean isInactiveStatus(Branding_Content__c branding) {
            return inactiveStatusToAccountStatus.containsKey(branding.Status__c);
        }

        public Boolean isWaitingStatus(Branding_Content__c branding) {
            return waitingStatusToAccountStatus.containsKey(branding.Status__c);
        }

        public String getAccountStatus(Branding_Content__c branding) {
            return isActiveStatus(branding)
                   ? activeStatusToAccountStatus.get(branding.Status__c)
                   : isWaitingStatus(branding)
                   ? waitingStatusToAccountStatus.get(branding.Status__c)
                   : inactiveStatusToAccountStatus.get(branding.Status__c);
        }


    }

    public static void createBackendEntryCase(List<Branding_Content__c> newList, Map<Id, Branding_Content__c> oldMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('BrandingActivation');
        List<Case> listCase = new List<Case>();
        Set<String> caseTypes = new Set<String>();
        Map<Id, string> validBrandingIds = new Map<Id, string>();
        if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
            for (Branding_Content__C b : newList) {
                if (b.status__c != oldMap.get(b.id).status__c) {
                    Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(b.RecordTypeId));
                    if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                        Set<String> brandingStatus = new Set<String>();
                        if (mapBusinessRules.get('BrandingStatus') != null && mapBusinessRules.get('BrandingStatus').Business_Rule_Value__c != null && b.status__c == mapBusinessRules.get('BrandingStatus').Business_Rule_Value__c) {
                            if (mapBusinessRules.get('BrandingCase') != null) {
                                validBrandingIds.put(b.id, mapBusinessRules.get('BrandingCase').Business_Rule_Value__c);
                            }
                        }
                    }
                }
            }
            if (validBrandingIds != null && !validBrandingIds.isEmpty()) {
                List<Branding_Content__C> brandingContent = [select id, ownerid, opportunity__c, opportunity__r.accountid, CurrencyIsoCode from branding_content__c where id = :validBrandingIds.keyset() ];
                for (Branding_Content__C branding : brandingContent) {

                    Case cs = new Case(Opportunity__c = branding.opportunity__c, AccountId = branding.opportunity__r.AccountId, CurrencyIsoCode = branding.CurrencyIsoCode, Branding__c = branding.id, ownerid = branding.ownerid);
                    for (String fieldAndValue : (validBrandingIds.get(branding.id)).split(',')) {
                        List<String> fields = fieldAndValue.split('=');
                        cs.put(fields[0], fields[1]);
                    }
                    listCase.add(cs);

                }
                insert listCase;
            }
        }
    }

    /**
     * @description Copy Account county to brandings
     *
     * @param brandings
     */
    public static void updateRecordCountry(List<Branding_Content__c> brandings) {
        Set<Id> accountIds = ClsSObjectUtils.extractSetIds(brandings, Branding_Content__c.Restaurant_Name__c.getDescribe().getLocalName());
        Map<Id,Account> accountMap = new Map<Id, Account>(AccountSelector.getByIds(accountIds));
        for (Branding_Content__c branding: brandings) {
            if (branding.Restaurant_Name__c == null || !accountMap.containsKey(branding.Restaurant_Name__c)) {
                continue;
            }
            branding.Account_Country__c = accountMap.get(branding.Restaurant_Name__c).Record_Country__c;
        }
    }
}