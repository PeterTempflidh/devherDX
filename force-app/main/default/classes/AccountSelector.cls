public inherited sharing class AccountSelector {

    public static Account getAccountDetailsforId(Id accountId) {
        return [SELECT Id, Name, Account_Email__c, RecordTypeId, RecordType.DeveloperName, Record_Country__c, Account_Status__c,Mark_up_Value__c,Mark_up__c,Vertical__c
                FROM Account
                WHERE Id =: accountId
                LIMIT 1];
    }

    public static Account getAccountByName(String name) {
        return [SELECT Id, GRID__c, Phone, Name, RecordTypeId, Record_Country__c
                FROM Account
                WHERE Name =: name
                LIMIT 1];
    }

    public static Account getByCountry(String countryName) {
        List<Account> accList = new List<Account>([SELECT RecordTypeId FROM Account WHERE Record_Country__c = :countryName LIMIT 1]);
        return !accList.isEmpty() ? accList[0] : new Account();
    }

    /**
	 * Retrieves Account related to specified country and RecordTypeId
	 * @param  country name
	 * @return recordTypeId
	 */
    public static Account getByPlatformAndRecordType(String recordType,String countryName) {
        List<Account> accList = new List<Account>([SELECT Id from Account where RecordTypeId =:recordType AND Record_Country__c =:countryName Limit 1]);
        return !accList.isEmpty() ? accList[0] : new Account();
    }

    /**
	 * Retrieves record type related to specified country and Account
	 * @param  country name
	 * @return reordTypeId
	 */
    public static String getAccountRecordTypeByCountry(String countryName) {
        Account acc = AccountSelector.getByCountry(countryName);
        return null != acc && String.isNotBlank(acc.RecordTypeId) ? String.valueOf(acc.RecordTypeId) : '';

    }
    
    /**
     * @description get accounts by their ids
     *
     * @param accountIds
     *
     * @return
     */
    public static List<Account> getByIds(Set<Id> accountIds) {
        List<Account> accounts = new List<Account>();
        try {
            accounts = [SELECT
                    Id, Parent.GRID__c, Parent.Type, Shared_Menu__c, Shared_Menu__r.GRID__c, Record_Country__c, Vertical__c,
                    (SELECT Id, Name FROM Contacts WHERE Contact_Role__c = 'Owner')
                FROM Account
                WHERE Id IN :accountIds];
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }
        return accounts;
    }

    @TestVisible
    private static List<Account> getAll() {
        List<Account> accounts = new List<Account>();
        try {
            accounts = [SELECT
                    Id, Parent.GRID__c, Parent.Type, Shared_Menu__c, Shared_Menu__r.GRID__c, Record_Country__c
            FROM Account];
          } catch (QueryException e) {
            System.debug(e.getMessage());
        }
        return accounts;
    }

    /**
     * @description get accounts with active platform by account Ids, opportunity Ids and opportunity business type.
     *
     * @param accountIds
     * @param opportunityIds
     * @param businessType
     *
     * @return
     */
    public static List<Account> getByIdsOpportunityIdsBusinessType(final Set<Id> accountIds, final Set<Id> opportunityIds, final String businessType) {
        List<Account> accounts = new List<Account>();
        try {
            accounts = [SELECT Id, Type, (SELECT Account__c FROM Platforms_Performance__r WHERE Account__c IN :accountIds AND Backend_ID__c != NULL)
                    FROM Account WHERE Id IN :accountIds AND Id IN
                        (SELECT AccountId FROM Opportunity WHERE Id IN :opportunityIds AND Business_Type__c = :businessType)];
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }
        return accounts;
    }

    
    /*******************************************************************************************************
    * @description (SSC-2547)Account Map Queried based on Account Id set to update status
    * @param accIdsSet
    * @return Map<Id,Account> holds Id and Account record
    */
    public static Map<Id,Account> getAccountMapFromAccIdSet(Set<Id> accIdsSet) {
    	Map<Id,Account> accMap = new Map<Id,Account>();
        try {
             accMap = new Map<Id,Account>([SELECT Id,Account_Status__c
                                            FROM Account 
                                            WHERE Id IN :accIdsSet ]);
         }catch (QueryException e) {
            Loggingutility.createLog('AccountSelector','getAccountMapFromAccIdSet','','');
            LoggingUtility.log('AccountSelector',e.getMessage());
            LoggingUtility.commitLogs();

         }
         return accMap;
     }


    /**
    *
    * @description -  get all accounts along with child accounts
    * @param accountIdSet - Set of ids of Accounts
    * @return - List of Accounts
    */
    public static List<Account> selectByIdWithChildAccounts(Set<Id> accountIdSet) {
        String queryStr = ' SELECT Id,Key_VIP_Account__c,Name,Parent.Key_VIP_Account__c,ParentId,Is_Apex__c,(SELECT Id,Key_VIP_Account__c,ParentId,Is_Apex__c FROM ChildAccounts) FROM ACCOUNT WHERE Id IN:accountIdSet ';
        return (List<Account>) Database.query(queryStr);
    }

}