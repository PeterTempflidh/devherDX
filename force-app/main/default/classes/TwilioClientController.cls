global class TwilioClientController {
       
        private TwilioCapability capability;
        public String uname {get; set;}
        public static TwilioRestClient client = TwilioAPI.getDefaultClient();
        
        //****** Initalizer - Set up Twilio Capability Token - requires ApplicationSid__c to be set
        global TwilioClientController() {
            capability = TwilioAPI.createCapability();
            capability.allowClientOutgoing(
                TwilioAPI.getTwilioConfig().ApplicationSid__c,null);
                capability.allowClientIncoming('salesforce_agent');

            //client = TwilioAPI.getDefaultClient();
        }
        
        //******* {!Token} method returns a string based capability token
        public String getToken() { return capability.generateToken(7200); }
        
        //******* Pass in a parameter PhoneNumber - and this will Dial the phone number
        public String getDial() {
            try{
                String callerid = TwilioAPI.getTwilioConfig().CallerId__c;        
                //phone number will be passed as http query parameter
                String PhoneNumber = System.currentPageReference().getParameters().get('PhoneNumber');
                TwilioTwiML.Response res = new TwilioTwiML.Response();
                System.debug('res: '+res);
                TwilioTwiML.Dial d = new TwilioTwiML.Dial(PhoneNumber);
                d.setCallerId(callerid);
                res.append(d);
                return res.toXML();
            }catch(Exception e){
                System.debug('Error: '+e.getMessage());
                ClsLogErrorMessage.logMessages('Twilio','getDial Method:'+e.getMessage()+e.getStackTraceString());
                return 'Error: at getDial Method:'+e.getMessage();
            }
            
        }

        @RemoteAction
        global static String getCallDuration(String callsid){
            try{
                TwilioCall call = client.getAccount().getCall(callsid);
                System.debug('call duration: '+call.getDuration());
                return ''+call.getDuration();
            }catch(Exception e){
                System.debug('erroe: '+e.getMessage());
                ClsLogErrorMessage.logMessages('Twilio','getCallDuration: '+ e.getMessage()+e.getStackTraceString());
                return 'Error: at getCallDuration'+e.getMessage();
            }
        }

        @RemoteAction
        global static String saveTask(Task taskObj){
            try{
                //Task taskObj = (Task) t;
                System.debug('taskObj: '+taskObj);
                /*Task t = new Task();
                if(params!=null && params.length()>1){
                    if(params.indexOf('&')>0){
                        for(String ss : params.split('&')){
                            if(ss.indexOf('=')>0){
                                List<String> fieldvalue = ss.split('=');
                                t.put(fieldvalue[0],fieldvalue[1]);
                            }
                        }
                        t.Activitydate = Date.today();
                        insert t;
                        return ''+t.Id;
                    }else{
                        System.debug('Error: parameter null for task creation');
                        return 'Error: no data available for creating task'; 
                    }*/
                if(taskObj!=null && taskObj.Subject!=null){
                    taskObj.Activitydate = Date.today();
                    taskObj.CallDurationInSeconds = Integer.valueOf(taskObj.CallDurationInSeconds);
                    if(taskObj.Id==null){
                        insert taskObj;
                    }else{
                        update taskObj;
                    }
                    return taskObj.Id;
                }else{
                    System.debug('Error: parameter null for task creation');
                    ClsLogErrorMessage.logMessages('Twilio', 'Error: parameter null for task creation');
                    return 'Error: no data available for creating task';  
                }
            }catch(Exception e){
                System.debug('error: '+e.getMessage());
                ClsLogErrorMessage.logMessages('Twilio', e.getMessage()+e.getStackTraceString()+' :: '+taskObj);
                return 'Error: '+e.getMessage();
            }
        }
    }