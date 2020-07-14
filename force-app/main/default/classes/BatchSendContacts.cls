global class BatchSendContacts implements Database.Batchable<sObject>, Database.AllowsCallouts {
     Integration_Config__c intConfig;

    
    global BatchSendContacts(){
         intConfig = Integration_Config__c.getValues('United Kingdom');
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([select id, firstname,lastname,Contact_Role__c,email,MobilePhone,Account.Backend_ID__c,salutation from contact where recordtype.developername='UK_Contact' and backend_sync__C=false  and email!=null and Account.Backend_ID__c!=null and createddate=today]);
    } 

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<contact> conLst =(List<contact>)scope;
        List<contact> conToUpdLst = new List<contact>();
         String sEndPoint =  intConfig.endpoint__c+'add-contacts';
         Blob headerValue = Blob.valueOf(intConfig.username__c + ':' + intConfig.password__c );
        String authorizationHeader = 'Basic ' +EncodingUtil.base64Encode(headerValue);
        Map<string,contact> backendContactMap = new Map<string,contact>();
        String jsonBdy ='[';
        for(Contact c: conLst){
            backendContactMap.put(c.account.backend_id__C,c);
            jsonBdy += '{"restaurant_id":'+c.Account.Backend_ID__c+',"surname":"'+c.lastname+'","email":"'+c.email+'","position":"'+c.Contact_Role__c+'"';
            if(c.MobilePhone!=null){
                String mob = c.mobilePhone.removeStart('0044');
                mob='0'+mob;
                if(mob.length()==11)
                    jsonBdy += ',"mobile":"'+mob+'"';
            } 
            if(c.firstname!=null) 
                jsonBdy += ',"first_name":"'+c.firstname+'"';

            if(c.salutation!=null)
                jsonBdy +=',"title":"'+c.salutation+'"';
          
          
            jsonBdy += '},';
        }
        String body = jsonBdy.removeEnd(',')+']';
        system.debug('**body'+body );
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();      
        Http http = new Http();
        req.setEndpoint(sEndPoint);
        req.setMethod('POST');
        req.setHeader('Authorization',authorizationHeader);
        req.setBody(body);
        try{
            integer i=0;
            res = http.send(req);
            if(res.getStatusCode()==207 ) {
                JSONParser parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                        while (parser.nextToken() != null) {
                            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                 ClsRoganAddContactResponseWrapper result = (ClsRoganAddContactResponseWrapper)parser.readValueAs(ClsRoganAddContactResponseWrapper.class);
                                if(result.success){
                                    
                                   conLst[i].backend_sync__c=true; 
                                   conToUpdLst.add(conLst[i]);
                                   i++;  
                                }
                                else 
                                    i++;
                            }
                        }
                    }
                }
            }
        }catch(Exception e){
            system.debug(e.getMessage());
        }
          system.debug(conToUpdLst);
        update conToUpdLst;
        
        }

    
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}