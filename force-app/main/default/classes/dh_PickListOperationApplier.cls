/**
   Created by Sudhakar 31/4/2020
 */

public inherited sharing class dh_PickListOperationApplier implements dh_IRuleApplier {

	public Map<String, Object> applyActivatedRules(Map<String, Object> input) {

		List<Map<String,String> > listOfValueMaps = new List<Map<String,String> >();
		Map<String, Object> actionsOutput = new Map<String, Object>();
		List<String> allValuesList = new List<String>();
		Map<String,Integer> valueCounterMap = new Map<String,Integer>();
		List<dh_RuleConfiguration.Actions> actionsToApply = new List<dh_RuleConfiguration.Actions>();

		if (!input.containsKey('rulesPassed')) {
			throw new dh_PickListOperationApplierException('Rule applier is expecting rules');
		}

		for (dh_RuleConfiguration.Rules eachRule : (List<dh_RuleConfiguration.Rules>)input.get('rulesPassed')) {
			actionsToApply.addAll(eachRule.actions);
		}

		if (actionsToApply.isEmpty()) {
			System.debug(LoggingLevel.WARN, 'The actions are empty for the rules');
		}

		for (dh_RuleConfiguration.Actions eachAction : actionsToApply) {
			allValuesList.addAll(eachAction.value.split(','));
		}

		if (allValuesList.isEmpty()) {
			System.debug(LoggingLevel.WARN, 'The values are empty for the actions');
		}

		for (String key : allValuesList) {
			if (valueCounterMap.containsKey(key)) {
				valueCounterMap.put(key, valueCounterMap.get(key)+1);
			}
			else {
				valueCounterMap.put(key, 1);
			}
		}

		for (String val : valueCounterMap.keySet()) {
			if (valueCounterMap.get(val) == actionsToApply.size()) {
				Map<String,String> valuesMap = new Map<String,String> {
					'value' => val,
					'label' => val,
					'active' => val,
					'defaultValue' => val,
					'validFor' => val
				};
				listOfValueMaps.add(valuesMap);
			}
		}
		actionsOutput.put('valuesMap', listOfValueMaps);

		return actionsOutput;
	}

	public class dh_PickListOperationApplierException extends Exception {}
}