/**
Created by Sudhakar 31/4/2020
*/

public inherited sharing class dh_RuleConfiguration {

    public PickListConfiguration pickListConfiguration;
	public List<SelectedPicklistValues> selectedPicklistValues;
	public String currentRecordId;
	public String picklistFieldAPIName;
	public String sObjectName;

	public class Actions {
		public String operator;
		public String value;
	}

	public class PickListConfiguration {
		public String pickListApiName;
		public String fieldsToQueryAPIName;
		public List<Rules> rules;
	}

	public class SelectedPicklistValues {
		public String field;
		public String value;
	}

	public class Rules {
		public List<Conditions> conditions;
		public List<Actions> actions;
	}

	public class Conditions {
		public String attribute;
		public String operator;
		public String value;
	}

    public static dh_RuleConfiguration deserialize( String serializedString ){
        return (dh_RuleConfiguration) JSON.deserialize( serializedString, dh_RuleConfiguration.class );
    }
}