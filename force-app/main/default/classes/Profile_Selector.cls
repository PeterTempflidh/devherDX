/**
 * Created by c.kumari on 21.10.2019.
 */

public with sharing class Profile_Selector {

    /**
  * Retrieves Profile Name of logged in user
  * @param  None
  * @return Profile record
  */

    public static Profile getProfileInfo(){

        Profile recProfile;
        try{
        recProfile = [SELECT
                        Id, Name
                        From Profile
                        WHERE Id =:UserInfo.getProfileId()];
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }
        return recProfile;
    }
}