public class TwilioRestGrant extends TwilioGrant
{
    public static String GET = 'GET';
    public static String POST = 'POST';
    public static String TO_DELETE = 'DELETE';
    public static String PUT = 'PUT';
	public static String ALL = '*';


    public TwilioRestGrant(string resource, string action) {
    	super(resource, new List<String>{ action });
    }
}