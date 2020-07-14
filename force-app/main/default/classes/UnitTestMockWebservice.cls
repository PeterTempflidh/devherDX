/*
@author : Alexander Faust
@reviewer : 
@creation : 05.12.2014
@notes : tests LibWebserviceHelper aswell
*/
@isTest
global class UnitTestMockWebservice implements HttpCalloutMock {
    public HttpResponse customResponse;
    global UnitTestMockWebservice(HttpResponse response){
        customResponse = response;
    }
    global UnitTestMockWebservice(){
    
    }
    
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        if(req.getEndpoint().contains('/accounts/UKHH/N1/2016/8/?complete_list=true')){
            res.setBody('[{"sf_restaurant_id":null,"account_owner_email":"magesh.maniyadav@deliveryhero.com","restaurant_postcode":"N79QG","restaurant_id":28596,"restaurant_name":"Newmarket Ale House","account_owner_id":15,"restaurant_owner_id":15}]');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('/accounts/UKHH/N1/2016/8/?complete_list=false')){
            res.setBody('[{"sf_restaurant_id":null,"account_owner_email":"magesh.maniyadav@deliveryhero.com","restaurant_postcode":"N79QG","restaurant_id":28596,"restaurant_name":"Newmarket Ale House","account_owner_id":15,"restaurant_owner_id":15}]');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('/postcode/UKHH/CM18/2016/8/')){
            res.setBody('[{"status":"open","username":"fprunty@hungryhouse.co.uk","restaurant_id":28613,"package_type":"default","booking_id":59191,"amount":50.0,"postcode":"CM18","restaurant_name":"Caspian Kebab"}]');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('accounts/UKHH/?number_of_leads=30')){
            res.setBody('[{"sf_restaurant_id":"0018E00000IHlI1QAL","restaurant_id":2266,"restaurant_owner_id":null,"restaurant_name":"Thames Tandoori","restaurant_postcode":"SW114ND"},{"sf_restaurant_id":"0018E00000IHlI2QAL","restaurant_id":2306,"restaurant_owner_id":null,"restaurant_name":"itsu","restaurant_postcode":"SW33AE"}]');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('accounts/UKHH/?complete_list=true')){
            res.setBody('[{"sf_restaurant_id":"0018E00000IHlI1QAL","restaurant_id":2266,"restaurant_owner_id":null,"restaurant_name":"Thames Tandoori","restaurant_postcode":"SW114ND"},{"sf_restaurant_id":"0018E00000IHlI2QAL","restaurant_id":2306,"restaurant_owner_id":null,"restaurant_name":"itsu","restaurant_postcode":"SW33AE"}]');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('cancelbooking/UKHH/')){
            res.setStatusCode(204);
        }else if(req.getEndpoint().contains('opportunities/close/UKHH/')){
            res.setStatusCode(204);
        }else if(req.getEndpoint().contains('restaurants/UKHH/')){
            res.setBody('[{"status":"free","distance":1.7646908,"distance_units":"mi.","postcode":"E8","coverage":99.0,"packages":[{"price":170,"package_type":"default","default_flag":true,"description":"Default booking"},{"price":237,"package_type":"p1_package","default_flag":false,"description":"First position"},{"price":204,"package_type":"p2_package","default_flag":false,"description":"Second position"}],"available_slots":3},{"status":"free","distance":1.677699,"distance_units":"mi.","postcode":"E98","coverage":100.0,"packages":[{"price":0,"package_type":"default","default_flag":true,"description":"Default booking"},{"price":0,"package_type":"p1_package","default_flag":false,"description":"First position"},{"price":0,"package_type":"p2_package","default_flag":false,"description":"Second position"}],"available_slots":4}]');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('book/UKHH/')){
            res.setBody('[{"booking_id":58983,"postcode":"E98"},{"booking_id":58984,"postcode":"E8"}]');
            res.setStatusCode(201);
        }else if(req.getEndpoint().contains('/v2/sites/UKHH/bookings/cancel')){
        	res.setBody('{"data":[{"id":58983,"status":204,"message":""}]}');
            res.setStatusCode(207);
        }else if(req.getEndpoint().contains('opportunities/close/UKHH/')){
            res.setStatusCode(204);

        }else if(req.getEndpoint().contains('staging-hungryhouse.com/api/salesforce/restaurant/add-charges')){
            res = customResponse;
        }else if(req.getEndpoint() == 'https://login.salesforce.com/services/oauth2/token'){
            res.setStatusCode(200);
            res.setBody('{"id":"https://login.salesforce.com/id/00D20000000CSSJEA4/00520000003GeDIAA0","issued_at":"1417790753927","token_type":"Bearer","instance_url":"https://emea.salesforce.com","signature":"wG1Qo49DfNHOZuvkibWwotVT6L2l6k5zqCXZKMQcez8=","access_token":"00D20000000CSSJ!AQgAQObGOGWNPpphCHmcemTKudhCRCc43KWE2xsxcE8WEJrNrbyObFoBI92OOfWT3ya37EV67XskPdL.jAVuUWtmufLBWJ.J"}');
        }else if(req.getEndpoint().contains('/services/data/v29.0/query')){
            res.setStatusCode(200);
            res.setBody('{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Account","url":"/services/data/v29.0/sobjects/Account/0012000000yYENOAA4"},"Id":"0012000000yYENOAA4","Name":"Pizzeria CC Test Einzelunternehmen"}]}');
        }else if(req.getBody() == 'Pass'){
            res.setStatusCode(201); 
        }else if(req.getBody() == 'Fail'){
            res.setStatusCode(400);
        }else if(req.getEndpoint().contains('hungryhouse')){
            res.setStatusCode(201);
            res.setBody('{"success":true, "restaurant_id":1234}');
        }else if(req.getEndpoint().contains('/talabat/api/')){
            res.setStatusCode(200);
            res.setBody('{"success":true,"access_token":"834853hfkj"}');
        }else if(req.getEndpoint().contains('/talabat/')){
            res.setStatusCode(200);
            res.setBody('[{"sf_restaurant_id":null,"account_owner_email":"magesh.maniyadav@deliveryhero.com","restaurant_postcode":"N79QG","restaurant_id":28596,"restaurant_name":"Newmarket Ale House","account_owner_id":15,"restaurant_owner_id":15}]');
            
        }else if(req.getEndpoint().contains('/aftership.com/')){
            res.setStatusCode(201);
            res.setbody('{"meta": { "code": 201},"data": {"tracking": { "id": "53aa7b5c415a670000000021","tracking_ship_date":"2014-06-25","updated_at":"2014-06-25T09:23:08+00:00","expected_delivery":"2014-06-25T09:23:08+00:00","tracking_number": "123456789","tag":"Exception","checkpoints": [{"tag":"Exception","message":"83dhu"}]}}}');
        }
        return res;
    }
}