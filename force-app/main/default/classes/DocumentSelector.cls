/**
* @author Aleksejs Jedamenko
* @date 01.10.2019
*
* @description Selector class for Document object
*/
public class DocumentSelector {

    /*****************************************************************************
    * @description Query for Document by Developer Name
    * @param developer name
    * @returnL Document record
    *******************************************************************************/
    public static Document getDocumentByDeveloperName(String docDevName){
        Document doc = new Document();
        try {
            doc = [SELECT Id, ContentType, Name, Body FROM Document WHERE DeveloperName = :docDevName LIMIT 1];
        } catch (QueryException e) {
            system.debug('Error: '+ e.getMessage());
        }
        return doc;
    }

    /*****************************************************************************
    * @description Query for Document by Set of Developer Name
    * @param Set<String> - Set of Documents developer names
    * @return Map<String, Document>
    *******************************************************************************/
    public static Map<Id, Document> getDocumentByDeveloperName(Set<String> docDevNameSet){
        Map<Id, Document> documentMap = new Map<Id, Document>([
            SELECT Id, ContentType, Name, Body FROM Document WHERE DeveloperName IN: docDevNameSet
        ]);

        return documentMap;
    }

    /*****************************************************************************
    * @description Query for Document by set of ids
    * @param set of ids
    * @returnL List of Document records
    *******************************************************************************/
     public static List<Document> getDocumentsByIds(Set<Id> docIdSet){ 
        List<Document> docs = new List<Document>();
        try {
            docs = [SELECT Id, ContentType, Name, Body FROM Document WHERE Id in :docIdSet];
        } catch (QueryException e) {
            system.debug('Error: '+ e.getMessage());
        }
        return docs;
    }
}