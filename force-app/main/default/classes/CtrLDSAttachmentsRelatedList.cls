/**
 * Controller for LDSAttachmentsRelatedList component.
 * Provides method to delete or upload new attachments
 */
public with sharing class CtrLDSAttachmentsRelatedList {

	public List<Attachment> attachments {
		get {
			return [
			    Select
			    Name,
			    ContentType,
			    LastModifiedById,
			    LastModifiedBy.Name
			    From Attachment
			    Where ParentId = : parentId];
		}
	}

	public String parentId {get; set;}

	public String toDelete {get; set;}

	public Attachment newAttachment {get; set;}

	public CtrLDSAttachmentsRelatedList() {
		newAttachment = new Attachment();
	}

	/**
	 * Insert a new attachment for parentId record
	 * @return always null
	 */
	public PageReference uploadAttachment() {
		System.debug('CtrLDSAttachmentsRelatedList.upload: start filename is: ' + newAttachment.Name);

		// set parent and insert
		newAttachment.ParentId = parentId;
		insert newAttachment;

		// reset attachment
		newAttachment = new Attachment();

		System.debug('CtrLDSAttachmentsRelatedList.upload: done');
		return null;
	}

	/**
	 * Delete an attachment. toDelete should contain the attachment id
	 * @return always null
	 */
	public PageReference deleteAttachment() {
		System.debug('CtrLDSAttachmentsRelatedList.delete: start. toDelete is: ' + toDelete);

		if (String.isNotBlank(toDelete)) {
			delete [Select Id From Attachment Where Id = : toDelete];
		}

		System.debug('CtrLDSAttachmentsRelatedList.delete: done');
		return null;
	}
}