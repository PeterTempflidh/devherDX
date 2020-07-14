/**
* @author Konrad Czykin
* @date 14.08.2019
*
* @description Selector class for retrieving contentversions, object's records for Attachments_AuraController.cls
*/
public class ContentVersion_Selector {
	
    /*Constants used in Contentversion trigger */
    public static final String FILE_TYPE_PDF = '.pdf';
    public static final String QUOTE_FILENAME_PREFIX = 'Contract - '; // THis prefix should always match with the delivery option File name mentioned in the Docgen package
     public static final String FILE_TYPE_SNOTE = 'snote';

    /*****************************************************************************
    * @description Query for ContendDocument by title and file extension 
    * @param title of the document
    * @param file extension of the document
    * @return List of ContentDocument records
    *******************************************************************************/
	/*
    public static List<ContentDocument> getContentDocumentByTitleAndExtension(String title, String fileExtension){
        List<ContentDocument> lstContentDocuments = new List<ContentDocument>();
        try {
              lstContentDocuments = [SELECT Id, Title, FileExtension FROM ContentDocument WHERE Title =:title AND FileExtension = :fileExtension LIMIT 1]; 
        } catch (QueryException e) {
            system.debug('Error: '+ e.getMessage());
        }
        return lstContentDocuments;
    } */

     /*****************************************************************************
    * @description Query for ContendDocument by id
    * @param set of ids
    * @return List of ContentDocument records
    *******************************************************************************/
	/*
    public static List<ContentDocument> getContentDocumentByIds(Set<Id> ids){
        List<ContentDocument> lstContentDocuments = new List<ContentDocument>();
        try {
              lstContentDocuments = [SELECT Id, Title, FileExtension FROM ContentDocument WHERE Id in :ids]; 
        } catch (QueryException e) {
            system.debug('Error: '+ e.getMessage());
        }
        return lstContentDocuments;
    }*/

     /*****************************************************************************
    * @description Query for ContendVersion including Body
    * @param set of ids
    * @return List of ContentVersions records
    *******************************************************************************/
	/*
    public static List<ContentVersion> getContentVersionWithBody(Set<Id> contentDocumentIds){
        List<ContentVersion> lstContentVersion = new List<ContentVersion>();
        try {
              lstContentVersion = [SELECT Id, IsLatest, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId in :contentDocumentIds AND IsLatest = true]; 
        } catch (QueryException e) {
            system.debug('Error: '+ e.getMessage());
        }
        return lstContentVersion;
    }*/
    /*****************************************************************************
    * @description Query for ContentDocumentLink object Id.
    * @param objectId
    * @return List of ContentDocumentLink
    *******************************************************************************/
    public static List<ContentDocumentLink> getContentDocumnetLink(String recordId){
        return [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
    }
	
     /*****************************************************************************
    * @description Query for ContentDocumentLink obect by id and file name
    * @param objectId
    * @return List of ContentDocumentLink
    *******************************************************************************/
    public static List<ContentDocumentLink> getContentDocumnetLink(String recordId, String fileName){
        return [SELECT ContentDocumentId, ShareType, Visibility, ContentDocument.LatestPublishedVersionId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :recordId AND ContentDocument.Title = :fileName];
    }
     /*****************************************************************************
    * @description Query for ContentDocumentLink obect by content document 
    * @param objectId
    * @return List of ContentDocumentLink
    *******************************************************************************/
    public static List<ContentDocumentLink> getContentDocumnetLinksWithLatestVersionBody(Set<Id> recordIds){
       
        return [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE ContentDocumentId IN :recordIds];

    }

    /*****************************************************************************
    * @description Query for ContentVersion Ids
    * @param list of contentDocumentIds
    * @return List of ContentVersions records
    *******************************************************************************/
    public static List<ContentVersion> getContentVersion(List<String> lstFilesId){
   
        return [SELECT Id, ContentDocumentId, Title, FileExtension, Attachment_Type__c, 
                                    ContentModifiedDate, CreatedBy.Name, ContentSize, Halal_Certificate_Expiry_Date__c
                                FROM ContentVersion 
                                WHERE IsLatest = true AND FileType != :FILE_TYPE_SNOTE AND ContentDocumentId IN :lstFilesId ORDER BY LastModifiedDate DESC];
    }

    /*****************************************************************************
    * @description Query for sObject
    * @param queryString
    * @return List of sObjects
    *******************************************************************************/
    public static List<sObject> getObjects(Id objectId){

        String sObjectName = objectId.getSObjectType().getDescribe().getName();
        String queryString = '';
        if(sObjectName =='Account'){
            queryString = 'SELECT Id, Name, (SELECT Id, Name, LastModifiedDate, ContentType, BodyLength, CreatedBy.Name FROM Attachments) FROM ' + sObjectName + ' WHERE Id =: objectId';
        }else if(sObjectName == 'Case'){
            queryString = 'SELECT CaseNumber, AccountId, (SELECT Id, Name, LastModifiedDate, ContentType, BodyLength, CreatedBy.Name FROM Attachments) FROM ' + sObjectName + ' WHERE Id =: objectId';
        }else if(sObjectName == 'Lead'){
            queryString = 'SELECT Name, (SELECT Id, Name, LastModifiedDate, ContentType, BodyLength, CreatedBy.Name FROM Attachments) FROM ' + sObjectName + ' WHERE Id =: objectId';
        }else if(sObjectName == 'Opportunity_Quote__c'){
            queryString = 'SELECT Name, Id_Account__c, (SELECT Id, Name, LastModifiedDate, ContentType, BodyLength, CreatedBy.Name FROM Attachments) FROM ' + sObjectName + ' WHERE Id =: objectId';
        }else{
            queryString = 'SELECT Name, AccountId, (SELECT Id, Name, LastModifiedDate, ContentType, BodyLength, CreatedBy.Name FROM Attachments) FROM ' + sObjectName + ' WHERE Id =: objectId';
        }

    
        return Database.query(queryString);
    }

    /*****************************************************************************
    * @description Query for Accounts
    * @param account Id
    * @return List of Accounts
    *******************************************************************************/
    public static List<Account> getAccounts(String parentId){
       
        return [SELECT Id, Halal_Certificate_Expiry_Date__c FROM Account WHERE Id = :parentId];
    }

    /*****************************************************************************
    * @description Query for ContentDocumentLinks
    * @param set of contentdocumentIds
    * @return List of ContentDocumentLink
    *******************************************************************************/
    public static List<ContentDocumentLink> getContentDocumentLinks(Set<Id> contentDocumentIds){
        List<ContentDocumentLink> lstCdL = new List<ContentDocumentLink>();
        lstCdL = [SELECT id, ContentDocumentID, LinkedEntity.type, LinkedEntityId 
                                    FROM ContentDocumentLink 
                                    WHERE ContentDocumentID IN :contentDocumentIds];
        return lstCdL;
    }
	
    /*****************************************************************************
    * @description Query to return documents based on file names
    * @param titleList list of all the filenames 
    * @return List of ContentDocuments
    *******************************************************************************/
    public static List<ContentDocument> getContentDocumentsFromTitles(List<String> titleList){
        List<ContentDocument> cdList = new List<ContentDocument>();
        cdList = [SELECT Id, Title FROM ContentDocument WHERE Title IN:titleList];
        return cdList;
    }
    
}
