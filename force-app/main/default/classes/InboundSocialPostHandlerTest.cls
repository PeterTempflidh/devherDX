@isTest
public class InboundSocialPostHandlerTest {
    
    static Map<String, Object> sampleSocialData;
    static InboundSocialPostHandler handler;
    public static Country__c c;
    public static Business_Config__c b1;
    public static  SocialPost testPost = new SocialPost();
    public static Attachment attachment = new Attachment();
    public static Case parentCase;

    static {
    	handler = new InboundSocialPostHandler();
        sampleSocialData = getSampleSocialData('1');
    }
    
    @TestSetup
    static void setupTestData(){
        User userid = UserSelector.getSocialApiUser();   
        Country__c c = UnitTestDataFactory.createCountry('MY','Malayasia', 'EUR');
        insert c;
        RecordType recordType = UnitTestDataFactory.getRecordType('FP_Inbound_Case');
        Business_Config__c b1 = UnitTestDataFactory.createBusinessConfig('CaseDetailsForSocialStudio','Process','Foodpanda',recordType.Id,c.id,'PlatformRecordTypeIdMapping',TRUE,TRUE);
        insert b1;

        Trigger_Manager__c cs = new Trigger_Manager__c(SetupOwnerId =userid.Id, Deactivate_Case_Trigger__c=TRUE,Deactivate_Contact_Trigger__c=TRUE,Deactivate_Account_Trigger__c=TRUE);
        insert cs;

    }

    public static testMethod void verifyNewRecordCreation() {
        User userid = UserSelector.getSocialApiUser();  

        System.runAs(userid){

        SocialPost post = getSocialPost(sampleSocialData);       
        SocialPersona persona = getSocialPersona(sampleSocialData); 

        test.startTest();
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        test.stopTest(); 
        System.assertEquals(persona.Id, post.PersonaId);


        }
    }

