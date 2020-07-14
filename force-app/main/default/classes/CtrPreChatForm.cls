// NOTE: most probably is deprecated, checks after de migration. Event the custom setting liveagent could be deprecated - @CreatedBy m.zeuli
public class CtrPreChatForm {
    public LiveChatTranscript pre {get;set;}
    public String Brand{get;set;}
    private List<string> picklistValues;
    public String lang{get;set;}
    public String brandImg{get;set;}

    public List<SelectOption> problems;
    
    
    public ctrPreChatForm(){
       String endpoint= ApexPages.currentPage().getParameters().get('endpoint') ;
       String buttonid=endpoint.substringafter('&button_id=');
       buttonid=buttonid.substringbefore('&session_id');
       system.debug('*endpoint'+endpoint+buttonid);
       
       LiveAgent__c LiveAgentPicklist = LiveAgent__c.getvalues(buttonid);
       picklistValues=LiveAgentPicklist.Problem__c.split(',');
       Brand= LiveAgentPicklist.Brand__c;
       lang=LiveAgentPicklist.Language__c;
       brandImg=LiveAgentPicklist.BrandImage__c;
    }
    
    public List<String> getProblems(){
        List<String> options = new List<String>();          
       for( String f : picklistValues)
       {
          options.add('"'+f+'"');
       }       
       return options;
        
    
    }
}