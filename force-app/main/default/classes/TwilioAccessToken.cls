public with sharing class TwilioAccessToken {
       
        static Integer DEFAULT_TTL = 3600;

        String signingKeySid { get; set; }
        String accountSid { get; set; }
        String secret { get; set; }
        Integer ttl { get; set; }
        List<TwilioGrant> grants { get; set; }

    public TwilioAccessToken(String signingKeySid, String accountSid, String secret) {
        this(signingKeySid, accountSid, secret, DEFAULT_TTL);
    }

    public TwilioAccessToken(String signingKeySid, String accountSid, String secret, Integer ttl)
    {
        this.signingKeySid = signingKeySid;
        this.accountSid = accountSid;
        this.secret = secret;
        this.ttl = ttl;
        this.grants = new List<TwilioGrant> ();
    }

    /// <summary>
    /// Add a Grant to this AccessToken.
    /// </summary>
    /// <param name="grant">The grant to add</param>
    /// <returns>AccessToken</returns>
    public TwilioAccessToken AddGrant(TwilioGrant grant) 
    {
        Grants.add(grant);
        return this;
    }

    /// <summary>
    /// Add a EndpointGrant to the AccessToken
    /// </summary>
    /// <returns>AccessToken</returns>
    /// <param name="endpointGrant">Endpoint grant.</param>
    public TwilioAccessToken AddGrant(TwilioEndpointGrant endpointGrant)
    {
        TwilioGrant grant = new TwilioGrant(String.format('sip:{0}@{1}.endpoint.twilio.com',  new String[]{endpointGrant.Resource, AccountSid}), endpointGrant.Actions);
        return this.AddGrant(grant);
    }

    /// <summary>
    /// Add a RestGrant to the AccessToken
    /// </summary>
    /// <returns>AccessToken</returns>
    /// <param name="restGrant">Rest grant.</param>
    public TwilioAccessToken AddGrant(TwilioRestGrant restGrant)
    {
        TwilioGrant grant = new TwilioGrant(String.format('https://api.twilio.com/2010-04-01/Accounts/{0}/{1}', new String[]{AccountSid, restGrant.Resource.replaceFirst('/', '')}), restGrant.Actions);
        return this.AddGrant(grant);
    }

    /// <summary>
    /// Enables the Network Traversal Service for this AccessToken
    /// </summary>
    /// <returns>AccessToken</returns>
    public TwilioAccessToken EnableNTS()
    {
        TwilioRestGrant grant = new TwilioRestGrant('/Tokens.json', TwilioRestGrant.POST);
        return this.AddGrant(grant);
    }

    /// <summary>
    /// Generate a JWT with the provided information and sign it with the given secret.
    /// </summary>
    /// <param name="secret">The secret to sign the token with</param>
    /// <returns>Signed JWT authorizing the grants configured on this object</returns>
    public string ToJWT()
    {
        Map<String, Object> payload = new Map<string, Object>();
        payload.put('jti', String.format('{0}-{1}', new String[]{SigningKeySid, String.valueOf(System.currentTimeMillis()/1000)}));
        payload.put('iss', SigningKeySid);
        payload.put('sub', AccountSid);
        payload.put('nbf', Integer.valueOf(System.currentTimeMillis()/1000));
        payload.put('exp', Integer.valueOf(System.currentTimeMillis()/1000 + ttl));
        List<Map<String, Object>> newGrants = new List<Map<String, Object>>();
        for( TwilioGrant g : this.grants)  {
            newGrants.add(g.ToDict());
        }
        payload.put('grants', newGrants);
       
        return jwtEncode(payload, secret);
    }

    /**
     * Construct JWT token consisting of header, payload, and signature
     *
     * See http://self-issued.info/docs/draft-jones-json-web-token.html
     */
    private static String jwtEncode(Map<String, Object> payload, String key) {
        Map<String, Object> header = new Map<String, Object>();
        header.put('cty', 'twilio-sat;v=1');
        header.put('typ', 'JWT');
        header.put('alg', 'HS256');

        List<String> segments = new List<String>();
        segments.add(urlSafeEncodeBase64(JSON.serialize(header)));
        segments.add(urlSafeEncodeBase64(JSON.serialize(payload)));

        String signature = sign(join(segments, '.'), key);
        segments.add(signature);

        return join(segments, '.');
    }

    private static String urlSafeEncodeBase64(String data) {
        return urlSafeEncodeBase64(Blob.valueOf(data));
    }

    private static String urlSafeEncodeBase64(Blob data) {
        String encodedString = EncodingUtil.base64Encode(data);
        return encodedString.replace('+','-').replace('/','_').replace('=', ''); // make URL-safe
    }
    
    /**
     * Construct a String containing the contents of 'vals' separated by 'sep'
     */
    private static String join(List<String> vals, String sep) {
        String sb = '';
        for (Iterator<String> it=vals.iterator(); it.hasNext(); ) {
            String value = it.next();
            if (sb.length() != 0)
                sb += sep;
            sb += value;
        }
        return sb;
    }

   /**
     * Generate a signature for the token
     *
     * See http://self-issued.info/docs/draft-jones-json-web-signature.html
     *   and http://discussion.forum.nokia.com/forum/showthread.php?130974-Help-required-How-to-generate-a-MAC-(HMAC-SHA1)-with-Java
     */
    private static String sign(String data, String key) {
        Blob mac = Crypto.generateMac('hmacSHA256', Blob.valueOf(data), Blob.valueOf(key));
        String result = urlSafeEncodeBase64(mac);
        return result;
    }    
}