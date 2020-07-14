/**
 * Created by p.bansal on 02-Jan-20.
 * Description: Class contains logic of setting capacity through a custom LWC 
 */
@IsTest
public class CustomPresenceConfig_LWCControllerTest {
    /* Group Configuration for testing that will be assigned to SUpervisor Config */
    private static Group testGroup ;
    private static Group testSubGroup ;
    private static Userrole parentRole ;
    private static Userrole childRole ;
    /* Create all needed Users, admin user to set up Omni channel object, Supervisor User, Agent User added as direct member of group, or agent coming as part of Role or RoleAndSubordinates in Omni Config for Supervisor */
    private static User adminUser = UnitTestDataFactory.createUser('System Administrator', 'testadminuser@deliveryhero.com', 'Germany', '');
    private static User testSupervisorUser = UnitTestDataFactory.createUser('Talabat Customer Care Management', 'testsupervisoruser@deliveryhero.com', 'Talabat', 'UY');    
    private static User agentUser = UnitTestDataFactory.createUser('Talabat Customer Care', 'testagentuser@deliveryhero.com', 'Germany', '');
    

    @TestSetup
    static void TestSetup(){
        parentRole = new UserRole(Name='Test Parent Role');
        insert parentRole;
        childRole = new UserRole(Name='Test Child Role',parentRoleId=parentRole.Id);
        insert childRole;

        List<User> userlst = new List<User>();
        User agentUserWithParentRole = UnitTestDataFactory.createUserWithRole('Talabat Customer Care', 'testAgentUserWithParentRole@deliveryhero.com', 'Germany', '',parentRole.Id);
        User agentUserWithChildRole = UnitTestDataFactory.createUserWithRole('Talabat Customer Care', 'testAgentUserWithChildRole@deliveryhero.com', 'Germany', '',childRole.Id);
        userlst.add(testSupervisorUser);
        userlst.add(adminUser);    
        userlst.add(agentUser);
        userlst.add(agentUserWithParentRole);    
        userlst.add(agentUserWithChildRole);
        insert userlst;

        testGroup = new Group(Name='Talabt Test Group',DeveloperName='Talabt_Test_Group',Type='Regular');
        testSubGroup = new Group(Name='Talabt Test SubGroup',DeveloperName='Talabt_Test_SubGroup',Type='Regular');        
        insert new List<Group>{testGroup,testSubGroup};

        GroupMember directUser = new GroupMember(UserOrGroupId=agentUser.Id,GroupId=testGroup.Id);
        GroupMember subGroupUser = new GroupMember(UserOrGroupId=testSubGroup.Id,GroupId=testGroup.Id);
        Map<String,Id> groupNameRoleIdMap = new Map<String,Id>();
        for(Group gp: [SELECT Id, Name FROM Group WHERE Type =: 'Role' LIMIT 1]){
            groupNameRoleIdMap.put('parentRoleMember', gp.Id);
        }   
        for(Group gp: [SELECT Id, Name FROM Group WHERE Type =: 'RoleAndSubordinates' LIMIT 1]){
            groupNameRoleIdMap.put('childRoleMember', gp.Id);
        }  
        system.assert(TRUE,(groupNameRoleIdMap.get('parentRoleMember') != NULL && groupNameRoleIdMap.get('childRoleMember')!=NULL));
        GroupMember roleMemberUser = new GroupMember(UserOrGroupId=groupNameRoleIdMap.get('parentRoleMember'),GroupId=testGroup.Id);
        GroupMember subRoleMemberUser = new GroupMember(UserOrGroupId=groupNameRoleIdMap.get('childRoleMember'),GroupId=testGroup.Id);
        List<GroupMember> grpMembers = new List<GroupMember>{directUser,subGroupUser ,roleMemberUser,subRoleMemberUser};
        insert grpMembers;
    } 
  
