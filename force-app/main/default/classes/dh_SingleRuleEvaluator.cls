/**
Created by Sudhakar 31/4/2020 */
// The single rule evaluator will take each rule and evaluate its different conditions and determine if they are true
// or false.
	public inherited sharing class dh_SingleRuleEvaluator implements dh_IRuleEvaluator {

	Map<String,String> selectedFieldValuesMap = new Map<String,String>();
	Map<String,String> fieldDataTypeMap = new Map<String,String>();
	dh_RuleConfiguration inputRules;
	List<sObject> currentRecord;
	Set<String> supportedOperator = new Set<String> { 'Currency', 'Double','Percent','DateTime','Date','INTEGER'};
	String fieldsToQuery;

	public Map<String, Object> getActivatedRules(Map<String, Object> input) {
		Map<String, Object> activatedRules = new Map<String, Object>();
		if (!input.containsKey('ruleConfiguration')) {
			throw new dh_SingleRuleEvaluatorException('Evaluator is expecting rules to parse');
		}

		inputRules = (dh_RuleConfiguration)input.get('ruleConfiguration');

		String[] types = new String[] {inputRules.sObjectName};
		Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
		Map<String, Schema.SObjectField> fieldMap = results[0].fields.getMap();

		for (dh_RuleConfiguration.selectedPicklistValues eachField : inputRules.selectedPicklistValues) {
			selectedFieldValuesMap.put(eachField.field, eachField.value);
			fieldDataTypeMap.put(eachField.field, String.valueOf(fieldMap.get(eachField.field).getDescribe().getType()));
		}

		fieldsToQuery = inputRules.pickListConfiguration.fieldsToQueryAPIName;
		String queryString = 'Select '+fieldsToQuery+' FROM '+inputRules.sObjectName+' WHERE Id=\''
							+String.escapeSingleQuotes(inputRules.currentRecordId)+'\'';
		currentRecord = Database.query(queryString);

		for (String field : fieldsToQuery.split(',')) {
			fieldDataTypeMap.put(field, String.valueOf(fieldMap.get(field).getDescribe().getType()));
		}

		List<dh_RuleConfiguration.Rules> rulesPassed = new List<dh_RuleConfiguration.Rules>();
		for (dh_RuleConfiguration.Rules eachRule : inputRules.PickListConfiguration.rules) {
			Boolean applyAction = True;
			for (dh_RuleConfiguration.Conditions eachCondition : eachRule.Conditions) {
				applyAction = (applyAction && conditionEvaluator(eachCondition));
			}
			if (applyAction) {
				rulesPassed.add(eachRule);
			}
			activatedRules.put('rulesPassed', rulesPassed);
		}

		return activatedRules;
	}

	public Boolean conditionEvaluator(dh_RuleConfiguration.Conditions eachCondition){

		String fieldValue;
		if(selectedFieldValuesMap != null && !selectedFieldValuesMap.isEmpty() && selectedFieldValuesMap.containsKey(eachCondition.attribute)) {
			fieldValue =  selectedFieldValuesMap.get(eachCondition.attribute);
		}
		else if (String.isNotBlank(fieldsToQuery) && fieldsToQuery.contains(eachCondition.attribute)) {
			fieldValue = (String)currentRecord[0].get(eachCondition.attribute);
		}
		else {
			String errorMessage = 'Conditional field should be added to fieldsToQueryAPIName or it is should be part of selected dependant fields';
			throw new dh_SingleRuleEvaluatorException( errorMessage );
		}

		if (String.isBlank(fieldValue)) {
			return false;
		}

		if ( eachCondition.operator.trim().equalsIgnoreCase('IN')) {
			return eachCondition.value.containsIgnoreCase(fieldValue);
		}
		else if (eachCondition.operator.trim().equalsIgnoreCase('NOT IN')) {
			return !eachCondition.value.containsIgnoreCase(fieldValue);
		}
		else if (eachCondition.operator.trim().equalsIgnoreCase('=')) {
			return eachCondition.value.equalsIgnoreCase(fieldValue);
		}
		else if (eachCondition.operator.trim().equalsIgnoreCase('!=')) {
			return !eachCondition.value.equalsIgnoreCase(fieldValue);
		}
		else if (eachCondition.operator.trim().equalsIgnoreCase('<') && fieldDataTypeMap.containsKey(eachCondition.attribute)
				&& supportedOperator.contains(fieldDataTypeMap.get(eachCondition.attribute))  ) {
			return (eachCondition.value < fieldValue);
		}
		else if (eachCondition.operator.trim().equalsIgnoreCase('>') && fieldDataTypeMap.containsKey(eachCondition.attribute)
				&& supportedOperator.contains(fieldDataTypeMap.get(eachCondition.attribute))  ) {
			return (eachCondition.value > fieldValue);
		}
		else if (eachCondition.operator.trim().equalsIgnoreCase('>=') && fieldDataTypeMap.containsKey(eachCondition.attribute)
				&& supportedOperator.contains(fieldDataTypeMap.get(eachCondition.attribute))  ) {
			return (eachCondition.value >= fieldValue);
		}
		else if (eachCondition.operator.trim().equalsIgnoreCase('<=') && fieldDataTypeMap.containsKey(eachCondition.attribute)
				&& supportedOperator.contains(fieldDataTypeMap.get(eachCondition.attribute))  ) {
			return (eachCondition.value <= fieldValue);
		}
		return false;
	}

	public class dh_SingleRuleEvaluatorException extends Exception {}
}