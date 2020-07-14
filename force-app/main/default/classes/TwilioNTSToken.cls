/**
 * The class TwilioNTSToken.
 * 
 * For more information see https://www.twilio.com/docs/api/rest/message
 */
public class TwilioNTSToken {

	private Map<String, Object> properties;
	public String iceServers {get;set;}
    /**
     * Instantiates a new TwilioNTSToken.
     *
     * @param client the client
     */
    public TwilioNTSToken(TwilioRestResponse response) {
		Map<String, Object> properties = response.toMap();
		this.properties = new Map<String, Object>(properties);
		 List<Object> ice_servers = (List<Object>)getObject('ice_servers');
		 iceServers = JSON.serialize(ice_servers);
    }


	/**
	 * Gets the property.
	 *
	 * @param name the name
	 * @return the property, 
	 * or null if it doesn't exist or is NULL in the response
	 */
	public String getProperty(String name) {
		Object prop = properties.get(name);

		prop = properties.get(name);

		if (prop == null) {
			return null;
		}

		if (prop instanceof String) {
			return (String) prop;
		}


		throw new TwilioRestException('Property ' + name
				+ ' is an object.  Use getObject() instead.');
	}

	private Object getObject(String name) {
		Object prop = properties.get(name);
	
		prop = properties.get(name);
		
		if (prop == null) {
			throw new TwilioRestException('Property ' + name
					+ ' does not exist');
		}
		return prop;
	}

    /*
     * Property getters
     */
    /**
     * Gets the sid.
     *
     * @return the sid
     */
    public String getUserName() {
        return this.getProperty('username');
    }
    
    /* DateCreated field accessor */
    public String getPassword() {
        return this.getProperty('password');
    }

    /* DateUpdated field accessor */
    public String getTTL() {
        return this.getProperty('ttl');
    }
    
    
    /**
     * Gets the account sid.
     *
     * @return the account sid
     */
    public String getAccountSid() {
        return this.getProperty('account_sid');
    }
}