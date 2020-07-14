/**
 * Created by p.bansal on 02-Jan-20.
 * Description: Class contains logic of setting capacity through a custom LWC 
 */

public class CustomPresenceConfig_LWCController {
    public static List<PresenceUserConfigUser> userPresConfigList = new List<PresenceUserConfigUser>();
    public static List<Id> allRoleIds = new List<Id>();
    public static List<Id> allUserIds = new List<Id>();
    public static List<Id> allRoleAndSubIds = new List<Id>();
    public static Map<Id,String> agentsName = new Map<Id,String>();
    public static Map<String,String> apiConstVals = new Map<String,String>();
    public static String configNotFound = 'NotFound';
    public static String errorMesg = 'Error';
    public static Set<String> namesList = new Set<String>{'API_callOutEndPoint','API_ErrorMessage','API_GeneralErrorMsg','API_noRecsReceived','API_requestContentType','API_SendReErrorMsg','API_SuccessMsg','API_MethodPOST'};
	public static Map<Id, User> mapOfAgentsUserRecs = new Map<Id,User>();
	public static Map<Id, String> userBasedCap = new Map<Id, String>();
	public static Map<String, agentsAndCapacity> agentsConfigOldMap = new Map<String, agentsAndCapacity>();
	
    /*@desc: Method called from LWC to get list of all Presence Configuration
     */
    @AuraEnabled(cacheable = true)
    public static List<PresenceUserConfig> getPresenceConfig(){
        List<PresenceUserConfig> prConfList = new List<PresenceUserConfig>();
        FOR(PresenceUserConfig pu: [SELECT Id,MasterLabel, Capacity FROM PresenceUserConfig WHERE DeveloperName!='default_presence_config']){
            prConfList.add(pu);
        }
        return prConfList;
    }

    /*@desc: Method called from LWC to get the list of Chat Agents
     */
    @AuraEnabled(cacheable = true)
    public static String getOmniSuprvisrAgents(){
        
        Set<Id> configId = new Set<Id>();
        String superVisorAgentsConfigs;
        try{
            //First query Omni Supervisor Config User object to check the logged in user is added as a User record here
            FOR(OmniSupervisorConfigUser omniUsers : [SELECT Id,OmniSupervisorConfigId,UserId FROM OmniSupervisorConfigUser
            WHERE UserId =: UserInfo.getUserId()]){
                configId.add(omniUsers.OmniSupervisorConfigId);
            }
            //If there is no record in above query then check if the logged in user profile is added in any of the Omni Supervisor Config Profile
            if(configId.isEmpty()){
                FOR(OmniSupervisorConfigProfile omniProfiles : [SELECT Id,OmniSupervisorConfigId,ProfileId FROM OmniSupervisorConfigProfile
                WHERE ProfileId =: UserInfo.getProfileId()]) {
                    configId.add(omniProfiles.OmniSupervisorConfigId);
                }
            }
            IF(configId.isEmpty()){return   configNotFound;}
            List<Id> grpIds = new List<Id>();
            grpIds.addAll(getConfigsId(configId));
            //Prepare the list of agents id and role/subrole ids of the agents   
            Group_Utils.getGroupMembers(grpIds); 
            allRoleIds = Group_Utils.allRoleIds ;
            allUserIds = Group_Utils.allUserIds ;
            allRoleAndSubIds = Group_Utils.allRoleAndSubIds ;
			//Get the list of agents and capacities
            superVisorAgentsConfigs = getAllAgentsId(allUserIds,allRoleIds,allRoleAndSubIds); 
        }catch(Exception e){
            system.debug('error inn getOmniSuprvisrAgents'+e.getMessage());
        }       
        return !String.isEmpty(superVisorAgentsConfigs)?superVisorAgentsConfigs:configNotFound;
    }

