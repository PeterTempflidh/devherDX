public class DistrictPriceCategoryWrapper {

	public class DistrictPriceItem {
		public Decimal amount;
		public Integer district_id;
		public String district_name;
	}

	public class District_price {
		public List<DistrictPriceItem> typeSuper;
		public List<DistrictPriceItem> typeBasic;
	}

	public District_price district_price;
	public List<Categories> categories;

	public boolean errorFlag {get;set;}
	public String errorMessage {get;set;}

	public Map<Integer,String> mapCategories {private set;
													get{
														if(this.mapCategories == null){
															this.createMapCategories();
															return this.mapCategories;
														}else{
															return this.mapCategories;
														}
													}
												 }

	public Map<Integer,String> mapDistricts {private set;
													get{
														if(this.mapDistricts == null){
															this.createMapDistricts();
															return this.mapDistricts;
														}else{
															return this.mapDistricts;
														}
													}
												 }

	public Map<String,Decimal> mapDistrictPrices {private set;
																	get{
																		if(this.mapDistrictPrices == null){
																			this.createMapDistrictPrices();
																			return this.mapDistrictPrices;
																		}else{
																			return this.mapDistrictPrices;
																		}
																	}
																 }

	public Map<String,List<Integer>> mapTypeDistricts {private set;
																	get{
																		if(this.mapTypeDistricts == null){
																			this.createMapTypeDistricts();
																			return this.mapTypeDistricts;
																		}else{
																			return this.mapTypeDistricts;
																		}
																	}
																 }
	public Map<String,String> mapTypeDistrictPricesInfo {private set;
																	get{
																		if(this.mapTypeDistrictPricesInfo == null){
																			this.createMapTypeDistrictPriceInfo();
																			return this.mapTypeDistrictPricesInfo;
																		}else{
																			return this.mapTypeDistrictPricesInfo;
																		}
																	}

														}															 											 

							 

	public class Categories {
		public Integer id;
		public String name;
	}

	public DistrictPriceCategoryWrapper(){

	}

	private void createMapCategories(){
		this.mapCategories = new Map<Integer,String>();

		for(Categories c : this.categories){
			this.mapCategories.put(c.id, c.name);
		}
	}

	private void createMapDistricts(){
		this.mapDistricts = new Map<Integer,String>();
		if(this.district_price.typeSuper!=null){
			for(DistrictPriceItem i : this.district_price.typeSuper){
			this.mapDistricts.put(i.district_id, i.district_name);
			}
		}
		if(this.district_price.typeBasic!=null){
			for(DistrictPriceItem i : this.district_price.typeBasic){
			this.mapDistricts.put(i.district_id, i.district_name);
			}
		}
		
	}

	private void createMapDistrictPrices(){
		this.mapDistrictPrices = new Map<String,Decimal>();

		if(this.district_price.typeSuper!=null){
			for(DistrictPriceItem i : this.district_price.typeSuper){
				this.mapDistrictPrices.put('Super-'+ String.valueOf(i.district_id), i.amount);
			}
		}
		if(this.district_price.typeBasic!=null){
			for(DistrictPriceItem i : this.district_price.typeBasic){
				this.mapDistrictPrices.put('Basic-'+ String.valueOf(i.district_id), i.amount);
			}
		}
	}

	private void createMapTypeDistricts(){
		this.mapTypeDistricts = new Map<String,List<Integer>>();
		if(this.district_price.typeSuper!=null){
			for(DistrictPriceItem i : this.district_price.typeSuper){
				if(!this.mapTypeDistricts.containsKey('Super')){
					this.mapTypeDistricts.put('Super', new List<Integer>{i.district_id});
				}else{
					this.mapTypeDistricts.get('Super').add(i.district_id);
				}
			}
		}
		if(this.district_price.typeBasic!=null){
			for(DistrictPriceItem i : this.district_price.typeBasic){
				if(!this.mapTypeDistricts.containsKey('Basic')){
					this.mapTypeDistricts.put('Basic', new List<Integer>{i.district_id});
				}else{
					this.mapTypeDistricts.get('Basic').add(i.district_id);
				}
			}
		}
	}

	private void createMapTypeDistrictPriceInfo(){
		this.mapTypeDistrictPricesInfo = new Map<String,String>();
		if(this.district_price.typeSuper!=null){
			for(DistrictPriceItem i : this.district_price.typeSuper){
				this.mapTypeDistrictPricesInfo.put('Super-'+ String.valueOf(i.district_id),'Super-'+i.district_name+'('+i.amount+')');
			}
		}
		if(this.district_price.typeBasic!=null){
			for(DistrictPriceItem i : this.district_price.typeBasic){
				this.mapTypeDistrictPricesInfo.put('Basic-'+ String.valueOf(i.district_id),'Basic-'+i.district_name+'('+i.amount+')');
			}
		}
	}

}