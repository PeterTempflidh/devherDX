public with sharing class CtrLDSDownloadAllAttachments {

	/**
	 * Retrieves all Attachment records related to a given record id, without
	 * the Body content
	 * @param  recordId Parent record id
	 * @return          A list of Attachment records or an empty list
	 */
	@RemoteAction
	public static List<Attachment> getAttachments(String recordId) {
		System.debug('CtrLDSDownloadAllAttachments.getAttachments: start, recordId is: ' + recordId);

		if (String.isBlank(recordId)) {
			return new List<Attachment>();
		}

		System.debug('CtrLDSDownloadAllAttachments.getAttachments: getting attachment list...');

		return [SELECT
		        Name,
		        ContentType,
				BodyLength,
		        LastModifiedDate,
		        LastModifiedBy.Name
		        FROM Attachment
		        WHERE ParentId = : recordId];
	}

	/**
	 * Retrieves specified Attachment record along with his body content
	 * @param  attachmentId Attachment record id
	 * @return              Specified Attachment record or null
	 */
	@RemoteAction
	public static BodyWrapper getAttachmentBody(String attachmentId) {
		System.debug('CtrLDSDownloadAllAttachments.getAttachmentBody: start, attachmentId is: ' + attachmentId);

		if (String.isBlank(attachmentId)) {
			return null;
		}

		Attachment res = [SELECT Id, Body FROM Attachment WHERE Id = : attachmentId];

		System.debug('CtrLDSDownloadAllAttachments.getAttachmentBody: retrieved attachment is: ' + res);
		return new BodyWrapper(res);
	}

	/**
	 * @description Retrieves specified Attachment record along with his partial body content, usable for when the attachment size is large to overcome 15MB response limit. This method processes attachments up to 19MB.
	 * @param attachmentId String
	 * @param splitSize Integer amount into which the body of the attachment should be split into
	 * @param splitPart Integer which part of the split body should be returned eg. if attachment is split into 5 parts, return 3rd part.
	 * @return bodyWrapper BodyWrapper
	 */
	@RemoteAction
	public static BodyWrapper getPartialAttachmentBody(String attachmentId, Integer splitSize, Integer splitPart) {
		BodyWrapper bodyWrapper = getAttachmentBody(attachmentId);
		Integer bodySize = bodyWrapper.Body.length();
		Integer sliceStart = bodySize/splitSize * (splitPart-1);
		Integer sliceEnd = splitSize == splitPart ? bodySize : sliceStart + bodySize/splitSize;
		bodyWrapper.Body = bodyWrapper.Body.substring(sliceStart, sliceEnd);
		return bodyWrapper;
	}

	public class BodyWrapper {
		public String Id {get; set;}
		public String Body {get; set;}
		public BodyWrapper(Attachment att) {
			this.Id = att.Id;
			this.Body = EncodingUtil.base64Encode(att.Body);
		}

		@testVisible
		private Boolean equals(BodyWrapper comparable) {
			return this.Id.equals(comparable.Id) && this.Body.equals(comparable.Body);
		}
	}
}