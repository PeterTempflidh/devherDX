public inherited sharing class GroupSelector {

    public static Group getQueueByName(String name) {
        return [SELECT Id, Name FROM Group WHERE  Type = 'Queue' AND Name = :name];
    }

    public static Group getQueueByDeveloperName(String developerName) {
        return [SELECT Id, Name FROM Group WHERE  Type = 'Queue' AND DeveloperName = :developerName];
    }
    
    public static List<Group> getQueuesByDeveloperName(List<String> developerNameList) {
        return [SELECT Id, Name, DeveloperName FROM Group WHERE  Type = 'Queue' AND DeveloperName IN :developerNameList];
    }

    /**
    * @author Hugh Crinion
    * @date 20-Oct-19
    * @description : used to get a group of owners, IDs, Names
    * SP-3791 : Global - Pandora Menu Change Process
    * @return 
    **/
    public static List<Group> getGroupOwnerName(Set<String> ownNme) {
        return [SELECT Id, Name FROM Group WHERE  Type = 'Queue' AND Name IN: ownNme];    
    }

}