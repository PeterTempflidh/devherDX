/**
 * Created by c.kumari on 31.07.2019.
 */

public with sharing class UserSelector {

    /*******************************************************************************************************
   * @description Queries to get the user record based on email address
   * @param String Email
   * @return User
   */

    public static User findUserByEmail(String Email) {
        User userRecord;
        try {
            userRecord = [SELECT id FROM User WHERE email =: Email AND IsActive = true  LIMIT 1];
        } catch(QueryException e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return userRecord;
    }

    /*******************************************************************************************************
   * @description Queries to get the user record based on User Ids
   * @param set of Ids
   * @return List<User>
   */

    public static List<User> getAllByUserId(set<ID> userIds) {
        List<User> listUser = new List<User>();
        try {
            listUser = [SELECT Id, Email, UserRole.Name, UserRole.DeveloperName, Profile.Name FROM User where id = :userIds];
        } catch(QueryException e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return listUser;
    }

       /*******************************************************************************************************
   * @description Queries to get the Social Api user  by Name
   * @param :Id
   * @return User
   */

    public static User getSocialApiUser() {
        User socialUser= new User();
        try {
            socialUser = [select Id from User where Name = 'Social Studio Account' AND CommunityNickname = 'socialstudioDH' Limit 1];
        } catch(QueryException e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return socialUser;
    }
	
    /*******************************************************************************************************
   * @description SCC-26: Get Logged in user's elastix extension details.
   * @param String fields, String whereClause
   * @return User
   */

    public static Map<Id, User> getUsersWithDynamicCondition(String fields, String whereClause) {
        String query = 'SELECT ' + fields + ' FROM User WHERE '+whereClause;
        List<User> users = (List<User>)database.query(query);
        if(users.size()>0) {
            return new Map<Id, User>(users);
        }
        return null;
    }

}