/***********************************************************************
**	Name: UnitTestClsEmailReply
**  
**  Purpose: Purpose of this class is testing class called ClsEmailReply
**
**  Author: Rijad Halidovic
**
**  Date Created: 06.01.2015.
**
**  Modification History/Comments:
**
************************************************************************/

@isTest
private class UnitTestClsEmailReply {

	private static Country__c testCountry;
	private static List<Account> accounts;
	private static List<Opportunity> opportunities;
	private static String ex;
       private static User testUser;

	static {
              testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'yogiyouser@deliveryhero.com', 'Yogiyo', 'KR');
       insert testUser;
		UnitTestDataFactory.getRecordtypeValues();
		testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
	    insert testCountry;	        
	    accounts = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
	    insert accounts;	        
	    opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'Yogiyo_Opportunity', Date.today().addMonths(2));
           opportunities[0].OwnerId = testUser.Id;
	    insert opportunities;

            Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='QuoteReplyStage',Business_Rule_Value__c='Documents Received',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='OppQuoteProcess',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
            Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='minProbability',Business_Rule_Value__c='60',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='OppQuoteProcess',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
            Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='stagesToIgnore',Business_Rule_Value__c='Please Check',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='OppQuoteProcess',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
            Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='probability',Business_Rule_Value__c='65',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='OppQuoteProcess',Record_Type_Id__c='Yogiyo_Account',Type__c='Process');
            insert new List<Business_Config__c>{b1,b2,b3,b4};
	}

	/// <name> Test_EmailReply </name>
	/// <summary> Testing email reply handleInboundEmail method </summary>
	static testMethod void Test_EmailReply() {	
		ex = '';	
		
		// Create a new email and envelope object.
       	Messaging.InboundEmail email = new Messaging.InboundEmail() ;
       	Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

       	// Test with the reference id stored in body
       	email.subject = 'email reply to salesforce';
       	email.plainTextBody = '(REF: #' + opportunities[0].Id + '.' + opportunities[0].OwnerId + '#)';
               // add an Binary attachment
             Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
             attachment.body = blob.valueOf('my attachment text');
             attachment.fileName = 'textfileone.txt';
             attachment.mimeTypeSubType = 'text/plain';
             email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
             
       	env.fromAddress = 'user@acme.com';
       
       	// Call the class and test it with the data in the testMethod.
       	// Catch exception
		ClsEmailReply emailReply = new ClsEmailReply();
       	try {
       		emailReply.handleInboundEmail(email, env );
       	}
       	catch(Exception e) {
       		ex = e.getMessage();

                     // No exception
                     System.assert(ex.length() == 0);
       	}

       	// Test if new Task (Activity) was created
       	List<Task> listTsk = [select id from Task where whatId = :opportunities[0].Id];
       	System.assertEquals(listTsk.size(), 1);
	
       }

              /// <name> Test_EmailReply </name>
       /// <summary> Testing email reply handleInboundEmail method </summary>
       static testMethod void Test_EmailReply_Q() {       
              ex = '';      
              
              // Create a new email and envelope object.
              Messaging.InboundEmail email = new Messaging.InboundEmail() ;
              Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

              // Test with the reference id stored in body
              email.subject = 'email reply to salesforce';
              email.plainTextBody = '(REFQ: #' + opportunities[0].Id + '.' + opportunities[0].OwnerId + '#)';
               // add an Binary attachment
             Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
             attachment.body = blob.valueOf('my attachment text');
             attachment.fileName = 'textfileone.txt';
             attachment.mimeTypeSubType = 'text/plain';
             email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
             
              env.fromAddress = 'user@acme.com';
       
              // Call the class and test it with the data in the testMethod.
              // Catch exception
              ClsEmailReply emailReply = new ClsEmailReply();
              try {
                     emailReply.handleInboundEmail(email, env );
              }
              catch(Exception e) {
                     ex = e.getMessage();

                     // No exception
                     System.assert(ex.length() == 0);
              }

              // Test if new Task (Activity) was created
              List<Task> listTsk = [select id from Task where whatId = :opportunities[0].Id];
              System.assertEquals(listTsk.size(), 1);
       
       }

       /// <name> Test_EmailReply </name>
       /// <summary> Testing email reply handleInboundEmail method </summary>
       static testMethod void Test_EmailReply_Q_NOAt() {       
              ex = '';      
              
              // Create a new email and envelope object.
              Messaging.InboundEmail email = new Messaging.InboundEmail() ;
              Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

              // Test with the reference id stored in body
              email.subject = 'email reply to salesforce';
              email.plainTextBody = '(REFQ: #' + opportunities[0].Id + '.' + opportunities[0].OwnerId + '#)';
             
              env.fromAddress = 'user@acme.com';
       
              // Call the class and test it with the data in the testMethod.
              // Catch exception
              ClsEmailReply emailReply = new ClsEmailReply();
              try {
                     emailReply.handleInboundEmail(email, env );
              }
              catch(Exception e) {
                     ex = e.getMessage();

                     // No exception
                     System.assert(ex.length() == 0);
              }

              // Test if new Task (Activity) was created
              List<Task> listTsk = [select id from Task where whatId = :opportunities[0].Id];
              System.assertEquals(listTsk.size(), 1);
       
       }
    

	/// <name> Test_EmailReply_Exception </name>
	/// <summary> Testing email reply handleInboundEmail method when exception occures </summary>
	static testMethod void Test_EmailReply_Exception() {
		ex = '';

		// Create a new email and envelope object.
       	Messaging.InboundEmail email = new Messaging.InboundEmail() ;
       	Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       
       	// Test with the reference id stored in body
       	email.subject = 'email reply to salesforce';
       	email.plainTextBody = '(REF: ' + opportunities[0].Name + ')';
       	env.fromAddress = 'user@acme.com';
       
       	// Call the class and test it with the data in the testMethod.
       	ClsEmailReply emailReply = new ClsEmailReply();
       	try {
       		emailReply.handleInboundEmail(email, env );
       	}
       	catch(Exception e) {
       		ex = e.getMessage();

                     // Exception occured
                     System.assert(ex.length() > 0);
       	}

              // Test if new Task (Activity) was created
              List<Task> listTsk = [select id from Task where whatId = :accounts[0].Id];
              System.assertEquals(listTsk.size(), 0);
	}
}