    @IsTest(seeAllData=false)
    static void testMethodGetOmniSUperVisprConfigUser(){
        //Omni Config Objects and create request response Strings
        OmniSupervisorConfig omniConfig ;
        OmniSupervisorConfigUser userConfig ;
        String pOmniSuperVisorConfig;
        String pOmniSuperVisorConfigResp;
        String pOmniSuperVisorConfigUser;
        String pOmniSuperVisorConfigUserResp;
        String pOmniSuperVisorConfigAgentUser;
        String pOmniSuperVisorConfigAgentUserResp;
        List<Database.SaveResult> pOmniSuperVisorConfigSaveRes  = new List<Database.SaveResult>();
  
        Test.setMock(HttpCalloutMock.class, new API_SalesforceInternalCalloutMockClass());
        Test.startTest();
        //Get API call related Configuration from metadata
        Map<String,String> custMetData = CustomMetadataSelector.getAPIConstanst(CustomPresenceConfig_LWCController.namesList); 
        
        //Create OmniSupervisorConfig
        omniConfig = new  OmniSupervisorConfig(developername ='testConfig',MasterLabel='testConfig' );
        pOmniSuperVisorConfig =   JSON.serialize(omniConfig) ;
        API_SalesforceInternalCalloutMockClass.respString = '[{"id":"0Q29E000000003ASAQ","success":true,"errors":[]}]';     
        API_SalesforceInternalCalloutMockClass.respStatusCode = 200;    
        pOmniSuperVisorConfigResp = API_SalesforceInternal_Service.createRecords(custMetData.get('API_callOutEndPoint'),pOmniSuperVisorConfig,custMetData.get('API_requestContentType'),custMetData.get('API_MethodPOST'));
        system.assert(true,pOmniSuperVisorConfigResp!=null);
        system.assert(true,pOmniSuperVisorConfigResp.contains('--'));
        pOmniSuperVisorConfigSaveRes = (List<Database.SaveResult>)System.JSON.deserialize(pOmniSuperVisorConfigResp.substringAfter('--'), List<Database.SaveResult>.class);
        system.assert(true,pOmniSuperVisorConfigSaveRes);

        //Add user as supervisor to OmniConfig
        //API_SalesforceInternalCalloutMockClass.respString = '[{"id":"0Q41r0000004CAS007","success":true,"errors":[]},{"id":"0Q41r0000004CAS008","success":true,"errors":[]},{"id":"0Q41r0000004CAS009","success":true,"errors":[]}]';
        API_SalesforceInternalCalloutMockClass.respString = '[{"id":"0Q41r0000004CAS007","success":true,"errors":[]}]';
        API_SalesforceInternalCalloutMockClass.respStatusCode = 200; 
        User supVsrUser = [Select id from User where username='testsupervisoruser@deliveryhero.com' Limit 1];
        system.assert(true, supVsrUser!=null); 
        userConfig = new OmniSupervisorConfigUser(OmniSupervisorConfigId = pOmniSuperVisorConfigSaveRes[0].id, UserId =supVsrUser.Id );
        pOmniSuperVisorConfigUser =  JSON.serialize(userConfig) ;  
        pOmniSuperVisorConfigUserResp = API_SalesforceInternal_Service.createRecords(custMetData.get('API_callOutEndPoint'),pOmniSuperVisorConfigUser,custMetData.get('API_requestContentType'),custMetData.get('API_MethodPOST'));
        system.assert(true,pOmniSuperVisorConfigUserResp!=null);
        system.assert(true,pOmniSuperVisorConfigUserResp.contains('--'));
        system.debug('pOmniSuperVisorConfigUserResp$$'+pOmniSuperVisorConfigUserResp);
        pOmniSuperVisorConfigSaveRes = (List<Database.SaveResult>)System.JSON.deserialize(pOmniSuperVisorConfigUserResp.substringAfter('--'), List<Database.SaveResult>.class);
        FOR(Database.SaveResult rec:pOmniSuperVisorConfigSaveRes){
            system.debug('rec$$'+rec);
        }
        system.assert(true,pOmniSuperVisorConfigSaveRes);
        system.assertEquals(API_SalesforceInternalCalloutMockClass.respString,pOmniSuperVisorConfigUserResp.substringAfter('--'));       
        system.debug('&&&&..'+[Select id,OmniSupervisorConfigId from OmniSupervisorConfigUser Where Id=:pOmniSuperVisorConfigSaveRes[0].Id]);
        //Add agent group into Omni Config
        API_SalesforceInternalCalloutMockClass.respString = '[{"id":"0QE9E000000007z007","success":true,"errors":[]}]';
        API_SalesforceInternalCalloutMockClass.respStatusCode = 200;          
        Group agentGroup = [Select Id FROM Group WHERE DeveloperName=:'Talabt_Test_Group'];
        system.assert(TRUE,agentGroup!=NULL);
        OmniSupervisorConfigGroup agentsUnderSupervisor = new OmniSupervisorConfigGroup(OmniSupervisorConfigId=pOmniSuperVisorConfigSaveRes[0].id,GroupId=agentGroup.Id);
        pOmniSuperVisorConfigAgentUser = JSON.serialize(agentsUnderSupervisor) ;
        pOmniSuperVisorConfigAgentUserResp = API_SalesforceInternal_Service.createRecords(custMetData.get('API_callOutEndPoint'),pOmniSuperVisorConfigAgentUser,custMetData.get('API_requestContentType'),custMetData.get('API_MethodPOST'));
        system.assert(true,pOmniSuperVisorConfigUserResp!=null);
        system.assert(true,pOmniSuperVisorConfigUserResp.contains('--'));
        system.assertEquals(API_SalesforceInternalCalloutMockClass.respString,pOmniSuperVisorConfigAgentUserResp.substringAfter('--'));  
        system.runAs(supVsrUser){
            system.debug('UserInfo.getUserId()...'+UserInfo.getUserId());
            CustomPresenceConfig_LWCController.getPresenceConfig();
            CustomPresenceConfig_LWCController.getOmniSuprvisrAgents();
        }  

    }

