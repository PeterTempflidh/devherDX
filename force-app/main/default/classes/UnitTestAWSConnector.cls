/**
 * @author bigassforce
 * Amazon Web Services SDK for Salesforce Apex
 */
@IsTest class UnitTestAWSConnector {

    static testmethod void testSignedRequest() {
        //arrange
        String accessKeyId = 'ACCESS_KEY_ID';
        String secretKey = 'wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY';

        AWSConnector connector = new AWSConnector(accessKeyId, secretKey, 'iam', 'us-east-1');
        connector.now = Datetime.newInstanceGmt(2015, 08, 30, 12, 36, 00);

        String method = 'GET';
        Url endpoint = new Url('https://iam.amazonaws.com/?Action=ListUsers&Version=2010-05-08');
        Map<String, String> Headers = new Map<String, String>{
                'Content-Type' => 'application/x-www-form-urlencoded; charset=utf-8'
        };

        //act
        HttpRequest request = connector.signedRequest(method, endpoint, headers, null, null);

        //assemble
        PageReference pr = new PageReference(request.getEndpoint());
        Map<String, String> parameters = pr.getParameters();

        //assert
        System.assertEquals('341eb0c76042ef23f50a9f3f42cc12b239e7e0cd347948c032b4f3ed3b8dc4a2', parameters.get('X-Amz-Signature'), 'wrong signature');
        System.assertEquals('20150830T123600Z', parameters.get('X-Amz-Date'), 'wrong date');
        System.assertEquals('ACCESS_KEY_ID/20150830/us-east-1/iam/aws4_request', parameters.get('X-Amz-Credential'), 'wrong credential');

        String expectedSignature = '341eb0c76042ef23f50a9f3f42cc12b239e7e0cd347948c032b4f3ed3b8dc4a2';
        String actualSignature = pr.getParameters().get('X-Amz-Signature');
        System.assertEquals(expectedSignature, actualSignature, 'wrong signature');
    }

    static testmethod void testCanonicalMethodFor() {
        //act
        String canonicalMethod = AWSConnector.canonicalMethodFor('post');

        //assert
        System.assertEquals('POST', canonicalMethod, 'wrong method');
    }

    static testmethod void testCanonicalUriFor() {
        //act
        String canonicalUri = AWSConnector.canonicalUriFor('https://localhost/foobar/baz');

        //assert
        System.assertEquals('/foobar/baz', canonicalUri, 'wrong uri');
    }

    static testmethod void testCanonicalQueryStringFor() {
        //arrange
        Map<String, String> parameters = new Map<String, String>{
                'zed' => '/home/home.jsp',
                'aye' => 'herp~derp'
        };

        //act
        String canonicalQueryString = AWSConnector.canonicalQueryStringFor(parameters);

        //assert
        System.assertEquals('aye=herp~derp&zed=%2Fhome%2Fhome.jsp', canonicalQueryString, 'wrong query');
    }

    static testmethod void testCanonicalHeadersFor() {
        //arrange
        Map<String, String> headers = new Map<String, String>{
                'X-Random' => 'test',
                'accept' => '*/*',
                'HOST' => 'localhost'
        };

        //act
        String canonicalHeaders = AWSConnector.canonicalHeadersFor(headers);

        //assert
        System.assertEquals('accept:*/*\nhost:localhost\nx-random:test\n', canonicalHeaders, 'wrong headers');
    }

    static testmethod void testSignedHeadersFor() {
        //arrange
        Map<String, String> headers = new Map<String, String>{
                'X-Random' => 'test',
                'accept' => '*/*',
                'HOST' => 'localhost'
        };

        //act
        String signedHeaders = AWSConnector.signedHeadersFor(headers);

        //assert
        System.assertEquals('accept;host;x-random', signedHeaders, 'wrong signed');
    }

    static testmethod void testHexEncodedHash() {
        //act
        String hexEncodedHash = AWSConnector.hexEncodedHashFor(Blob.valueOf(''));

        //assert
        System.assertEquals('e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', hexEncodedHash, 'wrong hash');
    }

    static testmethod void testRfc3986For() {
        //act
        String rfc3986 = AWSConnector.rfc3986For('/path with spaces', false);

        //assert
        System.assertEquals('/path%20with%20spaces', rfc3986, 'wrong rfc');
    }
}