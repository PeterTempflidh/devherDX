/**
 * File:        EventBusHelper.cls<br/> 
 * Project:     DE MIGRATION <br/>
 * Date:        November 22, 2017<br/>
 * Created By:  <br/>
 * *************************************************************************<br/>
 * Description:  Helper for the logic To Even bus Enrichment for Account/Contact Fields SP-1697<br/>
 * *************************************************************************<br/>
 * History:<br/>
 * Date:                Modified By:            Description:<br/>
 * TODO: Re-design the functionality to be able to test it properly (Refactor void methods into one's that are returning values).
 */
public inherited sharing class EventBusHelper {

    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    private static Map<String, String> mpJsonById = new Map<String, String>();
    private static Map<String, String> mpAddressTypeById = new Map<String, String>();
    private static Map<String, String> mpPlatformFieldsById = new Map<String, String>();
    private static Map<String, Account> mpAccount = new Map<String, Account>();
    private static Map<String, Set<String>> mpContactTypeById = new Map<String, Set<String>>();
    private static Map<String, Account> mpAccountToUpdate = new Map<String, Account>();
    private static Boolean blnExecute = true;

    public static Integer numberOfExecutions = 0;
    public static Set<Id> stAlreadyProcessed = new Set<Id>();

    /**
    * @author william Castillo
    * @date November 22, 2017
    * @description SP-1697, check with the information of the custom settings if something change on the object.
    * @param  
    */
    //Return type is temporary, until redesigned, for testing purposes.
    public static List<Backend_Integration__e> checkChanges(Map<Id, SObject> mpNewRecord, Map<Id, SObject> mpOldRecord, Map<String, String> mpUserEmail, Boolean isInsert) {
        Backend_Integration__e BackIntEvent = new Backend_Integration__e();
        SObject sObjOld;
        List<Backend_Integration__e> lstBackIntEvent = new List<Backend_Integration__e>();
        if (mpNewRecord.isEmpty()) {
            return lstBackIntEvent;
        }
        String jsonField;
        List<FieldEventMapping> lstFldMap = new List<FieldEventMapping>();
        Boolean publishEvent = true;

        Map<String, Backend_Integration__e> mpParentBackInt = new Map<String, Backend_Integration__e>();

        Map<Id, SObject> mpNewParentAccounts = new Map<Id, SObject> ();
        Account oldAccount ;
        Account newAccount ;

        Map<Id, Account> mpAccWthPar = new Map<Id, Account> (AccountSelector.getByIds(mpNewRecord.keySet()));

        final SObjectType objectType = mpNewRecord.values().get(0).getSObjectType();
        final String accountIdField = objectType == Account.getSObjectType()
                ? Account.Id.getDescribe().getLocalName()
                : ((objectType == AddressDetail__c.getSObjectType() || objectType == Platform_Performance__c.getSObjectType())
                        ? AddressDetail__c.Account__c.getDescribe().getLocalName()
                        : Contact.AccountId.getDescribe().getLocalName());

        Set<Id> accountIds = ClsSObjectUtils.extractSetIds(mpNewRecord.values(), accountIdField);
        Map<Id, List<AddressDetail__c>> accountAddressDetailsMap = getAccountAddressDetailMap(accountIds);
        Map<Id, List<Contact>> accountContactsDetailsMap = getAccountContactsDetailMap(accountIds);
        for (SObject sObjNew : mpNewRecord.values()) {
            sObjOld = mpOldRecord.get(sObjNew.Id);
            if (publishEvent) {
                BackIntEvent = new Backend_Integration__e();
                BackIntEvent.Event_Type__c = String.valueOf(sObjNew.getSObjectType());
                BackIntEvent.New__c = false;
                BackIntEvent.AccountId__c = (String) sObjNew.get(accountIdField);
                if (BackIntEvent.Event_Type__c == 'Account') {
                    oldAccount = (Account) sObjOld;
                    newAccount = (Account) sObjNew;
                    BackIntEvent.Account_GRID__c = (String) sObjNew.get('GRID__c');
                    if (accountAddressDetailsMap.containsKey(BackIntEvent.AccountId__c)) {
                        BackIntEvent.Addresses__c = JSON.serialize(accountAddressDetailsMap.get(BackIntEvent.AccountId__c));
                    }
                } else if (BackIntEvent.Event_Type__c == 'AddressDetail__c' || BackIntEvent.Event_Type__c == 'Platform_Performance__c') {
                    BackIntEvent.Account_GRID__c = mpAccount.get(BackIntEvent.AccountId__c).GRID__c;
                    if (accountAddressDetailsMap.containsKey(BackIntEvent.AccountId__c)) {
                        BackIntEvent.Addresses__c = JSON.serialize(accountAddressDetailsMap.get(BackIntEvent.AccountId__c));
                    }
                } else {
                    BackIntEvent.Account_GRID__c = mpAccount.get(BackIntEvent.AccountId__c).GRID__c;
                    if (BackIntEvent.Event_Type__c == 'Contact') {
                        BackIntEvent.Contact_Role__c = (String) sObjNew.get('Contact_Role__c');
                        if (accountContactsDetailsMap.containsKey(BackIntEvent.AccountId__c)) {
                            BackIntEvent.Contacts__c = JSON.serialize(accountContactsDetailsMap.get(BackIntEvent.AccountId__c));
                        }
                    }
                }
                if (sObjNew.getSObjectType().getDescribe().fields.getMap().keySet().contains('recordtypeid')) {
                    BackIntEvent.Record_type__c = LibRecordTypeHelper.getRecordTypeValue(String.valueOf(sObjNew.get('RecordTypeId')));
                } else {
                    BackIntEvent.Record_type__c = LibRecordTypeHelper.getRecordTypeValue(mpAccount.get(BackIntEvent.AccountId__c).RecordTypeId);
                }
                BackIntEvent.Account_Country_Code__c = mpAccount.get(BackIntEvent.AccountId__c).Account_Country_Code__c;

                publishEvent = false;
            }

            jsonField = mpJsonById.get(BackIntEvent.AccountId__c);

            if (jsonField != null && jsonField != '') {
                lstFldMap = (List<EventBusHelper.FieldEventMapping>) JSON.deserializeStrict(jsonField, List<EventBusHelper.FieldEventMapping>.class);
            }

            for (FieldEventMapping fldEvnMap : lstFldMap) {
                if (fldEvnMap.ObjectName != String.valueOf(sObjNew.getSObjectType())) {
                    continue;
                }
                if (BackIntEvent.Event_Type__c == 'AddressDetail__c') {
                    publishEvent = true;
                }
                if (fldEvnMap.ObjectField == 'Parent.GRID__c') {
                    BackIntEvent.Account_Parent_GRID__c = mpAccWthPar.get(newAccount.Id).Parent.GRID__c;
                    BackIntEvent.Account_Parent_Type__c = mpAccWthPar.get(newAccount.Id).Parent.Type;

                    if (newAccount.ParentId != null && newAccount.ParentId != oldAccount.ParentId) {
                        publishEvent = true;
                        mpNewParentAccounts.put(newAccount.ParentId, new Account (Id = newAccount.ParentId));
                        mpAccountToUpdate.put(newAccount.ParentId, new Account (Id = newAccount.ParentId, Published_on_eventBus__c = true));

                    }
                    mpParentBackInt.put(newAccount.ParentId, BackIntEvent);

                } else if (fldEvnMap.ObjectField == 'Shared_Menu__r.GRID__c') {
                    if (newAccount.Shared_Menu__c != null && newAccount.Shared_Menu__c != oldAccount.Shared_Menu__c) {
                        publishEvent = true;
                        BackIntEvent.Shared_Menu_GRID__c = mpAccWthPar.get(newAccount.Id).Shared_Menu__r.GRID__c;
                    }
                } else {
                    if (isInsert || sObjNew.get(fldEvnMap.ObjectField) != sObjOld.get(fldEvnMap.ObjectField) || Test.isRunningTest()) {
                        publishEvent = true;
                    }
                    Boolean addressNotCorrectType = fldEvnMap.ObjectName == 'AddressDetail__c' && BackIntEvent.Event_Type__c == 'AddressDetail__c' && !isObjectCorrectType('AddressDetail__c', sObjNew);
                    if (addressNotCorrectType) {
                        AddressDetail__c correctAddressType = getAddressDetailWithCorrectType(accountAddressDetailsMap.get(BackIntEvent.AccountId__c));
                        if (correctAddressType != null) {
                            BackIntEvent.put(fldEvnMap.EventField, correctAddressType.get(fldEvnMap.ObjectField));
                        }
                    } else if (fldEvnMap.ObjectName == 'Contact') {
                        if ((sObjNew.get('contact_Role__c') == 'Billing Manager' && fldEvnMap.Type == 'Billing')
                            || (sObjNew.get('contact_Role__c') != 'Billing Manager' && fldEvnMap.Type == null))
                        {
                            BackIntEvent.put(fldEvnMap.EventField, sObjNew.get(fldEvnMap.ObjectField));
                        }
                    } else {
                        BackIntEvent.put(fldEvnMap.EventField, sObjNew.get(fldEvnMap.ObjectField));
                    }

                    if (fldEvnMap.ObjectField == 'OwnerId') {
                        BackIntEvent.put(fldEvnMap.EventField, mpUserEmail.get((String) sObjNew.get(fldEvnMap.ObjectField)));
                    }
                }
            }
            if (publishEvent) {
                lstBackIntEvent.add(BackIntEvent);
                stAlreadyProcessed.add(sObjNew.Id);
            }
        }
        if (mpNewParentAccounts.keySet().size() > 0) {
            EventBusHelper.numberOfExecutions++;
            if (EventBusHelper.numberOfExecutions < 5) {
                EventBusHelper.ValidateRecordsPlatform('Account', mpNewParentAccounts);
            }
        } else {
            if (mpAccountToUpdate.size() > 0) {
                blnExecute = false;
                update mpAccountToUpdate.values();
            }
        }
        return publishEvents(lstBackIntEvent);
    }

    private static AddressDetail__c getAddressDetailWithCorrectType(List<AddressDetail__c> addressDetails) {
        for (AddressDetail__c addressDetail : addressDetails) {
            if (isObjectCorrectType('AddressDetail__c', addressDetail)) {
                return addressDetail;
            }
        }
        return null;
    }

    /**
    * @author william Castillo
    * @date November 22, 2017
    * @description SP-1697, Validate the records if apply to send it.
    * @param  
    */
    //Return type is temporary, until redesigned, for testing purposes.
    public static List<Backend_Integration__e> ValidateRecords(String sObjType, Map<Id, SObject> mpNewRecord, Map<Id, SObject> mpOldRecord, Boolean isInsert) {

        if (!blnExecute) {
            return null;
        }
        Map<String, Map<String, Business_Config__c>> mapProcessData = moam.get('EventBus');
        Set<String> stAccTypeExclude = new Set<String>();

        Map<Id, SObject> mpNewRecordClone = mpNewRecord.clone();
        Map<Id, SObject> mpOldRecordClone = mpOldRecord.clone();
        Set<Id> stAcc = new Set<Id>();
        Map<String, String> mpUserEmail = new Map<String, String>();
        Set<Id> stExcRecordAcc = new Set<Id>();
        String strDevNamRecord;
        Boolean blnTypeValid = true;
        Set<String> stAccTypeWithOutPlatform = new Set<String>();

        String strFieldId;

        if (sObjType == 'Account') {
            strFieldId = 'id';
        } else if (sObjType == 'AddressDetail__c' || sObjType == 'Platform_Performance__c') {
            strFieldId = 'Account__c';
        } else if (sObjType == 'Contact') {
            strFieldId = 'AccountId';
        }

        for (SObject obj : mpNewRecord.values()) {
            stAcc.add(String.valueOf(obj.get(strFieldId)));
        }

        for (Account acc : retrieveAccountDetails(stAcc, true)) {
            strDevNamRecord = LibRecordTypeHelper.getRecordTypeValue(acc.RecordTypeId);

            if (mapProcessData == null || !mapProcessData.containsKey(strDevNamRecord)) {
                stExcRecordAcc.add(acc.Id);
                continue;
            }
            stAccTypeExclude.addAll(mapProcessData.get(strDevNamRecord).get('TypesException').Business_Rule_Value__c.split(','));
            if (mapProcessData.get(strDevNamRecord).containsKey('AccountTypeWithOutPlatform')) {
                stAccTypeWithOutPlatform.addAll(mapProcessData.get(strDevNamRecord).get('AccountTypeWithOutPlatform').Business_Rule_Value__c.split(','));
            }

            Boolean accountShouldBeExcluded = (stAccTypeWithOutPlatform.contains(acc.Type) && !acc.Published_on_eventBus__c) || stAccTypeExclude.contains(acc.Type);
            Boolean accountMissingPlatformPerformance = (acc.Platforms_Performance__r == null || acc.Platforms_Performance__r.isEmpty()) && !stAccTypeWithOutPlatform.contains(acc.Type);
            if (accountShouldBeExcluded || accountMissingPlatformPerformance) { // exclude type od the accounts.
                stExcRecordAcc.add(acc.Id);
                continue;
            }

            Integer numPlatExc = 0 ;
            Set<String> stExcTypePlatforms = new Set<String>();

            if (mapProcessData.get(strDevNamRecord).containsKey('PlatformExceptions')) {
                stExcTypePlatforms.addAll(mapProcessData.get(strDevNamRecord).get('PlatformExceptions').Business_Rule_Value__c.split(','));
            }
            if (!stAccTypeWithOutPlatform.contains(acc.Type)) {
                for (Platform_Performance__c plaTemp : acc.Platforms_Performance__r) {
                    if (stExcTypePlatforms.contains(plaTemp.Platform__c)) {
                        numPlatExc++;
                    }
                }
                if (numPlatExc == acc.Platforms_Performance__r.size()) {
                    stExcRecordAcc.add(acc.Id);
                    continue;
                }
            }
            mpUserEmail.put(acc.OwnerId, acc.Owner.Email);
            mpJsonById.put(acc.Id, mapProcessData.get(strDevNamRecord).get('FieldsMap').Business_Rule_Value__c);
            mpAddressTypeById.put(acc.Id, mapProcessData.get(strDevNamRecord).get('AddressType').Business_Rule_Value__c);
            mpContactTypeById.put(acc.Id, new set<String>((mapProcessData.get(strDevNamRecord).get('ContactType').Business_Rule_Value__c).split(',')));
            mpAccount.put(acc.Id, acc);
        }
        for (SObject obj : mpNewRecord.values()) {
            if (stAlreadyProcessed.contains(obj.Id)) {
                mpNewRecordClone.remove(obj.Id);
                mpOldRecordClone.remove(obj.Id);
                continue;
            }

            if (sObjType != 'AddressDetail__c') {
                blnTypeValid = isObjectCorrectType(sObjType, obj);
            }
            if (!blnTypeValid || stExcRecordAcc.contains(String.valueOf(obj.get(strFieldId)))) {// Remove all the accounts that doesn't have platforms or the type is excluding
                mpNewRecordClone.remove(obj.Id);
                mpOldRecordClone.remove(obj.Id);
            }
        }
        return checkChanges(mpNewRecordClone, mpOldRecordClone, mpUserEmail, isInsert);
    }

    /**
     * @description  Check if the object that is being processed has the correct type of Address
     *
     * @param sObjType
     * @param obj
     *
     * @return Boolean
     */
    private static Boolean isObjectCorrectType(String sObjType, SObject obj) {
        if (sObjType == 'AddressDetail__c') {
            String strType = String.valueOf(obj.get('Type__c'));
            if (!mpAddressTypeById.containsKey(String.valueOf(obj.get('Account__c')))) {
                return false;
            }
            for (String strTypeBus : mpAddressTypeById.get(String.valueOf(obj.get('Account__c'))).split(',')) {
                if (strType.contains(strTypeBus)) {
                    return true;
                }
            }
            return false;
        } else if (sObjType == 'Contact') {
            if (!mpContactTypeById.containsKey(String.valueOf(obj.get('AccountId')))) {
                return false;
            }
            return mpContactTypeById.get(String.valueOf(obj.get('AccountId'))).contains(String.valueOf(obj.get('Contact_Role__c')));
        }
        return true;
    }

    /**
    * @author william Castillo
    * @date December 01, 2017
    * @description SP-1697, Send all the information when a record is inserting on Platform Object.
    * @param
    */
    public static List<Backend_Integration__e> ValidateRecordsPlatform(String sObjType, Map<Id, SObject> mpNewRecord) {
        Map<String, Map<String, Business_Config__c>> mapProcessData = moam.get('EventBus');
        Map<String, Account> mpAccountSent = new Map<String, Account>();

        Set<String> stAccTypeExclude = new Set<String>();
        Set<Id> stAcc = new Set<Id>();
        Map<String, String> mpUserEmail = new Map<String, String>();
        List<Backend_Integration__e> lstBackIntEvent = new List<Backend_Integration__e>();

        Set<String> stExcTypePlatforms = new Set<String>();
        Map<String, Set<String>> mpAccExpTypePlat = new Map<String, Set<String>>();
        Map<Id, SObject> mpNewParentAccounts = new Map<Id, SObject> ();

        Set<String> stAccTypeWithOutPlatform = new Set<String>();

        String strFieldId;

        if (sObjType == 'Account') {
            strFieldId = 'id';
        } else {
            strFieldId = 'Account__c';
        }

        for (SObject obj : mpNewRecord.values()) {
            if (!stAlreadyProcessed.contains(obj.Id)) {
                stAcc.add(String.valueOf(obj.get(strFieldId)));
                stAlreadyProcessed.add(obj.Id);
            }
        }
        //Initialise accounts that have to be updated and prepare them for further processing. Prepare maps of object types to exclude
        for (Account acc : retrieveAccountDetails(stAcc, false)) { // filter if the accounts related to the platform match with the the correct record type on the business config
            String strDevNamRecord = LibRecordTypeHelper.getRecordTypeValue(acc.RecordTypeId);
            if (mapProcessData == null || !mapProcessData.containsKey(strDevNamRecord)) {
                continue;
            }
            stAccTypeExclude.addAll(mapProcessData.get(strDevNamRecord).get('TypesException').Business_Rule_Value__c.split(','));

            if (mapProcessData.get(strDevNamRecord).containsKey('AccountTypeWithOutPlatform')) {
                stAccTypeWithOutPlatform.addAll(mapProcessData.get(strDevNamRecord).get('AccountTypeWithOutPlatform').Business_Rule_Value__c.split(','));
            }

            if (stAccTypeExclude.contains(acc.Type)) { // Accounts with the correct type
                continue;
            }
            mpAccountSent.put(acc.Id, acc);
            mpUserEmail.put(acc.OwnerId, acc.Owner.Email);
            mpJsonById.put(acc.Id, mapProcessData.get(strDevNamRecord).get('FieldsMap').Business_Rule_Value__c);
            mpAddressTypeById.put(acc.Id, mapProcessData.get(strDevNamRecord).get('AddressType').Business_Rule_Value__c);
            mpPlatformFieldsById.put(acc.Id, mapProcessData.get(strDevNamRecord).get('PlatformPerfomanceFields').Business_Rule_Value__c);
            if (mapProcessData.get(strDevNamRecord).containsKey('PlatformExceptions')) {
                stExcTypePlatforms.addAll(mapProcessData.get(strDevNamRecord).get('PlatformExceptions').Business_Rule_Value__c.split(','));
                mpAccExpTypePlat.put(acc.Id, stExcTypePlatforms);
            }
        }
        lstBackIntEvent = populateBackendEvents(mpNewParentAccounts, mpAccExpTypePlat, mpAccountSent, mpUserEmail, stAccTypeWithOutPlatform);

        if (mpNewParentAccounts.keySet().size() > 0) {
            EventBusHelper.numberOfExecutions++;
            if (EventBusHelper.numberOfExecutions < 5) {
                EventBusHelper.ValidateRecordsPlatform('Account', mpNewParentAccounts);
            }
        } else {
            if (mpAccountToUpdate.size() > 0) {
                blnExecute = false;
                update mpAccountToUpdate.values();
            }
        }
        return publishEvents(lstBackIntEvent);
    }

    /**
     * @description Create backend events from objects passed
     *
     * @param mpNewParentAccounts
     * @param mpAccExpTypePlat
     * @param mpAccountSent
     * @param mpUserEmail
     * @param stAccTypeWithOutPlatform
     *
     * @return List<Backend_Integration__e>
     */
    private static List<Backend_Integration__e> populateBackendEvents(Map<Id, SObject> mpNewParentAccounts, Map<String, Set<String>> mpAccExpTypePlat, Map<String, Account> mpAccountSent, Map<String, String> mpUserEmail, Set<String> stAccTypeWithOutPlatform) {
        Backend_Integration__e BackIntEvent = new Backend_Integration__e();
        List<FieldEventMapping> lstFldMap = new List<FieldEventMapping>();
        List<FieldEventMapping> lstFldMapPlat = new List<FieldEventMapping>();
        List<Backend_Integration__e> lstBackIntEvent = new List<Backend_Integration__e>();
        for (Account acc : mpAccountSent.values()) {
            List<Contact> lstContacts = acc.Contacts;
            List<Platform_Performance__c> lstPlatform = acc.Platforms_Performance__r;
            List<AddressDetail__c> lstAddress = acc.AddressDetails__r;
            List<AddressDetail__c> lstAddressFilter = new List<AddressDetail__c>();

            BackIntEvent.AccountId__c = acc.Id;
            BackIntEvent.Account_GRID__c = acc.GRID__c;
            BackIntEvent.Record_type__c = LibRecordTypeHelper.getRecordTypeValue(acc.RecordTypeId);
            BackIntEvent.Account_Country_Code__c = acc.Account_Country_Code__c;
            Boolean hasPlatformPerformance = false;

            String jsonField = mpJsonById.get(BackIntEvent.AccountId__c);
            if (jsonField != null && jsonField != '') {
                lstFldMap = (List<EventBusHelper.FieldEventMapping>) JSON.deserializeStrict(jsonField, List<EventBusHelper.FieldEventMapping>.class);
            }

            jsonField = mpPlatformFieldsById.get(BackIntEvent.AccountId__c);
            if (jsonField != null && jsonField != '') {
                lstFldMapPlat = (List<EventBusHelper.FieldEventMapping>) JSON.deserializeStrict(jsonField, List<EventBusHelper.FieldEventMapping>.class);
            }

            for (AddressDetail__c addTemp : lstAddress) { // filter the address records with the criteria from Business config.
                String strType = String.valueOf(addTemp.get('Type__c'));
                if (mpAddressTypeById.containsKey(String.valueOf(addTemp.get('Account__c')))) {
                    for (String strTypeBus : mpAddressTypeById.get(String.valueOf(addTemp.get('Account__c'))).split(',')) {
                        if (strType.contains(strTypeBus)) {
                            lstAddressFilter.add(addTemp);
                        }
                    }
                }
            }

            for (FieldEventMapping fldEvnMap : lstFldMap) {
                if (fldEvnMap.ObjectName == 'Account') {
                    if (fldEvnMap.ObjectField == 'Parent.GRID__c' || fldEvnMap.ObjectField == 'Parent.Type') {
                        if (acc.Parent != null) {
                            BackIntEvent.Account_Parent_GRID__c = acc.Parent.GRID__c;
                            BackIntEvent.Account_Parent_Type__c = acc.Parent.Type;
                        }
                    } else if (fldEvnMap.ObjectField == 'Shared_Menu__r.GRID__c') {
                        BackIntEvent.Shared_Menu_GRID__c = acc.Shared_Menu__r.GRID__c;
                    } else {
                        BackIntEvent.put(fldEvnMap.EventField, acc.get(fldEvnMap.ObjectField));
                        if (fldEvnMap.ObjectField == 'OwnerId') {
                            BackIntEvent.put(fldEvnMap.EventField, mpUserEmail.get((String) acc.get(fldEvnMap.ObjectField)));
                        }
                    }
                } else if (fldEvnMap.ObjectName == 'Contact') {
                    if (lstContacts != null && lstContacts.size() > 0) {
                        for (Contact c : lstContacts) {
                            Boolean isContactOwner = c.Contact_Role__c == 'Owner' && fldEvnMap.Type == null;
                            Boolean isContactBillingManager = c.Contact_Role__c == 'Billing Manager' && fldEvnMap.Type == 'Billing';
                            if (isContactOwner || isContactBillingManager) {
                                BackIntEvent.put(fldEvnMap.EventField, c.get(fldEvnMap.ObjectField));
                                break;
                            }
                        }
                    }
                } else if (fldEvnMap.ObjectName == 'Platform_Performance__c' && fldEvnMap.ObjectField == 'Id') {
                    String PPJson = getPlatformPerformanceJson(acc, lstPlatform, mpAccExpTypePlat, lstFldMapPlat);
                    if (PPJson != null) {
                        hasPlatformPerformance = Pattern.compile('("Backend_ID__c")\\s*:\\s*"(?!null)(?!NULL)\\w*\\d*"').matcher(PPJson).find();
                        BackIntEvent.put(fldEvnMap.EventField, PPJson);
                    } else {
                        BackIntEvent.put(fldEvnMap.EventField, '[]');
                    }
                } else if (fldEvnMap.ObjectName == 'AddressDetail__c') {
                    if (lstAddressFilter != null && !lstAddressFilter.isEmpty()) {
                        BackIntEvent.put(fldEvnMap.EventField, lstAddressFilter[0].get(fldEvnMap.ObjectField));
                    }
                }
            }
            if (lstAddress != null && !lstAddress.isEmpty()) {
                BackIntEvent.Addresses__c = JSON.serialize(lstAddress);
            }

            if (lstContacts != null && !lstContacts.isEmpty()) {
                BackIntEvent.Contacts__c =  JSON.serialize(lstContacts);
            }

            if (hasPlatformPerformance || acc.Published_on_eventBus__c) {
                BackIntEvent.Event_Type__c = 'Account';
                BackIntEvent.New__c = false;
            } else {
                BackIntEvent.New__c = true;
            }

            if (acc.ParentId != null && !acc.Parent.Published_on_eventBus__c) {
                mpNewParentAccounts.put(acc.ParentId, new Account (Id = acc.ParentId));
                mpAccountToUpdate.put(acc.ParentId, new Account (Id = acc.ParentId, Published_on_eventBus__c = true));
            }

            stAlreadyProcessed.add(acc.Id);
            if (BackIntEvent.Account_Platform__c != null || stAccTypeWithOutPlatform.contains(acc.Type)) {
                lstBackIntEvent.add(BackIntEvent);
            }
        }
        return lstBackIntEvent;
    }

    /**
     * @description get platform performance field values from config and convert them to Json array string
     *
     * @param acc
     * @param lstPlatform
     * @param mpAccExpTypePlat
     * @param lstFldMapPlat
     *
     * @return String
     */
    private static String getPlatformPerformanceJson(final Account acc, final List<Platform_Performance__c> lstPlatform, final Map<String, Set<String>> mpAccExpTypePlat, final List<FieldEventMapping> lstFldMapPlat) {
        if (lstPlatform == null || lstPlatform.isEmpty()) {
            return null;
        }

        Map<String, String> mpJsonFields = new Map<String, String>();
        List<Map<String, String>> lstJson = new List<Map<String, String>>();

        for (Platform_Performance__c plaPer : lstPlatform) {
            if (mpAccExpTypePlat.containsKey(acc.Id) && mpAccExpTypePlat.get(acc.Id).contains(plaPer.Platform__c)) {
                continue;
            }
            mpJsonFields = new Map<String, String>();
            for (FieldEventMapping fldEvnMapPlat : lstFldMapPlat) {
                mpJsonFields.put(fldEvnMapPlat.EventField, String.valueOf(plaPer.get(fldEvnMapPlat.ObjectField)));
            }
            lstJson.add(mpJsonFields);
        }
        return lstJson.isEmpty() ? null : JSON.serialize(lstJson);
    }

    /**
     * @description Get Address detail map for account from a fieldSet
     *
     * @param accountIds
     *
     * @return Map<Id, List<AddressDetail__c>>
     */
    private static Map<Id, List<AddressDetail__c>> getAccountAddressDetailMap(final Set<Id> accountIds) {
        List<FieldSetMember> addressFields = readFieldSet('EventBus', 'AddressDetail__c');
        final String baseQuery = 'SELECT {0} FROM AddressDetail__c WHERE Account__c IN :accountIds';
        String queryFields = '';
        for (FieldSetMember addressField : addressFields) {
            queryFields += addressField.getFieldPath() + ',';
        }

        List<AddressDetail__c> allAddressDetails = Database.query(String.format(baseQuery, new List<String>{
                queryFields.removeEnd(',')
        }));
        if (allAddressDetails == null || allAddressDetails.isEmpty()) {
            return new Map<Id, List<AddressDetail__c>>();
        }
        return ClsSObjectUtils.convertToIdMap(allAddressDetails, AddressDetail__c.Account__c.getDescribe().getLocalName());
    }
    /**
     * @description Get Contacts detail map for account from a fieldSet
     *
     * @param accountIds
     *
     * @return Map<Id, List<Contact>>
     */
    private static Map<Id, List<Contact>> getAccountContactsDetailMap(final Set<Id> accountIds) {
        List<FieldSetMember> contacsFields = readFieldSet('EventBus', 'Contact');
        set<String> stRoles = new set<String> {'Owner','Billing Manager','Restaurant Operations','Customer Contact'};
        final String baseQuery = 'SELECT {0} FROM Contact WHERE AccountId IN :accountIds and Contact_Role__c IN: stRoles ';
        String queryFields = '';
        for (FieldSetMember contactField : contacsFields) {
            queryFields += contactField.getFieldPath() + ',';
        }

        List<contact> allContactsDetails = Database.query(String.format(baseQuery, new List<String>{
                queryFields.removeEnd(',')
        }));
        if (allContactsDetails == null || allContactsDetails.isEmpty()) {
            return new Map<Id, List<Contact>>();
        }
        return ClsSObjectUtils.convertToIdMap(allContactsDetails, Contact.AccountId.getDescribe().getLocalName());
    }

    //Return type is temporary, until redesigned, for testing purposes.
    public static List<Backend_Integration__e> publishEvents(List<Backend_Integration__e> lstBackIntEvent) {

        if (lstBackIntEvent.isEmpty()) {
            return lstBackIntEvent;
        }
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(lstBackIntEvent);

        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
            } else {
                for (Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                            err.getStatusCode() +
                            ' - ' +
                            err.getMessage());
                    ClsLogErrorMessage.logMessages('SendToBackendEventBus', err.getStatusCode() + err.getMessage());
                }
            }
        }
        return lstBackIntEvent;
    }

    public static List<Account> queryAccountWithPlatforms(Set<Id> stAcc) {

        List<Account> lstAcc = new List<Account>();

        lstAcc = [
                SELECT Id,OwnerId, Owner.Email,Type,RecordTypeId,GRID__c, (SELECT Id FROM Platforms_Performance__r WHERE Backend_ID__c != NULL)
                FROM Account
                WHERE Id IN:stAcc
        ];
        return lstAcc;
    }

    public class FieldEventMapping {
        public String EventField;
        public String ObjectName;
        public String ObjectField;
        public String Type;
    }

    public class PlatformMessage {
        public String Id;
        public String Account;
        public String Platform;
        public String Status;
    }


    public static List<Account> retrieveAccountDetails(Set<Id> stAcc, Boolean withBackendID) {


        List<Schema.FieldSetMember> fields_Account = readFieldSet('EventBus', 'Account');
        List<Schema.FieldSetMember> fields_Contact = readFieldSet('EventBus', 'Contact');
        List<Schema.FieldSetMember> fields_Address = readFieldSet('EventBus', 'AddressDetail__c');
        List<Schema.FieldSetMember> fields_Platform = readFieldSet('EventBus', 'Platform_Performance__c');

        String queryString = 'SELECT Id, GRID__c,Parent.GRID__c,Parent.Type,Parent.Published_on_eventBus__c , OwnerId, Owner.Email,Type,RecordTypeId, Shared_Menu__r.GRID__c, Account_Country_Code__c ';

        if (fields_Account != null) {
            for (Schema.FieldSetMember fsm : fields_Account) {
                String filedName = fsm.getFieldPath();
                queryString += ', ' + filedName;

            }
        }

        queryString += ' ,(SELECT Id ';

        if (fields_Address != null) {
            for (Schema.FieldSetMember fsm : fields_Address) {
                String filedName = fsm.getFieldPath();
                queryString += ', ' + filedName;

            }
        }

        queryString += ' FROM AddressDetails__r )';

        queryString += ' ,(SELECT Id ';

        if (fields_Platform != null) {
            for (Schema.FieldSetMember fsm : fields_Platform) {
                String filedName = fsm.getFieldPath();
                queryString += ', ' + filedName;
            }
        }

        if (withBackendID) {
            queryString += ' FROM Platforms_Performance__r where Backend_ID__c  != null )';
        } else {
            queryString += ' FROM Platforms_Performance__r )';
        }

        queryString += ' ,(SELECT Id ';

        if (fields_Contact != null) {
            for (Schema.FieldSetMember fsm : fields_Contact) {
                String filedName = fsm.getFieldPath();
                queryString += ', ' + filedName;
            }
        }
        // TO DO : remove Contact_Role filter ????
        queryString += ' FROM Contacts where Contact_Role__c IN (\'Owner\',\'Billing Manager\',\'Restaurant Operations\',\'Customer Contact\' ))';
        queryString += ' FROM Account where id IN : stAcc';

        return Database.query(queryString);
    }

    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName) {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.fieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields();
    }

}