    @IsTest
    static void testMethodUpdateCapacityWithAgentsAsUsers(){
        
        //Request and response string
        String pConfigStrResp ;
        String pConfigUserStrResp;        
        List<Database.SaveResult> saveResList  = new List<Database.SaveResult>();
        List<String> userNames = new List<String>{'testagentuser@deliveryhero.com','testAgentUserWithParentRole@deliveryhero.com','testAgentUserWithChildRole@deliveryhero.com'};
        List<User> usrList = new List<User>();
        List<PresenceUserConfigUser> agentCapConfigList = new List<PresenceUserConfigUser>();
        List<Id> userIds = new List<Id>();
        List<Id> agentsPreConfigIds = new List<Id>();
        Map<String, Object> pAgentsConfigMap = new Map<String, Object>();

        Test.setMock(HttpCalloutMock.class, new API_SalesforceInternalCalloutMockClass());
        Test.startTest();
        //Get API call related Configuration from metadata
        Map<String,String> custMetData = CustomMetadataSelector.getAPIConstanst(CustomPresenceConfig_LWCController.namesList); 
        

        //Create PresenceUserConfig recs
        API_SalesforceInternalCalloutMockClass.respString = '[{"id":"0Nd1r0000004CAz007","success":true,"errors":[]},{"id":"0Nd1r0000004CAz008","success":true,"errors":[]}]';
        API_SalesforceInternalCalloutMockClass.respStatusCode = 200;  
        PresenceUserConfig p1 = new PresenceUserConfig(DeveloperName='TestPresConfi1', MasterLabel='TestPresConfi1', Capacity=5);
        PresenceUserConfig p2 = new PresenceUserConfig(DeveloperName='TestPresConfi2', MasterLabel='TestPresConfi2', Capacity=10);        
        pConfigStrResp = API_SalesforceInternal_Service.createRecords(custMetData.get('API_callOutEndPoint'),JSON.serialize(new List<PresenceUserConfig>{p1,p2}),custMetData.get('API_requestContentType'),custMetData.get('API_MethodPOST'));

        
        FOR(User u: [SELECT id,Name, Username FROM User WHERE username IN:userNames]){
            PresenceUserConfigUser p = new PresenceUserConfigUser(PresenceUserConfigId=p1.Id, UserId =u.id);       
            agentCapConfigList.add(p);
            usrList.add(u);
            userIds.add(u.Id);
        }
        system.assert(TRUE, agentCapConfigList.size()==3);
        
        //Create PresenceUserConfigUser records for the three agents
        API_SalesforceInternalCalloutMockClass.respString = '[{"id":"0Ne9E0000004ECY007","success":true,"errors":[]},{"id":"0Ne9E0000004ECY008","success":true,"errors":[]},{"id":"0Ne9E0000004ECY009","success":true,"errors":[]}]';
        API_SalesforceInternalCalloutMockClass.respStatusCode = 200; 
        pConfigUserStrResp = API_SalesforceInternal_Service.createRecords(custMetData.get('API_callOutEndPoint'),JSON.serialize(agentCapConfigList),custMetData.get('API_requestContentType'),custMetData.get('API_MethodPOST'));
        saveResList = (List<Database.SaveResult>)System.JSON.deserialize(pConfigUserStrResp.substringAfter('--'), List<Database.SaveResult>.class);
        system.assertEquals(3,saveResList.size());
        
        FOR(Database.SaveResult rec:saveResList){
           agentsPreConfigIds.add(rec.Id);
        }
      
        Integer counter = 0;
        FOR(User u: usrList){
            CustomPresenceConfig_LWCController.agentsAndCapacity obj = new CustomPresenceConfig_LWCController.agentsAndCapacity();
            obj.agentName = u.Name;
            obj.agentPresenceConfigId = saveResList[counter].Id;
            obj.presenceConfigId = p1.Id;
            obj.agentCapacity = 'TestPresConfi1' ;
            obj.userId = u.Id;
            obj.isCapSetAtUser = TRUE ;            
            Object o = (Object)obj;
            pAgentsConfigMap.put( saveResList[counter].Id,o);
            counter++;
        }
        system.debug('pAgentsConfigMap@@..'+pAgentsConfigMap);
        User supVsrUser = [Select id from User where username='testsupervisoruser@deliveryhero.com' Limit 1];
        system.assert(true, supVsrUser!=null); 

        // Class methods to remove and add capacity
        system.runAs(supVsrUser){
            CustomPresenceConfig_LWCController.removeAgentsOldCapacity(agentsPreConfigIds,pAgentsConfigMap);
            CustomPresenceConfig_LWCController.getAgentsUpdatedCapacity(p2.Id,'Test New Capacity',new List<Id>(userIds),pAgentsConfigMap);
        }
        Test.stopTest();
    }