    /*@desc: List of all capacity configurations added as public group in Supervisor Configuration
     *@param: List of user 
     */
    public static List<Id> getConfigsId(Set<Id> supervisorIds){
        List<Id> grpIds = new List<Id>();
        FOR(OmniSupervisorConfigGroup g: [SELECT GroupId,Id,OmniSupervisorConfigId FROM OmniSupervisorConfigGroup
        WHERE OmniSupervisorConfigId IN: supervisorIds]){
            grpIds.add(g.GroupId);
        }
        return grpIds;
    }

    /* @desc: Get List of all agents for a supervisor through role(s) or direct users added in the Supervisor Config
     * @param: takes list of agents Id(direct users added in the group), role(s), roles and subrole(s) added in the group
     */
    public static String getAllAgentsId(List<Id> pAllUserIds,List<Id> pAllRoleIds,List<Id> pAllRoleAndSubIds){

        String userPresConfigString  ;	
        List<Id> roleIdsList = new List<Id>();
        IF(!pAllRoleIds.isEmpty())   roleIdsList.addAll(pAllRoleIds);                  
        
        IF(!pAllRoleAndSubIds.isEmpty()){
                pAllRoleIds.addAll(pAllRoleAndSubIds);
                pAllRoleIds.addAll(Group_Utils.getAllSubRoleIds(new Set<Id>(pAllRoleAndSubIds)));
        }  
        IF(pAllUserIds.isEmpty() && pAllRoleIds.isEMpty()){return userPresConfigString;}
        userPresConfigString = agentsList(pAllUserIds, pAllRoleIds, getAgentsProfileId(pAllUserIds,pAllRoleIds));
        return  userPresConfigString;
    }  


    /* @desc: Get profile ids for the agents under supervisorconfig
     * @param: list of agents user id 
     */
    public static Set<Id> getAgentsProfileId(List<Id> pAgentsId,List<Id> pRolesId){
		//Added to fix the use case when ONLY there is role added in Public Group
        IF(pAgentsId.isEmpty() && pRolesId.isEmpty())    return new Set<Id>();
        Set<Id> profileIds = new Set<Id>();
        FOR(User u: [SELECT Id, Name, Username, ProfileId FROM User WHERE (Id IN:pAgentsId OR UserRoleId IN:pRolesId) AND IsActive=TRUE AND UserPermissionsLiveAgentUser =: TRUE]){
            profileIds.add(u.ProfileId);
            mapOfAgentsUserRecs.put(u.Id, u);
        }
        return profileIds;
    }
    

     /* @desc: List of all agents with their capacity, either via assignment at user level or via profile
      * @param: list of agents user id, list of all role ids, and list of user's profile id 
      */
    public static String agentsList(List<Id> pUserIds, List<Id> pRoleIds, Set<Id> pProfileIds){
         List<agentsAndCapacity> listOfAgents = new List<agentsAndCapacity>();	
        List<agentsAndCapacity> listOfAgentsFromProfileOrUserBasedConfig = new List<agentsAndCapacity>();
		//Capacities as agents added as direct users
        listOfAgentsFromProfileOrUserBasedConfig = getAgentsCapThroughUser(pUserIds,pRoleIds);
        IF(!listOfAgentsFromProfileOrUserBasedConfig.isEmpty()){ listOfAgents.addAll(listOfAgentsFromProfileOrUserBasedConfig)  ;}
		
		//Capacities as agents added as their profiles
        listOfAgentsFromProfileOrUserBasedConfig = getAgentsCapThroughProfiles(pProfileIds);
        IF(!listOfAgentsFromProfileOrUserBasedConfig.isEmpty()){ listOfAgents.addAll(listOfAgentsFromProfileOrUserBasedConfig)  ;}

        return !listOfAgents.isEmpty()?JSON.serialize(listOfAgents):'';
    }

