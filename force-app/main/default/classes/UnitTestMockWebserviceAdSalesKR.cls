@isTest
global class UnitTestMockWebserviceAdSalesKR implements HttpCalloutMock {
	
	global HttpResponse respond(HttpRequest req){
		HttpResponse res = new HttpResponse();

		if(req.getEndpoint() == 'https://www.yogiyo.co.kr/salesforce/restaurant/0815/available_districts_and_categories/?api_key=salesforce&secret=salesforceSecret'){
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