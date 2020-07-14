/**
* @author Preeti
* @date 16.03.2020
*
* @description Apex controller for custom knowledge lwc
*/
public with sharing class KnowledgeArticle_Controller {
	public static String fieldsSet = 'Id, Title, Summary, Article_Detail__c';
	public static Map<String,String> mapOfDCLabelAndNames = new Map<String,String>();
	public static Integer UIListCountLimit = Integer.valueOf(System.Label.List_count);	  

	/** @desc: Get the list of articles to show as suggested articles
	  * @param: record id from lightning page, Search key when someone searches for articles,
	  * Boolean to different to get articles list via search or on load , as both are diff in terms of queries.
	  * @result: List of Knowledge__kav records
	  */
    @AuraEnabled(cacheable = true)
    public static String getAllMatchingArticles(String objRecordId, String searchKey, Boolean isThroughSearch){
		Boolean useCaseObj =  FALSE ;
		String articlesListStr = '';
		String qryStr = '';
		List<Knowledge__kav> articleListWithDataCategory = new List<Knowledge__kav>();
		List<Knowledge__kav> articleList = new List<Knowledge__kav>();
		/* Articles to be shown on page load, either by Data Category(CLR3) or
		 * without data category if the count is less than 50
		 */
		if(!isThroughSearch){
			LiveChatTranscript liveChatTranscriptRecord = LiveChatTranscriptSelector.getChatCaseFieldsByChatTranscriptsId(objRecordId)[0];
			if(liveChatTranscriptRecord == null)     {	return System.Label.No_Result;}
			//If the CLR3 is not available on chat, then boolean to pick it from case(Precautionary step)	
			useCaseObj = !String.isEmpty(liveChatTranscriptRecord.CaseId) && !String.isEmpty(liveChatTranscriptRecord.Case.Case_Reason_Level_3__c)?TRUE:FALSE;
			
			if(useCaseObj){
				Case caseRecord =   CaseSelector.getCaseDetailsById(liveChatTranscriptRecord.CaseId);				
				articleList = getArticles(caseRecord, isThroughSearch,'');					
			}
			//Else run the search on CLR2 or CLR3 on chat
			else{
				articleList = getArticles(liveChatTranscriptRecord, isThroughSearch,'');				
			}
			articlesListStr = JSON.serialize(articleList);
		}else{
			articleList = getArticles(null, isThroughSearch,searchKey);
			articlesListStr = JSON.serialize(articleList);
		}
		if(String.isEmpty(articlesListStr)){
			articlesListStr = System.Label.No_Result;
		}
		return articlesListStr ;
    }
	/** @desc: Generate SOQL/SOSL for diff use cases, SOQL on load, SOSL on search
	  * @param: rec id, search key, boolean when search to generate SOSL else SOQL
	  * Data category filter to load the records first based on DC and 
	  * if count is less than 50 then without DC to a total of 50
	  * @result: SOQL/SOQL query string
	  */
	public static String getQuery(Sobject sobj, String pSearchKey, Boolean pisThroughSearch, Boolean withDCFilter){
		String caseReasLev3 = '';
		String CLR3dataCateg = '';
		String qryStr = '';
		//Get all the data categories unique names and labels
		mapOfDCLabelAndNames = DataCategory_Selector.getDescribeDCGStrucRes();
		
		if(sobj != null && !pisThroughSearch){
			qryStr = 'SELECT '+fieldsSet+ ' FROM Knowledge__kav ';
			Schema.SObjectType objType = sobj.getSObjectType();

			if(objType == Schema.Case.sObjectType){
				Case caseRecord = (Case)sobj;
				caseReasLev3 = caseRecord.Case_Reason_Level_3__c;
			}
			else if(objType ==  Schema.LiveChatTranscript.sObjectType){
				LiveChatTranscript liveChatTranscriptRecord = (LiveChatTranscript)sobj;
				caseReasLev3 = liveChatTranscriptRecord.Case_Reason_Level_3__c;
			}
			if(!String.isEmpty(caseReasLev3)){
				for(String s: mapOfDCLabelAndNames.keyset()){
					if(mapOfDCLabelAndNames.get(s) == caseReasLev3){
						CLR3dataCateg = s ;
					}
				}
			}

			if(!String.isEmpty(CLR3dataCateg) && withDCFilter){
				qryStr += ' WHERE PublishStatus = \'Online\' AND Language = \'en_US\'';
				qryStr += ' WITH DATA CATEGORY Case_Reasons__c AT '+CLR3dataCateg;
			}else if(!withDCFilter || String.isEmpty(CLR3dataCateg)){
				qryStr += 'WHERE Id NOT IN (SELECT ParentId FROM Knowledge__DataCategorySelection) AND ';
				qryStr += 'PublishStatus = \'Online\' AND Language = \'en_US\'';
			}
            qryStr += ' LIMIT '+UIListCountLimit;
			 
		}//When articles are searched
		else {
			if(pisThroughSearch && String.isEmpty(pSearchKey)){
				return '';
			}else{
				qryStr = 'FIND \'';
				qryStr += String.escapeSingleQuotes(pSearchKey)+'*\'';
				qryStr += ' IN ALL FIELDS RETURNING Knowledge__kav(id,Title,Summary,Article_Detail__c';
				qryStr += ' WHERE PublishStatus = \'Online\' AND Language = \'en_US\')'; 
				qryStr += ' LIMIT '+UIListCountLimit;
			}
		}
		return qryStr ;
	}

	/** @desc: Add the articles without Data Category if the count of artciles with Data
	  * Category is less than 50 as we want to show 50 articles on UI
	  * @param: articles with DC, articles without DC	 
	  * @result: Consolidated list of 50 articles
	  */
	  public static List<Knowledge__kav> updateOriginalList(List<Knowledge__kav> pArticleListWithDataCategory, List<Knowledge__kav> pArticleListWithoutDataCategory){
		List<Knowledge__kav> consolidatedList = new List<Knowledge__kav>();
		consolidatedList = pArticleListWithDataCategory;
		Set<Id> getPrevArtIds = new Set<Id>();
		for(Knowledge__kav prevListRec: pArticleListWithDataCategory){
			getPrevArtIds.add(prevListRec.Id);
		}
		//If there are no articles with Data Category matching the case reason selected, then just return the articles which do not have
		//any data category
		if(getPrevArtIds.isEmpty()){return pArticleListWithoutDataCategory;}
		
		for(Knowledge__kav newListRec: pArticleListWithoutDataCategory){
			if(!getPrevArtIds.isEmpty() && !getPrevArtIds.contains(newListRec.Id)){
				consolidatedList.add(newListRec);
			}
			if(consolidatedList.size()>UIListCountLimit){
				break ;
			}
		}
		return consolidatedList;
	}
	/** @desc: fetch the list of articles 
	  * @param: Case or chat object record depending on which object has CLR3	 
	  * @result: Articles list
	  */
	public static  List<Knowledge__kav> getArticles(Sobject caseOrChatObject, Boolean pIsThroughSearch, String pSearchKey){
		String qryStr = '';
		List<Knowledge__kav> articleListWithDataCategory = new List<Knowledge__kav>(); 
		List<Knowledge__kav> consolidatedFinalListOfArticles = new List<Knowledge__kav>();

		//Articles fetched on load  
		if(!pIsThroughSearch){
			qryStr = getQuery(caseOrChatObject,'', pIsThroughSearch, true);
			
			//Get the list of articles with Data Category Filter				
			articleListWithDataCategory = KnowledgeArticle_Selector.listOfArticles(qryStr, pIsThroughSearch);
			
			//IF the article count with data category is 0 or less than 50 then get the articles without any data category till 50
			Boolean fetchAdditionalRecs = (articleListWithDataCategory.isEmpty() || (!articleListWithDataCategory.isEmpty() && articleListWithDataCategory.size()<UIListCountLimit))?TRUE:FALSE;
			
            if(fetchAdditionalRecs){
				qryStr = getQuery(caseOrChatObject,'', pIsThroughSearch, false);                
				List<Knowledge__kav> articleListWithoutDataCategory = new List<Knowledge__kav>(); 
				articleListWithoutDataCategory = KnowledgeArticle_Selector.listOfArticles(qryStr, pIsThroughSearch);
                //Add it to original list till the count reaches 50
				consolidatedFinalListOfArticles = updateOriginalList(articleListWithDataCategory, articleListWithoutDataCategory);					
			
            }
			else{
				consolidatedFinalListOfArticles = articleListWithDataCategory;
			}
		}
		//Articles fetched on search
		else{
			qryStr = getQuery(null, pSearchKey, pIsThroughSearch, false);
			consolidatedFinalListOfArticles = KnowledgeArticle_Selector.listOfArticles(qryStr, pIsThroughSearch);
		}	
		return consolidatedFinalListOfArticles;
	}
	//Not good to set the cacheable as false, but is needed so that agents can see the updated results immediately after changing the case reason
	//There is a limit of 30 seconds to get the cache refreshed if there is already a call made to get data on UI.Hence, another call
	//to get updated list cannot be made within 30 seconds as cache expires only after 30  secs. Hence the cacheable is set to false to 
	//skip the 30 secs limit so that list gets updated immediately when case reason is selected.
	@AuraEnabled(cacheable = false)
    public static String getupdatedAllMatchingArticles(String objRecordId, String searchKey, Boolean isThroughSearch){
		String articlesList = getAllMatchingArticles(objRecordId, searchKey, isThroughSearch);
		return articlesList;
	}
	
}