     /* @desc: Get the capacity of the agents if they are added as user record in PresenceUserConfigUser
      * @param: list of agents user id, list of all role ids
      */
    public static List<agentsAndCapacity> getAgentsCapThroughUser(List<Id> pUserIds, List<Id> pRoleIds){

        Set<PresenceUserConfigUser> pConfigSet = new Set<PresenceUserConfigUser>();       
        List<PresenceUserConfigUser> pConfigList = new List<PresenceUserConfigUser>();
        Set<Id> pConfigIdSet = new Set<Id>();
        List<agentsAndCapacity> listOfAgents = new List<agentsAndCapacity>();

        FOR(PresenceUserConfigUser pc : [SELECT Id, UserId, User.Name , User.Username, PresenceUserConfigId,
                                         PresenceUserConfig.Capacity,PresenceUserConfig.MasterLabel
                                         FROM PresenceUserConfigUser
                                         WHERE (UserId IN: pUserIds 
                                               OR User.UserRoleId IN: pRoleIds) AND User.IsActive=: TRUE
                                         ]){
            String name = pc.User.Name;
            String capacity = pc.PresenceUserConfig.MasterLabel;
            pConfigList.add(pc);
            pConfigIdSet.add(pc.PresenceUserConfigId); 
            userBasedCap.put(pc.UserId,capacity);         
			agentsAndCapacity obj =  new agentsAndCapacity();
            obj.agentPresenceConfigId = pc.Id;
            obj.agentCapacity = pc.PresenceUserConfig.MasterLabel;
            obj.agentName = pc.User.Name;
            obj.agentUsername = pc.User.Username; 
            obj.userId = pc.UserId;
            obj.presenceConfigId = pc.PresenceUserConfigId ;
            obj.isCapSetAtUser = TRUE;
            listOfAgents.add(obj);
        }
        return listOfAgents ;
    }    
    
    /* @desc: Get the capacity of the agents if their profiles are added as record in PresenceUserConfigProfile
     * @param: list of agents' profile ids
     */
    public static List<agentsAndCapacity> getAgentsCapThroughProfiles(Set<Id> pProfileIds){
        IF(pProfileIds.isEmpty()){   return null;}
        
        //Map to get capacity for a profile and PresenceUserConfig Id for a profile.        
        Map<Id, String> profileBasedCap = new Map<Id, String>();
        Map<Id, Id> profileBasedConfig = new Map<Id, Id>();
        // Get capacity for all the profiles
        FOR(PresenceUserConfigProfile pc : [SELECT Id,ProfileId, PresenceUserConfigId,PresenceUserConfig.Capacity,PresenceUserConfig.MasterLabel
                                            FROM PresenceUserConfigProfile
                                            WHERE ProfileId IN:pProfileIds
                                         ]){            
            String capacity = pc.PresenceUserConfig.MasterLabel;   
            //The reason to put it in separate map is that related fields like PresenceUserConfig.Capacity cannot be maintained in collection like Map<Id,PresenceUserConfig>          
            profileBasedCap.put(pc.ProfileId,capacity);
            profileBasedConfig.put(pc.ProfileId,pc.PresenceUserConfigId);
       }
        List<agentsAndCapacity> listOfAgents = new List<agentsAndCapacity>();
    
        // Iterate over the capacity assigned to profiles b=
        FOR(Id recId:mapOfAgentsUserRecs.keySet()){
            //If the agent is already added as user based capacity then no need to check the prcapacity from profile 
            IF(!userBasedCap.isEmpty() && userBasedCap.containsKey(recId)){  continue;}
              IF(!profileBasedCap.isEmpty() && mapOfAgentsUserRecs.get(recId).ProfileId != null && 
               profileBasedCap.containsKey(mapOfAgentsUserRecs.get(recId).ProfileId) &&
              !profileBasedConfig.isEmpty() && profileBasedConfig.containsKey(mapOfAgentsUserRecs.get(recId).ProfileId)){
                agentsAndCapacity obj =  new agentsAndCapacity();                
                obj.agentCapacity = profileBasedCap.get(mapOfAgentsUserRecs.get(recId).ProfileId);
                obj.agentPresenceConfigId = recId;
                obj.agentName = mapOfAgentsUserRecs.get(recId).Name;
                obj.agentUsername = mapOfAgentsUserRecs.get(recId).Username ;
                obj.userId = recId;
                obj.presenceConfigId = profileBasedConfig.get(mapOfAgentsUserRecs.get(recId).ProfileId);
                obj.isCapSetAtUser = FALSE;
                listOfAgents.add(obj);
            }            
        }
      return listOfAgents ;
    }    
    //Wrapper for display list on LWC
    public class agentsAndCapacity{
        public String agentName ;
        public String agentUsername ;
		public String userId ;
        public String agentPresenceConfigId ;       
        public String presenceConfigId ;
        public String agentCapacity ;
        