    @IsTest
    static void testMethodUpdateCapacityWithAgentsAsUsersPartialSucc(){
        
        //Request and response string
        String pConfigStrResp ;
        String pConfigUserStrResp;        
        List<Database.SaveResult> saveResList  = new List<Database.SaveResult>();
        List<Database.SaveResult> saveResList2  = new List<Database.SaveResult>();
        List<String> userNames = new List<String>{'testagentuser@deliveryhero.com','testAgentUserWithParentRole@deliveryhero.com','testAgentUserWithChildRole@deliveryhero.com'};
        List<User> usrList = new List<User>();
        List<PresenceUserConfigUser> agentCapConfigList = new List<PresenceUserConfigUser>();
        List<Id> userIds = new List<Id>();
        List<Id> agentsPreConfigIds = new List<Id>();
        Map<String, Object> pAgentsConfigMap = new Map<String, Object>();

        Test.setMock(HttpCalloutMock.class, new API_SalesforceInternalCalloutMockClass());
        Test.startTest();
        //Get API call related Configuration from metadata
        Map<String,String> custMetData = CustomMetadataSelector.getAPIConstanst(CustomPresenceConfig_LWCController.namesList); 
        

        //Create PresenceUserConfig recs
        API_SalesforceInternalCalloutMockClass.respString = '[{"id":"0Nd1r0000004CAz007","success":true,"errors":[]},{"id":"0Nd1r0000004CAz008","success":true,"errors":[]}]';
        API_SalesforceInternalCalloutMockClass.respStatusCode = 200;   
        PresenceUserConfig p1 = new PresenceUserConfig(DeveloperName='TestPresConfi1', MasterLabel='TestPresConfi1', Capacity=5);
        PresenceUserConfig p2 = new PresenceUserConfig(DeveloperName='TestPresConfi2', MasterLabel='TestPresConfi2', Capacity=10);        
        pConfigStrResp = API_SalesforceInternal_Service.createRecords(custMetData.get('API_callOutEndPoint'),JSON.serialize(new List<PresenceUserConfig>{p1,p2}),custMetData.get('API_requestContentType'),custMetData.get('API_MethodPOST'));
        saveResList2  = (List<Database.SaveResult>)System.JSON.deserialize(pConfigStrResp.substringAfter('--'), List<Database.SaveResult>.class);
        List<Id> pconfigIds = new List<Id>();
        FOR(Database.SaveResult rec:saveResList2){
            IF(rec.success == TRUE){
                pconfigIds.add(rec.Id);
            }
        }
        system.assertEquals(2,pconfigIds.size());
        
        FOR(User u: [SELECT id,Name, Username FROM User WHERE username IN:userNames]){
            PresenceUserConfigUser p = new PresenceUserConfigUser(PresenceUserConfigId=p1.Id, UserId =u.id);       
            agentCapConfigList.add(p);
            usrList.add(u);
            userIds.add(u.Id);
        }
        system.assert(TRUE, agentCapConfigList.size()==3);
        
        //Create PresenceUserConfigUser records for the three agents
        API_SalesforceInternalCalloutMockClass.respString = '[{"id":"0Ne9E0000004ECY007","success":true,"errors":[]},{"id":"0Ne9E0000004ECY008","success":true,"errors":[]},{"id":"0Ne9E0000004ECY009","success":true,"errors":[]}]';
        API_SalesforceInternalCalloutMockClass.respStatusCode = 200; 
        pConfigUserStrResp = API_SalesforceInternal_Service.createRecords(custMetData.get('API_callOutEndPoint'),JSON.serialize(agentCapConfigList),custMetData.get('API_requestContentType'),custMetData.get('API_MethodPOST'));
        saveResList = (List<Database.SaveResult>)System.JSON.deserialize(pConfigUserStrResp.substringAfter('--'), List<Database.SaveResult>.class);
        system.assertEquals(3,saveResList.size());
        
        FOR(Database.SaveResult rec:saveResList){
            IF(rec.success == TRUE){
                agentsPreConfigIds.add(rec.Id);
            }
        }
      
        Integer counter = 0;
        FOR(User u: usrList){
            CustomPresenceConfig_LWCController.agentsAndCapacity obj = new CustomPresenceConfig_LWCController.agentsAndCapacity();
           // IF(saveResList[counter].success == TRUE){
                obj.agentName = u.Name;
                obj.agentPresenceConfigId = saveResList[counter].Id;
                obj.presenceConfigId = p1.Id;
                obj.agentCapacity = 'TestPresConfi1' ;
                obj.userId = u.Id;
                obj.isCapSetAtUser = TRUE ;            
                Object o = (Object)obj;
                pAgentsConfigMap.put( saveResList[counter].Id,o);
                counter++;
          //  }
            
        }
        
        User supVsrUser = [Select id from User where username='testsupervisoruser@deliveryhero.com' Limit 1];
        system.assert(true, supVsrUser!=null); 
        API_SalesforceInternalCalloutMockClass.respString = '[{"id":"0Ne9E0000004ECY007","success":true,"errors":[]},{"id":"0Ne9E0000004ECY008","success":true,"errors":[]},{"id":"0Ne9E0000004ECY009","success":false,"errors":[]}]';
        API_SalesforceInternalCalloutMockClass.respStatusCode = 200; 
        // Class methods to remove and add capacity
        system.runAs(supVsrUser){
            system.debug('pAgentsConfigMap@@..'+pAgentsConfigMap);
            CustomPresenceConfig_LWCController.removeAgentsOldCapacity(agentsPreConfigIds,pAgentsConfigMap);
            CustomPresenceConfig_LWCController.getAgentsUpdatedCapacity(pconfigIds[1],'Test New Capacity',new List<Id>(userIds),pAgentsConfigMap);
        }
        Test.stopTest();
    }

