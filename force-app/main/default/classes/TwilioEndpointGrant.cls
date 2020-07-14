public class TwilioEndpointGrant extends TwilioGrant 
{
    public static String CLIENT_LISTEN = 'listen';
    public static String CLIENT_INVITE = 'invite';
    
    public TwilioEndpointGrant(string endpoint, List<String> grants) {
    	super(endpoint, grants);
    }

    public TwilioEndpointGrant(string endpoint) {
    	this(endpoint, new List<String>{CLIENT_LISTEN, CLIENT_INVITE});
    }
}