        public Boolean isCapSetAtUser ;
        public Boolean dmlSuc = false;
    }


    /* @desc: Before changing the capacity for agent, the existing record needs to be removed. 
     *        This method will delete all existing configurations for agenst
     * @param: the selected PresenceUserConfig id selected by supervisor, list of old user config ids,map of presenceuserconfiguser id and record
     */
     @AuraEnabled
     public static String removeAgentsOldCapacity(List<Id> oldPresConfigIds, 
                                                  Map<String, Object> pAgentsConfigOldMap){
        
        IF(oldPresConfigIds.isEmpty()){   return '';}
		String resultCode ;
        String resultJSON ;
		String resultStr = '';
		apiConstVals = CustomMetadataSelector.getAPIConstanst(namesList) ;
        IF(!pAgentsConfigOldMap.isEmpty()){
            FOR(String s: pAgentsConfigOldMap.keyset()){           
            String str = JSON.serialize(pAgentsConfigOldMap.get(s));
            agentsAndCapacity mc = (agentsAndCapacity)JSON.deserialize(str,agentsAndCapacity.class);
            agentsConfigOldMap.put(s,mc);                
            }
        }  

        IF(!oldPresConfigIds.isEmpty() && !apiConstVals.isEmpty() && apiConstVals.containsKey('API_callOutEndPoint')){
            resultStr = API_SalesforceInternal_Utils.callDeleteRecords(oldPresConfigIds, apiConstVals.get('API_callOutEndPoint'));
        }
        IF(!String.isEmpty(resultStr)){            
            resultCode = resultStr.substringBefore('--');
            switch on resultCode {
                when '200' {
                    resultJSON = resultStr.substringAfter('--');
                }
                when else {
                    resultStr =  resultStr.substringAfter('--');
                }
            }
        }
        //If the agents selected are not added as direct users and are coming from Profiles then no delete happened, hence only create will be called
        IF(!String.isEmpty(resultStr) && oldPresConfigIds.isEmpty() && apiConstVals.isEmpty() && apiConstVals.containsKey('API_noRecsReceived')){    return apiConstVals.get('API_noRecsReceived');}
       
        IF(!String.isEmpty(resultCode) && resultCode == '200' && !apiConstVals.isEmpty() && apiConstVals.containsKey('API_SuccessMsg')){            
            return apiConstVals.get('API_SuccessMsg');}
      
        ELSE IF(!String.isEmpty(resultCode) && resultCode != '200' && !apiConstVals.isEmpty() && apiConstVals.containsKey('API_ErrorMessage')){     
            return apiConstVals.get('API_ErrorMessage');}
        
        return errorMesg;
    }

