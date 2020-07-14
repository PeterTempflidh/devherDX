global class BatchSendAddPricePlanToRogan implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    String query;
    Integration_Config__c intConfig;
    
    global BatchSendAddPricePlanToRogan() {
        intConfig = Integration_Config__c.getValues('United Kingdom');
        query = 'SELECT Id, StartDate, Commission__c, Id_Opportunity_Quote_Line_Item__r.Name, Account.Backend_ID__c  FROM Contract WHERE RecordType.DeveloperName=\'UK_Contract\' and Status=\'Draft\'';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        String sEndPoint =  intConfig.endpoint__c+'add-priceplan';
        Blob headerValue = Blob.valueOf(intConfig.username__c + ':' + intConfig.password__c );
        String authorizationHeader = 'Basic ' +EncodingUtil.base64Encode(headerValue);

        Map<Id, Contract> updateMapContracts = new Map<Id, Contract>();
        String jsonBdy = '[';
        for(Contract contr : (List<Contract>) scope){
            DateTime dt = DateTime.newInstance(contr.StartDate.year(),contr.StartDate.month(),contr.StartDate.day());
            String formattedSDate = dt.format('YYYY-MM-dd');
            Integer commission = Integer.valueOf(contr.Commission__c * 100);
            Integer monthly_fee = 0;
            Boolean conditional_monthly_fee = false;
            if(contr.Id_Opportunity_Quote_Line_Item__r.Name.contains(Label.Monthly_Administration_Fee)) {
                monthly_fee = 1490;
                conditional_monthly_fee = true;
            }
            updateMapContracts.put(contr.Id, contr);
            jsonBdy += '{"restaurant_id":'+contr.Account.Backend_ID__c+',"salesforce_id":"'+contr.Id+'","commission":'+commission+',"monthly_fee_amount":'+monthly_fee+',"conditional_monthly_fee":' + conditional_monthly_fee + ',"start_date":"'+formattedSDate+'"';
            jsonBdy += '},';
        }
        String body = jsonBdy.removeEnd(',')+']';
        
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();      
        Http http = new Http();
        req.setEndpoint(sEndPoint);
        req.setMethod('POST');
        req.setHeader('Authorization',authorizationHeader);
        req.setBody(body);
        try{
            res = http.send(req);
            System.debug('json: ' + body);
            System.debug('addPriceList Response: '+res.getBody());
            system.debug('##status code'+res.getStatusCode());
            if(res.getStatusCode()==201 || res.getStatusCode()==207) {              
                JSONParser parser = JSON.createParser(res.getBody());                
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                        while (parser.nextToken() != null) {
                            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                ClsRoganAddChargeResponseWrapper result = (ClsRoganAddChargeResponseWrapper)parser.readValueAs(ClsRoganAddChargeResponseWrapper.class);
                                if(result.success){
                                    updateMapContracts.get(result.salesforce_id).Status = 'Activated';
                                    updateMapContracts.get(result.salesforce_id).RoganAddPriceListAPIError__c = null;   
                                }else{
                                    updateMapContracts.get(result.salesforce_id).RoganAddPriceListAPIError__c = result.code+': '+result.message;
                                }
                            }
                        }
                    }
                }
                System.debug('updateMapContracts response: '+updateMapContracts);
            }else{
                for(Id ss : updateMapContracts.keySet()){
                    updateMapContracts.get(ss).RoganAddPriceListAPIError__c = res.getStatusCode()+': '+res.getBody().left(230);
                }
                System.debug('updateMapContracts failed: '+updateMapContracts);
            }
            Update updateMapContracts.values();
        }catch(Exception e){
            system.debug(e.getMessage());
        }

    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}