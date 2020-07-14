/**
 * Created by Sudhakar 31/4/2020
 */
// This class would be the base class for all engines that want to have all three pieces of the engine with the rule
// selector optional.
// Can throw exceptions dh_RuleEngineException and all the exceptions from the classes that contains.
public inherited sharing virtual class dh_RuleEngine implements dh_IRuleEngine {

	protected dh_IRuleSelector ruleSelector;
	protected dh_IRuleEvaluator ruleEvaluator;
	protected dh_IRuleApplier ruleApplier;

	public dh_RuleEngine( String ruleSelectorType, String ruleEvaluatorType, String ruleApplierType ){

		// The minimum form of the engine is to have an applier and an evaluator, there can be an external selector which
		// will provide the evaluator and the applier with the correctly formatted information.
		if( String.isEmpty( ruleEvaluatorType ) || String.isEmpty( ruleApplierType ) ) {
			String errorMessage = String.format('One of the following values [{0}] [{1}] is not valid as a name', new List<String> { ruleEvaluatorType, ruleApplierType} );
			throw new dh_RuleEngineException( errorMessage );
		}

		ruleApplier = (dh_IRuleApplier) Type.forName( ruleApplierType ).newInstance();
		ruleEvaluator = (dh_IRuleEvaluator) Type.forName( ruleEvaluatorType ).newInstance();

		if( String.isNotEmpty( ruleSelectorType ) ) {
			ruleSelector = (dh_IRuleSelector) Type.forName( ruleSelectorType ).newInstance();
		} else{
			System.debug( LoggingLevel.WARN, 'There is no selector type defined for this engine');
		}
	}

	public Map<String, Object> executeRules( Map<String, Object> input ) {
		Map<String,Object> ruleExecutionOutput = new Map<String, Object>();
		getRules( input );
		evaluateRules( input );
		ruleExecutionOutput.putAll( applyActions( input ) );
		return ruleExecutionOutput;
	}

	public virtual Map<String, Object> getRules( Map<String, Object> input ) {
		Map<String,Object> selectedRules = new Map<String, Object>();
		selectedRules = ruleSelector != null ? ruleSelector.getSetOfRules( input ) : new Map<String,Object>();
		input.putAll(selectedRules);
		return selectedRules;
	}

	public virtual Map<String, Object> evaluateRules( Map<String, Object> input ) {
		Map<String,Object> activatedRules = new Map<String, Object>();
		activatedRules = ruleEvaluator.getActivatedRules( input );
		input.putAll( activatedRules );
		return activatedRules;
	}

	public virtual Map<String, Object> applyActions( Map<String, Object> input ) {
		Map<String,Object> ruleApplicationOutput = new Map<String, Object>();
		ruleApplicationOutput = ruleApplier.applyActivatedRules( input );
		return ruleApplicationOutput;
	}

	public class dh_RuleEngineException extends Exception {}
}