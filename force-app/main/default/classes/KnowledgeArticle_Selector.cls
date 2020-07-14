/**
 * Created by p.bansal on 02-Jan-20.
 * Description: Query container class for Knowledge__kav
 */
public with sharing class KnowledgeArticle_Selector {
    //Get list of articles through SOQL on page load and SOSL on search
    public static List<Knowledge__kav> listOfArticles(String queryStr, Boolean isThroughSearch){

        List<Knowledge__kav> articlesList = new List<Knowledge__kav>();
        if(!isThroughSearch){
            for(Knowledge__kav art: Database.query(queryStr)){        
                articlesList.add(art);
            }            
        }else{
            Search.SearchResults searchResults = Search.find(queryStr);
            List<Search.SearchResult> articlelist = searchResults.get('Knowledge__kav');
            
            for(Search.SearchResult searchResult : articleList) { 
                Knowledge__kav article = (Knowledge__kav) searchResult.getSObject(); 
               articlesList.add(article);
            }
            
        }
        return articlesList ;
    }

}
