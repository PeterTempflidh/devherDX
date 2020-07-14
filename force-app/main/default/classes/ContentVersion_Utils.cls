public class ContentVersion_Utils {

   /**
	@Description: This method query latest ContentVersions for ContentVersions in trigger. 
                    Method works only when ContentVersion from trigger is a new version of existing file
    @Input Params	: List of ContentVersions from trigger
    @Return			: List of ContentVersions (IsLatest) for ContentVersions in trigger
	*/
    public static List<ContentVersion> getContentVersions(List<ContentVersion> cvs){
        List<String> lstDocIds = new List<String>();
        List<ContentVersion> lstCVlast = new List<ContentVersion>();
        if(cvs == null || cvs.size() == 0) return lstCVlast;

        for(ContentVersion cv : cvs){
            if(cv.ContentDocumentId != null){
                lstDocIds.add(cv.ContentDocumentId);
            }
        }
        lstCVlast = ContentVersion_Selector.getContentVersion(lstDocIds);
        
        return lstCVlast;
    }

   /**
	@Description: This method updates Attachment_Type field on ContentVersion 
    @Input Params	: List of ContentVersions from trigger, list of latest ContentVersions
    @Return			: no return. 
	*/
    public static void updateAttachmentType(ContentVersion cvT, List<ContentVersion> lstCVlast){
        if(lstCVlast == null || lstCVlast.size() == 0) return;
        for(ContentVersion cvLast : lstCVlast){
            if(cvLast.ContentDocumentId == cvT.ContentDocumentId && cvLast.Attachment_Type__c != null){
                cvT.Attachment_Type__c = cvLast.Attachment_Type__c;
                cvT.Halal_Certificate_Expiry_Date__c = cvLast.Halal_Certificate_Expiry_Date__c;
                break;
            }
        }
    }

   /**
	@Description: This method creates map of contentDocumentId and halal date for updated contentversions where Halal Date was changed 
    @Input Params	: List of ContentVersions from trigger, list of old ContentVersions from triiger
    @Return			: map od contentDocumentId and changed Halal Certificate Expiry Date 
	*/
    public static Map<Id, Date> getContentHalalDate(List<SObject> sobjects, Map<Id, SObject> oldSobjectMap){
        List<ContentVersion> newCV  	        = (List<ContentVersion>)sobjects;
      	Map<Id,ContentVersion> oldCVMap     	= (Map<Id,ContentVersion>)oldSobjectMap;
        Map<Id, Date> mapIdHalalDate            = new Map<Id, Date>();
        
        for(ContentVersion cv : newCV){
            if(cv.Halal_Certificate_Expiry_Date__c != oldCVMap.get(cv.Id).Halal_Certificate_Expiry_Date__c){
                mapIdHalalDate.put(cv.ContentDocumentId, cv.Halal_Certificate_Expiry_Date__c);
            }
        }
        
        return mapIdHalalDate;
    }

   /**
	@Description: This method creates map of contentDocumentId and ContentDocumentLink 
    @Input Params	: Set of contentDocumetIds
    @Return			: map od contentDocumentId and ContentDocumentLink
	*/
    public static  Map<Id, ContentDocumentLink> getContentDocumentLinks(Set<Id> setIds){
        List<ContentDocumentLink> lstCdLTemp    = new List<ContentDocumentLink>();
        Map<Id, ContentDocumentLink> mapCdL     = new Map<Id, ContentDocumentLink>();

        if(setIds.size() > 0){
            lstCdLTemp = ContentVersion_Selector.getContentDocumentLinks(setIds);
        }
        if(lstCdLTemp.size() == 0) return mapCdL;

        for(ContentDocumentLink cdl : lstCdLTemp){
            if(cdl.LinkedEntity.type == 'User') continue;
            mapCdL.put(cdl.ContentDocumentID, cdl);
        }
        return mapCdL;
    }

   /**
	@Description: This method creates map of contentDocumentId and account Id
    @Input Params	: Map of contentDocumentId and ContentDocumentLink
    @Return			: map od contentDocumentId and account Id
	*/
    public static Map<Id, Id> getSObjectsIdsToUpdate(Map<Id, ContentDocumentLink> mapCdl){
        Map<Id, Id> mapCdIdAccId        = new Map<Id, Id>();
        Map<Id, Id> mapCdIdCaseId       = new Map<Id, Id>();
        Map<Id, Id> mapCdIdOppId        = new Map<Id, Id>();
        Map<Id, Id> mapCdIdContactId    = new Map<Id, Id>();

        if(mapCdl.size() == 0) return mapCdIdAccId;

        for(Id cdId : mapCdl.keySet()){
            String type = mapCdl.get(cdId).LinkedEntity.type;
            if(type == 'Account' && mapCdl.get(cdId) != null && mapCdl.get(cdId).LinkedEntityId != null && 
                !mapCdIdAccId.values().contains(mapCdl.get(cdId).LinkedEntityId)){
                    mapCdIdAccId.put(cdId, mapCdl.get(cdId).LinkedEntityId);
            }
            if(type == 'Case') mapCdIdCaseId.put(cdId, mapCdl.get(cdId).LinkedEntityId);
            if(type == 'Contact') mapCdIdContactId.put(cdId, mapCdl.get(cdId).LinkedEntityId);
            if(type == 'Opportunity') mapCdIdOppId.put(cdId, mapCdl.get(cdId).LinkedEntityId);
        }

        List<Id> caseIds = mapCdIdCaseId.values();
        if(caseIds.size() != 0){
            Map<Id, Case> mapCases = new Map<Id,Case>([SELECT Id, AccountId FROM Case WHERE Id IN :caseIds]);
            
            for(Id cdId : mapCdIdCaseId.keySet()){
                Id caseId = mapCdIdCaseId.get(cdId);
                Id accId = mapCases.get(caseId).AccountId;
                if(mapCdIdAccId.values().contains(accId)) continue;
                mapCdIdAccId.put(cdId, accId);
            }
        }

        List<Id> oppIds = mapCdIdOppId.values();
        if(oppIds.size() > 0){
            Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>([SELECT Id, AccountId FROM Opportunity WHERE Id IN :oppIds]);
        
            for(Id cdId : mapCdIdOppId.keySet()){
                Id caseId = mapCdIdOppId.get(cdId);
                Id accId = mapOpp.get(caseId).AccountId;
                if(mapCdIdAccId.values().contains(accId)) continue;
                mapCdIdAccId.put(cdId, accId);
            }
        }

        List<Id> contactIds = mapCdIdContactId.values();
        if(contactIds.size() > 0){
            Map<Id, Contact> mapContact = new Map<Id, Contact>([SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds]);
            
            for(Id cdId : mapCdIdContactId.keySet()){
                Id caseId = mapCdIdContactId.get(cdId);
                Id accId = mapContact.get(caseId).AccountId;
                if(mapCdIdAccId.values().contains(accId)) continue;
                mapCdIdAccId.put(cdId, accId);
            }
        }

        return mapCdIdAccId;
    }

   /**
	@Description: This method creates list of accounts to update
    @Input Params	: Map of contentDocumentId and Halal Expiry Date, map of contentdocumentId and account Id
    @Return			: list of accounts to update. 
	*/
    public static List<Account> getSObjectToUpdate(Map<Id,Date> mapIdHalalDate, Map<Id,Id> mapCdIdAccId){
        List<Account> lstAccToUpdate = new List<Account>();
        for(Id cdId : mapCdIdAccId.keySet()){
            Account acc = new Account(Id = mapCdIdAccId.get(cdId),
                                    Halal_Certificate_Expiry_Date__c = mapIdHalalDate.get(cdId));
            lstAccToUpdate.add(acc);
        }
        return lstAccToUpdate;
    }
	
    /*****************************************************************************
    * @description Runs on before insert to stop inserting duplicate filenames on Opportunity Quote object
    * @param cvs All the newly inserted files
    *******************************************************************************/
    public static void checkDuplicateFilesOnQuote(List<ContentVersion> cvs){
       List<String> titleList = new List<String>(); 

       for(ContentVersion cv : cvs){
           if(cv.Title != null && cv.Title.endswith(ContentVersion_Selector.FILE_TYPE_PDF) && cv.Title.startswith(ContentVersion_Selector.QUOTE_FILENAME_PREFIX)){
            titleList.add(cv.Title);
           }       
       }

       List<ContentDocument> cdList = ContentVersion_Selector.getContentDocumentsFromTitles(titleList);

       if(!cdList.isEMpty()){
           List<String> duplicateFileNames = new List<String>();
           for(ContentDocument cd :cdList){
            duplicateFileNames.add(cd.Title);
           }

        throw new ContentVersionException(System.Label.duplicateFileNameError+' ' +String.Join(duplicateFileNames, ','));
       }
       
    }
	/*****************************************************************************
    * @description Extending exception class to throw errors
    *******************************************************************************/
    public class ContentVersionException extends Exception{}
	
}
