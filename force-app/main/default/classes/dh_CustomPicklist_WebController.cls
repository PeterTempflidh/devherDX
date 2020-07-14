/**
 * Created by Sudhakar 31/4/2020
 */
// This class is the facade layer for the picklist component, the responsibility of this class is to make sure that the
// correct composition of rule engine services is done and the result will be transformed into the expected format.
public with sharing class dh_CustomPicklist_WebController {

	@AuraEnabled
	public static String getPicklistValues( String jsonString ){
		Map<String, Object> input = new Map<String, Object>();
		if (String.isEmpty(jsonString)) {
			throw new dh_CustomPicklist_WebControllerException('There is no configuration');
		}

		input.putAll((Map<String, Object>)JSON.deserializeUntyped(jsonString)) ;

		String serializedSetOfResultingPicklist = '[]';

		// We need to verify all the parameters coming from the front end
		if( !input.containsKey('currentRecordId') ) {
			throw new dh_CustomPicklist_WebControllerException('There is no record Id');
		}

		if( !input.containsKey('picklistFieldAPIName') ) {
			throw new dh_CustomPicklist_WebControllerException('There is no a picklist API Name declared');
		}

		if( !input.containsKey('pickListConfiguration') ) {
			throw new dh_CustomPicklist_WebControllerException('There is no configuration for field');
		}

		if( !input.containsKey('sObjectName') ) {
			throw new dh_CustomPicklist_WebControllerException('There is no object name to query');
		}

		String selectedRuleSelectorName = 'dh_JsonRuleSelector';
		String selectedRuleEvaluatorName = 'dh_SingleRuleEvaluator';
		String selectedRuleApplierName = 'dh_PickListOperationApplier';

		dh_RuleEngine ruleEngine = new dh_RuleEngine( selectedRuleSelectorName, selectedRuleEvaluatorName, selectedRuleApplierName );
		Map<String, Object> engineInput = new Map<String, Object> {'jsonConfiguration'=>jsonString};
		Map<String, Object> selectedPicklistData = new Map<String, Object> {
			(String)input.get('picklistFieldAPIName') => ruleEngine.executeRules( engineInput ).get('valuesMap')
		};

		serializedSetOfResultingPicklist = !selectedPicklistData.isEmpty() ? JSON.serialize( selectedPicklistData ) : '[]';

		return serializedSetOfResultingPicklist;
	}

	public class dh_CustomPicklist_WebControllerException extends Exception {}
}