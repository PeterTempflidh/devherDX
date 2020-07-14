/**
 * Created by w.novoa on 27.06.2018.
 */

public with sharing class ClsPlatformPerformanceHandler {
    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;

    /**
    * Update The account with the status Online of the branchs goes Online
    * @param
    *   newPltMap: Trigger.newMap
    *   oldPltMap:  Trigger.oldMap
    * @return void
    *
    */
    public static void UpdateParentOnlineStatus(Map<id,Platform_Performance__c> newPltMap, Map<id,Platform_Performance__c> oldPltMap) {
        Map<id,Platform_Performance__c> mpFetch = new Map<id,Platform_Performance__c>();
        map<id,Account> mpAccUpdate = new map<id,Account>();
        set<String> stTypes = new set<String>();
        Map<String, Map<String, Business_Config__c>> mapProcessData = moam.get('UpdateAccountStatusParent');


        if (mapProcessData == null || mapProcessData.isEmpty()) {
            return;
        }


        // fetch the platforms that change or get the first Backend id
        for(Platform_Performance__c pltPerTemp :newPltMap.Values()){
            if(oldPltMap == null || newPltMap.get(pltPerTemp.id).Backend_ID__c != oldPltMap.get(pltPerTemp.id).Backend_ID__c ){
                mpFetch.put(pltPerTemp.id,pltPerTemp);
            }
        }

        for(Platform_Performance__c pltPerTemp : [select id,Account__c,Account__r.RecordType.DeveloperName,
                                                            Account__r.ParentId, Account__r.Parent.Type, Account__r.Parent.Account_Status__c,
                                                            Account__r.Parent.ParentId, Account__r.Parent.Parent.Type, Account__r.Parent.Parent.Account_Status__c,
                                                            Account__r.Parent.Parent.ParentId, Account__r.Parent.Parent.Parent.Type, Account__r.Parent.Parent.Parent.Account_Status__c,
                                                            Account__r.Parent.Parent.Parent.ParentId, Account__r.Parent.Parent.Parent.Parent.Type, Account__r.Parent.Parent.Parent.Parent.Account_Status__c
                                                  from Platform_Performance__c
                                                    where id in : mpFetch.keySet()
        ]){
            Map<String, Business_Config__c> mapBusinessData = mapProcessData.get(pltPerTemp.Account__r.RecordType.DeveloperName);
            if(mapBusinessData == null || mapBusinessData.isEmpty()){
                continue;
            }
            stTypes.addAll(mapBusinessData.get('ParentTypes').Business_Rule_Value__C.split(','));
            if(String.IsBlank(pltPerTemp.Account__r.ParentId)  ){
                Continue;
            }
            if(stTypes.contains(pltPerTemp.Account__r.Parent.Type) &&  (pltPerTemp.Account__r.Parent.Account_Status__c != 'Online')){
                mpAccUpdate.put(pltPerTemp.Account__r.ParentId,new account(id=pltPerTemp.Account__r.ParentId, Account_Status__c= 'Online'));
            }

            if(String.IsBlank(pltPerTemp.Account__r.Parent.ParentId)){
                Continue;
            }
            if(stTypes.contains(pltPerTemp.Account__r.Parent.Parent.Type) &&  (pltPerTemp.Account__r.Parent.Parent.Account_Status__c != 'Online')){
                mpAccUpdate.put(pltPerTemp.Account__r.Parent.ParentId,new account(id=pltPerTemp.Account__r.Parent.ParentId, Account_Status__c= 'Online'));
            }

            if(String.IsBlank(pltPerTemp.Account__r.Parent.Parent.ParentId)){
                Continue;
            }
            if(stTypes.contains(pltPerTemp.Account__r.Parent.Parent.Parent.Type) &&  (pltPerTemp.Account__r.Parent.Parent.Parent.Account_Status__c != 'Online')){
                mpAccUpdate.put(pltPerTemp.Account__r.Parent.Parent.ParentId,new account(id=pltPerTemp.Account__r.Parent.Parent.ParentId, Account_Status__c= 'Online'));
            }

            if(String.IsBlank(pltPerTemp.Account__r.Parent.Parent.Parent.ParentId)){
                Continue;
            }
            if(stTypes.contains(pltPerTemp.Account__r.Parent.Parent.Parent.Parent.Type) &&  (pltPerTemp.Account__r.Parent.Parent.Parent.Parent.Account_Status__c != 'Online')){
                mpAccUpdate.put(pltPerTemp.Account__r.Parent.Parent.Parent.ParentId,new account(id=pltPerTemp.Account__r.Parent.Parent.Parent.ParentId, Account_Status__c= 'Online'));
            }
        }

        update mpAccUpdate.values();

    }

}