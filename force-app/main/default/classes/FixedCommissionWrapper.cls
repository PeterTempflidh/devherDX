global class FixedCommissionWrapper {

    public List<Categories> categories;
	public List<Target_districts> target_districts;
    
	public class Target_districts {
		public String district_id;
		public String district_name;
		public String targetdistrict_id;
		public String start_date;
		public String end_date;
		public Decimal amount;
	}

	public class Categories {
		public String id;
		public String name;
	}
    
    //custom members
    public boolean errorFlag {get;set;}
    public String errorMessage {get;set;}
    public Map<String,String> mapCategories {private set;
													get{
														if(this.mapCategories == null){
															this.createMapCategories();
															return this.mapCategories;
														}else{
															return this.mapCategories;
														}
													}
												 }
    
    public Map<String,String> mapDistricts {private set;
                                             		get{
                                                        if(this.mapDistricts == null){
                                                            this.createMapDistricts();
                                                            return this.mapDistricts;
                                                        }else{
                                                            return this.mapDistricts;
                                                        }
                                                    }
                                            }
    
    public Map<String,Decimal> mapDistrictPrices{private set;
                                                 	get{
                                                        if(this.mapDistrictPrices == null){
                                                            this.createMapDistrictPrices();
                                                            return this.mapDistrictPrices;
                                                        }else{
                                                            return this.mapDistrictPrices;
                                                        }
                                                    }
                                                }

    public Map<String,String> mapDistrictPricesInfo {private set;
																	get{
																		if(this.mapDistrictPricesInfo == null){
																			this.createMapDistrictPriceInfo();
																			return this.mapDistrictPricesInfo;
																		}else{
																			return this.mapDistrictPricesInfo;
																		}
																	}

														}
    
    
    private void createMapCategories(){
		this.mapCategories = new Map<String,String>();

		for(Categories c : this.categories){
			this.mapCategories.put(c.id, c.name);
		}
	}
    
    private void createMapDistricts(){
        this.mapDistricts = new Map<String,String>();
        
        for(Target_districts t : this.target_districts){
            this.mapDistricts.put(t.district_id, t.district_name);
        }
    }
    
    private void createMapDistrictPrices(){
        this.mapDistrictPrices = new Map<String,Decimal>();
        
        for(Target_Districts t : this.target_districts){
            this.mapDistrictPrices.put(String.valueOf(t.district_id), t.amount);
        }
    }

    private void createMapDistrictPriceInfo(){
		this.mapDistrictPricesInfo = new Map<String,String>();
		
			for(Target_districts i : this.target_districts){
				this.mapDistrictPricesInfo.put(String.valueOf(i.district_id),i.district_name+'('+i.amount+')');
			}
	}

	
	/*public static FixedCommissionWrapper parse(String json) {
		return (FixedCommissionWrapper) System.JSON.deserialize(json, FixedCommissionWrapper.class);
	}
	
	static testMethod void testParse() {
		String json = '{'+
		'	\"categories\": ['+
		'		{'+
		'			\"id\": 1, \"name\": \"category 1\"'+
		'		}'+
		'	],'+
		'	\"target_districts\": ['+
		'		 {'+
		'			\"id\": 1,'+
		'			\"name\": \"target district 1\",'+
		'			\"district_id\": 123,'+
		'			\"start_date\": \"2015-08-01\",'+
		'			\"end_date\": \"2015-08-31\",'+
		'			\"monthly_fee\": 39500'+
		'		}'+
		'	]'+
		'}';
		FixedCommissionWrapper obj = parse(json);
		System.assert(obj != null);
	}*/
}
