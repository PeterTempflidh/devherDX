global class BatchSendMigrationChargeToRogan implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    String query;
    Integration_Config__c intConfig;

    
    global BatchSendMigrationChargeToRogan() {
        intConfig = Integration_Config__c.getValues('United Kingdom');
        //query = 'Select Id,Type__c,Product__c,Status__c,RoganAddChargeAPIError__c,Total_Amount__c,Installments__c,Id_Account__c,Id_Account__r.Backend_ID__c,Start_Date__c,Termination_Date__c,City_ZipCode__c,Booking_Api_Id__c from Additional_Charges__c where RecordType.DeveloperName=\''+intConfig.RecordTypeDName__c+'\' and Status__c=\'To be sent\'';
     query = 'SELECT Id,Id_List_Product_Price__r.product_name__c,Type__c, Product__c, Status__c, Rogan_Product_Name__c,RoganAddChargeAPIError__c, Total_Amount__c,Installments__c, Id_Account__c, Id_Account__r.Backend_ID__c, Start_Date__c, Termination_Date__c, City_ZipCode__c, Booking_Api_Id__c FROM Additional_Charges__c WHERE RecordType.DeveloperName = \'UK_Additional_charges\' AND Status__c = \'To be sent\' And Id_opportunity__r.owner.name not in (\'Hugh Jackman\',\'Sourabha Herur Nagaraja Rao\',\'Queen Elizabeth\') And Product__c in (\'UK Migration - LiveLink\',\'UK Migration - Tablink - 3G\',\'UK Migration - Tablink WiFi\') And Total_Amount__c > 0 order by Id_Account__c';
  }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        String sEndPoint =  intConfig.endpoint__c+'add-charges';
        Blob headerValue = Blob.valueOf(intConfig.username__c + ':' + intConfig.password__c );
        String authorizationHeader = 'Basic ' +EncodingUtil.base64Encode(headerValue);


        Map<Id,Additional_Charges__c> updateMapAddCharges = new Map<Id,Additional_Charges__c>();
        String jsonBdy = '[';
        for(Additional_Charges__c ad : (List<Additional_Charges__c>) scope){
            DateTime dt = DateTime.newInstance(ad.Start_Date__c.year(),ad.Start_Date__c.month(),ad.Start_Date__c.day());
            String formattedSDate = dt.format('YYYY-MM-dd');
            Integer amount = Integer.valueOf(ad.Total_Amount__c * 100);
            Integer installment = 1;
            if((Amount > 1) && ad.Installments__c!=null && ad.Installments__c!=0){
                installment = Integer.valueOf(ad.Installments__c);
            }
            updateMapAddCharges.put(ad.id,ad);
            jsonBdy += '{"restaurant_id":'+ad.Id_Account__r.Backend_ID__c+',"salesforce_id":"'+ad.Id+'","charge_name":"'+ad.Rogan_Product_Name__c+'","amount":'+amount+',"installment_count":'+installment+',"transaction_date":"'+formattedSDate+'"';
            if(ad.Type__c=='Premium Placement'){
                DateTime dte = DateTime.newInstance(ad.Termination_Date__c.year(),ad.Termination_Date__c.month(),ad.Termination_Date__c.day());
                String formattedEDate = dte.format('YYYY-MM-dd');
                jsonBdy += ',"note":"'+ad.Booking_Api_Id__c+','+ad.City_ZipCode__c+','+formattedSDate+','+formattedEDate+'"';
            }
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
            System.debug('addCharge Response: '+res.getBody());
            system.debug('##status code'+res.getStatusCode());
            if(res.getStatusCode()==201 || res.getStatusCode()==207) {
                JSONParser parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                        while (parser.nextToken() != null) {
                            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                ClsRoganAddChargeResponseWrapper result = (ClsRoganAddChargeResponseWrapper)parser.readValueAs(ClsRoganAddChargeResponseWrapper.class);
                                if(result.success){
                                    updateMapAddCharges.get(result.salesforce_id).Status__c = 'Active';
                                    updateMapAddCharges.get(result.salesforce_id).RoganAddChargeAPIError__c = null; 
                                }else{
                                    updateMapAddCharges.get(result.salesforce_id).RoganAddChargeAPIError__c = result.code+': '+result.message;
                                }
                            }
                        }
                    }
                }
                System.debug('updateMapAddCharges response: '+updateMapAddCharges);
            }else{
                for(Id ss : updateMapAddCharges.keySet()){
                    updateMapAddCharges.get(ss).RoganAddChargeAPIError__c = res.getStatusCode()+': '+res.getBody().left(230);
                }
                System.debug('updateMapAddCharges failed: '+updateMapAddCharges);
            }
            Update updateMapAddCharges.values();
        }catch(Exception e){
            system.debug(e.getMessage());
        }
    
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}