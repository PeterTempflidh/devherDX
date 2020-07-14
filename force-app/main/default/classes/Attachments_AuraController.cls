/**
* @author Konrad Czykin
* @date 06.08.2019
* @description Controller for uploading files lightning components
*/
public with sharing class Attachments_AuraController {
    
    /*****************************************************************************
    * @description Query for files related to record
    * @param objectId
    * @return List of uploaded files 
    *******************************************************************************/
    @AuraEnabled
    public static List<attWrapper> getAttachments(String recordId) {
        List<ContentVersion> lstAtts = new List<ContentVersion>();
        List<ContentDocumentLink> lstLinks = new List<ContentDocumentLink>();
        List<attWrapper> lstWrapper = new List<attWrapper>();
        List<String> lstFilesId = new List<String>();  //Ids of ContentDocuments belonged to a record

        Id objectId = Id.valueOf(recordId);
        String sObjectType = objectId.getSObjectType().getDescribe().getName();
        List<sObject> lstObject = ContentVersion_Selector.getObjects(objectId);
        String objectName = '';

        try{
            if(sObjectType == 'Case'){
                objectName = (String)lstObject[0].get('CaseNumber');
            }else{
                objectName = (String)lstObject[0].get('Name');
            }
        }
        catch(Exception e){
            system.debug('Error: '+ e.getMessage());
            LoggingUtility.commitLogs();
            return lstWrapper;
        }
        

        lstLinks = ContentVersion_Selector.getContentDocumnetLink(recordId);

        if(!lstLinks.isEmpty()){
            for(ContentDocumentLink link : lstLinks){
                lstFilesId.add(link.ContentDocumentId);
            }
            
            lstAtts = ContentVersion_Selector.getContentVersion(lstFilesId);
    
            for(ContentVersion cv : lstAtts){
                lstWrapper.add(new attWrapper(cv, objectName));
            }
        }

        if(lstObject[0].getSObjects('Attachments') == null || lstObject[0].getSObjects('Attachments').size() == 0){
            return lstWrapper;
        }

        List<Attachment> lstAttachments = (List<Attachment>)lstObject[0].getSObjects('Attachments');
        
        for(Attachment att : lstAttachments){
            lstWrapper.add(new attWrapper(att));
        }

        return lstWrapper;
    }
  
    /*****************************************************************************
    * @description Query for picklist values of Attachment_Type__c field on ContentVersion object
    * @param no params
    * @return List of picklistvalues
    *******************************************************************************/
    @AuraEnabled
    public static List<String> getAttTypePicklistValues(){
        List<String> lstAttTypes = new List<String>();
        Schema.DescribeFieldResult fieldResult = ContentVersion.Attachment_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry plVal : ple){
            lstAttTypes.add(plVal.getLabel());
        }
        return lstAttTypes;
    }

    /*****************************************************************************
    * @description method updates the ContentVersion with Attachment Type and Halal Certificate Date 
    * @param objectId, list of contentdcumentids, string of maptypes
    *******************************************************************************/
    @AuraEnabled
    public static void saveFile(Id parentId, List<String> contentDocIds, String mapOfTypes) {

        Boolean updateAccount = false;
        Date halalDate;
        String objectName =  parentId.getSObjectType().getDescribe().getName();
        String accId = '';
        List<Account> lstAcc = new List<Account>();
        
        List<MapOfTypes> lstMapOfTypes = (List<MapOfTypes>)JSON.deserializeStrict(mapOfTypes, List<MapOfTypes>.class);
    
        for(MapOfTypes mot : lstMapOfTypes){
            if(String.valueOf(mot.halalDate) != 'null' && (halalDate == null || mot.halalDate > halalDate)){
                updateAccount = true;
                halalDate = mot.halalDate;
            }
        }

        List<ContentVersion> cv = ContentVersion_Selector.getContentVersion(contentDocIds);

        if(objectName == 'Account'){
            accId = parentId;
        }else{
            List<sObject> lstObjects = ContentVersion_Selector.getObjects(parentId);
            String strObject = JSON.serialize(lstObjects[0]);
            ObjectClass obj = (ObjectClass)JSON.deserialize(strObject, ObjectClass.class);
            accId = obj.AccountId;
        }

        if(updateAccount && String.isNotBlank(accId)){
            lstAcc = ContentVersion_Selector.getAccounts(accId);
        }

        if(!lstAcc.isEmpty() && halalDate != null){
            lstAcc[0].Halal_Certificate_Expiry_Date__c = halalDate;
        }

        for(ContentVersion c : cv){
            for(MapOfTypes mot : lstMapOfTypes){
                if(mot.docId == c.ContentDocumentId){
                    c.Attachment_Type__c = String.join(mot.lstAtt, ';');
                    c.Halal_Certificate_Expiry_Date__c = mot.halalDate;
                    break;
                }
            }
        }
    
        try{
            update cv;
        }catch(DmlException d){
            System.debug('Exception during ContentVersion update ' + d.getMessage());
        }

        if(!updateAccount || lstAcc.size() == 0) return;
        
        try{
            update lstAcc[0];
        }catch(DmlException d){
            System.debug('Exception during Account update ' + d.getMessage());
        }
    }

    /*****************************************************************************
    * @description delete file when user click bucket and want to remove the file. Button on File Upload Component
    * @param list of ContentDocumentIds
    *******************************************************************************/
    @AuraEnabled
    public static void deleteFile(List<String> docIds){
        List<ContentDocument> lstCV = new List<ContentDocument>();
        for(String docId : docIds){
            ContentDocument cv = new ContentDocument(Id = docId);
            lstCV.add(cv);
        }
        try{
            delete lstCV;
        }catch(DMLException e){
            system.debug('The following error occured during file deletion: ' +  e.getMessage());
        }
    }

    @TestVisible
    private class attWrapper{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String contentdocumentid;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String fielextension;
        @AuraEnabled
        public String attachmenttype;
        @AuraEnabled
        public String formatteddate;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String createdby;
        @AuraEnabled
        public String contentsize;

            private attWrapper(ContentVersion cv, String name){
                this.id = cv.Id;
                this.contentdocumentid = cv.ContentDocumentId;
                this.title = cv.Title;
                this.fielextension = cv.FileExtension;
                this.attachmenttype = cv.Attachment_Type__c;
                this.formatteddate = String.valueOf(cv.ContentModifiedDate.format());
                this.createdby = cv.createdBy.Name;
                this.name = name;
                Decimal sizeInt = ((Decimal)cv.ContentSize/1024).round(System.RoundingMode.HALF_UP);
                String size = String.valueOf(sizeInt) + 'KB';
                this.contentsize = size;
            }

            private attWrapper(Attachment att){
                this.contentdocumentid = att.Id; 
                this.title = att.Name;
                this.fielextension = 'Attachment';
                this.formatteddate = String.valueOf(att.LastModifiedDate.format());
                this.createdby = att.CreatedBy.Name;
                this.contentsize = String.valueOf(((Decimal)att.BodyLength/1024).round(System.RoundingMode.HALF_UP)) + 'KB';
            }
    }

    @TestVisible
    private class MapOfTypes{
        private String docId;
        private List<String> lstAtt;
        private Date halalDate;
        private Boolean halalBolean;
        private String name;
    }

    @TestVisible
    private class ObjectClass{
        private String AccountId;
    }
}
