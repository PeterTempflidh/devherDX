@isTest
private class TwilioAccessTokenTest {
	
	@isTest static String getCapabilityToken() {		
		// Mock setup for Video capability Token
		string AccountSid = 'AC000000000000000000000000000000000';
		string SigningKeySid = 'SK000000000000000000000000000000000';
		string SigningKeySecret = '00000000000000000000000000000000';

		TwilioAccessToken token = new TwilioAccessToken(SigningKeySid, AccountSid, SigningKeySecret);
		token.AddGrant(new TwilioEndpointGrant('user'));
		token.EnableNTS();
		return token.ToJWT();
	}
}