    @IsTest
    static void testMethodUpdateCapacityWithAgentsAsProfiles(){
        //Request and response string
        String pConfigStrResp ;
        String pConfigUserStrResp;        
        List<Database.SaveResult> saveResList  = new List<Database.SaveResult>();
        List<String> userNames = new List<String>{'testagentuser@deliveryhero.com','testAgentUserWithParentRole@deliveryhero.com','testAgentUserWithChildRole@deliveryhero.com'};
        PresenceUserConfig p1 = new PresenceUserConfig(DeveloperName='TestPresConfi1', MasterLabel='TestPresConfi1', Capacity=5);
        PresenceUserConfig p2 = new PresenceUserConfig(DeveloperName='TestPresConfi2', MasterLabel='TestPresConfi2', Capacity=10); 
        List<User> usrList = new List<User>();
        List<Id> agentsPreConfigIds = new List<Id>();
        Map<String, Object> pAgentsConfigMap = new Map<String, Object>();
        List<PresenceUserConfigProfile> agentCapConfigList = new List<PresenceUserConfigProfile>(); 
        User u = [SELECT id,Name, Username, ProfileId FROM User WHERE username =: 'testagentuser@deliveryhero.com'];
        system.assert(TRUE, u != NULL);
        Profile pf = [Select id,Name FROM Profile where Name =: 'Talabat Customer Care'];
        system.assert(TRUE, pf != NULL);
        PresenceUserConfigProfile p = new PresenceUserConfigProfile(PresenceUserConfigId=p1.Id, ProfileId =pf.id); 

        Test.setMock(HttpCalloutMock.class, new API_SalesforceInternalCalloutMockClass());
        Test.startTest();
        //Get API call related Configuration from metadata
        Map<String,String> custMetData = CustomMetadataSelector.getAPIConstanst(CustomPresenceConfig_LWCController.namesList);         

        //Create PresenceUserConfig recs
        API_SalesforceInternalCalloutMockClass.respString = '[{"id":"0Nd1r0000004CAz007","success":true,"errors":[]},{"id":"0Nd1r0000004CAz008","success":true,"errors":[]}]'; 
        API_SalesforceInternalCalloutMockClass.respStatusCode = 200;             
        pConfigStrResp = API_SalesforceInternal_Service.createRecords(custMetData.get('API_callOutEndPoint'),JSON.serialize(new List<PresenceUserConfig>{p1,p2}),custMetData.get('API_requestContentType'),custMetData.get('API_MethodPOST'));
        
        //Create PresenceUserConfigProfile records for the three agents
        API_SalesforceInternalCalloutMockClass.respString = '[{"id":"0Nf1r0000008OIB007","success":true,"errors":[]}]';
        API_SalesforceInternalCalloutMockClass.respStatusCode = 200; 
        pConfigUserStrResp = API_SalesforceInternal_Service.createRecords(custMetData.get('API_callOutEndPoint'),JSON.serialize(p),custMetData.get('API_requestContentType'),custMetData.get('API_MethodPOST'));
        saveResList = (List<Database.SaveResult>)System.JSON.deserialize(pConfigUserStrResp.substringAfter('--'), List<Database.SaveResult>.class);
        system.assertEquals(1,saveResList.size());
        
        FOR(Database.SaveResult rec:saveResList){
           agentsPreConfigIds.add(rec.Id);
        }

        CustomPresenceConfig_LWCController.agentsAndCapacity obj = new CustomPresenceConfig_LWCController.agentsAndCapacity();
        obj.agentName = u.Name;
        obj.agentPresenceConfigId = saveResList[0].Id;
        obj.presenceConfigId = p1.Id;
        obj.agentCapacity = 'TestPresConfi2' ;
        obj.userId = u.Id;
        obj.isCapSetAtUser = FALSE ;            
        Object o = (Object)obj;
        pAgentsConfigMap.put( saveResList[0].Id,o);

        system.assert(TRUE, !pAgentsConfigMap.isEmpty());
        User supVsrUser = [Select id from User where username='testsupervisoruser@deliveryhero.com' Limit 1];
        system.assert(true, supVsrUser!=null);
        system.runAs(supVsrUser){
        // Class methods to remove and add capacity
            CustomPresenceConfig_LWCController.removeAgentsOldCapacity(agentsPreConfigIds,pAgentsConfigMap);              
            CustomPresenceConfig_LWCController.getAgentsUpdatedCapacity(p2.Id,'Test New Capacity',new List<Id>{u.Id},pAgentsConfigMap);
        }
        Test.stopTest();
    }
}