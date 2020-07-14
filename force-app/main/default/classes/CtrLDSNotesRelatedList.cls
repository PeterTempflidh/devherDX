/**
 * Controller class for LDSNotesRelatedList
 * Handles CRUD operations on Notes related to SObject record
 */
public with sharing class CtrLDSNotesRelatedList {

	/**
	 * Retrieves Note records related to specified parentId
	 * @param  parentId Notes' pranteId
	 * @return          A list of Note or an empty list
	 */
	@RemoteAction
	public static List<Note> retrieve(String parentId) {
		System.debug('CtrLDSNotesRelatedList.retrieve: start. ParentId is: ' + parentId);

		if (String.isBlank(parentId)) {
			return new List<Note>();
		}

		return [
		           Select
		           Title,
		           Body,
		           LastModifiedBy.Name
		           From Note
		           Where ParentId = : parentId
		                            Order By LastModifiedDate DESC
		       ];
	}

	/**
	 * Create or update a new note
	 * @param  id       Note id, empty if is a new Note
	 * @param  title    Note's title
	 * @param  body     Note's body
	 * @param  parentId Parent record id
	 * @return          Return new or update Note record or null.
	 */
	@RemoteAction
	public static Note upsertNote(String id, String title, String body, String parentId) {
		System.debug('CtrLDSNotesRelatedList.upsertNote: start. Id is: ' + id + ' - parent id is: ' + parentId);

		if (String.isBlank(parentId)) {
			return null;
		}

		Note n = new Note(
		    Title = title,
		    Body = body,
		    ParentId = parentId);

		// checks if id is not null
		n.Id = String.isNotBlank(id) ? id : null;

		System.debug('CtrLDSNotesRelatedList.upsertNote: upserting note: ' + n);
		upsert n;

		System.debug('CtrLDSNotesRelatedList.upsertNote: upserted note is: ' + n);
		return n;
	}

	/**
	 * Delete a Note
	 * @param id Note's id
	 */
	@RemoteAction
	public static void deleteNote(String id) {
		System.debug('CtrLDSNotesRelatedList.deleteNote: start. Id is: ' + id);
		if (String.isNotBlank(id)) {
			delete [Select Id From Note where Id =: id];
		}
	}
}