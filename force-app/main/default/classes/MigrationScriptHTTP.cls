public with sharing class MigrationScriptHTTP {

	public String accessToken{get;private set;}
	public String instanceURL{get;private set;}


	public MigrationScriptHTTP() {
		
	}


	private HttpResponse send(String uri, String httpMethod){
		return send(uri,httpMethod,null);
	}

	private HttpResponse send(String uri, String httpMethod, String body){
		Http h = new Http();
		HttpRequest hRqst = new HttpRequest();

		hRqst.setEndpoint(uri);
		hRqst.setMethod(httpMethod);
		hRqst.setTimeout(6000); // really needed? ->Check

		if(body != null){
			hRqst.setBody(body);
		}

		if(this.accessToken != null){
			hRqst.setHeader('Authorization', 'Bearer ' + this.accessToken);
		}

		return h.send(hRqst);

	}


	public void authenticateByUsernamePassword(String consumerKey,
											   String consumerSecret,
											   String uName,
											   String uPassword){

		String uri = 'https://login.salesforce.com/services/oauth2/token';

		String clientId = EncodingUtil.urlEncode(consumerKey, 'UTF-8');
		String clientSecret = EncodingUtil.urlEncode(consumerSecret, 'UTF-8');
		String userName = EncodingUtil.urlEncode(uName, 'UTF-8');
		String password = EncodingUtil.urlEncode(uPassword, 'UTF-8');

		String body = 'grant_type=password&client_id=' + clientId +
					  '&client_secret=' +clientSecret + 
					  '&username=' + username + 
					  '&password=' + password;


		HttpResponse res = this.send(uri,'POST',body);

		//if(res.getStatusCode() != 200){
			System.debug('Response :' + res.getBody());
		//}

		Map<String,String> mapResponse = (Map<String,String>) JSON.deserialize(res.getBody(), Map<String,String>.class);

		this.accessToken = mapResponse.get('access_token');
		this.instanceURL = mapResponse.get('instance_url');



	}

	public List<sObject> doSOQLQuery(String query){
		List<sObject> listResponse;

		PageReference urlPageRef = new PageReference(this.instanceURL + '/services/data/v29.0/query');
		urlPageRef.getParameters().put('q',query);

		String uri = urlPageRef.getUrl();

		HttpResponse httpRes = this.send(uri,'GET');

		if(httpRes.getStatusCode() == 200){
			System.debug('queryResponse: ' + httpRes.getBody());
			JSONParser parser = JSON.createParser(httpRes.getBody());

			do{
				parser.nextToken();
			}while(parser.hasCurrentToken() && !'records'.equals(parser.getCurrentName()));
			parser.nextToken();

			listResponse = (List<sObject>) parser.readValueAs(List<sObject>.class);

		}


		return listResponse;

	}
}