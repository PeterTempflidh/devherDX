public class Group_Utils {
    
    public static List<Id> allRoleIds = new List<Id>();
    public static List<Id> allUserIds = new List<Id>();
    public static List<Id> allRoleAndSubIds = new List<Id>();    
    
    /* @desc: prepare all grp members ids or role id including sub roles ids based on members added in the group
     * @param: list of group(s) id for which members need to be fetched
     */

    public static void getGroupMembers(List<Id> pGroupIds){  
        IF(!pGroupIds.isEmpty()){   
            Map<Id, List<GroupMember>> grpMembersMap = new Map<Id, List<GroupMember>>();
            List<Group> groups = new List<Group>();
            List<GroupMember> grpMembers = new List<GroupMember>();
            Map<Id, Group> grpInfoMap = new Map<Id, Group>();
            Boolean hasRoleMember = false;
			//SOQL on Group and GroupMember are splited because SF throws aggregate error using nested query on Group and GroupMember
            try{
                FOR(Group m: [SELECT Id,RelatedId, Type FROM Group WHERE  Id IN:pGroupIds] ){
                    IF(m.Type.startsWith('Role'))   {   hasRoleMember=TRUE;}
                    groups.add(m);
                    grpInfoMap.put(m.Id, m);
                }

                FOR(GroupMember m:[Select Id,UserOrGroupId,GroupId,Group.Type FROM GroupMember WHERE GroupId IN:pGroupIds]){          
                    IF(!grpMembersMap.isEmpty() && grpMembersMap.containsKey(m.GroupId)){
                        grpMembersMap.get(m.GroupId).add(m);
                    }ELSE{
                        grpMembersMap.put(m.GroupId, new List<GroupMember>{m});
                    }
                    grpMembers.add(m);           
                }
                
                
                String userType = Schema.SObjectType.User.getKeyPrefix();
                String groupType = Schema.SObjectType.Group.getKeyPrefix();
                String roleType = Schema.SObjectType.UserRole.getKeyPrefix();
                Set<Id> groupsId = new Set<Id>();           
                Set<Id> roleAndSubIds = new Set<Id>();

                IF(!grpMembers.isEmpty() )   {                
                    FOR(GroupMember grpMemRec: grpMembers){               
                            IF(((String)grpMemRec.UserOrGroupId).startsWith(userType)){
                                system.debug('is user');
                                allUserIds.add(grpMemRec.UserOrGroupId);
                            }
                            ELSE IF(grpInfoMap.get(grpMemRec.UserOrGroupId)!=null && grpInfoMap.get(grpMemRec.UserOrGroupId).RelatedId!='' && grpInfoMap.get(grpMemRec.UserOrGroupId).RelatedId != null &&
                                    ((String)grpInfoMap.get(grpMemRec.UserOrGroupId).relatedId).startsWith(roleType)){
                                system.debug('is role');
                                IF(grpInfoMap.get(grpMemRec.UserOrGroupId).type == 'Role'){
                                    allRoleIds.add(grpInfoMap.get(grpMemRec.UserOrGroupId).relatedId);
                                }
                                ELSE IF(grpInfoMap.get(grpMemRec.UserOrGroupId).type == 'RoleAndSubordinatesInternal') {
                                    allRoleAndSubIds.add(grpInfoMap.get(grpMemRec.UserOrGroupId).relatedId);
                                }
                            }
                            ELSE IF(((String)grpMemRec.UserOrGroupId).startsWith(groupType)){
                                system.debug('is group');
                                groupsId.add(grpMemRec.UserOrGroupId);
                            }
                        }
                }

                GovernorLimits_Utils.checkGovenorLimits();
				//Rerun the method for nested groups
                IF(!groupsId.isEmpty()){                    
                    getGroupMembers(new List<Id>(groupsId));                
                }
				//Get the role ids for roles and heirarichal roles
                IF(hasRoleMember) {  
                    getUsersFromGrps(grpInfoMap.values());    
                }        
                 
            }catch(Exception e){
                    system.debug('limit exp message'+e.getMessage());
                    LoggingUtility.logError(Group_Utils.class.getName(),'Error => ' + e.getMessage() + '\nLine Number : ' + e.getLineNumber());
                   
            } 
        }
    } 

    /* @desc: Get Role Ids from the GroupMembers which are added as Role or Roles and Subordinates
     * @param: List of group id which do have direct users added as members
     */
    public static void getUsersFromGrps(List<Group> pGrps){
        String roleType = Schema.SObjectType.UserRole.getKeyPrefix();

        FOR(Group grpRec: pGrps){          
                        
            IF(!(String.isEmpty((String)grpRec.RelatedId)) && ((String)grpRec.RelatedId).startsWith(roleType)){
                IF(grpRec.Type == 'Role'){
                     allRoleIds.add(grpRec.relatedId);
                }
                ELSE IF(grpRec.Type == 'RoleAndSubordinates') {
                    allRoleAndSubIds.add(grpRec.relatedId);
                }
            } 
        }
    }   

    /* @desc: Get all child roles for a given role
     * @param: Set of all parent roles
     */

    public static List<Id> getAllSubRoleIds(Set<Id> pRoleAndSubIds){
        IF(pRoleAndSubIds.isEmpty())    return null ;
        Set<Id> subRoleIds = new Set<Id>();
        FOR(UserRole u: [SELECT Id FROM UserRole WHERE ParentRoleId IN: pRoleAndSubIds] ){
            subRoleIds.add(u.Id);
        }
        
        List<Id> userRoleIdSet = new List<Id>();
        userRoleIdSet.addAll(subRoleIds);
        return  userRoleIdSet;
    }     

}
