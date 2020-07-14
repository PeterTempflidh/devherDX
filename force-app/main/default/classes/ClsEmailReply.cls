/***************************************************************************************
**	Name: ClsEmailReply
**  
**  Purpose: Global class used to create a task from inbounb email 
**           based on the reference id hidden in it's body.
**
**  Author: Rijad Halidovic
**
**  Date Created: 04.01.2016.
**
**  Modification History/Comments:
**     - Rijad Halidovic / 13.01.2016. / code refactoring + creating attachments
**
****************************************************************************************/

global class ClsEmailReply implements Messaging.InboundEmailHandler {
	public List<Task> listOfTasks = new List<Task>();
	public List<Attachment> listOfAttachments = new List<Attachment>();
	public Boolean isQuote = false;

	// global class that handles Inbound Messages. Main purpose is to create
	//		  a task based on the reference id that is hidden in email's body
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {

    	Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
    	String referenceId = getReferenceIdFromEmail(email.plainTextBody);
    	String ownerId = getOwnerIdFromEmail(email.plainTextBody);

    	if(referenceId.length() == 0)
    		return result;

    	Task createdTask = createTaskFromEmail(email.plainTextBody, email.subject, referenceId, ownerId);  	
	   	result.success = true;

	   	if(listOfTasks.size() > 0)
	   		insert listOfTasks;

	   	if(email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
    		Id parent = isQuote ? referenceId : createdTask.Id;
    		createAttachmentsForTask(parent, email.binaryAttachments, ownerId);
	   	}
    		
	   	if(listOfAttachments.size() > 0) {
	   		insert listOfAttachments;
		   	
	   	}
	   	if(isQuote) {
		   		changeOpportuntiyStage(referenceId);
		}
	   	
	   	return result;
	}
	
	//  Filters out the hidden reference id from the email's body and 
	//           returns it as a String value.
	public String getReferenceIdFromEmail(String emailBody) {
    	String getRef = emailBody.substringBetween('(REF: #', '#)');
    	if(getRef == null) {
    		getRef = emailBody.substringBetween('(REFQ: #', '#)');
    		isQuote = true;
    	}
		if(getRef.length() <= 1)
    		return '';
  	
    	return getRef.subStringBefore('.');
	}

	// Filters out the hidden owner id from the email's body and 
	//           returns it as a String value.
	public String getOwnerIdFromEmail(String emailBody) {
    	String getRef = emailBody.substringBetween('(REF: #', '#)');
    	if(getRef == null)
    		getRef = emailBody.substringBetween('(REFQ: #', '#)');
		if(getRef.length() <= 1)
    		return '';

    	return getRef.substringAfter('.');
	}


	// Create a task from received inbound email
	public Task createTaskFromEmail(String emailBody, String emailSubject, String referenceId, String ownerId) {
    	Task newTask = new Task(
	     	Description =  emailBody,
	      	ActivityDate = Date.today(),
	        Priority = 'Normal',
	        Status = 'Completed',
	        Subject = 'Email: ' + emailSubject,
	        WhatId =  referenceId,
	        //TaskSubtype = 'Email',
	        Type = 'Email'
	    );

    	if(ownerId.length() > 0)
	    	newTask.OwnerId = ownerId;
	    listOfTasks.add(newTask);

	   	return newTask;
	}

  	// Creates attachment that will be added to the newly created Task
    public void createAttachmentsForTask(Id taskId, Messaging.InboundEmail.BinaryAttachment[] attachments, String ownerId){
    	//List<Attachment> insertAttachments = new List<Attachment>();
    	if(taskId != null || taskId != '') {
	       	for(Messaging.InboundEmail.BinaryAttachment binAtt : attachments){ 
	        	Attachment newAttachment = new Attachment();
	        	newAttachment.ParentId = taskId;
	            newAttachment.Name = binAtt.fileName;
	            newAttachment.Body = binAtt.body;
	            if(ownerId.length() > 0)
	    			newAttachment.OwnerId = ownerId;
	           	listOfAttachments.add(newAttachment);
	        }   
	    } 
    }

  	/**
  	* @Description: This method updates the opportunity stage when the email is received 
  					Also checks for the probability and the stage of the opp
  	*/
    public void changeOpportuntiyStage(String referenceId) {
    	// Check if referenceid is opportunity id
    	Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    	Map<String, Map<String, Business_Config__c>> mapBusinessLogic 	= moam.get('OppQuoteProcess');
    	
    	if(mapBusinessLogic == null)
    		return;
    	
    	List<Opportunity> updateOpp 									= new List<Opportunity>();
    	List<Opportunity> opps 		= [SELECT AccountId,account.recordtype.developerName, StageName, Probability, 
    										  RecordType.DeveloperName,Owner.firstName,Owner.Email
    								 	FROM Opportunity 
    								 	WHERE Id = :referenceId];
    								 			
    	if(opps.size() == 0)
    		return;
    	
    	Opportunity opp = opps[0];  	
    	
		Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(opp.account.RecordType.DeveloperName);
		if(mapBusinessRules == null)
			return;
		
		if(mapBusinessRules.get('minProbability') == null	||
			mapBusinessRules.get('stagesToIgnore') == null 	||
			mapBusinessRules.get('QuoteReplyStage') == null	||
			mapBusinessRules.get('probability') == null)
			return;
		
		/* send notifications to the opportunity owners if the opportunity is in the later stage or in error stage
			that the feedback is received on the opportunity*/
		if(opp.Probability > Integer.valueOf(mapBusinessRules.get('minProbability').Business_Rule_Value__c)){
			sendEmailNotification(opp,'Feedback_Received');
			return; 
		}
		List<String> invalidStages = mapBusinessRules.get('stagesToIgnore').Business_Rule_Value__c.split(',');
		if(invalidStages.contains(opp.stageName)){
			sendEmailNotification(opp,'Feedback_Received');
			return;
		}
		opp.StageName 	= mapBusinessRules.get('QuoteReplyStage').Business_Rule_Value__c;
		opp.Probability = Integer.valueOf(mapBusinessRules.get('probability').Business_Rule_Value__c);
		update opp;
 
    }
    
    /**
      @Description: This method sends email notifications to the opportunity owners that the feedback has been received 
    				to the opportunity
    */
    public static void sendEmailNotification(Opportunity opp,String templateName){
    	List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
    	List<EmailTemplate> template = [SELECT Id,Subject,HtmlValue
    					 					FROM EmailTemplate 
    					 					where developerName =: templateName];
    	
    	if(template.size() == 0){
    		system.debug('No Email Template found');
    		return;
    	}
		
		// populate the body
		String body = template[0].htmlValue;
		body		= body.replaceAll('@INSTANCE',URL.getSalesforceBaseURL().toExternalForm());
		body		= body.replaceAll('@FIRSTNAME',opp.Owner.firstName);
		body		= body.replaceAll('@OPPORTUNITYID',opp.Id);
		
		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		// Add the oportunity owner to the to address
		message.setToAddresses(new List<String>{opp.Owner.Email});
		message.setSubject(template[0].subject);
		message.setHtmlBody(body);
		message.setSaveAsActivity(false);
		message.setUseSignature(false);
		emailMessages.add(message);
    	
    	Messaging.SendEmailResult[] results = Messaging.sendEmail(emailMessages);
		
		if (!results[0].success){
		    System.debug('The email failed to send: '+ results[0].errors[0].message);
		}		         
    }
    
}