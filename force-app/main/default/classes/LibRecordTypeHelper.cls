/**
 * RecordType records helper class
 */
public with sharing class LibRecordTypeHelper {

	/**
	 * Given a Sobject returns the default record type per current suer
	 * @param  obj sObject
	 * @return     Default record type id or null
	 */
	public static Id getDefaultRecordTypeId(SObjectType obj) {
		
		Id res;
		for (Schema.RecordTypeInfo info : obj.getDescribe().getRecordTypeInfos()) {
			if (info.isDefaultRecordTypeMapping()) {
				res = info.getRecordTypeId();
			}
		}

		return res;
	}

	/**
	 * Retrieve record type id or developer name according to key
	 * @param  key Key could be either the record type id or record type dev name
	 * @return     Record type id if key is the developer name, developer name if
	 * the key is record type id
	 *
	 */
	public static String getRecordTypeValue(String key) {
		return RecordType__c.getValues(key).value__c;
	}

	/**
	 * Retrieves record type record by developer name and Object
	 * @param  devName Record type developer name
	 * @param  sObjectName     Object name
	 * @return                 RecordType record or null
	 */
	public static RecordType getRecordType(String devName, String sObjectName) {


		Map<Id, RecordType> res = new Map<Id, RecordType>(
		    [
		        SELECT Id
		        FROM RecordType
		        WHERE DeveloperName = :devName
		                              AND SobjectType = :sObjectName
		                                      LIMIT 1
		    ]
		);


		return res.isEmpty() ? null : res.values()[0];
	}

	/**
	 * Returns all record type related to specified Objects
	 * @param  sObjectNames Objects list
	 * @return             Map where key is record type developer name and value
	 * record type record
	 */
	public static Map<String, RecordType> getRecordTypeForObjects(Set<String> sObjectNames) {
		Map<String, RecordType> res =  new Map<String, RecordType>();


		for (RecordType r : getRecordTypesBysObjectName(sObjectNames)) {
			res.put(r.DeveloperName, r);
		}


		return res;
	}

	/**
	 * Retrieves record type related to specified Objects
	 * @param  sObjectNames Objects list
	 * @return             Map where key is record type id and value record type record
	 */
	public static Map<Id, RecordType> getRecordTypeForIds(Set<String> sObjectNames) {
		return new Map<Id, RecordType>(getRecordTypesBysObjectName(sObjectNames));
	}
	/**
    * @method name  : getRecordTypeDeveloperNameById
    * @description  : record type developer name by SObjectname and Id
    * @param  sObjectName [object name]
    * @param  recordTypeId [record type id]
    * @return string
    */
	public static string getRecordTypeDeveloperNameById(string sObjectName,string recordTypeId){
		return Schema.getGlobalDescribe().get(sObjectName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getDeveloperName();
	}

	private static List<RecordType> getRecordTypesBysObjectName(Set<String> sObjectNames) {
		return [Select Id, DeveloperName from RecordType where SobjectType in: sObjectNames];
	}  
     /**
     *
     * @description  [ Get record type Id  ]
     * @param sObjectName [ sObject name - eg: Account/Contact]
     * @param recordTypeName [RecordType developerName]
     *
     * @return [ RecordTypeId value]
     */
     public static Id getRecordTypeIdByDeveloperName(String sObjectName,String recordTypeName){
        return Schema.getGlobalDescribe().get(sObjectName).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
  }
}
