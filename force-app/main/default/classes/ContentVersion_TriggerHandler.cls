/**
 * Class ContentVersion Handler
 *
 * Trigger Handler for the ContentVersion SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public class ContentVersion_TriggerHandler implements ITrigger{

    private List<ContentVersion> lstContentVs   = new List<ContentVersion>();
    private List<Account> lstAccToUpdate	    = new List<Account>();
    private Map<Id, ContentDocumentLink> mapCdL = new Map<Id, ContentDocumentLink>();
    private Map<Id, Date> mapIdHalalDate        = new Map<Id, Date>();
    private Map<Id, Id> mapCdIdAccId            = new Map<Id, Id>();

    public ContentVersion_TriggerHandler(){
    }

    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     *
     * NOTE: This method also performs bulk before oprations 
     */
    public void bulkBefore(){	
    	Boolean fetchContentVersions = false;
    	
    	if(Trigger.isInsert){
    		fetchContentVersions = true;
    	}
    	
    	/**
    	* Fetch the ContentVersions. The fetched records are used accross the trigger.
    	*/
    	if(fetchContentVersions){
    		// Fetch all the against against the opportunities		
            lstContentVs = ContentVersion_Utils.getContentVersions((List<ContentVersion>)Trigger.New);
	    ContentVersion_Utils.checkDuplicateFilesOnQuote((List<ContentVersion>)Trigger.New); //SSC-3048
    	}
    }
	
	/**
     * bulkAfter
     *
     * This method is called prior to execution of an AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     *
     * NOTE: This method also performs some bulk operations
     */
    public void bulkAfter(){
        Boolean fetchObjects = false;
    	
        if(Trigger.isUpdate){
            fetchObjects = true;
        }

        if(fetchObjects){
            mapIdHalalDate  = ContentVersion_Utils.getContentHalalDate(Trigger.New, Trigger.oldMap);
            mapCdL          = ContentVersion_Utils.getContentDocumentLinks(mapIdHalalDate.keySet());
            mapCdIdAccId    = ContentVersion_Utils.getSObjectsIdsToUpdate(mapCdL);
            lstAccToUpdate  = ContentVersion_Utils.getSObjectToUpdate(mapIdHalalDate, mapCdIdAccId);
        }
    }

	/**
     * beforeInsert
     *
     * This method is called iteratively for each record to be inserted during a BEFORE
     * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
     */
    public void beforeInsert(SObject so){
        ContentVersion cv = (ContentVersion)so;
        if(cv.ContentDocumentId == null) return;
        ContentVersion_Utils.updateAttachmentType(cv, lstContentVs);
    }
	
	/**
     * beforeUpdate
     *
     * This method is called iteratively for each record to be updated during a BEFORE
     * trigger.
     */
    public void beforeUpdate(SObject oldSo, SObject so){
    
    }

    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so){

    }
	
	/**
     * afterInsert
     *
     * This method is called iteratively for each record inserted during an AFTER
     * trigger. Always put field validation in the 'After' methods in case another trigger
     * has modified any values. The record is 'read only' by this point.
     */
    public void afterInsert(SObject so){

    }
	
	/**
     * afterUpdate
     *
     * This method is called iteratively for each record updated during an AFTER
     * trigger.
     */
    public void afterUpdate(SObject oldSo, SObject so){
        
    }
	
	/**
     * afterDelete
     *
     * This method is called iteratively for each record deleted during an AFTER
     * trigger.
     */
    public void afterDelete(SObject so){

    }

    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     
     NOTE: List<SObject> only supports insert,update and delete operation. Upsert operation is not supported. Seperating
     		the sobject list before.
     */
    public void andFinally(){
    	List<Account> sobjectsToBeUpdated = new List<Account>();

        if(lstAccToUpdate.size() == 0) return;
        
        for(Account acc : lstAccToUpdate){
            if(acc.id != null){
                sobjectsToBeUpdated.add(acc);
            }
        }
			
        if(sobjectsToBeUpdated.size() > 0)
            update sobjectsToBeUpdated;
    }
}
