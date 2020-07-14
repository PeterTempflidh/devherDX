global virtual class InboundSocialPostHandler implements Social.InboundSocialPostHandler {
    private static Map<String, Map<String, Map<String, Business_Config__c>>> moam = LibBusinessConfig.motherOfAllBusinessMaps;
    final static Integer CONTENT_MAX_LENGTH = SocialPost.Content.getDescribe().getLength();
    final static Integer SUBJECT_MAX_LENGTH = Case.Subject.getDescribe().getLength();
    Boolean isNewCaseCreated = false;
    Static String postCountry = '';

    // Reopen case if it has not been closed for more than this number
    global virtual Integer getMaxNumberOfDaysClosedToReopenCase() {  
        Integer daysToReOpen = Integer.valueOf(System.Label.MaxDaysToReOpenCaseFromClosed);
        return daysToReOpen;
    }
    
    // Create a case if one of these post tags are on the SocialPost, regardless of the skipCreateCase indicator.
    global virtual Set<String> getPostTagsThatCreateCase(){
        return new Set<String>();
    }

    // If true, use the active case assignment rule if one is found
    global virtual Boolean getUsingCaseAssignmentRule(){
        return true;
    }

    global virtual String getDefaultAccountId() {
        Id recordTypeId;
        Id recordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Social_Account').getRecordTypeId();
        try{
        Account acc  = AccountSelector.getByPlatformAndRecordType(recordType,postCountry);
        return acc.id;
        }catch(Exception ex){
            LoggingUtility.logError(InboundSocialPostHandler.class.getName(),'Error => ' + ex.getMessage() + '\nLine Number : ' + ex.getLineNumber());
            return null;
        }
    }

    global Social.InboundSocialPostResult handleInboundSocialPost(SocialPost post, SocialPersona persona, Map<String, Object> rawData) {
        Social.InboundSocialPostResult result = new Social.InboundSocialPostResult();
        result.setSuccess(true);
        matchPost(post);
        matchPersona(persona);

        if ((post.Content != null) && (post.Content.length() > CONTENT_MAX_LENGTH)) { 
            post.Content = post.Content.abbreviate(CONTENT_MAX_LENGTH);
        }
        if (post.Id != null) {
            handleExistingPost(post, persona);
            return result;
        }
        String[] tagList;
        if(post.PostTags.contains(',') && post.PostTags!=null){
            tagList = post.PostTags.split(',');
        }
        if(!tagList.isEmpty()){
            for(String tag : tagList){
               if(tag.contains('country')){
               postCountry = tag.subStringAfter('country:');
               }        
           }
        }
        setReplyTo(post, persona);
        buildPersona(persona);
        Case parentCase = buildParentCase(post, persona, rawData); 
        setRelationshipsOnPost(post, persona, parentCase);
        setModeration(post, rawData);
        
        upsert post; 
        
        if(isNewCaseCreated){
            updateCaseSource(post, parentCase);
        }
        
		handlePostAttachments(post, rawData);
		        
        return result;
    }
    
    private void setModeration(SocialPost post, Map<String, Object> rawData){
        //if we don't automatically create a case, we should flag the post as requiring moderator review.
        if(post.parentId == null && !isUnsentParent(rawData)){
            post.reviewedStatus = 'Needed';
        }
    }
    
    private void updateCaseSource(SocialPost post, Case parentCase){
        if(parentCase != null) {
            parentCase.SourceId = post.Id;
            //update as a new sobject to prevent undoing any changes done by insert triggers
            update new Case(Id = parentCase.Id, SourceId = parentCase.SourceId);
        }
    
    }
    
    private void handleExistingPost(SocialPost post, SocialPersona persona) {
        List<SocialPost> existingPosts = SocialPostSelector.getSocialPostById(post.Id);

    	// for any existing outbound post, we don't overwrite its recipient field
    	if (!existingPosts.isEmpty() && existingPosts[0].IsOutBound == true && String.isNotBlank(existingPosts[0].Recipient)) {
    		post.Recipient = existingPosts[0].Recipient;
    	}
    		
    	update post;
    	if (persona.id != null)
    		updatePersona(persona);
    }

    private void setReplyTo(SocialPost post, SocialPersona persona) {
        SocialPost replyTo = findReplyTo(post, persona);
        if(replyTo.id != null) {
            post.replyToId = replyTo.id;
            post.replyTo = replyTo;
        }
    }

    private SocialPersona buildPersona(SocialPersona persona) {
        if (persona.Id == null)
            createPersona(persona);
        else{
            updatePersona(persona);
        }
            
        return persona;
    }
    
    private void updatePersona(SocialPersona persona) {
        try{
            if (socialPersonaShouldBeUpdated(persona)){
                update persona;
            }
        }catch(Exception ex) {
            LoggingUtility.logError(InboundSocialPostHandler.class.getName(),'Error => ' + ex.getMessage() + '\nLine Number : ' + ex.getLineNumber());
        }
    }
    
    private Case buildParentCase(SocialPost post, SocialPersona persona, Map<String, Object> rawData){
        if(!isUnsentParent(rawData)) {
            Case parentCase = findParentCase(post, persona);
            if (parentCase != null && !parentCase.IsClosed) {
                return parentCase;              
            }
            if(shouldCreateCase(post, rawData)){
                isNewCaseCreated = true;
                return createCase(post, persona);
            }
        }
        
        return null;
    }
    
    @TestVisible
    private boolean caseShouldBeReopened(Case c){  
        return c.id != null && c.isClosed && c.closedDate != null && System.now() < c.closedDate.addDays(getMaxNumberOfDaysClosedToReopenCase());
    }

    private boolean socialPersonaShouldBeUpdated(SocialPersona persona){  
        boolean shouldUpdatePersona = false;
        //Do not update if persona was updated within a day because SocialPersona doesn't change often
        SocialPersona p = [SELECT Id, LastModifiedDate FROM SocialPersona WHERE Id = :persona.Id LIMIT 1];
        if((p.LastModifiedDate != null) && (System.now() < p.LastModifiedDate.addDays(1))){
            shouldUpdatePersona = true;
        }
        return shouldUpdatePersona;
    }

    private void setRelationshipsOnPost(SocialPost postToUpdate, SocialPersona persona, Case parentCase) {
        if (persona.Id != null) {
            postToUpdate.PersonaId = persona.Id;
            
            if(persona.ParentId.getSObjectType() != SocialPost.sObjectType) {
                postToUpdate.WhoId = persona.ParentId;
            }
        }
        if(parentCase != null) {
            postToUpdate.ParentId = parentCase.Id;
        }
    }

    @TestVisible
    private Boolean hasReview(SocialPost post) {
        return post.ReviewScore != null;
    }
    
    @TestVisible
    private Boolean hasRecommendationReview(SocialPost post) {
        return post.ReviewScale == Integer.ValueOf(System.Label.SocialPostRecommendationReview);
    }
    
    @TestVisible
    private String getRatingString(SocialPost post) {
        Integer maxNumberOfStars = 5;
        Double reviewScore = post.ReviewScore;
        Double reviewScale = post.ReviewScale;
        if (reviewScore == null) {
            reviewScore = 0;
        }
        if (reviewScale == null) {
            reviewScale = maxNumberOfStars;
        }
        Integer numberOfStars = Math.floor((reviewScore / reviewScale) * maxNumberOfStars).intValue();
        return numberOfStars.format() + '-Star';
    }
    
    @TestVisible
    private String getRecommendedReviewString(SocialPost post) {
        if (post.ReviewScore > 0) {
            return Label.socialpostrecommendation.recommends;
        } else {
            return Label.socialpostrecommendation.doesnotrecommend;
        }
    }
    
    private Case createCase(SocialPost post, SocialPersona persona) {
        String caseSubject ='';
        if(post.MessageType!=null){
        caseSubject = post.Provider+' - '+post.MessageType;
        }  
        Case newCase = new Case(subject = caseSubject,Type='Customer',Is_Verified__c=persona.IsVerified,
                                Description=post.Content,Customer_Name__c=persona.Name);
                              
        String[] tagList;
        String platform;
        if(post.PostTags.contains(',') && post.PostTags!=null){
            tagList = post.PostTags.split(',');
        }
        if(!tagList.isEmpty()){
           for(String tag : tagList){ 
               if(tag.contains('country')){
                   newCase.Country__c = tag.subStringAfter('country:');
                }if(tag.contains('platform')){
                   platform = tag.subStringAfter('platform:');
                   newCase.Platform__c = platform;
                }           
            }
        }
        newCase.RecordTypeId = getCaseRecordType(platform); 
        if (persona != null && persona.ParentId != null) {
            if (persona.ParentId.getSObjectType() == Contact.sObjectType) {
                newCase.ContactId = persona.ParentId;
            } 
        }
        if (post != null && post.Provider != null) {
            newCase.Origin = post.Provider;
        }

        if (getUsingCaseAssignmentRule()){
            //Find the active assignment rules on case
            AssignmentRule[] rules = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];

            if (rules.size() > 0){
                //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId= rules[0].id;

                //Setting the DMLOption on Case instance
                newCase.setOptions(dmlOpts);
            }
        } 
        insert newCase;
        return newCase;
    }
    
    @TestVisible
    private Id getCaseRecordType(String platform){
        Map<String,Map<String, Business_Config__c>> mapBusinessLogic = moam.get('CaseDetailsForSocialStudio'); 
        if(mapBusinessLogic.isEmpty()){	
            return null;
        }
        Map <String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get('PlatformRecordTypeIdMapping');
        Id fieldValue = mapBusinessRules.get(platform).Business_Rule_Value__c;
        if(fieldValue!=null){
           return fieldValue;
        }
        else{
           return null;
        } 
    }
    
    private Case findParentCase(SocialPost post, SocialPersona persona) {
    		Case parentCase = null;
    		if (!isChat(post) && (isReplyingToOutboundPost(post) && isSocialPostRecipientSameAsPersona(post.ReplyTo, persona)) || (!isReplyingToOutboundPost(post) && isReplyingToSelf(post,persona))) { //Modify to boolen in condition
    			parentCase = findParentCaseFromPostReply(post);
    			if (isParentCaseValid(parentCase)) { 
                return parentCase;
            }
    		}
		
		parentCase = findParentCaseFromPersonaAndRecipient(post, persona);
		if (parentCase == null && isChat(post)) {
			parentCase = findParentCaseOfChatFromPersonaAndRecipient(post, persona);	
		}
		return parentCase;
    }
    
    private boolean isChat(SocialPost post) {
        return post.messageType == 'Private' || post.messageType == 'Direct';
    }
        
    private boolean isParentCaseValid(Case parentCase) {
        return parentCase != null && (!parentCase.IsClosed || caseShouldBeReopened(parentCase));
    }
    
    private Case findParentCaseFromPostReply(SocialPost post) {
        if (post.ReplyTo != null && String.isNotBlank(post.ReplyTo.ParentId)) {
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE Id = :post.ReplyTo.ParentId LIMIT 1];
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }
    
    // reply to outbound post
    private boolean isReplyingToOutboundPost(SocialPost post) {
    		return (post != null && post.ReplyTo != null && post.ReplyTo.IsOutbound);
    }
    
    // replyTo.recipient == inboundSocialPost.persona.externalId
    private boolean isSocialPostRecipientSameAsPersona(SocialPost postWithRecipient, SocialPersona persona) {
    		return (postWithRecipient != null && postWithRecipient.Recipient == persona.ExternalId);
    }
    
    // is replying to self
    private boolean isReplyingToSelf(SocialPost post, SocialPersona persona) {
    		return (post != null && 
    				persona != null && 
    				String.isNotBlank(persona.Id) && 
    				post.ReplyTo != null &&
    				String.isNotBlank(post.ReplyTo.PersonaId) &&
    				post.ReplyTo.PersonaId == persona.id);
    }
    @TestVisible
    private Case findParentCaseFromPersona(SocialPost post, SocialPersona persona) {
        SocialPost lastestInboundPostWithSamePersona = findLatestInboundPostBasedOnPersona(post, persona);
        if (lastestInboundPostWithSamePersona != null) {
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE id = :lastestInboundPostWithSamePersona.parentId LIMIT 1];
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }
    @TestVisible
    private Case findParentCaseFromPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        SocialPost lastestInboundPostWithSamePersonaAndRecipient = findLatestInboundPostBasedOnPersonaAndRecipient(post, persona);
        if (lastestInboundPostWithSamePersonaAndRecipient != null) {
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE id = :lastestInboundPostWithSamePersonaAndRecipient.parentId LIMIT 1];
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }
    @TestVisible
    private Case findParentCaseOfChatFromPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        SocialPost lastestReplyToPost = findLatestOutboundReplyToPostBasedOnPersonaAndRecipient(post, persona);
        if (lastestReplyToPost != null) {
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE id = :lastestReplyToPost.parentId LIMIT 1];
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }
    @TestVisible
    private void reopenCase(Case parentCase) { 
        SObject[] status = [SELECT MasterLabel FROM CaseStatus WHERE IsClosed = false AND IsDefault = true];
        parentCase.Status = ((CaseStatus)status[0]).MasterLabel;
        update parentCase;
    }

    private void matchPost(SocialPost post) {
        if (post.Id != null) {
                return;
        }    
        performR6PostIdCheck(post);
        
        if (post.Id == null){
            performExternalPostIdCheck(post);
        }
    }
    
    
    private void performR6PostIdCheck(SocialPost post){
        if(post.R6PostId == null) return;
        List<SocialPost> postList = [SELECT Id FROM SocialPost WHERE R6PostId = :post.R6PostId LIMIT 1];
        if (!postList.isEmpty()) {
            post.Id = postList[0].Id;
        }
    }
    
    
    private void performExternalPostIdCheck(SocialPost post) {
        if (post.provider == 'Facebook' && post.messageType == 'Private') {
            return;
        }
        if (post.provider == null || post.externalPostId == null) {
            return;
        }
        List<SocialPost> postList = [SELECT Id FROM SocialPost WHERE ExternalPostId = :post.ExternalPostId AND Provider = :post.provider LIMIT 1];
        if (!postList.isEmpty()) {
            post.Id = postList[0].Id;
        }
    }
    
    @TestVisible
    private SocialPost findReplyTo(SocialPost post, SocialPersona persona) {
        if(post.replyToId != null && post.replyTo == null){
            return findReplyToBasedOnReplyToId(post);
        }
        if(post.responseContextExternalId != null){
            if((post.provider == 'Facebook' && post.messageType == 'Private') || (post.provider == 'Twitter' && post.messageType == 'Direct')) {
                SocialPost replyTo = findReplyToBasedOnResponseContextExternalPostIdAndProvider(post);
                if(replyTo.id != null){
                    return replyTo;
                }
            }
            return findReplyToBasedOnExternalPostIdAndProvider(post);
        }
        return new SocialPost();
    }
    @TestVisible
    private SocialPost findReplyToBasedOnReplyToId(SocialPost post){
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId, Recipient FROM SocialPost WHERE id = :post.replyToId LIMIT 1];
        if(posts.isEmpty())
            return new SocialPost();
        return posts[0];
    }

    private SocialPost findReplyToBasedOnExternalPostIdAndProvider(SocialPost post){
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId, Recipient FROM SocialPost WHERE Provider = :post.provider AND ExternalPostId = :post.responseContextExternalId LIMIT 1];
        if(posts.isEmpty())
            return new SocialPost();
        return posts[0];
    }
    
    private SocialPost findReplyToBasedOnResponseContextExternalPostIdAndProvider(SocialPost post){
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId FROM SocialPost WHERE Provider = :post.provider AND Recipient = :post.Recipient AND responseContextExternalId = :post.responseContextExternalId ORDER BY posted DESC NULLS LAST LIMIT 1];
        if(posts.isEmpty())
            return new SocialPost();
        return posts[0];
    }

    private SocialPost findLatestInboundPostBasedOnPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        if (persona != null && String.isNotBlank(persona.Id) && post != null && String.isNotBlank(post.Recipient)) {
            List<SocialPost> posts = [SELECT Id, ParentId FROM SocialPost WHERE Provider = :post.provider AND Recipient = :post.Recipient AND PersonaId = :persona.id AND IsOutbound = false ORDER BY CreatedDate DESC LIMIT 1];
            if (!posts.isEmpty()) {
                return posts[0];
            }
        }
        return null;
    }
    
    private SocialPost findLatestInboundPostBasedOnPersona(SocialPost post, SocialPersona persona) {
        if (persona != null && String.isNotBlank(persona.Id) && post != null) {
            List<SocialPost> posts = [SELECT Id, ParentId FROM SocialPost WHERE Provider = :post.provider AND PersonaId = :persona.id AND IsOutbound = false ORDER BY CreatedDate DESC LIMIT 1];
            if (!posts.isEmpty()) {
                return posts[0];
            }
        }
        return null;
    }
    
    private SocialPost findLatestOutboundReplyToPostBasedOnPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        if (persona != null && String.isNotBlank(persona.Id) && post != null) {
        		List<ExternalSocialAccount> accounts = [SELECT Id FROM ExternalSocialAccount WHERE ExternalAccountId = :post.Recipient];
            if (!accounts.isEmpty()) {
            		ExternalSocialAccount account = accounts[0];
	            List<SocialPost> posts = [SELECT Id, ParentId FROM SocialPost WHERE Provider = :post.provider AND Recipient = :persona.ExternalId AND OutboundSocialAccountId = :account.Id AND IsOutbound = true ORDER BY CreatedDate DESC LIMIT 1];
	            if (!posts.isEmpty()) {
	                return posts[0];
	            }
	        }
        }
        return null;
    }
    @TestVisible
    private void matchPersona(SocialPersona persona) { 
        if (persona != null) {
            List<SocialPersona> personaList = new List<SocialPersona>();
            if (persona.Provider != 'Other') {
                if (String.isNotBlank(persona.ExternalId)) {
                    personaList = [SELECT Id, ParentId FROM SocialPersona WHERE
                        Provider = :persona.Provider AND
                        ExternalId = :persona.ExternalId LIMIT 1];
                }
                else if (String.isNotBlank(persona.Name)) {
                    //Attempt to match: persona.Name.It is not guaranteed to be unique for all networks
                    personaList = [SELECT Id, ParentId FROM SocialPersona WHERE
                        Provider = :persona.Provider AND
                        Name = :persona.Name LIMIT 1];
                }
            }
            else if(persona.Provider == 'Other' && String.isNotBlank(persona.ExternalId) && String.isNotBlank(persona.MediaProvider)) {
                personaList = [SELECT Id, ParentId FROM SocialPersona WHERE
                    MediaProvider = :persona.MediaProvider AND
                    ExternalId = :persona.ExternalId LIMIT 1];
            } else if(persona.Provider == 'Other' && String.isNotBlank(persona.Name) && String.isNotBlank(persona.MediaProvider)) {
                personaList = [SELECT Id, ParentId FROM SocialPersona WHERE
                    MediaProvider = :persona.MediaProvider AND
                    Name = :persona.Name LIMIT 1];
            }
                    
            if (!personaList.isEmpty()) {
                persona.Id = personaList[0].Id;
                persona.ParentId = personaList[0].ParentId;
            }
        }
    }

    private void createPersona(SocialPersona persona) {
        if (persona == null || String.isNotBlank(persona.Id) || !isThereEnoughInformationToCreatePersona(persona)){
            return;
        }

        SObject parent = createPersonaParent(persona);
        persona.ParentId = parent.Id; 
        insert persona;
    }

    private boolean isThereEnoughInformationToCreatePersona(SocialPersona persona) {
        return String.isNotBlank(persona.Name) && 
               String.isNotBlank(persona.Provider) && 
               String.isNotBlank(persona.MediaProvider);
    }
    
    private boolean shouldCreateCase(SocialPost post, Map<String, Object> rawData) { 
        return !isUnsentParent(rawData) && (!hasSkipCreateCaseIndicator(rawData) || hasPostTagsThatCreateCase(post));
    }
    
    private boolean isUnsentParent(Map<String, Object> rawData) {
        Object unsentParent = rawData.get('unsentParent');
        return unsentParent != null && 'true'.equalsIgnoreCase(String.valueOf(unsentParent));
    }

    private boolean hasSkipCreateCaseIndicator(Map<String, Object> rawData) {
        Object skipCreateCase = rawData.get('skipCreateCase');
        return skipCreateCase != null && 'true'.equalsIgnoreCase(String.valueOf(skipCreateCase));
    }
    @TestVisible
    private boolean hasPostTagsThatCreateCase(SocialPost post){
        Set<String> postTags = getPostTags(post);
        postTags.retainAll(getPostTagsThatCreateCase());
        return !postTags.isEmpty();
    }
    
    private Set<String> getPostTags(SocialPost post){
        Set<String> postTags = new Set<String>();
        if(post.postTags != null){
            postTags.addAll(post.postTags.split(',', 0));
        }
        return postTags;
    }

    global String getPersonaFirstName(SocialPersona persona) {
        String name = getPersonaName(persona);      
        String firstName = '';
        if (name.contains(' ')) {
            firstName = name.substringBeforeLast(' ');
        }
        firstName = firstName.abbreviate(40);
        return firstName;
    }
    
    global String getPersonaLastName(SocialPersona persona) {   
        String name = getPersonaName(persona);   
        String lastName = name;
        if (name.contains(' ')) {
            lastName = name.substringAfterLast(' ');
        }
        lastName = lastName.abbreviate(80);
        return lastName;
    }
    
    private String getPersonaName(SocialPersona persona) {
        String name = persona.Name.trim();
        if (String.isNotBlank(persona.RealName)) {
            name = persona.RealName.trim();
        }
        return name;
    }
    
    global virtual SObject createPersonaParent(SocialPersona persona) {
        String firstName = getPersonaFirstName(persona);
        String lastName = getPersonaLastName(persona);
        
        Contact contact = new Contact(LastName = lastName, FirstName = firstName);
        contact.RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Social_Contact').getRecordTypeId();
        String defaultAccountId = getDefaultAccountId();
        if (defaultAccountId != null)
            contact.AccountId = defaultAccountId;
        insert contact;
        return contact;
    }
            
    private void handlePostAttachments(SocialPost post, Map<String, Object> rawData) {
        List<PostAttachment> attachments = rawData.containsKey('attachments') ?
                                                (List<PostAttachment>) JSON.deserialize(JSON.serialize(rawData.get('attachments')), List<PostAttachment>.class) :
                                                null;
        if (attachments != null && !attachments.isEmpty()) {
            createAttachments(post, attachments);
        } else if (rawData.containsKey('mediaUrls')) {
            List<LegacyPostAttachment> legacyAttachments = (List<LegacyPostAttachment>) JSON.deserialize(JSON.serialize(rawData.get('mediaUrls')), List<LegacyPostAttachment>.class);
            if (legacyAttachments != null && !legacyAttachments.isEmpty()) {
                createLegacyAttachments(post, legacyAttachments);
            }
        }
    }
    @TestVisible
    private void createAttachments(SocialPost post, List<PostAttachment> attachments) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for(PostAttachment attachment : attachments) {
            ContentVersion contentVersion = createAttachment(attachment);
            if(contentVersion != null){
                contentVersion.Title = 'post_Attachment_'+post.ExternalPostId;
                contentVersions.add(contentVersion);
            }
        }
        
        if (!contentVersions.isEmpty()) {
	        insert(contentVersions);
	        createLinksForAttachmentsToSocialPost(post, contentVersions);
        }
    }
    
    private ContentVersion createAttachment(PostAttachment attachment){
        List<PostAttachmentFacet> facets = attachment.facets;
        if(facets != null && !facets.isEmpty()){
            facets.sort();
            for(PostAttachmentFacet facet : facets) {
                if(facet.url != null && String.isNotBlank(facet.url) && facet.url.length() <= ContentVersion.ContentUrl.getDescribe().getLength()) {
                    ContentVersion contentVersion = new ContentVersion();
                    contentVersion.contentUrl = facet.url;
                    contentVersion.contentLocation = 'L';
                    return contentVersion;
                }
            }
        }
        
        // No valid facet, fall back to embeddedUrl
        if(attachment.embeddedUrl != null && String.isNotBlank(attachment.embeddedUrl) && attachment.embeddedUrl.length() <= ContentVersion.ContentUrl.getDescribe().getLength()){
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.contentUrl = attachment.embeddedUrl;
            contentVersion.contentLocation = 'L';
            return contentVersion;
        }
        return null;
    } 
    
    @TestVisible
    private void createLinksForAttachmentsToSocialPost(SocialPost post, List<ContentVersion> contentVersions) { // test it
        List<Id> versionIds = new List<Id>(new Map<Id, ContentVersion>(contentVersions).keySet());
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId IN :versionIds];
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        for(ContentDocument contentDocument : contentDocuments) {
            ContentDocumentLink contentDocLink = new ContentDocumentLink();
            contentDocLink.contentDocumentId = contentDocument.Id;
            contentDocLink.linkedEntityId = post.Id;
            contentDocLink.shareType = 'I';
            contentDocLink.visibility = 'AllUsers';
            contentDocumentLinks.add(contentDocLink);
        }
        if (!contentDocumentLinks.isEmpty()) {
        	insert(contentDocumentLinks);
    	}
    }
    @TestVisible
    public class PostAttachment {  
        public String thumbnailUrl;
        public String embeddedUrl;
        public List<PostAttachmentFacet> facets;
        
        public PostAttachment(String mediaType, String mediaUrl, List<PostAttachmentFacet> facets) {
            this.thumbnailUrl = thumbnailUrl;
            this.embeddedUrl = embeddedUrl;
            this.facets = facets;
        }
    }
     
    public class PostAttachmentFacet implements Comparable {
        public String url;
        public String mimeType;
        
        public PostAttachmentFacet(String url, String mimeType){
            this.url = url;
            this.mimeType = mimeType;
        }
        
        public Integer compareTo(Object compareTo) {
            PostAttachmentFacet compareToFacet = (PostAttachmentFacet)compareTo;
            return getMimetypeValue(mimeType) - getMimetypeValue(compareToFacet.mimeType);
        }
        
        private Integer getMimetypeValue(String mimetype){
            final List<String> typePreference = new List<String> {'video', 'audio', 'image', 'text', 'application'};
            // Prefer known mimetype than null
            if(mimetype == null || String.isBlank(mimetype))
                return typePreference.size();
            String type = getTypeFromMimeType(mimetype);
            if(type != null && String.isNotBlank(type) && typePreference.contains(type.toLowercase())){
                return typePreference.indexOf(type);
            }
            return typePreference.size();
        }
        
        private String getTypeFromMimeType(String mimetype) {
            if(mimetype.contains('/')) {
                return mimetype.substring(0, mimetype.indexOf('/'));
            }
            return null;
        }
    } 
    @TestVisible
    private void createLegacyAttachments(SocialPost post, List<LegacyPostAttachment> attachments) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for(LegacyPostAttachment attachment : attachments) {
            if (String.isNotBlank(attachment.mediaUrl) && attachment.mediaUrl != null && attachment.mediaUrl.length() <= ContentVersion.ContentUrl.getDescribe().getLength()) {
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.contentUrl = attachment.mediaUrl;
                contentVersion.contentLocation = 'L';
                contentVersions.add(contentVersion);
            }
        }
        if (!contentVersions.isEmpty()) {
            insert(contentVersions);
            createLinksForLegacyAttachmentsToSocialPost(post, contentVersions);
        }
    }
    @TestVisible
    private void createLinksForLegacyAttachmentsToSocialPost(SocialPost post, List<ContentVersion> contentVersions) {
        List<Id> versionIds = new List<Id>(new Map<Id, ContentVersion>(contentVersions).keySet());
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId IN :versionIds];
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        for(ContentDocument contentDocument : contentDocuments) {
            ContentDocumentLink contentDocLink = new ContentDocumentLink();
            contentDocLink.contentDocumentId = contentDocument.Id;
            contentDocLink.linkedEntityId = post.Id;
            contentDocLink.shareType = 'I';
            contentDocLink.visibility = 'AllUsers';
            contentDocumentLinks.add(contentDocLink);
        }
        if (!contentDocumentLinks.isEmpty()) {
            insert(contentDocumentLinks);
        }
    }

    public class LegacyPostAttachment {
        public String mediaType;
        public String mediaUrl;
        
        public LegacyPostAttachment(String mediaType, String mediaUrl) {
            this.mediaType = mediaType;
            this.mediaUrl = mediaUrl;
        }
    }
    
}