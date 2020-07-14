public without sharing class ClsCaseProcessor {
    @TestVisible
    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    public static Boolean donotValidateOppStage = false;
    public static Boolean talabatFlag = false;
    private static final String STATUS_CLOSED = 'Closed';
    private static final String TYPE_QC = 'Quality Check';
    private static final String CLOSED_REASON = 'Successful';
    public static Boolean apprCheck = false;

    /**
    * Method to fetch the contactId with Role = Owner when a new case gets inserted.
    * @param : cases : set cases to check if child exists,
    * @return : Map of child cases of each parent case id
    */
    public static Map<Id, Id> fetchOwnerInfo(List<Case> cases) {

        Map<Id, Id> caseIdOwnerMap = new Map<Id, Id>();
        Set<Id> accIdSet = new Set<Id>();
        for(Case newCase : cases) {
            if(String.isNotBlank(newCase.AccountId))
                accIdSet.add(newCase.AccountId);
        }

        if(!accIdSet.isEmpty()) {
            for(Contact con : ContactSelector.fetchContactsWithOwnerRole(accIdSet)) {
                if(null != con.AccountContactRelations && !con.AccountContactRelations.isEmpty()) {
                    if(String.isNotBlank(con.AccountId) && !caseIdOwnerMap.containsKey(con.AccountId))
                        caseIdOwnerMap.put(con.AccountId, con.AccountContactRelations[0].ContactId);
                }
            }
        }
        return caseIdOwnerMap;
    }

    /**
    * Method to populate the contactId with Role = Owner when a new case gets inserted.
    * @param : cases : set cases to check if child exists,
    * @param : Map<Id, Id>
    * @return : Map of child cases of each parent case id
    */
    public static void populateContactOwnerIdOnCase(List<Case> cases, Map<Id, Id> contactOwnerIdMap) {

        Map<Id, Id> caseIdOwnerMap = new Map<Id, Id>();
        Set<Id> accIdSet = new Set<Id>();

        for(Case newCase : cases) {
            if(String.isNotBlank(newCase.AccountId) && null != contactOwnerIdMap && contactOwnerIdMap.containsKey(newCase.AccountId))
                newCase.ContactId = contactOwnerIdMap.get(newCase.AccountId);
        }
    }

    /**
    * 
    *JIRA: SP-394
    *update: process did not check if parent case gets closed, so the process run at every update, causing duplicate cases
    *        changed signature to use Trigger.newMap and Trigger.oldMap to see if parent case got closed
    * @param : caseLst : Tigger.new()
    *		   oldMAp : Tigger.oldMap()
    * @return : void
    *
    **/
    @TestVisible
    public static void retentionCaseFlow(List<case> caseLst, Map<Id, Case> oldMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('RetentionCaseFlow');
        Map<Case, Map<String, Business_Config__c>> caseConfigMap = new Map<Case, Map<String, Business_Config__c>>();
        if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) {
            return;
        }
        for (Case c : caseLst) {
            if (c.isclosed && !oldMap.get(c.id).isclosed && c.type == 'Retention') {
                Map<String, Business_Config__c> mapBusinessRule =
                        mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(c.RecordTypeId));
                if (mapBusinessRule == null || mapBusinessRule.isEmpty()) {
                    continue;
                }
                //filter cases to create online/offline case
                caseConfigMap.put(c, mapBusinessRule);

            }
        }

        if (!caseConfigMap.isEmpty()) {
            Map<Id, List<Case>> childCaseMap = getChildCases(caseConfigMAp.keySet());
            createTakeOnlineOfflineCase(caseConfigMap, childCaseMap);
        }

    }


    /**
    * No ** clue why we check for child cases or if any will exists?
    * @param : cases : set cases to check if child exists
    * @return : Map of child cases of each parent case id
    */
    @TestVisible
    private static Map<Id, List<Case>> getChildCases(Set<Case> cases) {
        Map<Id, List<Case>> caseMap = new Map<Id, List<Case>>();
        List<Case> caseLst = [SELECT Id, Type, ParentId, Closed_Reason__c FROM Case WHERE ParentId IN :cases];
        for (Case ca : caseLst) {
            if (caseMap.containsKey(ca.ParentId)) {
                caseMap.get(ca.ParentId).add(ca);
            } else {
                caseMap.put(ca.ParentId, new List<Case>{
                        ca
                });
            }
        }
        return caseMap;
    }

    /**
    * check if child case exists
    * @param :  caseMap : Map of child cases
    *			cc : parent case
    * 			type : type of child case to check
    *			closedReason : closed reason of child case to compare
    *
    * @return : Boolean : true if there is no child case
    */
    @TestVisible
    private static Boolean doesChildExists(Map<Id, List<Case>> caseMap, Case cc, String typ, String closedReason) {
        Boolean childDoesNotExist = true;
        if (caseMap.containsKey(cc.Id)) {
            for (Case c : caseMap.get(cc.Id)) {
                if (c.Type.equals(typ) || (c.Closed_Reason__c != null && c.Closed_Reason__c.equals(closedReason))) {
                    childDoesNotExist = false;
                    break;
                }
            }
        }//if the case is a child of some other case
        if (cc.ParentId != null && caseMap.containsKey(cc.ParentId)) {
            for (Case c : caseMap.get(cc.ParentId)) {
                if (c.Type.equals(typ) || (c.Closed_Reason__c != null && c.Closed_Reason__c.equals(closedReason))) {
                    childDoesNotExist = false;
                    break;
                }
            }
        }
        return childDoesNotExist;
    }


    /**
    * Create take online / offline case depending on the closed reason
    * @param : caseConfigMap : map of cases and respective config
    *		   caseMap : Map of child cases
    * @return : void
    */
    @TestVisible
    private static void createTakeOnlineOfflineCase(Map<Case, Map<String, Business_Config__c>> caseConfigMap, Map<Id, List<Case>> childCaseMap) {
        List<Case> listCasesToInsert = new List<Case>();

        for (Case c : caseConfigMap.keySet()) {
            List<String> fieldsToCopy = new List<String>();
            Map<String, Business_Config__c> mapBusinessRule = caseConfigMap.get(c);
            if (mapBusinessRule.containsKey('FieldsToCopy')) {
                fieldsToCopy = mapBusinessRule.get('FieldsToCopy').Business_Rule_Value__c.split(',');
            }
            //If case is closed unsuccessful create 'Take Offline' Case
            if (c.Closed_Reason__c == mapBusinessRule.get('closingReasonUnsuccesful').Business_Rule_Value__c) {
                //Check for child cases
                Boolean createTakeOfflineCase = doesChildExists(childCaseMap, c, mapBusinessRule.get('takeOfflineCaseType').Business_Rule_Value__c, null);

                //get the take offline case fields values from config
                if (createTakeOfflineCase) {
                    Map<String, String> caseDetails =
                            (Map<String, String>) JSON.deserialize(mapBusinessRule.get('TakeOfflineCase').Business_Rule_Value__c, Map<String, String>.class);
                    listCasesToInsert.add(createNewCase(caseDetails, fieldsToCopy, c, true));

                }
            }//If the case is closed successfully create 'Take Online' Case
            else if (c.Closed_Reason__c == mapBusinessRule.get('closingReasonSuccessful').Business_Rule_Value__c
                    && mapBusinessRule.containsKey('TakeOnlineCase')) {

                Map<String, String> caseDetails =
                        (Map<String, String>) JSON.deserialize(mapBusinessRule.get('TakeOnlineCase').Business_Rule_Value__c, Map<String, String>.class);
                listCasesToInsert.add(createNewCase(caseDetails, fieldsToCopy, c, true));


            }
        }


        if (!listCasesToInsert.isEmpty()) {
            //try{
            insert listCasesToInsert;

            //}catch(Exception e){
            // System.debug('Exception: ' + e.getMessage());

            //}
        }
    }


    /**
    * Create a new case
    * @param : caseDetails : map of case field values
    *		   fieldsToCopy : List from configs
    *		   C  case
    *		   isParent : true if the case id is parent id of new case
    * @return : Case
    */
    private static Case createNewCase(Map<String, String>caseDetails, List<String> fieldsToCopy, Case c, Boolean isParent) {
        Case newCase = new Case(
                RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(caseDetails.get('Recordtype')),
                Status = caseDetails.get('CaseStatus'),
                Origin = caseDetails.get('CaseOrigin'),
                Subject = caseDetails.get('CaseSubject'),
                Type = caseDetails.get('CaseType'),
                Case_Reason__c = caseDetails.get('CaseReason')

        );

        if (isParent) {
            newCase.ParentId = c.ParentId;
        } else {
            newCase.ParentId = c.Id;
        }
        if (!fieldsToCopy.isEmpty()) {
            for (String str : fieldsToCopy) {
                newCase.put(str, c.get(str));
            }
        }
        return newCase;
    }

    /**
    *
    * JIRA: SP-394
    * update: process did not check if parent case gets closed, so the process run at every update, causing duplicate cases
    *       changed signature to use Trigger.newMap and Trigger.oldMap to see if parent case got closed
    *        (if(mapOld.get(cl.Id).isClosed != cl.IsClosed && cl.isClosed == true ))
    */
    public static void terminationCaseFlow(List<Case> caseLst, Map<Id, Case> oldMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('TerminationCaseFlow');
        Map<Case, Map<String, Business_Config__c>> caseConfigMap = new Map<Case, Map<String, Business_Config__c>>();

        if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) {
            return;
        }

        for (Case c : caseLst) {

            if (c.isclosed && !oldmap.get(c.id).isClosed && c.closed_reason__c != null) {
                Map<String, Business_Config__c> mapBusinessRule =
                        mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(c.RecordTypeId));

                if (mapBusinessRule == null) {
                    continue;
                }
                if (c.Type == mapBusinessRule.get('Type').Business_Rule_Value__c) {
                    caseConfigMap.put(c, mapBusinessRule);

                }

            }

        }
        if (!caseConfigMap.isEmpty()) {
            Map<Id, List<Case>> caseMap = getChildCases(caseConfigMAp.keySet());
            createTakeOfflineRetentionCase(caseConfigMap, caseMap);
        }
    }

    private static void createTakeOfflineRetentionCase(Map<Case, Map<String, Business_Config__c>> caseConfigMap, Map<Id, List<Case>> caseMap) {
        List<Case> listCasesToInsert = new List<Case>();

        for (Case c : caseConfigMap.keySet()) {
            List<String> fieldsToCopy = new List<String>();

            Map<String, Business_Config__c> mapBusinessRule = caseConfigMap.get(c);
            if (mapBusinessRule.containsKey('FieldsToCopy')) {
                fieldsToCopy = mapBusinessRule.get('FieldsToCopy').Business_Rule_Value__c.split(',');
            }
            if (c.Closed_Reason__c == mapBusinessRule.get('createRetentionCaseClosingReason').Business_Rule_Value__c) {
                Boolean createTakeOfflineCase =
                        doesChildExists(caseMap, c, mapBusinessRule.get('RetentionCaseType').Business_Rule_Value__c, mapBusinessRule.get('createRetentionCaseClosingReason').Business_Rule_Value__c);

                if (createTakeOfflineCase) {
                    Map<String, String> caseDetails =
                            (Map<String, String>) JSON.deserialize(mapBusinessRule.get('RetentionCase').Business_Rule_Value__c, Map<String, String>.class);
                    listCasesToInsert.add(createNewCase(caseDetails, fieldsToCopy, c, false));

                }
            } else if (c.Closed_Reason__c == mapBusinessRule.get('createTakeOfflineCaseClosingReason').Business_Rule_Value__c) {
                Boolean createTakeOfflineCase = doesChildExists(caseMap, c,
                        mapBusinessRule.get('TakeOfflineCaseType').Business_Rule_Value__c,
                        mapBusinessRule.get('createTakeOfflineCaseClosingReason').Business_Rule_Value__c);

                if (createTakeOfflineCase) {
                    Map<String, String> caseDetails =
                            (Map<String, String>) JSON.deserialize(mapBusinessRule.get('TakeOffline').Business_Rule_Value__c,
                                    Map<String, String>.class);
                    listCasesToInsert.add(createNewCase(caseDetails, fieldsToCopy, c, false));
                }

            }
        }

        if (!listCasesToInsert.isEmpty()) {
            try {
                insert listCasesToInsert;
            } catch (Exception e) {
                System.debug('Exception :' + e.getMessage());

            }

        }
    }



    /**
    * Actions performed when Menu processing case is closed
    * @param
    *   caseList: List of new Trigger values
    *    mapOldCase:  Map of old trigger values
    * @return void
    *
    */
    public static void menuProcessingClosingAction(List<Case> caseList, Map<Id, Case> mapOldCase) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('MenuProcessingClosingAction');

        Map<Case,Map<String, Business_Config__c>> caseConfigMap = new Map<Case,Map<String, Business_Config__c>>();
        Map<Id,Case> caseAccountMap 			= new Map<Id,Case>();
        Set<Id> oppToCheckForAddon 				= new Set<Id>();
        Set<Id> chkOrderTested 					= new Set<Id>();
        Set<Id> opptoCheckForOpenPhotoListing	= new Set<Id>();
        Set<Id> oppWithOpenPhotoListingCases	= new Set<Id>();
        Set<Id> oppWithInactive = new Set<Id>();


        Set<Id> oppWithInactiveAsset = new Set<Id>();
        Set<Id> oppWithUninstalledBranding = new Set<Id>();
        Set<Id> oppWithInactiveAddon = new Set<Id>();
        set<id> oppWithUndeliveredShipments = new Set<Id>();


        Set<Id> hasToCheckAssets = new Set<Id>();
        Set<Id> hasToCheckBrandings = new Set<Id>();
        Set<Id> hasToCheckAddon = new Set<Id>();
        set<id> hasToCheckShipments = new Set<id>();

        Set<Id> brandingOppsToCheck = new Set<Id>();
        Set<Id> assetOppsToCheck = new Set<Id>();
        Set<Id> addonOppsToCheck = new Set<Id>();
        Set<id> ShipmentsOppsToCheck = new set<id>();

        if (mapBusinessLogic == null) {
            return;
        }

        set<String> stStatusAssets;
        set<String> stStatusBranding;

        Map<String, Map<String, Business_Config__c>> mapBusinessStatus = moam.get('StatusObjectsByStage');
        if(mapBusinessStatus!= null){
            if(mapBusinessStatus.ContainsKey('General_Config')){
                Map<String, Business_Config__c> mapBusinessRuleStatus = mapBusinessStatus.get('General_Config');

                if(mapBusinessRuleStatus.containskey('AssetStatusMenuProcesing')){
                    stStatusAssets =  (set<String>)System.JSON.deserialize(mapBusinessRuleStatus.get('AssetStatusMenuProcesing').Business_Rule_Value__c, set<String>.class);
                }
                if(mapBusinessRuleStatus.containskey('BrandingStatusMenuProcesing')){
                    stStatusBranding =  (set<String>)System.JSON.deserialize(mapBusinessRuleStatus.get('BrandingStatusMenuProcesing').Business_Rule_Value__c, set<String>.class);

                }

            }

        }

        for (Case cs : caseList) {
            if (cs.type == 'Menu Processing'
                    && cs.isclosed
                    && !mapOldCase.get(cs.id).isclosed
                    && cs.Opportunity__c != null) {
                Map<String, Business_Config__c> mapBusinessRule =
                        mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(cs.RecordTypeId));

                if (mapBusinessRule == null) {
                    continue;
                }
                //Check for Account tested - applicable for countries without onboarding
                if (mapBusinessRule.containsKey('Check for Is_Tested__c')
                        && Boolean.valueOf(mapBusinessRule.get('Check for Is_Tested__c').Business_Rule_Value__c)
                        && cs.Accountid != null) {
                    chkOrderTested.add(cs.id);
                }
                // should check assets status before changing stage name
                if (mapBusinessRule.containsKey('chkAssetStatus')
                        && Boolean.valueOf(mapBusinessRule.get('chkAssetStatus').Business_Rule_Value__c)) {
                    assetOppsToCheck.add(cs.Opportunity__c);
                    hasToCheckAssets.add(cs.Id);
                }

                // should check assets status before changing stage name
                if (mapBusinessRule.containsKey('chkShipmentStatus')
                        && Boolean.valueOf(mapBusinessRule.get('chkShipmentStatus').Business_Rule_Value__c)) {
                    ShipmentsOppsToCheck.add(cs.Opportunity__c);
                    hasToCheckShipments.add(cs.Id);
                }

                // should check branding before changing stage name
                if (mapBusinessRule.containsKey('chkBrandingStatus')
                        && Boolean.valueOf(mapBusinessRule.get('chkBrandingStatus').Business_Rule_Value__c)) {
                    brandingOppsToCheck.add(cs.Opportunity__c);
                    hasToCheckBrandings.add(cs.Id);
                }
                // check for pending addons
                if (mapBusinessRule.containsKey('CheckForAddon')
                        && Boolean.valueOf(mapBusinessRule.get('CheckForAddon').Business_Rule_Value__c)) {
                    addonOppsToCheck.add(cs.Opportunity__c);
                    hasToCheckAddon.add(cs.Id);
                }
                if (mapBusinessRule.containsKey('CheckForPhotoListingCase')) {
                    opptoCheckForOpenPhotoListing.add(cs.Opportunity__c);
                }

                caseConfigMap.put(cs, mapBusinessRule);
            }
        }

        //Fetch accounts to check if order tested
        if (!chkOrderTested.isEmpty()) {
            caseAccountMap = orderTestedAccountDetails(chkOrderTested);
        }//For Countries without Onboarding check for open addons if any!
        // get inactive assets, branding & addons
        if (!assetOppsToCheck.isEmpty()) {
            oppWithInactiveAsset = LibHelper.checkForInactiveAsset(assetOppsToCheck,stStatusAssets);
        }
        if (!ShipmentsOppsToCheck.isEmpty()) {
            oppWithUndeliveredShipments = LibHelper.checkForUndeliveredShipments(ShipmentsOppsToCheck);
        }
        if(!brandingOppsToCheck.isEmpty()){
            oppWithUninstalledBranding = LibHelper.checkForUninstalledBranding(brandingOppsToCheck,stStatusBranding);
        }
        if(!addonOppsToCheck.isEmpty()){
            oppWithInactiveAddon=LibHelper.checkForNonActiveAddon(addonOppsToCheck);
        }
        // Check for the completion of Photo Listing cases
        if (!opptoCheckForOpenPhotoListing.isEmpty()) {
            oppWithOpenPhotoListingCases = Libhelper.checkForOpenPhotoListingCases(opptoCheckForOpenPhotoListing);
        }


        for(Case cs:caseConfigMap.keySet()) {
            If ((hasToCheckAssets.contains(cs.Id) && oppWithInactiveAsset.contains(cs.Opportunity__c))
                    || (hasToCheckShipments.contains(cs.Id) && oppWithUndeliveredShipments.contains(cs.Opportunity__c))
                    || (hasToCheckBrandings.contains(cs.Id) && oppWithUninstalledBranding.contains(cs.Opportunity__c))
                    || (hasToCheckAddon.contains(cs.Id) && oppWithInactiveAddon.contains(cs.Opportunity__c))) {
                oppWithInactive.add(cs.Opportunity__c);
            }
        }


        chkOrderTested.clear();
        oppToCheckForAddon.clear();
        if (!caseConfigMap.isEmpty()) {
            updateOppOnMenuProcessingClosure(caseConfigMap, CaseAccountMap, oppWithInactive, oppWithOpenPhotoListingCases);
        }

    }

    //For Countries without onboarding
    @TestVisible
    private static Map<Id, Case> orderTestedAccountDetails(Set<Id> chkOrderTested) {
        return(new Map<Id, Case>([
                SELECT Id,
                        Account.Is_Tested__c,Opportunity__r.StageName
                FROM case
                WHERE Id IN:chkOrderTested
        ]));
    }

    /**
    * Update opportunity depending on the closing reason of the MP case
    * @param
    *   caseConfigMap: Map of case and related config
    *   CaseAccountMap:  Map of accounts to check is tested
    * @return void
    *
    */

    private static void updateOppOnMenuProcessingClosure(Map<Case, Map<String, Business_Config__c>> caseConfigMap,
            Map<id, Case> CaseAccountMap, Set<Id> oppwithInactive, Set<Id> oppWithOpenPhotoListingCases) {
        List<Opportunity> updateOppList = new List<Opportunity>();
        for (Case c : caseConfigMap.keySet()) {

            Map<String, Business_Config__c> mapBusinessRule = caseConfigMap.get(c);
            Map<String, String> ClosedReason =
                    (Map<String, String>) JSON.deserialize(mapBusinessRule.get('ClosedReason').Business_Rule_Value__c,
                            Map<String, String>.class);

            Set<String> positiveReason = new Set<String>();
            Set<String> negativeReason = new Set<String>();

            positiveReason.addAll(ClosedReason.get('Positive').split(','));
            negativeReason.addAll(ClosedReason.get('Negative').split(','));

            //Check if the case is closed positive and account is order tested if applicable
            if (((CaseAccountMap == null || CaseAccountMap.isEmpty())
                    || (CaseAccountMap.containsKey(c.id)
                    && CaseAccountMap.get(c.id).Account.is_tested__c))
                    && (oppwithInactive.isEmpty()
                    || !oppwithInactive.contains(c.opportunity__c))
                    && (oppWithOpenPhotoListingCases.isEmpty()
                    || !oppWithOpenPhotoListingCases.contains(c.opportunity__c))
                    && positiveReason.contains(c.Closed_Reason__c)) {

                updateOppList.add(setOppIdStage(c.opportunity__c,
                        mapBusinessRule.get('PositiveStageName').Business_Rule_Value__c));
                // if the case is closed negative update opp stage to negative case closing stage
            }else if(oppwithInactive.contains(c.opportunity__c)){

                if(mapBusinessRule.containskey('InactiveStageName')
                        && (oppWithOpenPhotoListingCases.isEmpty() || !oppWithOpenPhotoListingCases.contains(c.opportunity__c))
                        && !negativeReason.contains(c.Closed_Reason__c) ){
                    updateOppList.add(setOppIdStage(c.opportunity__c,
                            mapBusinessRule.get('InactiveStageName').Business_Rule_Value__c));
                }else if(negativeReason.contains(c.Closed_Reason__c)){
                    updateOppList.add(setOppIdStage(c.opportunity__c,
                            mapBusinessRule.get('NegativeStageName').Business_Rule_Value__c));
                }
            }else if(negativeReason.contains(c.Closed_Reason__c)){
                updateOppList.add(setOppIdStage(c.opportunity__c,
                        mapBusinessRule.get('NegativeStageName').Business_Rule_Value__c));

            }
        }


        if (!updateOppList.isEmpty()) {
            update updateOppList;

        }
    }

    /**
    * Update case Age
    * @param
    *   newCsLst: Trigger.new
    *   oldCsMap:  Trigger.oldMap
    * @return void
    *
    */
    public static void updateCaseAge(List<Case> newCsLst, Map<id, Case>oldCsMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('updateDueDateForCase');
        if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) {
            return;
        }

        for (Case c : newCsLst) {
            Set<String> recordtypes = new Set<string>();
            Set<String> casetype = new Set<string>();
            Set<String> casetypeUpd = new Set<string>();
            String rtDevName = LibRecordTypeHelper.getRecordTypeValue(c.recordtypeid);
            Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(rtDevName);

            if (mapBusinessRule == null || mapBusinessRule.isEmpty()) {
                continue;
            }
            if (mapBusinessRule.containsKey('recordtypesOnCreate')) {
                recordtypes = new Set<String>((mapBusinessRule.get('recordtypesOnCreate').Business_Rule_Value__c).split(','));

            }if (mapBusinessRule.containsKey('casetypeOnCreate')) {
                casetype = new Set<String>((mapBusinessRule.get('casetypeOnCreate').Business_Rule_Value__c).split(','));

            }if (mapBusinessRule.containsKey('casetypeOnUpd')) {
                casetypeUpd = new Set<String>((mapBusinessRule.get('casetypeOnUpd').Business_Rule_Value__c).split(','));

            }if ((c.recordtypeid != oldCsMap.get(c.id).recordtypeid
                    || c.type != oldCsMap.get(c.id).type
                    || c.status != oldCsMap.get(c.id).status)
                    && (mapBusinessRule.get('MenuChangeCaseStatus') != null
                    && c.status == mapBusinessRule.get('MenuChangeCaseStatus').Business_Rule_Value__c
                    && casetypeUpd.contains(c.type)
                    && recordtypes.contains(LibRecordTypeHelper.getRecordTypeValue(c.recordtypeid)))) {
                c.menu_Change_date__c = datetime.now();

                // should calculate menu age?
            }if (oldCsMap.get(c.id).status == mapBusinessRule.get('CaseStatus').Business_Rule_Value__c
                    && recordtypes.contains(LibRecordTypeHelper.getRecordTypeValue(c.recordtypeid))) {

                Datetime startDate, endDate;

                // menu change or created date?
                if (c.menu_Change_date__c == null && casetype.contains(c.type)) {
                    // menu not changed
                    startDate = c.CreatedDate;
                    endDate = rtDevName.startsWith('UK') ? c.First_Check_Date__c : c.Menu_Typed_Date__c;
                } else if (c.Menu_Change_Date__c != null
                        && c.status != oldCsMap.get(c.id).status
                        && casetypeUpd.contains(c.type)) {
                    // menu changed
                    startDate = c.Menu_Change_Date__c;
                    endDate = rtDevName.startsWith('UK') ? c.First_Check_Date__c : c.Menu_Typed_Date__c;
                }

                // checks if has to update formula
                if (startDate != null && endDate != null) {
                    c.Menu_Type_Age__c = menuAgeAmazingFormula(startDate, endDate);
                }
            }

        }
    }


    /**
    * Update case Age
    * @param
    *   startDate:
    *   endDate:
    * @return  Returns number of hours between start and end excluding weekends
    *
    */
    @TestVisible
    private static Integer menuAgeAmazingFormula(Datetime startDate, Datetime endDate) {
        Long res;

        Long startTime = startDate.getTime();
        Long endTime = endDate.getTime();
        Long startDays = startTime / (3600000);
        Long endDays = endTime / (3600000);
        endDays = Math.mod(endDays, 24);
        startDays = Math.mod(startDays, 24);

        Date magicDate = Date.newInstance(1996, 01, 01);

        res = Math.abs(Math.round(24 * ((5 * math.FLOOR((DATE.valueOf(endDate).daysBetween(magicDate)) / 7)
                + math.min(5, math.mod(DATE.valueOf(endDate).daysBetween(magicDate), 7)))
                - (5 * Math.FLOOR((DATE.valueOf(startDate).daysBetween(magicDate)) / 7)
                + math.min(5, math.mod(DATE.valueOf(startDate).daysBetween(magicDate), 7))))));

        if (res == 24) {
            res = (24 - startDays) + endDays;
        } else {
            res += (24 - startDays) + endDays;
            res = Math.abs(res - 24);
        }

        // amaaaaazing isn't it?
        return res.intValue();

    }


    /**
    * Update account Backend online status on each case Age SP-706
    * @param
    *   newMap:
    *   oldMap:
    * @return
    *
    */
    public static void updateAccountOnlineStatus(List<Case> caseLst, Map<Id, Case> oldMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('MenuProcessingAccountUpdate');
        Map<Case, Map<String, Business_Config__c>> caseConfigMap = new Map<Case, Map<String, Business_Config__c>>();
        Set<Id>setAccountIds = new Set<Id>();
        if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) {
            return;
        }
        for (Case c : caseLst) {
            Map<String, Business_Config__c> mapBusinessRule =
                    mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(c.RecordTypeId));

            if (mapBusinessRule == null || mapBusinessRule.isEmpty()) {
                continue;
            }
            Set<String> listCaseType = new set<string>(mapBusinessRule.get('Type').Business_Rule_Value__c.split(','));

            if (listCaseType.contains(c.type) &&
                    (oldMap == null && c.type != null
                            && c.AccountID != null)
                    || (oldMap != null && oldMap.containsKey(c.id)
                    && c.status != oldmap.get(c.id).status)) {

                setAccountIds.add(c.AccountId);
                caseConfigMap.put(c, mapBusinessRule);

            }

        }
        if (!setAccountIds.isEmpty()) {
            Map<Id, Account> accMap = getAccountInfo(setAccountIds);
            updateAccountStatus(caseConfigMap, accMap, oldMap);

        }

    }


    private static void updateAccountStatus(Map<Case, Map<String, Business_Config__c>> caseConfigMap,
            Map<id, Account> accMap, Map<Id, Case> oldMap) {
        List<Account> accToUpdLst = new List<Account>();

        for (Case c : caseConfigMap.keySet()) {
            Set<String> setStatusValues = new Set<String>();
            Map<String, Integer> orderMap = new Map<String, Integer>();
            Map<String, String> caseAccountStatusMap = new Map<String, String>();
            Account theAccount = accMap.get(c.accountid);

            Map<String, Business_Config__c> mapBusinessRule = caseConfigMap.get(c);


            if (mapBusinessRule.containsKey('statusValues')) {
                setStatusValues = new Set<String>(mapBusinessRule.get('statusValues').Business_Rule_Value__c.split(','));

            }if (mapBusinessRule.containsKey(c.Type + 'CaseAccountStatusMap')) {
                caseAccountStatusMap =
                        (Map<String, String>) JSON.deserialize(mapBusinessRule.get(c.type + 'CaseAccountStatusMap').Business_Rule_Value__c,
                                Map<String, String>.class);

            }if (mapBusinessRule.containsKey('orderMap')) {
                orderMap =
                        (Map<String, Integer>) JSON.deserialize(mapBusinessRule.get('orderMap').Business_Rule_Value__c,
                                Map<String, Integer>.class);

            }

            if (c.isClosed && mapBusinessRule.containsKey(c.Type + ' closingStatus')
                    && c.Closed_Reason__c == mapBusinessRule.get(c.Type + ' closingStatus').Business_Rule_Value__c
                    && theAccount.Online_Status_Backend__c != caseAccountStatusMap.get(c.status)
                    && checkIfStatusIsProgressing(theAccount.Online_Status_Backend__c,
                    caseAccountStatusMap.get(c.status), orderMap)) {

                theAccount.Online_Status_Backend__c = caseAccountStatusMap.get(c.status);
                accToUpdLst.add(theAccount);
            } else if (caseAccountStatusMap.containsKey(c.status)
                    && theAccount.Online_Status_Backend__c != caseAccountStatusMap.get(c.status)
                    && checkIfStatusIsProgressing(theAccount.Online_Status_Backend__c,
                    caseAccountStatusMap.get(c.status), orderMap)) {
                theAccount.Online_Status_Backend__c = caseAccountStatusMap.get(c.status);
                accToUpdLst.add(theAccount);
            }


        }
        if (!accToUpdLst.isEmpty()) {
            update accToUpdLst;
        }
    }

    private static Map<Id, Account> getAccountInfo(Set<Id> accountIds) {
        return(new Map<Id, Account>([
                SELECT Id,
                        Online_Status_Backend__c
                FROM Account
                WHERE Id IN:accountIds
        ]));

    }

    //helper method for 'updateAccountOnlineStatusByMenuProcessing' SP-706
    private static boolean checkIfStatusIsProgressing(String oldStatus, String newStatus, Map<String, Integer> theMap) {
        Boolean result = false;

        if (theMap.get(oldStatus) == null && theMap.get(newStatus) != null) {
            System.debug('entered branch 1');
            result = true;
        } else if (theMap.get(oldStatus) != null && theMap.get(newStatus) == null) {
            System.debug('entered branch 2');
            result = false;
        } else if (theMap.get(oldStatus) != null && theMap.get(newStatus) != null) {
            System.debug('entered branch 3');
            if (theMap.get(oldStatus) != 6 && theMap.get(newStatus) == 0) {
                System.debug('entered branch 3.2');
                result = true;
            } else if (theMap.get(oldStatus) < theMap.get(newStatus)) {
                System.debug('entered branch 3.3');
                result = true;
            } else {
                System.debug('entered branch 3.4');
                result = false;
            }
        }
        return result;

    }


    /**
    * Actions performed when Non contracted menu processing case is closed
    * Used only for Korea
    * @param
    *   caseList: List of new Trigger values
    *   mapOldCase:  Map of old trigger values
    * @return void
    */
    public static void nonContractedMenuProcessingClosingAction(List<Case> caseList, Map<Id, Case> mapOldCase) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('NonContractedMPClosingAction');

        if (mapBusinessLogic == null) {
            return;
        }

        List<Opportunity> updateOppList = new List<Opportunity>();
        Set<Case> caseSet = new Set<Case>();
        for (Case cs : caseList) {
            if (cs.opportunity__c != null
                    && cs.isclosed
                    && !mapoldcase.get(cs.id).isclosed
                    && cs.type == 'Menu Processing') {
                Map<String, Business_Config__c> mapBusinessRule =
                        mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(cs.RecordTypeId));
                if (mapBusinessRule == null) {
                    continue;
                }
                //caselst to fetch opp stage name and non contracted field on opp for KR
                caseSet.add(cs);
            }
        }

        if (!caseSet.isEmpty()) {
            for (Case cs : [
                    SELECT id,
                            Opportunity__r.Non_Contracted__c,
                            Opportunity__r.StageName,
                            Opportunity__c,
                            recordtype.developername,
                            Closed_Reason__c
                    FROM Case
                    WHERE Id IN :caseSet
            ]) {


                Map<String, Business_Config__c> mapBusinessRule =
                        mapBusinessLogic.get(cs.Recordtype.developername);

                if (mapBusinessRule == null) {
                    continue;
                }
                if (cs.Opportunity__r.Non_Contracted__c ==
                        Boolean.valueOf(mapBusinessRule.get('Non_Contracted__c').Business_Rule_Value__c)
                        && cs.Opportunity__r.stageName ==
                        mapBusinessRule.get('StageName').Business_Rule_Value__c) {


                    Set<String> skipStages = new Set<String>();

                    if (mapBusinessRule.containsKey('SkipForStage')) {
                        skipStages.addAll(mapBusinessRule.get('SkipForStage').Business_Rule_Value__c.split(','));
                    }
                    if (!skipStages.contains(cs.Opportunity__r.StageName)) {
                        Set<String> positiveReason = new Set<String>();
                        Set<String> negativeReason = new Set<String>();

                        Map<String, String> ClosedReason =
                                (Map<String, String>) JSON.deserialize(mapBusinessRule.get('ClosedReason').Business_Rule_Value__c,
                                        Map<String, String>.class);

                        positiveReason.addAll(ClosedReason.get('Positive').split(','));
                        negativeReason.addAll(ClosedReason.get('Negative').split(','));

                        if (positiveReason.contains(cs.Closed_Reason__c)
                                && mapBusinessRule.containsKey('PositiveStageName')) {
                            updateOppList.add(setOppIdStage(cs.opportunity__c,
                                    mapBusinessRule.get('PositiveStageName').Business_Rule_Value__c));

                        } else if (negativeReason.contains(cs.Closed_Reason__c)
                                && mapBusinessRule.containsKey('NegativeStageName')) {
                            Opportunity opp =
                                    setOppIdStage(cs.opportunity__c,
                                            mapBusinessRule.get('NegativeStageName').Business_Rule_Value__c);

                            if (opp.stageName == 'Closed Lost') {
                                opp.Lost_Reason__c =
                                        mapBusinessRule.get('LostReasonIfOppClosedLost').Business_Rule_Value__c;
                            }
                            updateOppList.add(opp);

                        }

                    }
                }

            }try {
                if (!updateOppList.isEmpty()) {
                    update updateOppList;
                }
            } catch (Exception e) {
                caseList[0].addError(e.getMessage());
                System.debug('Exception: ' + e.getMessage());
            }
        }

    }
    /**
	* used by UK & SE not sure if we will continue using this process!!
	*
	*/

    public static void qualityCheckReplacementClosingAction(List<Case> caseList, Map<Id, Case> mapOldCase) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('QCReplacementClosingAction');
        Map<Id, String> oppIdWithRStatus = new Map<Id, String>();
        Map<Id, Boolean> mapOppWithOnboarding = new Map<Id, Boolean>();
        Map<Id, String> mapOppWithONBoardData = new Map<Id, String>();
        Map<Id, Id> mapOppAccount = new Map<Id, Id>();
        Map<Id, Opportunity> updateOppStage = new Map<Id, Opportunity>();
        List<Id> caseIds = new List<Id>();

        if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) {
            return;
        }

        for (Case c : caseList) {
            if (c.type == 'Quality Check Replacement'
                    && c.isClosed
                    && !mapOldCase.get(c.id).isClosed
                    && c.Opportunity__c != null) {

                Map<String, Business_Config__c> mapBusinessRule =
                        mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(c.RecordTypeId));

                if (mapBusinessRule == null || mapBusinessRule.isEmpty()) {
                    continue;
                }

                Map<String, String> closedReason =
                        (Map<String, String>) JSON.deserialize(mapBusinessRule.get('ClosingReason').Business_Rule_Value__c,
                                Map<String, String>.class);

                Set<String> positiveReason = new Set<String>(closedReason.get('Positive').split(','));
                Set<String> negativeReason = new Set<String>(closedReason.get('Negative').split(','));

                if (positiveReason.contains(c.Closed_Reason__c)) {
                    if (mapBusinessRule.containsKey('PositiveRepStatus')) {
                        oppIdWithRStatus.put(c.Opportunity__c,
                                mapBusinessRule.get('PositiveRepStatus').Business_Rule_Value__c);
                        if (mapBusinessRule.containsKey('OnboardingCase')) {
                            mapOppWithONBoardData.put(c.Opportunity__c,
                                    mapBusinessRule.get('OnboardingCase').Business_Rule_Value__c);
                        } else {
                            mapOppWithONBoardData.put(c.Opportunity__c, null);
                        }
                        mapOppAccount.put(c.Opportunity__c, c.AccountId);
                    } else if (negativeReason.contains(c.Closed_Reason__c)) {
                        if (mapBusinessRule.containsKey('NegativeRepStatus')) {
                            oppIdWithRStatus.put(c.Opportunity__c,
                                    mapBusinessRule.get('NegativeRepStatus').Business_Rule_Value__c);
                            if (mapBusinessRule.containsKey('NegativeStageName')) {
                                caseIds.add(c.Id);
                                updateOppStage.put(c.Opportunity__c, setOppIdStage(c.Opportunity__c,
                                        mapBusinessRule.get('NegativeStageName').Business_Rule_Value__c));
                            }
                        }
                    }

                }


            }
        }
        if (!updateOppStage.isEmpty()) {
            for (Case cs : [SELECT id, Opportunity__c, Opportunity__r.StageName FROM Case WHERE id IN :caseIds]) {
                if (cs.Opportunity__r.StageName == 'Closed Won' || cs.Opportunity__r.StageName == 'Closed Lost') {
                    updateOppStage.remove(cs.Opportunity__c);
                }
            }
        }


        List<Case> onboardingCs = new List<Case>();
        if (!oppIdWithRStatus.isEmpty()) {
            for (Case cs : [
                    SELECT id,
                            Closed_Reason__c,
                            isClosed,
                            Opportunity__c,
                            Opportunity__r.stageName
                    FROM case
                    WHERE Type = 'Onboarding'
                    AND Opportunity__c IN:oppIdWithRStatus.keySet()
            ]) {

                if (cs.isClosed && cs.Closed_Reason__c != 'Successful') {
                    if (cs.Opportunity__r.stageName == 'Onboarding Failed') {
                        updateOppStage.put(cs.Opportunity__c,
                                new Opportunity(Id = cs.Opportunity__c, StageName = 'Onboarding'));
                    } else {
                        mapOppWithOnboarding.put(cs.Opportunity__c, true);
                    }
                } else if (cs.isClosed && cs.Closed_Reason__c == 'Successful') {
                    mapOppWithOnboarding.put(cs.Opportunity__c, false);
                } else if (!cs.isClosed) {
                    mapOppWithOnboarding.put(cs.Opportunity__c, false);
                }
            }
            Map<Id, Account> accMap =
                    new Map<Id, Account>([
                            SELECT Id,
                                    Delivery_Service__c
                            FROM account
                            WHERE id = :mapOppAccount.values()
                    ]);
            for (Id oppID : oppIdWithRStatus.keySet()) {
                if (mapOppWithONBoardData.get(oppID) != null
                        && (mapOppWithOnboarding.get(oppID) == null || (mapOppWithOnboarding.containsKey(oppID)
                        && mapOppWithOnboarding.get(oppID) == true))) {

                    Case cs = new Case(Opportunity__c = oppID, AccountId = mapOppAccount.get(oppID));
                    Account acc = accMap.get(mapOppAccount.get(oppID));

                    if (acc.Delivery_Service__c != null && acc.Delivery_Service__c.contains('Mixed')) {
                        cs.Case_reason__c = 'Mixed';
                    } else if (acc.Delivery_Service__c != null && acc.Delivery_Service__c.contains('All Inclusive')) {
                        cs.Case_reason__c = 'All Inclusive';
                    }

                    for (String fieldAndValue : mapOppWithONBoardData.get(oppID).split(',')) {
                        List<String> fields = fieldAndValue.split('=');
                        cs.put(fields[0], fields[1]);
                    }
                    onboardingCs.add(cs);
                }
            }
            updateReplacementOrder(oppIdWithRStatus);
            //System.debug('onboardingCs: '+onboardingCs);
            try {
                if (!onboardingCs.isEmpty()) {
                    insert onboardingCs;
                }
                if (!updateOppStage.isEmpty()) {
                    update updateOppStage.values();
                }
            } catch (Exception e) {
                caseList[0].addError(e.getMessage());
                System.debug('Exception: ' + e.getMessage());
            }
        }
    }


    /**
    * used by UK and Talabat?!?!
    * whenever a salestask is closed as successful the ownership of account in midas is assigned to the sales rep closing the case
    * the sales agent can now create PP OPP from Account list page
    * @param : newList : trigger.new values
    *          OldMap : trigger.old map
    * @return void
    */

    public static void inboundUKPPUpdateMidasAPI(List<Case> newList, Map<Id, Case> oldMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('InboundPremiumPlacement');
        if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) {
            return;
        }
        List<String> csLst = new List<String>();

        for (case cs : newList) {
            if (oldMap.get(cs.id).status != cs.status && cs.isclosed == true) {
                Map<String, Business_Config__c> mapBusinessRule =
                        mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(cs.RecordTypeId));

                if (mapBusinessRule == null || mapBusinessRule.isEmpty()) {
                    continue;
                }

                if (cs.type == mapBusinessRule.get('CaseType').Business_Rule_Value__c
                        && cs.Case_Reason__c == mapBusinessRule.get('CaseReason').business_rule_value__c) {


                    String intrestedData = InterestedOppClosedLost__c.getValues('Interested').caseClosingReason__c;

                    if (intrestedData == null) {
                        cs.addError('Custom setting InterestedOppClosedLost__c is not defined with values');
                        return;
                    }

                    Set<String> intrestedReasons = new Set<String>();

                    if (intrestedData.indexOf(',') > 0) {
                        for (String str : intrestedData.split(',')) {
                            intrestedReasons.add(str);
                        }
                    } else {
                        intrestedReasons.add(intrestedData);
                    }

                    if (intrestedReasons.contains(cs.closed_reason__c)) {
                        csLst.add(cs.Id);


                    }
                }
            }

        }
        if (csLst != null && !csLSt.isEmpty()) {
            callMidasCaseLostAPI(csLSt);
        }
    }

    @future(Callout = true)
    public static void callMidasCaseLostAPI(List<string> csIDs) {
        List<case> csToUpd = new List<case>();
        List<Case> cList = [
                SELECT
                        id,
                        MidasAPIException__c,
                        closed_reason__c,
                        Root_Cause__c,
                        accountid,
                        account.record_country__c
                FROM Case
                WHERE id = :csIDs
        ];

        String reason = 'case_interest';
        Id currentUserId = UserInfo.getUserId();
        User userData = [SELECT Id, Email, UserRole.Name FROM User WHERE id = :currentUserId];
        for (case cs : cList) {
            try {
                if (cs.Root_Cause__c != null) {
                    if (cs.Root_Cause__c.contains(';')) {
                        reason = cs.Root_cause__c.split(';')[0];
                    } else {
                        reason = cs.Root_cause__c;

                    }
                }
                Boolean interested = true;


                String bodyparam = '{"meta": {"username": "' + userData.Email + '","sf_role": "'
                        + userData.UserRole.Name + '","sf_opportunity_id": "' + cs.Id + '"},"data": {"reason":"'
                        + reason + '","expressed_interest":' + interested + '}}';

                HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest('PP',
                        '/restaurants/sf:' + cs.accountid + '/register_interest', cs.account.record_country__c,
                        'POST', bodyparam);

                HttpResponse res = new HttpResponse();
                Http http = new Http();
                system.debug('bodyparam: ' + bodyparam);

                if (req != null) {
                    res = http.send(req);
                    System.debug('response :' + res.getBody());
                    system.debug('##status code' + res.getStatusCode());
                    if (res.getStatusCode() == 201) {
                        if (cs.MidasAPIException__c != null) {
                            cs.MidasAPIException__c = null;
                            csToUpd.add(cs);
                        }
                    } else {
                        cs.MidasAPIException__c = res.getStatusCode() + '-' + res.getBody();
                        csToUpd.add(cs);
                    }

                } else {
                    cs.MidasAPIException__c = 'MidasIntegration__c is not configured';
                    csToUpd.add(cs);
                }

            } catch (System.CalloutException e) {
                system.debug('Error: ' + e.getMessage());
                String err = e.getMessage();
                if (err.length() > 250) {
                    err = err.left(250);
                }
                cs.MidasAPIException__c = 'Er-' + err;
                csToUpd.add(cs);
            }
        }
        update csToUpd;
    }


    /**
   * creation of Menu change case based on opportunity stage name for KOREA only
   * this method clearly doesnt belong here.. but to shift it to opp trigger i dont know the conditions
   * @param
   *   caseList: List of new Trigger values
   * @return
   */
    public static void nonContractedMenuChange(List<Case> caseList) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('NonContractedMenuChange');
        List<Case> listCase = new List<Case>();
        Map<Id, String> mapCaseStatusOppIds = new Map<Id, String>();
        List<Id> accList = new List<Id>();
        Map<Id, Boolean> existingMenuChangeMap = new Map<Id, Boolean>();

        if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) {
            return;
        }
        for (Case cs : caseList) {
            //had to hardcode the recordtype as there are no other filter conditions available to check
            if (cs.type == 'Menu Processing'
                    && LibRecordTypeHelper.getRecordTypeValue(cs.RecordTypeId).contains('Yogiyo')) {

                mapCaseStatusOppIds.put(cs.Opportunity__c, cs.Status);
                accList.add(cs.AccountId);
            }
        }

        if (!mapCaseStatusOppIds.isEmpty()) {
            for (Case c : [
                    SELECT id,
                            Opportunity__c,
                            AccountId
                    FROM Case
                    WHERE Type = 'Convert to Contract'
                    AND AccountId IN :accList
            ]) {
                existingMenuChangeMap.put(c.AccountId, true);
            }
        }

        for (Opportunity opp : [
                SELECT stageName,
                        AccountId,
                        RecordTypeId,
                        CurrencyIsoCode,
                        Non_Contracted__c
                FROM Opportunity
                WHERE id IN:mapCaseStatusOppIds.keySet()
        ]) {
            if (!existingMenuChangeMap.containsKey(opp.AccountId)) {

                Map<String, Business_Config__c> mapBusinessRule =
                        mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                if (mapBusinessRule != null && !mapBusinessRule.isEmpty()) {
                    String menuProcessingStatus = mapBusinessRule.get('Menu Processing Status').Business_Rule_Value__c;
                    if (opp.Non_Contracted__c ==
                            Boolean.valueOf(mapBusinessRule.get('Non_Contracted__c').Business_Rule_Value__c)
                            && mapCaseStatusOppIds.get(opp.id) == menuProcessingStatus
                            && opp.stageName == mapBusinessRule.get('StageName').Business_Rule_Value__c) {
                        if (mapBusinessRule.containsKey('Menu Change Case')) {
                            Case cs = new Case(Opportunity__c = opp.id, AccountId = opp.AccountId,
                                    CurrencyIsoCode = opp.CurrencyIsoCode);

                            for (String fieldAndValue : (mapBusinessRule.get('Menu Change Case').Business_Rule_Value__c).split(',')) {
                                List<String> fields = fieldAndValue.split('=');
                                cs.put(fields[0], fields[1]);
                            }
                            listCase.add(cs);
                        }
                    }
                }
            }

        }
        try {
            if (!listCase.isEmpty())
                insert listCase;
        } catch (Exception e) {
            caseList[0].addError(e.getMessage());
        }
    }


    /**
    * SP-1084 used for CD Marketing and shipping products. Updates opportunity when both shipping and
    * backend cases are closed.
    * When one of the case closed negative Opp goes to Please check
    * @param : newList : Tigger.new List
    * 		   oldMap : Trigger.old map
    * @return
    *
    */
    public static void backendShippingCaseClosure(List<Case> newList, Map<Id, Case> oldMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('BackendShippingCaseClosure');
        Map<case, Map<String, Business_Config__c>> caseBusinessMap = new Map<case, Map<String, Business_Config__c>>();

        if (mapBusinessLogic == null) {
            return;
        }
        for (Case c : newList) {
            if (c.isClosed
                    && c.Closed_Reason__c != oldMap.get(c.id).Closed_Reason__c
                    && c.Opportunity__c != null
                    && c.Type != null) {
                Map<String, Business_Config__c> mapBusinessRule =
                        mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(c.RecordTypeId));
                if (mapBusinessRule != null && !mapBusinessRule.isEmpty()) {
                    caseBusinessMap.put(c, mapBusinessRule);
                }
            }
        }
        if (!caseBusinessMap.isEmpty()) {
            oppUpdateProcess(caseBusinessMap);
        }
    }
    /**
    * update Opportunity Stagename on positive / negative closure of case
    * @param caseBusinessMap : case config map
    * @return void
    */
    private static void oppUpdateProcess(Map<case, Map<String, Business_Config__c>> caseBusinessMap) {
        Map<Id, Case> oppCaseMap = new Map<Id, case>();
        List<Opportunity> updateOppList = new List<Opportunity>();
        Map<Id, List<Case>> oppConnectedCaseMap = new Map<Id, List<Case>>();

        for (Case c : caseBusinessMap.keySet()) {
            Set<String> caseTypes = new Set<String>();
            Map<String, Business_Config__c> mapBusinessRule = caseBusinessMap.get(c);

            caseTypes.addAll(mapBusinessRule.get('CheckForTypes') != null ?
                    mapBusinessRule.get('CheckForTypes').Business_Rule_Value__c.split(',') : new List<String>());

            if (caseTypes.contains(c.type)) {
                if (c.closed_Reason__c == 'Successful' || c.closed_Reason__c == 'Take Online') {
                    oppCaseMap.put(c.Opportunity__c, c);

                } else {
                    updateOppList.add(setOppIdStage(c.Opportunity__c,
                            mapBusinessRule.get('NegativeStageName').Business_Rule_Value__c));
                }
            }
        }

        if (!OppCaseMap.isEmpty()) {
            List<Case> siblingCaseLst = checkForSiblingCases(oppCaseMap);

            for (Case c : siblingCaseLst) {
                if (!oppConnectedCaseMap.containsKey(c.opportunity__c)) {
                    oppConnectedCaseMap.put(c.opportunity__c, new List<Case>{
                            c
                    });
                } else {
                    oppConnectedCaseMap.get(c.opportunity__c).add(c);
                }
            }

        }

        for (Case c : oppCaseMap.values()) {
            List<String> caseTypes = new List<String>();
            List<case> siblingCases = new List<Case>();
            Map<String, Business_Config__c> mapBusinessRule = caseBusinessMap.get(c);

            caseTypes.addAll(mapBusinessRule.containsKey('CheckForTypes') ?
                    mapBusinessRule.get('CheckForTypes').Business_Rule_Value__c.split(',') : new List<String>());
            String sbCase = 'none'; // default no siblings
            if (oppConnectedCaseMap.containsKey(c.opportunity__c)) {
                siblingCases = oppConnectedCaseMap.get(c.opportunity__c);

                if (siblingCases != null && !siblingCases.isEmpty()) {
                    for (Case cs : siblingCases) {
                        if (caseTypes.contains(cs.type) && cs.type != c.type) {
                            if (cs.isClosed && (cs.Closed_Reason__c == 'Successful' || cs.Closed_Reason__c == 'Take Online')) {
                                sbCase = 'Close' ; // sibling is closed
                            } else if (sbCase != 'Close') {
                                sbCase = 'Open'; // sibling is open  not successful update only if there are no successful case
                            }
                        }
                    }
                }
            }
            if (sbCase != 'Open') {
                updateOppList.add(setOppIdStage(c.Opportunity__c,
                        mapBusinessRule.get('OppStageForPositiveIfBothClosed').Business_Rule_Value__c));
            }

        }

        system.debug(updateOppList);
        if (!updateOppList.isEmpty())
            update updateOppList;

    }

    private static Opportunity setOppIdStage(Id OppId, String stageNameStr) {
        return(new Opportunity(Id = OppId,
                stageName = stageNameStr));
    }

    private static List<case> checkForSiblingCases(Map<Id, Case> oppCaseMap) {
        return([
                SELECT Id,Closed_Reason__c,Opportunity__c,type,isClosed
                FROM Case
                WHERE Opportunity__c IN :oppCaseMap.keySet()AND id NOT IN :oppCaseMap.values()
        ]);
    }

    /**
    * On positive closure of branding cases update Opportunity
    * @param
    *   newList : Trigger.new Values
    *   oldMap : Trigger.old Map
    * @return
    *
    */
    public static void brandingCaseClosure(List<Case> newList, Map<Id, Case> oldMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('brandingCaseClosure');
        Set<String> caseTypes = new Set<String>();
        Set<String> positiveReasons = new Set<String>();

        List<Opportunity> updateOppList = new List<Opportunity>();

        if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) {
            return;
        }
        for (Case c : newList) {
            if (c.isClosed
                    && !oldmap.get(c.id).isClosed
                    && c.Opportunity__c != null
                    && c.type != null) {
                Map<String, Business_Config__c> mapBusinessRule =
                        mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(c.RecordTypeId));

                if (mapBusinessRule == null || mapBusinessRule.isEmpty()) {
                    continue;
                }
                if (mapBusinessRule.containsKey('CheckForTypes')) {
                    caseTypes.addAll(mapBusinessRule.get('CheckForTypes').Business_Rule_Value__c.split(','));
                }
                if (mapBusinessRule.containsKey('ClosedReasonPositive')) {
                    positiveReasons.addAll(mapBusinessRule.get('ClosedReasonPositive').Business_Rule_Value__c.split(','));
                }
                //Check if the case belongs to the branding related case type and is closed reason is positive
                if (caseTypes.contains(c.type) && positiveReasons.contains(c.closed_reason__c)) {
                    Opportunity opp = setOppIdStage(c.opportunity__c,
                            mapBusinessRule.get('ClosedPositiveStage').Business_Rule_Value__c);

                    updateOppList.add(opp);

                }

            }

        }
        if (!updateOppList.isEmpty()) {
            update updateOppList;
        }
    }


    /**
    * Handle closing action on Onboarding case. Push Opportunity to next stage if
    * closed successfully or back
    * @param
    *  newList Trigger.new Values
    *  oldMap  Trigger.old Map Values
    * @return
    */
    public static void onboardingCaseClosingAction(List<Case> newList, Map<Id, Case> oldMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('RestaurantCareClosingAction');
        if (mapBusinessLogic == null) {
            return;
        }
        Set<Id> oppWithInactiveAsset = new Set<Id>();
        Set<Id> oppWithUninstalledBranding = new Set<Id>();
        Set<Id> oppWithInactiveAddon = new Set<Id>();
        set<id> oppWithUndeliveredShipments = new Set<Id>();

        Set<Id> hasToCheckAssets = new Set<Id>();
        Set<Id> hasToCheckBrandings = new Set<Id>();
        Set<Id> hasToCheckAddon = new Set<Id>();
        set<id> hasToCheckShipments = new Set<id>();

        Set<Id> brandingOppsToCheck = new Set<Id>();
        Set<Id> assetOppsToCheck = new Set<Id>();
        Set<Id> addonOppsToCheck = new Set<Id>();
        Set<id> ShipmentsOppsToCheck = new set<id>();

        List<Opportunity> toUpdate = new List<Opportunity>();
        List<Case> validCasesWithOpp = new List<Case>();

        Map<String, Map<String, Business_Config__c>> mapBusinessStatus = moam.get('StatusObjectsByStage');
        set<String> stStatusAssets;
        set<String> stStatusBranding;
        if(mapBusinessStatus!= null){
            if(mapBusinessStatus.Containskey('General_Config')){
                Map<String, Business_Config__c> mapBusinessRuleStatus = mapBusinessStatus.get('General_Config');
                if(mapBusinessRuleStatus.containskey('AssetStatusOnBoarding')){
                    stStatusAssets =  (set<String>)System.JSON.deserialize(mapBusinessRuleStatus.get('AssetStatusOnBoarding').Business_Rule_Value__c, set<String>.class);
                }
                if(mapBusinessRuleStatus.containskey('BrandingStatusOnBoarding')){
                    stStatusBranding =  (set<String>)System.JSON.deserialize(mapBusinessRuleStatus.get('BrandingStatusOnBoarding').Business_Rule_Value__c, set<String>.class);

                }
            }

        }


        for (Case currentCase : newList) {
            Map<String, Business_Config__c> rules =
                    mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(currentCase.RecordTypeId));

            if (rules == null) {
                continue;
            }

            // filter valid cases
            if (oldMap.get(currentCase.Id).Status != currentCase.Status
                    && currentCase.isClosed
                    && currentCase.Type == rules.get('Type').Business_Rule_Value__c
                    && String.isNotBlank(currentCase.Opportunity__c)
                    && currentCase.Case_Reason__c == rules.get('CaseReason').Business_Rule_Value__c) {

                Map<String, String> closedReason =
                        (Map<String, String>) JSON.deserialize(rules.get('closingReason').Business_Rule_Value__c,
                                Map<String, String>.class);

                Set<String> positiveReason = new Set<String>(closedReason.get('Positive').split(','));
                Set<String> negativeReason = new Set<String>(closedReason.get('Negative').split(','));

                if (negativeReason.contains(currentCase.Closed_Reason__c)
                        && rules.containsKey('NegativeStageName')) {
                    toUpdate.add(setOppIdStage(currentCase.opportunity__c,rules.get('NegativeStageName').Business_Rule_Value__c));
                }else if( positiveReason.contains(currentCase.Closed_Reason__c)){


                    // this is positive onboarding case
                    validCasesWithOpp.add(currentCase);

                    // should check assets status before changing stage name
                    if (rules.containsKey('chkAssetStatus')
                            && Boolean.valueOf(rules.get('chkAssetStatus').Business_Rule_Value__c)) {
                        assetOppsToCheck.add(currentCase.Opportunity__c);
                        hasToCheckAssets.add(currentCase.Id);
                    }

                    // should check assets status before changing stage name
                    if (rules.containsKey('chkShipmentStatus')
                            && Boolean.valueOf(rules.get('chkShipmentStatus').Business_Rule_Value__c)) {
                        ShipmentsOppsToCheck.add(currentCase.Opportunity__c);
                        hasToCheckShipments.add(currentCase.Id);

                    }

                    // should check branding before changing stage name
                    if (rules.containsKey('chkBrandingStatus')
                            && Boolean.valueOf(rules.get('chkBrandingStatus').Business_Rule_Value__c)) {
                        brandingOppsToCheck.add(currentCase.Opportunity__c);
                        hasToCheckBrandings.add(currentCase.Id);
                    }
                    // check for pending addons
                    if (rules.containsKey('CheckForAddon')
                            && Boolean.valueOf(rules.get('CheckForAddon').Business_Rule_Value__c)) {
                        addonOppsToCheck.add(currentCase.Opportunity__c);
                        hasToCheckAddon.add(currentCase.Id);

                    }
                }
            }
        }

        // get inactive assets, branding & addons
        if (!assetOppsToCheck.isEmpty()) {
            oppWithInactiveAsset = LibHelper.checkForInactiveAsset(assetOppsToCheck,stStatusAssets);
        }
        if (!ShipmentsOppsToCheck.isEmpty()) {
            oppWithUndeliveredShipments = LibHelper.checkForUndeliveredShipments(ShipmentsOppsToCheck);
        }

        if(!brandingOppsToCheck.isEmpty()){
            oppWithUninstalledBranding = LibHelper.checkForUninstalledBranding(brandingOppsToCheck,stStatusBranding);
        }

        if (!addonOppsToCheck.isEmpty()) {
            oppWithInactiveAddon = LibHelper.checkForNonActiveAddon(addonOppsToCheck);
        }

        for (Case c : validCasesWithOpp) {
            Map<String, Business_Config__c> rules =
                    mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(c.RecordTypeId));

            if ( rules.containsKey('PositiveStageName')
                    // does not need to check asset, or opps has no inactive assets
                    && (!hasToCheckAssets.contains(c.Id)
                    || !oppWithInactiveAsset.contains(c.Opportunity__c))
                    && (!hasToCheckShipments.contains(c.Id)
                    || !oppWithUndeliveredShipments.contains(c.Opportunity__c))
                    // does not need to check branding, or opps has no uninstalled branding
                    && (!hasToCheckBrandings.contains(c.Id)
                    || !oppWithUninstalledBranding.contains(c.Opportunity__c))
                    &&(!hasToCheckAddon.contains(c.Id)
                    || !oppWithInactiveAddon.contains(c.Opportunity__c))) {


                toUpdate.add(setOppIdStage(c.opportunity__c, rules.get('PositiveStageName').Business_Rule_Value__c));

            }else{
                if(hasToCheckAssets.contains(c.Id)&& oppWithInactiveAsset.contains(c.Opportunity__c)){
                    if(rules.ContainsKey('AssetValidationError')){
                        c.addError(rules.get('AssetValidationError').Business_Rule_Value__c);
                    }
                }

                if(hasToCheckShipments.contains(c.Id)&& oppWithUndeliveredShipments.contains(c.Opportunity__c)){
                    if(rules.ContainsKey('ShipmentValidationError')){
                        c.addError(rules.get('ShipmentValidationError').Business_Rule_Value__c);
                    }
                }
            }

        }if (!toUpdate.isEmpty()) {
            update toUpdate;
        }

    }


    /**
    * SP-373 Actions performed when quality check case is closed
    * @param
    *   caseList: List of new Trigger values
    *  mapOldCase:  Map of old trigger values
    * @return void
    */
    public static void qualityCheckClosingAction(List<Case> caseList, Map<Id, Case> mapOldCase) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('QualityCheckInternalCaseClosingAction');
        if (mapBusinessLogic == null) {
            return;
        }
        Map<Id, Id>caseOppMap = new Map<Id, Id>();
        Map<Case, Map<String, Business_Config__c>>caseConfigsMap = new Map<Case, Map<String, Business_Config__c>>();

        for (Case c : caseList) {
            if (c.IsClosed
                    && !mapOldCase.get(c.Id).IsClosed
                    && c.Type == 'Quality Check'
                    && c.Closed_Reason__c != null
                    && c.Opportunity__c != null) {

                Map<String, Business_Config__c> mapBusinessRule =
                        mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(c.RecordTypeId));

                if (mapBusinessRule == null) {
                    continue;
                }
                Map<String, String> ClosedReason =
                        (Map<String, String>) JSON.deserialize(mapBusinessRule.get('ClosedReason').Business_Rule_Value__c,
                                Map<String, String>.class);

                Set<String> positiveReason = new Set<String>();
                positiveReason.addAll(ClosedReason.get('positive').split(','));


                if (positiveReason.contains(c.Closed_Reason__c)) {
                    caseOppMap.put(c.Id, c.Opportunity__c);
                }
                caseConfigsMap.put(c, mapBusinessRule);

            }
        }
        if (!caseConfigsMap.isEmpty()) {
            updateOppsOnQcClosure(caseConfigsMap, caseOppMap);

        }
    }


    private static void updateOppsOnQcClosure(Map<Case, Map<String, Business_Config__c>> caseConfigsMap, Map<Id, Id> caseOppMap) {
        List<Opportunity> oppToUpd = new List<Opportunity>();
        List<Opportunity_Quote_Line_Item__c> oppQuoteLineList = new List<Opportunity_Quote_Line_Item__c>();
        Map<Id, String> oppIdWithRStatus = new Map<Id, String>();
        Map<Id, Opportunity_Quote_Line_Item__c> oppQuoteLinesMap = new Map<Id, Opportunity_Quote_Line_Item__c>();
        Map<Id, Set<String>> OppIdRelatedRecordMap = new Map<Id, Set<String>>();

        /*refered in product only etc etc*/
        Map<Id, Boolean> mapIsAssetProducts = new Map<Id, Boolean>();
        Map<Id, Boolean> mapIsBrandingProd = new Map<Id, Boolean>();
        Map<Id, Boolean> mapIsAddOnProducts = new Map<Id, Boolean>();
        Map<Id, Boolean> mapIsPhotoListingProd = new Map<Id, Boolean>();

        Map<Id, Shipment_Order__c> mpShipOrder = new Map<Id, Shipment_Order__c>();
        Map<Id, Shipment_Order_Line_Item__c> mpShipOrderLine = new Map<Id, Shipment_Order_Line_Item__c>();
        Map<String,String> optByLineitem = new Map<String,String>();


        /*used to create related line items*/
        Set<Id>assetProducts = new Set<Id>();
        Set<Id>brandingProducts = new Set<Id>();
        Set<Id>addonProducts = new Set<Id>();

        // Set of opportunities which are Chain Opportunity (Headquarter deals)
        Set<Id> chainOppIds = new Set<Id>();
        Set<Id> shopOpportunities = new Set<Id>();

        Set<Id> oppIdSet = new Set<Id>();

        if (!caseOppMap.isEmpty()) {
            oppQuoteLineList.addAll(getlineitemsOppdetails(caseOppMap));
        }

        for(Opportunity_Quote_Line_Item__c opq : oppQuoteLineList){
            oppIdSet.add(opq.Id_Opportunity__c);
        }
        Set<Id> oppWithUndeliveredShipments = new Set<Id>();
        oppWithUndeliveredShipments = LibHelper.checkForUndeliveredShipments(oppIdSet);

        if(oppQuoteLineList!=null && !oppQuoteLineList.isEmpty()){
            for(Opportunity_Quote_Line_Item__c opq : oppQuoteLineList){
                oppQuoteLinesMap.put(opq.id_opportunity__c,opq);

                // populate chain opportunity set
                if(opq.Id_Opportunity__r.recordType.developerName == 'Chain_Opportunity'){
                    chainOppIds.add(opq.Id_Opportunity__c);
                }

                if(opq.Id_Opportunity__r.Account.Vertical__c == 'Shop') {
                    shopOpportunities.add(opq.Id_Opportunity__c);
                }

                if (opq.Id_List_Product_Price__r.Requires_Asset__c == true){
                    AssetProducts.add(opq.Id_Opportunity__c);
                    if( (opq.Id_Opportunity__r.type == 'Product Only'
                            || opq.Id_Opportunity__r.type == 'Additional Contract')) {
                        mapIsAssetProducts.put(opq.Id_Opportunity__c, true);
                    }
                    if(opq.Delivery__c == 'Shipment' && !chainOppIds.contains(opq.Id_Opportunity__c) && !oppWithUndeliveredShipments.contains(opq.Id_Opportunity__c)) { // included to create the shipping Order. //SP-2413
                        if(!mpShipOrder.ContainsKey(opq.Id_Opportunity__c)){
                            mpShipOrder.put(opq.Id_Opportunity__c, new Shipment_Order__c ( Account__c = opq.Id_Opportunity__r.AccountID ,
                                    Opportunity__c = opq.Id_Opportunity__c ,
                                    Opportunity_Quote__c = opq.Id_Opportunity_Quote__c,
                                    Status__c = 'Ready to be shipped' ));
                        }

                        mpShipOrderLine.put(opq.id, new Shipment_Order_Line_Item__c(Name = opq.Name,
                                List_Product_Price__c = opq.Id_List_Product_Price__c ,
                                Opportunity_Quote_Line_Item__c = opq.id,
                                SKU__c = opq.Id_List_Product_Price__r.sku__c,
                                Quantity__c = opq.Quantity__c,
                                Total_Amount__c = opq.Total_Amount__c,
                                CurrencyIsoCode = opq.CurrencyIsoCode
                        ));
                        optByLineitem.put(opq.id,opq.Id_Opportunity__c);
                    }
                }
                if (opq.Id_List_Product_Price__r.Product_Type__c != null){
                    if(opq.id_list_product_price__r.requires_branding__c){
                        brandingProducts.add(opq.Id_Opportunity__c);

                        if( opq.Id_List_Product_Price__r.Product_Type__c.containsIgnoreCase('White Label')) {
                            mapIsBrandingProd.put(opq.Id_Opportunity__c, true);
                        }

                        if(opq.Delivery__c == 'Shipment' ){ // included to create the shipping Order. //SP-2413
                            if(!mpShipOrder.ContainsKey(opq.Id_Opportunity__c)){
                                mpShipOrder.put(opq.Id_Opportunity__c, new Shipment_Order__c ( Account__c = opq.Id_Opportunity__r.AccountID ,
                                        Opportunity__c = opq.Id_Opportunity__c ,
                                        Opportunity_Quote__c = opq.Id_Opportunity_Quote__c,
                                        Status__c = 'Ready to be shipped'
                                ));
                            }

                            mpShipOrderLine.put(opq.id, new Shipment_Order_Line_Item__c(Name = opq.Name,
                                    List_Product_Price__c = opq.Id_List_Product_Price__c ,
                                    Opportunity_Quote_Line_Item__c = opq.id,
                                    Quantity__c = opq.Quantity__c,
                                    SKU__c = opq.Id_List_Product_Price__r.sku__c,
                                    Total_Amount__c = opq.Total_Amount__c));
                            optByLineitem.put(opq.id,opq.Id_Opportunity__c);
                        }

                    }
                    if(opq.Id_List_Product_Price__r.Product_Type__c.containsIgnoreCase('Dish Level Photoshoot')){
                        mapIsPhotoListingProd.put(opq.Id_Opportunity__c, true);
                    }
                }

                if (opq.Line_Item_Type__c != null && opq.Line_Item_Type__c=='AddOn') {
                    addonProducts.add(opq.id_opportunity__c);
                    mapIsAddOnProducts.put(opq.Id_Opportunity__c, true);
                }

            }
        }

        Map<Id, Boolean> oppsWithClosedDish = CaseSelector.getDishCasesForOpportunities(shopOpportunities);

        for (Case c : caseConfigsMap.keySet()) {
            Map<String, Business_Config__c> mapBusinessRule = caseConfigsMap.get(c);
            Set<String> skipStages = new Set<String>();


            Map<String, String> ClosedReason =
                    (Map<String, String>) JSON.deserialize(mapBusinessRule.get('ClosedReason').Business_Rule_Value__c,
                            Map<String, String>.class);

            Set<String> positiveReason = new Set<String>();
            Set<String> negativeReason = new Set<String>();

            positiveReason.addAll(ClosedReason.get('positive').split(','));
            negativeReason.addAll(ClosedReason.get('negative').split(','));


            //Check if QC is closed negatively
            if (negativeReason.contains(c.Closed_Reason__c)) {
                oppToUpd.add(setOppIdStage(c.Opportunity__c,
                        mapBusinessRule.get('NegativeQC').Business_Rule_Value__c));

                if (mapBusinessRule.containsKey('NegativeRepStatus')) {
                    oppIdWithRStatus.put(c.Opportunity__c,
                            mapBusinessRule.get('NegativeRepStatus').Business_Rule_Value__c);
                }
            } else if (positiveReason.contains(c.Closed_Reason__c) && chainOppIds.contains(c.Opportunity__c)) { // if the case QC case is a part of chain opportunity, only update the status
                oppToUpd.add(setOppIdStage(c.Opportunity__c,
                        mapBusinessRule.get('PositiveQCChainOpp').Business_Rule_Value__c));
            } else if (positiveReason.contains(c.Closed_Reason__c)) { //For Positive QC
                Set<String> skipMPForBtypes = new Set<String>();
                Set<String> skipMPForTypes = new Set<String>();

                if (mapBusinessRule.containsKey('SkipForStage')) {
                    skipStages.addAll(mapBusinessRule.get('SkipForStage').Business_Rule_Value__c.split(','));
                }

                //if stagename is in skipstage do nothing
                if (skipStages.contains(oppQuoteLinesMap.get(caseOppMap.get(c.Id)).Id_Opportunity__r.StageName)) {
                    continue;
                }
                //Add the types & business types where Menu processing creation stage needs to be skipped (Editorial Queue)
                if (mapBusinessRule.containsKey('skipMPForType')) {
                    skipMPForTypes.addAll(mapBusinessRule.get('skipMPForType').Business_Rule_Value__c.split(','));
                }
                if (mapBusinessRule.containsKey('skipMPForBtype')) {
                    skipMPForBTypes.addAll(mapBusinessRule.get('skipMPForBtype').Business_Rule_Value__c.split(','));
                }

                //Map of Opportunity and type of Related child records to be created on closure of QC from the line items
                if (!addonProducts.isEmpty()
                        && addonProducts.contains(c.Opportunity__c)
                        && mapBusinessRule.containsKey('CreateAddon')
                        && Boolean.valueOf(mapBusinessRule.get('CreateAddon').Business_Rule_Value__c)) {
                    OppIdRelatedRecordMap.putAll(mapOppToRelatedRecordtypes(OppIdRelatedRecordMap,
                            c.Opportunity__c, 'AddOn'));
                }
                if (!assetProducts.isEmpty()
                        && assetProducts.contains(c.Opportunity__c)
                        && mapBusinessRule.containsKey('CreateAsset')
                        && Boolean.valueOf(mapBusinessRule.get('CreateAsset').Business_Rule_Value__c)) {
                    OppIdRelatedRecordMap.putAll(mapOppToRelatedRecordtypes(OppIdRelatedRecordMap,
                            c.Opportunity__c, 'Asset'));
                }
                if (!brandingProducts.isEmpty()
                        && brandingProducts.contains(c.Opportunity__c)
                        && mapBusinessRule.containsKey('CreateBranding')
                        && Boolean.valueOf(mapBusinessRule.get('CreateBranding').Business_Rule_Value__c)) {
                    OppIdRelatedRecordMap.putAll(mapOppToRelatedRecordtypes(OppIdRelatedRecordMap,
                            c.Opportunity__c, 'Branding'));
                }

                /*skip MP stagename  */
                /* Set the stage name to onboarding only when Add. charges Requires asset is true. */
                if (mapBusinessRule.containsKey('SkipMPStageName')
                        && mapBusinessRule.containsKey('stageNameForContProdWoutAsset')
                        && skipMPForTypes.contains(oppQuoteLinesMap.get(caseOppMap.get(c.Id)).Id_Opportunity__r.Type)
                        && skipMPForBtypes.contains(oppQuoteLinesMap.get(caseOppMap.get(c.Id)).Id_Opportunity__r.Business_Type__c)) {
                    Map<String, String> typeStageMap =
                            (Map<String, String>) JSON.deserialize(mapBusinessRule.get('SkipMPStageName').Business_Rule_Value__c, Map<String, String>.class);
                    String stgName = typeStageMap.get(oppQuoteLinesMap.get(caseOppMap.get(c.Id)).Id_Opportunity__r.Type);
                    Map<String, String> typeConProdStageMap =
                            (Map<String, String>) JSON.deserialize(mapBusinessRule.get('stageNameForContProdWoutAsset').Business_Rule_Value__c, Map<String, String>.class);

                    //turn off opp trigger which validates the stagename updates
                    donotValidateOppStage = true;
                    if (typeConProdStageMap.containsKey(oppQuoteLinesMap.get(caseOppMap.get(c.Id)).Id_Opportunity__r.Type) && !assetProducts.isEmpty() && assetProducts.contains(oppQuoteLinesMap.get(caseOppMap.get(c.Id)).Id_Opportunity__c)) {
                        oppToUpd.add(setOppIdStage(c.Opportunity__c, typeConProdStageMap.get(oppQuoteLinesMap.get(caseOppMap.get(c.Id)).Id_Opportunity__r.Type)));
                    } else {
                        oppToUpd.add(setOppIdStage(c.Opportunity__c, stgName)); //###
                    }
                } else if (mapBusinessRule.containsKey('ClosedPositiveShopVertical')
                        && mapIsPhotoListingProd.containsKey(c.Opportunity__c)
                        && shopOpportunities.contains(c.Opportunity__c)
                        && !oppsWithClosedDish.containsKey(c.Opportunity__c)) {
                    oppToUpd.add(setOppIdStage(c.Opportunity__c, mapBusinessRule.get('ClosedPositiveShopVertical').Business_Rule_Value__c));
                } else if ((mapBusinessRule.containsKey('ClosedPositiveProductOnly') /* Product Only QC Opp stage update */
                        || mapBusinessRule.containsKey('ClosedPositiveProductOnlyBranding')
                        || mapBusinessRule.containsKey('ClosedPositiveProductOnlyAddOn')
                        || mapBusinessRule.containsKey('ClosedPositiveProductOnlyAsset')
                        || mapBusinessRule.containsKey('PhotoListing')
                        || mapBusinessRule.containsKey('ClosedPositiveMarketingAndPackaging'))
                        && (oppQuoteLinesMap.get(caseOppMap.get(c.Id)).Id_Opportunity__r.Type == 'Product Only')) {
                    if (mapBusinessRule.containsKey('ClosedPositiveMarketingAndPackaging')
                            && oppQuoteLinesMap.get(caseOppMap.get(c.Id)).Id_Opportunity__r.Id_Tarif__r.Name == 'Marketing & Packaging') {

                        oppToUpd.add(setOppIdStage(c.Opportunity__c,
                                mapBusinessRule.get('ClosedPositiveMarketingAndPackaging').Business_Rule_Value__c));
                    } else if (mapBusinessRule.containsKey('ClosedPositiveProductOnlyAsset') /*If Product only QC has asset it might need Onboarding */
                            && !mapIsAssetProducts.isEmpty()
                            && mapIsAssetProducts.containsKey(c.Opportunity__c)) {

                        oppToUpd.add(setOppIdStage(c.Opportunity__c,
                                mapBusinessRule.get('ClosedPositiveProductOnlyAsset').Business_Rule_Value__c));

                    } else if (mapBusinessRule.containsKey('ClosedPositiveProductOnlyBranding') /*Product Only Branding special case.. no idea why!*/
                            && !mapIsBrandingProd.isEmpty()
                            && mapIsBrandingProd.get(c.Opportunity__c) != null) {

                        oppToUpd.add(setOppIdStage(c.Opportunity__c,
                                mapBusinessRule.get('ClosedPositiveProductOnlyBranding').Business_Rule_Value__c));

                    } else if (mapBusinessRule.containsKey('ClosedPositiveProductOnlyAddOn') /* Product only but has an addon*/
                            && !mapIsAddOnProducts.isEmpty()
                            && mapIsAddOnProducts.containsKey(c.Opportunity__c)) {

                        oppToUpd.add(setOppIdStage(c.Opportunity__c,
                                mapBusinessRule.get('ClosedPositiveProductOnlyAddOn').Business_Rule_Value__c));
                    } else if (mapBusinessRule.containsKey('PhotoListing') && mapIsPhotoListingProd.containsKey(c.Opportunity__c)) {
                        Map<String, Object> mpJsonPhotoListing = (Map<String, Object>) JSON.deserializeUntyped(mapBusinessRule.get('PhotoListing').Business_Rule_Value__c);
                        oppToUpd.add(setOppIdStage(c.Opportunity__c, (String) mpJsonPhotoListing.get('stageName')));

                    } else {
                        if (mapBusinessRule.containsKey('ClosedPositiveProductOnly')) {
                            oppToUpd.add(setOppIdStage(c.Opportunity__c,
                                    mapBusinessRule.get('ClosedPositiveProductOnly').Business_Rule_Value__c));
                        }
                    }
                    //If Opp type is Additional Contract
                } else if ((mapBusinessRule.containsKey('ClosedPositiveAddContract'))
                        && oppQuoteLinesMap.get(caseOppMap.get(c.Id)).Id_Opportunity__r.Type == 'Additional Contract') {
                    //Additional contract which contains branding? not sure if it s valid and why UK - no idea
                    if ((!mapIsBrandingProd.isEmpty()
                            && mapIsBrandingProd.containsKey(c.Opportunity__c)
                            || oppQuoteLinesMap.get(caseOppMap.get(c.Id)).Id_Opportunity__r.RecordType.DeveloperName.contains('UK'))) {

                        if (mapBusinessRule.containsKey('ClosedPositiveAddContract')) {
                            oppToUpd.add(setOppIdStage(c.Opportunity__c,
                                    mapBusinessRule.get('ClosedPositiveAddContract').Business_Rule_Value__c));

                        } else {
                            oppToUpd.add(setOppIdStage(c.Opportunity__c,
                                    mapBusinessRule.get('ClosedPositiveProductOnly').Business_Rule_Value__c));

                        }
                    }
                } else {
                    oppToUpd.add(setOppIdStage(c.Opportunity__c,
                            mapBusinessRule.get('PositiveQC').Business_Rule_Value__c));

                }//Something for Replacement!
                if (mapBusinessRule.containsKey('PositiveRepStatus')) {
                    oppIdWithRStatus.put(c.Opportunity__c,
                            mapBusinessRule.get('PositiveRepStatus').Business_Rule_Value__c);
                }
            }
        }

        // Opportunities that have inactive Addons should not be Closed Won
        Map<Id, List<Opportunity_Quote_Line_Item__c>> oppLineItemMap = ClsSObjectUtils.convertToIdMap(oppQuoteLineList, Opportunity_Quote_Line_Item__c.Id_Opportunity__c.getDescribe().getLocalName());
        oppToUpd = filterOutInactiveAddonOpportunities(oppToUpd, oppLineItemMap);

        if (!oppIdWithRStatus.isEmpty()) {
            updateReplacementOrder(oppIdWithRStatus);
        }
        if (!OppIdRelatedRecordMap.isEmpty()) {
            LibHelper.createRelatedRecords(OppIdRelatedRecordMap);
        }
        if (!oppToUpd.isEmpty()) {
            try{
                update oppToUpd;
            } catch(Exception  exc){
                Integer errorIndex;
                String errorToFind = 'FIELD_CUSTOM_VALIDATION_EXCEPTION,';
                for(Case cas : caseConfigsMap.keySet()){
                    String errorMessage = exc.getMessage();

                    if(exc.getMessage().containsIgnoreCase(errorToFind)){
                        errorIndex = exc.getMessage().indexOf(errorToFind);
                        errorIndex += errorToFind.length();
                        errorMessage = exc.getMessage().substring(errorIndex);
                    }

                    cas.addError(errorMessage);
                }
            }
        }

        if(mpShipOrder.size()>0){
            Insert mpShipOrder.values();
            for(Shipment_Order_Line_Item__c ShiOrdTemp: mpShipOrderLine.values()){
                ShiOrdTemp.Shipment_Order__c =  mpShipOrder.get(optByLineitem.get(ShiOrdTemp.Opportunity_Quote_Line_Item__c)).Id;
            }

            insert mpShipOrderLine.values();
        }

    }

    /**
     * @description filters out opportunities that have inactive addons to be created
     *
     * @param opportunities
     * @param qlineItemMap
     *
     * @return
     */
    public static List<Opportunity> filterOutInactiveAddonOpportunities(List<Opportunity> opportunities, Map<Id, List<Opportunity_Quote_Line_Item__c>> qlineItemMap) {
        List<Opportunity> filteredOpps = new List<Opportunity>();

        for (Opportunity opp: opportunities) {
            Boolean hasInactiveAddon = false;
            if (!opp.StageName.equals('Closed Won')) {
                filteredOpps.add(opp);
                continue;
            }

            for (Opportunity_Quote_Line_Item__c opqli : qlineItemMap.get(opp.Id)) {
                if (opqli.Line_Item_Type__c.equals('AddOn') && opqli.Id_Opportunity__r.RecordType.DeveloperName != 'Chain_Opportunity'){
                    Business_Config__c addonConfig = LibBusinessConfig.getBusinessConfigFromRuleMap('AddonCreation', opqli.RecordTypeId, opqli.Sub_type__c);
                    if (addonConfig != null && addonConfig.Business_Rule_Value__c.equalsIgnoreCase('New')) {
                        hasInactiveAddon = true;
                        break;
                    }
                }
            }
            if (!hasInactiveAddon) {
                filteredOpps.add(opp);
            }
        }
        return filteredOpps;
    }

    /*Replacement orders - for UK & SE*/
    public static void updateReplacementOrder(Map<Id, String> oppIdWithRStatus) {
        List<Replacement_Order__c> rps = new List<Replacement_Order__c>();
        for (Replacement_Order__c rp : [
                SELECT id,
                        status__c,
                        Id_Opportunity__c
                FROM Replacement_Order__c
                WHERE Id_Opportunity__c IN:oppIdWithRStatus.keySet()
                AND status__c = 'BackOffice-Pending'
        ]) {

            rp.status__c = oppIdWithRStatus.get(rp.Id_Opportunity__c);
            rps.add(rp);
        }
        try {
            update rps;
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            rps[0].addError(e.getMessage());
        }
    }


    private static List<Opportunity_Quote_Line_Item__c> getlineitemsOppdetails(Map<Id, Id>caseOppMap) {
        List<Opportunity_Quote_Line_Item__c> oppQline = new List<Opportunity_Quote_Line_Item__c>();
        oppQline =  [SELECT id,
                Line_Item_Type__c,
                Sub_type__c,
                RecordTypeId,
                Id_Opportunity__c,
                Id_opportunity__r.Stagename,
                Id_Opportunity__r.type,
                Id_Opportunity__r.Id_Tarif__r.Name,
                Id_Opportunity__r.business_type__c,
                Id_List_Product_Price__r.Requires_Asset__c,
                Id_List_Product_Price__r.Requires_Branding__c,
                Id_List_Product_Price__r.Product_Type__c,
                Id_List_Product_Price__r.SKU__c,
                Id_opportunity__r.RecordType.developerName,
                Id_opportunity__r.AccountId,
                Id_Opportunity_Quote__c,
                Quantity__c,
                Delivery__c,
                Total_Amount__c,
                Name,
                Id_Opportunity__r.Account.Vertical__c,
                CurrencyIsoCode
        FROM Opportunity_Quote_Line_Item__c
        WHERE Id_Opportunity__c IN : caseOppMap.values()
        AND Id_Opportunity_Quote__r.Status__c = 'Accepted' ];


        return oppQline;

    }

    private static Map<Id, Set<String>> mapOppToRelatedRecordtypes(Map<Id, Set<String>> mapOppIds, String OppId, String type) {
        Set <String> types = new Set<String>();
        types.add(type);
        if (mapOppIds.containsKey(OppId)) {
            mapOppIds.get(OppId).add(type);
        } else {
            mapOppIds.put(OppId, types);
        }

        return mapOppIds;

    }


    /**
    * Actions performed when Photo Listing Process case is closed
    * @param
    *   caseList: List of new Trigger values
    *   mapOldCase:  Map of old trigger values
    * @return void
    *
    */
    @TestVisible
    public static void photoListingProcessClosingAction(List<Case> caseList, Map<Id, Case> mapOldCase) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('photoListingProcessClosingAction');
        Map<Id, Map<String, Business_Config__c>> caseConfigMap = new Map<Id, Map<String, Business_Config__c>>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        List<Case> menuProcessingClosureCheckList = new List<Case>();

        set<id> oppWithUndeliveredShipments = new Set<Id>();
        set<id> hasToCheckShipments = new Set<id>();
        Set<id> ShipmentsOppsToCheck = new set<id>();

        if (mapBusinessLogic == null) {
            return;
        }
        // Shortlist the Photo Listing Process Closed Cases
        for (Case cs : caseList) {
            if (cs.type == 'Photo Listing'
                    && cs.isclosed
                    && !mapOldCase.get(cs.id).isclosed
                    && cs.Opportunity__c != null) {
                Map<String, Business_Config__c> mapBusinessRule =
                        mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(cs.RecordTypeId));

                if (mapBusinessRule == null) {
                    continue;
                }

                // Check If Menu Processing Case closure is required or not
                if (mapBusinessRule.containsKey('checkMenuProcessingClosure')
                        && Boolean.valueOf(mapBusinessRule.get('checkMenuProcessingClosure').Business_Rule_Value__c)) {
                    menuProcessingClosureCheckList.add(cs);
                }

                // should check assets status before changing stage name
                if (mapBusinessRule.containsKey('chkShipmentStatus')
                        && Boolean.valueOf(mapBusinessRule.get('chkShipmentStatus').Business_Rule_Value__c)) {
                    ShipmentsOppsToCheck.add(cs.Opportunity__c);
                    hasToCheckShipments.add(cs.Id);
                }

                caseConfigMap.put(cs.Id, mapBusinessRule);
                caseMap.put(cs.Id, cs);
            }
        }
        if (!ShipmentsOppsToCheck.isEmpty()) {
            oppWithUndeliveredShipments = LibHelper.checkForUndeliveredShipments(ShipmentsOppsToCheck);
        }

        if (!caseConfigMap.isEmpty()) {
            updateOppsAfterPhotoListingClosure(caseMap, oppWithUndeliveredShipments,caseConfigMap,menuProcessingClosureCheckList);
        }
    }

    /**
	* @Description: update the opportunity after the Photo listing process case is closed
					1. update the opportunity only if the Menu Processing case is closed Positively
	*/
    @TestVisible
    private static void updateOppsAfterPhotoListingClosure(Map<Id, Case> caseMap,
            Set<Id> oppwithInactive,
            Map<Id, Map<String, Business_Config__c>> caseConfigMap,
            List<Case> menuProcessingClosureCheckList) {
        Set<Id> oppHavingMenuProcessing = new Set<Id>();
        List<Opportunity> oppsToBeUpdated = new List<Opportunity>();

        oppHavingMenuProcessing = getOppsWithMenuProcessingCases(menuProcessingClosureCheckList, caseConfigMap);

        for (String caseId : caseConfigMap.keySet()) {
            if (Boolean.valueOf(caseConfigMap.get(caseId).get('checkMenuProcessingClosure').Business_Rule_Value__c)
                    && oppHavingMenuProcessing.contains(caseMap.get(caseId).Opportunity__c)
                    && (oppwithInactive.isEmpty()
                    || !oppwithInactive.contains(caseMap.get(caseId).Opportunity__c))) {
                oppsToBeUpdated.add(setOppIdStage(caseMap.get(caseId).Opportunity__c,
                        caseConfigMap.get(caseId).get('positiveStageName').Business_Rule_Value__c));
            } else if(oppwithInactive.contains(caseMap.get(caseId).Opportunity__c)){
                if(caseConfigMap.get(caseId).containskey('InactiveStageName') && oppHavingMenuProcessing.contains(caseMap.get(caseId).Opportunity__c) ){
                    oppsToBeUpdated.add(setOppIdStage(caseMap.get(caseId).Opportunity__c,
                            caseConfigMap.get(caseId).get('InactiveStageName').Business_Rule_Value__c));
                }
            }else if (!Boolean.valueOf(caseConfigMap.get(caseId).get('checkMenuProcessingClosure').Business_Rule_Value__c)) {
                oppsToBeUpdated.add(setOppIdStage(caseMap.get(caseId).Opportunity__c,
                        caseConfigMap.get(caseId).get('positiveStageName').Business_Rule_Value__c));
            }
        }

        if (oppsToBeUpdated.size() > 0) {
            update oppsToBeUpdated;
        }
    }

    /**
    * @Description: Get the opportunites having positively closed Menu Processing cases
    */
    @TestVisible
    private static Set<Id> getOppsWithMenuProcessingCases(List<Case> menuProcessingClosureCheckList,
            Map<Id, Map<String, Business_Config__c>> caseConfigMap) {
        Set<Id> oppHavingMenuProcessing = new Set<Id>();
        if (menuProcessingClosureCheckList.size() > 0) {
            List<Id> oppIds = new List<Id>();
            for (Case cs : menuProcessingClosureCheckList) {
                oppIds.add(cs.Opportunity__c);
            }

            List<Case> menuProcessingCases = [
                    Select Id,Opportunity__c
                    FROM Case
                    WHERE Opportunity__c in:oppIds
                    AND Type = 'Menu Processing'
                    AND isClosed = True
                    AND Closed_Reason__c = 'Take Online'
            ];

            for (Case cs : menuProcessingCases) {
                oppHavingMenuProcessing.add(cs.Opportunity__c);
            }
        }

        return oppHavingMenuProcessing;
    }

    /**
     * @description checks whether a quality check case that has
     *
     * @param newCases
     * @param oldCases
     */
    public static void validateSharedMenu(final List<Case> newCases, final Map<Id,Case> oldCases) {

        Set<Object> recordTypeIds = new Set<Object>();
        for (Case newCase: newCases) {
            Business_Config__c config = LibBusinessConfig.getBusinessConfigFromRuleMap('QualityCheckInternalCaseClosingAction', newCase.RecordTypeId, 'ValidateSharedMenu');
            if (config != null && Boolean.valueOf(config.Business_Rule_Value__c)) {
                recordTypeIds.add(newCase.RecordTypeId);
            }
        }
        if (recordTypeIds.isEmpty()) {
            return;
        }

        Map<String, Set<Object>> fieldFilter = new Map<String, Set<Object>>{
                Case.Type.getDescribe().getLocalName() => new Set<Object>{ TYPE_QC },
                Case.Status.getDescribe().getLocalName() => new Set<Object>{ STATUS_CLOSED },
                Case.Closed_Reason__c.getDescribe().getLocalName() => new Set<Object>{ CLOSED_REASON },
                Case.RecordTypeId.getDescribe().getLocalName() => recordTypeIds
        };

        List<Case> filteredCases = oldCases == null ? ClsSObjectUtils.filterFieldValues(newCases, fieldFilter, true)
                : ClsSObjectUtils.filterFieldValues(newCases, oldCases, fieldFilter, true);
        if (filteredCases.isEmpty()) {
            return;
        }

        Set<Id> accountsIds = ClsSObjectUtils.extractSetIds(filteredCases, Case.AccountId.getDescribe().getLocalName());
        List<Account> accounts = ClsAccountSelector.getSharedMenuAccountsWOBackendIdFromIds(accountsIds);
        if (accounts.isEmpty()) {
            return;
        }

        Map<Id, Account> accountMap = new Map<Id, Account>(accounts);

        for (Case newCase: filteredCases) {
            if (accountMap.containsKey(newCase.AccountId)) {
                newCase.addError(String.format(Label.Account_Shared_Menu_Error, new List<String>{ accountMap.get(newCase.AccountId).Shared_Menu__r.GRID__c }));
            }
        }
    }

    /**
     * @description Checks if account has backend Id before closing quality check for Upgrade/Upsell opportunity
     */
    public static void validateQualityCheckClosing(final List<Case> newCases, final Map<Id,Case> oldCases) {
        Map<String, Set<Object>> fieldFilter = new Map<String, Set<Object>>{
                Case.Type.getDescribe().getLocalName() => new Set<Object>{ TYPE_QC },
                Case.Status.getDescribe().getLocalName() => new Set<Object>{ STATUS_CLOSED },
                Case.Closed_Reason__c.getDescribe().getLocalName() => new Set<Object>{ CLOSED_REASON },
                // TODO: Remove recordtype check after other countries have platform performance,
                // this is a temporary solution for countries that do not have platform performance
                Case.RecordTypeId.getDescribe().getLocalName() => new Set<Object>{
                        LibRecordTypeHelper.getRecordTypeValue('PY_Internal_Case'),
                        LibRecordTypeHelper.getRecordTypeValue('FP_Internal_Case'),
                        LibRecordTypeHelper.getRecordTypeValue('Talabat_Internal_Case')
                }
        };

        List<Case> filteredCases = oldCases == null ? ClsSObjectUtils.filterFieldValues(newCases, fieldFilter, true)
                : ClsSObjectUtils.filterFieldValues(newCases, oldCases, fieldFilter, true);
        if (filteredCases.isEmpty()) {
            return;
        }

        Set<Id> accountIds = ClsSObjectUtils.extractSetIds(filteredCases, Case.AccountId.getDescribe().getLocalName());
        Set<Id> opportunityIds = ClsSObjectUtils.extractSetIds(filteredCases, Case.Opportunity__c.getDescribe().getLocalName());

        List<Account> accounts = AccountSelector.getByIdsOpportunityIdsBusinessType(accountIds, opportunityIds, ClsOpportunityProcessor.BT_UPGRADE);

        Map<Id, Account> platformAccounts = new Map<Id, Account>(accounts);

        for (Case cs: filteredCases) {
            Business_Config__c excludeConfig = getPlatformPerformanceConfiguration(cs);
            Boolean shouldAccountHavePlatform = excludeConfig != null && platformAccounts.containsKey(cs.AccountId) && !excludeConfig.Business_Rule_Value__c.contains(platformAccounts.get(cs.AccountId).Type);
            if (shouldAccountHavePlatform && (platformAccounts.get(cs.AccountId).Platforms_Performance__r == null || platformAccounts.get(cs.AccountId).Platforms_Performance__r.isEmpty())) {
                cs.addError(Label.Quality_Check_Platform_Error);
            }
        }

    }

    private static Business_Config__c getPlatformPerformanceConfiguration(Case cs) {
        String recordTypeName = LibRecordTypeHelper.getRecordTypeValue(cs.RecordTypeId);
        Id oppRecordTypeId = LibRecordTypeHelper.getRecordTypeValue(recordTypeName.substringBefore('_')+ '_Opportunity');
        return LibBusinessConfig.getBusinessConfigFromRuleMap('PlatformRecordOnQC', oppRecordTypeId, 'ExcludeType');
    }

    /**
    * @description actions performed on "dish level photo" case closure - move opp to correct stage
    *
    * @param caseList param from a trigger handler
    * @param mapOldCase param from a trigger handler
    *
    * @return void
    */

    @TestVisible
    public static void dishLevelProcessClosingAction(List<Case> caseList, Map<Id, Case> mapOldCase) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('DishLevelProcessClosingAction');
        Map<Id, Map<String, Business_Config__c>> caseConfigMap = new Map<Id, Map<String, Business_Config__c>>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        List<Opportunity> oppsToBeUpdated = new List<Opportunity>();
        Set<Id> accountIds = new Set<Id>();

        for(Case c : caseList) {
            accountIds.add(c.AccountId);
        }
        Map<Id,Account> accountsMap = new Map<Id, Account> (AccountSelector.getByIds(accountIds));

        if (mapBusinessLogic == null) {
            return;
        }

        // Shortlist the Dish Level Closed Cases
        for (Case cs : caseList) {
            if (cs.type == 'Dish Level Photo'
                    && cs.isclosed
                    && !mapOldCase.get(cs.id).isclosed
                    && cs.Opportunity__c != null
                    && accountsMap.containsKey(cs.AccountId)
                    && accountsMap.get(cs.AccountId).Vertical__c == 'Shop') {

                Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(cs.RecordTypeId));

                if (mapBusinessRule == null) {
                    continue;
                }

                if(cs.Status == 'Closed' && cs.Closed_Reason__c == 'Take Online') {
                    oppsToBeUpdated.add(setOppIdStage(cs.Opportunity__c, mapBusinessRule.get('positiveStageName').Business_Rule_Value__c));
                } else if(cs.Status == 'Closed') {
                    oppsToBeUpdated.add(setOppIdStage(cs.Opportunity__c, mapBusinessRule.get('negativeStageName').Business_Rule_Value__c));
                }
            }
        }

        if (!oppsToBeUpdated.isEmpty()) {
            update oppsToBeUpdated;
        }
    }

    /**
    * @author Hugh Crinion
    * @date 20-Oct-19
    * @description : Major with images close case
    * SP-3791 : Global - Pandora Menu Change Process
    * @return VOID
    */
    public static void menuChangeMajorWithImageCloseCase(List<Case> caseLst)
    {
        if(caseLst == NULL)
        {
            return;
        }

        List<Case> caseLstMain = new List<case>();

        for(Case cse : caseLst)
        {
            if((cse.Type == 'Menu Change') && (cse.Case_Reason__c == 'Menu Update Major' || cse.Case_Reason__c == 'Menu Update Major with Images' || cse.Case_Reason__c == 'Imagery only update'))
            {
                caseLstMain.add(cse);
            }
        }

        Set<Id> caseIds = new Set<Id>();
        for(Case theCase : caseLstMain)
        {
            if(theCase.Case_Reason__c == 'Menu Update Major with Images' && theCase.Closed_Reason__c == 'Not Successful' && theCase.status == 'Closed' && theCase.Menu_Upd_Mjr_Check__c == true && theCase.ParentId != NULL)
            {
                caseIds.add(theCase.ParentId);
            }
        }
        Map<Id, Case> caseIdMp = CaseSelector.getCasesByIds(caseIds);

        List<Case> listOfCase = new List<Case>();
        for(Case theCase : caseLstMain)
        {
            if(caseIdMp != NULL && caseIdMp.get(theCase.ParentId) != NULL && caseIdMp.get(theCase.ParentId).Case_Reason__c == 'Imagery only update' && caseIdMp.get(theCase.ParentId).Status != 'Closed')
            {
                //update parent case here
                Case UpdateCs = new Case();
                UpdateCs.Id = caseIdMp.get(theCase.ParentId).Id;
                UpdateCs.Closed_Reason__c = 'Not Successful';
                UpdateCs.Status = 'Closed';
                UpdateCs.Root_Cause__c = theCase.Root_Cause__c;
                listOfCase.add(UpdateCs);
            }
        }

        try
        {
            //new child cases inserted here
            if(!listOfCase.isEmpty())
            {
                update listOfCase;
            }
        }
        catch(Exception ee)
        {
            system.debug('error inserting : ' + ee);
        }
    }


    /**
    * @author Hugh Crinion
    * @date 20-Oct-19
    * @description : Major with images create case
    * SP-3791 : Global - Pandora Menu Change Process
    * @return VOID
    */
    public static void menuChangeMajorWithImageCreateCase(List<Case> caseLst)
    {
        if(caseLst == NULL)
        {
            return;
        }

        List<Case> caseLstMain = new List<case>();

        for(Case cse : caseLst)
        {
            if((cse.Type == 'Menu Change') && (cse.status == 'New') && (cse.Case_Reason__c == 'Menu Update Minor'|| cse.Case_Reason__c == 'Menu Update Major' || cse.Case_Reason__c == 'Menu Update Major with Images' || cse.Case_Reason__c == 'Imagery only update'))         //cse.status == 'Approved' 
            {
                caseLstMain.add(cse);
            }
        }

        Set<Id> caseIds = new Set<Id>();

        for(Case theCase : caseLstMain)
        {
            if(theCase.Case_Reason__c == 'Menu Update Major with Images' && theCase.Closed_Reason__c == 'Not Successful' && theCase.status == 'Closed' && theCase.Menu_Upd_Mjr_Check__c == true && theCase.ParentId != NULL)
            {
                caseIds.add(theCase.ParentId);
            }
        }
        Map<Id, Case> caseIdMp = CaseSelector.getCasesByIds(caseIds);

        List<Case> listOfCase = new List<Case>();
        for(Case theCase : caseLstMain)
        {
            if(theCase.Case_Reason__c == 'Imagery only update' && theCase.Menu_Upd_Mjr_Check__c == true && theCase.status == 'New') //theCase.status == 'Menu Typing'
            {
                //create the child case
                Case childCase = new Case();
                childCase.AccountId = theCase.AccountId;
                childCase.RecordTypeId = theCase.RecordTypeId;
                childCase.Status = 'New';
                childCase.subject = 'Menu change';
                childCase.Case_Reason__c = 'Menu Update Major with Images';
                childCase.CurrencyIsoCode = theCase.CurrencyIsoCode;
                childCase.Type = theCase.Type;
                childCase.ParentId = theCase.Id;
                childCase.Menu_Upd_Mjr_Check__c = true;
                childCase.Mark_up__c = theCase.Mark_up__c;
                childCase.Mark_up_Value__c = theCase.Mark_up_Value__c;                
                listOfCase.add(childCase);
            }
        }

        try
        {
            //new child cases inserted here
            if(!listOfCase.isEmpty())
            {
                insert listOfCase;
            }
        }
        catch(Exception ee)
        {
            system.debug('error inserting : ' + ee);
        }

    }

    /**
    * @author Hugh Crinion
    * @date 20-Oct-19
    * @description : On creation of a menu change record set the correct queue to the case  
    * SP-3791 : Global - Pandora Menu Change Process
    * @return VOID
    */
    public static void setOwnerOfMenuCase(List<Case> caseLst)
    {  
        Map<String, Business_Config__c> mapProcessData = new Map<String, Business_Config__c>();
        Map<String, Map<String, Map<String, Business_Config__c>> > moamMap = LibBusinessConfig.motherOfAllBusinessMaps;
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic   = moamMap.get('MarkCompleteBtn');

        if(mapBusinessLogic == null)
        {
            return; 
        }

        for(Case theCase : caseLst)
        {
            mapProcessData = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(theCase.RecordTypeId));
            if(mapProcessData != NULL)
            {
                if(theCase.Case_Reason__c == 'Imagery only update' || theCase.Case_Reason__c == 'Menu Update Minor'|| theCase.Case_Reason__c == 'Menu Update Major' || theCase.Case_Reason__c == 'Menu Update Major with Images')
                {
                    if(mapProcessData.Containskey(theCase.Type + theCase.Case_Reason__c + theCase.Status + theCase.Account_vertical__c))
                    {
                        theCase.OwnerId = mapProcessData.get(theCase.Type + theCase.Case_Reason__c + theCase.Status + theCase.Account_vertical__c).Business_Rule_Value__c;
                    }                
                }
            }
        }
    }
     /* @description assign sharing for parent and child cases
     *
     * @param isUpdate - Whether trigger is update or insert
     * @param newCaseMap - Trigger.newMap()
     * @param oldCases - Trigger.oldMap()
     */

    public static Map<String,List<CaseShare>> childToParentCaseShare(Boolean isUpdate, Map<Id,Case> newCaseMap, Map<Id,Case> oldCases){
        List<CaseShare> parentChildInsertCaseShares = new List<CaseShare>();
        List<CaseShare> parentChildDeleteCaseShares = new List<CaseShare>();
        Map<Id,Id> caseOldOwnerIdMap = new Map<Id,Id>();
        Map<String,List<CaseShare>> returnMap = new Map<String,List<CaseShare>>();
        String whereClause = '';
        String parentCaseIds = '';
        for(Id c:newCaseMap.keySet()){
            if(newCaseMap.get(c).ParentId!=null) {
                parentCaseIds = parentCaseIds + '\'' + newCaseMap.get(c).ParentId + '\',';
            }
            else{
                parentCaseIds = parentCaseIds + '\'' + c + '\',';
            }
        }
        if(!isUpdate && parentCaseIds.length()==0){
            return null;
        }
        whereClause = 'Id IN ('+parentCaseIds.subString(0,parentCaseIds.length()-1)+')';
        String fields = 'Id,OwnerId';
        Map<Id,Case> parentCases = CaseSelector.getCaseWithDynamicCondition(whereClause,fields);
        whereClause = 'ParentId IN ('+parentCaseIds.subString(0,parentCaseIds.length()-1)+')';
        fields='Id,OwnerId,ParentId';
        Map<Id,Case> allChildCases = CaseSelector.getCaseWithDynamicCondition(whereClause,fields);
        for(Id caseId:newCaseMap.keySet()){
            if(!isUpdate) {
                if(newCaseMap.get(caseId).ParentId!=null) {
                    if(newCaseMap.get(caseId).OwnerId!=parentCases.get(newCaseMap.get(caseId).ParentId).OwnerId) {
                        parentChildInsertCaseShares.add(apexSharingForParentChildCases(newCaseMap.get(caseId).OwnerId, newCaseMap.get(caseId).ParentId));
                        parentChildInsertCaseShares.add(apexSharingForParentChildCases(parentCases.get(newCaseMap.get(caseId).ParentId).OwnerId, caseId));
                    }
                }
            }
            else if(isUpdate && newCaseMap.get(caseId).OwnerId!=oldCases.get(caseId).OwnerId){
                if(parentCases.containsKey(caseId)){
                    Boolean isAlreadyPresent = false;
                    if(allChildCases!=null) {
                        for (Id c : allChildCases.keySet()) {
                            if (allChildCases.get(c).ParentId == caseId) {
                                parentChildInsertCaseShares.add(apexSharingForParentChildCases(newCaseMap.get(caseId).OwnerId, c));
                                if (oldCases.get(caseId).OwnerId == allChildCases.get(c).OwnerId) {
                                    isAlreadyPresent = true;
                                    break;
                                }
                                if (!isAlreadyPresent) {
                                    caseOldOwnerIdMap.put(c, oldCases.get(caseId).OwnerId);
                                }
                            }
                        }
                    }
                }
                if(allChildCases!=null) {
                    if(allChildCases.containsKey(caseId)){
                        if(newCaseMap.get(caseId).OwnerId != parentCases.get(allChildCases.get(caseId).ParentId).OwnerId) {
                            parentChildInsertCaseShares.add(apexSharingForParentChildCases(newCaseMap.get(caseId).OwnerId,allChildCases.get(caseId).ParentId));
                            parentChildInsertCaseShares.add(apexSharingForParentChildCases(parentCases.get(allChildCases.get(caseId).ParentId).OwnerId, caseId));
                        }
                        Boolean isAlreadyPresent = false;
                        for (Id c : allChildCases.keySet()) {
                            if (oldCases.get(caseId).OwnerId == allChildCases.get(c).OwnerId) {
                                isAlreadyPresent = true;
                                break;
                            }
                            if (!isAlreadyPresent) {
                                caseOldOwnerIdMap.put(allChildCases.get(caseId).ParentId, oldCases.get(caseId).OwnerId);
                            }
                        }
                    }
                }
            }
        }
        whereClause = '';
        String caseIds='';
        String ownerIds='';
        for(Id caseId:caseOldOwnerIdMap.keySet()){
            caseIds = caseIds+'\''+caseId+'\',';
            ownerIds = ownerIds+'\''+caseOldOwnerIdMap.get(caseId)+'\',';
        }
        if(caseIds.length()>0){
            whereClause = 'RowCause = \'Manual\' AND CaseId IN ('+caseIds.substring(0,caseIds.length()-1)+')';
            if(ownerIds.length()>0){
                whereClause = whereClause+' AND UserOrGroupId IN ('+ownerIds.substring(0,ownerIds.length()-1)+')';
            }
        }
        fields = 'Id';
        if(whereClause!='') {
            parentChildDeleteCaseShares = CaseSelector.getCaseSharesWithDynamicCondition(whereClause, fields);
        }
        returnMap.put('insert',parentChildInsertCaseShares);
        returnMap.put('delete',parentChildDeleteCaseShares);
        return returnMap;
    }

    /**
     * @description create sharing record
     *
     * @param ownerId
     * @param caseId
     */
    public static CaseShare apexSharingForParentChildCases(Id ownerId, Id caseId){
        CaseShare childToParentCaseShare = new CaseShare();
        childToParentCaseShare.CaseId = caseId;
        childToParentCaseShare.UserOrGroupId = ownerId;
        childToParentCaseShare.CaseAccessLevel = 'Read';
        childToParentCaseShare.RowCause = 'Manual';
        return childToParentCaseShare;
    }

    /**
    * @author Hugh Crinion
    * @date 20-Oct-19
    * @description : Used to prepare case for menu change
    * also closes case on C/D platform performance
    * SSC-398 : APAC New Markets - Menu Change Process
    * @return VOID
    */
    public static void prepMenuUpdateMjr(List<Case> caseLst)
    {   
        if(caseLst == NULL)
        {
            return;
        }
        List<Case> newCaseLst = new List<Case>();
        Set<Id> accountIds = new Set<Id>();

        for (Case theCase : caseLst) 
        {
            //set the owner to the queue on creation
            try
            {
                if(theCase.Case_Reason__c == 'Menu Update Major with Images' && theCase.Menu_Upd_Mjr_Check__c == false)
                {
                    theCase.Case_Reason__c = 'Imagery only update';
                    theCase.status = 'New';     //'Approved'
                    theCase.Menu_Upd_Mjr_Check__c = true;
                }  
                else if(theCase.Case_Reason__c == 'Imagery only update')
                {
                    theCase.status = 'New';     //'Approved'
                    
                }

                if(theCase.type == 'Menu Change' && (theCase.Case_Reason__c == 'Imagery only update' || theCase.Case_Reason__c == 'Menu Update Major with Images' || theCase.Case_Reason__c == 'Menu Update Major' || theCase.Case_Reason__c == 'Menu Update Minor'))
                {
                    accountIds.add(theCase.accountId);
                    newCaseLst.add(theCase);
                }
            }
            catch(Exception ee)
            {
                system.debug('error with ownerID ' + ee);
            }
        }

/*
NOT USED AS ITS NEEDED FOR APPROVAL PROCESS=================
        Map<Id, Platform_Performance__c> accountIdMp = PlatformPerformanceSelector.getPlatformPerformancesForAccountsMap(accountIds);
        if (accountIdMp == NULL || newCaseLst == NULL) 
        {
            return;
        }

        for (Case theCase : newCaseLst) 
        {
            //C or D then auto close
            try 
            {
                if(accountIdMp.get(theCase.accountId).GMVClass__c == 'C' || accountIdMp.get(theCase.accountId).GMVClass__c == 'D')
                {
                    //close case here
                    theCase.status = 'Closed';
                    theCase.Closed_Reason__c = 'Unsuccessful';
                    theCase.Root_Cause__c = 'Mark up rejected';
                }                   
            } 
            catch (Exception ee) 
            {
                System.debug(ee);
            }
        }*/
    }
    /**
    * @author Tarun Jain
    * @date 25-Feb-20
    * @description : Capture Account on case based on the backend Id on platform performance
    * SCC-124
    * @return VOID
    */
    public static void captureAccountOnCase(List<Case> newCases) {
        map<String,List<Case>> backendIdCaseMap = new map<String,List<Case>>();
        for(Case newCase:newCases){
            if(newCase.PP_Backend_Id__c==null || newCase.AccountId!=null) {
                continue;
            }
            //Set map of backend id with list of case
            if(backendIdCaseMap.keySet().size()!=0 && backendIdCaseMap.containsKey(newCase.PP_Backend_Id__c)){
                List<Case> caseList = backendIdCaseMap.get(newCase.PP_Backend_Id__c);
                caseList.add(newCase);
                backendIdCaseMap.put(newCase.PP_Backend_Id__c,caseList);
            }
            else{
                List<Case> caseList = new List<Case>();
                caseList.add(newCase);
                backendIdCaseMap.put(newCase.PP_Backend_Id__c.toLowerCase(),caseList);
            }
        }
        if(backendIdCaseMap.keySet().size()==0){
            return;
        }
        try {
            //Get platform performance records
            List<Platform_Performance__c> platformPerformanceList = PlatformPerformanceSelector.getPlatformPerformancesByBackendIds(backendIdCaseMap.keySet());

            for (Platform_Performance__c platformPerformance : platformPerformanceList) {
                for (Case newCase : backendIdCaseMap.get(platformPerformance.Backend_ID__c.toLowerCase())) {
                    if (newCase.Platform__c == platformPerformance.Platform__c) {
                        newCase.AccountId = platformPerformance.Account__c;
                    }
                }
            }
        }catch(Exception e){
            Loggingutility.createLog('API_FormstackCC','CC-Formstack','','');
            LoggingUtility.log('API_FormstackCC',e.getMessage());
            LoggingUtility.commitLogs();
        }
    }


    /*******************************************************************************************************
   * @description Check if new retention case is being created under same account with existing open
   *                 retention case then show error and block creation of case(SSC-2547)
   * @param newCases from Before Trigger (Trigger.new)
   */
    public static void blockAnotherRetentionCaseCreationForAccount(List<Case> newCases){
        // getting Required business config from Business Config object
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('RetentionCaseAccountUpdate');
        // if no record exist, exit the method
        if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) {
            return;
        }
        // set of Account Id for which exisiting open Retention cases will be queried
        Set<Id> accountIdSet = new Set<Id>();
        // list of cases which are of retention type and not closed
        List<Case> retentionTypeCasesList = new List<Case>();
        // This map stored duplicate case check values to apply in condition and Query
        Map<String, String> caseDuplicateCheckBusinessLogic = new Map<String, String>();
        // this variable stores fields which will be part of query in order to avoid extra field
        String fieldsToQuery = '';
        // map to stored AccountID and associated open case
        Map<Id,Case> accountIdAndCaseMap =  new  Map<Id,Case>();
        Map<Id,Case> openCasesForAccountMap = new Map<Id,Case>();
        Map<String, Business_Config__c> mapBusinessRule = new Map<String, Business_Config__c>();
        for(Case newCase : newCases) {
            String recordTypeName = LibRecordTypeHelper.getRecordTypeValue(newCase.RecordTypeId);
            if(recordTypeName == null || recordTypeName == ''){
                continue;
            }
            // fetching business config for case record type
            mapBusinessRule = mapBusinessLogic.containsKey(recordTypeName) ? mapBusinessLogic.get(recordTypeName) : null;
            if(mapBusinessRule == null){
                continue;
            }
            // getting list of field which will be added to dynamic query
            fieldsToQuery = mapBusinessRule.containsKey('FieldsToQuery')? mapBusinessRule.get('FieldsToQuery').Business_Rule_Value__c:'';
            String duplicateCheckLogic = mapBusinessRule.containsKey('duplicateRetentionCaseCheck')? mapBusinessRule.get('duplicateRetentionCaseCheck').Business_Rule_Value__c:'';
            if(String.isBlank(duplicateCheckLogic) || String.isBlank(fieldsToQuery)){
                continue;
            }
            caseDuplicateCheckBusinessLogic =
                    (Map<String, String>) JSON.deserialize(duplicateCheckLogic, Map<String, String>.class);

            // condition check for Retention case which are open and being inserted (before insert)
            Boolean conditionForOpenRetentionCase = caseDuplicateCheckBusinessLogic.ContainsKey('IsClosed') && newCase.IsClosed == Boolean.valueoF(caseDuplicateCheckBusinessLogic.get('IsClosed'))
                    && caseDuplicateCheckBusinessLogic.ContainsKey('Type') && newCase.Type == caseDuplicateCheckBusinessLogic.get('Type');
            if(conditionForOpenRetentionCase && String.isNotBlank(newCase.AccountId)){
                accountIdSet.add(newCase.AccountId);
                retentionTypeCasesList.add(newCase);
            }

        }
        if(accountIdSet.isEmpty() || retentionTypeCasesList.isEmpty()){
            return;
        }

        // getting existing open cases for the account for which another retention case is being inserted
        openCasesForAccountMap = existingOpenCasesForAccount(accountIdSet,caseDuplicateCheckBusinessLogic,fieldsToQuery);

        // no existing open case then no issues. Case will be created
        if(openCasesForAccountMap == null || openCasesForAccountMap.isEmpty()){
            return;
        }

        for(Case caseRec : openCasesForAccountMap.values()){
            accountIdAndCaseMap.put(caseRec.AccountId,caseRec);
        }
        // if open retention case exist for associated Account then throw an error
        for(Case retentionCase : retentionTypeCasesList){
            if(accountIdAndCaseMap.containsKey(retentionCase.AccountId) && accountIdAndCaseMap.get(retentionCase.AccountId) != null){
                retentionCase.addError(Label.Retention_pending_with_this_Account);
            }
        }

    }

    /*******************************************************************************************************
    * @description generating dynamic query conditions to get existing open retention cases for Account SSC-2547
    * @param accountIdSet AccountId to get cases
    * @param caseDuplicateCheckBusinessLogic contains Where logic of query
	* @param fields fields to be queried
    * @return Map<Id,Case>
    */

    private static Map<Id,Case> existingOpenCasesForAccount(Set<Id> accountIdSet,
            Map<String, String> caseDuplicateCheckBusinessLogic,
            String fields){
        String whereClause = '';
        String accountIdsString = '';
        Map<Id,Case> existingCasesOnAccount = new Map<Id,Case>();
        List<String> andConditions = new List<String>();
        // converting account Id set for string query IN condition
        for(Id idval:accountIdSet){
            accountIdsString= accountIdsString +   + '\'' + idval + '\',';
        }
        // creating Where conditions parameter
        for(String s:caseDuplicateCheckBusinessLogic.keyset()){
            String soqlCriteria = getSOQLCriteria(s,'=',caseDuplicateCheckBusinessLogic.get(s));
            if(!String.isBlank(soqlCriteria)){
                andConditions.add(soqlCriteria);
            }
        }
        String soqlCriteriaForIN = getSOQLCriteria(fields,'IN',accountIdsString.subString(0,accountIdsString.length()-1));
        andConditions.add(soqlCriteriaForIN);
        // add conditions with AND logical operator
        whereClause = String.join(andConditions, ' AND ');
        // making call to dynamic query to fetch open retention type cases for account
        existingCasesOnAccount = CaseSelector.getCaseWithDynamicCondition(whereClause,fields);
        return existingCasesOnAccount;
    }
    /*******************************************************************************************************
    * @description generating where criteria of SOQL based on field name , operator and value SSC-2547-
    * @param fieldName field Api name to check
    * @param operator operator to apply for check
    * @param fieldValue value to compare
    * @return String
    */

    public static String getSOQLCriteria(String fieldName,String operator, String fieldValue){
        String soqlCriteria = '';

        if (Schema.SObjectType.Case.fields.getMap().get(fieldName).getDescribe().getType() == Schema.DisplayType.PICKLIST || Schema.SObjectType.Case.fields.getMap().get(fieldName).getDescribe().getType() == Schema.DisplayType.STRING){
            soqlCriteria = fieldName + ' '  + operator + ' \'' + fieldValue + '\'';
        }
        if(Schema.SObjectType.Case.fields.getMap().get(fieldName).getDescribe().getType() == Schema.DisplayType.BOOLEAN){
            soqlCriteria =  fieldName + ' '  + operator + ' '+ fieldValue;
        }
        if(Schema.SObjectType.Case.fields.getMap().get(fieldName).getDescribe().getType() == Schema.DisplayType.REFERENCE){
            soqlCriteria =  fieldName + ' '  + operator + ' (' + fieldValue + ')';
        }
        return soqlCriteria;
    }

    /*******************************************************************************************************
    * @description update Account status field based on after insert and updated based on case type
    *              ,Is_the_restaurant_going_to_take_orders__c and closing status (Successful,invalid) : SSC-2547 -
    * @param caseLst (Trigger.New)
    * @param oldMap (Trigger.OldMap)
    */
    public static void updateAccountStatusForRetentionCase(List<Case> caseLst, Map<Id, Case> oldMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('RetentionCaseAccountUpdate');
        Map<Case, Map<String, Business_Config__c>> caseConfigMap = new Map<Case, Map<String, Business_Config__c>>();
        Map<String, Business_Config__c> mapBusinessRule = new Map<String, Business_Config__c>();
        Set<Id>setAccountIds = new Set<Id>();
        if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) {
            return;
        }
        for (Case newCase : caseLst) {
            // fetching business config record based on record type name
            String recordTypeName = LibRecordTypeHelper.getRecordTypeValue(newCase.RecordTypeId);
            if(recordTypeName == null || recordTypeName == ''){
                continue;
            }
            // fetching business config for case record type
            mapBusinessRule = mapBusinessLogic.containsKey(recordTypeName) ? mapBusinessLogic.get(recordTypeName) : null;
            if (mapBusinessRule == null) {
                continue;
            }

            String caseType = mapBusinessRule.containsKey('Type') ? mapBusinessRule.get('Type').Business_Rule_Value__c:null;
            String restaurantTakingOrder = mapBusinessRule.containsKey('restaurantTakingOrder') ? mapBusinessRule.get('restaurantTakingOrder').Business_Rule_Value__c:null;
            String closedStatus = mapBusinessRule.containsKey('ClosedStatus') ? mapBusinessRule.get('ClosedStatus').Business_Rule_Value__c:null;
            if(caseType ==  null || restaurantTakingOrder == null || closedStatus == null){
                continue;
            }
            // checking below conditions
            // 1. (after insert) Case type = Retention and Restaurant not taking order
            Boolean retentionCaseNoOrder = newCase.Type != null && caseType == newCase.Type &&
                    newCase.Is_the_restaurant_going_to_take_orders__c != null && restaurantTakingOrder == newCase.Is_the_restaurant_going_to_take_orders__c &&
                    oldMap == null && newCase.AccountId != null ;
            // 2. (After update) Case type = Retention and Restaurant not taking order (previously field was empty)
            Boolean caseRetentionOrderChangedToNo = oldMap != null && caseType == newCase.Type && oldMap.containsKey(newCase.Id) && newCase.Is_the_restaurant_going_to_take_orders__c != null &&
                    restaurantTakingOrder == newCase.Is_the_restaurant_going_to_take_orders__c
                    && newCase.Is_the_restaurant_going_to_take_orders__c != oldMap.get(newCase.Id).Is_the_restaurant_going_to_take_orders__c;

            // 3. (After Update) case status updated
            Boolean statusChanged = oldMap != null && caseType == newCase.Type && newCase.Is_the_restaurant_going_to_take_orders__c != null && restaurantTakingOrder == newCase.Is_the_restaurant_going_to_take_orders__c
                && oldMap.containsKey(newCase.Id) && newCase.Status != oldMap.get(newCase.Id).Status && newCase.Closed_Reason__c != null
                && newCase.Closed_Reason__c != closedStatus;

            if (retentionCaseNoOrder || statusChanged || caseRetentionOrderChangedToNo ) {
                setAccountIds.add(newCase.AccountId);
                caseConfigMap.put(newCase, mapBusinessRule);

            }
        }
        // if account to be updated are >0, then proceed
        if (!setAccountIds.isEmpty()) {
            // fetch account map based on AccountIdSet from account utility class
            Map<Id, Account> accMap = AccountSelector.getAccountMapFromAccIdSet(setAccountIds);
            updateAccountStatusForRetention(caseConfigMap, accMap);
        }

    }


    /*******************************************************************************************************
    * @description internal method to update account status based on existing account status and
    							business configuration SSC-2547
    * @param caseConfigMap case record with associated business config
    * @param accMap  Account map to update account status field
   */
    private static void updateAccountStatusForRetention(Map<Case, Map<String, Business_Config__c>> caseConfigMap,
            Map<Id, Account> accMap) {
        // list of accounts to be updated
        List<Account> accountsToUpdateList = new List<Account>();

        for (Case updatedCase : caseConfigMap.keySet()) {
            Map<String, String> caseAccountStatusMap = new Map<String, String>();
            Account theAcc = accMap.get(updatedCase.AccountId);
            Map<String, Business_Config__c> mapBusinessRule = caseConfigMap.get(updatedCase);
            // getting all status which needs to be verified during account update conditions
            if (mapBusinessRule.containsKey('CaseAccountStatusMap')) {
                caseAccountStatusMap =
                        (Map<String, String>) JSON.deserialize(mapBusinessRule.get('CaseAccountStatusMap').Business_Rule_Value__c,
                                Map<String, String>.class);

            }

            if(caseAccountStatusMap == null || caseAccountStatusMap.isEmpty()){
                continue;
            }
            String closedReasonBusinessConfig =  mapBusinessRule.containsKey(updatedCase.Type + 'ClosingStatus')? mapBusinessRule.get(updatedCase.Type + 'ClosingStatus').Business_Rule_Value__c:'';
            // If case is successfully closed and Account existing status is Active - Temp. Unavailable
            // and case closed either successful or invalid only then change it to Active status
            Boolean caseClosedSuccessfulWithRetentionAccount = updatedCase.IsClosed &&
                    updatedCase.Closed_Reason__c != null && String.isNotBlank(closedReasonBusinessConfig) &&
                    closedReasonBusinessConfig.containsIgnoreCase(updatedCase.Closed_Reason__c) &&
                    caseAccountStatusMap.containsKey(updatedCase.Type + 'AccountStatus') &&
                    theAcc.Account_Status__c != null && theAcc.Account_Status__c == caseAccountStatusMap.get(updatedCase.Type + 'AccountStatus');

            // if cases is not closed and restaurant not taking order and account existing status is not terminated then
            // change it to Active - Temp. Unavailable
            Boolean openRetentionCaseNoOrder = !updatedCase.IsClosed && caseAccountStatusMap.containsKey('TerminatedAccountStatus')
                    &&  !caseAccountStatusMap.get('TerminatedAccountStatus').containsIgnoreCase(theAcc.Account_Status__c);
            if (caseClosedSuccessfulWithRetentionAccount){
                theAcc.Account_Status__c = caseAccountStatusMap.get('ActiveAccountStatus');
                accountsToUpdateList.add(theAcc);
            }

            else if (openRetentionCaseNoOrder) {
                theAcc.Account_Status__c = caseAccountStatusMap.get(updatedCase.Type + 'AccountStatus');
                accountsToUpdateList.add(theAcc);
            }
        }
        try{
            if (!accountsToUpdateList.isEmpty()) {
                update accountsToUpdateList;
            }
        }
        catch(Exception e){
            LoggingUtility.createLog('ClsCaseProcessor','UpdateAccountStatus','','');
            LoggingUtility.log('ClsCaseProcessor',e.getMessage());
            LoggingUtility.commitLogs();
        }

    }

    /**
    * @description Method launches process to check if the limit of onboarding failed cases has been reached
    *
    * @param updatedCases cases that have been updated through trigger
    */
    public static void processFailedOnboarding(List<Case> updatedCases) {
        List<Case> onboardingFailedCases = ClsSObjectUtils.filterFieldValues(updatedCases, new Map<String, Set<Object>> {
            Case.Type.getDescribe().getLocalName() => new Set<Object> { CaseSelector.TYPE_ONBOARDING },
            Case.Closed_Reason__c.getDescribe().getLocalName() => new Set<Object> { CaseSelector.CR_NOT_SUCCESSFUL },
            Case.Status.getDescribe().getLocalName() => new Set<Object> { 'Closed' }
        }, true);
        if (onboardingFailedCases.isEmpty()) { return; }
        CloseOpportunities_Utils processUtils = CloseOpportunities_Utils.getInstance();
        List<Opportunity> opportunitiesToUpdate = processUtils.checkFailedOpportunities(onboardingFailedCases);
        processUtils.updateOpportunities(opportunitiesToUpdate).commitLogs();
    }
}