    @AuraEnabled(cacheable = true)
    public static String getAgentsUpdatedCapacity(String newPresConfig,String newCapacity, List<Id> agentsId, 
                                                  Map<String, Object> pAgentsConfigOldMap){       
		Set<Id> setOfagentsId = new Set<Id>(agentsId);
        IF(setOfagentsId.isEmpty() || String.isEmpty(newPresConfig)){   return '';}
		
		apiConstVals = CustomMetadataSelector.getAPIConstanst(namesList) ;
       
        List<Sobject> res = new List<Sobject>();
        List<agentsAndCapacity> recsToBeUpdated = new List<agentsAndCapacity>();
		List<PresenceUserConfigUser> pu = new List<PresenceUserConfigUser>();
		List<Sobject> sobjList = new List<Sobject>();
		String resultStr = '';
		List<agentsAndCapacity> allList = new List<agentsAndCapacity>();
        Boolean hasError = false;

        IF(!pAgentsConfigOldMap.isEmpty()){
            FOR(String s: pAgentsConfigOldMap.keyset()){           
                String str = JSON.serialize(pAgentsConfigOldMap.get(s));
                agentsAndCapacity mc = (agentsAndCapacity)JSON.deserialize(str,agentsAndCapacity.class);
                agentsConfigOldMap.put(mc.userId,mc);     
                recsToBeUpdated.add(mc);         
            }
        }
		
        FOR(agentsAndCapacity rec: recsToBeUpdated){
            system.debug(setOfagentsId.contains(rec.UserId)+'..what is rec.userid..'+rec.UserId);
            IF(setOfagentsId.contains(rec.UserId)){
                PresenceUserConfigUser p = new PresenceUserConfigUser();
                p.PresenceUserConfigId = newPresConfig;
                p.UserId = rec.UserId;
                pu.add(p);
            }
        }
        sobjList.addAll(pu);

        IF(!apiConstVals.isEmpty() && apiConstVals.containsKey('API_callOutEndPoint') && apiConstVals.containsKey('API_MethodPOST') && apiConstVals.containsKey('API_requestContentType')){
             resultStr = API_SalesforceInternal_Utils.callCreateRecords(sobjList, FALSE,apiConstVals.get('API_callOutEndPoint'),apiConstVals.get('API_requestContentType'),apiConstVals.get('API_MethodPOST'));
        }
       
        String resultCode ;
        String resultJSON ;
        List<Database.SaveResult> saveRes = new List<Database.SaveResult>();
        IF(!String.isEmpty(resultStr)){
            resultCode = resultStr.substringBefore('--');
            switch on resultCode {
                when '200' {
                    resultJSON = resultStr.substringAfter('--');
                    saveRes = (List<Database.SaveResult>)System.JSON.deserialize(resultJSON, List<Database.SaveResult>.class);
                 }
                when else {
                    resultStr =  resultStr.substringAfter('--');
                }
            } 

        }
	    IF(!saveRes.isEmpty()){            
            LoggingUtility.createLog('CustomPresenceConfig_LWCController','AGENT CAPACITY','CREATE PRESENCE CONFIG',null);
            Integer counter = 0;
            
            FOR(Database.SaveResult obj: saveRes){               
                IF(!obj.isSuccess()){       
                    String errMessage ;
                    for (Database.Error err : obj.getErrors()){
                         System.debug('Error: '+ err.getStatusCode() + ' ' + err.getMessage());
                         errMessage += err.getMessage() ;
                    }
                    hasError = TRUE;
                    LoggingUtility.logError('CustomPresenceConfig_LWCController','getAgentsUpdatedCapacity: Create failed for' + recsToBeUpdated[counter].UserId +' with Errors: '+errMessage);
                }
                ELSE{            
                    recsToBeUpdated[counter].agentPresenceConfigId = obj.getId() ;
                    recsToBeUpdated[counter].presenceConfigId = newPresConfig ;
                    recsToBeUpdated[counter].isCapSetAtUser = TRUE ;
                    recsToBeUpdated[counter].agentCapacity = newCapacity;        
                    recsToBeUpdated[counter].dmlSuc = true ;                   
                }
                allList.add(recsToBeUpdated[counter]);
                counter++ ;              
            }           
        }
        IF(hasError){
           LoggingUtility.commitLogs();
        }  
       
        IF(!String.isEmpty(resultCode) && resultCode == '200' && !allList.isEmpty() && !apiConstVals.isEmpty() && 		apiConstVals.containsKey('API_SuccessMsg')){
            return (apiConstVals.get('API_SuccessMsg')+'--'+JSON.serialize(allList));
        } 
        ELSE IF(!String.isEmpty(resultCode) && resultCode != '200' && !apiConstVals.isEmpty() && apiConstVals.containsKey('API_ErrorMessage')) {       
            return apiConstVals.get('API_ErrorMessage');
        }
        
        return errorMesg;
    }
}