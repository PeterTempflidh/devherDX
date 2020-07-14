/**
* @author Chaitali Kumari
* @date 29.05.2019
*
* @description Selector class for retrieving Attachment records
*/
public with sharing class AttachmentSelector {

    /*******************************************************************************************************
    * @description Query for Attachment record based on Opportunity Id.
    * @param keys Opportunity Id, Quote Name
    * @return List of attachments
    */

    public static List<Attachment> getAttachmentsForOpportunity (final string paramOppId, final string paramQuoteName) {
        List<Attachment> listAttach = new List<Attachment>();
        try {
            listAttach = [select body,Name,ContentType from Attachment where parentId = :paramOppId and Name =:paramQuoteName];
        } catch (QueryException e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return listAttach;
    }



    /*******************************************************************************************************
    * @description Query for Document record based document name.
    * @param keys list of document names
    * @return List of documents
    */

    public static List<Document> getDocumentsByName (final List<String> attachmentNames) {
        List<Document> listAttach = new List<Document>();
        try {
            listAttach = [SELECT ContentType, Name, Body FROM Document WHERE DeveloperName IN :attachmentNames];
        } catch (QueryException e) {
            system.debug('Error: '+e.getMessage());
            LoggingUtility.commitLogs();
        }
        return listAttach;
    }


    /*******************************************************************************************************
    * @description Query for Document record based document name.
    * @param keys String document name
    * @return document
    */

    public static Document getDocumentByName (final String attachmentName) {
        List<Document> documents = AttachmentSelector.getDocumentsByName(new List<String>{attachmentName});

        if (documents.isEmpty()) {
            return null;
        }

        return documents.get(0);
    }


}