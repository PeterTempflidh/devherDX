public virtual class TwilioGrant {
	public static string ALL = '*';

    /// <summary>
    /// The fully-qualified URL of the resource on which this Grant authorizes actions.
    /// May contain wildcards to authorize access to multiple resources matching a pattern:
    /// 
    /// "*" as a URL component matches any single path element; e.g. "https://api.twilio.com/2010-04-01/Accounts/*"
    /// authorizes access to all Account resources
    /// "**" as a URL component matches all following path elements; e.g. "https://api.twilio.com/2010-04-01/Accounts/AC123/**"
    /// authorizes access to all resources owned by Account AC123.
    /// </summary>
    public string Resource { get; set; }
    /// <summary>
    /// A list of actions authorized by this grant over the specified resources.
    /// For REST resources, this may include the four HTTP verbs "GET", "POST", "PUT", and "DELETE";
    /// for other Twilio features this may include other action specifiers.
    /// The special value "*" allows all possible actions over the corresponding resources.
    /// </summary>
    public List<string> Actions { get; set; }

    public TwilioGrant(string resource, List<string> actions)
    {
        this.resource = resource;
        this.actions = actions;
    }

    public Map<string, object> ToDict()
    {
        Map<String, Object> dict = new Map<String, Object>();
        dict.put('res', Resource);
        dict.put('act', Actions);
        return dict;
    }
}