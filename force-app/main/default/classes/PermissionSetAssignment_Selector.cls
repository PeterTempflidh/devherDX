/**
 * Created by c.kumari on 10.10.2019.
 */

public with sharing class PermissionSetAssignment_Selector {


    /**
  * Return whether the current user has a specific PermissionSet assigned
  * @param  Permission Set Name
  * @return Boolean
  */

    public static Boolean getByName(String permSetName){

        Boolean hasPermissionEnabled = false;
        try {
            PermissionSetAssignment permSet = [SELECT AssigneeId
                                                FROM PermissionSetAssignment
                                                WHERE PermissionSet.Name =: permSetName
                                                AND AssigneeId =:UserInfo.getUserId()];

            if(permSet != null){
                hasPermissionEnabled = true;
            }
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }
        return hasPermissionEnabled;
    }

}
