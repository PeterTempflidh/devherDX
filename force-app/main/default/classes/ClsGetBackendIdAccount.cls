global class ClsGetBackendIdAccount {

    webservice static String getBackendIdAccount(String accId, String accType) {
        try {
            String label = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get('Backend_ID__c').getDescribe().getLabel();
            //get account details
            Account acc = [Select Id, Name, Restaurant_Name__c, Backend_ID__c, BillingStreet, BillingCity, Phone, Delivery_Fee__c, Minimum_order_value_Cash__c,
                           parent.Backend_ID__c, parent.parent.Backend_ID__c, Company_Number__c, Brand__c, parent.Chain__c, Record_Country__c, parent.brand__c
                           from account where Id = : accId];

            // get the contacts:
            List<Contact> conlst = [Select Id, email, Phone from contact where id in (select contactid from AccountContactRelation  where accountid = : accId)];



            //Construct Body
            String body;
            String backEndId;
            String path;
            BEIntegration_CountriesToCities__c cntCit;
            if (accType == 'Client' || accType == 'Branch') {
                cntCit = BEIntegration_CountriesToCities__c.getValues(acc.BillingCity);
                //check if cntCit != null
                if (cntCit == null) {return 'warning';}
            }
            if (accType == 'Client') {
                // set the path
                path = '/clients/create';
                //Construct body
                // Billing Street can contain new line characters.  we need to escape it
                String street =  acc.BillingStreet;
                street = street.replace('\r\n', ' ');
                street = street.replace('\n', ' ');
                street = street.replace('\r', ' ');


                String bodySt = '{"salesforce-id":'     + '"' + String.valueOf(acc.Id)  + '"' + ',' +
                                '"legal-number":'       + '"' + acc.Company_Number__c   + '"'   + ',' +
                                '"address":'                + '"' + street                  + '"'   +  ',' +
                                '"city-id":'                + '"' + cntCit.City_Backend_Id__c + '"' +  ',' +
                                '"country-id":'         + '"' + cntCit.Country_Backend_Id__c + '"'  + ',' +
                                '"legal-name":'         + '"' + acc.Name        + '"' + ',' +
                                '"commercial-name":'    + '"' + acc.Restaurant_Name__c  + '"' + ',' +
                                '"salesperson-email":'    + '"' + UserInfo.getUserEmail() + '"'   + ',';
                String bodyParEmail = '';
                String bodyParPhone = '';
                for (contact con : conlst) {
                    bodyParEmail += con.email + ',';
                    bodyParPhone += con.Phone + ',';
                }

                //body
                body = bodySt + '"contact-emails":' + '"' + bodyParEmail.removeEnd(',') + '"' + ',' + '"contact-phones":' + '"' + bodyParPhone.removeEnd(',') + '"' + '}';
                system.debug(body);
            }
            // Brand
            if (accType == 'Brand') {
                path = '/brands/create';
                String bodySt = '{"salesforce-id":' + '"' + String.valueOf(acc.Id)  + '"' + ',' + '"name":' + '"' + acc.Name + '"' + '}';

                body = bodySt;
                system.debug(body);
            }

            if (accType == 'Franchise') {
                path = '/franchises/create';
                String bodySt = '{"salesforce-id":'     + '"' + String.valueOf(acc.Id)    + '"' + ',' +
                                '"name":'           + '"' + acc.Name            + '"'   + ',' +
                                '"client-id":'        + '"' + acc.parent.Id   + '"'   + ',' +
                                '"brand-id":'         + '"' + acc.Brand__c        + '"';

                //body
                body = bodySt + '}';
            }

            if (accType == 'Branch') {

                String street =  acc.BillingStreet;
                street = street.replace('\r\n', ' ');
                street = street.replace('\n', ' ');
                street = street.replace('\r', ' ');

                path = '/branches/create';
                String bodySt = '{"salesforce-id":'     + '"' + String.valueOf(acc.Id)        + '"' + ',' +
                                '"brand-id":'           + '"' + acc.parent.brand__c             + '"'   + ',' +
                                '"client-id":'          + '"' + acc.parent.parent.Id            + '"' + ',' +
                                '"address":'          + '"' + street                              + '"' + ',' +
                                '"name":'           + '"' + acc.Name              + '"' + ',';

                //min-order-amount and delivery-cost are optional fields
                //in the request message. only include them if populated.

                if (acc.phone != null) {bodySt += '"manager-phone":' + '"' + acc.Phone + '"' + ',';}
                if (acc.Delivery_Fee__c != null) {bodySt += '"min-order-amount":' + acc.Delivery_Fee__c + ',';}
                if (acc.Minimum_order_value_Cash__c != null) {bodySt += '"delivery-cost":' + acc.Minimum_order_value_Cash__c + ',';}

                bodySt += '"city-id":' + '"' + cntCit.City_Backend_Id__c + '"' + ',';
                bodySt += '"country-id":' + '"'  + cntCit.Country_Backend_Id__c + '"';

                body = bodySt + '}';
                system.debug('body' + body);
            }

            HttpResponse res = new HttpResponse();
            Http http = new Http();

            //system.debug('countrycode' + acc.Record_Country__c);
            HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest(acc.Record_Country__c, path, 'POST', body);

            if (req != null) {
                res = http.send(req);
                if (res.getStatusCode() == 201 || res.getStatusCode() == 200) {
                    JSONParser parser = JSON.createParser(res.getBody());

                    while (parser.nextToken() != null) {
                        if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'Id') {
                            parser.nextToken();
                            backEndId = parser.getText();
                            break;
                        }
                    }
                } else {
                    return 'Error:' + res.getStatus();
                }

            } else {
                return 'MidasIntegration__c is not configured';
            }


            acc.Backend_ID__c = backEndId;

            update acc;
            return 'SUCCESS:' + label + ':' + acc.Backend_ID__c;
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }


    }


}