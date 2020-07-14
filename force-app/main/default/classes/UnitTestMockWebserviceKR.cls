@isTest
global class UnitTestMockWebserviceKR implements HttpCalloutMock {
	
	global HttpResponse respond(HttpRequest req){
		HttpResponse res = new HttpResponse();


		if(req.getEndpoint() == 'http://midas-staging.medusa-hero.com/backend/book/UKHH/0018E00000Jws43QAB/'){
			res.setBody('[{"booking_id":59194,"postcode":"E1"},{"booking_id":59195,"postcode":"E2"}]');
			res.setStatusCode(201);
			res.setStatus('Created');
		}else if(req.getEndpoint() == 'http://midas-staging.medusa-hero.com/backend/book/UKHH/0018E00000Jws43QAC/'){
			res.setBody('Not found');
			res.setStatusCode(500);
			res.setStatus('Error');
		}else if(req.getEndpoint() == 'http://midas-staging.medusa-hero.com/backend/restaurants/UKHH/0018E00000Jws43QAB/2016/8/'){
			res.setBody('[{"status":"free","distance":1.6093483,"distance_units":"mi.","postcode":"HA0","coverage":60.0,"packages":[{"price":0,"package_type":"default","default_flag":true,"description":"Default booking"},{"price":0,"package_type":"p1_package","default_flag":false,"description":"First position"},{"price":0,"package_type":"p2_package","default_flag":false,"description":"Second position"}],"available_slots":4},{"status":"free","distance":1.5472113,"distance_units":"mi.","postcode":"NW10","coverage":65.0,"packages":[{"price":0,"package_type":"default","default_flag":true,"description":"Default booking"},{"price":0,"package_type":"p1_package","default_flag":false,"description":"First position"},{"price":0,"package_type":"p2_package","default_flag":false,"description":"Second position"}],"available_slots":4},{"status":"free","distance":1.5037154,"distance_units":"mi.","postcode":"NW26","coverage":94.0,"packages":[{"price":0,"package_type":"default","default_flag":true,"description":"Default booking"},{"price":0,"package_type":"p1_package","default_flag":false,"description":"First position"},{"price":0,"package_type":"p2_package","default_flag":false,"description":"Second position"}],"available_slots":4},{"status":"free","distance":1.2551674,"distance_units":"mi.","postcode":"W3","coverage":99.0,"packages":[{"price":0,"package_type":"default","default_flag":true,"description":"Default booking"},{"price":0,"package_type":"p1_package","default_flag":false,"description":"First position"},{"price":0,"package_type":"p2_package","default_flag":false,"description":"Second position"}],"available_slots":4},{"status":"free","distance":1.3918688,"distance_units":"mi.","postcode":"W5","coverage":98.0,"packages":[{"price":0,"package_type":"default","default_flag":true,"description":"Default booking"},{"price":0,"package_type":"p1_package","default_flag":false,"description":"First position"},{"price":0,"package_type":"p2_package","default_flag":false,"description":"Second position"}],"available_slots":4},{"status":"free","distance":2.0318799,"distance_units":"mi.","postcode":"W12","coverage":54.0,"packages":[{"price":0,"package_type":"default","default_flag":true,"description":"Default booking"},{"price":0,"package_type":"p1_package","default_flag":false,"description":"First position"},{"price":0,"package_type":"p2_package","default_flag":false,"description":"Second position"}],"available_slots":4},{"status":"free","distance":1.9759566,"distance_units":"mi.","postcode":"W13","coverage":92.0,"packages":[{"price":0,"package_type":"default","default_flag":true,"description":"Default booking"},{"price":0,"package_type":"p1_package","default_flag":false,"description":"First position"},{"price":0,"package_type":"p2_package","default_flag":false,"description":"Second position"}],"available_slots":4}]');
			res.setStatusCode(200);
			res.setStatus('OK');
		}else if(req.getEndpoint() == 'http://midas-staging.medusa-hero.com/backend/restaurants/UKHH/0018E00000Jws43QAC/2016/8/'){
			res.setBody('Error server not available');
			res.setStatusCode(500);
		}else if(req.getEndpoint() == 'https://www.yogiyo.co.kr/salesforce/restaurant/create/?api_key=salesforce&secret=salesforceSecret'){
			res.setStatusCode(200);
			String json = '{\"restaurant_id\":\"123456\"}';

			res.setBody(json);
		}else if(req.getEndpoint() == 'https://www.yogiyo.co.kr/salesforce/restaurant/0815/available_districts_and_categories/?api_key=salesforce&secret=salesforceSecret'){
			res.setStatusCode(200);
			String json = '{'+
			'    \"district_price\": {'+
			'        \"super\": ['+
			'            {'+
			'                \"amount\": 50000,'+
			'                \"district__id\": 4006,'+
			'                \"district__name\": \"서울 강남구 논현1동\"'+
			'            },'+
			'            {'+
			'                \"amount\": 50000,'+
			'                \"district__id\": 1451,'+
			'                \"district__name\": \"서울 강남구 논현2동\"'+
			'            },'+
			'            {'+
			'                \"amount\": 50000,'+
			'                \"district__id\": 4998,'+
			'                \"district__name\": \"서울 강남구 논현동\"'+
			'            }'+
			'        ],'+
			'        \"basic\": ['+
			'            {'+
			'                \"amount\": 30000,'+
			'                \"district__id\": 4006,'+
			'                \"district__name\": \"서울 강남구 논현1동\"'+
			'            },'+
			'            {'+
			'                \"amount\": 30000,'+
			'                \"district__id\": 1451,'+
			'                \"district__name\": \"서울 강남구 논현2동\"'+
			'            },'+
			'            {'+
			'                \"amount\": 30000,'+
			'                \"district__id\": 4998,'+
			'                \"district__name\": \"서울 강남구 논현동\"'+
			'            }'+
			'        ]'+
			'    },'+
			'    \"categories\": ['+
			'        {'+
			'            \"id\": 18,'+
			'            \"name\": \"일식돈까스\"'+
			'        },'+
			'        {'+
			'            \"id\": 13,'+
			'            \"name\": \"분식\"'+
			'        },'+
			'        {'+
			'            \"id\": 4,'+
			'            \"name\": \"치킨\"'+
			'        },'+
			'        {'+
			'            \"id\": 3,'+
			'            \"name\": \"야식\"'+
			'        },'+
			'        {'+
			'            \"id\": 2,'+
			'            \"name\": \"한식\"'+
			'        },'+
			'        {'+
			'            \"id\": 1,'+
			'            \"name\": \"피자양식\"'+
			'        }'+
			'    ]'+
			'}';

			res.setBody(json);
		}else if(req.getEndpoint() == 'https://www.yogiyo.co.kr/salesforce/restaurant/0816/available_districts_and_categories/?api_key=salesforce&secret=salesforceSecret'){
			res.setStatusCode(200);
			String json = '{'+
			'    \"district_price\": {'+
			'        \"super\": ['+
			'            {'+
			'                \"amount\": 50000.00,'+
			'                \"district__id\": 4006,'+
			'                \"district__name\": \"서울 강남구 논현1동\"'+
			'            },'+
			'            {'+
			'                \"amount\": 50000.00,'+
			'                \"district__id\": 1451,'+
			'                \"district__name\": \"서울 강남구 논현2동\"'+
			'            },'+
			'            {'+
			'                \"amount\": 50000.00,'+
			'                \"district__id\": 4998,'+
			'                \"district__name\": \"서울 강남구 논현동\"'+
			'            }'+
			'        ],'+
			'        \"basic\": ['+
			'            {'+
			'                \"amount\": 30000.00,'+
			'                \"district__id\": 4006,'+
			'                \"district__name\": \"서울 강남구 논현1동\"'+
			'            },'+
			'            {'+
			'                \"amount\": 30000.00,'+
			'                \"district__id\": 1451,'+
			'                \"district__name\": \"서울 강남구 논현2동\"'+
			'            },'+
			'            {'+
			'                \"amount\": 30000.00,'+
			'                \"district__id\": 4998,'+
			'                \"district__name\": \"서울 강남구 논현동\"'+
			'            }'+
			'        ]'+
			'    },'+
			'    \"categories\": ['+
			'        {'+
			'            \"id\": 18,'+
			'            \"name\": \"일식돈까스\"'+
			'        },'+
			'        {'+
			'            \"id\": 13,'+
			'            \"name\": \"분식\"'+
			'        },'+
			'        {'+
			'            \"id\": 4,'+
			'            \"name\": \"치킨\"'+
			'        },'+
			'        {'+
			'            \"id\": 3,'+
			'            \"name\": \"야식\"'+
			'        },'+
			'        {'+
			'            \"id\": 2,'+
			'            \"name\": \"한식\"'+
			'        },'+
			'        {'+
			'            \"id\": 1,'+
			'            \"name\": \"피자양식\"'+
			'        }'+
			'    ]'+
			'}';

			res.setBody(json);
		}else if(req.getEndpoint() == 'https://www.yogiyo.co.kr/salesforce/restaurant/0816/zero_commission/?api_key=salesforce&secret=salesforceSecret'){
			res.setStatusCode(200);
			String json = '{"amounts": [{"amount": 39900, "name": "39,900c6d0"}, {"amount": 0, "name": "bb34b8cc"}], "target_districts": [{"end_date": null, "district_name": "c11cc6b8 ac15b3d9ad6c cc9cd6382b3d9", "amount": null, "district_id": 153, "targetdistrict_id": 2825992, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 ac15b3d9ad6c ac15c77cb3d9", "amount": null, "district_id": 400, "targetdistrict_id": 2825993, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 c1a1d30cad6c d48db0a92b3d9", "amount": null, "district_id": 892, "targetdistrict_id": 2825994, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 ac15b3d9ad6c ae38b3d9", "amount": null, "district_id": 993, "targetdistrict_id": 2825995, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 ac15b3d9ad6c c554c0ac2b3d9", "amount": null, "district_id": 1178, "targetdistrict_id": 2825996, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 ac15b3d9ad6c ace0b355b3d9", "amount": null, "district_id": 1224, "targetdistrict_id": 2825997, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 ac15b3d9ad6c c0c1c77cb3d9", "amount": null, "district_id": 1406, "targetdistrict_id": 2825998, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 ac15b3d9ad6c c131b0b42b3d9", "amount": null, "district_id": 2025, "targetdistrict_id": 2825999, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 ac15b3d9ad6c ace0b3551b3d9", "amount": null, "district_id": 2532, "targetdistrict_id": 2826000, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 ac15b3d9ad6c cc9cd6383b3d9", "amount": null, "district_id": 3067, "targetdistrict_id": 2826001, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 ac15b3d9ad6c cc9cd6381b3d9", "amount": null, "district_id": 3217, "targetdistrict_id": 2826002, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 c1a1d30cad6c d48db0a9b3d9", "amount": null, "district_id": 3902, "targetdistrict_id": 2826003, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 ac15b3d9ad6c c554c0ac3b3d9", "amount": null, "district_id": 4024, "targetdistrict_id": 2826004, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 c1a1d30cad6c d48db0a91b3d9", "amount": null, "district_id": 4111, "targetdistrict_id": 2826005, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 ac15b3d9ad6c c554c0ac1b3d9", "amount": null, "district_id": 4198, "targetdistrict_id": 2826006, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 ac15b3d9ad6c c131b0b4b3d9", "amount": null, "district_id": 4458, "targetdistrict_id": 2826007, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 ac15b3d9ad6c c131b0b43b3d9", "amount": null, "district_id": 4734, "targetdistrict_id": 2826008, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 ac15b3d9ad6c c131b0b41b3d9", "amount": null, "district_id": 4879, "targetdistrict_id": 2826009, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 ac15b3d9ad6c cc9cd638b3d9", "amount": null, "district_id": 5005, "targetdistrict_id": 2826010, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 ac15b3d9ad6c ba85c77cb3d9", "amount": null, "district_id": 5355, "targetdistrict_id": 2826011, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 ac15b3d9ad6c ba85c77c2b3d9", "amount": null, "district_id": 5543, "targetdistrict_id": 2826012, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 ac15b3d9ad6c ba85c77c1b3d9", "amount": null, "district_id": 5790, "targetdistrict_id": 2826013, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 ac15b3d9ad6c c554c0acb3d9", "amount": null, "district_id": 5900, "targetdistrict_id": 2826014, "district__is_custom": false, "start_date": null}, {"end_date": null, "district_name": "c11cc6b8 ac15b3d9ad6c ace0b3552b3d9", "amount": null, "district_id": 5906, "targetdistrict_id": 2826015, "district__is_custom": false, "start_date": null}], "categories": [{"id": 18, "name": "c77cc2ddb3c8ae4cc2a4"}, {"id": 3, "name": "c57cc2dd"}]}';

			res.setBody(json);
		}else if(req.getEndpoint() == 'https://www.yogiyo.co.kr/salesforce/restaurant/0023/available_districts_and_categories/?api_key=salesforce&secret=salesforceSecret'){
			res.setStatusCode(200);
			String json = '{'+
			'    \"district_price\": {'+
			'        \"super\": ['+
			'            {'+
			'                \"amount\": 50000,'+
			'                \"district__id\": 4006,'+
			'                \"district__name\": \"서울 강남구 논현1동\"'+
			'            },'+
			'            {'+
			'                \"amount\": 50000,'+
			'                \"district__id\": 1451,'+
			'                \"district__name\": \"서울 강남구 논현2동\"'+
			'            },'+
			'            {'+
			'                \"amount\": 50000,'+
			'                \"district__id\": 4998,'+
			'                \"district__name\": \"서울 강남구 논현동\"'+
			'            }'+
			'        ]'+
			'    },'+
			'    \"categories\": ['+
			'        {'+
			'            \"id\": 18,'+
			'            \"name\": \"일식돈까스\"'+
			'        },'+
			'        {'+
			'            \"id\": 13,'+
			'            \"name\": \"분식\"'+
			'        },'+
			'        {'+
			'            \"id\": 4,'+
			'            \"name\": \"치킨\"'+
			'        },'+
			'        {'+
			'            \"id\": 3,'+
			'            \"name\": \"야식\"'+
			'        },'+
			'        {'+
			'            \"id\": 2,'+
			'            \"name\": \"한식\"'+
			'        },'+
			'        {'+
			'            \"id\": 1,'+
			'            \"name\": \"피자양식\"'+
			'        }'+
			'    ]'+
			'}';

			res.setBody(json);
		}else if(req.getEndpoint() == 'https://www.yogiyo.co.kr/salesforce/restaurant/0024/available_districts_and_categories/?api_key=salesforce&secret=salesforceSecret'){
			res.setStatusCode(200);
			String json = '{'+
			'    \"district_price\": {'+
			'        \"basic\": ['+
			'            {'+
			'                \"amount\": 30000,'+
			'                \"district__id\": 4006,'+
			'                \"district__name\": \"서울 강남구 논현1동\"'+
			'            },'+
			'            {'+
			'                \"amount\": 30000,'+
			'                \"district__id\": 1451,'+
			'                \"district__name\": \"서울 강남구 논현2동\"'+
			'            },'+
			'            {'+
			'                \"amount\": 30000,'+
			'                \"district__id\": 4998,'+
			'                \"district__name\": \"서울 강남구 논현동\"'+
			'            }'+
			'        ]'+
			'    },'+
			'    \"categories\": ['+
			'        {'+
			'            \"id\": 18,'+
			'            \"name\": \"일식돈까스\"'+
			'        },'+
			'        {'+
			'            \"id\": 13,'+
			'            \"name\": \"분식\"'+
			'        },'+
			'        {'+
			'            \"id\": 4,'+
			'            \"name\": \"치킨\"'+
			'        },'+
			'        {'+
			'            \"id\": 3,'+
			'            \"name\": \"야식\"'+
			'        },'+
			'        {'+
			'            \"id\": 2,'+
			'            \"name\": \"한식\"'+
			'        },'+
			'        {'+
			'            \"id\": 1,'+
			'            \"name\": \"피자양식\"'+
			'        }'+
			'    ]'+
			'}';

			res.setBody(json);
		}else if(req.getEndpoint() == 'https://www.yogiyo.co.kr/salesforce/restaurant/4711/available_districts_and_categories/?api_key=salesforce&secret=salesforceSecret'){
			res.setStatusCode(404);
		}else if(req.getEndpoint() == 'https://www.yogiyo.co.kr/salesforce/restaurant/0021/available_districts_and_categories/?api_key=salesforce&secret=salesforceSecret'){
			res.setStatusCode(200);
			res.setBody('');
		}else if(req.getEndpoint() == 'https://www.yogiyo.co.kr/salesforce/restaurant/0022/available_districts_and_categories/?api_key=salesforce&secret=salesforceSecret'){
			res.setStatusCode(200);
			res.setBody(null);
		}else if(req.getEndpoint() == 'https://www.yogiyo.co.kr/salesforce/restaurant/4712/zero_commission/?api_key=salesforce&secret=salesforceSecret'){
            res.setStatusCode(200);
            String json = '{'+
                        '  \"categories\": ['+
                        '    {'+
                        '      \"id\": 1, \"name\": \"category 1\"'+
                        '    }'+
                        '  ],'+
                        '  \"target_districts\": ['+
                        '     {'+
                        '      \"id\": 1,'+
                        '      \"name\": \"target district 1\",'+
                        '      \"district_id\": 123,'+
                        '      \"start_date\": \"2015-08-01\",'+
                        '      \"end_date\": \"2015-08-31\",'+
                        '      \"monthly_fee\": 39500'+
                        '    }'+
                        '  ]'+
                        '}';
            res.setBody(json);
        }
		

		return res;
	}
}