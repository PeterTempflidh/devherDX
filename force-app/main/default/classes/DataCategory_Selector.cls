/**
 * Created by p.bansal on 20-Mar-20.
 * Description: Data Catgeories structure processor to get all data categories with their unique names and labels.
 */
public with sharing class DataCategory_Selector {    
    public static Map<String,String> mapOfDCs = new Map<String,String>();  
	public static List<DataCategory> allDataCategories = new List<DataCategory>();

    public static Map<String,String>  getDescribeDCGStrucRes(){
        List<DescribeDataCategoryGroupResult> describeCategoryResult;
        List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
		
        try {
           //Making the call to the describeDataCategoryGroups to get the list of category groups associated
           List<String> objType = new List<String>();
           objType.add('KnowledgeArticleVersion');
           describeCategoryResult = Schema.describeDataCategoryGroups(objType);
		   
           List<DataCategoryGroupSobjectTypePair> pairs =   new List<DataCategoryGroupSobjectTypePair>();
           pairs = getDCGrpTypePair(describeCategoryResult);

           //Whole heirachy starting from Catgry Grp. 
           //For e.g(Case Reason> Cancellation(>>Request Cancellation), Late Order(>>)) etc.
           describeCategoryStructureResult =  Schema.describeDataCategoryGroupStructures(pairs, false);

           //Getting data from the result
           List<DataCategory> allCategories = new List<DataCategory>();
           allCategories = getAllDataCategories(describeCategoryStructureResult);
          
           if(!allCategories.isEmpty()){
                getLabelAndNames(allCategories);
           } 
        } catch (Exception e){
            LoggingUtility.logError(DataCategory_Selector.class.getName(),'Error => ' + e.getMessage() + '\nLine Number : ' + e.getLineNumber());        
        }
        return mapOfDCs;
     }
            
    //Creating a list of pair objects to use as a parameter
    //for the describe call
    public static List<DataCategoryGroupSobjectTypePair> getDCGrpTypePair(List<DescribeDataCategoryGroupResult> pDescribeCategoryResult){
        List<DataCategoryGroupSobjectTypePair> pairs =   new List<DataCategoryGroupSobjectTypePair>();
          
        //Looping throught the first describe result to create
        //the list of pairs for the second describe call
        //Pair would be like (Schema.DataCategoryGroupSobjectTypePair[getDataCategoryGroupName=Case_Reasons;getSobject=KnowledgeArticleVersion;])
        for(DescribeDataCategoryGroupResult singleResult :  pDescribeCategoryResult){
            DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
            p.setSobject(singleResult.getSobject());
            p.setDataCategoryGroupName(singleResult.getName());
            pairs.add(p);
        }
        return pairs;
    }

    public static List<DataCategory> getAllDataCategories(List<DescribeDataCategoryGroupStructureResult> pDescribeCategoryStructureResult){
        for(DescribeDataCategoryGroupStructureResult singleResult : pDescribeCategoryStructureResult){        
            //Get the top level categories. This starts with first category in a given group
            //With the most outer one as 'All'
            DataCategory [] toplevelCategories = 	singleResult.getTopCategories();
            //Recursively get all the categories
            allDataCategories.addAll(getAllCategories(toplevelCategories));           
         }
         return allDataCategories;
    }

     private static DataCategory[] getAllCategories(DataCategory [] categories){
        if(categories.isEmpty()){
           return new DataCategory[]{};
        } 
		//This is reptitive to get the first catgory in the heirachy to process
		//1. First it is cloned 
	    DataCategory [] categoriesClone = categories.clone();
		//2. The highest parent is picked with its heirarchy		
	    DataCategory category = categoriesClone[0];
		//3. That parent is added in flat list below
	    DataCategory[] allCategories = new DataCategory[]{category};
	   
	    //This is to remove the top first record which is already processed
	    //since this is iterative in nature to process all categories one by one 
	    //As categoriesClone is populated once and same is
	    // passed in next call to getAllCategories it is required to remove the already processes categ;
	    categoriesClone.remove(0);
	    categoriesClone.addAll(category.getChildCategories());
		
		//The children also added in same flat list
	    allCategories.addAll(getAllCategories(categoriesClone));
	    
		return allCategories;
        
     }
     //Get unique names and labels of all data categories except the top most level
     public static void getLabelAndNames(List<DataCategory> pdataCatgs){
        for(DataCategory category : pdataCatgs) {            
            mapOfDCs.put(category.getName()+'__c',category.getLabel());			
            //Get the list of sub categories in the category
            DataCategory [] childCategories =   category.getChildCategories();
            if(!childCategories.isEmpty()){
                getLabelAndNames(childCategories);
            }
        }              
     }
}
