/*
@author : Alexander Faust
@reviewer : 
@creation : 05.12.2014
@notes : tests LibWebserviceHelper aswell
*/
@isTest
private class UnitTestMigrationScriptHTTP {

	static final String consumerKey = '3MVG9WtWSKUDG.x5gl5J_PPwNGONQPPY_1DEhdPC3ePgfykbw6KsZuzWxCixsWQ9HZLRwDp72IU6Tz2mZSDVm';
	static final String consumerSecret = '2371138857444993287';
	static final String userName = 'john.doe@email.com';
	static final String password = 'thisismypassword';

	static final String templateAccessToken = '00D20000000CSSJ!AQgAQObGOGWNPpphCHmcemTKudhCRCc43KWE2xsxcE8WEJrNrbyObFoBI92OOfWT3ya37EV67XskPdL.jAVuUWtmufLBWJ.J';
	static final String templateInstanceURL = 'https://emea.salesforce.com';
	
	@isTest static void test_method_one() {

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());

		MigrationScriptHTTP m = new MigrationScriptHTTP();
		m.authenticateByUsernamePassword(consumerKey,consumerSecret,userName,password);
		String query = 'SELECT Id,Name FROM Account WHERE Name = \'Pizzeria CC Test Einzelunternehmen\'';

		List<sObject> listQueryResult = m.doSOQLQuery(query);
		Account queryAccount = (Account)listQueryResult[0];

		Test.stopTest();

		System.assertEquals(templateAccessToken,m.accessToken);
		System.assertEquals(templateInstanceURL,m.instanceURL);
		System.assertEquals(1,listQueryResult.size());
		System.assertEquals('Pizzeria CC Test Einzelunternehmen',queryAccount.Name);


	}
	
}