public class CtrPlatformEventDemo{

    private static final String PlATFORM_EVENT= 'Backend_Integration__e';
    
    public String channel{get; private set;}
    public Integer replayFrom{get;set;}
    public Id topicId{get;set;}
    
    public CtrPlatformEventDemo() {
        this.channel = '/event/' + PlATFORM_EVENT;
        this.replayFrom = -2;
    }
    
    /*public PageReference getOrCreatePushChannel() {
        List<PushTopic> pushTopics = [SELECT Id,Name FROM PushTopic WHERE Name=:TOPIC_NAME];
        if (null == pushTopics || pushTopics.size() == 0) {
            PushTopic topic = new PushTopic();
            topic.Name = TOPIC_NAME;
            topic.Query = 'SELECT Id,Name,Website FROM ACCOUNT';
            topic.NotifyForFields = 'Referenced';
            topic.ApiVersion = 37.0;
            insert topic;
            this.topicId = topic.Id;
        } else {
            this.topicId = pushTopics.get(0).Id;
        }
        return null;
    }*/
}