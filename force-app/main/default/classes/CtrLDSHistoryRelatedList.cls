/**
 * Controller for LDSHistoryRelatedList component.
 */
public with sharing class CtrLDSHistoryRelatedList {

	// table to query
	public String historyObject 	{get; set;}

	// field to filter for
	public String parentField 		{get; set;}

	// parent object
	public String parentObject 		{get; set;}

	// parent record id
	public String parentReocrd 		{get; set;}

	// list to render on the page
	public List<HistoryWrapper> historyRecords {get; private set;}

	// query offset used for pagination
	public Integer offsetSize		{get; set;}

	// query limit
	public Integer baseListSize 	{get; set;}

	// dynamic query to execute
	private String query {
		get {
			return 'SELECT OldValue, NewValue, Field, CreatedBy.Name, CreatedDate' +
			' FROM ' + historyObject +
			' WHERE ' + parentField + ' = \'' + parentReocrd + '\'' +
			' ORDER BY CreatedDate DESC' +
			' LIMIT ' + baseListSize +
			' OFFSET ' + offsetSize;
		}
	}

	public CtrLDSHistoryRelatedList() {
		System.debug('CtrLDSHistoryRelatedList.init: start');
		offsetSize = 0;
		baseListSize = 5;
		historyRecords = new List<HistoryWrapper>();
		System.debug('CtrLDSHistoryRelatedList.init: done');
	}

	public PageReference loadAllRecords() {
		baseListSize = 10000; // should be enough... who is going through such a list
		loadRecords();
		baseListSize = 5;
		return null;
	}

	/**
	 * Load next bunch of history records
	 * @return always null
	 */
	public PageReference loadRecords() {
		System.debug('CtrLDSHistoryRelatedList.loadRecords: start. offsetSize is: ' + offsetSize);

		try {
			System.debug('CtrLDSHistoryRelatedList.loadRecords: parentObject is: ' + parentObject + ' and parentReocrd is: ' + parentReocrd);

			sObject record = Database.query('SELECT Id FROM ' + parentObject + ' WHERE Id =\'' + parentReocrd + '\'');

			Map<String, Schema.SObjectField> fieldMap = record.getSobjectType().getDescribe().fields.getMap();

			for (HistoryWrapper wrap : getHistory(query)) {
				if (wrap.isValid(fieldMap)) {
					historyRecords.add(wrap);
				}
			}

			offsetSize += baseListSize;
		} catch (Exception ex) {
			System.debug('CtrLDSHistoryRelatedList.loadRecords: exception occurred. Message is: ' + ex.getMessage() + '. Stacktrace is: ' + ex.getStackTraceString());
			// reset history records
			historyRecords = new List<HistoryWrapper>();
		}

		System.debug('CtrLDSHistoryRelatedList.loadRecords: done');
		return null;
	}

	/**
	 * Execute specified query to retrieve history fields and make some formal
	 * checks on values returned
	 * @param  q Query to execute
	 * @return   A list of HistoryWrapper or an empty list
	 */
	private List<HistoryWrapper> getHistory(String q) {
		System.debug('CtrLDSHistoryRelatedList.history: start. query is: ' + q);

		List<HistoryWrapper> res = new List<HistoryWrapper>();

		if (Test.isRunningTest()) {
			res = mockHistoryFields;
		}

		// this query during test returns no records
		for (sObject h : Database.query(q)) {
			res.add(new HistoryWrapper(h));
		}

		System.debug('CtrLDSHistoryRelatedList.history: done. res is: ' + res);
		return res;
	}

	/**
	 * History record wrapper
	 */
	public class HistoryWrapper {
		public String oldVal 		{get; set;}
		public String newVal 		{get; set;}
		public String field 		{get; set;}
		public String createdBy 	{get; set;}
		public String createdDate   {get; set;}
		public HistoryWrapper() {}
		public HistoryWrapper(sObject h) {
			oldVal = String.valueOf( h.get('OldValue') );
			newVal = String.valueOf( h.get('NewValue') );
			field = String.valueOf( h.get('Field') );
			createdBy = Test.isRunningTest() ? 'fake' : (String) h.getSobject('CreatedBy').get('Name');
			createdDate = Test.isRunningTest() ? 'fake' : ( (Datetime) h.get('CreatedDate') ).format('dd.MM.yyyy HH:mm');
		}

		/**
		 * Checks if current HistoryWrapper is a valid history record that could be displayed.
		 * If so format oldVal and newVal according to their type
		 * @param  parentFieldMap Parent sObject fields map
		 * @return                true if this is a valid history record that could
		 * be displayed, false otherwise
		 */
		public Boolean isValid(Map<String, Schema.SObjectField> parentFieldMap) {
			System.debug('CtrLDSHistoryRelatedList.HistoryWrapper.isValid: start. Field is: ' + field + ' - Old is: ' + oldVal + ' - New is: ' + newVal);

			if (String.isBlank(oldVal) && String.isBlank(newVal) && !parentFieldMap.containsKey(field)) {
				return false;
			}

			try {
				Id.valueOf(oldVal);
				return false;
			} catch (Exception ok) {}

			try {
				Id.valueOf(newVal);
				return false;
			} catch (Exception ok) {}

			/* Ok, ok... I know what you are thinking... last two try statements
			makes no sense but wait let explain myself.. that's because lookup fields are inserted
			twice in history tables. Once with the Id value and once with the
			record name. In this way I'm skipping the Id value */

			// checks if field exist in parent maps
			field = parentFieldMap.containsKey(field) ? field : field + 'Id'; // could be a std lookup field

			// checks again
			if (!parentFieldMap.containsKey(field)) {
				System.debug('CtrLDSHistoryRelatedList.HistoryWrapper.isValid: field not in map');
				return false;
			}

			Schema.DescribeFieldResult fieldDesc = parentFieldMap.get(field).getDescribe();

			// transcode the field
			if (fieldDesc.getType() == Schema.DisplayType.Date) {
				oldVal = String.isNotBlank(oldVal) ? formatDate(oldVal) : oldVal;
				newVal = formatDate(newVal);
			} else if (fieldDesc.getType() == Schema.DisplayType.Datetime) {
				oldVal = String.isNotBlank(oldVal) ? formatDateTime(oldVal) : oldVal;
				newVal = formatDateTime(newVal);
			} else if (fieldDesc.getType() == Schema.DisplayType.Picklist) {
				oldVal = String.isNotBlank(oldVal) ? translatePicklistValue(oldVal, fieldDesc.getPicklistValues()) : oldVal;
				newVal = translatePicklistValue(newVal, fieldDesc.getPicklistValues());
			}

			return true;
		}

		private String formatDate(String dateString) {
			return Date.valueOf(dateString).format();
		}

		private String formatDateTime(String dateTimeString) {
			return Datetime.valueOf(dateTimeString).format();
		}

		private String translatePicklistValue(String val, List<Schema.PicklistEntry> all) {
			String res;
			for (Schema.PicklistEntry e : all) {
				if (e.getValue() == val) {
					res = e.getLabel();
					break;
				}
			}
			return res;
		}
	}

	/**
	 * Used only in unit test to feed in mock history records
	 */
	@testVisible
	private transient List<HistoryWrapper> mockHistoryFields;
}