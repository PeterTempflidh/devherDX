public with sharing class SocialPostSelector {
    /* @description Query for SocialPost filter by Id .
    * @param keys String postId : Idof the Socialpost
    * @return : list of socialposts
    */
    @TestVisible
    public static List<SocialPost> getSocialPostById (Id postId) {
        List<SocialPost> postList = new List<SocialPost>();
        try {
            postList = [Select Recipient, IsOutbound from SocialPost where id = :postId limit 1];
        } catch (Exception e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return postList;
    }
}