    static testMethod void matchCaseRecord() {
        User userid = UserSelector.getSocialApiUser();   
        System.runAs(userid){

        Contact existingContact = new Contact(LastName = 'LastName');
        existingContact.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Social_Contact').getRecordTypeId();
        insert existingContact;

        SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
        existingPersona.ParentId = existingContact.Id;
        insert existingPersona;

        Case existingCase = new Case(ContactId = existingContact.Id, Subject = 'Test Case');
        insert existingCase;

        SocialPost existingPost = getSocialPost(getSampleSocialData('2'));
        existingPost.ParentId = existingCase.Id;
        existingPost.WhoId = existingContact.Id;
        existingPost.PersonaId = existingPersona.Id;
        String recipient = 'scs';
        existingPost.recipient = recipient;
        insert existingPost;
        
        SocialPost post = getSocialPost(sampleSocialData);
        post.responseContextExternalId = existingPost.ExternalPostId;
        post.Recipient = recipient;
        
        test.startTest();
        handler.handleInboundSocialPost(post, existingPersona, sampleSocialData);
        handler.reopenCase(existingCase);
        test.stopTest();

        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost WHERE R6PostId = :post.R6PostId];
        System.assertEquals(existingPersona.Id, createdPost.PersonaId);
        System.assertEquals(existingContact.Id, createdPost.WhoId);
        System.assertEquals(existingCase.Id, createdPost.ParentId);
        System.assertEquals(1, [SELECT Id FROM Case].size(), 'There should only be 1 Case.');

        }
      
    }

    static testMethod void matchSocialPostRecord() {

        User userid = UserSelector.getSocialApiUser();   
        System.runAs(userid){
        SocialPost existingPost = getSocialPost(getSampleSocialData('2'));
        insert existingPost;
        
        SocialPost post = getSocialPost(sampleSocialData);
        post.R6PostId = existingPost.R6PostId;
        SocialPersona persona = getSocialPersona(sampleSocialData);

        test.startTest();
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        handler.hasPostTagsThatCreateCase(post);
        handler.hasReview(post);
        handler.hasRecommendationReview(post);
        handler.getRatingString(post);
        handler.getRecommendedReviewString(post);
        handler.findParentCaseFromPersona(post,persona);
        handler.findParentCaseOfChatFromPersonaAndRecipient(post,persona);
        handler.matchPersona(persona);
        handler.findReplyToBasedOnReplyToId(testPost);
        
        test.stopTest();
        }
    }

    
    static testMethod void matchSocialPersonaRecord() {
        User userid = UserSelector.getSocialApiUser();   


        System.runAs(userid){
        Contact existingContact = new Contact(LastName = 'LastName');
        existingContact.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Social_Contact').getRecordTypeId();
        insert existingContact;
        SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
        existingPersona.ParentId = existingContact.Id;
        insert existingPersona;
        
        SocialPost post = getSocialPost(sampleSocialData);
        //post.postTags = 'platform:Foodpanda,country:Malaysia';
        SocialPersona persona = getSocialPersona(sampleSocialData);
        persona.ExternalId = existingPersona.ExternalId;

        String url = post.PostUrl;
        String mimeType = 'Image/*';
        String mediaType = post.mediaType;
        String mediaUrl = post.mediaType;
        Object compareTo;
       
        InboundSocialPostHandler.PostAttachmentFacet facet = new InboundSocialPostHandler.PostAttachmentFacet(url,mimeType);    
        List<InboundSocialPostHandler.PostAttachmentFacet> facetList = new List<InboundSocialPostHandler.PostAttachmentFacet>();
        facetList.add(facet);

        InboundSocialPostHandler.PostAttachment postAttachment = new InboundSocialPostHandler.PostAttachment(mediaType,mediaUrl,facetList);
        List<InboundSocialPostHandler.PostAttachment> attachmentList = new List<InboundSocialPostHandler.PostAttachment>();
        attachmentList.add(postAttachment);
        
        InboundSocialPostHandler.LegacyPostAttachment legacyPostattachments = new InboundSocialPostHandler.LegacyPostAttachment(mediaType,mediaUrl);
        List<InboundSocialPostHandler.LegacyPostAttachment> legacyPostattachmentsList = new List<InboundSocialPostHandler.LegacyPostAttachment>();
        legacyPostattachmentsList.add(legacyPostattachments);

        
        test.startTest();
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        test.stopTest();
   
        }
       
    }
    
    static testMethod void reopenClosedCase() {
       
        User userid = UserSelector.getSocialApiUser();   

        System.runAs(userid){
        Contact existingContact = new Contact(LastName = 'LastName');
        existingContact.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Social_Contact').getRecordTypeId();
        insert existingContact;

        SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
        existingPersona.ParentId = existingContact.Id;
        insert existingPersona;

        Case existingCase = new Case(ContactId = existingContact.Id, Subject = 'Test Case', Status = 'Closed');
        insert existingCase;

        SocialPost existingPost = getSocialPost(getSampleSocialData('2'));
        existingPost.ParentId = existingCase.Id;
        existingPost.WhoId = existingContact.Id;
        existingPost.PersonaId = existingPersona.Id;
        String recipient = 'scs';
        existingPost.recipient = recipient;
        insert existingPost;
        
        SocialPost post = getSocialPost(sampleSocialData);
        post.responseContextExternalId = existingPost.ExternalPostId;
        post.Recipient = recipient;
        
        test.startTest();

        handler.handleInboundSocialPost(post, existingPersona, sampleSocialData);
        handler.caseShouldBeReopened(existingCase);
        handler.reopenCase(existingCase);

        test.stopTest();
        }
    }

    static testMethod void testAttachements() {

        User userid = UserSelector.getSocialApiUser();   

        System.runAs(userid){
        Contact existingContact = new Contact(LastName = 'LastName');
        existingContact.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Social_Contact').getRecordTypeId();
        insert existingContact;

        SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
        existingPersona.ParentId = existingContact.Id;
        insert existingPersona;
        
        SocialPost post = getSocialPost(sampleSocialData);
        insert post;

        SocialPersona persona = getSocialPersona(sampleSocialData);
        persona.ExternalId = existingPersona.ExternalId;

        String url = post.PostUrl;
        String mimeType = 'Image/*';
        String mediaType = post.mediaType;
        String mediaUrl = post.mediaType;
        Object compareTo;
       
        InboundSocialPostHandler.PostAttachmentFacet facet = new InboundSocialPostHandler.PostAttachmentFacet(url,mimeType);
    
        List<InboundSocialPostHandler.PostAttachmentFacet> facetList = new List<InboundSocialPostHandler.PostAttachmentFacet>();
        facetList.add(facet);

        InboundSocialPostHandler.PostAttachment postAttachment = new InboundSocialPostHandler.PostAttachment(mediaType,mediaUrl,facetList);
        List<InboundSocialPostHandler.PostAttachment> attachmentList = new List<InboundSocialPostHandler.PostAttachment>();
        attachmentList.add(postAttachment);

        InboundSocialPostHandler.LegacyPostAttachment legacyPostattachments = new InboundSocialPostHandler.LegacyPostAttachment(mediaType,mediaUrl);
        List<InboundSocialPostHandler.LegacyPostAttachment> legacyPostattachmentsList = new List<InboundSocialPostHandler.LegacyPostAttachment>();
        legacyPostattachmentsList.add(legacyPostattachments);

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentUrl = System.Label.sampleContentUrl;
        contentVersion.Title = 'post_Attachment_'+post.ExternalPostId;
        insert contentVersion;

        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        contentVersionList.add(contentVersion);

        test.startTest();
       // Integer getMimeType = handler.getMimetypeValue(mimeType);
        handler.createAttachments(post,attachmentList);
        handler.createLegacyAttachments(post,legacyPostattachmentsList);
        handler.createLinksForLegacyAttachmentsToSocialPost(post,contentVersionList);
        test.stopTest();
        }
    }

    static SocialPost getSocialPost(Map<String, Object> socialData) {

        User userid = UserSelector.getSocialApiUser();   


        SocialPost post = new SocialPost();

        System.runAs(userid){
       	post.Name = String.valueOf(socialData.get('source'));
        post.Content = String.valueOf(socialData.get('content'));
        post.Posted = Date.valueOf(String.valueOf(socialData.get('postDate')));
        post.PostUrl = String.valueOf(socialData.get('postUrl'));
        post.Provider = 'Twitter';
        post.MessageType = 'Direct';
        post.Recipient = '113438576959001';
        post.ExternalPostId = String.valueOf(socialData.get('externalPostId'));
        post.R6PostId = String.valueOf(socialData.get('r6PostId'));
        post.postTags = String.valueOf(socialData.get('postTags'));
        post.AttachmentUrl = String.valueOf(socialData.get('mediaUrls'));
        post.reviewScore = 5;
        post.reviewScale = 10;
        
        }
        return post;

    }

    static SocialPersona getSocialPersona(Map<String, Object> socialData) {
        User userid = UserSelector.getSocialApiUser();   
        SocialPersona persona = new SocialPersona();

        System.runAs(userid){
        persona.Name = String.valueOf(socialData.get('author'));
        persona.RealName = String.valueOf(socialData.get('realName'));
        persona.Provider = String.valueOf(socialData.get('mediaProvider'));
        persona.MediaProvider = String.valueOf(socialData.get('mediaProvider'));
        persona.ExternalId = String.valueOf(socialData.get('postTags'));        
        }
        return persona;

    }


    static Map<String, Object> getSampleSocialData(String suffix) {

        Map<String, Object> socialData = new Map<String, Object>();       
        socialData.put('r6PostId', 'R6PostId' + suffix);
        socialData.put('r6SourceId', 'R6SourceId' + suffix);
        socialData.put('postTags', 'platform:Foodpanda,country:Malaysia'); 
        socialData.put('externalPostId', 'ExternalPostId' + suffix);
        socialData.put('content', 'Content' + suffix);
        socialData.put('postDate', '2015-01-12T12:12:12Z');
        socialData.put('mediaType', 'Twitter');
        socialData.put('author', 'Other');
        socialData.put('skipCreateCase', false);
        socialData.put('mediaProvider', 'TWITTER');
        socialData.put('externalUserId', 'ExternalUserId');
        socialData.put('postUrl', 'PostUrl' + suffix);
        socialData.put('messageType', 'Tweet');
        socialData.put('source', 'Source' + suffix);
        socialData.put('replyToId',System.Label.SampleSocialPostId);
        socialData.put('replyToExternalPostId', null);
        socialData.put('realName', 'Real Name');
      
        return socialData;
}

}
